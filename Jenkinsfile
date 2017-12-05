#!groovy
def run_tests(environment) {
    sh "make ${environment}-docker"
    publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: "${environment}cov",
                reportFiles: 'index.html',
                reportName: "${environment} Coverage Report"])
}

def package_version = ''

pipeline {
    agent none

    parameters {
        booleanParam(
                name: 'RELEASE_PACKAGE',
                defaultValue: false,
                description: 'Enables publishing package to Artifactory when true')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr:'100'))
        timestamps()
    }

    stages {
        stage('Tests') {
            parallel {
                stage('Analysis') {
                    agent { label 'common_builder' }
                    steps {
                        sh 'make analysis-docker'
                    }
                    post { always { deleteDir() } }
                }

                stage('py27') {
                    agent { label 'common_builder' }
                    steps {
                        script {
                            run_tests('py27-test')
                        }
                    }

                    post {
                        always {
                            junit '*results.xml'
                            deleteDir()
                        }
                    }
                }

                stage('py3') {
                    agent { label 'common_builder' }
                    steps {
                        script {
                            run_tests('py3-test')
                        }
                    }

                    post {
                        always {
                            junit '*results.xml'
                            deleteDir()
                        }
                    }
                }
            }
        }
        stage('Publish') {
            agent { label 'common_builder' }
            when {
                allOf {
                    branch 'master'
                    expression {
                        params.RELEASE_PACKAGE == true
                    }
                }
            }

            steps {
                script {
                    milestone(0)
                    package_version = readTrusted('package_name/VERSION').trim()
                    sshagent(['github.adtran.com-SSH']) {
                        sh("git tag -a v${package_version} -m 'Jenkins auto release'")
                        sh("git push origin v${package_version}")
                    }
                    sh 'python setup.py sdist upload -r artifactory'
                }
            }
            post {
                always {
                    deleteDir()
                }
            }
        }
    }
}
