resource "google_bigquery_dataset" "simba_dataset" {
  dataset_id = "simba_dataset"
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

resource "google_datastream_connection_profile" "simba_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "simba-postgresql-connection-profile"
  connection_profile_id = "simba-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.hag_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.simba_db_cloud_sql_port
    username = local.simba_db_credentials["username"]
    password = local.simba_db_credentials["password"]
    database = "inntektsmelding"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.hag_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "simba_datastream" {
  stream_id     = "simba-datastream"
  display_name  = "simba-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.simba_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "simba_publication"
      replication_slot              = "simba_replication"

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
      data_freshness = "300s"

      single_target_dataset {
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.simba_dataset.dataset_id}"
      }
    }
  }
}
