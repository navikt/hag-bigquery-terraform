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
  access {
    view {
      dataset_id = "simba_dataprodukter"
      project_id = var.gcp_project["project"]
      table_id   = "forespoersel_svartid"
    }
  }
  access {
    view {
      dataset_id = "simba_dataprodukter"
      project_id = var.gcp_project["project"]
      table_id   = "forespoersler"
    }
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
    database = "helsearbeidsgiver-bro-sykepenger"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.hag_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "bro_datastream" {
  stream_id     = "bro-datastream"
  display_name  = "bro-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.bro_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "bro_publication"
      replication_slot              = "bro_replication"

      exclude_objects {
        postgresql_schemas {
          schema = "public"

          postgresql_tables {
            table = "flyway_schema_history"
          }
        }
      }

      include_objects {
        postgresql_schemas {
          schema = "public"
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.datastream_bigquery_connection_profile.id

    bigquery_destination_config {
      data_freshness = "600s"

      single_target_dataset {
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.bro_dataset.dataset_id}"
      }
    }
  }
}

