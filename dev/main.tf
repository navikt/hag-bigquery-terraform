terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
    }
  }
  // For å lagre terraform state i google cloud storage
  backend "gcs" {
    bucket = "hag-bigquery-terraform-state-dev"
  }
}

provider "google" {
  project = var.gcp_project["project"]
  region  = var.gcp_project["region"]
}

data "google_project" "project" {}

module "google_storage_bucket" {
  source = "../modules/google-cloud-storage"

  name     = "hag-bigquery-terraform-state-dev"
  location = var.gcp_project["region"]
}
