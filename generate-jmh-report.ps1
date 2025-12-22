# JMH Report Generator Script
# Generates HTML report from JMH JSON results

param(
    [string]$JsonFile = ""
)

Write-Host "JMH Report Generator" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

# Find latest JSON result file
$resultsDir = "target\jmh-results"
if (-not (Test-Path $resultsDir)) {
    Write-Host "[ERROR] Results directory not found: $resultsDir" -ForegroundColor Red
    Write-Host "Please run benchmarks first using: .\run-jmh.ps1" -ForegroundColor Yellow
    exit 1
}

if ([string]::IsNullOrEmpty($JsonFile)) {
    $jsonFiles = Get-ChildItem -Path $resultsDir -Filter "*.json" | Sort-Object LastWriteTime -Descending
    if ($jsonFiles.Count -eq 0) {
        Write-Host "[ERROR] No JSON result files found in $resultsDir" -ForegroundColor Red
        exit 1
    }
    $JsonFile = $jsonFiles[0].FullName
    Write-Host "[INFO] Using latest result file: $JsonFile" -ForegroundColor Yellow
} else {
    if (-not (Test-Path $JsonFile)) {
        Write-Host "[ERROR] JSON file not found: $JsonFile" -ForegroundColor Red
        exit 1
    }
}

Write-Host "[INFO] Generating HTML report..." -ForegroundColor Yellow

# Create HTML report
$htmlFile = $JsonFile -replace "\.json$", ".html"
$jsonContent = Get-Content $JsonFile -Raw | ConvertFrom-Json

$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>JMH Benchmark Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
        h2 { color: #555; margin-top: 30px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #4CAF50; color: white; }
        tr:hover { background-color: #f5f5f5; }
        .score { font-weight: bold; color: #2196F3; }
        .unit { color: #666; font-size: 0.9em; }
        .summary { background-color: #e8f5e9; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>JMH Microbenchmark Results</h1>
        <p class="timestamp">Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        <p class="timestamp">Source: $JsonFile</p>
        
        <div class="summary">
            <h2>Summary</h2>
            <p>Total Benchmarks: $($jsonContent.Count)</p>
        </div>
        
        <h2>Benchmark Results</h2>
        <table>
            <thead>
                <tr>
                    <th>Benchmark</th>
                    <th>Mode</th>
                    <th>Score</th>
                    <th>Unit</th>
                    <th>Error</th>
                </tr>
            </thead>
            <tbody>
"@

foreach ($benchmark in $jsonContent) {
    $benchmarkName = $benchmark.benchmark -replace ".*\.", ""
    $mode = $benchmark.mode
    $score = [math]::Round($benchmark.primaryMetric.score, 2)
    $unit = $benchmark.primaryMetric.scoreUnit
    $errorValue = if ($benchmark.primaryMetric.scoreError) { [math]::Round($benchmark.primaryMetric.scoreError, 2) } else { "N/A" }
    
    $html += @"
                <tr>
                    <td>$benchmarkName</td>
                    <td>$mode</td>
                    <td class="score">$score</td>
                    <td class="unit">$unit</td>
                    <td>$errorValue</td>
                </tr>
"@
}

$html += @"
            </tbody>
        </table>
    </div>
</body>
</html>
"@

$html | Out-File -FilePath $htmlFile -Encoding UTF8

Write-Host "[OK] HTML report generated: $htmlFile" -ForegroundColor Green
Write-Host ""
Write-Host "Opening report..." -ForegroundColor Yellow
Start-Process $htmlFile

