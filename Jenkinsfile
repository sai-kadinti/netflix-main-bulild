pipeline 
{
    agent { label "main" }

    environment 
    {
        DEV_SERVER_IP  = "100.27.28.9"
        JENKINS_SERVER_IP= "54.174.190.209"
        SONARQUBE_IPADDRESS = "http://100.27.28.9:9000/"
        SONARQUBE_TOKEN = "squ_ccb0d1ce68936479547512162c5d5f24ca606bea"
        DOCKERHUB_USER = 'kadintisai'
        DOCKERHUB_PASS = credentials('docker_pwd')
        HOST_PORT = '9998'
        SKIP_STAGE = 'true'
    }

    stages {
        stage('Download source code') 
        {
            steps 
            {
                git branch: 'gh-pages', url: 'https://github.com/sai-kadinti/netflix-main-bulild.git'
                sh 'echo "Present working Directory: $(pwd)"'
                sh 'echo "List of files: $(ls -lrth)"'
            }
        }

        stage('SonarQube Scan') 
        {
            when
            {
                expression { return env.SKIP_STAGE = 'true' }
            }
            steps 
            {
                echo "use != in when block to skip this step if need"
                sh '''
                    /opt/sonar-scanner/bin/sonar-scanner \
                      -Dsonar.projectKey=web-ui-project \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=${SONARQUBE_IPADDRESS} \
                      -Dsonar.token=${SONARQUBE_TOKEN} \
                      -Dsonar.sourceEncoding=UTF-8 \
                      -Dsonar.exclusions=**/node_modules/**,**/*.min.js
                '''
            }
        }
        stage ("Installing dependencies")
        {
            steps 
            {
                sh "cd /home/ubuntu/jenkins/workspace/${JOB_NAME}"
                sh "npm install"
            }
        }
        stage ("Building Artifats")
        {
            steps
            {
                sh "npm run build"
                sh "ls -lrth"
            }
        }
        stage ("Deploy in QA")
        {
            steps
            {
                sh 'ssh root@${JENKINS_SERVER_IP} "sudo rm -rf /var/www/html/*"'
                sh 'scp -r dist/* root@${JENKINS_SERVER_IP}:/var/www/html/'
                sh 'ssh root@${JENKINS_SERVER_IP} "sudo systemctl restart nginx"'
                echo "Access it via: http://${JENKINS_SERVER_IP}/"
            }
        }
        stage ('Create Docker image')
        {
            steps
            {
                sh "docker build -t kadintisai/netflix:${BUILD_NUMBER} ."
            }
        }
        stage ("Docker login")
        {
            steps 
            {

                sh 'docker login -u $DOCKERHUB_USER -p $DOCKERHUB_PASS'
                sh 'echo "Docker login succeed"'
            }
        }
        stage ("Push the image to DockerHub")
        {
            steps 
            {
                sh "docker push kadintisai/netflix:${BUILD_NUMBER}"
            }
        }
        stage ("Run the container")
        {
            steps
            {
                sh 'docker run --name netflix_${BUILD_NUMBER} -p ${HOST_PORT}:80 -d kadintisai/netflix:${BUILD_NUMBER}'
            }
        }
        stage ('Access the service')
        {
            steps
            {
                echo "QA Server: http://${JENKINS_SERVER_IP}/"
                echo "PROD Server: http://${DEV_SERVER_IP}:${HOST_PORT}/"
            }
        }
    }
}
