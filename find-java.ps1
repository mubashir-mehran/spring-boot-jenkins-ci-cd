# Script to find Java installation
Write-Host "Searching for Java installation..." -ForegroundColor Cyan
Write-Host ""

$found = $false

# Check common locations
$searchPaths = @(
    "C:\Program Files\Java",
    "C:\Program Files\Eclipse Adoptium",
    "C:\Program Files\Microsoft",
    "C:\Program Files (x86)\Java",
    "C:\Program Files (x86)\Eclipse Adoptium"
)

foreach ($basePath in $searchPaths) {
    if (Test-Path $basePath) {
        $javaDirs = Get-ChildItem $basePath -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*jdk*" -or $_.Name -like "*java*" }
        foreach ($dir in $javaDirs) {
            $javaExe = Join-Path $dir.FullName "bin\java.exe"
            if (Test-Path $javaExe) {
                $javaHome = $dir.FullName
                Write-Host "✓ Found Java at: $javaHome" -ForegroundColor Green
                Write-Host ""
                Write-Host "To use this Java, run:" -ForegroundColor Yellow
                Write-Host "  `$env:JAVA_HOME = '$javaHome'" -ForegroundColor White
                Write-Host ""
                $found = $true
            }
        }
    }
}

# Check registry
try {
    $javaKeys = Get-ChildItem "HKLM:\SOFTWARE\JavaSoft\Java Development Kit" -ErrorAction SilentlyContinue
    foreach ($key in $javaKeys) {
        $javaHome = $key.GetValue("JavaHome")
        if ($javaHome -and (Test-Path "$javaHome\bin\java.exe")) {
            Write-Host "✓ Found Java in registry: $javaHome" -ForegroundColor Green
            Write-Host ""
            Write-Host "To use this Java, run:" -ForegroundColor Yellow
            Write-Host "  `$env:JAVA_HOME = '$javaHome'" -ForegroundColor White
            $found = $true
        }
    }
} catch {
    # Registry access might fail
}

if (-not $found) {
    Write-Host "✗ Java not found in common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please find where Java was installed and set JAVA_HOME:" -ForegroundColor Yellow
    Write-Host '  $env:JAVA_HOME = "C:\path\to\java"' -ForegroundColor White
    Write-Host ""
    Write-Host "Common installation paths:" -ForegroundColor Yellow
    Write-Host "  - C:\Program Files\Java\jdk-21" -ForegroundColor White
    Write-Host "  - C:\Program Files\Eclipse Adoptium\jdk-21.x-hotspot" -ForegroundColor White
    Write-Host "  - C:\Program Files\Microsoft\jdk-21.x" -ForegroundColor White
}
