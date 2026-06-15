---
versão: 1.0
status: estável
atualizado: 2026-05-23
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
Se o bug toca em áreas com decisions arquivadas (auth, payments, schema), consultar `.codeflow/decisions/INDEX.md` e carregar decisions ATIVAS por tag.

## Protocolo

### Passo 1 — Reproduzir o bug
- Executar passos de reprodução fornecidos pelo usuário ou inferidos do relato.
- Confirmar sintoma observável (mensagem de erro, comportamento incorreto, output divergente).
- Gate: bug reproduzido. Se não reproduz, parar e pedir mais informação.

### Passo 2 — Escrever teste de regressão
- Criar teste que captura o comportamento errado: falha agora, passa após o fix.
- Não modificar código de produção ainda.
- Gate: teste roda e falha pelo motivo esperado.

### Passo 3 — Formar hipótese
- Aplicar protocolo da skill `debug-protocol`: uma hipótese por vez, declarada explicitamente, com critério de teste claro.
- Limite: três hipóteses no total. Se três falharem, aplicar política de falhas e parar.

### Passo 4 — Implementar fix
- Modificar **apenas** os arquivos necessários para a hipótese atual.
- Diff mínimo conforme constitution universal.
- Gate: teste de regressão (Passo 2) passa.

### Passo 5 — Validar
- Executar `make check` (ou alternativas conforme `.codeflow/manifest.md`).
- Aplicar skill `self-review` no diff produzido.
- Se `make check` falha: aplicar política de falhas da constitution.

### Passo 6 — Resumir e (se aplicável) gerar decision
- Apresentar resumo final no formato fixo de cinco seções.
- **Gatilhos de decision (`gera_decision: auto`) — gerar decision em `.codeflow/decisions/` quando qualquer um ocorrer:**
  1. O fix envolveu mudança não-trivial (não foi typo, não foi off-by-one isolado).
  2. **Default após incerteza do usuário:** a IA fez uma pergunta (ex.: qual status code), o usuário respondeu `não sei` / `o que você recomenda?` / `usa o padrão`, e a IA aplicou um default. Registrar o default escolhido e por que esse (e não outro) — para que futuros leitores entendam a escolha que ficou no código. Vale mesmo quando o default "restaura o HEAD" ou "alinha à constitution": registrar é o comportamento esperado, não opcional.
  3. **Divergência consciente da constitution:** a implementação contraria uma regra invariante da constitution (do projeto ou universal) — seja para seguir a convenção real do código, seja por trade-off técnico. Registrar: qual regra, qual divergência, por quê, e qual débito fica aberto (corrigir a constitution ou corrigir o código). Sem decision, o conflito fica silenciado.

## Definition of Done
- [ ] Bug reproduzido no Passo 1.
- [ ] Teste de regressão adicionado e falhando antes do fix.
- [ ] Teste de regressão passando após o fix.
- [ ] `make check` retornou zero.
- [ ] Diff dentro do escopo declarado.
- [ ] Self-review aplicado.
- [ ] Decision gerada se aplicável (gera_decision: auto) — incluindo default após "não sei" do usuário e divergência consciente da constitution.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
