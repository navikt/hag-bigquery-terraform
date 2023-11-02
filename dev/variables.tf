variable "gcp_project" {
  description = "GCP project and region defaults."
  type        = map(string)
  default = {
    region  = "europe-north1",
    zone    = "europe-north1-a",
    project = "helsearbeidsgiver-dev-6d06"
  }
}

variable "bro_db_cloud_sql_port" {
  description = "The port exposed by the helsearbeidsgiver-bro-sykepenger database Cloud SQL instance."
  type        = string
  default     = "5432"
}
