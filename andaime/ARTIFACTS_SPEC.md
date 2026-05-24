---
versão: 1.1
status: estável
atualizado: 2026-05-20
documento: ARTIFACTS_SPEC.md
projeto: codeflow
localização: ~/Projetos/codeflow/andaime/ARTIFACTS_SPEC.md
audiência principal: Claude Code (construtor do framework)
audiência secundária: mantenedor do framework
---

# ARTIFACTS_SPEC.md — Schemas exatos de cada arquivo do codeflow

> Este documento define o **formato exato** de cada arquivo gerado ou consumido pelo codeflow. Para cada arquivo: schema obrigatório, schema opcional, exemplo preenchido realista, regras de validação e anti-padrões.
>
> **Hierarquia de autoridade.** Em caso de conflito com o `SPEC.md`, o SPEC vence. Em caso de conflito com qualquer outro documento do andaime (`BUILD_PLAN.md`, `VALIDATION.md`, `PROMPTS.md`), este documento vence.

---

## Sumário

- [Parte 0 — Convenções gerais](#parte-0--convenções-gerais)
- [Parte 1 — Conteúdo do framework (`~/.codeflow/`)](#parte-1--conteúdo-do-framework-codeflow)
  - 1.1 Constitution universal
  - 1.2 Glossary
  - 1.3 EVOLUTION
  - 1.4 Rules
  - 1.5 Workflows magros
  - 1.6 Workflows médios
  - 1.7 Workflows detalhados
  - 1.8 Skills
  - 1.9 Meta-skills
  - 1.10 Agents
- [Parte 2 — Artefatos do projeto (`.codeflow/`)](#parte-2--artefatos-do-projeto-codeflow)
  - 2.1 INDEX.md
  - 2.2 Constitution de projeto
  - 2.3 Manifest
  - 2.4 Discovered
  - 2.5 Decision individual
  - 2.6 Decisions INDEX
  - 2.7 Checkpoint
- [Parte 3 — Regras transversais de validação](#parte-3--regras-transversais-de-validação)

---

## Parte 0 — Convenções gerais

Esta parte define as convenções que se aplicam a **todos** os arquivos do codeflow (conteúdo de framework e artefatos de projeto). Convenções declaradas aqui não são repetidas nas seções subsequentes — só são repetidas exceções ou refinamentos por tipo de arquivo.

### 0.1 Encoding e formato bruto

- **Encoding:** UTF-8 sem BOM. Obrigatório em todos os arquivos `.md` e `.sh`.
- **Line endings:** LF (`\n`). Nunca CRLF. Vale também para arquivos gerados em ambientes WSL.
- **Trailing newline:** todo arquivo termina com exatamente uma linha em branco (`\n` final).
- **Indentação dentro de blocos de código:** dois espaços. Nunca tab.
- **Largura de linha:** sem limite rígido. Linhas longas (>120 caracteres) são permitidas quando quebrar prejudica leitura (URLs, comandos, exemplos).

### 0.2 Frontmatter YAML

Todo arquivo markdown do codeflow começa com **frontmatter YAML** delimitado por `---` na primeira linha e em uma linha posterior. Sem exceções.

**Campos universais obrigatórios** (presentes em qualquer frontmatter):

- `versão` — formato `X.Y` (ex: `1.0`, `2.3`). Nunca `X.Y.Z`.
- `status` — um de: `estável`, `experimental`, `deprecated`. Em minúsculas.
- `atualizado` — data ISO `AAAA-MM-DD`.

Campos adicionais variam por tipo de arquivo e são declarados na seção correspondente da Parte 1 ou Parte 2.

**Regras de parsing:**
- Chaves em minúsculas, sem espaços (use `_` quando necessário, ex: `usa_checkpoints`).
- Valores string sem aspas, exceto quando contêm `:`, `#`, `[`, `]` ou começam com número.
- Listas em formato inline (`tags: [auth, jwt]`) quando curtas, formato bloco (`- item`) quando longas.
- Sem comentários (`#`) dentro do frontmatter.

### 0.3 Versionamento

Regras de bump conforme `SPEC.md` §6.1:

- **Minor (`1.0 → 1.1`):** adição de capacidade ou regra. Comportamento existente preservado.
- **Major (`1.0 → 2.0`):** alteração de comportamento existente ou remoção de capacidade.
- **Sem bump:** correção de typo, clarificação, reformatação que não altera comportamento.

Toda criação inicial de arquivo começa em `1.0` com `status: estável` — exceto quando o `BUILD_PLAN.md` instruir explicitamente `experimental`.

### 0.4 Idioma e nomenclatura

- **Conteúdo:** sempre pt-BR. Inclui títulos, descrições, comentários em bash, mensagens de echo, exemplos.
- **Termos técnicos consagrados:** mantidos em inglês (`commit`, `diff`, `workflow`, `pull request`, `branch`, `merge`).
- **Nomes de arquivos e pastas:** kebab-case em inglês (`debug-protocol`, `feature-small`, `code-quality.md`).
- **Nomes em frontmatter (chaves):** podem ser em pt-BR com acentos quando isso melhora a legibilidade (`versão`, `atualizado`, `descrição`, `é_meta_skill`, `data_inspeção`, `última_atualização`, `relaciona-com`). Quando o termo é técnico consagrado em inglês, manter em inglês com snake_case (`gera_decision`, `usa_checkpoints`). Exigência: consistência interna por tipo de artefato — uma vez escolhida a forma de uma chave, todos os artefatos do mesmo tipo a usam de modo idêntico.
- **Nomes de seções markdown:** pt-BR em prosa natural (`## Quando usar`, `## Protocolo`, `## Definition of Done` — esta última mantida em inglês por ser termo técnico consagrado, conforme `SPEC.md` §4.2.3 e §5.6).

### 0.5 Datas e timestamps

- **Datas:** formato ISO `AAAA-MM-DD` (ex: `2026-05-17`). Sempre em frontmatter e em texto.
- **Timestamps:** formato `AAAA-MM-DD-HHMMSS` (ex: `2026-05-17-143205`). Usado apenas em nomes de checkpoint e em campo `timestamp` do frontmatter de checkpoint.
- **Fuso:** sempre local da máquina. Não converter para UTC.

### 0.6 Símbolos padronizados

Conforme `SPEC.md` §7.2 (T2 — Saída amigável a parsing):

| Símbolo | Significado | Uso |
|---------|-------------|-----|
| `✓` | Sucesso, item concluído, validação passou | Checklists, output de scripts |
| `✗` | Falha, item não concluído, validação falhou | Checklists, output de scripts |
| `⚠` | Aviso, condição degradada mas não bloqueante | Output de scripts, notas em artefatos |
| `[ ]` | Item de checklist não marcado | Definition of Done em workflows |
| `[✓]` | Item de checklist marcado como concluído | Resumo final |
| `[—]` | Item pulado com justificativa | Resumo final (quando target make ausente) |

Não usar outros símbolos decorativos (emojis, setas Unicode, asteriscos coloridos) em conteúdo do framework. Exceção: o `✓` ao lado do título "CONCLUÍDO" no resumo final, conforme `SPEC.md` §5.6.4.

### 0.7 Códigos de saída de scripts

Conforme `SPEC.md` §7.2, todo script bash do codeflow segue:

- `0` — sucesso.
- `1` — falha de regra (a operação rodou mas a condição esperada não foi atingida).
- `2` — erro de execução (ferramenta faltando, permissão negada, arquivo inacessível).
- `3` — input inválido (argumento ausente, valor fora do conjunto esperado).

Códigos `>3` reservados para uso futuro; não inventar significados.

### 0.8 Caminhos e referências

- **Referências ao framework:** sempre via `~/.codeflow/...`. Nunca caminho absoluto literal (`/home/usuario/.codeflow/...`), nunca variável de ambiente (`$CODEFLOW_HOME`).
- **Referências ao projeto:** sempre relativas à raiz do projeto, começando por `.codeflow/...` ou nome de pasta (`src/`, `tests/`).
- **Links em markdown:** preferir links explícitos a referências implícitas. Quando o caminho aparece em prosa, formatar como código inline com crases.

### 0.9 Stack permitida em scripts

Conforme `SPEC.md` §7.3:

- **Permitido:** bash 4.0+, git, coreutils (`grep`, `sed`, `awk`, `find`, `sha256sum`, `cut`, `sort`, `uniq`, `wc`, `head`, `tail`), openssl, make (apenas no projeto-alvo).
- **Proibido:** jq, yq, python, node, go, rust, docker, ferramentas específicas de OS (`pbcopy`, `xclip`).

Toda dependência fora da lista permitida exige decisão explícita no `SPEC.md` antes de uso.

---

## Parte 1 — Conteúdo do framework (`~/.codeflow/`)

Esta parte define o formato dos arquivos que vivem em `~/.codeflow/` — o framework propriamente dito. Esses arquivos são gerenciados pelo mantenedor (você) e atualizados via `git pull`. Não são gerados pelas meta-skills durante o uso do framework — são gerados pelo Claude Code durante a **construção** do framework, seguindo este documento.

### Estrutura uniforme de 7 blocos

Cada subseção da Parte 1 e da Parte 2 segue rigorosamente a mesma estrutura, na mesma ordem:

**1. Localização.** Caminho exato no sistema de arquivos, usando convenções da Parte 0.8. Indica se há uma única localização ou duas (universal + projeto), e o que cada uma significa.

**2. Propósito.** Uma a três frases declarando o que o arquivo é e por que existe. Sem redundância com o `SPEC.md` — apenas o suficiente para ancorar o leitor.

**3. Schema obrigatório.** Lista exaustiva e ordenada do que **deve** estar presente no arquivo: frontmatter (campos específicos além dos universais da Parte 0.2), seções markdown obrigatórias, sub-seções dentro de cada seção, ordem fixa. O Claude Code não tem liberdade para omitir, reordenar ou renomear nada listado aqui.

**4. Schema opcional.** Campos de frontmatter, seções ou sub-seções que **podem** estar presentes mas não são obrigatórios. Inclui critério explícito de quando incluir e quando omitir.

**5. Exemplo preenchido.** Uma instância completa e realista do arquivo, em bloco de código markdown. Realista significa: conteúdo coerente, não-trivial, que poderia existir num projeto real. O Claude Code usa este exemplo como referência ao gerar análogos durante a construção.

**6. Regras de validação.** Checks objetivos que devem passar após o arquivo ser gerado. Cada check é verificável programaticamente (via grep, parsing simples, ou inspeção visual estruturada). Esta seção é a fonte primária para o `VALIDATION.md`.

**7. Anti-padrões.** Lista do que **não fazer** ao criar o arquivo. Captura armadilhas previsíveis de geração assistida por IA: invenção de campos, copy-paste de outros tipos de arquivo, prosa onde deveria ser estrutura, generalização vazia.

**Princípio transversal:** se um bloco não tem conteúdo relevante para um tipo específico de arquivo, ele aparece explicitamente como `Nenhum.` ou `Não se aplica.` — nunca omitido. A omissão silenciosa abre espaço para alucinação.

---

### 1.1 Constitution universal

#### 1.1.1 Localização

Localização única: `~/.codeflow/framework/core/constitution.md`.

Não há versão de constitution universal no projeto. A constitution de projeto (descrita em §2.2) é arquivo **distinto**, vive em `<projeto>/.codeflow/constitution.md`, e **estende** esta, não a substitui.

#### 1.1.2 Propósito

Declarar os princípios universais e invariantes que governam o comportamento da IA em qualquer projeto que usa codeflow. É a "lei do framework". Carregada no início de toda sessão de workflow, antes de qualquer outra coisa.

#### 1.1.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

Nenhum.

**Seções markdown — na ordem fixa abaixo (título + 5 seções `##`):**

1. `# Constitution universal do codeflow` — título único, exato.
2. `## Princípios invariantes` — declara **exatamente quatro princípios**, alinhados a `SPEC.md` §1.2 e §4.1.1: (a) diff mínimo; (b) declaração de escopo antes de modificar; (c) seguir convenções existentes; (d) comentários só registram "por quê" não-óbvio. Inclui também, como bullet final desta mesma seção, a regra de que **mudanças quebradoras exigem detecção e documentação explícita antes de aplicar** (incorporada aqui em vez de seção própria).
3. `## Política de falhas` — classificação em quatro categorias (Transitória, Lógica, Escopo, Ambiente), limite de duas tentativas para falhas Lógicas. Conforme `SPEC.md` §4.1.1 e §5.5. **Não** contém o bloco de formato PARADO (vive em seção separada).
4. `## Formato PARADO` — declara o formato fixo de reporte de parada (`PARADO:` / `Estado atual:` / `Bloqueador:` / `Opções:`). Conforme `SPEC.md` §4.1.1 e §5.5.
5. `## Proibições absolutas` — declara que arquivos protegidos não são modificados sem instrução. Conforme `SPEC.md` §4.1.1 e §8.3.
6. `## Quando esta constitution se aplica` — declara o escopo de carregamento (toda sessão de workflow, antes de qualquer outra coisa) e a relação com a constitution de projeto (estende, não substitui).

**Restrições adicionais:**

- Tamanho total: **50 a 100 linhas** (contando frontmatter e linhas em branco). Limite duro — viola §3.7 do SPEC se ultrapassar.
- Linguagem **imperativa**: "deve", "não deve", "nunca". Proibido: "preferencialmente", "recomendado", "sugere-se", "pode considerar".
- Cada princípio em uma frase única ou parágrafo curto (até 3 linhas). Sem prosa explicativa longa.

#### 1.1.4 Schema opcional

- Seção `## Notas de versionamento` no fim, com 1-3 linhas resumindo o que mudou da versão anterior. Incluir somente a partir da versão `1.1`. Versão `1.0` omite.

#### 1.1.5 Exemplo preenchido

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
---

# Constitution universal do codeflow

## Princípios invariantes

A IA deve produzir o **diff mínimo** necessário para cumprir a tarefa declarada. Refatoração não solicitada é proibida, mesmo quando o código adjacente parecer melhorável.

A IA deve **declarar o escopo antes de modificar qualquer arquivo**. Escopo é o conjunto explícito de arquivos e mudanças autorizados pela tarefa. Modificar fora do escopo declarado exige parar e reportar.

A IA deve **seguir convenções existentes** do projeto mesmo quando achar que tem abordagem melhor. Consistência vence esperteza individual.

A IA não deve adicionar comentários explicativos sobre o que o código faz. **Comentários só registram "por quê" não-óbvio.**

- **Mudanças quebradoras** (alteração de assinatura pública, formato de retorno, schema persistido, contrato de API ou formato de configuração) devem ser detectadas antes de aplicadas e documentadas explicitamente; a confirmação do usuário precede a execução.

## Política de falhas

Toda falha encontrada durante execução de workflow deve ser classificada em uma de quatro categorias:

- **Transitória:** flakiness, timeout, rede instável. Ação: retry uma vez. Não conta para o limite.
- **Lógica:** fix errado, hipótese incorreta, arquivo errado. Ação: re-executar com o erro como contexto. Conta para o limite.
- **Escopo:** o fix exige tocar em algo fora do escopo declarado. Ação: parar imediatamente e reportar.
- **Ambiente:** dependência faltando, toolchain quebrado, permissão negada. Ação: parar imediatamente e reportar.

Limite padrão: **duas tentativas para falhas Lógicas**. Após duas falhas Lógicas consecutivas, a IA para.

Falhas de Escopo e Ambiente param na primeira ocorrência. Não há retry.

## Formato PARADO

Ao parar, a IA apresenta resumo no formato fixo:

```
PARADO: <motivo em uma frase>
Estado atual: <o que foi feito até agora>
Bloqueador: <o que está impedindo a conclusão>
Opções: <1-3 possíveis próximos passos>
```

Após este reporte, a IA aguarda intervenção do usuário. Não tenta caminhos adicionais.

## Proibições absolutas

A IA não modifica os arquivos abaixo sem instrução explícita:

- `CLAUDE.md`, `AGENTS.md`, `.cursorrules` ou arquivos análogos de framework alheio na raiz do projeto.
- `~/.bashrc`, `~/.gitconfig` ou qualquer configuração global do sistema do usuário.
- Arquivos `.env`, secrets, chaves ou credenciais.
- Pastas declaradas como protegidas pela constitution de projeto ou marcadas como "não tocar" durante `/discover`.

## Quando esta constitution se aplica

Esta constitution é carregada no início de **toda sessão de workflow do codeflow**, antes de qualquer outro artefato. A constitution de projeto (`<projeto>/.codeflow/constitution.md`) é arquivo distinto que **estende** esta — adiciona regras específicas do projeto, sem sobrepor nem revogar princípios universais. Em caso de conflito, a constitution universal vence.
```

#### 1.1.6 Regras de validação

1. Frontmatter presente, parseável, com os três campos universais (`versão`, `status`, `atualizado`).
2. Tamanho total entre 50 e 100 linhas, inclusive. Verificar com `wc -l`.
3. As seis seções obrigatórias presentes, na ordem exata listada em §1.1.3 (título `#` + cinco seções `##`: `## Princípios invariantes`, `## Política de falhas`, `## Formato PARADO`, `## Proibições absolutas`, `## Quando esta constitution se aplica`).
4. Título exato `# Constitution universal do codeflow` em linha única.
5. Nenhuma ocorrência de palavras-fraca: `preferencialmente`, `recomendado`, `sugere-se`, `pode considerar`, `idealmente`. Verificar com `grep -i`.
6. Bloco de código com formato `PARADO:` presente na seção `## Formato PARADO` (seção independente — não embutido em `## Política de falhas`).
7. Lista de `## Proibições absolutas` cobre os quatro alvos canônicos do `SPEC.md` §8.3: arquivos de framework alheio na raiz, configurações globais do sistema, secrets/`.env`, pastas marcadas como protegidas.
8. Quatro categorias de falha (Transitória, Lógica, Escopo, Ambiente) presentes literalmente em `## Política de falhas`.
9. A seção `## Princípios invariantes` contém **exatamente quatro princípios** (diff mínimo; escopo antes de modificar; seguir convenções; comentários só registram "por quê" não-óbvio), mais um bullet final tratando de mudanças quebradoras.
10. Nenhuma referência a stack específica (Python, Node, etc.), framework específico, ou linguagem de programação concreta. A constitution universal é agnóstica.
11. Nenhum caminho absoluto literal (validação geral §0.8) — exceto `~/.bashrc` e `~/.gitconfig` na lista de proibições, que são exemplos canônicos do próprio `SPEC.md` §8.3.

#### 1.1.7 Anti-padrões

- **Inchar com regras específicas de stack ou linguagem.** Essas vivem em rules (§1.4) ou na constitution de projeto (§2.2). A constitution universal é agnóstica por design.
- **Adicionar detalhes operacionais de workflows.** Detalhes de protocolo vivem nos próprios workflows (§1.5-1.7), não aqui.
- **Usar linguagem hedge.** "Preferencialmente", "recomendado", "considere" são proibidos. A constitution é lei, não sugestão.
- **Exceder 100 linhas.** Constitution longa não cabe no contexto inicial sem competir com a tarefa — viola o propósito declarado em `SPEC.md` §3.7.
- **Copiar a estrutura de constitutions de outros frameworks** (Anthropic constitution, Cursor rules, etc.). O codeflow tem desenho próprio.
- **Listar proibições genéricas ("seja cuidadoso", "não quebre coisas").** Cada proibição é uma operação concreta e verificável.
- **Omitir uma das cinco seções obrigatórias `##`** por achar que "esse projeto não precisa". A constitution universal é monolítica; quem não precisa de seção X simplesmente não cria conflito com ela.

### 1.2 Glossary

#### 1.2.1 Localização

Localização única: `~/.codeflow/framework/core/glossary.md`.

Não há versão de glossary no projeto. O vocabulário oficial do codeflow é universal por definição.

#### 1.2.2 Propósito

Definir cada termo do codeflow com precisão, sem ambiguidade entre ferramentas de IA. Quando o mesmo termo significa coisas diferentes em ferramentas distintas (ex: "agent" no Claude Code vs Cursor vs AutoGPT), o glossário declara o significado oficial **no codeflow**, vinculante para todos os outros documentos.

#### 1.2.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

Nenhum.

**Seções markdown — na ordem fixa abaixo:**

1. `# Glossário do codeflow` — título único, exato (com acento, pt-BR).
2. `## Termos centrais` — uma entrada por termo, **em ordem alfabética pt-BR**. Cobertura obrigatória — **exatamente 12 termos**: Agent, Artefato, Checkpoint, Constitution, Decision, Discovered, INDEX, Manifest, Meta-skill, Rule, Skill, Workflow. Conforme `SPEC.md` §6.2.
3. `## Distinções importantes` — pares de termos com fronteira sutil, cada par com sua delimitação explícita. Cobertura obrigatória — **exatamente 4 distinções**: Workflow vs Skill, Agent vs Skill, Rule vs Constitution, Decision vs Checkpoint. Conforme `SPEC.md` §6.2.
4. `## Termos com colisão entre ferramentas` — termos que existem em outras ferramentas com significado diferente. Cobertura mínima obrigatória: `agent` (no codeflow vs Claude Code, Cursor, AutoGPT). Conforme `SPEC.md` §6.2.

**Formato de cada entrada em `## Termos centrais`:**

Cada termo é uma sub-seção `### <Termo>` contendo, na ordem fixa, os campos abaixo em formato de lista de definição:

- **Definição:** uma frase única, declarativa. Obrigatória.
- **Onde mora:** caminho de sistema de arquivos. Obrigatório quando o termo refere-se a um arquivo ou pasta concreto; omitido quando o termo é abstrato.
- **O que NÃO é:** anti-definição que dissipa confusão previsível. Obrigatório quando há colisão real (com outro termo do codeflow, com termo de outra ferramenta, com uso vernacular). Omitido quando não há ambiguidade.
- **Exemplo concreto:** uma frase com instância real do termo em uso. Obrigatória.

**Formato de cada entrada em `## Distinções importantes`:**

Cada par é uma sub-seção `### <Termo A> vs <Termo B>` contendo um parágrafo único que declara a fronteira: o que cada lado captura e o que separa um do outro. Sem listas, sem sub-campos.

**Formato de cada entrada em `## Termos com colisão entre ferramentas`:**

Cada termo é uma sub-seção `### <Termo>` contendo:

- **No codeflow:** uma frase declarando o significado oficial.
- **Em outras ferramentas:** lista de ferramenta + significado, uma linha por ferramenta.

**Restrições adicionais:**

- Definições nunca usam o próprio termo sendo definido (sem circularidade).
- Definições não dependem de outros termos do glossário sem que esses outros estejam definidos no mesmo arquivo.
- Toda referência a outro termo do glossário aparece em **negrito** na primeira menção dentro de cada entrada.

#### 1.2.4 Schema opcional

- Sub-seções `## <Letra>` (estilo dicionário, A/C/D/...) para organização alfabética dentro de `## Termos centrais`. Permitidas quando o número de termos passa de 20; recomendadas mas não exigidas.
- Seção final `## Termos descartados` listando termos considerados durante o design do codeflow mas explicitamente rejeitados (ex: "proxy", conforme `SPEC.md` §9). Incluir somente se há descartes a registrar.

#### 1.2.5 Exemplo preenchido

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
---

# Glossário do codeflow

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
```

#### 1.2.6 Regras de validação

1. Frontmatter presente, parseável, com os três campos universais.
2. Título exato `# Glossário do codeflow` em linha única (com acento).
3. Três seções obrigatórias presentes: `## Termos centrais`, `## Distinções importantes`, `## Termos com colisão entre ferramentas`, nesta ordem.
4. Em `## Termos centrais`, as **12 entradas obrigatórias** presentes como sub-seções `###`, em ordem alfabética pt-BR: Agent, Artefato, Checkpoint, Constitution, Decision, Discovered, INDEX, Manifest, Meta-skill, Rule, Skill, Workflow. Verificar nominalmente e na ordem.
5. Em `## Distinções importantes`, as **4 distinções obrigatórias** presentes: Workflow vs Skill, Agent vs Skill, Rule vs Constitution, Decision vs Checkpoint.
6. Em `## Termos com colisão entre ferramentas`, a entrada Agent presente, com sub-campos "No codeflow" e "Em outras ferramentas".
7. Toda entrada em `## Termos centrais` tem `**Definição:**` e `**Exemplo concreto:**` (campos obrigatórios). Verificar com `grep`.
8. Toda entrada em `## Termos centrais` cujo termo refere-se a arquivo ou pasta concreta (todos os 12 termos atuais) tem `**Onde mora:**`. Verificar nominalmente.
9. Nenhuma definição usa o próprio termo sendo definido. Verificar grep da palavra do título da sub-seção dentro do bullet "Definição".
10. Nenhuma referência a stack específica, linguagem ou ferramenta como parte da definição em si. Referências a outras ferramentas só aparecem em `## Termos com colisão entre ferramentas`.

#### 1.2.7 Anti-padrões

- **Definir termo usando o próprio termo.** "Workflow é um workflow que..." é circular e inútil. Toda definição precisa fechar em um termo mais primitivo.
- **Adicionar termos sem cobertura mínima.** A lista obrigatória da §1.2.3 é piso, não teto — mas omitir um termo do piso quebra outros documentos que dependem dele.
- **Misturar definição e regra.** Glossário declara o que cada termo significa, não como ele deve ser usado. Regras de uso vivem na constitution ou em rules.
- **Prosa contínua entre entradas.** Cada entrada é discreta, com formato fixo. Não há transições explicativas entre termos.
- **Definição com hedges ou subjetividade.** "Workflow geralmente é..." ou "Skill costuma ser..." quebra o propósito do glossário. Uso: declarativo e categórico.
- **Sinônimos no campo Termo.** Cada termo aparece uma vez com um nome canônico. Variantes (ex: "meta-skill" e "metaskill") são proibidas — escolha uma forma e use sempre.
- **Modificar entrada existente em vez de criar nova.** Conforme `SPEC.md` §6.2, o glossário só pode ser **estendido**. Alterar significado de termo existente quebra workflows que dependem da definição antiga.

### 1.3 EVOLUTION

#### 1.3.1 Localização

Localização única: `~/.codeflow/framework/core/EVOLUTION.md`.

Não há versão de EVOLUTION no projeto. A política de evolução é universal por definição — descreve como o **framework** cresce, não como projetos individuais evoluem.

#### 1.3.2 Propósito

Declarar como o codeflow pode crescer sem virar bagunça. É o manual do mantenedor (o autor do framework) para tomar decisões consistentes ao longo do tempo: o que promover, o que adicionar, o que recusar.

#### 1.3.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

Nenhum.

**Seções markdown — na ordem fixa abaixo:**

1. `# Política de evolução do codeflow` — título único, exato.
2. `## Promoção de skill ou workflow específico para universal` — critérios mínimos + quem aprova + como fazer. Conforme `SPEC.md` §6.3.
3. `## Adição de rule universal` — critérios mínimos + aprovação. Conforme `SPEC.md` §6.3.
4. `## Adição de meta-skill` — critério + aprovação + exigências. Conforme `SPEC.md` §6.3.
5. `## Mudança em arquivo do core` — política para mudança aditiva vs comportamental. Conforme `SPEC.md` §6.3.
6. `## Anti-evolução` — lista do que **não** fazer ao evoluir o framework. Conforme `SPEC.md` §6.3.

**Conteúdo obrigatório por seção:**

A seção `## Promoção de skill ou workflow específico para universal` declara, em ordem:
- Quatro critérios mínimos, cada um como bullet imperativo: skill usada em pelo menos dois projetos distintos; skill testada em projeto real; skill referenciada por pelo menos um workflow; quem aprova é o mantenedor.
- Procedimento de execução: `git mv` da pasta para `framework/library/skills/`, atualização de referências.

A seção `## Adição de rule universal` declara, em ordem:
- Critério de universalidade: o tema é claramente universal, não específico de stack ou domínio.
- Critério de densidade: a rule tem pelo menos três regras concretas com anti-regras correspondentes.
- Aprovação: mantenedor.

A seção `## Adição de meta-skill` declara, em ordem:
- Critério de motivação: existe artefato do framework cuja criação manual é repetitiva e propensa a inconsistência.
- Aprovação: mantenedor.
- Exigências: template de saída, exemplo preenchido, testes da meta-skill em pelo menos dois casos diferentes.

A seção `## Mudança em arquivo do core` (constitution, glossary, EVOLUTION) declara, em ordem:
- Mudança aditiva: bump minor, sem cerimônia adicional.
- Mudança que altera comportamento: bump major, aviso em CHANGELOG do repositório, período mínimo de transição de 30 dias em que a versão antiga ainda é referenciável.

A seção `## Anti-evolução` declara, como bullets imperativos, os quatro pontos literais do `SPEC.md` §6.3:
- Não adicionar tipos novos de artefatos sem ter sentido a dor três vezes.
- Não copiar estruturas de outros frameworks sem propósito explícito.
- Não adicionar campos opcionais em templates só porque "pode ser útil".
- Não criar workflow universal sem o critério de "usado em dois ou mais projetos".

**Restrições adicionais:**

- Linguagem imperativa em critérios e procedimentos. Sem hedges (proibido `preferencialmente`, `recomendado`, `sugere-se`, `pode considerar`, `idealmente`).
- Cada critério mínimo é verificável: "usada em pelo menos dois projetos" é checável; "deve estar madura" não é.

#### 1.3.4 Schema opcional

- Seção final `## Histórico de evoluções aplicadas` listando, em ordem cronológica reversa, as evoluções já realizadas conforme esta política (data, tipo, item promovido/adicionado/alterado). Incluir somente a partir da primeira evolução real. Versão `1.0` omite.

#### 1.3.5 Exemplo preenchido

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
---

# Política de evolução do codeflow

Este documento descreve como o codeflow cresce sem virar bagunça. Aplicar este protocolo é responsabilidade do mantenedor. Qualquer evolução do framework deve passar por uma das seções abaixo.

## Promoção de skill ou workflow específico para universal

Uma skill ou workflow específico de projeto pode ser promovido a universal — movido de `<projeto>/.codeflow/` para `~/.codeflow/framework/library/` — apenas quando **todos** os critérios mínimos abaixo são satisfeitos:

- A skill foi usada em pelo menos **dois projetos distintos**.
- A skill tem teste em projeto real, não apenas em exemplo do mantenedor.
- A skill é referenciada por pelo menos **um workflow** (universal ou específico).
- O mantenedor aprova a promoção.

**Procedimento:**

1. `git mv <projeto>/.codeflow/skills/<nome>/ ~/.codeflow/framework/library/skills/<nome>/`.
2. Atualizar referências cruzadas em workflows que carregavam a skill via caminho de projeto.
3. Commit no repositório do framework com mensagem `promote: skill <nome> de <projeto-origem>`.

A mesma regra vale para workflows: promoção exige uso em dois projetos distintos, teste real, e aprovação do mantenedor.

## Adição de rule universal

Uma nova rule universal (módulo temático em `~/.codeflow/framework/core/rules/`) pode ser adicionada apenas quando **ambos** os critérios abaixo são satisfeitos:

- O tema é claramente universal: aplica-se independentemente de stack, linguagem ou domínio.
- A rule tem pelo menos **três regras concretas** com anti-regras correspondentes.

Aprovação: mantenedor. Não há outro filtro.

## Adição de meta-skill

Uma nova meta-skill (em `~/.codeflow/framework/meta/`) pode ser adicionada apenas quando o critério abaixo é satisfeito:

- Existe artefato do framework cuja criação manual é repetitiva e propensa a inconsistência. A meta-skill resolve essa repetição.

Aprovação: mantenedor.

**Exigências obrigatórias antes de marcar a meta-skill como `estável`:**

- Template de saída completo na própria meta-skill.
- Pelo menos um exemplo preenchido do artefato que ela gera.
- Testes da meta-skill em pelo menos **dois casos diferentes** (projetos ou cenários distintos).

## Mudança em arquivo do core

Arquivos do core são `~/.codeflow/framework/core/constitution.md`, `~/.codeflow/framework/core/glossary.md` e este `EVOLUTION.md`. Mudanças seguem regime estrito:

**Mudança aditiva** (acrescenta regra, termo ou política sem alterar significado de itens existentes):

- Bump minor (`X.Y` → `X.(Y+1)`).
- Sem cerimônia adicional.

**Mudança que altera comportamento** (modifica significado de regra ou termo existente, ou remove item):

- Bump major (`X.Y` → `(X+1).0`).
- Aviso registrado em CHANGELOG do repositório do framework.
- Período mínimo de transição de **30 dias** em que a versão antiga permanece referenciável (tag git da versão anterior preservada, com aviso de deprecation).

## Anti-evolução

Estas restrições são vinculantes para o mantenedor. Quando a tentação de evoluir o framework surgir contra um destes itens, a resposta padrão é **não**:

- Não adicionar tipos novos de artefatos sem ter sentido a dor de não tê-los **três vezes**.
- Não copiar estruturas de outros frameworks sem propósito explícito declarado em decision.
- Não adicionar campos opcionais em templates só porque "pode ser útil".
- Não criar workflow universal sem o critério de "usado em dois ou mais projetos".

Cada decisão de evolução que viole uma destas anti-regras exige registro em decision com justificativa explícita, e revisão posterior em cadência mínima trimestral.
```

#### 1.3.6 Regras de validação

1. Frontmatter presente, parseável, com os três campos universais.
2. Título exato `# Política de evolução do codeflow` em linha única.
3. Título exato presente como `#` (item 1 do schema) e as cinco seções `##` obrigatórias presentes, na ordem exata listada em §1.3.3 (Promoção, Adição de rule, Adição de meta-skill, Mudança em arquivo do core, Anti-evolução).
4. Em `## Promoção de skill ou workflow específico para universal`, os quatro critérios literais presentes: "dois projetos distintos", "teste em projeto real", "referenciada por pelo menos um workflow", "mantenedor aprova". Verificar via grep.
5. Em `## Promoção de skill ou workflow específico para universal`, procedimento com `git mv` mencionado literalmente.
6. Em `## Adição de rule universal`, ambos os critérios presentes: "tema claramente universal" e "três regras concretas com anti-regras".
7. Em `## Adição de meta-skill`, as três exigências literais presentes: "template de saída", "exemplo preenchido", "testes em pelo menos dois casos".
8. Em `## Mudança em arquivo do core`, política de bump minor (aditiva) e bump major (comportamental) explicitamente diferenciadas, com prazo de **30 dias** literal.
9. Em `## Anti-evolução`, os quatro pontos do `SPEC.md` §6.3 presentes, na forma de bullets imperativos iniciando por "Não".
10. Nenhuma ocorrência de palavras-fraca (mesma lista da §1.1.6 #5): `preferencialmente`, `recomendado`, `sugere-se`, `pode considerar`, `idealmente`.

#### 1.3.7 Anti-padrões

- **Critérios não-verificáveis.** "Skill deve estar madura" é hedge. "Skill usada em dois projetos distintos" é verificável. Trocar precisão por sensação de razoabilidade quebra o propósito do documento.
- **Adicionar tipos novos de evolução sem demanda real.** Cada seção `##` representa uma fronteira disciplinar. Inflar com tipos especulativos ("evolução de hook", "evolução de adapter") quando esses conceitos sequer existem no framework é gold-plating.
- **Diluir os critérios mínimos.** "Pelo menos dois projetos" é piso, não sugestão. Aceitar promoção com um projeto só viola a própria política.
- **Confundir EVOLUTION com CHANGELOG.** EVOLUTION declara política (regras de mudança); CHANGELOG registra fatos (mudanças aplicadas). A seção opcional `## Histórico de evoluções aplicadas` é resumo curto, não CHANGELOG detalhado.
- **Linguagem de aspiração.** "Idealmente, o mantenedor revisa..." quebra o regime imperativo. Toda regra é categórica.
- **Documentar EVOLUTION como se fosse roadmap.** Roadmap descreve o que será feito; EVOLUTION descreve sob que regras pode ser feito. O codeflow não tem roadmap (§1.4 do `SPEC.md`).

### 1.4 Rules

#### 1.4.1 Localização

Duas localizações possíveis:

- **Universal:** `~/.codeflow/framework/core/rules/<tema>.md`. Quatro rules seed entregues no escopo inicial: `code-quality.md`, `testing.md`, `security.md`, `naming.md` (`SPEC.md` §4.6.2).
- **Projeto:** `<projeto>/.codeflow/rules/<tema>.md`. Criadas sob demanda pela meta-skill `create-skill` ou manualmente pelo usuário.

Uma rule de projeto com o mesmo nome de uma universal **estende** a universal — não a substitui. Workflows que carregam a rule lêem ambas, na ordem universal-primeiro.

#### 1.4.2 Propósito

Módulo temático opcional que estende a constitution. Carregado seletivamente por workflows conforme relevância da tarefa, evitando inflar a constitution principal com regras que só fazem sentido em alguns contextos. Cada rule cobre **um único tema**.

#### 1.4.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `escopo` — um de: `universal`, `projeto`. Obrigatório. Indica em qual das duas localizações a rule mora.

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §4.6.3:**

1. `# Rule: <tema>` — título único, com tema em minúsculas (ex: `# Rule: testing`).
2. `## Quando carregar` — condições objetivas que indicam que workflows devem incluir essa rule. Imperativa.
3. `## Regras` — lista de regras imperativas, agrupadas em sub-seções `###` por sub-tema quando o número de regras passa de cinco.
4. `## Anti-regras` — o que explicitamente **não** fazer. Mesma forma de lista imperativa.
5. `## Exceções` — casos em que a regra pode ser relaxada, com justificativa explícita por exceção.

**Restrições adicionais:**

- Cada regra é uma frase única ou parágrafo de até três linhas.
- Cada anti-regra usa "não", "nunca" ou equivalente categórico.
- Cada exceção declara: condição da exceção + por que a relaxação é aceitável + o que continua valendo mesmo na exceção.

#### 1.4.4 Schema opcional

- Sub-seções `### <sub-tema>` dentro de `## Regras` e `## Anti-regras` para agrupar quando há mais de cinco itens. Recomendadas para legibilidade; não exigidas.
- Seção final `## Referências` com links para fontes externas que embasam o tema (ex: link para OWASP em `security.md`). Permitida apenas quando a referência é estável e publicamente acessível.

#### 1.4.5 Exemplo preenchido

Exemplo: `testing.md` (rule universal seed).

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
escopo: universal
---

# Rule: testing

## Quando carregar

Workflows devem carregar esta rule quando a tarefa envolve criação ou modificação de código de produção, fix de bug, ou refatoração. Workflows puramente documentais ou de revisão podem omitir.

## Regras

- Todo código novo deve ter teste correspondente. Sem teste, o código não está pronto.
- Bugfix deve incluir teste de regressão que falharia antes do fix e passa depois.
- Teste descreve **comportamento**, não implementação. Nomes de teste expressam o que o sistema faz, não como.
- Teste é determinístico. Flakiness é tratado como bug, não como tolerância.
- Setup compartilhado entre testes vive em fixture ou helper claro, não duplicado.

## Anti-regras

- Não deletar teste para fazê-lo passar. Teste que falha sinaliza problema no código ou no próprio teste — investigar, não silenciar.
- Não criar teste apenas para satisfazer cobertura. Teste sem asserção real é ruído.
- Não testar implementação interna privada quando comportamento público cobre o caso.
- Não introduzir teste flaky com `retry` ou `skip` sem registrar decision explicando.

## Exceções

- **Spike exploratório:** código de prova de conceito explicitamente declarado como descartável pode não ter testes. Condição: o spike vive em pasta marcada (`spikes/`, `prototypes/`) e não é mergeado para `main`.
- **Migração de dados única:** scripts de migração executados uma vez podem prescindir de teste de regressão. Continua valendo: o script deve ser idempotente (T1) e revisado antes da execução.
```

#### 1.4.6 Regras de validação

1. Frontmatter presente, com os três campos universais mais `escopo` em valor válido (`universal` ou `projeto`).
2. Título no formato `# Rule: <tema>`, com tema em minúsculas e sem espaços.
3. As quatro seções obrigatórias presentes na ordem: `## Quando carregar`, `## Regras`, `## Anti-regras`, `## Exceções`.
4. `## Regras` contém pelo menos três bullets de primeiro nível. Conforme critério literal de `SPEC.md` §6.3.
5. `## Anti-regras` contém pelo menos um bullet por regra de primeiro nível em `## Regras`. Não exigida correspondência um-a-um, mas a contagem mínima evita assimetria gritante.
6. Cada bullet em `## Anti-regras` começa com forma imperativa negativa (`Não`, `Nunca`, `Jamais`).
7. `## Exceções` contém pelo menos uma exceção declarada ou texto literal `Nenhuma.` quando não há.
8. Nenhuma referência a stack ou framework específico em rule universal. Rules de projeto podem mencionar stack.
9. Nenhuma ocorrência de palavras-fraca: `preferencialmente`, `recomendado`, `sugere-se`, `pode considerar`, `idealmente`.
10. Coerência entre `escopo` no frontmatter e localização do arquivo. Rule com `escopo: universal` mora em `~/.codeflow/framework/core/rules/`; com `escopo: projeto`, em `<projeto>/.codeflow/rules/`.

#### 1.4.7 Anti-padrões

- **Cobrir dois temas em uma rule.** Cada arquivo é mono-tema. `testing-and-security.md` é violação — divida em dois.
- **Regras sem anti-regras correspondentes.** O SPEC §6.3 exige paridade quando se trata de promover nova rule a universal. Mesmo em rule de projeto, a assimetria sinaliza regra mal formulada.
- **Exceções genéricas tipo "casos especiais".** Toda exceção é nomeada e justificada. "Pode relaxar quando fizer sentido" não é exceção, é falta de regra.
- **Regras específicas de stack em rule universal.** `pytest fixtures` em `testing.md` universal é violação. Versão universal fica agnóstica; específicos de stack vão para rule de projeto.
- **Prosa explicativa entre regras.** Cada regra é um bullet auto-suficiente. Transições e contexto pertencem a `## Quando carregar`, não à lista.
- **Numerar regras sem necessidade.** Use bullets `-`, não enumeração `1.`. Numeração só é justificada quando a ordem importa para aplicação — raramente o caso.

### 1.5 Workflows magros

#### 1.5.1 Localização

Duas localizações possíveis:

- **Universal:** `~/.codeflow/framework/library/workflows/<nome>.md`. Workflows seed magros entregues no escopo inicial: `review-only` (e potencialmente `format-check`, citado em `SPEC.md` §4.2.2 como exemplo).
- **Projeto:** `<projeto>/.codeflow/workflows/<nome>.md`. Criado quando o projeto precisa de variante específica.

Workflow de projeto sobrescreve universal de mesmo nome (`SPEC.md` §4.2.1).

#### 1.5.2 Propósito

Descreve sequência ordenada de passos para tarefa **simples, sem decisões intermediárias**. A IA executa direto, sem precisar perguntar nada ao usuário durante a execução. Tamanho-alvo: **20 a 30 linhas**.

Critério canônico (`SPEC.md` §4.2.2): "a IA pode fazer sem perguntar?" → workflow magro.

#### 1.5.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2, conforme `SPEC.md` §4.2.3:**

- `granularidade` — valor fixo `magro`.
- `gera_decision` — um de: `yes`, `no`, `auto`. Magros tipicamente declaram `no`.
- `usa_checkpoints` — valor fixo `no` para workflows magros.
- `politica_falhas` — valor fixo `padrão` para workflows magros (override não permitido em magro).

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §5.2:**

1. `# Workflow: <nome>` — título único.
2. `## Quando usar` — descrição imperativa do caso de uso. Uma a três linhas.
3. `## Quando NÃO usar` — anti-casos com workflow alternativo sugerido quando aplicável.
4. `## LEIA TAMBÉM` — lista de arquivos a carregar antes de começar. Conforme `SPEC.md` §4.2.3 item 4.
5. `## Protocolo` — passos sequenciais, cada um como sub-seção `### Passo N — <nome>`.
6. `## Definition of Done` — checklist objetivo de conclusão.
7. `## Resumo final` — template do formato fixo de cinco seções (`SPEC.md` §5.6.4).

**Restrições adicionais:**

- Tamanho-alvo aproximado do arquivo: **20 a 30 linhas** conforme `SPEC.md` §5.2. O número é orientação, não limite duro: o que descaracteriza o workflow como magro é existência de fases, decisões intermediárias ou perguntas ao usuário durante execução — não o tamanho exato. Quando o `## LEIA TAMBÉM` infla o arquivo total, contar a partir de `## Protocolo` como referência.
- Sem fases. Sem checkpoints. Sem perguntas ao usuário durante execução.
- Sem seção de proibições específicas (reservada para detalhados, §1.7).
- `## LEIA TAMBÉM` inclui obrigatoriamente: constitution universal, `.codeflow/INDEX.md`, `.codeflow/constitution.md`, `.codeflow/manifest.md`. Skills e rules adicionais são opcionais.

#### 1.5.4 Schema opcional

- Sub-bullets dentro de cada passo do `## Protocolo` para detalhar regra específica do passo. Permitidos somente quando o passo perde clareza sem eles.
- Skills universais relevantes em `## LEIA TAMBÉM` além das obrigatórias (ex: `self-review` para workflows que modificam código).

#### 1.5.5 Exemplo preenchido

Exemplo: `review-only.md` (workflow universal seed).

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
granularidade: magro
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: review-only

## Quando usar
Revisar diff produzido pelo usuário ou por outra sessão da IA, sem modificar código.

## Quando NÃO usar
- Para aplicar correções → use `/bugfix` ou `/refactor-safe`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Protocolo

### Passo 1 — Ler diff
Carregar diff via `git diff`. Não modificar arquivos.

### Passo 2 — Avaliar contra rules e manifest
Anotar violações, riscos e sugestões.

## Definition of Done
- [ ] Diff lido na íntegra.
- [ ] Cada arquivo avaliado contra rules carregadas.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
```

#### 1.5.6 Regras de validação

1. Frontmatter presente, parseável, com os três campos universais mais `granularidade: magro`, `gera_decision` em conjunto válido, `usa_checkpoints: no`, `politica_falhas: padrão`.
2. Tamanho-alvo aproximado do arquivo: 20 a 30 linhas, ou no máximo 50 quando `## LEIA TAMBÉM` é extenso. Acima de 50 linhas requer justificativa explícita no commit de criação.
3. As sete seções obrigatórias presentes na ordem listada em §1.5.3.
4. Título no formato `# Workflow: <nome>`, com `<nome>` em kebab-case correspondendo ao nome do arquivo.
5. `## LEIA TAMBÉM` contém as quatro entradas obrigatórias: constitution universal, `.codeflow/INDEX.md`, `.codeflow/constitution.md`, `.codeflow/manifest.md`.
6. `## Protocolo` contém pelo menos um passo `### Passo N — <nome>`.
7. Sem seção `## Fase N` (reservada para detalhados).
8. Sem seção `## Proibições durante este workflow` (reservada para detalhados).
9. Nenhuma referência a `gravação de checkpoint` no corpo do workflow.
10. `## Definition of Done` contém pelo menos um item de checklist `- [ ]`.

#### 1.5.7 Anti-padrões

- **Inchar workflow magro com passos opcionais.** Se a tarefa exige decisões intermediárias, é workflow médio — escolha a granularidade correta em vez de forçar formato.
- **Pular `## Quando NÃO usar`.** O SPEC §3.8 depende dessa seção para a IA avisar o usuário quando o workflow não combina com a tarefa. Não é opcional.
- **Listar todas as rules universais em `## LEIA TAMBÉM`.** Carregue só as relevantes — esse é o ponto das rules modulares.
- **Descrever o passo na própria seção `## Protocolo` em vez de em `### Passo N`.** Cada passo é uma sub-seção discreta, não bullet inline.
- **Adicionar `## Princípio guia`** (reservado para detalhados, §1.7).
- **Substituir `## Resumo final` por prosa livre.** O formato fixo de cinco seções do `SPEC.md` §5.6.4 é vinculante.

### 1.6 Workflows médios

#### 1.6.1 Localização

Duas localizações possíveis:

- **Universal:** `~/.codeflow/framework/library/workflows/<nome>.md`. Workflows seed médios entregues no escopo inicial: `bugfix`, `feature-small`, `refactor-safe` (`SPEC.md` §4.2.2 e §3.5).
- **Projeto:** `<projeto>/.codeflow/workflows/<nome>.md`. Criado quando o projeto precisa de variante.

Workflow de projeto sobrescreve universal de mesmo nome.

#### 1.6.2 Propósito

Descreve sequência ordenada de passos com **validações intermediárias entre eles**. A IA executa passos automaticamente, com gates de progressão; não conduz conversa com o usuário durante a execução. Tamanho-alvo de conteúdo substantivo: **60 a 100 linhas**.

Critério canônico (`SPEC.md` §4.2.2): "sequência com validações automáticas, sem conversa estruturada com o usuário" → workflow médio.

#### 1.6.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `granularidade` — valor fixo `médio`.
- `gera_decision` — um de: `yes`, `no`, `auto`.
- `usa_checkpoints` — valor fixo `no` para workflows médios.
- `politica_falhas` — `padrão` ou nome de override declarado (raro).

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §5.3:**

1. `# Workflow: <nome>` — título único.
2. `## Quando usar` — três a cinco linhas descrevendo caso de uso e pré-requisitos.
3. `## Quando NÃO usar` — anti-casos.
4. `## LEIA TAMBÉM` — lista de arquivos a carregar.
5. `## Antes de começar` — instruções condicionais: consultar decisions/INDEX se a tarefa toca em tags relevantes; carregar decisions ATIVAS.
6. `## Protocolo` — passos sequenciais como sub-seções `### Passo N — <nome>`, cada um com regras e (opcionalmente) gate de progressão.
7. `## Definition of Done` — checklist objetivo.
8. `## Resumo final` — template fixo de cinco seções.

**Restrições adicionais:**

- Tamanho-alvo aproximado do arquivo: **60 a 100 linhas** conforme `SPEC.md` §5.3. Orientação, não limite duro.
- Quatro a sete passos no `## Protocolo`. Menos que quatro indica que o workflow deveria ser magro; mais que sete indica que deveria ser detalhado.
- Pelo menos um passo de validação executando `make check` (ou alternativas conforme manifest do projeto).
- Sem fases, sem checkpoints, sem perguntas ao usuário durante execução.

#### 1.6.4 Schema opcional

- Sub-bullets dentro de cada passo: regras específicas + gate de progressão (formato `Gate: <condição>`).
- Skills universais relevantes em `## LEIA TAMBÉM` (ex: `debug-protocol` para `bugfix`, `self-review` para todos os workflows que modificam código).
- Override de política de falhas declarado no frontmatter quando o tema exige (raro; ex: workflow em área crítica que reduz limite de tentativas para um).

#### 1.6.5 Exemplo preenchido

Exemplo: `bugfix.md` (workflow universal seed).

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
granularidade: médio
gera_decision: auto
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: bugfix

## Quando usar
Corrigir bug reproduzível em código existente. Há sintoma observável, hipótese inicial possível, e escopo da correção é limitado a poucos arquivos. Pré-requisito: bug pode ser reproduzido localmente ou via teste.

## Quando NÃO usar
- Para feature nova → use `/feature-small`.
- Para refatoração sem bug → use `/refactor-safe`.
- Para investigar comportamento incerto (não há sintoma claro) → discutir em chat antes de invocar workflow.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/debug-protocol/SKILL.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Antes de começar
Se o bug toca em áreas com decisions arquivadas (auth, payments, schema), consultar `.codeflow/decisions/INDEX.md` e carregar decisions ATIVAS por tag.

## Protocolo

### Passo 1 — Reproduzir o bug
- Executar passos de reprodução fornecidos pelo usuário ou inferidos do relato.
- Confirmar sintoma observável (mensagem de erro, comportamento incorreto, output divergente).
- Gate: bug reproduzido. Se não reproduz, parar e pedir mais informação.

### Passo 2 — Escrever teste de regressão
- Criar teste que captura o comportamento errado: falha agora, passa após o fix.
- Não modificar código de produção ainda.
- Gate: teste roda e falha pelo motivo esperado.

### Passo 3 — Formar hipótese
- Aplicar protocolo da skill `debug-protocol`: uma hipótese por vez, declarada explicitamente, com critério de teste claro.
- Limite: três hipóteses no total. Se três falharem, aplicar política de falhas e parar.

### Passo 4 — Implementar fix
- Modificar **apenas** os arquivos necessários para a hipótese atual.
- Diff mínimo conforme constitution universal.
- Gate: teste de regressão (Passo 2) passa.

### Passo 5 — Validar
- Executar `make check` (ou alternativas conforme `.codeflow/manifest.md`).
- Aplicar skill `self-review` no diff produzido.
- Se `make check` falha: aplicar política de falhas da constitution.

### Passo 6 — Resumir e (se aplicável) gerar decision
- Apresentar resumo final no formato fixo de cinco seções.
- Se o fix envolveu mudança não-trivial (não foi typo, não foi off-by-one isolado), gerar decision em `.codeflow/decisions/`.

## Definition of Done
- [ ] Bug reproduzido no Passo 1.
- [ ] Teste de regressão adicionado e falhando antes do fix.
- [ ] Teste de regressão passando após o fix.
- [ ] `make check` retornou zero.
- [ ] Diff dentro do escopo declarado.
- [ ] Self-review aplicado.
- [ ] Decision gerada se aplicável (gera_decision: auto).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
```

#### 1.6.6 Regras de validação

1. Frontmatter presente, com `granularidade: médio`, `usa_checkpoints: no`, `gera_decision` em conjunto válido.
2. Tamanho-alvo aproximado do arquivo: 60 a 100 linhas, conforme `SPEC.md` §5.3. Arquivos significativamente fora dessa faixa requerem revisão de granularidade.
3. As oito seções obrigatórias presentes na ordem listada em §1.6.3.
4. `## Protocolo` contém entre **quatro e sete** passos `### Passo N — <nome>`.
5. Pelo menos um passo invoca `make check` ou comando equivalente declarado no manifest.
6. `## LEIA TAMBÉM` contém as quatro entradas obrigatórias (constitution universal, INDEX, constitution de projeto, manifest).
7. `## Antes de começar` referencia `.codeflow/decisions/INDEX.md` quando o tema do workflow pode tocar decisions.
8. `## Definition of Done` inclui item de validação executando `make check` (ou marcação `[—]` permitida quando target ausente).
9. Sem seção `## Fase N` ou `## Proibições durante este workflow` (reservadas para detalhados).
10. Quando `gera_decision: yes` ou `auto`, o protocolo declara explicitamente em qual passo a decision é gerada.

#### 1.6.7 Anti-padrões

- **Embutir conversa estruturada com o usuário em workflow médio.** Conversas vão para workflows detalhados (§1.7). Se a tarefa exige perguntar coisas ao usuário durante a execução, escolha a granularidade certa.
- **Pular `## Antes de começar`.** Decisions ativas existem justamente para evitar repetir erros. Workflows médios que ignoram decisions tornam o registro irrelevante.
- **Validar sem `make check`.** Conforme `SPEC.md` §3.10, comandos brutos diretos (ex: `pytest tests/`) são proibidos. Sempre via `make`.
- **Gate ausente entre passos sequenciais.** Cada passo termina em estado verificável; o gate declara o que deve ser verdade antes de avançar.
- **Lista de `## LEIA TAMBÉM` colada de outro workflow.** Carregar rule irrelevante (ex: `security.md` em refactor puramente cosmético) é ruído de contexto.
- **`gera_decision: yes` em bugfix de typo.** Decision é registro de **decisão** não-trivial. Para bugs cosméticos, `gera_decision: auto` deixa a IA pular o registro.

### 1.7 Workflows detalhados

#### 1.7.1 Localização

Duas localizações possíveis:

- **Universal:** `~/.codeflow/framework/library/workflows/<nome>.md`. Workflows detalhados universais são raros; no escopo inicial não há workflow detalhado em `library/workflows/` — os exemplos canônicos (`discover`, `bootstrap`) vivem em `framework/meta/` como meta-skills (§1.9), não como workflows.
- **Projeto:** `<projeto>/.codeflow/workflows/<nome>.md`. Criado quando o projeto precisa de processo estruturado com múltiplas decisões abertas.

Workflow de projeto sobrescreve universal de mesmo nome.

#### 1.7.2 Propósito

Conduz **conversa estruturada com o usuário** em múltiplas fases, com decisões abertas, perguntas intermediárias, e checkpoints entre fases. A IA não executa sozinha — alterna entre executar e consultar o usuário. Tamanho-alvo aproximado: **150 a 300 linhas**.

Critério canônico (`SPEC.md` §4.2.2): "conduz conversa estruturada com o usuário" → workflow detalhado.

#### 1.7.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `granularidade` — valor fixo `detalhado`.
- `gera_decision` — geralmente `yes` (decisões abertas merecem registro).
- `usa_checkpoints` — valor fixo `yes` para workflows detalhados.
- `politica_falhas` — `padrão` ou override declarado.

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §5.4:**

1. `# Workflow: <nome>` — título único.
2. `## Princípio guia` — duas a três linhas declarando a filosofia do workflow. Exclusivo de detalhados.
3. `## Quando usar` — descrição extensa: contexto, pré-requisitos, audiência.
4. `## Quando NÃO usar` — anti-casos.
5. `## LEIA TAMBÉM` — lista extensa de arquivos a carregar.
6. `## Estrutura do workflow` — declara em quantas fases o workflow opera. Uma a três linhas.
7. `## Fase 1 — <nome>` (e fases subsequentes) — cada fase com sub-seções `### Objetivo`, `### Ações`, `### Checkpoint`.
8. `## Fase N — Geração de artefatos` — última fase obrigatória, declara o que será gerado e onde.
9. `## Proibições durante este workflow` — ações que normalmente seriam permitidas mas são bloqueadas neste workflow.
10. `## Definition of Done` — checklist mais extenso, com itens específicos do workflow.
11. `## Resumo final` — template fixo de cinco seções.

**Restrições adicionais:**

- Tamanho-alvo aproximado: **150 a 300 linhas**.
- Três a sete fases. Menos que três indica que o workflow deveria ser médio; mais que sete indica que deveria ser dividido em workflows separados.
- Cada fase termina em checkpoint (grava estado em `.codeflow/checkpoints/<workflow>-<timestamp>.md`).
- Pelo menos uma fase pausa para pergunta ao usuário. Workflow detalhado sem interação com usuário é workflow médio mal-classificado.

#### 1.7.4 Schema opcional

- Override de política de falhas declarado no frontmatter. Workflows detalhados em áreas críticas podem reduzir limite de tentativas.
- Sub-seção `### Validação` dentro de cada fase, quando a fase produz artefato verificável imediatamente.
- Seção `## Retomada` antes de `## Fase 1`, declarando como o workflow detecta checkpoint pré-existente e oferece retomar (conforme `SPEC.md` §6.6.3).

#### 1.7.5 Exemplo preenchido

Exemplo: esqueleto de workflow detalhado hipotético `db-migration` (não é workflow seed; usado para ilustrar a estrutura sem alongar este documento). Workflows seed equivalentes em estrutura: `discover` e `bootstrap`, descritos como meta-skills em §1.9.

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
granularidade: detalhado
gera_decision: yes
usa_checkpoints: yes
politica_falhas: padrão
---

# Workflow: db-migration

## Princípio guia
Migrações de schema são reversíveis por padrão. Cada migração tem caminho de rollback explícito antes de ser aplicada. Nenhum dado é perdido sem decisão registrada.

## Quando usar
Aplicar mudança de schema no banco do projeto: criar tabela, alterar coluna, renomear índice, criar constraint. Pré-requisito: o projeto tem ferramenta de migração configurada (Alembic, Flyway, Knex, similar) e o usuário está disponível para confirmar decisões intermediárias.

## Quando NÃO usar
- Para data migration sem mudança de schema → use `/data-fix` (não no escopo inicial).
- Para criar projeto novo do zero → use `/bootstrap`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/core/rules/security.md
- ~/.codeflow/framework/library/skills/handoff/SKILL.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (filtrar por tag `schema`)

## Estrutura do workflow
Quatro fases sequenciais. Checkpoint ao fim de cada fase. Pausa para confirmação do usuário entre Fase 2 e Fase 3.

## Fase 1 — Inspeção

### Objetivo
Compreender o schema atual e o impacto da mudança proposta.

### Ações
1. Ler schema atual da área afetada (ler migrações anteriores ou usar introspecção).
2. Listar consumidores do schema impactado (queries, ORMs, views, jobs).
3. Identificar dados em produção que serão afetados (estimativa de linhas, tipos de valor).

### Checkpoint
Gravar `.codeflow/checkpoints/db-migration-<timestamp>.md` com: schema atual, consumidores listados, estimativa de impacto.

## Fase 2 — Desenho

### Objetivo
Definir a mudança e seu rollback.

### Ações
1. Propor migração `up` (mudança forward).
2. Propor migração `down` (rollback).
3. Identificar dados que exigem transformação (não só DDL).
4. Apresentar plano ao usuário e aguardar confirmação.

### Checkpoint
Gravar estado: proposta `up`, proposta `down`, transformações de dados, resposta do usuário.

## Fase 3 — Implementação

### Objetivo
Gerar arquivos de migração e código de aplicação adaptado.

### Ações
1. Criar arquivo de migração com `up` e `down`.
2. Adaptar código de aplicação (modelos, queries, types).
3. Adicionar testes que rodam contra schema novo.
4. Executar `make check`.

### Checkpoint
Gravar estado: arquivos criados/modificados, resultado de `make check`.

## Fase 4 — Geração de artefatos

### Objetivo
Registrar a decisão e finalizar.

### Ações
1. Gerar decision em `.codeflow/decisions/<data>-<titulo>.md` com tags `[schema, migration]`.
2. Atualizar `.codeflow/decisions/INDEX.md`.
3. Apresentar resumo final.

## Proibições durante este workflow
- Não aplicar a migração em ambiente de produção. Workflow gera arquivos; aplicação é decisão separada do usuário.
- Não deletar migrações anteriores, mesmo que pareçam obsoletas.
- Não alterar arquivo de migração já mergeado em `main` (criar nova migração que corrige, em vez).

## Definition of Done
- [ ] Schema atual inspecionado (Fase 1).
- [ ] Proposta `up` e `down` confirmadas pelo usuário (Fase 2).
- [ ] Arquivos de migração criados com `up` e `down` simétricos.
- [ ] Testes adaptados e passando.
- [ ] `make check` retornou zero.
- [ ] Decision gerada com tags `[schema, migration]`.
- [ ] Checkpoints da execução deletados (workflow concluído com sucesso).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
```

#### 1.7.6 Regras de validação

1. Frontmatter presente, com `granularidade: detalhado`, `usa_checkpoints: yes`, `gera_decision` em conjunto válido.
2. Tamanho-alvo aproximado: 150 a 300 linhas. Arquivos significativamente fora dessa faixa requerem revisão de granularidade.
3. As onze seções obrigatórias presentes na ordem listada em §1.7.3.
4. Entre **três e sete fases** `## Fase N — <nome>`.
5. Cada fase contém as três sub-seções obrigatórias: `### Objetivo`, `### Ações`, `### Checkpoint`.
6. A última fase tem nome iniciado por "Geração de artefatos" ou equivalente declarando o que é entregue.
7. `## Princípio guia` presente (seção exclusiva de detalhados).
8. `## Proibições durante este workflow` presente, com pelo menos um bullet.
9. Pelo menos uma fase declara pausa para confirmação do usuário (presença de termos como "aguardar confirmação", "pergunta ao usuário", "apresentar plano e aguardar").
10. Cada `### Checkpoint` referencia caminho `.codeflow/checkpoints/<workflow>-<timestamp>.md`.

#### 1.7.7 Anti-padrões

- **Workflow detalhado sem pausa para o usuário.** Se a IA executa tudo sem perguntar nada, o workflow é médio, não detalhado. Mude a granularidade.
- **Fases sem checkpoint.** Cada fase grava estado — esse é o motivo de existir como fase, não como passo. Pular checkpoint quebra o protocolo de retomada (`SPEC.md` §6.6).
- **Proibições genéricas tipo "seja cuidadoso".** Cada proibição é operação concreta bloqueada (ex: "não aplicar migração em produção"). Generalidades não restringem.
- **Mais de sete fases.** Indica que o workflow deveria ser dividido em workflows separados, encadeados por slash commands distintos.
- **`gera_decision: no` em workflow detalhado.** Decisões abertas merecem registro — esse é o ponto da granularidade detalhada. Exceções exigem justificativa no commit de criação.
- **`## Princípio guia` como prosa filosófica longa.** Duas a três linhas. Princípio é frase curta, não ensaio.
- **Misturar Geração de artefatos no meio do workflow.** A última fase é sempre Geração de artefatos. Gerar artefato em fase intermediária quebra a invariante e dificulta retomada.

### 1.8 Skills

#### 1.8.1 Localização

Duas localizações possíveis, sempre em pasta com nome da skill em kebab-case:

- **Universal:** `~/.codeflow/framework/library/skills/<nome>/SKILL.md`. Skills seed entregues no escopo inicial: `debug-protocol`, `handoff`, `self-review` (`SPEC.md` §4.3.2).
- **Projeto:** `<projeto>/.codeflow/skills/<nome>/SKILL.md`. Criada sob demanda quando uma capacidade é específica do projeto.

A pasta da skill contém **no mínimo** `SKILL.md`. Pode conter arquivos auxiliares (templates, scripts, exemplos) referenciados pelo `SKILL.md` (`SPEC.md` §4.3.1).

#### 1.8.2 Propósito

Encapsula uma **capacidade discreta e reutilizável** que é aplicada **dentro** de workflows. Diferente de workflow (que é processo — o quê fazer, em que ordem), skill é capacidade (como fazer uma coisa bem).

Skills nunca são invocadas diretamente por slash command. São carregadas pela seção `## LEIA TAMBÉM` de workflows.

#### 1.8.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `descrição` — uma linha resumindo a capacidade da skill. Obrigatória.

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §4.3.3:**

1. `# Skill: <nome>` — título único.
2. `## Quando usar` — condições objetivas que indicam que a skill deve ser carregada/aplicada por um workflow.
3. `## Princípio guia` — uma ou duas frases resumindo a filosofia da skill.
4. `## Protocolo` — passos da skill em sequência. Diferente de workflow, **skills não têm Definition of Done**.
5. `## Proibições durante esta skill` — o que NÃO fazer enquanto a skill está ativa.
6. `## Saídas válidas` — o que a skill produz como resultado.

**Restrições adicionais:**

- Skill é aplicada **dentro** de workflows, nunca invocada isoladamente. O protocolo da skill é um sub-protocolo do passo de workflow que a carrega.
- `## Princípio guia` é curto (até três frases). Princípio é base filosófica, não tutorial.
- `## Saídas válidas` declara o **tipo** de saída (ex: "lista numerada de hipóteses testáveis", "arquivo de handoff em formato fixo"), não o conteúdo exato.

#### 1.8.4 Schema opcional

- Arquivos auxiliares na pasta da skill (`template.md`, `exemplo.md`, `<script>.sh`). Cada arquivo auxiliar referenciado explicitamente em `## Protocolo` ou `## Saídas válidas`.
- Sub-seções `### <fase>` dentro de `## Protocolo` quando a skill tem fases internas (raro; skills curtas devem ser mantidas curtas).
- Seção final `## Referências` quando a skill se baseia em fonte externa identificável (link, livro, paper).

#### 1.8.5 Exemplo preenchido

Exemplo: `debug-protocol/SKILL.md` (skill universal seed).

Estrutura da pasta:

```
~/.codeflow/framework/library/skills/debug-protocol/
└── SKILL.md
```

Conteúdo do `SKILL.md`:

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
descrição: Protocolo anti-loop para debug. Uma hipótese por vez, limite de tentativas, parar e reportar.
---

# Skill: debug-protocol

## Quando usar

Workflows devem carregar esta skill quando a tarefa envolve diagnóstico de bug, comportamento errôneo, ou falha não-reproduzível imediatamente. Workflows de fix puramente cosmético (typo, formatação) podem omitir.

## Princípio guia

Bug não cede a tentativas aleatórias. Cede a hipóteses testáveis aplicadas uma de cada vez. Loop em bug simples é falha de processo, não de inteligência.

## Protocolo

### 1. Reproduzir antes de hipotetizar
- Bug que não pode ser reproduzido não pode ser corrigido. Se não há reprodução, parar e pedir mais informação ao usuário.
- Reprodução é um teste ou sequência de passos manuais que sempre dispara o sintoma.

### 2. Formar uma hipótese explícita
- Hipótese declara: causa provável + arquivo/função suspeita + previsão (o que acontece se a hipótese estiver certa).
- Sem hipótese, não há mudança no código.

### 3. Testar a hipótese antes de implementar
- Adicionar log, breakpoint, ou inspeção que valida ou refuta a hipótese.
- Se a hipótese é refutada, registrar e formar nova hipótese.

### 4. Implementar fix correspondente à hipótese validada
- Apenas modificar o que a hipótese aponta. Sem refatoração adjacente.
- Validar que o sintoma desapareceu rodando a reprodução.

### 5. Limite de tentativas
- Máximo de **três** hipóteses por sessão de debug.
- Após três hipóteses falhas consecutivas, parar e aplicar política de falhas da constitution (formato PARADO).

## Proibições durante esta skill

- Não tentar duas hipóteses em paralelo. Uma por vez, completa, antes da próxima.
- Não modificar código antes de validar a hipótese.
- Não silenciar erro com try/except amplo para "fazer passar".
- Não desabilitar teste para evitar a falha.

## Saídas válidas

- **Bug corrigido:** diff mínimo aplicado, teste de regressão passando, hipótese validada documentada no resumo final do workflow.
- **Bug não corrigido (limite atingido):** reporte PARADO no formato fixo da constitution, listando as três hipóteses testadas, o que cada uma refutou, e estado atual do código.
```

#### 1.8.6 Regras de validação

1. Frontmatter presente, com `descrição` em uma única linha.
2. Pasta da skill em kebab-case, com `SKILL.md` em maiúsculas (nome exato).
3. Título no formato `# Skill: <nome>`, com `<nome>` correspondendo ao nome da pasta.
4. As seis seções obrigatórias presentes na ordem listada em §1.8.3.
5. **Não** contém seção `## Definition of Done` (vedada para skills — esta é seção de workflow).
6. **Não** contém seção `## LEIA TAMBÉM` (vedada — skills não carregam outros arquivos; quem carrega é workflow).
7. `## Princípio guia` tem entre uma e três frases.
8. `## Proibições durante esta skill` contém pelo menos um bullet imperativo negativo.
9. `## Saídas válidas` declara tipos de saída (não conteúdo específico).
10. Arquivos auxiliares na pasta (se houver) são referenciados explicitamente em `## Protocolo` ou `## Saídas válidas`.

#### 1.8.7 Anti-padrões

- **Skill como mini-workflow.** Adicionar `## Definition of Done`, `## Resumo final`, ou `## Antes de começar` confunde os papéis. Skill aplica capacidade; workflow define processo.
- **Skill que invoca outra skill.** Conforme `SPEC.md` §10.6, composição entre skills é anti-feature. Skills compõem com workflows, não entre si.
- **Skill genérica demais.** "Boas práticas de código" é tema, não skill. Skill captura **uma** capacidade discreta com protocolo claro.
- **Princípio guia como manifesto.** Duas a três frases. Filosofia, não dissertação.
- **Proibições sem operação concreta.** "Não seja descuidado" não é proibição; "Não modificar código antes de validar hipótese" é.
- **Saídas válidas como prosa de resultado esperado.** Tipo, não conteúdo. "Diff mínimo aplicado" é tipo; "diff corrigindo bug do contador" é conteúdo (específico demais para saída de skill genérica).

### 1.9 Meta-skills

#### 1.9.1 Localização

Localização única (meta-skills sempre são universais, conforme `SPEC.md` §4.4.1):

`~/.codeflow/framework/meta/<nome>/SKILL.md`

Meta-skills seed entregues no escopo inicial (`SPEC.md` §4.4.2): `discover`, `bootstrap`, `create-workflow`, `create-skill`, `create-agent`. Total: cinco.

A pasta da meta-skill segue a mesma convenção de skill (§1.8.1): contém no mínimo `SKILL.md`, pode conter arquivos auxiliares.

#### 1.9.2 Propósito

Skill cujo propósito é **criar outros artefatos do framework** — outros workflows, skills, agents, ou os artefatos iniciais de projeto (INDEX, constitution, manifest, discovered). Meta-skills são skills sobre skills.

Diferente de skills regulares, meta-skills **são invocadas diretamente por slash command** quando o nome é parte da interface do usuário (ex: `/discover`, `/bootstrap`, `/create-workflow`).

#### 1.9.3 Schema obrigatório

Meta-skill segue **toda a estrutura obrigatória de skill** (§1.8.3) e adiciona três seções obrigatórias específicas, conforme `SPEC.md` §4.4.3:

**Frontmatter — campos além dos universais da §0.2:**

- `descrição` — uma linha resumindo a capacidade. Obrigatória (herdado de skill).
- `é_meta_skill` — valor fixo `yes`. Permite distinção mecânica de skills regulares.
- `granularidade` — uma de: `magro`, `médio`, `detalhado`. Meta-skills do tipo `discover` e `bootstrap` são detalhadas; do tipo `create-*` podem ser médias.

**Seções markdown — na ordem fixa abaixo:**

1. `# Meta-skill: <nome>` — título único.
2. `## Quando usar` — herdado de skill, mas com critério adicional: a meta-skill é invocada quando a tarefa é **criar** um artefato do framework.
3. `## Princípio guia` — herdado de skill.
4. `## Protocolo` — herdado de skill. Em meta-skills detalhadas, segue estrutura de fases similar a workflow detalhado.
5. `## Proibições durante esta meta-skill` — herdado de skill (renomeado para refletir o tipo).
6. `## Template de saída` — **seção exclusiva de meta-skill**. Formato exato do arquivo gerado, com placeholders explícitos.
7. `## Onde salvar` — **seção exclusiva de meta-skill**. Caminho exato do arquivo gerado, distinguindo universal (`~/.codeflow/...`) versus projeto (`.codeflow/...`).
8. `## Validação pós-geração` — **seção exclusiva de meta-skill**. Verificações que a IA faz no arquivo recém-criado antes de apresentar ao usuário.
9. `## Saídas válidas` — herdado de skill.

**Restrições adicionais:**

- O template em `## Template de saída` é literal, em bloco de código, com placeholders identificados por `<chave>` ou `{{chave}}`. Sem prosa explicando o template — o template fala por si.
- `## Onde salvar` declara caminho **exato**, sem ambiguidade. Se houver dois destinos possíveis (universal vs projeto), declara o critério de escolha.
- `## Validação pós-geração` declara checks objetivos. Esses checks correspondem às regras de validação definidas neste documento para o tipo de artefato gerado.

#### 1.9.4 Schema opcional

- Arquivos auxiliares na pasta da meta-skill: `template.md` separado (referenciado por `## Template de saída`), `exemplos/` com instâncias preenchidas, scripts de validação em bash.
- Seção `## Retomada` quando a meta-skill é detalhada e usa checkpoints (caso de `discover` e `bootstrap`).
- Override de política de falhas quando a meta-skill opera em área crítica.

#### 1.9.5 Exemplo preenchido

Exemplo: `create-workflow/SKILL.md` (meta-skill seed). Versão de granularidade média, ilustrando a estrutura mínima de meta-skill.

Estrutura da pasta:

```
~/.codeflow/framework/meta/create-workflow/
└── SKILL.md
```

Conteúdo do `SKILL.md`:

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
descrição: Entrevista o usuário e gera workflow novo no formato correto.
é_meta_skill: yes
granularidade: médio
---

# Meta-skill: create-workflow

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
Aplicar `## Template de saída` substituindo placeholders pelos valores coletados.

### Passo 6 — Validar e apresentar
Aplicar `## Validação pós-geração`. Se qualquer check falha, corrigir antes de apresentar.

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
```

#### 1.9.6 Regras de validação

1. Frontmatter presente, com `descrição`, `é_meta_skill: yes`, `granularidade` em conjunto válido.
2. Pasta da meta-skill em `~/.codeflow/framework/meta/<nome>/`, com `SKILL.md` em maiúsculas.
3. Título no formato `# Meta-skill: <nome>`.
4. As nove seções obrigatórias presentes na ordem listada em §1.9.3.
5. As três seções exclusivas de meta-skill presentes: `## Template de saída`, `## Onde salvar`, `## Validação pós-geração`.
6. `## Template de saída` contém ao menos um bloco de código markdown ou referência explícita a template existente em `ARTIFACTS_SPEC.md`.
7. `## Onde salvar` declara caminho exato (não "pasta apropriada" ou genéricos).
8. `## Validação pós-geração` lista pelo menos três checks objetivos.
9. Para meta-skill com `granularidade: detalhado`, presença de fases `### Fase N` em `## Protocolo` ou seção `## Retomada` opcional.
10. Nenhuma referência a stack específica em meta-skill universal (meta-skills são sempre agnósticas).

#### 1.9.7 Anti-padrões

- **Meta-skill que gera coisa fora do framework.** Se a meta-skill cria arquivo de projeto qualquer (ex: gerar componente React, gerar API endpoint), é workflow, não meta-skill. Meta-skill cria **artefatos do framework**.
- **Template prosa em vez de literal.** `## Template de saída` é o template, não descrição dele. Sem "o arquivo deve ter um cabeçalho", sim com o cabeçalho efetivo em bloco de código.
- **`## Onde salvar` ambíguo.** "Pasta apropriada" não é caminho. Sempre `~/.codeflow/framework/...` ou `<projeto>/.codeflow/...` com nome de subpasta.
- **`## Validação pós-geração` herdada genericamente.** Cada meta-skill valida o tipo específico de artefato que gera. `create-workflow` valida conforme §1.5/1.6/1.7; não como "valide se está OK".
- **Meta-skill sem qualificação inicial.** Toda meta-skill começa qualificando se a criação é mesmo necessária — anti-evolução (`SPEC.md` §6.3) começa aqui.
- **Adicionar `## Definition of Done` por confusão com workflow.** Meta-skill segue regra de skill (§1.8.3 item 4): sem Definition of Done. As verificações vão em `## Validação pós-geração`.

### 1.10 Agents

#### 1.10.1 Localização

Duas localizações possíveis:

- **Universal:** `~/.codeflow/framework/library/agents/<nome>.md`. **Nenhum agent seed é entregue no escopo inicial** (`SPEC.md` §4.5.4).
- **Projeto:** `<projeto>/.codeflow/agents/<nome>.md`. Criado pela meta-skill `create-agent` sob demanda.

Diferente de skills e workflows, agent é um único arquivo `.md` (não pasta).

#### 1.10.2 Propósito

Definição de **subagente** da ferramenta de IA com escopo de ferramentas restrito, invocado por workflow para isolar sub-tarefa em contexto próprio. Não é a IA inteira — é instância especializada com permissões limitadas.

No escopo inicial, apenas a meta-skill `create-agent` é entregue. Agents propriamente ditos são criados sob demanda, quando o usuário identifica necessidade real de isolar contexto.

#### 1.10.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `escopo` — um de: `universal`, `projeto`. Obrigatório.

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §4.5.3:**

1. `# Agent: <nome>` — título único.
2. `## Propósito` — o que o agent faz e por que existe **como agent** (não como skill nem workflow).
3. `## Ferramentas permitidas` — lista exaustiva de tools que o agent pode usar (ex: Read, Glob, Grep). Lista é fechada — tools fora dela são proibidas.
4. `## System prompt` — o prompt de sistema do agent, incluindo restrições. Em bloco de código markdown.
5. `## Como invocar` — instrução para workflows que querem usar esse agent.

**Restrições adicionais:**

- `## Ferramentas permitidas` é declaração positiva (apenas estas tools), não negativa (proibições). Tudo que não está listado é proibido.
- `## System prompt` é literal: o bloco de código contém o texto exato que será injetado como system prompt ao agent.
- `## Como invocar` declara passos concretos do workflow chamador (ex: "Workflow X chama o agent via mecanismo Y da ferramenta de IA, passando arquivo Z como input").
- `## Propósito` justifica por que agent (não skill): a sub-tarefa exige **isolamento de contexto** ou **restrição de permissões** que skill não oferece.

#### 1.10.4 Schema opcional

- Sub-seção `### Caso de uso típico` em `## Propósito` com exemplo concreto de workflow que usa o agent.
- Seção `## Limitações conhecidas` declarando o que o agent **não** consegue fazer mesmo dentro do escopo de ferramentas permitidas.

#### 1.10.5 Exemplo preenchido

Exemplo: `code-reviewer.md` (agent hipotético — não é agent seed do framework). Ilustra o schema sem implicar entrega no escopo inicial.

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
escopo: universal
---

# Agent: code-reviewer

## Propósito

Revisar diff de código produzido por workflow em sessão isolada, sem possibilidade de modificar arquivos. Existe como agent (não como skill) porque a revisão exige **garantia mecânica** de não-modificação: as ferramentas permitidas não incluem nenhuma capacidade de edição. Skill regular dependeria de disciplina; agent restringe na camada de ferramenta.

## Ferramentas permitidas

- Read (leitura de arquivos)
- Glob (listagem de arquivos por padrão)
- Grep (busca textual em arquivos)

Toda outra tool (Edit, Write, Bash, network) é proibida e não acessível ao agent.

## System prompt

```
Você é o agent code-reviewer do codeflow. Sua única tarefa é revisar diff de código e reportar.

Você não modifica arquivos. Você não executa comandos. Você não pode acessar a rede. Suas ferramentas estão restritas a Read, Glob e Grep.

Ao receber um diff:
1. Leia o diff completo.
2. Avalie cada arquivo modificado contra a constitution universal, a constitution do projeto, e as rules carregadas pelo workflow chamador.
3. Reporte achados em três categorias: violações de constitution/rules, riscos identificados, sugestões de melhoria.

Se for solicitado a modificar algo, recuse e explique que está operando como agent restrito.
```

## Como invocar

Workflow chamador (tipicamente `feature-small` ou `bugfix`) invoca o agent ao terminar a fase de implementação:

1. Salvar o diff produzido em arquivo temporário, ou identificá-lo via `git diff`.
2. Invocar o agent passando: caminho do diff, lista de rules carregadas, constitution efetiva (universal + projeto).
3. Aguardar o reporte do agent.
4. Incorporar achados no resumo final do workflow.

## Limitações conhecidas

- Não consegue rodar testes ou validações dinâmicas (sem acesso a Bash).
- Não consegue inspecionar histórico de commits além do diff fornecido.
- Não tem memória entre invocações: cada chamada é independente.
```

#### 1.10.6 Regras de validação

1. Frontmatter presente, com `escopo` em conjunto válido.
2. Arquivo único (não pasta) em `~/.codeflow/framework/library/agents/<nome>.md` (universal) ou `<projeto>/.codeflow/agents/<nome>.md` (projeto).
3. Título no formato `# Agent: <nome>`, com `<nome>` em kebab-case correspondendo ao nome do arquivo.
4. As cinco seções obrigatórias presentes na ordem listada em §1.10.3.
5. `## Ferramentas permitidas` contém lista explícita de tools, em bullets `-`.
6. `## System prompt` contém pelo menos um bloco de código markdown com o prompt literal.
7. `## Propósito` declara por que agent (não skill). A palavra "isolamento" ou "restrição" deve aparecer.
8. `## Como invocar` declara passos numerados ou enumerados de como o workflow chamador usa o agent.
9. Lista de ferramentas permitidas não inclui tools mutuamente contraditórias (ex: agent declarado como "somente leitura" não pode listar Edit).
10. Coerência entre `escopo` no frontmatter e localização do arquivo.

#### 1.10.7 Anti-padrões

- **Agent que duplica skill.** Se a sub-tarefa pode ser realizada com disciplina (sem exigir restrição mecânica de ferramentas), use skill, não agent. Agent é mais caro de operar e justificável apenas quando isolamento importa.
- **`## Ferramentas permitidas` como declaração negativa.** "Tudo exceto Edit" é proibido. Sempre lista positiva fechada.
- **System prompt em prosa fora de bloco de código.** O prompt é literal, vai no system prompt da ferramenta — bloco de código preserva fidelidade.
- **`## Como invocar` genérico.** "O workflow chama o agent quando precisar." Não é instrução. Sempre passos concretos com inputs e outputs identificados.
- **Agent sem `## Propósito` justificando por que agent.** Toda criação de agent justifica isolamento. Sem justificativa, a criação viola anti-evolução (`SPEC.md` §6.3).
- **Agent seed entregue no escopo inicial.** Conforme `SPEC.md` §4.5.4, o framework inicial entrega apenas a meta-skill `create-agent`. Agents reais são criados sob demanda.

### 1.11 Wrappers de slash command

Wrappers materializam a decisão de `SPEC.md` §3.6.1: cada workflow universal e cada meta-skill seed ganha um arquivo curto que registra o nome como slash command nativo na ferramenta de IA (Claude Code). Wrappers não fazem trabalho — apenas instruem a IA a ler o arquivo real e executar.

#### 1.11.1 Localização

Dois caminhos canônicos, conforme escopo:

- **Universal:** `~/.claude/commands/<nome>.md` — disponível em qualquer projeto.
- **Projeto:** `<projeto>/.claude/commands/<nome>.md` — disponível apenas dentro do projeto; sobrescreve homônimo universal.

Wrappers **não** vivem em `~/.codeflow/framework/` nem em `<projeto>/.codeflow/` — são gerados em `~/.claude/commands/` (pelo `setup-slash-commands.sh`) ou em `<projeto>/.claude/commands/` (pelo `install.sh`).

#### 1.11.2 Propósito

Fechar o gap entre a decisão arquitetural de `SPEC.md` §3.6 (workflows via slash command) e a implementação concreta. Sem o wrapper, o usuário precisaria digitar manualmente "leia tal arquivo e execute" toda vez. O wrapper transforma isso em `/bugfix`.

#### 1.11.3 Schema obrigatório

**Frontmatter:** opcional. Pode ser omitido completamente. Se presente, segue os campos universais de §0.2 (versão, status, atualizado).

**Corpo:**

- 2 a 4 linhas em pt-BR.
- Contém **exatamente uma** referência a path absoluto começando com `~/.codeflow/framework/` (universal) ou `<projeto>/.codeflow/` (projeto).
- Instrui a IA a ler o arquivo referenciado e executar o protocolo, carregando `## LEIA TAMBÉM` antes.
- Sem lógica adicional, sem duplicação de conteúdo, sem reformulação do workflow.

**Restrições adicionais:**

- Tamanho-alvo: 2 a 4 linhas. Acima de 6 sinaliza que conteúdo do workflow vazou para o wrapper.
- Nome do arquivo (`<nome>.md`) **deve** bater com o nome do workflow/meta-skill referenciado.

#### 1.11.4 Schema opcional

- Nada. Wrappers são deliberadamente mínimos. Qualquer enriquecimento (parâmetros, variantes) cabe no workflow, não no wrapper.

#### 1.11.5 Exemplo preenchido

Wrapper universal para o workflow `bugfix`:

```markdown
Leia ~/.codeflow/framework/library/workflows/bugfix.md e execute o protocolo
descrito ali, aplicando ao projeto atual. Carregue todos os arquivos listados
em ## LEIA TAMBÉM antes de começar.
```

Wrapper universal para a meta-skill `discover`:

```markdown
Leia ~/.codeflow/framework/meta/discover/SKILL.md e execute o protocolo da
meta-skill no projeto atual. Carregue arquivos referenciados antes de começar.
```

Wrapper de projeto para um workflow específico do projeto:

```markdown
Leia ~/projetos/meu-projeto/.codeflow/workflows/deploy-staging.md e execute
o protocolo descrito ali. Carregue ## LEIA TAMBÉM antes de começar.
```

#### 1.11.6 Regras de validação

1. Corpo tem entre 2 e 6 linhas (alvo: 2-4).
2. Contém exatamente uma linha começando com `~/.codeflow/framework/` (universal) ou caminho absoluto para `<projeto>/.codeflow/` (projeto).
3. Path referenciado existe no disco (verificação dinâmica feita pelo `setup-slash-commands.sh` ao gerar/atualizar).
4. Nome do arquivo `<nome>.md` bate com nome do arquivo referenciado (last segment do path, sem `.md` ou sem `/SKILL.md`).
5. Conteúdo é em pt-BR (conforme §0.4).
6. Nenhuma seção markdown (`##`, `###`) — wrapper é prosa curta, não documento estruturado.
7. Não contém código, scripts, nem instruções operacionais além de "leia X e execute".

#### 1.11.7 Anti-padrões

- **Duplicar conteúdo do workflow no wrapper.** Wrapper apenas aponta; conteúdo vive no arquivo referenciado. Atualização do workflow propaga automaticamente.
- **Lógica condicional no wrapper.** "Se for projeto Python, leia X; senão Y." Lógica vive no workflow. Wrapper é dispatch puro.
- **Wrapper para skill regular ou agent.** Skills são carregadas por workflows via `## LEIA TAMBÉM`; agents são invocados de dentro de workflows. Criar slash command próprio quebra o modelo de composição (`SPEC.md` §4.3.4, §4.5.2).
- **Frontmatter com campos exóticos.** Apenas os universais de §0.2 quando presente. Wrapper não é artefato rico.
- **Modificar wrappers à mão.** São gerados por `setup-slash-commands.sh` e `install.sh`. Edições manuais são sobrescritas na próxima sincronização.

---

## Parte 2 — Artefatos do projeto (`.codeflow/`)

Esta parte define o formato dos sete artefatos que vivem em `<projeto>/.codeflow/`, gerados pelas meta-skills (`discover`, `bootstrap`) ou por workflows durante o uso do framework. Diferente da Parte 1, esses arquivos **não** são gerados pelo Claude Code durante a construção do framework — são gerados em tempo de uso, em projetos reais. Este documento define o formato que essas gerações devem seguir.

Toda subseção segue a estrutura uniforme de 7 blocos definida no preâmbulo da Parte 1.

### 2.1 INDEX.md

#### 2.1.1 Localização

Localização única: `<projeto>/.codeflow/INDEX.md`.

Gerado por `discover` (em projeto existente) ou `bootstrap` (em projeto novo). Atualizado quando novos artefatos significativos são adicionados ao `.codeflow/` — tipicamente após criação manual de skill ou workflow de projeto.

#### 2.1.2 Propósito

Mapa de leitura prioritária para a IA. Diz, na primeira leitura do `.codeflow/`, em que ordem carregar os outros artefatos. Sem o INDEX, a IA teria que adivinhar a estrutura (`SPEC.md` §6.7.1).

#### 2.1.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `schema_version` — versão do schema do INDEX (não da versão do projeto). Permite a IA detectar incompatibilidade entre INDEX gerado por versão antiga do framework e leitura por versão nova. Formato `X.Y`.

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §6.7.1:**

1. `# INDEX do .codeflow/ do projeto` — título único.
2. `## Leia sempre primeiro` — lista ordenada de arquivos a carregar em toda sessão de workflow. Conteúdo obrigatório: `constitution.md`, `manifest.md`, nesta ordem.
3. `## Leia se relevante ao contexto` — lista de arquivos a carregar condicionalmente. Conteúdo obrigatório: `discovered.md` (se existe), `decisions/INDEX.md` (com nota sobre filtrar por tag).
4. `## Arquivos gerados automaticamente — não editar manualmente` — aviso. Conteúdo obrigatório: `checkpoints/*` e `decisions/<arquivo>.md` individuais (o INDEX de decisions é editado automaticamente).
5. `## Versão do schema e última atualização` — uma linha registrando versão do schema do INDEX e data da última geração.

**Restrições adicionais:**

- Tamanho-alvo: **15 a 25 linhas** conforme `SPEC.md` §6.7.1. Orientação, não limite duro.
- Cada arquivo listado é referenciado por caminho relativo a partir de `.codeflow/`.
- Nenhuma prosa explicativa entre seções — INDEX é mapa funcional, não tutorial.

#### 2.1.4 Schema opcional

- Sub-seções `### <tema>` dentro de `## Leia se relevante ao contexto` agrupando arquivos por área (ex: arquivos relacionados a auth, payments, schema). Recomendado quando o número de arquivos passa de cinco.
- Linha final em `## Versão do schema e última atualização` com nome da meta-skill que gerou o INDEX (`discover` ou `bootstrap`).

#### 2.1.5 Exemplo preenchido

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
schema_version: 1.0
---

# INDEX do .codeflow/ do projeto

## Leia sempre primeiro
1. `constitution.md` — regras invariantes deste projeto.
2. `manifest.md` — stack, comandos make, padrões detectados.

## Leia se relevante ao contexto
- `discovered.md` — snapshot do onboarding (consultar se houver dúvida sobre estrutura do projeto).
- `decisions/INDEX.md` — índice navegável de decisões. Filtrar por tag relevante antes de carregar decisions individuais.

## Arquivos gerados automaticamente — não editar manualmente
- `checkpoints/*` — estado intermediário de workflows em execução. Efêmero, vai para `.gitignore`.
- `decisions/<data>-<titulo>.md` — decisões individuais. Geradas por workflows; alterações manuais quebram o índice.

## Versão do schema e última atualização
Schema 1.0 | Última atualização: 2026-05-17 | Gerado por: discover
```

#### 2.1.6 Regras de validação

1. Frontmatter presente, com `schema_version` em formato `X.Y`.
2. Tamanho-alvo: 15 a 25 linhas. Acima de 35 sinaliza inchaço.
3. As cinco seções obrigatórias presentes na ordem listada em §2.1.3.
4. `## Leia sempre primeiro` lista `constitution.md` e `manifest.md`, nesta ordem.
5. `## Leia se relevante ao contexto` lista `discovered.md` (se aplicável) e `decisions/INDEX.md`.
6. `## Arquivos gerados automaticamente` cita `checkpoints/` e `decisions/<arquivo>.md`.
7. Caminhos referenciados são relativos a `.codeflow/` (sem `~/` ou `/`).
8. Nenhuma prosa explicativa de mais de uma linha entre seções.
9. Linha final `## Versão do schema e última atualização` contém schema_version e data ISO.
10. Se o projeto não tem `discovered.md` (caso de `bootstrap` que não gera esse arquivo), a referência a `discovered.md` em `## Leia se relevante ao contexto` é omitida.

#### 2.1.7 Anti-padrões

- **Tratar INDEX como README.** README é introdução prosa para humanos. INDEX é mapa funcional para IA. Sem narrativa, sem boas-vindas.
- **Listar todos os arquivos do `.codeflow/`.** INDEX é mapa de **prioridade**, não inventário. Arquivos efêmeros (checkpoints) só aparecem na seção de aviso.
- **Caminho absoluto em referência.** Sempre relativo a `.codeflow/`. `/home/usuario/projeto/.codeflow/manifest.md` é violação.
- **Conteúdo desatualizado.** INDEX desatualizado é pior que ausente — a IA confia no INDEX. Toda criação significativa em `.codeflow/` exige atualização do INDEX.
- **Sub-seções em `## Leia sempre primeiro`.** Essa seção é lista linear curta. Hierarquia confunde a ordem de prioridade.
- **Omitir versão do schema.** Sem `schema_version`, incompatibilidades entre framework versão A e INDEX gerado por versão B não são detectáveis.

### 2.2 Constitution de projeto

#### 2.2.1 Localização

Localização única: `<projeto>/.codeflow/constitution.md`.

Gerada por `discover` (em projeto existente, baseada em inspeção + perguntas ao usuário) ou `bootstrap` (em projeto novo, baseada em decisões do usuário durante o setup). Versionada no git do projeto.

#### 2.2.2 Propósito

Declarar as regras específicas deste projeto que **estendem** (ou em caso raro, sobrescrevem) a constitution universal. Workflows carregam as duas em ordem: universal primeiro, projeto depois — em conflito, projeto vence (`SPEC.md` §4.1.2).

#### 2.2.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `projeto` — nome do projeto. Obrigatório. Usado em mensagens e logs.

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §4.1.2:**

1. `# Constitution do projeto: <nome>` — título único.
2. `## Stack` — linguagem principal, frameworks, banco de dados, bibliotecas principais. Lista factual.
3. `## Padrão arquitetural` — padrão detectado ou escolhido (ex: hexagonal, MVC, layered, etc.).
4. `## Regras invariantes específicas` — regras imperativas particulares a este projeto (ex: bibliotecas proibidas, convenções obrigatórias).
5. `## Áreas de alto risco` — pastas, módulos, ou subsistemas que exigem cuidado extra, com política específica por área.
6. `## Definition of Done específica` — itens adicionais ao Definition of Done padrão (universal), específicos deste projeto. Pode declarar `Sem extensões.` quando o projeto adota o padrão sem mudanças.

**Restrições adicionais:**

- Linguagem imperativa. Sem hedges.
- Cada regra em `## Regras invariantes específicas` é verificável (passível de check programático ou inspeção objetiva).
- Áreas de alto risco têm nome específico (caminho da pasta ou módulo), não descrição vaga.
- Constitution de projeto **não** repete conteúdo da constitution universal — apenas estende.

#### 2.2.4 Schema opcional

- Sub-seções `### <subsistema>` dentro de `## Áreas de alto risco` agrupando áreas correlatas.
- Seção `## Arquivos e pastas protegidos` listando explicitamente o que workflows não devem modificar mesmo dentro de escopo declarado (ex: `legacy/`, `vendored/`). Esses caminhos são referenciados pela constitution universal em `## Proibições absolutas` (§1.1).
- Seção `## Glossário do projeto` definindo termos específicos do domínio que workflows precisam entender.

#### 2.2.5 Exemplo preenchido

Exemplo: constitution de um projeto hipotético FastAPI/Python, para tornar concreto. Conteúdo realista mas não é constitution real de projeto entregue.

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
projeto: tarefas-api
---

# Constitution do projeto: tarefas-api

## Stack

- **Linguagem:** Python 3.11+
- **Framework web:** FastAPI
- **Banco:** PostgreSQL 15 (via psycopg, sem ORM)
- **Migrações:** Alembic
- **Testes:** pytest + httpx
- **Linter/formatter:** ruff
- **Type checker:** mypy strict

## Padrão arquitetural

Hexagonal (ports and adapters). Três camadas:
- `core/` — entidades e regras de negócio puras, sem dependência externa.
- `adapters/` — implementações concretas (HTTP, banco, integrações).
- `interfaces/` — pontos de entrada (rotas FastAPI, CLI, jobs).

Dependências fluem para dentro: `interfaces` depende de `adapters`, `adapters` depende de `core`. Nunca o contrário.

## Regras invariantes específicas

- SQL é escrito à mão em arquivos `.sql` referenciados pelo código. **SQLAlchemy é proibido** — escolha registrada em decision de bootstrap.
- Endpoints HTTP retornam Pydantic models, nunca dicts soltos.
- Toda função pública em `core/` tem type hint completo (mypy strict valida).
- Autenticação usa JWT short-lived (15 min). Refresh tokens vivem em tabela separada com TTL.
- Mensagens de erro voltadas ao usuário final são em pt-BR.

## Áreas de alto risco

- **`adapters/db/`** — qualquer mudança em queries SQL exige teste de integração com banco real (não mock). Workflows que tocam essa pasta carregam `rules/security.md` e `rules/testing.md` obrigatoriamente.
- **`core/auth/`** — mudanças em fluxo de autenticação exigem revisão por dois pares ou registro em decision com aprovação explícita do usuário. Política mais restritiva que a padrão.

## Definition of Done específica

Itens adicionais ao Definition of Done padrão (constitution universal):

- `make typecheck` retornou zero (mypy strict não permite warnings).
- Toda função nova em `core/` tem teste unitário.
- Migração Alembic foi gerada e revisada quando há mudança de schema.
```

#### 2.2.6 Regras de validação

1. Frontmatter presente, com `projeto` não-vazio.
2. Título no formato `# Constitution do projeto: <nome>`, com `<nome>` correspondendo ao valor de `projeto` no frontmatter.
3. As seis seções obrigatórias presentes na ordem listada em §2.2.3.
4. `## Stack` lista pelo menos linguagem e (se aplicável) framework principal.
5. `## Padrão arquitetural` declara um padrão nomeado (não "depende") ou texto literal `Sem padrão definido — discutir com /discover --refresh`.
6. `## Regras invariantes específicas` contém pelo menos um bullet, ou texto literal `Sem regras específicas além da constitution universal.` (caso raro).
7. `## Áreas de alto risco` referencia caminhos concretos do projeto (não descrições genéricas tipo "código sensível").
8. `## Definition of Done específica` contém pelo menos um item adicional ou texto literal `Sem extensões.`.
9. Nenhuma regra contradiz literalmente uma regra da constitution universal — constituição de projeto **estende**, raramente sobrescreve, e sobrescritas exigem comentário explícito.
10. Caminhos referenciados são relativos à raiz do projeto (sem prefixo `/` ou `~/`).

#### 2.2.7 Anti-padrões

- **Repetir conteúdo da constitution universal.** "Diff mínimo" e "política de falhas" vivem na universal; repetir é ruído. Constitution de projeto estende, não duplica.
- **Stack como prosa.** Lista factual, não parágrafo descritivo. "Usamos Python e às vezes Go" não é stack — é confusão.
- **Áreas de alto risco genéricas.** "Código sensível" não é área. `adapters/auth/` é área.
- **Padrão arquitetural inventado.** Se o projeto não tem padrão claro, declare-o assim. Forçar nome de padrão que não corresponde à realidade engana workflows.
- **Regras não-verificáveis.** "Manter código limpo" não é regra. "Funções têm no máximo 30 linhas (verificável via lint)" é regra.
- **Pular `## Definition of Done específica` quando o projeto adota o padrão.** Sempre presente, com `Sem extensões.` quando não há adições. Omissão silenciosa confunde a IA.

### 2.3 Manifest

#### 2.3.1 Localização

Localização única: `<projeto>/.codeflow/manifest.md`.

Gerado por `discover` ou `bootstrap`. Atualizado quando a stack do projeto muda significativamente (nova linguagem, nova lib principal, mudança em comandos make) — tipicamente via `/discover --refresh`.

#### 2.3.2 Propósito

Descrever **fatos** sobre o projeto: stack identificada, comandos make canônicos, padrões detectados. Diferente da constitution (que declara regras), o manifest registra estado factual. Inclui mecanismo de freshness check para detectar obsolescência (`SPEC.md` §6.7.3).

#### 2.3.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `last_validated` — data ISO da última validação por `discover`. Obrigatório.
- `validation_hash` — SHA-256 calculado sobre arquivos críticos do projeto (Makefile, manifest de stack, configs de linter). Obrigatório. Workflows que carregam o manifest recalculam o hash e avisam se difere.
- `projeto` — nome do projeto, herdado da constitution. Obrigatório.

**Seções markdown — na ordem fixa abaixo:**

1. `# Manifest do projeto: <nome>` — título único.
2. `## Stack identificada` — espelha a stack da constitution, mas com versões exatas detectadas (não apenas "Python", mas `Python 3.11.5`).
3. `## Comandos make canônicos` — mapeamento dos targets canônicos (`check`, `test`, `lint`, `typecheck`) para os comandos efetivos. Targets ausentes são marcados como `[—]`.
4. `## Padrões detectados` — convenções inferidas pela inspeção (estrutura de pastas, padrão de testes, formato de imports).
5. `## Arquivos críticos para freshness` — lista de arquivos cujo hash é computado em `validation_hash`. Permite a IA recalcular e verificar.
6. `## Notas de inspeção` — observações livres do `discover` sobre o projeto: o que foi inspecionado, hipóteses formadas, pontos a confirmar com o usuário.

**Restrições adicionais:**

- `validation_hash` é SHA-256 hexadecimal, 64 caracteres.
- `## Comandos make canônicos` cobre os quatro targets mínimos (`check`, `test`, `lint`, `typecheck`) do `SPEC.md` §3.10, mesmo quando alguns são `[—]`.
- `## Padrões detectados` é factual: o que foi observado, não o que deveria existir. Regras prescritivas vivem na constitution.

**Fórmula canônica de `validation_hash`:**

```bash
cat <arquivo1> <arquivo2> ... <arquivoN> 2>/dev/null | sha256sum | cut -d' ' -f1
```

Regras de aplicação:

- A ordem dos arquivos é exatamente a declarada literalmente na seção `## Arquivos críticos para freshness` do manifest.
- Arquivos ausentes (não existentes no disco) são tratados como string vazia: o `2>/dev/null` engole o erro de `cat`/`stat` e o conteúdo desse arquivo simplesmente não contribui para o stream concatenado.
- A fórmula é a única autorizada. Workflows que recalculam `validation_hash` para verificar freshness usam exatamente este comando, com a mesma lista de arquivos, na mesma ordem.

#### 2.3.4 Schema opcional

- Sub-seções `### <categoria>` em `## Padrões detectados` agrupando por tema (testes, imports, naming, estrutura).
- Seção `## Targets make estendidos` listando targets úteis além dos canônicos (ex: `make migrate`, `make seed`).
- Seção `## Limitações conhecidas` declarando o que `discover` não conseguiu inferir e precisa de confirmação manual do usuário.

#### 2.3.5 Exemplo preenchido

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
projeto: tarefas-api
last_validated: 2026-05-17
validation_hash: 7c3b8a9e2f1d4c5b6a8e9f0d1c2b3a4e5f6d7c8b9a0e1f2d3c4b5a6e7f8d9c0b
---

# Manifest do projeto: tarefas-api

## Stack identificada

- **Linguagem:** Python 3.11.5
- **Framework web:** FastAPI 0.110
- **Banco:** PostgreSQL 15.3 (driver: psycopg 3.1)
- **Migrações:** Alembic 1.13
- **Testes:** pytest 8.0, httpx 0.27
- **Linter/formatter:** ruff 0.4
- **Type checker:** mypy 1.10 (strict)

## Comandos make canônicos

| Target canônico | Comando efetivo                        | Status |
|-----------------|----------------------------------------|--------|
| `make check`    | `ruff check . && mypy . && pytest`     | ✓      |
| `make test`     | `pytest`                               | ✓      |
| `make lint`     | `ruff check .`                         | ✓      |
| `make typecheck`| `mypy .`                               | ✓      |

## Padrões detectados

- **Estrutura de pastas:** `core/`, `adapters/`, `interfaces/`, `tests/` no raiz. Coerente com padrão hexagonal declarado na constitution.
- **Padrão de testes:** arquivos em `tests/` espelhando estrutura de `core/` e `adapters/`. Nomenclatura: `test_<modulo>.py`.
- **Padrão de imports:** imports absolutos a partir da raiz do projeto. Sem imports relativos.
- **Padrão de migrations:** arquivos em `alembic/versions/`, com timestamp + descrição curta no nome.

## Arquivos críticos para freshness

Hash `validation_hash` é computado sobre os arquivos abaixo, na ordem:

- `Makefile`
- `pyproject.toml`
- `alembic.ini`
- `ruff.toml` (se presente, senão pula)

## Notas de inspeção

- Projeto inspecionado em 2026-05-17 por `/discover`.
- Constitution gerada com base em padrões claramente observáveis. Regra "SQLAlchemy proibido" foi confirmada com usuário (presença histórica em commits antigos, removida deliberadamente).
- Pasta `legacy/` na raiz não foi inspecionada (marcada como "não tocar" pelo usuário).
```

#### 2.3.6 Regras de validação

1. Frontmatter presente, com `last_validated` em formato ISO, `validation_hash` em hexadecimal de 64 caracteres, `projeto` não-vazio.
2. Título no formato `# Manifest do projeto: <nome>`, correspondendo ao `projeto` do frontmatter.
3. As seis seções obrigatórias presentes na ordem listada em §2.3.3.
4. `## Stack identificada` lista versões específicas (números) quando aplicável, não apenas nomes.
5. `## Comandos make canônicos` cobre os quatro targets do `SPEC.md` §3.10, mesmo que com status `[—]`.
6. `## Arquivos críticos para freshness` lista pelo menos o Makefile e o manifest principal de stack do projeto.
7. `validation_hash` recalculado a partir dos arquivos listados em `## Arquivos críticos para freshness` bate com o registrado no frontmatter (verificação dinâmica feita por workflows).
8. `## Padrões detectados` contém ao menos três bullets factuais.
9. Nenhuma regra prescritiva em `## Padrões detectados`. Manifest descreve, não prescreve.
10. `## Notas de inspeção` registra data de inspeção e meta-skill que gerou (`discover` ou `bootstrap`).

#### 2.3.7 Anti-padrões

- **Manifest com regras prescritivas.** "Funções devem ter type hints" é regra — vai na constitution. "Funções têm type hints (100% de cobertura observada)" é fato — vai aqui.
- **Hash desatualizado sem aviso.** Workflows que detectam hash divergente devem avisar imediatamente (`SPEC.md` §6.7.3). Ignorar quebra freshness check.
- **Stack vaga.** "Python e Postgres" não é stack identificada — falta versão e libs. Manifest é fonte de fato; vagueza torna inútil.
- **Comandos brutos em vez de via make.** Conforme `SPEC.md` §3.10, workflows invocam via `make <target>`. O mapeamento canônico → comando efetivo vive aqui no manifest, mas workflows não usam o comando efetivo diretamente.
- **Misturar inspeção com configuração.** Manifest é resultado de inspeção. Configurações desejadas (que não existem ainda) vivem em decision ou são solicitadas via `/discover --refresh`.
- **Notas de inspeção como histórico longo.** Notas registram a inspeção atual, não histórico de inspeções anteriores. Reinspeção sobrescreve.

### 2.4 Discovered

#### 2.4.1 Localização

Localização única: `<projeto>/.codeflow/discovered.md`.

Gerado **apenas** por `discover` (`SPEC.md` §4.7.1). `bootstrap` não gera discovered, pois não há projeto pré-existente a descobrir.

Diferente de outros artefatos, `discovered.md` **não é atualizado** depois de gerado. Para reaprender o projeto, gera-se **novo snapshot datado**: `discovered-<data>.md`, e o `discovered.md` principal aponta para o mais recente.

#### 2.4.2 Propósito

Registrar o **snapshot do onboarding**: o que `discover` inspecionou no projeto, hipóteses formadas, perguntas que ficaram em aberto, e respostas que o usuário deu. Serve como histórico do raciocínio de descoberta — não como fonte primária para workflows.

Workflows não consultam discovered diretamente em fluxo normal. Discovered é referência para: depurar inconsistência entre manifest e realidade do projeto, reconstruir contexto após muito tempo sem uso do framework no projeto, ou comparar estado atual vs estado original.

#### 2.4.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `data_inspeção` — data ISO em que `discover` rodou. Obrigatório.
- `meta_skill` — valor fixo `discover`. Obrigatório.
- `superseded_by` — nome de discovered mais recente (`discovered-<data>.md`) quando este snapshot foi substituído. Nulo no snapshot atual.

**Seções markdown — na ordem fixa abaixo:**

1. `# Discovered: snapshot de <data>` — título único.
2. `## O que foi inspecionado` — lista de arquivos, pastas e configurações que `discover` examinou. Ordem cronológica de inspeção.
3. `## Hipóteses formadas` — interpretações que `discover` fez a partir da inspeção. Cada hipótese rotulada como `confirmada`, `refutada` ou `pendente`.
4. `## Perguntas feitas ao usuário e respostas` — diálogo estruturado de no máximo cinco perguntas (`SPEC.md` §4.4.2), com a resposta de cada uma.
5. `## Áreas marcadas como "não tocar"` — lista de pastas ou arquivos que o usuário declarou explicitamente como fora de escopo para workflows.
6. `## Artefatos gerados a partir deste discovered` — lista de outros artefatos criados por `discover` nesta execução: constitution.md, manifest.md, INDEX.md.

**Restrições adicionais:**

- Discovered é histórico, não fonte primária. Manifest e constitution refletem o estado final acordado; discovered registra como se chegou lá.
- Cada hipótese tem rótulo explícito de estado (não deixar ambíguo).
- Áreas "não tocar" são caminhos concretos.

#### 2.4.4 Schema opcional

- Seção `## Limitações da inspeção` declarando o que `discover` não conseguiu inferir (ex: "não consegui identificar padrão de erro handling — pasta `errors/` tem três abordagens diferentes").
- Anexos `### <tema>` para registrar achados específicos com mais detalhe (ex: lista de bibliotecas externas usadas, mapa de dependências entre módulos).

#### 2.4.5 Exemplo preenchido

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
data_inspeção: 2026-05-17
meta_skill: discover
superseded_by: null
---

# Discovered: snapshot de 2026-05-17

## O que foi inspecionado

1. `README.md` — propósito do projeto e instruções de setup.
2. `pyproject.toml` — dependências, configuração de ruff e mypy.
3. `Makefile` — targets disponíveis e comandos efetivos.
4. Estrutura de pastas (`core/`, `adapters/`, `interfaces/`, `tests/`).
5. Cinco arquivos representativos de `core/` e três de `adapters/db/`.
6. Histórico recente de commits (últimos 30 dias) para inferir cadência e estilo.

## Hipóteses formadas

- **[confirmada]** O projeto segue padrão hexagonal estrito (separação core/adapters/interfaces). Inferida pela estrutura de pastas e ausência de imports cruzando camadas.
- **[confirmada]** SQLAlchemy foi removido deliberadamente. Inferida pela ausência da dependência em `pyproject.toml` apesar de aparecer em commits antigos. Confirmada com o usuário.
- **[confirmada]** Mensagens de erro voltadas ao usuário final são em pt-BR. Inferida por amostragem; confirmada.
- **[pendente]** Há uma pasta `legacy/` no raiz que não foi inspecionada. Usuário marcou como "não tocar"; conteúdo desconhecido.
- **[refutada]** Hipótese inicial: o projeto usa Pydantic v1. Inspeção revelou Pydantic v2. Manifest atualizado.

## Perguntas feitas ao usuário e respostas

1. **Q:** Confirma que SQLAlchemy é proibido como decisão arquitetural? **R:** Sim. Registrar como regra invariante na constitution.
2. **Q:** A pasta `legacy/` deve ser inspecionada por workflows? **R:** Não. Marcar como "não tocar" até decisão futura.
3. **Q:** O Makefile atual cobre `check`, `test`, `lint`, `typecheck`. Falta algum target canônico que deseja adicionar? **R:** Não, está completo.
4. **Q:** Áreas adicionais de alto risco além de `adapters/db/`? **R:** Sim, `core/auth/` exige política mais restritiva.
5. **Q:** Idioma das mensagens ao usuário final é pt-BR. Confirma como regra invariante? **R:** Sim.

## Áreas marcadas como "não tocar"

- `legacy/` — pasta no raiz, conteúdo legacy não revisado, fora de escopo de workflows.

## Artefatos gerados a partir deste discovered

- `.codeflow/constitution.md` — versão 1.0
- `.codeflow/manifest.md` — versão 1.0
- `.codeflow/INDEX.md` — versão 1.0
```

#### 2.4.6 Regras de validação

1. Frontmatter presente, com `data_inspeção` em formato ISO, `meta_skill: discover`, `superseded_by` em `null` ou nome de arquivo discovered mais recente.
2. Título no formato `# Discovered: snapshot de <data>`, com data correspondendo ao `data_inspeção`.
3. As seis seções obrigatórias presentes na ordem listada em §2.4.3.
4. `## O que foi inspecionado` lista pelo menos três itens (sem inspeção mínima, não há base para hipóteses).
5. `## Hipóteses formadas` contém ao menos uma hipótese, cada uma com rótulo explícito `[confirmada]`, `[refutada]` ou `[pendente]`.
6. `## Perguntas feitas ao usuário e respostas` contém **no máximo cinco** perguntas (`SPEC.md` §4.4.2). Pode conter menos.
7. Cada pergunta tem resposta correspondente declarada.
8. `## Áreas marcadas como "não tocar"` lista caminhos concretos ou texto literal `Nenhuma.` quando o usuário não declarou nenhuma.
9. `## Artefatos gerados a partir deste discovered` cita pelo menos `constitution.md`, `manifest.md`, `INDEX.md`.
10. `superseded_by` é `null` no snapshot mais recente. Snapshots antigos têm `superseded_by` preenchido apontando para o nome do mais recente.

#### 2.4.7 Anti-padrões

- **Atualizar discovered.md depois de gerado.** Conforme `SPEC.md` §4.7.1, discovered é snapshot. Atualizações vêm via novo snapshot datado.
- **Hipóteses sem rótulo de estado.** Sem `[confirmada]`/`[refutada]`/`[pendente]`, a hipótese fica ambígua e perde valor histórico.
- **Mais de cinco perguntas.** Limite literal do SPEC §4.4.2. Mais que cinco indica falha na inspeção: a meta-skill deveria ter inferido mais sem perguntar.
- **Conteúdo prescritivo em discovered.** Discovered registra o que foi descoberto, não o que deve ser feito. Prescrições vivem na constitution gerada a partir do discovered.
- **Misturar inspeção e perguntas em ordem caótica.** Cada seção tem propósito específico; misturar quebra a função histórica do snapshot.
- **Discovered como base de leitura recorrente.** Workflows leem manifest e constitution, não discovered. Discovered é referência arqueológica; consultas frequentes indicam que algo está faltando no manifest.

### 2.5 Decision individual

#### 2.5.1 Localização

Localização única: `<projeto>/.codeflow/decisions/<data>-<titulo-curto>.md`.

Formato do nome: `AAAA-MM-DD-<titulo-em-kebab-case>.md`. Exemplo: `2026-05-17-jwt-curto-vs-longo.md`.

Gerada por workflow que declara `gera_decision: yes` no frontmatter, ou por workflow `gera_decision: auto` quando a IA julga necessário (tipicamente: mudança não-trivial, escolha entre alternativas, registro de aprovação do usuário para mudança quebradora).

#### 2.5.2 Propósito

Registro **leve** de decisões tomadas durante workflow significativo. Não é ADR formal — é nota de decisão estruturada, com header padronizado para permitir indexação e filtragem por tag. Vai para o git do projeto e viaja com o código (`SPEC.md` §6.5).

#### 2.5.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2, conforme `SPEC.md` §6.5.2:**

- `data` — data ISO da geração. Obrigatória.
- `workflow` — nome do workflow que gerou a decision. Obrigatório.
- `tags` — lista de tags em formato inline `[tag1, tag2]`. Obrigatória. Tags são livres mas vocabulário deve emergir do uso real do projeto.
- `status_decisão` — um de: `ativa`, `superseded`, `arquivada`. Obrigatório. **Distinto** do campo universal `status` (estável/experimental/deprecated, definido em §0.2), que descreve a maturidade do schema do arquivo decision em si.
- `supersede` — nome de decision substituída (formato `<data>-<titulo>`), ou `null`. Obrigatório (pode ser nulo).
- `relaciona-com` — lista de decisions relacionadas (formato `[<data>-<titulo>, ...]`), ou `[]`. Obrigatório (pode ser vazio).

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §6.5.2:**

1. `# Decisões: <título>` — título único.
2. `## Contexto` — o que estava sendo feito quando essas decisões surgiram.
3. `## Decisões tomadas` — uma ou mais decisões, cada uma como sub-seção `### N. <decisão>` com sub-campos `**Por quê:**` e `**Alternativa rejeitada:**`.
4. `## Próximos passos sugeridos` — ações resultantes que ainda precisam ser executadas (em outro workflow ou manualmente).

**Restrições adicionais:**

- O frontmatter segue o template literal de `SPEC.md` §6.5.2. Campos opcionais (relaciona-com, supersede) sempre presentes, com `null` ou `[]` quando vazios.
- `## Decisões tomadas` contém pelo menos uma decisão. Decision file sem decisão é violação.
- Cada decisão tem **alternativa rejeitada** explícita. Se realmente não havia alternativa considerada, declare-o literalmente: `Alternativa rejeitada: Nenhuma alternativa considerada — único caminho viável.`. Honestidade vence vacuidade.

#### 2.5.4 Schema opcional

- Sub-seção `### Implicações` dentro de cada decisão, declarando o que a decisão obriga ou impede daqui em diante.
- Seção `## Notas` ao fim com observações soltas que não cabem em "Decisões" nem "Próximos passos".
- Anexos `### Diagramas` ou `### Tabelas` quando a decisão é melhor explicada visualmente.

#### 2.5.5 Exemplo preenchido

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
data: 2026-05-17
workflow: feature-small
tags: [auth, jwt, security]
status_decisão: ativa
supersede: null
relaciona-com: [2026-04-12-escolha-de-jwt-vs-session]
---

# Decisões: TTL de access tokens reduzido para 15 minutos

## Contexto

Durante implementação da feature de logout em múltiplos dispositivos (workflow `feature-small`), identificamos que o TTL atual de access tokens (24 horas) inviabiliza logout efetivo: após logout, o token permanece válido até expirar naturalmente. Discutimos com o usuário a escolha entre reduzir TTL, implementar revocation list, ou ambos.

## Decisões tomadas

### 1. Reduzir TTL de access tokens para 15 minutos
**Por quê:** balança usabilidade (não exige re-login frequente) com janela de exposição em caso de token comprometido. Endpoints de refresh já existem; ônus operacional baixo.
**Alternativa rejeitada:** revocation list em Redis. Adiciona dependência operacional (Redis) sem ganho proporcional ao caso de uso atual.

### 2. Manter TTL de refresh tokens em 7 dias
**Por quê:** sem mudança, refresh tokens já têm rotação implementada. Mexer aumenta superfície de mudança sem ganho.
**Alternativa rejeitada:** reduzir refresh para 24 horas. Atrito alto para usuários em mobile.

## Próximos passos sugeridos

- Atualizar documentação interna de auth (`docs/auth.md`) com novo TTL.
- Adicionar métrica de "refresh por minuto" no dashboard de observabilidade para detectar anomalia se essa decisão impactar carga.
- Reavaliar em três meses: se refresh excessivo virar problema, considerar revocation list.
```

#### 2.5.6 Regras de validação

1. Frontmatter presente, com todos os seis campos específicos: `data`, `workflow`, `tags`, `status_decisão`, `supersede`, `relaciona-com`.
2. Nome do arquivo no formato `AAAA-MM-DD-<titulo-kebab>.md`, com `<data>` correspondendo ao `data` do frontmatter.
3. `status_decisão` em conjunto válido: `ativa`, `superseded`, `arquivada`. (O campo universal `status` segue a tabela de §0.2 e não se confunde com este.)
4. `supersede` é `null` ou aponta para arquivo decision existente em `.codeflow/decisions/`.
5. `relaciona-com` é `[]` ou lista de arquivos decision existentes.
6. Tags em `tags` em kebab-case, sem espaços.
7. Título no formato `# Decisões: <título>`, com título descritivo (não apenas data).
8. As quatro seções obrigatórias presentes na ordem listada em §2.5.3.
9. `## Decisões tomadas` contém pelo menos uma sub-seção `### N. <decisão>`, com `**Por quê:**` e `**Alternativa rejeitada:**` em cada.
10. Quando `status_decisão: superseded`, o arquivo `supersede` do frontmatter aponta para a decision que substituiu esta (relação inversa — útil para navegação).

#### 2.5.7 Anti-padrões

- **Decision sem alternativa rejeitada.** Sempre há alternativa, mesmo que seja "não fazer nada". Vacuidade aqui apaga a parte mais valiosa do registro.
- **Tag vaga.** `bug` ou `feature` não filtra nada. Tags úteis: `auth`, `schema`, `performance`, `breaking`, nomes de subsistema do projeto.
- **Decision como ata de reunião.** Decision registra **escolhas**, não diálogo cronológico. Conversa vai para discovered ou para `## Contexto` resumido.
- **Modificar decision ativa.** Decisão muda → criar nova decision com `supersede` apontando para a antiga, marcar antiga como `superseded`. Não editar in-place.
- **Não atualizar `decisions/INDEX.md`.** Toda decision nova exige atualização do INDEX (§2.6). Workflow responsável pela geração deve atualizar ambos.
- **Workflow sem `gera_decision: yes/auto` gerando decision.** Workflow declara seu comportamento; gerar decision quando o workflow declara `gera_decision: no` é violação.

### 2.6 Decisions INDEX

#### 2.6.1 Localização

Localização única: `<projeto>/.codeflow/decisions/INDEX.md`.

Gerado quando a primeira decision é criada (workflows que geram decision são responsáveis por atualizar o INDEX). Atualizado automaticamente toda vez que decision nova é criada, ou quando status de decision muda (`SPEC.md` §6.5.3).

#### 2.6.2 Propósito

Índice **navegável** de todas as decisions do projeto. Permite à IA filtrar decisions por tag, data ou status sem carregar todos os arquivos individuais. Workflows que tocam áreas sensíveis consultam o INDEX antes de carregar decisions específicas (`SPEC.md` §6.5.3).

#### 2.6.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2:**

- `total_decisions` — número total de decisions catalogadas (inclui superseded e arquivadas). Obrigatório.
- `última_atualização` — data ISO da última atualização do INDEX. Obrigatório.

**Seções markdown — na ordem fixa abaixo:**

1. `# Índice de decisões` — título único.
2. `## Por data` — tabela markdown ordenada por data, mais recente primeiro. Conforme `SPEC.md` §6.5.3.
3. `## Por tag` — tabela markdown agrupando decisions por tag. Conforme `SPEC.md` §6.5.3.
4. `## Estatísticas` — contagens: total, ativas, superseded, arquivadas.

**Formato da tabela em `## Por data`:**

```
| Data       | Título                          | Workflow      | Tags                | Status     |
|------------|----------------------------------|---------------|---------------------|------------|
| AAAA-MM-DD | <título>                        | <workflow>    | tag1, tag2          | ativa      |
```

Colunas: Data (do frontmatter), Título (do frontmatter, em `#`), Workflow (que gerou), Tags (lista inline), Status (valor de `status_decisão` do frontmatter da decision — `ativa`, `superseded` ou `arquivada`).

**Formato da tabela em `## Por tag`:**

```
| Tag       | Decisões (data + título)                                                |
|-----------|-------------------------------------------------------------------------|
| auth      | 2026-05-17 — TTL de access tokens; 2026-04-12 — Escolha JWT vs session  |
```

Decisions na coluna direita listadas em ordem cronológica reversa, separadas por `; `.

**Restrições adicionais:**

- Cada decision aparece **uma vez** em `## Por data` e **uma vez por tag** em `## Por tag` (ou seja, decision com três tags aparece em três linhas de `## Por tag`).
- INDEX desatualizado é violação. Workflows que geram decision atualizam INDEX no mesmo passo.

#### 2.6.4 Schema opcional

- Seção `## Superseded chain` quando há cadeias de decisions substituídas: linha por cadeia, mostrando ancestralidade (`A → B → C`, com `C` ativa).
- Coluna adicional na tabela `## Por data` mostrando o nome do arquivo (`<data>-<titulo>.md`) para clique direto. Útil em ferramentas que renderizam markdown como hyperlink.

#### 2.6.5 Exemplo preenchido

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
total_decisions: 4
última_atualização: 2026-05-17
---

# Índice de decisões

## Por data

| Data       | Título                                         | Workflow       | Tags                  | Status     |
|------------|------------------------------------------------|----------------|-----------------------|------------|
| 2026-05-17 | TTL de access tokens reduzido para 15 minutos  | feature-small  | auth, jwt, security   | ativa      |
| 2026-05-03 | Migração de Pydantic v1 para v2                | bugfix         | breaking, deps        | ativa      |
| 2026-04-12 | Escolha de JWT vs session-based                | bootstrap      | auth, jwt             | ativa      |
| 2026-03-08 | Adoção de Alembic para migrações               | discover       | schema, migration     | ativa      |

## Por tag

| Tag        | Decisões (data + título)                                                         |
|------------|----------------------------------------------------------------------------------|
| auth       | 2026-05-17 — TTL de access tokens; 2026-04-12 — Escolha JWT vs session-based     |
| jwt        | 2026-05-17 — TTL de access tokens; 2026-04-12 — Escolha JWT vs session-based     |
| security   | 2026-05-17 — TTL de access tokens                                                |
| breaking   | 2026-05-03 — Migração de Pydantic v1 para v2                                     |
| deps       | 2026-05-03 — Migração de Pydantic v1 para v2                                     |
| schema     | 2026-03-08 — Adoção de Alembic para migrações                                    |
| migration  | 2026-03-08 — Adoção de Alembic para migrações                                    |

## Estatísticas

- **Total:** 4
- **Ativas:** 4
- **Superseded:** 0
- **Arquivadas:** 0
```

#### 2.6.6 Regras de validação

1. Frontmatter presente, com `total_decisions` (número) e `última_atualização` (data ISO).
2. As quatro seções obrigatórias presentes na ordem listada em §2.6.3.
3. `## Por data` é tabela markdown válida com cinco colunas (Data, Título, Workflow, Tags, Status — reflete `status_decisão` da decision).
4. `## Por data` está ordenado por data descendente (mais recente no topo).
5. Cada linha de `## Por data` corresponde a um arquivo decision real em `<projeto>/.codeflow/decisions/`.
6. `## Por tag` é tabela markdown válida com duas colunas (Tag, Decisões).
7. Cada decision com N tags aparece em N linhas de `## Por tag`.
8. `## Estatísticas` reporta valores que somam ao `total_decisions` do frontmatter (Ativas + Superseded + Arquivadas = Total).
9. Toda decision listada no INDEX existe como arquivo. Nenhum arquivo decision real existe sem entrada no INDEX.
10. `última_atualização` >= data da decision mais recente listada.

#### 2.6.7 Anti-padrões

- **INDEX desatualizado.** Decision criada sem atualizar INDEX é decisão invisível para workflows. Toda geração de decision exige atualização atômica do INDEX no mesmo passo.
- **Tabela com colunas extras inventadas.** O schema é fixo; adicionar colunas (ex: "Autor", "Severidade") sem decisão registrada em EVOLUTION é violação.
- **Tags inconsistentes entre decision e INDEX.** Tag no INDEX é cópia literal das tags do frontmatter da decision. Divergência indica regeneração manual incorreta.
- **Ordem alfabética em `## Por data`.** A ordem é cronológica reversa. Ordenação por título destrói a função primária do índice (ver o que foi decidido recentemente).
- **Misturar decisions superseded e ativas sem marcação.** O status na tabela é obrigatório. Decisions superseded continuam no índice (para rastreabilidade), mas com status explícito.
- **INDEX como log de atividade.** Não registrar geração/modificação de decisions como entradas. Cada decision é uma linha; modificações são feitas in-place na linha existente.

### 2.7 Checkpoint

#### 2.7.1 Localização

Localização única: `<projeto>/.codeflow/checkpoints/<workflow>-<timestamp>.md`.

Formato do nome: `<nome-do-workflow>-AAAA-MM-DD-HHMMSS.md`. Exemplo: `discover-2026-05-17-143205.md`.

Gerado **automaticamente** por workflow detalhado (com `usa_checkpoints: yes`) entre fases longas ou antes de pergunta ao usuário. Efêmero: deletado ao fim do workflow bem-sucedido.

A pasta `.codeflow/checkpoints/` é adicionada ao `.gitignore` do projeto pelo `install.sh` (`SPEC.md` §6.6.4). Checkpoints **não** vão para o git.

#### 2.7.2 Propósito

Registrar estado intermediário de workflow detalhado em execução. Permite retomada quando sessão da IA morre, é interrompida, ou atinge limite de contexto. Workflow retomado lê o checkpoint, oferece "retomar ou começar do zero?", e continua da fase em pausa (`SPEC.md` §6.6.3).

#### 2.7.3 Schema obrigatório

**Frontmatter — campos além dos universais da §0.2, conforme `SPEC.md` §6.6.2:**

- `workflow` — nome do workflow que gerou o checkpoint. Obrigatório.
- `timestamp` — timestamp ISO estendido `AAAA-MM-DD-HHMMSS`. Obrigatório. Bate com o sufixo do nome do arquivo.
- `fase_atual` — número e nome da fase em pausa (ex: `2 — Desenho`). Obrigatório.
- `status` — um de: `em_progresso`, `concluído`, `abortado`. Obrigatório. `em_progresso` é o estado normal; `concluído` é marcado momentaneamente antes do checkpoint ser deletado (transiente); `abortado` é registrado se o usuário cancela.

**Seções markdown — na ordem fixa abaixo, conforme `SPEC.md` §6.6.2:**

1. `## Estado da execução` — header da seção (não título `#`, conforme o template literal do SPEC).
2. `### Fases concluídas` — lista de fases já completadas, com resumo curto do resultado de cada.
3. `### Fase atual (em pausa)` — objetivo da fase, ações já realizadas dentro dela, próxima ação planejada.
4. `### Decisões tomadas até aqui` — lista cumulativa de decisões intermediárias ao longo do workflow. Não confundir com decisions formais (§2.5) — essas são notas em transição.
5. `### Pendências` — itens não resolvidos que retomam quando o workflow continua.

**Restrições adicionais:**

- Diferente da maioria dos outros artefatos, checkpoint **não tem título `#`** (apenas o cabeçalho `## Estado da execução`). Isso é literal do template do SPEC §6.6.2.
- Cada checkpoint é independente: não referencia outros checkpoints do mesmo workflow. A IA, ao retomar, lê o mais recente apenas.
- Checkpoint é **efêmero**: deletado quando o workflow conclui com sucesso. Se sobreviver após `concluído`, é resíduo de execução incompleta.

#### 2.7.4 Schema opcional

- Seção `### Contexto carregado` listando arquivos lidos até o ponto da pausa, útil para a IA retomar sem recarregar tudo.
- Campo de frontmatter `cancelável: yes/no` indicando se o usuário pode cancelar a retomada sem perda de trabalho irrecuperável.

#### 2.7.5 Exemplo preenchido

Nome do arquivo: `discover-2026-05-17-143205.md`.

```markdown
---
versão: 1.0
status: estável
atualizado: 2026-05-17
workflow: discover
timestamp: 2026-05-17-143205
fase_atual: 3 — Geração de constitution
status: em_progresso
---

## Estado da execução

### Fases concluídas

- **Fase 1 — Inspeção do projeto.** Inspecionados README, pyproject.toml, Makefile, estrutura de pastas, cinco arquivos representativos de core/ e três de adapters/db/, histórico de commits dos últimos 30 dias. Resultado: hipóteses formadas registradas, base para perguntas ao usuário.

- **Fase 2 — Entrevista qualificada (cinco perguntas).** Confirmadas: SQLAlchemy proibido, pasta `legacy/` marcada como "não tocar", padrão hexagonal, idioma pt-BR em mensagens ao usuário, área de alto risco `core/auth/`. Resultado: respostas registradas, base para constitution.

### Fase atual (em pausa)

- **Objetivo:** gerar `.codeflow/constitution.md` consolidando inspeção + respostas da entrevista.
- **Ações já realizadas:**
  - Esboço da seção `## Stack` redigido.
  - Esboço da seção `## Padrão arquitetural` redigido.
  - Esboço da seção `## Regras invariantes específicas` redigido.
- **Próxima ação planejada:** finalizar `## Áreas de alto risco` e `## Definition of Done específica`, validar contra ARTIFACTS_SPEC §2.2.6, apresentar ao usuário.

### Decisões tomadas até aqui

- Padrão arquitetural será declarado como "Hexagonal (ports and adapters)" — confirmação implícita por inspeção.
- Bibliotecas proibidas explicitadas: SQLAlchemy (confirmada com usuário).
- Regra de pt-BR em mensagens ao usuário será incluída como regra invariante.

### Pendências

- Confirmar com o usuário se a seção `## Definition of Done específica` deve incluir `make typecheck` como item obrigatório (mypy strict pode causar fricção em mudanças rápidas).
- Decidir se pasta `legacy/` aparece em `## Áreas de alto risco` ou em seção `## Arquivos e pastas protegidos` (opcional, §2.2.4).
```

#### 2.7.6 Regras de validação

1. Frontmatter presente, com `workflow`, `timestamp`, `fase_atual`, `status` em conjunto válido.
2. Nome do arquivo no formato `<workflow>-AAAA-MM-DD-HHMMSS.md`, com `<workflow>` correspondendo ao `workflow` do frontmatter e timestamp correspondente.
3. **Não há título `#`** no corpo. Diferente dos outros artefatos. Conforme template literal do SPEC §6.6.2.
4. Seção `## Estado da execução` presente como cabeçalho de segundo nível.
5. As quatro sub-seções `###` obrigatórias presentes na ordem listada em §2.7.3.
6. `### Fase atual (em pausa)` contém os três campos: objetivo, ações já realizadas, próxima ação planejada.
7. `### Decisões tomadas até aqui` contém pelo menos um item, ou texto literal `Nenhuma decisão intermediária registrada.` quando não há.
8. `### Pendências` contém pelo menos um item, ou texto literal `Nenhuma pendência.` quando não há.
9. Pasta `<projeto>/.codeflow/checkpoints/` está listada em `.gitignore` do projeto (verificação fora do arquivo).
10. Checkpoints com `status: concluído` que permanecem no disco indicam workflow que terminou sem limpar — sinal de bug ou aborto incompleto.

#### 2.7.7 Anti-padrões

- **Adicionar título `#`.** O template do SPEC §6.6.2 começa em `## Estado da execução`. Adicionar `# Checkpoint` ou similar é divergência.
- **Versionar checkpoints em git.** Conforme `SPEC.md` §6.6.4, `.codeflow/checkpoints/` vai para `.gitignore`. Commitar checkpoints é violação e polui histórico.
- **Checkpoint referenciando outros checkpoints.** Cada checkpoint é autossuficiente. Retomada lê o mais recente apenas; cadeias confundem.
- **Não deletar checkpoint ao concluir.** Workflow bem-sucedido deleta seus próprios checkpoints. Resíduo é problema operacional.
- **Conteúdo prosaico extenso.** Checkpoint é estado, não relatório. Bullets curtos com resultados objetivos. Reflexão e narrativa pertencem ao resumo final do workflow.
- **Decisões formais registradas em `### Decisões tomadas até aqui`.** Decisões formais vão em `.codeflow/decisions/` (§2.5). Notas aqui são intermediárias, transitórias — perdem-se quando o checkpoint é deletado.

---

## Parte 3 — Regras transversais de validação

Esta parte consolida as verificações que se aplicam a **qualquer arquivo do codeflow**, independentemente de tipo. Servem como camada base de validação antes (ou em paralelo) das regras específicas de cada artefato declaradas nas Partes 1 e 2. O `VALIDATION.md` (próximo documento do andaime) referencia esta parte como fonte primária da camada base.

A ordem das regras segue da mais geral (forma) para a mais específica (conteúdo).

### 3.1 Forma do arquivo

Aplicam-se a todos os arquivos `.md` do framework e dos projetos.

1. **Encoding UTF-8 sem BOM.** Verificar com `file <arquivo>` ou comparação direta dos primeiros bytes. Falha de encoding bloqueia todo o resto.
2. **Line endings LF (`\n`).** Sem CRLF. Verificar com `file <arquivo>` (output não deve mencionar "CRLF") ou `grep -lU $'\r' <arquivo>` (vazio = OK).
3. **Trailing newline.** Arquivo termina com exatamente uma `\n`. Verificar com `tail -c 1 <arquivo> | xxd` (deve mostrar `0a`).
4. **Sem caracteres de controle não-imprimíveis** além de tab (`\t`), LF (`\n`) e espaço.
5. **Indentação em blocos de código:** dois espaços. Sem tabs em código interno (tabs no shell são aceitáveis quando relevantes).

### 3.2 Frontmatter

Aplica-se a todos os arquivos `.md` do framework e dos artefatos do projeto.

6. **Frontmatter presente.** Delimitado por `---` na primeira linha e em linha posterior. Sem espaços antes do `---` inicial.
7. **YAML parseável.** Chaves em minúsculas, sem espaços (snake_case com `_` quando composto). Valores não-string sem aspas; strings sem aspas exceto quando contêm `:`, `#`, `[`, `]`, ou começam com número.
8. **Campos universais obrigatórios presentes:** `versão`, `status`, `atualizado`.
9. **`versão` no formato `X.Y`.** Nunca `X.Y.Z`, nunca apenas `X`.
10. **`status` em conjunto válido:** `estável`, `experimental`, `deprecated`. Em minúsculas.
11. **`atualizado` em formato ISO `AAAA-MM-DD`.**
12. **Sem comentários `#` dentro do frontmatter.**

### 3.3 Idioma e nomenclatura

13. **Conteúdo em pt-BR.** Verificável heuristicamente por amostragem. Anomalias: blocos de texto inteiramente em inglês fora de blocos de código.
14. **Termos técnicos consagrados em inglês:** `commit`, `diff`, `workflow`, `branch`, `merge`, `pull request` — preservados, não traduzidos.
15. **Nomes de arquivos e pastas em kebab-case inglês.** Verificável por `ls`: arquivos com underscore, camelCase ou caracteres especiais são violações.
16. **Chaves de frontmatter em snake_case inglês** (ex: `gera_decision`, `usa_checkpoints`). Sem hífen, sem acento.

### 3.4 Caminhos e referências

17. **Referências ao framework usam `~/.codeflow/...`.** Nunca caminho absoluto literal (`/home/usuario/...`), nunca variável (`$CODEFLOW_HOME`). Exceções: documentos do próprio mantenedor que descrevem o repositório (`~/Projetos/codeflow/`).
18. **Referências ao projeto são relativas à raiz do projeto** ou começam com `.codeflow/`. Sem `/` ou `~/` no início.
19. **Links markdown internos consistentes.** Quando o caminho aparece em prosa, formatar como código inline com crases (`` `caminho/exemplo` ``).

### 3.5 Linguagem imperativa em regras

Aplica-se a constitution (1.1, 2.2), rules (1.4), workflows (1.5–1.7), skills (1.8), meta-skills (1.9), agents (1.10) e EVOLUTION (1.3).

20. **Sem palavras-fraca.** Não pode ocorrer (case-insensitive, fora de blocos de código): `preferencialmente`, `recomendado`, `sugere-se`, `pode considerar`, `idealmente`. Verificar com `grep -i`.
21. **Anti-regras começam por forma negativa.** `Não`, `Nunca`, `Jamais`. Sem hedges como "evitar".

### 3.6 Símbolos padronizados

Conforme tabela §0.6.

22. **Símbolos de status são exatamente:** `✓` (sucesso), `✗` (falha), `⚠` (aviso). Sem alternativas decorativas (emojis, setas Unicode).
23. **Checklists usam:** `[ ]`, `[✓]`, `[—]`. Sem outras variações.

### 3.7 Caminhos e datas em frontmatter

24. **Datas em frontmatter no formato ISO `AAAA-MM-DD`.**
25. **Timestamps no formato `AAAA-MM-DD-HHMMSS`** (usado apenas em checkpoints).
26. **Fuso local da máquina.** Não converter para UTC.

### 3.8 Stack permitida em scripts

Aplica-se a scripts bash do framework (`install.sh`, hooks opcionais, scripts auxiliares dentro de pastas de skill ou meta-skill).

27. **Apenas bash + coreutils + git + openssl.** Conforme `SPEC.md` §7.3 e §0.9. Tools proibidas (presença bloqueia validação): `jq`, `yq`, `python`, `node`, `go`, `rust`, `docker`, `podman`, `pbcopy`, `xclip`.
28. **Códigos de saída no conjunto válido:** 0 (sucesso), 1 (falha de regra), 2 (erro de execução), 3 (input inválido). Outros códigos exigem decisão registrada.

### 3.9 Coerência entre arquivos

Verificações que cruzam múltiplos arquivos. Mais caras computacionalmente; aplicadas em validações de integridade do `.codeflow/` (não em cada arquivo individualmente).

29. **Decision listada no INDEX existe como arquivo.** Para cada linha em `decisions/INDEX.md` Por data, o arquivo `decisions/<data>-<titulo>.md` correspondente existe.
30. **Decision real existe no INDEX.** O caminho inverso da regra anterior. Arquivos órfãos em `decisions/` indicam atualização incompleta.
31. **`supersede` em decision aponta para arquivo existente** ou é `null`.
32. **`relaciona-com` em decision aponta apenas para arquivos existentes.**
33. **Coerência entre `escopo` de rule/agent no frontmatter e localização do arquivo.** `escopo: universal` mora em `~/.codeflow/framework/...`; `escopo: projeto` mora em `<projeto>/.codeflow/...`.
34. **`validation_hash` do manifest bate com o hash dos arquivos críticos listados.** Verificável dinamicamente recalculando SHA-256 sobre os arquivos em `## Arquivos críticos para freshness`.
35. **Workflow com `gera_decision: yes` sempre gera decision ao concluir.** Verificável por inspeção de log/histórico. Workflow com `gera_decision: no` nunca gera decision.

### 3.10 Anti-padrões transversais

36. **Sem caminhos absolutos hardcoded** fora dos casos documentados em §3.4. Verificar com `grep -E '^/|/home/|/Users/'`.
37. **Sem referências a ferramentas de IA específicas embutidas em conteúdo neutro.** "Claude Code", "Cursor" só aparecem em contexto explicitamente comparativo (glossary, EVOLUTION). Workflows, skills, constitution: agnósticos.
38. **Sem TODO, FIXME, XXX em arquivos do framework ou artefatos.** Esses marcadores indicam trabalho incompleto; toda criação chega completa ou não chega.
39. **Sem comentários HTML (`<!-- -->`) com instruções para humanos.** Markdown do framework é lido por IA; comentários HTML viram ruído. Notas para humanos vão em arquivos do andaime (`SPEC.md`, este documento), não em conteúdo entregue do framework.

---

## Fim do ARTIFACTS_SPEC.md
