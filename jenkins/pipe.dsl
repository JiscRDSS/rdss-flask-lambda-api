node {
    def credentialsId = '495f3d88-a067-44b0-8547-e62e24566ace'
    def url = 'git@flask-lambda-api.git'

    stage('Checkout') {
        git credentialsId: credentialsId, url: url
    }

    stage('Tests') {
        sh "docker-compose run test"
        sh "docker-compose down"
    }

    stage('Infra') {
        sh "./bin/deploy"
    }

    stage('Results') {
        junit 'junit.xml'
        archiveArtifacts 'htmlcov'
    }
}
