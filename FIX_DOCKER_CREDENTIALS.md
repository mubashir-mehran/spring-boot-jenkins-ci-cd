# Fix Docker Credentials Issue

## Problem
The pipeline is looking for credentials with ID `DockerHub-Token`, but your Jenkins has credentials with ID `dckr_pat_Rgo0rM8UVvrQCJKNhL4Yvfx1PzY`.

## Solution Options

### Option 1: Use Existing Credentials (Current Fix)
I've updated the Jenkinsfile to use your existing credential ID. This assumes your credential is of type **"Secret text"** (token only).

**If your credential is "Secret text" type:**
- The Jenkinsfile is now configured correctly
- Just commit and push the changes

### Option 2: Create New Credentials with Correct ID (Recommended)
This is cleaner and more maintainable:

1. **Go to Jenkins → Manage Jenkins → Credentials**
2. **Click on your existing credential** (`dckr_pat_Rgo0rM8UVvrQCJKNhL4Yvfx1PzY`)
3. **Click "Update"** (or delete and recreate)
4. **Change the ID to:** `DockerHub-Token`
5. **Make sure the type is:**
   - **"Username with password"** (recommended)
     - Username: `mubashir2025`
     - Password: `dckr_pat_Rgo0rM8UVvrQCJKNhL4Yvfx1PzY`
   - OR **"Secret text"** (if you prefer)
     - Secret: `dckr_pat_Rgo0rM8UVvrQCJKNhL4Yvfx1PzY`
6. **Save**

Then update the Jenkinsfile back to use `DockerHub-Token`:
```groovy
withCredentials([usernamePassword(credentialsId: 'DockerHub-Token', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
    // ... rest of the code
}
```

## Current Jenkinsfile Configuration

The Jenkinsfile is now configured to use your existing credential ID. If your credential is:
- **"Secret text"** type: ✅ It will work as-is
- **"Username with password"** type: You need to update the Jenkinsfile

## Check Your Credential Type

1. Go to Jenkins → Manage Jenkins → Credentials
2. Click on `dckr_pat_Rgo0rM8UVvrQCJKNhL4Yvfx1PzY`
3. Check the "Kind" field:
   - If it says "Secret text" → Current Jenkinsfile is correct
   - If it says "Username with password" → I need to update the Jenkinsfile

## Next Steps

1. **Commit and push the updated Jenkinsfile:**
   ```bash
   git add Jenkinsfile
   git commit -m "Update Docker credentials ID"
   git push origin main
   ```

2. **Run the pipeline again**

3. **If it still fails**, let me know what type your credential is, and I'll adjust the Jenkinsfile accordingly.

