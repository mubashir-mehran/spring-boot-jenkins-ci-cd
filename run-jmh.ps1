# JMH Microbenchmark Runner Script
# This script compiles and runs JMH benchmarks, then generates reports

Write-Host "JMH Microbenchmark Runner" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if Java is available
$javaVersion = & java -version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[INFO] Java not in PATH. Trying to find Java..." -ForegroundColor Yellow
    
    # Try to find Java
    $javaPaths = @(
        "C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot\bin\java.exe",
        "C:\Program Files\Eclipse Adoptium\jdk-17*\bin\java.exe",
        "C:\Program Files\Java\jdk-21*\bin\java.exe",
        "C:\Program Files\Java\jdk-17*\bin\java.exe",
        "$env:JAVA_HOME\bin\java.exe"
    )
    
    $foundJava = $false
    foreach ($path in $javaPaths) {
        $resolvedPath = Resolve-Path $path -ErrorAction SilentlyContinue
        if ($resolvedPath -and (Test-Path $resolvedPath)) {
            $javaHome = Split-Path (Split-Path $resolvedPath -Parent) -Parent
            $env:JAVA_HOME = $javaHome
            $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
            Write-Host "[OK] Found Java at: $javaHome" -ForegroundColor Green
            $foundJava = $true
            break
        }
    }
    
    if (-not $foundJava) {
        Write-Host "[ERROR] Java not found. Please install Java 17 or 21 and set JAVA_HOME." -ForegroundColor Red
        exit 1
    }
    
    $javaVersion = & java -version 2>&1 | Select-Object -First 1
}
Write-Host "[OK] Java found: $javaVersion" -ForegroundColor Green

# Ensure JAVA_HOME is set for Maven
if (-not $env:JAVA_HOME) {
    $javaExe = Get-Command java -ErrorAction SilentlyContinue
    if ($javaExe) {
        $javaPath = $javaExe.Path
        $env:JAVA_HOME = Split-Path (Split-Path $javaPath -Parent) -Parent
        Write-Host "[INFO] Set JAVA_HOME to: $env:JAVA_HOME" -ForegroundColor Gray
    }
}

Write-Host ""

# Check if Maven is available
$mvnCmd = $null
if (Test-Path ".\mvnw.cmd") {
    $mvnCmd = ".\mvnw.cmd"
    Write-Host "[OK] Using Maven wrapper" -ForegroundColor Green
} elseif (Get-Command mvn -ErrorAction SilentlyContinue) {
    $mvnCmd = "mvn"
    Write-Host "[OK] Using system Maven" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Maven not found. Please install Maven or use Maven wrapper." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Create results directory
$resultsDir = Join-Path (Get-Location).Path "target\jmh-results"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
    Write-Host "[OK] Created results directory: $resultsDir" -ForegroundColor Green
}

Write-Host "[INFO] Compiling project and benchmarks..." -ForegroundColor Yellow
& $mvnCmd clean compile -q
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Compilation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Compilation successful" -ForegroundColor Green
Write-Host ""

Write-Host "[INFO] Running JMH benchmarks..." -ForegroundColor Cyan
Write-Host "This may take several minutes..." -ForegroundColor Yellow
Write-Host ""

# Run all benchmarks
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultsFile = Join-Path $resultsDir "jmh-results-$timestamp.txt"
$jsonFile = Join-Path $resultsDir "jmh-results-$timestamp.json"

# Create empty files first to ensure they can be written
New-Item -ItemType File -Path $resultsFile -Force | Out-Null
New-Item -ItemType File -Path $jsonFile -Force | Out-Null

# Use relative paths from project root for Java
$resultsFileJava = "target/jmh-results/jmh-results-$timestamp.txt"
$jsonFileJava = "target/jmh-results/jmh-results-$timestamp.json"

# Use Maven exec plugin to run benchmarks
Write-Host "[INFO] Using Maven exec plugin to run benchmarks..." -ForegroundColor Yellow

# Run with JSON output - use wildcard to find all benchmarks, disable forking
$argsString = ".*Benchmark -f 0 -rf json -rff $jsonFileJava"
& $mvnCmd exec:java "-Dexec.mainClass=org.openjdk.jmh.Main" "-Dexec.args=$argsString" "-Dexec.classpathScope=compile" -q

if ($LASTEXITCODE -eq 0) {
    # Run again with text output
    Write-Host "[INFO] Generating text report..." -ForegroundColor Yellow
    $argsString = ".*Benchmark -f 0 -rf text -rff $resultsFileJava"
    & $mvnCmd exec:java "-Dexec.mainClass=org.openjdk.jmh.Main" "-Dexec.args=$argsString" "-Dexec.classpathScope=compile" -q
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Benchmarks completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Results:" -ForegroundColor Cyan
    Write-Host "  Text report: $resultsFile" -ForegroundColor White
    Write-Host "  JSON report: $jsonFile" -ForegroundColor White
    Write-Host ""
    
    # Display summary
    if (Test-Path $resultsFile) {
        Write-Host "Benchmark Summary:" -ForegroundColor Cyan
        Write-Host "==================" -ForegroundColor Cyan
        Get-Content $resultsFile | Select-Object -First 50
        Write-Host ""
        Write-Host "[INFO] Full report saved to: $resultsFile" -ForegroundColor Yellow
        Write-Host "[INFO] Opening report..." -ForegroundColor Yellow
        Start-Process notepad.exe $resultsFile
    }
} else {
    Write-Host "[ERROR] Benchmark execution failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
