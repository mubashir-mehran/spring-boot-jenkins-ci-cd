# Jenkins CI/CD Pipeline Setup Guide

## 🎯 Current Status

✅ **Jenkins**: Running on http://localhost:8081  
✅ **SonarQube**: Running on http://localhost:9000  
✅ **Initial Admin Password**: `fa198848548047c9bcc72106528c29e3`

---

## Step 1: Initial Jenkins Setup

### 1.1 Access Jenkins
1. Open your browser and go to: **http://localhost:8081**
2. You'll be prompted for the initial admin password
3. Enter: `fa198848548047c9bcc72106528c29e3`
4. Click **Continue**

### 1.2 Install Suggested Plugins
1. Click **Install suggested plugins**
2. Wait for installation to complete (may take 5-10 minutes)
3. Create your admin user or continue as admin

---

## Step 2: Install Required Jenkins Plugins

After initial setup, install these plugins:

1. Go to **Manage Jenkins** → **Plugins** → **Available plugins**
2. Search and install:
   - ✅ **Docker Pipeline**
   - ✅ **SonarQube Scanner**
   - ✅ **OWASP Dependency-Check**
   - ✅ **Git**
   - ✅ **Docker**
   - ✅ **Pipeline**
   - ✅ **Pipeline: Stage View**
   - ✅ **Blue Ocean** (optional, for better UI)

3. Click **Install without restart** or **Download now and install after restart**
4. Restart Jenkins if prompted

---

## Step 3: Configure Jenkins Tools

### 3.1 Configure JDK 17
1. Go to **Manage Jenkins** → **Tools**
2. Under **JDK installations**, click **Add JDK**
3. Name: `jdk17`
4. Check **Install automatically**
5. Version: Select **Java 17** (e.g., `17` or `17.0.x`)
6. Click **Save**

### 3.2 Configure Maven
1. In the same **Tools** page
2. Under **Maven installations**, click **Add Maven**
3. Name: `maven3`
4. Check **Install automatically**
5. Version: Select latest **Maven 3.x**
6. Click **Save**

### 3.3 Configure Docker
1. In the same **Tools** page
2. Under **Docker installations**, click **Add Docker**
3. Name: `docker`
4. Path: `docker` (if Docker is in PATH)
   - Or full path: `C:\Program Files\Docker\Docker\resources\bin\docker.exe` (Windows)
5. Click **Save**

### 3.4 Configure OWASP Dependency-Check
1. In the same **Tools** page
2. Under **OWASP Dependency-Check**, click **Add Dependency-Check**
3. Name: `db-check`
4. Check **Install automatically**
5. Version: Select **Latest**
6. Click **Save**

---

## Step 4: Configure SonarQube in Jenkins

### 4.1 Set Up SonarQube Server
1. Go to **Manage Jenkins** → **Configure System**
2. Scroll down to **SonarQube servers**
3. Click **Add SonarQube**
4. Configure:
   - **Name**: `SonarQube`
   - **Server URL**: `http://sonarqube:9000` (for Docker) or `http://localhost:9000`
   - **Server authentication token**: (We'll add this after creating SonarQube token)
5. Click **Save**

### 4.2 Configure SonarQube Scanner
1. Go to **Manage Jenkins** → **Tools**
2. Under **SonarQube Scanner**, click **Add SonarQube Scanner**
3. Name: `SonarQube Scanner`
4. Check **Install automatically**
5. Version: Select **Latest**
6. Click **Save**

---

## Step 5: Set Up SonarQube Project

### 5.1 Access SonarQube
1. Open browser: **http://localhost:9000**
2. Default credentials:
   - Username: `admin`
   - Password: `admin` (you'll be prompted to change it)

### 5.2 Create Project
1. Click **Create Project** → **Manually**
2. **Project key**: `gestion-professeurs`
3. **Display name**: `Gestion Professeurs`
4. Click **Set Up**

### 5.3 Generate Token
1. Go to **My Account** → **Security** (top right)
2. Under **Generate Tokens**, enter:
   - **Name**: `jenkins-ci-cd`
   - **Type**: **User Token**
   - **Expires in**: (optional, or set expiration date)
3. Click **Generate**
4. **⚠️ COPY THE TOKEN IMMEDIATELY** (you won't see it again!)
   - Format: `squ_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### 5.4 Add Token to Jenkins
1. Go back to Jenkins: **Manage Jenkins** → **Configure System**
2. Find **SonarQube servers** section
3. Click **Add** next to **Server authentication token**
4. Select **Secret text**
5. **Secret**: Paste your SonarQube token
6. **ID**: `sonarqube-token` (or any ID)
7. Click **Add**
8. Select the token from dropdown in SonarQube server config
9. Click **Save**

---

## Step 6: Set Up Docker Hub Credentials

### 6.1 Create Docker Hub Access Token
1. Go to https://hub.docker.com/
2. Sign in (or create account)
3. Go to **Account Settings** → **Security**
4. Click **New Access Token**
5. **Description**: `jenkins-ci-cd`
6. **Permissions**: **Read & Write**
7. Click **Generate**
8. **⚠️ COPY THE TOKEN** (you won't see it again!)

### 6.2 Add Docker Hub Credentials to Jenkins
1. Go to **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
2. Click **Add Credentials**
3. Configure:
   - **Kind**: `Username with password`
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub access token (not password!)
   - **ID**: `DockerHub-Token`
   - **Description**: `Docker Hub Credentials`
4. Click **OK**

---

## Step 7: Update Jenkinsfile (If Needed)

The Jenkinsfile needs to be updated with your specific values:

### 7.1 Update SonarQube URL
If SonarQube is running in Docker, you may need to update the URL:
- Current: `http://localhost:9000/`
- If Jenkins can't reach it, try: `http://host.docker.internal:9000/` (Windows/Mac)
- Or use the Docker service name if in same network

### 7.2 Update Docker Hub Username
The Jenkinsfile currently uses `abdeod` as Docker Hub username. Update lines 48-51 if different:
```groovy
sh "docker tag ${imageName} YOUR_USERNAME/${buildTag}"
sh "docker tag ${imageName} YOUR_USERNAME/${latestTag}"
sh "docker push YOUR_USERNAME/${buildTag}"
sh "docker push YOUR_USERNAME/${latestTag}"
```

### 7.3 Update SonarQube Token
Update line 27 with your actual SonarQube token:
```groovy
-Dsonar.login=YOUR_ACTUAL_SONARQUBE_TOKEN
```

---

## Step 8: Create Jenkins Pipeline Job

### 8.1 Create New Pipeline
1. Go to Jenkins dashboard
2. Click **New Item**
3. **Item name**: `spring-boot-ci-cd`
4. Select **Pipeline**
5. Click **OK**

### 8.2 Configure Pipeline
1. **Description**: `Spring Boot CI/CD Pipeline with SonarQube, OWASP, Docker, and Trivy`

2. **Pipeline Definition**: 
   - Select **Pipeline script from SCM**
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/AbderrahmaneOd/Spring-Boot-Jenkins-CI-CD`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`
   - **Credentials**: (Leave empty if public repo, or add if private)

3. Click **Save**

### 8.3 Build the Pipeline
1. Click **Build Now** on the pipeline page
2. Click on the build number to see progress
3. Click **Console Output** to see detailed logs

---

## Step 9: Install Trivy (For Vulnerability Scanning)

Trivy needs to be installed on the Jenkins server/agent.

### Option A: Install on Jenkins Container (Recommended)
```powershell
docker exec -it jenkins bash
apt-get update
apt-get install -y wget
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update
apt-get install -y trivy
exit
```

### Option B: Install on Windows Host
1. Download from: https://github.com/aquasecurity/trivy/releases
2. Extract and add to PATH
3. Ensure Jenkins can access it

---

## Step 10: Troubleshooting

### Issue: SonarQube Connection Failed
- **Solution**: 
  - Check SonarQube is running: `docker ps | grep sonarqube`
  - Update SonarQube URL in Jenkinsfile to use Docker service name or host IP
  - Verify token is correct

### Issue: Docker Build/Push Failed
- **Solution**:
  - Verify Docker Hub credentials in Jenkins
  - Check Docker Hub username in Jenkinsfile matches your account
  - Ensure Docker is accessible from Jenkins container

### Issue: Trivy Not Found
- **Solution**:
  - Install Trivy in Jenkins container (see Step 9)
  - Or install on host and ensure it's in PATH
  - Verify installation: `docker exec jenkins trivy --version`

### Issue: OWASP Dependency-Check Failed
- **Solution**:
  - Verify plugin is installed
  - Check installation name matches (`db-check`)
  - First run may take time to download database

### Issue: Jenkins Can't Access Docker
- **Solution**:
  - Add Jenkins user to docker group (Linux)
  - Or mount Docker socket: `-v /var/run/docker.sock:/var/run/docker.sock` (if using Docker-in-Docker)
  - For Windows, ensure Docker Desktop is running

---

## Step 11: Verify Pipeline Stages

Your pipeline should execute these stages:

1. ✅ **Code Checkout** - Clones repository
2. ✅ **OWASP Dependency Check** - Scans dependencies
3. ✅ **SonarQube Analysis** - Code quality analysis
4. ✅ **Clean & Package** - Builds JAR file
5. ✅ **Docker Build & Push** - Creates and pushes Docker image
6. ✅ **Vulnerability Scanning** - Scans Docker image with Trivy
7. ✅ **Staging** - Deploys using Docker Compose

---

## Quick Reference

### Access URLs
- **Jenkins**: http://localhost:8081
- **SonarQube**: http://localhost:9000
- **Application**: http://localhost:8080

### Important Credentials
- **Jenkins Initial Password**: `fa198848548047c9bcc72106528c29e3`
- **SonarQube Default**: `admin/admin` (change on first login)
- **Docker Hub**: Your username + access token

### Useful Commands
```powershell
# View Jenkins logs
docker logs jenkins -f

# View SonarQube logs
docker logs sonarqube -f

# Restart Jenkins
docker restart jenkins

# Restart SonarQube
docker restart sonarqube
```

---

## Next Steps

1. ✅ Complete Jenkins initial setup
2. ✅ Install required plugins
3. ✅ Configure tools (JDK, Maven, Docker, OWASP)
4. ✅ Set up SonarQube project and token
5. ✅ Add Docker Hub credentials
6. ✅ Create and run pipeline
7. ✅ Monitor pipeline execution
8. ✅ Review SonarQube reports
9. ✅ Check Docker Hub for pushed images

---

**Setup Guide Created**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Status**: Ready for configuration

