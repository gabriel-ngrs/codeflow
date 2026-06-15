---
versão: 1.5
status: experimental
atualizado: 2026-06-15
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: execute-spec-phase

## Quando usar
Executar a **próxima fase pendente** de uma spec gerada por `/create-spec` (em `.codeflow/specs/<slug>/SPEC_<NAME>.md`), deixando-a **pronta para avaliação** por `/evaluate-spec-phase`. Uma fase por execução: lê a spec e os documentos referenciados, executa só a fase da vez, **commita** o trabalho e grava o relatório `FASE-<id>-<slug>-EXECUCAO.md` (com frontmatter machine-readable e range de commits). Também opera em **modo rework**: ao receber uma avaliação REPROVADA/COM RESSALVAS, corrige a mesma fase. O `<id>` e o `<slug>` da fase vêm da spec (§5) e são reusados verbatim. Pré-requisito: a spec tem `## 5. Plano de desenvolvimento por fases`.

## Quando NÃO usar
- Para criar a spec → use `/create-spec`.
- Para avaliar a fase executada → use `/evaluate-spec-phase` (em chat zerado).
- Para executar várias fases de uma vez → **uma fase por execução**; rode de novo após a fase atual ser APROVADA.
- Para spec sem plano de fases (`§5`) → não há o que executar em fatias.
- Para um gate humano "aprove o plano antes de codar" → este workflow é **médio** (sem conversa estruturada): após preparar, executa direto. Se quiser revisar o plano da fase, faça-o no chat **antes** de invocar. É redução deliberada do gate do padrão-ouro, não omissão.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (carregar decisions ATIVAS cujas tags cruzem o domínio da fase)

## Antes de começar
Identificar a spec que o usuário pediu (por caminho ou slug em `.codeflow/specs/`). **Trocar para a branch de trabalho da spec antes de qualquer coisa** (`spec/<slug>`, ou a de `.codeflow/manifest.md`; se não existir, criá-la a partir da default) — a spec e os artefatos vivem nela e em `main` não aparecem; sem isso o Passo 1 falha em chat zerado. Se o usuário colou uma avaliação (`FASE-<id>-*-AVALIACAO.md` com `veredito: REPROVADO` ou `RESSALVAS`), o alvo é o **rework** dessa fase. Se a fase tocar áreas com decisions arquivadas, carregar as decisions ATIVAS por tag antes de implementar.

## Protocolo

### Passo 1 — Carregar a spec e o contexto
- Localizar `.codeflow/specs/<slug>/SPEC_<NAME>.md` e lê-lo **na íntegra** — atenção a §4 (abordagem), §5 (plano de fases) e ao escopo travado / violações bloqueantes de cada fase.
- Ler os documentos referenciados (`linked_adr`, rules, decisions ativas, `.codeflow/manifest.md`) e inspecionar os seams de código citados em §4. **Não escrever nada ainda.**
- Gate: spec encontrada e §5 interpretada como lista ordenada de fases.

### Passo 2 — Determinar a fase-alvo (estado por frontmatter, não por prosa)
- Para cada fase de §5 (identificada pelo seu `id`), ler o **frontmatter** dos artefatos em `artefatos/` (campos `fase:`, `status:`, `tentativa:`, `reprovacoes:` no EXECUCAO; `fase:`, `tentativa:`, `veredito:` no AVALIACAO) — nunca inferir estado de texto livre. **Sempre parear EXECUCAO e AVALIACAO da mesma fase pela tentativa** (`AVALIACAO.tentativa == EXECUCAO.tentativa`); avaliação de tentativa antiga não classifica a tentativa corrente. Classificar cada fase em **um único** estado:
  - **pendente** — não existe EXECUCAO para aquele `id`.
  - **aguardando avaliação** — existe EXECUCAO com `tentativa: T` e **não** existe AVALIACAO com `tentativa: T` (inclui o caso de rework recém-feito: a AVALIACAO antiga, de tentativa < T, **não** conta).
  - **reprovada** — existe AVALIACAO com `tentativa: T == EXECUCAO.tentativa` e `veredito: REPROVADO` ou `RESSALVAS`.
  - **concluída** — existe AVALIACAO com `tentativa: T == EXECUCAO.tentativa` e `veredito: APROVADO`.
- Uma fase só é **elegível** para nova execução quando **todas** as fases listadas em "Depende de" (por `id`) estão **concluídas** (AVALIACAO `APROVADO` da tentativa corrente) — vale também entre tracks (`B.2` depende de `A.7`). Uma dependência apenas "aguardando avaliação" **não** está concluída, então não libera quem depende dela.
- Selecionar o alvo nesta ordem (a precedência resolve sobreposições): (1) avaliação reprovada colada pelo usuário → **rework** dessa fase; (2) primeira fase **reprovada** (na **ordem textual** de §5, não lexical — `2` antes de `10`) → rework; (3) primeira fase **pendente e elegível** (deps concluídas) → nova execução; (4) nenhuma elegível, mas há fase **aguardando avaliação** → **parar** e pedir `/evaluate-spec-phase`; (5) nenhuma elegível nem aguardando, mas há pendente bloqueada por dependência → **parar** e relatar a dependência faltante; (6) todas concluídas → atualizar a spec para `status: done` + `updated_at`, commitar a spec, e **parar** (spec concluída).
- **Multi-track:** como a elegibilidade (3) é por dependência de `id`, tracks independentes avançam em paralelo — uma fase "aguardando avaliação" só segura quem depende dela, nunca o grafo inteiro. A regra (4) só dispara quando **não** há nada elegível para executar (em single-track, isso é logo após cada execução).
- **Teto de rework:** a fase para após **3 vereditos não-APROVADO**. Neste pipeline "reprovado" = qualquer veredito não-APROVADO (`REPROVADO` **ou** `RESSALVAS`); ambos disparam rework e contam em `reprovacoes`. Como o alvo só vira rework quando há uma AVALIACAO não-APROVADO da tentativa corrente, a regra é: se a fase-alvo é rework e `EXECUCAO.reprovacoes` já vale `2` (o veredito corrente fecharia o 3º), **parar** e escalar ao owner. `reprovacoes` é cumulativo e sobrevive à sobrescrita (ver Passo 7). Este teto é o **ciclo executor↔avaliador**; falhas Lógicas **dentro** de uma execução seguem o limite de 2 tentativas da constitution (Passo 5).
- Gate: um único alvo definido (rework ou nova execução), ou parada limpa/escalonamento.

### Passo 3 — Preparar e marcar o início
- Reler o bloco da fase-alvo em §5. Em rework, ler também os achados BLOQUEANTES/IMPORTANTES da AVALIACAO. Confirmar que os **caminhos de "Arquivos alterados" existem** no repo (se a spec citou caminho inexistente, parar e apontar — não inventar).
- Conferir dependências: cada `id` listado em "Depende de" da fase-alvo está **concluído** (AVALIACAO `veredito: APROVADO` da tentativa corrente); se faltar, **parar** e relatar qual dependência. Criar `artefatos/` se não existir (esta pasta é criada aqui, não por `/create-spec`).
- **Branch de trabalho:** confirmar que está na branch de trabalho da spec (já trocada em *Antes de começar*). Nunca commitar na default/`main`.
- **Ciclo da spec:** se o frontmatter da spec está `status: draft` e esta é a primeira execução de qualquer fase, atualizar para `status: active` + `updated_at` (commitado junto no Passo 7).
- **SHA inicial:** em **nova execução**, anotar o HEAD atual como `sha_inicial` (início ORIGINAL da fase). Em **rework**, **reusar** o `sha_inicial` do EXECUCAO existente (não redefinir).
- Gate: pré-requisitos satisfeitos, branch de trabalho ativa, `artefatos/` existe, `sha_inicial` conhecido.

### Passo 4 — Executar a fase (TDD, escopo fechado)
- Nova execução: implementar **somente** os passos da fase-alvo, tocando apenas os arquivos que ela declara (diff mínimo). Rework: corrigir **apenas** os achados da avaliação, sem ampliar escopo.
- Seguir TDD: teste vermelho → implementação → verde, conforme a subseção "Testes" da fase. Respeitar o escopo travado declarado na fase.
- **Não** iniciar nenhuma fase posterior nem antecipar trabalho dela.
- Gate: passos implementados (ou achados corrigidos); testes da fase passam.

### Passo 5 — Validar
- Executar `make check` (ou os alvos equivalentes de `.codeflow/manifest.md`) e aplicar `self-review` no diff.
- Se o target `make check` (e equivalentes do manifest) **não existir** no projeto: marcar `[—]` com justificativa no relatório e rodar a validação mínima possível (testes/lint da fase) — não tratar como falha (SPEC §3.10).
- Se `make check` existir e falhar: aplicar a política de falhas da constitution (falha Lógica → re-tentar com o erro como contexto, limite de **2 tentativas**; falha de Escopo/Ambiente → parar). Distinto do teto de 3 reworks do Passo 2.
- Gate: `make check` retornou zero (ou `[—]` justificado) e self-review limpo.

### Passo 6 — Commitar a fase
- Commitar o trabalho na branch de trabalho (Conventional Commits em pt-BR; um ou mais commits lógicos). Não commitar na default/`main`.
- Anotar o `sha_final` = HEAD atual. O **range canônico da fase é sempre `sha_inicial..sha_final`** (início original → HEAD), de modo que em rework o avaliador veja a fase inteira, não só os commits de conserto.
- Gate: trabalho commitado; `range` conhecido.

### Passo 7 — Gerar o relatório pronto para avaliação
- Escrever (ou, em rework, sobrescrever) `.codeflow/specs/<slug>/artefatos/FASE-<id>-<slug>-EXECUCAO.md` com este **frontmatter machine-readable** seguido do corpo. `fase` é o `id` da fase na spec (`1` ou `A.1`); `slug_fase` é o `slug` da fase na spec, **reusado verbatim** (não derivar de novo) para casar com o arquivo de avaliação:

  ```markdown
  ---
  spec: <slug>
  fase: <id>
  slug_fase: <slug>
  status: executado
  tentativa: <n>
  reprovacoes: <n>
  sha_inicial: <sha>
  sha_final: <sha>
  range: <sha_inicial>..<sha_final>
  ---
  ```
  Regras dos campos: `status` é `executado` (nova execução) ou `rework`. **Nova execução:** `tentativa: 1`, `reprovacoes: 0`, `sha_inicial` = HEAD original da fase. **Rework:** `tentativa` = anterior + 1; `reprovacoes` = anterior + 1 (o veredito não-APROVADO que motivou este rework); `sha_inicial` = **reusar** o do EXECUCAO anterior. `range` é sempre `sha_inicial..sha_final` (início original → HEAD), para o avaliador ver a fase inteira. Se a branch de trabalho ≠ `spec/<slug>`, **incluir `branch: <nome>`** no frontmatter (avaliador e spec-status leem este campo antes de cair no manifest).
  Corpo: resumo do que foi feito; tabela de arquivos CRIADOS/ALTERADOS (caminho + propósito); confirmação do REUSO; decisões de design e **qualquer desvio** da spec/rules com justificativa; comandos rodados + **saídas reais** (linters/test/`make check`); checklist dos ACs/critério de conclusão, cada item **com evidência**; (em rework) o que mudou nesta tentativa; dúvidas para o avaliador.
- **Commitar o relatório** (`.codeflow/specs/` é versionado): commit separado do de código. Se a spec teve o frontmatter atualizado neste run (`status: draft → active`, ou `→ done` no caso 6 do Passo 2), commitar a spec também.
- Ser **honesto** sobre o que não ficou pronto — será conferido contra o código real por um revisor independente. As decisões da fase ficam registradas **neste relatório**, não em artefato paralelo.
- Apresentar o resumo final e instruir: avaliar a fase com `/evaluate-spec-phase` em **chat zerado**.

## Definition of Done
- [ ] Spec lida na íntegra (incl. escopo travado) e documentos referenciados carregados (Passo 1).
- [ ] Fase-alvo determinada por frontmatter, pareando EXECUCAO/AVALIACAO pela `tentativa`; teto de rework (`reprovacoes`) respeitado (Passo 2).
- [ ] Dependências (por `id`) e caminhos verificados; branch de trabalho ativa; `sha_inicial` anotado (Passo 3).
- [ ] Apenas a fase-alvo executada/corrigida, dentro do escopo; nenhuma fase fora do alvo tocada (Passo 4).
- [ ] Testes da fase passam; `make check` retornou zero (ou `[—]` justificado); self-review aplicado (Passo 5).
- [ ] Trabalho commitado na branch de trabalho; `range = sha_inicial..sha_final` (Passo 6).
- [ ] Relatório `FASE-<id>-<slug>-EXECUCAO.md` gravado com frontmatter machine-readable (incl. `reprovacoes`) e commitado (Passo 7).
- [ ] Ciclo da spec avançado quando aplicável (`draft → active` na 1ª execução; `→ done` quando todas concluídas) e commitado.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
