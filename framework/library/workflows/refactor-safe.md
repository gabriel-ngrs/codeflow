---
versão: 1.0
status: estável
atualizado: 2026-05-23
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: refactor-safe

## Quando usar
Refatorar código existente sem alterar comportamento observável. Há cobertura de testes suficiente para detectar regressão e o objetivo é melhorar legibilidade, dividir função grande, renomear identificadores ou extrair abstração já justificada.

## Quando NÃO usar
- Para corrigir bug → use `/bugfix`. Refactor-safe não muda comportamento.
- Para adicionar feature → use `/feature-small`.
- Para refatoração que muda contrato público ou exige decisão arquitetural → discutir em chat antes; pode exigir decision dedicada e plano de migração.
- Quando a cobertura de testes da área é insuficiente para detectar regressão → adicionar testes primeiro (rota `/feature-small` ou `/bugfix` conforme o caso) antes de refatorar.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Antes de começar
Conferir `.codeflow/manifest.md` para confirmar comando de teste padrão. Se a área tocada tem decisions ATIVAS, carregar antes para evitar refatoração que conflita com escolha registrada.

## Protocolo

### Passo 1 — Snapshot de testes existentes
- Identificar testes que cobrem a área a ser refatorada.
- Executar `make check` antes de qualquer mudança e registrar o resultado de referência.
- Gate: todos os testes relevantes passam antes do refactor. Se algum já falha, parar — refactor-safe exige base verde.

### Passo 2 — Identificar refatoração
- Declarar por escrito o tipo de mudança (extrair função, renomear, dividir, mover, inlining).
- Identificar arquivos afetados e confirmar que o conjunto é limitado.
- Gate: a refatoração preserva comportamento. Se exige mudança de contrato público, parar e indicar workflow alternativo.

### Passo 3 — Aplicar mudança
- Diff mínimo conforme constitution universal.
- Não adicionar feature nem corrigir bug latente identificado no caminho — anotar para tarefa separada.
- Em mudanças mecânicas (rename), preferir uma operação por commit lógico para facilitar revisão.

### Passo 4 — Confirmar testes passam idênticos
- Re-executar a mesma suíte do Passo 1.
- Gate: resultado idêntico ao snapshot. Qualquer teste que mudou de status sinaliza alteração de comportamento — reverter e investigar.

### Passo 5 — Validar
- Executar `make check` completo (ou alternativas conforme `.codeflow/manifest.md`).
- Aplicar skill `self-review` com atenção especial a: refatoração que vazou para fora do escopo, mudanças cosméticas adjacentes, comentários novos que explicam o quê em vez de o por quê.
- Se `make check` falha: aplicar política de falhas da constitution.

### Passo 6 — Resumir
- Apresentar resumo final no formato fixo de cinco seções.
- Como `gera_decision: no`, não gerar decision por padrão. Caso o refactor tenha revelado uma escolha de design que vale registrar (raro), discutir com o usuário antes de criar decision.

## Definition of Done
- [ ] Snapshot de testes verde antes do refactor.
- [ ] Tipo de refatoração declarado por escrito.
- [ ] Diff dentro do escopo declarado, sem feature ou fix lateral.
- [ ] Testes passam idênticos ao snapshot (mesmos passando, mesmos falhando).
- [ ] `make check` retornou zero.
- [ ] Self-review aplicado.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
