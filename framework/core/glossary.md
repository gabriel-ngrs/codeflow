---
versão: 1.2
status: estável
atualizado: 2026-06-15
---

# Glossário do codeflow

> **Specs:** `SPEC.md` e `ARTIFACTS_SPEC.md`, citados aqui e nos artefatos do framework, vivem em `~/.codeflow/framework/core/` (contratos normativos de runtime).

## Termos centrais

### Agent

- **Definição:** definição de subagente da ferramenta de IA com escopo de ferramentas restrito, invocado por **workflow** para isolar sub-tarefa em contexto próprio.
- **Onde mora:** `~/.codeflow/framework/library/agents/<nome>.md` (universal) ou `<projeto>/.codeflow/agents/<nome>.md` (projeto).
- **O que NÃO é:** não é a IA inteira. Não é skill. Ver `## Termos com colisão entre ferramentas` para distinção do uso em outras ferramentas.
- **Exemplo concreto:** um agent de auditoria de dependências read-only tem Read e Grep mas não Bash, para que não possa rodar `pip install` nem regenerar o lockfile enquanto audita; um workflow o invoca para a checagem antes do commit. Nenhum agent universal acompanha o framework — agents nascem por projeto, via `/create-agent`.

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
- **Exemplo concreto:** ao terminar um `/bugfix` cujo fix alterou o schema, a IA gera `2026-05-17-schema-users-table.md` com a escolha e a alternativa rejeitada.

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
- **Exemplo concreto:** workflows leem `manifest.md` para descobrir que, no projeto X, o gate `check` equivale a `pytest && ruff check`.

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

## Termos do pipeline de spec

O pipeline de spec é a cadeia `/create-spec` → `/execute-spec-phase` → `/evaluate-spec-phase` (com `/spec-status` para visão de progresso). Os termos abaixo são específicos dele; o vocabulário central acima continua valendo.

### Spec

- **Definição:** documento único e autoexecutável (`SPEC_<NAME>.md`) gerado por `/create-spec`, ancorado na sondagem do repositório. Contém problema, requisitos (FR/NFR), critérios de aceite, abordagem técnica e o **plano de desenvolvimento por fases** (§5).
- **Onde mora:** `<projeto>/.codeflow/specs/<slug>/SPEC_<NAME>.md`, versionado na branch atual (o pipeline não cria branch própria; quem gerencia a branch é o owner).
- **O que NÃO é:** não é decision. Decision é registro leve de uma escolha pontual; a spec é o plano completo e executável. As decisões de escopo da spec ficam dentro dela (§4 e §8), não em artefato separado.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.8.

### Fase

- **Definição:** unidade executável e avaliável de uma spec, declarada na §5, com `id` canônico, `slug`, dependências por `id`, arquivos, passos, testes e critério de conclusão. Uma fase entrega um incremento testável.
- **Onde mora:** descrita na §5 da spec; sua execução e avaliação geram artefatos em `<projeto>/.codeflow/specs/<slug>/artefatos/`.
- **O que NÃO é:** não é passo de workflow. Passo é interno a uma sessão; fase é incremento com artefatos próprios (`EXECUCAO`/`AVALIACAO`), executado uma por vez em chats separados.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.8.6 (estrutura) e §2.11 (estados).

### Track e wave

- **Definição:** `wave` é o modo da spec — `single` (um track só) ou `multi` (tracks paralelos com dependência cruzada). `track` é o agrupador de fases num fluxo paralelo.
- **Onde mora:** `wave` no frontmatter da spec; o track aparece no `id` da fase. Single-track usa `id` inteiro (`1`, `2`); multi-track usa `<TRACK>.<n>` (`A.1`, `B.2`).
- **O que NÃO é:** track não é fase. É um cabeçalho de agrupamento (`### Track A — …`) que não conta na contagem de 3–8 fases por track.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.8.6.

### Execução de fase

- **Definição:** relatório `FASE-<id>-<slug>-EXECUCAO.md` gerado por `/execute-spec-phase` ao implementar (ou refazer) uma fase, com frontmatter machine-readable (`fase`, `tentativa`, `reprovacoes`, `sha_inicial`, `sha_final`, `range`) e corpo com evidências.
- **Onde mora:** `<projeto>/.codeflow/specs/<slug>/artefatos/`. Versionado, mas é artefato de ciclo de vida (sem `versão`/`atualizado`; usa `status: executado|rework`).
- **O que NÃO é:** não é a fonte de verdade da avaliação. O avaliador o trata como ponto de partida e confere tudo contra o código real.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.9.

### Avaliação de fase

- **Definição:** relatório `FASE-<id>-<slug>-AVALIACAO.md` gerado por `/evaluate-spec-phase`, **sempre em chat zerado e independente**, com scorecard ponderado, achados (BLOQUEANTE/IMPORTANTE/SUGESTÃO) e veredito machine-readable.
- **Onde mora:** `<projeto>/.codeflow/specs/<slug>/artefatos/`. Usa `veredito` no lugar de `status`.
- **O que NÃO é:** não é auto-revisão. A independência (chat separado, não confiar no relatório) é o motivo de existir do workflow.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.10.

### Veredito

- **Definição:** resultado da avaliação de uma fase: `APROVADO`, `RESSALVAS` ou `REPROVADO`, decidido por precedência estrita **`REPROVADO` > `RESSALVAS` > `APROVADO`**. Só `APROVADO` conclui a fase; `RESSALVAS` e `REPROVADO` devolvem ao rework.
- **Onde mora:** campo `veredito` no frontmatter do `FASE-*-AVALIACAO.md`.
- **O que NÃO é:** `RESSALVAS` não é aprovação condicional — neste pipeline nunca fecha uma fase nem libera a seguinte.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.10.3 (cascata de veredito).

### Gate estrutural

- **Definição:** validação **determinística** da §5 da spec, rodada por `run-structural.sh` antes de qualquer classificação de fases: `id`s únicos, heading `### Fase <id>` igual ao bullet `id`, todo `id` em "Depende de" existente, grafo acíclico, 3–8 fases por track, `slug` em kebab-case e `wave` coerente com o formato de `id`.
- **Onde mora:** `~/.codeflow/framework/core/scripts/run-structural.sh`; consumido por `/execute-spec-phase`, `/evaluate-spec-phase` e `/spec-status`.
- **O que NÃO é:** não é avaliação de qualidade. Só valida a forma da §5; mérito do código é da avaliação de fase.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.8.6.

### Máquina de estados da fase

- **Definição:** definição canônica de como cada fase deriva **um único** estado — **pendente**, **aguardando avaliação**, **reprovada** ou **concluída** — a partir do frontmatter dos artefatos `EXECUCAO`+`AVALIACAO` (pareados pela `tentativa`), com elegibilidade por dependências concluídas e teto de reprovações.
- **Onde mora:** definida em `ARTIFACTS_SPEC.md` §2.11; consumida (não redefinida) por `/execute-spec-phase`, `/evaluate-spec-phase` e `/spec-status`.
- **O que NÃO é:** não é um runtime nem orquestrador. É uma derivação de estado a partir de arquivos, calculada pela IA ao ler os artefatos — não há processo em execução.
- **Referência canônica:** `ARTIFACTS_SPEC.md` §2.11.

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
