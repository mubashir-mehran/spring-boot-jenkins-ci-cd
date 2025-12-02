# SonarQube Code Coverage Setup Guide

## 🔍 Problem Identified

SonarQube was showing **0.0% code coverage** because:
1. ❌ Tests were being skipped (`-DskipTests` in Jenkinsfile)
2. ❌ SonarQube analysis ran before tests, so no coverage data existed
3. ❌ Incorrect JaCoCo report path in `pom.xml`
4. ❌ SonarQube wasn't configured to read the XML coverage report

---

## ✅ Changes Made

### **1. Fixed `pom.xml`**

#### **Updated JaCoCo Properties:**
```xml
<!-- Fixed report path (was: ../target/jacoco.exec) -->
<sonar.jacoco.reportPath>${project.basedir}/target/jacoco.exec</sonar.jacoco.reportPath>

<!-- Added XML report path for SonarQube -->
<sonar.coverage.jacoco.xmlReportPaths>${project.basedir}/target/site/jacoco/jacoco.xml</sonar.coverage.jacoco.xmlReportPaths>
```

#### **Updated JaCoCo Plugin Configuration:**
- ✅ Removed duplicate plugin entry
- ✅ Added `jacoco:report` execution in `test` phase
- ✅ Added `jacoco:check` execution for coverage validation

**Key Changes:**
- Coverage report now generates after tests run
- XML report is created for SonarQube
- Coverage check validates minimum coverage (currently set to 0% to not fail builds)

---

### **2. Updated `Jenkinsfile`**

#### **New Stage: "Test & Coverage"**
- ✅ Runs `mvn clean test` (tests are NOT skipped)
- ✅ Generates JaCoCo coverage report with `mvn jacoco:report`
- ✅ Archives test results and coverage reports

#### **Updated "Sonarqube Analysis" Stage:**
- ✅ Now runs AFTER tests
- ✅ Includes coverage report paths:
  - `-Dsonar.jacoco.reportPath=target/jacoco.exec`
  - `-Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml`

#### **Updated "Package" Stage:**
- ✅ Renamed from "Clean & Package"
- ✅ Still uses `-DskipTests` (tests already ran in previous stage)
- ✅ Only packages the application

---

## 📊 Pipeline Flow (New Order)

```
1. Verify Workspace
   ↓
2. Test & Coverage          ← NEW: Runs tests and generates coverage
   ├── mvn clean test
   ├── mvn jacoco:report
   └── Archive reports
   ↓
3. Sonarqube Analysis       ← UPDATED: Now includes coverage data
   ├── Reads jacoco.exec
   ├── Reads jacoco.xml
   └── Uploads to SonarQube
   ↓
4. Package
   ↓
5. Docker Build & Push
   ↓
6. Vulnerability scanning
   ↓
7. Staging
```

---

## 🧪 How It Works

### **Step 1: Tests Run with JaCoCo Agent**
When you run `mvn test`, JaCoCo agent (configured in `prepare-agent` execution) automatically:
- Instruments your Java classes
- Tracks which lines are executed during tests
- Writes coverage data to `target/jacoco.exec`

### **Step 2: Coverage Report Generation**
When you run `mvn jacoco:report`, JaCoCo:
- Reads `target/jacoco.exec`
- Generates HTML report: `target/site/jacoco/index.html`
- Generates XML report: `target/site/jacoco/jacoco.xml` (for SonarQube)

### **Step 3: SonarQube Analysis**
When you run `mvn sonar:sonar` with coverage paths:
- SonarQube reads `jacoco.exec` and `jacoco.xml`
- Calculates coverage metrics
- Displays coverage in SonarQube dashboard

---

## 📈 Expected Results

### **After Next Build:**

1. **SonarQube Dashboard:**
   - Coverage should show actual percentage (not 0%)
   - Coverage will be low initially (only 1 basic test exists)
   - As you add more tests, coverage will increase

2. **Jenkins Build:**
   - Test results will be archived
   - Coverage HTML report will be available in Jenkins
   - Build logs will show coverage generation

3. **Coverage Files Generated:**
   - `target/jacoco.exec` - Binary coverage data
   - `target/site/jacoco/index.html` - HTML report
   - `target/site/jacoco/jacoco.xml` - XML report for SonarQube

---

## 🔍 How to Verify Coverage

### **1. Check SonarQube Dashboard**
- Go to: `http://localhost:9000`
- Navigate to your project: **GestionProfesseurs**
- Check the **Coverage** metric
- Should show actual percentage (not 0%)

### **2. View Coverage Report in Jenkins**
- After build completes, click on build number
- Look for **"JaCoCo Coverage Report"** link
- Click to view HTML coverage report
- See which lines are covered/uncovered

### **3. Check Build Logs**
Look for these messages in Jenkins build logs:
```
Running tests with JaCoCo coverage...
Coverage report generated at: target/site/jacoco/index.html
Coverage exec file: target/jacoco.exec
Coverage XML report: target/site/jacoco/jacoco.xml
Running SonarQube analysis with coverage data...
SonarQube analysis completed
```

### **4. View Coverage Locally**
After running tests locally:
```bash
mvn clean test jacoco:report
# Open: target/site/jacoco/index.html in browser
```

---

## ⚠️ Current Coverage Status

### **Expected Initial Coverage: ~5-10%**
- Only 1 basic test exists (`GestionProfesseursApplicationTests`)
- This test only checks if Spring context loads
- Most code is not covered by tests

### **To Increase Coverage:**
1. Add controller tests
2. Add service tests
3. Add repository tests
4. Add integration tests

See `TEST_ANALYSIS_REPORT.md` for details on missing tests.

---

## 🛠️ Troubleshooting

### **Issue: Coverage Still Shows 0%**

**Check:**
1. ✅ Tests are running (check build logs for test execution)
2. ✅ `target/jacoco.exec` file exists after tests
3. ✅ `target/site/jacoco/jacoco.xml` file exists
4. ✅ SonarQube analysis includes coverage paths
5. ✅ SonarQube analysis runs AFTER tests

**Solution:**
```bash
# Run locally to verify
mvn clean test jacoco:report
ls -la target/jacoco.exec
ls -la target/site/jacoco/jacoco.xml
```

### **Issue: Tests Failing**

**Check:**
- Test database connection
- Test data setup
- Application properties for tests

**Solution:**
- Add H2 in-memory database for tests
- Configure separate test profile

### **Issue: Coverage Report Not Showing in Jenkins**

**Check:**
- HTML Publisher Plugin is installed in Jenkins
- Build completed successfully
- Reports are archived

**Solution:**
- Install "HTML Publisher Plugin" in Jenkins
- Check build artifacts

---

## 📝 Next Steps

### **1. Run the Pipeline**
- Push changes to GitHub
- Trigger Jenkins build
- Check SonarQube dashboard for coverage

### **2. Add More Tests**
To increase coverage, add:
- Controller tests
- Service tests
- Repository tests
- Integration tests

### **3. Set Coverage Thresholds**
Once you have good coverage, update `pom.xml`:
```xml
<limit>
    <counter>LINE</counter>
    <value>COVEREDRATIO</value>
    <minimum>0.80</minimum>  <!-- 80% coverage required -->
</limit>
```

---

## 🎯 Summary

✅ **Fixed Issues:**
- Tests now run before SonarQube analysis
- JaCoCo generates coverage reports
- SonarQube reads coverage data
- Coverage paths are correctly configured

✅ **Result:**
- SonarQube will now show actual code coverage
- Coverage reports available in Jenkins
- Coverage will increase as you add tests

---

## 📚 Additional Resources

- **JaCoCo Documentation:** https://www.jacoco.org/jacoco/
- **SonarQube Coverage:** https://docs.sonarqube.org/latest/analysis/coverage/
- **Maven JaCoCo Plugin:** https://www.jacoco.org/jacoco/trunk/doc/maven.html

---

**Note:** After pushing these changes and running the Jenkins build, SonarQube should display actual code coverage instead of 0%.


