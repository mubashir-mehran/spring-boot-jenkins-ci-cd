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

        stage('Sonarqube Analysis') {
            steps {
                sh ''' mvn clean compile sonar:sonar \
                    -Dsonar.host.url=http://sonarqube:9000/ \
                    -Dsonar.login=squ_e1220c80b300dc3eefd296a5d0cb3fd9aaca2edf '''
            }
        }

        stage('Clean & Package'){
            steps{
                sh "mvn clean package -DskipTests"
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
                        
                        // Push with retry logic
                        def maxRetries = 3
                        def retryCount = 0
                        def pushSuccess = false
                        
                        while (retryCount < maxRetries && !pushSuccess) {
                            try {
                                echo "Attempting to push ${dockerHubRepo}:${BUILD_NUMBER} (attempt ${retryCount + 1}/${maxRetries})"
                                sh "docker push ${dockerHubRepo}:${BUILD_NUMBER}"
                                pushSuccess = true
                                echo "Successfully pushed ${dockerHubRepo}:${BUILD_NUMBER}"
                            } catch (Exception e) {
                                retryCount++
                                if (retryCount < maxRetries) {
                                    echo "Push failed, retrying in 10 seconds..."
                                    sleep(10)
                                } else {
                                    error("Failed to push Docker image after ${maxRetries} attempts: ${e.getMessage()}")
                                }
                            }
                        }
                        
                        // Push latest tag
                        retryCount = 0
                        pushSuccess = false
                        while (retryCount < maxRetries && !pushSuccess) {
                            try {
                                echo "Attempting to push ${dockerHubRepo}:latest (attempt ${retryCount + 1}/${maxRetries})"
                                sh "docker push ${dockerHubRepo}:latest"
                                pushSuccess = true
                                echo "Successfully pushed ${dockerHubRepo}:latest"
                            } catch (Exception e) {
                                retryCount++
                                if (retryCount < maxRetries) {
                                    echo "Push failed, retrying in 10 seconds..."
                                    sleep(10)
                                } else {
                                    error("Failed to push Docker image latest tag after ${maxRetries} attempts: ${e.getMessage()}")
                                }
                            }
                        }
                        
                        env.BUILD_TAG = "${dockerHubRepo}:${BUILD_NUMBER}"
                    }
                }
            }
        }
        
        stage('Vulnerability scanning'){
            steps{
                script {
                    def buildTag = "spring-boot-prof-management:${BUILD_NUMBER}"
                    // Use Trivy via Docker since it's not installed in Jenkins container
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image mubashir2025/${buildTag}"
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
