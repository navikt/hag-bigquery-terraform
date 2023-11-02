resource "google_bigquery_dataset" "bro_dataset" {
  dataset_id = "bro_dataset"
  location   = var.gcp_project["region"]
  project    = var.gcp_project["project"]
  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
}

resource "google_datastream_connection_profile" "bro_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "bro-postgresql-connection-profile"
  connection_profile_id = "bro-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.hag_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.bro_db_cloud_sql_port
    username = local.bro_db_credentials["username"]
    password = local.bro_db_credentials["password"]
    database = data.google_sql_database_instance.bro_db.name
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.hag_datastream_private_connection.id
  }
}
