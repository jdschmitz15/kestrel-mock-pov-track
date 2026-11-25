# Windows VEN practice host: traffic-generator listens on 9443 and talks to its neighbours,
# plus the preflight command.
$ErrorActionPreference = "Stop"
#@psfile assets/bin/preflight.ps1 C:\kestrel\preflight.ps1
#@psfile assets/bin/preflight.cmd C:\Windows\preflight.cmd
# Lab traffic between the servers (rows in assets/traffic/traffic.csv)
#@psfile assets/traffic/traffic.csv C:\kestrel\traffic\traffic.csv
#@psfile assets/windows/install-traffic.ps1 C:\kestrel\install-traffic.ps1
& powershell -NoProfile -ExecutionPolicy Bypass -File C:\kestrel\install-traffic.ps1
if ($LASTEXITCODE -ne 0) { Write-Output "FAIL: traffic-generator install"; exit 1 }
