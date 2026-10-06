---
versão: 1.9
status: experimental
atualizado: 2026-10-05
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: evaluate-spec-phase

## Quando usar
Avaliar, de forma **independente e cética**, a fase executada por `/execute-spec-phase`: o código gerado, o relatório `FASE-<id>-*-EXECUCAO.md` e os commits da fase. **Invocar sempre em um chat zerado, separado do que executou** — a independência é o ponto: o avaliador não confia no relatório, verifica tudo contra o código real. Emite achados por severidade e veredito machine-readable — `APROVADO` (zero BLOQUEANTE), `REPROVADO` ou `PENDENTE-EXTERNO` — e confere os IMPORTANTES herdados de fases anteriores. Nota e threshold, se usados, só informam: não decidem o veredito.

## Quando NÃO usar
- No mesmo chat que executou a fase → quebra a independência (a IA tende a validar o próprio trabalho). Abra um chat novo.
- Para corrigir o código → este workflow **só avalia e reporta**; as correções voltam ao chat executor.
- Para avaliar uma fase ainda não executada (sem `FASE-<id>-*-EXECUCAO.md`) → nada a avaliar.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/ARTIFACTS_SPEC.md — **só §2.9 a §2.11** (relatório de execução, avaliação e máquina de estados da fase; cerca de 230 linhas), nunca o arquivo inteiro: `sed -n '/^### 2\.9 /,/^### 2\.12 /p' ~/.codeflow/framework/core/ARTIFACTS_SPEC.md`. A forma da §5 da spec (§2.8.6) é checada pelo `run-structural.sh`, não por leitura.
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
**Pré-condição de independência (processo, não auto-detecção):** este workflow só é válido invocado em **chat zerado**, separado do que executou a fase — a independência é o motivo de existir dele. Num chat genuinamente zerado não há auto-detecção confiável de autoria; portanto, se houver **qualquer** chance de você ter escrito ou alterado este código na sessão atual, **pare e peça reabertura num chat novo** antes de avaliar. Não avalie o próprio trabalho. **Avaliar na branch atual** — o pipeline não troca de branch; o código da fase, a spec e os artefatos foram commitados na branch em que o executor trabalhou. Se você abriu este chat zerado em outra branch (ex: a default), o `range` do EXECUCAO não estará presente (o Passo 2 detecta) — troque para a branch onde o trabalho foi commitado, ou peça-a ao usuário. Identificar a spec e a fase a avaliar (por slug em `.codeflow/specs/`; por padrão, a fase no estado **aguardando avaliação** — `FASE-<id>-*-EXECUCAO.md` com `tentativa: T` **sem** AVALIACAO de `tentativa: T`, conforme ARTIFACTS_SPEC §2.11). Reusar `fase` (`id`) e `slug_fase` do EXECUCAO **verbatim** ao nomear o arquivo de avaliação. Levantar os **herdados destinados à fase** (ARTIFACTS_SPEC §2.11.5): os IMPORTANTES abertos das avaliações `APROVADO` (ou do legado `RESSALVAS`) das fases de que ela depende. Carregar decisions ATIVAS por tag se a fase tocar áreas com decisions arquivadas.

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
- Gate: commits do range são ancestrais de HEAD na branch; diff de código (sem `artefatos/`) lido na íntegra, incluindo as correções de herdados (escopo autorizado da fase).

### Passo 3 — Rodar as verificações você mesmo (não acreditar no relatório)
- Rodar os **comandos de validação do projeto** (do `.codeflow/manifest.md`; se ausente, inferir do stack): lint e type-check dos arquivos tocados, a suíte de testes relevante, segurança quando aplicável. Reportar falhas **reais**. Gate que **não existir** no projeto → `[—]` com justificativa; rodar as validações mínimas possíveis — gate ausente é "pulado", não falha (SPEC §3.10).
- Aplicáveis conforme a fase: hooks de fitness, round-trip de migration se houver schema, `grep` de segredo/PII (deve ser zero) e os **greps de escopo travado** declarados na spec.
- **Sem mutar o repo:** as verificações não podem alterar a working tree nem criar/reescrever commits; se uma checagem suja a árvore (artefatos de teste), reverter (`git stash`/`git checkout --`); resets de banco só em DB de **dev descartável**. Colar as **SAÍDAS REAIS** — nunca "passou" sem output. Opcional: `/code-review`.
- Gate: verificações aplicáveis rodadas, com evidência, e árvore limpa ao final.

### Passo 4 — Achados e veredito
- Ler a fase por estas dimensões, como checklist (nota opcional, sem peso decisório): (1) conformidade com a fase — ACs e escopo travado; (2) arquitetura e direção de dependências; (3) segurança/LGPD/multi-tenant; (4) reusar/espelhar, não duplicar; (5) padrões de domínio/aplicação; (6) local e nomes dos arquivos; (7) qualidade de código; (8) testes e cobertura; (9) migration safety, se aplicável.
- **Conferir os herdados** destinados à fase contra o código: cada um resolvido (com evidência própria) ou aberto. Herdado omitido da seção **Herdados** do EXECUCAO conta como aberto.
- Classificar **cada achado** pela severidade de ARTIFACTS_SPEC §2.10.3: **BLOQUEANTE** só o que afeta correção, requisito, contrato, escopo travado, segurança ou dado; **IMPORTANTE** (numerado `I-<n>`); **SUGESTÃO**. Erro só de registro (frontmatter, `range`, lista de arquivos, link) vai à parte e não entra no veredito.
- **Escalada:** herdado aberto vira BLOQUEANTE (é o mesmo IMPORTANTE pela 2ª vez); 3 ou mais IMPORTANTES abertos ao mesmo tempo — novos mais herdados abertos — viram todos BLOQUEANTE.
- Veredito, na **precedência estrita `REPROVADO` > `PENDENTE-EXTERNO` > `APROVADO`** (§2.10.3): **`REPROVADO`** se há ≥1 BLOQUEANTE, contada a escalada; senão **`PENDENTE-EXTERNO`** se um gate não pôde ser fechado por depender de algo fora da fase (cota, push ou CI remoto, ação física do dono, outra fase que precisa vir antes) — nomear a condição e quem a resolve; senão **`APROVADO`**, e os IMPORTANTES abertos viram herdados da fase de destino (§2.11.5). Nota e threshold, se preenchidos, não mudam o veredito.

### Passo 5 — Gravar e commitar o artefato de avaliação
- Partir do molde `.codeflow/specs/_TEMPLATES/TEMPLATE-AVALIACAO.md` (anti-alucinação) e escrever `.codeflow/specs/<slug>/artefatos/FASE-<id>-<slug>-AVALIACAO.md` com este **frontmatter machine-readable** seguido do corpo. `fase` (`id`), `slug` no nome do arquivo e `tentativa` vêm do EXECUCAO avaliado, reusados verbatim; `score` e `threshold` são opcionais e informativos:

  ```markdown
  ---
  spec: <slug>
  fase: <id>
  slug_fase: <slug>
  tentativa: <n da tentativa avaliada>
  veredito: <APROVADO | REPROVADO | PENDENTE-EXTERNO>
  range_avaliado: <sha_inicial>..<sha_final>
  ---
  ```
  Corpo, nesta ordem (§2.10.3): (1) veredito; (2) conferência dos herdados; (3) achados BLOQUEANTES (arquivo:linha + correção sugerida); (4) IMPORTANTES `I-<n>`; (5) sugestões; (6) erros de registro; (7) comandos rodados + saídas reais; (8) itens da fase/DoD não atendidos; (9) divergências entre o relatório e o que o código realmente faz.
- **Commitar a avaliação** (`.codeflow/specs/` é versionado). O avaliador **não** altera código.
- Apresentar o resumo final com o veredito explícito e instruir o próximo passo: `REPROVADO` → colar esta avaliação no chat do executor para o rework e reavaliar em chat zerado; `PENDENTE-EXTERNO` → resolver a condição nomeada e rodar `/evaluate-spec-phase` de novo na mesma tentativa, sem rework; `APROVADO` com herdados → a fase de destino os recebe; erros de registro → o executor os corrige num commit só de documento, sem nova avaliação.

## Definition of Done
- [ ] Pré-condição de independência satisfeita (chat zerado); `run-structural.sh` retornou `0` (gate da §5); spec, fase, DoD, princípios, ACs, escopo travado e rules/ADRs carregados (Passo 1).
- [ ] Na branch onde o trabalho foi commitado, commits do `range` confirmados como ancestrais de HEAD (senão parar); diff de código (excluindo `artefatos/`) lido na íntegra (Passo 2).
- [ ] Verificações rodadas pelo próprio avaliador (os comandos de validação do projeto, ou `[—]` justificado se ausente), com saídas reais e árvore limpa ao final (Passo 3).
- [ ] Herdados destinados à fase conferidos contra o código; cada achado classificado com evidência, com a escalada aplicada e os erros de registro à parte (Passo 4).
- [ ] Veredito (`APROVADO`/`REPROVADO`/`PENDENTE-EXTERNO`) pela precedência estrita `REPROVADO` > `PENDENTE-EXTERNO` > `APROVADO`: aprovar só com zero BLOQUEANTE; nota e threshold não decidem.
- [ ] Artefato `FASE-<id>-<slug>-AVALIACAO.md` gravado com frontmatter machine-readable (incl. `fase`/`slug_fase`/`tentativa` do EXECUCAO) e **commitado**.
- [ ] Nenhuma alteração de código feita pelo avaliador (só relatório).

## Resumo final
Apresentar no formato do resumo final do `SPEC.md` §5.6.4, sem abrir o arquivo para isso: o título `## ✓ CONCLUÍDO: <workflow> — <escopo>` e as cinco seções, na ordem — `### O que foi feito`, `### Checklist Definition of Done`, `### Riscos e notas`, `### Próximos passos sugeridos`, `### Decisão registrada (se aplicável)`.
