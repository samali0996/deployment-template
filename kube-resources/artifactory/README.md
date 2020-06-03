helm repo add jfrog https://charts.jfrog.io

helm upgrade --install artifactory --namespace jenkins jfrog/artifactory-oss -f values.yaml