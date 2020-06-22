# Microservice configuration

Configuration for applications deployed by `deployment-tools` are externalized as Kubernetes ConfigMap resources. These ConfigMaps are then exposed to the applications as volume mounts. Applications can share common configuration and/or have seperate configurations. 

Configuration updates can be independent from the application deployment pipeline, meaning configuration can be updated without retriggering CI/CD pipeline.

## Configuration used by applications
The following configuration files are defined in the Kubernetes cluster as a ConfigMap object. The ConfigMap object is then mounted to the application as a volume.

### SPRINGBOOT: application.yaml
Configuration used by the applications. Can include configuration such as server configuration, security configuation, bean configurations etc.

## Create new ConfigMap resource

This is to create a new ConfigMap resource and expose it to your application deployment as a volume mount. 

**Note: Adding new ConfigMap resources to your deployment requires you to trigger deployment pipeline**

Create the ConfigMap resource on your Kubernetes cluster
```
kubectl apply -f <path/to/configmap.yaml>
```
Inject the ConfigMap into your application deployment as a volume mount
```
path/to/helmchart/values.yaml
---
# define the ConfigMaps to be used in the deployment as volumes
volumes:
  - name: <volume-name>
    configMap:
      name: <config-map-name>

# mount the volumes into the pods of your deployment
volumeMounts:
  - name: <volume-name>
    mountPath: <path/of/mount>
```
Commit and push changes onto git repo to trigger deployment pipeline

### Example: Adding sample configuration for application

Create ConfigMap resource yaml file
```
<project-root>/deployment/configmap.yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: server-config
  namespace: dev
data:
  application.yaml: |-
    applicationConfig:
      topicName: email-topic
```
Apply the yaml file to create ConfigMap resource on Kubernetes cluster
```
kubectl apply -f <project-root>/deployment/configmap.yaml
```
Inject the ConfigMap into your application deployment as a volume mount
```
<project-root>/deployment/deployment-tools/values.yaml
---
# define the ConfigMaps to be used in the deployment as volumes
volumes:
  - name: config
    configMap:
      name: server-config

# mount the volumes into the pods of your deployment
volumeMounts:
  - name: config
    mountPath: /config
```
Commit and push changes onto git repo to trigger deployment pipeline, when the application is deployed onto Kubernetes the ConfigMap will be added into the application.


## Update existing ConfigMap resource

This is to update the configuration of a ConfigMap resource that you have already added to your application deployment. 

**Note: Updating existing ConfigMap resources does not require you to trigger deployment pipeline, Kubernetes will automatically inject new values to deployment pods**

- Ensure the ConfigMap you would like to update has already been added to your deployment as a mounted volume
- Edit the ConfigMap object by following one of the below methods:
  - `kubectl edit -n <namespace> cm <configmap-name>` in CLI
  - via Kubernetes UI
  - Edit ConfigMap object yaml file and then `kubectl apply -f <path/to/configmap.yaml>`

The Kubernetes cluster will automatically update deployed microservices which have mounted the ConfigMap as volumes with the new configuration files.

However, this doesn't mean that the runtime environment will already have the updated configuration files. You must restart the pods of the deployment to update the runtime to work with the new configuration files

```
kubectl rollout restart deployment <deployment-name> -n <namespace>
```

### Example: Updating existing ConfigMap with field-mapping.json file
Ensure the ConfigMap you would like to update has already been added to your deployment as a mounted volume
```
<project-root>/deployment/deployment-tools/values.yaml
---
volumes:
  - name: config
    configMap:
      name: server-config
      
volumeMounts:
  - name: config
    mountPath: /config
```
Edit the ConfigMap object
```
kubectl edit -n dev cm server-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: server-config
  namespace: dev
data:
  application.yaml: |-
    request-handler-ms:
      applicationConfig:
        topicName: email-topic
  
  # New configuration file to be added
  field-mapping.json: |-
    {
      "foo": "bar",
      "foo2": "bar2"
    }
```
Kuberenetes will automatically update the volume mounts of the deployments with the new configuration files. This update may take a few moments to take place.

Now we must restart the pods to update the application's runtime environment with new the configuration files we have added 

```
kubectl rollout restart deployment my-deployment -n dev
```