# PIT (Pitest) Mutation Testing Guide

## 📋 Overview

**PIT (Pitest)** is a state-of-the-art mutation testing system for Java. Unlike code coverage tools like JaCoCo that only show which lines were executed, PIT actually tests the **quality** of your tests by introducing small changes (mutations) to your code and checking if your tests catch them.

### What is Mutation Testing?

Mutation testing works by:
1. **Creating mutants**: Making small changes to your code (e.g., changing `>` to `>=`, `+` to `-`, etc.)
2. **Running tests**: Executing your test suite against each mutant
3. **Analyzing results**: 
   - ✅ **Killed mutant**: Test failed → Good! Your tests caught the bug
   - ❌ **Survived mutant**: Test passed → Bad! Your tests didn't catch the bug
   - ⚠️ **Timeout**: Test took too long → May indicate infinite loop

### Why Use PIT?

- **Better than code coverage**: Code coverage shows what was executed, but not if it was tested correctly
- **Finds weak tests**: Identifies tests that pass but don't actually verify behavior
- **Improves test quality**: Encourages writing more thorough, meaningful tests

---

## ✅ Implementation Status

**PIT is now configured in your project!**

### Configuration Details

- **Plugin**: `pitest-maven` version `1.15.0`
- **JUnit 5 Support**: `pitest-junit5-plugin` version `1.2.0`
- **Report Location**: `target/pit-reports/`
- **Mutation Threshold**: 70% (minimum mutation score to pass)
- **Coverage Threshold**: 70% (minimum coverage to pass)

### What Gets Tested

- ✅ **Included**: All classes in `ma.projet.gestionprofesseurs.*` package
- ❌ **Excluded**: 
  - Entity classes (getters/setters don't need mutation testing)
  - Application main class
  - Test classes themselves

---

## 🚀 How to Run PIT

### Option 1: Run via Maven Command

```bash
# Run mutation testing (runs after tests)
mvn clean test org.pitest:pitest-maven:mutationCoverage

# Or use the shorter form
mvn clean test pitest:mutationCoverage
```

### Option 2: Run via Maven Wrapper (Windows)

```powershell
# Using Maven wrapper
.\mvnw.cmd clean test org.pitest:pitest-maven:mutationCoverage

# Or
.\mvnw.cmd clean test pitest:mutationCoverage
```

### Option 3: Run as Part of Build

PIT is configured to run automatically during the `test` phase:

```bash
mvn clean test
```

This will:
1. Run your unit tests
2. Generate JaCoCo coverage report
3. Run PIT mutation testing
4. Generate mutation reports

---

## 📊 Viewing PIT Reports

### HTML Report (Recommended)

After running PIT, open the HTML report:

**Location**: `target/pit-reports/index.html`

**On Windows:**
```powershell
# Open in default browser
Start-Process "target\pit-reports\index.html"
```

**Or manually navigate to:**
```
C:\Users\dev\Spring-Boot-Jenkins-CI-CD\target\pit-reports\index.html
```

### Report Contents

The HTML report shows:

1. **Summary Page**:
   - Overall mutation score (percentage of mutants killed)
   - Number of mutations generated
   - Number of mutations killed/survived/timed out
   - Coverage statistics

2. **Class-Level Details**:
   - Mutation score per class
   - Line-by-line mutation analysis
   - Which mutations survived (weak tests)
   - Which mutations were killed (good tests)

3. **Mutation Details**:
   - Exact code changes made
   - Which tests ran against each mutant
   - Why mutants survived or were killed

### XML Report

**Location**: `target/pit-reports/mutations.xml`

Useful for:
- CI/CD integration
- Automated analysis
- SonarQube integration (if configured)

### CSV Report

**Location**: `target/pit-reports/mutations.csv`

Useful for:
- Spreadsheet analysis
- Data export
- Custom reporting

---

## 📈 Understanding PIT Results

### Mutation Score

**Mutation Score = (Killed Mutants / Total Mutants) × 100%**

- **90-100%**: Excellent! Your tests are very thorough
- **70-89%**: Good! Most edge cases are covered
- **50-69%**: Fair! Some gaps in test coverage
- **<50%**: Poor! Many tests are weak or missing

### Example Report Interpretation

```
Class: ProfesseurService
Mutation Score: 75%
- Total Mutations: 40
- Killed: 30 ✅
- Survived: 8 ❌ (weak tests)
- Timed Out: 2 ⚠️
```

**What this means:**
- 75% of mutations were caught by tests (good)
- 8 mutations survived → Need better tests for those code paths
- 2 timeouts → May indicate infinite loop potential

### Common Mutation Types

PIT creates mutations like:

1. **Conditional Boundary**:
   ```java
   // Original
   if (x > 10) { ... }
   
   // Mutant
   if (x >= 10) { ... }  // Changed > to >=
   ```

2. **Increment Mutator**:
   ```java
   // Original
   return count + 1;
   
   // Mutant
   return count - 1;  // Changed + to -
   ```

3. **Negate Conditionals**:
   ```java
   // Original
   if (isValid) { ... }
   
   // Mutant
   if (!isValid) { ... }  // Negated condition
   ```

---

## 🔧 Configuration Options

### Adjusting Thresholds

Edit `pom.xml` to change thresholds:

```xml
<properties>
    <!-- Minimum mutation score to pass (0-100) -->
    <pitest.mutationThreshold>70</pitest.mutationThreshold>
    
    <!-- Minimum coverage to pass (0-100) -->
    <pitest.coverageThreshold>70</pitest.coverageThreshold>
</properties>
```

### Excluding More Classes

To exclude additional classes from mutation testing:

```xml
<excludedClasses>
    <param>ma.projet.gestionprofesseurs.entities.*</param>
    <param>ma.projet.gestionprofesseurs.config.*</param>
    <param>ma.projet.gestionprofesseurs.dto.*</param>
</excludedClasses>
```

### Running on Specific Classes Only

To test only specific classes:

```xml
<targetClasses>
    <param>ma.projet.gestionprofesseurs.services.*</param>
    <param>ma.projet.gestionprofesseurs.controllers.*</param>
</targetClasses>
```

---

## 🎯 Best Practices

### 1. Run PIT Regularly

- Run mutation testing before committing code
- Include in CI/CD pipeline (optional, as it's slow)
- Review reports to identify weak tests

### 2. Focus on Survived Mutants

- **Survived mutants** indicate weak tests
- Improve tests to kill these mutants
- Aim for 80%+ mutation score

### 3. Don't Test Everything

- Exclude entity classes (getters/setters)
- Exclude configuration classes
- Focus on business logic (services, controllers)

### 4. Balance Speed vs. Coverage

- PIT can be slow on large codebases
- Use `threads` configuration for parallel execution
- Consider running on subset of classes during development

---

## 🔄 Integration with CI/CD

### Jenkins Integration

Add to your `Jenkinsfile`:

```groovy
stage('Mutation Testing') {
    steps {
        script {
            try {
                echo "Running PIT mutation testing..."
                sh 'mvn clean test pitest:mutationCoverage'
                
                // Archive mutation reports
                archiveArtifacts artifacts: 'target/pit-reports/**', 
                                allowEmptyArchive: true
            } catch (Exception e) {
                echo "⚠ Mutation testing failed: ${e.message}"
                currentBuild.result = 'UNSTABLE'
            }
        }
    }
}
```

### SonarQube Integration

PIT can integrate with SonarQube using the `sonar-pitest-plugin`:

1. Install SonarQube plugin: `sonar-pitest-plugin`
2. Configure SonarQube to read PIT XML reports
3. View mutation scores in SonarQube dashboard

---

## ⚠️ Troubleshooting

### Issue: PIT runs very slowly

**Solution:**
- Reduce number of threads: `<threads>2</threads>`
- Exclude more classes
- Run on specific packages only
- Use incremental analysis (history files)

### Issue: Tests fail during mutation testing

**Solution:**
- Ensure all tests pass normally first: `mvn clean test`
- Check for flaky tests
- Increase timeout: `<timeoutConst>5000</timeoutConst>`

### Issue: No mutations generated

**Solution:**
- Check `targetClasses` configuration
- Verify classes are not excluded
- Ensure source code is compiled: `mvn clean compile`

### Issue: Reports not generated

**Solution:**
- Check `reportDir` path in configuration
- Verify write permissions
- Check Maven build output for errors

---

## 📚 Additional Resources

- **PIT Official Documentation**: https://pitest.org/
- **PIT Maven Plugin**: https://pitest.org/quickstart/maven/
- **Mutation Testing Explained**: https://pitest.org/faq/

---

## ✅ Quick Reference

| Command | Description |
|---------|-------------|
| `mvn pitest:mutationCoverage` | Run mutation testing |
| `mvn clean test pitest:mutationCoverage` | Clean, test, then mutate |
| `target/pit-reports/index.html` | View HTML report |
| `target/pit-reports/mutations.xml` | XML report for CI/CD |

---

**Happy Mutation Testing! 🧬**

