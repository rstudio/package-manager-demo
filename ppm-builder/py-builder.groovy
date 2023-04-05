def buildImage = 'rocker/verse:4.2'

pipeline {
    agent any
    environment {
        R_LIBS = 'packages'
        R_KEEP_PKG_SOURCE = 'yes'
        PACKAGEMANAGER_ADDRESS = 'http://host.docker.internal:4242'
        PACKAGEMANAGER_TOKEN = credentials('PACKAGEMANAGER_TOKEN')
        PACKAGEMANAGER_SOURCE = 'local-r'
        PACKAGEMANAGER_DISTRIBUTION = 'jammy'
    }
    triggers {
        pollSCM('H/5 * * * *')
    }
    stages {
        stage('Initialize') {
            steps{
                dir(env.R_LIBS) {
                    deleteDir()
                }
                sh 'mkdir $R_LIBS'
                checkout scmGit(branches: [[name: '*/main']], 
                                extensions:  [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'source']], 
                                userRemoteConfigs: [[url: '!!!REPO_URL!!!']])
            }
        }
        stage('Initialize Container') {
            agent {
                docker { 
                    image "${buildImage}"
                    reuseNode true 
                }
            }
            steps {
                sh '''
# install package dependencies
R -e 'devtools::install("source", dependencies=TRUE)'
'''
            }      
        }
        stage('Check') {
            agent {
                docker { 
                    image "${buildImage}"
                    reuseNode true 
                }
            }
            steps {
                sh '''
# check package for errors
echo Checking package...
R -e 'devtools::check("source")'
'''
            }
        }
        stage('Build') {
            agent {
                docker { 
                    image "${buildImage}"
                    reuseNode true 
                }
            }
            steps {
                sh '''
# build source package
echo Building source package...
R -e 'cat(devtools::build("source"), file="sourcefile")'

# build binary package
echo Building binary package...
R -e 'cat(devtools::build("source", binary=TRUE), file="binaryfile")'
'''
            }
        }
        stage('Publish') {
            steps{
                sh '''
# get vars from previous stage
sourcefile=$(cat sourcefile)
binaryfile=$(cat binaryfile)
# download API if not available
[ -x rspm ] || curl -O -J -H \"Authorization: Bearer ${PACKAGEMANAGER_TOKEN}\" ${PACKAGEMANAGER_ADDRESS}/__api__/download && chmod +x ./rspm
# upload source package
./rspm add --source=${PACKAGEMANAGER_SOURCE} --path=$sourcefile --replace
# upload binary package
./rspm add binary --source=${PACKAGEMANAGER_SOURCE} --distribution=${PACKAGEMANAGER_DISTRIBUTION} --path=$binaryfile --replace
'''
            }
        }
    }
}