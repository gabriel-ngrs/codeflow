---
versão: 1.0
status: estável
atualizado: 2026-11-05
data: 2026-11-05
workflow: implement-change
tags: [core, glossary, registro, proposta]
status_decisão: superseded
supersede: 2026-11-05-adocao-glossary-base
relaciona-com: [2026-11-05-gate-e-registro]
---

# Decisões: Proposta: registro da execução de fase pela `base` no glossary

> **Adotada em 2026-11-05** pela decision `2026-11-05-adocao-glossary-base`, que a substitui: a nova
> redação está no `framework/core/glossary.md` 3.0.

## Contexto

A decision `2026-11-05-gate-e-registro` trocou o registro do relatório de execução de fase no
`framework/core/ARTIFACTS_SPEC.md` §2.9: entra o campo `base`, e `sha_inicial`, `sha_final` e `range` passam a
opcionais, aceitos em artefato antigo; o avaliador calcula o intervalo pela `base` (§2.10.1). O
`framework/core/glossary.md` 2.0 ainda define "Execução de fase" só pelo trio antigo. O glossary é core e segue o
regime de `framework/core/EVOLUTION.md` ("Mudança em arquivo do core"): proposta visível, 30 dias, bump major,
adoção pelo dono. Esta decision é a proposta; data de adoção prevista: 2026-12-05, salvo ordem do dono.

## Decisões tomadas

### 1. Proposta: nova redação de "Execução de fase"
- **Definição:** relatório `FASE-<id>-<slug>-EXECUCAO.md` gerado por `/execute-spec-phase` ao implementar (ou
  refazer) uma fase, com frontmatter machine-readable (`fase`, `tentativa`, `reprovacoes`, `base`) e corpo com
  evidências. O intervalo da fase se calcula pela `base` (`<merge-base de base e HEAD>..HEAD`); `sha_inicial`,
  `sha_final` e `range`, do formato anterior, seguem aceitos em artefato antigo.
- Demais campos da entrada ("Onde mora", "O que NÃO é", "Referência canônica") sem mudança.

**Por quê:** alinhar o vocabulário oficial ao contrato do `ARTIFACTS_SPEC.md` §2.9 vigente desde 2026-11-05; um
glossary que manda gravar `sha_final` e `range` empurra a IA ao commit só para acertar sha, que o contrato
agora proíbe.
**Alternativa rejeitada:** reescrever também "Avaliação de fase" — a entrada não cita os campos do registro, e
`range_avaliado` não mudou de nome; mexer nela seria texto além do que a `base` muda.

## Próximos passos sugeridos

- Com o "sim" do dono: aplicar a redação no `framework/core/glossary.md` com bump major (2.0 → 3.0), deixando a
  2.0 referenciável pela tag git `glossary-v2.0`.
