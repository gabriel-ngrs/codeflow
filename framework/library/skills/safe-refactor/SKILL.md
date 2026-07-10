---
versão: 1.0
status: experimental
atualizado: 2026-07-10
descrição: Refatoração segura — rede de testes antes de mexer, um refactor por vez, passos pequenos e reversíveis, comportamento travado.
---

# Skill: safe-refactor

## Quando usar

Workflows devem carregar esta skill quando a tarefa reorganiza código existente sem que o objetivo seja um novo comportamento: extrair função, renomear, mover módulo, quebrar uma classe grande, remover duplicação, isolar uma dependência. Vale tanto para refatoração pura (comportamento idêntico) quanto para reestruturação declarada. Workflows de fix de bug (o objetivo é mudar comportamento) usam `debug-protocol`, não esta skill.

## Princípio guia

Refatorar é mudar a forma sem mudar o que o código faz. A rede de testes vem antes do primeiro toque; sem ela, não há como saber se a forma nova preserva o comportamento. Um refactor de cada vez, pequeno e reversível, é o que separa refatoração de reescrita arriscada.

## Protocolo

### 1. Travar o comportamento antes de mexer
- Nenhuma mudança estrutural começa sem uma rede de testes verde cobrindo o comportamento da área afetada.
- Se a cobertura existe e passa, essa é a rede. Se não existe, escrever **testes de caracterização** que capturam o comportamento atual como ele é hoje — inclusive quirks — e confirmar que passam antes de qualquer edição.
- Teste de caracterização descreve o que o sistema faz agora, não o que deveria fazer. Bug preexistente é preservado (e anotado), não corrigido dentro do refactor.

### 2. Um refactor por vez
- Cada passo é uma transformação nomeável e única (extrair método, renomear símbolo, inline de variável, mover arquivo). Não empilhar duas transformações no mesmo passo.
- Declarar o passo antes de aplicá-lo: qual transformação, em quais símbolos/arquivos, e o que deve continuar verdadeiro depois.

### 3. Verde depois de cada passo
- Rodar a rede de testes ao fim de cada passo. O estado esperado é **verde → verde**.
- Se um teste fica vermelho num passo de refatoração pura, o passo introduziu mudança de comportamento: reverter o passo (não seguir em frente "consertando" adiante) e refazer menor.

### 4. Preservar o contrato, ou declarar a quebra
- Em modo puro: assinatura pública, formato de retorno, schema e contrato de API ficam idênticos. Qualquer alteração desses é mudança quebradora — parar e escalar ao workflow, não decidir sozinho.
- Em modo reestruturação: mudança de contrato é permitida, mas cada uma é explicitada e os testes que mudam de asserção são apontados um a um, com o porquê.

### 5. Diff mínimo, sem carona
- Refatorar **apenas** o que a tarefa declarou. Nada de "já que estou aqui" em código adjacente fora do escopo.
- Não misturar mudança de comportamento (fix, feature) no mesmo diff de refatoração. Se surgir um bug real durante o trabalho, registrar e tratar em separado.

## Proibições durante esta skill

- Não editar código de produção antes de ter a rede de testes verde cobrindo a área.
- Não deletar nem afrouxar teste existente para fazer o refactor "passar"; teste vermelho num refactor puro sinaliza mudança de comportamento — reverter, investigar.
- Não empilhar múltiplas transformações num passo só para "adiantar".
- Não corrigir bug preexistente dentro do refactor — caracterizar o comportamento atual e tratar o bug fora.
- Não alterar contrato público em modo puro sem parar e escalar.
- Não expandir o escopo para código adjacente não solicitado.

## Saídas válidas

- **Refatoração concluída:** sequência de passos pequenos aplicada, rede de testes verde no início e no fim, contrato preservado (modo puro) ou quebras declaradas (modo reestruturação), diff restrito ao escopo.
- **Refatoração interrompida:** reporte PARADO no formato da constitution, indicando o último passo verde, o passo que quebrou o comportamento (ou tocou contrato/escopo), e o estado atual da rede de testes.
