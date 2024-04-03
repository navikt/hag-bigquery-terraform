data "google_secret_manager_secret_version" "bro_datastream_user_secret" {
  secret = "bro_datastream_user_secret"
}
data "google_secret_manager_secret_version" "spinosaurus_datastream_user_secret" {
  secret = "spinosaurus_datastream_user_secret"
}
data "google_secret_manager_secret_version" "simba_datastream_user_secret" {
  secret = "simba_datastream_user_secret"
}

locals {
  bro_db_credentials = jsondecode(
    data.google_secret_manager_secret_version.bro_datastream_user_secret.secret_data
  )
  spinosaurus_db_credentials = jsondecode(
    data.google_secret_manager_secret_version.spinosaurus_datastream_user_secret.secret_data
  )
  simba_db_credentials = jsondecode(
    data.google_secret_manager_secret_version.simba_datastream_user_secret.secret_data
  )
}
