podTemplate(yaml:"""
spec:
  containers:
  - name: jnlp
    volumeMounts:
    - name: shared-volume
      mountPath: /usr/share/maven
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
  - name: maven
    tty: true
    command: ["/bin/bash"]
    volumeMounts:
    - name: shared-volume
      mountPath: /usr/share/maven
    image: maven:3.6.3-jdk-8
  volumes:
  - name: shared-volume
    emptyDir: {}
  
""") {
    node(POD_LABEL) {
        // create Artifactory server instance
        def server = Artifactory.newServer url: env.ARTIFACTORY_URL, username: env.ARTIFACTORY_USERNAME, password: env.ARTIFACTORY_PASSWORD
        // Create an Artifactory Maven instance.
        def rtMaven = Artifactory.newMavenBuild()
        def buildInfo

        stage('Clone') {
          checkout scm
        }

        stage('Artifactory configuration') {
          // Tool name from Jenkins configuration
          // rtMaven.tool = "Maven-3.3.9"
          env.MAVEN_HOME = '/usr/share/maven'
          // env.PATH = '${env.MAVEN_HOME}/bin:${env.PATH}'
          // Set Artifactory repositories for dependencies resolution and artifacts deployment.
          rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
          rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
          sh"""
            export PATH=/usr/share/maven/bin:$PATH
          """
        }

        stage('Maven build') {
          // buildInfo = rtMaven.run pom: 'maven-example/pom.xml', goals: 'clean install'
          sh"""
            ls /usr/share/maven/
            /usr/share/maven/bin/mvn --version
          """
        }

        stage('Publish build info') {
          // server.publishBuildInfo buildInfo
        }
    }
}