import json
import os
from datetime import datetime, timezone

import boto3
import psycopg
import pyarrow as pa
import pyarrow.parquet as pq


secrets_client = boto3.client("secretsmanager")
s3_client = boto3.client("s3")

SECRET_ARN = os.environ["DATABASE_SECRET_ARN"]
ANALYTICS_BUCKET = os.environ["ANALYTICS_BUCKET"]

TABLE_CONFIG = {
    "pedido": {
        "table": "pedido",
        "id_column": "id_pedido",
        "columns": [
            "id_pedido",
            "id_campanha",
            "data_pedido",
            "status_pedido",
            "atualizado_em",
        ],
    },
    "item_pedido": {
        "table": "item_pedido",
        "id_column": "id_item",
        "columns": [
            "id_item",
            "id_pedido",
            "id_produto",
            "quantidade",
            "valor_unitario",
            "atualizado_em",
        ],
    },
    "produto": {
        "table": "produto",
        "id_column": "id_produto",
        "columns": [
            "id_produto",
            "nome_produto",
            "categoria",
            "preco",
            "custo_unitario",
            "atualizado_em",
        ],
    },
    "campanha": {
        "table": "campanha",
        "id_column": "id_campanha",
        "columns": [
            "id_campanha",
            "nome_campanha",
            "tipo_campanha",
            "data_inicio",
            "data_fim",
            "atualizado_em",
        ],
    },
}

def get_database_credentials():
    response = secrets_client.get_secret_value(
        SecretId=SECRET_ARN
    )

    return json.loads(response["SecretString"])


def lambda_handler(event, context):
    credentials = get_database_credentials()

    connection = psycopg.connect(
        host=os.environ["DATABASE_HOST"],
        port=os.environ.get("DATABASE_PORT", "5432"),
        dbname=os.environ["DATABASE_NAME"],
        user=credentials["username"],
        password=credentials["password"],
        sslmode="require",
    )

    with connection:
        with connection.cursor() as cursor:

            # 1. Descobre de onde a última carga parou
            processo = event.get("processo", "pedido")

            if processo not in TABLE_CONFIG:
                raise Exception(
                    f"Processo '{processo}' não configurado."
                )

            config = TABLE_CONFIG[processo]

            cursor.execute(
                """
                SELECT ultima_data_atualizacao, ultimo_id
                FROM controle_carga
                WHERE nome_processo = %s
                """,
                (processo,),
            )

            control = cursor.fetchone()

            if control is None:
                raise Exception(
                    f"Processo '{processo}' não encontrado em controle_carga."
                )

            ultima_data, ultimo_id = control

            # 2. Busca somente registros novos ou alterados
                # 2.1 Normaliza os IDs usados nos relacionamentos
                pedido["id_campanha"] = pd.to_numeric(
                    pedido["id_campanha"],
                    errors="coerce",
                ).astype("Int64")

                campanha["id_campanha"] = pd.to_numeric(
                    campanha["id_campanha"],
                    errors="coerce",
                ).astype("Int64")

                item_pedido["id_pedido"] = pd.to_numeric(
                    item_pedido["id_pedido"],
                    errors="coerce",
                ).astype("int64")

                pedido["id_pedido"] = pd.to_numeric(
                    pedido["id_pedido"],
                    errors="coerce",
                ).astype("int64")

                item_pedido["id_produto"] = pd.to_numeric(
                    item_pedido["id_produto"],
                    errors="coerce",
                ).astype("int64")

                produto["id_produto"] = pd.to_numeric(
                    produto["id_produto"],
                    errors="coerce",
                ).astype("int64")
            columns = config["columns"]
            id_column = config["id_column"]
            table = config["table"]

            column_sql = ", ".join(columns)

            query = f"""
                SELECT
                    {column_sql}
                FROM {table}
                WHERE
                    atualizado_em > %s
                    OR (
                        atualizado_em = %s
                        AND {id_column} > %s
                    )
                ORDER BY atualizado_em, {id_column}
            """

            cursor.execute(
                query,
                (
                    ultima_data,
                    ultima_data,
                    ultimo_id,
                ),
            )

            rows = cursor.fetchall()

            # Não há nada novo para carregar
            if not rows:
                return {
                    "statusCode": 200,
                    "body": {
                        "processo": processo,
                        "registros": 0,
                        "mensagem": "Nenhum registro novo ou alterado."
                    }
                }

            # 3. Cria tabela Arrow para gerar Parquet
            columns = config["columns"]

            data = {
                column: [row[index] for row in rows]
                for index, column in enumerate(columns)
            }

            table = pa.Table.from_pydict(data)

            # 4. Gera o arquivo temporariamente no /tmp da Lambda
            timestamp = datetime.now(timezone.utc)

            filename = (
                f"lote_{timestamp.strftime('%Y%m%dT%H%M%SZ')}.parquet"
            )

            local_path = f"/tmp/{filename}"

            pq.write_table(
                table,
                local_path,
                compression="snappy",
            )

            # 5. Organiza o RAW por ano/mês/dia
            raw_key = (
                f"raw/{processo}/"
                f"ano={timestamp.year}/"
                f"mes={timestamp.month:02d}/"
                f"dia={timestamp.day:02d}/"
                f"{filename}"
            )

            # 6. Envia o Parquet para o S3
            s3_client.upload_file(
                local_path,
                ANALYTICS_BUCKET,
                raw_key,
            )

            # 7. SOMENTE depois do upload bem-sucedido,
            # atualiza o marcador de controle.
            ultima_linha = rows[-1]

            nova_data = ultima_linha[columns.index("atualizado_em")]
            novo_id = ultima_linha[columns.index(id_column)]

            cursor.execute(
                """
                UPDATE controle_carga
                SET
                    ultima_data_atualizacao = %s,
                    ultimo_id = %s,
                    atualizado_em = CURRENT_TIMESTAMP
                WHERE nome_processo = %s
                """,
                (
                    nova_data,
                    novo_id,
                    processo,
                ),
            )

    return {
        "statusCode": 200,
        "body": {
            "processo": processo,
            "registros": len(rows),
            "arquivo": f"s3://{ANALYTICS_BUCKET}/{raw_key}",
            "ultimo_id": novo_id,
            "ultima_data_atualizacao": str(nova_data),
        }
    }