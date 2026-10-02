---
versão: 1.0
status: estável
atualizado: 2026-10-02
projeto: codeflow
---

# Constitution do projeto: codeflow

## Stack

- **Produto:** o próprio framework — texto normativo em Markdown pt-BR (`framework/core/`, `framework/library/`, `framework/meta/`) e scripts bash. Sem aplicação, banco, staging nem usuário final.
- **Scripts:** bash 4.0+ (`install.sh`, `setup-slash-commands.sh`, `setup-codex-skills.sh`, `setup-codex-prompts.sh`, `framework/core/scripts/run-structural.sh`).
- **Ferramentas permitidas em script:** bash, coreutils, git, openssl (`framework/core/ARTIFACTS_SPEC.md` §0.9).
- **Hospedagem:** GitHub, repositório público.
- **Distribuição:** os symlinks de `~/.codeflow` apontam para o clone principal do repositório (`framework/core/SPEC.md` §3.4).

Versões em `manifest.md`.

## Padrão arquitetural

Camadas. `framework/core/` guarda o contrato normativo (`SPEC.md`, `ARTIFACTS_SPEC.md`) e o core (`constitution.md`, `glossary.md`, `EVOLUTION.md`); `framework/library/` guarda workflows, skills, agents e moldes; `framework/meta/` guarda as meta-skills. Os scripts da raiz expõem a biblioteca às ferramentas de IA como wrappers. Dependências fluem para dentro: `library` e `meta` citam `core`; `core` não cita `library` nem `meta` como regra.

## Regras invariantes específicas

- **O clone principal é produção.** O clone para onde os symlinks de `~/.codeflow` apontam fica sempre em `main`, limpo, e só recebe `git pull --ff-only` depois de um merge. Nunca editar, commitar, trocar de ramo, fazer `stash` ou `rebase` nele: o que está no disco dele vale na hora para todos os projetos consumidores. Conferir com `git status -sb` → `## main...origin/main` sem alterações.
- **Toda mudança mora numa worktree de trilha, num ramo por tarefa** nascido de `origin/main`: `evolucao/<slug>` na trilha de evolução, `chore/auditoria-<AAAA-MM-DD>-<slug>` na de auditoria. Nunca commitar direto em `main`.
- **Todo ramo chega a `main` por pull request**, com merge por `gh pr merge <n> --merge`. Nunca squash, nunca rebase. O merge só acontece depois de uma revisão em terminal limpo — quem revisa não viu o trabalho nascer — com todos os gates de `manifest.md` verdes e a saída real anexada, inclusive em pull request só de documentos. Commit só de documento depois da revisão aprovada (o laudo da revisão, a linha do índice) não pede nova revisão; trazer `origin/main` para o ramo pede o gate `check` de novo, por um revisor limpo, com ou sem conflito. O ramo é apagado à mão depois do merge.
- **O merge só fecha com o deploy:** `git pull --ff-only` no clone principal e os pós-passos que a mudança pedir:
  - conjunto de workflows ou meta-skills universais mudou (novo, renomeado, removido), ou mudou `setup-slash-commands.sh` ou `setup-codex-skills.sh`: `bash ~/.codeflow/setup-slash-commands.sh` (com `--prune` quando houve remoção) e `bash ~/.codeflow/setup-codex-skills.sh` (órfão apagado à mão);
  - mudou `framework/library/templates/specs/` ou `install.sh`: aviso de re-rodar `bash ~/.codeflow/install.sh` em cada projeto consumidor;
  - todo deploy que muda `framework/` ou os scripts da raiz avisa os orquestradores dos projetos consumidores de que o framework mudou para todos ao mesmo tempo. Pull request só de documentos de `.codeflow/` não muda o framework ao vivo e dispensa o aviso.
- **Atribuição a IA é permitida.** O commit feito com ferramenta de IA leva o trailer `Co-Authored-By` que ela adiciona; o pull request leva o rodapé de geração dela.
- **Mudança no core é gate duro.** Tocar `framework/core/constitution.md`, `framework/core/glossary.md` ou `framework/core/EVOLUTION.md` exige decision em `.codeflow/decisions/`, 30 dias com a proposta visível e bump major (`framework/core/EVOLUTION.md`). Nenhum orquestrador aprova sozinho, e decisão delegada não destrava: a tarefa para em `PARADO` para o dono. Correção de typo e reformatação sem mudança de sentido ficam fora do gate.
- **Mudança grande para no dono.** Mudança classificada como grande pela skill `change-sizing`, ou que altere schema de artefato de projeto (`framework/core/ARTIFACTS_SPEC.md` Parte 2), para em `PARADO` para o dono. Não há trilha de spec neste repositório.
- **Toda mudança paga o catálogo na mesma entrega:** a árvore de `framework/core/SPEC.md` §2.2, a lista de §3.5, `README.md`, o termo novo em `framework/core/glossary.md` e o frontmatter (`versão`, `atualizado`) de cada arquivo tocado. Paga-se o item criado ou tocado pela mudança; a defasagem anterior do catálogo é item da trilha de auditoria. O termo novo no glossary segue o regime de core da regra acima.
- **O repositório é público.** Nenhum arquivo versionado carrega segredo, credencial, dado real, nome de cliente ou nome de pessoa. Todo pull request passa pelo gate `security` de `manifest.md`, que roda o `gitleaks` e a varredura de nome de cliente ou de pessoa nas linhas que o ramo acrescenta, contra a lista em `~/.config/codeflow/nomes-proibidos.txt` (fora do repositório, `chmod 600`). A saída da varredura cita só nome de arquivo, nunca o valor.
- **Nunca rodar `install.sh` neste repositório, nem numa worktree dele, nem com `HOME` temporário.** Ele opera no diretório corrente: reescreveria os wrappers de `.claude/commands/` com caminho absoluto, mexeria no `.gitignore` e copiaria moldes para `.codeflow/specs/_TEMPLATES/`. Os wrappers de projeto daqui usam caminho relativo (decision `2026-10-02-operacao-por-trilhas`). Para ensaiar `install.sh`, rodá-lo num projeto descartável criado dentro de um `HOME` temporário.
- **Script de setup só se testa com `HOME` temporário** apontando para a worktree (gate `test` de `manifest.md`). Rodá-lo com o `HOME` real testa o framework ao vivo, não o ramo, e reescreve os wrappers da máquina.

## Áreas de alto risco

- **`framework/core/constitution.md`, `framework/core/glossary.md`, `framework/core/EVOLUTION.md`** — core. Política: gate duro das regras invariantes; nunca entram num pull request comum, salvo correção de typo e reformatação sem mudança de sentido (regra "Mudança no core").
- **`framework/core/ARTIFACTS_SPEC.md` e `framework/core/SPEC.md`** — contrato que os projetos consumidores já seguem. Política: mudança de schema ou de comportamento é mudança grande e para no dono; correção de texto que não muda contrato segue o fluxo comum.
- **`install.sh`, `setup-slash-commands.sh`, `setup-codex-skills.sh`, `setup-codex-prompts.sh`** — escrevem fora do repositório (configuração das ferramentas de IA e `.codeflow/` dos projetos). Política: os de setup só se testam com `HOME` temporário, e `install.sh` só num projeto descartável dentro dele; o pull request diz quais pós-passos do deploy a mudança exige.
- **`framework/core/scripts/run-structural.sh`** — valida as specs dos projetos consumidores. Política: o gate `test` compara o código de saída de `origin/main` e do ramo sobre todas as specs reais; divergência é regressão até ser justificada no pull request.
- **`framework/library/templates/specs/`** — copiado por `install.sh` para cada projeto. Política: mudança aqui inclui no deploy o aviso de re-rodar `install.sh` nos projetos.
- **`framework/library/skills/modo-delegado/`** — rege os recrutas de todos os orquestradores, deste e dos outros projetos. Política: mudança aqui é avisada aos orquestradores no deploy.

## Definition of Done específica

Itens adicionais ao Definition of Done padrão (constitution universal):

- O gate `check` de `manifest.md` rodou na raiz da worktree, sobre o ramo commitado, e a saída real está no relatório da revisão.
- O catálogo foi pago (regra "Toda mudança paga o catálogo").
- O pull request lista os pós-passos do deploy que a mudança exige, ou declara que não exige nenhum.
