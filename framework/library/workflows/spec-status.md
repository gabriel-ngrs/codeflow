---
versão: 1.3
status: experimental
atualizado: 2026-06-15
granularidade: magro
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: spec-status

## Quando usar
Mostrar o progresso de uma spec gerada por `/create-spec`: quais fases estão pendentes, aguardando avaliação, reprovadas ou concluídas, e qual é o próximo passo. Read-only — não executa nem avalia nada.

## Quando NÃO usar
- Para executar a próxima fase → use `/execute-spec-phase`.
- Para avaliar uma fase → use `/evaluate-spec-phase`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Protocolo

### Passo 1 — Carregar a spec e os artefatos
**Trocar para a branch de trabalho da spec** (`spec/<slug>`, ou a do `branch` do EXECUCAO/manifest); se ela não existir, **abortar** avisando que a spec não foi criada — não produzir uma tabela silenciosamente errada em `main`. Localizar `.codeflow/specs/<slug>/SPEC_<NAME>.md`; se faltar `## 5. Plano de desenvolvimento por fases`, **abortar** (spec sem plano de fases — nada a reportar). Extrair as fases de §5 (com `id` e `Depende de`). Ler o frontmatter de cada `FASE-*-EXECUCAO.md` (`fase`, `tentativa`, `reprovacoes`, `branch`) e `FASE-*-AVALIACAO.md` (`fase`, `tentativa`, `veredito`, `score`), casando os dois pelo `id`. Read-only: não modificar arquivos.

### Passo 2 — Classificar cada fase e reportar
Para cada fase de §5, derivar **um único** estado, sempre pareando EXECUCAO/AVALIACAO pela `tentativa`: **pendente** (sem EXECUCAO para o `id`); **aguardando avaliação** (EXECUCAO `tentativa: T` sem AVALIACAO de `tentativa: T` — rework recém-feito cai aqui: AVALIACAO antiga de tentativa < T não conta); **reprovada** (AVALIACAO de `tentativa == EXECUCAO.tentativa`, `veredito: REPROVADO`/`RESSALVAS`); **concluída** (idem com `veredito: APROVADO`). Só `APROVADO` conclui; `RESSALVAS` é rework. O pareamento por `tentativa` desambigua "reprovada" vs "aguardando". Apresentar a tabela `Fase (id) | Estado | Tentativa | Reprovações | Score | Próximo passo` e o próximo comando: reprovada → `/execute-spec-phase`; aguardando → `/evaluate-spec-phase`; 1ª pendente com dependências (ids) concluídas → `/execute-spec-phase`; pendente bloqueada → indicar o `id` faltante; todas concluídas → "spec concluída".

## Definition of Done
- [ ] Na branch de trabalho da spec; spec localizada e fases de §5 extraídas (ou abortado se branch/§5 ausentes).
- [ ] Cada fase classificada pelo frontmatter dos artefatos (não por prosa), pareando EXECUCAO/AVALIACAO pela `tentativa`.
- [ ] Tabela de progresso + próximo passo apresentados; nada modificado.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
