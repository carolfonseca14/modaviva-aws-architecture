resource "aws_glue_catalog_database" "analytics" {
  name        = "modaviva_analytics"
  description = "Catalogo de dados analiticos da ModaViva"
}

resource "aws_glue_catalog_table" "fato_vendas" {
  name          = "fato_vendas"
  database_name = aws_glue_catalog_database.analytics.name
  description   = "Fato analitico de vendas da ModaViva"
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.analytics.bucket}/curated/fato_vendas/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "id_pedido"
      type = "bigint"
    }

    columns {
      name = "id_item"
      type = "bigint"
    }

    columns {
      name = "id_produto"
      type = "bigint"
    }

    columns {
      name = "id_campanha"
      type = "bigint"
    }

    columns {
      name = "id_data"
      type = "int"
    }

    columns {
      name = "data_hora_venda"
      type = "timestamp"
    }

    columns {
      name = "quantidade"
      type = "bigint"
    }

    columns {
      name = "valor_unitario"
      type = "decimal(10,2)"
    }

    columns {
      name = "valor_venda"
      type = "decimal(10,2)"
    }

    columns {
      name = "custo_unitario"
      type = "decimal(10,2)"
    }

    columns {
      name = "custo_total"
      type = "decimal(10,2)"
    }

    columns {
      name = "lucro"
      type = "decimal(10,2)"
    }

    columns {
      name = "status_pedido"
      type = "string"
    }

    columns {
      name = "categoria"
      type = "string"
    }

    columns {
      name = "nome_campanha"
      type = "string"
    }

    columns {
      name = "tipo_campanha"
      type = "string"
    }

    columns {
      name = "atualizado_em"
      type = "timestamp"
    }
  }

  partition_keys {
    name = "ano"
    type = "int"
  }

  partition_keys {
    name = "mes"
    type = "int"
  }

  partition_keys {
    name = "dia"
    type = "int"
  }
}