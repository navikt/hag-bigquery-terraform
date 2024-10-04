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
  authorized_datasets = [
    {
      dataset = {
        dataset_id = "simba_dataprodukter"
        project_id = var.gcp_project["project"]
      }
  }]
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
}

module "spinosaurus_datastream" {
  source                              = "../modules/google-bigquery-datastream"
  gcp_project                         = var.gcp_project
  application_name                    = "spinosaurus"
  cloud_sql_instance_name             = "spinosaurus"
  cloud_sql_instance_db_name          = "spinosaurus"
  cloud_sql_instance_db_credentials   = local.spinosaurus_db_credentials
  datastream_vpc_resources            = local.datastream_vpc_resources
  cloud_sql_instance_replication_name = "spinosaurus_replication"
  cloud_sql_instance_publication_name = "spinosaurus_publication"
  datastream_id                       = "spinosaurus-datastream"
  dataset_id                          = "spinosaurus_dataset"
  postgresql_exclude_schemas = [
    {
      schema = "public"
      tables = [
        {
          table = "flyway_schema_history"
        },
        {
          table = "bakgrunnsjobb"
        },
        {
          table = "arbeidsgiverperiode"
        },
        {
          table = "feilet"
        },
        {
          table   = "inntektsmelding",
          columns = ["aktor_id", "sak_id", "arbeidsgiver_privat"]
        },
        {
          table   = "utsatt_oppgave",
          columns = ["fnr", "aktor_id", "sak_id", "enhet", "gosys_oppgave_id"]
        }
      ]
    }
  ]
}
