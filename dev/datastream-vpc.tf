resource "google_compute_network" "hag_datastream_private_vpc" {
  name    = "hag-datastream-vpc"
  project = var.gcp_project["project"]
}

// The IP-range in the VPC used for the Datastream VPC peering. If a Cloud SQL instance is assigned a private
// IP address, this is the range it will be assigned from.
resource "google_compute_global_address" "hag_datastream_vpc_ip_range" {
  name          = "hag-datastream-vpc-ip-range"
  project       = var.gcp_project["project"]
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  network       = google_compute_network.hag_datastream_private_vpc.id
  prefix_length = 20
}
