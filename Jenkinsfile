podTemplate() {
    node(POD_LABEL) {
        stage('Git Clone') {
            // checks out the source the JenkinsFile is taken from
            checkout scm
        }
        stage('Initialize') {
            sh'''#!/bin/bash
            set -e +x
            APP_VERSION="$(git rev-parse --short HEAD)"
            echo "APP_VERSION=$APP_VERSION" > ./env-config
            cat ./env-config

            git config --global user.email "${APP_NAME}@ci"
            git config --global user.name "Jenkins CI"
            '''
        }
    }
}