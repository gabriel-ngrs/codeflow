---
versão: 1.0
status: estável
atualizado: 2026-05-23
---

# andaime/ — documentos-fonte do codeflow

Esta pasta contém os documentos que especificam o codeflow e guiam sua construção. Não fazem parte do framework instalado em `~/.codeflow/` — são o insumo a partir do qual o Claude Code (ou agente equivalente) monta o framework, conforme `SPEC.md` §2.2.

Documentos previstos:
- `SPEC.md` — especificação normativa do framework.
- `ARTIFACTS_SPEC.md` — schema de cada tipo de arquivo gerado.
- `BUILD_PLAN.md` — ordem e dependências das etapas de construção.
- `VALIDATION.md` — procedimentos de verificação por etapa _(pendente — integração formal na Fase 5)_.
- `PROMPTS.md` — prompts prontos por etapa _(pendente — integração formal na Fase 5)_.
