# AWS Well-Architected Framework — ModaViva

## Visão geral

A arquitetura da ModaViva foi analisada considerando os seis pilares do AWS Well-Architected Framework.

A análise considera o estado atual da PoC e diferencia explicitamente os pontos já implementados das evoluções recomendadas para um ambiente de produção.

---

## 1. Excelência Operacional

### Implementado

- Infraestrutura provisionada e gerenciada com Terraform.
- Pipeline de CI para testes da aplicação e validação do Terraform.
- Pipeline de CD com GitHub Actions.
- Autenticação do GitHub Actions na AWS utilizando OIDC.
- Logs e métricas centralizados no Amazon CloudWatch.
- Alarmes configurados para CPU, memória e quantidade de tasks ECS.
- Dashboard operacional no CloudWatch.
- ADRs documentando decisões arquiteturais.

### Evolução

Para produção, seria possível ampliar os processos de observabilidade, adicionar procedimentos formais de incident response e automatizar ainda mais os testes de infraestrutura.

---

## 2. Segurança

### Implementado

- Aplicação ECS executada em subnets privadas.
- RDS executado sem exposição pública.
- Security Groups restringindo a comunicação entre as camadas.
- Secrets Manager utilizado para armazenar credenciais do banco.
- IAM com funções separadas para ECS, Lambda e GitHub Actions.
- GitHub Actions utiliza OIDC em vez de credenciais AWS permanentes.
- Buckets S3 com bloqueio de acesso público.
- Dados armazenados em serviços AWS com criptografia.
- Não são armazenados dados completos de cartão de pagamento.
- A arquitetura segue o princípio de menor privilégio sempre que possível.

### Evolução

Em produção, seria recomendável ampliar políticas de proteção de dados, auditoria de acesso e controles específicos de LGPD, além de avaliar serviços como AWS KMS, CloudTrail e GuardDuty conforme o nível de criticidade.

---

## 3. Confiabilidade

### Implementado

- Aplicação distribuída em duas Availability Zones.
- Application Load Balancer distribuindo o tráfego.
- ECS Fargate com Auto Scaling entre 2 e 4 tasks.
- Health checks da aplicação.
- RDS com backups automatizados.
- Monitoramento de disponibilidade das tasks e dos targets do ALB.
- Teste de falha de uma task ECS realizado com sucesso.
- Teste de escalabilidade durante carga realizado com sucesso.

### Limitação conhecida da PoC

O RDS está configurado como Single-AZ por decisão de custo para o laboratório.

Portanto, a PoC não representa uma arquitetura de banco totalmente redundante.

### Evolução para produção

Utilizar RDS Multi-AZ, aumentar a retenção de backups e definir formalmente RTO e RPO de acordo com os requisitos do negócio.

---

## 4. Eficiência de Performance

### Implementado

- ECS Fargate permite dimensionamento horizontal das tasks.
- Auto Scaling baseado em utilização média de CPU.
- ALB distribui requisições entre as tasks disponíveis.
- S3 utilizado para armazenamento dos dados analíticos.
- Athena utilizado para consultas analíticas sem necessidade de manter um servidor dedicado de consulta.
- Dados analíticos armazenados em formato Parquet.

### Evolução

Em produção, métricas adicionais poderiam ser utilizadas para scaling, como latência, quantidade de requisições e métricas específicas da aplicação.

---

## 5. Otimização de Custos

### Implementado

- ECS Fargate utilizado para evitar gerenciamento de servidores.
- Tasks pequenas dimensionadas para a PoC.
- RDS utilizando instância pequena.
- Ausência de NAT Gateway na PoC para evitar custo recorrente.
- S3 utilizado para armazenamento de objetos e dados analíticos.
- Athena utilizado sob demanda.
- Auto Scaling permite reduzir recursos quando a demanda diminui.
- Recursos podem ser destruídos com Terraform após os testes.

### Trade-offs

Algumas escolhas reduzem o custo da PoC, mas não representam necessariamente a configuração recomendada para produção.

O principal exemplo é o RDS Single-AZ.

---

## 6. Sustentabilidade

### Implementado

- Uso de serviços gerenciados e serverless quando aplicável.
- Auto Scaling para ajustar a capacidade à demanda.
- Armazenamento de dados analíticos em S3.
- Dimensionamento pequeno dos recursos durante a PoC.
- Desligamento/destruição dos recursos quando não utilizados.

### Evolução

Em produção, seria possível acompanhar métricas de utilização e realizar revisões periódicas de right-sizing para evitar recursos subutilizados.

---

# Resumo

| Pilar | Situação |
|---|---|
| Excelência Operacional | Implementado |
| Segurança | Implementado |
| Confiabilidade | Implementado com limitação no RDS |
| Eficiência de Performance | Implementado |
| Otimização de Custos | Implementado |
| Sustentabilidade | Considerado |

## Principais trade-offs

1. RDS Single-AZ foi escolhido para reduzir o custo da PoC.
2. NAT Gateway não foi utilizado para evitar custo recorrente.
3. ECS Fargate foi escolhido em vez de EC2 para reduzir esforço operacional.
4. Analytics foi separado do workload transacional utilizando S3, Glue e Athena.

## Evolução para produção

Uma arquitetura de produção deveria considerar, entre outros pontos:

- RDS Multi-AZ;
- política de backup alinhada ao RPO;
- RTO formalizado;
- controles adicionais de LGPD;
- observabilidade e auditoria ampliadas;
- revisão de conectividade e egress;
- testes de disaster recovery.