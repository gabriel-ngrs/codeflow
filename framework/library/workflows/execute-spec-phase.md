---
versão: 1.9
status: experimental
atualizado: 2026-06-25
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
- ~/.codeflow/framework/core/ARTIFACTS_SPEC.md (§2.8.6 gate estrutural; §2.11 máquina de estados da fase)
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- ~/.codeflow/framework/library/skills/avoid-ai-look/SKILL.md (carregar quando a fase toca interface gráfica)
- ~/.codeflow/framework/library/skills/accessibility-audit/SKILL.md (carregar quando a fase toca interface gráfica)
- ~/.codeflow/framework/library/skills/visual-consistency/SKILL.md (carregar quando a fase toca interface gráfica)
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (carregar decisions ATIVAS cujas tags cruzem o domínio da fase)

## Antes de começar
Identificar a spec que o usuário pediu (por caminho ou slug em `.codeflow/specs/`). **Trabalhar na branch atual** — o pipeline não cria nem troca de branch; a spec e os artefatos vivem na branch em que você está (a mesma onde `/create-spec` os commitou). Se a branch atual é a default (`main`/`master`), **avisar e pedir confirmação** antes de commitar (Passo 6). Se o usuário colou uma avaliação (`FASE-<id>-*-AVALIACAO.md` com `veredito: REPROVADO` ou `RESSALVAS`), o alvo é o **rework** dessa fase. Se a fase tocar áreas com decisions arquivadas, carregar as decisions ATIVAS por tag antes de implementar.

## Protocolo

### Passo 1 — Carregar a spec e o contexto
- Localizar `.codeflow/specs/<slug>/SPEC_<NAME>.md` e lê-lo **na íntegra** — atenção a §4 (abordagem), §5 (plano de fases) e ao escopo travado / violações bloqueantes de cada fase.
- **Gate estrutural da §5 (determinístico, antes de classificar fases):** rodar `bash ~/.codeflow/framework/core/scripts/run-structural.sh .codeflow/specs/<slug>/SPEC_<NAME>.md`. Exit `0` libera o Passo 2. Exit `1` = §5 malformada (id duplicado, heading ≠ bullet `id`, "Depende de" órfão, ciclo, fora de 3–8 por track, ou slug inválido): **parar**, colar a saída do script e pedir correção da spec por `/create-spec` — não classificar fases sobre uma §5 quebrada. Exit `2`/`3` = erro de execução/uso: parar. Aplica as regras de ARTIFACTS_SPEC §2.8.6 sem depender de leitura humana.
- Ler os documentos referenciados (`linked_adr`, rules, decisions ativas, `.codeflow/manifest.md`) e inspecionar os seams de código citados em §4. **Não escrever nada ainda.**
- Gate: spec encontrada, `run-structural.sh` retornou `0`, e §5 interpretada como lista ordenada de fases.

### Passo 2 — Determinar a fase-alvo (estado por frontmatter, não por prosa)
- Para cada fase de §5 (identificada pelo `id`), ler o **frontmatter** dos artefatos em `artefatos/` (`fase:`, `status:`, `tentativa:`, `reprovacoes:` no EXECUCAO; `fase:`, `tentativa:`, `veredito:` no AVALIACAO) — nunca inferir estado de texto livre. Classificar cada fase em **um único** estado (**pendente** / **aguardando avaliação** / **reprovada** / **concluída**) e resolver **elegibilidade** e **teto** conforme a definição canônica de **ARTIFACTS_SPEC §2.11** (máquina de estados da fase): pareamento EXECUCAO↔AVALIACAO pela `tentativa`, deps concluídas por `id`, teto por `reprovacoes` (vereditos não-APROVADO). Não redefinir esses termos aqui. **Caso base:** se a pasta `artefatos/` não existe ou está vazia, nenhuma fase foi executada — o alvo é a **primeira fase de §5** (gatilho 3 da tabela).
- **Tabela de seleção do alvo** — avaliar de cima para baixo na **ordem textual de §5** (não lexical: `2` antes de `10`); o **primeiro** gatilho que casar define o alvo (a ordem das linhas é a precedência):

  | # | Gatilho | Ação |
  |---|---|---|
  | 1 | AVALIACAO não-APROVADO colada pelo usuário (fase = a dela) | alvo = **rework** dessa fase → aplicar **guard de teto** |
  | 2 | Existe fase **reprovada** (1ª na ordem textual de §5) | alvo = **rework** dessa fase → aplicar **guard de teto** |
  | 3 | Existe fase **pendente e elegível** (todas as deps por `id` concluídas) | alvo = **nova execução** dessa fase |
  | 4 | Nenhuma elegível, mas há fase **aguardando avaliação** | **PARAR** e pedir `/evaluate-spec-phase` |
  | 5 | Nenhuma elegível nem aguardando, mas há **pendente bloqueada** por dep | **PARAR** e relatar o(s) `id`(s) de dependência faltante |
  | 6 | Todas **concluídas** | spec → `status: done` + `updated_at`, commitar a spec, **PARAR** (spec concluída) |

- **Guard de teto (só em rework, §2.11.4):** com `R = EXECUCAO.reprovacoes`, se a fase-alvo é rework e `R >= 2` (o veredito não-APROVADO corrente fecharia o 3º) → **PARAR** e escalar ao owner. Vale para `REPROVADO` **e** `RESSALVAS` (ambos contam): escalar a um humano é o estado terminal seguro, e contar os dois garante que nenhuma sequência de vereditos faça ping-pong sem fim. Este teto é o do ciclo **executor↔avaliador**; falhas Lógicas **dentro** de uma execução seguem o limite de 2 tentativas da constitution (Passo 5), independente.
- **Multi-track:** a elegibilidade (linha 3) é por dependência de `id`, então tracks independentes avançam em paralelo — uma fase "aguardando avaliação" só segura quem depende dela, nunca o grafo inteiro. A linha 4 só dispara quando **não** há nada elegível para executar (em single-track, isso é logo após cada execução).
- Gate: um único alvo definido (rework ou nova execução), ou parada limpa/escalonamento.

### Passo 3 — Preparar e marcar o início
- Reler o bloco da fase-alvo em §5. Em rework, ler também os achados BLOQUEANTES/IMPORTANTES da AVALIACAO. Confirmar que os **caminhos de "Arquivos alterados" existem** no repo (se a spec citou caminho inexistente, parar e apontar — não inventar).
- Conferir dependências: cada `id` listado em "Depende de" da fase-alvo está **concluído** (AVALIACAO `veredito: APROVADO` da tentativa corrente); se faltar, **parar** e relatar qual dependência. Criar `artefatos/` se não existir (esta pasta é criada aqui, não por `/create-spec`).
- **Branch:** trabalhar na branch atual (o pipeline não troca de branch). Se for a default (`main`), avisar e pedir confirmação antes de commitar (Passo 6).
- **Ciclo da spec:** se o frontmatter da spec está `status: draft` e esta é a primeira execução de qualquer fase, atualizar para `status: active` + `updated_at` (commitado junto no Passo 7).
- **SHA inicial:** em **nova execução**, anotar o HEAD atual como `sha_inicial` (início ORIGINAL da fase). Em **rework**, **reusar** o `sha_inicial` do EXECUCAO existente (não redefinir).
- Gate: pré-requisitos satisfeitos, `artefatos/` existe, `sha_inicial` conhecido.

### Passo 4 — Executar a fase (TDD, escopo fechado)
- Nova execução: implementar **somente** os passos da fase-alvo, tocando apenas os arquivos que ela declara (diff mínimo). Rework: corrigir **apenas** os achados da avaliação, sem ampliar escopo.
- Seguir TDD: teste vermelho → implementação → verde, conforme a subseção "Testes" da fase. Respeitar o escopo travado declarado na fase.
- **Não** iniciar nenhuma fase posterior nem antecipar trabalho dela.
- Gate: passos implementados (ou achados corrigidos); testes da fase passam.

### Passo 5 — Validar
- Rodar os **comandos de validação do projeto** (do `.codeflow/manifest.md`; se ausente, inferir do stack) — os gates que se aplicam à fase (lint, type, testes, segurança) — e aplicar `self-review` no diff. Rodar o necessário para provar a fase, não a suíte inteira por reflexo.
- Se um gate de validação **não existir** no projeto: marcar `[—]` com justificativa no relatório e rodar a validação mínima possível (os testes/lint da fase) — não tratar como falha (SPEC §3.10).
- Se um comando de validação existir e falhar: aplicar a política de falhas da constitution (falha Lógica → re-tentar com o erro como contexto, limite de **2 tentativas**; falha de Escopo/Ambiente → parar). Distinto do teto do Passo 2 (3 vereditos não-APROVADO, ciclo executor↔avaliador).
- Gate: os comandos de validação aplicáveis retornaram zero (ou `[—]` justificado) e self-review limpo.

### Passo 6 — Commitar a fase
- Commitar o trabalho na branch atual (Conventional Commits em pt-BR; um ou mais commits lógicos). Se a branch atual é a default (`main`), confirmar antes.
- Anotar o `sha_final` = HEAD atual. O **range canônico da fase é sempre `sha_inicial..sha_final`** (início original → HEAD), de modo que em rework o avaliador veja a fase inteira, não só os commits de conserto.
- Gate: trabalho commitado; `range` conhecido.

### Passo 7 — Gerar o relatório pronto para avaliação
- Partir do molde `.codeflow/specs/_TEMPLATES/TEMPLATE-EXECUCAO.md` (anti-alucinação) e escrever (ou, em rework, sobrescrever) `.codeflow/specs/<slug>/artefatos/FASE-<id>-<slug>-EXECUCAO.md` com este **frontmatter machine-readable** seguido do corpo. `fase` é o `id` da fase na spec (`1` ou `A.1`); `slug_fase` é o `slug` da fase na spec, **reusado verbatim** (não derivar de novo) para casar com o arquivo de avaliação:

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
  Regras dos campos: `status` é `executado` (nova execução) ou `rework`. **Nova execução:** `tentativa: 1`, `reprovacoes: 0`, `sha_inicial` = HEAD original da fase. **Rework:** `tentativa` = anterior + 1; `reprovacoes` = anterior + 1 (o veredito não-APROVADO — `REPROVADO` ou `RESSALVAS` — que motivou este rework; §2.9.3 / §2.11.4); `sha_inicial` = **reusar** o do EXECUCAO anterior. `range` é sempre `sha_inicial..sha_final` (início original → HEAD), para o avaliador ver a fase inteira. O avaliador roda na **mesma branch** (o pipeline não troca de branch), então o `range` basta — não há campo de branch no frontmatter.
  Corpo: resumo do que foi feito; tabela de arquivos CRIADOS/ALTERADOS (caminho + propósito); confirmação do REUSO; decisões de design e **qualquer desvio** da spec/rules com justificativa; comandos rodados + **saídas reais** (os comandos de validação do projeto); checklist dos ACs/critério de conclusão, cada item **com evidência**; (em rework) o que mudou nesta tentativa; dúvidas para o avaliador.
- **Commitar o relatório** (`.codeflow/specs/` é versionado): commit separado do de código. Se a spec teve o frontmatter atualizado neste run (`status: draft → active`, ou `→ done` no caso 6 do Passo 2), commitar a spec também.
- Ser **honesto** sobre o que não ficou pronto — será conferido contra o código real por um revisor independente. As decisões da fase ficam registradas **neste relatório**, não em artefato paralelo.
- Apresentar o resumo final e instruir: avaliar a fase com `/evaluate-spec-phase` em **chat zerado**.

## Definition of Done
- [ ] Spec lida na íntegra (incl. escopo travado); `run-structural.sh` retornou `0` (gate da §5) e documentos referenciados carregados (Passo 1).
- [ ] Fase-alvo determinada por frontmatter (estado/elegibilidade/teto conforme §2.11), pareando EXECUCAO/AVALIACAO pela `tentativa`; guard de teto (3 não-APROVADO → escala ao owner) respeitado (Passo 2).
- [ ] Dependências (por `id`) e caminhos verificados; `sha_inicial` anotado (Passo 3).
- [ ] Apenas a fase-alvo executada/corrigida, dentro do escopo; nenhuma fase fora do alvo tocada (Passo 4).
- [ ] Testes da fase passam; comandos de validação do projeto retornaram zero (ou `[—]` justificado); self-review aplicado (Passo 5).
- [ ] Trabalho commitado na branch atual; `range = sha_inicial..sha_final` (Passo 6).
- [ ] Relatório `FASE-<id>-<slug>-EXECUCAO.md` gravado com frontmatter machine-readable (incl. `reprovacoes`) e commitado (Passo 7).
- [ ] Ciclo da spec avançado quando aplicável (`draft → active` na 1ª execução; `→ done` quando todas concluídas) e commitado.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
