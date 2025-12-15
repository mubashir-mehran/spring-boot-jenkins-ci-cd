# PIT (Pitest) Mutation Testing Script
# This script runs PIT mutation testing and opens the HTML report

Write-Host "🧬 PIT (Pitest) Mutation Testing" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Java is available
$javaVersion = & java -version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Java not found. Please install Java 17 or 21 and set JAVA_HOME." -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying to find Java..." -ForegroundColor Yellow
    
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
        if (Test-Path $path) {
            $javaHome = Split-Path (Split-Path $path -Parent) -Parent
            $env:JAVA_HOME = $javaHome
            $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
            Write-Host "✅ Found Java at: $javaHome" -ForegroundColor Green
            $foundJava = $true
            break
        }
    }
    
    if (-not $foundJava) {
        Write-Host "❌ Could not find Java. Please install Java 17 or 21." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Java found: $javaVersion" -ForegroundColor Green
}

Write-Host ""

# Check if Maven wrapper exists
if (Test-Path ".\mvnw.cmd") {
    $mvnCmd = ".\mvnw.cmd"
    Write-Host "✅ Using Maven wrapper (mvnw.cmd)" -ForegroundColor Green
} elseif (Get-Command mvn -ErrorAction SilentlyContinue) {
    $mvnCmd = "mvn"
    Write-Host "✅ Using system Maven" -ForegroundColor Green
} else {
    Write-Host "❌ Maven not found. Please install Maven or use Maven wrapper." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🚀 Running PIT mutation testing..." -ForegroundColor Yellow
Write-Host "   This may take several minutes..." -ForegroundColor Yellow
Write-Host ""

# Run PIT mutation testing
& $mvnCmd clean test org.pitest:pitest-maven:mutationCoverage

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ PIT mutation testing completed successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Check if report exists
    $reportPath = "target\pit-reports\index.html"
    if (Test-Path $reportPath) {
        Write-Host "📊 Opening mutation test report..." -ForegroundColor Cyan
        Write-Host "   Location: $((Resolve-Path $reportPath).Path)" -ForegroundColor Gray
        Write-Host ""
        
        # Open report in default browser
        Start-Process $reportPath
        
        Write-Host "✅ Report opened in browser!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Warning: Report not found at $reportPath" -ForegroundColor Yellow
        Write-Host "   Check target/pit-reports/ directory" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "📁 Report locations:" -ForegroundColor Cyan
    Write-Host "   - HTML: target\pit-reports\index.html" -ForegroundColor Gray
    Write-Host "   - XML:  target\pit-reports\mutations.xml" -ForegroundColor Gray
    Write-Host "   - CSV:  target\pit-reports\mutations.csv" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ PIT mutation testing failed!" -ForegroundColor Red
    Write-Host "   Check the output above for errors." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "✨ Done!" -ForegroundColor Green

