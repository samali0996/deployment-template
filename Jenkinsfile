podTemplate(yaml:'''
metadata:
  namespace: jenkins
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
  - name: kube-tools
    image: dtzar/helm-kubectl:3.2.0
    tty: true
    volumeMounts:
    - name: home-volume
      mountPath: /home/jenkins
    env:
    - name: HOME
      value: /home/jenkins
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
      value: deployment-template
    - name: DOCKERFILE
      value: ./Dockerfile
    - name: CONTEXT
      value: .
    - name: TLS_VERIFY
      value: "false"
    - name: PERFORM_REGISTRY_PUSH
      value: "false"
  volumes:
  - name: home-volume
    emptyDir: {}
''') {
    node(POD_LABEL) {
      //Explicily call the jnlp container
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

                if [[ $CR_USERNAME && $CR_PASSWORD ]]
                then
                  echo "Logging into registry $REGISTRY_URL"
                  buildah login -u "$CR_USERNAME" -p "$CR_PASSWORD" "$REGISTRY_URL"
                fi

                if $PERFORM_REGISTRY_PUSH
                then
                echo "Pushing image to the registry"
                buildah --tls-verify=$TLS_VERIFY push "$APP_IMAGE" "docker://$APP_IMAGE"
                fi
                '''
          }
        }
      stage ("Deploy to dev") {
        sh '''#!/bin/bash
          set -e
          . ./env-config

        '''
      }
    }
}