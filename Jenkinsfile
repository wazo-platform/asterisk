def packageName = null
def version = null
def isRc = false

pipeline {
  agent any
  triggers {
    githubPush()
    pollSCM('H H * * *')
  }
  environment {
    MAIL_RECIPIENTS = 'dev+tests-reports@wazo.community'
  }
  options {
    skipStagesAfterUnstable()
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
  }
  stages {
    stage ('Prepare') {
      steps {
        script {
          isRc = env.GIT_BRANCH == 'origin/asterisk-rc'
          packageName = sh(script: 'dpkg-parsechangelog --show-field source', returnStdout: true).trim()
          version = sh(script: 'dpkg-parsechangelog --show-field version', returnStdout: true).trim()
          if (isRc) {
            version = "${version}~astrc"
          }
          currentBuild.displayName = "${JOB_NAME} ${version}"
          currentBuild.description = "Build Debian package ${packageName} ${version}"
        }
      }
    }
    stage('Debian build and deploy') {
      steps {
        script {
          def parameters = [
            string(name: 'PACKAGE', value: packageName),
            string(name: 'VERSION', value: version),
          ]
          if (isRc) {
            parameters += [
              string(name: 'BRANCH', value: 'asterisk-rc'),
              string(name: 'DISTRIBUTION', value: 'asterisk-rc'),
            ]
          }
          build job: 'build-package-multi-arch', parameters: parameters
        }
      }
    }
    stage('Docker build') {
      when { expression { !isRc } }
      steps {
        sh "docker build --no-cache -t wazoplatform/${JOB_NAME}:latest ."
      }
    }
    stage('Docker publish') {
      when { expression { !isRc } }
      steps {
        sh "docker push wazoplatform/${JOB_NAME}:latest"
      }
    }
  }
  post {
    success {
      script {
        if (!isRc) {
          build wait: false, job: 'asterisk-to-asterisk-vanilla'
          build wait: false, job: 'asterisk-to-asterisk-debug'
        }
      }
    }
    failure {
      emailext to: "${MAIL_RECIPIENTS}", subject: '${DEFAULT_SUBJECT}', body: '${DEFAULT_CONTENT}'
    }
    fixed {
      emailext to: "${MAIL_RECIPIENTS}", subject: '${DEFAULT_SUBJECT}', body: '${DEFAULT_CONTENT}'
    }
  }
}
