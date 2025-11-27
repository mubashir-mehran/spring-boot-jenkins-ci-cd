# Fix Trivy Installation Issue

## Problem
The pipeline failed with: `trivy: not found` because Trivy is not installed in the Jenkins container.

## Solution: Use Trivy via Docker

I've updated the Jenkinsfile to use Trivy via Docker container instead of requiring it to be installed in Jenkins. This is cleaner and doesn't require modifying the Jenkins container.

### What Changed:
- Instead of: `trivy image ...`
- Now using: `docker run --rm aquasec/trivy:latest image ...`

The `--rm` flag automatically removes the container after it finishes.

## Alternative Solutions

### Option 1: Install Trivy in Jenkins Container (Permanent)
If you want Trivy permanently available in Jenkins:

1. **Access Jenkins container:**
   ```bash
   docker exec -it jenkins bash
   ```

2. **Install Trivy:**
   ```bash
   # Download Trivy
   wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
   echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
   apt-get update
   apt-get install -y trivy
   ```

3. **Verify installation:**
   ```bash
   trivy --version
   ```

4. **Exit container:**
   ```bash
   exit
   ```

**Note:** This installation will be lost if you recreate the Jenkins container. To make it persistent, you'd need to create a custom Jenkins image.

### Option 2: Skip Trivy Stage (Temporary)
If you want to skip vulnerability scanning for now:

Comment out the `Vulnerability scanning` stage in the Jenkinsfile:
```groovy
// stage('Vulnerability scanning'){
//     steps{
//         script {
//             def buildTag = "spring-boot-prof-management:${BUILD_NUMBER}"
//             sh "trivy image mubashir2025/${buildTag}"
//         }
//     }
// }
```

## Current Solution (Recommended)

The Jenkinsfile now uses Trivy via Docker, which:
- ✅ Doesn't require installing anything in Jenkins
- ✅ Always uses the latest Trivy version
- ✅ Works immediately without container modifications
- ✅ Is isolated and doesn't affect Jenkins container

## Next Steps

1. **Commit and push the updated Jenkinsfile:**
   ```bash
   git add Jenkinsfile
   git commit -m "Fix Trivy vulnerability scanning using Docker"
   git push origin main
   ```

2. **Run the pipeline again** - The vulnerability scanning stage should now work!

## Testing

After the pipeline runs, you should see Trivy scanning your Docker image and reporting any vulnerabilities found.

