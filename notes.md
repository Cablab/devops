# Notes

DevOps covers **Continuous Integration** and **Continuous Delivery** (**CI/CD**)

## Continuous Integration

Code is automatically built and tested each time a commit happens. This makes it so that errors are detected earlier and can be fixed pretty quickly instead of waiting until the end of the development sprint/cycle to detect all errors. The goal is to detect errors early so they don't multiply.

**Artifact**: AKA Build Artifact. A built and tested version of the codebase that could be put into a live environment. Can be in various formats depending on the OS, like .jar, .zip, .rar, .msi, .exe, etc.

## Continuous Delivery

Automate various manual steps in deployment:
  - Server provisioning
  - Dependency upgrades
  - Configuration changes
  - Network changes
  - Artifact deployment

## Tools and Technology Prereqs

[Course GitHub Repo with Resources](https://github.com/devopshydclub/vprofile-project/tree/master)

### Software Installed for Course

**Oracle VM VirtualBox**
- `choco install virtualbox`

**Git Bash**
- Already installed

**Vagrant**
- `choco install vagrant`

**Chocolatey**
- Already installed, upgraded with `choco upgrade chocolatey`

**JDK8**
- `choco install jdk8`

**Maven**
- `choco install maven`

**AWS CLI**
- `choco install awscli`

**Domain Purchase**
- Using GoDaddy.com, purchased cab-dev.com

**Docker Hub**
- Host Docker images
- Sign up for account

**SonarCloud**
- Sign up using GitHub account
- Create unique organization and project with free tier

### AWS Account Setup

**IAM with MFA**

- Go to IAM service in AWS account
- Click `Users` and `Add User`
- Create IAM user with `AccountAdmin` permissions
- Create a good password and save access keys and information

**Create Billing Alarms**

- Go to CloudWatch service
- Go to `All Alarms` and choose `Create Alarm`
- With `Select Metric`, go to `Billing` group
  - If you cannot see the `Billing` group, you need to log into the account as the root user and enable `Get Billing Notifications` in `Account Preferences > Billing Dashboard`
  - May also need to follow steps in [Activating IAM access](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1) and [Granting Permissions](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step2)
  - Apparently `Billing` is only in region `us-east-1`, so change to that to setup the alarm
- Choose `Total Estimated Charge`, select the currency, and then click `Set Metric` in the bottom right
- In the `Configure Actions` screen, do:
  - Click `Add Notification`, select `In Alarm`, and choose the topic (email) where you want to receive the alerts (or create a new topic if you need to)
- Create the alarm and confirm in your email that you meant to subscribe to that

**Certificate Setup**

- Go to `ACM` service (AWS Certificate Manager)
- `Request a Certificate` > Choose a Public certificate
- Add the FQDN of a domain you own into the box
  - You can enable the cert on subdomains by adding `*.` wildcard to the beginning.
  - For example: setting up cert on `testing.com`, you could do `*.testing.com` for subdomains
- Use DNS validation
- Click into the (now pending) cert and you should see `CNAME name` and `CNAME value` fields. You need to create a DNS record on your domain with these values so AWS can verify the cert
- Cert verification can take up to 48 hours
