# kp-sql01: SQL Server 2022 Express with the Kestrel Point claims database on TCP 1433.
$ErrorActionPreference = "Stop"
Set-ExecutionPolicy Bypass -Scope Process -Force
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  $env:Path += ";$env:ProgramData\chocolatey\bin"
}
if (-not (Get-Service 'MSSQL$SQLEXPRESS' -ErrorAction SilentlyContinue)) {
  choco install sql-server-express -y --no-progress
}

# Mixed-mode auth and a fixed TCP port 1433
$inst = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').SQLEXPRESS
$base = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$inst\MSSQLServer"
Set-ItemProperty -Path $base -Name LoginMode -Value 2
Set-ItemProperty -Path "$base\SuperSocketNetLib\Tcp" -Name Enabled -Value 1
Set-ItemProperty -Path "$base\SuperSocketNetLib\Tcp\IPAll" -Name TcpPort -Value '1433'
Set-ItemProperty -Path "$base\SuperSocketNetLib\Tcp\IPAll" -Name TcpDynamicPorts -Value ''
Restart-Service -Name 'MSSQL$SQLEXPRESS' -Force
Start-Sleep -Seconds 10

function Invoke-Sql([string]$sql, [string]$db = 'master') {
  $c = New-Object System.Data.SqlClient.SqlConnection "Server=localhost\SQLEXPRESS;Database=$db;Integrated Security=true"
  $c.Open(); $cmd = $c.CreateCommand(); $cmd.CommandText = $sql; [void]$cmd.ExecuteNonQuery(); $c.Close()
}

Invoke-Sql "IF DB_ID('claims') IS NULL CREATE DATABASE claims"
Invoke-Sql @"
IF OBJECT_ID('claims') IS NULL BEGIN
  CREATE TABLE claims (claim_id INT IDENTITY PRIMARY KEY, policy NVARCHAR(20), status NVARCHAR(20), amount DECIMAL(10,2));
  INSERT INTO claims (policy, status, amount) VALUES
   ('KP-100231','Open',1250.00),('KP-100877','Paid',830.50),('KP-101004','Review',12000.00),
   ('KP-101118','Open',455.25),('KP-101552','Denied',2999.99),('KP-102010','Paid',640.00);
END
"@ 'claims'
foreach ($l in @(@('kpapp','Kestrel-Claims-2026!'), @('kpreport','Kestrel-Report-2026!'))) {
  $n = $l[0]; $p = $l[1]
  Invoke-Sql "IF SUSER_ID('$n') IS NULL CREATE LOGIN [$n] WITH PASSWORD = '$p', CHECK_POLICY = OFF"
  Invoke-Sql "IF USER_ID('$n') IS NULL BEGIN CREATE USER [$n] FOR LOGIN [$n]; ALTER ROLE db_datareader ADD MEMBER [$n]; END" 'claims'
}

if (-not (Get-NetFirewallRule -DisplayName 'Kestrel SQL 1433' -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -DisplayName 'Kestrel SQL 1433' -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow | Out-Null
}
Write-Output "SQL Express ready on 1433"
