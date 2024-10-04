locals {
  datastream_vpc_resources = {
    vpc_name                       = google_compute_network.hag_datastream_private_vpc.name
    private_connection_id          = google_datastream_private_connection.hag_datastream_private_connection.id
    bigquery_connection_profile_id = google_datastream_connection_profile.datastream_bigquery_connection_profile.id
  }
}

module "simba_datastream" {
  source                              = "../modules/google-bigquery-datastream"
  gcp_project                         = var.gcp_project
  application_name                    = "im-db"
  cloud_sql_instance_name             = "im-db"
  cloud_sql_instance_db_name          = "inntektsmelding"
  cloud_sql_instance_db_credentials   = local.simba_db_credentials
  datastream_vpc_resources            = local.datastream_vpc_resources
  cloud_sql_instance_replication_name = "simba_replication"
  cloud_sql_instance_publication_name = "simba_publication"
  datastream_id                       = "simba-datastream"
  dataset_id                          = "simba_dataset"
  authorized_views = [
    {
      view = {
        dataset_id = "simba_dataprodukter"
        project_id = var.gcp_project["project"]
        table_id   = "forespoersel_svartid"
      }
  }]
}

