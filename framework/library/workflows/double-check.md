---
versão: 1.0
status: estável
atualizado: 2026-07-02
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: double-check

> **Spec de runtime:** a referência a `SPEC.md §x` neste workflow aponta para `~/.codeflow/framework/core/SPEC.md`.

## Quando usar
Verificar, contra um lote de bugs, se as correções realmente sanaram cada bug — tentando **reproduzi-los de novo** e rodando toda a validação possível do projeto. Entrada natural: o ledger `.codeflow/bug-batches/<slug>.md` produzido pelo `/batch-bugfix`. Também aceita um documento bruto de bugs (`.txt`/`.md`/`.csv`/planilha), que é normalizado antes de verificar.

## Quando NÃO usar
- Para **corrigir** bugs → usar `/batch-bugfix` (lote) ou `/bugfix` (avulso). Este workflow só confere, nunca aplica fix.
- Para rodar a suíte de testes sem um lote de referência → rodar os comandos do projeto direto no chat; não há o que verificar bug a bug.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/workflows/batch-bugfix.md
- ~/.codeflow/framework/library/skills/debug-protocol/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Antes de começar
- Este workflow **não modifica código de produção.** Se ele encontrar um bug ainda reproduzível (regrediu ou nunca foi sanado), o veredito é registrado e o bug é devolvido ao `/batch-bugfix` ou `/bugfix` — corrigir aqui violaria a separação de responsabilidades.
- A fonte de verdade é o ledger `.codeflow/bug-batches/<slug>.md` (formato definido no `/batch-bugfix`). Se receber um documento bruto sem ledger, normalizá-lo primeiro (mesmo Passo 1 do `/batch-bugfix`) para ter contra o que verificar.

## Protocolo

### Passo 1 — Localizar a fonte de verdade
- Se apontado a um ledger existente, carregá-lo. Se apontado a um documento bruto, normalizá-lo num ledger `.codeflow/bug-batches/<slug>.md` (bugs entram como `pendente`, sem info de fix).
- Gate: ledger carregado com ≥1 bug a verificar. Se nada é parseável, parar e pedir esclarecimento.

### Passo 2 — Reproduzir cada bug
- Para cada bug do ledger, executar a **sequência de reprodução** registrada (do ledger ou do documento). Rodar o teste de regressão associado ao fix, quando existir.
- Aplicar a disciplina do `debug-protocol`: reproduzir de fato antes de concluir qualquer coisa — não inferir "provavelmente sanado" de cabeça.
- Gate: cada bug tem um resultado de reprodução observável (reproduz / não reproduz / repro indisponível).

### Passo 3 — Julgar a sanidade e marcar o ledger
- Traduzir cada resultado do Passo 2 na coluna `verificação` do ledger:
  - `✓` — bug **não** reproduz mais: sanado.
  - `✗` — bug **ainda** reproduz: não sanado ou regrediu.
  - `⚠` — sem reprodução determinística possível: inconclusivo (registrar por quê).
- Carimbar cada linha com a data da verificação. Gate: nenhum bug fica com `verificação: —`.

### Passo 4 — Rodar toda a validação do projeto
- Rodar a **suíte completa** de validação do projeto (do `.codeflow/manifest.md`; se ausente, inferir do stack): testes, lint, type-check e build — tudo o que o projeto oferece. Aqui, ao contrário do fix, roda-se o máximo, não o mínimo: o objetivo é caçar regressão colateral fora dos bugs listados.
- Gate que não existe no projeto → `[—]` justificado (SPEC §3.10). Registrar o resultado agregado (verde / falhas) no relatório.

### Passo 5 — Relatório de verificação
- Apresentar o resumo final (cinco seções fixas) com o **placar de verificação**: X sanados (`✓`), Y não sanados/regrediram (`✗`), Z inconclusivos (`⚠`), mais o resultado da suíte completa.
- Listar explicitamente os `✗` e `⚠` como pendências, cada um com a ação sugerida (reentrada no `/batch-bugfix`/`/bugfix`, ou mais informação para tornar reproduzível).
- Deixar o ledger salvo com a coluna `verificação` preenchida — é o registro de que o lote foi conferido.

## Definition of Done
- [ ] Ledger localizado ou normalizado a partir do documento bruto (Passo 1).
- [ ] Cada bug teve tentativa de reprodução observável (Passo 2).
- [ ] Coluna `verificação` preenchida para todo bug — nenhum `—` restante (Passo 3).
- [ ] Suíte completa de validação do projeto rodada (ou `[—]` justificado) (Passo 4).
- [ ] Placar de verificação apresentado e pendências (`✗`/`⚠`) listadas com ação sugerida.
- [ ] Nenhum código de produção modificado por este workflow.
- [ ] Ledger salvo com os vereditos de verificação.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4, incluindo o placar de verificação na seção "O que foi feito".
