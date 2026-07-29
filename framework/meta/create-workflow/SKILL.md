---
versão: 1.2
status: estável
atualizado: 2026-07-29
descrição: Entrevista o usuário e gera workflow novo no formato correto.
é_meta_skill: yes
granularidade: médio
---

# Meta-skill: create-workflow

> **Specs de runtime:** as referências a `ARTIFACTS_SPEC.md §x` (templates e validação) e a `SPEC.md §x` ao longo deste protocolo apontam para `~/.codeflow/framework/core/ARTIFACTS_SPEC.md` e `~/.codeflow/framework/core/SPEC.md`. Leia o template literal de lá — não parafraseie de memória.

## Quando usar

Usuário invoca `/create-workflow` quando identifica necessidade de novo workflow universal ou de projeto. A meta-skill conduz a entrevista, gera o arquivo no formato correto e o salva no caminho apropriado.

## Princípio guia

Workflow novo nasce de necessidade concreta e usada, não de especulação. A entrevista qualifica antes de gerar: se a tarefa não merece workflow, recusar.

## Protocolo

### Passo 1 — Qualificar a necessidade
- Perguntar: a tarefa é repetitiva? Aconteceu pelo menos duas vezes? Sem workflow, há risco real de inconsistência?
- Se qualquer resposta é "não", sugerir resolver ad hoc e não gerar workflow.

### Passo 2 — Identificar granularidade
- Perguntar: a IA pode fazer sem perguntar nada ao usuário durante execução?
  - Sim → magro.
- Perguntar: a tarefa exige conversa estruturada com decisões abertas?
  - Sim → detalhado.
- Caso contrário → médio.

### Passo 3 — Coletar metadata e estrutura
- Nome do workflow (kebab-case, sugerido pelo usuário).
- `gera_decision`: yes / no / auto.
- `usa_checkpoints`: yes apenas se granularidade é detalhado.
- Lista de skills e rules a carregar (`## LEIA TAMBÉM`).
- Lista de passos (magro/médio) ou fases (detalhado).

### Passo 4 — Determinar destino
- Universal vs projeto: perguntar ao usuário. Se específico do projeto atual, salvar em `<projeto>/.codeflow/workflows/`. Se reutilizável entre projetos, salvar em `~/.codeflow/framework/library/workflows/` — mas apenas após confirmação explícita do usuário (promoção universal exige critérios da EVOLUTION.md).

### Passo 5 — Gerar arquivo conforme template
- Aplicar `## Template de saída` substituindo placeholders pelos valores coletados.

### Passo 6 — Validar e apresentar
- Aplicar `## Validação pós-geração`. Se qualquer check falha, corrigir antes de apresentar.

### Passo 7 — Registrar slash command
- Se o workflow gerado foi salvo em `~/.codeflow/framework/library/workflows/`, registrar conforme a ferramenta em uso:
  - Claude Code: executar `bash ~/.codeflow/setup-slash-commands.sh` para criar o wrapper em `~/.claude/commands/<nome>.md`.
  - Codex: executar `bash ~/.codeflow/setup-codex-skills.sh` para criar a skill em `~/.agents/skills/<nome>/SKILL.md`, invocada como `$<nome>` ou via `/skills`.
- Se o workflow foi salvo em `<projeto>/.codeflow/workflows/`, registrar conforme a ferramenta em uso:
  - Claude Code: **não** rodar o script universal; o wrapper local é criado por `install.sh` na próxima vez que rodar no projeto (ou pode-se rodar `bash ~/.codeflow/install.sh` imediatamente para sincronizar).
  - Codex: executar `bash ~/.codeflow/setup-codex-skills.sh --project-dir <projeto> --project-prefix <prefixo>` para criar `$<prefixo>-<nome>`.
- Confirmar com o usuário que o slash command da ferramenta atual está disponível antes de encerrar.

## Proibições durante esta meta-skill

- Não gerar workflow sem qualificar a necessidade no Passo 1.
- Não inventar campos de frontmatter fora do conjunto válido definido em `ARTIFACTS_SPEC.md` §1.5–§1.7.
- Não promover workflow a universal sem passar pelos critérios da `EVOLUTION.md`.

## Template de saída

Selecionar template conforme granularidade:

- **Magro:** template em `ARTIFACTS_SPEC.md` §1.5.5.
- **Médio:** template em `ARTIFACTS_SPEC.md` §1.6.5.
- **Detalhado:** template em `ARTIFACTS_SPEC.md` §1.7.5.

Substituir placeholders: `<nome>`, `<descrição>`, `<passos>`, `<rules>`, `<skills>`, `<gera_decision>`.

## Onde salvar

- Workflow de projeto: `<projeto>/.codeflow/workflows/<nome>.md`.
- Workflow universal: `~/.codeflow/framework/library/workflows/<nome>.md`.

Critério: workflow específico de stack ou domínio do projeto → projeto. Workflow agnóstico, com uso previsto em dois ou mais projetos → universal (somente após critérios da `EVOLUTION.md` serem satisfeitos).

## Validação pós-geração

- Aplicar regras de validação correspondentes em `ARTIFACTS_SPEC.md`: §1.5.6, §1.6.6, ou §1.7.6.
- Verificar que o nome do arquivo bate com o título.
- Verificar que `## LEIA TAMBÉM` inclui as quatro entradas obrigatórias.
- Apresentar resumo do workflow gerado ao usuário antes de finalizar.

## Saídas válidas

- **Workflow gerado:** arquivo `.md` no caminho declarado, passando todas as regras de validação do tipo correspondente. Resumo apresentado ao usuário com o caminho do arquivo gerado.
- **Workflow recusado (Passo 1):** mensagem ao usuário explicando por que a tarefa não merece workflow, com sugestão alternativa (resolver ad hoc, criar skill em vez, criar rule em vez).
