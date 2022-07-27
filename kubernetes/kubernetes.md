# Kubernetes

[Kubernetes Docs](https://kubernetes.io/docs/home/)

- Kubernetes is a container orchestration tool
- Containers run on Docker Engine, so if the Engine goes down, all containers also go down. We can avoid this by having multiple Docker Engine nodes with the full container setup
- We also need a master node (**orchestrator** or **control plane**) to control the multiple Docker Engine nodes (**worker nodes**)

## Architecture

- **Master Node** / **Orchestrator** / **Control Plane** - contains API Server, Scheduler, Controller Manager, and etcd
  - Kube API Server - handles all requests and enables communication. Connect to it with Kubectl CLI
  - etcd server - Key value store, stores info of current state for entire cluster
  - Kube Scheduler - watches for new pods and selects a node to run on them based on factors that you can decide
  - Controller Manager - a collection of separate processes
    - Node Controller - monitors nodes
    - Replication Controller - maintain correct number of pods
    - Endpoints Controller - populates the Endpoints object (joins Services and Pods)
    - Service Account & Token Controllers - create default accounts and API access tokens for new namespace
- **Worker Node** - Kubelet, Proxy, Container Runtime
  - Kubelet - agent running on every node in cluster. Listens for master requests.
  - Kube Proxy - network proxy running on each node in the cluster
  - Container Runtime - some kind of container runtime environmen, like Docker Engine
  - Each node also will have its own private network so Pods on the Node can communicate with each other
  - Separate Nodes will be grouped by a wider **overlay** network so Pods on different Nodes can also communicate
- **Pods** - A pod provides physical resources for containers that are running in it
  - Pods should only have 1 main container running inside of them, but there can be sidecar/helper containers (like logging or monitoring agents)

## Local minikube Setup

We will install Minikube for a simple local setup on VM. Then we will use Kops for setup on AWS EC2 instances. Check out [Class Repo (kubernetes-setup)](https://github.com/devopshydclub/vprofile-project/tree/kubernetes-setup) for details about installation

[Minikube Getting Started Docs](https://minikube.sigs.k8s.io/docs/start/)

- [Local minikube VM setup commands](https://github.com/devopshydclub/vprofile-project/blob/kubernetes-setup/minikube/Minikube-commands.txt)
  - I had to install Docker Desktop and run `minikube start --vm-driver=docker` because VirtualBox was giving me so many problems...
- You can check `~/.kube/config` to see config info about the VM

*Note*: `minikube` is used to setup a local Kubernetes cluster, `kubectl` is the service used to configure the cluster by creating pods, services, etc.

## Kops for K8s Setup

### Prerequisites

- Owned Domain name and setup
  - Create NS records for subdomain pointing to Route53 hostzed zone NS servers
- Linux VM and setup (EC2 instance)
  - kops, kubectl, ssh keys, awscli
- AWS Account setup
  - S3 bucket, IAM user for awscli, Route53 hosted zone

### Route 53 and DNS Setup

- Go to Route 53 and `Create hosted zone`
- Give it a name that is `<subdomain-name>-<owned-domain>`
  - Something like `<project-name>.cab-dev.com`
- Make it public and create it
- Take the `NS` records that it creates and go to your DNS provided where you own the domain
- Create a Nameserver (NS) record for each NS record shown in Route53. The `Name` is the `<subdomain>` part of what you created in AWS. The `Value` is the provided NS route in Route 53
- Verify on any device with `nslookup -type=ns <subdomain>.<domain>`

### EC2 Instance Setup

- Generate an SSH key that will get pushed to all instances
- Install `awscli` and configure with the IAM user credentials using `aws configure`
- Use [Install Kubectl Docs](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) to install kubectl
- Use [Install Kubernetes with Kops Docs](https://kubernetes.io/docs/setup/production-environment/tools/kops/) to install kops on the instance

### Kubernetes Cluster Setup

- Run the `kops create cluster` command in [kopscreate.txt](resources/kopscreate.txt) to create a configuration for the cluster and store it in the S3 bucket you created
- Run the `kops update cluster` command in [kopscreate.txt](resources/kopscreate.txt) to use the config stored in the S3 bucket to create the cluster
- Run `kops validate cluster --state=s3://<bucket-name>` to 
- When ready, you'll find a file at `~/.kube/config` that `kubectl` uses to connect to the cluster
- Kops will also set up the following in your AWS account for you:
  - EC2 instances for the specified nodes
  - Auto-scaling groups, 1 for the orchestrator node, and 1 for each zone where there are worker nodes
  - A VPC
  - New DNS A records in your Route53 hosted zone
    - One for kops-controller
    - 1 pointing at master node public IP, 1 pointing at master node private IP

## Kubernetes Objects

- **Pod**: manages containers
- **Service**: does things like allow static endpoints to a service
- **Replica Set**: cluster of pods or replica of the same pod
- **Deployment**: similar to replica set. Can create new image tags with deployments
- **Config Map**: Stores variables and configurations
- **Secret**: Stores variables and secret info
- **Volumes**: storages volumes that can be attached to pods

## Kube Config

[Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)

- When you create a cluster, config info is stored at `~/.kube/config`. Some kinds of info are:
  - Clusters, Users, Namespaces, Auth mechanisms
- You can run `kubectl config view` to get a quick look (with secrets omitted) of your current context
- Once the `~/.kube/config` file has been created, you can copy it and place it on any machine or service (localhost, jenkins, etc.) and have access to the cluster through `kubectl` since kubectl uses that file for authentication/access to the cluster

## Namespaces

[Namespaces Docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

[Classroom Guide Commands](resources/namespaces.txt)

- Namespaces are a way to isolate groups of resources within a single cluster
- Use `kubectl get all` to see all objects in the default namespace
  - pass `--all-namespaces` flag to see all objects in all namespaces
  - pass `-n <namespace>` to see all in the specified namespace
- `default` is the default namespace where objects you create will go. Kops uses `kube-system` namespace for control plane resources and objects (it sets up the master node with lots of services, each in their own pod)
- Create a new namespace with `kubectl create namespace <name>`
- Create pods inside of a namespace with a `yaml` file (see [resources/pod-example.yaml](resources/pod-example.yaml) for an example) by running `kubectl apply -f <yaml-file>`

## Pods

- Pods are the smallest, most basic unit in Kubernetes. They represent a process running in the cluster. A container runs inside of a pod
- Pods are like a wrapper around containers. Kubernetes manages the pods
- You can have multiple containers in a pod, but they should be supporters to the main process container, not separate processes. Only 1 process per pod
  - For scalability, you create more pods. You do not add more containers into a pod
- Define pods with `yaml` definition files (see [resources/pod-example.yaml](resources/pod-example.yaml)
- Create pods from a definition file with `kubectl apply -f <yaml-file>`
- If you're creating a pod with a default image, you can use `kubectl run <pod-name> --image=<default-container-image-name>`

## Service

- **Service** is a way of exposing an application running on a set of **pods** as a network service that can be accessed. It's kind of similar to a load balancer
- Since Pods are dynamic and get created/destroyed a lot, **Service** provides a static endpoint behind which the relevant pods can change
  - For example, a static MySQL Service endpoint that other Pods can hit, even if the Pods actually running the MySQL process keep changing
- Make a service definition `yaml` file and create it with `kubectl create -f <service-file.yaml>`

### NodePort

- **NodePort**: similar to port mapping, just mapping a host port to a service port. Mostly used for non-production scenarios. Exposes the service port to outside networks
- Requires a publicly visible (external-facing) `nodePort`, an internal frontend (receiver) `port`, and an internal backend (forwarding) `targetPort`
- Also requires a `selector` object to be defined as a key-value pair. Pods where the NodePort is forwarding requests should have a `label` that matches the key-value pair in the `selector`
- The NodePort forwards requests to any pods matching the `selector` on the `targetPort`
- See an example in [definitions/app](definitions/app/)

### LoadBalancer

- **LoadBalancer**: expose to outside networks for production use-cases
- Automatically generates a `nodePort` without having to specify one, uses a range of ports starting at 30000
- Receives requests from the external network and forwards them to the appropriate pod
- The NodePort forwards requests to any pods matching the `selector` on the `targetPort`
- See an example in [definitions/app](definitions/app/)

### ClusterIP

- **ClusterIP**: exposes services internally for communication between services

## Replica Set

- ReplicaSet is kind of like an auto-scaling group. It will automatically keep a specified number of identical pods available and splay them across the worker nodes. This is nice even if you only have 1 pod because a ReplicaSet can automatically spin up a new Pod if the one that's running dies
- In a ReplicatSet definition `yaml` file, the `spec.selector.matchLabels` must have a key-value pair that matches a key-value pair in `spec.template.metadata.labels`. This is how it knows which pods to count as part of the ReplicaSet
- Define a ReplicaSet in a `yaml` file and create it with `kubectl create -f <replica-set.yaml>`
- If you want to update a ReplicaSet, modify the file and run `kubectl apply -f <replica-set.yaml>`
- See [resources/replicaset-example.yaml](resources/replicaset-example.yaml) for an example

## Deployment

- Deployment objects allow you to upgrade, rollback, and make changes gracefully
- Deployment is a declarative definition `yaml` file that manages ReplicaSets and Pods
- You can specify a **desired state** in a Deployment and the Deployment controller will roll out the new state at a controlled rate
- Create a deployment by making a definition file and running `kubectl apply -f <deployment.yaml>`
- To update a deployment (like updating an image version), edit the definition file and then run `kubectl apply -f <deployment.yaml>` again
  - You can check the rollout status with `kubectl rollout status deployment/<deployment-name>`
- Applying a change to a Deployment will create a new ReplicaSet, spin it up, and then phase out the old one
- You can revert to the previous Deployment (old ReplicaSet) with `kubectl rollout undo deployment/<deployment-name>`
  - If you want to revert to a specific Deployment, search for the one you want with `kubectl rollout history deployment/<deployment-name>` and then pass the REVISION numbers into `kubectl rollout history deployment/<deployment-name> --revision=X` to get specific data and see which one you wanted
  - Once you find the one you want, use `kubectl rollout undo deployment/<deployment-name> --revision=X` to go back to that specific version

## Commands & Arguments

- You can tell a Pod to run a command and pass it arguments when it comes up with the `command` and `args` objects in the definition file. See [resources/pod-example.yaml](resources/pod-example.yaml) for an example
- However, if a Pod is given a simple command to run, it will run the command and then terminate since it wasn't told to stay up and running. It finished its job, and it terminates

## Volumes

- You can attach volumes to a Pod. See [Kubernetes Volumes Docs](https://kubernetes.io/docs/concepts/storage/volumes/) for examples of how to attach many different kinds of volumes
- Normally you want to make a good, persistent storage, but for testing purposes you can also mount a directory on the Kubernetes worker node as a volume on the Pod ([Local Volume Docs](https://kubernetes.io/docs/concepts/storage/volumes/#local)). This is not recommended for production

## Config Map and Environment Variables

[ConfigMap Docs](https://kubernetes.io/docs/concepts/configuration/configmap/)

- You can define variables in a ConfigMap and then use the variables in a Pod definition file
- The ConfigMap defintion file just lists the variable names and values in the `.data` object. See [resources/configmap-example.yaml](resources/configmap-example.yaml) for an example
- With the defintion file, run `kubectl apply -f <configmap.yaml>` to put it in the cluster
- Once the config map is created, reference the variables in a Pod definition file with the following setup (see [resources/configpod-example.yaml](resources/configpod-example.yaml)):
  - `.spec.containers[].env[].name` is the ENV name that will be set into the POD
  - `.spec.containers[].env[].valueFrom.configMapKeyRef.name` is the name of the ConfigMap that was created
  - `.spec.containers[].env[].valueFrom.configMapKeyRef.key` is the key of the variable defined in the `.data` section of the references ConfigMap that you want to get the value of

## Secrets

[Secrets Docs](https://kubernetes.io/docs/concepts/configuration/secret/)

- Config maps are great, but we still don't want to store passwords and credentials in plaintext. This is where secrets come in
- There are more secure encryption methods, but for this course we're just showing basic obfuscation because it's at least best practice
- Whatever secrets you need to store, run them through `echo -n "<plaintext-secret>" | base64` to get base64 encoded text
  - You can reverse this with `echo -n "<base64-encoded> | base64 -d`
- Store the base64 encoded secrets in a Secret definition file (see [resources/secret-example.yaml](resources/secret-example.yaml)) and create the Secret in the cluster with `kubectl create -f <secret.yaml>`
- In a Pod definition file, reference the Secret file in the `.spec.containers[].env[]` object (see [resources/secretpod-example.yaml](resources/secretpod-example.yaml))

*Note*: A popular use of Secrets is to set Docker Hub credentials as a Secret to allow pulling Docker images from a private repository. See [Pull Private Images Guide](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) for a guide on that

## Ingress

[Ingress Docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)

- Ingress is an API object that manages external access to the sevices in a cluster (typically HTTP)
- You'll have to install an [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/), so make sure you choose the one that fits your architecture and install it properly. We'll use [ingress-nginx for AWS](https://kubernetes.github.io/ingress-nginx/deploy/#aws)
- Installing `ingress-nginx` will create a namespace of the same name. You can see what all it spins up with `kubectl get all -n ingress-nginx`

### Ingress Setup

Once you've installed the Ingress Controller, here are all the steps you need to take to actually set it up:

- Create a Deployment definition for your service (see [definitions/app/vproapp-deployment.yaml](definitions/app/vproapp-deployment.yaml))
- Create a ClusterIP Service definition for your service (see [definitions/app/vproapp-clusterip.yaml](definitions/app/vproapp-clusterip.yaml))
- Create a CNAME record in your DNS provider mapping some subdomain to the DNS name of the Load Balancer that was created in AWS by ingress-nginx
- Create an Ingress definition for your service targeting the `name` used in the Deployment and the `host` being the `<subdomain>.<domain>` you setup with your DNS provider
- Apply all the definition files with `kubectl apply -f <file.yaml>`

## Taints and Tolerations

[Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

- **Node affinity** is a propery of Pods that attracts them to certain nodes
- You can **taint** a Kubernetes worker node with a certain value
- Pods will only get put onto tainted nodes when a Pod has a **toleration** that matches the node's **taint**

## Request and Limit

[Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

- Pods can request the amount of physical resources they require to run
- Pods can also set a limit to how much of a certain resource they're allowed to use

## Jobs and CronJobs

[Jobs Docs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)

[CronJob Docs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

- Jobs are a kind of Pod that will run when executed, execute the given commands, and terminate
- A CronJob will define a Job that will run and a schedule of when it will run

## DaemonSet 

[DaemonSet Docs](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

- A **DaemonSet** is a type of object that's similar to a Deployment, but it specifically makes sure that a certain Pod exists on every single worker node in the cluster
- These are usually for monitoring or log gathering

## Lens

- [Lens](https://k8slens.dev/) is a GUI that can explore your Kubernetes cluster, including logs, monitoring, graphs, etc.
- You can add your Kubernetes cluster into Lens just by adding your `~/.kube/config` file
