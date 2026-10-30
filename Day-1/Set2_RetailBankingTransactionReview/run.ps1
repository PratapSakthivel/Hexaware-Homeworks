# PowerShell runner for Set 2 - Retail Banking Transaction Review
$ErrorActionPreference = "Stop"

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Set-Location $PSScriptRoot

$javac = "C:\Program Files\Java\jdk-25.0.5.0.3\bin\javac.exe"
$java  = "C:\Program Files\Java\jdk-25.0.5.0.3\bin\java.exe"

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host " Compiling Set 2 - Retail Banking Suite..." -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

if (-not (Test-Path "bin")) {
    New-Item -ItemType Directory -Path "bin" | Out-Null
}

& $javac -d bin -sourcepath src src/com/hexaware/banking/Main.java

Write-Host "`n===================================================" -ForegroundColor Green
Write-Host " Running Set 2 - Retail Banking Suite..." -ForegroundColor Green
Write-Host "===================================================`n" -ForegroundColor Green

& $java -cp bin com.hexaware.banking.Main
