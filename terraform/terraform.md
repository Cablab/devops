# Terraform

- Terraform is Infrastructure as a Code (IaaC)
- Terraform automates infrastructure itself and manages its state 

## Exercise 1 - Create EC2 Instance

[first_instance.tf](exercises/exercise1/first_instance.tf)

## Exercise 2 - Variables

[exercise2/](exercises/exercise2/)

## Exercise 3 - Provisioners

[exercise3/](exercises/exercise3/)

- You can configure Terraform to SSH onto a resource that's created and do things there (like copy files or run commands)
- This is specified in a `provisioner` Terraform object
  - Types are like `file` (copy files or directories), `remote-exec` (run commands on remote resource), and `local-exec` (invoke a local executable after the resource is created)
  - Others include `puppet`, `chef`, 
- You must provide credentials so Terraform has access to the instance
  - Easiest way is to SSH with access keys, so you can create a keypair locally and then reference them in your terraform

## Exercise 4 - Output

[exercise4/](exercises/exercise4/)

## Exercise 5 - Backend

[exercise5/](exercises/exercise5/)

- Terraform keeps track of the infrastructure state locally with the `terraform.tfstate` file that it generates
- This can be a problem for teams that are working on the same infrastructure since the tracking needs to be available to everyone and not local to 1 machine
- The easiest thing to do is to tell Terraform to store the `terraform.tfstate` file in an S3 bucket that everyone has access to

## Exercise 6 - Multi Resource

[exercise6/](exercises/exercise6/)

## Terraform Commands

- `terraform init` - checks provider, downloads necessary plugins in working directory
  - This will create a `.terraform` and `.terraform.lock.hcl` directory where run
- `terraform validate` - checks to see if the terraform file in the directory is valid
- `terraform fmt` - formats terraform files in the directory
- `terraform plan` - doesn't make changes, but shows what actions Terraform will take
- `terraform apply` - make the changes
- `terraform destroy` - destroyes the resources defined in terraform files

## Generated Files

- **terraform.tfstate** - maintains the current state of your resources
- **terraform.tfstate.backup** - 
- **.terraform.lock.hcl** - 
