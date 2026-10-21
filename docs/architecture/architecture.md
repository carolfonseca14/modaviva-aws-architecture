# Arquitetura AWS — ModaViva

## Visão geral

```mermaid
flowchart TB

    USER["Usuário / Cliente"]
    GH["GitHub Actions<br/>CI/CD + OIDC"]
    ECR["Amazon ECR<br/>modaviva-api"]

    subgraph AWS["AWS — us-east-1"]

        subgraph VPC["VPC 10.0.0.0/16"]

            subgraph PUBLIC["Subnets Públicas — 2 AZs"]
                ALB["Application Load Balancer"]
            end

            subgraph PRIVATE["Subnets Privadas — 2 AZs"]
                ECS["Amazon ECS / Fargate<br/>ModaViva API<br/>Auto Scaling 2–4 tasks"]
                RDS["Amazon RDS PostgreSQL<br/>Single-AZ na PoC"]
                LAMBDA["Lambda Ingest"]
                CURATED["Lambda Curated"]
            end

        end

        S3RAW["Amazon S3<br/>Analytics RAW"]
        S3CUR["Amazon S3<br/>Analytics CURATED"]
        GLUE["AWS Glue Data Catalog"]
        ATHENA["Amazon Athena"]
        CW["Amazon CloudWatch<br/>Logs / Metrics / Alarms"]
        SNS["Amazon SNS<br/>Alertas"]
        SECRETS["AWS Secrets Manager"]
        IAM["IAM<br/>Least Privilege"]

    end

    POWERBI["Power BI"]

    USER --> ALB
    ALB --> ECS
    ECS --> RDS

    GH --> ECR
    ECR --> ECS

    RDS --> LAMBDA
    LAMBDA --> S3RAW
    S3RAW --> CURATED
    CURATED --> S3CUR
    S3CUR --> GLUE
    GLUE --> ATHENA
    ATHENA --> POWERBI

    ECS --> CW
    ALB --> CW
    CW --> SNS

    ECS --> SECRETS
    LAMBDA --> SECRETS

    IAM -.-> ECS
    IAM -.-> LAMBDA
    IAM -.-> GH