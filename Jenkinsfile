podTemplate(yaml: """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: 'jenkins/jnlp-slave:3.35-5-alpine'
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
    env:
      - name: GIT_USERNAME
        valueFrom:
            secretKeyRef:
              name: git-credentials
              key: username
      - name: GIT_PASSWORD
        valueFrom:
        secretKeyRef:
            name: git-credentials
            key: password
  - name: buildah
    image: quay.io/buildah/stable:v1.14.8
    envFrom:
      - configMapRef:
            name: icr-config
    env:
      - name: ICR_APIKEY
        valueFrom:
            secretKeyRef:
              name: default-us-icr-io
              key: .dockerconfigjson

        

""") {
    node(POD_LABEL) {
        stage('Git Clone') {
            // checks out the source the JenkinsFile is taken from
            checkout scm
        }
        stage('Initialize') {
            sh '''#!/bin/bash
            set -e +x
            APP_VERSION="$(git rev-parse --short HEAD)"
            echo "APP_VERSION=$APP_VERSION" > ./env-config
            cat ./env-config

            git config --global user.email "jenkins@ci"
            git config --global user.name "Jenkins CI"
            git config --global credential.helper "!f() { echo username=\\$GIT_USERNAME; echo password=\\$GIT_PASSWORD; }; f"
            '''
        }
        container('buildah') {
            stage('Build Image') {
            }
        }
    }
}