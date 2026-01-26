
## This is a simple docker deployment in this we used different tools like 

##
GitHub
   ↓
Jenkins (CI/CD)
   ↓
Docker Image
   ↓
Docker Hub
   ↓
Docker Swarm
   ↓
Multiple Replicas on Multiple Nodes
##



**
## Git+Maven+Jenkins+dockerswarm+docker**

First we need to take ec2 servers based on the our requirement so i tool two servers 

1st machine I have installed Jenkins and docker swarm its called master machine where our docker swarm availble

then i have installed docker in another server to communicate with the docker swarm its called a master and node concept in the docker swarm

Now i am pasting here installation procceses hope you know the jenkins installation processes

* jenkins.io select which operating system you want

## Maven installation on the main server called where our jenkins is there

  * sudo apt-get update -y && apt-get install -y mvn
 * sudo apt-get install -y
## install docker swarm first you need to install docker

* sudo apt-get update -y 
* apt-get install -y docker

once the installation is completed then you can run the 

** docker init command

## Once the installation is completed then you can navigate to the secon machiine and install the docker

* sudo apt-get update -y && apt-get install -y docker

then login to the first server and run the command like below

* docker swarm join-token worker 
## it will generate one command then copy that command and run in the second server where our docker installed

## once the above steps completed create a one docker hub account which is used for to store the docker images

once the docker hub is created navigate to the setting>>accesss token>>generate new token then copy the credentials

after that we need to add those credentials into the jenkins 

## jenkins main page > manage Jenkins > credentials > select global > then select secret text then add your credential
 Field	   Value
Kind	      Secret text
Secret	    👉 Docker Hub Access Token (not password)
ID	         dockerhub-token
Description   	Docker Hub Token


After all setup completed now you can create a jenkins pipeline

pipeline {
    agent any

    environment {
        BUILD_NO = "${BUILD_NUMBER}"   ### this is just a build number
        IMAGE_NAME = "chaitanya9666/java-web-app"      ## This is our docker image name 
        DOCKER_SERVICE_NAME = "java-web-app-service"   ## This is service name
    }

    stages {

        stage('Download the Code') {     ## to clone the code 
            steps {
                git 'https://github.com/chaithushanvi/java-web-app-docker.git'
            }
        }

        stage('Build the Code (Maven)') {    ## build the code and generate the artifacts
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {     ## Building the image with the docker file docker docker file is already in the sorce code so no need to write sepearatly.
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:${BUILD_NO} .
                """
            }
        }

        stage('Docker Login') {       ### here we need to loguin the docker hub because we need to store our docker image right so thats why we need to login using this the below script
            steps {
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u chaitanya9666 --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {   ### once the login we need to push the image to docker hub using the below command
            steps {
                sh """
                    docker push ${IMAGE_NAME}:${BUILD_NO}
                """
            }
        }

        stage('Deploy to Docker Swarm') {         ### then we need to deploy our application into the tomcat server 
            steps {
                sh """
                    docker service rm ${DOCKER_SERVICE_NAME} || true

                    docker service create \
                      --name ${DOCKER_SERVICE_NAME} \
                      --replicas 2 \
                      --publish published=8081,target=8080 \
                      ${IMAGE_NAME}:${BUILD_NO}
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}




once the deployment is completed now you can verify whether our application is working or not

copy the public id of secon machine and give the port like 8081 http://id:8081

once the page is running then you can verify the docker swarm healing like

we have given like 2 replicas so you can delete one replica

** docker ps

** docker kill <container-id>

** docker ps

** docker service ps java-web-app-service


and also we can increase replicas and decrease the replicas

** docker service scale java-web-app-service=3

docker service scale java-web-app-service=2






