module "simba_inntektsmelding_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = "simba_dataset"
  view_id             = "public_inntektsmelding_view"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "INTEGER"
      },
      {
        name = "dokument"
        type = "JSON"
      },
      {
        name = "forespoersel_id"
        type = "STRING"
      },
      {
        name = "journalpost_id"
        type = "STRING"
      },
      {
        name = "innsendt"
        type = "TIMESTAMP"
      },
      {
        name = "ekstern_inntektsmelding"
        type = "JSON"
      },
      {
        name = "skjema"
        type = "JSON"
      },
      {
        name = "inntektsmelding_id"
        type = "STRING"
      },
      {
        name = "avsender_navn"
        type = "STRING"
      },
      {
        name = "datastream_metadata"
        type = "RECORD"
        fields = [
          {
            name = "uuid"
            type = "STRING"
          },
          {
            name = "source_timestamp"
            type = "INTEGER"
          },
          {
            name = "change_sequence_number"
            type = "STRING"
          },
          {
            name = "change_type"
            type = "STRING"
          },
          {
            name = "sort_keys"
            type = "STRING"
            mode = "REPEATED"
          }
        ]
      },
      {
        name = "row_num"
        type = "INTEGER"
      }
    ]
  )
  view_query = <<EOF
SELECT *
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY id
      ORDER BY datastream_metadata.source_timestamp DESC
    ) AS row_num
  FROM
    `${var.gcp_project["project"]}.simba_dataset.public_inntektsmelding`
  WHERE
    datastream_metadata.change_type != 'DELETE'
)
WHERE row_num = 1
EOF
}

module "simba_selvbestemt_inntektsmelding_view" {
  source              = "../modules/google-bigquery-view"
  deletion_protection = false
  dataset_id          = "simba_dataset"
  view_id             = "public_selvbestemt_inntektsmelding_view"
  view_schema = jsonencode(
    [
      {
        name = "id"
        type = "INTEGER"
      },
      {
        name = "inntektsmelding_id"
        type = "STRING"
      },
      {
        name = "selvbestemt_id"
        type = "STRING"
      },
      {
        name = "inntektsmelding"
        type = "JSON"
      },
      {
        name = "journalpost_id"
        type = "STRING"
      },
      {
        name = "opprettet"
        type = "TIMESTAMP"
      },
      {
        name = "datastream_metadata"
        type = "RECORD"
        fields = [
          {
            name = "uuid"
            type = "STRING"
          },
          {
            name = "source_timestamp"
            type = "INTEGER"
          },
          {
            name = "change_sequence_number"
            type = "STRING"
          },
          {
            name = "change_type"
            type = "STRING"
          },
          {
            name = "sort_keys"
            type = "STRING"
            mode = "REPEATED"
          }
        ]
      },
      {
        name = "prosessert"
        type = "TIMESTAMP"
      },
      {
        name = "row_num"
        type = "INTEGER"
      }
    ]
  )
  view_query = <<EOF
SELECT *
FROM (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY id
      ORDER BY datastream_metadata.source_timestamp DESC
    ) AS row_num
  FROM
    `${var.gcp_project["project"]}.simba_dataset.public_selvbestemt_inntektsmelding`
  WHERE
    datastream_metadata.change_type != 'DELETE'
)
WHERE row_num = 1
EOF
}

