# ModaViva — AWS Solutions Architecture PoC

PoC de arquitetura em AWS para uma plataforma fictícia de e-commerce de moda, desenvolvida a partir de um cenário de negócio com crescimento de tráfego durante campanhas, indisponibilidade da aplicação, processos manuais de deploy e necessidade de separar workloads transacionais e analíticos.

O projeto foi desenvolvido como estudo prático de **AWS Solutions Architecture**, passando por levantamento de requisitos, desenho arquitetural, implementação, testes, segurança, observabilidade, automação, análise de custos e AWS Well-Architected Framework.

---

## Contexto

A ModaViva é um e-commerce de médio porte que apresenta aumento significativo de tráfego e vendas durante campanhas promocionais.

### Cenário de negócio

| Cenário | Acessos | Compras |
|---|---:|---:|
| Normal | ~2.000/dia | ~300/dia |
| Campanha | 15.000–20.000/dia | ~2.000/dia |
| Pico de campanha | — | ~150/hora |

O cenário original apresentava:

- dois servidores de aplicação no mesmo datacenter;
- dependência de um banco de dados central;
- indisponibilidade durante campanhas;
- deploys manuais;
- rollback demorado;
- dados utilizados em análises distribuídos;
- backups pouco frequentes;
- necessidade de maior controle de acesso;
- ausência de monitoramento centralizado adequado.

---

## Objetivo

Projetar e implementar uma PoC capaz de:

- suportar picos de demanda durante campanhas;
- aumentar a disponibilidade da camada de aplicação;
- reduzir pontos únicos de falha;
- permitir escalabilidade conforme a demanda;
- automatizar o processo de implantação;
- aplicar controle de acesso baseado em menor privilégio;
- proteger credenciais e dados sensíveis;
- separar cargas analíticas das transacionais;
- centralizar dados para análise;
- monitorar a infraestrutura e gerar alertas;
- manter os custos controlados.

---

## Arquitetura

A arquitetura utiliza serviços gerenciados da AWS e separa as principais responsabilidades entre aplicação, banco transacional, analytics, segurança e observabilidade.

### Principais componentes

- **Amazon VPC** — isolamento da rede em duas Availability Zones;
- **Application Load Balancer** — distribuição do tráfego para a aplicação;
- **Amazon ECS com AWS Fargate** — execução da API em containers;
- **ECS Service Auto Scaling** — escala da aplicação entre 2 e 4 tasks;
- **Amazon RDS PostgreSQL** — banco de dados transacional;
- **Amazon S3** — armazenamento de imagens de produtos e dados analíticos;
- **AWS Lambda** — ingestão e transformação dos dados;
- **AWS Glue Data Catalog** — catálogo dos dados analíticos;
- **Amazon Athena** — consultas SQL sobre os dados no S3;
- **Amazon CloudWatch** — logs, métricas, dashboards e alarmes;
- **Amazon SNS** — envio de notificações dos alarmes;
- **AWS Secrets Manager** — armazenamento das credenciais do banco;
- **AWS IAM** — controle de acesso e menor privilégio;
- **Amazon ECR** — armazenamento das imagens Docker;
- **GitHub Actions + OIDC** — CI/CD sem credenciais AWS permanentes;
- **Terraform** — infraestrutura como código.

### Diagrama

O diagrama arquitetural está disponível em:

`docs/architecture/architecture.md`

---

## Fluxo da aplicação

```text
Usuário
   │
   ▼
Application Load Balancer
   │
   ▼
ECS / Fargate
   │
   ├── Task 1
   └── Task 2
        │
        ▼
   RDS PostgreSQL
```

A camada de aplicação é executada em **subnets privadas distribuídas em duas Availability Zones**.

O Application Load Balancer realiza a distribuição do tráfego e utiliza health checks para identificar targets saudáveis.

O ECS Service Auto Scaling permite aumentar ou reduzir a quantidade de tasks de acordo com a utilização da aplicação.

---

## Escalabilidade

O serviço ECS foi configurado com:

- mínimo de 2 tasks;
- máximo de 4 tasks;
- target tracking baseado em utilização de CPU;
- scale-out com target de 60% de CPU.

### Validação

Durante um teste de carga utilizando o endpoint `/load-test`, a utilização de CPU da aplicação aumentou significativamente.

O Auto Scaling identificou a necessidade de expansão e aumentou a quantidade desejada de tasks de **2 para 4**.

Após a redução da carga, o serviço também realizou scale-in.

Esse teste validou o comportamento de escalabilidade automática da camada de aplicação.

---

## Disponibilidade e tolerância a falhas

A camada de aplicação foi distribuída entre duas Availability Zones.

O serviço ECS utiliza múltiplas tasks e o Application Load Balancer remove automaticamente targets que não estejam saudáveis.

Também foi realizado um teste de falha de task:

```text
Task em execução
      ↓
Task interrompida
      ↓
ECS mantém/recompõe a capacidade desejada
      ↓
Aplicação permanece atendida por task saudável
```

### Observação sobre o banco

O **RDS PostgreSQL desta PoC utiliza Single-AZ**.

Essa decisão foi tomada para manter o custo do ambiente de estudo controlado.

Em um ambiente de produção que exigisse maior resiliência do banco, a evolução planejada seria utilizar **RDS Multi-AZ**.

Essa decisão e seu trade-off estão documentados em:

`docs/adr/ADR-002-rds-single-az-poc.md`

---

## Segurança

A arquitetura utiliza diferentes camadas de controle de acesso.

### Secrets Manager

As credenciais do banco não são armazenadas no código da aplicação.

A aplicação recebe as informações necessárias por meio do **AWS Secrets Manager**.

### IAM

As permissões foram separadas por responsabilidade, utilizando políticas específicas para os serviços.

Exemplos:

- ECS possui permissões necessárias para execução da aplicação;
- Lambda de ingestão possui acesso de escrita ao prefixo RAW;
- Lambda de transformação possui acesso ao RAW e ao CURATED;
- GitHub Actions utiliza uma role específica;
- acesso ao S3 é limitado aos recursos necessários.

### Teste de menor privilégio

Foi realizado um teste real utilizando uma role temporária com permissão somente para leitura das imagens de produtos.

O teste demonstrou:

```text
Acesso ao bucket de imagens
        ↓
Permitido
```

e:

```text
Tentativa de acessar dados analíticos RAW
        ↓
AccessDenied
```

O resultado confirmou que a role não possuía acesso aos objetos fora do escopo autorizado.

A role temporária utilizada para o teste foi posteriormente removida.

---

## Dados e Analytics

A arquitetura separa o workload transacional do workload analítico.

### Fluxo

```text
RDS PostgreSQL
      │
      ▼
Lambda — Ingestão
      │
      ▼
S3 RAW
      │
      ▼
Lambda — Curadoria
      │
      ▼
S3 CURATED
      │
      ▼
Glue Data Catalog
      │
      ▼
Amazon Athena
      │
      ▼
Análises / Power BI
```

O processamento utiliza uma estratégia incremental, evitando a necessidade de processar novamente todo o conjunto de dados a cada execução.

Os arquivos analíticos são armazenados em formato **Parquet**, com particionamento por ano, mês e dia.

---

## Consultas analíticas

A pipeline foi validada utilizando consultas no Athena para responder perguntas de negócio.

### Indicadores gerais

Resultado validado:

- **3 pedidos**
- **7 unidades vendidas**
- **R$ 2.049,30 de faturamento**
- **R$ 1.109,30 de lucro**
- **R$ 683,10 de ticket médio**

### Campanha × sem campanha

Os dados também foram utilizados para comparar resultados de vendas entre períodos com e sem campanha.

### Evolução diária

Foi realizada uma consulta de evolução das vendas por dia, permitindo analisar:

- pedidos;
- unidades;
- faturamento;
- lucro.

Essas consultas demonstram o uso do ambiente analítico para responder perguntas relacionadas ao desempenho comercial.

---

## Armazenamento de imagens

As imagens dos produtos são armazenadas em um bucket S3 separado.

A aplicação possui um endpoint que recupera a imagem do produto utilizando o SDK da AWS.

O bucket utiliza:

- bloqueio de acesso público;
- criptografia server-side;
- controle de acesso via IAM.

---

## Observabilidade

A solução utiliza Amazon CloudWatch para centralizar métricas, logs e alertas.

### Dashboard

O dashboard operacional acompanha indicadores como:

- CPU do ECS;
- memória do ECS;
- quantidade de targets saudáveis no ALB;
- quantidade de requisições;
- erros HTTP 5xx;
- tempo de resposta.

### Alarmes

Foram configurados alarmes para situações como:

- CPU elevada;
- memória elevada;
- quantidade insuficiente de tasks.

Os alarmes utilizam um tópico SNS para notificação.

Também foi realizado um teste controlado de alarme de CPU, verificando a transição para `ALARM` e posterior retorno para `OK`.

---

## CI/CD

O projeto utiliza GitHub Actions para automatizar validações e deploy.

### CI

A pipeline de CI executa:

- instalação das dependências Python;
- testes automatizados;
- `terraform fmt`;
- `terraform validate`.

### CD

O processo de deploy:

1. autentica o GitHub Actions na AWS utilizando OIDC;
2. realiza login no Amazon ECR;
3. constrói a imagem Docker;
4. envia a imagem para o ECR;
5. cria uma nova revisão da task definition;
6. atualiza o serviço ECS;
7. aguarda a estabilização do deployment.

A integração utiliza **OIDC**, evitando a necessidade de armazenar access keys permanentes da AWS no GitHub.

---

## Docker

A API foi containerizada utilizando Docker.

A imagem utiliza Python 3.12 e executa a aplicação FastAPI com Uvicorn.

Também foram realizados testes locais da imagem Docker antes do deploy na AWS.

---

## Infrastructure as Code

A infraestrutura AWS é gerenciada utilizando **Terraform**.

A IaC contempla componentes como:

- VPC;
- subnets;
- security groups;
- VPC endpoints;
- ECS;
- ALB;
- Auto Scaling;
- RDS;
- S3;
- Lambda;
- Glue;
- EventBridge Scheduler;
- IAM;
- CloudWatch;
- SNS;
- ECR.

A configuração Terraform também é validada automaticamente pela pipeline de CI.

### Terraform × aplicação

A infraestrutura base permanece gerenciada pelo Terraform.

As revisões da task definition utilizadas no processo de deploy da aplicação são gerenciadas pelo GitHub Actions, permitindo que o CI/CD publique novas versões da aplicação sem sobrescrever o ciclo de IaC.

---

## Custos e trade-offs

Como o projeto foi desenvolvido como uma PoC de portfólio, o custo foi considerado durante as decisões arquiteturais.

### Principais decisões de custo

- uso de Fargate em vez de gerenciamento de servidores;
- instância RDS de baixo custo;
- RDS Single-AZ na PoC;
- ausência de NAT Gateway;
- armazenamento analítico em S3;
- consultas sob demanda com Athena;
- Auto Scaling limitado entre 2 e 4 tasks;
- destruição dos recursos quando o ambiente não está sendo utilizado.

### Trade-offs

A redução de custos implica algumas limitações em relação a uma arquitetura de produção.

Principalmente:

- RDS não utiliza Multi-AZ nesta PoC;
- não existe estratégia multi-region;
- não existe NAT Gateway;
- o ambiente não representa integralmente uma arquitetura produtiva de alta criticidade.

Essas decisões são intencionais e estão documentadas.

Mais detalhes:

`docs/costs.md`

---

## AWS Well-Architected Framework

A arquitetura foi analisada considerando os principais pilares do **AWS Well-Architected Framework**:

- Operational Excellence;
- Security;
- Reliability;
- Performance Efficiency;
- Cost Optimization;
- Sustainability.

A análise está disponível em:

`docs/well-architected.md`

---

## Testes realizados

A PoC foi validada através de diferentes testes.

### Testes da aplicação

- testes automatizados da API;
- teste local da aplicação;
- teste da imagem Docker;
- health check.

### Testes de infraestrutura

- validação do Terraform;
- teste de Auto Scaling;
- teste de falha de task;
- teste de health check/ALB;
- teste de alarmes CloudWatch.

### Testes de segurança

- teste de acesso permitido a imagens;
- teste de acesso negado a objetos analíticos;
- validação de IAM com menor privilégio;
- utilização de Secrets Manager.

### Testes analíticos

- ingestão RDS → S3;
- transformação RAW → CURATED;
- catálogo no Glue;
- consultas no Athena;
- validação de indicadores comerciais.

---

## Estrutura do projeto

```text
modaviva-aws-architecture/
│
├── app/
│   ├── main.py
│   ├── database.py
│   ├── config.py
│   └── requirements.txt
│
├── analytics/
│   └── lambda_ingest/
│
├── infra/
│   ├── network.tf
│   ├── security_groups.tf
│   ├── ecs.tf
│   ├── rds.tf
│   ├── s3.tf
│   ├── lambda.tf
│   ├── iam.tf
│   └── ...
│
├── tests/
│   └── test_api.py
│
├── docs/
│   ├── adr/
│   │   ├── ADR-001-ecs-fargate.md
│   │   ├── ADR-002-rds-single-az-poc.md
│   │   └── ADR-003-analytics-s3-athena.md
│   │
│   ├── architecture/
│   │   └── architecture.md
│   │
│   ├── costs.md
│   └── well-architected.md
│
├── data/
│   ├── raw/
│   └── processed/
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── cd.yml
│
└── README.md
```

---

## Architecture Decision Records

As principais decisões arquiteturais foram documentadas utilizando ADRs.

### ADR-001 — ECS + Fargate

Decisão pela utilização de containers gerenciados pelo ECS/Fargate para reduzir a necessidade de administração de servidores e facilitar escalabilidade.

### ADR-002 — RDS Single-AZ na PoC

Decisão de utilizar Single-AZ para controlar custos durante o desenvolvimento do projeto, mantendo Multi-AZ como evolução para um ambiente de produção.

### ADR-003 — S3 + Athena para Analytics

Decisão de separar as consultas analíticas do banco transacional utilizando S3, Lambda, Glue e Athena.

---

## Limitações da PoC

Este projeto não representa uma arquitetura de produção completa.

Entre as principais limitações estão:

- RDS Single-AZ;
- ausência de disaster recovery multi-region;
- ausência de NAT Gateway;
- ausência de SQS na pipeline atual;
- ambiente dimensionado para uma PoC;
- controles de backup e retenção reduzidos para controle de custos.

Essas limitações foram mantidas de forma consciente para equilibrar **aprendizado, complexidade e custo**.

---

## Evoluções futuras

Em uma evolução para produção, poderiam ser avaliados:

- RDS Multi-AZ;
- estratégia de disaster recovery;
- NAT Gateway ou alternativa de conectividade de saída;
- SQS entre etapas da pipeline analítica;
- políticas de backup e retenção mais robustas;
- maior automação de rollback;
- testes de carga mais próximos do comportamento real;
- centralização e expansão das métricas de negócio;
- políticas adicionais de proteção e governança.

---

## Principais aprendizados

O projeto foi desenvolvido com foco não apenas na implementação dos serviços AWS, mas no processo de **Solutions Architecture**:

```text
Problema de negócio
        ↓
Levantamento de requisitos
        ↓
Identificação de riscos e restrições
        ↓
Decisões arquiteturais
        ↓
Implementação
        ↓
Testes
        ↓
Análise de segurança
        ↓
Observabilidade
        ↓
Análise de custos
        ↓
Documentação
```

O principal objetivo da PoC foi demonstrar que uma arquitetura não deve ser definida apenas pelos serviços disponíveis, mas pela relação entre **requisitos, trade-offs, segurança, confiabilidade, desempenho e custo**.

---

## Sobre o projeto

**ModaViva** foi desenvolvido como projeto de portfólio para aprofundar conhecimentos em **AWS Solutions Architecture, Cloud, Infrastructure as Code, CI/CD, segurança, observabilidade e análise de dados**.

### Tecnologias

`AWS` · `Terraform` · `Docker` · `Python` · `FastAPI` · `PostgreSQL` · `ECS` · `Fargate` · `ALB` · `RDS` · `S3` · `Lambda` · `Glue` · `Athena` · `CloudWatch` · `IAM` · `Secrets Manager` · `ECR` · `GitHub Actions`

---

## Documentação

- [Architecture](docs/architecture/architecture.md)
- [ADR-001 — ECS + Fargate](docs/adr/ADR-001-ecs-fargate.md)
- [ADR-002 — RDS Single-AZ PoC](docs/adr/ADR-002-rds-single-az-poc.md)
- [ADR-003 — Analytics com S3 + Athena](docs/adr/ADR-003-analytics-s3-athena.md)
- [Costs](docs/costs.md)
- [AWS Well-Architected](docs/well-architected.md)
