// @Library('k2glyph-shared@master') _ 

pipeline {
    agent {
        kubernetes {
          containerTemplate(name: 'gcloud', image: 'medineshkatwal/gcloud', command: '', ttyEnabled: true)
        }
    }
    parameters{
        file name:'jmeter/sample.jmx', description:'Please provide the jmeter script that you wana run.'
    }
    stages {
        stage("Execute Jmeter") {
            steps {
                withCredentials([file(credentialsId: 'staging', variable: 'staging')]) {
                    sh("gcloud auth activate-service-account --key-file=${staging}")
                    sh("gcloud container clusters get-credentials standard-cluster-1 --zone asia-south1-a --project staging-auzmor")
                }
                script {
                    sh """
                        export MASTER_NAME=\$(kubectl get pods -l app.kubernetes.io/component=master -o jsonpath='{.items[*].metadata.name}')
                        export SERVER_IPS=\$(kubectl get pods -l app.kubernetes.io/component=server -o jsonpath='{.items[*].status.podIP}' | tr ' ' ',')
                        kubectl exec -it \$MASTER_NAME -- jmeter -Jjmeter.save.saveservice.output_format=csv -n -t /jmeter/LMSAdminV2.jmx -l /jmeter/result${BUILD_NUMBER}.csv -R \$SERVER_IPS
    
                        kubectl cp \$MASTER_NAME:/jmeter/result${BUILD_NUMBER}.csv result${BUILD_NUMBER}.csv
                    """
                }
            }
        }
        stage("Publish Reports") {
            steps {
                container("gcloud") {
                 perfReport "result${env.BUILD_NUMBER}.csv"
                }
            }
        }
    }
}