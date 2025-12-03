# How to Test Locally Before Jenkins Build

## Prerequisites

### 1. Check Java Installation
```powershell
java -version
```
Should show Java 17 or higher.

### 2. Set JAVA_HOME (if not set)
```powershell
# Find Java installation path (usually one of these):
# C:\Program Files\Java\jdk-17
# C:\Program Files\Eclipse Adoptium\jdk-17.0.x-hotspot

# Set JAVA_HOME (replace with your actual path):
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
# Or
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.9-hotspot"

# Verify:
echo $env:JAVA_HOME
```

### 3. Check Maven (Optional - we'll use Maven Wrapper)
```powershell
mvn -version
```
If Maven is not installed, that's OK - we'll use `mvnw.cmd` (Maven Wrapper).

---

## Step 1: Run Tests Locally

### Using Maven Wrapper (Recommended):
```powershell
# Run tests
.\mvnw.cmd clean test

# Or if you have Maven installed:
mvn clean test
```

### What to Look For:
- ✅ **"Tests run: X"** - Should show **6+ tests** (not just 1!)
- ✅ **"BUILD SUCCESS"** - All tests passed
- ✅ **"Compiling X source files"** - Should compile **6 test files**, not just 1

### Expected Output:
```
[INFO] Compiling 6 source files to target/test-classes
[INFO] Running ma.projet.gestionprofesseurs.GestionProfesseursApplicationTests
[INFO] Running ma.projet.gestionprofesseurs.SimpleUnitTest
[INFO] Running ma.projet.gestionprofesseurs.services.ProfesseurServiceTest
[INFO] Running ma.projet.gestionprofesseurs.services.SpecialiteServiceTest
[INFO] Running ma.projet.gestionprofesseurs.controllers.ProfesseurControllerTest
[INFO] Running ma.projet.gestionprofesseurs.controllers.SpecialiteControllerTest
[INFO] Tests run: 30+, Failures: 0, Errors: 0, Skipped: 0
```

---

## Step 2: Generate Coverage Report

### After tests pass, generate coverage:
```powershell
.\mvnw.cmd jacoco:report

# Or if you have Maven:
mvn jacoco:report
```

### Or run both in one command:
```powershell
.\mvnw.cmd clean test jacoco:report
```

---

## Step 3: View Coverage Report

### Open the HTML Report:
```powershell
# Windows PowerShell:
Start-Process target\site\jacoco\index.html

# Or manually navigate to:
# target\site\jacoco\index.html
```

### What You Should See:
- ✅ **Coverage > 0%** (likely 30-50% with current tests)
- ✅ **Coverage by Package**:
  - `controllers` - Should have coverage
  - `services` - Should have coverage
  - `entities` - May be 0% (excluded from coverage)
- ✅ **Color-coded lines**:
  - 🟢 Green = Covered
  - 🔴 Red = Missed

---

## Step 4: Verify All Test Files Are Discovered

### Check Test Compilation:
```powershell
.\mvnw.cmd test-compile
```

### Look for:
```
[INFO] Compiling 6 source files to target/test-classes
```

**If you see only 1 file**, there's a problem!

### List Compiled Test Files:
```powershell
Get-ChildItem -Recurse target\test-classes\**\*Test.class
```

Should show:
- `GestionProfesseursApplicationTests.class`
- `SimpleUnitTest.class`
- `ProfesseurServiceTest.class`
- `SpecialiteServiceTest.class`
- `ProfesseurControllerTest.class`
- `SpecialiteControllerTest.class`

---

## Step 5: Check Coverage Files Generated

### Verify Coverage Files Exist:
```powershell
# Check coverage execution data
Test-Path target\jacoco.exec

# Check XML report
Test-Path target\site\jacoco\jacoco.xml

# Check HTML report
Test-Path target\site\jacoco\index.html
```

All should return `True`.

### View Coverage Summary:
```powershell
# Check file sizes (should be > 0)
Get-ChildItem target\jacoco.exec, target\site\jacoco\jacoco.xml | Select-Object Name, Length
```

---

## Troubleshooting

### Issue 1: Only 1 Test File Compiled

**Symptoms:**
```
[INFO] Compiling 1 source file to target/test-classes
```

**Solution:**
1. Check if all test files exist:
   ```powershell
   Get-ChildItem -Recurse src\test\**\*Test.java
   ```
   Should show 6 files.

2. Check for compilation errors:
   ```powershell
   .\mvnw.cmd test-compile -X
   ```
   Look for errors in the output.

3. Verify test file naming:
   - Must end with `Test.java` or `Tests.java`
   - Must be in `src/test/java` directory

### Issue 2: Tests Fail with Database Error

**Symptoms:**
```
CommunicationsException: Communications link failure
```

**Solution:**
- This shouldn't happen with current tests (they don't use Spring context)
- If it does, check `GestionProfesseursApplicationTests.java` - it should NOT have `@SpringBootTest`

### Issue 3: Coverage is 0%

**Symptoms:**
- Coverage report shows 0% for all classes

**Possible Causes:**
1. Tests didn't run (check test output)
2. JaCoCo agent not attached (check `target/jacoco.exec` exists)
3. Only failing tests ran (no code executed)

**Solution:**
1. Verify tests passed:
   ```powershell
   .\mvnw.cmd clean test
   ```
2. Check `target/jacoco.exec` exists and has size > 0
3. Regenerate report:
   ```powershell
   .\mvnw.cmd jacoco:report
   ```

### Issue 4: JAVA_HOME Not Set

**Solution:**
```powershell
# Find Java installation
where java

# Set JAVA_HOME (replace with actual path)
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"

# Or set permanently:
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", "User")
```

---

## Quick Test Script

Create a file `test-local.ps1`:

```powershell
# Set JAVA_HOME if needed
# $env:JAVA_HOME = "C:\Program Files\Java\jdk-17"

Write-Host "=== Running Tests ===" -ForegroundColor Green
.\mvnw.cmd clean test

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Generating Coverage Report ===" -ForegroundColor Green
    .\mvnw.cmd jacoco:report
    
    Write-Host "`n=== Coverage Report Generated ===" -ForegroundColor Green
    Write-Host "Opening coverage report..." -ForegroundColor Yellow
    Start-Process target\site\jacoco\index.html
} else {
    Write-Host "`nTests failed! Fix errors before checking coverage." -ForegroundColor Red
}
```

Run it:
```powershell
.\test-local.ps1
```

---

## What to Check Before Pushing to Jenkins

✅ **All 6 test files compile**
✅ **All tests pass** (30+ tests)
✅ **Coverage report generated** (`target/site/jacoco/index.html` exists)
✅ **Coverage > 0%** (at least 20-30%)
✅ **No compilation errors**
✅ **No test failures**

---

## Expected Results

### Test Count:
- `GestionProfesseursApplicationTests`: 1 test
- `SimpleUnitTest`: 4 tests
- `ProfesseurServiceTest`: 9 tests
- `SpecialiteServiceTest`: 7 tests
- `ProfesseurControllerTest`: 10 tests
- `SpecialiteControllerTest`: 8 tests
- **Total: ~39 tests**

### Coverage:
- **Services**: ~80-90% (well tested)
- **Controllers**: ~80-90% (well tested)
- **Entities**: 0% (excluded from coverage)
- **Overall**: ~30-50% (depending on what's included)

---

## Next Steps

Once local testing works:
1. ✅ Commit any fixes
2. ✅ Push to GitHub
3. ✅ Trigger Jenkins build
4. ✅ Verify Jenkins shows same results

