# Kubernetes App Deployment Project

Everything in [src/](src/) was copied from [Class Repo/kube-app/kubernetes](https://github.com/devopshydclub/vprofile-project/tree/kube-app/kubernetes)

## Steps

- Create a Kubernetes cluster with Kops on AWS
- Have a containerized app (see [../docker/containerize-project](../docker/containerize-project/))
- Create an EBS volume for persistent storage on database Pod
- Label nodes with the names of the Availability Zones that they're in
- K8s definition files

## EBS Volume

- You can create this with `awscli` like `aws ec2 create-volume --availability-zone=<zone> --size=<# in GB> --volume-type=<volume-type>`
- Make sure the database pod runs in the same zone as the EBS volume you just created
- Use `kubectl get node` and `kubectl describe node <node-name>` to figure out which worker node is in the same zone as the volume you created
- Use `kubectl label nodes <node-name> <key>=<value>` to give a node a label that is `<key>=<value>`, something like `zone=us-east-1`
- In AWS, give the volume a tag that is Key:Value `KubernetesCluster:<cluster-name>`
