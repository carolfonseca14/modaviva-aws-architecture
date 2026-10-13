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
            cursor.execute(
                """
                SELECT ultima_data_atualizacao, ultimo_id
                FROM controle_carga
                WHERE nome_processo = %s
                """,
                ("pedido",),
            )

            control = cursor.fetchone()

            if control is None:
                raise Exception(
                    "Processo 'pedido' não encontrado em controle_carga."
                )

            ultima_data, ultimo_id = control

            # 2. Busca somente registros novos ou alterados
            cursor.execute(
                """
                SELECT
                    id_pedido,
                    id_campanha,
                    data_pedido,
                    status_pedido,
                    atualizado_em
                FROM pedido
                WHERE
                    atualizado_em > %s
                    OR (
                        atualizado_em = %s
                        AND id_pedido > %s
                    )
                ORDER BY atualizado_em, id_pedido
                """,
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
                        "processo": "pedido",
                        "registros": 0,
                        "mensagem": "Nenhum registro novo ou alterado."
                    }
                }

            # 3. Cria tabela Arrow para gerar Parquet
            columns = [
                "id_pedido",
                "id_campanha",
                "data_pedido",
                "status_pedido",
                "atualizado_em",
            ]

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
                f"raw/pedido/"
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

            nova_data = ultima_linha[4]
            novo_id = ultima_linha[0]

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
                    "pedido",
                ),
            )

    return {
        "statusCode": 200,
        "body": {
            "processo": "pedido",
            "registros": len(rows),
            "arquivo": f"s3://{ANALYTICS_BUCKET}/{raw_key}",
            "ultimo_id": novo_id,
            "ultima_data_atualizacao": str(nova_data),
        }
    }