# Quick Start Guide

## 🚀 Running the Application (Fastest Way)

### Using Docker Compose (Recommended)

**Prerequisites:** Docker Desktop must be running

**Windows:**
```powershell
.\run-app.ps1
```

**Linux/Mac:**
```bash
chmod +x run-app.sh
./run-app.sh
```

**Or manually:**
```bash
docker-compose -f docker-compose.local.yml up --build
```

**Access the application:**
- 🌐 Application: http://localhost:8080
- 📚 Swagger UI: http://localhost:8080/swagger-ui
- 🔌 API Base: http://localhost:8080/api

**Stop the application:**
```bash
docker-compose -f docker-compose.local.yml down
```

---

## 🧪 Quick API Test

Once the application is running, test it with these commands:

### 1. Create a Specialty
```bash
curl -X POST http://localhost:8080/api/specialite ^
  -H "Content-Type: application/json" ^
  -d "{\"code\":\"CS\",\"libelle\":\"Computer Science\"}"
```

### 2. Get All Specialties
```bash
curl http://localhost:8080/api/specialite
```

### 3. Create a Professor
```bash
curl -X POST http://localhost:8080/api/professeur ^
  -H "Content-Type: application/json" ^
  -d "{\"nom\":\"Smith\",\"prenom\":\"John\",\"telephone\":\"123-456-7890\",\"email\":\"john.smith@university.edu\",\"dateEmbauche\":\"2023-01-15\",\"specialite\":{\"id\":1}}"
```

### 4. Get All Professors
```bash
curl http://localhost:8080/api/professeur
```

---

## 📋 CI/CD Pipeline Setup (Summary)

For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)

### Quick CI/CD Setup Checklist:

1. ✅ **Install Jenkins** (via Docker or local)
2. ✅ **Install Jenkins Plugins:**
   - Docker Pipeline
   - SonarQube Scanner
   - OWASP Dependency-Check
   - Git
3. ✅ **Set up SonarQube** (via Docker)
4. ✅ **Configure Docker Hub credentials** in Jenkins
5. ✅ **Install Trivy** on Jenkins server
6. ✅ **Update Jenkinsfile** with your tokens/usernames
7. ✅ **Create Jenkins Pipeline** job
8. ✅ **Run the pipeline!**

### Docker Commands for CI/CD Services:

**Start SonarQube:**
```bash
docker run -d --name sonarqube -p 9000:9000 -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true sonarqube:latest
```

**Start Jenkins:**
```bash
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

---

## 📖 Full Documentation

- **Complete Setup Guide:** [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Project Analysis:** [PROJECT_ANALYSIS.md](PROJECT_ANALYSIS.md)
- **Original README:** [README.md](README.md)

---

## 🆘 Troubleshooting

**Application won't start?**
- Check Docker is running: `docker ps`
- Check logs: `docker-compose -f docker-compose.local.yml logs`
- Verify port 8080 is not in use

**Database connection error?**
- Wait for MySQL to be healthy (check logs)
- Verify database credentials

**Need help?** See the detailed [SETUP_GUIDE.md](SETUP_GUIDE.md) for more troubleshooting tips.

