---
versão: 1.0
status: estável
atualizado: 2026-06-25
granularidade: magro
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: design-pass

## Quando usar
Dar um trato de excelência visual numa interface já existente (tela legada, UI que não nasceu pelo pipeline de spec, ou pedido pontual "melhora essa tela"). Aplica as três skills de design e corrige o que elas apontarem.

## Quando NÃO usar
- Construindo UI dentro de uma fase de spec → as três skills já são carregadas pelo `/execute-spec-phase`; não rode este workflow em paralelo.
- Para corrigir bug de comportamento (não estético) → use `/bugfix`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/library/skills/avoid-ai-look/SKILL.md
- ~/.codeflow/framework/library/skills/accessibility-audit/SKILL.md
- ~/.codeflow/framework/library/skills/visual-consistency/SKILL.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Protocolo

### Passo 1 — Delimitar o alvo
Identificar os arquivos de UI a tratar e declarar o escopo esperado. Não sair dele sem justificar.

### Passo 2 — Auditar com as três skills
Aplicar `avoid-ai-look`, `accessibility-audit` e `visual-consistency` sobre o alvo. Consolidar os achados das três numa lista única `arquivo:linha — achado — correção`.

### Passo 3 — Corrigir
Aplicar as correções da lista, diff mínimo, sem refatoração lateral. Achado que opta-se por não corrigir fica registrado com o motivo.

### Passo 4 — Validar
Rodar os comandos de validação do projeto (do `.codeflow/manifest.md`) sobre os arquivos tocados e aplicar a skill `self-review` no diff. Gate ausente no projeto → `[—]` justificado.

## Definition of Done
- [ ] Escopo declarado no Passo 1.
- [ ] As três skills aplicadas e achados consolidados numa lista.
- [ ] Correções aplicadas dentro do escopo, ou não-correção registrada com motivo.
- [ ] Comandos de validação retornaram zero (ou `[—]` justificado) e self-review aplicado.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
