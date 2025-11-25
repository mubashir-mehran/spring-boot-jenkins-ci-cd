# Setup: Push to Your New Personal Repository

## 🎯 Goal
Push all your code (including the updated Jenkinsfile) to a new repository in your personal GitHub account.

---

## 📋 Step-by-Step Instructions

### Step 1: Create New Repository on GitHub

1. **Go to GitHub**: https://github.com
2. **Sign in** to your personal account
3. **Click the "+" icon** (top right) → **"New repository"**
4. **Configure repository**:
   - **Repository name**: `spring-boot-jenkins-ci-cd` (or any name you prefer)
   - **Description**: "Spring Boot CI/CD Pipeline with Jenkins, SonarQube, Docker"
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README, .gitignore, or license (we have code already)
5. **Click "Create repository"**

### Step 2: Copy Your New Repository URL

After creating the repository, GitHub will show you the repository URL. It will look like:
```
https://github.com/YOUR_USERNAME/spring-boot-jenkins-ci-cd.git
```

**Copy this URL** - you'll need it in the next step.

---

### Step 3: Update Git Remote URL

In your local project, update the remote to point to your new repository:

```powershell
# Replace YOUR_USERNAME and REPO_NAME with your actual values
git remote set-url origin https://github.com/YOUR_USERNAME/REPO_NAME.git
```

**Example**:
```powershell
git remote set-url origin https://github.com/mubashir2025/spring-boot-jenkins-ci-cd.git
```

### Step 4: Verify Remote URL

Check that the remote is updated correctly:

```powershell
git remote -v
```

You should see your new repository URL.

---

### Step 5: Push All Code to New Repository

Now push all your code (including the updated Jenkinsfile):

```powershell
# Push to the new repository
git push -u origin main
```

If you get authentication errors:
- You may need to use a Personal Access Token
- Generate one at: https://github.com/settings/tokens
- Use it as your password when pushing

---

### Step 6: Update Jenkins Pipeline Configuration

After pushing to your new repository, update Jenkins to use your new repository:

1. **Go to Jenkins**: http://localhost:8081
2. **Open your pipeline**: `spring-boot-ci-cd`
3. **Click "Configure"**
4. **Scroll to Pipeline section**
5. **Update Repository URL** to your new repository:
   ```
   https://github.com/YOUR_USERNAME/REPO_NAME.git
   ```
6. **Click "Save"**

---

## 🔄 Alternative: Add New Remote (Keep Both)

If you want to keep the old remote and add a new one:

```powershell
# Add new remote (you can name it anything)
git remote add personal https://github.com/YOUR_USERNAME/REPO_NAME.git

# Push to new remote
git push -u personal main
```

Then update Jenkins to use the new remote URL.

---

## 📝 Quick Command Summary

```powershell
# 1. Check current remote
git remote -v

# 2. Update remote to your new repository
git remote set-url origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# 3. Verify remote
git remote -v

# 4. Push all code
git push -u origin main
```

---

## ⚠️ Important Notes

1. **All your changes are committed locally** - they're safe
2. **The updated Jenkinsfile** (with OWASP disabled) is included
3. **All documentation files** will be pushed too
4. **After pushing**, update Jenkins pipeline configuration to use new repo URL

---

## 🎯 After Pushing

1. ✅ Code is in your personal repository
2. ✅ Update Jenkins pipeline to use new repository URL
3. ✅ Rebuild pipeline in Jenkins
4. ✅ Test all stages

---

## 🔐 Authentication

If you need to set up authentication:

1. **Generate Personal Access Token**:
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes: `repo` (full control)
   - Copy the token

2. **Use token when pushing**:
   - Username: Your GitHub username
   - Password: Your Personal Access Token (not your GitHub password)

---

**Ready to set up your new repository!** 🚀

