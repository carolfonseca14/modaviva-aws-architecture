# ADR-001 — Uso de ECS Fargate

## Status
Aceito

## Contexto
A ModaViva precisa executar uma API containerizada com disponibilidade em múltiplas zonas de disponibilidade e capacidade de aumentar o número de tarefas durante campanhas.

A PoC também busca reduzir a complexidade operacional, evitando o gerenciamento direto de servidores.

## Decisão
Utilizar Amazon ECS com AWS Fargate para executar a API da ModaViva.

A aplicação é executada em tarefas Fargate em subnets privadas, atrás de um Application Load Balancer. O serviço utiliza Auto Scaling baseado na utilização média de CPU, com mínimo de 2 e máximo de 4 tarefas.

## Alternativas consideradas
- EC2 com Auto Scaling: oferece maior controle, porém exige gerenciamento de instâncias.
- ECS Fargate: reduz a responsabilidade operacional sobre servidores e atende ao objetivo da PoC.

## Consequências
Positivas:
- Menor gerenciamento de infraestrutura.
- Integração com ALB e Auto Scaling.
- Execução em múltiplas zonas de disponibilidade.
- Escalabilidade horizontal.

Negativas:
- Fargate pode ter custo maior que EC2 em determinados cenários.
- Menor controle sobre o ambiente de execução.

## Evolução
Para produção, os limites de escalabilidade e capacidade devem ser recalibrados com base em métricas reais de tráfego e custo.
