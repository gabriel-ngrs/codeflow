---
versão: 1.12
status: experimental
atualizado: 2026-11-05
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: execute-spec-phase

## Quando usar
Executar a **próxima fase pendente** de uma spec gerada por `/create-spec` (em `.codeflow/specs/<slug>/SPEC_<NAME>.md`), deixando-a **pronta para avaliação** por `/evaluate-spec-phase`. Uma fase por execução: lê a spec e os documentos referenciados, executa só a fase da vez, **commita** o trabalho e grava o relatório `FASE-<id>-<slug>-EXECUCAO.md` (com frontmatter machine-readable e range de commits). Também opera em **modo rework**: ao receber uma avaliação `REPROVADO`, corrige a mesma fase. Em nova execução, resolve também os IMPORTANTES **herdados** destinados a ela (ARTIFACTS_SPEC §2.11.5). O `<id>` e o `<slug>` da fase vêm da spec (§5) e são reusados verbatim. Pré-requisito: a spec tem `## 5. Plano de desenvolvimento por fases`.

## Quando NÃO usar
- Para criar a spec → use `/create-spec`.
- Para avaliar a fase executada → use `/evaluate-spec-phase` (em chat zerado).
- Para executar várias fases de uma vez → **uma fase por execução**; rode de novo após a fase atual ser APROVADA.
- Para spec sem plano de fases (`§5`) → não há o que executar em fatias.
- Para um gate humano "aprove o plano antes de codar" → este workflow é **médio** (sem conversa estruturada): após preparar, executa direto. Se quiser revisar o plano da fase, faça-o no chat **antes** de invocar. É redução deliberada do gate do padrão-ouro, não omissão.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/ARTIFACTS_SPEC.md — **só §2.9 a §2.11** (relatório de execução, avaliação e máquina de estados da fase; cerca de 230 linhas), nunca o arquivo inteiro: `sed -n '/^### 2\.9 /,/^### 2\.12 /p' ~/.codeflow/framework/core/ARTIFACTS_SPEC.md`. A forma da §5 da spec (§2.8.6) é checada pelo `run-structural.sh`, não por leitura.
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- ~/.codeflow/framework/library/skills/avoid-ai-look/SKILL.md (carregar quando a fase toca interface gráfica)
- ~/.codeflow/framework/library/skills/accessibility-audit/SKILL.md (carregar quando a fase toca interface gráfica)
- ~/.codeflow/framework/library/skills/visual-consistency/SKILL.md (carregar quando a fase toca interface gráfica)
- .codeflow/constitution.md
- .codeflow/manifest.md — **só os comandos**, nunca o arquivo inteiro: `awk '/^## /{p=($0 ~ /^## (Comandos de validação|Gate|CI)/)} p' .codeflow/manifest.md`
- .codeflow/decisions/INDEX.md (carregar decisions ATIVAS cujas tags cruzem o domínio da fase)

## Antes de começar
Identificar a spec que o usuário pediu (por caminho ou slug em `.codeflow/specs/`). **Trabalhar na branch atual** — o pipeline não cria nem troca de branch; a spec e os artefatos vivem na branch em que você está (a mesma onde `/create-spec` os commitou). Se a branch atual é a default (`main`/`master`), **avisar e pedir confirmação** antes de commitar (Passo 6). Se o usuário colou uma avaliação (`FASE-<id>-*-AVALIACAO.md`) com `veredito: REPROVADO`, o alvo é o **rework** dessa fase. `PENDENTE-EXTERNO` não é rework: a fase espera a condição de fora e é reavaliada. `APROVADO`, ou o legado `RESSALVAS`, conclui a fase; seus IMPORTANTES abertos são herdados (ARTIFACTS_SPEC §2.11.5). Se a avaliação só aponta **erros de registro** (frontmatter, `range`, lista de arquivos, link), corrigi-los num commit só de documento, sem rework e sem nova avaliação. Se a fase tocar áreas com decisions arquivadas, carregar as decisions ATIVAS por tag antes de implementar.

**Menor mudança que resolve (YAGNI).** Vale para a fase inteira. Antes de escrever, ler o código que a fase toca e listar o que ela alcança (chamadores, testes, fixtures, config, exports). Escada, parando no primeiro degrau que resolve:
1. A spec manda; não corte requisito. O que a fase não pede não se faz, e se cita em uma linha no relatório.
2. Já existe no repositório (helper, componente, padrão)? Reusar.
3. A biblioteca padrão ou um recurso nativo resolve? Usar.
4. Uma dependência já instalada resolve? Usar. Nunca adicionar dependência por poucas linhas.
5. Senão, o mínimo que funciona.
- Sem abstração, wrapper, opção, config ou código "para depois". Remover é melhor que adicionar; manter as camadas e convenções existentes.
- Econômico na solução, nunca na mudança: terminar os chamadores, testes e fixtures que a fase quebrar.
- Lógica nova (ramo, laço, parser, dinheiro, segurança) leva um teste pequeno que falha se ela quebrar. Código movido ou mesclado mantém validação e tratamento de erro.
- **Nunca corte:** critério de aceite da spec, validação em fronteira (entrada externa), tratamento de erro que evita perda de dados, segurança, acessibilidade, sincronização e modo offline.
- No relatório de execução, uma linha: o que ficou deliberadamente de fora e o risco, se houver.

## Protocolo

### Passo 1 — Carregar a spec e o contexto
- Localizar `.codeflow/specs/<slug>/SPEC_<NAME>.md` **sem ler a spec inteira**: o frontmatter (`sed -n '2,/^---$/p' <SPEC>`) e a lista de fases com as dependências, `grep -n '^### Fase\|Depende de' <SPEC>`. O conteúdo da fase-alvo chega pelo pacote do Passo 3.
- **Gate estrutural da §5 (determinístico, antes de classificar fases):** rodar `bash ~/.codeflow/framework/core/scripts/run-structural.sh .codeflow/specs/<slug>/SPEC_<NAME>.md`. Exit `0` libera o Passo 2. Exit `1` = §5 malformada (id duplicado, heading ≠ bullet `id`, "Depende de" órfão, ciclo, fora de 3–8 por track, ou slug inválido): **parar**, colar a saída do script e pedir correção da spec por `/create-spec` — não classificar fases sobre uma §5 quebrada. Exit `2`/`3` = erro de execução/uso: parar. Aplica as regras de ARTIFACTS_SPEC §2.8.6 sem depender de leitura humana.
- Ler os documentos referenciados (`linked_adr`, rules, decisions ativas, os comandos do `.codeflow/manifest.md` pela expressão de `## LEIA TAMBÉM`). Os seams de código citados se inspecionam no Passo 3, a partir do pacote. **Não escrever nada ainda.**
- Gate: spec encontrada, `run-structural.sh` retornou `0`, e §5 interpretada como lista ordenada de fases.

### Passo 2 — Determinar a fase-alvo (estado por frontmatter, não por prosa)
- Para cada fase de §5 (identificada pelo `id`), ler o **frontmatter** dos artefatos em `artefatos/` (`fase:`, `status:`, `tentativa:`, `reprovacoes:` no EXECUCAO; `fase:`, `tentativa:`, `veredito:` no AVALIACAO) — nunca inferir estado de texto livre. Classificar cada fase em **um único** estado (**pendente** / **aguardando avaliação** / **reprovada** / **pendente externo** / **concluída**) e resolver **elegibilidade** e **teto** conforme a definição canônica de **ARTIFACTS_SPEC §2.11** (máquina de estados da fase): pareamento EXECUCAO↔AVALIACAO pela `tentativa`, deps concluídas por `id`, teto por `reprovacoes` (só `REPROVADO` conta). Não redefinir esses termos aqui. **Caso base:** se a pasta `artefatos/` não existe ou está vazia, nenhuma fase foi executada — o alvo é a **primeira fase de §5** (gatilho 3 da tabela).
- **Tabela de seleção do alvo** — avaliar de cima para baixo na **ordem textual de §5** (não lexical: `2` antes de `10`); o **primeiro** gatilho que casar define o alvo (a ordem das linhas é a precedência):

  | # | Gatilho | Ação |
  |---|---|---|
  | 1 | AVALIACAO `REPROVADO` colada pelo usuário (fase = a dela) | alvo = **rework** dessa fase → aplicar **guard de teto** |
  | 2 | Existe fase **reprovada** (1ª na ordem textual de §5) | alvo = **rework** dessa fase → aplicar **guard de teto** |
  | 3 | Existe fase **pendente e elegível** (todas as deps por `id` concluídas) | alvo = **nova execução** dessa fase, com os herdados destinados a ela |
  | 4 | Nenhuma elegível, mas há fase **aguardando avaliação** ou **pendente externo** | **PARAR**: aguardando → pedir `/evaluate-spec-phase`; pendente externo → relatar a condição de fora e quem a resolve (depois, `/evaluate-spec-phase` na mesma tentativa) |
  | 5 | Nenhuma elegível nem aguardando, mas há **pendente bloqueada** por dep | **PARAR** e relatar o(s) `id`(s) de dependência faltante |
  | 6 | Todas **concluídas** | **fechamento:** resolver os herdados destinados ao fechamento (§2.11.5), um commit cada; spec → `status: done` + `updated_at`, commitar a spec com a lista herdado → `sha` no corpo do commit; o documento vivo (`CLAUDE.md`, `AGENTS.md`, README) recebe no máximo o estado atual e um ponteiro para a spec, nunca o histórico dela; **PARAR** (spec concluída) |

- **Guard de teto (só em rework, §2.11.4):** com `R = EXECUCAO.reprovacoes`, se a fase-alvo é rework e `R >= 2` (o `REPROVADO` corrente fecharia o 3º) → **PARAR** e escalar ao owner. Só `REPROVADO` conta; `PENDENTE-EXTERNO` não volta ao executor e não conta. Escalar a um humano é o estado terminal seguro. Este teto é o do ciclo **executor↔avaliador**; falhas Lógicas **dentro** de uma execução seguem o limite de 2 tentativas da constitution (Passo 5), independente.
- **Multi-track:** a elegibilidade (linha 3) é por dependência de `id`, então tracks independentes avançam em paralelo — uma fase "aguardando avaliação" ou "pendente externo" só segura quem depende dela, nunca o grafo inteiro. A linha 4 só dispara quando **não** há nada elegível para executar (em single-track, isso é logo após cada execução).
- Gate: um único alvo definido (rework ou nova execução), ou parada limpa/escalonamento.

### Passo 3 — Preparar e marcar o início
- **Pacote da fase:** gravar o recorte da spec com `bash ~/.codeflow/framework/core/scripts/pacote-da-fase.sh .codeflow/specs/<slug>/SPEC_<NAME>.md <id> > .codeflow/checkpoints/pacote-<slug>-<id>.md` e lê-lo: frontmatter, resumo executivo, princípios invioláveis, o bloco da fase (com o escopo travado e as violações bloqueantes), os AC/FR/NFR/R citados e as linhas da §9. Seção fora do pacote (ex.: a §4, para os seams de código) se abre pelas linhas do rodapé, `sed -n '<a>,<b>p'`, quando a fase a cita ou um item depende dela. Id com `⚠` no rodapé se procura na spec por `grep -n`. **Saída ≠ 0 do script** (fase não achada, ou recorte não confiável, ex.: bloco de código sem fechamento): o arquivo do pacote fica vazio ou incompleto e **não se usa** — apagá-lo, ler a spec inteira por trecho (`grep -n` nos headings e `sed -n` por seção: frontmatter, resumo, princípios, o bloco da fase, os AC/FR/NFR/R citados e a §9) e registrar no relatório de execução a saída do script e que a fase foi lida sem pacote. Nunca seguir com o pacote vazio. Em rework, ler também os achados BLOQUEANTES/IMPORTANTES da AVALIACAO. Em nova execução, levantar os **herdados** destinados à fase (ARTIFACTS_SPEC §2.11.5): os IMPORTANTES `I-<n>` abertos de avaliações `APROVADO` (ou do legado `RESSALVAS`) cuja fase de destino é esta — a **primeira** fase, na ordem textual da §5, que depende da fase de origem; outra dependente não os recebe. Sem dependente, o destino é o fechamento (gatilho 6). Confirmar que os **caminhos de "Arquivos alterados" existem** no repo (se a spec citou caminho inexistente, parar e apontar — não inventar).
- Conferir dependências: cada `id` listado em "Depende de" da fase-alvo está **concluído** (AVALIACAO `veredito: APROVADO`, ou o legado `RESSALVAS`, da tentativa corrente); se faltar, **parar** e relatar qual dependência. Criar `artefatos/` se não existir (esta pasta é criada aqui, não por `/create-spec`).
- **Branch:** trabalhar na branch atual (o pipeline não troca de branch). Se for a default (`main`), avisar e pedir confirmação antes de commitar (Passo 6).
- **Ciclo da spec:** se o frontmatter da spec está `status: draft` e esta é a primeira execução de qualquer fase, atualizar para `status: active` + `updated_at` (commitado junto no Passo 7).
- **Base:** em **nova execução**, anotar a `base` da fase (`ARTIFACTS_SPEC.md` §2.9.3): o ramo remoto de que o ramo nasceu (ex.: `origin/main`) ou, quando a fase segue outra no mesmo ramo, o sha da ponta agora. Em **rework**, **reusar** a `base` do EXECUCAO existente (ou o `sha_inicial`, se ele é do formato anterior).
- **Fase ativa:** gravar `.codeflow/checkpoints/fase-ativa` com três linhas, `spec=<caminho da spec>`, `fase=<id>` e `criterio=<o comando entre crases do critério de conclusão da fase>` (`ARTIFACTS_SPEC.md` §2.8.3). Critério só em prosa (spec antiga): não gravar `fase-ativa`, e o Passo 5 roda o que a prosa pede. É o que o `fim-de-fase.sh` lê, e o Stop hook do projeto, quando ligado (`~/.codeflow/framework/library/templates/hooks/README.md`).
- Gate: pré-requisitos satisfeitos, `artefatos/` existe, `base` conhecida.

### Passo 4 — Executar a fase (TDD, escopo fechado)
- Nova execução: implementar **somente** os passos da fase-alvo, tocando apenas os arquivos que ela declara (diff mínimo). Rework: corrigir **apenas** os achados da avaliação, sem ampliar escopo — IMPORTANTE da avaliação anterior que segue aberto é "o mesmo IMPORTANTE pela 2ª vez" e vira BLOQUEANTE (ARTIFACTS_SPEC §2.10.3, escalada). Herdados recebidos são escopo autorizado da fase, mesmo fora dos arquivos que ela declara.
- Seguir TDD: teste vermelho → implementação → verde, conforme a subseção "Testes" da fase. Respeitar o escopo travado declarado na fase.
- **Não** iniciar nenhuma fase posterior nem antecipar trabalho dela.
- Gate: passos implementados (ou achados corrigidos); testes da fase passam.

### Passo 5 — Validar
- Rodar os **comandos de validação do projeto** (do `.codeflow/manifest.md`; se ausente, inferir do stack) — os gates que se aplicam à fase (lint, type, testes, segurança) — e aplicar `self-review` no diff. Rodar o necessário para provar a fase, não a suíte inteira por reflexo.
- Com `## Gate` no manifest: o L0 a cada etapa e o L1 uma vez no fim da fase, salvo quando o `## CI` declara que o CI roda o L1; nunca o L2 (`ARTIFACTS_SPEC.md` §2.3.4).
- Se um gate de validação **não existir** no projeto: marcar `[—]` com justificativa no relatório e rodar a validação mínima possível (os testes/lint da fase) — não tratar como falha (SPEC §3.10).
- Se um comando de validação existir e falhar: aplicar a política de falhas da constitution (falha Lógica → re-tentar com o erro como contexto, limite de **2 tentativas**; falha de Escopo/Ambiente → parar). Distinto do teto do Passo 2 (3 `REPROVADO`, ciclo executor↔avaliador).
- **Fim de fase:** com `fase-ativa` gravada, rodar `bash ~/.codeflow/framework/core/scripts/fim-de-fase.sh`: roda o critério e o L0 do `## Gate` e grava `.codeflow/checkpoints/fim-de-fase-<id>.log`. Saída 1 é falha Lógica (bullet acima); 0 fecha o critério.
- Gate: os comandos de validação aplicáveis retornaram zero (ou `[—]` justificado) e self-review limpo.

### Passo 6 — Commitar a fase
- Commitar o trabalho na branch atual (Conventional Commits em pt-BR; um ou mais commits lógicos). Se a branch atual é a default (`main`), confirmar antes.
- O intervalo da fase é `<merge-base de base e HEAD>..HEAD` (início original → HEAD), de modo que em rework o avaliador veja a fase inteira, não só os commits de conserto. Não há sha a anotar: o avaliador o calcula.
- Gate: trabalho commitado; `base` conhecida.

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
  base: <ramo remoto ou sha>
  ---
  ```
  Regras dos campos: `status` é `executado` (nova execução) ou `rework`. **Nova execução:** `tentativa: 1`, `reprovacoes: 0`, `base` = a do Passo 3. **Rework:** `tentativa` = anterior + 1; `reprovacoes` = anterior + 1 (o `REPROVADO` que motivou este rework; §2.9.3 / §2.11.4); `base` = **reusar** a do EXECUCAO anterior. O avaliador roda na **mesma branch** (o pipeline não troca de branch) e calcula o intervalo pela `base` — não há campo de branch no frontmatter. EXECUCAO do formato anterior (`sha_inicial`, `sha_final`, `range`) segue válido (§2.9.3).
  Corpo, até **60 linhas** fora as saídas: resumo do que foi feito; os commits da fase, por assunto; os arquivos pela saída de `git diff --stat <merge-base>..HEAD`; confirmação do REUSO; decisões de design e **qualquer desvio** da spec/rules com justificativa; **Herdados** (cada herdado recebido → `resolvido em <sha>` ou `não resolvido: <motivo>`; "nenhum" se não houver); comandos rodados + **saídas reais** (os comandos de validação do projeto: as últimas 20 linhas e o código de saída de cada um; a inteira fica no log de `.codeflow/checkpoints/`); checklist dos ACs/critério de conclusão, cada item **com evidência**; (em rework) o que mudou nesta tentativa; dúvidas para o avaliador.
- **Commitar o relatório** (`.codeflow/specs/` é versionado) no **último commit da fase**: junto do código do último passo, ou num commit logo depois. Nenhum commit só para acertar sha ou range. Se a spec teve o frontmatter atualizado neste run (`status: draft → active`, ou `→ done` no caso 6 do Passo 2), commitar a spec também.
- **Log do fim de fase:** as saídas reais do critério e do L0 vêm do `.codeflow/checkpoints/fim-de-fase-<id>.log`, não digitadas. Feito o relatório, apagar `.codeflow/checkpoints/fase-ativa`.
- Ser **honesto** sobre o que não ficou pronto — será conferido contra o código real por um revisor independente. As decisões da fase ficam registradas **neste relatório**, não em artefato paralelo.
- Apresentar o resumo final e instruir: avaliar a fase com `/evaluate-spec-phase` em **chat zerado**.

## Definition of Done
- [ ] Frontmatter e lista de fases lidos sem ler a spec inteira; `run-structural.sh` retornou `0` (gate da §5) e documentos referenciados carregados (Passo 1). Pacote da fase gravado em `.codeflow/checkpoints/` e lido (incl. escopo travado), ou, com saída ≠ 0 do script, a spec lida por trecho e o fato registrado no relatório; seção fora do pacote aberta por linha quando citada (Passo 3).
- [ ] Fase-alvo determinada por frontmatter (estado/elegibilidade/teto conforme §2.11), pareando EXECUCAO/AVALIACAO pela `tentativa`; guard de teto (3 `REPROVADO` → escala ao owner) respeitado (Passo 2).
- [ ] Herdados destinados à fase (ou ao fechamento) resolvidos e listados com o desfecho (Passos 3, 4 e 7).
- [ ] Dependências (por `id`) e caminhos verificados; `base` anotada (Passo 3).
- [ ] Apenas a fase-alvo executada/corrigida, dentro do escopo; nenhuma fase fora do alvo tocada (Passo 4).
- [ ] Testes da fase passam; comandos de validação do projeto retornaram zero (ou `[—]` justificado); self-review aplicado (Passo 5).
- [ ] Trabalho commitado na branch atual; intervalo `<merge-base de base e HEAD>..HEAD` (Passo 6).
- [ ] Relatório `FASE-<id>-<slug>-EXECUCAO.md` gravado com frontmatter machine-readable (incl. `reprovacoes`) e commitado (Passo 7).
- [ ] Ciclo da spec avançado quando aplicável (`draft → active` na 1ª execução; `→ done` quando todas concluídas) e commitado.

## Resumo final
Apresentar no formato do resumo final do `SPEC.md` §5.6.4, sem abrir o arquivo para isso: o título `## ✓ CONCLUÍDO: <workflow> — <escopo>` e as cinco seções, na ordem — `### O que foi feito`, `### Checklist Definition of Done`, `### Riscos e notas`, `### Próximos passos sugeridos`, `### Decisão registrada (se aplicável)`.
