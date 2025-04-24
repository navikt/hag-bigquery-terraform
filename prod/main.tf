terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.31.0, < 7.0.0"
    }
  }
  // For å lagre terraform state i google cloud storage
  backend "gcs" {
    bucket = "hag-bigquery-terraform-state-prod"
  }
}

provider "google" {
  project = var.gcp_project["project"]
  region  = var.gcp_project["region"]
}

data "google_project" "project" {}

module "google_storage_bucket" {
  source = "../modules/google-cloud-storage"

  name     = "hag-bigquery-terraform-state-prod"
  location = var.gcp_project["region"]
}
