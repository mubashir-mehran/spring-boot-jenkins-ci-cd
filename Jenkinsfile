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
                    // Verify we're in the workspace and git is initialized
                    sh '''
                        pwd
                        ls -la
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
                        def latestTag = "${imageName}:latest"  // Define latest tag
                        
                        // Docker Hub login using username and token
                        sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                        sh "docker build -t ${imageName} -f Dockerfile.final ."
                        sh "docker tag ${imageName} mubashir2025/${buildTag}"
                        sh "docker tag ${imageName} mubashir2025/${latestTag}"  // Tag with latest
                        sh "docker push mubashir2025/${buildTag}"
                        sh "docker push mubashir2025/${latestTag}"  // Push latest tag
                        env.BUILD_TAG = buildTag
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
