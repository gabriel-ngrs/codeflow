---
versão: 1.4
status: experimental
atualizado: 2026-06-15
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: evaluate-spec-phase

## Quando usar
Avaliar, de forma **independente e cética**, a fase executada por `/execute-spec-phase`: o código gerado, o relatório `FASE-<id>-*-EXECUCAO.md` e os commits da fase. **Invocar sempre em um chat zerado, separado do que executou** — a independência é o ponto: o avaliador não confia no relatório, verifica tudo contra o código real. Emite scorecard + veredito machine-readable. O **threshold** é o `quality_gate.threshold` do frontmatter da spec (default 8.5 se ausente); o usuário pode informar outro ao invocar, e o valor efetivamente usado é persistido na avaliação.

## Quando NÃO usar
- No mesmo chat que executou a fase → quebra a independência (a IA tende a validar o próprio trabalho). Abra um chat novo.
- Para corrigir o código → este workflow **só avalia e reporta**; as correções voltam ao chat executor.
- Para avaliar uma fase ainda não executada (sem `FASE-<id>-*-EXECUCAO.md`) → nada a avaliar.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/core/rules/security.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (carregar decisions ATIVAS cujas tags cruzem o domínio da fase)

## Antes de começar
**Auto-check de independência:** se você implementou ou alterou este código nesta mesma sessão/chat, **declare isso e recomende reabrir num chat zerado** antes de avaliar — a independência é o motivo de existir deste workflow. **Trocar para a branch de trabalho da spec** (`spec/<slug>`, ou a de `.codeflow/manifest.md`) **antes de qualquer coisa** — o código da fase, a spec e os artefatos foram commitados nela; em `main` (chat zerado) eles não aparecem e você avaliaria a árvore errada. Identificar a spec e a fase a avaliar (por slug em `.codeflow/specs/`; por padrão, a fase cujo `FASE-<id>-*-EXECUCAO.md` tem `tentativa: T` **sem** AVALIACAO de `tentativa: T` — ou seja, a tentativa corrente ainda não avaliada). Reusar `fase` (`id`) e `slug_fase` do EXECUCAO **verbatim** ao nomear o arquivo de avaliação. Resolver o threshold: `quality_gate.threshold` da spec, ou o valor que o usuário informou. Carregar decisions ATIVAS por tag se a fase tocar áreas com decisions arquivadas.

## Protocolo

### Passo 1 — Carregar a spec, a fase e o relatório (sem confiar nele)
- Ler o bloco da fase-alvo em §5, a DoD (§9), os princípios (§1.x), os ACs (§3), os FR/NFR (§2) e o **escopo travado / violações bloqueantes** declarado na spec, mais as rules e ADRs referenciados.
- Ler o relatório `FASE-<id>-*-EXECUCAO.md` (frontmatter + corpo) como **ponto de partida, NÃO fonte de verdade**.
- Gate: fase-alvo identificada pelo campo `fase:` e contexto carregado.

### Passo 2 — Confirmar o estado git e isolar o diff da fase
- **Estar na ponta da branch de trabalho** (a do campo `branch` do EXECUCAO, se houver; senão `spec/<slug>` ou a do manifest). Confirmar que os commits do `range` são **ancestrais do HEAD atual** — `git merge-base --is-ancestor <sha_final> HEAD`. Se não forem, **PARAR**: árvore errada (ex: `main`) ou branch incompleta; peça a branch/commits corretos. **Não** fazer checkout de `sha_final` em detached HEAD — o executor commitou o relatório **em cima** de `sha_final` (commit separado, só markdown), então a ponta da branch já contém o código da fase **e** é onde o AVALIACAO precisa ser commitado (Passo 5); avaliar em detached orfanaria esse commit e travaria o pipeline. Rodar as verificações do Passo 3 na ponta da branch.
- Obter o **range** (`range: <sha_inicial>..<sha_final>` do EXECUCAO); se ausente, identificá-lo via `git log --oneline` e registrar a incerteza como achado.
- Examinar o diff **completo** do range, **excluindo** `.codeflow/specs/<slug>/artefatos/` (em rework o range engloba os `.md` de execução/avaliação de tentativas anteriores — ruído; o foco é o código): `git diff <sha_inicial>..<sha_final> -- . ':(exclude).codeflow/specs/*/artefatos/*'`. Comparar com o precedente/molde citado na spec — divergência de shape sem justificativa é achado.
- Gate: commits do range são ancestrais de HEAD na branch; diff de código (sem `artefatos/`) lido na íntegra.

### Passo 3 — Rodar as verificações você mesmo (não acreditar no relatório)
- Linters e type-check dos arquivos tocados + `make check` (ou os alvos equivalentes de `.codeflow/manifest.md`); rodar a suíte relevante e reportar falhas **reais**. Se `make check` (e equivalentes do manifest) **não existir**, marcar `[—]` com justificativa e rodar as validações mínimas possíveis — alvo ausente é "pulado", não falha (SPEC §3.10).
- Aplicáveis conforme a fase: hooks de fitness, round-trip de migration se houver schema, `grep` de segredo/PII (deve ser zero) e os **greps de escopo travado** declarados na spec.
- **Sem mutar o repo:** as verificações não podem alterar a working tree nem criar/reescrever commits; se uma checagem suja a árvore (artefatos de teste), reverter (`git stash`/`git checkout --`); resets de banco só em DB de **dev descartável**. Colar as **SAÍDAS REAIS** — nunca "passou" sem output. Opcional: `/code-review`.
- Gate: verificações aplicáveis rodadas, com evidência, e árvore limpa ao final.

### Passo 4 — Scorecard e veredito
- Notar cada dimensão de 0 a 5, com peso e **EVIDÊNCIA** (arquivo:linha ou saída): (1) conformidade com a fase — ACs e escopo travado [peso 3]; (2) arquitetura e direção de dependências [3]; (3) segurança/LGPD/multi-tenant [3]; (4) reusar/espelhar, não duplicar [3]; (5) padrões de domínio/aplicação [2]; (6) local e nomes dos arquivos [2]; (7) qualidade de código [2]; (8) testes e cobertura [2]; (9) migration safety, se aplicável [2].
- Score final = média ponderada normalizada para 0–10. Classificar **cada achado** como BLOQUEANTE / IMPORTANTE / SUGESTÃO. Usar o **threshold resolvido** (quality_gate da spec ou override do usuário), não um literal.
- Veredito (valores fixos para o frontmatter): **`APROVADO`** (score ≥ threshold E zero BLOQUEANTES); **`RESSALVAS`** (score ≥ threshold, mas há IMPORTANTES); **`REPROVADO`** (score < threshold OU qualquer BLOQUEANTE).
- **Apenas `APROVADO` conclui a fase.** Tanto `REPROVADO` quanto `RESSALVAS` exigem rework e reavaliação — neste pipeline `RESSALVAS` **nunca** fecha uma fase nem libera a fase seguinte (alinhado ao padrão-ouro, em que "reprovado/com ressalvas" devolve os achados ao executor).

### Passo 5 — Gravar e commitar o artefato de avaliação
- Escrever `.codeflow/specs/<slug>/artefatos/FASE-<id>-<slug>-AVALIACAO.md` com este **frontmatter machine-readable** seguido do corpo. `fase` (`id`), `slug` no nome do arquivo e `tentativa` vêm do EXECUCAO avaliado, reusados verbatim; `threshold` é o **valor efetivamente usado**, não um literal:

  ```markdown
  ---
  spec: <slug>
  fase: <id>
  slug_fase: <slug>
  tentativa: <n da tentativa avaliada>
  veredito: <APROVADO | RESSALVAS | REPROVADO>
  score: <0.0-10.0>
  threshold: <threshold usado>
  range_avaliado: <sha_inicial>..<sha_final>
  ---
  ```
  Corpo, nesta ordem: (1) veredito + score; (2) scorecard (dimensão | nota | peso | evidência); (3) achados BLOQUEANTES (arquivo:linha + correção sugerida); (4) IMPORTANTES; (5) sugestões; (6) comandos rodados + saídas reais; (7) itens da fase/DoD não atendidos; (8) divergências entre o relatório e o que o código realmente faz.
- **Commitar a avaliação** (`.codeflow/specs/` é versionado). O avaliador **não** altera código.
- Apresentar o resumo final com o veredito explícito. Se `REPROVADO`/`RESSALVAS`, instruir: colar esta avaliação no chat do executor para corrigir e depois reavaliar em chat zerado.

## Definition of Done
- [ ] Independência verificada; spec, fase, DoD, princípios, ACs, escopo travado e rules/ADRs carregados (Passo 1).
- [ ] Na ponta da branch de trabalho, commits do `range` confirmados como ancestrais de HEAD (senão parar); diff de código (excluindo `artefatos/`) lido na íntegra (Passo 2).
- [ ] Verificações rodadas pelo próprio avaliador (incl. `make check`, ou `[—]` justificado se ausente), com saídas reais e árvore limpa ao final (Passo 3).
- [ ] Scorecard com evidência por dimensão e score final calculado (Passo 4).
- [ ] Veredito (`APROVADO`/`RESSALVAS`/`REPROVADO`) coerente com o threshold resolvido (quality_gate da spec ou override; zero BLOQUEANTES para aprovar); `threshold` real persistido.
- [ ] Artefato `FASE-<id>-<slug>-AVALIACAO.md` gravado com frontmatter machine-readable (incl. `fase`/`slug_fase`/`tentativa` do EXECUCAO) e **commitado**.
- [ ] Nenhuma alteração de código feita pelo avaliador (só relatório).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
