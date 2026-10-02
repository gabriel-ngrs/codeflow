---
versão: 1.0
status: estável
atualizado: 2026-10-02
schema_version: 1.0
---

# INDEX do .codeflow/ do projeto

## Leia sempre primeiro
1. `constitution.md` — regras invariantes do repositório do framework: pasta principal, ramos, merge, core, catálogo.
2. `manifest.md` — stack, gates de validação do framework, padrões detectados.

## Leia se relevante ao contexto
- `decisions/INDEX.md` — índice de decisões. Filtrar por tag relevante antes de carregar decisions individuais.
- `workflows/orquestrar-*.md` — roteiros dos orquestradores das trilhas `evolucao` e `auditoria`.

## Arquivos gerados automaticamente — não editar manualmente
- `checkpoints/*` — estado intermediário de workflows em execução. Efêmero, está no `.gitignore`.
- `decisions/<data>-<titulo>.md` — decisões individuais. Alterações manuais quebram o índice.

## Versão do schema e última atualização
Schema 1.0 | Última atualização: 2026-10-02 | Gerado por: fundação manual no formato de discover
