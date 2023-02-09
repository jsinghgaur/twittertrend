pipeline{
    agent{
        node{
            label 'java-build-server'
        }
    }
    
    stages{
        
        stage('sonar analysis'){
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
    }
    
}