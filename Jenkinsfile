podTemplate(yaml:"""
spec:
  containers:
  - name: jnlp
  env:
  - name: ARTIFACTORY_URL
    valueFrom:
      configMapRef:
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
        // // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
        // def server = Artifactory.newServer url: "artifactory-artifactory:8081", username: 'user', password: ''
        // // Create an Artifactory Maven instance.
        // def rtMaven = Artifactory.newMavenBuild()
        // def buildInfo
        println"""
        URL: ${env.ARTIFACTORY_URL}
        """

        stage('Clone') {
            checkout scm
        }
    }
}