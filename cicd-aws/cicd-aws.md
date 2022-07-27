# AWS CI/CD Project

**AWS CI/CD Pipline**

- Source Code Management (SCM): GitHub => AWS CodeCommit 
- Code Review: SonarQube => AWS CodeBuild
- Code Build: Jenkins => AWS CodeBuild
- Artifact Storage: Nexus => AWS S3
- Artifact Deploy: ??? => AWS Deploy
- Pipeline Management: Maven/Jenkins => AWS Pipeline

## Beanstalk Setup

Also see [vprofile-cloud/refactor.md#Beanstalk](../vprofile-cloud/refactor.md#beanstalk)

- Setup a tomcat java beanstalk application for this project
- Make sure that security group can only allow SSH from you

## RDS Setup

- Create a MySQL RDS database 
- Make sure that security group allows MySQL TCP:3306 from the Beanstalk security group
- Log into one of the beanstalk instances (or create a new instance in the same VPC and log into that) and do the following to setup the database:
  - `install git mysql -y`
  - Clone the source code from the course `git clone https://github.com/devopshydclub/vprofile-repo.git`
  - CD into the repo and change to the `vp-rem` branch
  - Test RDS connectivity with `mysql -h <RDS-endpoint> -u <username> -p<pass> <database-name>`
  - If you can get in, run the backup script by adding `< <path-to-backup-script` to the end of the command you ran to test connection

## App Setup

- Build the artifact on your localhost
  - Clone the course repo `git clone https://github.com/devopshydclub/vprofile-repo.git` and switch to the `vp-rem` branch
  - Edit the `src/main/resources/application.properties` file to have the correct info for your deployed AWS services
  - Run `mvn install` in the base repo directory to build the artifact
  - Go to Beanstalk > Application versions > Upload and create a new version by uploading the artifact you just built
  - Before deploying the new version, go to `Configuration` on the Beanstalk Envrionment, edit the Load Balancer, selected the default `Processes` listing, edit that, and then change the health check endpoint to `/login` (for Tomcat) and check the `Enable Stickiness` box
  - Go back to Application versions and select the new Beanstalk application version > Actions > Deploy > choose beanstalk environments to deploy it to

## Code Commit

- Go to Code Commit Service > Repositories > Create Repository
- Create an IAM Policy and IAM User that has full admin access to Code Commit, but only specifically for this one repo
- Create a local SSH key and upload it to the user's Security Credentials section
- On your local host, add the following block to `~/.ssh/config` so that SSHing to CodeCommit from your local host will use the credentials you just set up for the new IAM user

```txt
Host git-codecommit.*.amazonaws.com
    USER <SSH key ID from IAM User Security Credentials>
    IdentityFile <path to IAM User's SSH key>
```

- Test your verification with `ssh git-codecommit.<aws-region>.amazonaws.com`

### Migration from GitHub to CodeCommit

- CD into a local repository that you want to migrate
- Run `git branch -a` to see all branches, use bash commands to trim it down so that it's just a list of the branch names only (excluding HEAD)
- Loop over the list of branch names and check out each one so that your local repo has record of it
- Use `git fetch --tags` to also pull down local record of all tags
- Remove the remote origin that's pointing at GitHub with `git remote rm origin` (you can see the value of this in `.git/config` file in the repo)
- Add the new origin URL with `git remote add origin <SSH-URL-for-new-CodeCommit-repo>`
- Push all branches into CodeCommit with `git push origin --all`
- Push all tags into CodeCommit with `git push --tags`

## Build Artifact from CodeCommit Repo Source Code

- Go to CodeCommit > Build > Build Projects > Create build project
- Choose a name for the project and whatever has your source code
- In Environment, you can choose a managed image or a custom Docker image
- Create or choose a Service Role that will store the build artifact
- For `Buildspec`, you can insert build commands if they're simple. Otherwise, you can use a buildspec file that you've prewritten and upload it (see [buildspec.yaml](buildspec.yaml) for an example on this project)
- In `Artifacts`, choose an S3 bucket where the artifacts will get stored
- Make sure you set CloudWatch Log Group and Stream so we can see logs of what happens during the build job, otherwise we won't see what went wrong if there are issues
- Once you've made a Build Project, you can click `Build` to manually trigger a build
- During a build execution, you can look at different tabs to see how the build is going

## Build, Deploy, and Code Pipeline

- Go to CodeCommit > Pipeline > Pipelines > Create Pipeline
- Populate all settings with what has been created up until now:
  - S3 Bucket where artifacts are stored
  - AWS CodeCommit repo branch (triggered on CloudWatch Events)
  - AWS CodeBuild job to run the build
  - Deploy to AWS Beanstalk Application and Environment that were created
- Once the Pipeline has been created, you can click on the `Edit` button and add additional steps anywhere in the pipeline
