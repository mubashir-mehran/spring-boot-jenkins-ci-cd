#!/bin/bash

# OpenJML Static Verification Script
# This script runs OpenJML to verify JML specifications in the codebase

echo "🔍 OpenJML Static Verification"
echo "=============================="
echo ""

# Check if Java is available
if ! command -v java &> /dev/null; then
    echo "❌ Java not found. Please install Java 17 or 21 and set JAVA_HOME."
    exit 1
fi

echo "✅ Java found: $(java -version 2>&1 | head -n 1)"
echo ""

# Create OpenJML directory if it doesn't exist
OPENJML_DIR="./openjml"
OPENJML_JAR="$OPENJML_DIR/openjml.jar"

if [ ! -f "$OPENJML_JAR" ]; then
    echo "📥 OpenJML not found. Downloading OpenJML..."
    echo ""
    
    # Create directory
    mkdir -p "$OPENJML_DIR"
    
    # Download OpenJML
    OPENJML_URL="https://github.com/OpenJML/OpenJML/releases/download/v0.17.0-alpha-15/openjml.jar"
    
    echo "Downloading OpenJML from GitHub..."
    if curl -L -o "$OPENJML_JAR" "$OPENJML_URL"; then
        echo "✅ OpenJML downloaded successfully"
    else
        echo "❌ Failed to download OpenJML"
        echo ""
        echo "Please download OpenJML manually:"
        echo "1. Visit: https://www.openjml.org/"
        echo "2. Download the latest release"
        echo "3. Extract openjml.jar to: $OPENJML_DIR"
        exit 1
    fi
else
    echo "✅ OpenJML found at: $OPENJML_JAR"
fi

echo ""

# Create output directory for reports
REPORT_DIR="./target/openjml-reports"
mkdir -p "$REPORT_DIR"

# Find all Java source files with JML annotations
echo "🔍 Scanning for JML-annotated Java files..."
JAVA_FILES=$(find ./src/main/java -name "*.java" -type f | xargs grep -l "@requires\|@ensures\|@invariant\|/\*@" 2>/dev/null || true)

if [ -z "$JAVA_FILES" ]; then
    echo "⚠️  No JML-annotated files found."
    exit 0
fi

FILE_COUNT=$(echo "$JAVA_FILES" | wc -l)
echo "✅ Found $FILE_COUNT JML-annotated file(s)"
echo ""

# Build classpath
CLASSPATH="./target/classes"
if [ -d "./target/test-classes" ]; then
    CLASSPATH="$CLASSPATH:./target/test-classes"
fi

# Add Maven repository dependencies (simplified)
MAVEN_REPO="$HOME/.m2/repository"
if [ -d "$MAVEN_REPO" ]; then
    # Add Spring Boot dependencies
    for jar in $(find "$MAVEN_REPO/org/springframework/boot" -name "*.jar" 2>/dev/null | head -20); do
        CLASSPATH="$CLASSPATH:$jar"
    done
    for jar in $(find "$MAVEN_REPO/jakarta/persistence" -name "*.jar" 2>/dev/null); do
        CLASSPATH="$CLASSPATH:$jar"
    done
fi

echo "🔬 Running OpenJML static verification..."
echo ""

# Run OpenJML on each file
REPORT_FILE="$REPORT_DIR/openjml-report.txt"
ERROR_COUNT=0
WARNING_COUNT=0
VERIFIED_COUNT=0

echo "OpenJML Static Verification Report" > "$REPORT_FILE"
echo "===================================" >> "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for file in $JAVA_FILES; do
    echo "Verifying: $(basename $file)"
    
    RELATIVE_PATH=$(echo "$file" | sed "s|^\./||")
    
    # Run OpenJML with ESC (Extended Static Checking)
    OUTPUT=$(java -jar "$OPENJML_JAR" -esc -cp "$CLASSPATH" "$file" 2>&1)
    
    echo "File: $RELATIVE_PATH" >> "$REPORT_FILE"
    echo "$(printf '=%.0s' {1..80})" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    if [ -n "$OUTPUT" ]; then
        echo "$OUTPUT" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        # Count errors and warnings
        ERRORS=$(echo "$OUTPUT" | grep -i "error" | wc -l)
        WARNINGS=$(echo "$OUTPUT" | grep -i "warning" | wc -l)
        VERIFIED=$(echo "$OUTPUT" | grep -i "verified" | wc -l)
        
        ERROR_COUNT=$((ERROR_COUNT + ERRORS))
        WARNING_COUNT=$((WARNING_COUNT + WARNINGS))
        VERIFIED_COUNT=$((VERIFIED_COUNT + VERIFIED))
        
        if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
            echo "  ✅ Verified successfully"
        else
            if [ $ERRORS -gt 0 ]; then
                echo "  ❌ $ERRORS error(s)"
            fi
            if [ $WARNINGS -gt 0 ]; then
                echo "  ⚠️  $WARNINGS warning(s)"
            fi
        fi
    else
        echo "  ✅ Verified successfully"
        VERIFIED_COUNT=$((VERIFIED_COUNT + 1))
    fi
done

echo ""
echo "📊 Verification Summary"
echo "======================"
echo "Files verified: $FILE_COUNT"
echo "Verified successfully: $VERIFIED_COUNT"
echo "Errors: $ERROR_COUNT"
echo "Warnings: $WARNING_COUNT"
echo ""

# Add summary to report
echo "Summary:" >> "$REPORT_FILE"
echo "- Files verified: $FILE_COUNT" >> "$REPORT_FILE"
echo "- Verified successfully: $VERIFIED_COUNT" >> "$REPORT_FILE"
echo "- Errors: $ERROR_COUNT" >> "$REPORT_FILE"
echo "- Warnings: $WARNING_COUNT" >> "$REPORT_FILE"

echo "📄 Detailed report saved to: $REPORT_FILE"
echo ""

if [ $ERROR_COUNT -gt 0 ] || [ $WARNING_COUNT -gt 0 ]; then
    echo "Opening report..."
    if command -v xdg-open &> /dev/null; then
        xdg-open "$REPORT_FILE"
    elif command -v open &> /dev/null; then
        open "$REPORT_FILE"
    fi
else
    echo "✅ All JML specifications verified successfully!"
fi

echo ""






