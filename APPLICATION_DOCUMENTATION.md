# Spring Boot Professor Management System - Complete Documentation

## 📋 Table of Contents
1. [Application Overview](#application-overview)
2. [Architecture & Technology Stack](#architecture--technology-stack)
3. [Application Structure](#application-structure)
4. [Main Files & Code Explanation](#main-files--code-explanation)
5. [Database Schema & Entities](#database-schema--entities)
6. [API Endpoints](#api-endpoints)
7. [How to Test APIs](#how-to-test-apis)
8. [Functionalities & How They Work](#functionalities--how-they-work)

---

## 🎯 Application Overview

**Application Name:** GestionProfesseurs (Professor Management System)

**Purpose:** A RESTful web application for managing professors and their specialties in an educational institution.

**Main Features:**
- CRUD operations for Professors
- CRUD operations for Specialties
- Search professors by specialty
- Filter professors by hire date range
- RESTful API with Swagger documentation
- MySQL database integration

---

## 🏗️ Architecture & Technology Stack

### Technology Stack:
- **Framework:** Spring Boot 3.1.5
- **Java Version:** 17
- **Database:** MySQL 8.0
- **ORM:** JPA/Hibernate
- **API Documentation:** Swagger/OpenAPI (SpringDoc)
- **Build Tool:** Maven
- **Architecture Pattern:** MVC (Model-View-Controller) / Layered Architecture

### Architecture Layers:
```
┌─────────────────────────────────────┐
│   Controllers (REST API Layer)      │
├─────────────────────────────────────┤
│   Services (Business Logic Layer)   │
├─────────────────────────────────────┤
│   Repositories (Data Access Layer)  │
├─────────────────────────────────────┤
│   Entities (Database Models)        │
└─────────────────────────────────────┘
```

---

## 📁 Application Structure

```
src/
├── main/
│   ├── java/ma/projet/gestionprofesseurs/
│   │   ├── GestionProfesseursApplication.java    # Main application class
│   │   ├── controllers/                          # REST Controllers
│   │   │   ├── ProfesseurController.java
│   │   │   └── SpecialiteController.java
│   │   ├── services/                            # Business Logic
│   │   │   ├── ProfesseurService.java
│   │   │   └── SpecialiteService.java
│   │   ├── repository/                           # Data Access
│   │   │   ├── ProfesseurRepository.java
│   │   │   └── SpecialiteRepository.java
│   │   ├── entities/                             # JPA Entities
│   │   │   ├── Professeur.java
│   │   │   └── Specialite.java
│   │   └── dao/                                  # Generic DAO Interface
│   │       └── IDao.java
│   └── resources/
│       └── application.properties                # Configuration
└── test/
    └── java/.../GestionProfesseursApplicationTests.java
```

---

## 📄 Main Files & Code Explanation

### 1. **GestionProfesseursApplication.java**
**Location:** `src/main/java/ma/projet/gestionprofesseurs/GestionProfesseursApplication.java`

**Purpose:** Main entry point of the Spring Boot application.

**Key Features:**
- `@SpringBootApplication` annotation enables auto-configuration
- Starts the embedded Tomcat server
- Scans and initializes all Spring components

**Code:**
```java
@SpringBootApplication
public class GestionProfesseursApplication {
    public static void main(String[] args) {
        SpringApplication.run(GestionProfesseursApplication.class, args);
    }
}
```

---

### 2. **Entities (Database Models)**

#### **Specialite.java** (Specialty Entity)
**Location:** `src/main/java/ma/projet/gestionprofesseurs/entities/Specialite.java`

**Purpose:** Represents a specialty/field of study.

**Fields:**
- `id` (int): Primary key, auto-generated
- `code` (String): Specialty code (e.g., "CS", "MATH")
- `libelle` (String): Specialty name/label (e.g., "Computer Science", "Mathematics")

**Annotations:**
- `@Entity`: Marks as JPA entity
- `@Id`: Primary key
- `@GeneratedValue(strategy = GenerationType.IDENTITY)`: Auto-increment

**Example Data:**
```json
{
  "id": 1,
  "code": "CS",
  "libelle": "Computer Science"
}
```

#### **Professeur.java** (Professor Entity)
**Location:** `src/main/java/ma/projet/gestionprofesseurs/entities/Professeur.java`

**Purpose:** Represents a professor.

**Fields:**
- `id` (int): Primary key, auto-generated
- `nom` (String): Last name
- `prenom` (String): First name
- `telephone` (String): Phone number
- `email` (String): Email address
- `dateEmbauche` (Date): Hire date
- `specialite` (Specialite): Many-to-One relationship with Specialty

**Relationships:**
- `@ManyToOne`: Many professors can have one specialty
- `@Temporal(TemporalType.DATE)`: Stores only date (no time)

**Example Data:**
```json
{
  "id": 1,
  "nom": "Smith",
  "prenom": "John",
  "telephone": "123-456-7890",
  "email": "john.smith@university.edu",
  "dateEmbauche": "2023-01-15",
  "specialite": {
    "id": 1,
    "code": "CS",
    "libelle": "Computer Science"
  }
}
```

---

### 3. **Repositories (Data Access Layer)**

#### **SpecialiteRepository.java**
**Location:** `src/main/java/ma/projet/gestionprofesseurs/repository/SpecialiteRepository.java`

**Purpose:** Data access interface for Specialty entity.

**Features:**
- Extends `JpaRepository<Specialite, Integer>`
- Provides built-in CRUD methods:
  - `save()`, `findAll()`, `findById()`, `delete()`, etc.

**Code:**
```java
@Repository
public interface SpecialiteRepository extends JpaRepository<Specialite, Integer> {
    // Inherits all CRUD operations from JpaRepository
}
```

#### **ProfesseurRepository.java**
**Location:** `src/main/java/ma/projet/gestionprofesseurs/repository/ProfesseurRepository.java`

**Purpose:** Data access interface for Professor entity.

**Custom Methods:**
- `findBySpecialite(Specialite specialite)`: Find all professors by specialty
- `findByDateEmbaucheBetween(Date dateDebut, Date dateFin)`: Find professors hired between dates

**Code:**
```java
@Repository
public interface ProfesseurRepository extends JpaRepository<Professeur, Integer> {
    List<Professeur> findBySpecialite(Specialite specialite);
    List<Professeur> findByDateEmbaucheBetween(Date dateDebut, Date dateFin);
}
```

**How It Works:**
- Spring Data JPA automatically implements these methods based on method names
- `findBySpecialite` → `SELECT * FROM professeur WHERE specialite_id = ?`
- `findByDateEmbaucheBetween` → `SELECT * FROM professeur WHERE date_embauche BETWEEN ? AND ?`

---

### 4. **Services (Business Logic Layer)**

#### **IDao.java** (Generic DAO Interface)
**Location:** `src/main/java/ma/projet/gestionprofesseurs/dao/IDao.java`

**Purpose:** Generic interface defining common CRUD operations.

**Methods:**
- `create(T o)`: Create new entity
- `delete(T o)`: Delete entity
- `update(T o)`: Update entity
- `findAll()`: Get all entities
- `findById(int id)`: Get entity by ID

#### **SpecialiteService.java**
**Location:** `src/main/java/ma/projet/gestionprofesseurs/services/SpecialiteService.java`

**Purpose:** Business logic for Specialty operations.

**Methods:**
- Implements `IDao<Specialite>` interface
- All CRUD operations delegate to `SpecialiteRepository`
- `@Service`: Marks as Spring service component

#### **ProfesseurService.java**
**Location:** `src/main/java/ma/projet/gestionprofesseurs/services/ProfesseurService.java`

**Purpose:** Business logic for Professor operations.

**Methods:**
- Standard CRUD operations
- `findBySpecialite(Specialite specialite)`: Find professors by specialty
- `findByDateEmbaucheBetween(Date dateDebut, Date dateFin)`: Filter by hire date range

---

### 5. **Controllers (REST API Layer)**

#### **SpecialiteController.java**
**Location:** `src/main/java/ma/projet/gestionprofesseurs/controllers/SpecialiteController.java`

**Purpose:** REST API endpoints for Specialty management.

**Base URL:** `/api/specialite`

**Endpoints:**
- `GET /api/specialite` - Get all specialties
- `GET /api/specialite/{id}` - Get specialty by ID
- `POST /api/specialite` - Create new specialty
- `PUT /api/specialite/{id}` - Update specialty
- `DELETE /api/specialite/{id}` - Delete specialty

**Annotations:**
- `@RestController`: Combines `@Controller` + `@ResponseBody`
- `@RequestMapping("/api/specialite")`: Base path for all endpoints
- `@Autowired`: Dependency injection for service

#### **ProfesseurController.java**
**Location:** `src/main/java/ma/projet/gestionprofesseurs/controllers/ProfesseurController.java`

**Purpose:** REST API endpoints for Professor management.

**Base URL:** `/api/professeur`

**Endpoints:**
- `GET /api/professeur` - Get all professors
- `GET /api/professeur/{id}` - Get professor by ID
- `POST /api/professeur` - Create new professor
- `PUT /api/professeur/{id}` - Update professor
- `DELETE /api/professeur/{id}` - Delete professor
- `GET /api/professeur/specialite/{id}` - Get professors by specialty ID
- `GET /api/professeur/filterByDate?dateDebut=YYYY-MM-DD&dateFin=YYYY-MM-DD` - Filter by hire date

---

### 6. **Configuration Files**

#### **application.properties**
**Location:** `src/main/resources/application.properties`

**Configuration:**
```properties
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3307/springboot3
spring.datasource.username=root
spring.datasource.password=

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=update  # Auto-create/update tables
spring.jpa.show-sql=true              # Show SQL queries in logs

# Swagger Configuration
springdoc.swagger-ui.path=/swagger-ui
```

**Key Settings:**
- `ddl-auto=update`: Automatically creates/updates database schema
- `show-sql=true`: Logs all SQL queries (useful for debugging)

---

## 🗄️ Database Schema & Entities

### Database: `springboot3`

### Tables:

#### **specialite** Table
```sql
CREATE TABLE specialite (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(255),
    libelle VARCHAR(255)
);
```

#### **professeur** Table
```sql
CREATE TABLE professeur (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255),
    prenom VARCHAR(255),
    telephone VARCHAR(255),
    email VARCHAR(255),
    date_embauche DATE,
    specialite_id INT,
    FOREIGN KEY (specialite_id) REFERENCES specialite(id)
);
```

### Entity Relationship:
```
Specialite (1) ────< (Many) Professeur
```
- One Specialty can have many Professors
- Each Professor belongs to one Specialty

---

## 🔌 API Endpoints

### Base URL: `http://localhost:8080`

### **Specialty APIs** (`/api/specialite`)

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/specialite` | Get all specialties | - | List of specialties |
| GET | `/api/specialite/{id}` | Get specialty by ID | - | Specialty object or error |
| POST | `/api/specialite` | Create specialty | JSON specialty | Created specialty |
| PUT | `/api/specialite/{id}` | Update specialty | JSON specialty | Updated specialty or error |
| DELETE | `/api/specialite/{id}` | Delete specialty | - | Success message or error |

### **Professor APIs** (`/api/professeur`)

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/professeur` | Get all professors | - | List of professors |
| GET | `/api/professeur/{id}` | Get professor by ID | - | Professor object or error |
| POST | `/api/professeur` | Create professor | JSON professor | Created professor |
| PUT | `/api/professeur/{id}` | Update professor | JSON professor | Updated professor or error |
| DELETE | `/api/professeur/{id}` | Delete professor | - | Success message or error |
| GET | `/api/professeur/specialite/{id}` | Get professors by specialty | - | List of professors |
| GET | `/api/professeur/filterByDate?dateDebut=YYYY-MM-DD&dateFin=YYYY-MM-DD` | Filter by hire date | - | List of professors |

---

## 🧪 How to Test APIs

### **Method 1: Using Swagger UI (Recommended)**

1. **Start the application:**
   ```bash
   # Application should be running on http://localhost:8080
   ```

2. **Access Swagger UI:**
   - Open browser: `http://localhost:8080/swagger-ui`
   - You'll see all available APIs with interactive documentation

3. **Test APIs:**
   - Click on any endpoint
   - Click "Try it out"
   - Enter request body (for POST/PUT)
   - Click "Execute"
   - See response

### **Method 2: Using cURL (Command Line)**

#### **1. Create a Specialty**
```bash
curl -X POST http://localhost:8080/api/specialite \
  -H "Content-Type: application/json" \
  -d "{\"code\":\"CS\",\"libelle\":\"Computer Science\"}"
```

#### **2. Get All Specialties**
```bash
curl http://localhost:8080/api/specialite
```

#### **3. Get Specialty by ID**
```bash
curl http://localhost:8080/api/specialite/1
```

#### **4. Update Specialty**
```bash
curl -X PUT http://localhost:8080/api/specialite/1 \
  -H "Content-Type: application/json" \
  -d "{\"code\":\"CS\",\"libelle\":\"Computer Science & Engineering\"}"
```

#### **5. Delete Specialty**
```bash
curl -X DELETE http://localhost:8080/api/specialite/1
```

#### **6. Create a Professor**
```bash
curl -X POST http://localhost:8080/api/professeur \
  -H "Content-Type: application/json" \
  -d "{\"nom\":\"Smith\",\"prenom\":\"John\",\"telephone\":\"123-456-7890\",\"email\":\"john.smith@university.edu\",\"dateEmbauche\":\"2023-01-15\",\"specialite\":{\"id\":1}}"
```

#### **7. Get All Professors**
```bash
curl http://localhost:8080/api/professeur
```

#### **8. Get Professor by ID**
```bash
curl http://localhost:8080/api/professeur/1
```

#### **9. Get Professors by Specialty**
```bash
curl http://localhost:8080/api/professeur/specialite/1
```

#### **10. Filter Professors by Hire Date**
```bash
curl "http://localhost:8080/api/professeur/filterByDate?dateDebut=2023-01-01&dateFin=2023-12-31"
```

#### **11. Update Professor**
```bash
curl -X PUT http://localhost:8080/api/professeur/1 \
  -H "Content-Type: application/json" \
  -d "{\"nom\":\"Smith\",\"prenom\":\"John\",\"telephone\":\"123-456-7890\",\"email\":\"john.smith@university.edu\",\"dateEmbauche\":\"2023-01-15\",\"specialite\":{\"id\":1}}"
```

#### **12. Delete Professor**
```bash
curl -X DELETE http://localhost:8080/api/professeur/1
```

### **Method 3: Using Postman**

1. **Import Collection:**
   - Create a new collection in Postman
   - Add requests for each endpoint

2. **Example Request Setup:**
   - **Method:** POST
   - **URL:** `http://localhost:8080/api/specialite`
   - **Headers:** `Content-Type: application/json`
   - **Body (raw JSON):**
     ```json
     {
       "code": "CS",
       "libelle": "Computer Science"
     }
     ```

3. **Send Request:**
   - Click "Send"
   - View response

### **Method 4: Using PowerShell (Windows)**

#### **Create Specialty:**
```powershell
$body = @{
    code = "CS"
    libelle = "Computer Science"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/specialite" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

#### **Get All Specialties:**
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/specialite" -Method GET
```

---

## ⚙️ Functionalities & How They Work

### **1. CRUD Operations for Specialties**

#### **Create Specialty:**
1. Client sends POST request to `/api/specialite` with JSON body
2. `SpecialiteController` receives request
3. Calls `SpecialiteService.create()`
4. Service calls `SpecialiteRepository.save()`
5. JPA persists entity to database
6. Returns created specialty with generated ID

#### **Read Specialty:**
- **Get All:** `GET /api/specialite` → Returns all specialties
- **Get By ID:** `GET /api/specialite/{id}` → Returns specific specialty or error if not found

#### **Update Specialty:**
1. Client sends PUT request to `/api/specialite/{id}` with updated data
2. Controller validates ID exists
3. Service updates entity
4. Repository saves changes
5. Returns updated specialty

#### **Delete Specialty:**
1. Client sends DELETE request to `/api/specialite/{id}`
2. Controller validates ID exists
3. Service deletes entity
4. Returns success message

---

### **2. CRUD Operations for Professors**

**Same flow as Specialties, with additional features:**

#### **Create Professor:**
- Must include `specialite` object with `id` in request body
- Example:
  ```json
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

#### **Search by Specialty:**
- Endpoint: `GET /api/professeur/specialite/{id}`
- Uses `findBySpecialite()` method
- Returns all professors with that specialty

#### **Filter by Hire Date:**
- Endpoint: `GET /api/professeur/filterByDate?dateDebut=YYYY-MM-DD&dateFin=YYYY-MM-DD`
- Uses `findByDateEmbaucheBetween()` method
- Returns professors hired between the two dates
- Example: `?dateDebut=2023-01-01&dateFin=2023-12-31`

---

### **3. Data Flow Example: Creating a Professor**

```
1. Client Request
   POST /api/professeur
   {
     "nom": "Smith",
     "prenom": "John",
     "specialite": {"id": 1}
   }
   ↓
2. ProfesseurController.createProfesseur()
   - Receives JSON, converts to Professeur object
   - Sets ID to 0 (new entity)
   ↓
3. ProfesseurService.create()
   - Business logic validation (if any)
   ↓
4. ProfesseurRepository.save()
   - JPA saves to database
   - Foreign key constraint ensures specialty exists
   ↓
5. Database
   - Inserts new row in professeur table
   - Links to specialite via specialite_id
   ↓
6. Response
   - Returns created professor with generated ID
```

---

### **4. Error Handling**

**404 Not Found:**
- When ID doesn't exist: Returns `400 Bad Request` with error message
- Example: `"Professeur with ID 999 not found"`

**Validation:**
- Foreign key constraints ensure specialty exists before creating professor
- Date format validation for `dateEmbauche`

---

## 🎯 Main APIs Summary

### **Most Important APIs:**

1. **GET `/api/specialite`** - List all specialties
2. **POST `/api/specialite`** - Create specialty (required before creating professors)
3. **GET `/api/professeur`** - List all professors
4. **POST `/api/professeur`** - Create professor
5. **GET `/api/professeur/specialite/{id}`** - Find professors by specialty
6. **GET `/api/professeur/filterByDate?dateDebut=...&dateFin=...`** - Filter by hire date

---

## 📝 Testing Workflow Example

### **Step-by-Step Testing:**

1. **Start Application:**
   ```bash
   # Application runs on http://localhost:8080
   ```

2. **Create a Specialty:**
   ```bash
   curl -X POST http://localhost:8080/api/specialite \
     -H "Content-Type: application/json" \
     -d "{\"code\":\"CS\",\"libelle\":\"Computer Science\"}"
   ```
   **Response:** `{"id":1,"code":"CS","libelle":"Computer Science"}`

3. **Create Another Specialty:**
   ```bash
   curl -X POST http://localhost:8080/api/specialite \
     -H "Content-Type: application/json" \
     -d "{\"code\":\"MATH\",\"libelle\":\"Mathematics\"}"
   ```

4. **Get All Specialties:**
   ```bash
   curl http://localhost:8080/api/specialite
   ```

5. **Create a Professor:**
   ```bash
   curl -X POST http://localhost:8080/api/professeur \
     -H "Content-Type: application/json" \
     -d "{\"nom\":\"Smith\",\"prenom\":\"John\",\"telephone\":\"123-456-7890\",\"email\":\"john.smith@university.edu\",\"dateEmbauche\":\"2023-01-15\",\"specialite\":{\"id\":1}}"
   ```

6. **Get All Professors:**
   ```bash
   curl http://localhost:8080/api/professeur
   ```

7. **Get Professors by Specialty:**
   ```bash
   curl http://localhost:8080/api/professeur/specialite/1
   ```

8. **Filter by Date:**
   ```bash
   curl "http://localhost:8080/api/professeur/filterByDate?dateDebut=2023-01-01&dateFin=2023-12-31"
   ```

---

## 🔍 Key Features

1. **RESTful API Design:** Follows REST principles
2. **Swagger Documentation:** Interactive API documentation
3. **JPA/Hibernate:** Object-relational mapping
4. **Spring Data JPA:** Automatic query generation
5. **MySQL Integration:** Relational database
6. **Layered Architecture:** Separation of concerns
7. **Error Handling:** Proper HTTP status codes and error messages

---

## 🚀 Quick Start Testing

**Access Swagger UI:**
```
http://localhost:8080/swagger-ui
```

**Base API URL:**
```
http://localhost:8080/api
```

**Health Check:**
```
http://localhost:8080/actuator/health (if actuator is enabled)
```

---

## 📚 Additional Resources

- **Swagger UI:** `http://localhost:8080/swagger-ui`
- **API Docs:** `http://localhost:8080/v3/api-docs`
- **Application Logs:** Check console for SQL queries and application logs

---

**Note:** Make sure MySQL is running and the database `springboot3` exists before starting the application. The application will auto-create tables on first run due to `ddl-auto=update`.

