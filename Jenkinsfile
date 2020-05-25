// import org.jenkinsci.plugins.workflow.support.steps.build.RunWrapper

// def sanitize(name) {
//   return name.replaceAll('[^\\p{IsAlphabetic}\\d]', '-')
// }

// def computeAppName(RunWrapper build) {
//   def i = build.projectName.indexOf('.')
//   return sanitize(build.projectName.substring(i + 1)).toLowerCase()
// }

def branch = env.BRANCH_NAME
def appName = env.JOB_NAME.toLowerCase().replaceAll("/${branch}", "")
def buildNumber = env.BUILD_NUMBER
def timestamp = env.TAG_TIMESTAMP


println"""
App Name: ${appName}
Branch: ${branch}
Build Number: ${buildNumber}
Timestamp: ${timestamp}
"""

podTemplate(yaml:"""
metadata:
  namespace: jenkins
spec:
  containers:
  - name: ibmcloud
    image: docker.io/sam0996/helm:1.0
    tty: true
    command: ["/bin/bash"]
    volumeMounts:
    - name: home-volume
      mountPath: /home/jenkins
    envFrom:
      - configMapRef:
          name: cr-config    
    env:
    - name: HOME
      value: /home/jenkins
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
    - name: BRANCH
      value: ${branch}
    - name: APP_NAME
      value: ${appName}
  - name: buildah
    image: quay.io/buildah/stable:v1.14.8
    command: ["/bin/bash"]
    securityContext:
      privileged: true
    tty: true
    volumeMounts:
    - name: home-volume
      mountPath: /home/jenkins
    envFrom:
      - configMapRef:
          name: cr-config
    env:
    - name: HOME
      value: /home/jenkins
    - name: CR_USERNAME
      valueFrom:
        secretKeyRef:
          name: cr-credentials
          key: username
    - name: CR_PASSWORD
      valueFrom:
        secretKeyRef:
          name: cr-credentials
          key: password
    - name: APP_NAME
      value: ${appName}
    - name: DOCKERFILE
      value: ./Dockerfile
    - name: CONTEXT
      value: .
    - name: TLS_VERIFY
      value: "false"
  volumes:
  - name: home-volume
    emptyDir: {}
""") {
    node(POD_LABEL) {
        container(name: 'ibmcloud', shell: '/bin/bash') {
          stage('Git Clone') {
              // checks out the source the JenkinsFile is taken from
              checkout scm
          }
        }
        container(name: 'ibmcloud', shell: '/bin/bash') {
          stage('Initialize') {
              sh'''#!/bin/bash
              set -e +x

              APP_VERSION="$(git rev-parse --short HEAD)-$BRANCH"
              APP_IMAGE="${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${APP_NAME}:${APP_VERSION}"
              echo "APP_VERSION=$APP_VERSION" >> ./env-config
              echo "APP_IMAGE=$APP_IMAGE" >> ./env-config
              cat ./env-config

              git config --global user.email "${APP_NAME}@ci"
              git config --global user.name "Jenkins CI"
              git config --global credential.helper "!f() { echo username=\\$GIT_USERNAME; echo password=\\$GIT_PASSWORD; }; f"
              '''
          }
        }
        container(name: 'buildah', shell: '/bin/bash') {
          if (false)
          {
          stage('Build Image') {
            sh '''#!/bin/bash
                set -e +x
                . ./env-config

                echo "Building image $APP_IMAGE"

                buildah bud --format=docker -f "$DOCKERFILE" -t "$APP_IMAGE" "$CONTEXT"

                if [[ $CR_USERNAME && $CR_PASSWORD ]]
                then
                  echo "Logging into registry $REGISTRY_URL"
                  buildah login -u "$CR_USERNAME" -p "$CR_PASSWORD" "$REGISTRY_URL"
                fi

                echo "Pushing image to the registry"
                buildah --tls-verify=$TLS_VERIFY push "$APP_IMAGE" "docker://$APP_IMAGE"
                '''
          }
          }
        }
        container(name: 'ibmcloud', shell: '/bin/bash') {
          stage ("Deploy to dev") {
            sh '''#!/bin/bash
              set -e
              . ./env-config
              helm version
              helm upgrade $APP_NAME deployment/$APP_NAME -f deployment/values_dev.yaml --install --set image.tag=$APP_VERSION --namespace dev --atomic --cleanup-on-fail --timeout 30s
            '''
          }
        }
    }
}