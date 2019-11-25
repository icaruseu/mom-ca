pipeline {
    agent any

    stages {
        stage('Get Source') {
            steps {
                echo 'Building..'
                checkout([$class: 'GitSCM', branches: [[name: '*/exist-next']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'mom.XRX']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '5a9a1614-9e11-4679-94f8-75dc11d7bde7', url: 'http://github.com/StephanMa/mom-ca']]])
            }
        }
        stage('build') {
            steps {
                echo 'building'
                withAnt(installation: 'ant_latest', jdk: 'jdk8u212') {
                    dir("mom.XRX") {
                       sh "ant "
                    }
                }
            }
        }
    }
}
