# Reconfigure Jenkins After Container Recreation

Since we recreated the Jenkins container, you need to reconfigure the following:

## Step 1: Configure JDK and Maven Tools

1. Go to **Manage Jenkins** → **Tools**
2. Under **JDK installations**:
   - Click **Add JDK**
   - Name: `jdk17`
   - Check **Install automatically**
   - Version: Select **Java 17** (or latest available)
   - Click **Save**

3. Under **Maven installations**:
   - Click **Add Maven**
   - Name: `maven3`
   - Check **Install automatically**
   - Version: Select **Maven 3.9.x** (or latest available)
   - Click **Save**

## Step 2: Add Docker Hub Credentials

1. Go to **Manage Jenkins** → **Credentials**
2. Click **System** → **Global credentials (unrestricted)**
3. Click **Add Credentials**
4. Fill in:
   - **Kind**: Username with password
   - **Scope**: Global
   - **Username**: `mubashir2025` (your Docker Hub username)
   - **Password**: Your Docker Hub password or access token
   - **ID**: `DockerHub-Token` (must match exactly)
   - **Description**: Docker Hub Credentials
5. Click **OK**

## Step 3: Create the Pipeline Job

1. Click **New Item** on the Jenkins dashboard
2. Enter item name: `spring-boot-ci-cd`
3. Select **Pipeline**
4. Click **OK**
5. In the pipeline configuration:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/mubashir-mehran/spring-boot-jenkins-ci-cd`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`
6. Click **Save**

## Step 4: Verify SonarQube is Running

1. Check if SonarQube is accessible:
   - Open: http://localhost:9000
   - Default credentials: `admin` / `admin` (you may need to change password on first login)
   - The token in Jenkinsfile should still work: `squ_f6ae0f1ae224b08bb01266f9a817e169d24ee0b9`

## Step 5: Run the Pipeline

1. Go to your pipeline job: `spring-boot-ci-cd`
2. Click **Build Now**
3. Monitor the build progress

## Quick Checklist

- [ ] JDK 17 configured (name: `jdk17`)
- [ ] Maven 3 configured (name: `maven3`)
- [ ] Docker Hub credentials added (ID: `DockerHub-Token`)
- [ ] Pipeline job created (`spring-boot-ci-cd`)
- [ ] SonarQube accessible at http://localhost:9000
- [ ] Docker is working in Jenkins container (already done)

## Notes

- Docker CLI is already installed in the Jenkins container
- SonarQube should still be running (we didn't recreate its data volume)
- The Jenkinsfile is already in your GitHub repository

