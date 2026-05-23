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

## Quando usar
Corrigir bug reproduzível em código existente. Há sintoma observável, hipótese inicial possível, e escopo da correção é limitado a poucos arquivos. Pré-requisito: bug pode ser reproduzido localmente ou via teste.

## Quando NÃO usar
- Para feature nova → use `/feature-small`.
- Para refatoração sem bug → use `/refactor-safe`.
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
- Se o fix envolveu mudança não-trivial (não foi typo, não foi off-by-one isolado), gerar decision em `.codeflow/decisions/`.

## Definition of Done
- [ ] Bug reproduzido no Passo 1.
- [ ] Teste de regressão adicionado e falhando antes do fix.
- [ ] Teste de regressão passando após o fix.
- [ ] `make check` retornou zero.
- [ ] Diff dentro do escopo declarado.
- [ ] Self-review aplicado.
- [ ] Decision gerada se aplicável (gera_decision: auto).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
