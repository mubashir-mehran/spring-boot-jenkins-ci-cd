# Spring Boot CI/CD Pipeline with Jenkins

This repository contains a simple Spring Boot application integrated with a CI/CD pipeline using Jenkins. The pipeline automates the build, test, and deployment processes, including OWASP Dependency Check, SonarQube Analysis, Docker image creation, vulnerability scanning, Code Coverage and deployment to a staging environment.

## Technologies Used

- Jenkins (CI/CD orchestration)
- Spring Boot (Application framework)
- Maven (Build automation)
- OWASP Dependency Check (Security scanning)
- SonarQube (Code quality analysis)
- Docker (Containerization)
- Trivy (Container security scanning)
- Docker Compose (Container orchestration)
- JaCoCO (Code Coverage)
- PiTest (Mutation Test)
- JML (Java Modeling Language) - Formal specifications for design-by-contract
- OpenJML - Static verification tool for JML specifications
- JMH (Java Microbenchmark Harness) - Performance benchmarking

## Pipeline Stages
The CI/CD pipeline follows these key stages:  

![CI/CD Pipeline](images/cicd-pipeline.png)

1. **Code Checkout**
   - Clones repository from GitHub
   - Branch: main (Base Branch)

2. **OWASP Dependency Check**
   - Scans all project dependencies
   - Generates HTML report

3. **SonarQube Analysis**
   - Performs static code analysis
   - Checks code quality

4. **Build and Package**
   - Cleans workspace
   - Compiles code
   - Creates JAR file

5. **Docker Build and Push**
   - Builds Docker image
   - Tags with build number and latest
   - Pushes to Docker Hub

6. **Vulnerability Scanning**
   - Scans Docker image with Trivy
   - Checks for security vulnerabilities

7. **Staging Deployment**
   - Deploys using Docker Compose
   - Sets up application stack
  
   
## Prerequisites

- Java JDK 17
- Maven 3.x
- Docker and Docker Compose
- SonarQube Server
- Git

## Installation and Setup

### Jenkins Configuration

1. Install required Jenkins plugins:
   - Docker Pipeline
   - SonarQube Scanner
   - OWASP Dependency-Check
   - Git

2. Configure Jenkins tools:
```groovy
tools {
    jdk 'jdk17'
    maven 'maven3'
}
```

3. Add credentials:
   - GitHub credentials
   - DockerHub credentials
   - SonarQube token
   - Docker Hub token

### SonarQube Setup

1. Install and start SonarQube server:
```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest
```

2. Configure SonarQube project:
   - Create new project
   - Generate authentication token
   - Add token to Jenkins credentials

### Docker Configuration

1. Install Docker and Docker Compose
2. Configure Docker Hub authentication

## JML (Java Modeling Language) Implementation

This application uses **JML (Java Modeling Language)** for formal specification and design-by-contract programming. JML specifications are embedded as special comments in the Java source code.

### JML Features Implemented

1. **Class Invariants** - Properties that must always hold for class instances
   - Example: `id >= 0`, `nom != null` in `Professeur` class

2. **Preconditions (`@requires`)** - Conditions that must be true before method execution
   - Example: `requires o != null` for create/update methods

3. **Postconditions (`@ensures`)** - Conditions that must be true after method execution
   - Example: `ensures \result != null` for find methods

4. **Quantified Expressions** - Used for collection operations
   - Example: `(\forall int i; 0 <= i && i < \result.size(); ...)` for filtering methods

## JMH (Java Microbenchmark Harness) Implementation

This application uses **JMH (Java Microbenchmark Harness)** for performance benchmarking of service methods. JMH is the de-facto standard for microbenchmarking on the JVM.

