---
versão: 1.0
status: estável
atualizado: 2026-10-06
data: 2026-10-06
workflow: implement-change
tags: [core, glossary, veredito, adocao]
status_decisão: ativa
supersede: 2026-10-05-proposta-glossary-veredito
relaciona-com: [2026-10-05-proposta-glossary-veredito, 2026-10-05-aceleracao-do-ciclo]
---

# Decisões: adoção da proposta do glossary — veredito, avaliação de fase e herdado

## Contexto

A decision `2026-10-05-proposta-glossary-veredito` propôs três entradas para o `framework/core/glossary.md`
("Veredito", "Avaliação de fase" e o termo novo "Herdado"), para alinhar o vocabulário oficial ao veredito da
avaliação de fase que a `2026-10-05-aceleracao-do-ciclo` já tinha mudado no `ARTIFACTS_SPEC.md` §2.10.3. O
glossary é core e segue o regime de `framework/core/EVOLUTION.md` ("Mudança em arquivo do core"): 30 dias
entre proposta e adoção, versão anterior referenciável por tag git, nova versão exercitada em projeto real e
bump major. Em 2026-10-06 o dono ordenou aplicar a proposta sem esperar o fim do prazo.

## Decisões tomadas

### 1. Adotar a proposta e aplicar as três entradas no glossary 2.0
As decisões 1, 2 e 3 da proposta entram no `framework/core/glossary.md` com o texto proposto, na seção
"Termos do pipeline de spec": "Avaliação de fase" e "Veredito" reescritas no lugar, "Herdado" logo depois de
"Veredito". Bump major 1.2 → 2.0, `atualizado: 2026-10-06`.
**Por quê:** o glossary 1.2 definia `RESSALVAS` e scorecard ponderado, contrato que deixou de valer em
2026-10-05; um vocabulário oficial que contradiz o `ARTIFACTS_SPEC.md` induz a IA ao erro em toda avaliação.
**Alternativa rejeitada:** manter o 1.2 até 2026-11-04 — o vocabulário seguiria contradizendo o contrato
por mais quatro semanas, sem nada a ganhar com a espera (decisão 2).

### 2. Dispensa dos 30 dias, pelo dono, em 2026-10-06
O dono dispensou o período de transição de 30 dias em 2026-10-06. O prazo serve para a nova regra ser
exercitada em projeto real antes de virar oficial, e isso já aconteceu: as regras estão em uso no framework
desde o PR #2 e foram adotadas por dois projetos reais do mantenedor, cada um com ADR própria de adoção
(ADR-76 num, ADR-28 no outro; os nomes ficam fora deste repositório público), o que cumpre o
"exercitada em pelo menos um projeto real" do EVOLUTION. A dispensa vale só para esta mudança; o regime do
core segue igual para as próximas.
**Por quê:** o glossary é o único lugar que ainda descreve o contrato antigo; o risco que o prazo mitiga
(regra não testada em uso) já não existe.
**Alternativa rejeitada:** cumprir o prazo integral — custo de quatro semanas de contradição sem ganho de
evidência.

### 3. A versão 1.2 fica referenciável pela tag git `glossary-v1.2`
A tag `glossary-v1.2` aponta para o último commit com o glossary 1.2, e é ela que atende à exigência de a
versão anterior seguir referenciável. Artefatos antigos com `RESSALVAS` continuam legíveis pela própria
entrada "Veredito" 2.0, que o lê como `APROVADO`.
**Por quê:** é o mecanismo que o EVOLUTION nomeia para a versão anterior, sem duplicar arquivo no core.
**Alternativa rejeitada:** manter uma cópia `glossary-1.2.md` no core — arquivo morto que cresce a cada
major.

## Próximos passos sugeridos

- O `framework/core/SPEC.md` §6.3 pede aviso em CHANGELOG do repositório para mudança de core que altera
  comportamento; o repositório não tem CHANGELOG. Fica para a Auditoria decidir se cria um ou se a decision
  basta.
- O `framework/core/SPEC.md` §6.2 diz que o glossário só pode ser estendido, não modificado
  retroativamente; esta adoção reescreve "Veredito" e "Avaliação de fase". A leitura de `RESSALVAS` como
  `APROVADO` preserva os artefatos antigos, mas o texto do §6.2 merece revisão na Auditoria.
- A lista de vocabulário do `framework/core/SPEC.md` §4.2 (spec, fase, track/wave, veredito, gate
  estrutural, máquina de estados) não cita "herdado".
