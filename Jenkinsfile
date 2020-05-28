import org.jenkinsci.plugins.workflow.support.steps.build.RunWrapper
import java.text.SimpleDateFormat

//TODO: use configmaps
// use secrets
// fix helm release name, you need to add the branch instead of remove, when using override
// try taking out the repeat login and see if it still works
// add override name to image tag?
DEFAULT_BRANCH = "dev"
IMAGE_TAG_OVERRIDE = "c2129be-dev"
DOCKER_CONTEXT_OVERRIDE = "docker-apps/springboot/."
HELM_RELEASE_NAME_OVERRIDE = ""


def computeTimestamp(RunWrapper build) {
  def date = new Date(build.timeInMillis)
  return new SimpleDateFormat('yyyyMMdd-HHmmss').format(date)
}

def addBranchSuffix(name, branch) {
  def nameSuffix = branch == DEFAULT_BRANCH ? "" : "-${branch}"
  return "${name.toLowerCase()}${nameSuffix}"
}

def computeAppName(name, branch) {
  return name.toLowerCase().replaceAll("/${branch}", "")
}

def helmChartPath = "deployment/deployment-tools"
def dockerContext = DOCKER_CONTEXT_OVERRIDE ? DOCKER_CONTEXT_OVERRIDE : "."
def dockerfile = "${dockerContext}/Dockerfile"
def branch = env.BRANCH_NAME
def buildNumber = env.BUILD_NUMBER
def appName = computeAppName(env.JOB_NAME, branch)
def helmReleaseName = HELM_RELEASE_NAME_OVERRIDE ? addBranchSuffix("${HELM_RELEASE_NAME_OVERRIDE}", branch) : addBranchSuffix(appName, branch)
def timestamp = computeTimestamp(currentBuild)


println"""
App Name: ${appName}
Branch: ${branch}
Build Number: ${buildNumber}
Timestamp: ${timestamp}
Helm Release Name: ${helmReleaseName}
Image Tag Override: ${IMAGE_TAG_OVERRIDE}
Docker Context: ${dockerContext}
"""

podTemplate(yaml:"""
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
    - name: HELM_CHART_PATH
      value: ${helmChartPath}
    - name: HELM_RELEASE_NAME
      value: ${helmReleaseName}
    - name: IMAGE_TAG_OVERRIDE
      value: ${IMAGE_TAG_OVERRIDE}
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
      value: ${dockerfile}
    - name: CONTEXT
      value: ${dockerContext}
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

              APP_VERSION="${IMAGE_TAG_OVERRIDE:-$(git rev-parse --short HEAD)-$BRANCH}"

              REPOSITORY_URL="${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${APP_NAME}"
              APP_IMAGE="${REPOSITORY_URL}:${APP_VERSION}"

              echo "REPOSITORY_URL=$REPOSITORY_URL" >> ./env-config
              echo "APP_VERSION=$APP_VERSION" >> ./env-config
              echo "APP_IMAGE=$APP_IMAGE" >> ./env-config
              cat ./env-config

              git config --global user.email "${APP_NAME}@ci"
              git config --global user.name "Jenkins CI"
              git config --global credential.helper "!f() { echo username=\\$GIT_USERNAME; echo password=\\$GIT_PASSWORD; }; f"
              '''
          }
        }
        stage('Build Image') {
          try {
            container(name: 'buildah', shell: '/bin/bash') {
                sh '''#!/bin/bash
              set -e +x
              . ./env-config

              if [[ $CR_USERNAME && $CR_PASSWORD ]]
              then
                echo "Logging into registry $REGISTRY_URL"
                buildah login -u "$CR_USERNAME" -p "$CR_PASSWORD" "$REGISTRY_URL"
              fi

              echo "Attempt to pull existing image"

              buildah pull --tls-verify=false $REPOSITORY_URL:$APP_VERSION
              '''
            }
          }
          catch (exception) {
            container(name: 'buildah', shell: '/bin/bash') {
              sh '''#!/bin/bash
              set -e +x
              . ./env-config

              if [[ $CR_USERNAME && $CR_PASSWORD ]]
              then
                echo "Logging into registry $REGISTRY_URL"
                buildah login -u "$CR_USERNAME" -p "$CR_PASSWORD" "$REGISTRY_URL"
              fi

              echo "Building image $APP_IMAGE"

              buildah bud --format=docker -f "$DOCKERFILE" -t "$APP_IMAGE" "$CONTEXT"

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
              helm upgrade $HELM_RELEASE_NAME $HELM_CHART_PATH -f deployment/values_dev.yaml --install --namespace dev --atomic --cleanup-on-fail --timeout 45s \\
                --set image.repository=$REPOSITORY_URL \\
                --set image.tag=$APP_VERSION \\
                --set nameOverride=$HELM_RELEASE_NAME
            '''
          }
        }
    }
}