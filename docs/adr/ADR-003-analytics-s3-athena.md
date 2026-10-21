# ADR-003 — Arquitetura de Analytics com S3 e Athena

## Status
Aceito

## Contexto
A área comercial precisa consultar indicadores de vendas sem aumentar a carga sobre o banco transacional da aplicação.

Também é necessário consolidar dados de pedidos, itens, produtos e campanhas em uma camada analítica.

## Decisão
Separar o processamento analítico do ambiente transacional.

Os dados são extraídos incrementalmente do RDS por uma Lambda e armazenados em formato Parquet no Amazon S3 na camada RAW.

Uma segunda Lambda transforma os dados e grava a tabela analítica ato_vendas na camada CURATED.

O AWS Glue Data Catalog registra os metadados e o Amazon Athena consulta os dados diretamente no S3.

## Alternativas consideradas
- Consultar diretamente o RDS: simples, porém aumenta a carga no banco transacional.
- Utilizar um data warehouse: adequado para ambientes maiores, mas desnecessário para a escala da PoC.
- S3 + Athena: baixo custo e adequado para demonstrar uma arquitetura analítica desacoplada.

## Consequências
Positivas:
- Separação entre workload transacional e analítico.
- Dados em formato Parquet.
- Baixo custo para a PoC.
- Consultas SQL utilizando Athena.
- Possibilidade de integração posterior com ferramentas de BI.

Negativas:
- Maior complexidade que consultar diretamente o RDS.
- O pipeline precisa controlar processamento incremental e transformação.

## Evolução
Em uma arquitetura de maior escala, avaliar AWS Glue para processamento mais robusto, catálogo centralizado e orquestração, além de mecanismos de mensageria como SQS para desacoplar as etapas do pipeline.
