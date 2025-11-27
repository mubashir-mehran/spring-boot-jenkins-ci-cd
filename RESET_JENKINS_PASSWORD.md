# Reset Jenkins Admin Password

## Option 1: Reset via Jenkins Container

1. **Stop Jenkins container:**
   ```bash
   docker stop jenkins
   ```

2. **Edit the config.xml file:**
   ```bash
   docker run --rm -v spring-boot-jenkins-ci-cd_jenkins_home:/var/jenkins_home -it alpine sh
   # Inside the container:
   apk add --no-cache xmlstarlet
   cd /var/jenkins_home
   # Backup first
   cp config.xml config.xml.backup
   # Remove password hash (this will allow login with any password)
   xmlstarlet ed -L -d '//useSecurity' config.xml
   xmlstarlet ed -L -d '//authorizationStrategy' config.xml
   exit
   ```

3. **Start Jenkins:**
   ```bash
   docker start jenkins
   ```

4. **Access Jenkins** - it will be accessible without authentication

5. **Re-enable security:**
   - Go to Manage Jenkins → Configure Global Security
   - Enable security and create a new admin user

## Option 2: Use Jenkins Script Console (Easier)

1. **Access Jenkins** (if you can login or if security is disabled)

2. **Go to:** Manage Jenkins → Script Console

3. **Run this script:**
   ```groovy
   import jenkins.model.*
   import hudson.security.*
   
   def instance = Jenkins.getInstance()
   def hudsonRealm = new HudsonPrivateSecurityRealm(false)
   hudsonRealm.createAccount("admin", "newpassword123")
   instance.setSecurityRealm(hudsonRealm)
   instance.setAuthorizationStrategy(new FullControlOnceLoggedInAuthorizationStrategy())
   instance.save()
   ```

4. **Login with:**
   - Username: `admin`
   - Password: `newpassword123`

## Option 3: Disable Security Temporarily

1. **Stop Jenkins:**
   ```bash
   docker stop jenkins
   ```

2. **Edit config.xml:**
   ```bash
   docker exec -it jenkins sh
   cd /var/jenkins_home
   # Backup
   cp config.xml config.xml.backup
   # Edit to disable security
   sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/' config.xml
   exit
   ```

3. **Start Jenkins:**
   ```bash
   docker start jenkins
   ```

4. **Access Jenkins** without login, then re-enable security with a new password

