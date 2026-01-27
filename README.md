# astradb-flyway-cql-poc
Proof of Concept for managing DataStax AstraDB schema changes using Flyway and CQL scripts via GitHub Actions CI/CD pipeline.

## Prereqs
- Astra DB token (Application Token)
- Secure Connect Bundle ZIP for the DB
- A keyspace already created (or create it first)

## Local run (Windows PowerShell)
```powershell
.\scripts\run-local.ps1 `
  -Keyspace "your_keyspace" `
  -Token "AstraCS:..." `
  -SecureConnectBundleZipPath "C:\path\secure-connect-yourdb.zip"
