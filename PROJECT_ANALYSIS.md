# Spring Boot Jenkins CI/CD Project - Complete Analysis

## Project Overview

This is a **Spring Boot REST API application** for managing professors (professeurs) and their specialties (specialités), integrated with a comprehensive **Jenkins CI/CD pipeline**. The application demonstrates modern DevOps practices including automated testing, security scanning, code quality analysis, containerization, and automated deployment.

---

## Application Architecture

### Technology Stack

#### Backend Framework
- **Spring Boot 3.1.5** - Main application framework
- **Java 17** - Programming language
- **Maven** - Build automation and dependency management

#### Data Layer
- **Spring Data JPA** - Java Persistence API for database operations
- **MySQL** - Relational database (configured for local and Docker environments)
- **Hibernate** - JPA implementation for ORM

#### API Documentation
- **SpringDoc OpenAPI (Swagger UI)** - API documentation and testing interface
  - Accessible at: `/swagger-ui`

#### Testing & Code Quality
- **JUnit 5** - Unit testing framework
- **JaCoCo** - Code coverage tool (version 0.8.11)
- **SonarQube Maven Plugin** - Static code analysis integration

---

## Application Features

### Domain Model

The application manages two main entities:

#### 1. **Specialite (Specialty)**
- **Fields:**
  - `id` (Integer, Primary Key, Auto-generated)
  - `code` (String) - Specialty code identifier
  - `libelle` (String) - Specialty label/name

#### 2. **Professeur (Professor)**
- **Fields:**
  - `id` (Integer, Primary Key, Auto-generated)
  - `nom` (String) - Last name
  - `prenom` (String) - First name
  - `telephone` (String) - Phone number
  - `email` (String) - Email address
  - `dateEmbauche` (Date) - Hire date
  - `specialite` (Specialite) - Many-to-One relationship with Specialite

### API Endpoints

#### Specialite (Specialty) Management
**Base URL:** `/api/specialite`

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| GET | `/api/specialite` | Get all specialties | List<Specialite> |
| GET | `/api/specialite/{id}` | Get specialty by ID | Specialite or Error |
| POST | `/api/specialite` | Create new specialty | Specialite |
| PUT | `/api/specialite/{id}` | Update existing specialty | Specialite or Error |
| DELETE | `/api/specialite/{id}` | Delete specialty | Success message or Error |

#### Professeur (Professor) Management
**Base URL:** `/api/professeur`

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| GET | `/api/professeur` | Get all professors | List<Professeur> |
| GET | `/api/professeur/{id}` | Get professor by ID | Professeur or Error |
| POST | `/api/professeur` | Create new professor | Professeur |
| PUT | `/api/professeur/{id}` | Update existing professor | Professeur or Error |
| DELETE | `/api/professeur/{id}` | Delete professor | Success message or Error |
| GET | `/api/professeur/specialite/{id}` | Get professors by specialty | List<Professeur> |
| GET | `/api/professeur/filterByDate?dateDebut={date}&dateFin={date}` | Filter professors by hire date range | List<Professeur> |

**Date Format:** `yyyy-MM-dd` (e.g., `2023-01-01`)

### Application Architecture Pattern

The application follows a **layered architecture**:

1. **Controller Layer** (`controllers/`)
   - REST endpoints
   - Request/Response handling
   - HTTP status code management

2. **Service Layer** (`services/`)
   - Business logic
   - Implements `IDao<T>` generic interface
   - Transaction management

3. **Repository Layer** (`repository/`)
   - Extends `JpaRepository<T, ID>`
   - Custom query methods using Spring Data JPA naming conventions
   - Database abstraction

4. **Entity Layer** (`entities/`)
   - JPA entities
   - Database table mapping
   - Relationships (Many-to-One)

5. **DAO Interface** (`dao/`)
   - Generic CRUD operations interface
   - Implemented by service classes

---

## CI/CD Pipeline (Jenkins)

### Pipeline Stages

The Jenkins pipeline (`Jenkinsfile`) implements a **7-stage CI/CD process**:

#### Stage 1: Code Checkout
- Clones the repository from GitHub
- Branch: `main`
- Disables changelog and polling for performance

#### Stage 2: OWASP Dependency Check
- **Tool:** OWASP Dependency-Check plugin
- **Action:** Scans all project dependencies for known vulnerabilities
- **Output:** HTML report (`dependency-check-report.xml`)
- **Installation:** Requires `db-check` installation in Jenkins

#### Stage 3: SonarQube Analysis
- **Tool:** SonarQube Scanner
- **Action:** Static code analysis for code quality, bugs, vulnerabilities, code smells
- **Configuration:**
  - SonarQube server: `http://localhost:9000/`
  - Authentication token required
- **Integration:** Uses JaCoCo for code coverage reporting

#### Stage 4: Clean & Package
- **Action:** Maven build process
  - Cleans previous builds
  - Compiles source code
  - Packages into JAR file
  - Skips tests (`-DskipTests`)
- **Output:** `target/GestionProfesseurs-0.0.1-SNAPSHOT.jar`

#### Stage 5: Docker Build & Push
- **Action:**
  1. Builds Docker image using `Dockerfile.final`
  2. Tags image with:
     - Build number: `spring-boot-prof-management:{BUILD_NUMBER}`
     - Latest: `spring-boot-prof-management:latest`
  3. Pushes both tags to Docker Hub (`abdeod/spring-boot-prof-management`)
- **Credentials:** Requires DockerHub token stored in Jenkins (`DockerHub-Token`)

#### Stage 6: Vulnerability Scanning
- **Tool:** Trivy
- **Action:** Scans the Docker image for security vulnerabilities
- **Target:** The built Docker image with build number tag

#### Stage 7: Staging Deployment
- **Action:** Deploys application using Docker Compose
- **Configuration:** Uses `docker-compose.yml`
- **Services:**
  - MySQL database
  - Spring Boot application
  - (Optional: phpMyAdmin - commented out)

---

## Docker Configuration

### Dockerfile.final
- **Base Image:** `openjdk:17-jdk-alpine` (lightweight)
- **Port:** Exposes port 8081
- **Build Process:** Copies pre-built JAR from `target/` directory
- **Entry Point:** Runs the Spring Boot JAR file

### docker-compose.yml
Defines a multi-container application:

#### MySQL Service
- **Image:** `mysql:latest`
- **Database:** `springboot3`
- **Root Password:** `root`
- **Port:** 3306 (internal only)
- **Health Check:** MySQL ping every 5 seconds
- **Restart Policy:** Always

#### Backend Service
- **Image:** `abdeod/spring-boot-prof-management:latest`
- **Port Mapping:** `8085:8080` (host:container)
- **Dependencies:** Waits for MySQL to start
- **Environment Variables:**
  - `SPRING_DATASOURCE_URL`: `jdbc:mysql://mysql:3306/springboot3`
  - `SPRING_DATASOURCE_USERNAME`: `root`
  - `SPRING_DATASOURCE_PASSWORD`: `root`
- **Restart Policy:** On failure

#### phpMyAdmin (Commented Out)
- Optional database management interface
- Would be accessible on port 8081

---

## Database Configuration

### Local Development (`application.properties`)
- **URL:** `jdbc:mysql://localhost:3307/springboot3`
- **Driver:** `com.mysql.cj.jdbc.Driver`
- **Username:** `root`
- **Password:** (empty)
- **Hibernate:** 
  - `ddl-auto=update` - Auto-updates schema
  - `show-sql=true` - Logs SQL queries

### Docker Environment
- Configured via environment variables in `docker-compose.yml`
- Database host: `mysql` (service name)
- Port: `3306`

---

## Build Configuration (Maven)

### Key Dependencies
- `spring-boot-starter-data-jpa` - JPA support
- `spring-boot-starter-data-rest` - REST API support
- `spring-boot-starter-web` - Web MVC
- `spring-boot-devtools` - Development tools (hot reload)
- `mysql-connector-j` - MySQL JDBC driver
- `springdoc-openapi-starter-webmvc-ui` - Swagger UI
- `spring-boot-starter-test` - Testing support

### Maven Plugins
- **spring-boot-maven-plugin** - Package executable JAR
- **sonar-maven-plugin** (v3.10.0.2594) - SonarQube integration
- **jacoco-maven-plugin** (v0.8.11) - Code coverage
  - Prepares agent during test execution
  - Generates coverage report during package phase

---

## How It Works

### Application Flow

1. **Startup:**
   - Spring Boot initializes the application
   - Hibernate creates/updates database schema
   - Swagger UI becomes available at `/swagger-ui`

2. **API Request Flow:**
   ```
   Client Request → Controller → Service → Repository → Database
                    ↓
                Response ← Entity ← JPA ← Result Set
   ```

3. **Data Persistence:**
   - JPA entities map to database tables
   - Many-to-One relationship: Professeur → Specialite
   - Automatic ID generation using `@GeneratedValue`

### CI/CD Flow

1. **Developer pushes code** to GitHub main branch
2. **Jenkins triggers pipeline** (on push or scheduled)
3. **Security & Quality Checks:**
   - OWASP scans dependencies
   - SonarQube analyzes code quality
4. **Build & Package:**
   - Maven compiles and packages application
5. **Containerization:**
   - Docker image is built and pushed to Docker Hub
6. **Security Scan:**
   - Trivy scans Docker image
7. **Deployment:**
   - Docker Compose deploys application stack

---

## Key Features Implemented

### ✅ Application Features
- [x] RESTful API for CRUD operations
- [x] Two-entity domain model (Professeur, Specialite)
- [x] Many-to-One relationship mapping
- [x] Custom query methods (filter by specialty, date range)
- [x] Error handling with appropriate HTTP status codes
- [x] Swagger/OpenAPI documentation
- [x] JPA/Hibernate ORM
- [x] MySQL database integration

### ✅ CI/CD Features
- [x] Automated code checkout
- [x] Dependency vulnerability scanning (OWASP)
- [x] Static code analysis (SonarQube)
- [x] Automated build and packaging
- [x] Docker image creation
- [x] Container registry push (Docker Hub)
- [x] Container security scanning (Trivy)
- [x] Automated staging deployment
- [x] Multi-stage Docker builds
- [x] Code coverage reporting (JaCoCo)

### ✅ DevOps Features
- [x] Docker containerization
- [x] Docker Compose orchestration
- [x] Health checks for services
- [x] Environment variable configuration
- [x] Service dependencies management
- [x] Automated testing framework setup

---

## Prerequisites to Run

### Local Development
- Java JDK 17
- Maven 3.x
- MySQL Server (running on port 3307)
- Git

### CI/CD Pipeline
- Jenkins server with plugins:
  - Docker Pipeline
  - SonarQube Scanner
  - OWASP Dependency-Check
  - Git
- SonarQube server (running on port 9000)
- Docker and Docker Compose
- Docker Hub account and credentials
- Trivy installed

---

## Project Structure

```
Spring-Boot-Jenkins-CI-CD/
├── .mvn/                    # Maven wrapper
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── ma/projet/gestionprofesseurs/
│   │   │       ├── GestionProfesseursApplication.java
│   │   │       ├── controllers/
│   │   │       │   ├── ProfesseurController.java
│   │   │       │   └── SpecialiteController.java
│   │   │       ├── dao/
│   │   │       │   └── IDao.java
│   │   │       ├── entities/
│   │   │       │   ├── Professeur.java
│   │   │       │   └── Specialite.java
│   │   │       ├── repository/
│   │   │       │   ├── ProfesseurRepository.java
│   │   │       │   └── SpecialiteRepository.java
│   │   │       └── services/
│   │   │           ├── ProfesseurService.java
│   │   │           └── SpecialiteService.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/
│           └── ma/projet/gestionprofesseurs/
│               └── GestionProfesseursApplicationTests.java
├── images/                   # Pipeline diagram images
├── Dockerfile                # Multi-stage build (not used in pipeline)
├── Dockerfile.final          # Final Docker image (used in pipeline)
├── docker-compose.yml        # Container orchestration
├── Jenkinsfile               # CI/CD pipeline definition
├── pom.xml                   # Maven configuration
├── mvnw                      # Maven wrapper (Unix)
├── mvnw.cmd                  # Maven wrapper (Windows)
└── README.md                 # Project documentation
```

---

## Security & Best Practices

### Security Measures
- OWASP Dependency Check for vulnerability scanning
- Trivy for container image scanning
- SonarQube for code quality and security analysis
- Environment-based configuration (no hardcoded secrets)

### Code Quality
- SonarQube integration for static analysis
- JaCoCo for code coverage metrics
- Layered architecture for maintainability
- Generic DAO interface for code reusability

### DevOps Best Practices
- Multi-stage Docker builds
- Health checks for services
- Service dependencies management
- Automated testing in pipeline
- Version tagging (build number + latest)

---

## API Usage Examples

### Create a Specialty
```bash
POST /api/specialite
Content-Type: application/json

{
  "code": "CS",
  "libelle": "Computer Science"
}
```

### Create a Professor
```bash
POST /api/professeur
Content-Type: application/json

{
  "nom": "Smith",
  "prenom": "John",
  "telephone": "123-456-7890",
  "email": "john.smith@university.edu",
  "dateEmbauche": "2023-01-15",
  "specialite": {
    "id": 1
  }
}
```

### Get Professors by Specialty
```bash
GET /api/professeur/specialite/1
```

### Filter Professors by Hire Date
```bash
GET /api/professeur/filterByDate?dateDebut=2023-01-01&dateFin=2023-12-31
```

---

## Conclusion

This project demonstrates a **complete DevOps workflow** for a Spring Boot application, from development to deployment. It showcases:

1. **Modern Spring Boot development** with REST APIs, JPA, and Swagger
2. **Comprehensive CI/CD pipeline** with security scanning and quality checks
3. **Containerization** with Docker and Docker Compose
4. **Automated deployment** to staging environment
5. **Best practices** in code organization, security, and DevOps

The application is production-ready with proper error handling, API documentation, and a robust CI/CD pipeline that ensures code quality and security before deployment.

