---
versão: 1.8
status: experimental
atualizado: 2026-06-25
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
- ~/.codeflow/framework/core/ARTIFACTS_SPEC.md (§2.8.6 gate estrutural; §2.10.3 cascata de veredito; §2.11 máquina de estados da fase)
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/core/rules/security.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- ~/.codeflow/framework/library/skills/avoid-ai-look/SKILL.md (carregar quando a fase avaliada toca interface gráfica)
- ~/.codeflow/framework/library/skills/accessibility-audit/SKILL.md (carregar quando a fase avaliada toca interface gráfica)
- ~/.codeflow/framework/library/skills/visual-consistency/SKILL.md (carregar quando a fase avaliada toca interface gráfica)
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (carregar decisions ATIVAS cujas tags cruzem o domínio da fase)

## Antes de começar
**Pré-condição de independência (processo, não auto-detecção):** este workflow só é válido invocado em **chat zerado**, separado do que executou a fase — a independência é o motivo de existir dele. Num chat genuinamente zerado não há auto-detecção confiável de autoria; portanto, se houver **qualquer** chance de você ter escrito ou alterado este código na sessão atual, **pare e peça reabertura num chat novo** antes de avaliar. Não avalie o próprio trabalho. **Avaliar na branch atual** — o pipeline não troca de branch; o código da fase, a spec e os artefatos foram commitados na branch em que o executor trabalhou. Se você abriu este chat zerado em outra branch (ex: a default), o `range` do EXECUCAO não estará presente (o Passo 2 detecta) — troque para a branch onde o trabalho foi commitado, ou peça-a ao usuário. Identificar a spec e a fase a avaliar (por slug em `.codeflow/specs/`; por padrão, a fase no estado **aguardando avaliação** — `FASE-<id>-*-EXECUCAO.md` com `tentativa: T` **sem** AVALIACAO de `tentativa: T`, conforme ARTIFACTS_SPEC §2.11). Reusar `fase` (`id`) e `slug_fase` do EXECUCAO **verbatim** ao nomear o arquivo de avaliação. Resolver o threshold: `quality_gate.threshold` da spec, ou o valor que o usuário informou. Carregar decisions ATIVAS por tag se a fase tocar áreas com decisions arquivadas.

## Protocolo

### Passo 1 — Carregar a spec, a fase e o relatório (sem confiar nele)
- **Gate estrutural da §5 (determinístico, antes de classificar/usar fases):** rodar `bash ~/.codeflow/framework/core/scripts/run-structural.sh .codeflow/specs/<slug>/SPEC_<NAME>.md`. Exit `0` segue. Exit `1` = §5 malformada (ARTIFACTS_SPEC §2.8.6) → **abortar**, colar a saída do script e pedir correção da spec por `/create-spec`. Exit `2`/`3` = erro de execução/uso → parar.
- Ler o bloco da fase-alvo em §5, a DoD (§9), os princípios (§1.x), os ACs (§3), os FR/NFR (§2) e o **escopo travado / violações bloqueantes** declarado na spec, mais as rules e ADRs referenciados.
- Ler o relatório `FASE-<id>-*-EXECUCAO.md` (frontmatter + corpo) como **ponto de partida, NÃO fonte de verdade**.
- Se a spec não tem `## 5. Plano de desenvolvimento por fases`, ou não existe `FASE-<id>-*-EXECUCAO.md` para a fase-alvo, **abortar** (nada a avaliar) — guard simétrico ao do executor e do spec-status.
- Gate: §5 estruturalmente válida (`run-structural.sh` = `0`), fase-alvo identificada pelo campo `fase:` e contexto carregado.

### Passo 2 — Confirmar o estado git e isolar o diff da fase
- **Estar na branch atual onde o trabalho foi commitado** (o pipeline não troca de branch). Confirmar que os commits do `range` são **ancestrais do HEAD atual** — `git merge-base --is-ancestor <sha_final> HEAD`. Se não forem, **PARAR**: você está na branch errada (ex: a default) ou a branch está incompleta; troque para a branch correta ou peça-a ao usuário. **Não** fazer checkout de `sha_final` em detached HEAD — o executor commitou o relatório **em cima** de `sha_final` (commit separado, só markdown), então a ponta da branch já contém o código da fase **e** é onde o AVALIACAO precisa ser commitado (Passo 5); avaliar em detached orfanaria esse commit e travaria o pipeline. Rodar as verificações do Passo 3 na ponta da branch.
- Obter o **range** (`range: <sha_inicial>..<sha_final>` do EXECUCAO); se ausente, identificá-lo via `git log --oneline` e registrar a incerteza como achado.
- Examinar o diff **completo** do range, **excluindo** `.codeflow/specs/<slug>/artefatos/` (em rework o range engloba os `.md` de execução/avaliação de tentativas anteriores — ruído; o foco é o código): `git diff <sha_inicial>..<sha_final> -- . ':(exclude).codeflow/specs/*/artefatos/*'`. Comparar com o precedente/molde citado na spec — divergência de shape sem justificativa é achado.
- Gate: commits do range são ancestrais de HEAD na branch; diff de código (sem `artefatos/`) lido na íntegra.

### Passo 3 — Rodar as verificações você mesmo (não acreditar no relatório)
- Rodar os **comandos de validação do projeto** (do `.codeflow/manifest.md`; se ausente, inferir do stack): lint e type-check dos arquivos tocados, a suíte de testes relevante, segurança quando aplicável. Reportar falhas **reais**. Gate que **não existir** no projeto → `[—]` com justificativa; rodar as validações mínimas possíveis — gate ausente é "pulado", não falha (SPEC §3.10).
- Aplicáveis conforme a fase: hooks de fitness, round-trip de migration se houver schema, `grep` de segredo/PII (deve ser zero) e os **greps de escopo travado** declarados na spec.
- **Sem mutar o repo:** as verificações não podem alterar a working tree nem criar/reescrever commits; se uma checagem suja a árvore (artefatos de teste), reverter (`git stash`/`git checkout --`); resets de banco só em DB de **dev descartável**. Colar as **SAÍDAS REAIS** — nunca "passou" sem output. Opcional: `/code-review`.
- Gate: verificações aplicáveis rodadas, com evidência, e árvore limpa ao final.

### Passo 4 — Scorecard e veredito
- Notar cada dimensão de 0 a 5, com peso e **EVIDÊNCIA** (arquivo:linha ou saída): (1) conformidade com a fase — ACs e escopo travado [peso 3]; (2) arquitetura e direção de dependências [3]; (3) segurança/LGPD/multi-tenant [3]; (4) reusar/espelhar, não duplicar [3]; (5) padrões de domínio/aplicação [2]; (6) local e nomes dos arquivos [2]; (7) qualidade de código [2]; (8) testes e cobertura [2]; (9) migration safety, se aplicável [2].
- Score final = média ponderada normalizada para 0–10. Classificar **cada achado** como BLOQUEANTE / IMPORTANTE / SUGESTÃO. Usar o **threshold resolvido** (quality_gate da spec ou override do usuário), não um literal.
- Veredito (valores fixos para o frontmatter) — avaliar nesta **precedência estrita (primeiro que casar vence): `REPROVADO` > `RESSALVAS` > `APROVADO`** (§2.10.3): **`REPROVADO`** se `score < threshold` **ou** há ≥1 BLOQUEANTE (BLOQUEANTE sempre reprova, qualquer que seja o score); senão **`RESSALVAS`** se há ≥1 IMPORTANTE (já implica `score ≥ threshold` e zero BLOQUEANTES); senão **`APROVADO`** (`score ≥ threshold`, zero BLOQUEANTES e zero IMPORTANTES).
- **Apenas `APROVADO` conclui a fase.** Tanto `REPROVADO` quanto `RESSALVAS` exigem rework e reavaliação — neste pipeline `RESSALVAS` **nunca** fecha uma fase nem libera a fase seguinte (alinhado ao padrão-ouro, em que "reprovado/com ressalvas" devolve os achados ao executor).

### Passo 5 — Gravar e commitar o artefato de avaliação
- Partir do molde `.codeflow/specs/_TEMPLATES/TEMPLATE-AVALIACAO.md` (anti-alucinação) e escrever `.codeflow/specs/<slug>/artefatos/FASE-<id>-<slug>-AVALIACAO.md` com este **frontmatter machine-readable** seguido do corpo. `fase` (`id`), `slug` no nome do arquivo e `tentativa` vêm do EXECUCAO avaliado, reusados verbatim; `threshold` é o **valor efetivamente usado**, não um literal:

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
- [ ] Pré-condição de independência satisfeita (chat zerado); `run-structural.sh` retornou `0` (gate da §5); spec, fase, DoD, princípios, ACs, escopo travado e rules/ADRs carregados (Passo 1).
- [ ] Na branch onde o trabalho foi commitado, commits do `range` confirmados como ancestrais de HEAD (senão parar); diff de código (excluindo `artefatos/`) lido na íntegra (Passo 2).
- [ ] Verificações rodadas pelo próprio avaliador (os comandos de validação do projeto, ou `[—]` justificado se ausente), com saídas reais e árvore limpa ao final (Passo 3).
- [ ] Scorecard com evidência por dimensão e score final calculado (Passo 4).
- [ ] Veredito (`APROVADO`/`RESSALVAS`/`REPROVADO`) pela precedência estrita `REPROVADO` > `RESSALVAS` > `APROVADO`, coerente com o threshold resolvido (quality_gate da spec ou override; zero BLOQUEANTES para aprovar); `threshold` real persistido.
- [ ] Artefato `FASE-<id>-<slug>-AVALIACAO.md` gravado com frontmatter machine-readable (incl. `fase`/`slug_fase`/`tentativa` do EXECUCAO) e **commitado**.
- [ ] Nenhuma alteração de código feita pelo avaliador (só relatório).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
