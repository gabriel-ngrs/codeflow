---
mudanca: aceleracao-do-ciclo
status: rework
tentativa: 2
reprovacoes: 1
etapas_concluidas: [1, 2, 3]
sha_inicial: af22ea5
sha_final: 301c389
range: af22ea5..301c389
---

<!-- Preenchido pelo IMPLEMENTADOR (/implement-change). É declaração, não prova:
     o REVISOR não confia nele e confere contra o código real.

     status: "executado" (primeira execução) ou "rework".
     Primeira execução: tentativa=1, reprovacoes=0, sha_inicial = HEAD antes da etapa 1.
     Rework: tentativa = anterior+1; reprovacoes = anterior+1; sha_inicial = REUSAR o
       anterior. range é sempre sha_inicial..sha_final (a mudança inteira).
     etapas_concluidas: ids das etapas do plano já commitadas e verdes — é o ponto
       de retomada se a execução parar no meio. -->

# Aceleração do ciclo (R1, R3, R8) — Relatório de execução

## 1. Resumo

As três etapas do plano entraram, cada uma num commit verde: o veredito novo da fase de spec e do ciclo de
mudança, com herdados, escalada, erro de registro e `PENDENTE-EXTERNO`, retrocompatível com `RESSALVAS`
(R1); o tamanho P direto e o plano M aprovado por pedido claro (R3); e a leitura só da seção usada do
contrato, com o gate estrutural no `/create-spec` (R8). Um quarto commit fecha uma lacuna da etapa 1.

## 2. Etapas

| Etapa | Commit | Gate | Resultado |
|-------|--------|------|-----------|
| 1 — Veredito (R1) | `c3b36a8` | bloco `lint` do manifest | verde (`lint rc=0`) |
| 2 — Tamanho (R3) | `43435ab` | bloco `lint` do manifest | verde (`lint rc=0`) |
| 3 — Contexto e shift-left (R8) | `ba1ea45` | `check` do manifest | verde (lint, test, security `rc=0`) |
| correção da etapa 1 | `103ac6d` | `check` do manifest | verde |
| rework B-1, B-2 (REVISAO-1) | `4bb991f` | `check` do manifest | verde (saída na §5) |
| rework I-1 (REVISAO-1) | `301c389` | `check` do manifest | verde (saída na §5) |

## 3. Arquivos criados e alterados

| Arquivo | Criado / alterado | Propósito |
|---------|-------------------|-----------|
| `framework/core/ARTIFACTS_SPEC.md` | alterado (2.3) | §2.8 `quality_gate` opcional; §2.9 seção Herdados e teto só com `REPROVADO`; §2.10 vereditos, escalada, erro de registro, score opcional; §2.11 estado "pendente externo" e §2.11.5 Herdados |
| `framework/core/SPEC.md` | alterado (3.3) | §4.2.5 e §4.7.1 com os vereditos novos |
| `framework/library/workflows/evaluate-spec-phase.md` | alterado (1.9) | Passo 4 sem score decisório, herdados, escalada; seções do contrato; resumo final; reavaliação de pendente externo |
| `framework/library/workflows/execute-spec-phase.md` | alterado (1.10) | herdados, teto só com `REPROVADO`, linha 4 e fechamento (linha 6) da tabela; seções; resumo |
| `framework/library/workflows/spec-status.md` | alterado (1.7) | estado pendente externo, sem coluna Score; §2.11 só; resumo |
| `framework/library/workflows/review-change.md` | alterado (1.1) | escalada, erro de registro, `PENDENTE-EXTERNO`; resumo |
| `framework/library/workflows/implement-change.md` | alterado (1.1) | teto só com `AJUSTAR`; aprovação por pedido claro; P direto; gatilhos de decision; resumo |
| `framework/library/workflows/plan-change.md` | alterado (1.1) | P e G param; M claro nasce `aprovado`; resumo |
| `framework/library/workflows/batch-bugfix.md`, `double-check.md` | alterado (1.1) | coluna `reaberturas` e teto de 2 reaberturas; gatilhos de decision; resumo |
| `framework/library/workflows/bugfix.md` | alterado (1.3) | sem o gatilho "mudança não-trivial"; resumo |
| `framework/library/workflows/refactor.md` | alterado (1.1) | `gera_decision: auto` com gatilhos; resumo |
| `framework/library/workflows/create-spec.md` | alterado (1.7) | só para G; ação 4 roda o `run-structural.sh`; resumo |
| `framework/library/workflows/ideacao.md` | alterado (1.1) | só §2.12; resumo; ganha `atualizado` no frontmatter |
| `framework/library/skills/change-sizing/SKILL.md` | alterado (1.1) | tamanho P, régua P/M/G, destino e trailer |
| `framework/library/templates/specs/*` | alterado | moldes AVALIACAO, EXECUCAO, SPEC_TEMPLATE e README no veredito novo |
| `framework/library/templates/changes/PLANO.md`, `REVISAO.md`, `README.md` | alterado | pedido claro; `PENDENTE-EXTERNO` e erros de registro |
| `.codeflow/decisions/2026-10-05-aceleracao-do-ciclo.md` | criado | aprovação do schema e as dez escolhas (sem linha no INDEX) |
| `.codeflow/decisions/2026-10-05-proposta-glossary-veredito.md` | criado | proposta ao glossary (core), adoção a partir de 2026-11-04 |
| `.codeflow/manifest.md` | alterado (1.1) | contrato normativo SPEC 3.3 e ARTIFACTS_SPEC 2.3 |

## 4. Desvios do plano

- Commit `103ac6d` fora das três etapas: o `evaluate-spec-phase` não escolhia a fase em "pendente externo" para
  reavaliar. Corrige a etapa 1, dentro do escopo.
- O texto gêmeo de "não-trivial" no `batch-bugfix` e no `implement-change` foi alinhado ao `bugfix` (R2: corrigir as ocorrências gêmeas).
- `.codeflow/manifest.md` não estava no mapa do código: ganhou só as versões novas do contrato.
- `README.md` da raiz e `SPEC.md` §2.2/§3.5 conferidos e não alterados: nenhum item criado, renomeado ou com
  descrição desatualizada pelo pacote.

## 5. Comandos rodados e saídas reais

```text
# check do manifest (lint, test, security) em 301c389 (tentativa 2)
== lint
lint rc=0
== test
specs comparadas: 55, divergências: 0
  órfãos detectados: 0 (rode com --prune para remover)
✓ Sincronização concluída.
  criados:     21 (slash commands) · criados: 21 (skills Codex)
✓ Sincronização concluída. Reinicie o Codex ou abra um chat novo para recarregar as skills.
test rc=0
== security
INF 9 commits scanned.
INF no leaks found
security rc=0

# core e scripts intocados
$ git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md \
    framework/core/EVOLUTION.md framework/core/scripts/ install.sh setup-*.sh
(vazio)

# os comandos de seção citados pelos workflows
$ sed -n '/^### 2\.9 /,/^### 2\.12 /p' framework/core/ARTIFACTS_SPEC.md | wc -l   → 232
$ sed -n '/^### 2\.11 /,/^### 2\.12 /p' framework/core/ARTIFACTS_SPEC.md | wc -l  → 38
$ sed -n '/^### 2\.12 /,/^## Parte 3/p' framework/core/ARTIFACTS_SPEC.md | wc -l  → 133
(o arquivo inteiro: 3176 linhas, 203695 bytes)
```

## 6. Critérios de aceite

| CA | Atendido? | Evidência (teste, comando, arquivo:linha) |
|----|-----------|--------------------------------------------|
| CA-1 | sim | `ARTIFACTS_SPEC.md` §2.10.3 (precedência e `APROVADO`); `evaluate-spec-phase.md` Passo 4 |
| CA-2 | sim | §2.10.3 "Escalada de IMPORTANTE"; `evaluate-spec-phase.md` Passo 4; `review-change.md` Passo 3 |
| CA-3 | sim | §2.10.3, §2.11.3 (estado pendente externo), §2.11.4 (não conta); `execute-spec-phase.md` linha 4 da tabela |
| CA-4 | sim | §2.10.3 "Legado", §2.10.4 (score/scorecard antigos válidos), §2.9.3 (Herdados ausente válido); gate `test` sem divergência |
| CA-5 | sim | `double-check.md` Passo 3 (`reaberturas` = 2 → `bloqueado`); `batch-bugfix.md` formato do ledger |
| CA-6 | sim | `change-sizing/SKILL.md` protocolo 4 e 5 |
| CA-7 | sim | `plan-change.md` Passo 5; `create-spec.md` "Quando NÃO usar"; `bugfix.md` Passo 6; `refactor.md` frontmatter e Fase 6 |
| CA-8 | sim | LEIA TAMBÉM dos quatro workflows; "Resumo final" dos doze tocados; `create-spec.md` ação 4 da Fase 4 |
| CA-9 | sim | gate `test`: 55 specs, 0 divergência; `check` verde (§5) |

## 7. No rework: o que mudou nesta tentativa

- **B-1** (escalada com quatro definições) → uma definição só na §2.10.3 do ARTIFACTS_SPEC ("o IMPORTANTE de uma avaliação anterior da mesma fase (rework), ou herdado destinado à fase, que segue aberto"), citada por evaluate-spec-phase, execute-spec-phase, TEMPLATE-AVALIACAO (seção 2 confere também os IMPORTANTES da avaliação anterior) e a decision; no ciclo de mudança só escala o de destino "corrigir agora" (review-change e REVISAO alinhados) → `4bb991f`.
- **B-2** (destino dos herdados) → execute-spec-phase e evaluate-spec-phase seguem a §2.11.5: só a primeira fase dependente; sem dependente, o fechamento (ratificação D9.1 do orquestrador) → `4bb991f`.
- **I-1** (SPEC §6.5.1, exemplo de `gera_decision: auto`) → alinhado aos gatilhos do bugfix → `301c389`.
- Sugestões da REVISAO-1 não aplicadas (descartadas por padrão; não pedidas no rework).

## 8. Dúvidas para o revisor

- Destino dos herdados (§2.11.5): ratificado pelo orquestrador (D9.1). O fechamento corrige sem
  nova avaliação, o que a REVISAO-1 (§8) confirmou como conforme à R1.
- O `review-change` com `APROVADO` manda corrigir os IMPORTANTES "corrigir agora" num commit antes do PR, sem
  nova revisão. É a leitura da R1 para o ciclo de mudança, que não tem "próxima fase".
- O glossary segue com a definição antiga até a adoção da proposta; a decision registra a divergência.
- Os workflows `audit`, `verify-audit`, `design-pass` e `security-sweep` ficaram com o resumo final antigo (fora do pacote).
