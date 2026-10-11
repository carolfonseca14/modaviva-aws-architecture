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

### Aplicação

- Até 2.000 acessos/dia em períodos normais;
- 15.000–20.000 acessos/dia durante campanhas;
- Até 2.000 compras/dia durante campanhas;
- Até 150 compras/hora nos períodos de maior demanda.

### Disponibilidade e recuperação

- Aplicação distribuída em múltiplas zonas de disponibilidade;
- Redundância do banco de dados;
- Detecção de falhas na aplicação;
- Escalabilidade automática;
- Redução do tempo de recuperação após falhas.

### Segurança

- Controle de acesso baseado em menor privilégio;
- Secrets fora do código-fonte;
- Proteção de dados pessoais;
- Separação entre componentes públicos e internos.

### Dados e analytics

- Separação entre cargas transacionais e analíticas;
- Transferência incremental de dados;
- Armazenamento analítico no Amazon S3;
- Consultas utilizando Amazon Athena;
- Dados preparados para análise de campanhas.

## Arquitetura planejada

A arquitetura será construída utilizando serviços AWS como:

- Amazon VPC
- Application Load Balancer
- Amazon ECS
- AWS Fargate
- Amazon RDS
- Amazon S3
- Amazon Athena
- AWS Lambda
- AWS IAM
- AWS Secrets Manager
- Amazon CloudWatch
- Amazon ECR

A arquitetura será implementada gradualmente e poderá ser ajustada conforme os resultados dos testes e da PoC.

## Tecnologias

- Python
- Docker
- Terraform
- GitHub
- GitHub Actions
- AWS

## Estrutura do projeto

```text
app/          Aplicação Python
analytics/    Componentes relacionados ao pipeline analítico
infra/        Infraestrutura como código
tests/        Testes da aplicação e da infraestrutura
docs/         Documentação e decisões arquiteturais
data/         Dados utilizados pela PoC
.github/      Workflows de CI/CD