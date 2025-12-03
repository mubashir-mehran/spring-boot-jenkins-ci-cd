pipeline {
    agent any

    options {
        skipDefaultCheckout(true)  // Skip automatic checkout - code is already checked out by "Pipeline script from SCM"
    }

    tools{
        jdk 'jdk17'
        maven 'maven3'
    }

    stages {
        stage('Verify Workspace') {
            steps {
                script {
                    // Fix Git ownership issue and verify workspace
                    sh '''
                        pwd
                        # Fix Git dubious ownership warning
                        git config --global --add safe.directory $(pwd) || true
                        # Verify we're in the workspace and git is initialized
                        if [ ! -d .git ]; then
                            echo "Git directory not found, this should not happen with Pipeline script from SCM"
                            exit 1
                        fi
                        git status
                    '''
                }
            }
        }
        
        // Temporarily disabled - configure Dependency-Check tool first
        // stage('OWASP Dependency Check'){
        //     steps{
        //         dependencyCheck additionalArguments: '--scan ./ --format HTML ', odcInstallation: 'db-check'
        //         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //     }
        // }

        stage('Test & Coverage') {
            steps {
                script {
                    try {
                        echo "Running tests with JaCoCo coverage..."
                        sh '''
                            echo "=== Checking test files exist ==="
                            find src/test/java -name "*Test.java" -type f | sort
                            echo "Total test files found: $(find src/test/java -name "*Test.java" -type f | wc -l)"
                            
                            echo "=== Checking Maven configuration ==="
                            mvn help:evaluate -Dexpression=project.build.plugins -q -DforceStdout | grep -iE "surefire|jacoco" || true
                            
                            echo "=== Running tests ==="
                            mvn clean test 2>&1 | tee test-output.log || {
                                echo "=== TEST EXECUTION FAILED ==="
                                echo "Last 100 lines of test output:"
                                tail -100 test-output.log || echo "Could not read test output"
                                exit 1
                            }
                            
                            echo "=== Checking test compilation ==="
                            echo "Test classes compiled:"
                            find target/test-classes -name "*Test.class" -type f | wc -l
                            find target/test-classes -name "*Test.class" -type f | sort
                            
                            echo "=== Checking for JaCoCo agent in test output ==="
                            grep -iE "argLine|javaagent|jacoco" test-output.log | head -5 || echo "No JaCoCo agent found in output"
                            
                            echo "=== Test execution summary ==="
                            grep -E "Tests run:|BUILD" test-output.log | tail -5
                        '''
                        echo "Generating JaCoCo coverage report..."
                        sh "mvn jacoco:report"
                        
                        // Verify coverage files were generated
                        sh '''
                            echo "=== Verifying Coverage Files ==="
                            if [ -f target/jacoco.exec ]; then
                                echo "✓ Coverage exec file exists: target/jacoco.exec"
                                ls -lh target/jacoco.exec
                                echo "File size: $(stat -f%z target/jacoco.exec 2>/dev/null || stat -c%s target/jacoco.exec 2>/dev/null || echo 'unknown') bytes"
                                if [ -s target/jacoco.exec ]; then
                                    echo "✓ Coverage exec file is NOT empty (has coverage data)"
                                else
                                    echo "⚠ WARNING: Coverage exec file is EMPTY (no coverage data collected)"
                                fi
                            else
                                echo "⚠ Coverage exec file NOT found: target/jacoco.exec"
                            fi
                            
                            if [ -f target/site/jacoco/jacoco.xml ]; then
                                echo "✓ Coverage XML report exists: target/site/jacoco/jacoco.xml"
                                ls -lh target/site/jacoco/jacoco.xml
                                echo "Checking coverage data in XML..."
                                if grep -q "covered=\"[1-9]" target/site/jacoco/jacoco.xml 2>/dev/null; then
                                    echo "✓ Coverage XML contains coverage data (found covered > 0)"
                                    echo "Sample coverage data:"
                                    grep -o "covered=\"[0-9]*\"" target/site/jacoco/jacoco.xml | head -5
                                else
                                    echo "⚠ WARNING: Coverage XML exists but shows 0% coverage (all covered=\"0\")"
                                    echo "First few lines of XML:"
                                    head -10 target/site/jacoco/jacoco.xml
                                fi
                            else
                                echo "⚠ Coverage XML report NOT found: target/site/jacoco/jacoco.xml"
                            fi
                            
                            if [ -f target/site/jacoco/index.html ]; then
                                echo "✓ Coverage HTML report exists: target/site/jacoco/index.html"
                            else
                                echo "⚠ Coverage HTML report NOT found: target/site/jacoco/index.html"
                            fi
                            
                            echo "=== Coverage Files Summary ==="
                            find target -name "jacoco*" -type f 2>/dev/null | head -10 || echo "No jacoco files found"
                        '''
                        
                        echo "✓ Tests passed and coverage report generated"
                    } catch (Exception e) {
                        echo "⚠ WARNING: Tests failed, but pipeline will continue"
                        echo "⚠ Error: ${e.getMessage()}"
                        echo "⚠ Attempting to generate coverage report anyway..."
                        try {
                            sh "mvn jacoco:report || true"
                            sh '''
                                echo "Checking for coverage files after failed test..."
                                ls -la target/jacoco.exec 2>/dev/null || echo "No jacoco.exec found"
                                ls -la target/site/jacoco/jacoco.xml 2>/dev/null || echo "No jacoco.xml found"
                            '''
                        } catch (Exception e2) {
                            echo "⚠ Could not generate coverage report: ${e2.getMessage()}"
                        }
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                always {
                    script {
                        // Archive test results (if they exist)
                        catchError(buildResult: null, stageResult: null) {
                            junit 'target/surefire-reports/*.xml'
                        }
                        // Archive coverage reports (if they exist)
                        catchError(buildResult: null, stageResult: null) {
                            sh '''
                                echo "=== Archiving Coverage Reports ==="
                                if [ -d target/site/jacoco ]; then
                                    echo "Archiving jacoco directory..."
                                    tar -czf jacoco-reports.tar.gz -C target/site jacoco/ 2>/dev/null || true
                                fi
                            '''
                            archiveArtifacts artifacts: 'target/site/jacoco/**/*', allowEmptyArchive: true
                            archiveArtifacts artifacts: 'target/jacoco.exec', allowEmptyArchive: true
                            archiveArtifacts artifacts: 'jacoco-reports.tar.gz', allowEmptyArchive: true
                        }
                    }
                }
            }
        }

        stage('Sonarqube Analysis') {
            steps {
                script {
                    sh '''
                        echo "=== Preparing SonarQube Analysis ==="
                        echo "Checking for coverage files..."
                        
                        if [ -f target/jacoco.exec ]; then
                            echo "✓ Found coverage exec file: target/jacoco.exec"
                            ls -lh target/jacoco.exec
                        else
                            echo "⚠ WARNING: Coverage exec file not found: target/jacoco.exec"
                        fi
                        
                        if [ -f target/site/jacoco/jacoco.xml ]; then
                            echo "✓ Found coverage XML report: target/site/jacoco/jacoco.xml"
                            ls -lh target/site/jacoco/jacoco.xml
                            echo "First few lines of coverage XML:"
                            head -20 target/site/jacoco/jacoco.xml || true
                        else
                            echo "⚠ WARNING: Coverage XML report not found: target/site/jacoco/jacoco.xml"
                            echo "Creating empty coverage report structure..."
                            mkdir -p target/site/jacoco || true
                        fi
                        
                        echo "Running SonarQube analysis with coverage data..."
                    '''
                    
                    sh ''' 
                        mvn sonar:sonar \
                    -Dsonar.host.url=http://sonarqube:9000/ \
                            -Dsonar.login=squ_e1220c80b300dc3eefd296a5d0cb3fd9aaca2edf \
                            -Dsonar.jacoco.reportPath=target/jacoco.exec \
                            -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                            -Dsonar.coverage.exclusions=**/entities/**,**/GestionProfesseursApplication.java
                        echo "SonarQube analysis completed"
                    '''
                }
            }
        }

        stage('Package'){
            steps{
                sh "mvn package -DskipTests"
            }
        }


        
       stage("Docker Build & Push"){
            steps{
                script{
                    // Using the existing credential ID from Jenkins (Username with password type)
                    withCredentials([usernamePassword(credentialsId: 'dckr_pat_Rgo0rM8UVvrQCJKNhL4Yvfx1PzY', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        def imageName = "spring-boot-prof-management"
                        def buildTag = "${imageName}:${BUILD_NUMBER}"
                        def latestTag = "${imageName}:latest"
                        def dockerHubRepo = "mubashir2025/${imageName}"
                        
                        // Docker Hub login using username and token
                        sh """
                            echo "Logging into Docker Hub..."
                            echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin
                            echo "Verifying Docker Hub connection..."
                            docker info
                        """
                        
                        // Build Docker image
                        sh "docker build -t ${imageName} -f Dockerfile.final ."
                        
                        // Check image size
                        sh """
                            echo "Docker image size:"
                            docker images ${imageName} --format "{{.Size}}"
                        """
                        
                        // Tag images
                        sh "docker tag ${imageName} ${dockerHubRepo}:${BUILD_NUMBER}"
                        sh "docker tag ${imageName} ${dockerHubRepo}:latest"
                        
                        // Push with retry logic (non-blocking - pipeline continues even if push fails)
                        def maxRetries = 3
                        def pushBuildSuccess = false
                        def pushLatestSuccess = false
                        
                        // Try to push build tag (non-blocking)
                        try {
                            def retryCount = 0
                            while (retryCount < maxRetries && !pushBuildSuccess) {
                                try {
                                    echo "Attempting to push ${dockerHubRepo}:${BUILD_NUMBER} (attempt ${retryCount + 1}/${maxRetries})"
                                    sh "docker push ${dockerHubRepo}:${BUILD_NUMBER}"
                                    pushBuildSuccess = true
                                    echo "✓ Successfully pushed ${dockerHubRepo}:${BUILD_NUMBER}"
                                } catch (Exception e) {
                                    retryCount++
                                    if (retryCount < maxRetries) {
                                        echo "⚠ Push failed, retrying in 10 seconds... (${e.getMessage()})"
                                        sleep(10)
                                    } else {
                                        echo "⚠ WARNING: Failed to push ${dockerHubRepo}:${BUILD_NUMBER} after ${maxRetries} attempts"
                                        echo "⚠ Error: ${e.getMessage()}"
                                        echo "⚠ Pipeline will continue despite push failure"
                                    }
                                }
                            }
                        } catch (Exception e) {
                            echo "⚠ WARNING: Docker push for build tag failed, but continuing pipeline"
                            echo "⚠ Error: ${e.getMessage()}"
                        }
                        
                        // Try to push latest tag (non-blocking)
                        try {
                            def retryCount = 0
                            while (retryCount < maxRetries && !pushLatestSuccess) {
                                try {
                                    echo "Attempting to push ${dockerHubRepo}:latest (attempt ${retryCount + 1}/${maxRetries})"
                                    sh "docker push ${dockerHubRepo}:latest"
                                    pushLatestSuccess = true
                                    echo "✓ Successfully pushed ${dockerHubRepo}:latest"
                                } catch (Exception e) {
                                    retryCount++
                                    if (retryCount < maxRetries) {
                                        echo "⚠ Push failed, retrying in 10 seconds... (${e.getMessage()})"
                                        sleep(10)
                                    } else {
                                        echo "⚠ WARNING: Failed to push ${dockerHubRepo}:latest after ${maxRetries} attempts"
                                        echo "⚠ Error: ${e.getMessage()}"
                                        echo "⚠ Pipeline will continue despite push failure"
                                    }
                                }
                            }
                        } catch (Exception e) {
                            echo "⚠ WARNING: Docker push for latest tag failed, but continuing pipeline"
                            echo "⚠ Error: ${e.getMessage()}"
                        }
                        
                        // Set build tag regardless of push success
                        env.BUILD_TAG = "${dockerHubRepo}:${BUILD_NUMBER}"
                        
                        // Summary
                        if (pushBuildSuccess && pushLatestSuccess) {
                            echo "✓ Docker push completed successfully"
                        } else {
                            echo "⚠ WARNING: Docker push had failures, but pipeline continues"
                            currentBuild.result = 'UNSTABLE'
                        }
                    }
                }
            }
        }
        
        stage('Vulnerability scanning'){
            steps{
                script {
                    try {
                        // Scan the local image (since push may have failed)
                        def imageToScan = "spring-boot-prof-management:latest"
                        echo "Starting vulnerability scan for local image: ${imageToScan}..."
                        
                        // Use Trivy via Docker with timeout and skip DB update if it fails
                        // Use --skip-db-update to avoid network issues if DB download fails
                        def scanSuccess = false
                        def maxRetries = 2
                        def retryCount = 0
                        
                        while (retryCount < maxRetries && !scanSuccess) {
                            try {
                                if (retryCount == 0) {
                                    // First attempt: try with DB update
                                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --timeout 5m ${imageToScan}"
                                } else {
                                    // Retry: skip DB update to avoid network issues
                                    echo "Retrying scan with --skip-db-update to avoid network issues..."
                                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --skip-db-update --timeout 5m ${imageToScan}"
                                }
                                scanSuccess = true
                                echo "✓ Vulnerability scan completed successfully"
                            } catch (Exception e) {
                                retryCount++
                                if (retryCount < maxRetries) {
                                    echo "⚠ Scan failed, retrying... (${e.getMessage()})"
                                    sleep(5)
                                } else {
                                    throw e
                                }
                            }
                        }
                    } catch (Exception e) {
                        echo "⚠ WARNING: Vulnerability scanning failed, but pipeline continues"
                        echo "⚠ Error: ${e.getMessage()}"
                        echo "⚠ This may be due to network/DNS issues or Trivy database download problems"
                        echo "⚠ You can run Trivy scan manually later if needed"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }

        stage("Staging"){
            steps{
                sh 'docker-compose up -d'
            }
        }
    }
}
