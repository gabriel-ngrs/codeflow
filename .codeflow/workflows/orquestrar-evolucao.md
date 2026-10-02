---
versão: 1.0
status: experimental
atualizado: 2026-10-02
granularidade: detalhado
gera_decision: auto
usa_checkpoints: yes
politica_falhas: padrão
---

# Workflow: orquestrar-evolucao

## Princípio guia

A pasta principal `~/Projetos/codeflow` é o framework em produção: o que chega nela vale na mesma hora
para todos os projetos. Por isso toda mudança nasce num ramo da worktree da trilha, passa por revisão
em terminal limpo, entra por merge e só então chega à principal, por `git pull --ff-only`.

## Quando usar

No workspace **Codeflow · Evolução** do Maestri (worktree `~/Projetos/codeflow-wt/evolucao`), no
terminal com o **modo Maestro ligado**. Este chat vira o **Maestro da evolução do framework**: tria o
pedido com o dono e conduz, um terminal por passo, **qualquer** mudança no framework (bug, melhoria,
feature, workflow ou skill novos) até o merge na `main` e o deploy na pasta principal:

```
dono + Maestro -> Planejador -> DONO APROVA -> Implementador -> Revisor -> PR -> merge -> deploy
  (triagem)       /plan-change   o plano       /implement-change /review-change  --merge   pull --ff-only
                  (ou relato do                (ou /bugfix)      (ou /double-check)        + pós-passos
                   bug)                                                                    + aviso
```

Argumento: o pedido (texto do dono, retorno de um Maestro de projeto, um item do consolidado da trilha
de Auditoria). Não há trilha separada de bugs, de spec nem de QA neste repositório (operação, item 1):
bug e mudança seguem por aqui; o ensaio de verdade acontece depois do merge, nas trilhas dos projetos
que consomem o framework.

### Pré-requisitos

- **Situar-se:** `git rev-parse --show-toplevel` tem de ser `~/Projetos/codeflow-wt/evolucao`, e
  `maestri list` tem de mostrar `maestro: true`. Se não, parar e avisar o dono.
- **Ensaiar na worktree não testa a worktree:** `~/.codeflow` aponta para a principal, então quem
  invoca `/bugfix` ou segue um `LEIA TAMBÉM` lê a versão **ao vivo**. O que muda se lê na worktree,
  pelo caminho relativo; script de setup se ensaia com o `HOME` temporário do manifest.
- **Decisions:** carregar as ATIVAS de `.codeflow/decisions/INDEX.md` cujas tags cruzem o pedido.
- **Quadro:** se `maestri list` mostrar uma nota **Quadro** conectada, mantê-la em dia a cada fase — o
  pedido, o caminho, a fase, quem faz o quê. Nunca colar segredo nem nome de cliente ou de pessoa.
- **Varredura de nome** (repositório público, operação, item 4): é a do gate `security` do
  `.codeflow/manifest.md` — as linhas que o ramo acrescenta, palavra inteira, contra a lista fora do
  repositório; imprime só nome de arquivo. Roda dentro do `check`; este roteiro não a repete. Lista
  ausente faz o gate falhar → `PARADO` ao dono.
- **Plano da trilha**, fora do repositório:
  `~/.config/codeflow/orquestracao/evolucao/PLANO-<AAAA-MM-DD>-<slug>.md` (`mkdir -p` na pasta,
  `chmod 600` no arquivo), com as tabelas **Decisões** (`# · momento · decisão · por quê`) e **Diário**
  (`hora · fase · resultado`).

### O despacho

- **Regras que vão em todo despacho** (copiar verbatim no bloco de despacho):
  1. Pasta `~/Projetos/codeflow-wt/evolucao`, ramo `evolucao/<slug>`. Sem push, PR nem merge; nunca
     trocar de ramo, `git stash` nem rebase; `git add` só pelos caminhos tocados.
  2. Nunca escrever em `~/Projetos/codeflow` nem em `~/.codeflow/` (é a pasta principal, ao vivo).
     Meta-skill que mande salvar em `~/.codeflow/framework/...` salva no **caminho relativo
     equivalente da worktree** (`framework/library/...`). Script de setup só com `HOME` temporário.
     `install.sh` **nunca roda na worktree** (opera no diretório corrente: escreve `.codeflow/`,
     `.gitignore` e wrappers com caminho absoluto); para ensaiá-lo, um projeto descartável dentro de
     `$T`, com `HOME="$T"`. Passo de meta-skill que mande rodar `install.sh` é pulado e declarado.
  3. Conventional Commits em pt-BR, assunto até 72 caracteres, escopo entre parênteses, corpo com o que
     muda e por quê; trailer `Co-Authored-By` (operação, item 5). Nunca `--no-verify`.
  4. Nunca perguntar ao dono: seguir a skill `modo-delegado`.
  5. Core (`framework/core/constitution.md`, `glossary.md`, `EVOLUTION.md`) não se edita: tocar um
     deles é `PARADO` (operação, item 6), salvo typo ou reformatação, que o retorno declara.
  6. Toda mudança paga o catálogo na mesma entrega (operação, item 7): `SPEC.md` §2.2 e §3.5,
     `README.md` e o frontmatter (`versão`, `atualizado`) — do item criado ou tocado; a dívida anterior
     do catálogo é item da Auditoria, não deste PR. Termo novo no
     `glossary.md` é core: vai como proposta de decision.
  7. Repositório **público** (operação, item 4): nenhum nome de cliente, de pessoa, dado real, segredo
     nem caminho absoluto de máquina em arquivo versionado.
  8. Script: só bash, coreutils, git e openssl (`ARTIFACTS_SPEC.md` §0.9); saídas 0 a 3 (§0.7).
  9. Decision gerada nasce em `.codeflow/decisions/AAAA-MM-DD-<slug>.md` **sem linha no INDEX**; a
     linha é do Maestro, na Fase 6.
  10. Retorno em no máximo 15 linhas; o detalhe fica em `.codeflow/checkpoints/`.

**Formato do bloco de despacho:**

```
MODO DELEGADO — antes de tudo, leia e siga ~/.codeflow/framework/library/skills/modo-delegado/SKILL.md.
Orquestrador: <nome do Maestro em `maestri list`>
Pasta: ~/Projetos/codeflow-wt/evolucao — comece com `cd ~/Projetos/codeflow-wt/evolucao`.
Ramo: evolucao/<slug> (já aberto; não troque).
Workflow: <comando e alvo>
Decisões delegadas:
  1. <...>
Regras do projeto: <as dez acima, verbatim>
Commitar ao fim: <sim | não>
```

Recruta: `maestri recruit "<codinome>" --preset "<preset do workspace>"`, **sem `--role`** (a role muda
o diretório do recruta), ou um existente depois de `maestri ask "<nome>" --raw "/clear\n"`. Todo
`maestri ask` de trabalho roda **em segundo plano**: o Maestro continua livre para o dono.

## Quando NÃO usar

- Fora do Maestri, ou sem o modo Maestro → os workflows do ciclo direto (`/plan-change`,
  `/implement-change`, `/review-change`, `/bugfix`), com o dono no chat, na worktree.
- Para **auditar** o framework ou colher candidatos nos projetos → `/orquestrar-auditoria`, no
  workspace Codeflow · Auditoria. Esta trilha recebe a lista dela, item a item.
- Para **adotar** mudança no core (constitution universal, glossary, EVOLUTION) → gate duro (operação,
  item 6): esta trilha só leva a proposta (Fase 1); nenhum Maestro aprova a adoção.
- Para mudança **grande** pela `change-sizing` → `PARADO` ao dono (operação, item 8); não há trilha de
  spec aqui.
- Para trabalho entre projetos, ou conversa sobre o framework sem mudança concreta → o workspace
  **Codeflow** (a pasta principal, o hub). Para várias mudanças → uma de cada vez, sem modo lote.

## LEIA TAMBÉM

- `~/.codeflow/framework/core/constitution.md` · `.codeflow/INDEX.md` · `.codeflow/constitution.md`
  (pasta principal = produção, ramos, atribuição, gate duro do core, "toda mudança paga o catálogo") ·
  `.codeflow/manifest.md` (os gates do framework — a validação que o Revisor roda) ·
  `.codeflow/decisions/INDEX.md`
- `.codeflow/decisions/2026-10-02-operacao-por-trilhas.md` — a operação por trilhas, que este roteiro
  cita como "operação, item N" (trilhas, ramo e merge, deploy, repositório público, atribuição, gate
  duro do core, catálogo, mudança grande).
- `framework/core/EVOLUTION.md` (promoção a universal, rule, meta-skill, core, anti-evolução) e
  `framework/core/ARTIFACTS_SPEC.md` (o schema de cada tipo, as regras §x.6 e a Parte 3) — lidos **da
  worktree**, não de `~/.codeflow/`.
- `~/.codeflow/framework/library/skills/change-sizing/SKILL.md` — o Maestro a usa na triagem.
- `~/.codeflow/framework/library/skills/modo-delegado/SKILL.md`, os workflows `plan-change`,
  `implement-change`, `review-change`, `bugfix` e `double-check` e as meta-skills `create-workflow` e
  `create-skill` — **quem os lê é o recruta**; o Maestro lê só o bastante para despachar.

## Estrutura do workflow

Sete fases. Os caminhos **correção** (bug) e **mudança** (melhoria, feature, artefato novo) só divergem
nas Fases 3 a 5; triagem, ramo, PR, merge e deploy são os mesmos.

## Retomada

Ao abrir, procurar `.codeflow/checkpoints/orquestrar-evolucao-*.md`. Se houver um `em_progresso`,
mostrar ao dono a fase em pausa e perguntar "retomar ou começar do zero?"; retomar lê só o mais recente.

## Fase 1 — Triagem com o dono

### Objetivo
Decidir com o dono se o pedido é desta trilha, por qual caminho segue e com que tamanho.

### Ações
- **É do framework?** Necessidade que só existe num projeto → volta à trilha daquele projeto.
- **Toca o core?** → **gate duro** (operação, item 6). Com o "sim" do dono, o único trabalho é a
  **proposta**: uma decision em `.codeflow/decisions/` com a mudança, o motivo e a data a partir da qual
  a adoção pode ocorrer (30 dias), escrita por um **Redator** na Fase 4 e levada pelas Fases 5, 6 e 7
  como PR só de documentos (a Fase 3 não se aplica).
- **Caminho:** **correção** (um protocolo leva o agente ao erro, um script falha) ou **mudança**
  (melhoria, feature, artefato novo).
- **Tamanho** pela skill `change-sizing`, sinal por sinal, com evidência. Somar a régua do framework —
  qualquer uma destas é **grande** (`PARADO` ao dono, operação, item 8):
  - muda o schema de um artefato de projeto (`ARTIFACTS_SPEC.md` Parte 2) de forma que os
    `.codeflow/` existentes deixam de valer;
  - muda a máquina de estados da fase de spec (§2.11) ou o formato que o `run-structural.sh` valida;
  - remove ou renomeia workflow, skill ou meta-skill que um projeto usa.
- **Artefato novo:** a granularidade (`SPEC.md` §4.2.2), o tipo e o destino. Universal exige o critério
  do EVOLUTION (uso real em dois projetos); sem ele, nasce no projeto que o usa, ou o dono decide
  violar a anti-evolução — e então a decision com a justificativa é obrigatória (Fase 4).
- O Maestro **propõe** caminho e tamanho, com o porquê; **o dono decide**. Fechar com ele o `<slug>`
  (kebab-case), as **decisões delegadas** e, para artefato novo, as respostas da entrevista da
  meta-skill (nome, propósito, granularidade, gatilhos, destino). Pergunta ao usuário: aguardar a
  decisão antes de seguir.

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-evolucao-<timestamp>.md` (schema `ARTIFACTS_SPEC.md` §2.7)
com o caminho, o tamanho e as decisões; registrar no plano da trilha e no Quadro.

## Fase 2 — Ramo e preparo

### Objetivo
Abrir o ramo da tarefa a partir de `origin/main`, sem tocar a principal.

### Ações
- `git fetch origin && git switch -c evolucao/<slug> origin/main` (operação, item 2). A worktree
  repousa em `HEAD` destacado: nunca `git switch main`.
- Conferir `git status --short` vazio e `git check-ignore -q .codeflow/checkpoints/x.md`.
- Correção: o **relato** em `~/.config/codeflow/orquestracao/evolucao/RELATO-<slug>.md` — sintoma, onde
  aparece (workflow, passo), reprodução e o esperado. É a entrada do Corretor e do Conferente; o resumo
  vai ao corpo do PR, sem nome de cliente nem de pessoa.

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-evolucao-<timestamp>.md` com o ramo e o `sha` de partida.

## Fase 3 — Planejar ou reproduzir

### Objetivo
Ter, antes de qualquer edição, o plano aprovado pelo dono (mudança) ou a reprodução declarada (correção).

### Ações
- **Mudança:** um **Planejador** em terminal limpo roda `/plan-change` sobre o pedido, com o slug
  `<slug>` (artefatos em `.codeflow/changes/<slug>/`), a régua de grande da Fase 1 e
  `Commitar ao fim: sim`. Os gates de cada etapa são gates do manifest. Para artefato novo, o plano
  traz a etapa que roda a meta-skill e as respostas da entrevista fechadas na Fase 1; e a etapa que
  paga o catálogo (regra 6). Se o Planejador reclassificar como grande, levar ao dono.
- Apresentar o plano ao dono em poucas linhas — objetivo, fora de escopo, critérios de aceite, etapas
  com gates, o que muda para os projetos — e **aguardar confirmação**. Ajuste pedido volta ao **mesmo**
  Planejador. Aprovado → o Maestro troca `status: aprovado`, com `aprovado_por` e `aprovado_em`, e
  commita só isso: `docs(changes): aprova o plano de <slug>`.
- **Correção:** para protocolo de texto, o gate é a **reprodução manual declarada** do `/bugfix`
  (Passo 2): o passo exato, o que o agente faz hoje e o que devia fazer. Para script, um caso que falha
  agora e passa depois. O Maestro confere que o relato tem isso antes de despachar.

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-evolucao-<timestamp>.md` com o `sha` do plano aprovado ou o
caminho do relato.

## Fase 4 — Implementar

### Objetivo
Executar o plano aprovado, ou o conserto, num terminal que não planejou.

### Ações
- **Mudança:** um **Implementador** em terminal limpo roda `/implement-change` sobre
  `.codeflow/changes/<slug>/`, com `Commitar ao fim: sim`. A etapa de artefato novo roda
  `/create-workflow` ou `/create-skill` respondendo a entrevista pelas decisões delegadas, no destino
  da regra 2. Retornos: `CONCLUÍDO`, `PRECISA DE DECISÃO`, `PARADO` (skill `modo-delegado`).
- **Correção:** um **Corretor** em terminal limpo roda `/bugfix` sobre o relato, com a reprodução
  declarada e `Commitar ao fim: sim`.
- **Proposta de core:** um **Redator** em terminal limpo escreve a decision da proposta (schema §2.5;
  o título começa por "Proposta:" e o corpo traz a data de adoção), sem linha no INDEX (regra 9), e
  commita só ela.
- `PRECISA DE DECISÃO` → ratificar ou corrigir, registrar no plano e responder ao **mesmo** recruta;
  desvio de escopo, de critério de aceite ou que acenda a régua de grande → ao dono.
- **Decision:** a que o `/implement-change` ou o `/bugfix` gerar (`gera_decision: auto`), ou a da
  exceção à anti-evolução decidida na Fase 1, nasce aqui, pelo recruta, sem linha no INDEX (regra 9).

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-evolucao-<timestamp>.md` com os `sha` das etapas.

## Fase 5 — Revisar em terminal limpo

### Objetivo
Um terminal que não viu nada julga a entrega com a validação real do framework.

### Ações
- Revisor: recruta novo, ou um anterior depois de `/clear` — **nunca** quem planejou, implementou ou
  corrigiu. Mudança → `/review-change`; correção → `/double-check` sobre o relato, com a decisão delegada "o
  relato é privado: o ledger normalizado vai para `.codeflow/checkpoints/`, nunca para
  `.codeflow/bug-batches/` nem para o commit". `Commitar ao fim: sim` (o relatório da revisão).
- A revisão confere e cola **com saída real**: o **gate `check` do `.codeflow/manifest.md`** (`lint`,
  `test` e `security`, que varre segredo nos commits do ramo), uma vez, na raiz da worktree; as
  **regras §x.6 do tipo tocado** e a **Parte 3** do `ARTIFACTS_SPEC.md`, arquivo por arquivo; o
  **catálogo pago** (regra 6); e a **varredura de nome**, que é o gate `security` (Pré-requisitos).
- PR só de documentos (proposta de core): o mesmo gate `check` e a varredura, mais o escopo do diff e o
  schema da decision (§2.5).
- `APROVADO` (ou `✓`) → Fase 6. `AJUSTAR` → os BLOQUEANTES voltam ao **mesmo** implementador, e a
  revisão seguinte é em terminal limpo de novo. **Teto: duas reprovações** — na terceira, o dono decide.

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-evolucao-<timestamp>.md` com o veredito e o `sha` revisado.

## Fase 6 — PR e merge na `main`

### Objetivo
Levar o ramo revisado à `main` por PR, com merge commit e sem reescrever história.

### Ações
- **Decision gerada:** acrescentar a linha em `.codeflow/decisions/INDEX.md` (schema §2.6) e commitar
  só isso: `docs(decisions): indexa a decision de <slug>`.
- `git fetch origin`; **se o `origin/main` andou:** `git merge origin/main -m "chore(evolucao): traz o
  origin/main" -m "Ramo: evolucao/<slug>"` — **nunca rebase**, que reescreve os `sha` citados.
  Conflito volta ao mesmo implementador. Com ou sem conflito, um Revisor limpo roda de novo o gate
  `check` e a varredura sobre o novo HEAD, com saída real.
- **O que vale como revisado:** o `sha` que o Revisor validou. Commit **só de documento** depois dele
  (a `REVISAO-<n>.md`, a linha do INDEX) não pede nova revisão — o Maestro confere com
  `git diff --stat <sha validado>..HEAD` que nada fora deles mudou; código novo ou `origin/main`
  trazido pedem.
- `git push -u origin evolucao/<slug>` e `gh pr create --base main --title "<assunto do PR>"
  --body-file ~/.config/codeflow/orquestracao/evolucao/PR-<slug>.md`. Corpo (escrito fora do
  repositório): contexto, o que mudou (etapas e `sha`), como se prova (veredito e validação), o que
  muda para os projetos, e o rodapé de atribuição (operação, item 5).
- **Merge pelo Maestro** (operação, item 2): revisão aprovada sobre o `sha` validado, com só documento
  depois dele → `gh pr merge <n> --merge`. **Nunca squash, nunca rebase.** O GitHub não apaga o ramo:
  `git push origin --delete evolucao/<slug>`.

### Checkpoint
Gravar `.codeflow/checkpoints/orquestrar-evolucao-<timestamp>.md` com o PR e o `sha` do merge.

## Fase 7 — Geração de artefatos: deploy, aviso e devolução da pasta

### Objetivo
Pôr o merge em produção na pasta principal, cumprir os pós-passos e avisar quem sente a mudança.

### Ações
- **Logo após o merge, pelo Maestro** (operação, item 3), sem esperar o dono: o `pull` muda o
  framework de todos os projetos de uma vez, até entre dois passos de uma tarefa em curso — por isso o
  aviso abaixo é obrigatório.
- **Pré-condição:** na principal, `git -C ~/Projetos/codeflow branch --show-current` = `main` e
  `status --porcelain` vazio. Se não, `PARADO` — nunca limpar, trocar de ramo nem stashar a principal.
- **Deploy:** `git -C ~/Projetos/codeflow pull --ff-only` (operação, item 3); recusa → `PARADO`.
- **Pós-passos**, pelo que o diff mudou (`git diff --stat <antes>..<depois>` na principal):

  | Mudou | Passo |
  | --- | --- |
  | Só conteúdo de workflow, skill, meta-skill ou rule | nada mais |
  | Workflow ou meta-skill universal novo, renomeado ou removido | `bash ~/.codeflow/setup-slash-commands.sh` (com `--prune` se removeu) e `bash ~/.codeflow/setup-codex-skills.sh`; órfão em `~/.agents/skills/` vai ao dono, que apaga à mão |
  | Moldes em `framework/library/templates/specs/` | o dono re-roda `bash ~/.codeflow/install.sh` em cada projeto |
  | `setup-slash-commands.sh` ou `setup-codex-skills.sh` (formato do wrapper ou da skill instalada) | re-rodar o script mudado, para os instalados não ficarem velhos |
  | `install.sh` | aviso ao dono para re-rodá-lo em cada projeto que o usa |
  | Só `.codeflow/` deste repositório | nada mais |

- **Aviso** (operação, item 3), no Quadro e no resumo final — e, se `maestri list` o mostrar, ao
  Maestro do hub **Codeflow**: o framework mudou para os projetos; o que mudou, o `sha`, os projetos
  que sentem, os passos que ficaram com o dono. Artefato novo fica `experimental`
  até o uso real; o primeiro ensaio nos projetos vai ao plano como pendência do dono.
- **Devolver a pasta:** `git fetch origin && git switch --detach origin/main && git branch -d
  evolucao/<slug>`; apagar os checkpoints; dispensar os recrutas (`maestri dismiss`); limpar o Quadro.

### Checkpoint
Marcar `.codeflow/checkpoints/orquestrar-evolucao-<timestamp>.md` como `concluído` e apagá-lo (§2.7:
efêmero). O plano da trilha guarda o diário.

## Proibições durante este workflow

- O Maestro não planeja, não implementa e não revisa: cada passo é um terminal. Sem subagente.
- Não escrever em `~/Projetos/codeflow` nem em `~/.codeflow/`, salvo o `git pull --ff-only` da Fase 7;
  não rodar script de setup com o `HOME` real antes do merge; nunca `install.sh` na worktree.
- Não mudar o core além da proposta em decision; delegação não destrava o gate duro.
- Não implementar sem o plano aprovado pelo dono; não deixar quem implementou revisar; não rebaixar
  mudança grande; não criar universal sem o critério do EVOLUTION ou a decision da exceção.
- Não mergear sem a revisão aprovada, com saída real, sobre o `sha` validado (depois dele, só
  documento). Nunca squash, rebase,
  `--no-verify`, `git stash` nem push direto na `main`.
- Não colar segredo, nome de cliente, de pessoa ou dado real no canvas, no plano ou no PR.

## Definition of Done

- [ ] Pedido triado com o dono (do framework; core só como proposta; caminho e tamanho pela
      `change-sizing`); grande devolvido como `PARADO`.
- [ ] Ramo `evolucao/<slug>` de `origin/main`; a principal intocada até o deploy.
- [ ] Plano aprovado pelo dono antes de editar (mudança) ou reprodução declarada antes do conserto
      (correção); artefato novo no destino da worktree, com o critério do EVOLUTION ou a decision.
- [ ] Revisão em terminal limpo com o gate `check` do manifest, as regras §x.6 e a Parte 3, o
      catálogo pago e a varredura do repositório público, com saída real.
- [ ] Decision gerada, se houver, indexada; PR para `main` mergeado com `--merge`; ramo remoto apagado.
- [ ] Deploy por `git pull --ff-only` logo após o merge, pelo Maestro; pós-passos cumpridos ou
      entregues ao dono; aviso no Quadro e no resumo final.
- [ ] Worktree de volta a `origin/main` destacado, sem ramo velho; checkpoints apagados; plano com as
      decisões e o diário.

## Resumo final

Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4. Ao dono, curto: a mudança, o caminho e o
tamanho, o PR e o `sha` do merge, o aviso de que o framework mudou para os projetos (deploy feito), o
veredito e a validação que o sustentou, as decisões tomadas por delegação (uma linha cada), os
pós-passos que ficaram com ele e o primeiro ensaio pendente nos projetos.
