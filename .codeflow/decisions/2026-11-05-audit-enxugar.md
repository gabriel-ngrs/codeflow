---
versão: 1.0
status: estável
atualizado: 2026-11-05
data: 2026-11-05
workflow: implement-change
tags: [anti-evolucao, auditoria, enxugar, experimental]
status_decisão: ativa
supersede: null
relaciona-com: [2026-10-02-operacao-por-trilhas]
---

# Decisões: skill universal `audit-enxugar` como exceção à anti-evolução

## Contexto

A pesquisa de tokens de 2026-11-02 apontou que o código já existente nos projetos consumidores carrega
arquivos, exports e dependências sem uso, duplicação e funções complexas demais, e que pedir "enxugue o
repo" a um agente sem lista de candidatos é o modo a evitar. O framework só tem "código morto" como item
avulso de severidade baixa no `audit-code-quality`, sem linha de base, sem ordem de risco e sem regra de
lote. Em 2026-11-05 o dono aprovou a lista inteira do pacote de tokens, que inclui uma rotina para enxugar
o código existente.

A `framework/core/EVOLUTION.md` restringe isso duas vezes: a seção "Promoção" só leva skill ou workflow a
universal com **uso real em dois projetos distintos**, e a seção "Anti-evolução" manda não criar item
universal sem o critério de "usado em dois ou mais projetos". A mesma seção diz que cada violação exige
decision com justificativa explícita e revisão em cadência mínima trimestral. Esta é essa decision.

## Decisões tomadas

### 1. A skill nasce universal sem o uso real em dois projetos, por decisão do dono
`framework/library/skills/audit-enxugar/SKILL.md` nasce direto em `library/`, sem passar por skill de
projeto, contra a anti-regra da `EVOLUTION.md` ("Anti-evolução" e "Promoção": uso real em dois projetos).
**Por quê:** o dono decidiu em 2026-11-05, ao aprovar a lista do pacote de tokens; o custo de tokens que a
rotina ataca aparece em todos os projetos consumidores JS/TS, e nascer como skill de um projeto obrigaria a
copiá-la para os outros antes da promoção.
**Alternativa rejeitada:** nascer como skill de projeto num consumidor e promover depois do segundo uso —
atrasa a rotina nos demais projetos sem ganho de evidência que a revisão da decisão 3 não dê.

### 2. Nasce `experimental`
A skill nasce com `status: experimental` e `versão: 1.0`, como os demais itens novos do framework.
**Por quê:** é o estado que sinaliza contrato ainda não exercitado em uso real.
**Alternativa rejeitada:** nascer `estável` — afirmaria uso que ainda não existe.

### 3. Revisão em 2027-02-05, com critério de saída
Na revisão trimestral de 2027-02-05 confere-se o uso real: se a dimensão `enxugar` não rodou em pelo menos
dois projetos distintos até lá, a skill é removida de `library/` ou rebaixada a skill de projeto do
consumidor que a usou. Com uso em dois projetos, a exceção se encerra e a skill segue o regime normal de
`experimental` → `estável`.
**Por quê:** é a revisão posterior que a "Anti-evolução" exige, com um critério verificável em vez de
"rever depois".
**Alternativa rejeitada:** revisão sem data nem critério — a exceção viraria permanente por omissão.

### 4. Encaixe como dimensão do `/audit`, não workflow próprio
A rotina é uma dimensão nova da família `/audit` (entrada `enxugar`), carregada pelo `/audit` para listar
e confirmar candidatos e pelo `/refactor`, em modo puro, para executar cada lote. Não nasce workflow, slash
command nem wrapper.
**Por quê:** o `/audit` (somente leitura, ferramentas primeiro, laudo pelo molde), o `/verify-audit`
(confirmação em chat zerado, consolidado) e o `/refactor` (rede verde, passo a passo, `self-review`) já
cobrem os passos com decisão aberta; falta só a capacidade de enxugar, que é o que uma skill dá.
**Alternativa rejeitada:** workflow próprio sobre o `refactor` — repetiria o protocolo dos três e criaria
um segundo workflow universal sem uso, agravando a exceção.

## Próximos passos sugeridos

- Agendar a revisão de 2027-02-05 na trilha de auditoria, junto às demais revisões trimestrais.
