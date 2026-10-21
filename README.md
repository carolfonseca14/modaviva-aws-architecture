# ModaViva — AWS E-commerce Architecture

PoC de arquitetura AWS para um e-commerce de moda, desenvolvida com foco em escalabilidade, alta disponibilidade, segurança, automação e análise de dados.

## Contexto

A ModaViva é um e-commerce de médio porte que apresenta picos significativos de acesso e vendas durante campanhas.

Na arquitetura atual, a aplicação depende de dois servidores localizados no mesmo datacenter e de um banco de dados central, criando pontos únicos de falha e dificuldades para lidar com aumentos de demanda.

Além disso, os processos de implantação são manuais e os dados utilizados para análise de campanhas estão distribuídos em diferentes fontes.

## Objetivo

Projetar e implementar uma PoC de arquitetura AWS capaz de:

- suportar picos de demanda durante campanhas;
- aumentar a disponibilidade da aplicação;
- reduzir pontos únicos de falha;
- permitir escalabilidade conforme a demanda;
- automatizar o processo de implantação;
- proteger dados sensíveis utilizando controle de acesso adequado;
- separar cargas analíticas das transacionais;
- centralizar dados para análise de campanhas;
- monitorar a aplicação e gerar alertas;
- manter os custos controlados.

## Principais requisitos
# ModaViva — AWS Solutions Architecture PoC

PoC de arquitetura em AWS para uma plataforma fictícia de e-commerce de moda, desenvolvida a partir de um cenário de negócio com crescimento de tráfego em campanhas, indisponibilidade, processo manual de deploy e necessidade de separar workloads transacionais e analíticos.

O projeto foi desenvolvido como estudo prático de **AWS Solutions Architecture**, com foco em arquitetura, segurança, escalabilidade, observabilidade, automação, análise de custos e AWS Well-Architected Framework.

---

## 🎯 Contexto do negócio

A ModaViva possui aproximadamente:

- 2.000 acessos/dia em períodos normais;
- 15.000–20.000 acessos/dia durante campanhas;
- aproximadamente 300 compras/dia normalmente;
- até 2.000 compras/dia durante campanhas;
- picos de aproximadamente 150 compras/hora.

O cenário original apresentava:

- aplicação executando em dois servidores no mesmo datacenter;
- banco de dados central sem redundância;
- indisponibilidade durante campanhas;
- deploys manuais;
- rollback demorado;
- dados de campanha espalhados;
- backups pouco frequentes;
- necessidade de maior controle de acesso e monitoramento.

---

## 🏗️ Arquitetura proposta

A solução utiliza uma arquitetura baseada em serviços gerenciados da AWS.

### Principais componentes

- **Amazon VPC** — isolamento de rede em duas Availability Zones;
- **Application Load Balancer** — distribuição de tráfego;
- **Amazon ECS com Fargate** — execução da API em containers;
- **ECS Service Auto Scaling** — escala entre 2 e 4 tasks;
- **Amazon RDS PostgreSQL** — banco transacional;
- **Amazon S3** — imagens de produtos e plataforma analítica;
- **AWS Lambda** — ingestão e transformação de dados;
- **AWS Glue Data Catalog** — catálogo dos dados analíticos;
- **Amazon Athena** — consultas SQL sobre dados em S3;
- **Amazon CloudWatch** — logs, métricas, dashboard e alarmes;
- **Amazon SNS** — notificações de alertas;
- **AWS Secrets Manager** — armazenamento das credenciais do banco;
- **IAM** — controle de acesso;
- **Amazon ECR** — armazenamento das imagens Docker;
- **GitHub Actions + OIDC** — CI/CD sem credenciais AWS permanentes;
- **Terraform** — infraestrutura como código.

### Diagrama

O diagrama completo está disponível em:

`docs/architecture/architecture.md`

---

## 🔄 Principais fluxos

### Aplicação

```text
Usuário
   ↓
Application Load Balancer
   ↓
ECS / Fargate
   ↓
RDS PostgreSQL