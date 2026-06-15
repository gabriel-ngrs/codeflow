---
id: <FEAT-XXXX | null>
slug: <slug>
title: "<título descritivo longo>"
type: feature | refactor | infra | ...
status: draft
priority: P0|P1|P2|P3
size: S|M|L|XL
risk_level: GREEN|YELLOW|RED
risk_score: <0-25 | null>
refine_mode: SHALLOW|DEEP
estimated_effort: "<≈Xh / ~Y P-D | null>"
wave: <single | multi | null>
domain: backend|frontend|infra|...
bounded_context: <contexto>
cross_context: [<outros contextos>]
created_at: <AAAA-MM-DD>
updated_at: <AAAA-MM-DD>
owner: <owner>
linked_adr: [<ADRs aplicáveis>]
linked_feat: [<FEATs relacionadas>]
depends_on: []
blocks: []
related_bugs: []
quality_gate:
  scorer: phase-evaluator
  threshold: 8.5
---

<!-- Campos opcionais de refinamento (risk_*, refine_mode, estimated_effort,
     cross_context, linked_*, depends_on, blocks, related_bugs): preencher só
     quando aplicável; caso contrário omitir a linha ou usar null/[]. Não
     inventar risk_score numérico para spec trivial. (ARTIFACTS_SPEC §2.8.4) -->

# <ID — título curto>

> **Nota de planning (<data>):** spec construída após sondagem do codebase.
> Declarar o ponto central: o que já existe e é reusado vs. o que é novo.
> Declarar explicitamente o que está **fora do escopo desta spec**.

## Resumo executivo (TL;DR)

Tabela O quê / Por quê / Backend-Infra / Frontend / Decisão / Tamanho.

## Sumário

Lista numerada das seções abaixo (incluindo o Plano de desenvolvimento por fases).

## 1. Problema e contexto

Contexto real do repositório; por que a necessidade existe; o seam existente.

### 1.x Princípios invioláveis

Lista numerada dos princípios derivados de rules/ADRs (cada um rastreia a uma
regra ou ADR real do repo — não inventar).

## 2. Requisitos

Funcionais (FR-N) e Não-funcionais (NFR-N), cada um numerado e testável.

## 3. Critérios de aceite

Given/When/Then por critério (AC-N), rastreáveis aos FR/NFR.

## 4. Abordagem técnica

Mapa NOVO vs. REUSADO (vs. REMOVIDO) + detalhamento por área. É o desenho do
"o quê fazer", que a §5 transforma em sequência executável. Todo caminho citado
como REUSADO/alterado existe de fato no repo.

## 5. Plano de desenvolvimento por fases

> Cada fase é executável de forma isolada por um agente de IA lendo só este
> documento: teste vermelho → implementação → verde → validação (os comandos do
> projeto) → regressão. Uma fase só inicia quando **todas as fases listadas em
> "Depende de"** estão concluídas (não basta ordem textual). O `id` e o `slug`
> de cada fase são canônicos: `/execute-spec-phase` e `/evaluate-spec-phase` os
> reusam verbatim nos nomes dos artefatos (`FASE-<id>-<slug>-EXECUCAO.md`,
> `FASE-<id>-<slug>-AVALIACAO.md`). O `threshold` que aprova cada fase é o
> `quality_gate.threshold` do frontmatter (default 8.5).
> Single-track (`wave: single`) usa `id` inteiro (`1`, `2`, …); multi-track
> (`wave: multi`) usa `<TRACK>.<n>` (`A.1`, `B.2`, …) com dependência cruzada
> explícita por `id`. Alvo: **3 a 8 fases por track**.

### Fase <id> — <nome> *(tamanho S/M/L; esforço ≈Xh — estimativa grosseira, opcional)*

> O `<id>` no heading é literal: `### Fase 1 — …` (single-track) ou
> `### Fase A.1 — …` (multi-track). O heading carrega o mesmo `id` do bullet abaixo.

- **id:** `1` (single-track) ou `A.1`/`B.2` (multi-track).
- **slug:** `<slug-da-fase>` (kebab-case curto, canônico — entra nos nomes de artefato).
- **Objetivo:** o incremento que esta fase entrega.
- **Depende de:** lista de `id`s de fase pré-requisito (ex: `A.7`) ou "nenhuma".
- **Arquivos novos:** caminhos. **Arquivos alterados:** caminhos (que existem no repo).
- **Passos:** 1) … 2) … — instruções acionáveis o bastante para executar sem
  reabrir decisões (decisões já estão em §4 e §8).
- **Testes:** o que provar, mapeado aos AC-N relevantes.
- **Escopo travado / violações BLOQUEANTES:** o que esta fase NÃO pode fazer
  (atalhos, anti-padrões, quebras de princípio) — vira os achados bloqueantes
  do avaliador.
- **Critério de conclusão (gate):** condição verificável de pronto.

### Fase <id> — <nome>

(mesma estrutura; repetir por fase — alvo 3 a 8 fases **por track**. O heading sempre traz o `id`.)

## 6. Riscos

Tabela: # | Risco | Prob. | Impacto | Mitigação.

## 7. Rollout

Como entra em produção, flags, ordem, rollback.

## 8. Open Questions

Cada OQ com status RESOLVIDO (decisão + data + justificativa) ou aberta.

## 9. Definition of Done (gate por etapa)

Checklist de prontidão com gate por fase (cada fase só fecha com seu critério de
conclusão verde) + os itens globais transversais (testes, validação do projeto,
segurança/PII, sem regressão). Cada item objetivo e verificável.
