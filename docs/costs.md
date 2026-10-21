# Análise de custos — ModaViva

## Objetivo

A PoC foi projetada para validar a arquitetura da ModaViva com baixo custo,
priorizando serviços gerenciados e evitando componentes que gerariam custos
fixos desnecessários durante o desenvolvimento.

## Principais decisões

| Componente | Decisão | Motivo |
|---|---|---|
| ECS | Fargate | Evita administrar servidores EC2 e permite ajustar a capacidade à demanda |
| Auto Scaling | 2 a 4 tasks | Mantém capacidade mínima para alta disponibilidade e escala durante picos |
| RDS | db.t4g.micro | Capacidade adequada para a PoC |
| RDS Multi-AZ | Não habilitado na PoC | Redução de custo; evolução prevista para produção |
| NAT Gateway | Não utilizado | Evita custo recorrente significativo em uma PoC |
| S3 | Utilizado para imagens e analytics | Armazenamento gerenciado e adequado para objetos |
| Athena | Consultas sob demanda | Evita manter um ambiente analítico dedicado |
| Lambda | Processamento incremental | Executa processamento somente quando necessário |
| VPC Endpoints | Utilizados | Permitem comunicação privada com serviços AWS sem NAT Gateway |
| Terraform | Create/Destroy por código | Facilita remover recursos quando a PoC não estiver em uso |

## Trade-offs

A principal decisão de custo foi manter o RDS em Single-AZ durante a PoC.
Essa escolha reduz o custo, mas não atende completamente ao requisito de
redundância do banco de dados.

Em um ambiente de produção, a evolução recomendada é utilizar RDS Multi-AZ.

A ausência de NAT Gateway também reduz o custo da PoC. Para workloads de
produção que necessitem de acesso de saída à internet a partir das subnets
privadas, essa decisão deverá ser reavaliada.

## Controle de custos

Os recursos da PoC são provisionados com Terraform, permitindo sua criação e
destruição por código.

A arquitetura também utiliza Auto Scaling para evitar manter capacidade
computacional elevada permanentemente.

O orçamento da conta AWS foi configurado separadamente como mecanismo de
controle financeiro, embora a consulta desse orçamento não faça parte das
permissões do usuário IAM utilizado pela PoC.

## Conclusão

A arquitetura prioriza baixo custo durante a validação técnica, mantendo
trade-offs explícitos para os componentes que seriam fortalecidos em um
ambiente de produção.