---
versão: 1.1
status: experimental
atualizado: 2026-10-05
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: review-change

## Quando usar
Revisar, de forma **independente e cética**, uma melhoria ou feature executada por `/implement-change`: o diff da mudança, o `EXECUCAO.md` e o `PLANO.md` aprovado. **Sempre em chat zerado**, separado de quem implementou — o relatório é ponto de partida, não prova. Grava `.codeflow/changes/<slug>/REVISAO-<tentativa>.md` com o veredito: `APROVADO` (zero BLOQUEANTE), `AJUSTAR` ou `PENDENTE-EXTERNO`.

## Quando NÃO usar
- No mesmo chat que implementou → quebra a independência. Abra um chat novo.
- Para corrigir o código → este workflow só julga; as correções voltam ao `/implement-change` em rework.
- Para fase de spec → `/evaluate-spec-phase`. Para lote de bugs → `/double-check`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/core/rules/security.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- ~/.codeflow/framework/library/skills/accessibility-audit/SKILL.md e visual-consistency/SKILL.md (carregar quando a mudança toca interface gráfica)
- ~/.codeflow/framework/library/templates/changes/REVISAO.md (o molde)
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Antes de começar
- **Independência:** se houver qualquer chance de você ter escrito ou alterado este código na sessão atual, parar e pedir um chat novo.
- Ler o `PLANO.md` (CA, etapas, fora de escopo) e o `EXECUCAO.md` (o `range` e a `tentativa`). Sem `EXECUCAO.md`, nada a revisar: parar.
- Consultar `.codeflow/decisions/INDEX.md` e carregar as decisions ATIVAS das áreas tocadas, mais as rules do projeto que o plano cita.

## Protocolo

### Passo 1 — Isolar o diff
- Na branch atual, confirmar que os commits do `range` são ancestrais do HEAD (`git merge-base --is-ancestor <sha_final> HEAD`); se não forem, parar — branch errada.
- Ler o diff **completo** do `range`, excluindo `.codeflow/changes/`. Comparar com o mapa do código do plano: arquivo tocado fora do mapa é achado.
- Gate: diff de código lido na íntegra.

### Passo 2 — Rodar as verificações você mesmo
- Rodar a **validação completa** do projeto (do manifest) — aqui roda-se o máximo, porque é o último gate antes do PR. Mais os greps de segredo e dado pessoal (devem ser zero).
- Para cada CA, a prova **própria**: o teste correspondente rodado, ou a reprodução do comportamento. Colar as **saídas reais**.
- Sem mutar o repositório: se uma verificação suja a árvore, reverter. Não criar nem reescrever commits.
- Gate: verificações rodadas, com saída real, e árvore limpa.

### Passo 3 — Julgar
- **Conformidade:** cada CA atendido com evidência; as etapas entregues como planejado; nada fora do escopo.
- **Qualidade:** aplicar a skill `self-review` como revisor; rules e decisions do projeto respeitadas; testes que testam de fato (falham sem a mudança); reuso em vez de duplicação.
- Classificar cada achado: **BLOQUEANTE** (CA não atendido, rule violada, regressão, risco de segurança ou de dado), **IMPORTANTE** (problema real que não impede a entrega), **SUGESTÃO**. Cada um com `arquivo:linha` e a régua violada.
- **Escalada:** vira BLOQUEANTE o IMPORTANTE da revisão anterior com destino "corrigir agora" que segue aberto (o mesmo IMPORTANTE pela 2ª vez), e o conjunto quando há **3 ou mais IMPORTANTES abertos** ao mesmo tempo.
- **Erro só de registro** (frontmatter, `range`, lista de arquivos, link) vai à parte e não entra no veredito: o implementador o corrige num commit só de documento, sem nova revisão.
- Gate: todo achado classificado e com evidência.

### Passo 4 — Veredito
- Precedência estrita `AJUSTAR` > `PENDENTE-EXTERNO` > `APROVADO`: **AJUSTAR** se há pelo menos um BLOQUEANTE, contada a escalada; senão **PENDENTE-EXTERNO** se uma verificação não pôde ser fechada por depender de algo fora da mudança (cota, push ou CI remoto, ação física do dono, outra mudança que precisa entrar antes) — nomear a condição e quem a resolve; senão **APROVADO**. Nota não decide veredito.
- Cada IMPORTANTE sai com destino: corrigir agora, se for barato — no rework, se houver um; com `APROVADO`, num commit próprio antes do PR, sem nova revisão —, ou registrar como melhoria. SUGESTÃO se descarta por padrão.
- Gate: veredito coerente com a contagem de BLOQUEANTES.

### Passo 5 — Gravar e commitar a revisão
- Preencher `REVISAO-<tentativa>.md` a partir do molde, com as divergências entre o relatório e o código. Commitar. **O revisor não altera código.**
- Se `AJUSTAR`, instruir: os BLOQUEANTES voltam ao `/implement-change` em rework, e a próxima revisão é em chat zerado de novo. Se `PENDENTE-EXTERNO`, instruir: resolver a condição nomeada e revisar de novo a mesma tentativa, sem rework; não conta para o teto.

## Definition of Done
- [ ] Independência garantida (chat zerado); plano e relatório lidos; nada a revisar sem `EXECUCAO.md`.
- [ ] Commits do `range` ancestrais do HEAD; diff de código lido na íntegra e comparado ao mapa do plano.
- [ ] Validação completa do projeto rodada pelo revisor (ou `[—]` justificado), com saídas reais; greps de segredo e dado pessoal zerados; árvore limpa.
- [ ] Cada CA conferido com prova própria; todo achado classificado com `arquivo:linha` e régua.
- [ ] Escalada aplicada e erros de registro à parte; veredito `APROVADO` só com zero BLOQUEANTE, `PENDENTE-EXTERNO` só com a condição de fora nomeada; IMPORTANTES com destino.
- [ ] `REVISAO-<tentativa>.md` gravado a partir do molde e commitado; nenhum código alterado.

## Resumo final
Apresentar no formato do resumo final do `SPEC.md` §5.6.4, sem abrir o arquivo para isso: o título `## ✓ CONCLUÍDO: <workflow> — <escopo>` e as cinco seções, na ordem — `### O que foi feito`, `### Checklist Definition of Done`, `### Riscos e notas`, `### Próximos passos sugeridos`, `### Decisão registrada (se aplicável)`, com o veredito explícito e a contagem de achados por severidade.
