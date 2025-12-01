# API Testing Guide - Quick Reference

## 🚀 Quick Start

**Base URL:** `http://localhost:8080`  
**Swagger UI:** `http://localhost:8080/swagger-ui`

---

## 📋 Testing Sequence (Recommended Order)

### Step 1: Create Specialties First
Specialties must exist before creating professors.

### Step 2: Create Professors
Professors reference specialties.

### Step 3: Test Search & Filter Functions

---

## 🎯 Complete API Testing Examples

### **SPECIALTY APIs**

#### 1. Create Specialty
```bash
curl -X POST http://localhost:8080/api/specialite \
  -H "Content-Type: application/json" \
  -d '{"code":"CS","libelle":"Computer Science"}'
```

**Expected Response:**
```json
{
  "id": 1,
  "code": "CS",
  "libelle": "Computer Science"
}
```

#### 2. Create More Specialties
```bash
# Mathematics
curl -X POST http://localhost:8080/api/specialite \
  -H "Content-Type: application/json" \
  -d '{"code":"MATH","libelle":"Mathematics"}'

# Physics
curl -X POST http://localhost:8080/api/specialite \
  -H "Content-Type: application/json" \
  -d '{"code":"PHYS","libelle":"Physics"}'
```

#### 3. Get All Specialties
```bash
curl http://localhost:8080/api/specialite
```

**Expected Response:**
```json
[
  {"id":1,"code":"CS","libelle":"Computer Science"},
  {"id":2,"code":"MATH","libelle":"Mathematics"},
  {"id":3,"code":"PHYS","libelle":"Physics"}
]
```

#### 4. Get Specialty by ID
```bash
curl http://localhost:8080/api/specialite/1
```

#### 5. Update Specialty
```bash
curl -X PUT http://localhost:8080/api/specialite/1 \
  -H "Content-Type: application/json" \
  -d '{"code":"CS","libelle":"Computer Science & Engineering"}'
```

#### 6. Delete Specialty
```bash
curl -X DELETE http://localhost:8080/api/specialite/3
```

---

### **PROFESSOR APIs**

#### 1. Create Professor
```bash
curl -X POST http://localhost:8080/api/professeur \
  -H "Content-Type: application/json" \
  -d '{
    "nom":"Smith",
    "prenom":"John",
    "telephone":"123-456-7890",
    "email":"john.smith@university.edu",
    "dateEmbauche":"2023-01-15",
    "specialite":{"id":1}
  }'
```

**Expected Response:**
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

#### 2. Create More Professors
```bash
# Professor 2
curl -X POST http://localhost:8080/api/professeur \
  -H "Content-Type: application/json" \
  -d '{
    "nom":"Doe",
    "prenom":"Jane",
    "telephone":"987-654-3210",
    "email":"jane.doe@university.edu",
    "dateEmbauche":"2023-03-20",
    "specialite":{"id":1}
  }'

# Professor 3 (Different Specialty)
curl -X POST http://localhost:8080/api/professeur \
  -H "Content-Type: application/json" \
  -d '{
    "nom":"Johnson",
    "prenom":"Robert",
    "telephone":"555-123-4567",
    "email":"robert.johnson@university.edu",
    "dateEmbauche":"2022-09-10",
    "specialite":{"id":2}
  }'
```

#### 3. Get All Professors
```bash
curl http://localhost:8080/api/professeur
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "nom": "Smith",
    "prenom": "John",
    "telephone": "123-456-7890",
    "email": "john.smith@university.edu",
    "dateEmbauche": "2023-01-15",
    "specialite": {"id": 1, "code": "CS", "libelle": "Computer Science"}
  },
  {
    "id": 2,
    "nom": "Doe",
    "prenom": "Jane",
    "telephone": "987-654-3210",
    "email": "jane.doe@university.edu",
    "dateEmbauche": "2023-03-20",
    "specialite": {"id": 1, "code": "CS", "libelle": "Computer Science"}
  }
]
```

#### 4. Get Professor by ID
```bash
curl http://localhost:8080/api/professeur/1
```

#### 5. Get Professors by Specialty
```bash
# Get all Computer Science professors
curl http://localhost:8080/api/professeur/specialite/1
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "nom": "Smith",
    "prenom": "John",
    ...
  },
  {
    "id": 2,
    "nom": "Doe",
    "prenom": "Jane",
    ...
  }
]
```

#### 6. Filter Professors by Hire Date
```bash
# Get professors hired in 2023
curl "http://localhost:8080/api/professeur/filterByDate?dateDebut=2023-01-01&dateFin=2023-12-31"
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "nom": "Smith",
    "prenom": "John",
    "dateEmbauche": "2023-01-15",
    ...
  },
  {
    "id": 2,
    "nom": "Doe",
    "prenom": "Jane",
    "dateEmbauche": "2023-03-20",
    ...
  }
]
```

#### 7. Update Professor
```bash
curl -X PUT http://localhost:8080/api/professeur/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nom":"Smith",
    "prenom":"John",
    "telephone":"111-222-3333",
    "email":"john.smith@university.edu",
    "dateEmbauche":"2023-01-15",
    "specialite":{"id":1}
  }'
```

#### 8. Delete Professor
```bash
curl -X DELETE http://localhost:8080/api/professeur/1
```

**Expected Response:**
```json
"Professeur has been deleted"
```

---

## 🧪 Testing Error Cases

### 1. Get Non-Existent Professor
```bash
curl http://localhost:8080/api/professeur/999
```

**Expected Response:**
```json
"Professeur with ID 999 not found"
```
**Status Code:** `400 Bad Request`

### 2. Create Professor with Invalid Specialty
```bash
curl -X POST http://localhost:8080/api/professeur \
  -H "Content-Type: application/json" \
  -d '{
    "nom":"Test",
    "prenom":"User",
    "specialite":{"id":999}
  }'
```

**Expected:** Database constraint error (specialty doesn't exist)

### 3. Update Non-Existent Professor
```bash
curl -X PUT http://localhost:8080/api/professeur/999 \
  -H "Content-Type: application/json" \
  -d '{"nom":"Test"}'
```

**Expected Response:**
```json
"Professeur with ID 999 not found"
```

---

## 📝 Postman Collection JSON

Save this as `ProfessorManagement.postman_collection.json`:

```json
{
  "info": {
    "name": "Professor Management API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Specialties",
      "item": [
        {
          "name": "Get All Specialties",
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://localhost:8080/api/specialite",
              "host": ["localhost"],
              "port": "8080",
              "path": ["api", "specialite"]
            }
          }
        },
        {
          "name": "Create Specialty",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"code\": \"CS\",\n  \"libelle\": \"Computer Science\"\n}"
            },
            "url": {
              "raw": "http://localhost:8080/api/specialite",
              "host": ["localhost"],
              "port": "8080",
              "path": ["api", "specialite"]
            }
          }
        }
      ]
    },
    {
      "name": "Professors",
      "item": [
        {
          "name": "Get All Professors",
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://localhost:8080/api/professeur",
              "host": ["localhost"],
              "port": "8080",
              "path": ["api", "professeur"]
            }
          }
        },
        {
          "name": "Create Professor",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"nom\": \"Smith\",\n  \"prenom\": \"John\",\n  \"telephone\": \"123-456-7890\",\n  \"email\": \"john.smith@university.edu\",\n  \"dateEmbauche\": \"2023-01-15\",\n  \"specialite\": {\n    \"id\": 1\n  }\n}"
            },
            "url": {
              "raw": "http://localhost:8080/api/professeur",
              "host": ["localhost"],
              "port": "8080",
              "path": ["api", "professeur"]
            }
          }
        },
        {
          "name": "Get Professors by Specialty",
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://localhost:8080/api/professeur/specialite/1",
              "host": ["localhost"],
              "port": "8080",
              "path": ["api", "professeur", "specialite", "1"]
            }
          }
        },
        {
          "name": "Filter by Date",
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://localhost:8080/api/professeur/filterByDate?dateDebut=2023-01-01&dateFin=2023-12-31",
              "host": ["localhost"],
              "port": "8080",
              "path": ["api", "professeur", "filterByDate"],
              "query": [
                {
                  "key": "dateDebut",
                  "value": "2023-01-01"
                },
                {
                  "key": "dateFin",
                  "value": "2023-12-31"
                }
              ]
            }
          }
        }
      ]
    }
  ]
}
```

---

## 🔍 PowerShell Examples (Windows)

### Create Specialty
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

### Get All Specialties
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/specialite" -Method GET
```

### Create Professor
```powershell
$body = @{
    nom = "Smith"
    prenom = "John"
    telephone = "123-456-7890"
    email = "john.smith@university.edu"
    dateEmbauche = "2023-01-15"
    specialite = @{
        id = 1
    }
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "http://localhost:8080/api/professeur" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

---

## ✅ Testing Checklist

- [ ] Create at least 3 specialties
- [ ] Get all specialties
- [ ] Get specialty by ID
- [ ] Update a specialty
- [ ] Create at least 3 professors (with different specialties)
- [ ] Get all professors
- [ ] Get professor by ID
- [ ] Get professors by specialty
- [ ] Filter professors by date range
- [ ] Update a professor
- [ ] Delete a professor
- [ ] Test error cases (non-existent IDs)

---

## 🎯 Most Important APIs to Test

1. **POST `/api/specialite`** - Create specialty (required first)
2. **POST `/api/professeur`** - Create professor
3. **GET `/api/professeur`** - List all professors
4. **GET `/api/professeur/specialite/{id}`** - Search by specialty
5. **GET `/api/professeur/filterByDate?dateDebut=...&dateFin=...`** - Filter by date

---

**Tip:** Use Swagger UI at `http://localhost:8080/swagger-ui` for the easiest testing experience!

