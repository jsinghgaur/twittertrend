
def registry = 'https://jsinghg.jfrog.io/'
def imageName = 'jsinghg.jfrog.io/ttrends-docker-local/ttrend'
def version   = '2.0.2'
pipeline{
    agent {
        node {
            label "java-build-server"
        }
    }
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '8', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '8')
    }
    environment {
        PATH = "/opt/apache-maven-3.9.0/bin:$PATH"
    }
    stages {
        stage('SCM checkout'){
            steps{
               git branch: 'main', credentialsId: '2dca0189-cd3d-484d-8d0e-c69b4a710658', url: 'https://github.com/jsinghgaur/twittertrend.git'
            }
        }
        stage('build') {
            steps{
                sh 'mvn clean deploy'
            }
        } 
        stage("Sonar Analysis") {
            environment {
               scannerHome = tool 'MySonarScanner'
            }
            steps {
                echo '<--------------- Sonar Analysis started  --------------->'
                withSonarQubeEnv('MySonarQubeServer') {    
                    sh "${scannerHome}/bin/sonar-scanner"
                echo '<--------------- Sonar Analysis ends --------------->'    
                }    
            }   
        }
        stage('Quality Gate'){
            steps{
                echo '<----------------Quality Gate------------------------->'
                script{
                    timeout (time: 1, unit: 'HOURS'){
                        def qg = waitForQualityGate()   
                        if(qg.status !='OK'){   
                           error "Pipeline failed due to quality gate failures: ${qg.status}"  
                        }
                    }
                }
            }
       
        }
        stage('jfrog deploy'){
            steps{
                 script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"jenkins-jfrog-token"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "ttrends-libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
            
                }
            }
        }

        stage(" Docker Build "){
            steps {
                script {
                    echo '<--------------- Docker Build Started --------------->'
                    app = docker.build(imageName+":"+version)
                    echo '<--------------- Docker Build Ends --------------->'
                }
            }
        }

        stage (" Docker Publish "){
            steps {
                script {
                    echo '<--------------- Docker Publish Started --------------->'  
                    docker.withRegistry(registry, 'jenkins-jfrog-token'){
                    app.push()
                    }    
                    echo '<--------------- Docker Publish Ended --------------->'  
                }
            }
        }
        stage('Deploy'){
            steps {
                script{
                    sh './deploy.sh'
                }
            }
        }
    }
}
