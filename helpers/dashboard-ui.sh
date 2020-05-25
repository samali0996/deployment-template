#!/bin/bash
printf "Access Dashboard at:  http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/";echo;echo
printf $(kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') -o=jsonpath='{.data.token}' | base64 --decode);echo
kubectl proxy > /dev/null 2>&1