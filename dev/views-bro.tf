module "bro_forespoersel_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = "bro_dataset"
  view_id             = "public_forespoersel_view"
  view_query          = <<EOF
SELECT *
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY id
      ORDER BY datastream_metadata.source_timestamp DESC
    ) AS row_num
  FROM
    `${var.gcp_project["project"]}.bro_dataset.public_forespoersel`
  WHERE
    datastream_metadata.change_type != 'DELETE'
)
WHERE row_num = 1
EOF
}

module "bro_besvarelse_metadata_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = "bro_dataset"
  view_id             = "public_besvarelse_metadata_view"
  view_query          = <<EOF
SELECT *
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY id
      ORDER BY datastream_metadata.source_timestamp DESC
    ) AS row_num
  FROM
    `${var.gcp_project["project"]}.bro_dataset.public_besvarelse_metadata`
  WHERE
    datastream_metadata.change_type != 'DELETE'
)
WHERE row_num = 1
EOF
}
