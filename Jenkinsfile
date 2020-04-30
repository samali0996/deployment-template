podTemplate(
    yaml: """
apiVersion: v1
kind: Pod
spec:
    containers:
    - name: jnlp
      image: jenkins/jnlp-slave:3.27-1
      imagePullPolicy: IfNotPresent
      workingDir: /home/jenkins
      env:
       - name: JENKINS_URL
         value: http://jenkins.default.svc.cluster.local:8080
    - name: nodejs
      image: node:alpine
      imagePullPolicy: Always
"""
) {
    node(POD_LABEL) {
        container(jnlp) {
            stage('Build') {
                steps {
                    sh 'ls'
                }
            }
        }
    }
}