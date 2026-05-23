---
versão: 1.0
status: estável
atualizado: 2026-05-23
escopo: universal
---

# Rule: testing

## Quando carregar

Workflows devem carregar esta rule quando a tarefa envolve criação ou modificação de código de produção, fix de bug, ou refatoração. Workflows puramente documentais ou de revisão podem omitir.

## Regras

- Todo código novo deve ter teste correspondente. Sem teste, o código não está pronto.
- Bugfix deve incluir teste de regressão que falharia antes do fix e passa depois.
- Teste descreve **comportamento**, não implementação. Nomes de teste expressam o que o sistema faz, não como.
- Teste é determinístico. Flakiness é tratado como bug, não como tolerância.
- Setup compartilhado entre testes vive em fixture ou helper claro, não duplicado.

## Anti-regras

- Não deletar teste para fazê-lo passar. Teste que falha sinaliza problema no código ou no próprio teste — investigar, não silenciar.
- Não criar teste apenas para satisfazer cobertura. Teste sem asserção real é ruído.
- Não testar implementação interna privada quando comportamento público cobre o caso.
- Não introduzir teste flaky com `retry` ou `skip` sem registrar decision explicando.

## Exceções

- **Spike exploratório:** código de prova de conceito explicitamente declarado como descartável pode não ter testes. Condição: o spike vive em pasta marcada (`spikes/`, `prototypes/`) e não é mergeado para `main`.
- **Migração de dados única:** scripts de migração executados uma vez podem prescindir de teste de regressão. Continua valendo: o script deve ser idempotente e revisado antes da execução.
