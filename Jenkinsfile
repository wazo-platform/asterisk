def version = null

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
    throttleJobProperty(
      categories: ['asterisk'],
      throttleEnabled: true,
      throttleOption: 'category'
    )
  }
  stages {
    stage ('Prepare') {
      steps {
        script {
          version = sh(script: 'dpkg-parsechangelog --show-field version', returnStdout: true).trim()
          currentBuild.displayName = "${JOB_NAME} ${version}"
          currentBuild.description = "Build Debian package ${JOB_NAME} ${version}"
        }
      }
    }
    stage('Debian build and deploy') {
      steps {
        build job: 'build-package-multi-arch', parameters: [
          string(name: 'PACKAGE', value: "${JOB_NAME}"),
          string(name: 'VERSION', value: "${version}"),
        ]
      }
    }
    stage('Docker build') {
      steps {
        sh "docker build --no-cache -t wazoplatform/${JOB_NAME}:latest ."
      }
    }
    stage('Docker publish') {
      steps {
        sh "docker push wazoplatform/${JOB_NAME}:latest"
      }
    }
  }
  post {
    success {
      build wait: false, job: 'asterisk-to-asterisk-vanilla'
      build wait: false, job: 'asterisk-to-asterisk-debug'
    }
    failure {
      emailext to: "${MAIL_RECIPIENTS}", subject: '${DEFAULT_SUBJECT}', body: '${DEFAULT_CONTENT}'
    }
    fixed {
      emailext to: "${MAIL_RECIPIENTS}", subject: '${DEFAULT_SUBJECT}', body: '${DEFAULT_CONTENT}'
    }
  }
}
