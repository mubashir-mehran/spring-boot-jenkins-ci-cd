pipeline {
    agent any

    tools{
        jdk 'jdk17'
        maven 'maven3'
    }

    stages {
        stage('Code Checkout') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/AbderrahmaneOd/Spring-Boot-Jenkins-CI-CD'
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
                sh ''' mvn sonar:sonar \
                    -Dsonar.host.url=http://localhost:9000/ \
                    -Dsonar.login=squ_f6ae0f1ae224b08bb01266f9a817e169d24ee0b9 '''
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
                    withDockerRegistry(credentialsId: 'DockerHub-Token', toolName: 'docker') {
                        def imageName = "spring-boot-prof-management"
                        def buildTag = "${imageName}:${BUILD_NUMBER}"
                        def latestTag = "${imageName}:latest"  // Define latest tag
                        
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
                sh " trivy image mubashir2025/${buildTag}"
            }
        }

        stage("Staging"){
            steps{
                sh 'docker-compose up -d'
            }
        }
    }
}
