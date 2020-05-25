#!/bin/bash
POD_NAME=$(kubectl get pods --namespace jenkins -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=jenkins" -o jsonpath="{.items[0].metadata.name}")
printf $(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
kubectl --namespace jenkins port-forward $POD_NAME 8080:8080 > /dev/null 2>&1
