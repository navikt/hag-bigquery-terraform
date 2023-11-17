data "google_secret_manager_secret_version" "bro_datastream_user_secret" {
  secret = "bro_datastream_user_secret"
}

locals {
  bro_db_credentials = jsondecode(
    data.google_secret_manager_secret_version.bro_datastream_user_secret.secret_data
  )
}
