---
versão: 1.0
status: estável
atualizado: 2026-10-05
data: 2026-10-05
workflow: implement-change
tags: [veredito, avaliacao, schema, herdados, teto, retrocompatibilidade, tamanho, decisions]
status_decisão: ativa
supersede: null
relaciona-com: [2026-10-02-operacao-por-trilhas, 2026-10-05-proposta-glossary-veredito]
---

# Decisões: aceleração do ciclo — veredito, tamanho e contexto

## Contexto

A medição de 2026-10-05 sobre o histórico de cinco projetos consumidores mostrou que 70% dos vereditos
não-APROVADO de fase de spec eram `RESSALVAS` (zero BLOQUEANTE, rework completo mesmo assim), que o score
decidiu só 5,1% das avaliações, que o laço batch-bugfix↔double-check não tinha teto e que quatro
workflows mandavam ler o `ARTIFACTS_SPEC.md` inteiro para usar poucas seções. O dono aprovou em
2026-10-05 as "Regras novas" R1 a R9; esta mudança aplica ao framework universal R1 (veredito), R3
(tamanho de processo) e R8 (lembrete vira script), pelo plano `.codeflow/changes/aceleracao-do-ciclo/`.
R1 muda o schema de artefato de projeto (`framework/core/ARTIFACTS_SPEC.md` Parte 2), o que a constitution
do repositório e a operação por trilhas (item 8) reservam ao dono.

## Decisões tomadas

### 1. A mudança de schema da avaliação de fase tem aprovação do dono
O dono aprovou em 2026-10-05 a mudança de schema de §2.9 (EXECUCAO), §2.10 (AVALIACAO) e §2.11
(máquina de estados) do `ARTIFACTS_SPEC.md`, que sobe para 2.3. É a aprovação que a decisão 8 da
operação por trilhas exige; o tamanho médio foi fixado por ele no despacho.
**Por quê:** a regra R1 só tem efeito se o contrato que os workflows de spec seguem mudar.
**Alternativa rejeitada:** abrir trilha de spec para a mudança — não existe neste repositório (operação, item 8).

### 2. Vereditos: `APROVADO`, `REPROVADO`, `PENDENTE-EXTERNO`
`APROVADO` = zero BLOQUEANTE; os IMPORTANTES abertos viram herdados. `REPROVADO` = ao menos um
BLOQUEANTE, contada a escalada: herdado não resolvido (o mesmo IMPORTANTE pela 2ª vez) e 3 ou mais
IMPORTANTES abertos ao mesmo tempo viram BLOQUEANTE. `PENDENTE-EXTERNO` = um gate depende de cota,
push ou CI remoto, ação física do dono ou outra fase antes; é um estado próprio da fase ("pendente
externo"), não volta ao executor, não conta para o teto e é reavaliado na mesma tentativa. Precedência:
`REPROVADO` > `PENDENTE-EXTERNO` > `APROVADO`. Score e threshold viram opcionais e informativos, inclusive o
`quality_gate` da spec. Erro só de registro (frontmatter, `range`, lista de arquivos, link) sai do
veredito e se corrige num commit só de documento. No ciclo de mudança, `review-change` ganha a mesma
escalada, o erro de registro e o `PENDENTE-EXTERNO`; o `AJUSTAR` segue como nome do veredito que pede rework.
**Por quê:** é a R1. O `review-change` já aprovava com zero BLOQUEANTE; o framework passa a ter uma regra só.
**Alternativa rejeitada:** manter `RESSALVAS` como veredito que conclui com ressalva — dois nomes para o mesmo desfecho confundem a máquina de estados.

### 3. Retrocompatibilidade: nenhum `.codeflow/` existente deixa de valer
`RESSALVAS` emitido antes de 2026-10-05 se lê como `APROVADO`, com os IMPORTANTES daquela avaliação como
herdados. `score`, `threshold`, scorecard e a ordem antiga de 8 seções da AVALIACAO continuam válidos; o
EXECUCAO sem a seção "Herdados" também. O `reprovacoes` de artefato antigo, que contava `RESSALVAS`, não é
reescrito nem decresce: o teto só fica mais conservador. O `run-structural.sh` não muda.
**Por quê:** os projetos consumidores têm fases em curso e leem o framework ao vivo depois do deploy.
**Alternativa rejeitada:** migrar os artefatos antigos — reescreveria histórico de projeto sem ganho.

### 4. Destino dos herdados
Os herdados de uma fase vão para a primeira fase, na ordem textual da §5, cujo `Depende de` a cita; sem
dependente, para o fechamento da spec (gatilho 6 de `/execute-spec-phase`), que os corrige em commits
próprios e lista herdado → `sha` no commit que leva a spec a `done`. O executor de destino os lista na
seção "Herdados" do EXECUCAO; o avaliador de destino os confere. Corrigir um herdado é escopo autorizado
da fase que o recebe.
**Por quê:** a R1 diz "a próxima fase"; com dependências cruzadas entre tracks, "próxima" precisa de regra
determinística, e a dependência por `id` é a que a máquina de estados já usa.
**Alternativa rejeitada:** a próxima fase executada, qualquer que fosse — em ondas paralelas (R4) duas
fases correm ao mesmo tempo e o destino ficaria ambíguo.

### 5. Teto de 2 reaberturas no lote de bugs
O ledger do `/batch-bugfix` ganha a coluna `reaberturas` (ausente = `0`). O `/double-check` reabre um bug
só abaixo de 2 reaberturas; no teto, o bug vai a `bloqueado` com o motivo "teto de reabertura: decisão do dono".
**Por quê:** o laço batch-bugfix↔double-check era o único ciclo de correção do framework sem teto.
**Alternativa rejeitada:** teto de 3, como o do executor↔avaliador — o despacho fixou 2.

### 6. O glossary (core) fica para proposta própria
As entradas "Veredito" e "Avaliação de fase" do `framework/core/glossary.md` descrevem o modelo antigo.
O glossary é core (gate duro, operação item 6): a nova redação vai como proposta na decision
`2026-10-05-proposta-glossary-veredito`. Até a adoção, vale o `ARTIFACTS_SPEC.md` §2.10.3, que o próprio
glossary cita como referência canônica do veredito.
**Por quê:** nenhum orquestrador nem decisão delegada destrava o core.
**Alternativa rejeitada:** editar o glossary neste pull request.

### 7. Tamanho P (direta) na `change-sizing`
Mudança pequena vira **P** quando o diff cabe numa frase, toca uma área e não tem nenhum sinal de risco
(contrato, migração, auth/tenant, dinheiro, dado pessoal, deploy). P vai direto: teste do que mudou, check
verde, `self-review`, sem plano nem documento, com o trailer `Tamanho: P` no commit. Pequena e média
formam o **M** (ciclo de mudança); grande é **G** (spec). Dúvida entre P e M vai para M.
**Por quê:** é a R3; a medição achou a mudança pequena mais cara que um bugfix, e o ciclo novo foi usado uma vez.
**Alternativa rejeitada:** renomear pequena/média para P/M — quebraria o campo `tamanho` dos PLANO já escritos.

### 8. M sem aprovação formal quando o pedido é claro
O `/plan-change` faz o plano nascer `aprovado` (`aprovado_por: pedido claro do dono`) quando o pedido diz
o quê e o porquê e o plano não deixa decisão para o dono; senão, `proposto`. O `/create-spec` passa a ser só
para G.
**Por quê:** é a R3; a aprovação de um pedido já claro era um commit e um despacho a mais sem decisão nova.
**Alternativa rejeitada:** dispensar a aprovação em todo M — esconderia do dono as decisões abertas.

### 9. Decision só para o que sobrevive ao código
O `/bugfix` perde o gatilho "mudança não-trivial" (o porquê do fix vai no corpo do commit); o `/refactor` passa
de `gera_decision: yes` para `auto`, com gatilhos: reestruturação com mudança quebradora, default após
incerteza do owner, divergência da constitution. O texto gêmeo do `/batch-bugfix` ("fix não-trivial") e do
`/implement-change` ("escolha técnica não-trivial") foi alinhado aos gatilhos do `/bugfix`.
**Por quê:** é a R3; o gatilho "não-trivial" cobria quase todo fix e enchia o índice de decisions.
**Alternativa rejeitada:** deixar o `/implement-change` com o gatilho próprio — ele declara usar "os mesmos gatilhos do `/bugfix`", e a regra ficaria dupla.

## Próximos passos sugeridos

- No deploy: avisar os orquestradores dos projetos consumidores da mudança de veredito e pedir o re-rodar
  de `bash ~/.codeflow/install.sh` (os moldes de `templates/specs/` mudaram).
- Avaliar, nas trilhas dos projetos, os workflows de projeto que leem `quality_gate.threshold` ou `RESSALVAS`.
- Adotar a proposta do glossary a partir de 2026-11-04, com bump major.
