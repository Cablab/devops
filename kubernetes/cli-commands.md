# CLI Commands

## kubectl

[kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

- `kubectl get nodes` - lists kubernetes nodes that exist on system
- `kubectl get pod` - shows running pods
- `kubectl get deploy` - shows running deploys
- `kubectl get service` - shows info about running deploys
- `kubectl cluster-info` - shows cluster state
- `kubectl describe node <node-name>` - shows lots of info about a node
 
### Pods

- `kubectl get pod <pod-name> -o yaml` - prints the pod definition file in `yaml` format
- `kubectl describe pod <pod-name>` - shows info about the pod, including event logs
- `kubectl logs <pod-name>` - shows output logs of the process that is running on the container inside the pod
- `kubectl exec --stdin --tty <pod-name> -- <shell-path>` - logs into a pod
- `kubectl run <pod-name> --image=<image-name> --dry-run=client -o yaml > <local-file.yaml>` - this will just get you a Pod definition file

## minikube

- `minikube start` - starts a local VM for kubernetes
- `minikube stop` - turns off the local VM
- `minikube delete` - deletes the local VM
  - `--all` can be passed to fully clean the local environment of files
