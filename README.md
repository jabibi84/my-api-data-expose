# Technical Assessment

This repository contain the architecture needed to expose the results. 

# Problem Statement

Our company would like to assess its capabilities to consume and run analyses on large
datasets and make the results available for consumption to end users. For this assessment, we
will be using publicly available data for New York Taxi trips during 2016 (Yellow Cabs only).

This dataset contains information about every single trip completed by cabs within New York
City, and includes data points such as the pick-up and drop off location, pick-up and drop off
date and time, trip fare, number of passengers, etc.

The dataset is available for download from the following location. Please note this data is large
and averages around 1.6 GB for each month.

## Prerequisites

* Download and configure Terraform >= 0.12
* Setup Cloud SDK, or use Cloud Shell.
* Create a Google Cloud Platform (GCP) project, or use an existing one.
* Enable the Cloud Run API.
* Enable the Container Registry API.
* Install and configure Docker Desktop (Optional just to local test)

## Set Environment variables to Project and Region
Set env variables for the gcp project id and the region
```
PROJECT_ID=my-project-id
REGION=europe-west1

export COMPOSE_DOCKER_CLI_BUILD=0
export DOCKER_BUILDKIT=0
```

## Setup gcloud
Authenticate
```
gcloud auth login
```
Create a new gcp project (choose a unique PROJECT_ID)
```
gcloud projects create $PROJECT_ID
```
Set new project as default
``` 
gcloud config set project $PROJECT_ID
```
Create a service account
```
SERVICE_ACCOUNT=deployer
gcloud iam service-accounts create $SERVICE_ACCOUNT \
--project $PROJECT_ID
```
Grant admin role to the service account (clearly more than is actually here, we could narrow it down)
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
--role=roles/admin \
--project $PROJECT_ID
```
Create Service Account keys
```
gcloud iam service-accounts keys create tf/sa.json \
--iam-account $SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
--project $PROJECT_ID
```
Enable APIS
```
PROJECT_ID=$PROJECT_ID make gcp-enable-apis
```

## Build/Push containers
Build/Push backend service container
```
PROJECT_ID=$PROJECT_ID make gcr-push-docker-image
```


## Terraform setup
Init
```
make tf-init
```

## Terraform deploy
Plan
```
PROJECT_ID=$PROJECT_ID REGION=$REGION  make tf-plan
```
Apply
```
make tf-apply
```
destroy
```
PROJECT_ID=$PROJECT_ID REGION=$REGION make tf-destroy
```


/*estas son mis notas*/

Build local image  
docker image build . -t my-api-backend:0.1.1

run container local imagen 
docker run -d -e PORT=8080 -p8080:8080 my-api-backend:0.1.1 



1. Loging to GCP
gcloud auth login

2. Set env variables for the gcp project id and the region
PROJECT_ID=groovy-vector-317916
REGION=us-central1

3. Create a new gcp project (choose a unique PROJECT_ID)
gcloud projects create $PROJECT_ID

4. Set new project as default 
gcloud config set project $PROJECT_ID

4. Create a service account
SERVICE_ACCOUNT=deployer
gcloud iam service-accounts create $SERVICE_ACCOUNT \
--project $PROJECT_ID

5. Grant admin role to the service account (clearly more than is actually here, we could narrow it down)
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
--role=roles/admin \
--project $PROJECT_ID

6. Create Service Account keys
gcloud iam service-accounts keys create tf/sa.json \
--iam-account $SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
--project $PROJECT_ID

7. Enable APIS
PROJECT_ID=$PROJECT_ID make gcp-enable-apis


8. Deploy Docker image
PROJECT_ID=$PROJECT_ID make gcr-push-docker-image

9. Initializete terraform environment 
make tf-init 

10. Run terraform plan 
PROJECT_ID=$PROJECT_ID REGION=$REGION make tf-plan

11. Run terraform apply to apply changes reported in plan file.  
PROJECT_ID=$PROJECT_ID REGION=$REGION make tf-apply

12. Run terraform destroy 
PROJECT_ID=$PROJECT_ID REGION=$REGION make tf-destroy

13. once deploy backend container it wont be accessible public so run it to test. 

curl -H \
"Authorization: Bearer $(gcloud auth print-identity-token)" \
https://second-test-rqgdhs4h7q-uc.a.run.app


14. Create api-getaway configuration
URL_BACKEND=https://my-service-backend-2emf4umsba-uc.a.run.app PROJECT_ID=$PROJECT_ID REGION=$REGION make build-api-gateway-config

Deploy the gateway

PROJECT_ID=$PROJECT_ID REGION=$REGION make deploy-api-gateway
Get gateway url

PROJECT_ID=$PROJECT_ID REGION=$REGION make get-gateway-url

 go to APIS and Services and enabled recently deploy getaway 
find by api_id
