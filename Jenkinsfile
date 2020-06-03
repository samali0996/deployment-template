podTemplate(yaml:"""
spec:
  containers:
  - name: maven
    tty: true
    command: ["/bin/bash"]
    volumeMounts:
    - name: home-volume
      mountPath: /home/jenkins
    image: maven:3.6.3-jdk-8
    env:
    - name: ARTIFACTORY_URL
      valueFrom:
        configMapKeyRef:
          name: artifactory-config
          key: url
    - name: ARTIFACTORY_USERNAME
      valueFrom:
        secretKeyRef:
          name: artifactory-credentials
          key: username
    - name: ARTIFACTORY_PASSWORD
      valueFrom:
        secretKeyRef:
          name: artifactory-credentials
          key: password
  volumes:
  - name: home-volume
    emptyDir: {}
""") {
    node(POD_LABEL) {
        // create Artifactory server instance
        container('maven') {
          def server = Artifactory.newServer url: env.ARTIFACTORY_URL, username: env.ARTIFACTORY_USERNAME, password: env.ARTIFACTORY_PASSWORD
          // Create an Artifactory Maven instance.
          def rtMaven = Artifactory.newMavenBuild()
          def buildInfo
        }

        stage('Clone') {
          checkout scm
        }

        stage('Artifactory configuration') {
          sh"""
            env
          """
        }
    }
}