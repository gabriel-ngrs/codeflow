---
versão: 1.0
status: estável
atualizado: 2026-05-23
granularidade: magro
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: review-only

> **Spec de runtime:** a referência a `SPEC.md §x` neste workflow aponta para `~/.codeflow/framework/core/SPEC.md`.

## Quando usar
Revisar diff produzido pelo usuário ou por outra sessão da IA, sem modificar código.

## Quando NÃO usar
- Para aplicar correções → use `/bugfix` ou `/refactor-safe`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Protocolo

### Passo 1 — Ler diff
Carregar diff via `git diff`. Não modificar arquivos.

### Passo 2 — Avaliar contra rules e manifest
Anotar violações, riscos e sugestões.

## Definition of Done
- [ ] Diff lido na íntegra.
- [ ] Cada arquivo avaliado contra rules carregadas.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
