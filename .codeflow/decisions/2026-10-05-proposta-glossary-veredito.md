---
versão: 1.0
status: estável
atualizado: 2026-10-05
data: 2026-10-05
workflow: implement-change
tags: [core, glossary, veredito, proposta]
status_decisão: ativa
supersede: null
relaciona-com: [2026-10-05-aceleracao-do-ciclo, 2026-10-02-operacao-por-trilhas]
---

# Decisões: proposta de mudança no glossary — veredito e avaliação de fase

## Contexto

A decision `2026-10-05-aceleracao-do-ciclo` mudou o veredito da avaliação de fase no
`framework/core/ARTIFACTS_SPEC.md` §2.10.3 (2.3). O `framework/core/glossary.md` 1.2 ainda define
"Veredito" com `RESSALVAS` e "Avaliação de fase" com scorecard ponderado. O glossary é core: segue o regime
de `framework/core/EVOLUTION.md` ("Mudança em arquivo do core") — proposta visível por 30 dias, bump major,
adoção só pelo dono. Esta decision é a proposta; nada no glossary muda agora.

## Decisões tomadas

### 1. Proposta: nova redação de "Veredito"
- **Definição:** resultado da avaliação de uma fase: `APROVADO`, `REPROVADO` ou `PENDENTE-EXTERNO`, por
  precedência estrita **`REPROVADO` > `PENDENTE-EXTERNO` > `APROVADO`**. `APROVADO` (zero BLOQUEANTE)
  conclui a fase, e os IMPORTANTES abertos seguem como herdados; `REPROVADO` devolve ao rework;
  `PENDENTE-EXTERNO` espera uma condição de fora da fase e é reavaliado na mesma tentativa.
- **Onde mora:** campo `veredito` no frontmatter do `FASE-*-AVALIACAO.md`.
- **O que NÃO é:** não é nota. Score e threshold, se existirem, só informam. O `RESSALVAS` de artefatos
  anteriores a 2026-10-05 se lê como `APROVADO`.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.10.3.

**Por quê:** alinhar o vocabulário oficial ao contrato vigente desde 2026-10-05.
**Alternativa rejeitada:** remover a entrada e deixar só a referência ao ARTIFACTS_SPEC — o termo é central no pipeline de spec.

### 2. Proposta: nova redação de "Avaliação de fase"
Trocar "com scorecard ponderado, achados (BLOQUEANTE/IMPORTANTE/SUGESTÃO) e veredito machine-readable" por
"com achados (BLOQUEANTE/IMPORTANTE/SUGESTÃO), conferência dos herdados e veredito machine-readable".
**Por quê:** o scorecard virou opcional.
**Alternativa rejeitada:** manter o texto — descreveria um campo que não decide nada.

### 3. Proposta: termo novo "Herdado"
- **Definição:** IMPORTANTE aberto de uma fase aprovada, que passa à fase dependente (ou ao fechamento da
  spec) para ser resolvido; não resolvido, vira BLOQUEANTE na avaliação seguinte.
- **Onde mora:** seção "Herdados" do `FASE-*-EXECUCAO.md` e conferência na seção 2 do `FASE-*-AVALIACAO.md`.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.11.5.

**Por quê:** termo novo do pipeline, usado em workflows e moldes.
**Alternativa rejeitada:** nenhuma alternativa considerada — único caminho viável para termo novo no core.

## Próximos passos sugeridos

- A partir de 2026-11-04, com o "sim" do dono: aplicar as três entradas no `framework/core/glossary.md`
  com bump major (1.2 → 2.0).
