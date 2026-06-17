---
versão: 1.2
status: estável
atualizado: 2026-06-16
granularidade: médio
gera_decision: auto
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: bugfix

> **Spec de runtime:** a referência a `SPEC.md §x` neste workflow aponta para `~/.codeflow/framework/core/SPEC.md`.

## Quando usar
Corrigir bug reproduzível em código existente. Há sintoma observável, hipótese inicial possível, e escopo da correção é limitado a poucos arquivos. Pré-requisito: bug pode ser reproduzido localmente ou via teste.

## Quando NÃO usar
- Para feature nova ou refatoração sem bug → resolver ad hoc em chat; se o escopo for grande o bastante para exigir plano, usar `/create-spec`.
- Para investigar comportamento incerto (não há sintoma claro) → discutir em chat antes de invocar workflow.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/debug-protocol/SKILL.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Antes de começar
- Se o bug toca em áreas com decisions arquivadas (auth, payments, schema), consultar `.codeflow/decisions/INDEX.md` e carregar decisions ATIVAS por tag.
- **Declarar o escopo esperado:** com base no relato, listar os arquivos que se espera tocar para corrigir. É uma âncora, não uma trava — refina-se durante a investigação —, mas tocar fora dela é **sinal de alerta** de refatoração lateral, e é contra essa lista que o `self-review` confere "diff dentro do escopo declarado" (Passo 5). Se a investigação obrigar a sair do escopo, declarar explicitamente por quê antes de fazê-lo.

## Protocolo

### Passo 1 — Reproduzir o bug
- Executar passos de reprodução fornecidos pelo usuário ou inferidos do relato.
- Confirmar sintoma observável (mensagem de erro, comportamento incorreto, output divergente).
- Gate: bug reproduzido. Se não reproduz, parar e pedir mais informação.

### Passo 2 — Escrever teste de regressão
- Criar teste que captura o comportamento errado: falha agora, passa após o fix.
- Não modificar código de produção ainda.
- Gate: teste roda e falha pelo motivo esperado.
- **Quando teste automatizado é inviável** (bug de UI, timing, configuração de ambiente, integração externa sem mock viável): não forçar um teste frágil só para cumprir o passo. Declarar a **sequência de reprodução manual** do Passo 1 como o gate de regressão (passos exatos que disparam o sintoma antes do fix e param de disparar depois) e **registrar por que o teste automatizado não cabe** — mesma honestidade do `[—]` justificado do Passo 5. Reprodução manual vira o critério de verificação; não pular para o fix sem ela.

### Passo 3 — Formar hipótese
- Aplicar protocolo da skill `debug-protocol`: uma hipótese por vez, declarada explicitamente, com critério de teste claro.
- **Ancorar a hipótese no código real:** a hipótese cita o `arquivo:linha` suspeito que foi efetivamente lido no repositório — não descreve uma causa abstrata "de cabeça". Sem âncora verificada no código, é palpite, não hipótese; ler o caminho antes de afirmar a causa.
- Limite: três hipóteses no total. Se três falharem, aplicar política de falhas e parar.

### Passo 4 — Implementar fix
- Modificar **apenas** os arquivos necessários para a hipótese atual.
- Diff mínimo conforme constitution universal.
- Gate: teste de regressão (Passo 2) passa.

### Passo 5 — Validar
- Rodar os comandos de validação do projeto (do `.codeflow/manifest.md`; se ausente, inferir do stack) — **o necessário para provar o fix**: o teste de regressão do Passo 2 + lint/type dos arquivos tocados. Não rodar a suíte inteira por reflexo se o subconjunto já prova.
- Aplicar skill `self-review` no diff produzido.
- Se um comando de validação falha: aplicar política de falhas da constitution. Gate que não existe no projeto → `[—]` com justificativa, não falha (SPEC §3.10).

### Passo 6 — Resumir e (se aplicável) gerar decision
- Apresentar resumo final no formato fixo de cinco seções.
- **Gatilhos de decision (`gera_decision: auto`) — gerar decision em `.codeflow/decisions/` quando qualquer um ocorrer:**
  1. O fix envolveu mudança não-trivial (não foi typo, não foi off-by-one isolado).
  2. **Default após incerteza do usuário:** a IA fez uma pergunta (ex.: qual status code), o usuário respondeu `não sei` / `o que você recomenda?` / `usa o padrão`, e a IA aplicou um default. Registrar o default escolhido e por que esse (e não outro) — para que futuros leitores entendam a escolha que ficou no código. Vale mesmo quando o default "restaura o HEAD" ou "alinha à constitution": registrar é o comportamento esperado, não opcional.
  3. **Divergência consciente da constitution:** a implementação contraria uma regra invariante da constitution (do projeto ou universal) — seja para seguir a convenção real do código, seja por trade-off técnico. Registrar: qual regra, qual divergência, por quê, e qual débito fica aberto (corrigir a constitution ou corrigir o código). Sem decision, o conflito fica silenciado.

## Definition of Done
- [ ] Bug reproduzido no Passo 1.
- [ ] Escopo esperado declarado antes da investigação (Antes de começar).
- [ ] Hipótese validada ancorada em `arquivo:linha` real (Passo 3).
- [ ] Teste de regressão adicionado e falhando antes do fix — **ou** sequência de reprodução manual declarada como gate, com justificativa de por que o teste automatizado não cabe (Passo 2).
- [ ] Teste de regressão passando após o fix — **ou** reprodução manual deixa de disparar o sintoma.
- [ ] Comandos de validação do projeto retornaram zero (ou `[—]` justificado).
- [ ] Diff dentro do escopo declarado.
- [ ] Self-review aplicado.
- [ ] Decision gerada se aplicável (gera_decision: auto) — incluindo default após "não sei" do usuário e divergência consciente da constitution.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
