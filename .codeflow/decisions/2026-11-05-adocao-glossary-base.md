---
versão: 1.0
status: estável
atualizado: 2026-11-05
data: 2026-11-05
workflow: implement-change
tags: [core, glossary, registro, adocao]
status_decisão: ativa
supersede: 2026-11-05-proposta-glossary-base
relaciona-com: [2026-11-05-proposta-glossary-base, 2026-11-05-gate-e-registro]
---

# Decisões: adoção da proposta do glossary — registro da execução de fase pela `base`

## Contexto

A decision `2026-11-05-proposta-glossary-base` propôs reescrever a entrada "Execução de fase" do
`framework/core/glossary.md` para descrever o registro pela `base`, como o `ARTIFACTS_SPEC.md` §2.9 faz desde a
`2026-11-05-gate-e-registro`. O glossary é core e segue o regime de `framework/core/EVOLUTION.md` ("Mudança em
arquivo do core"): 30 dias entre proposta e adoção, versão anterior referenciável por tag git, nova versão
exercitada em projeto real e bump major. Por ordem do dono em 2026-11-05, os 30 dias foram dispensados.

## Decisões tomadas

### 1. Adotar a proposta e aplicar a redação no glossary 3.0
A decisão 1 da proposta entra no `framework/core/glossary.md` com o texto proposto, no lugar da "Definição" de
"Execução de fase" (seção "Termos do pipeline de spec"); o resto do arquivo fica igual. Bump major 2.0 → 3.0,
`atualizado: 2026-11-05`.
**Por quê:** o glossary 2.0 descrevia o registro por `sha_final` e `range`, formato que deixou de ser o
padrão em 2026-11-05; um vocabulário oficial que contradiz o `ARTIFACTS_SPEC.md` induz a IA ao erro em toda
execução de fase.
**Alternativa rejeitada:** manter o 2.0 até 2026-12-05 — quatro semanas de contradição com o contrato, sem
evidência nova a ganhar com a espera (decisão 2).

### 2. Dispensa dos 30 dias, por ordem do dono em 2026-11-05
O dono ordenou a adoção em 2026-11-05, dispensando os 30 dias, como na adoção do glossary 2.0 em 2026-10-06. A
mudança é retrocompatível: o formato antigo segue aceito, então nenhum artefato existente deixa de valer. A
dispensa vale só para esta mudança; o regime do core segue igual para as próximas.
**Por quê:** o prazo protege contra regra não exercitada; aqui o glossary só passa a descrever o contrato já
vigente, sem regra nova.
**Alternativa rejeitada:** cumprir o prazo integral — custo de quatro semanas de contradição sem ganho.

### 3. A versão 2.0 fica referenciável pela tag git `glossary-v2.0`
A tag `glossary-v2.0` aponta para o último commit com o glossary 2.0 e atende à exigência de a versão anterior
seguir referenciável. Relatórios antigos, só com `sha_inicial`, `sha_final` e `range`, continuam descritos pela
própria entrada 3.0.
**Por quê:** é o mecanismo que o EVOLUTION nomeia, o mesmo usado na `glossary-v1.2`.
**Alternativa rejeitada:** manter uma cópia `glossary-2.0.md` no core — arquivo morto que cresce a cada major.

## Próximos passos sugeridos

- Criar a tag `glossary-v2.0` no merge (é do Maestro).
