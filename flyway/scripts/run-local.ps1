Param(
  [Parameter(Mandatory=$true)][string]$Keyspace,
  [Parameter(Mandatory=$true)][string]$Token,
  [Parameter(Mandatory=$true)][string]$SecureConnectBundleZipPath,
  [string]$FlywayVersion = "10.20.1",  # Latest stable
  [string]$JdbcWrapperVersion = "4.16.0"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$toolsDir = Join-Path $root ".tools"
$flywayDir = Join-Path $toolsDir "flyway"
$jarDir = Join-Path $toolsDir "jars"
New-Item -ItemType Directory -Force -Path $toolsDir, $flywayDir, $jarDir | Out-Null

# Download Flyway
$flywayZip = Join-Path $toolsDir "flyway.zip"
$flywayUrl = "https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$FlywayVersion/flyway-commandline-$FlywayVersion-linux-x64.tar.gz"
Invoke-WebRequest -Uri $flywayUrl -OutFile $flywayZip
tar -xzf $flywayZip -C $toolsDir
$flywayExe = (Get-ChildItem -Path $toolsDir -Recurse -Filter "flyway" -Name "flyway" | Select-Object -First 1)
if (-not $flywayExe) { throw "Flyway not found" }

# Download JDBC Wrapper (included in Redgate but safe for OSS Flyway)
$jarUrl = "https://repo1.maven.org/maven2/com/ing/data/cassandra-jdbc-wrapper/$JdbcWrapperVersion/cassandra-jdbc-wrapper-$JdbcWrapperVersion.jar"
$jarPath = Join-Path $jarDir "cassandra-jdbc-wrapper-$JdbcWrapperVersion.jar"
Invoke-WebRequest -Uri $jarUrl -OutFile $jarPath

# Run with config + overrides
& $flywayExe.FullName `
  info `
  -configFiles=flyway/conf/flyway.conf `
  -jarDirs=$jarDir `
  -url="jdbc:cassandra:dbaas:///$Keyspace?secureconnectbundle=$SecureConnectBundleZipPath&user=token&password=$Token"

& $flywayExe.FullName `
  validate `
  -configFiles=flyway/conf/flyway.conf `
  -jarDirs=$jarDir `
  -url="jdbc:cassandra:dbaas:///$Keyspace?secureconnectbundle=$SecureConnectBundleZipPath&user=token&password=$Token"

& $flywayExe.FullName `
  migrate `
  -configFiles=flyway/conf/flyway.conf `
  -jarDirs=$jarDir `
  -url="jdbc:cassandra:dbaas:///$Keyspace?secureconnectbundle=$SecureConnectBundleZipPath&user=token&password=$Token"
