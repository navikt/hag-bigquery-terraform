variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default = {
    region  = "europe-north1",
    zone    = "europe-north1-a",
    project = "helsearbeidsgiver-prod-8a1c"
  }
}

variable "bro_db_cloud_sql_port" {
  description = "The port exposed by the helsearbeidsgiver-bro-sykepenger database Cloud SQL instance."
  type        = string
  default     = "5432"
}

variable "spinosaurus_db_cloud_sql_port" {
  description = "The port exposed by the spinosaurus database Cloud SQL instance."
  type        = string
  default     = "5433"
}

variable "simba_db_cloud_sql_port" {
  description = "The port exposed by the im-db (simba) database Cloud SQL instance."
  type        = string
  default     = "5434"
}

variable "flytt_spinosaurus_service_user" {
  description = "The service account used by the flytt-spinosaurus Cloud Function."
  type        = string
}

locals {
  flytt_spinosaurus_service_user = "serviceAccount:${var.flytt_spinosaurus_service_user}"
}
