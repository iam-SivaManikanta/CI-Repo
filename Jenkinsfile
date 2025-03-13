pipeline{
    agent { label 'Linux' }
    
    environment{
        IMAGE_TAG = "${BUILD_NUMBER}"
        PATH = "/usr/bin:/usr/local/bin:/usr/sbin:/sbin:$PATH"
        GIT = "/usr/bin/git"
        DOCKER = "/usr/bin/docker"
    }
    
    stages{
        stage('git checkout'){
            steps{
               checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: '896ffc88-c10d-43e4-b721-b3bcb6da0285', url: 'https://github.com/iam-SivaManikanta/CI-Repo.git']]) 
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') { // Match the name of your SonarQube server config
                    sh '''
                    echo 'Running SonarQube Analysis...'
                    /opt/sonar-scanner-5.0.1.3006-linux/bin/sonar-scanner \
                      -Dsonar.projectKey=cicdpython \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=http://localhost:9000 \
                      -Dsonar.login=squ_e765e9cca6005ac7ea260a68350465aab7e89c11
                    '''
                }
            }
        }
        
        stage('Building Docker Image'){
            steps{
                sh '''
                echo 'building docker image'
                docker --version
                docker build -t mani937/cicdpython:${BUILD_NUMBER} .
                '''
            }
        }
        stage('Scanning Image with Trivy') {
            steps {
                sh '''
                echo 'Scanning Docker image with Trivy...'
                trivy image -f table -o result.sui mani937/cicdpython:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Pushing the Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                sh '''
                echo "Logging into Docker Hub..."
                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
             
                echo "Pushing to repo..."
                docker push mani937/cicdpython:${BUILD_NUMBER}
                '''
        }
    }
}

        
        stage('checking out the kube files'){
            steps{
               checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: '896ffc88-c10d-43e4-b721-b3bcb6da0285', url: 'https://github.com/iam-SivaManikanta/CD-manifeasts.git']])
            }
        }
        
        stage('update kube files'){
            steps{
                withCredentials([usernamePassword(credentialsId: '896ffc88-c10d-43e4-b721-b3bcb6da0285', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh '''
                    cat deploy.yaml
                    sed -i "s|mani937/cicdpython:[v0-9]*|mani937/cicdpython:${BUILD_NUMBER}|g" deploy.yaml
                    cat deploy.yaml
                    git add deploy.yaml
                    git commit -m 'Updated the deploy yaml | Jenkins Pipeline'
                    git remote -v
                    git push https://$GIT_USERNAME:$GIT_PASSWORD@github.com/iam-SivaManikanta/CD-manifeasts.git HEAD:master
                    '''
                }
            }
        }
    }
}
