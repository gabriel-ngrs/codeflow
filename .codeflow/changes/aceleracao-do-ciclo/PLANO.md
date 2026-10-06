---
mudanca: aceleracao-do-ciclo
tipo: melhoria
tamanho: media
status: aprovado
aprovado_por: dono
aprovado_em: 2026-10-05
registro: nota "Plano de ação" do fichário "Pesquisa de aceleração" (Maestri), regras R1, R3 e R8 da nota "Regras novas"
---

<!-- Preenchido pelo PLANEJADOR (/plan-change). Ninguém implementa antes de o
     dono aprovar: o /implement-change exige status: aprovado.

     status: "proposto" (escrito, aguardando o dono) ou "aprovado".
     Quem aprova é o dono; quem troca o campo é ele, ou o orquestrador com a
     aprovação dele registrada (aprovado_por, aprovado_em).
     tamanho: pequena = 1 etapa; media = 2 a 4 etapas. Grande não tem plano
     aqui — vira spec. -->

# Aceleração do ciclo (R1, R3, R8) — Plano

## 1. Objetivo

Cortar o rework e a cerimônia que a medição de 2026-10-05 apontou no framework universal, sem perder o
gate de qualidade: o veredito passa a aprovar com zero BLOQUEANTE e os IMPORTANTES viram "Herdados" (R1);
o processo ganha o tamanho P direto e a mudança média deixa de esperar aprovação formal quando o pedido é
claro (R3); e os workflows passam a ler só as seções do contrato que usam e a validar a spec na origem (R8).
Tudo retrocompatível: nenhum `.codeflow/` existente deixa de valer.

## 2. Fora de escopo

- Core (`framework/core/constitution.md`, `glossary.md`, `EVOLUTION.md`): a definição de "Veredito" e de
  "Avaliação de fase" no glossary fica como **proposta** na decision desta mudança (gate duro, operação item 6).
- `run-structural.sh`: não muda o que valida (nem o piso de 3 fases); só passa a ser chamado no `/create-spec`.
- Checkpoints dos workflows detalhados, workflows de projeto (camada de cada consumidor), R2, R4 a R7 e R9.
- Dívida anterior do catálogo (`SPEC.md` §2.2 sem o ciclo de mudança e as skills novas): item da Auditoria.
- Os workflows `audit`, `verify-audit`, `design-pass` e `security-sweep`: não são tocados por R1, R3 ou R8 neste pacote.

## 3. Classificação (skill `change-sizing`)

| Sinal | Valor | Evidência |
|-------|-------|-----------|
| Etapas | 3 | as três regras do pacote, uma por etapa, cada uma verde e commitada sozinha |
| Áreas tocadas | 2 camadas (core/contrato e library) | `.codeflow/constitution.md`, "Padrão arquitetural" |
| Contrato / fronteira | muda de forma compatível | `ARTIFACTS_SPEC.md` §2.9–§2.11: valor novo de veredito, campos que viram opcionais, `RESSALVAS` legado lido como `APROVADO`; nenhum artefato existente fica inválido |
| Migração | não | nenhum artefato de projeto precisa ser reescrito |
| ADR nova | não (decision de registro) | aprovação do dono de 2026-10-05 registrada em `.codeflow/decisions/2026-10-05-aceleracao-do-ciclo.md` |
| Comportamento percebido | muda o desfecho da avaliação (fronteira com grande) | o tamanho médio foi fixado pelo dono no despacho, e a mudança de schema foi aprovada por ele (operação, item 8) |

## 4. Mapa do código

| Caminho | NOVO / ALTERADO / REUSADO | Para quê |
|---------|---------------------------|----------|
| `framework/core/ARTIFACTS_SPEC.md` | ALTERADO | §2.8 (quality_gate opcional), §2.9 (Herdados, teto), §2.10 (vereditos), §2.11 (estado pendente-externo) |
| `framework/core/SPEC.md` | ALTERADO | §4.2.5 e §4.7.1: vereditos novos |
| `framework/library/workflows/evaluate-spec-phase.md` | ALTERADO | veredito R1; seções do contrato; resumo final pela seção |
| `framework/library/workflows/execute-spec-phase.md` | ALTERADO | Herdados, teto só com REPROVADO, PENDENTE-EXTERNO; seções; resumo |
| `framework/library/workflows/spec-status.md` | ALTERADO | estado pendente-externo; seções; resumo |
| `framework/library/workflows/review-change.md` | ALTERADO | escalada de IMPORTANTE, erro de registro, PENDENTE-EXTERNO |
| `framework/library/workflows/implement-change.md` | ALTERADO | teto sem PENDENTE-EXTERNO; plano aprovado por pedido claro; gatilhos de decision |
| `framework/library/workflows/plan-change.md` | ALTERADO | P direto para; M nasce aprovado com pedido claro |
| `framework/library/workflows/batch-bugfix.md`, `double-check.md` | ALTERADO | teto de 2 reaberturas por bug |
| `framework/library/workflows/bugfix.md` | ALTERADO | sem o gatilho "mudança não-trivial" |
| `framework/library/workflows/refactor.md` | ALTERADO | `gera_decision: auto` |
| `framework/library/workflows/create-spec.md` | ALTERADO | só para G; roda o `run-structural.sh` no fim |
| `framework/library/workflows/ideacao.md` | ALTERADO | lê só a §2.12 |
| `framework/library/skills/change-sizing/SKILL.md` | ALTERADO | tamanho P direto e trailer `Tamanho: P` |
| `framework/library/templates/specs/TEMPLATE-AVALIACAO.md`, `TEMPLATE-EXECUCAO.md`, `SPEC_TEMPLATE.md`, `README.md` | ALTERADO | moldes do veredito novo |
| `framework/library/templates/changes/REVISAO.md`, `PLANO.md`, `README.md` | ALTERADO | veredito PENDENTE-EXTERNO; aprovação por pedido claro |
| `framework/core/scripts/run-structural.sh` | REUSADO | chamado pelo `/create-spec`, sem mudança |
| `.codeflow/decisions/2026-10-05-aceleracao-do-ciclo.md` | NOVO | aprovação do schema, adaptação das regras, proposta ao glossary (sem linha no INDEX) |
| `README.md` | REUSADO | conferido: não cita veredito, score nem tamanho; nada a pagar |

> Todo caminho ALTERADO ou REUSADO existe no repositório (conferido ao escrever).

## 5. Critérios de aceite

- **CA-1** — Dado uma avaliação de fase sem BLOQUEANTE e com até 2 IMPORTANTES, quando o avaliador decide, então o veredito é `APROVADO` e os IMPORTANTES vão para "Herdados" da próxima fase; score e threshold, se preenchidos, não mudam o veredito.
- **CA-2** — Dado um IMPORTANTE herdado não resolvido, ou 3 ou mais IMPORTANTES abertos, quando o avaliador decide, então eles viram BLOQUEANTE e o veredito é `REPROVADO`.
- **CA-3** — Dado um gate que depende de cota, push, ação física do dono ou ordem das fases, quando o avaliador não consegue fechá-lo, então o veredito é `PENDENTE-EXTERNO`, a fase não conta para o teto e é reavaliada na mesma tentativa.
- **CA-4** — Dado um `.codeflow/` existente com `veredito: RESSALVAS`, `score` e `threshold`, quando lido pelos workflows novos, então ele continua válido e a fase conta como concluída, com os IMPORTANTES como herdados.
- **CA-5** — Dado o lote de bugs, quando o `/double-check` reabre um bug pela 3ª vez, então o bug vai para `bloqueado` (teto de 2 reaberturas) em vez de voltar a `pendente`.
- **CA-6** — Dado um pedido classificado P pela `change-sizing`, então não há plano nem documento: implementação com teste, check verde, self-review e trailer `Tamanho: P`; sinal de risco nunca é P.
- **CA-7** — Dado um pedido M claro, quando o `/plan-change` termina, então o plano nasce `aprovado` sem esperar o dono; `/create-spec` só se usa para G; bugfix sem o gatilho "não-trivial"; refactor com `gera_decision: auto`.
- **CA-8** — Dado `execute-spec-phase`, `evaluate-spec-phase`, `spec-status` e `ideacao`, então nenhum manda ler o `ARTIFACTS_SPEC.md` inteiro, só as seções que usam; o resumo final cita as seções do `SPEC.md` §5.6.4 sem mandar abrir o arquivo; o `/create-spec` roda o `run-structural.sh` antes do commit.
- **CA-9** — Dado o gate `test` do manifest, então nenhuma spec real muda de código de saída entre `origin/main` e o ramo; o gate `check` sai verde.

## 6. Etapas

### Etapa 1 — Veredito (R1)
- **Faz:** reescreve a cascata de veredito e a máquina de estados em `ARTIFACTS_SPEC.md` §2.8–§2.11 e `SPEC.md` §4.2.5/§4.7.1; alinha `evaluate-spec-phase`, `execute-spec-phase`, `spec-status`, `review-change`, `implement-change` (teto), `batch-bugfix` e `double-check` (teto de reabertura); moldes `TEMPLATE-AVALIACAO`, `TEMPLATE-EXECUCAO`, `SPEC_TEMPLATE`, `templates/specs/README.md` e `templates/changes/REVISAO.md`; escreve a decision com a aprovação do schema e a proposta ao glossary.
- **Arquivos:** os da tabela da §4 ligados a R1.
- **Testes:** framework de texto, sem suíte: `grep` de `RESSALVAS` só nos trechos de leitura legada; gate `test` (regressão do `run-structural.sh`).
- **Cobre:** CA-1, CA-2, CA-3, CA-4, CA-5, CA-9
- **Gate:** bloco `lint` do `.codeflow/manifest.md`

### Etapa 2 — Tamanho (R3)
- **Faz:** `change-sizing` ganha o tamanho P direto; `plan-change` para no P e faz o M claro nascer aprovado; `implement-change` aceita essa aprovação; moldes `PLANO.md` e `templates/changes/README.md`; `create-spec` só para G; `bugfix` (e o texto gêmeo em `batch-bugfix` e `implement-change`) sem o gatilho "não-trivial"; `refactor` com `gera_decision: auto`.
- **Arquivos:** `change-sizing/SKILL.md`, `plan-change.md`, `implement-change.md`, `create-spec.md`, `bugfix.md`, `batch-bugfix.md`, `refactor.md`, `templates/changes/PLANO.md`, `templates/changes/README.md`.
- **Testes:** `grep` do gatilho removido e do `gera_decision` do refactor.
- **Cobre:** CA-6, CA-7
- **Gate:** bloco `lint` do `.codeflow/manifest.md`

### Etapa 3 — Contexto e shift-left (R8)
- **Faz:** `execute-spec-phase`, `evaluate-spec-phase`, `spec-status` e `ideacao` citam só as seções do `ARTIFACTS_SPEC.md` (com o comando que extrai a seção); o resumo final dos workflows tocados nomeia as seções do `SPEC.md` §5.6.4; `create-spec` roda o `run-structural.sh` antes do commit.
- **Arquivos:** os quatro workflows, `create-spec.md` e o resumo final dos workflows já tocados nas etapas 1 e 2.
- **Testes:** `grep` de `ARTIFACTS_SPEC.md` sem seção nos quatro workflows; extração da seção pelo comando citado devolve o trecho certo.
- **Cobre:** CA-8, CA-9
- **Gate:** `check` do `.codeflow/manifest.md` (lint, test, security)

## 7. Riscos e como desfazer

- Projetos com spec em curso mudam de estado na leitura (fase em `RESSALVAS` passa a concluída). É o efeito pedido pelo dono (R1); o `reprovacoes` antigo nunca decresce, então o teto fica mais conservador, não mais frouxo.
- O glossary (core) segue com a definição antiga até a proposta ser adotada; a decision registra a divergência e o `ARTIFACTS_SPEC.md`, que o glossary cita como referência canônica, vence.
- Desfazer: `git revert` dos três commits de etapa; nenhum artefato de projeto é reescrito.

## 8. Como a revisão vai provar

- Ler o diff contra os CA; conferir que nenhum trecho manda tratar `RESSALVAS` como rework.
- Rodar o gate `check` do manifest (o `test` compara o `run-structural.sh` de `origin/main` e do ramo sobre as specs reais).
- Conferir que nenhum arquivo do core foi tocado: `git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md framework/core/EVOLUTION.md` vazio.
