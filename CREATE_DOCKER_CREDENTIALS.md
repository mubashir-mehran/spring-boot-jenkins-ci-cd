# Create Docker Hub Credentials in Jenkins

## Problem
The pipeline is failing with: `ERROR: Could not find credentials entry with ID 'DockerHub-Token'`

## Solution: Create Docker Hub Credentials

### Step 1: Access Jenkins Credentials
1. Open Jenkins: http://localhost:8080
2. Click **Manage Jenkins** (left sidebar)
3. Click **Credentials**
4. Click on **(global)** (or your specific domain if you have one)

### Step 2: Add New Credentials
1. Click **Add Credentials** (or **+ Add** if you see a dropdown)
2. Fill in the form:
   - **Kind**: Select **Username with password**
   - **Scope**: Select **Global** (or **System** if you prefer)
   - **Username**: Enter your Docker Hub username: `mubashir2025`
   - **Password**: Enter your Docker Hub password or access token
   - **ID**: Enter `DockerHub-Token` (this must match exactly!)
   - **Description**: (Optional) e.g., "Docker Hub credentials for CI/CD"
3. Click **Create**

### Step 3: Verify Credentials
1. You should now see `DockerHub-Token` in your credentials list
2. The ID must be exactly `DockerHub-Token` (case-sensitive)

### Step 4: Test the Pipeline
1. Go back to your pipeline job
2. Click **Build Now**
3. The pipeline should now be able to authenticate with Docker Hub

## Alternative: Use a Different Credentials ID

If you already have Docker Hub credentials with a different ID, you can update the Jenkinsfile instead:

1. Find your existing credentials ID in Jenkins
2. Update the Jenkinsfile line 43:
   ```groovy
   withCredentials([usernamePassword(credentialsId: 'YOUR_EXISTING_ID', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
   ```

## Docker Hub Access Token (Recommended)

Instead of using your Docker Hub password, you can use an access token:

1. Go to Docker Hub: https://hub.docker.com
2. Click your profile → **Account Settings**
3. Go to **Security** → **New Access Token**
4. Give it a name (e.g., "Jenkins CI/CD")
5. Set permissions: **Read & Write** (or **Read, Write & Delete**)
6. Click **Generate**
7. **Copy the token immediately** (you won't see it again!)
8. Use this token as the password when creating Jenkins credentials

## Troubleshooting

- **ID mismatch**: The credentials ID in Jenkins must exactly match `DockerHub-Token` (case-sensitive)
- **Wrong credential type**: Make sure it's "Username with password", not "Secret text"
- **Scope issue**: If using a folder-scoped credential, make sure your pipeline job is in that folder

