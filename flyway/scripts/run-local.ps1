Param(
  [Parameter(Mandatory=$true)]
  [string]$Keyspace,

  [Parameter(Mandatory=$true)]
  [string]$Token,

  [Parameter(Mandatory=$true)]
  [string]$SecureConnectBundleZipPath,

  [string]$FlywayVersion = "10.17.0",
  [string]$JdbcWrapperVersion = "4.16.0"
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

$toolsDir = Join-Path $root ".tools"
$flywayDir = Join-Path $toolsDir "flyway"
$jarDir = Join-Path $toolsDir "jars"
New-Item -ItemType Directory -Force -Path $flywayDir, $jarDir | Out-Null

Write-Host "== Download Flyway CLI $FlywayVersion =="

$flywayZip = Join-Path $toolsDir "flyway.zip"
$flywayUrl = "https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$FlywayVersion/flyway-commandline-$FlywayVersion-windows-x64.zip"
Invoke-WebRequest -Uri $flywayUrl -OutFile $flywayZip

Expand-Archive -Path $flywayZip -DestinationPath $flywayDir -Force
$flywayExe = Get-ChildItem -Path $flywayDir -Recurse -Filter "flyway.cmd" | Select-Object -First 1
if (-not $flywayExe) { throw "Flyway executable not found after extraction." }

Write-Host "== Download Cassandra JDBC Wrapper $JdbcWrapperVersion =="
$jarUrl = "https://repo1.maven.org/maven2/com/ing/data/cassandra-jdbc-wrapper/$JdbcWrapperVersion/cassandra-jdbc-wrapper-$JdbcWrapperVersion.jar"
$jarPath = Join-Path $jarDir "cassandra-jdbc-wrapper-$JdbcWrapperVersion.jar"
Invoke-WebRequest -Uri $jarUrl -OutFile $jarPath

Write-Host "== Run Flyway migrate against AstraDB =="
& $flywayExe.FullName `
  "-configFiles=flyway/conf/flyway.conf" `
  "-jarDirs=$jarDir" `
  "-url=jdbc:cassandra:dbaas:///$Keyspace?secureconnectbundle=$SecureConnectBundleZipPath&user=token&password=$Token" `
  migrate
