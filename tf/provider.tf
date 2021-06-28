terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = file("sa.json")
  project     = var.gcp_project_id
  region      = var.gcp_region
}
# enable cloud run api

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}