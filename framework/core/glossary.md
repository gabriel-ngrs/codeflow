---
versão: 1.0
status: estável
atualizado: 2026-05-23
---

# Glossário do codeflow

> **Specs:** `SPEC.md` e `ARTIFACTS_SPEC.md`, citados aqui e nos artefatos do framework, vivem em `~/.codeflow/framework/core/` (contratos normativos de runtime).

## Termos centrais

### Agent

- **Definição:** definição de subagente da ferramenta de IA com escopo de ferramentas restrito, invocado por **workflow** para isolar sub-tarefa em contexto próprio.
- **Onde mora:** `~/.codeflow/framework/library/agents/<nome>.md` (universal) ou `<projeto>/.codeflow/agents/<nome>.md` (projeto).
- **O que NÃO é:** não é a IA inteira. Não é skill. Ver `## Termos com colisão entre ferramentas` para distinção do uso em outras ferramentas.
- **Exemplo concreto:** o agent `code-reviewer` tem ferramentas Read e Grep mas não Edit nem Bash; o workflow `feature-small` delega a ele a revisão final do diff.

### Artefato

- **Definição:** arquivo gerado pelo codeflow durante o uso, que vive em `<projeto>/.codeflow/`.
- **Onde mora:** dentro de `.codeflow/` do projeto. Tipos: INDEX.md, constitution.md, manifest.md, discovered.md, decisions/*, checkpoints/*.
- **O que NÃO é:** não é conteúdo de framework. Conteúdo de framework vive em `~/.codeflow/` e é fixo entre projetos; artefato é específico do projeto.
- **Exemplo concreto:** a meta-skill `discover`, ao terminar, deixa quatro artefatos em `.codeflow/`: INDEX.md, constitution.md, manifest.md, discovered.md.

### Checkpoint

- **Definição:** **artefato** efêmero que registra estado intermediário de **workflow** detalhado em execução.
- **Onde mora:** `<projeto>/.codeflow/checkpoints/<workflow>-<timestamp>.md`. Adicionado ao `.gitignore` pelo `install.sh`.
- **O que NÃO é:** não é decision. Checkpoint é estado de execução em pausa; decision é registro permanente de escolha tomada.
- **Exemplo concreto:** o workflow `discover` grava checkpoint ao fim da fase de inspeção, antes de pausar para perguntar ao usuário.

### Constitution

- **Definição:** conjunto de regras invariantes que governam o comportamento da IA, em duas versões (universal e de projeto).
- **Onde mora:** `~/.codeflow/framework/core/constitution.md` (universal) e `<projeto>/.codeflow/constitution.md` (projeto).
- **O que NÃO é:** não é workflow nem skill. Não contém passos. Contém princípios.
- **Exemplo concreto:** a regra "diff mínimo" vive na constitution universal e vale para todos os workflows.

### Decision

- **Definição:** **artefato** permanente que registra decisões tomadas durante **workflow** significativo, com header estruturado.
- **Onde mora:** `<projeto>/.codeflow/decisions/<data>-<titulo>.md`. Versionado no git do projeto.
- **O que NÃO é:** não é checkpoint. Decisão é permanente; checkpoint é efêmero. Não é ADR formal — é registro leve, sem cerimônia.
- **Exemplo concreto:** ao terminar `/feature-small` com mudança de schema, a IA gera `2026-05-17-schema-users-table.md` com a escolha e a alternativa rejeitada.

### Discovered

- **Definição:** **artefato** gerado pela meta-skill `discover` que registra padrões, decisões implícitas e observações sobre o projeto que não cabem em constitution, manifest ou INDEX.
- **Onde mora:** `<projeto>/.codeflow/discovered.md`.
- **O que NÃO é:** não é manifest. Manifest descreve stack e comandos; discovered registra padrões e observações qualitativas detectadas durante inspeção.
- **Exemplo concreto:** ao rodar `/discover` em um projeto Django, a IA registra em `discovered.md` que "models seguem padrão fat-model, lógica de domínio fica em métodos de modelo, não em services".

### INDEX

- **Definição:** mapa de leitura prioritária. Existe em duas instâncias: a do `.codeflow/` do projeto e a da pasta `decisions/`.
- **Onde mora:** `<projeto>/.codeflow/INDEX.md` (mapa geral) e `<projeto>/.codeflow/decisions/INDEX.md` (índice navegável de decisions).
- **O que NÃO é:** não é README. Não é introdução prosa. É mapa funcional para a IA priorizar leituras.
- **Exemplo concreto:** ao iniciar um workflow, a IA lê `INDEX.md` para saber em que ordem carregar constitution, manifest e decisions relevantes.

### Manifest

- **Definição:** arquivo que descreve stack, comandos `make` e padrões detectados do projeto, com header de freshness check.
- **Onde mora:** `<projeto>/.codeflow/manifest.md`.
- **O que NÃO é:** não é constitution. Constitution declara regras; manifest descreve o estado factual do projeto.
- **Exemplo concreto:** workflows leem `manifest.md` para descobrir que `make check` no projeto X equivale a `pytest && ruff check`.

### Meta-skill

- **Definição:** **skill** cujo propósito é criar outros artefatos do framework (workflows, skills, agents).
- **Onde mora:** `~/.codeflow/framework/meta/<nome>/SKILL.md`. Sempre universal.
- **O que NÃO é:** não é workflow. Meta-skill é capacidade reutilizada por mais de uma forma de invocação.
- **Exemplo concreto:** `/create-workflow` invoca a meta-skill `create-workflow`, que entrevista o usuário e gera arquivo novo em `framework/library/workflows/` ou `.codeflow/workflows/`.

### Rule

- **Definição:** módulo temático opcional que estende a **constitution**, carregado seletivamente por workflows conforme relevância.
- **Onde mora:** `~/.codeflow/framework/core/rules/<tema>.md` (universal) ou `<projeto>/.codeflow/rules/<tema>.md` (projeto).
- **O que NÃO é:** não é constitution. Constitution é base universal e curta; rule é tema específico carregado sob demanda.
- **Exemplo concreto:** o workflow `bugfix` carrega `rules/testing.md` para reforçar que todo bug fix exige teste de regressão.

### Skill

- **Definição:** arquivo markdown que encapsula uma capacidade discreta e reutilizável, aplicada dentro de um **workflow**.
- **Onde mora:** `~/.codeflow/framework/library/skills/<nome>/SKILL.md` (universal) ou `<projeto>/.codeflow/skills/<nome>/SKILL.md` (projeto).
- **O que NÃO é:** não é workflow. Skill é capacidade (como fazer bem uma coisa); workflow é processo (o quê fazer, em que ordem).
- **Exemplo concreto:** a skill `debug-protocol` define como formar hipóteses uma por vez; o workflow `bugfix` carrega essa skill e a aplica no passo de diagnóstico.

### Workflow

- **Definição:** arquivo markdown que descreve sequência ordenada de passos para realizar tarefa repetitiva, invocado via slash command.
- **Onde mora:** `~/.codeflow/framework/library/workflows/<nome>.md` (universal) ou `<projeto>/.codeflow/workflows/<nome>.md` (projeto).
- **O que NÃO é:** não é prompt, não é agente, não é runtime. É protocolo estruturado lido pela IA.
- **Exemplo concreto:** o usuário invoca `/bugfix`, e a IA carrega `bugfix.md` e segue seus passos.

### Wrapper

- **Definição:** arquivo curto (2-4 linhas) em `~/.claude/commands/<nome>.md` (universal) ou `<projeto>/.claude/commands/<nome>.md` (projeto) que registra um workflow ou meta-skill como slash command nativo da ferramenta de IA. Conteúdo: instrução para ler o arquivo real e executar o protocolo.
- **Onde mora:** fora do framework e do `.codeflow/` do projeto — em `~/.claude/commands/` (gerado por `setup-slash-commands.sh`) ou `<projeto>/.claude/commands/` (gerado por `install.sh`).
- **O que NÃO é:** não é workflow nem skill. Não duplica conteúdo do arquivo referenciado. Não tem lógica própria.
- **Referência canônica:** `SPEC.md` §3.6.1 (decisão) e `ARTIFACTS_SPEC.md` §1.11 (schema).

## Distinções importantes

### Workflow vs Skill

Workflow é processo — define **o quê** fazer, em que ordem, com que validações. Skill é capacidade — define **como** fazer uma coisa bem (formar hipótese, registrar handoff, fazer self-review). Workflows referenciam skills em sua seção "LEIA TAMBÉM"; skills nunca referenciam workflows.

### Agent vs Skill

Skill é capacidade aplicada pela mesma sessão da IA dentro de um workflow. Agent é subagente isolado em contexto próprio, com escopo de ferramentas restrito, invocado por um workflow para uma sub-tarefa específica. Skill compartilha contexto com o workflow; agent não.

### Rule vs Constitution

Constitution declara princípios universais e invariantes — curta, densa, sempre carregada. Rule declara regras temáticas — carregada apenas por workflows que pedem (ex: `rules/testing.md` só entra em workflows que tocam testes). Constitution é monolítica; rules são modulares.

### Decision vs Checkpoint

Decision é registro permanente de escolha tomada — fica versionada no git do projeto, sobrevive a sessões e a refactorings, é fonte de verdade para entender por que algo é como é. Checkpoint é estado efêmero de execução em pausa — fica em `.gitignore`, vale apenas para retomar um workflow detalhado interrompido. Decision responde "por quê"; checkpoint responde "onde parei".

## Termos com colisão entre ferramentas

### Agent

- **No codeflow:** definição de subagente com escopo de ferramentas restrito, invocado por workflow para sub-tarefa isolada.
- **Em outras ferramentas:**
  - Claude Code: refere-se à própria IA executando o chat.
  - Cursor: refere-se ao modo "agent" da IDE, com loop autônomo de ações.
  - AutoGPT e similares: refere-se a entidade autônoma com objetivo de alto nível.

A IA que lê este glossário ao executar um workflow do codeflow deve adotar **exclusivamente** a definição "no codeflow", ignorando o significado da ferramenta hospedeira.
