pipeline{
    agent {
        node {
            label "java-build-server"
        }
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
                script{
                    timeout (time:1, unit:'HOURS'){
                        def qg = waitForQualityGate()   
                        if(qg.status !='OK'){   
                           error "Pipeline failed due to quality gate failures: ${qg.status}"  
                    }
                }
            }
        }
       
    }
}
