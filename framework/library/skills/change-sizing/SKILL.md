---
versão: 1.0
status: experimental
atualizado: 2026-10-02
descrição: Classificar um pedido de mudança — tipo (melhoria, feature, ou fora do ciclo) e tamanho (pequena, média, grande) — por critérios objetivos, antes de planejar.
---

# Skill: change-sizing

## Quando usar

Workflows devem carregar esta skill no início do ciclo de mudança (`/plan-change`) e sempre que um
orquestrador precisa decidir para onde um pedido vai: o ciclo de mudança (pequena ou média), a
trilha de spec (grande), ou outra trilha (bug, regra de negócio). É a porta de entrada que impede
uma feature grande de entrar como "melhoria" e uma correção de entrar como "feature".

## Princípio guia

Tamanho não é impressão, é contagem de riscos: quantas etapas, quantas fronteiras, quanto se pode
desfazer. Uma mudança só é pequena ou média se **todos** os sinais disserem isso; um sinal de grande
basta para ela ser grande.

## Protocolo

### 1. Decidir se o pedido é do ciclo de mudança
- **Bug** — o sistema faz algo diferente do que já foi especificado ou prometido → não é deste ciclo
  (vai para o fluxo de bug).
- **Regra de negócio** — o pedido muda prazo, limite, preço, política → a decisão é do dono do
  negócio antes de virar código; registrar e parar.
- **Configuração** — o que falta é um valor ou um ponto de configuração, não comportamento novo →
  tratar como configuração, se o projeto tiver esse conceito.
- Sobrou: é **mudança**. Seguir.

### 2. Decidir o tipo
- **Melhoria** — muda, ajusta ou melhora o que **já existe**: refino de comportamento, ergonomia,
  dívida técnica, robustez, clareza.
- **Feature** — capacidade **nova**, que o sistema hoje não tem, por iniciativa do dono ou pedido de
  cliente.
- Em dúvida, a pergunta é: "o usuário consegue fazer isto hoje, de algum jeito?" Sim → melhoria.
  Não → feature. O tipo muda o registro, não o processo.

### 3. Medir o tamanho por sinais
Avaliar cada sinal e anotar o valor. **Qualquer** sinal na coluna "grande" torna a mudança grande.

| Sinal | Pequena | Média | Grande |
| --- | --- | --- | --- |
| Etapas para entregar com segurança | 1 | 2 a 4 | 5 ou mais, ou fases com dependência |
| Áreas do código tocadas (módulo, camada, app) | 1 | 2 a 3 | 4 ou mais |
| Contrato ou fronteira entre partes (API, schema, protocolo, formato de dado persistido) | não toca | toca de forma compatível (campo novo opcional) | muda ou quebra |
| Migração de dado ou de schema | não | aditiva e reversível | destrutiva ou irreversível |
| Decisão de arquitetura nova (ADR) | não | não | sim |
| Comportamento que o usuário final percebe | nenhum ou cosmético | novo, porém isolado | muda fluxo existente de ponta a ponta |
| Trabalho em paralelo de mais de uma pessoa ou track | não | não | sim |

- Somar às réguas do projeto: se o projeto declara fronteiras ou áreas sensíveis (rules, ADRs,
  método), tocar uma delas **de forma não compatível** é sinal de grande.

### 4. Registrar a classificação
- Uma linha por sinal, com o valor encontrado e a evidência (arquivo, contrato, ADR).
- A conclusão: tipo, tamanho, e o destino — ciclo de mudança (pequena/média) ou trilha de spec
  (grande).
- Quando um sinal está na fronteira entre duas faixas, classificar na faixa **maior** e dizer por quê.

## Proibições durante esta skill

- Não classificar por impressão de esforço ("parece rápido") — só pelos sinais.
- Não rebaixar uma mudança grande para caber no ciclo de mudança; grande é spec.
- Não tratar regra de negócio como mudança de código antes de o dono decidir a regra.
- Não deixar sinal sem evidência: sinal que não se verificou no código é registrado como "não
  verificado" e conta como a faixa maior.

## Saídas válidas

- **Classificação:** tipo (melhoria ou feature), tamanho (pequena, média ou grande), a tabela de
  sinais com valor e evidência, e o destino recomendado.
- **Fora do ciclo:** o pedido é bug, regra de negócio ou configuração, com o motivo e a trilha certa.
