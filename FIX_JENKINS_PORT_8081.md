# Fix Jenkins Not Accessible on Port 8081

## Problem
Jenkins is not accessible at `http://localhost:8081`

## Quick Checks

### 1. Check if Jenkins Container is Running

Run this command in your terminal:
```bash
docker ps
```

Look for a container named `jenkins`. If you don't see it, the container might be stopped.

### 2. Check All Containers (Including Stopped)

```bash
docker ps -a
```

This will show all containers, including stopped ones. Look for `jenkins`.

### 3. Start Jenkins Container

If Jenkins is stopped, start it:

**Option A: Using docker-compose (Recommended)**
```bash
cd C:\Users\dev\Spring-Boot-Jenkins-CI-CD
docker-compose -f docker-compose.cicd.yml up -d
```

**Option B: Start the container directly**
```bash
docker start jenkins
```

### 4. Check Jenkins Container Logs

If Jenkins is running but not accessible, check the logs:
```bash
docker logs jenkins
```

Look for any errors or the message showing Jenkins is ready.

### 5. Verify Port Mapping

Check if port 8081 is already in use by another application:
```bash
netstat -ano | findstr :8081
```

If something else is using port 8081, you'll need to either:
- Stop that application, OR
- Change Jenkins port in `docker-compose.cicd.yml`

### 6. Check Jenkins Container Status

```bash
docker inspect jenkins
```

Look for the "State" section to see if it's running.

## Common Issues and Solutions

### Issue 1: Container is Stopped
**Solution:** Start it with `docker start jenkins` or `docker-compose -f docker-compose.cicd.yml up -d`

### Issue 2: Port 8081 is Already in Use
**Solution:** 
1. Find what's using port 8081: `netstat -ano | findstr :8081`
2. Either stop that application or change Jenkins port in `docker-compose.cicd.yml`:
   ```yaml
   ports:
     - "8082:8080"  # Change 8081 to 8082 or another port
   ```
3. Restart: `docker-compose -f docker-compose.cicd.yml restart jenkins`

### Issue 3: Jenkins Container Crashed
**Solution:**
1. Check logs: `docker logs jenkins`
2. Look for error messages
3. Try recreating: `docker-compose -f docker-compose.cicd.yml up -d --force-recreate jenkins`

### Issue 4: Jenkins is Still Starting
**Solution:** Wait a minute or two. Jenkins takes time to start. Check logs:
```bash
docker logs -f jenkins
```
Wait until you see: "Jenkins is fully up and running"

## Quick Start Commands

If Jenkins is not running, use these commands:

```bash
# Navigate to project directory
cd C:\Users\dev\Spring-Boot-Jenkins-CI-CD

# Start Jenkins and SonarQube
docker-compose -f docker-compose.cicd.yml up -d

# Check if containers are running
docker ps

# Check Jenkins logs
docker logs jenkins

# Access Jenkins (after it starts)
# Open browser: http://localhost:8081
```

## Verify Jenkins is Running

After starting, you should see:
- Container `jenkins` in `docker ps` output
- Jenkins accessible at `http://localhost:8081`
- Initial setup page or login page

## Next Steps

1. Run the commands above to check Jenkins status
2. If it's stopped, start it
3. Wait 1-2 minutes for Jenkins to fully start
4. Try accessing `http://localhost:8081` again

Let me know what you find when you run these commands!

