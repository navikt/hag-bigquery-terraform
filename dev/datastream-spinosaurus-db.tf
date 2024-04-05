resource "google_bigquery_dataset" "spinosaurus_dataset" {
  dataset_id = "spinosaurus_dataset"
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

resource "google_datastream_connection_profile" "spinosaurus_postgresql_connection_profile" {
  location              = var.gcp_project["region"]
  display_name          = "spinosaurus-postgresql-connection-profile"
  connection_profile_id = "spinosaurus-postgresql-connection-profile"

  postgresql_profile {
    hostname = google_compute_instance.hag_datastream_cloud_sql_proxy_vm.network_interface[0].network_ip
    port     = var.spinosaurus_db_cloud_sql_port
    username = local.spinosaurus_db_credentials["username"]
    password = local.spinosaurus_db_credentials["password"]
    database = "spinosaurus"
  }

  private_connectivity {
    private_connection = google_datastream_private_connection.hag_datastream_private_connection.id
  }
}

resource "google_datastream_stream" "spinosaurus_datastream" {
  stream_id     = "spinosaurus-datastream"
  display_name  = "spinosaurus-datastream"
  desired_state = "RUNNING"
  project       = var.gcp_project["project"]
  location      = var.gcp_project["region"]
  labels        = {}
  backfill_all {}
  timeouts {}

  source_config {
    source_connection_profile = google_datastream_connection_profile.spinosaurus_postgresql_connection_profile.id

    postgresql_source_config {
      max_concurrent_backfill_tasks = 0
      publication                   = "spinosaurus_publication"
      replication_slot              = "spinosaurus_replication"

      exclude_objects {
        postgresql_schemas {
          schema = "public"

          postgresql_tables {
            table = "flyway_schema_history"
          }

          postgresql_tables {
            table = "bakgrunnsjobb"
          }

          postgresql_tables {
            table = "arbeidsgiverperiode"
          }

          postgresql_tables {
            table = "feilet"
          }

          postgresql_tables {
            table = "inntektsmelding"
            postgresql_columns {
              column = "aktor_id"
            }
            postgresql_columns {
              column = "sak_id"
            }
            postgresql_columns {
              column = "arbeidsgiver_privat"
            }
          }

          postgresql_tables {
            table = "utsatt_oppgave"
            postgresql_columns {
              column = "fnr"
            }
            postgresql_columns {
              column = "aktor_id"
            }
            postgresql_columns {
              column = "sak_id"
            }
            postgresql_columns {
              column = "enhet"
            }
            postgresql_columns {
              column = "gosys_oppgave_id"
            }
            postgresql_columns {
              column = "gosys_oppgave_id"
            }
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
        dataset_id = "${var.gcp_project["project"]}:${google_bigquery_dataset.spinosaurus_dataset.dataset_id}"
      }
    }
  }
}

resource "google_bigquery_table_iam_binding" "inntektsmelding_view_iam_binding" {
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.spinosaurus_dataset.dataset_id
  table_id   = "${google_bigquery_dataset.spinosaurus_dataset.dataset_id}.public_inntektsmelding"
  role       = "roles/bigquery.dataViewer"
  members    = [var.flytt_spinosaurus_service_user]
}

resource "google_bigquery_table_iam_binding" "utsatt_oppgave_view_iam_binding" {
  project    = var.gcp_project.project
  dataset_id = google_bigquery_dataset.spinosaurus_dataset.dataset_id
  table_id   = "${google_bigquery_dataset.spinosaurus_dataset.dataset_id}.public_utsatt_oppgave"
  role       = "roles/bigquery.dataViewer"
  members    = [var.flytt_spinosaurus_service_user]
}
