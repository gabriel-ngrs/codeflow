---
versão: 1.1
status: estável
atualizado: 2026-06-14
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: evaluate-spec-phase

## Quando usar
Avaliar, de forma **independente e cética**, a fase executada por `/execute-spec-phase`: o código gerado, o relatório `FASE-<N>-*-EXECUCAO.md` e os commits da fase. **Invocar sempre em um chat zerado, separado do que executou** — a independência é o ponto: o avaliador não confia no relatório, verifica tudo contra o código real. Emite scorecard + veredito machine-readable (threshold padrão 8.5; o usuário pode informar outro ao invocar).

## Quando NÃO usar
- No mesmo chat que executou a fase → quebra a independência (a IA tende a validar o próprio trabalho). Abra um chat novo.
- Para corrigir o código → este workflow **só avalia e reporta**; as correções voltam ao chat executor.
- Para avaliar uma fase ainda não executada (sem `FASE-<N>-*-EXECUCAO.md`) → nada a avaliar.

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
**Auto-check de independência:** se você implementou ou alterou este código nesta mesma sessão/chat, **declare isso e recomende reabrir num chat zerado** antes de avaliar — a independência é o motivo de existir deste workflow. Identificar a spec e a fase a avaliar (por slug em `.codeflow/specs/`; por padrão, a última fase com `FASE-<N>-*-EXECUCAO.md` cujo frontmatter ainda não tem AVALIACAO com `veredito: APROVADO`). Carregar decisions ATIVAS por tag se a fase tocar áreas com decisions arquivadas.

## Protocolo

### Passo 1 — Carregar a spec, a fase e o relatório (sem confiar nele)
- Ler o bloco da fase-alvo em §5, a DoD (§9), os princípios (§1.x), os ACs (§3), os FR/NFR (§2) e o **escopo travado / violações bloqueantes** declarado na spec, mais as rules e ADRs referenciados.
- Ler o relatório `FASE-<N>-*-EXECUCAO.md` (frontmatter + corpo) como **ponto de partida, NÃO fonte de verdade**.
- Gate: fase-alvo identificada pelo campo `fase:` e contexto carregado.

### Passo 2 — Isolar e ler o diff da fase
- Obter o **range do frontmatter do EXECUCAO** (`range: <sha_inicial>..<sha_final>`); se ausente, identificá-lo via `git log --oneline` e registrar a incerteza como achado.
- Examinar o diff **completo** e cada arquivo criado/alterado. Comparar com o precedente/molde citado na spec — divergência de shape sem justificativa é achado.
- Gate: diff isolado pelo range e lido na íntegra.

### Passo 3 — Rodar as verificações você mesmo (não acreditar no relatório)
- Linters e type-check dos arquivos tocados + `make check` (ou os alvos equivalentes de `.codeflow/manifest.md`); rodar a suíte relevante e reportar falhas **reais**.
- Aplicáveis conforme a fase: hooks de fitness, round-trip de migration se houver schema, `grep` de segredo/PII (deve ser zero) e os **greps de escopo travado** declarados na spec.
- **Sem mutar o repo:** as verificações não podem alterar a working tree nem criar/reescrever commits; se uma checagem suja a árvore (artefatos de teste), reverter (`git stash`/`git checkout --`); resets de banco só em DB de **dev descartável**. Colar as **SAÍDAS REAIS** — nunca "passou" sem output. Opcional: `/code-review`.
- Gate: verificações aplicáveis rodadas, com evidência, e árvore limpa ao final.

### Passo 4 — Scorecard e veredito
- Notar cada dimensão de 0 a 5, com peso e **EVIDÊNCIA** (arquivo:linha ou saída): (1) conformidade com a fase — ACs e escopo travado [peso 3]; (2) arquitetura e direção de dependências [3]; (3) segurança/LGPD/multi-tenant [3]; (4) reusar/espelhar, não duplicar [3]; (5) padrões de domínio/aplicação [2]; (6) local e nomes dos arquivos [2]; (7) qualidade de código [2]; (8) testes e cobertura [2]; (9) migration safety, se aplicável [2].
- Score final = média ponderada normalizada para 0–10. Classificar **cada achado** como BLOQUEANTE / IMPORTANTE / SUGESTÃO.
- Veredito (valores fixos para o frontmatter): **`APROVADO`** (score ≥ threshold E zero BLOQUEANTES); **`RESSALVAS`** (score ok, mas há IMPORTANTES); **`REPROVADO`** (score < threshold OU qualquer BLOQUEANTE).

### Passo 5 — Gravar e commitar o artefato de avaliação
- Escrever `.codeflow/specs/<slug>/artefatos/FASE-<N>-<slug-da-fase>-AVALIACAO.md` com este **frontmatter machine-readable** seguido do corpo:

  ```markdown
  ---
  spec: <slug>
  fase: <N>
  tentativa: <n da tentativa avaliada>
  veredito: REPROVADO          # APROVADO | RESSALVAS | REPROVADO
  score: <0.0-10.0>
  threshold: 8.5
  range_avaliado: <sha_inicial>..<sha_final>
  ---
  ```
  Corpo, nesta ordem: (1) veredito + score; (2) scorecard (dimensão | nota | peso | evidência); (3) achados BLOQUEANTES (arquivo:linha + correção sugerida); (4) IMPORTANTES; (5) sugestões; (6) comandos rodados + saídas reais; (7) itens da fase/DoD não atendidos; (8) divergências entre o relatório e o que o código realmente faz.
- **Commitar a avaliação** (`.codeflow/specs/` é versionado). O avaliador **não** altera código.
- Apresentar o resumo final com o veredito explícito. Se `REPROVADO`/`RESSALVAS`, instruir: colar esta avaliação no chat do executor para corrigir e depois reavaliar em chat zerado.

## Definition of Done
- [ ] Independência verificada; spec, fase, DoD, princípios, ACs, escopo travado e rules/ADRs carregados (Passo 1).
- [ ] Diff da fase isolado pelo `range` do frontmatter e lido na íntegra (Passo 2).
- [ ] Verificações rodadas pelo próprio avaliador (incl. `make check`), com saídas reais e árvore limpa ao final (Passo 3).
- [ ] Scorecard com evidência por dimensão e score final calculado (Passo 4).
- [ ] Veredito (`APROVADO`/`RESSALVAS`/`REPROVADO`) coerente com o threshold (zero BLOQUEANTES para aprovar).
- [ ] Artefato `FASE-<N>-<slug>-AVALIACAO.md` gravado com frontmatter machine-readable e **commitado**.
- [ ] Nenhuma alteração de código feita pelo avaliador (só relatório).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
