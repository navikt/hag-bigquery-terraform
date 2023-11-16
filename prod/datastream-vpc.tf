resource "google_compute_network" "hag_datastream_private_vpc" {
  name    = "hag-datastream-vpc"
  project = var.gcp_project["project"]
}
