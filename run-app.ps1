# PowerShell script to run the Spring Boot application using Docker Compose

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Spring Boot Application Launcher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Building and starting application..." -ForegroundColor Yellow
Write-Host ""

# Build and start the application
docker-compose -f docker-compose.local.yml up --build

Write-Host ""
Write-Host "Application stopped." -ForegroundColor Yellow

