---
versão: 1.0
status: estável
atualizado: 2026-06-14
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
Localizar `.codeflow/specs/<slug>/SPEC_<NAME>.md` (slug indicado pelo usuário) e extrair a lista ordenada de fases de `## 5. Plano de desenvolvimento por fases`. Ler o **frontmatter** de cada `FASE-*-EXECUCAO.md` e `FASE-*-AVALIACAO.md` em `artefatos/` (campos `fase`, `status`, `tentativa`, `veredito`, `score`). Não modificar nada.

### Passo 2 — Classificar cada fase e reportar
Para cada fase de §5, derivar o estado pelos campos (nunca por prosa): **pendente** (sem EXECUCAO), **aguardando avaliação** (EXECUCAO sem AVALIACAO da tentativa atual), **reprovada** (`veredito: REPROVADO`/`RESSALVAS`), **concluída** (`veredito: APROVADO`). Apresentar uma tabela `Fase | Estado | Tentativa | Score | Próximo passo` e, ao fim, o próximo comando a rodar (`/execute-spec-phase` ou `/evaluate-spec-phase`) ou "spec concluída".

## Definition of Done
- [ ] Spec localizada e fases de §5 extraídas.
- [ ] Cada fase classificada pelo frontmatter dos artefatos (não por prosa).
- [ ] Tabela de progresso + próximo passo apresentados; nada modificado.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
