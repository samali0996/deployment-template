# Deployment Template

Deployment template is a tool that quickly sets up CI/CD integration with your Kubernetes cluster.

## Prerequisites 
- Install kubectl cli
- Provision a Kubernetes cluster
- Install `helm` cli
- Create access tokens for git repository and container registry


## Deploy Jenkins onto Cluster
1. Create a namespace to deploy your Jenkins release to
```
kubectl create namespace jenkins
```
2. Provision a persistent volume resource and a persistent volume claim resource so that the Jenkins service can have persistent data.
```
kubectl apply -f pv-volume.yaml
```
3. Provision the persistent volume claim for Jenkins
```
kubectl apply -f pv-claim.yaml 
```
4. Using `helm` and the values file in `jeknins/values.yaml`, deploy a release of the Jenkins chart onto your cluster
```
helm install jenkins stable/jenkins -f values.yaml --namespace jenkins
```
5. Access the Jenkins UI
```
. helpers/jenkins-ui.sh 
```

### Redeploy
```
helm upgrade -f jenkins/values.yaml jenkins stable/jenkins --namespace jenkins
```

## Set up Secrets and Config
1. Add Git repo access token
```
kubectl apply -f git-credentials.yaml
```
2. Add container registry access token
```
kubectl apply -f cr-credentials.yaml
```
3. Add container registry configuration
```
kubectl apply -f cr-configmap.yaml
```
## Deploy Kubernetes Dashboard (Optional)
1. Deploy the Kubernetes dashboard
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
```
2. Deploy the secrets required to access the dashboard
```
kubectl apply -f dashboard-adminuser.yaml
```
3. Access dashboard
```
. helpers/dashboard-ui.sh
```
- add git credentials as secrets
- add icr credentials as secrets
- k apply -f jenkins/icr-configmap.yaml  
