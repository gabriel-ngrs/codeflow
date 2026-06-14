---
versão: 1.0
status: estável
atualizado: 2026-05-23
---

# Política de evolução do codeflow

Este documento descreve como o codeflow cresce sem virar bagunça. Aplicar este protocolo é responsabilidade do mantenedor. Qualquer evolução do framework deve passar por uma das seções abaixo.

## Promoção (skill/workflow de projeto → universal)

Uma skill ou workflow específico de projeto pode ser promovido a universal — movido de `<projeto>/.codeflow/` para `~/.codeflow/framework/library/` — apenas quando **todos** os critérios mínimos abaixo são satisfeitos:

- Uso real em **dois projetos distintos**. Não há prazo mínimo; o que conta é o uso efetivo, não o tempo decorrido.
- A skill ou workflow tem teste em projeto real, não apenas em exemplo do mantenedor.
- A skill ou workflow é referenciado por pelo menos **um workflow** (universal ou específico).
- O mantenedor aprova a promoção.

**Versionamento:** `bump minor` (`X.Y` → `X.(Y+1)`) no manifesto do framework. A promoção é mudança aditiva — não altera comportamento de itens já universais.

**Processo:**

1. `git mv <projeto>/.codeflow/skills/<nome>/ ~/.codeflow/framework/library/skills/<nome>/` (ou caminho análogo para workflow).
2. Atualizar referências cruzadas em workflows que carregavam o item via caminho de projeto.
3. Commit no repositório do framework com mensagem `promote: <tipo> <nome> de <projeto-origem>`.

**O que NÃO justifica promoção:** uso em um único projeto, ainda que extenso; "achei a ideia boa" sem cliente real; cópia de skill análoga vista em outro framework.

## Adição de rule

Uma nova rule universal (módulo temático em `~/.codeflow/framework/core/rules/`) pode ser adicionada apenas quando **ambos** os critérios abaixo são satisfeitos:

- O tema é claramente universal: aplica-se independentemente de stack, linguagem ou domínio.
- A rule tem pelo menos **três regras concretas** com anti-regras correspondentes.

Aprovação: mantenedor. Não há outro filtro.

**O que NÃO justifica adição:** tema cujo conteúdo só faz sentido em uma stack específica (vai para rule de projeto); rule com menos de três regras concretas (não atinge densidade mínima); rule cujo conteúdo se sobrepõe substancialmente a uma rule existente.

## Adição de meta-skill

Uma nova meta-skill (em `~/.codeflow/framework/meta/`) pode ser adicionada apenas quando o critério abaixo é satisfeito:

- Existe artefato do framework cuja criação manual é repetitiva e propensa a inconsistência. A meta-skill resolve essa repetição.

Aprovação: mantenedor.

**Exigências obrigatórias antes de marcar a meta-skill como `estável`:**

- Template de saída completo dentro da própria meta-skill.
- Pelo menos um exemplo preenchido do artefato que ela gera.
- Testes da meta-skill em pelo menos **dois casos diferentes** (projetos ou cenários distintos).

**O que NÃO justifica criação:** meta-skill que gera artefato que ainda não existe no framework (resolver o artefato primeiro); meta-skill que apenas envolve uma skill existente sem agregar valor; meta-skill especulativa sem dor concreta documentada.

## Mudança em arquivo do core (constitution, glossary, EVOLUTION)

Arquivos do core são `~/.codeflow/framework/core/constitution.md`, `~/.codeflow/framework/core/glossary.md` e este `EVOLUTION.md`. Mudanças aqui têm regime estrito porque afetam o comportamento de toda sessão do codeflow em todos os projetos.

**Período de transição obrigatório:** entre a proposta da mudança e sua adoção definitiva, deve haver **30 dias** mínimos. Durante esse período, a versão anterior permanece referenciável via tag git e a nova versão é exercitada em pelo menos um projeto real do mantenedor.

**Versionamento:** `bump major` (`X.Y` → `(X+1).0`). Toda mudança em arquivo do core é tratada como capaz de alterar comportamento, mesmo quando o intuito é apenas aditivo — o regime é uniformemente estrito.

**Processo:**

1. Abrir proposta em decision dedicada (`.codeflow/decisions/`), descrevendo a mudança e o motivo.
2. Aguardar 30 dias com a proposta visível.
3. Aplicar a mudança no arquivo do core, com bump major.
4. Registrar entrada em `## Histórico de evoluções aplicadas` (quando esta seção existir).

**O que NÃO justifica mudança:** typo (corrigido sem cerimônia, sem bump); reformatação que não altera significado (idem); preferência estética do mantenedor sem demanda funcional.

## Anti-evolução

Estas restrições são vinculantes para o mantenedor. Quando a tentação de evoluir o framework surgir contra um destes itens, a resposta padrão é **não**:

- Não adicionar tipos novos de artefatos sem ter sentido a dor de não tê-los **três vezes**.
- Não copiar estruturas de outros frameworks sem propósito explícito declarado em decision.
- Não adicionar campos opcionais em templates só porque "pode ser útil".
- Não criar workflow universal sem o critério de "usado em dois ou mais projetos".

Cada decisão de evolução que viole uma destas anti-regras exige registro em decision com justificativa explícita, e revisão posterior em cadência mínima trimestral.
