---
versão: 1.0
status: experimental
atualizado: 2026-10-02
granularidade: detalhado
gera_decision: no
usa_checkpoints: yes
politica_falhas: padrão
---

# Workflow: orquestrar-auditoria

## Princípio guia

A auditoria só aponta: mede o framework contra as próprias regras e colhe nos projetos o que se repetiu,
e entrega uma lista confirmada à trilha de Evolução. Não corrige, não decide e não muda o framework.

## Quando usar

No workspace **Codeflow · Auditoria** do Maestri (worktree `~/Projetos/codeflow-wt/auditoria`), no
terminal com o **modo Maestro ligado**, **sob demanda do dono**. Este chat vira o **Maestro da
auditoria**: combina com o dono as dimensões e o alvo, abre **um auditor por dimensão, em paralelo**,
cada um num terminal limpo, e depois **um Verificador** em terminal limpo que confirma os candidatos e
consolida. A auditoria cobre duas frentes (operação, item 1): a **coerência** do framework
consigo mesmo e a **colheita** nos projetos que o usam.

```
dono + Maestro -> Auditores em paralelo -> Verificador -> DONO APROVA -> PR para main -> Revisor
  (dimensões       /audit <dimensão>        /verify-audit   o consolidado  (só documentos)  limpo
   e alvo)                                  + validação                                    |
                                            do manifest                     merge --merge <-+
                                                                                 |
                                                     lista para Codeflow · Evolução
```

### Pré-requisitos

- **Situar-se:** `git rev-parse --show-toplevel` tem de ser `~/Projetos/codeflow-wt/auditoria`, e
  `maestri list` tem de mostrar `maestro: true`. Se não, parar e avisar o dono.
- **Decisions:** consultar `.codeflow/decisions/INDEX.md` e carregar as ATIVAS — são régua da rodada.
- **Quadro:** se `maestri list` mostrar uma nota **Quadro** conectada, mantê-la em dia — as dimensões,
  o estado de cada auditor, o placar. Nunca colar segredo nem nome de cliente ou de pessoa.
- **Varredura de nome** (repositório público, operação, item 4): no PR, é a do gate `security` do
  `.codeflow/manifest.md` (linhas acrescentadas, palavra inteira, só nome de arquivo), dentro do
  `check`. Nos laudos ainda não commitados da Fase 3, onde o arquivo inteiro é novo, a mesma lista com
  `-w`: `grep -rilwFf ~/.config/codeflow/nomes-proibidos.txt <pasta da rodada>`, saída vazia. Lista
  ausente → `PARADO` ao dono.
- **Plano da trilha**, fora do repositório:
  `~/.config/codeflow/orquestracao/auditoria/PLANO-<AAAA-MM-DD>-<slug>.md` (`mkdir -p` na pasta,
  `chmod 600` no arquivo), com as tabelas **Decisões** (`# · momento · decisão · por quê`) e **Diário**
  (`hora · fase · resultado`).

### As dimensões e a régua do framework

Vão nas decisões delegadas de cada auditor; a régua do framework vence a genérica da skill.

| Dimensão | Régua | Ferramenta (só leitura) |
| --- | --- | --- |
| `living-docs` | o catálogo (`SPEC.md` §2.2 e §3.5, `README.md`, `glossary.md`) contra `git ls-files framework`; o frontmatter (`versão`, `atualizado`) contra o `git log` de cada arquivo; o `INDEX.md` e o `manifest.md` deste repositório; os adaptadores instalados contra os workflows e meta-skills universais | `git ls-files`, `git log -1 --format=%cs -- <arquivo>`, `ls` dos diretórios de adaptador |
| `code-quality` | os scripts (`install.sh`, `setup-*.sh`, `framework/core/scripts/*.sh`): stack de `ARTIFACTS_SPEC.md` §0.9 e Parte 3 regra 27, saídas de §0.7, idempotência, respeito ao `HOME` | `bash -n`, `grep` de ferramenta proibida; `shellcheck` se existir, senão `[—]` |
| `conformidade` | dimensão própria do framework, sem skill universal: cada arquivo de `framework/` contra o schema do seu tipo (`ARTIFACTS_SPEC.md` Parte 1, regras §x.6) e as regras transversais da Parte 3; e o próprio `ARTIFACTS_SPEC.md` contra si mesmo | `grep`, `wc -l`, contagem de seções e de passos |
| `colheita` | dimensão própria do framework, sem skill universal: os `.codeflow/workflows/`, `.codeflow/skills/` e `.codeflow/rules/` dos projetos que usam o framework, lidos em **somente leitura**; candidato é o item que existe, com a mesma função, em **dois ou mais** projetos (critério de promoção do `framework/core/EVOLUTION.md`) | `ls`, `diff`, `grep` |

- `conformidade` e `colheita` não têm `audit-<dimensão>` em `framework/library/skills/`: o `/audit`
  roda com a régua inteira na decisão delegada (decisão 3 do bloco de despacho), no molde `LAUDO.md`,
  e grava `LAUDO-conformidade.md` e `LAUDO-colheita.md`.
- Sem `architecture`, `tests`, `data-privacy`, `dependencies`, `interface` nem `/security-sweep`: o
  framework é texto normativo e cinco scripts bash, sem app, banco nem interface; o `gitleaks git` do
  manifest cobre segredo.

### O despacho

- **Regras que vão em todo despacho** (copiar verbatim no bloco de despacho):
  1. Ramo `chore/auditoria-<AAAA-MM-DD>-<slug>` (operação, item 2), pasta
     `~/Projetos/codeflow-wt/auditoria`.
     Sem push, sem PR, sem merge; nunca trocar de ramo; nunca `git stash`; nunca rebase.
  2. **Auditor não commita** (`Commitar ao fim: não`): vários auditores no mesmo checkout não podem
     commitar ao mesmo tempo — os laudos são do Maestro; o consolidado, do Verificador. Quem commita:
     Conventional Commits em pt-BR, assunto até 72 caracteres, escopo entre parênteses, trailer
     `Co-Authored-By` (operação, item 5); nunca `--no-verify`; `git add` só pelos caminhos tocados.
  3. Nunca perguntar ao dono: seguir a skill `modo-delegado`.
  4. Somente leitura fora da pasta da rodada: nunca escrever em `~/Projetos/codeflow`, em
     `~/.codeflow/`, nos diretórios de adaptador nem em outro projeto. Nos projetos colhidos, só
     `ls`, `cat`, `grep`, `diff` e `git log`; nunca `git switch`, `fetch`, `pull` nem comando que mude
     estado. Os arquivos do framework se leem **da worktree**, nunca de `~/.codeflow/`.
  5. O repositório é **público** (operação, item 4): laudo, consolidado, Quadro e retorno não levam
     nome de cliente, nome de pessoa, nome de projeto, dado real nem segredo. A colheita cita o
     projeto **pelo pseudônimo** da decisão delegada (`projeto-A`, `projeto-B`...) e o caminho dentro
     do `.codeflow/` dele (`projeto-A:.codeflow/workflows/<arquivo>.md:<linha>`), com a função do item;
     **nunca** a pasta real nem o conteúdo de domínio do projeto.
  6. O auditor roda só leitura e nunca script de setup nem `install.sh`; o gate `check` do
     manifest é do Verificador, uma vez.
  7. Retorno em no máximo 15 linhas; o detalhe fica em
     `.codeflow/checkpoints/relatorio-<workflow>-<dimensão>-<AAAAMMDD-HHMM>.md` (a dimensão no nome:
     auditores em paralelo na mesma pasta não podem colidir no mesmo minuto).

- **Bloco de despacho:**

  ```
  MODO DELEGADO — antes de tudo, leia e siga ~/.codeflow/framework/library/skills/modo-delegado/SKILL.md.
  Orquestrador: <nome do Maestro em `maestri list`>
  Pasta: ~/Projetos/codeflow-wt/auditoria — comece com `cd ~/Projetos/codeflow-wt/auditoria`.
  Ramo: chore/auditoria-<AAAA-MM-DD>-<slug> (já aberto; não troque).
  Workflow: /audit <dimensão> — alvo <alvo>, slug <slug>; pasta .codeflow/audits/<AAAA-MM-DD>-<slug>/
  Decisões delegadas:
    1. Régua: <a linha da dimensão na tabela do orquestrar-auditoria>.
    2. <o que fica fora do alvo>
    3. (só conformidade e colheita) Dimensão sem skill universal: a régua da decisão 1 substitui
       a skill audit-<dimensão>; o molde é o LAUDO.md e o arquivo, LAUDO-<dimensão>.md.
    4. (só colheita) Pseudônimos: projeto-A = <pasta>, projeto-B = <pasta>... — a pasta real
       serve só para ler; no laudo e no retorno vai o pseudônimo.
  Regras do projeto: <as sete acima, verbatim>
  Commitar ao fim: não.
  ```

- Recruta: `maestri recruit "<codinome>" --preset "<preset do workspace>"`, **sem `--role`** (a role
  muda o diretório do recruta), ou um existente depois de `maestri ask "<nome>" --raw "/clear\n"`.

## Quando NÃO usar

- Para corrigir o que a auditoria achou, ou para promover um item colhido → `/orquestrar-evolucao`, no
  workspace Codeflow · Evolução.
- Para revisar um PR ou uma mudança → a revisão da Fase 5 do `orquestrar-evolucao`.
- Para auditar o **código de um projeto consumidor** → a trilha de auditoria daquele projeto. A
  colheita daqui só lê os artefatos do codeflow que ele tem.
- Para ensaiar um workflow do framework em uso real → é nas trilhas dos projetos, depois do merge.

## LEIA TAMBÉM

- `~/.codeflow/framework/core/constitution.md` · `.codeflow/INDEX.md` · `.codeflow/constitution.md` ·
  `.codeflow/manifest.md` (a validação que o Verificador e o Revisor rodam) ·
  `.codeflow/decisions/INDEX.md`
- `.codeflow/decisions/2026-10-02-operacao-por-trilhas.md` — a operação por trilhas, que este roteiro
  cita como "operação, item N" (trilhas, ramo e merge, deploy, repositório público, atribuição, gate
  duro do core, catálogo, mudança grande).
- `framework/core/ARTIFACTS_SPEC.md` (Parte 1, regras §x.6, e Parte 3) e `framework/core/EVOLUTION.md`
  (o critério de promoção) — a régua de `conformidade` e de `colheita`.
- `~/.codeflow/framework/library/templates/audits/README.md` — as dimensões, o fluxo e os moldes
  (`LAUDO.md`, `CONSOLIDADO.md`).
- `.codeflow/workflows/orquestrar-evolucao.md` — o destino das seções 3 e 4 do consolidado.
- `~/.codeflow/framework/library/skills/modo-delegado/SKILL.md` e os workflows `audit` e
  `verify-audit` — **quem os lê é o recruta**; o Maestro lê só o bastante para despachar.

## Estrutura do workflow

Seis fases: combinar, preparar, auditar, verificar, aprovar e entregar. O dono fala na primeira e na
quinta; o resto corre em terminais próprios.

## Retomada

Ao abrir, procurar `.codeflow/checkpoints/orquestrar-auditoria-*.md`. Se houver um `em_progresso`,
mostrar ao dono a fase em pausa e perguntar "retomar ou começar do zero?"; retomar lê só o mais recente.

## Fase 1 — Combinar a auditoria com o dono

### Objetivo
Fixar dimensões, alvo e slug da rodada, e a régua de cada auditor.

### Ações
- Quais dimensões (as quatro, ou as que o dono escolher); o alvo (o repositório inteiro, ou caminhos
  como `framework/library/workflows/`); para `colheita`, quais projetos, cada um com um pseudônimo
  estável (`projeto-A`, `projeto-B`...) — o mapa pseudônimo → pasta fica **só no plano da trilha**; o
  `<slug>` (ex.: `geral`, `catalogo`). Data canônica: `date +%F`.
- **Primeira rodada:** a lista de inconsistências dos *Próximos passos* da decision da operação
  (`.codeflow/decisions/2026-10-02-operacao-por-trilhas.md`; seis itens: catálogo
  defasado, frontmatter que não acompanha a edição, o core mudado sem o regime do EVOLUTION, a
  contradição entre §0.4 e §3.3 do `ARTIFACTS_SPEC.md`, adaptadores dessincronizados, moldes de spec
  copiados que divergem) entra como **candidatos de partida** nas dimensões `living-docs` e
  `conformidade` — o auditor os reconfirma contra o `HEAD`, como qualquer outro.
- Montar com o dono as **decisões delegadas** de cada auditor (a linha da tabela, o que fica fora) e
  **aguardar confirmação** antes de abrir o ramo.

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-auditoria-<timestamp>.md` (schema `ARTIFACTS_SPEC.md` §2.7)
com as dimensões, o alvo e o slug; registrar no plano da trilha e no Quadro.

## Fase 2 — Abrir o ramo e preparar a pasta

### Objetivo
Ramo da rodada nascido de `origin/main` e a pasta da rodada pronta.

### Ações
- `git fetch origin && git switch -c chore/auditoria-<AAAA-MM-DD>-<slug> origin/main`. A worktree
  repousa em `HEAD` destacado: nunca `git switch main`. A pasta da rodada é
  `.codeflow/audits/<AAAA-MM-DD>-<slug>/`.
- Conferir a árvore limpa (`git status --short` vazio) e que `.codeflow/checkpoints/` é ignorado
  (`git check-ignore -q .codeflow/checkpoints/x.md`).

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-auditoria-<timestamp>.md` com o ramo e o `sha` de partida.

## Fase 3 — Auditores em paralelo e os laudos

### Objetivo
Um laudo por dimensão, de terminais independentes, commitados juntos pelo Maestro.

### Ações
- Um recruta **por dimensão**, cada um em terminal limpo, com o bloco de despacho e a régua da tabela.
  Disparar todos juntos com `maestri ask --batch`, **em segundo plano**. Retornos: o número de
  candidatos por severidade, ou `PARADO` (decidir se couber na delegação; senão levar ao dono).
- Com todos de volta, conferir que cada `LAUDO-<dimensão>.md` existe na pasta da rodada e rodar sobre
  ela a **varredura de nome** (Pré-requisitos) e `grep -rlE '~/Projetos/|/h[o]me/|/U[s]ers/'` (caminho real
  de projeto ou de máquina). Arquivo listado é aberto e o documento ajustado à mão antes do commit.
- `git add .codeflow/audits/<AAAA-MM-DD>-<slug>/` — só a pasta da rodada, `git status` antes — e
  commitar todos juntos: `docs(auditoria): laudos da auditoria <AAAA-MM-DD>-<slug>`. Dispensar os
  auditores (`maestri dismiss`).

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-auditoria-<timestamp>.md` com o `sha` dos laudos e o placar
bruto por dimensão.

## Fase 4 — Verificar em terminal limpo

### Objetivo
Confirmar cada candidato, consolidar e medir a linha de base do framework.

### Ações
- Um terminal que **não foi auditor** roda `/verify-audit` sobre a pasta, com o bloco de despacho e
  `Commitar ao fim: sim` (a regra 6 vale ao contrário: a validação é dele). Ele confirma cada
  candidato, deduplica, dá severidade e destino, mede a taxa de falso positivo e roda **o gate
  `check` do `.codeflow/manifest.md`**, uma vez, como linha de base, com a saída real no relatório.
- Destino: as seções 3 (bug) e 4 (melhoria) do consolidado vão **ambas** à trilha de Evolução, que
  não separa bug de mudança. Item que toca o core leva a marca **gate duro** (operação, item 6); item
  de `colheita` leva os pseudônimos dos projetos em que foi visto e o que falta do critério do
  EVOLUTION.

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-auditoria-<timestamp>.md` com o `sha` do consolidado, o placar
e a taxa de falso positivo.

## Fase 5 — Aprovação do dono

### Objetivo
O dono aprova o consolidado que vai à trilha de Evolução.

### Ações
- Apresentar ao dono o placar, a taxa de falso positivo, o que mais pesa, os itens de gate duro e os
  candidatos a promoção, e **aguardar confirmação**. O dono pode tirar itens ou mudar destino; o
  Maestro ajusta o consolidado e commita só isso
  (`docs(auditoria): ajusta o consolidado <AAAA-MM-DD>-<slug>`), registrando no plano.

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-auditoria-<timestamp>.md` com a aprovação e os ajustes.

## Fase 6 — Geração de artefatos: PR, merge e entrega da lista

### Objetivo
Levar laudos e consolidado à `main` por PR só de documentos e entregar a lista à Evolução.

### Ações
- `git fetch origin`; se o `origin/main` andou: `git merge origin/main -m "chore(auditoria): traz o
  origin/main" -m "Ramo: chore/auditoria-<AAAA-MM-DD>-<slug>"` — **nunca rebase**.
- `git push -u origin chore/auditoria-<AAAA-MM-DD>-<slug>` e
  `gh pr create --base main --title "docs(auditoria): auditoria <AAAA-MM-DD>-<slug>" --body-file
  ~/.config/codeflow/orquestracao/auditoria/PR-<AAAA-MM-DD>-<slug>.md`, só com documentos da pasta da
  rodada. Corpo (escrito fora do repositório): contexto, placar, para onde vai a lista, rodapé de
  atribuição (operação, item 5).
- **Revisor** em terminal limpo (nunca auditor nem o Verificador), `Commitar ao fim: não`, sobre o HEAD
  que vai ao merge: o **escopo do diff** (`git diff --name-only origin/main...HEAD` lista só `.md` de
  `.codeflow/audits/<AAAA-MM-DD>-<slug>/`), o **gate `check`** do manifest, cujo `security` faz a
  varredura de nome, com saída real.
- Revisor `✓` → `gh pr merge <n> --merge` (operação, item 2) — **nunca squash** — e
  `git push origin --delete chore/auditoria-<AAAA-MM-DD>-<slug>`. Revisor `✗` → o Maestro corrige
  só o documento da pasta da rodada, e um Revisor limpo de novo; **teto: duas reprovações** — na
  terceira, o dono decide.
- **A principal acompanha:** com `git -C ~/Projetos/codeflow branch --show-current` = `main` e
  `status --porcelain` vazio, `git -C ~/Projetos/codeflow pull --ff-only`. Sem pós-passos e sem o aviso
  de deploy aos projetos: o PR só de documentos de `.codeflow/` não muda `framework/` (conferir com
  `git diff --stat`), e o framework que eles leem é o mesmo. Principal fora de `main` ou suja → avisar
  o dono, sem tocar nela.
- **Entregar:** avisar o dono de que o consolidado vai ao workspace **Codeflow · Evolução**, item a
  item, por `/orquestrar-evolucao` com o caminho
  `.codeflow/audits/<AAAA-MM-DD>-<slug>/CONSOLIDADO.md` e o número do item.
- **Devolver a pasta:** `git fetch origin && git switch --detach origin/main && git branch -d
  chore/auditoria-<AAAA-MM-DD>-<slug>`. Apagar os checkpoints da rodada; dispensar o Verificador e o
  Revisor; limpar o Quadro.

### Checkpoint
Marcar `.codeflow/checkpoints/orquestrar-auditoria-<timestamp>.md` como `concluído` e apagá-lo (§2.7:
efêmero). O plano da trilha guarda o diário.

## Proibições durante este workflow

- O Maestro não audita, não verifica e não corrige o framework: cada passo é um terminal; ele só ajusta
  documento da pasta da rodada (laudo na varredura, consolidado a pedido do dono). Sem subagente.
- Não deixar um auditor verificar o próprio laudo, nem o Verificador revisar o PR.
- Auditor não commita e não roda script de setup, `install.sh` nem o gate `check`.
- Não alterar arquivo de `framework/`, `install.sh` nem `setup-*.sh`: o PR da trilha é só de documentos
  da pasta da rodada. Não abrir item na trilha de Evolução: quem decide o que entra é o dono.
- Não escrever em `~/Projetos/codeflow` (salvo o `git pull --ff-only` da Fase 6), em `~/.codeflow/`,
  nos diretórios de adaptador nem nos projetos colhidos.
- Nunca squash; nunca rebase; nunca `--no-verify`; nunca `git stash`; nunca push direto na `main`.
- Não colar segredo, nome de cliente, nome de pessoa, dado real nem conteúdo de domínio de projeto no
  canvas, nos despachos, no plano, nos laudos ou no PR.

## Definition of Done

- [ ] Dimensões, alvo e slug decididos com o dono; na primeira rodada, as seis inconsistências como
      candidatos de partida.
- [ ] Ramo `chore/auditoria-<AAAA-MM-DD>-<slug>` nascido de `origin/main`.
- [ ] Um auditor por dimensão, em terminais limpos e em paralelo; nenhum commitou nem escreveu fora da
      pasta da rodada; laudos commitados juntos pelo Maestro, sem nome de cliente nem de pessoa.
- [ ] Verificador em terminal limpo: cada candidato com veredito e motivo; consolidado com placar e
      taxa de falso positivo; o gate `check` do manifest como linha de base, com saída real; colheita
      só com pseudônimos.
- [ ] Consolidado aprovado pelo dono.
- [ ] PR só de documentos para `main`, revisado em terminal limpo (escopo, gate `check`, varredura
      de nome), mergeado com `--merge`; ramo remoto apagado; a principal acompanhou por `pull --ff-only`.
- [ ] O dono sabe que a lista vai à trilha de Evolução; nenhum arquivo do framework alterado; worktree
      de volta a `origin/main` destacado; checkpoints apagados; plano com as decisões e o diário.

## Resumo final

Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4. Ao dono, curto: as dimensões auditadas, o placar
e a taxa de falso positivo, os três achados que mais pesam, os itens de gate duro, os candidatos a
promoção com os pseudônimos dos projetos em que apareceram, o PR e o `sha` do merge, e as decisões
tomadas por delegação (uma linha cada).
