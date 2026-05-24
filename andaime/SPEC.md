---
versão: 1.1
status: estável
atualizado: 2026-05-20
documento: SPEC.md
projeto: codeflow
localização: ~/Projetos/codeflow/andaime/SPEC.md
audiência principal: Claude Code (e qualquer IA) que vai construir o framework
audiência secundária: desenvolvedores que querem entender o framework profundamente
---

# SPEC.md — Especificação completa do codeflow

> Este documento descreve o codeflow como produto final: o que ele é, como funciona, e por que foi desenhado assim. Toda decisão tem justificativa. Anti-decisões são explícitas.
>
> **Este documento é a fonte da verdade durante a construção do framework.** Em caso de conflito entre este documento e qualquer outro, este vence.

---

## Sumário

- [Parte 1 — Fundamentos](#parte-1--fundamentos)
  - [1.1 Problema que o codeflow resolve](#11-problema-que-o-codeflow-resolve)
  - [1.2 Filosofia fundamental](#12-filosofia-fundamental)
  - [1.3 O que o codeflow é](#13-o-que-o-codeflow-é)
  - [1.4 O que o codeflow NÃO é](#14-o-que-o-codeflow-não-é)
- [Parte 2 — Arquitetura](#parte-2--arquitetura)
  - [2.1 Visão geral: duas localizações com papéis distintos](#21-visão-geral-duas-localizações-com-papéis-distintos)
  - [2.2 `~/.codeflow/` — Definições reutilizáveis](#22-codeflow--definições-reutilizáveis)
  - [2.3 `.codeflow/` no projeto — Estado específico](#23-codeflow-no-projeto--estado-específico)
  - [2.4 Por que essa separação](#24-por-que-essa-separação)
  - [2.5 Convivência com outros frameworks e arquivos do projeto](#25-convivência-com-outros-frameworks-e-arquivos-do-projeto)
- [Parte 3 — Decisões fundamentais](#parte-3--decisões-fundamentais)
  - [3.1 Stack de implementação: bash + markdown](#31-stack-de-implementação-bash--markdown)
  - [3.2 Idioma: pt-BR](#32-idioma-pt-br)
  - [3.3 Distribuição: GitHub privado com atualização via git pull](#33-distribuição-github-privado-com-atualização-via-git-pull)
  - [3.4 Localização única: `~/.codeflow/` (via symlink)](#34-localização-única-codeflow-via-symlink)
  - [3.5 Organização: universais planas + projetos isolados (Abordagem 3)](#35-organização-universais-planas--projetos-isolados-abordagem-3)
  - [3.6 Invocação: slash commands disparados pelo usuário](#36-invocação-slash-commands-disparados-pelo-usuário)
  - [3.7 Sessão fresca por workflow](#37-sessão-fresca-por-workflow)
  - [3.8 Comportamento quando workflow não encaixa](#38-comportamento-quando-workflow-não-encaixa)
  - [3.9 install.sh: instalação mínima sem tocar no projeto](#39-installsh-instalação-mínima-sem-tocar-no-projeto)
  - [3.10 Make como abstração canônica de execução](#310-make-como-abstração-canônica-de-execução)
- [Parte 4 — Conceitos centrais](#parte-4--conceitos-centrais)
  - [4.1 Constitution](#41-constitution)
  - [4.2 Workflows](#42-workflows)
  - [4.3 Skills](#43-skills)
  - [4.4 Meta-skills](#44-meta-skills)
  - [4.5 Agents](#45-agents)
  - [4.6 Rules](#46-rules)
  - [4.7 Artefatos](#47-artefatos)
- [Parte 5 — Estrutura interna detalhada de workflows](#parte-5--estrutura-interna-detalhada-de-workflows)
  - [5.1 Como workflows puxam dependências](#51-como-workflows-puxam-dependências)
  - [5.2 Anatomia de um workflow magro](#52-anatomia-de-um-workflow-magro-20-30-linhas)
  - [5.3 Anatomia de um workflow médio](#53-anatomia-de-um-workflow-médio-60-100-linhas)
  - [5.4 Anatomia de um workflow detalhado](#54-anatomia-de-um-workflow-detalhado-150-300-linhas)
  - [5.5 Política de falhas](#55-política-de-falhas)
  - [5.6 Definition of Done](#56-definition-of-done)
- [Parte 6 — Características adicionais](#parte-6--características-adicionais)
  - [6.1 Versionamento de artefatos (A1)](#61-versionamento-de-artefatos-a1)
  - [6.2 Glossário do framework (A2)](#62-glossário-do-framework-a2)
  - [6.3 Política de evolução do framework (A3)](#63-política-de-evolução-do-framework-a3)
  - [6.4 Modo dry-run (B1)](#64-modo-dry-run-b1)
  - [6.5 Log de decisões (B2)](#65-log-de-decisões-b2)
  - [6.6 Checkpoints em workflows longos (B4)](#66-checkpoints-em-workflows-longos-b4)
  - [6.7 Refinamentos finais](#67-refinamentos-finais)
- [Parte 7 — Princípios transversais](#parte-7--princípios-transversais)
  - [7.1 T1 — Idempotência total](#71-t1--idempotência-total)
  - [7.2 T2 — Saída amigável a parsing](#72-t2--saída-amigável-a-parsing)
  - [7.3 T3 — Sem dependências externas escondidas](#73-t3--sem-dependências-externas-escondidas)
  - [7.4 T4 — Reversibilidade por padrão](#74-t4--reversibilidade-por-padrão)
  - [7.5 T5 — Documentação como código](#75-t5--documentação-como-código)
- [Parte 8 — Dependências](#parte-8--dependências)
  - [8.1 Dependências da máquina](#81-dependências-da-máquina)
  - [8.2 Dependências do projeto-alvo](#82-dependências-do-projeto-alvo)
  - [8.3 O que workflows alteram no projeto](#83-o-que-workflows-alteram-no-projeto)
- [Parte 9 — Glossário](#parte-9--glossário)
- [Parte 10 — Anti-features](#parte-10--anti-features)

---

## Parte 1 — Fundamentos

### 1.1 Problema que o codeflow resolve

Desenvolvedores que usam IAs (Claude Code, Codex, Cursor, GLM) para gerar código enfrentam quatro dores recorrentes:

1. **Violação silenciosa de padrões arquiteturais.** A IA gera código que funciona mas viola convenções do projeto (imports cruzando camadas, dead code, padrões inconsistentes).

2. **Loops em bugs simples.** Sem protocolo de debug, a IA tenta soluções aleatórias até estourar o contexto. Um bug de 5 minutos vira sessão de 1 hora sem resultado.

3. **Dead code e inconsistência.** Em projetos grandes, a IA cria arquivos órfãos, duplica utilitários, perde rastreio do que está ativo.

4. **Perda de contexto na auto-compactação.** Sessões longas degradam. O contexto inicial (regras do projeto, padrões) é descartado para fazer espaço, e a qualidade cai progressivamente.

O codeflow resolve essas dores impondo **estrutura de processo** acima da IA. A IA não decide como agir — ela segue protocolos definidos em markdown.

### 1.2 Filosofia fundamental

O codeflow é construído sobre cinco princípios. Eles orientam toda decisão de design.

**Processo acima de prompts.** Estrutura imposta por arquivos versionados, não por boa vontade da IA em uma única conversa. Regras vivem em markdown lido pela IA antes de qualquer ação.

**Previsibilidade vale mais que esperteza.** A IA deve seguir convenções mesmo quando achar que tem abordagem melhor. Consistência habilita confiança e revisão rápida.

**Mínima superfície de mudança.** A IA faz menos do que poderia fazer. Diff mínimo. Sem refatoração não solicitada. Sem "já que estou aqui...".

**Reversibilidade primeiro.** Tudo que a IA faz acontece em branches git. Nada é mergeado sem validação humana. O desenvolvedor retém autoridade final.

**IAs como ferramentas, não oráculos.** Diferentes provedores são intercambiáveis. A inteligência vive nos workflows e skills, não em um único modelo.

### 1.3 O que o codeflow é

O codeflow é um **meta-framework agnóstico** de governança para desenvolvimento assistido por IA.

Concretamente:
- Um conjunto estruturado de arquivos markdown e scripts bash.
- Vive em `~/.codeflow/` na home do usuário (clone de repositório git).
- É consumido por IAs (Claude Code, Codex, Cursor, GLM, ou outras) via slash commands.
- Adapta-se a qualquer projeto, em qualquer linguagem, sem impor estrutura.

É **meta** porque não entrega apenas workflows prontos — entrega skills que criam workflows, skills que criam skills, skills que aprendem projetos novos. Cresce com o uso.

É **agnóstico** porque não depende de nenhuma ferramenta de IA específica. O conteúdo é markdown puro. Cada IA lê e executa segundo suas capacidades.

É **de governança** porque seu propósito é restringir e guiar o comportamento da IA, não amplificar capacidades dela.

### 1.4 O que o codeflow NÃO é

Estas anti-definições são tão importantes quanto as definições positivas. Cada uma corresponde a uma armadilha real que o codeflow evita.

**Não é um runtime.** Não tem CLI própria, daemon, máquina de estados, ou orquestrador. A inteligência vive nos arquivos markdown; a execução vive na IA que os lê.

**Não é um produto SaaS.** Não tem servidor, dashboard, telemetria centralizada, ou backend. É um conjunto de arquivos numa pasta.

**Não é uma biblioteca de prompts.** Prompts mudam por contexto. Workflows são protocolos estruturados com fases, gates, validações.

**Não é um agente de IA.** Agentes decidem. O codeflow restringe decisões.

**Não substitui linters, testes, ou CI.** Pelo contrário: integra com o que o projeto já tem (Makefile, lint, test) e usa esses gates como Definition of Done.

**Não é um produto a manter eternamente.** É uma camada pessoal de disciplina. Construída uma vez, evolui conforme o uso real. Sem roadmap, sem versionamento semântico rigoroso, sem ciclo de releases.

**Não impõe estrutura aos projetos.** Cada projeto continua com sua arquitetura, sua stack, seu Makefile. O codeflow aprende e respeita.

**Não toca em arquivos do projeto sem permissão.** Em particular, nunca modifica `CLAUDE.md`, `AGENTS.md`, `README.md` ou outros arquivos de doc existentes no projeto.

---

## Parte 2 — Arquitetura

### 2.1 Visão geral: duas localizações com papéis distintos

O codeflow opera em duas localizações físicas separadas, cada uma com papel distinto. Esta separação é fundamental e governa todo o resto do desenho.

```
~/.codeflow/                    ← DEFINIÇÕES reutilizáveis
  (clone do GitHub privado)
  (atualiza via git pull)
  (única na máquina, serve todos os projetos)

seu-projeto/.codeflow/          ← ESTADO específico do projeto
  (versionado no git do projeto)
  (gerado pelas meta-skills, não copiado do framework)
  (cresce conforme uso real do projeto)
```

A regra que governa o que mora onde é simples: **se é reutilizável entre projetos, mora em `~/.codeflow/`. Se é único do projeto, mora em `.codeflow/` do projeto.**

### 2.2 `~/.codeflow/` — Definições reutilizáveis

Esta localização contém **tudo que é universal** ao framework.

```
~/.codeflow/
├── framework/
│   ├── core/                       ← núcleo invariante
│   │   ├── constitution.md         ← princípios universais
│   │   ├── glossary.md             ← vocabulário oficial
│   │   ├── EVOLUTION.md            ← política de evolução do framework
│   │   └── rules/                  ← módulos temáticos opcionais
│   │       ├── code-quality.md
│   │       ├── testing.md
│   │       ├── security.md
│   │       └── naming.md
│   │
│   ├── meta/                       ← skills que criam outras coisas
│   │   ├── discover/SKILL.md       ← aprende projeto existente
│   │   ├── bootstrap/SKILL.md      ← cria projeto novo
│   │   ├── create-workflow/SKILL.md
│   │   ├── create-skill/SKILL.md
│   │   └── create-agent/SKILL.md
│   │
│   └── library/                    ← biblioteca viva (seeds + extensões)
│       ├── skills/                 ← skills universais (planas)
│       │   ├── debug-protocol/SKILL.md
│       │   ├── handoff/SKILL.md
│       │   └── self-review/SKILL.md
│       │
│       └── workflows/              ← workflows universais (planos)
│           ├── bugfix.md
│           ├── feature-small.md
│           ├── refactor-safe.md
│           └── review-only.md
│
├── andaime/                        ← documentos de construção (histórico)
│   ├── README.md
│   ├── SPEC.md
│   ├── ARTIFACTS_SPEC.md
│   ├── BUILD_PLAN.md
│   ├── VALIDATION.md
│   └── PROMPTS.md
│
├── install.sh                      ← script de instalação em projeto-alvo
└── README.md                       ← manual de uso geral
```

**Atualização:** uma vez via `git pull` em `~/.codeflow/`. Todos os projetos que usam o framework veem a mudança imediatamente (não há cópia local).

**Edição:** somente pelo mantenedor do framework (você). Workflows do dia a dia nunca modificam `~/.codeflow/`. Modificar exige operações deliberadas: `cd ~/.codeflow && git pull`, edição manual, commit, push.

### 2.3 `.codeflow/` no projeto — Estado específico

Esta localização vive **dentro de cada projeto** que usa codeflow.

```
seu-projeto/
├── .codeflow/
│   ├── INDEX.md                    ← mapa de leitura para a IA
│   ├── constitution.md             ← regras específicas deste projeto
│   ├── manifest.md                 ← stack, comandos, padrões detectados
│   ├── discovered.md               ← snapshot do onboarding
│   │
│   ├── decisions/                  ← log de decisões tomadas
│   │   ├── INDEX.md                ← índice navegável
│   │   └── <data>-<titulo>.md      ← uma decisão por workflow significativo
│   │
│   ├── checkpoints/                ← estado intermediário (efêmero)
│   │   └── <workflow>-<timestamp>.md
│   │
│   ├── workflows/                  ← workflows específicos deste projeto
│   └── skills/                     ← skills específicas deste projeto
│
└── (resto do projeto, intocado pelo codeflow)
```

**Geração:** pelos meta-skills `discover` (projeto existente) ou `bootstrap` (projeto novo). Crescimento contínuo conforme uso.

**Versionamento:** vai pro git do projeto. Equipe pega via `git pull` normal do projeto.

**Exceção:** `checkpoints/` é adicionado ao `.gitignore` pelo install. É efêmero, não vai pro git.

### 2.4 Por que essa separação

A separação entre as duas localizações resolve um problema fundamental: **definições reutilizáveis não devem ser duplicadas por projeto.**

Sem essa separação, teríamos duas opções ruins:

- **Tudo em `~/.codeflow/`**: regras do projeto X morariam fora do projeto, não viajariam com o git do projeto, equipe não pegaria.
- **Tudo em `.codeflow/` do projeto**: cada projeto teria sua cópia das skills e workflows universais. Melhorar uma skill exigiria atualizar N cópias.

A separação resolve ambos:
- Definições reutilizáveis ficam em `~/.codeflow/`, atualizadas em um lugar.
- Estado específico fica em `.codeflow/` do projeto, versionado junto com o código.

Workflows universais leem **dos dois lugares** ao executar:
- Carregam constitution universal de `~/.codeflow/framework/core/constitution.md`
- Carregam regras específicas de `.codeflow/constitution.md`
- Carregam comandos do projeto de `.codeflow/manifest.md`

Resultado: a IA tem contexto completo sem duplicação física.

### 2.5 Convivência com outros frameworks e arquivos do projeto

O codeflow é deliberadamente **paralelo** aos arquivos existentes do projeto. Não substitui, não modifica, não conflita.

**O codeflow NÃO toca em:**
- `CLAUDE.md` na raiz do projeto (mesmo se existir)
- `AGENTS.md` (idem)
- `.cursorrules` (idem)
- `.claude/` ou similar de outros frameworks
- `README.md`, `ARCHITECTURE.md`, ou qualquer doc do projeto
- Configs raiz (`package.json`, `pyproject.toml`, `.env`, etc.) — exceto durante `bootstrap` de projeto novo

**Como a IA descobre o codeflow:** via **slash commands**. Quando você invoca `/bugfix`, o slash command aponta para `~/.codeflow/framework/library/workflows/bugfix.md`, que carrega tudo necessário. Não depende de nenhum arquivo na raiz do projeto.

**Por quê:** projetos existentes têm sua própria documentação. Essa documentação pode estar desatualizada, errada, ou simplesmente diferente do que o codeflow precisa. Depender dela é frágil. O codeflow se auto-suficiência via `.codeflow/` próprio.

**Resultado prático:**
- Projeto com outro framework (ex: ritmly do exemplo): codeflow coexiste em `.codeflow/`, ignorando o framework alheio.
- Projeto sem documentação: codeflow gera `.codeflow/` próprio, suficiente para operar.
- Projeto com CLAUDE.md desatualizado: codeflow ignora, gera sua própria visão atualizada via `/discover`.

---

## Parte 3 — Decisões fundamentais

Esta parte registra as decisões de design do codeflow com justificativa explícita. Cada decisão é numerada para referência. Decisões aqui são **invioláveis durante a construção** — só podem ser alteradas mediante atualização deste documento.

Formato de cada decisão:
- **Decisão:** declaração imperativa do que será feito.
- **Justificativa:** por que essa escolha e não outras.
- **Implicações:** o que essa decisão obriga a fazer.
- **Anti-decisão:** o que essa decisão explicitamente impede.

### 3.1 Stack de implementação: bash + markdown

**Decisão:** O codeflow deve ser implementado exclusivamente em bash (para scripts) e markdown (para conteúdo). Nenhuma outra linguagem ou runtime é permitida.

**Justificativa:** Bash e markdown são universais em Linux, macOS e WSL. Não exigem instalação adicional, build, gerenciamento de dependências, ou compatibilidade de versões. O codeflow precisa funcionar imediatamente após `git clone`, sem setup. Uma versão anterior do framework (CodeFlow v1) foi descartada por se transformar em produto runtime em TypeScript com 7 pacotes — armadilha que esta decisão previne.

**Implicações:**
- Scripts auxiliares (install.sh, validators, hooks) são bash.
- Toda documentação, skills, workflows, e regras são markdown.
- Coreutils (`grep`, `sed`, `awk`, `find`, `sha256sum`) podem ser usados livremente.
- Make pode ser usado pelo projeto-alvo, mas o framework em si não exige nem distribui Makefile.

**Anti-decisão:**
- Não usar Python, Node.js, Go, Rust, ou qualquer linguagem compilada/interpretada além de bash.
- Não usar `jq`, `yq`, ou utilitários não-nativos que exigem instalação separada.
- Não criar binários, daemons, ou processos em background.
- Não criar máquina de estados, orquestrador, ou runtime próprio.

### 3.2 Idioma: pt-BR

**Decisão:** Toda documentação, comentários, mensagens e conteúdo do framework deve ser escrito em português brasileiro.

**Justificativa:** O mantenedor é falante nativo de pt-BR. Documentação na língua nativa reduz fricção cognitiva durante escrita e leitura. IAs modernas (Claude, Codex, GLM, Cursor) processam pt-BR com qualidade equivalente a inglês para tarefas técnicas. Não há ganho real em escrever em inglês neste contexto.

**Implicações:**
- README, SKILL.md, workflows, constitution: tudo em pt-BR.
- Mensagens de scripts bash (echo, error messages): pt-BR.
- Nomes de arquivos e pastas: kebab-case em inglês (ex: `debug-protocol`, `feature-small`) por convenção técnica, mas conteúdo dentro deles em pt-BR.
- Glossário oficial em pt-BR.

**Anti-decisão:**
- Não criar versão em inglês paralela.
- Não misturar idiomas dentro do mesmo arquivo.
- Não traduzir termos técnicos consagrados em inglês (ex: "commit", "diff", "workflow" permanecem).

### 3.3 Distribuição: GitHub privado com atualização via git pull

**Decisão:** O framework deve ser distribuído como repositório Git privado no GitHub. Atualizações chegam aos usuários via `git pull` natural.

**Justificativa:** Git é universal, gratuito, versionado, e suporta privacidade nativa. Não há necessidade de empacotador (npm, pip, brew), servidor próprio, ou mecanismo customizado de update. Repositório privado evita exposição prematura enquanto framework amadurece. Pode ser tornado público no futuro com um clique.

**Implicações:**
- Mantenedor edita em `~/Projetos/codeflow/`, commit, push.
- Usuários atualizam com `cd ~/.codeflow && git pull` (ou equivalente via symlink).
- Versionamento de release segue tags git semânticas quando aplicável.
- Colaboradores recebem acesso via GitHub collaborator (read-only por padrão).

**Anti-decisão:**
- Não publicar em npm, pip, brew, ou qualquer package manager.
- Não criar servidor de updates, CDN, ou mecanismo próprio de distribuição.
- Não usar git submodule (problemático em equipes; bloqueia customização local).
- Não distribuir como zip ou tarball — atualizações ficariam manuais.

### 3.4 Localização única: `~/.codeflow/` (via symlink)

**Decisão:** O framework deve ser clonado em `~/Projetos/codeflow/` e exposto como `~/.codeflow/` via symlink. Toda referência interna do framework usa o caminho `~/.codeflow/`.

**Justificativa:** Centralizar em `~/.codeflow/` torna referências previsíveis e portáveis entre máquinas (caminho usa `~`, resolvido pela shell ou IA). Manter o desenvolvimento em `~/Projetos/codeflow/` honra a organização do mantenedor (todos os projetos juntos). Symlink elimina duplicação: editar uma versão atualiza ambas instantaneamente.

**Implicações:**
- Comando de setup: `git clone ... ~/Projetos/codeflow && ln -s ~/Projetos/codeflow ~/.codeflow`.
- Workflows, skills, constitutions referenciam sempre `~/.codeflow/...`.
- Projeto-alvo nunca tem cópia do framework — apenas referencia.
- Mudança no framework propaga para todos os projetos sem ação adicional.

**Anti-decisão:**
- Não copiar o framework para dentro de cada projeto.
- Não usar caminho absoluto literal (`/home/usuario/.codeflow/...`) — quebra entre máquinas.
- Não usar variável de ambiente `$CODEFLOW_HOME` — complexidade desnecessária para localização fixa.
- Não exigir clone duplicado (uma cópia para desenvolver, outra para usar) — sincronização manual é frágil.

### 3.5 Organização: universais planas + projetos isolados (Abordagem 3)

**Decisão:** Skills e workflows universais ficam planos em `framework/library/skills/` e `framework/library/workflows/`. Versões específicas de projeto vivem em `.codeflow/skills/` e `.codeflow/workflows/` dentro do projeto.

**Justificativa:** Esta organização escala bem: universais ficam fáceis de listar e gerenciar (sem prefixos artificiais), específicos ficam isolados em "ilhas" por projeto. Promover uma skill de projeto para universal é trivial (`git mv`). A separação entre origem e escopo é clara.

**Implicações:**
- Workflows seed iniciais (bugfix, feature-small, refactor-safe, review-only) vivem em `framework/library/workflows/`.
- Quando um projeto precisa de workflow específico, é criado em `.codeflow/workflows/` do projeto via `/create-workflow`.
- Quando um workflow específico se prova útil em múltiplos projetos, é promovido manualmente para `framework/library/workflows/`.

**Anti-decisão:**
- Não usar prefixos artificiais em skills universais (ex: `financas--auth-debug`).
- Não aninhar workflows universais em subpastas temáticas — manter flat.
- Não criar hierarquia complexa em `.codeflow/` do projeto — manter simples (skills e workflows como subpastas diretas).

### 3.6 Invocação: slash commands disparados pelo usuário

**Decisão:** Workflows são invocados exclusivamente pelo usuário, via slash commands nativos da ferramenta de IA (`/bugfix`, `/feature-small`, etc.). A IA nunca escolhe workflow sozinha.

**Justificativa:** Disciplinar a IA exige tirar dela a decisão de "qual processo seguir". O usuário, ao invocar um workflow, está explicitamente declarando o tipo de tarefa e ativando o protocolo correspondente. Slash commands existem nativamente em Claude Code, Codex, Cursor — não inventamos mecanismo novo. O nome do arquivo do workflow é o nome do comando.

**Implicações:**
- Cada workflow em `framework/library/workflows/<nome>.md` se torna automaticamente `/nome` na ferramenta de IA.
- A IA não tenta classificar a tarefa do usuário em workflow — ela apenas executa o que foi invocado.
- Se o usuário pedir tarefa sem invocar workflow, a IA opera em "modo livre" (sem protocolo), guiada apenas pela constitution.

**Anti-decisão:**
- Não criar mecanismo de "roteamento automático" da tarefa para workflow.
- Não criar meta-skill que decida workflow baseado na mensagem do usuário.
- Não exigir que toda mensagem do usuário seja precedida por slash command.

#### 3.6.1 Implementação em Claude Code

A decisão acima delegou à ferramenta de IA o disparo de workflows. Esta subseção documenta como o disparo é materializado **em Claude Code**. Outras ferramentas (Codex, Cursor) suportam mecanismo análogo; adapters específicos ficam fora do escopo da v1.0.0.

**Mecanismo.** Claude Code descobre slash commands custom em dois caminhos nativos:

- `~/.claude/commands/<nome>.md` — disponível em qualquer projeto (escopo de usuário).
- `<projeto>/.claude/commands/<nome>.md` — disponível apenas dentro do projeto (escopo local). Sobrescreve homônimo universal.

O codeflow não tenta substituir esse mecanismo. Em vez disso, **gera wrappers** nesses caminhos que apontam para os arquivos reais em `~/.codeflow/framework/` (universal) ou `<projeto>/.codeflow/` (projeto).

**Mapeamento.** Para cada workflow `framework/library/workflows/<nome>.md`, existe wrapper `~/.claude/commands/<nome>.md`. Para cada meta-skill seed `framework/meta/<nome>/SKILL.md` declarada com slash command (todas as cinco do escopo inicial: `discover`, `bootstrap`, `create-workflow`, `create-skill`, `create-agent`), existe wrapper `~/.claude/commands/<nome>.md`. Skills regulares (`framework/library/skills/*/SKILL.md`) **não** ganham wrapper — são carregadas via `## LEIA TAMBÉM` de workflows, não disparadas direto. Agents também não — são invocados de dentro de workflows.

A nível de projeto: cada workflow em `<projeto>/.codeflow/workflows/<nome>.md` ganha wrapper correspondente em `<projeto>/.claude/commands/<nome>.md` quando `install.sh` roda no projeto.

**Conteúdo do wrapper.** Formato literal definido em `ARTIFACTS_SPEC.md` §1.11. Resumo: 2-4 linhas em pt-BR instruindo a IA a ler o arquivo real e executar o protocolo, carregando `## LEIA TAMBÉM` antes. Sem lógica adicional, sem duplicação de conteúdo.

**Setup universal: `setup-slash-commands.sh`.** Script na raiz do framework. Varre `framework/library/workflows/` e `framework/meta/`, gera/atualiza wrappers em `~/.claude/commands/`. Idempotente. Detecta órfãos (wrapper que aponta para arquivo inexistente) — apenas avisa por padrão; remove com flag `--prune`. Roda **uma vez por máquina** ao instalar o framework, e novamente sempre que workflows ou meta-skills universais são adicionados ou removidos. A meta-skill `create-workflow` invoca o script automaticamente ao gerar workflow universal.

**Setup de projeto: extensão de `install.sh`.** Após criar `.codeflow/` no projeto, se `<projeto>/.codeflow/workflows/` existe e contém arquivos, `install.sh` gera wrappers em `<projeto>/.claude/commands/`. Roda toda vez que `install.sh` é invocado (idempotente).

**Implicações operacionais:**
- Editar conteúdo de workflow ou meta-skill **não** exige rodar o setup — wrappers apontam para path, não copiam conteúdo.
- Adicionar ou remover workflow/meta-skill universal exige rodar `setup-slash-commands.sh` (ou usar `create-workflow` que dispara automaticamente).
- Trocar de máquina exige rodar `setup-slash-commands.sh` uma vez no setup inicial.

**Anti-decisão (complementa §3.6):**
- Não inventar registry, banco de dados, ou runtime para slash commands. O mecanismo é uma pasta com arquivos.
- Não embutir lógica nos wrappers além de "leia X e execute". Lógica vive no workflow.
- Não gerar wrappers para skills regulares ou agents — viola o modelo de composição (`SPEC.md` §4.3.4, §4.5).

### 3.7 Sessão fresca por workflow

**Decisão:** Cada invocação de workflow significativo deve acontecer em uma **sessão nova** da ferramenta de IA (chat novo, contexto limpo). A constitution é carregada uma vez no início dessa sessão.

**Justificativa:** Auto-compactação é a principal causa de degradação de qualidade em sessões longas. A constitution e os artefatos do projeto, sendo lidos no início, podem ser descartados quando a sessão fica grande. Sessões novas eliminam esse risco: cada workflow começa com contexto limpo, carrega o necessário, executa, termina antes de atingir limite de contexto.

**Implicações:**
- A constitution deve ser **curta e densa** (50-100 linhas) para caber no contexto inicial sem competir com a tarefa.
- Workflows devem ser **autossuficientes**: declaram explicitamente o que carregar.
- Disciplina do usuário: invocar `/bugfix` em chat novo, não no chat anterior.
- Workflows longos (granularidade detalhada) usam checkpoints para sobreviver a sessões maiores.

**Anti-decisão:**
- Não tentar manter contexto entre workflows via memória persistente da IA.
- Não inflar a constitution com detalhes operacionais — eles vivem em workflows específicos.
- Não criar mecanismo de "lembrar" sessão anterior — artefatos versionados em `.codeflow/` cumprem esse papel.

### 3.8 Comportamento quando workflow não encaixa

**Decisão:** Quando o usuário invoca um workflow que não combina perfeitamente com a tarefa, a IA deve avisar e sugerir alternativas (incluindo criar workflow novo). A decisão final é do usuário: se ele insistir, a IA executa.

**Justificativa:** Usuário pode usar nomenclatura imprecisa ou pedir tarefa fora do escopo padrão. Bloquear seria rígido demais; executar silenciosamente seria perigoso. Avisar + obedecer respeita autonomia do usuário com proteção mínima.

**Implicações:**
- Cada workflow declara explicitamente "Quando usar" e "Quando NÃO usar".
- Se a tarefa do usuário cai em "Quando NÃO usar", IA avisa e sugere workflow alternativo ou criação de novo.
- Se usuário responde "execute mesmo assim", IA executa registrando observação no resumo final.

**Anti-decisão:**
- Não bloquear execução por divergência de workflow.
- Não executar silenciosamente quando há divergência clara.
- Não criar mecanismo de "aprovação obrigatória" — a IA segue a decisão final do usuário.

### 3.9 install.sh: instalação mínima sem tocar no projeto

**Decisão:** O script `install.sh` deve criar apenas a estrutura `.codeflow/` no projeto-alvo. Não deve modificar nenhum arquivo na raiz do projeto.

**Justificativa:** Projetos existentes têm CLAUDE.md, README, configs próprias — muitas vezes versionadas, com convenções de equipe, ou simplesmente em formato que não bate com o codeflow. Modificá-las introduziria conflitos e ruído. A IA descobre o codeflow via slash commands, não via arquivos na raiz.

**Implicações:**
- `install.sh` cria: `.codeflow/INDEX.md` (placeholder), `.codeflow/decisions/`, `.codeflow/checkpoints/`.
- `install.sh` verifica pré-requisitos: existe git? existe `~/.codeflow/`? existe Makefile (apenas aviso)?
- `install.sh` adiciona `.codeflow/checkpoints/` ao `.gitignore` do projeto (cria `.gitignore` se ausente).
- `install.sh` imprime mensagem com próximos passos (`/discover` ou `/bootstrap`).
- Constitution, manifest, discovered.md são gerados depois, pelos meta-skills, não pelo install.

**Anti-decisão:**
- `install.sh` não modifica CLAUDE.md, AGENTS.md, README, ou qualquer arquivo na raiz.
- `install.sh` não cria constitution, manifest, ou discovered.md — esses dependem de conhecimento do projeto, que o install não tem.
- `install.sh` não roda git init nem altera configurações do git.
- `install.sh` não instala dependências, não baixa nada, não modifica nada fora de `.codeflow/`.

### 3.10 Make como abstração canônica de execução

**Decisão:** Workflows usam targets `make` para executar comandos de validação do projeto. O subconjunto mínimo esperado é: `make check`, `make test`, `make lint`, `make typecheck`.

**Justificativa:** Make é universal em Linux/macOS/WSL, executável sem instalação adicional (em ambientes mainstream), versionável no projeto, e útil para humanos além do codeflow. Centraliza comandos do projeto em um arquivo. Permite ao codeflow ser agnóstico de stack: `make test` funciona seja pytest, vitest, ou go test por baixo.

**Implicações:**
- Workflows que validam código rodam `make check` (ou alternativas equivalentes) no Definition of Done.
- `discover` propõe criar Makefile básico se ausente.
- `bootstrap` cria Makefile com targets canônicos no projeto novo.
- Workflows toleram targets ausentes: se `make typecheck` não existe, marca como "pulado", não como falha.
- Codeflow não duplica funcionalidades que Make já oferece (logging, guards, prompts) — usa o que o projeto tem.

**Anti-decisão:**
- Não criar `validators/` plugáveis paralelos ao Makefile.
- Não exigir conjunto rígido de targets — projeto pode ter mais, mas precisa ter o mínimo para workflows funcionarem plenamente.
- Não invocar comandos brutos diretamente (ex: `pytest tests/`) — sempre via `make`.
- Não exigir Make em ambientes onde não está disponível (Windows nativo sem WSL) — nesse caso, workflows operam em modo degradado, perguntando comandos.

---

## Parte 4 — Conceitos centrais

Esta parte define cada elemento do codeflow: o que é, qual seu propósito, onde mora, como é estruturado, e como se relaciona com outros elementos.

A ordem dos conceitos segue dependência: começa com constitution (base de tudo), passa por skills, workflows, meta-skills, agents, rules, e termina com artefatos.

### 4.1 Constitution

A **constitution** é o conjunto de regras invariantes que governam o comportamento da IA. Existe em duas versões: universal e de projeto.

#### 4.1.1 Constitution universal

**Localização:** `~/.codeflow/framework/core/constitution.md`

**Propósito:** declarar os princípios universais que valem em qualquer projeto. É a "lei do framework codeflow".

**Características obrigatórias:**
- **Curta e densa:** entre 50 e 100 linhas. Deve caber no contexto inicial de qualquer sessão sem competir com a tarefa.
- **Imperativa:** usa "deve" / "não deve". Nunca "preferencialmente" ou "recomendado".
- **Auto-suficiente:** lida com fundamentos universais (diff mínimo, política de falhas padrão, regra de escopo). Não depende de outros arquivos para fazer sentido.
- **Versionada:** começa com cabeçalho `Versão: X.Y | Atualizado: AAAA-MM-DD | Status: Estável`.

**Conteúdo mínimo obrigatório — 5 seções `##` na ordem fixa (ver `ARTIFACTS_SPEC.md` §1.1.3):**
- `## Princípios invariantes` — exatamente 4 princípios: diff mínimo, declaração de escopo antes de modificar, seguir convenções existentes, comentários só registram "por quê" não-óbvio. Inclui também, como bullet final desta seção, a regra de mudanças quebradoras (exigem detecção e documentação explícita antes de aplicar).
- `## Política de falhas` — classificação Transitória/Lógica/Escopo/Ambiente, limite de 2 tentativas para Lógica.
- `## Formato PARADO` — formato literal de reporte (PARADO/Estado atual/Bloqueador/Opções), em seção separada de Política de falhas.
- `## Proibições absolutas` — não modificar arquivos protegidos sem instrução (framework alheio na raiz, configs globais, secrets/.env, pastas marcadas).
- `## Quando esta constitution se aplica` — escopo de carregamento e relação com a constitution de projeto (estende, não substitui).

**Anti-características:**
- Não contém detalhes operacionais de workflows específicos (esses vivem nos workflows).
- Não contém regras de stack ou linguagem (essas vivem em rules ou na constitution do projeto).
- Não muda frequentemente (versão raramente passa de 2.x).

#### 4.1.2 Constitution de projeto

**Localização:** `<projeto>/.codeflow/constitution.md`

**Propósito:** declarar as regras específicas daquele projeto que estendem (ou sobrescrevem) a constitution universal.

**Características obrigatórias:**
- **Personalizada:** gerada pelo `discover` ou `bootstrap` baseada em inspeção do projeto e respostas do usuário.
- **Concreta:** menciona stack, padrões arquiteturais, áreas de alto risco, bibliotecas proibidas — coisas específicas do projeto.
- **Versionada:** mesmo cabeçalho que a universal.

**Conteúdo típico:**
- Stack do projeto (linguagem, frameworks, banco, libs principais).
- Padrão arquitetural detectado/escolhido.
- Regras invariantes específicas (ex: "nunca usar SQLAlchemy", "tudo em pt-BR", "auth via JWT short-lived").
- Áreas de alto risco com política específica (ex: "pasta /admin/* exige cuidado extra").
- Definition of Done específica do projeto, se diferir da padrão.

**Relação com constitution universal:**
- Em caso de conflito, **constitution de projeto vence**.
- Workflows carregam **ambas** em ordem: universal primeiro, projeto depois (sobrescreve).

### 4.2 Workflows

Um **workflow** é um arquivo markdown que descreve uma sequência ordenada de passos para realizar uma tarefa repetitiva. É o que a IA executa quando o usuário invoca um slash command.

#### 4.2.1 Localização

- **Universais:** `~/.codeflow/framework/library/workflows/<nome>.md`
- **Específicos de projeto:** `<projeto>/.codeflow/workflows/<nome>.md`

Workflows específicos de projeto **sobrescrevem** universais de mesmo nome. Se ambos existem com nome `bugfix`, o do projeto é carregado.

#### 4.2.2 Granularidade variável

Workflows têm tamanho proporcional à complexidade da tarefa. Três categorias:

**Magro (~20-30 linhas):** uma ação clara, sem decisões intermediárias. Exemplos: `review-only`, `format-check`.

**Médio (~60-100 linhas):** sequência de passos com validações entre eles. Exemplos: `bugfix`, `feature-small`, `refactor-safe`.

**Detalhado (~150-300 linhas):** conversa estruturada com o usuário, múltiplas decisões abertas. Exemplos: `bootstrap`, `discover`.

**Critério de escolha:** A IA pode fazer sem perguntar? → Magro. Sequência com validações automáticas? → Médio. Conduz conversa com usuário? → Detalhado. Em caso de dúvida entre dois, escolher o menor.

#### 4.2.3 Estrutura obrigatória

Todo workflow contém, na ordem:

1. **Cabeçalho com metadata:**
   - Versão (`X.Y`)
   - Status (`Estável` / `Experimental` / `Deprecated`)
   - Granularidade (`magro` / `médio` / `detalhado`)
   - Gera decision (`yes` / `no` / `auto`)
   - Usa checkpoints (`yes` / `no`)
   - Override de política de falhas (campo opcional)

2. **Seção "Quando usar":** descrição imperativa de quando esse workflow é apropriado.

3. **Seção "Quando NÃO usar":** anti-casos. A IA usa isso para avisar o usuário se a tarefa não combina.

4. **Seção "LEIA TAMBÉM":** lista de arquivos que a IA deve carregar antes de começar. Inclui:
   - `~/.codeflow/framework/core/constitution.md` (sempre)
   - `.codeflow/INDEX.md` do projeto (sempre)
   - `.codeflow/constitution.md` do projeto (sempre)
   - `.codeflow/manifest.md` do projeto (sempre)
   - Skills universais relevantes (ex: `~/.codeflow/framework/library/skills/debug-protocol/SKILL.md` para workflow bugfix)
   - Rules temáticas relevantes (ex: `~/.codeflow/framework/core/rules/testing.md` para workflows que tocam testes)

5. **Protocolo:** sequência ordenada de passos. Cada passo:
   - Tem objetivo claro.
   - Pode ter regras específicas (sub-bullets).
   - Pode ter gates de falha (o que fazer se falhar).
   - Em workflows detalhados, pode pausar para checkpoint.

6. **Definition of Done:** checklist objetivo de conclusão. Inclui:
   - Itens verificáveis pela IA (ex: "todos os passos do protocolo foram executados").
   - Itens validados por script via `make` (ex: "make check passou").
   - Itens documentais (ex: "decision foi gerada se aplicável").

7. **Seção "Resumo final":** template do formato fixo de 5 seções (estado, mudanças, checklist, riscos, próximos) que a IA apresenta ao terminar.

#### 4.2.4 Dependências do workflow

Workflows usam **referências explícitas** para puxar contexto. A IA é instruída a ler os arquivos listados em "LEIA TAMBÉM" antes de começar. Não há mecanismo automático de carregamento — a instrução é parte do workflow.

Workflows **não copiam** conteúdo de constitution ou skills. Apenas referenciam. Isso evita duplicação e propaga atualizações automaticamente.

### 4.3 Skills

Uma **skill** é um arquivo markdown que encapsula uma capacidade discreta e reutilizável. Diferente de workflow (que é processo), skill é capacidade.

#### 4.3.1 Localização

- **Universais:** `~/.codeflow/framework/library/skills/<nome>/SKILL.md`
- **Específicas de projeto:** `<projeto>/.codeflow/skills/<nome>/SKILL.md`

Cada skill vive em sua **própria pasta**, contendo no mínimo o arquivo `SKILL.md`. A pasta pode conter arquivos auxiliares (templates, exemplos, scripts).

#### 4.3.2 Skills seed do framework

O framework é entregue com três skills universais iniciais:

**`debug-protocol`:** protocolo anti-loop para debug. Define: reproduzir antes de hipotetizar, uma hipótese por vez, máximo 3 tentativas, parar e reportar se 3 falham. Carregada por workflows tipo `bugfix`.

**`handoff`:** protocolo de passagem de bastão entre sessões. Define como a IA registra estado antes de auto-compactação ou quebra de sessão. Carregada por workflows detalhados.

**`self-review`:** checklist objetivo que a IA aplica antes de marcar tarefa como concluída. Inclui: diff dentro do escopo? estilo consistente? riscos identificados? Carregada por todos os workflows que modificam código.

#### 4.3.3 Estrutura obrigatória de uma skill

Todo SKILL.md contém:

1. **Cabeçalho com metadata:** versão, status, descrição em uma linha.

2. **Seção "Quando usar":** condições objetivas que indicam que a skill deve ser carregada/aplicada.

3. **Seção "Princípio guia":** uma ou duas frases que resumem a filosofia da skill.

4. **Seção "Protocolo":** passos da skill em sequência. Diferente de workflow, skills não têm Definition of Done — elas são aplicadas dentro de workflows.

5. **Seção "Proibições durante esta skill":** o que NÃO fazer enquanto a skill está ativa.

6. **Seção "Saídas válidas":** o que a skill produz como resultado.

#### 4.3.4 Composição com workflows

Workflows referenciam skills em sua seção "LEIA TAMBÉM". Quando carregadas juntas, skill e workflow operam em camadas:

- Workflow define **o quê** fazer (sequência).
- Skill define **como** fazer cada coisa bem.

Exemplo: workflow `bugfix` referencia skill `debug-protocol`. O workflow diz "Passo 2: formar hipótese e implementar". A skill `debug-protocol` detalha como formar hipótese: uma por vez, declarada explicitamente, com critério de teste claro.

### 4.4 Meta-skills

Uma **meta-skill** é uma skill cujo propósito é **criar outros artefatos do framework**. São skills sobre skills.

#### 4.4.1 Localização

`~/.codeflow/framework/meta/<nome>/SKILL.md`

Meta-skills sempre são universais. Não existem versões específicas de projeto.

#### 4.4.2 Meta-skills obrigatórias

O framework é entregue com cinco meta-skills:

**`discover`:** aprende um projeto existente. Conduz inspeção silenciosa, formula hipóteses, faz no máximo 5 perguntas, gera os artefatos iniciais (INDEX.md, constitution.md, manifest.md, discovered.md). Granularidade detalhada.

**`bootstrap`:** cria um projeto novo a partir de uma ideia. Conduz conversa estruturada (escopo, stack, padrão arquitetural, regras), gera estrutura de pastas, configs iniciais, Makefile, e os artefatos do codeflow. Granularidade detalhada.

**`create-workflow`:** entrevista o usuário para criar um workflow novo. Pergunta nome, escopo, granularidade, passos, gera o arquivo no formato correto.

**`create-skill`:** entrevista o usuário para criar uma skill nova. Pergunta nome, propósito, protocolo, gera o arquivo no formato correto.

**`create-agent`:** entrevista o usuário para criar uma definição de subagente com escopo restrito.

#### 4.4.3 Estrutura especial de meta-skills

Meta-skills seguem a estrutura geral de skills, mas com adições obrigatórias:

- **Seção "Template de saída":** o formato exato do arquivo que será gerado, com placeholders.
- **Seção "Onde salvar":** caminho exato do arquivo gerado (universal vs projeto).
- **Seção "Validação pós-geração":** verificações que a IA faz no arquivo recém-criado antes de apresentar ao usuário.

### 4.5 Agents

Um **agent** (no contexto do codeflow) é uma definição de subagente com escopo de ferramentas restrito. Não é a IA em si — é uma instância especializada da IA com permissões limitadas.

#### 4.5.1 Localização

- **Universais:** `~/.codeflow/framework/library/agents/<nome>.md`
- **Específicos de projeto:** `<projeto>/.codeflow/agents/<nome>.md`

#### 4.5.2 Propósito

Agents são usados quando um workflow precisa isolar uma sub-tarefa em contexto próprio. Exemplo: workflow `feature-small` pode delegar a parte de "revisar diff antes de commitar" a um agent `code-reviewer` com escopo restrito (só pode ler, não escrever).

#### 4.5.3 Estrutura obrigatória

Todo arquivo de agent contém:

1. **Cabeçalho:** versão, status, nome.
2. **Seção "Propósito":** o que o agent faz e por que existe como agent (não como skill).
3. **Seção "Ferramentas permitidas":** lista de tools/capacidades que o agent pode usar (ex: Read, Glob, Grep mas não Edit ou Bash).
4. **Seção "System prompt":** o prompt de sistema do agent, incluindo restrições.
5. **Seção "Como invocar":** instrução para workflows que querem usar esse agent.

#### 4.5.4 Status no escopo inicial

Agents são **opcionais** no escopo inicial do framework. Apenas a meta-skill `create-agent` é criada, mas nenhum agent seed é entregue. Agents são criados sob demanda quando o usuário identifica necessidade real de isolar contexto.

### 4.6 Rules

**Rules** são módulos temáticos opcionais que estendem a constitution. Existem para que workflows carreguem **apenas as regras relevantes** à sua tarefa, sem inflar a constitution principal.

#### 4.6.1 Localização

- **Universais:** `~/.codeflow/framework/core/rules/<tema>.md`
- **Específicas de projeto:** `<projeto>/.codeflow/rules/<tema>.md`

#### 4.6.2 Rules universais entregues no escopo inicial

O framework é entregue com quatro rules universais:

**`code-quality.md`:** regras de qualidade aplicáveis a qualquer linguagem (nomes descritivos, funções pequenas, sem código morto, comentários explicam porquê não o quê).

**`testing.md`:** regras de teste agnósticas (todo código novo tem teste, testes descrevem comportamento, nunca deletar teste para fazê-lo passar, novos testes antes ou junto com código novo).

**`security.md`:** regras de segurança agnósticas (nunca commitar secrets, validar entrada, sanitizar saída, princípio do menor privilégio).

**`naming.md`:** regras de nomenclatura (nomes descritivos, kebab-case para arquivos, evitar abreviações obscuras, consistência com o que já existe no projeto).

#### 4.6.3 Estrutura obrigatória de uma rule

Toda rule contém:

1. **Cabeçalho:** versão, status, escopo (universal ou específico).
2. **Seção "Quando carregar":** condições que indicam que workflows devem incluir essa rule.
3. **Seção "Regras":** lista de regras imperativas, agrupadas por tema.
4. **Seção "Anti-regras":** o que explicitamente NÃO fazer (igualmente imperativo).
5. **Seção "Exceções":** casos em que a regra pode ser relaxada, com justificativa.

#### 4.6.4 Relação com workflows

Workflows declaram quais rules carregam em "LEIA TAMBÉM". Não toda rule é carregada em todo workflow — só as relevantes.

Exemplos:
- Workflow `bugfix` carrega `code-quality.md` e `testing.md`.
- Workflow `refactor-safe` carrega `code-quality.md` e `naming.md`.
- Workflow `review-only` carrega `code-quality.md`, `testing.md`, e `security.md`.

#### 4.6.5 Relação com constitution

Rules **estendem** a constitution, não a substituem. Constitution define princípios universais; rules detalham aplicação por tema.

Conflito de prioridade: constitution > rules. Mas rules raramente conflitam com constitution — elas operam em níveis diferentes.

### 4.7 Artefatos

**Artefatos** são arquivos gerados pelo codeflow durante o uso e que vivem dentro de `.codeflow/` do projeto. Diferem de conteúdo do framework (que mora em `~/.codeflow/` e é fixo).

#### 4.7.1 Tipos de artefatos

Existem sete tipos de artefatos no codeflow:

**`INDEX.md`:** mapa de leitura prioritária do `.codeflow/`. Gerado por `discover` ou `bootstrap`. Indica à IA em que ordem ler os outros artefatos.

**`constitution.md`:** regras específicas do projeto (já descrito em 4.1.2). Gerado por `discover` ou `bootstrap`.

**`manifest.md`:** descreve stack, comandos make, padrões detectados do projeto. Gerado por `discover` ou `bootstrap`. Contém `validation_hash` e `last_validated` para detecção de obsolescência.

**`discovered.md`:** snapshot do onboarding. Registra o que a IA inspecionou, hipóteses formadas, perguntas em aberto. Gerado apenas por `discover`. Não é atualizado depois — para reaprender, gera-se novo snapshot datado.

**`decisions/<arquivo>.md`:** registro leve de decisões tomadas durante workflows significativos. Um arquivo por workflow que declara `gera_decision: yes`. Formato com header estruturado (data, workflow, tags, status, supersede, relaciona-com).

**`decisions/INDEX.md`:** índice navegável de todas as decisões. Atualizado automaticamente toda vez que uma decision nova é gerada. Permite a IA filtrar decisões por tag, data, ou status sem carregar todos os arquivos.

**`checkpoints/<workflow>-<timestamp>.md`:** estado intermediário de workflows detalhados em execução. Gerado automaticamente entre passos longos. Efêmero — deletado ao fim do workflow bem-sucedido. Vai para `.gitignore`.

#### 4.7.2 Regras universais de artefatos

Três disciplinas se aplicam a todos os artefatos:

**Localização fixa:** cada tipo tem um caminho exato. A IA nunca inventa onde salvar.

**Formato definido por template:** cada artefato tem template (no framework ou na meta-skill que o gera). IA preenche, não inventa formato.

**Gatilho explícito:** geração nunca é silenciosa. Ou foi declarada no workflow, ou foi pedida pelo usuário, ou é automática em momento previsto (checkpoint).

#### 4.7.3 Versionamento

Artefatos vão para o git do projeto. Exceção: `checkpoints/` é adicionado ao `.gitignore` pelo `install.sh`.

#### 4.7.4 Detalhamento técnico

A especificação completa de schema (campos exatos, exemplos preenchidos) de cada artefato vive em `ARTIFACTS_SPEC.md`, não neste documento. Este SPEC define **o que cada artefato é**; o ARTIFACTS_SPEC define **o formato exato**.

---

## Parte 5 — Estrutura interna detalhada de workflows

A Parte 4 introduziu workflows como conceito. Esta parte detalha a mecânica interna: como referências funcionam, como cada granularidade é construída, como falhas são tratadas, como conclusão é validada.

### 5.1 Como workflows puxam dependências

Workflows usam **referências explícitas** no início do arquivo. A IA é instruída a ler todos os arquivos listados antes de começar o protocolo.

**Mecanismo:** seção "LEIA TAMBÉM" obrigatória logo após o cabeçalho. Cada item é um caminho absoluto (com `~`) que a IA resolve e carrega no contexto da sessão.

**Ordem de carregamento (orientativa, não estrita):**
1. Constitution universal (`~/.codeflow/framework/core/constitution.md`)
2. INDEX.md do projeto (`.codeflow/INDEX.md`)
3. Constitution do projeto (`.codeflow/constitution.md`)
4. Manifest do projeto (`.codeflow/manifest.md`)
5. Rules temáticas relevantes (uma ou mais de `~/.codeflow/framework/core/rules/*.md`)
6. Skills relevantes (uma ou mais de `~/.codeflow/framework/library/skills/*/SKILL.md`)
7. Decisões anteriores relevantes (consulta opcional ao `.codeflow/decisions/INDEX.md` por tag)

A ordem listada acima é **orientativa, não estrita**. Workflows podem agrupar referências por afinidade lógica — por exemplo, listar as rules logo após a constitution universal, ou colocar skills antes do manifest quando isso melhora a legibilidade. O que importa é que todas as referências necessárias estejam presentes em `## LEIA TAMBÉM` antes do início do protocolo.

**Princípio:** workflows não duplicam conteúdo. Eles **apontam**. Atualização de uma skill propaga automaticamente para todos os workflows que a referenciam.

**Anti-mecanismo:** não existe carregamento automático ou descoberta mágica. A instrução de leitura está visível no workflow, é executada explicitamente pela IA. Se um workflow esquece de referenciar uma skill, ela não é carregada.

### 5.2 Anatomia de um workflow magro (~20-30 linhas)

Workflows magros são usados quando a IA executa **uma ação clara sem decisões intermediárias**. Exemplo canônico: `review-only`.

**Estrutura obrigatória:**

```markdown
---
versão: 1.0
status: estável
granularidade: magro
gera_decision: no
usa_checkpoints: no
---

# Workflow: <nome>

## Quando usar
<2-3 linhas descrevendo o caso de uso>

## Quando NÃO usar
- <caso 1 e workflow alternativo>
- <caso 2 e workflow alternativo>

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- (skills/rules específicas)

## Protocolo
1. <passo único ou 2-3 passos curtos>
2. ...

## Definition of Done
- [ ] <item 1>
- [ ] <item 2>

## Resumo final
<template do formato fixo de 5 seções>
```

**Características:**
- Não inclui política de falhas (herda do padrão da constitution).
- Não gera decision.
- Não usa checkpoints.
- Total: 20-30 linhas.

### 5.3 Anatomia de um workflow médio (~60-100 linhas)

Workflows médios são usados para **sequências de passos com validações intermediárias**. Exemplos canônicos: `bugfix`, `feature-small`, `refactor-safe`.

**Estrutura obrigatória:**

```markdown
---
versão: 1.0
status: estável
granularidade: médio
gera_decision: yes (ou no para refactor-safe)
usa_checkpoints: no
politica_falhas: padrão (ou override declarado)
---

# Workflow: <nome>

## Quando usar
<3-5 linhas descrevendo o caso de uso e pré-requisitos>

## Quando NÃO usar
- <casos com workflow alternativo>

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/<skill-relevante>/SKILL.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md

## Antes de começar

Se a tarefa toca em <tags relevantes>, consulte `.codeflow/decisions/INDEX.md`
e carregue decisões ATIVAS encontradas.

## Protocolo

### Passo 1 — <nome do passo>
- <regra 1>
- <regra 2>
- Gate: <condição para passar para Passo 2>

### Passo 2 — <nome>
- ...

### Passo 3 — <nome>
- ...

### Passo 4 — Validar
- Executar `make check` (ou alternativas conforme manifest)
- Se falhar: aplicar política de falhas da constitution

### Passo 5 — Resumir e (se aplicável) gerar decision

## Definition of Done
- [ ] Todos os passos do protocolo concluídos
- [ ] make check passou
- [ ] Diff dentro do escopo declarado
- [ ] Teste adicionado se aplicável
- [ ] Decision gerada se workflow declara gera_decision: yes

## Resumo final
<template do formato fixo de 5 seções>
```

**Características:**
- 4 a 7 passos sequenciais.
- Pode gerar decision.
- Política de falhas geralmente padrão (override raro).
- Total: 60-100 linhas.

### 5.4 Anatomia de um workflow detalhado (~150-300 linhas)

Workflows detalhados conduzem **conversa estruturada com o usuário**, geralmente em múltiplas fases, com decisões abertas. Exemplos canônicos: `discover`, `bootstrap`.

**Estrutura obrigatória:**

```markdown
---
versão: 1.0
status: estável
granularidade: detalhado
gera_decision: yes
usa_checkpoints: yes
politica_falhas: padrão (ou override)
---

# Workflow: <nome>

## Princípio guia
<2-3 linhas declarando a filosofia do workflow>

## Quando usar
<descrição extensa: contexto, pré-requisitos, audiência>

## Quando NÃO usar
- <casos com workflow alternativo>

## LEIA TAMBÉM
<lista extensa>

## Estrutura do workflow

Este workflow opera em N fases. Cada fase tem objetivo, ações, e checkpoint.

## Fase 1 — <nome>
### Objetivo
<o que essa fase entrega>

### Ações
1. ...
2. ...

### Checkpoint
Ao fim desta fase, grave estado em `.codeflow/checkpoints/<workflow>-<timestamp>.md`
com:
- Fase atual concluída
- Decisões tomadas
- Próxima fase planejada

## Fase 2 — <nome>
<mesma estrutura>

## Fase N — Geração de artefatos
<o que será gerado e onde>

## Proibições durante este workflow
- <ações que a IA não deve fazer enquanto este workflow está ativo>

## Definition of Done
<checklist mais extenso, com itens específicos do workflow>

## Resumo final
<template do formato fixo>
```

**Características:**
- 3 a 7 fases.
- Cada fase termina em checkpoint (grava estado para retomar se sessão morrer).
- Pode ter seção de proibições específicas (ações que normalmente seriam permitidas mas são bloqueadas neste workflow).
- Total: 150-300 linhas.

### 5.5 Política de falhas

Política padrão é definida na constitution universal. Workflows herdam por padrão; podem declarar override.

#### 5.5.1 Classificação obrigatória

Toda falha que ocorre durante workflow é classificada em uma de quatro categorias:

**Transitória:** flakiness, timeout, rede instável. Ação: retry uma vez sem mudar nada.

**Lógica:** fix errado, hipótese incorreta, arquivo errado. Ação: re-executar a tentativa com o erro como contexto adicional. Conta para o limite de tentativas.

**Escopo:** o fix exige tocar em coisas além do escopo declarado. Ação: parar imediatamente e reportar, pedir aprovação para expandir escopo.

**Ambiente:** dependência faltando, toolchain quebrado, permissão. Ação: parar imediatamente, não tentar resolver, reportar.

#### 5.5.2 Limite de tentativas

Padrão: **2 tentativas para falhas Lógicas**. Após 2 falhas lógicas consecutivas, a IA para e reporta.

Falhas Transitórias têm 1 retry "grátis" (não conta). Falhas de Escopo e Ambiente param na primeira ocorrência (limite zero).

Workflows podem declarar override no cabeçalho (ex: `politica_falhas: bugfix-strict` referenciando arquivo de override). Override raramente é necessário.

#### 5.5.3 Formato de reporte ao parar

Quando a IA para por exaustão de tentativas ou falha não-recuperável, apresenta resumo no formato fixo de quatro campos:

```
PARADO: <motivo em uma frase>
Estado atual: <o que foi feito até agora>
Bloqueador: <o que está impedindo a conclusão>
Opções: <1-3 possíveis próximos passos para o desenvolvedor>
```

A IA não tenta caminhos adicionais após apresentar este formato. Aguarda intervenção do usuário.

### 5.6 Definition of Done

Define o critério objetivo de conclusão de um workflow. Usa o **Modelo C**: checklist explícito + scripts/comandos `make` como gates automáticos.

#### 5.6.1 Tipos de itens

Cada item do checklist pertence a um de três tipos:

**Verificável pela IA:** a IA confirma com base em sua própria execução (ex: "todos os passos do protocolo foram concluídos").

**Validado por comando:** a IA roda um comando, lê a saída, confirma sucesso (ex: "make check passou"). Se o comando falha, o item NÃO pode ser marcado como pronto.

**Documental:** verifica que artefatos esperados foram gerados (ex: "decision gerada em .codeflow/decisions/", "teste de regressão adicionado").

#### 5.6.2 Comandos make como gates

Workflows que modificam código devem incluir `make check` (ou equivalentes do manifest) no Definition of Done. A IA não pode marcar como concluído sem que esses comandos retornem código de saída zero.

Se um target `make` necessário não existe no projeto, a IA marca o item como "pulado" com justificativa, não como "falhou". Workflow continua.

#### 5.6.3 Sinal verde (modo de confirmação)

Quando todos os itens do Definition of Done estão preenchidos, a IA **apresenta resumo no formato fixo**, mas **não pede confirmação explícita**. A próxima mensagem do usuário (qualquer que seja) implicitamente confirma o fechamento do workflow.

Razão: a IA já fez seu trabalho. Pedir "ok, posso fechar?" adicionaria fricção sem ganho. Se algo está errado, o usuário responde apontando o problema; se está tudo certo, o usuário segue para a próxima tarefa.

#### 5.6.4 Formato do resumo final

Cinco seções fixas, na ordem:

```markdown
## ✓ CONCLUÍDO: <workflow> — <escopo declarado>

### O que foi feito
- <arquivo X: mudança Y>
- <arquivo Z: nova função W>

### Checklist Definition of Done
- [✓] Item 1
- [✓] Item 2
- [✓] Item 3 (pulado: justificativa)

### Riscos e notas
- <riscos identificados ou "nenhum">

### Próximos passos sugeridos
- <ação 1>
- <ação 2>

### Decisão registrada (se aplicável)
- <link para .codeflow/decisions/<arquivo>.md>
```

Esta estrutura é obrigatória para que o usuário consiga, em 30 segundos, decidir o que fazer em seguida.

---

## Parte 6 — Características adicionais

Esta parte detalha as características refinadas que foram incorporadas ao escopo do codeflow durante o planejamento.

### 6.1 Versionamento de artefatos (A1)

Toda constitution, workflow, skill, rule e meta-skill começa com cabeçalho de metadata:

```
Versão: X.Y | Atualizado: AAAA-MM-DD | Status: <estado>
```

**Estados válidos:**
- `Estável`: pronto para uso em produção, mudanças requerem versão major.
- `Experimental`: em teste, pode mudar sem aviso, usar com cautela.
- `Deprecated`: marcado para remoção, não usar em workflows novos.

**Regras de bump de versão:**
- Mudança que **adiciona** capacidade ou regra: minor (1.0 → 1.1).
- Mudança que **altera comportamento** ou remove capacidade: major (1.0 → 2.0).
- Correção de typo ou clarificação que não muda comportamento: sem bump.

A IA, ao carregar um workflow ou skill, lê o status. Se for `Experimental`, aplica cautela extra (pergunta antes de ações irreversíveis). Se for `Deprecated`, avisa o usuário e sugere alternativa.

### 6.2 Glossário do framework (A2)

Localização: `~/.codeflow/framework/core/glossary.md`

**Propósito:** definir cada termo do codeflow com precisão, sem ambiguidade entre ferramentas de IA.

**Conteúdo obrigatório:**
- Termos centrais: workflow, skill, meta-skill, agent, rule, artefato, constitution, manifest, checkpoint, decision, INDEX.
- Distinções importantes: skill vs workflow, agent vs skill, rule vs constitution.
- Termos com colisão entre ferramentas: ex: "agent" significa coisas diferentes em Claude Code, Cursor, AutoGPT — o glossário declara o significado oficial no codeflow.

**Formato de cada entrada:**
- Termo
- Definição em uma frase
- Onde mora (se aplicável)
- O que NÃO é (anti-definição quando há confusão potencial)
- Exemplo concreto

O glossário só pode ser **estendido**, não modificado retroativamente. Termos existentes não mudam de significado entre versões — isso evita quebrar workflows e skills que dependem deles.

### 6.3 Política de evolução do framework (A3)

Localização: `~/.codeflow/framework/core/EVOLUTION.md`

**Propósito:** declarar como o codeflow pode crescer sem virar bagunça. É o manual do mantenedor (você) para tomar decisões consistentes ao longo do tempo.

**Conteúdo obrigatório:**

**Promoção de skill ou workflow específico → universal:**
- Critério mínimo: skill foi usada em pelo menos 2 projetos distintos.
- Critério mínimo: skill tem teste em projeto real.
- Critério mínimo: skill é referenciada por pelo menos 1 workflow.
- Quem aprova: mantenedor (você).
- Como fazer: `git mv` da pasta para `framework/library/skills/`, atualizar referências.

**Adição de rule universal:**
- Critério: tema é claramente universal (não específico de stack ou domínio).
- Critério: tem pelo menos 3 regras concretas com anti-regras correspondentes.
- Aprovação: mantenedor.

**Adição de meta-skill:**
- Critério: existe artefato no framework cuja criação manual é repetitiva e propensa a inconsistência.
- Aprovação: mantenedor.
- Exige: template de saída, exemplo preenchido, testes da meta-skill em pelo menos 2 casos diferentes.

**Mudança em arquivo do core (constitution, glossary, EVOLUTION):**
- Mudança aditiva: bump minor, sem cerimônia adicional.
- Mudança que altera comportamento: bump major + aviso em CHANGELOG do repositório + período de transição (mínimo 30 dias) onde versão antiga ainda é referenciável.

**Anti-evolução:**
- Não adicionar tipos novos de artefatos sem ter sentido 3 vezes a dor de não tê-los.
- Não copiar estruturas de outros frameworks sem propósito explícito.
- Não adicionar campos opcionais em templates só porque "pode ser útil".
- Não criar workflow universal sem critério de "usado em 2+ projetos".

### 6.4 Modo dry-run (B1)

Workflows aceitam flag opcional `--dry-run` na invocação.

**Comportamento com dry-run:**
- A IA executa o protocolo do workflow **mentalmente**, sem modificar nenhum arquivo.
- Apresenta o plano completo: que arquivos seria criados, quais modificados, que comandos seriam rodados.
- Aguarda decisão do usuário antes de prosseguir.

**Resposta do usuário pode ser:**
- "Confirma" / "Pode executar" / equivalente → IA roda o workflow normalmente.
- Ajuste solicitado → IA refaz o plano com ajustes.
- Cancelamento → IA encerra sem modificar nada.

**Implementação:** workflows não precisam implementar nada especial. A constitution universal contém regra geral: "quando invocado com `--dry-run`, apresentar plano e aguardar antes de executar".

**Anti-uso:** dry-run não é "modo educacional" — é apenas validação de plano. Para aprender, considerar skill `/learn` separada (não no escopo inicial).

### 6.5 Log de decisões (B2)

Decisões significativas são gravadas em `.codeflow/decisions/`. Uma decisão por workflow significativo.

#### 6.5.1 Quando gera decision

Workflows declaram em seu cabeçalho:
- `gera_decision: yes` → sempre gera ao concluir.
- `gera_decision: no` → nunca gera (ex: review-only, refactor-safe).
- `gera_decision: auto` → IA decide com base na natureza da tarefa (ex: bugfix de typo não gera; bugfix com mudança arquitetural gera).

#### 6.5.2 Formato

Cada arquivo `.codeflow/decisions/<data>-<titulo-curto>.md` tem header estruturado:

```markdown
---
data: AAAA-MM-DD
workflow: <nome>
tags: [tag1, tag2, tag3]
status_decisão: ativa | superseded | arquivada
supersede: null ou <data-titulo da decisão substituída>
relaciona-com: [<lista de outras decisões>]
---

# Decisões: <título>

## Contexto
<o que estava sendo feito quando essas decisões surgiram>

## Decisões tomadas

### 1. <decisão>
**Por quê:** <justificativa>
**Alternativa rejeitada:** <opção descartada + motivo>

### 2. <decisão>
...

## Próximos passos sugeridos
- <ação>
```

#### 6.5.3 Índice navegável

`.codeflow/decisions/INDEX.md` é atualizado automaticamente toda vez que decision nova é gerada. Contém tabela por data + tabela por tag.

A IA, ao iniciar workflows que tocam em áreas sensíveis (auth, payments, schema), consulta o INDEX, filtra por tag relevante, e carrega decisões **ativas** correspondentes.

#### 6.5.4 Revisão e arquivamento

Não há curadoria automática. Mantenedor revisa manualmente em cadência trimestral (ou conforme conveniência), marca decisões obsoletas como `arquivada`, registra superseder quando aplicável.

### 6.6 Checkpoints em workflows longos (B4)

Workflows com `usa_checkpoints: yes` (sempre detalhados) gravam estado em `.codeflow/checkpoints/<workflow>-<timestamp>.md` entre fases longas.

#### 6.6.1 Quando gravar

Workflow detalhado grava checkpoint:
- Ao fim de cada fase principal.
- Antes de qualquer operação que possa consumir muito contexto (ex: leitura de arquivo grande).
- Imediatamente antes de pergunta ao usuário (para retomar se sessão morre durante espera).

#### 6.6.2 Conteúdo

```markdown
---
workflow: <nome>
timestamp: AAAA-MM-DD-HHMMSS
fase_atual: <número e nome>
status: em_progresso | concluído | abortado
---

## Estado da execução

### Fases concluídas
- Fase 1: <resumo curto do resultado>
- Fase 2: <resumo>

### Fase atual (em pausa)
- Objetivo: <da fase>
- Ações já realizadas: <lista>
- Próxima ação planejada: <descrição>

### Decisões tomadas até aqui
- <decisão 1>
- <decisão 2>

### Pendências
- <itens não resolvidos>
```

#### 6.6.3 Retomada

Quando o usuário invoca o mesmo workflow em sessão nova, a IA verifica se existe checkpoint recente para esse workflow. Se sim:
- Apresenta o checkpoint ao usuário.
- Pergunta: "retomar daqui ou começar do zero?"
- Se retomar: carrega o estado, continua da fase em pausa.
- Se começar do zero: deleta checkpoint antigo, começa novo.

#### 6.6.4 Ciclo de vida

Checkpoints são efêmeros. Ao fim bem-sucedido do workflow, todos os checkpoints daquela execução são deletados.

Checkpoints que sobram (de workflows abortados ou interrompidos) podem ser deletados manualmente pelo usuário, ou via comando `make codeflow-clean-checkpoints` (se mantenedor quiser oferecer).

`.codeflow/checkpoints/` é adicionado ao `.gitignore` do projeto pelo `install.sh`.

### 6.7 Refinamentos finais

Três refinamentos pequenos completam o desenho dos artefatos.

#### 6.7.1 INDEX.md do `.codeflow/` do projeto

Arquivo curto (15-25 linhas) que serve de mapa de prioridade de leitura para a IA.

Conteúdo obrigatório:
- Lista ordenada de "leia sempre primeiro" (constitution, manifest).
- Lista de "leia se relevante ao contexto" (discovered.md, decisions/INDEX.md).
- Aviso sobre arquivos gerados automaticamente que não devem ser editados (checkpoints, decisions individuais).
- Indicação de versão do schema e última atualização.

A IA é instruída a ler o INDEX antes de qualquer outro artefato em `.codeflow/`. Sem o INDEX, ela teria que adivinhar a estrutura.

#### 6.7.2 Decisões navegáveis

Já detalhado em 6.5.3. Inclui:
- `.codeflow/decisions/INDEX.md` atualizado automaticamente.
- Header estruturado em cada decision com tags, status, relacionamentos.

#### 6.7.3 Manifest com freshness check

`.codeflow/manifest.md` contém no header:
- `last_validated: AAAA-MM-DD`
- `validation_hash: <sha256>` calculado sobre arquivos críticos (Makefile, package.json/pyproject.toml, etc.)

Workflows que carregam o manifest recalculam o hash no momento da carga. Se difere do registrado, a IA avisa o usuário: "manifest pode estar desatualizado, quer rodar `/discover --refresh`?"

Esta verificação custa ~50ms e previne workflows operarem com informação desatualizada.

---

## Parte 7 — Princípios transversais

Estes princípios não são features do codeflow — são qualidades que **toda parte do framework deve respeitar**. Aplicam-se à constitution, workflows, skills, scripts bash, meta-skills, e a qualquer artefato gerado pelo framework.

Cada princípio é uma lente de revisão: ao construir ou modificar qualquer elemento, deve-se verificar conformidade com cada um destes cinco.

### 7.1 T1 — Idempotência total

**Princípio:** Todo script bash e toda operação do framework deve poder ser executada N vezes com o mesmo resultado.

**Implicações:**
- `install.sh` rodado duas vezes não cria duplicatas, não sobrescreve arquivos existentes sem confirmação, não trava em estado intermediário.
- Hooks em `.git/hooks/` instalados duas vezes não duplicam comportamento.
- Validators que rodam em pre-commit não fazem side-effects (apenas leem e reportam).
- Meta-skills (`/discover`, `/bootstrap`) detectam estado existente e não recriam o que já existe.

**Como verificar:** rodar a operação duas vezes seguidas. Resultado da segunda deve ser equivalente ao da primeira, sem erros, sem mudanças adicionais.

**Anti-prática:** scripts que assumem "primeira execução" e quebram em re-execução; scripts que fazem `>>` (append) onde deveria ser `>` (overwrite) com verificação de existência.

### 7.2 T2 — Saída amigável a parsing

**Princípio:** Toda saída de script, validator, ou comando do framework deve ser estruturada de forma previsível, permitindo que IA leia programaticamente.

**Implicações:**
- Linhas começando com `✓` para resultado positivo, `✗` para negativo, `⚠` para aviso.
- Códigos de saída claros: `0` para sucesso, `1` para falha de regra, `2` para erro de execução, `3` para input inválido.
- Mensagens de erro contém: contexto (o que estava sendo feito), problema (o que falhou), sugestão (próximo passo).
- Quando aplicável, output estruturado em blocos demarcados (ex: `[STATUS]`, `[DETAILS]`).

**Como verificar:** IA deve conseguir extrair informação útil da saída usando padrão simples (`grep`, parsing de linhas).

**Anti-prática:** mensagens de erro genéricas como "erro"; saída em prosa contínua sem estrutura; uso inconsistente de cores ou símbolos sem significado fixo.

### 7.3 T3 — Sem dependências externas escondidas

**Princípio:** O framework deve funcionar com apenas as ferramentas declaradas como obrigatórias (bash, git, make básico, coreutils). Nenhuma dependência adicional pode ser introduzida sem decisão explícita registrada.

**Stack permitida:**
- bash (4.0+)
- git
- coreutils: grep, sed, awk, find, sha256sum, cut, sort, uniq, wc, head, tail
- openssl (para hashes em casos específicos)
- make (no projeto-alvo, não no framework)

**Stack proibida:**
- jq, yq (ferramentas de parsing de JSON/YAML que exigem instalação)
- Python, Node.js, Go, Rust (qualquer linguagem além de bash)
- Docker, podman (dependências de containerização)
- Ferramentas específicas de OS (não pode usar `pbcopy`, `xclip`, etc.)

**Como verificar:** clonar o framework numa máquina recém-instalada com apenas bash, git e coreutils. Tudo deve funcionar.

**Anti-prática:** "ah, é só instalar jq" — não é. Cada dependência adicional é fricção para o usuário final.

### 7.4 T4 — Reversibilidade por padrão

**Princípio:** Toda operação do framework no projeto-alvo deve ser reversível por `rm -rf .codeflow/`. Nenhum efeito permanente no sistema do usuário.

**Implicações:**
- Não criar arquivos fora de `.codeflow/` no projeto (exceto entrada em `.gitignore` para `checkpoints/`).
- Não modificar configurações globais do sistema (`~/.bashrc`, `~/.gitconfig`, etc.).
- Não criar serviços, daemons, cron jobs, ou hooks permanentes.
- Hooks em `.git/hooks/` (se forem instalados) podem ser removidos sem deixar resíduo.
- Se framework precisa de estado global, mora em `~/.codeflow/` — que é o próprio clone, removível por `rm -rf`.

**Como verificar:** após uso do framework, executar `rm -rf .codeflow/` no projeto e `rm -rf ~/.codeflow/` na home. Sistema deve voltar ao estado anterior, sem arquivos órfãos, sem alterações em configs.

**Anti-prática:** modificar `~/.bashrc` para adicionar atalho; criar arquivo em `/etc/` ou `/usr/local/`; deixar hooks após desinstalar.

### 7.5 T5 — Documentação como código

**Princípio:** O próprio framework deve seguir as regras que prega. Coerência entre o que ele exige e o que ele pratica.

**Implicações:**
- O README do framework usa o vocabulário oficial do glossary.
- As meta-skills (`discover`, `bootstrap`) seguem o protocolo de uma skill detalhada — são exemplos vivos de boa skill.
- A constitution universal segue suas próprias regras (curta, densa, imperativa).
- Os workflows seed (bugfix, feature-small) são exemplares — qualquer dúvida sobre "como escrever workflow bom" se resolve consultando-os.
- A política de evolução (EVOLUTION.md) é respeitada pelo próprio mantenedor ao evoluir o framework.

**Como verificar:** ler qualquer arquivo do framework e identificar se ele viola alguma regra que o próprio framework declara. Se viola, corrigir.

**Anti-prática:** "regra para os outros, não para mim". Framework que prega diff mínimo mas tem skills inchadas; framework que pede versionamento mas não versiona seus próprios arquivos.

---

## Parte 8 — Dependências

### 8.1 Dependências da máquina

**Obrigatórias (sem isso o framework não funciona):**

- **Bash** versão 4.0 ou superior. Padrão em Linux, macOS, e WSL.
- **Git** qualquer versão recente. Necessário para clone, pull, hooks.
- **Uma ferramenta de IA com slash commands.** Sem IA que execute o conteúdo dos workflows, o framework é apenas markdown estático.

**Fortemente recomendadas (degrada experiência sem):**

- **GNU Make** no projeto-alvo. Sem make, workflows operam em modo degradado: perguntam comandos ao usuário ou pulam validações.
- **Coreutils completos:** grep, sed, awk, find, sha256sum, cut, sort, uniq. Padrão em Linux/macOS/WSL.

**Não requeridas (framework não usa):**

- Python, Node.js, Go, Rust, qualquer linguagem além de bash.
- jq, yq, ou outros parsers externos.
- Docker, podman, ou ferramentas de containerização.
- Ferramentas de IDE específicas.

**Sistemas operacionais suportados:**
- Linux (qualquer distribuição moderna).
- macOS.
- WSL (Windows Subsystem for Linux).

**Sistema operacional não suportado:**
- Windows nativo (sem WSL). PowerShell não executa bash; caminhos com `~` não resolvem da mesma forma.

### 8.2 Dependências do projeto-alvo

**Obrigatórias:**

- **Repositório git inicializado** (`git init` executado). Se não, `install.sh` aborta com instrução clara.

**Esperadas (sem isso, `/discover` faz mais perguntas):**

- **Algum manifest de stack**: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `composer.json`, ou similar.
- **Algum README** ou arquivo de documentação. Fonte de contexto para `/discover` entender propósito do projeto.
- **Algum padrão de testes** (pasta `tests/`, `__tests__/`, ou similar).

**Idealmente presentes:**

- **Makefile** com targets canônicos: `make check`, `make test`, `make lint`, `make typecheck`. Se ausente, `/discover` pode propor criar; `/bootstrap` cria automaticamente em projeto novo.
- **`.gitignore`** configurado. `install.sh` adiciona `.codeflow/checkpoints/` se já existe; cria arquivo se não existe.

**Não requeridas:**

- `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, ou qualquer doc específica de ferramenta. Framework ignora.
- CI configurado.
- ADRs, docs/ formal, ou estrutura arquitetural específica.
- Linguagem específica. Framework é agnóstico — funciona em Python, TS, Go, Rust, qualquer combinação.

### 8.3 O que workflows alteram no projeto

Esta seção declara explicitamente o universo de mudanças que workflows podem fazer no projeto-alvo.

**Sempre alteram (esperado e desejado):**

- Arquivos em `.codeflow/` do projeto (artefatos, decisions, checkpoints).
- Código do projeto **relevante à tarefa** (`.py`, `.ts`, `.go`, etc., conforme escopo do workflow).
- Arquivos de teste correspondentes às mudanças de código.
- Arquivos de documentação **se a tarefa é documentação** (ex: workflow `/feature-small` pode atualizar README se feature é visível ao usuário).

**Podem alterar com aviso explícito:**

- Manifest do projeto (`package.json`, `pyproject.toml`) — apenas se tarefa exige nova dependência, e apenas após confirmação do usuário.
- Migrations de banco — apenas em workflows específicos (`/feature-small` tocando schema, ou `/db-migration` quando criado).
- Makefile — apenas se `/discover` ou `/bootstrap` propõem, e usuário aprova.

**Apenas em `/bootstrap` (projeto novo):**

- Estrutura inicial de pastas (`src/`, `tests/`, etc.).
- Manifest de stack inicial (`package.json`, `pyproject.toml`).
- Configs de linter e formatter (eslint, ruff, prettier).
- Makefile com targets canônicos.
- README inicial.
- `.gitignore` inicial.
- Tudo conforme escolhas explícitas do usuário durante a conversa do bootstrap.

**Nunca alteram (proibições absolutas):**

- `CLAUDE.md` na raiz, mesmo se existir.
- `AGENTS.md`, `.cursorrules`, ou outros arquivos de framework alheio.
- Configurações globais do sistema (`~/.bashrc`, `~/.gitconfig`).
- Arquivos `.env`, secrets, ou qualquer arquivo declarado como protegido pela constitution do projeto.
- Pastas declaradas como "não tocar" pelo usuário durante `/discover` (ex: `/legacy/`).

**Comportamento ao detectar mudança fora do escopo:**

A IA, ao perceber que está prestes a modificar arquivo fora do escopo declarado, **para imediatamente e reporta** no formato PARADO. Não tenta justificar a mudança; passa decisão ao usuário.

---

## Parte 9 — Glossário

Esta seção define os termos do codeflow com precisão. Em caso de ambiguidade entre este glossário e qualquer outro documento, este vence.

### A

**Agent:** definição de subagente com escopo de ferramentas restrito. Não é a IA em si — é uma instância especializada da IA com permissões limitadas. Mora em `framework/library/agents/` (universal) ou `.codeflow/agents/` (projeto). Diferente de "agent" no sentido de Cursor ou Claude Code, que se refere à própria IA.

**Andaime:** os cinco documentos descartáveis usados para construir o framework (SPEC.md, ARTIFACTS_SPEC.md, BUILD_PLAN.md, VALIDATION.md, PROMPTS.md). Vivem em `~/Projetos/codeflow/andaime/`. Mantidos por histórico mesmo após construção concluída.

**Artefato:** arquivo gerado pelo codeflow durante o uso, que vive em `.codeflow/` do projeto. Inclui: INDEX.md, constitution.md, manifest.md, discovered.md, decisions/*, checkpoints/*. Diferente de "conteúdo do framework" (que vive em `~/.codeflow/` e não é artefato).

### C

**Checkpoint:** arquivo em `.codeflow/checkpoints/` que registra estado intermediário de workflow detalhado em execução. Efêmero — deletado ao fim do workflow bem-sucedido. Vai para `.gitignore`.

**Codeflow:** o framework descrito por este documento. Sempre minúsculo, sem capitalização.

**Constitution:** conjunto de regras invariantes. Existe em duas versões: universal (em `framework/core/constitution.md`) e do projeto (em `.codeflow/constitution.md`).

### D

**Decision:** registro leve de decisões tomadas durante workflow significativo. Arquivo em `.codeflow/decisions/<data>-<titulo>.md`. Tem header estruturado com data, workflow de origem, tags, status, supersede.

**Discover:** meta-skill que aprende um projeto existente, gera os artefatos iniciais. Invocada via `/discover`.

**Discovered.md:** snapshot do onboarding gerado por `/discover`. Não é atualizado depois — para reaprender, gera-se novo snapshot datado.

**Dry-run:** modo de invocação de workflow (`<workflow> --dry-run`) onde a IA apresenta plano sem executar. Aguarda confirmação do usuário antes de prosseguir.

### F

**Framework:** o conjunto completo do codeflow. Pode se referir a `~/.codeflow/` (a localização) ou ao conceito abstrato.

### G

**Granularidade (de workflow):** tamanho proporcional à complexidade da tarefa. Três categorias: magro (20-30 linhas), médio (60-100), detalhado (150-300).

### I

**INDEX.md (do projeto):** mapa de leitura prioritária em `.codeflow/INDEX.md`. Diz à IA em que ordem ler os outros artefatos.

**INDEX.md (de decisions):** índice navegável de todas as decisões em `.codeflow/decisions/INDEX.md`. Atualizado automaticamente.

### M

**Make:** sistema de build canônico usado pelo codeflow para executar comandos do projeto. Subconjunto mínimo esperado: `make check`, `make test`, `make lint`, `make typecheck`.

**Manifest:** arquivo `.codeflow/manifest.md` que descreve stack, comandos make, padrões detectados do projeto. Contém `validation_hash` e `last_validated` para detecção de obsolescência.

**Meta-skill:** skill cujo propósito é criar outros artefatos do framework. Mora em `framework/meta/`. Cinco no escopo inicial: `discover`, `bootstrap`, `create-workflow`, `create-skill`, `create-agent`.

### P

**Proxy:** termo descartado. O codeflow não usa proxies (arquivos curtos na raiz do projeto). A IA descobre o codeflow via slash commands.

### R

**Rule:** módulo temático opcional que estende a constitution. Mora em `framework/core/rules/<tema>.md` (universal) ou `.codeflow/rules/<tema>.md` (projeto). Quatro no escopo inicial: `code-quality.md`, `testing.md`, `security.md`, `naming.md`.

### S

**Sessão fresca:** chat novo da ferramenta de IA, com contexto limpo. Cada workflow significativo deve ser invocado em sessão fresca para evitar degradação por auto-compactação.

**Skill:** arquivo markdown que encapsula uma capacidade discreta e reutilizável. Diferente de workflow: skill é capacidade, workflow é processo. Mora em `framework/library/skills/` (universal) ou `.codeflow/skills/` (projeto).

**Slash command:** mecanismo nativo das ferramentas de IA (Claude Code, Codex, Cursor) para invocar comandos pré-definidos. O codeflow usa exclusivamente slash commands para disparar workflows.

**SPEC.md:** este documento. A especificação do codeflow.

### W

**Workflow:** arquivo markdown que descreve sequência ordenada de passos para realizar tarefa repetitiva. Invocado via slash command. Mora em `framework/library/workflows/` (universal) ou `.codeflow/workflows/` (projeto).

---

## Parte 10 — Anti-features

Esta parte registra explicitamente o que **NÃO** será incluído no codeflow, com justificativa. Esta lista existe para que mantenedor (e Claude Code durante construção) tenha clareza de fronteira: estes itens não são esquecimentos — são exclusões deliberadas.

### 10.1 Validators plugáveis em `.codeflow/validators/`

**Descrição:** ideia de criar pasta `.codeflow/validators/` para scripts bash customizados de validação do projeto.

**Por que não:** Makefile do projeto já cobre essa função, com bonus de ser útil para humanos e CI. Adicionar segunda fila de validações cria confusão (qual rodar? quem mantém?) e duplicação inevitável.

**Reconsiderar quando:** sentir dor real de validação que não cabe no Makefile. Improvável.

### 10.2 Skill `/learn` como modo tutor

**Descrição:** ideia de skill que ensina conceitos enquanto executa feature ("explica enquanto faz").

**Por que não:** mistura dois objetivos diferentes (executar vs aprender) num mesmo workflow, com critérios de sucesso conflitantes. Aprender no meio de feature atrasa entrega e raramente ensina de verdade.

**Reconsiderar quando:** se houver demanda real, criar `/learn` separado — skill que **só ensina**, sem modificar código. Não no escopo inicial.

### 10.3 Trust levels para workflows

**Descrição:** sistema de classificação de risco (low, medium, high, critical) que faria IA pedir confirmação extra em níveis altos.

**Por que não:** redundante com guards do Makefile (que você já tem no ritmly), com Definition of Done que apresenta resumo antes de fechar, e com a flag `--dry-run`. Gold-plating.

**Reconsiderar quando:** improvável.

### 10.4 Catálogo de anti-patterns detectáveis

**Descrição:** pasta `framework/library/anti-patterns/` com padrões ruins que IAs costumam produzir.

**Por que não:** linters cobrem 80% dos casos. Os 20% restantes mudam com tempo e modelo. Catálogo viraria documento morto rapidamente.

**Reconsiderar quando:** se um anti-pattern específico aparece repetidamente em código gerado, adicionar como regra em `rules/code-quality.md`. Catálogo dedicado é overkill.

### 10.5 Telemetria local de uso

**Descrição:** registro local em `~/.codeflow/.telemetry/` de cada invocação de workflow.

**Por que não:** é uma pessoa só usando. Dado que ninguém vai analisar. Estranho na própria máquina.

**Reconsiderar quando:** se múltiplas pessoas usam e mantenedor quer entender padrões de uso para evoluir o framework.

### 10.6 Skill composition profunda

**Descrição:** skills que referenciam outras skills, criando árvore de invocações.

**Por que não:** passa de um nível de profundidade vira labirinto. Atomicidade tem limite. Composição funciona melhor entre workflow e skills, não entre skills.

**Reconsiderar quando:** improvável.

### 10.7 Modo auto-evolution

**Descrição:** sistema onde a IA propõe melhorias nos próprios workflows e skills baseado em padrões observados.

**Por que não:** viola decisão fundamental "IA não cria workflows sozinha, eu crio". Sem usuário no controle, framework drifta.

**Reconsiderar quando:** improvável.

### 10.8 Estrutura do `.devmind` (framework alheio)

O codeflow analisou o framework `.devmind` (do projeto ritmly) e identificou os seguintes elementos **explicitamente não adotados**:

**Memory/ com entities.json + relations.json:** grafo de conhecimento. Exigiria busca vetorial real, ferramentas de alimentação/consulta. Fora do escopo de markdown + bash.

**Brainstorm/ com 22 documentos numerados:** captura formal de sessões de brainstorm. Faz sentido em equipe, raramente em solo. Sem demanda real.

**Delivery/ (sprints, SLOs, SRE):** gestão operacional de produto SaaS. Dimensão do projeto, não do framework.

**Knowledge/ com Q&A acumulado:** banco de perguntas recorrentes. Faz sentido com equipe que repete perguntas. Não em solo.

**Configs JSON na raiz do framework:** `config.json`, `execution-registry.json`, `structure-version.json`, `workflow-gaps.json` sugerem runtime/automação. Codeflow é explicitamente sem runtime.

**Numeração formal (FEAT-XXXX, ADR-XXXX, QA-XXXX, BRAINSTORM-XXXX):** exige registro centralizado de números. Codeflow usa nomes descritivos com data, igualmente informativo, sem overhead.

**11+ subpastas no nível raiz:** amplitude estrutural sustentada por equipe full-time. Codeflow começa com 3 (framework/, andaime/, mais o que for necessário) e cresce sob demanda.

**Reconsiderar quando:** caso a caso, se o codeflow crescer a ponto de algum desses elementos se justificar. Improvável no horizonte previsível.

### 10.9 Adapters por ferramenta (CLAUDE.md, AGENTS.md gerados)

**Descrição:** ideia inicial de gerar arquivos específicos por ferramenta (CLAUDE.md para Claude Code, AGENTS.md para Codex, etc.) na raiz do projeto.

**Por que não:** todos os arquivos do projeto são território do projeto. Codeflow não toca neles. IA descobre o codeflow via slash commands, não via arquivos na raiz.

**Reconsiderar quando:** nunca. Esta é decisão fundamental.

---

## Fim do SPEC.md

Este documento descreve o codeflow como produto final. Toda decisão registrada aqui é vinculante durante a construção. Mudanças na especificação durante a construção devem ser refletidas neste documento antes de implementadas em código.

**Próximos documentos do andaime:**
- `ARTIFACTS_SPEC.md` — schemas detalhados de cada artefato com exemplos preenchidos.
- `BUILD_PLAN.md` — ordem de construção etapa por etapa.
- `VALIDATION.md` — checklist de validação por etapa.
- `PROMPTS.md` — prompts prontos para invocar cada etapa no Claude Code.
