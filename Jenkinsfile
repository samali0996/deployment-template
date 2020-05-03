podTemplate(yaml:'''
spec:
  containers:
  - name: jnlp
    image: jenkins/jnlp-slave:4.0.1-1
    volumeMounts:
    - name: home-volume
      mountPath: /home/jenkins
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
          name: icr-config
    env:
    - name: HOME
      value: /home/jenkins
    - name: ICR_USERNAME
      valueFrom:
        secretKeyRef:
          name: icr-credentials
          key: username
    - name: ICR_PASSWORD
      valueFrom:
        secretKeyRef:
          name: icr-credentials
          key: password
    - name: APP_NAME
      value: deployment-template
    - name: DOCKERFILE
      value: ./Dockerfile
    - name: CONTEXT
      value: .
    - name: TLS_VERIFY
      value: "false"
  volumes:
  - name: home-volume
    emptyDir: {}
''') {
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
            git config --global credential.helper "!f() { echo username=\\$GIT_USERNAME; echo password=\\$GIT_PASSWORD; }; f"
            '''
        }
        container('buildah') {
          stage('Build Image') {
            sh '''#!/bin/bash
                set -e +x
                . ./env-config

                APP_IMAGE="${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${APP_NAME}:${APP_VERSION}"
                echo "Building image $APP_IMAGE"

                buildah bud --format=docker -f "$DOCKERFILE" -t "$APP_IMAGE" "$CONTEXT"

                if [[ $ICR_USERNAME && $ICR_PASSWORD ]]
                then
                  echo "Logging into registry $REGISTRY_URL"
                  buildah login -u "$ICR_USERNAME" -p "$ICR_PASSWORD" "$REGISTRY_URL"
                fi

                echo "Pushing image to the registry"
                buildah push "$APP_IMAGE" "docker://$APP_IMAGE"
                '''
          }
        }
    }
}