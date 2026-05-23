---
versão: 1.0
status: estável
atualizado: 2026-05-23
granularidade: médio
gera_decision: auto
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: feature-small

## Quando usar
Adicionar feature nova de escopo limitado a poucos arquivos, com interface clara e sem dependência de decisão arquitetural maior. Pré-requisito: o usuário consegue declarar a feature em uma frase e identificar onde ela entra no código existente.

## Quando NÃO usar
- Para correção de bug em código existente → use `/bugfix`.
- Para mudança que altera contrato público de módulo grande ou múltiplos serviços → discutir arquitetura em chat antes; pode exigir decision dedicada.
- Para feature que exige conversa estruturada com o usuário durante execução → use workflow detalhado.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/core/rules/naming.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Antes de começar
Se a feature toca áreas com decisions arquivadas (auth, payments, schema, integrações externas), consultar `.codeflow/decisions/INDEX.md` e carregar decisions ATIVAS por tag. Conferir se há rule de projeto que muda o protocolo padrão.

## Protocolo

### Passo 1 — Confirmar escopo
- Reescrever a feature em uma frase, listando entradas, saídas e arquivos afetados.
- Identificar comportamento esperado e o que continua igual.
- Gate: escopo cabe em poucos arquivos e não toca decision arquitetural. Se não cabe, parar e propor split.

### Passo 2 — Desenhar interface
- Definir assinatura pública (função, endpoint, comando, componente) antes de implementar.
- Confirmar consistência com convenções do projeto via `manifest.md` e rule de `naming`.
- Gate: interface declarada por escrito, antes do código.

### Passo 3 — Implementar
- Diff mínimo conforme constitution universal.
- Tocar apenas os arquivos identificados no Passo 1.
- Refatoração lateral fica fora do escopo.

### Passo 4 — Testar
- Adicionar teste cobrindo o comportamento novo. Teste descreve comportamento, não implementação.
- Cobrir pelo menos um caso feliz e um caso de borda relevante.
- Gate: testes novos passam; testes antigos continuam passando.

### Passo 5 — Validar
- Executar `make check` (ou alternativas conforme `.codeflow/manifest.md`).
- Aplicar skill `self-review` no diff produzido.
- Se `make check` falha: aplicar política de falhas da constitution.

### Passo 6 — Resumir e (se aplicável) gerar decision
- Apresentar resumo final no formato fixo de cinco seções.
- Se a feature introduziu padrão novo, dependência nova, ou escolha entre alternativas relevantes, gerar decision em `.codeflow/decisions/`.

## Definition of Done
- [ ] Escopo confirmado e cabe em poucos arquivos.
- [ ] Interface declarada antes da implementação.
- [ ] Diff dentro do escopo declarado, sem refatoração lateral.
- [ ] Testes do comportamento novo presentes e passando.
- [ ] `make check` retornou zero.
- [ ] Self-review aplicado.
- [ ] Decision gerada se aplicável (gera_decision: auto).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
