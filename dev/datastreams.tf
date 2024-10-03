locals {
  datastream_vpc_resources = {
    vpc_name                       = google_compute_network.hag_datastream_private_vpc.name
    private_connection_id          = google_datastream_private_connection.hag_datastream_private_connection.id
    bigquery_connection_profile_id = google_datastream_connection_profile.datastream_bigquery_connection_profile.id
  }
}

module "bro_datastream" {
  source                              = "../modules/google-bigquery-datastream"
  gcp_project                         = var.gcp_project
  application_name                    = "helsearbeidsgiver-bro-sykepenger"
  cloud_sql_instance_name             = "helsearbeidsgiver-bro-sykepenger"
  cloud_sql_instance_db_name          = "helsearbeidsgiver-bro-sykepenger"
  cloud_sql_instance_db_credentials   = local.bro_db_credentials
  datastream_vpc_resources            = local.datastream_vpc_resources
  cloud_sql_instance_replication_name = "bro_replication"
  cloud_sql_instance_publication_name = "bro_publication"
  datastream_id                       = "bro-datastream"
  dataset_id                          = "bro_dataset"
}
