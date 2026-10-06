---
versão: 1.2
status: estável
atualizado: 2026-10-06
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: double-check

> **Spec de runtime:** a referência a `SPEC.md §x` neste workflow aponta para `~/.codeflow/framework/core/SPEC.md`.

## Quando usar
Verificar, contra um lote de bugs, se as correções realmente sanaram cada bug — tentando **reproduzi-los de novo** e rodando a validação do projeto (local, ou pelo CI quando o manifest o declara gate de merge: Passo 4). Entrada natural: o ledger `.codeflow/bug-batches/<slug>.md` produzido pelo `/batch-bugfix`. Também aceita um documento bruto de bugs (`.txt`/`.md`/`.csv`/planilha), que é normalizado antes de verificar.

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
- Para cada bug do ledger, executar a **sequência de reprodução** registrada na coluna `repro/teste` (ou, sem ledger, a do documento). Rodar o teste de regressão apontado ali, quando existir.
- Aplicar a disciplina do `debug-protocol`: reproduzir de fato antes de concluir qualquer coisa — não inferir "provavelmente sanado" de cabeça.
- Gate: cada bug tem um resultado de reprodução observável (reproduz / não reproduz / repro indisponível).

### Passo 3 — Julgar a sanidade e marcar o ledger
- Traduzir cada resultado do Passo 2 na coluna `verificação` do ledger:
  - `✓` — bug **não** reproduz mais: sanado.
  - `✗` — bug **ainda** reproduz: não sanado ou regrediu. Com `reaberturas` < 2 (coluna ausente = `0`), reabrir a linha: setar `status: pendente`, mantendo `verificação: ✗` e somando 1 em `reaberturas`, para que o `/batch-bugfix` a recolha na retomada. Com `reaberturas` = 2, **não reabrir** (teto do ciclo batch-bugfix↔double-check): setar `status: bloqueado` com o motivo "teto de reabertura: decisão do dono" e listar o bug como pendência do dono. Mexer nessa coluna do ledger é coordenação, não código de produção — não viola a separação de responsabilidades.
  - `⚠` — sem reprodução determinística possível: inconclusivo (registrar por quê).
- Carimbar cada linha com a data da verificação. Gate: nenhum bug fica com `verificação: —`.

### Passo 4 — Rodar a validação do projeto
- O objetivo é caçar regressão colateral fora dos bugs listados; o alcance local depende do CI (do `.codeflow/manifest.md`; se ausente, inferir do stack):
  - **Sem** a seção `## CI` no manifest declarando o CI como gate de merge e o que ele cobre: rodar a **suíte completa** — testes, lint, type-check e build, tudo o que o projeto oferece. Aqui, ao contrário do fix, roda-se o máximo, não o mínimo.
  - **Com** essa declaração: rodar localmente só o que o CI **não** cobre (o manifest diz o quê) e conferir o **CI verde** do PR, ou de um run sobre o mesmo sha, como evidência — colar o link ou a saída do run. CI vermelho conta como falha; CI que ainda não rodou sobre o sha fica como pendência no relatório, nomeando o sha.
- Gate que não existe no projeto → `[—]` justificado (SPEC §3.10). Registrar o resultado agregado (verde / falhas) no relatório.

### Passo 5 — Relatório de verificação
- Apresentar o resumo final (cinco seções fixas) com o **placar de verificação**: X sanados (`✓`), Y não sanados/regrediram (`✗`), Z inconclusivos (`⚠`), mais o resultado da validação do Passo 4 (local e, quando declarado, o CI).
- Listar explicitamente os `✗` e `⚠` como pendências, cada um com a ação sugerida (reentrada no `/batch-bugfix`/`/bugfix`, decisão do dono para o bug que esgotou o teto de reabertura, ou mais informação para tornar reproduzível).
- Deixar o ledger salvo com a coluna `verificação` preenchida — é o registro de que o lote foi conferido.

## Definition of Done
- [ ] Ledger localizado ou normalizado a partir do documento bruto (Passo 1).
- [ ] Cada bug teve tentativa de reprodução observável (Passo 2).
- [ ] Coluna `verificação` preenchida para todo bug — nenhum `—` restante; bug com `✗` reaberto só abaixo do teto de 2 reaberturas, e no teto levado a `bloqueado` (Passo 3).
- [ ] Validação do projeto rodada (Passo 4): suíte completa, ou, com o CI declarado gate de merge no manifest, o que o CI não cobre mais o CI verde do sha conferido; ou `[—]` justificado.
- [ ] Placar de verificação apresentado e pendências (`✗`/`⚠`) listadas com ação sugerida.
- [ ] Nenhum código de produção modificado por este workflow.
- [ ] Ledger salvo com os vereditos de verificação.

## Resumo final
Apresentar no formato do resumo final do `SPEC.md` §5.6.4, sem abrir o arquivo para isso: o título `## ✓ CONCLUÍDO: <workflow> — <escopo>` e as cinco seções, na ordem — `### O que foi feito`, `### Checklist Definition of Done`, `### Riscos e notas`, `### Próximos passos sugeridos`, `### Decisão registrada (se aplicável)`, incluindo o placar de verificação na seção "O que foi feito".
