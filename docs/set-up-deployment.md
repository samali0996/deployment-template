# Deploying new microservice to Kubernetes cluster

The following documents the process of deploying a service to the Kubernetes cluster via the CI/CD pipeline

## Step One: Add the DevOps resources to the project repo
You need to add the relevant DevOps files to your project repo to be able to deploy using the pipeline:
- `deployment`: directory that will deploy the service to Kubernetes using helm
- `Jenkinsfile`: CI/CD Pipeline file for Jenkins
- `Dockerfile`: Used to build image of service

## Step Two: Add the project repo to Jenkins
Once the repo is ready to be added to the cluster, we need to set up jenkins to deploy it
- Go to the jenkins UI and login
- Click on new item
  - Enter item name
  - select Multibranch Pipeline
  - Click OK
- Under Branch Sources:
  - Open drop-down menu `Add Source`
  - Select Git
  - Add repo URL under `Project Repository`
  - Select existing credentials or
    - Create credentials for pipeline
      - Click add
      - Select pipeline name as scope
      - Generate Deploy Token
        - Go to GitLab Repo in a seperate tab
        - Settings -> Repository -> Deploy Tokens
        - Enter name and select `read_repository` for scope
        - Click `Create deploy token`
      - Enter Username and Password that you have generated
      - Click Add
    - Select the credentials you have just added
  - Click Save

Jenkins will then scan your Repo for any branches with a valid Jenkinsfile, which will then trigger the pipeline for those branches

## Step Three: Add webhooks to automatically trigger builds when pushing to remote repo
- On Jenkins
  - Click on `admin` on top right of page
  - Click Configure
  - Under API Token
    - Click `Add new token`
    - Click `Generate`
    - Copy Value
- Go to GitLab repo for your project on a seperate tab
- Settings --> Integrations
- Paste token you have generated for `Secret Token`
- To get Jenkins webhook URL
  - Go to Jenkins in a seperate tab
  - Click on the pipeline you want to add the webhook to
  - Click on a branch
  - Click View Configuration
  - Copy URL found under Build Triggers (NOTE: make sure to exclude the branch name at the end of the URL so that pushes to any branch trigger build)
- Paste the URL
- Click Add webhook
- Click `Test --> Push events` for the webhook you have just created to validate webhook is working