# Fix SonarQube Token Issue

## Problem
The error shows: `Not authorized. Please check the user token in the property 'sonar.token' or 'sonar.login' (deprecated).`

This means the SonarQube token in your Jenkinsfile is invalid or expired.

## Solution: Generate a New SonarQube Token

### Step 1: Access SonarQube
1. Open: http://localhost:9000
2. Login with default credentials:
   - Username: `admin`
   - Password: `admin` (you may have changed this)

### Step 2: Generate a New Token
1. Click on your profile icon (top right)
2. Select **My Account**
3. Go to the **Security** tab
4. Under **Generate Tokens**, enter:
   - **Name**: `jenkins-token` (or any name)
   - **Type**: `User Token`
   - **Expires in**: `No expiration` (or set a date)
5. Click **Generate**
6. **Copy the token immediately** (you won't be able to see it again!)

### Step 3: Update Jenkinsfile
Replace the token in your Jenkinsfile with the new token.

The current token in Jenkinsfile is:
```
squ_f6ae0f1ae224b08bb01266f9a817e169d24ee0b9
```

Replace it with your new token in the `Sonarqube Analysis` stage.

### Step 4: Commit and Push
After updating the token, commit and push the changes:
```bash
git add Jenkinsfile
git commit -m "Update SonarQube token"
git push origin main
```

### Step 5: Rebuild Pipeline
Run the pipeline again in Jenkins.

## Alternative: Use SonarQube Password Instead

If you prefer to use a password instead of a token:

1. In Jenkinsfile, change:
   ```groovy
   -Dsonar.login=squ_f6ae0f1ae224b08bb01266f9a817e169d24ee0b9
   ```
   
   To:
   ```groovy
   -Dsonar.login=admin
   -Dsonar.password=your_sonarqube_password
   ```

   **Note**: Using password is less secure than tokens.

## Quick Fix Command

If you want me to update the Jenkinsfile with a new token, provide me with the new token and I'll update it for you.

