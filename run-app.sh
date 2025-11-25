#!/bin/bash
# Bash script to run the Spring Boot application using Docker Compose

echo "========================================"
echo "Spring Boot Application Launcher"
echo "========================================"
echo ""

# Check if Docker is running
echo "Checking Docker..."
if ! docker ps > /dev/null 2>&1; then
    echo "✗ Docker is not running. Please start Docker Desktop."
    exit 1
fi
echo "✓ Docker is running"
echo ""

echo "Building and starting application..."
echo ""

# Build and start the application
docker-compose -f docker-compose.local.yml up --build

echo ""
echo "Application stopped."

