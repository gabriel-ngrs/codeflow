---
mudanca: contexto-e-papeis
tipo: melhoria
tamanho: media
status: aprovado
aprovado_por: dono (lista de 05/11)
aprovado_em: 2026-11-05
registro: lista aprovada pelo dono em 2026-11-05 (pacote de tokens, PR-A, PR-C, PR-H e as regras do ponytail; decisões D1, D2, D3 e D5 do plano do orquestrador)
---

<!-- Preenchido pelo PLANEJADOR (/plan-change). Ninguém implementa antes da
     aprovação: o /implement-change exige status: aprovado.

     status: "aprovado" já ao nascer quando o pedido é claro (diz o quê e o
     porquê, sem decisão aberta para o dono): aprovado_por: pedido claro do
     dono, aprovado_em: a data. Senão "proposto" (aguardando o dono).
     Fora do pedido claro, quem aprova é o dono; quem troca o campo é ele, ou
     o orquestrador com a aprovação dele registrada (aprovado_por, aprovado_em).
     tamanho: pequena = 1 etapa; media = 2 a 4 etapas (ambas M). Direta (P) e
     grande (G) não têm plano aqui: P vai direto, G vira spec. -->

# Contexto enxuto e modelo por papel — Plano

## 1. Objetivo

Cortar o que cada agente lê e o modelo que ele gasta, sem mudar o que é exigido dele. Os workflows deixam de
mandar ler o trio INDEX + constitution + manifest quando não usam, e leem do manifest só os comandos. O
executor e o avaliador de fase leem um pacote recortado da spec (`pacote-da-fase.sh`), e o avaliador continua
podendo abrir a spec inteira. O wrapper para de mandar "carregar todos". O `modo-delegado` ganha a leitura por
trecho, a escrita por edição e a tabela papel → modelo. A orquestração ganha moldes (despacho, ciclo do recruta,
Maestro) e uma vigília só leitura. O bootstrap oferece um `CLAUDE.md` curto, e o discover relata o tamanho do que
já existe. Implementação, fase e bugfix ganham a regra da menor mudança (YAGNI). Tudo é retrocompatível: nenhum
`.codeflow/` de projeto deixa de valer.

## 2. Fora de escopo

- PR-B, PR-D e PR-E: mudança `gate-e-registro`, em paralelo. Não tocar `ARTIFACTS_SPEC.md` §2.8 a §2.10, os moldes
  de `framework/library/templates/specs/` nem o `.codeflow/manifest.md`, onde o PR-B escreve `## Gate`. Por isso
  o manifest é lido por `## Comandos de validação|Gate|CI`: a seção `## Gate` passa a valer quando existir.
- O `check-contexto.sh` é do PR-E. O discover mede com `wc -c`, sem depender dele.
- PR-F, PR-G, PR-I e `audit-enxugar`.
- Do PR-A, ficam de fora: o molde do ledger (A5); os roteiros `.codeflow/workflows/orquestrar-*` (A6); a linha
  nova do `self-review` (A2); e a conferência do INDEX pelo `audit-living-docs` (mitigação do A1). Do PR-C, fica
  de fora a linha `Tamanho:` no retorno (C3). Nenhum deles está no pedido. Ver a decisão 2 do relatório.
- Sonnet em qualquer papel, e a 2ª opinião do Codex fora da 1ª rodada de revisão de spec.
- Os wrappers de projeto escritos à mão (`.claude/commands/orquestrar-*.md` daqui e dos consumidores) não mudam.
  Cada trilha os ajusta.
- Core (`framework/core/constitution.md`, `glossary.md`, `EVOLUTION.md`): nenhum termo novo. "Pacote da fase",
  "vigília" e "recruta" aparecem como texto descritivo. A constitution universal já admite mexer no `CLAUDE.md`
  "com instrução explícita", e o "sim" do bootstrap é essa instrução.
- A defasagem anterior do catálogo (a árvore de `SPEC.md` §2.2 sem `templates/` nem skills novas) fica para a
  Auditoria. Aqui se paga só o item criado ou tocado.

## 3. Classificação (skill `change-sizing`)

| Sinal | Valor | Evidência |
|-------|-------|-----------|
| Etapas | 4 (média) | uma etapa por frente; cada uma fecha verde e commitada sozinha |
| Áreas tocadas | **4 (grande)** | `framework/core/` (SPEC, ARTIFACTS, scripts), `framework/library/` (workflows, skills, moldes), `framework/meta/` (bootstrap, discover, create-workflow) e os scripts da raiz (`setup-*.sh`, `install.sh`); camadas da `.codeflow/constitution.md`, "Padrão arquitetural" |
| Contrato / fronteira | toca de forma compatível (média) | `ARTIFACTS_SPEC.md` Parte 1 (§1.5.3, §1.5.6, §1.6.6, §1.9 e §1.11): o INDEX deixa de ser entrada obrigatória, e os workflows com as quatro entradas continuam válidos. `SPEC.md` §3.7 e §10.9 são emendados, e §2.5 ganha a exceção do bootstrap. Nenhum schema da Parte 2 muda; §2.3.3 muda só texto de regra |
| Migração | não | nenhum artefato de projeto precisa ser reescrito |
| ADR nova | não (decision de registro) | aprovação do dono de 2026-11-05 (D1, D2), registrada na decision da Etapa 3 |
| Comportamento percebido | muda o que todo recruta lê e o modelo de quem executa (fronteira com grande) | o veredito e o critério do avaliador não mudam; quem não segue a tabela continua em high |
| Trabalho em paralelo | não | a mudança `gate-e-registro` corre em paralelo, mas não divide esta tarefa |

**Conclusão:** a `change-sizing` dá **G**, pelas 4 áreas e pela fronteira de comportamento. Pelo despacho, o
pacote segue como **M (média, 4 etapas)**: a lista foi aprovada inteira pelo dono, e a D2 cobre o contrato do
`SPEC.md` e a política de modelo. Isso está registrado, não rebaixado em silêncio.

## 4. Mapa do código

| Caminho | NOVO / ALTERADO / REUSADO | Para quê |
|---------|---------------------------|----------|
| `framework/library/workflows/{design-pass,evaluate-spec-phase,bugfix,implement-change,batch-bugfix,plan-change,verify-audit,refactor,security-sweep,execute-spec-phase,double-check,review-change}.md` | ALTERADO | sai `.codeflow/INDEX.md`; o manifest passa a ser lido por seção (`awk` só nos comandos; com `Stack identificada\|Padrões` em `plan-change` e `refactor`) |
| `framework/library/workflows/create-spec.md`, `audit.md` | ALTERADO | o INDEX fica; o manifest é lido por seção, com stack e padrões |
| `framework/library/workflows/spec-status.md` | ALTERADO | sai o trio inteiro (lê frontmatter) |
| `framework/library/workflows/ideacao.md` | REUSADO | já lê só a constitution, sem INDEX nem manifest; não muda |
| `framework/core/ARTIFACTS_SPEC.md` | ALTERADO | §1.5.3 (l. 820), §1.5.6 (l. 879), §1.6.6 (l. 1032) e §1.9 (l. 1506): três entradas obrigatórias (constitution universal, a de projeto, o manifest por seção), e o INDEX só para quem sonda sem lista fechada; §1.11: o literal novo do wrapper; §2.3.3 (l. 1999): só `discover` e `audit` recalculam o hash |
| `framework/meta/create-workflow/SKILL.md` | ALTERADO | l. 87: a validação confere as três entradas |
| `setup-slash-commands.sh` (l. 124), `setup-codex-skills.sh` (l. 195, 241), `setup-codex-prompts.sh` (l. 193, 239), `install.sh` (l. 166) | ALTERADO | texto novo do wrapper. Os geradores da máquina regravam o wrapper quando o corpo difere (`setup-slash-commands.sh:128-136`). O `install.sh` preserva o wrapper e relata a divergência (`install.sh:168-172`) |
| `framework/library/workflows/implement-change.md`, `execute-spec-phase.md`, `bugfix.md` | ALTERADO | seção "Menor mudança que resolve (YAGNI)", com o trecho do ponytail ajustado. No `execute-spec-phase`, o degrau 1 vira "a spec manda; não corte requisito" |
| `framework/library/workflows/evaluate-spec-phase.md` | ALTERADO | l. 57: sai o `git stash`; reverte por `git checkout -- <caminho>` e `git clean -fd -- <caminho>`, só do que a verificação criou |
| `framework/core/scripts/pacote-da-fase.sh` | NOVO | `bash pacote-da-fase.sh <SPEC.md> <id>` imprime: o frontmatter, o `## Resumo executivo`, o `### 1.x Princípios invioláveis`, o bloco `### Fase <id> —`, os AC/FR/NFR/R citados no bloco, as linhas da §9 que citam a fase e um rodapé com as linhas das seções omitidas (id não achado aparece com `⚠`). Saídas: 0; 1 fase inexistente; 2 arquivo inacessível; 3 uso |
| `framework/core/scripts/run-structural.sh` | REUSADO | molde de estilo (cabeçalho, `usage`, saídas 0 a 3); sem mudança |
| `framework/library/workflows/execute-spec-phase.md` | ALTERADO | Passo 1: lista as fases por `grep -n '^### Fase\|Depende de'`, sem ler a spec inteira. Passo 3: grava o pacote em `.codeflow/checkpoints/pacote-<slug>-<id>.md` e o lê. DoD (l. 113): "pacote lido; seção fora dele aberta por linha quando citada" |
| `framework/library/workflows/evaluate-spec-phase.md` | ALTERADO | Passo 1 (l. 43) e DoD (l. 85): lê o mesmo pacote e pode conferir contra a spec inteira, ou abrir a seção pelo rodapé, sempre que um achado pedir |
| `framework/library/skills/modo-delegado/SKILL.md` | ALTERADO | §1 guarda a linha `Modelo:` do despacho. "4a. Ler pouco, escrever por edição": `grep -n` + `sed -n` acima de 300 linhas; não reler; doc existente muda por Edit ou `>>`; saída longa por `tail` ou log. "Papel, modelo e esforço": a tabela, a escalada para high e o Codex só na 1ª rodada de revisão de spec, no máximo 1 por spec e com retorno ≤ 15 linhas. Sem Sonnet |
| `framework/library/templates/orquestracao/DESPACHO.md` | NOVO | bloco de despacho com `Modelo:` e as regras genéricas de todo despacho (≤ 2k chars) |
| `framework/library/templates/orquestracao/CICLO-DO-RECRUTA.md` | NOVO | um recruta por tarefa; correção da mesma tarefa no mesmo recruta, sem `/clear`, enquanto o contexto couber; dispensar no `CONCLUÍDO`; `/clear` só antes de tarefa nova; avaliador sempre em outro terminal |
| `framework/library/templates/orquestracao/MAESTRO.md` | NOVO | um Maestro novo por spec ou lote, com o PLANO como memória; a conversa com o dono separada do Maestro que despacha; `/compact` ou passagem de bastão antes de espera longa; status numa fonte só; vigília por cron com `vigia.sh` |
| `framework/core/scripts/vigia.sh` | NOVO | só leitura. Recebe `<arquivo-de-estado> [<ramo>...]` e um limite em minutos (padrão 30), lê o `git log -1 --format=%ct` dos ramos e o mtime do arquivo (`stat -c %Y`). Saídas: 0 houve avanço; 1 parado acima do limite; 2 erro de execução; 3 uso. Quem chama `maestri notify` é o cron ou a routine, nunca o script (§0.9) |
| `framework/core/SPEC.md` | ALTERADO | §3.7: sessão fresca **por tarefa**, e a correção da mesma tarefa pode seguir na sessão do executor; §2.5 e §10.9: o bootstrap pode criar `CLAUDE.md`/`AGENTS.md` curtos num projeto novo, com "sim" explícito; §2.2: `pacote-da-fase.sh`, `vigia.sh`, `templates/orquestracao/`, `templates/projeto/`; frontmatter |
| `.codeflow/decisions/AAAA-MM-DD-contexto-e-papeis.md` | NOVO | registra a aprovação do dono (D1, D2), as emendas do §3.7 e do §10.9 e a promoção dos moldes de orquestração. Nasce sem linha no INDEX |
| `framework/library/templates/projeto/CLAUDE.md`, `AGENTS.md` | NOVO | molde curto (≤ 8k chars, < 200 linhas): o que é o projeto, as invariantes, os ramos, um ponteiro para os comandos do manifest e para docs, e "nunca narrar bug nem spec aqui". O `CLAUDE.md` só importa `@AGENTS.md` |
| `framework/meta/bootstrap/SKILL.md` | ALTERADO | Fase 3 oferece criar os dois a partir do molde, e só escreve com "sim" explícito; Fase 5 os lista |
| `framework/meta/discover/SKILL.md` | ALTERADO | Fase 1 mede `wc -c` e `wc -l` de `CLAUDE.md`/`AGENTS.md`; Fase 4b relata o que passou do teto do molde, sem editar. O schema do `discovered.md` (§2.4) não muda |
| `framework/core/SPEC.md` §3.5 | REUSADO | conferido: lista só workflows universais, e nenhum é criado; nada a pagar |
| `README.md` | ALTERADO | l. 92: cita os scripts novos ao lado do `run-structural.sh`; frontmatter |

> Todo caminho ALTERADO ou REUSADO existe no repositório (conferido ao escrever, `ls` e `grep -n` nas linhas citadas).

## 5. Critérios de aceite

- **CA-1** — Dado os 16 workflows universais, então `.codeflow/INDEX.md` aparece em `## LEIA TAMBÉM` só no
  `create-spec` e no `audit`. Nenhum manda ler o `.codeflow/manifest.md` inteiro: todos os que o citam usam a
  expressão `awk` por seção. O `spec-status` não cita o trio. O `ideacao` não muda.
- **CA-2** — Dado a expressão `awk` citada, quando aplicada ao `.codeflow/manifest.md` daqui, então ela devolve
  `## Comandos de validação` inteiro e nenhuma outra seção. Se o manifest tiver `## Gate` ou `## CI`, eles saem
  junto. A variante com stack devolve também `## Stack identificada` e `## Padrões detectados`.
- **CA-3** — Dado `ARTIFACTS_SPEC.md` §1.5.3, §1.5.6, §1.6.6 e §1.9 e o `create-workflow`, então a regra exige
  três entradas (constitution universal, constitution de projeto e manifest por seção), e o INDEX passa a valer
  só para quem sonda sem lista fechada. Um workflow com as quatro entradas antigas continua válido. §2.3.3 diz
  que só `discover` e `audit` recalculam o hash.
- **CA-4** — Dado os cinco geradores de wrapper e o literal de §1.11, então nenhum contém "Carregue todos os
  arquivos listados". Todos levam o mesmo texto novo: "como cada item manda; só a seção indicada; condicional só
  quando a condição vale". O gate `test` gera os wrappers em `HOME` temporário com o texto novo. O `install.sh`,
  ensaiado num projeto descartável dentro de `$T` com `HOME="$T"`, cria o wrapper novo e preserva o antigo.
- **CA-5** — Dado as 66 specs reais em `~/Projetos/*/.codeflow/specs/`, quando `pacote-da-fase.sh` roda para cada
  id de fase da §5, então sai 0, e a saída contém o frontmatter, o TL;DR, o heading `### Fase <id>` e o rodapé de
  seções omitidas. Com id inexistente sai 1; sem argumento, 3; com arquivo inexistente, 2. Ele não escreve em
  disco e só usa bash, coreutils e awk (bloco `lint`).
- **CA-6** — Dado uma fase que cita `AC-N` e `FR-N`, quando o pacote é gerado, então cada item citado aparece com o
  texto da spec. Um id citado que não existe aparece no rodapé com `⚠`, sem derrubar a saída.
- **CA-7** — Dado `execute-spec-phase` e `evaluate-spec-phase`, então nenhum manda ler a spec "na íntegra". Os dois
  gravam e leem o pacote em `.codeflow/checkpoints/`. O avaliador declara que pode conferir contra a spec
  inteira, ou abrir a seção pelo rodapé, e o critério do veredito não muda. O `evaluate-spec-phase` não cita
  `git stash`.
- **CA-8** — Dado `implement-change`, `execute-spec-phase` e `bugfix`, então cada um tem a seção "Menor mudança que
  resolve (YAGNI)": a escada de 5 degraus, o "nunca corte" e uma linha no relatório com o que ficou de fora. No
  `execute-spec-phase`, o primeiro degrau é "a spec manda; não corte requisito".
- **CA-9** — Dado o `modo-delegado`, então ele tem a leitura por trecho e a escrita por edição. Tem a tabela papel
  → modelo: Opus medium para executor, avaliador, conferente e revisor de mudança; Opus high para Maestro, spec,
  revisão de spec, contrato, segurança e debug difícil. Tem a escalada para high: 2 falhas Lógicas seguidas, o
  2º `REPROVADO` da mesma fase ou um sinal de risco da `change-sizing`. Tem o Codex só na 1ª rodada de revisão
  de spec, no máximo 1 por spec, e nenhuma linha de Sonnet. O §1 guarda a linha `Modelo:`.
- **CA-10** — Dado `templates/orquestracao/`, então os três moldes cobrem: despacho com `Modelo:`; correção no mesmo
  recruta e dispensa ao concluir; Maestro novo por spec ou lote, com o PLANO como memória e a conversa com o dono
  separada. Dado `vigia.sh` com um arquivo de estado de mtime antigo e um ramo sem commit recente, então ele sai
  1. Com avanço dentro do limite, sai 0. Ele não escreve nada: `git status` igual antes e depois.
- **CA-11** — Dado `SPEC.md`, então §3.7 diz "sessão fresca por tarefa", com o rework da mesma tarefa na sessão do
  executor e o avaliador sempre em outra. §10.9 e §2.5 admitem o `CLAUDE.md`/`AGENTS.md` do bootstrap, com "sim"
  explícito. §8.3 continua: workflow não toca `CLAUDE.md`. A decision existe, sem linha no `decisions/INDEX.md`.
- **CA-12** — Dado o molde `templates/projeto/`, então o `CLAUDE.md` tem `@AGENTS.md` e mais nada de regra, e o
  `AGENTS.md` cabe em 8k chars e 200 linhas. O bootstrap só escreve com "sim" explícito. O discover relata o
  tamanho de `CLAUDE.md`/`AGENTS.md` existentes e nunca os edita.
- **CA-13** — Dado o catálogo, então `SPEC.md` §2.2 lista os itens novos, `README.md` cita os scripts novos e
  todo arquivo tocado tem `versão` e `atualizado` atualizados. O gate `check` sai verde. Nenhum arquivo do core
  foi tocado.

## 6. Etapas

### Etapa 1 — Contexto enxuto nos workflows, wrapper e regras transversais
- **Faz:** tira o INDEX de 12 workflows e o trio do `spec-status`, e troca a linha do manifest pela expressão
  `awk` nos outros 14. Emenda `ARTIFACTS_SPEC.md` §1.5.3, §1.5.6, §1.6.6, §1.9, §1.11 e §2.3.3, e o
  `create-workflow`. Põe o texto novo do wrapper nos 5 geradores. Põe a seção YAGNI em `implement-change`,
  `execute-spec-phase` e `bugfix`, e troca o `git stash` do `evaluate-spec-phase`.
- **Arquivos:** os 15 workflows da §4; `framework/core/ARTIFACTS_SPEC.md`; `framework/meta/create-workflow/SKILL.md`;
  `setup-slash-commands.sh`; `setup-codex-skills.sh`; `setup-codex-prompts.sh`; `install.sh`.
- **Testes:** nascem vermelhos e ficam verdes:
  - `grep -l '\.codeflow/INDEX.md' framework/library/workflows/*.md` devolve só `create-spec` e `audit`;
  - `grep -rn 'Carregue todos os arquivos' setup-*.sh install.sh framework/core/ARTIFACTS_SPEC.md` volta vazio;
  - `grep -n 'stash' framework/library/workflows/evaluate-spec-phase.md` volta vazio;
  - a expressão `awk` aplicada ao `.codeflow/manifest.md` devolve só as seções esperadas;
  - o ensaio do `install.sh` num projeto descartável, com `HOME="$T"`.
- **Cobre:** CA-1, CA-2, CA-3, CA-4, CA-8, parte do CA-7 (stash)
- **Gate:** bloco `lint` do `.codeflow/manifest.md`, mais o bloco `test` (os setups mudaram)

### Etapa 2 — Pacote da fase
- **Faz:** escreve `framework/core/scripts/pacote-da-fase.sh` no estilo do `run-structural.sh`, com uma lista de
  prefixos de id (`AC`, `CA`, `FR`, `NFR`, `R`) e avisando o que não achou. O `execute-spec-phase` (Passos 1 e 3,
  DoD) e o `evaluate-spec-phase` (Passo 1, DoD) passam a gravar e ler o pacote, e o avaliador mantém o direito de
  ler a spec inteira.
- **Arquivos:** `framework/core/scripts/pacote-da-fase.sh`, `execute-spec-phase.md`, `evaluate-spec-phase.md`.
- **Testes:** nascem vermelhos e ficam verdes:
  - laço sobre as 66 specs reais, cada id de `grep '^### Fase'`, com saída 0 e o heading presente; a saída vai
    para `/dev/null` ou para o scratchpad, nunca para o repositório;
  - id inexistente sai 1; sem argumento, 3; arquivo inexistente, 2;
  - uma fase com `AC-N` citado traz o item;
  - `grep -n 'na íntegra' execute-spec-phase.md` não acha a spec.
- **Cobre:** CA-5, CA-6, CA-7
- **Gate:** bloco `lint` do `.codeflow/manifest.md` (o `bash -n` e a stack já cobrem `framework/core/scripts/*.sh`)

### Etapa 3 — Modelo por papel e molde de orquestração
- **Faz:**
  - `modo-delegado` ganha "4a. Ler pouco, escrever por edição" e "Papel, modelo e esforço", e o §1 guarda a
    linha `Modelo:`;
  - nascem `templates/orquestracao/{DESPACHO,CICLO-DO-RECRUTA,MAESTRO}.md` e `framework/core/scripts/vigia.sh`;
  - `SPEC.md` §3.7 é emendado;
  - nasce a decision `.codeflow/decisions/AAAA-MM-DD-contexto-e-papeis.md`. Ela cobre a aprovação do dono, a
    emenda do §3.7, a do §10.9 (redigida aqui, aplicada na Etapa 4) e a promoção dos moldes.
- **Arquivos:** `framework/library/skills/modo-delegado/SKILL.md`; os três moldes;
  `framework/core/scripts/vigia.sh`; `framework/core/SPEC.md`; a decision.
- **Testes:** nascem vermelhos e ficam verdes:
  - `vigia.sh` em repositório descartável no scratchpad: com o arquivo de estado em mtime antigo (`touch -d`) e
    commit antigo, sai 1; com commit novo, sai 0; sem argumento, sai 3. Antes e depois, o `git status` é igual;
  - `grep -n 'Sonnet' modo-delegado/SKILL.md` só acha a linha que diz "sem Sonnet", ou volta vazio;
  - `wc -c DESPACHO.md` ≤ 2000.
- **Cobre:** CA-9, CA-10, parte do CA-11 (§3.7 e decision)
- **Gate:** bloco `lint` do `.codeflow/manifest.md`

### Etapa 4 — CLAUDE.md enxuto e catálogo
- **Faz:**
  - nascem os moldes `templates/projeto/{CLAUDE,AGENTS}.md`;
  - o `bootstrap` oferece os moldes e só escreve com "sim"; o `discover` mede e relata;
  - `SPEC.md` §2.5 e §10.9 são emendados;
  - paga o catálogo: `SPEC.md` §2.2 e `README.md`, e `versão` e `atualizado` de todo arquivo tocado nas quatro
    etapas, uma vez cada; o frontmatter de `SPEC.md` e de `ARTIFACTS_SPEC.md` sobe a versão menor.
- **Arquivos:** os dois moldes, `framework/meta/bootstrap/SKILL.md`, `framework/meta/discover/SKILL.md`,
  `framework/core/SPEC.md`, `README.md` e o frontmatter dos arquivos das Etapas 1 a 3.
- **Testes:** nascem vermelhos e ficam verdes:
  - `wc -c AGENTS.md` ≤ 8000 e `wc -l` < 200;
  - `grep -c '^@AGENTS.md' CLAUDE.md` = 1;
  - `git diff --name-only origin/main...HEAD` comparado ao `grep -l "atualizado: <hoje>"`: todo arquivo do diff
    com frontmatter tem a data;
  - core intocado: `git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md framework/core/EVOLUTION.md` volta vazio.
- **Cobre:** CA-11, CA-12, CA-13
- **Gate:** `check` do `.codeflow/manifest.md` (lint, test e security)

## 7. Riscos e como desfazer

- **Um workflow perde uma informação que só existia no INDEX.** O INDEX daqui só aponta constitution, manifest e
  decisions, que continuam carregados por outro caminho. Nos consumidores, a conferência pelo `audit-living-docs`
  fica como próximo passo (fora de escopo).
- **O executor perde uma restrição transversal por ler o pacote.** O TL;DR e os princípios sempre entram, e o
  rodapé dá a linha do resto. O avaliador pode abrir a spec inteira. A medição com e sem pacote (2 fases) é
  pós-passo do orquestrador.
- **O avaliador em medium deixa passar um bloqueante.** A escalada e o critério do veredito não mudam. O A/B curto é
  pós-passo do orquestrador.
- **Conflito com `gate-e-registro`.** Os dois ramos tocam `SPEC.md` §2.2 (scripts novos lado a lado),
  `execute-spec-phase.md` e `evaluate-spec-phase.md` (Passos diferentes) e os frontmatters. Quem fizer o merge
  depois traz `origin/main` por merge (D4) e resolve, e o gate `check` roda de novo.
- **Deploy.** Mudam `setup-*.sh`, `install.sh`, o `modo-delegado` e os workflows. Na Fase 7: `git pull --ff-only`,
  `bash ~/.codeflow/setup-slash-commands.sh` e `bash ~/.codeflow/setup-codex-skills.sh`, o aviso de re-rodar
  `install.sh` (só o wrapper de projeto muda, e ele é preservado) e o aviso aos orquestradores (o `modo-delegado`
  mudou; o executor lê o pacote; a tabela de modelos).
- **Desfazer:** `git revert` dos quatro commits de etapa. Nenhum artefato de projeto é reescrito.

## 8. Como a revisão vai provar

- Ler o diff contra os CA e rodar os `grep` de cada etapa (§6).
- Rodar o laço do `pacote-da-fase.sh` sobre as specs reais e os casos de saída 1, 2 e 3. Abrir um pacote de uma
  fase com AC citado e conferir contra a spec.
- Rodar `vigia.sh` no repositório descartável (saídas 0, 1 e 3, com `git status` igual).
- Ensaiar o `install.sh` num projeto descartável dentro de `$T` com `HOME="$T"`, e conferir o wrapper criado.
- Rodar o gate `check` do manifest na raiz da worktree, sobre o ramo commitado, e colar a saída real.
- Conferir que o core e os trechos da outra mudança ficaram intocados:
  `git diff origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md framework/core/EVOLUTION.md framework/library/templates/specs/ .codeflow/manifest.md`
  volta vazio, e `git diff origin/main...HEAD -- framework/core/ARTIFACTS_SPEC.md` não tem hunk entre `### 2.8` e
  `### 2.11`.
