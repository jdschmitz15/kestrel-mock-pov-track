# Claims database tier (Windows): SQL Server 2022 Express on 1433, plus the preflight command.
$ErrorActionPreference = "Stop"
#@psfile assets/windows/install-sql-express.ps1 C:\kestrel\install-sql-express.ps1
#@psfile assets/bin/preflight.ps1 C:\kestrel\preflight.ps1
#@psfile assets/bin/preflight.cmd C:\Windows\preflight.cmd
& powershell -NoProfile -ExecutionPolicy Bypass -File C:\kestrel\install-sql-express.ps1
if ($LASTEXITCODE -ne 0) { Write-Output "FAIL: SQL Express install"; exit 1 }
