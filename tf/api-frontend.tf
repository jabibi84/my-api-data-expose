resource "null_resource" "build-api-gateway-config" {
 provisioner "local-exec" {
    command = "cd .. && URL_BACKEND=${google_cloud_run_service.my-service-backend.status[0].url} PROJECT_ID=${var.gcp_project_id} REGION=${var.gcp_region} make build-api-gateway-config"
  }
  depends_on = [google_project_service.run, google_cloud_run_service.my-service-backend]
}

resource "google_api_gateway_api" "my_api_cfg" {
  provider = google-beta
  api_id = "my-api-cfg"
  project = var.gcp_project_id
  depends_on=[google_cloud_run_service.my-service-backend, null_resource.build-api-gateway-config]
}

resource "google_api_gateway_api_config" "my_api_cfg" {
  provider = google-beta
  api = google_api_gateway_api.my_api_cfg.api_id
  api_config_id = "cfg"
  project = var.gcp_project_id

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = filebase64("../api-gateway/api.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on=[google_cloud_run_service.my-service-backend, null_resource.build-api-gateway-config]
}

resource "google_api_gateway_gateway" "my_api_gw" {
  provider = google-beta
  api_config = google_api_gateway_api_config.my_api_cfg.id
  gateway_id = "api-gw"
  project = var.gcp_project_id
  region = var.gcp_region
  depends_on=[google_cloud_run_service.my-service-backend, null_resource.build-api-gateway-config]
}

resource "null_resource" "enable-api-gateway" {
 provisioner "local-exec" {
    command = "cd .. && API_MANAGED_SERVICES=${google_api_gateway_api.my_api_cfg.managed_service} PROJECT_ID=${var.gcp_project_id} REGION=${var.gcp_region} make enable-api-gateway"
  }
  depends_on = [google_api_gateway_api.my_api_cfg,google_api_gateway_gateway.my_api_gw]
}
