API_APP_VERSION=0.1.1
API_APP_IMAGE=gcr.io/$(PROJECT_ID)/my-api-backend:$(API_APP_VERSION)

gcp-enable-apis:
	gcloud services enable cloudresourcemanager.googleapis.com --project $(PROJECT_ID)
	gcloud services enable cloudbuild.googleapis.com --project $(PROJECT_ID)
	gcloud services enable apigateway.googleapis.com --project $(PROJECT_ID)
	gcloud services enable servicemanagement.googleapis.com --project $(PROJECT_ID)
	gcloud services enable servicecontrol.googleapis.com --project $(PROJECT_ID)

gcr-push-docker-image:
	(cd docker-image &&\
	gcloud builds submit ./ --tag $(API_APP_IMAGE) --project $(PROJECT_ID))

push-docker-image-local:
	(cd docker-image &&\
	docker image build . -t my-api-backend:$(API_APP_VERSION))

tf-init:
	(cd tf &&\
	terraform init) 

tf-plan:
	(cd tf &&\
	terraform plan -var='gcp_project_id=$(PROJECT_ID)' -var='gcp_region=$(REGION)' -var='api_app_image=$(API_APP_IMAGE)' -out=out.tfplan) 

tf-apply:
	(cd tf &&\
	terraform apply out.tfplan)  

tf-destroy:
	(cd tf &&\
	terraform destroy -var='gcp_project_id=$(PROJECT_ID)' -var='gcp_region=$(REGION)' -var='api_app_image=$(API_APP_IMAGE)') 

build-api-gateway-config:
	$(eval API_BACKEND_URL=$(URL_BACKEND))
	@echo API_BACKEND_URL: $(API_BACKEND_URL)
	$(eval PROJECT_ID=$(PROJECT_ID))
	@echo PROJECT_ID: $(PROJECT_ID)		
	@sed 's,API_BACKEND_URL,$(API_BACKEND_URL),g; s,PROJECT_ID,$(PROJECT_ID),g;' ./api-gateway/api.yaml.example > ./api-gateway/api.yaml

deploy-api-gateway:
	gcloud beta api-gateway api-configs create gateway-demo \
  	--api=gateway-demo --openapi-spec=api.yaml \
  	--project=$(PROJECT_ID)
	gcloud beta api-gateway gateways create gateway-demo \
  	--api=gateway-demo --api-config=gateway-demo \
  	--location=$(REGION) --project=$(PROJECT_ID)

get-gateway-url:	
	$(eval GATEWAY_URL=$(shell gcloud beta api-gateway gateways describe gateway-demo \
	--location=$(REGION) --project=$(PROJECT_ID) \
	--format=json|jq ".defaultHostname"))
	@echo https://$(GATEWAY_URL)

enable-api-gateway:
	gcloud services enable $(API_MANAGED_SERVICES) --project $(PROJECT_ID)