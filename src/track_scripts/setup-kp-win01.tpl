# Windows VEN practice host: ncat listener on 9443, plus the preflight command.
$ErrorActionPreference = "Stop"
#@psfile assets/windows/install-ncat.ps1 C:\kestrel\install-ncat.ps1
#@psfile assets/bin/preflight.ps1 C:\kestrel\preflight.ps1
#@psfile assets/bin/preflight.cmd C:\Windows\preflight.cmd
& powershell -NoProfile -ExecutionPolicy Bypass -File C:\kestrel\install-ncat.ps1
if ($LASTEXITCODE -ne 0) { Write-Output "FAIL: ncat install"; exit 1 }
