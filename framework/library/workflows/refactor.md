---
versão: 1.0
status: experimental
atualizado: 2026-07-10
granularidade: detalhado
gera_decision: yes
usa_checkpoints: yes
politica_falhas: padrão
---

# Workflow: refactor

## Princípio guia
Refatorar é mudar a forma sem mudar o que o código faz — e só se sabe se a forma preserva o comportamento com uma rede de testes verde antes do primeiro toque. Este workflow investiga o código real antes de propor qualquer coisa, alinha objetivo e escopo com o owner em diálogo, e executa em passos pequenos e reversíveis. Decisão aberta é resolvida com o owner, nunca chutada; mudança quebradora é declarada e confirmada antes de aplicada, nunca silenciosa.

## Quando usar
Reorganizar código existente que já funciona: extrair função ou módulo, renomear, quebrar um arquivo grande, remover duplicação, isolar uma dependência, endireitar uma camada. Serve para os dois modos, decididos na Fase 1: **puro** (comportamento observável idêntico, contrato preservado, testes verdes → verdes) e **reestruturação** (redesenho que pode mudar API, schema ou comportamento interno, com cada quebra confirmada e registrada). Pré-requisitos: o repositório tem `.codeflow/` inicializado (rode `/discover` antes, se não tiver) e o owner está disponível para confirmar objetivo, escopo e o plano — este workflow é conversacional por natureza.

## Quando NÃO usar
- Para corrigir um bug reproduzível (o objetivo é mudar comportamento) → use `/bugfix`.
- Para construir feature nova do zero, com plano por fases → use `/create-spec` e depois `/execute-spec-phase`.
- Para uma renomeação trivial e óbvia num só arquivo, sem risco e sem ambiguidade → resolva ad hoc em chat; o cerimonial deste workflow é overhead.
- Para descobrir/documentar um projeto ainda não mapeado (stack, padrões, regras) → isso é `/discover`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/safe-refactor/SKILL.md
- ~/.codeflow/framework/library/skills/debug-protocol/SKILL.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (filtrar pelas tags da área a refatorar)

## Estrutura do workflow
Seis fases sequenciais com checkpoint ao fim de cada uma. Pausa obrigatória para o owner em dois momentos: confirmação do objetivo e do **modo** (Fase 1) e aprovação do plano de refatoração (Fase 4). A execução (Fase 5) só começa depois do plano aprovado. A última fase gera decision e o resumo. Investigar sempre precede propor; propor sempre precede tocar código.

## Retomada
`refactor` usa checkpoints (`SPEC.md` §6.6). Ao iniciar, verificar se existe `.codeflow/checkpoints/refactor-*.md` recente: se sim, apresentar o resumo e perguntar ao owner se deseja retomar daquele ponto ou começar do zero. Retomar carrega a fase em pausa, o modo escolhido, o plano aprovado e o último passo verde; começar do zero deleta o checkpoint antigo.

## Fase 1 — Enquadramento e modo

### Objetivo
Entender o que o owner quer refatorar e o que já existe, e fixar o **modo** que governa o resto do protocolo.

### Ações
1. **Data canônica:** obter a data de hoje com `date +%F` via Bash; usar em todos os campos de data. Não inferir de memória.
2. **Capturar o pedido** literalmente: qual código, qual incômodo com a forma atual, qual resultado se espera da refatoração. Registrar o que o owner descreve como já existente (arquivos, módulos, padrões que ele acredita estarem em jogo) — sem validar ainda; a validação é a Fase 2.
3. **Decidir o modo com o owner:**
   - **puro** — o comportamento observável não muda; assinatura pública, contrato de API, formato de retorno e schema ficam idênticos; testes existentes passam antes e depois sem mudar asserção.
   - **reestruturação** — o redesenho pode mudar API, schema ou comportamento interno. Cada mudança quebradora será confirmada e registrada; testes que mudam de asserção serão apontados um a um.
   - Na dúvida entre os dois, apresentar a diferença ao owner e **aguardar a escolha** — não presumir.
4. Delimitar o escopo inicial em uma frase: o que entra na refatoração e o que fica explicitamente de fora.
5. **Apresentar o enquadramento (pedido, modo escolhido, escopo) ao owner e aguardar confirmação** antes de investigar.

### Checkpoint
Gravar `.codeflow/checkpoints/refactor-<timestamp>.md` com: pedido bruto, modo (puro/reestruturação), escopo declarado (entra/fica de fora), e a confirmação do owner.

## Fase 2 — Investigação do código real

### Objetivo
Substituir suposição por evidência: entender como a área funciona hoje antes de propor qualquer mudança.

### Ações
1. Ler o código da área afetada de fato — não confiar na descrição da Fase 1 nem em memória. Mapear responsabilidades, fluxos e o comportamento observável atual.
2. **Levantar consumidores e contratos:** quem chama o código a refatorar (chamadas internas, imports, APIs públicas, jobs, testes, callers externos). Isso define a fronteira do que precisa ficar intacto no modo puro.
3. Identificar os padrões e convenções vigentes na área (nomeação, camadas, estilo) — a refatoração segue o que já existe no projeto, conforme a constitution, não uma estética própria.
4. Anotar dívidas e riscos observados que **não** fazem parte do escopo (bug preexistente, dead code adjacente) para tratar em separado, sem carona.
5. Registrar dúvidas abertas que dependem do owner (ex.: "este método público é usado por alguém fora do repo?").

### Checkpoint
Atualizar o checkpoint com: mapa da área (responsabilidades e comportamento atual), consumidores/contratos, padrões vigentes, riscos fora de escopo e dúvidas abertas.

## Fase 3 — Rede de segurança

### Objetivo
Garantir uma rede de testes verde que trava o comportamento atual antes de qualquer edição, aplicando a skill `safe-refactor`.

### Ações
1. Verificar a cobertura existente sobre o comportamento da área (rodar os testes relevantes do `.codeflow/manifest.md`; se ausente, inferir do stack).
2. Onde falta cobertura, **escrever testes de caracterização** que capturam o comportamento atual como ele é hoje — inclusive quirks. Bug preexistente é preservado e anotado, não corrigido dentro do refactor.
3. Confirmar que a rede inteira (cobertura existente + caracterização nova) está **verde** antes de tocar código de produção. Se não fecha verde, parar e reportar — não há como refatorar com segurança sem baseline.
4. Em modo reestruturação, marcar quais testes descrevem comportamento que **vai** mudar; esses serão adaptados na Fase 5 com justificativa, não removidos.

### Checkpoint
Atualizar o checkpoint com: estado da cobertura antes, testes de caracterização adicionados, confirmação de baseline verde, e (modo reestruturação) a lista de testes marcados para mudar.

## Fase 4 — Plano e alinhamento

### Objetivo
Propor a refatoração em passos pequenos e reversíveis e **alinhar com o owner** antes de executar.

### Ações
1. Redigir o plano como uma sequência de passos, cada um uma transformação única e nomeável (extrair método, renomear símbolo, mover arquivo, inline), com o que deve continuar verdadeiro após cada passo.
2. Para cada mudança quebradora prevista (modo reestruturação), declarar o contrato afetado, o impacto nos consumidores da Fase 2 e o plano de adaptação — nada de quebra implícita.
3. Resolver as dúvidas abertas da Fase 2 com o owner. Escopo aberto material não é chutado: ou o owner decide, ou o item sai do escopo desta rodada.
4. **Apresentar o plano ao owner e aguardar aprovação** — esta pausa é obrigatória. Ajustes do owner re-entram no plano antes de seguir.

### Checkpoint
Atualizar o checkpoint com: plano aprovado (passos ordenados), mudanças quebradoras confirmadas, decisões de escopo resolvidas, e a aprovação do owner.

## Fase 5 — Execução incremental

### Objetivo
Aplicar o plano aprovado passo a passo, mantendo a rede verde, sob o protocolo da skill `safe-refactor`.

### Ações
1. Executar **um passo por vez**. Após cada passo, rodar a rede de testes: o estado esperado é **verde → verde**.
2. Em modo puro, teste vermelho num passo significa mudança de comportamento indevida: reverter o passo e refazer menor (não "consertar adiante"). Se travar, aplicar `debug-protocol` para diagnosticar, respeitando o limite de tentativas da política de falhas.
3. Em modo reestruturação, adaptar os testes marcados na Fase 3 junto do passo que muda o contrato, com a asserção nova refletindo o comportamento novo e o porquê registrado.
4. Manter o diff mínimo e restrito ao escopo aprovado. Surgindo um bug real ou dívida fora de escopo, registrar para tratar em separado — não misturar no diff da refatoração.
5. Ao fim de todos os passos, rodar os comandos de validação do projeto (do `.codeflow/manifest.md`; se ausente, inferir do stack) e aplicar a skill `self-review` sobre o diff completo.

### Checkpoint
Atualizar o checkpoint com: passos executados e seu resultado (verde/revertido), testes adaptados (modo reestruturação), resultado dos comandos de validação, e pendências fora de escopo registradas.

## Fase 6 — Geração de artefatos

### Objetivo
Registrar a decisão de refatoração e finalizar.

### Ações
1. **Gerar decision** em `.codeflow/decisions/<data>-<titulo>.md` (data da Fase 1) com as tags da área e do modo, registrando: o que foi refatorado e por quê, o modo, as mudanças quebradoras (se houve) e as alternativas de abordagem descartadas.
2. Atualizar `.codeflow/decisions/INDEX.md`.
3. Apresentar o resumo final no formato fixo de cinco seções.
4. Concluído com sucesso, deletar os checkpoints da execução.

## Proibições durante este workflow
- Não tocar código de produção antes da rede de testes verde (Fase 3): investigar e travar comportamento vêm primeiro.
- Não propor plano antes de investigar o código real (Fase 2): suposição da Fase 1 não é evidência.
- Não aplicar mudança quebradora em modo puro; se ela for necessária, parar e realinhar o modo com o owner.
- Não deletar nem afrouxar teste existente para o refactor "passar" — teste vermelho em modo puro é sinal de comportamento alterado, a investigar.
- Não corrigir bug preexistente dentro do refactor: caracterizar o comportamento atual e tratar o bug em separado.
- Não expandir o escopo para código adjacente não solicitado ("já que estou aqui").
- Não empilhar múltiplas transformações num passo só (Fase 5): uma de cada vez, com a rede verde entre elas.
- Não inferir datas de memória — toda data vem do `date +%F` da Fase 1.

## Definition of Done
- [ ] Data obtida via `date +%F`; pedido capturado e **modo** (puro/reestruturação) confirmado pelo owner (Fase 1).
- [ ] Código real investigado: consumidores/contratos mapeados e padrões vigentes identificados (Fase 2).
- [ ] Rede de testes verde travando o comportamento atual, com caracterização adicionada onde faltava cobertura (Fase 3).
- [ ] Plano de passos pequenos aprovado pelo owner; mudanças quebradoras confirmadas (Fase 4).
- [ ] Refatoração executada passo a passo com a rede verde ao fim de cada passo; `self-review` aplicado (Fase 5).
- [ ] Comandos de validação do projeto retornaram zero (ou `[—]` justificado).
- [ ] Decision gerada com as tags da área e do modo; `decisions/INDEX.md` atualizado; checkpoints da execução deletados (Fase 6).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
