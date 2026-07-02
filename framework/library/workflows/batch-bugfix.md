---
versão: 1.0
status: estável
atualizado: 2026-07-02
granularidade: médio
gera_decision: auto
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: batch-bugfix

> **Spec de runtime:** a referência a `SPEC.md §x` neste workflow aponta para `~/.codeflow/framework/core/SPEC.md`.

## Quando usar
Corrigir uma **lista de bugs** entregue como documento (`.txt`, `.md`, `.csv` ou planilha exportada) — tipicamente uma rodada de QA. Cada bug é identificável por número ou nome e tem escopo compatível com o `/bugfix` avulso. Pré-requisito: os bugs podem ser reproduzidos localmente ou via teste.

## Quando NÃO usar
- Para **um** bug isolado → usar `/bugfix`. Este workflow só se paga a partir de ~3 bugs.
- Para lista que na verdade é backlog de features/refactors → cada item merece `/create-spec` ou chat, não este loop.
- Para verificar se bugs de um lote já corrigido foram sanados → usar `/double-check` (este workflow corrige; aquele confere).

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/workflows/bugfix.md
- ~/.codeflow/framework/library/skills/debug-protocol/SKILL.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Antes de começar
- Se qualquer bug toca em áreas com decisions arquivadas (auth, payments, schema), consultar `.codeflow/decisions/INDEX.md` e carregar decisions ATIVAS por tag antes de corrigir aquele bug.
- **O ledger é a espinha dorsal deste workflow.** É o artefato `.codeflow/bug-batches/<slug>.md` que normaliza a lista bruta, guarda o status por bug e serve de contrato para o `/double-check`. Se um ledger com o mesmo `<slug>` já existe (lote retomado), reusar: pular os bugs já em estado terminal e corrigir só os `pendente`.

## Protocolo

### Passo 1 — Ingerir e normalizar a lista no ledger
- Ler o documento fornecido. Extrair cada bug identificado por número **ou** nome. De `.csv`/planilha, mapear colunas prováveis (id, título/descrição, passos de reprodução, severidade); de `.txt`/`.md`, inferir itens de lista ou seções.
- Derivar `<slug>` do nome do documento (ou da data se ambíguo) e criar/atualizar `.codeflow/bug-batches/<slug>.md` conforme o schema em **Formato do ledger** (abaixo). Cada bug entra com status inicial `pendente`.
- Gate: ledger criado com ≥1 bug e origem registrada. Se o documento não é parseável ou nenhum bug é identificável, parar e pedir esclarecimento — **não** adivinhar bugs.

### Passo 2 — Ordenar a fila e declarar escopo
- Ordenar os bugs `pendente` (ordem do documento por padrão; agrupar por área quando severidade/módulo forem claros para redudir troca de contexto).
- Para cada bug, declarar o **escopo esperado** (arquivos que se espera tocar) quando inferível do relato — âncora para o self-review, não trava.
- Gate: fila ordenada, sem bug `pendente` órfão de posição.

### Passo 3 — Corrigir cada bug (loop `bugfix`)
- Para cada bug `pendente`, aplicar o protocolo do `/bugfix` sobre aquele bug isoladamente: reproduzir → teste de regressão (ou repro manual justificada) → hipótese ancorada em `arquivo:linha` real via `debug-protocol` → fix mínimo → validar o subconjunto que prova o fix.
- Ao terminar cada bug, atualizar seu status no ledger: `corrigido` (com `fix` = `arquivo:linha`), `bloqueado` (com motivo: repro falhou, ambíguo, exige decisão do usuário) ou `não-reproduz`.
- **Bug bloqueado não trava o lote.** Registrar o motivo e seguir para o próximo. Bugs `bloqueado`/`não-reproduz` são reportados no fim para tratamento avulso via `/bugfix`.
- Gate: todo bug sai do loop em estado terminal no ledger (nenhum permanece `pendente`).

### Passo 4 — Validar o lote
- Rodar os comandos de validação do projeto (do `.codeflow/manifest.md`; se ausente, inferir do stack) sobre o conjunto tocado — o necessário para provar os fixes agregados, incluindo os testes de regressão adicionados.
- Aplicar a skill `self-review` no diff acumulado do lote, conferindo que cada mudança cai no escopo declarado do seu bug (Passo 2).
- Se um comando falha: aplicar política de falhas da constitution. Gate que não existe no projeto → `[—]` justificado (SPEC §3.10).

### Passo 5 — Resumir e gerar decisions
- Apresentar o resumo final (cinco seções fixas) com o **placar do lote**: quantos `corrigido`, `bloqueado`, `não-reproduz`.
- Gerar decision em `.codeflow/decisions/` para cada fix não-trivial (`gera_decision: auto`; mesmos gatilhos do `/bugfix`), e registrar o link da decision na linha do bug no ledger.
- Deixar o ledger salvo e atualizado — ele é a entrada do `/double-check`.

## Formato do ledger (`.codeflow/bug-batches/<slug>.md`)
Frontmatter: `versão`, `lote: <slug>`, `origem: <caminho do documento bruto>`, `criado`, `atualizado`. Corpo com uma tabela, uma linha por bug:

```markdown
## Bugs
| id | título | status | fix (arquivo:linha) | decision | verificação |
|----|--------|--------|---------------------|----------|-------------|
| B1 | Login aceita senha vazia | corrigido | src/auth.py:88 | 2026-07-02-senha-vazia.md | — |
```

Vocabulário de `status`: `pendente`, `corrigido`, `bloqueado`, `não-reproduz`. A coluna `verificação` é preenchida pelo `/double-check` (`✓` sanado, `✗` regrediu, `⚠` inconclusivo, `—` não verificado); o `batch-bugfix` a deixa `—`.

## Definition of Done
- [ ] Documento ingerido e normalizado no ledger com origem registrada (Passo 1).
- [ ] Todo bug em estado terminal — nenhum permanece `pendente` (Passo 3).
- [ ] Cada fix ancorado em `arquivo:linha` real e com teste de regressão (ou repro manual justificada).
- [ ] Bugs `bloqueado`/`não-reproduz` listados com motivo para tratamento avulso.
- [ ] Comandos de validação do projeto retornaram zero (ou `[—]` justificado) sobre o lote.
- [ ] Self-review aplicado ao diff acumulado, dentro do escopo declarado por bug.
- [ ] Decisions geradas para fixes não-triviais e linkadas no ledger.
- [ ] Ledger salvo e atualizado, pronto para o `/double-check`.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4, incluindo o placar do lote na seção "O que foi feito".
