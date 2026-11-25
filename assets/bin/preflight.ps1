# Pre-flight check for one Windows host. Usage: preflight <pce-hostname>[:port]
param([Parameter(Mandatory=$true)][string]$Target)
$parts = $Target.Split(':'); $pceHost = $parts[0]; $port = if ($parts.Count -gt 1) { [int]$parts[1] } else { 443 }
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$sup = if ($os -match '2012 R2|2016|2019|2022|2025') { 'yes' } else { 'check' }
$net = if ((Test-NetConnection -ComputerName $pceHost -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded) { 'yes' } else { 'no' }
$result = if ($sup -eq 'yes' -and $net -eq 'yes') { 'PASS' } else { 'FAIL' }
$line = "$($env:COMPUTERNAME.ToLower()) | $os | VEN-supported: $sup | 443 to PCE: $net | $result"
Write-Output $line
New-Item -ItemType Directory -Force -Path C:\kestrel | Out-Null
Set-Content -Path C:\kestrel\preflight.txt -Value $line
