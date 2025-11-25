# Install Dependency-Check from GitHub

## 🔍 Issue
When clicking "+ Add Installer", you don't see a "Dependency-Check" option. This means we need to install it manually from GitHub.

## ✅ Solution: Use "Install from github.com"

### Step 1: Select "Install from github.com"

1. In the dropdown menu, click **"Install from github.com"**

### Step 2: Configure GitHub Installation

You'll see a form with these fields:

1. **Repository URL**:
   ```
   https://github.com/dependency-check/dependency-check
   ```

2. **Tag/Version** (Optional but recommended):
   - Leave empty for latest, OR
   - Enter a specific version like: `v10.0.0` or `v9.0.9`
   - To find latest version: https://github.com/dependency-check/dependency-check/releases

3. **Subdirectory** (Optional):
   - Leave empty (Dependency-Check is in the root)

4. **Label** (Optional):
   - Leave empty or enter: `Dependency-Check`

### Step 3: Alternative - Use "Extract *.zip/*.tar.gz"

If "Install from github.com" doesn't work, use the extract method:

1. **Download Dependency-Check manually**:
   - Go to: https://github.com/dependency-check/dependency-check/releases
   - Download the latest release (e.g., `dependency-check-10.0.0-release.zip`)
   - Note the download URL

2. **In Jenkins, select "Extract *.zip/*.tar.gz"**:
   - **Zip URL**: Enter the direct download URL
     - Example: `https://github.com/dependency-check/dependency-check/releases/download/v10.0.0/dependency-check-10.0.0-release.zip`
   - **Subdirectory**: Leave empty
   - **Label**: Leave empty

---

## 🎯 Recommended: Manual Installation Method

Since automatic installation isn't working, let's do a manual installation:

### Step 1: Download Dependency-Check

1. Go to: https://github.com/dependency-check/dependency-check/releases
2. Download the latest release ZIP file
   - Example: `dependency-check-10.0.0-release.zip`
3. Note where you downloaded it

### Step 2: Extract and Copy to Jenkins

Since Jenkins is running in Docker, we need to copy it into the container:

```powershell
# 1. Extract the ZIP file to a folder (e.g., C:\dependency-check)

# 2. Copy into Jenkins container
docker cp C:\dependency-check jenkins:/var/jenkins_home/tools/dependency-check

# 3. Set permissions (if needed)
docker exec jenkins chmod -R 755 /var/jenkins_home/tools/dependency-check
```

### Step 3: Configure in Jenkins

1. Go to **Manage Jenkins** → **Tools**
2. Under **Dependency-Check installations**, click on `db-check`
3. **Uncheck** "Install automatically"
4. **Installation directory**: Enter:
   ```
   /var/jenkins_home/tools/dependency-check
   ```
5. Click **Save**

---

## 🚀 Quick Alternative: Skip OWASP Stage Temporarily

If you want to test the rest of the pipeline first, you can temporarily skip the OWASP stage:

### Option 1: Comment Out in Jenkinsfile

Edit your Jenkinsfile and comment out the OWASP stage:

```groovy
// stage('OWASP Dependency Check'){
//     steps{
//         dependencyCheck additionalArguments: '--scan ./ --format HTML ', odcInstallation: 'db-check'
//         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
//     }
// }
```

Then commit and push to GitHub, rebuild pipeline.

### Option 2: Make Stage Optional

Modify Jenkinsfile to make it optional:

```groovy
stage('OWASP Dependency Check'){
    when {
        expression { return false } // Set to true when ready
    }
    steps{
        dependencyCheck additionalArguments: '--scan ./ --format HTML ', odcInstallation: 'db-check'
        dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
    }
}
```

---

## 🔍 Check Plugin Installation

The missing installer option might mean the plugin isn't fully installed:

1. **Check plugin**:
   - Manage Jenkins → Plugins → Installed
   - Search for "OWASP Dependency-Check"
   - Verify it's installed and enabled

2. **Update plugin**:
   - Manage Jenkins → Plugins → Available
   - Search for "OWASP Dependency-Check"
   - Update if newer version available
   - Restart Jenkins after update

3. **Reinstall plugin**:
   - Uninstall "OWASP Dependency-Check"
   - Restart Jenkins
   - Reinstall "OWASP Dependency-Check"
   - Restart Jenkins again

---

## 📋 Recommended Approach

**For now, I recommend**:

1. **Skip OWASP stage temporarily** (Option 1 above)
2. **Test the rest of the pipeline** (SonarQube, Build, Docker, etc.)
3. **Fix OWASP later** using manual installation method

This way you can:
- ✅ Test SonarQube integration
- ✅ Test Docker build and push
- ✅ Test other stages
- ✅ Come back to fix OWASP when you have time

---

## 🎯 Quick Fix: Skip OWASP for Now

Would you like me to:
1. Update your Jenkinsfile to skip OWASP stage temporarily?
2. Help you with manual installation?
3. Check if the plugin needs updating?

Let me know which approach you prefer!

