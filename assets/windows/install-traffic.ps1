# Install traffic-generator and run it in "continuous" mode from C:\kestrel\traffic\traffic.csv.
# The host listens on every row where it is dst and connects on every row where it is src.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$version = '1.0.5'
$dir = 'C:\kestrel\traffic'
$exe = "$dir\traffic-generator.exe"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
if (-not (Test-Path $exe)) {
  $zip = "$env:TEMP\traffic-generator.zip"
  Invoke-WebRequest -UseBasicParsing -OutFile $zip `
    -Uri "https://github.com/jdschmitz15/traffic-generator/releases/download/v$version/windows.zip"
  Expand-Archive -Path $zip -DestinationPath "$env:TEMP\tg" -Force
  Copy-Item "$env:TEMP\tg\windows\traffic-generator.exe" $exe -Force
}

# traffic-generator matches rows on the exact hostname, and Windows may report it in upper case.
# Swap this host's name for its IP address so the match always works.
$me = $env:COMPUTERNAME.ToLower()
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
       Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
       Select-Object -First 1).IPAddress
$rows = Import-Csv "$dir\traffic.csv"
foreach ($r in $rows) {
  if ($r.src.ToLower() -eq $me) { $r.src = $ip }
  if ($r.dst.ToLower() -eq $me) { $r.dst = $ip }
}
$rows | Export-Csv -NoTypeInformation -Encoding ASCII "$dir\traffic-local.csv"

# Allow the program through the Windows firewall for any listener port in the CSV.
if (-not (Get-NetFirewallRule -DisplayName 'Kestrel traffic-generator' -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -DisplayName 'Kestrel traffic-generator' -Direction Inbound -Program $exe -Action Allow | Out-Null
}

# Run at boot as SYSTEM; the log lands in the working directory.
$action = New-ScheduledTaskAction -Execute $exe -Argument "continuous $dir\traffic-local.csv" -WorkingDirectory $dir
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -RestartCount 99 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName 'Kestrel traffic-generator' -Action $action -Trigger $trigger -Settings $settings `
  -User 'SYSTEM' -RunLevel Highest -Force | Out-Null
Start-ScheduledTask -TaskName 'Kestrel traffic-generator'
Write-Output "traffic-generator running; log: $dir\traffic-generator.log"
