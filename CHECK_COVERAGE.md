# How to Check Code Coverage

## Method 1: From Jenkins Build Artifacts (Recommended)

### Steps:
1. **Open Jenkins Dashboard**
   - Navigate to: `http://localhost:8081`
   - Click on your pipeline: `spring-boot-ci-cd`

2. **Open a Build**
   - Click on any build number (e.g., `#27`)
   - Look for the "Build Artifacts" link in the left sidebar

3. **Download Coverage Report**
   - Find: `target/site/jacoco/index.html`
   - Click to download
   - Open the HTML file in your web browser

4. **View Coverage Details**
   - The report shows:
     - **Overall Coverage**: Percentage at the top
     - **Package Coverage**: Coverage by package (controllers, services, entities)
     - **Class Coverage**: Click on a class to see line-by-line coverage
     - **Color Coding**:
       - 🟢 Green = Covered lines
       - 🔴 Red = Missed lines
       - 🟡 Yellow = Partially covered branches

### Alternative: Download Tar Archive
- Download: `jacoco-reports.tar.gz`
- Extract it
- Open `jacoco/index.html` in your browser

---

## Method 2: From SonarQube Dashboard

### Steps:
1. **Open SonarQube**
   - Navigate to: `http://localhost:9000`
   - Login (default: `admin` / `admin`)

2. **Open Your Project**
   - Click on: `ma.projet:GestionProfesseurs`
   - Or search for: `GestionProfesseurs`

3. **View Coverage**
   - On the main dashboard, look for the **"Coverage"** metric
   - Click on **"Coverage"** to see detailed breakdown
   - Navigate to **"Measures"** → **"Coverage"** for:
     - Coverage by file
     - Coverage by package
     - Line coverage, branch coverage, etc.

---

## Method 3: Run Tests Locally and Generate Report

### Steps:
1. **Run Tests with Coverage**
   ```bash
   mvn clean test
   ```

2. **Generate Coverage Report**
   ```bash
   mvn jacoco:report
   ```

3. **Open the Report**
   - Navigate to: `target/site/jacoco/index.html`
   - Open in your web browser

### Quick Command (Windows PowerShell):
```powershell
mvn clean test jacoco:report; Start-Process target/site/jacoco/index.html
```

### Quick Command (Linux/Mac):
```bash
mvn clean test jacoco:report && open target/site/jacoco/index.html
```

---

## Method 4: Check Coverage in Jenkins Console Output

### Steps:
1. **Open Build Console**
   - Go to your Jenkins build
   - Click "Console Output"

2. **Look for Coverage Messages**
   - Search for: `"Coverage exec file exists"`
   - Search for: `"Coverage XML report exists"`
   - These confirm coverage files were generated

---

## Understanding Coverage Metrics

### Types of Coverage:
- **Line Coverage**: Percentage of lines executed
- **Branch Coverage**: Percentage of branches (if/else) executed
- **Method Coverage**: Percentage of methods called
- **Class Coverage**: Percentage of classes instantiated

### What's Good Coverage?
- **80%+**: Excellent
- **60-80%**: Good
- **40-60%**: Acceptable
- **<40%**: Needs improvement

### Current Status:
Based on your last build, coverage is **0%** because:
- Only 1 test file was compiled (others weren't discovered)
- The test failed (tried to load Spring context)
- No actual code was executed during tests

**After the next build** (with all fixes), you should see:
- ✅ All test files compiled
- ✅ All tests passing
- ✅ Coverage > 0% (likely 30-50% with current tests)

---

## Troubleshooting

### If Coverage is Still 0%:
1. **Check Test Execution**
   - Verify tests are actually running
   - Check console output for test results

2. **Check JaCoCo Agent**
   - Verify `target/jacoco.exec` exists
   - File size should be > 0 bytes

3. **Check Report Generation**
   - Verify `target/site/jacoco/jacoco.xml` exists
   - Verify `target/site/jacoco/index.html` exists

4. **Check SonarQube Integration**
   - Verify SonarQube analysis completed
   - Check SonarQube logs for errors

---

## Quick Reference

| Location | Path | Format |
|----------|------|--------|
| Jenkins Artifacts | `target/site/jacoco/index.html` | HTML |
| SonarQube | Dashboard → Coverage | Web UI |
| Local Report | `target/site/jacoco/index.html` | HTML |
| Raw Data | `target/jacoco.exec` | Binary |
| XML Report | `target/site/jacoco/jacoco.xml` | XML |

---

## Next Steps

After your next Jenkins build:
1. ✅ Check Jenkins artifacts for HTML report
2. ✅ Check SonarQube dashboard for coverage metrics
3. ✅ Verify all test files are being compiled
4. ✅ Confirm coverage is > 0%


