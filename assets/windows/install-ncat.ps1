# kp-win01: Nmap's ncat (Windows has no built-in nc) and a listener on 9443 that survives reboots.
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dir = 'C:\kestrel\ncat'
if (-not (Test-Path "$dir\ncat.exe")) {
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $zip = "$env:TEMP\ncat.zip"
  Invoke-WebRequest -UseBasicParsing -Uri 'https://nmap.org/dist/ncat-portable-5.59BETA1.zip' -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath "$env:TEMP\ncat" -Force
  Copy-Item (Get-ChildItem "$env:TEMP\ncat" -Recurse -Filter ncat.exe | Select-Object -First 1).FullName "$dir\ncat.exe"
}
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
if ($machinePath -notlike "*$dir*") { [Environment]::SetEnvironmentVariable('Path', "$machinePath;$dir", 'Machine') }

if (-not (Get-NetFirewallRule -DisplayName 'Kestrel ncat 9443' -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -DisplayName 'Kestrel ncat 9443' -Direction Inbound -Protocol TCP -LocalPort 9443 -Action Allow | Out-Null
}
$action = New-ScheduledTaskAction -Execute "$dir\ncat.exe" -Argument '-lk 9443'
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName 'Kestrel ncat 9443' -Action $action -Trigger $trigger -User 'SYSTEM' -RunLevel Highest -Force | Out-Null
Start-ScheduledTask -TaskName 'Kestrel ncat 9443'
Write-Output "ncat listening on 9443"
