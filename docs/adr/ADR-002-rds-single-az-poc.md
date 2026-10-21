# ADR-002 — RDS Single-AZ na PoC

## Status
Aceito

## Contexto
A arquitetura de produção da ModaViva necessita de maior disponibilidade do banco de dados. Entretanto, a PoC possui uma restrição de custo e busca utilizar uma configuração compatível com o ambiente de aprendizado.

## Decisão
Utilizar Amazon RDS PostgreSQL em configuração Single-AZ na PoC.

O banco possui armazenamento criptografado, backups automáticos e credenciais armazenadas no AWS Secrets Manager.

## Alternativas consideradas
- RDS Multi-AZ: maior disponibilidade e failover automático, porém com custo adicional.
- RDS Single-AZ: menor custo e suficiente para validar a integração da aplicação com o banco.

## Consequências
Positivas:
- Menor custo para a PoC.
- Banco gerenciado pela AWS.
- Criptografia e integração com Secrets Manager.
- Permite validar a arquitetura de aplicação e banco.

Negativas:
- Não atende completamente ao requisito de redundância de banco.
- Uma falha da zona de disponibilidade pode indisponibilizar o banco.

## Evolução
Em produção, utilizar RDS Multi-AZ para aumentar a disponibilidade e reduzir o impacto de falhas da zona de disponibilidade.
