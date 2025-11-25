# Add Dependency-Check Installer

## 🔍 Issue Identified

Your Dependency-Check configuration has:
- ✅ Name: `db-check` (correct)
- ✅ Install automatically: Checked (correct)
- ❌ **Missing**: No installer/version selected!

## ✅ Solution: Add Installer

### Step 1: Click "+ Add Installer" Button

1. In the Dependency-Check configuration box, you'll see a button: **"+ Add Installer"**
2. Click this button

### Step 2: Select Installer Type

After clicking "+ Add Installer", you'll see a dropdown menu with options. Select:

**"Dependency-Check"** (or "Install Dependency-Check")

### Step 3: Configure the Installer

You'll see a form with these fields:

1. **Version**: 
   - Click the dropdown
   - Select **"Latest"** or the most recent version available
   - Examples: `10.0.0`, `9.0.9`, `8.4.0`, etc.
   - **Recommended**: Select **"Latest"**

2. **Label** (Optional):
   - Leave empty or add a label like "Dependency-Check Latest"

### Step 4: Save Configuration

1. After selecting the version, click **"Save"** at the bottom of the page
2. Jenkins will start downloading Dependency-Check (this takes 5-15 minutes)

### Step 5: Verify Installation

1. Go back to **Manage Jenkins** → **Tools**
2. Under **Dependency-Check installations**, you should see:
   - Name: `db-check`
   - Version: Should show the version you selected (e.g., `10.0.0`)
   - Status: May show "Installing..." initially, then the version number when complete

---

## 📋 Quick Steps Summary

1. ✅ Name: `db-check` (already set)
2. ✅ Install automatically: Checked (already set)
3. **Click "+ Add Installer"** ← **YOU NEED TO DO THIS!**
4. Select "Dependency-Check" from dropdown
5. Select Version: **Latest**
6. Click **Save**
7. Wait 5-15 minutes for installation
8. Rebuild pipeline

---

## 🎯 What You Should See

After adding the installer, your configuration should look like:

```
┌─────────────────────────────────────┐
│ Dependency-Check                    │
│ Name: db-check                      │
│ ☑ Install automatically?            │
│                                     │
│ Installers:                         │
│ ┌─────────────────────────────────┐ │
│ │ Dependency-Check                │ │
│ │ Version: Latest (10.0.0)        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [+ Add Installer]                   │
└─────────────────────────────────────┘
```

---

## ⚠️ Important Notes

1. **You MUST add an installer**: Just checking "Install automatically" is not enough - you need to specify which version to install

2. **First download takes time**: 
   - Dependency-Check is a large download (100+ MB)
   - Can take 5-15 minutes depending on internet speed
   - Be patient!

3. **Check installation status**:
   - After saving, go back to Tools page
   - Status will show "Installing..." while downloading
   - When complete, it will show the version number

---

## 🔄 After Adding Installer

1. **Save** the configuration
2. **Wait** for installation to complete (check Tools page)
3. **Verify** status shows version number (not "Installing...")
4. **Rebuild** your pipeline

---

## 🐛 If Installer Option Doesn't Appear

If clicking "+ Add Installer" doesn't show "Dependency-Check" option:

1. **Check plugin is installed**:
   - Manage Jenkins → Plugins → Installed
   - Search for "OWASP Dependency-Check"
   - Should be installed and enabled

2. **Update plugin**:
   - Manage Jenkins → Plugins → Available
   - Search for "OWASP Dependency-Check"
   - Update if newer version available

3. **Restart Jenkins**:
   ```powershell
   docker restart jenkins
   ```

---

**The key step you're missing: Click "+ Add Installer" and select a version!** 🚀

