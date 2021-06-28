resource "google_cloud_run_service" "my-service-backend" {
  name     = "my-service-backend"
  location = var.gcp_region
  template {
    spec {
      containers {
        image = var.api_app_image
      }
      service_account_name  = "493063605634-compute@developer.gserviceaccount.com"      
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }    
  depends_on = [google_project_service.run]
}
