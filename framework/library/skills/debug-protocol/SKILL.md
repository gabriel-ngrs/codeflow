---
versão: 1.0
status: estável
atualizado: 2026-05-23
descrição: Protocolo anti-loop para debug. Uma hipótese por vez, limite de tentativas, parar e reportar.
---

# Skill: debug-protocol

## Quando usar

Workflows devem carregar esta skill quando a tarefa envolve diagnóstico de bug, comportamento errôneo, ou falha não-reproduzível imediatamente. Workflows de fix puramente cosmético (typo, formatação) podem omitir.

## Princípio guia

Bug não cede a tentativas aleatórias. Cede a hipóteses testáveis aplicadas uma de cada vez. Loop em bug simples é falha de processo, não de inteligência.

## Protocolo

### 1. Reproduzir antes de hipotetizar
- Bug que não pode ser reproduzido não pode ser corrigido. Se não há reprodução, parar e pedir mais informação ao usuário.
- Reprodução é um teste ou sequência de passos manuais que sempre dispara o sintoma.

### 2. Formar uma hipótese explícita
- Hipótese declara: causa provável + arquivo/função suspeita + previsão (o que acontece se a hipótese estiver certa).
- Sem hipótese, não há mudança no código.

### 3. Testar a hipótese antes de implementar
- Adicionar log, breakpoint, ou inspeção que valida ou refuta a hipótese.
- Se a hipótese é refutada, registrar e formar nova hipótese.

### 4. Implementar fix correspondente à hipótese validada
- Apenas modificar o que a hipótese aponta. Sem refatoração adjacente.
- Validar que o sintoma desapareceu rodando a reprodução.

### 5. Limite de tentativas
- Máximo de **três** hipóteses por sessão de debug.
- Após três hipóteses falhas consecutivas, parar e aplicar política de falhas da constitution (formato PARADO).

## Proibições durante esta skill

- Não tentar duas hipóteses em paralelo. Uma por vez, completa, antes da próxima.
- Não modificar código antes de validar a hipótese.
- Não silenciar erro com try/except amplo para "fazer passar".
- Não desabilitar teste para evitar a falha.

## Saídas válidas

- **Bug corrigido:** diff mínimo aplicado, teste de regressão passando, hipótese validada documentada no resumo final do workflow.
- **Bug não corrigido (limite atingido):** reporte PARADO no formato fixo da constitution, listando as três hipóteses testadas, o que cada uma refutou, e estado atual do código.
