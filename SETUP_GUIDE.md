# Complete Setup Guide - Spring Boot Jenkins CI/CD Project

This guide will help you run the application and set up the complete CI/CD pipeline.

---

## Part 1: Running the Application

### Option A: Using Docker Compose (Recommended - No Java Required)

This is the easiest way to run the application without installing Java locally.

#### Prerequisites
- Docker Desktop installed and running
- Docker Compose v2.x

#### Steps

1. **Navigate to the project directory:**
   ```bash
   cd Spring-Boot-Jenkins-CI-CD
   ```

2. **Build and start the application:**
   ```bash
   docker-compose -f docker-compose.local.yml up --build
   ```

   This will:
   - Build the Spring Boot application Docker image
   - Start MySQL database
   - Start the Spring Boot application
   - Wait for MySQL to be healthy before starting the app

3. **Verify the application is running:**
   - Application: http://localhost:8080
   - Swagger UI: http://localhost:8080/swagger-ui
   - API Base: http://localhost:8080/api

4. **Stop the application:**
   ```bash
   docker-compose -f docker-compose.local.yml down
   ```

5. **Stop and remove volumes (clean database):**
   ```bash
   docker-compose -f docker-compose.local.yml down -v
   ```

#### Testing the API

Once the application is running, you can test it:

**1. Create a Specialty:**
```bash
curl -X POST http://localhost:8080/api/specialite \
  -H "Content-Type: application/json" \
  -d "{\"code\":\"CS\",\"libelle\":\"Computer Science\"}"
```

**2. Get all Specialties:**
```bash
curl http://localhost:8080/api/specialite
```

**3. Create a Professor:**
```bash
curl -X POST http://localhost:8080/api/professeur \
  -H "Content-Type: application/json" \
  -d "{\"nom\":\"Smith\",\"prenom\":\"John\",\"telephone\":\"123-456-7890\",\"email\":\"john.smith@university.edu\",\"dateEmbauche\":\"2023-01-15\",\"specialite\":{\"id\":1}}"
```

**4. Get all Professors:**
```bash
curl http://localhost:8080/api/professeur
```

### Option B: Local Development (Requires Java 17)

If you prefer to run locally with Java:

#### Prerequisites
- Java JDK 17 installed
- Maven 3.x installed
- MySQL Server running on port 3307

#### Steps

1. **Install Java 17:**
   - Download from: https://adoptium.net/
   - Set JAVA_HOME environment variable

2. **Install Maven:**
   - Download from: https://maven.apache.org/download.cgi
   - Add to PATH

3. **Set up MySQL:**
   ```sql
   CREATE DATABASE springboot3;
   ```

4. **Update application.properties** (if MySQL is on different port):
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3307/springboot3
   spring.datasource.username=root
   spring.datasource.password=your_password
   ```

5. **Build and run:**
   ```bash
   cd Spring-Boot-Jenkins-CI-CD
   ./mvnw clean package
   java -jar target/GestionProfesseurs-0.0.1-SNAPSHOT.jar
   ```

6. **Access the application:**
   - Application: http://localhost:8080
   - Swagger UI: http://localhost:8080/swagger-ui

---

## Part 2: CI/CD Pipeline Setup

### Prerequisites for CI/CD

1. **Jenkins Server** (can be installed via Docker)
2. **SonarQube Server** (can be installed via Docker)
3. **Docker Hub Account**
4. **Trivy** (for vulnerability scanning)

---

### Step 1: Install Jenkins

#### Option A: Jenkins via Docker (Recommended)

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

**Initial Setup:**
1. Access Jenkins at: http://localhost:8080
2. Get initial admin password:
   ```bash
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Install suggested plugins
4. Create admin user

#### Option B: Jenkins on Local Machine

1. Download Jenkins from: https://www.jenkins.io/download/
2. Install and start Jenkins service
3. Follow initial setup wizard

---

### Step 2: Install Required Jenkins Plugins

1. Go to **Manage Jenkins** → **Plugins** → **Available plugins**
2. Search and install:
   - **Docker Pipeline**
   - **SonarQube Scanner**
   - **OWASP Dependency-Check**
   - **Git**
   - **Docker**
   - **Pipeline**

---

### Step 3: Configure Jenkins Tools

1. Go to **Manage Jenkins** → **Tools**

2. **Configure JDK:**
   - Name: `jdk17`
   - JAVA_HOME: Path to your JDK 17 installation
   - Or use automatic installer

3. **Configure Maven:**
   - Name: `maven3`
   - MAVEN_HOME: Path to your Maven installation
   - Or use automatic installer

4. **Configure Docker:**
   - Name: `docker`
   - Path: `docker` (if in PATH) or full path to docker executable

---

### Step 4: Set Up OWASP Dependency-Check

1. Go to **Manage Jenkins** → **Global Tool Configuration**
2. Find **OWASP Dependency-Check**
3. Add installation:
   - Name: `db-check`
   - Install automatically: Check this
   - Version: Latest

---

### Step 5: Set Up SonarQube

#### Install SonarQube Server

```bash
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:latest
```

**Wait for SonarQube to start** (may take 1-2 minutes):
```bash
docker logs -f sonarqube
```

#### Configure SonarQube

1. Access SonarQube: http://localhost:9000
2. Default credentials:
   - Username: `admin`
   - Password: `admin` (you'll be prompted to change it)

3. **Create a Project:**
   - Go to **Projects** → **Create Project**
   - Project key: `gestion-professeurs`
   - Display name: `Gestion Professeurs`

4. **Generate Token:**
   - Go to **My Account** → **Security**
   - Generate token: `squ_<your-token>`
   - Copy the token (you'll need it for Jenkins)

5. **Configure Jenkins:**
   - Go to **Manage Jenkins** → **Configure System**
   - Find **SonarQube servers**
   - Add SonarQube:
     - Name: `SonarQube`
     - Server URL: `http://localhost:9000`
     - Server authentication token: Add the token you generated

6. **Update Jenkinsfile:**
   - Edit the `Jenkinsfile` in your project
   - Update the SonarQube token on line 27:
     ```groovy
     -Dsonar.login=YOUR_SONARQUBE_TOKEN
     ```

---

### Step 6: Set Up Docker Hub Credentials

1. **Create Docker Hub Account** (if you don't have one):
   - Go to: https://hub.docker.com/
   - Sign up for free account

2. **Generate Access Token:**
   - Go to Docker Hub → **Account Settings** → **Security**
   - Click **New Access Token**
   - Name: `jenkins-ci-cd`
   - Copy the token

3. **Add Credentials in Jenkins:**
   - Go to **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
   - Click **Add Credentials**
   - Kind: `Username with password`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub access token
   - ID: `DockerHub-Token`
   - Description: `Docker Hub Credentials`

4. **Update Jenkinsfile:**
   - The Jenkinsfile already references `DockerHub-Token`
   - Update the Docker Hub username on lines 48-51:
     ```groovy
     sh "docker tag ${imageName} YOUR_DOCKERHUB_USERNAME/${buildTag}"
     sh "docker tag ${imageName} YOUR_DOCKERHUB_USERNAME/${latestTag}"
     sh "docker push YOUR_DOCKERHUB_USERNAME/${buildTag}"
     sh "docker push YOUR_DOCKERHUB_USERNAME/${latestTag}"
     ```

---

### Step 7: Install Trivy

Trivy needs to be installed on the Jenkins server or agent.

#### On Jenkins Server (Linux/Docker):

```bash
# Install Trivy
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

#### On Jenkins Server (Windows):

1. Download from: https://github.com/aquasecurity/trivy/releases
2. Extract and add to PATH

#### Verify Installation:

```bash
trivy --version
```

---

### Step 8: Create Jenkins Pipeline

1. **Create New Item:**
   - Go to Jenkins dashboard
   - Click **New Item**
   - Name: `spring-boot-ci-cd`
   - Type: **Pipeline**
   - Click **OK**

2. **Configure Pipeline:**
   - **Pipeline Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** `https://github.com/AbderrahmaneOd/Spring-Boot-Jenkins-CI-CD`
   - **Branch:** `main`
   - **Script Path:** `Jenkinsfile`

3. **Save and Build:**
   - Click **Save**
   - Click **Build Now**

4. **Monitor Build:**
   - Click on the build number
   - Click **Console Output** to see progress

---

### Step 9: Update Jenkinsfile (Important!)

Before running the pipeline, you need to update the `Jenkinsfile` with your specific values:

1. **Update SonarQube Token** (line 27):
   ```groovy
   -Dsonar.login=YOUR_ACTUAL_SONARQUBE_TOKEN
   ```

2. **Update Docker Hub Username** (lines 48-51):
   ```groovy
   sh "docker tag ${imageName} YOUR_USERNAME/${buildTag}"
   sh "docker tag ${imageName} YOUR_USERNAME/${latestTag}"
   sh "docker push YOUR_USERNAME/${buildTag}"
   sh "docker push YOUR_USERNAME/${latestTag}"
   ```

3. **Update Docker Hub Image Name** (line 18 in docker-compose.yml):
   ```yaml
   image: YOUR_USERNAME/spring-boot-prof-management:latest
   ```

---

## Troubleshooting

### Application Issues

**Problem: Application won't start**
- Check if MySQL is running and accessible
- Verify database connection in application.properties
- Check Docker logs: `docker logs springboot-app`

**Problem: Database connection error**
- Ensure MySQL container is healthy: `docker ps`
- Check MySQL logs: `docker logs springboot-mysql`
- Verify database credentials match

### CI/CD Pipeline Issues

**Problem: SonarQube connection failed**
- Verify SonarQube is running: `docker ps | grep sonarqube`
- Check SonarQube URL in Jenkinsfile matches your setup
- Verify token is correct

**Problem: Docker build/push failed**
- Verify Docker Hub credentials in Jenkins
- Check Docker Hub username in Jenkinsfile
- Ensure Docker is accessible from Jenkins

**Problem: Trivy not found**
- Verify Trivy is installed and in PATH
- Check Jenkins agent has Trivy installed
- May need to install on Jenkins server

**Problem: OWASP Dependency-Check failed**
- Verify plugin is installed
- Check installation name matches (`db-check`)
- May need to download database on first run

---

## Quick Start Commands

### Run Application (Docker):
```bash
cd Spring-Boot-Jenkins-CI-CD
docker-compose -f docker-compose.local.yml up --build
```

### Stop Application:
```bash
docker-compose -f docker-compose.local.yml down
```

### View Logs:
```bash
docker-compose -f docker-compose.local.yml logs -f
```

### Access Services:
- Application: http://localhost:8080
- Swagger UI: http://localhost:8080/swagger-ui
- Jenkins: http://localhost:8080 (if running on default port)
- SonarQube: http://localhost:9000

---

## Next Steps

1. ✅ Run the application using Docker Compose
2. ✅ Test the API endpoints
3. ✅ Set up Jenkins server
4. ✅ Configure SonarQube
5. ✅ Set up Docker Hub credentials
6. ✅ Create and run the pipeline
7. ✅ Monitor pipeline execution
8. ✅ Review SonarQube reports
9. ✅ Check Docker Hub for pushed images

---

## Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)

