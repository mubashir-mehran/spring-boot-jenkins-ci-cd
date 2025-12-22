# Local Build Script for Spring Boot Application
# This script builds the application locally with all options

param(
    [switch]$SkipTests,
    [switch]$Clean,
    [switch]$Package,
    [switch]$Install,
    [switch]$Run,
    [switch]$Help
)

function Show-Help {
    Write-Host ""
    Write-Host "Local Build Script - Usage Guide" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Basic Usage:" -ForegroundColor Yellow
    Write-Host "  .\build-local.ps1                    # Clean build with tests"
    Write-Host "  .\build-local.ps1 -SkipTests         # Build without tests (faster)"
    Write-Host "  .\build-local.ps1 -Package           # Create JAR file"
    Write-Host "  .\build-local.ps1 -Install           # Install to local Maven repo"
    Write-Host "  .\build-local.ps1 -Run               # Build and run application"
    Write-Host ""
    Write-Host "Combined Options:" -ForegroundColor Yellow
    Write-Host "  .\build-local.ps1 -Clean -SkipTests  # Clean build, skip tests"
    Write-Host "  .\build-local.ps1 -Package -SkipTests # Package without tests"
    Write-Host ""
    Write-Host "Switches:" -ForegroundColor Yellow
    Write-Host "  -SkipTests    Skip running tests (faster build)"
    Write-Host "  -Clean        Clean before building"
    Write-Host "  -Package      Create executable JAR file"
    Write-Host "  -Install      Install to local Maven repository"
    Write-Host "  -Run          Run application after building"
    Write-Host "  -Help         Show this help message"
    Write-Host ""
    exit 0
}

if ($Help) {
    Show-Help
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Spring Boot Local Build" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Java
Write-Host "[1/5] Checking Java..." -ForegroundColor Yellow
$javaVersion = & java -version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[INFO] Java not in PATH. Searching..." -ForegroundColor Yellow
    
    $javaPaths = @(
        "C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot\bin\java.exe",
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
            Write-Host "   [OK] Found Java at: $javaHome" -ForegroundColor Green
            $foundJava = $true
            break
        }
    }
    
    if (-not $foundJava) {
        Write-Host "   [ERROR] Java not found!" -ForegroundColor Red
        Write-Host "   Please install Java 17 or 21" -ForegroundColor Yellow
        exit 1
    }
    
    $javaVersion = & java -version 2>&1 | Select-Object -First 1
}
Write-Host "   [OK] $javaVersion" -ForegroundColor Green

# Check Maven
Write-Host ""
Write-Host "[2/5] Checking Maven..." -ForegroundColor Yellow
$mvnCmd = $null
if (Test-Path ".\mvnw.cmd") {
    $mvnCmd = ".\mvnw.cmd"
    Write-Host "   [OK] Using Maven wrapper" -ForegroundColor Green
} elseif (Get-Command mvn -ErrorAction SilentlyContinue) {
    $mvnCmd = "mvn"
    $mvnVersion = & mvn -version | Select-Object -First 1
    Write-Host "   [OK] Using system Maven: $mvnVersion" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Maven not found!" -ForegroundColor Red
    exit 1
}

# Build command construction
Write-Host ""
Write-Host "[3/5] Preparing build command..." -ForegroundColor Yellow

$buildPhase = "compile"
$buildOptions = @()

if ($Clean) {
    $buildPhase = "clean $buildPhase"
    Write-Host "   [+] Clean build enabled" -ForegroundColor Cyan
}

if ($Package) {
    $buildPhase = $buildPhase -replace "compile", "package"
    Write-Host "   [+] Packaging enabled (will create JAR)" -ForegroundColor Cyan
}

if ($Install) {
    $buildPhase = $buildPhase -replace "(compile|package)", "install"
    Write-Host "   [+] Install to local repo enabled" -ForegroundColor Cyan
}

if ($SkipTests) {
    $buildOptions += "-DskipTests"
    Write-Host "   [+] Skipping tests (faster build)" -ForegroundColor Cyan
}

$buildCommand = "$buildPhase $($buildOptions -join ' ')"
Write-Host "   [OK] Build command: mvn $buildCommand" -ForegroundColor Green

# Execute build
Write-Host ""
Write-Host "[4/5] Building project..." -ForegroundColor Yellow
Write-Host "   This may take a few minutes..." -ForegroundColor Gray
Write-Host ""

$startTime = Get-Date

& $mvnCmd $buildCommand.Split(' ')

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "   [OK] Build successful!" -ForegroundColor Green
    Write-Host "   Build time: $([math]::Round($duration, 2)) seconds" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "   [ERROR] Build failed!" -ForegroundColor Red
    exit 1
}

# Display output information
Write-Host ""
Write-Host "[5/5] Build output..." -ForegroundColor Yellow

if (Test-Path "target\classes") {
    Write-Host "   [OK] Classes compiled: target\classes" -ForegroundColor Green
}

if ($Package -or $Install) {
    $jarFiles = Get-ChildItem -Path "target" -Filter "*.jar" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "*original*" }
    if ($jarFiles) {
        Write-Host "   [OK] JAR created:" -ForegroundColor Green
        foreach ($jar in $jarFiles) {
            $sizeInMB = [math]::Round($jar.Length / 1MB, 2)
            Write-Host "       - $($jar.Name) ($sizeInMB MB)" -ForegroundColor White
        }
    }
}

if ($Install) {
    Write-Host "   [OK] Installed to: $env:USERPROFILE\.m2\repository" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "BUILD COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Run application if requested
if ($Run) {
    Write-Host "Starting application..." -ForegroundColor Cyan
    Write-Host ""
    
    if ($Package -or $Install) {
        $jarFile = Get-ChildItem -Path "target" -Filter "*.jar" -ErrorAction SilentlyContinue | 
                   Where-Object { $_.Name -notlike "*original*" } | 
                   Select-Object -First 1
        
        if ($jarFile) {
            Write-Host "Running: java -jar $($jarFile.Name)" -ForegroundColor Yellow
            Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
            Write-Host ""
            & java -jar $jarFile.FullName
        } else {
            Write-Host "[ERROR] JAR file not found!" -ForegroundColor Red
            Write-Host "Use -Package option to create JAR" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Using Spring Boot Maven plugin..." -ForegroundColor Yellow
        Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
        Write-Host ""
        & $mvnCmd spring-boot:run
    }
}

Write-Host ""
Write-Host "Quick Commands:" -ForegroundColor Cyan
Write-Host "  Run application:  .\build-local.ps1 -Package -Run" -ForegroundColor White
Write-Host "  Fast build:       .\build-local.ps1 -SkipTests" -ForegroundColor White
Write-Host "  Full clean build: .\build-local.ps1 -Clean -Package" -ForegroundColor White
Write-Host ""


