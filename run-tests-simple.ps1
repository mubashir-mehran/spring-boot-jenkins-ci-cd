# Simple test runner - handles Java path with spaces
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Running Tests & Coverage" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verify Java
$javaExe = "$env:JAVA_HOME\bin\java.exe"
if (-not (Test-Path $javaExe)) {
    Write-Host "✗ Java not found at: $javaExe" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Java found: $env:JAVA_HOME" -ForegroundColor Green
& $javaExe -version
Write-Host ""

# Use Maven wrapper with proper quoting
Write-Host "Step 1: Running tests..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

# Set JAVA_HOME in the environment for the batch file
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot"

# Run Maven wrapper
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot"
& cmd.exe /c "set JAVA_HOME=$env:JAVA_HOME & mvnw.cmd clean test"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Tests failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Checking test results..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$testClasses = Get-ChildItem -Recurse target\test-classes\**\*Test.class -ErrorAction SilentlyContinue
$testCount = ($testClasses | Measure-Object).Count
Write-Host "Test classes compiled: $testCount" -ForegroundColor $(if ($testCount -ge 6) { "Green" } else { "Yellow" })

if (Test-Path "target\jacoco.exec") {
    $size = (Get-Item "target\jacoco.exec").Length
    Write-Host "✓ Coverage data: target\jacoco.exec ($([math]::Round($size/1KB, 2)) KB)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 3: Generating coverage report..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

& cmd.exe /c "set JAVA_HOME=$env:JAVA_HOME & mvnw.cmd jacoco:report"

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to generate coverage report!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 4: Opening coverage report..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$reportPath = "target\site\jacoco\index.html"
if (Test-Path $reportPath) {
    Write-Host "✓ Coverage report generated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Opening coverage report..." -ForegroundColor Yellow
    Start-Process $reportPath
    Write-Host ""
    Write-Host "Coverage report: $((Resolve-Path $reportPath).Path)" -ForegroundColor Cyan
} else {
    Write-Host "✗ Coverage report NOT found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

