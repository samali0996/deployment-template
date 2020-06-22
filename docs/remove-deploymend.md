# To remove a application deployed on the cluster

List deployments using helm
```
 helm list -n <namespace> 
```

To uninstall
```
helm uninstall -n <namespace> <deploymentname>
```