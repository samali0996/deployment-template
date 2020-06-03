podTemplate(yaml:"""
spec:
  containers:
  - name: jnlp
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
""") {
    node(POD_LABEL) {
        // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
        def server = Artifactory.newServer url: env.ARTIFACTORY_URL, username: env.ARTIFACTORY_USERNAME, password: env.ARTIFACTORY_PASSWORD
        // Create an Artifactory Maven instance.
        def rtMaven = Artifactory.newMavenBuild()
        def buildInfo

        stage('Clone') {
          checkout scm
        }
    }
}