# 🚀 Quick Start: Jenkins CI/CD Setup

## ✅ Pre-requisites Check

- [x] Jenkins running on http://localhost:8081
- [x] SonarQube running on http://localhost:9000
- [x] Docker Desktop running
- [x] Application running on http://localhost:8080

---

## 📋 Setup Checklist

### Phase 1: Jenkins Initial Setup (5 minutes)

1. **Access Jenkins**
   - URL: http://localhost:8081
   - Password: `fa198848548047c9bcc72106528c29e3`
   - Install suggested plugins
   - Create admin user

2. **Install Required Plugins**
   - Docker Pipeline
   - SonarQube Scanner
   - OWASP Dependency-Check
   - Git
   - Docker

### Phase 2: Configure Tools (5 minutes)

3. **Configure JDK 17**
   - Manage Jenkins → Tools → Add JDK
   - Name: `jdk17`
   - Install automatically: ✅

4. **Configure Maven**
   - Add Maven
   - Name: `maven3`
   - Install automatically: ✅

5. **Configure Docker**
   - Add Docker
   - Name: `docker`
   - Path: `docker`

6. **Configure OWASP Dependency-Check**
   - Add Dependency-Check
   - Name: `db-check`
   - Install automatically: ✅

### Phase 3: SonarQube Setup (5 minutes)

7. **Access SonarQube**
   - URL: http://localhost:9000
   - Login: `admin` / `admin` (change password)

8. **Create Project**
   - Project key: `gestion-professeurs`
   - Display name: `Gestion Professeurs`

9. **Generate Token**
   - My Account → Security → Generate Tokens
   - Name: `jenkins-ci-cd`
   - **⚠️ COPY THE TOKEN!**

10. **Add Token to Jenkins**
    - Manage Jenkins → Configure System
    - SonarQube servers → Add SonarQube
    - Name: `SonarQube`
    - Server URL: `http://sonarqube:9000` or `http://localhost:9000`
    - Add authentication token (paste your token)

### Phase 4: Docker Hub Setup (5 minutes)

11. **Create Docker Hub Access Token**
    - Go to https://hub.docker.com/
    - Account Settings → Security → New Access Token
    - **⚠️ COPY THE TOKEN!**

12. **Add Docker Hub Credentials to Jenkins**
    - Manage Jenkins → Credentials → System → Global
    - Add Credentials
    - Kind: Username with password
    - Username: Your Docker Hub username
    - Password: Your Docker Hub access token
    - ID: `DockerHub-Token`

### Phase 5: Update Jenkinsfile (2 minutes)

13. **Update SonarQube Token in Jenkinsfile**
    - Line 27: Replace `squ_9bd7c664e4941bd4e7670a88ed93d68af40b42a3` with your token

14. **Update Docker Hub Username (if different)**
    - Lines 48-51: Replace `abdeod` with your Docker Hub username

15. **Update SonarQube URL (if needed)**
    - Line 26: Use `http://sonarqube:9000/` if Jenkins is in Docker
    - Or `http://host.docker.internal:9000/` for Windows/Mac

### Phase 6: Create Pipeline (3 minutes)

16. **Create New Pipeline**
    - New Item → `spring-boot-ci-cd` → Pipeline

17. **Configure Pipeline**
    - Pipeline script from SCM
    - Git
    - Repository: `https://github.com/AbderrahmaneOd/Spring-Boot-Jenkins-CI-CD`
    - Branch: `*/main`
    - Script Path: `Jenkinsfile`

18. **Build Pipeline**
    - Click Build Now
    - Monitor Console Output

### Phase 7: Install Trivy (Optional - 5 minutes)

19. **Install Trivy in Jenkins Container**
```powershell
docker exec -it jenkins bash
apt-get update && apt-get install -y wget
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update && apt-get install -y trivy
exit
```

---

## 🎯 Quick Access Links

- **Jenkins**: http://localhost:8081
- **SonarQube**: http://localhost:9000
- **Application**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui

---

## 🔑 Important Credentials

| Service | Username | Password/Token |
|---------|----------|----------------|
| Jenkins Initial | admin | `fa198848548047c9bcc72106528c29e3` |
| SonarQube Default | admin | admin (change on first login) |
| Docker Hub | Your username | Your access token |

---

## ⚠️ Important Notes

1. **SonarQube Token**: Generate it in SonarQube UI and add to Jenkins
2. **Docker Hub Token**: Use access token, NOT password
3. **Jenkinsfile Updates**: Update SonarQube token and Docker Hub username
4. **Network**: Jenkins and SonarQube should be on same Docker network
5. **Trivy**: Install in Jenkins container for vulnerability scanning

---

## 🐛 Common Issues

### Jenkins can't reach SonarQube
- Use `http://sonarqube:9000` if on same Docker network
- Or `http://host.docker.internal:9000` for Windows/Mac

### Docker build fails
- Ensure Docker Hub credentials are correct
- Check Docker Hub username in Jenkinsfile

### Trivy not found
- Install Trivy in Jenkins container (see Phase 7)

---

## 📚 Full Documentation

For detailed setup instructions, see:
- **JENKINS_CI_CD_SETUP.md** - Complete step-by-step guide
- **SETUP_GUIDE.md** - Original setup guide
- **SETUP_COMPLETE.md** - Application setup summary

---

**Estimated Total Setup Time**: 30-40 minutes  
**Status**: Ready to start! 🚀

