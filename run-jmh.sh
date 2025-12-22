#!/bin/bash

# JMH Microbenchmark Runner Script
# This script compiles and runs JMH benchmarks, then generates reports

echo "JMH Microbenchmark Runner"
echo "========================="
echo ""

# Check if Java is available
if ! command -v java &> /dev/null; then
    echo "[ERROR] Java not found. Please install Java 17 or 21."
    exit 1
fi
echo "[OK] Java found: $(java -version 2>&1 | head -n 1)"
echo ""

# Check if Maven is available
if [ -f "./mvnw" ]; then
    MVN_CMD="./mvnw"
    echo "[OK] Using Maven wrapper"
elif command -v mvn &> /dev/null; then
    MVN_CMD="mvn"
    echo "[OK] Using system Maven"
else
    echo "[ERROR] Maven not found. Please install Maven or use Maven wrapper."
    exit 1
fi

echo ""

# Create results directory
RESULTS_DIR="target/jmh-results"
mkdir -p "$RESULTS_DIR"
echo "[OK] Results directory: $RESULTS_DIR"
echo ""

echo "[INFO] Compiling project and benchmarks..."
$MVN_CMD clean package -DskipTests -q
if [ $? -ne 0 ]; then
    echo "[ERROR] Build failed!"
    exit 1
fi
echo "[OK] Build successful"
echo ""

# Check if benchmarks jar exists
BENCHMARKS_JAR="target/benchmarks.jar"
if [ ! -f "$BENCHMARKS_JAR" ]; then
    echo "[WARNING] Benchmarks jar not found. Building with benchmarks..."
    $MVN_CMD package -DskipTests
    if [ ! -f "$BENCHMARKS_JAR" ]; then
        echo "[ERROR] Failed to create benchmarks jar"
        exit 1
    fi
fi

echo "[INFO] Running JMH benchmarks..."
echo "This may take several minutes..."
echo ""

# Run all benchmarks
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_FILE="$RESULTS_DIR/jmh-results-$TIMESTAMP.txt"
JSON_FILE="$RESULTS_DIR/jmh-results-$TIMESTAMP.json"

java -jar "$BENCHMARKS_JAR" \
    -rf text -rff "$RESULTS_FILE" \
    -rf json -rff "$JSON_FILE" \
    -prof gc \
    -prof stack

if [ $? -eq 0 ]; then
    echo ""
    echo "[OK] Benchmarks completed successfully!"
    echo ""
    echo "Results:"
    echo "  Text report: $RESULTS_FILE"
    echo "  JSON report: $JSON_FILE"
    echo ""
    
    # Display summary
    if [ -f "$RESULTS_FILE" ]; then
        echo "Benchmark Summary:"
        echo "=================="
        head -n 50 "$RESULTS_FILE"
        echo ""
        echo "[INFO] Full report saved to: $RESULTS_FILE"
    fi
else
    echo "[ERROR] Benchmark execution failed!"
    exit 1
fi

echo ""


