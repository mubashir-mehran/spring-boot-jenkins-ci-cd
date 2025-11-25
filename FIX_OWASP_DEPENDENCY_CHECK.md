# Fix: OWASP Dependency-Check Configuration

## 🔴 Error Message
```
ERROR: No installation db-check found. Please define one in manager Jenkins.
```

## ✅ Solution: Configure OWASP Dependency-Check Tool

### Step 1: Access Jenkins Tools Configuration

1. Open Jenkins: **http://localhost:8081**
2. Click **"Manage Jenkins"** (left sidebar)
3. Click **"Tools"** (under System Configuration)

### Step 2: Configure OWASP Dependency-Check

1. Scroll down to find **"OWASP Dependency-Check"** section
2. Click **"Add Dependency-Check"** button
3. Configure the following:
   - **Name**: `db-check` (must match exactly what's in Jenkinsfile)
   - **Install automatically**: ✅ Check this box
   - **Version**: Select **"Latest"** or a specific version
4. Click **"Save"** at the bottom of the page

### Step 3: Verify Configuration

1. Go back to **Manage Jenkins** → **Tools**
2. Under **OWASP Dependency-Check**, you should see:
   - Name: `db-check`
   - Version: (the version you selected)
   - Status: Will show "Installing..." on first use

### Step 4: Rebuild Pipeline

1. Go back to your pipeline: `spring-boot-ci-cd`
2. Click **"Build Now"** again
3. The OWASP Dependency-Check stage should now work

---

## 📋 Quick Checklist

- [ ] Go to Manage Jenkins → Tools
- [ ] Find OWASP Dependency-Check section
- [ ] Click "Add Dependency-Check"
- [ ] Name: `db-check` (exact match)
- [ ] Check "Install automatically"
- [ ] Select version (Latest recommended)
- [ ] Click Save
- [ ] Rebuild pipeline

---

## 🔍 Alternative: Manual Installation

If automatic installation doesn't work:

1. Download OWASP Dependency-Check from: https://owasp.org/www-project-dependency-check/
2. Extract to a location accessible by Jenkins
3. In Jenkins Tools configuration:
   - Name: `db-check`
   - **Uncheck** "Install automatically"
   - **Installation directory**: Enter the path where you extracted it

---

## ⚠️ Important Notes

1. **Name must match exactly**: The name `db-check` in Jenkins Tools must match exactly what's in your Jenkinsfile (line 18)
2. **First run takes time**: The first time OWASP Dependency-Check runs, it will download vulnerability databases (this can take 10-20 minutes)
3. **Internet required**: OWASP Dependency-Check needs internet access to download vulnerability data

---

## 🐛 If Still Not Working

1. **Check Jenkins logs**:
   ```powershell
   docker logs jenkins -f
   ```

2. **Verify plugin is installed**:
   - Manage Jenkins → Plugins → Installed
   - Search for "OWASP Dependency-Check"
   - Should be installed and enabled

3. **Check tool name in Jenkinsfile**:
   - Line 18 should have: `odcInstallation: 'db-check'`
   - This must match the name in Tools configuration

---

**After fixing, rebuild your pipeline!** 🚀

