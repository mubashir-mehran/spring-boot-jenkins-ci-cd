# Simple Test Runner Script
# This script helps you run tests and check coverage locally

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test & Coverage Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to find Java
function Find-Java {
    # Check JAVA_HOME first
    if ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
        return $env:JAVA_HOME
    }
    
    # Try common locations
    $paths = @(
        "C:\Program Files\Java\jdk-17",
        "C:\Program Files\Java\jdk-21",
        "C:\Program Files\Eclipse Adoptium\jdk-17*",
        "C:\Program Files\Eclipse Adoptium\jdk-21*"
    )
    
    foreach ($path in $paths) {
        $resolved = Get-ChildItem $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($resolved -and (Test-Path "$($resolved.FullName)\bin\java.exe")) {
            return $resolved.FullName
        }
    }
    
    return $null
}

# Find Java
Write-Host "Looking for Java..." -ForegroundColor Yellow
$javaHome = Find-Java

if (-not $javaHome) {
    Write-Host "✗ Java not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Java 17 or higher:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://adoptium.net/" -ForegroundColor Cyan
    Write-Host "  2. Install Java JDK 17 or 21" -ForegroundColor Cyan
    Write-Host "  3. Set JAVA_HOME:" -ForegroundColor Cyan
    Write-Host '     $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.x-hotspot"' -ForegroundColor White
    Write-Host ""
    exit 1
}

$env:JAVA_HOME = $javaHome
Write-Host "✓ Found Java: $javaHome" -ForegroundColor Green
Write-Host ""

# Check for Maven
Write-Host "Checking for Maven..." -ForegroundColor Yellow
$mvnCmd = $null

# Try Maven wrapper first
if (Test-Path "mvnw.cmd") {
    $mvnCmd = ".\mvnw.cmd"
    Write-Host "✓ Using Maven Wrapper (mvnw.cmd)" -ForegroundColor Green
} elseif (Get-Command mvn -ErrorAction SilentlyContinue) {
    $mvnCmd = "mvn"
    Write-Host "✓ Using Maven (mvn)" -ForegroundColor Green
} else {
    Write-Host "✗ Maven not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  1. Install Maven: https://maven.apache.org/download.cgi" -ForegroundColor Cyan
    Write-Host "  2. Or use the Maven Wrapper (mvnw.cmd should exist)" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 1: Running Tests" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Run tests
& $mvnCmd clean test

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Tests failed! Exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "Please fix the errors above before continuing." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 2: Checking Test Results" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Count compiled test files
$testClasses = Get-ChildItem -Recurse target\test-classes\**\*Test.class -ErrorAction SilentlyContinue
$testCount = ($testClasses | Measure-Object).Count

Write-Host "Test classes compiled: $testCount" -ForegroundColor $(if ($testCount -ge 6) { "Green" } else { "Yellow" })

if ($testCount -lt 6) {
    Write-Host "⚠ WARNING: Expected 6 test files, but found $testCount" -ForegroundColor Yellow
    Write-Host "This might indicate a compilation issue." -ForegroundColor Yellow
}

# Check coverage file
if (Test-Path "target\jacoco.exec") {
    $size = (Get-Item "target\jacoco.exec").Length
    Write-Host "✓ Coverage data: target\jacoco.exec ($([math]::Round($size/1KB, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "✗ Coverage data NOT found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 3: Generating Coverage Report" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Generate coverage report
& $mvnCmd jacoco:report

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Failed to generate coverage report!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 4: Opening Coverage Report" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if report exists
$reportPath = "target\site\jacoco\index.html"
if (Test-Path $reportPath) {
    Write-Host "✓ Coverage report generated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Opening coverage report..." -ForegroundColor Yellow
    Start-Process $reportPath
    Write-Host ""
    Write-Host "Coverage report location:" -ForegroundColor Cyan
    Write-Host "  $((Resolve-Path $reportPath).Path)" -ForegroundColor White
} else {
    Write-Host "✗ Coverage report NOT found at: $reportPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan





