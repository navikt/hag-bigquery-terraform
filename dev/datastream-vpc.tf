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

// Private connectivity lets you create a peered configuration between your VPC and Datastream’s private network.
// A single configuration can be used by all streams and connection profiles within a single region.
resource "google_datastream_private_connection" "hag_datastream_private_connection" {
  location              = var.gcp_project["region"]
  display_name          = "hag-datastream-private-connection"
  private_connection_id = "hag-datastream-private-connection"

  vpc_peering_config {
    vpc    = google_compute_network.hag_datastream_private_vpc.id
    subnet = "10.1.0.0/29"
  }
}


// VPC Firewall rules control incoming or outgoing traffic to an instance. By default, incoming traffic from outside
// your network is blocked. Since we are using a Cloud SQL reverse proxy, we need to then create an ingress firewall
// rule that allows traffic on the source database port.
resource "google_compute_firewall" "allow_datastream_to_cloud_sql" {
  project = var.gcp_project["project"]
  name    = "allow-datastream-to-cloud-sql"
  network = google_compute_network.hag_datastream_private_vpc.name

  allow {
    protocol = "tcp"
    ports = [
      var.bro_db_cloud_sql_port,
    ]
  }

  source_ranges = [google_datastream_private_connection.hag_datastream_private_connection.vpc_peering_config.0.subnet]
}


data "google_sql_database_instance" "bro_db" {
  name = "helsearbeidsgiver-bro-sykepenger"
}

locals {
  proxy_instances = [
    "${data.google_sql_database_instance.bro_db.connection_name}=tcp:0.0.0.0:${var.bro_db_cloud_sql_port}",
  ]
}

// This module handles the generation of metadata used to create an instance used to host containers on GCE.
// The module itself does not launch an instance or managed instance group.
module "cloud_sql_auth_proxy_container_datastream" {
  source         = "terraform-google-modules/container-vm/google"
  version        = "3.1.0"
  cos_image_name = "cos-stable-101-17162-127-8"
  container = {
    image   = "eu.gcr.io/cloudsql-docker/gce-proxy:1.33.2"
    command = ["/cloud_sql_proxy"]
    args = [
      "-instances=${join(",", local.proxy_instances)}",
      "-ip_address_types=PRIVATE"
    ]
  }
  restart_policy = "Always"
}

// Create a VM used to host the Cloud SQL reverse proxy.
resource "google_compute_instance" "hag_datastream_cloud_sql_proxy_vm" {
  name         = "hag-datastream-cloud-sql-proxy-vm"
  machine_type = "e2-micro"
  project      = var.gcp_project["project"]
  zone         = var.gcp_project["zone"]

  boot_disk {
    initialize_params {
      image = module.cloud_sql_auth_proxy_container_datastream.source_image
    }
  }

  network_interface {
    network = google_compute_network.hag_datastream_private_vpc.name
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    gce-container-declaration = module.cloud_sql_auth_proxy_container_datastream.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  labels = {
    container-vm = module.cloud_sql_auth_proxy_container_datastream.vm_container_label
  }
}

// Datastream connection profile for BigQuery target. Can be used by multiple streams.
resource "google_datastream_connection_profile" "datastream_bigquery_connection_profile" {
  display_name          = "datastream-bigquery-connection-profile"
  location              = var.gcp_project["region"]
  connection_profile_id = "datastream-bigquery-connection-profile"

  bigquery_profile {}
}
