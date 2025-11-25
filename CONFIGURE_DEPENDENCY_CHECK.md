# Configure Dependency-Check Tool

## ✅ You Found It!

The section is called **"Dependency-Check installations"** (not "OWASP Dependency-Check"). This is the correct section!

---

## 📋 Step-by-Step Configuration

### Step 1: Add Dependency-Check Installation

1. In Jenkins Tools page, scroll to **"Dependency-Check installations"** section
2. Click **"Add Dependency-Check"** button
   - You should see a form appear below

### Step 2: Configure the Installation

Fill in the form with these values:

1. **Name**: `db-check`
   - ⚠️ **Must match exactly** what's in your Jenkinsfile (line 18)
   - This is case-sensitive!

2. **Install automatically**: ✅ **Check this box**
   - This will download and install Dependency-Check automatically

3. **Version**: Select from dropdown
   - Choose **"Latest"** or the most recent version available
   - Examples: `10.0.0`, `9.0.9`, etc.

4. **Installation directory** (if not using auto-install):
   - Leave empty if using auto-install
   - Only fill if you want to use a manually installed version

### Step 3: Save Configuration

1. Click **"Save"** or **"Apply"** button at the bottom of the page
2. Jenkins will start downloading Dependency-Check (this may take a few minutes)

### Step 4: Verify Installation

1. Go back to **Manage Jenkins** → **Tools**
2. Under **"Dependency-Check installations"**, you should now see:
   - Name: `db-check`
   - Version: (the version you selected)
   - Status: May show "Installing..." initially

---

## 🎯 Quick Configuration Summary

| Field | Value |
|-------|-------|
| **Name** | `db-check` (exact match!) |
| **Install automatically** | ✅ Checked |
| **Version** | Latest (or most recent) |

---

## ⚠️ Important Notes

1. **Name must be exact**: `db-check` (lowercase, with hyphen)
   - This must match line 18 in your Jenkinsfile: `odcInstallation: 'db-check'`

2. **First download takes time**: 
   - Dependency-Check will download vulnerability databases
   - This can take 10-20 minutes on first run
   - Be patient!

3. **Internet required**: 
   - Dependency-Check needs internet to download databases
   - Ensure Jenkins container has internet access

---

## 🔍 Verify in Jenkinsfile

Your Jenkinsfile line 18 should look like this:
```groovy
dependencyCheck additionalArguments: '--scan ./ --format HTML ', odcInstallation: 'db-check'
```

The `odcInstallation: 'db-check'` part must match the name you configure in Tools.

---

## ✅ After Configuration

1. **Save** the Tools configuration
2. Go back to your pipeline: `spring-boot-ci-cd`
3. Click **"Build Now"** again
4. The OWASP Dependency Check stage should now work!

---

## 🐛 If Still Not Working

1. **Check plugin is installed**:
   - Manage Jenkins → Plugins → Installed
   - Search for "OWASP Dependency-Check"
   - Should be installed and enabled

2. **Verify name matches**:
   - Tools → Dependency-Check installations → Name should be `db-check`
   - Jenkinsfile line 18 → `odcInstallation: 'db-check'`
   - These must match exactly!

3. **Check Jenkins logs**:
   ```powershell
   docker logs jenkins -f
   ```
   Look for Dependency-Check installation messages

---

**Once configured, rebuild your pipeline!** 🚀

