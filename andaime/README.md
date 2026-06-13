---
versão: 1.0
status: estável
atualizado: 2026-05-23
---

# andaime/ — documentos de construção do codeflow

Esta pasta contém os documentos que guiaram a construção do codeflow. São o insumo a partir do qual o Claude Code (ou agente equivalente) montou o framework — registro de processo, não artefato de runtime.

Documentos:
- `BUILD_PLAN.md` — ordem e dependências das etapas de construção.
- `VALIDATION.md` — procedimentos de verificação por etapa.
- `PROMPTS.md` — prompts prontos por etapa.
- `EXECUTION_LOG.md` — log incremental das etapas concluídas no `BUILD_PLAN`.

> **`SPEC.md` e `ARTIFACTS_SPEC.md` foram promovidos para `framework/core/`.**
> São contratos normativos lidos em **runtime** pelas meta-skills (que aplicam os
> templates literais de `ARTIFACTS_SPEC.md §x.5`) e pelos workflows — portanto
> moram no framework instalado, não no andaime. Os build docs acima ainda os
> citam pelo path antigo (`andaime/SPEC.md`, `andaime/ARTIFACTS_SPEC.md`): são
> registro histórico do estado durante a construção e não foram reescritos.
