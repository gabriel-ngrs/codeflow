---
mudanca: gate-e-registro
tipo: melhoria
tamanho: media
status: aprovado
aprovado_por: dono (lista de 05/11)
aprovado_em: 2026-11-05
registro: lista aprovada pelo dono em 2026-11-05 (pesquisa de tokens de 2026-11-02, pacotes PR-B, PR-D e PR-E, e os cortes de processo no que for do framework); plano do orquestrador de 2026-11-05, decisões D1, D2, D3 e D5
---

<!-- Preenchido pelo PLANEJADOR (/plan-change), em modo delegado. Pela decisão
     D1 do orquestrador, o plano não espera nova aprovação do dono: o
     orquestrador troca o status para aprovado (aprovado_por: dono (lista de
     05/11)). Sai "proposto" porque leva decisões pequenas para ele ratificar
     (§7, "Decisões pedidas ao orquestrador"). -->

# Esteira em camadas, fim de fase executável e registro mínimo — Plano

## 1. Objetivo

O framework passa a ter vocabulário e ferramentas para rodar o barato sempre e o caro raramente, sem deixar de rodar:
a seção opcional `## Gate` (L0/L1/L2) no manifest, com quem roda cada camada; o critério de conclusão da fase com um
comando, conferido por script e, se o projeto quiser, por um Stop hook; e um registro mais curto — `base` no lugar dos
sha, o relatório no último commit, teto de 60 linhas, e dois scripts somente leitura que conferem commits e tamanho de
contexto. Tudo retrocompatível: nenhum `.codeflow/` existente deixa de valer, e o `run-structural.sh` mantém o código de
saída de toda spec antiga.

## 2. Fora de escopo

- PR-A, PR-C, PR-H, PR-F, PR-G, PR-I e as regras do ponytail (mudança paralela `contexto-e-papeis`). Nos arquivos que ela
  também toca (`execute-spec-phase`, `evaluate-spec-phase`, `implement-change`, `bugfix`), só o bullet que este pacote exige;
  `modo-delegado` e os wrappers (`setup-*.sh`) não são tocados.
- O molde de despacho `templates/orquestracao/DESPACHO.md` (é do PR-C). O `/goal` pelo orquestrador (D3) fica descrito no
  README do molde de hooks (§7, decisão pedida 1).
- Corte 36 (congelar o contrato no passo da revisão de spec): o framework não tem workflow universal de revisão de spec nem
  de congelamento; são workflows de projeto. Nada a mudar aqui (§7, decisão pedida 2).
- Molde de hook `commit-msg` e a regra "nenhum `--no-verify`" do `check-commits.sh`: o git não registra o `--no-verify` no
  histórico, então não há o que conferir por script (§7, decisão pedida 4).
- Transformar o aviso do `run-structural.sh` em erro (exit 1): versão seguinte, depois que as specs ativas migrarem.
- Core (`constitution.md`, `glossary.md`, `EVOLUTION.md`): intocado; nenhum termo novo no glossary (D3). "Esteira em camadas",
  "camada" e "base" ficam como texto descritivo.
- `install.sh` e os scripts de setup: não mudam. O Stop hook é opt-in, com o trecho pronto; nada escreve `.claude/settings.json`
  (`SPEC.md` §3.9).
- Dívida anterior do catálogo (`SPEC.md` §2.2 sem `templates/`, sem as skills novas): item da Auditoria.

## 3. Classificação (skill `change-sizing`)

| Sinal | Valor | Evidência |
|-------|-------|-----------|
| Etapas | 4 | uma por pacote (B, D, E1+E2, E3) e a última paga o catálogo; cada uma verde e commitada sozinha |
| Áreas tocadas | 3 camadas (core/contrato e scripts, library, meta) | `.codeflow/constitution.md`, "Padrão arquitetural" |
| Contrato / fronteira | muda de forma compatível | `ARTIFACTS_SPEC.md` §2.3 (seção opcional), §2.8 (regra nova só de aviso), §2.9/§2.10 (campo novo `base`; `sha_inicial`/`sha_final`/`range` viram opcionais e os antigos seguem válidos) |
| Migração | não | nenhum artefato de projeto precisa ser reescrito |
| ADR nova | não (decision de registro) | aprovação do schema retrocompatível pelo dono em 2026-11-05 (D2), registrada na decision da Etapa 1 |
| Comportamento percebido | novo, isolado e opt-in | sem `## Gate`, sem `fase-ativa` e sem hook, todo workflow faz o que faz hoje |

Tamanho **M (média)**, fixado também pelo despacho. A mudança de schema da Parte 2, que pela constitution do repositório
para no dono, está coberta pela D2 por ser retrocompatível; o CA-12 exige o teste disso.

## 4. Mapa do código

| Caminho | NOVO / ALTERADO / REUSADO | Para quê |
|---------|---------------------------|----------|
| `framework/core/ARTIFACTS_SPEC.md` | ALTERADO | §2.3.4–§2.3.7 (`## Gate`, quem roda cada camada, teto da seção de comandos); §2.8.3/§2.8.6 (critério com comando, aviso); §2.9.1/§2.9.3/§2.9.6/§2.9.7 e §2.10.1/§2.10.3/§2.10.6 (`base`, relatório no último commit, teto de 60 linhas) |
| `framework/core/SPEC.md` | ALTERADO | §3.10 (a camada do `## Gate`); §2.2 (scripts novos, testes e `templates/hooks/`) |
| `framework/core/scripts/run-structural.sh` | ALTERADO | `⚠ fase <id>: critério de conclusão sem comando entre crases`, mantendo o código de saída |
| `framework/core/scripts/fim-de-fase.sh` | NOVO | lê `.codeflow/checkpoints/fase-ativa`, roda o critério e o L0, grava o log; modo `--hook` para Stop hook |
| `framework/core/scripts/check-commits.sh` | NOVO | `<base>`: assunto ≤ 72 e Conventional Commits, trailer `Tamanho:` nos ramos `bug/*`, `melhoria/*`, `chore/*`, nenhum commit "acerta os sha" |
| `framework/core/scripts/check-contexto.sh` | NOVO | tetos de `CLAUDE.md` (e igual ao `AGENTS.md`), `MEMORY.md` do projeto, INDEX, constitution, manifest e `## Comandos de validação`; aviso para `SPEC_*.md` ativo |
| `framework/core/scripts/testes/run-testes.sh` e `framework/core/scripts/testes/casos/` | NOVO | casos dos quatro scripts, com fixtures sintéticas (spec antiga, spec nova, repo git temporário, `HOME` temporário) |
| `framework/library/templates/hooks/stop-fim-de-fase.json`, `framework/library/templates/hooks/README.md` | NOVO | trecho do `.claude/settings.json` (timeout acima do tempo-alvo do L0) e como ligar; o `/goal` opcional do orquestrador |
| `framework/library/templates/specs/SPEC_TEMPLATE.md` | ALTERADO | bullet do critério: `` `<comando>` passa; e <condição verificável, numa linha> `` |
| `framework/library/templates/specs/TEMPLATE-EXECUCAO.md`, `TEMPLATE-AVALIACAO.md` | ALTERADO | `base`; sha opcionais; teto de 60 linhas; saída real = últimas 20 linhas + código de saída; arquivos por `git diff --stat` |
| `framework/library/templates/changes/EXECUCAO.md`, `REVISAO.md` | ALTERADO | o mesmo para o ciclo de mudança |
| `framework/library/workflows/execute-spec-phase.md` | ALTERADO | Passo 3 (`base`, grava `fase-ativa`), Passo 5 (L0), Passos 6–7 (relatório no último commit, log do `fim-de-fase.sh`), linha 6 do Passo 2 (fechamento enxuto) |
| `framework/library/workflows/evaluate-spec-phase.md` | ALTERADO | Passo 2 (diff pela `base`, conferência da lista de commits), Passo 3 (L1 ou gate de merge verde) |
| `framework/library/workflows/implement-change.md` | ALTERADO | Passo 1 (`base`), Passo 3 (L0; L1 no fim se o CI não roda o L1), Passo 5 (relatório no último commit; fechamento enxuto) |
| `framework/library/workflows/review-change.md` | ALTERADO | Passo 1 (diff pela `base`), Passo 2 (L1 ou gate de merge verde) |
| `framework/library/workflows/bugfix.md`, `double-check.md` | ALTERADO | Passo 5 do bugfix (L0); Passo 4 do double-check ("gate de merge declarado verde") |
| `framework/library/workflows/create-spec.md` | ALTERADO | Fase 4: critério de conclusão com comando |
| `framework/library/skills/change-sizing/SKILL.md` | ALTERADO | §5: o trailer é conferido por `check-commits.sh` |
| `framework/meta/discover/SKILL.md`, `framework/meta/bootstrap/SKILL.md` | ALTERADO | 3b/4b: `## Gate` opcional, só com comando observado (discover) ou decidido (bootstrap) |
| `.codeflow/manifest.md` | ALTERADO | `## Gate` (L0 = `lint`, L1 = `check`, L2 = `[—]`); `test` chama `run-testes.sh`; `lint` cobre `scripts/testes/` e chama os dois `check-*`; `validation_hash` recalculado (o `run-structural.sh` é arquivo crítico) |
| `.codeflow/decisions/2026-11-05-gate-e-registro.md` | NOVO | aprovação do schema (D2), regras de retrocompatibilidade, a exceção de saída do modo `--hook` (sem linha no INDEX) |
| `README.md` | ALTERADO | seção dos scripts: os três novos e o molde de hooks |
| `framework/library/workflows/plan-change.md`, `framework/library/templates/changes/PLANO.md` | REUSADO | este plano; sem mudança |

> Todo caminho ALTERADO ou REUSADO existe no repositório (conferido ao escrever).

## 5. Critérios de aceite

- **CA-1** — Dado um manifest com `## Gate`, então ele declara L0, L1 e L2, uma linha por camada (quando, comando, tempo-alvo, trava), camada sem comando é `[—]`, e o texto diz que L2 nunca some, só muda de hora; dado um manifest sem `## Gate`, então todo workflow segue o texto de hoje.
- **CA-2** — Dado `## Gate`, quando quem escreve código (`execute-spec-phase`, `implement-change`, `bugfix`) valida, então roda L0 a cada etapa e L1 uma vez no fim, salvo se o `## CI` declara que o CI roda o L1; quem confere (`evaluate-spec-phase`, `review-change`, `double-check`) roda L1 ou confere o gate de merge declarado verde do sha; ninguém roda L2. A regra mora em §2.3.4 e os workflows a citam.
- **CA-3** — Dado o `ARTIFACTS_SPEC.md` §2.3.7, então há o anti-padrão "`## Comandos de validação` com histórico, acima de 4.000 caracteres", e o `check-contexto.sh` o confere.
- **CA-4** — Dado uma spec cujo critério de conclusão de fase não tem comando entre crases, quando o `run-structural.sh` roda, então imprime `⚠ fase <id>: critério de conclusão sem comando entre crases` e sai com o mesmo código que sairia sem a regra; com o comando, nenhum aviso.
- **CA-5** — Dado o molde `SPEC_TEMPLATE.md` e a Fase 4 do `create-spec`, então o critério de conclusão nasce no formato `` `<comando>` passa; e <condição> ``.
- **CA-6** — Dado `.codeflow/checkpoints/fase-ativa` com o comando do critério, quando o `fim-de-fase.sh` roda, então executa o critério e o L0 do `## Gate` (se houver), grava `.codeflow/checkpoints/fim-de-fase-<id>.log` e sai 0 (verde) ou 1 (vermelho); argumento inválido sai 3, erro de execução sai 2.
- **CA-7** — Dado o modo `--hook` (Stop hook), quando o JSON do stdin traz `"stop_hook_active": true`, ou não há `fase-ativa`, ou há erro de execução, então sai 0 sem prender o agente; com o gate vermelho, sai 2 com o fim do log no stderr. O JSON é lido com `grep`, sem ferramenta fora de §0.9.
- **CA-8** — Dado um EXECUCAO novo, então o frontmatter traz `base` (ramo remoto ou sha de onde a fase/mudança partiu) e pode omitir `sha_inicial`, `sha_final` e `range`; o avaliador e o revisor calculam o diff por `git merge-base <base> HEAD` e conferem `git log --oneline` desse intervalo contra a lista de commits do relatório; o `range_avaliado`/`range_revisado` passa a ser esse intervalo.
- **CA-9** — Dado um EXECUCAO antigo com `sha_inicial`, `sha_final` e `range` e sem `base`, quando avaliado, então continua válido e o avaliador usa o `range` quando o `sha_final` é ancestral do HEAD.
- **CA-10** — Dado o fim de uma fase ou mudança, então o relatório vai no último commit (junto do código ou logo depois), nenhum commit só para acertar sha ou range, o corpo tem até 60 linhas fora as saídas, cada saída real são as últimas 20 linhas mais o código de saída (a inteira no log de `checkpoints/`), e a lista de arquivos vem de `git diff --stat`; artefato antigo maior continua válido.
- **CA-11** — Dado o fechamento de uma spec ou de uma mudança, então o documento vivo (`CLAUDE.md`, `AGENTS.md`, README) recebe no máximo o estado atual e um ponteiro para a spec ou o plano, nunca o histórico dela.
- **CA-12** — Dado o gate `test` do manifest, então nenhuma spec real muda de código de saída entre `origin/main` e o ramo, e o `run-testes.sh` passa, incluindo o caso de uma spec antiga (critério em prosa) que sai 0 com o aviso e o de uma spec malformada que segue saindo 1.
- **CA-13** — Dado `check-commits.sh <base>` num repositório git temporário, então reprova (1) assunto acima de 72 caracteres ou fora de Conventional Commits, ramo `bug/*`/`melhoria/*`/`chore/*` sem nenhum commit com `Tamanho: P|M|G`, e commit "acerta os sha"; aprova (0) o intervalo limpo; sem argumento sai 3. Não escreve nada.
- **CA-14** — Dado `check-contexto.sh` com `HOME` temporário, então reprova (1) cada teto estourado (`CLAUDE.md` > 8.000, `CLAUDE.md` ≠ `AGENTS.md` quando ele existe, `MEMORY.md` do projeto > 5.000, INDEX > 3.000, constitution > 8.000, manifest > 12.000, `## Comandos de validação` > 4.000), só avisa (`⚠`) `SPEC_*.md` ativo > 60.000, aceita tetos por argumento e não escreve nada.
- **CA-15** — Dado o catálogo, então `SPEC.md` §2.2 lista os três scripts novos, a pasta de testes e `templates/hooks/`, §3.5 foi conferida (nenhum workflow novo), o `README.md` cita os scripts e o molde, e cada arquivo tocado tem `versão` e `atualizado` novos; o gate `check` sai verde.

## 6. Etapas

<!-- Média: 4 etapas, na ordem; cada uma termina verde e commitada e não depende
     de etapa posterior. O frontmatter dos itens tocados sobe uma vez, na Etapa 4,
     para não bumpar o mesmo arquivo em várias etapas (decisão delegada 2). -->

### Etapa 1 — Esteira em camadas (PR-B)
- **Faz:** `ARTIFACTS_SPEC.md` §2.3.4 ganha a seção opcional `## Gate` (tabela L0/L1/L2, `[—]`, "L2 nunca some, só muda de hora", com `## Gate` o `## CI` diz qual camada o CI roda) e, num só lugar, quem roda cada camada; §2.3.5 ganha o exemplo; §2.3.6 a regra "se há `## Gate`, L1 tem comando"; §2.3.7 o anti-padrão do teto de 4.000 caracteres (aviso; o check chega na Etapa 4). `SPEC.md` §3.10 ganha uma implicação. Os seis workflows de validação citam §2.3.4 em um bullet cada, e "CI verde" vira "gate de merge declarado no manifest verde". `discover` 3b e `bootstrap` 4b ganham o `## Gate` opcional. O manifest deste repositório ganha o seu `## Gate`. Nasce a decision.
- **Arquivos:** `framework/core/ARTIFACTS_SPEC.md`, `framework/core/SPEC.md`, os workflows `execute-spec-phase`, `implement-change`, `bugfix`, `evaluate-spec-phase`, `review-change`, `double-check`, `framework/meta/discover/SKILL.md`, `framework/meta/bootstrap/SKILL.md`, `.codeflow/manifest.md`, `.codeflow/decisions/2026-11-05-gate-e-registro.md`.
- **Testes:** framework de texto: `grep -n 'CI verde'` nos seis workflows só no trecho "sem `## Gate`"; `grep -c '§2.3.4'` ≥ 1 em cada um; a seção `## Gate` do manifest daqui lida pela tabela (três linhas L0–L2).
- **Cobre:** CA-1, CA-2, CA-3 (texto)
- **Gate:** bloco `lint` do `.codeflow/manifest.md`

### Etapa 2 — Fim de fase executável (PR-D)
- **Faz:** molde `SPEC_TEMPLATE.md` e `create-spec` Fase 4 com o critério em comando; §2.8.3 e §2.8.6 (regra nova, só aviso); `run-structural.sh` imprime o `⚠` por fase sem comando (bullet ausente também avisa) antes da linha final, sem mudar o `exit`. Nasce `fim-de-fase.sh` (formato `chave=valor` de `fase-ativa`: `spec`, `fase`, `criterio`; L0 extraído da linha `L0` do `## Gate`, primeiro trecho entre crases da coluna Comando; modo `--hook` como no CA-7). Nascem `templates/hooks/stop-fim-de-fase.json` (comando com `--hook`, timeout 600 s) e o `README.md` dos hooks (como ligar e o `/goal` opcional). `execute-spec-phase` grava `fase-ativa` no Passo 3, roda o script no Passo 5, cola o log no Passo 7 e apaga `fase-ativa` no fim; `implement-change` Passo 3 pode fazer o mesmo com o gate da etapa. Nasce `scripts/testes/run-testes.sh` com os casos de `run-structural.sh` e `fim-de-fase.sh`; o manifest chama o `run-testes.sh` no `test` e cobre `scripts/testes/*.sh` no `lint`; `validation_hash` e `last_validated` recalculados.
- **Arquivos:** `framework/library/templates/specs/SPEC_TEMPLATE.md`, `framework/library/workflows/create-spec.md`, `framework/core/ARTIFACTS_SPEC.md`, `framework/core/scripts/run-structural.sh`, `framework/core/scripts/fim-de-fase.sh`, `framework/library/templates/hooks/`, `framework/library/workflows/execute-spec-phase.md`, `framework/library/workflows/implement-change.md`, `framework/core/scripts/testes/`, `.codeflow/manifest.md`.
- **Testes (nascem vermelhos):** spec antiga (critério em prosa, 3 fases válidas) → sai 0 e imprime 3 `⚠`; spec nova (critério com comando) → sai 0 sem `⚠`; spec malformada (ciclo) → sai 1 como em `origin/main`; `fim-de-fase.sh` sem `fase-ativa` → 0; critério `true` → 0 e log gravado; critério `false` → 1, e em `--hook` → 2 com o log no stderr; stdin com `"stop_hook_active": true` → 0; argumento desconhecido → 3.
- **Cobre:** CA-4, CA-5, CA-6, CA-7, CA-12
- **Gate:** blocos `lint` e `test` do `.codeflow/manifest.md`

### Etapa 3 — Registro mínimo (PR-E1, PR-E2 e fechamento enxuto)
- **Faz:** §2.9.3 ganha `base` e torna `sha_inicial`/`sha_final`/`range` opcionais (obrigatório: `base`, ou o trio antigo); §2.9.6 regra 1 e 5 passam a valer "quando presentes"; §2.9.1 e §2.10.1 trocam "commit separado em cima de `sha_final`" por "no último commit da fase" e a ancestralidade por `merge-base` + lista de commits, mantendo o caminho do `range` antigo; §2.10.3 e §2.10.6: `range_avaliado` = `<merge-base>..<HEAD auditado>`; corpo até 60 linhas fora as saídas, saída real = últimas 20 linhas + código de saída, arquivos por `git diff --stat`. Moldes de specs e de changes no mesmo formato. `execute-spec-phase` (Passos 3, 6, 7), `evaluate-spec-phase` (Passo 2), `implement-change` (Passos 1 e 5) e `review-change` (Passo 1) seguem o contrato. Fechamento enxuto: linha 6 do Passo 2 do `execute-spec-phase` e Passo 5 do `implement-change` (CA-11).
- **Arquivos:** `framework/core/ARTIFACTS_SPEC.md`, `framework/library/templates/specs/TEMPLATE-EXECUCAO.md`, `TEMPLATE-AVALIACAO.md`, `framework/library/templates/changes/EXECUCAO.md`, `REVISAO.md`, os workflows `execute-spec-phase`, `evaluate-spec-phase`, `implement-change`, `review-change`.
- **Testes:** `grep` de "commit separado" e de "acerta" sem ocorrência normativa; o comando de diff citado roda num repo temporário e devolve só os commits do intervalo; um EXECUCAO antigo do próprio repositório (`.codeflow/changes/aceleracao-do-ciclo/EXECUCAO.md`) segue atendendo às regras de §2.9.6 relidas.
- **Cobre:** CA-8, CA-9, CA-10, CA-11
- **Gate:** bloco `lint` do `.codeflow/manifest.md`

### Etapa 4 — Checagens por script e catálogo (PR-E3 e PR-B3)
- **Faz:** nascem `check-commits.sh` e `check-contexto.sh`, somente leitura, saídas 0–3, tetos por argumento no segundo (`MEMORY.md` em `~/.claude/projects/<caminho com ->/memory/`, ausente = pula); casos no `run-testes.sh`; `change-sizing` §5 cita o `check-commits.sh`; §2.3.7 cita o `check-contexto.sh`; o `lint` do manifest daqui chama os dois (`check-commits.sh origin/main`). Paga o catálogo: `SPEC.md` §2.2 e conferência de §3.5, `README.md`, a linha "Contrato normativo" do manifest, e `versão`/`atualizado` de todo item tocado nas quatro etapas (`ARTIFACTS_SPEC.md` 2.6, `SPEC.md` 3.5).
- **Arquivos:** `framework/core/scripts/check-commits.sh`, `framework/core/scripts/check-contexto.sh`, `framework/core/scripts/testes/`, `framework/library/skills/change-sizing/SKILL.md`, `framework/core/ARTIFACTS_SPEC.md`, `framework/core/SPEC.md`, `README.md`, `.codeflow/manifest.md` e o frontmatter dos itens tocados.
- **Testes (nascem vermelhos):** repo git temporário com um commit de assunto de 80 caracteres → 1; ramo `bug/x` sem `Tamanho:` → 1, com `Tamanho: P` → 0; commit "acerta os sha" → 1; sem argumento → 3; `HOME` temporário com `CLAUDE.md` de 8.001 caracteres → 1, `AGENTS.md` diferente → 1, `MEMORY.md` de 5.001 → 1, seção de comandos de 4.001 → 1, `SPEC_*.md` ativo de 60.001 → 0 com `⚠`; teto por argumento muda o veredito; `git status --porcelain` vazio depois de cada script.
- **Cobre:** CA-3 (check), CA-13, CA-14, CA-15, CA-12
- **Gate:** `check` do `.codeflow/manifest.md` (lint, test, security)

## 7. Riscos e como desfazer

- **Projeto declara L1 fraco demais.** O texto de §2.3.4 diz que L2 só muda de hora; a revisão confere que a regra está lá.
- **Hook lento ou com falso vermelho prende o agente.** O hook roda só o critério e o L0, o timeout fica acima do tempo-alvo, e `stop_hook_active`, ausência de `fase-ativa` e erro de execução saem 0.
- **`base` errada infla o diff.** O avaliador confere `git log --oneline <merge-base>..HEAD` contra a lista do relatório; fase que segue outra no mesmo ramo usa como `base` o sha da ponta no início.
- **Palavras do grep de stack nos scripts.** O `lint` reprova `jq`, `python`, `node`, `go` como palavra inteira em `framework/core/scripts/*.sh`, até em comentário; os scripts novos não as escrevem.
- **Conflito com `contexto-e-papeis`.** Quatro workflows são tocados pelos dois ramos; aqui, um bullet por passo citado, nunca reescrita de parágrafo. O merge de `origin/main` no ramo (nunca rebase) resolve.
- **Desfazer:** `git revert` dos commits de etapa; nenhum artefato de projeto é reescrito, e sem `## Gate`/`fase-ativa`/hook nada muda.

**Decisões pedidas ao orquestrador** (opção conservadora já no plano; alternativa descartada entre parênteses):
1. O `/goal` opcional (D3) mora no `templates/hooks/README.md`; o `DESPACHO.md` do PR-C passa a citá-lo depois (criar `templates/orquestracao/` aqui — conflitaria com o PR-C).
2. Corte 36 não tem superfície no framework e fica para os workflows de projeto (inventar um passo de congelamento no `create-spec`).
3. `fim-de-fase.sh --hook` sai 2 no vermelho pelo protocolo do Stop hook e 0 no erro de execução, para não prender o agente; fora do hook, as saídas seguem §0.7. A exceção fica na decision (sair 2 no erro de execução também, o que prenderia o agente por defeito de ambiente).
4. "Nenhum `--no-verify`" sai do `check-commits.sh` e o molde de `commit-msg` fica fora (conferir por heurística de mensagem, sem garantia).
5. AVALIACAO e REVISAO mantêm `range_avaliado`/`range_revisado`, agora calculados da `base`, sem campo novo (trocar por `base` + `head_avaliado`).
6. Os testes dos scripts moram em `framework/core/scripts/testes/` e o gate `test` os chama (colocar os casos no bloco do manifest, o que estouraria o teto de 4.000 caracteres da própria seção).

## 8. Como a revisão vai provar

- Ler o diff contra os CA e o mapa da §4: arquivo fora do mapa é achado; nos quatro workflows partilhados com o ramo paralelo, só os bullets citados.
- Rodar o gate `check` do manifest (o `test` compara o `run-structural.sh` de `origin/main` e do ramo sobre as specs reais e roda o `run-testes.sh`).
- Rodar `bash framework/core/scripts/run-structural.sh` numa spec real antiga e conferir o `⚠` e o código de saída igual ao de `origin/main`.
- Conferir que os scripts não escrevem: `git status --porcelain` vazio depois de `check-commits.sh origin/main` e `check-contexto.sh`.
- Conferir o core intocado: `git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md framework/core/EVOLUTION.md` vazio.
