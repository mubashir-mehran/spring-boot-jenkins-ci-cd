# Step 7: Create Jenkins Pipeline - Detailed Guide

## 🎯 Objective
Create a Jenkins pipeline job that will automatically build, test, scan, and deploy your Spring Boot application.

---

## 📋 Prerequisites Checklist

Before creating the pipeline, ensure you have completed:

- [x] Jenkins initial setup (Step 1)
- [x] Installed required plugins (Step 2)
- [x] Configured JDK, Maven, Docker, OWASP tools (Step 3)
- [x] Set up SonarQube and added token to Jenkins (Step 4)
- [x] Added Docker Hub credentials to Jenkins (Step 5)
- [x] Updated Jenkinsfile with your tokens/usernames (Step 6)

---

## 🚀 Step-by-Step Instructions

### Step 7.1: Access Jenkins Dashboard

1. Open your web browser
2. Navigate to: **http://localhost:8081**
3. Log in with your Jenkins admin credentials
4. You should see the Jenkins dashboard

---

### Step 7.2: Create New Pipeline Item

1. On the Jenkins dashboard, click **"New Item"** (usually on the left sidebar)
   - If you don't see it, click **"Create a job"** or look for **"+"** icon

2. You'll see the "New Item" page with different job types

3. **Enter an item name**: `spring-boot-ci-cd`
   - This will be the name of your pipeline job
   - Use lowercase, no spaces (or use hyphens)

4. **Select job type**: Scroll down and select **"Pipeline"**
   - Pipeline jobs allow you to define the build process using a Jenkinsfile

5. Click **"OK"** button at the bottom

---

### Step 7.3: Configure Pipeline Settings

You'll now be on the pipeline configuration page. Fill in the following:

#### General Settings

1. **Description** (Optional but recommended):
   ```
   Spring Boot CI/CD Pipeline
   - OWASP Dependency Check
   - SonarQube Analysis
   - Docker Build & Push
   - Trivy Vulnerability Scanning
   - Staging Deployment
   ```

2. **Build Triggers** (Optional):
   - You can set up automatic builds later
   - For now, leave unchecked (manual builds)

#### Pipeline Configuration

1. Scroll down to the **"Pipeline"** section

2. **Definition**: Select **"Pipeline script from SCM"**
   - This tells Jenkins to use the Jenkinsfile from your Git repository

3. **SCM**: Select **"Git"** from the dropdown

4. **Repository URL**: 
   ```
   https://github.com/AbderrahmaneOd/Spring-Boot-Jenkins-CI-CD
   ```
   - This is your GitHub repository URL
   - If your repo is private, you'll need to add credentials (see below)

5. **Credentials** (if repository is private):
   - Click **"Add"** button
   - Select **"Jenkins"**
   - Choose **"Username with password"**
   - Enter your GitHub username and password/token
   - ID: `github-credentials` (or any name)
   - Click **"Add"**
   - Then select it from the dropdown

6. **Branch Specifier**: 
   ```
   */main
   ```
   - This tells Jenkins to build from the main branch
   - If your default branch is `master`, use `*/master`

7. **Script Path**: 
   ```
   Jenkinsfile
   ```
   - This is the name of your Jenkinsfile in the repository
   - Jenkins will look for this file in the root of your repository

8. **Lightweight checkout** (Optional):
   - Leave unchecked for now
   - This is useful for large repositories

---

### Step 7.4: Save Configuration

1. Scroll to the bottom of the page
2. Click **"Save"** button
   - This will save your pipeline configuration
   - You'll be redirected to the pipeline job page

---

### Step 7.5: Verify Pipeline Configuration

After saving, you should see:

1. **Pipeline job page** with the name `spring-boot-ci-cd`
2. **Left sidebar** with options:
   - Status
   - Build History
   - Build Now
   - Configure
   - Delete Pipeline
   - etc.

3. **Pipeline Syntax** link (useful for testing Jenkinsfile syntax)

---

### Step 7.6: Build the Pipeline

1. On the pipeline job page, click **"Build Now"** button
   - This will trigger the first build
   - You'll see a new build appear in the "Build History" section

2. **Monitor the build**:
   - Click on the build number (e.g., **#1**) in the Build History
   - Or click on the progress bar that appears
   - This opens the build details page

3. **View Console Output**:
   - Click **"Console Output"** in the left sidebar
   - This shows real-time logs of the build process
   - You can see each stage executing:
     - Code Checkout
     - OWASP Dependency Check
     - SonarQube Analysis
     - Clean & Package
     - Docker Build & Push
     - Vulnerability Scanning
     - Staging

---

### Step 7.7: Understanding Build Stages

Your pipeline will execute these stages in order:

1. **Code Checkout** ✅
   - Clones the repository from GitHub

2. **OWASP Dependency Check** 🔍
   - Scans project dependencies for vulnerabilities
   - Generates HTML report

3. **SonarQube Analysis** 📊
   - Performs static code analysis
   - Checks code quality metrics

4. **Clean & Package** 📦
   - Cleans previous builds
   - Compiles and packages the application into JAR

5. **Docker Build & Push** 🐳
   - Builds Docker image
   - Tags with build number and latest
   - Pushes to Docker Hub

6. **Vulnerability Scanning** 🔒
   - Scans Docker image with Trivy
   - Reports security vulnerabilities

7. **Staging** 🚀
   - Deploys using Docker Compose
   - Sets up application stack

---

## 🐛 Troubleshooting Common Issues

### Issue 1: "Cannot connect to repository"
**Solution**:
- Verify repository URL is correct
- If private repo, add GitHub credentials
- Check internet connectivity

### Issue 2: "Jenkinsfile not found"
**Solution**:
- Verify Script Path is `Jenkinsfile` (case-sensitive)
- Ensure Jenkinsfile exists in repository root
- Check branch name is correct

### Issue 3: "Tool not found" (JDK, Maven, etc.)
**Solution**:
- Go to Manage Jenkins → Tools
- Verify tools are configured with correct names:
  - JDK: `jdk17`
  - Maven: `maven3`
  - Docker: `docker`
  - OWASP: `db-check`

### Issue 4: "SonarQube connection failed"
**Solution**:
- Check SonarQube is running: `docker ps | grep sonarqube`
- Verify SonarQube URL in Jenkinsfile
- Check SonarQube token is correct
- Ensure SonarQube is accessible from Jenkins

### Issue 5: "Docker build/push failed"
**Solution**:
- Verify Docker Hub credentials in Jenkins
- Check Docker Hub username in Jenkinsfile matches your account
- Ensure Docker is accessible from Jenkins
- Verify Docker Hub token has correct permissions

### Issue 6: "Trivy not found"
**Solution**:
- Install Trivy in Jenkins container:
```powershell
docker exec -it jenkins bash
apt-get update && apt-get install -y wget
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update && apt-get install -y trivy
exit
```

---

## ✅ Success Indicators

Your pipeline is working correctly if you see:

1. ✅ All stages complete successfully (green checkmarks)
2. ✅ Build status shows "Success" (blue ball)
3. ✅ Docker image pushed to Docker Hub
4. ✅ SonarQube analysis completed
5. ✅ Application deployed to staging

---

## 📊 Viewing Results

### Build Status
- **Blue ball**: Success
- **Red ball**: Failure
- **Yellow ball**: Unstable
- **Gray ball**: Not built/Aborted

### Build Artifacts
- Click on build number → **Artifacts**
- Download generated reports (OWASP, etc.)

### SonarQube Results
- Go to http://localhost:9000
- Navigate to your project
- View code quality metrics

### Docker Hub
- Go to https://hub.docker.com/
- Check your repository for pushed images

---

## 🔄 Running Subsequent Builds

After the first build:

1. **Manual Build**: Click **"Build Now"** anytime
2. **Automatic Build**: Configure triggers in pipeline settings:
   - Poll SCM (check repository periodically)
   - GitHub webhook (trigger on push)
   - Scheduled builds (cron)

---

## 📝 Next Steps After Pipeline Creation

1. ✅ Monitor first build completion
2. ✅ Review SonarQube reports
3. ✅ Check Docker Hub for pushed images
4. ✅ Verify staging deployment
5. ✅ Set up build triggers (optional)
6. ✅ Configure notifications (optional)

---

## 🎯 Quick Reference

| Action | Location |
|--------|----------|
| Create Pipeline | Dashboard → New Item |
| Build Pipeline | Pipeline page → Build Now |
| View Logs | Build → Console Output |
| Configure | Pipeline page → Configure |
| View History | Pipeline page → Build History |

---

**Pipeline Name**: `spring-boot-ci-cd`  
**Repository**: `https://github.com/AbderrahmaneOd/Spring-Boot-Jenkins-CI-CD`  
**Branch**: `main`  
**Jenkinsfile**: `Jenkinsfile`

---

**Ready to create your pipeline!** 🚀

Follow the steps above, and if you encounter any issues, refer to the troubleshooting section or check the console output for detailed error messages.

