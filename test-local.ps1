# Local Test and Coverage Script
# This script runs tests and generates coverage report locally

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Local Test & Coverage Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if JAVA_HOME is set
if (-not $env:JAVA_HOME) {
    Write-Host "⚠ WARNING: JAVA_HOME is not set!" -ForegroundColor Yellow
    Write-Host "Attempting to find Java installation..." -ForegroundColor Yellow
    
    # Try to find java.exe in common locations
    $javaExePaths = @(
        "C:\Program Files\Java\jdk-17\bin\java.exe",
        "C:\Program Files\Java\jdk-21\bin\java.exe",
        "C:\Program Files\Eclipse Adoptium\jdk-17*\bin\java.exe",
        "C:\Program Files\Eclipse Adoptium\jdk-21*\bin\java.exe",
        "C:\Program Files (x86)\Java\jdk-17\bin\java.exe",
        "C:\Program Files (x86)\Java\jdk-21\bin\java.exe"
    )
    
    $found = $false
    foreach ($javaExe in $javaExePaths) {
        $resolved = Get-ChildItem $javaExe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($resolved) {
            $javaHome = $resolved.Directory.Parent.FullName
            $env:JAVA_HOME = $javaHome
            Write-Host "✓ Found Java at: $env:JAVA_HOME" -ForegroundColor Green
            $found = $true
            break
        }
    }
    
    # Also check registry for Java installations
    if (-not $found) {
        try {
            $javaKeys = Get-ChildItem "HKLM:\SOFTWARE\JavaSoft\Java Development Kit" -ErrorAction SilentlyContinue
            foreach ($key in $javaKeys) {
                $javaHome = $key.GetValue("JavaHome")
                if ($javaHome -and (Test-Path "$javaHome\bin\java.exe")) {
                    $env:JAVA_HOME = $javaHome
                    Write-Host "✓ Found Java in registry: $env:JAVA_HOME" -ForegroundColor Green
                    $found = $true
                    break
                }
            }
        } catch {
            # Registry access might fail, continue
        }
    }
    
    if (-not $found) {
        Write-Host "✗ Could not find Java installation automatically." -ForegroundColor Red
        Write-Host ""
        Write-Host "Please install Java 17 or higher, or set JAVA_HOME manually:" -ForegroundColor Yellow
        Write-Host '  $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"' -ForegroundColor Yellow
        Write-Host ""
        Write-Host "You can download Java from:" -ForegroundColor Cyan
        Write-Host "  https://adoptium.net/" -ForegroundColor White
        exit 1
    }
} else {
    Write-Host "✓ JAVA_HOME is set: $env:JAVA_HOME" -ForegroundColor Green
}

# Verify Java is accessible
$javaExe = "$env:JAVA_HOME\bin\java.exe"
if (-not (Test-Path $javaExe)) {
    Write-Host "✗ Java executable not found at: $javaExe" -ForegroundColor Red
    Write-Host "Please check your JAVA_HOME setting." -ForegroundColor Yellow
    exit 1
}

# Check if mvnw.cmd exists
if (-not (Test-Path "mvnw.cmd")) {
    Write-Host "✗ mvnw.cmd not found in current directory!" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Running tests..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray
.\mvnw.cmd clean test

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Tests failed! Fix errors before checking coverage." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Checking test results..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

# Count test files compiled
$testFiles = (Get-ChildItem -Recurse target\test-classes\**\*Test.class -ErrorAction SilentlyContinue).Count
Write-Host "Test classes compiled: $testFiles" -ForegroundColor $(if ($testFiles -ge 6) { "Green" } else { "Yellow" })

if ($testFiles -lt 6) {
    Write-Host "⚠ WARNING: Expected 6 test files, but only found $testFiles" -ForegroundColor Yellow
    Write-Host "This might indicate a compilation issue." -ForegroundColor Yellow
}

# Check if jacoco.exec exists
if (Test-Path "target\jacoco.exec") {
    $execSize = (Get-Item "target\jacoco.exec").Length
    Write-Host "✓ Coverage data file exists: target\jacoco.exec ($([math]::Round($execSize/1KB, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "✗ Coverage data file NOT found: target\jacoco.exec" -ForegroundColor Red
    Write-Host "Tests may not have run with JaCoCo agent." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 3: Generating coverage report..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray
.\mvnw.cmd jacoco:report

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Failed to generate coverage report!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 4: Verifying coverage files..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$coverageFiles = @(
    @{Path="target\jacoco.exec"; Name="Coverage execution data"},
    @{Path="target\site\jacoco\jacoco.xml"; Name="Coverage XML report"},
    @{Path="target\site\jacoco\index.html"; Name="Coverage HTML report"}
)

$allExist = $true
foreach ($file in $coverageFiles) {
    if (Test-Path $file.Path) {
        $size = (Get-Item $file.Path).Length
        Write-Host "✓ $($file.Name): $($file.Path) ($([math]::Round($size/1KB, 2)) KB)" -ForegroundColor Green
    } else {
        Write-Host "✗ $($file.Name): NOT FOUND" -ForegroundColor Red
        $allExist = $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($allExist) {
    Write-Host "✓ All checks passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Opening coverage report..." -ForegroundColor Yellow
    Start-Process "target\site\jacoco\index.html"
    Write-Host ""
    Write-Host "Coverage report location:" -ForegroundColor Cyan
    Write-Host "  target\site\jacoco\index.html" -ForegroundColor White
} else {
    Write-Host "⚠ Some coverage files are missing!" -ForegroundColor Yellow
    Write-Host "Check the output above for details." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

