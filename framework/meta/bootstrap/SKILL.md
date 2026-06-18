---
versão: 1.3
status: estável
atualizado: 2026-06-18
descrição: Cria um projeto novo a partir de ideia, com estrutura mínima e artefatos do .codeflow/.
é_meta_skill: yes
granularidade: detalhado
---

# Meta-skill: bootstrap

> **Specs de runtime:** as referências a `ARTIFACTS_SPEC.md §x` (templates e validação) e a `SPEC.md §x` ao longo deste protocolo apontam para `~/.codeflow/framework/core/ARTIFACTS_SPEC.md` e `~/.codeflow/framework/core/SPEC.md`. Leia os templates literais de lá — não parafraseie de memória.

## Quando usar

Usuário invoca `/bootstrap` quando quer criar um projeto **novo** a partir de uma ideia, sem código pré-existente. A meta-skill conduz coleta de requisitos, decide stack e estrutura, gera o esqueleto do projeto e os artefatos iniciais do `.codeflow/` (`constitution.md`, `manifest.md`, `INDEX.md`). Não gera `discovered.md` — não há projeto pré-existente a descobrir (`ARTIFACTS_SPEC.md` §2.4.1).

**Onde cria:** em **greenfield** (você está numa pasta-mãe como `~/projetos/`), o bootstrap pergunta o nome e **cria a subpasta `<nome>/`** — rodar de uma pasta com vários projetos é o caso normal. Se você já está dentro de um projeto inicializado (ex: `/ideacao` já criou a pasta e o `roteiro.md`), ele opera **ali mesmo**. Os dois modos são decididos na Fase 0.

**Auto-contida:** **não exige** que o `install.sh` tenha rodado antes — ela mesma cria o `.codeflow/` que precisa. O `install.sh` continua útil depois, para completar o aparato do `.codeflow/` (templates de spec, `decisions/`) — sugerido nos próximos passos (Fase 5).

**Consome o roteiro:** se houver `roteiro.md` (de `/ideacao`), o bootstrap parte dele em vez de re-perguntar propósito, escopo e restrições. Cadeia típica: `/ideacao` → `/bootstrap` → `/create-spec`.

## Princípio guia

Projeto novo nasce com decisões mínimas explícitas: propósito, stack, padrão arquitetural, regras invariantes. O bootstrap não tenta antecipar features futuras — entrega o esqueleto suficiente para começar, com os comandos de validação da stack registrados no manifest e codeflow integrado. Decisões adiáveis ficam adiadas e documentadas como pendentes.

## Protocolo

### Fase 0 — Pré-flight e preparação

Antes de coletar requisitos, preparar o terreno e decidir **onde** o projeto será criado. Sem isso, os checkpoints das Fases 1–3 não teriam onde ser gravados.

1. **Data canônica:** obter a data de hoje executando `date +%F` via Bash. Usar esse valor em todos os campos de data (`atualizado`, `last_validated`). **Não** inferir a data de memória.
2. **Detectar o modo e estabelecer `<projeto>`:**
   - **Em-projeto** — o cwd já é um projeto inicializado (existe `./.codeflow/`, tipicamente porque `/ideacao` rodou aqui). Então `<projeto>` = cwd; **não** criar pasta nova. Confirmar que não há código-fonte de aplicação (só `.codeflow/`, `.git/`, e talvez um `roteiro.md` são esperados). Se houver código, abortar — projeto com código é caso de `/discover`.
   - **Greenfield** — o cwd **não** é um projeto inicializado (típico: você está em `~/projetos/`). Aqui o bootstrap **cria a pasta do projeto**: como o nome só nasce na conversa, perguntar o **nome (kebab-case)** já agora, e criar `./<nome>/`. Se `./<nome>/` já existir, parar e pedir outro nome (não sobrescrever pasta existente). Daqui em diante `<projeto>` = `./<nome>/`. Rodar a partir de uma pasta que contém vários projetos é o caso **normal**, não um erro.
3. **Procurar um roteiro:** se existir `<projeto>/.codeflow/roteiro.md`, lê-lo agora — ele traz visão, escopo do MVP, restrições e backlog decididos em `/ideacao`. A Fase 1 vai **consumir** o roteiro em vez de re-perguntar.
4. **Criar o esqueleto mínimo do `.codeflow/`:** `mkdir -p <projeto>/.codeflow/checkpoints <projeto>/.codeflow/decisions <projeto>/.codeflow/specs`. Dá casa aos checkpoints já a partir da Fase 1. Os artefatos (`constitution.md`/`manifest.md`/`INDEX.md`) são escritos na Fase 4; os templates de spec em `_TEMPLATES/` ficam para o `install.sh` (Fase 5).

### Fase 1 — Coleta de requisitos

**Se há `roteiro.md` (Fase 0):** não re-perguntar o que já está decidido. Derivar dele o nome, o propósito, o público e as restrições; **apresentar ao owner um resumo do que foi extraído** e pedir só o que faltar (tipo de projeto, licença, idioma da doc). Confirmar e seguir.

**Se não há roteiro:**
- Pergunta ao usuário: propósito em uma frase, tipo de projeto (CLI, biblioteca, serviço web, app desktop, etc.). (O nome já foi capturado na Fase 0 em modo greenfield; em modo em-projeto, derivar do `.codeflow/` existente.)
- Pergunta sobre licença pretendida (default sugerido: MIT) e idioma da documentação voltada ao usuário final.
- Pergunta se há restrições conhecidas: dependências proibidas, padrão arquitetural exigido, áreas sensíveis a planejar desde já.

- Apresentar plano de coleta (resumo das respostas, vindas do roteiro ou das perguntas) ao usuário e aguardar confirmação antes de avançar. Esta pausa é obrigatória.
- Gravar checkpoint ao fim da fase (`SPEC.md` §6.6).

### Fase 1 — Coleta de requisitos

- Pergunta ao usuário: nome do projeto (kebab-case), propósito em uma frase, tipo de projeto (CLI, biblioteca, serviço web, app desktop, etc.).
- Pergunta sobre licença pretendida (default sugerido: MIT) e idioma da documentação voltada ao usuário final.
- Pergunta se há restrições conhecidas: dependências proibidas, padrão arquitetural exigido, áreas sensíveis a planejar desde já.
- Apresentar plano de coleta (resumo das respostas) ao usuário e aguardar confirmação antes de avançar. Esta pausa é obrigatória.
- Gravar checkpoint ao fim da fase (`SPEC.md` §6.6).

### Fase 2 — Decisão de stack e estrutura

- Propor stack concreta (linguagem, versão, gerenciador de pacotes, framework principal se aplicável) compatível com tipo de projeto e restrições da Fase 1. Se há `roteiro.md`, ancorar a proposta no escopo do MVP e nas restrições dele (ex: "web primeiro" no roteiro favorece stack web).
- Propor padrão arquitetural inicial (camadas mínimas, organização de pastas).
- Propor os comandos de validação da stack (`check`, `lint`, `typecheck`, `test`, `security`) e como embrulhá-los (scripts de `package.json`, um `Makefile`, `justfile`, ou comandos diretos) — a forma idiomática da stack escolhida.
- Pergunta ao usuário se aprova as propostas. Aceitar contraproposta e iterar até confirmação.
- Aguardar resposta final do usuário antes de avançar. Esta pausa é obrigatória.
- Gravar checkpoint ao fim da fase.

### Fase 3 — Geração de estrutura mínima do projeto

- Criar pastas conforme decisão da Fase 2.
- Criar `<projeto>/README.md` esqueleto (título, descrição em uma frase, seção de setup, seção de licença).
- Materializar os comandos de validação na forma idiomática da stack (scripts em `package.json`, um `Makefile`, ou `justfile`) quando útil — cada um chamando o comando real da stack, ou um `noop` quando ainda não há comando definido. O embrulho é opcional; a fonte canônica dos comandos é o `manifest.md` (Fase 4).
- Criar `<projeto>/.gitignore` com entradas mínimas: artefatos de build da stack, `.codeflow/checkpoints/`, arquivos de IDE comuns.
- Criar `<projeto>/LICENSE` com texto da licença escolhida.
- Gravar checkpoint ao fim da fase.

### Fase 4 — Geração de artefatos do `.codeflow/`

**Regra dura desta fase:** seguir os templates de `ARTIFACTS_SPEC.md` §2.2.5, §2.3.5 e §2.1.5 **literalmente** — títulos, nomes de seções e campos de frontmatter são vinculantes. Não renomear, não numerar, não traduzir, não improvisar. O nome do projeto (`projeto`) é o mesmo, idêntico, nos três artefatos.

#### 4a) `<projeto>/.codeflow/constitution.md` — schema §2.2.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado` (= data da Fase 0), `projeto`. Não inventar campos.

**Título exato:** `# Constitution do projeto: <nome>` — com dois pontos e `<nome>` idêntico ao `projeto` do frontmatter.

**Seções obrigatórias, nesta ordem literal:**
1. `## Stack` — lista factual (linguagem, framework, banco) decidida na Fase 2.
2. `## Padrão arquitetural` — nome do padrão decidido, ou literal `Sem padrão definido — discutir com /discover --refresh`.
3. `## Regras invariantes específicas` — bullets imperativos verificáveis, **ancorados em decisão das Fases 1/2**; no mínimo um, ou literal `Sem regras específicas além da constitution universal.`. Não inventar regra sem decisão de origem.
4. `## Áreas de alto risco` — caminhos concretos a planejar desde já (se houver restrição na Fase 1), ou literal apropriado.
5. `## Definition of Done específica` — extensões do DoD universal ou literal `Sem extensões.`. **Sempre presente.**

#### 4b) `<projeto>/.codeflow/manifest.md` — schema §2.3.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado`, `projeto` (= o da constitution), `last_validated` (= data da Fase 0 — não houve `discover`, mas o campo é obrigatório; serve de baseline), `validation_hash` (SHA-256 de 64 hex).

**Cálculo de `validation_hash` — REGRA DURA, anti-alucinação:** computar executando o comando via Bash sobre os arquivos criados na Fase 3, e colar a saída literal. **Proibido** escrever 64 hex "plausíveis" de memória. Como a Fase 3 já materializou `package.json`/`Makefile`/configs, o hash é computável de verdade:

```bash
cat <arquivo1> <arquivo2> ... <arquivoN> 2>/dev/null | sha256sum | cut -d' ' -f1
```

A lista e a ordem são exatamente as de `## Arquivos críticos para freshness`. Arquivos ausentes contribuem como string vazia.

**Título exato:** `# Manifest do projeto: <nome>` — com dois pontos.

**Seções obrigatórias, nesta ordem literal:**
1. `## Stack identificada` — versões exatas decididas na Fase 2 (ex: `Python 3.12`).
2. `## Comandos de validação` — os cinco gates (`check`, `lint`, `typecheck`, `test`, `security`) mapeados ao comando real da stack decidido na Fase 2. Gate que ainda não tem validação de verdade fica `[—]`, mesmo que a Fase 3 tenha criado um alvo `noop` como placeholder no embrulho — o manifest registra o que valida de fato, não o placeholder. `check` é o agregador.
3. `## Padrões definidos` — **não** `## Padrões detectados` (§2.3.3 item 4): bootstrap não inspeciona código, então os padrões são metas da Fase 2. Usar verbos prospectivos ("a estabelecer", "definido como meta", "núcleo a separar de I/O"); nunca afirmar que algo foi "detectado"/"estabelecido" com arquivos inexistentes.
4. `## Arquivos críticos para freshness` — os arquivos de stack/config criados na Fase 3 que existem no disco (manifest de stack, lockfile se houver, `Makefile`/`justfile`, configs de linter). Mesma ordem usada no hash.
5. `## Notas de inspeção` — registrar a data (Fase 0), que a meta-skill foi `bootstrap`, e **que os padrões são prospectivos** (não observados).

#### 4c) `<projeto>/.codeflow/INDEX.md` — schema §2.1.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado`, `schema_version` em formato `X.Y`.

**Título exato:** `# INDEX do .codeflow/ do projeto` — sem sufixo com nome do projeto.

**Seções obrigatórias, nesta ordem literal:**
1. `## Leia sempre primeiro` — lista ordenada: `constitution.md` (1), `manifest.md` (2). Caminhos relativos a `.codeflow/`.
2. `## Leia se relevante ao contexto` — `decisions/INDEX.md` e, **se existir**, `roteiro.md` (gerado por `/ideacao`). **Não** referenciar `discovered.md` — bootstrap não o gera.
3. `## Arquivos gerados automaticamente — não editar manualmente` — `checkpoints/*` e `decisions/<arquivo>.md`.
4. `## Versão do schema e última atualização` — uma linha com `schema_version` e a data.

**Tamanho-alvo: 15–25 linhas.** Acima de 35 sinaliza inchaço. Não criar seções extras — INDEX é mapa de prioridade, não inventário.

#### 4d) Validação obrigatória antes de avançar

Para cada um dos três arquivos:
1. Re-ler o arquivo do disco.
2. Confrontar **item por item** com a respectiva `§2.X.6` (validação) e `§2.X.3` (schema) do `ARTIFACTS_SPEC.md`.
3. Se algum item falhar: **regenerar o artefato inteiro** a partir do template §2.X.5, não corrigir parcialmente.
4. **Específico do manifest:** re-executar o comando de `validation_hash` (mesma lista/ordem) via Bash e confirmar que a saída é **idêntica** ao frontmatter. Divergência = corrigir com a saída real.
5. Só avançar quando os três passarem em todas as regras.
6. Gravar checkpoint ao fim da fase.

### Fase 5 — Entrega e próximos passos

- Apresentar ao usuário o resumo: árvore de pastas criadas, arquivos gerados (raiz + `.codeflow/`), próximos passos sugeridos.
- Sugerir comandos imediatos, **nesta ordem**: (1) `git init` (se ainda não for repo); (2) `bash ~/.codeflow/install.sh` — completa o aparato do `.codeflow/` (sincroniza `specs/_TEMPLATES/`, garante `decisions/`, registra `.codeflow/checkpoints/` no `.gitignore`); é idempotente e **preserva** os artefatos que o bootstrap já gerou; (3) instalar dependências da stack; (4) primeiro commit.
- **Avisar sobre entrypoints prospectivos:** se o manifest de stack declara um entrypoint que aponta para módulo ainda inexistente (ex.: `[project.scripts] tsconv = "tsconv.cli:main"` com `cli.py` a ser criado por uma feature futura), avisar explicitamente que `pip install -e` (ou equivalente) criará um console-script **quebrado** até a primeira feature materializar esse módulo. Não é erro do esqueleto — é consequência honesta de o entrypoint preceder o código —, mas o usuário precisa saber. Isso soma-se ao já conhecido `pytest exit 5` (nenhum teste coletado) num projeto recém-criado.
- Aguardar resposta do usuário. Aplicar ajustes solicitados, re-rodar validação. Após confirmação final, encerrar.

## Proibições durante esta meta-skill

- Não gerar `discovered.md`. `bootstrap` cria projeto novo; não há descoberta. Confunde-se com `discover` (`ARTIFACTS_SPEC.md` §2.4.1).
- Não escolher stack sem confirmação explícita do usuário na Fase 2.
- Não criar arquivos de código de aplicação (módulos, componentes, endpoints) — apenas esqueleto mínimo. Features são responsabilidade de workflows posteriores.
- Não baixar dependências nem rodar instaladores. Bootstrap gera arquivos; o usuário roda comandos da stack.
- Não criar projeto em diretório que já contém **código-fonte**. Um diretório vazio, com `.git/`, ou com `.codeflow/` de um `install.sh` prévio é aceitável (Fase 0); código de aplicação existente não — isso é caso de `discover`.
- Não inventar regras invariantes na constitution sem ancorar em decisão tomada nas Fases 1 ou 2.
- **Não escrever `validation_hash` de memória.** O hash é sempre a saída literal do `sha256sum` rodado via Bash sobre os arquivos de `## Arquivos críticos para freshness` criados na Fase 3. Fabricar 64 hex é proibido — e omitir o campo reprova o schema §2.3.3.
- **Não inferir datas de memória.** Toda data ISO vem do `date +%F` da Fase 0.

## Template de saída

Esta meta-skill gera três artefatos do `.codeflow/` mais arquivos esqueleto do projeto. Selecionar template conforme tipo:

- **`INDEX.md`:** template em `ARTIFACTS_SPEC.md` §2.1.5.
- **`constitution.md`:** template em `ARTIFACTS_SPEC.md` §2.2.5.
- **`manifest.md`:** template em `ARTIFACTS_SPEC.md` §2.3.5.
- **README.md, .gitignore, LICENSE (e Makefile/scripts se a stack pedir):** esqueletos mínimos descritos na Fase 3, sem template formal.

Substituir placeholders com valores coletados nas Fases 1 e 2. Datas em formato ISO `AAAA-MM-DD`, sempre a obtida na Fase 0 via `date +%F` — nunca inferida de memória.

## Onde salvar

Dois conjuntos de destinos:

- **Artefatos do codeflow** (gerados nesta meta-skill): `<projeto>/.codeflow/INDEX.md`, `<projeto>/.codeflow/constitution.md`, `<projeto>/.codeflow/manifest.md`.
- **Arquivos do projeto** (estrutura mínima): `<projeto>/README.md`, `<projeto>/.gitignore`, `<projeto>/LICENSE`, o embrulho de comandos se houver (`Makefile`/scripts), e pastas decididas na Fase 2.

Nenhum arquivo é criado em `~/.codeflow/` por esta meta-skill.

## Validação pós-geração

- Aplicar `ARTIFACTS_SPEC.md` §2.1.6 a `INDEX.md`, §2.2.6 a `constitution.md`, §2.3.6 a `manifest.md`, **item por item**. Em qualquer falha, regenerar o artefato inteiro a partir do template (§2.X.5), não corrigir parcialmente.
- **Recomputar o `validation_hash`** via Bash (mesma lista/ordem de `## Arquivos críticos para freshness`) e confirmar que bate com o frontmatter do `manifest.md`. Divergência ou campo ausente reprova.
- Verificar que a quarta seção do `manifest.md` é `## Padrões definidos` (não `## Padrões detectados`) e usa verbos prospectivos — nenhuma afirmação de que estrutura foi "detectada"/"estabelecida" com arquivos que ainda não existem.
- Verificar que `INDEX.md` **não** referencia `discovered.md` (bootstrap não o gera) e que o `projeto` é idêntico em `constitution.md` e `manifest.md`.
- Verificar que o `manifest.md` registra os cinco gates (`check`, `lint`, `typecheck`, `test`, `security`); se houver embrulho (`Makefile`/scripts), que ele os reflete.
- Verificar que `.codeflow/checkpoints/` está no `.gitignore` (criado na Fase 3; senão, o `install.sh` da Fase 5 o adiciona).
- Apresentar resumo final ao usuário com caminhos dos arquivos gerados.

## Retomada

`bootstrap` é detalhado e usa checkpoints (`SPEC.md` §6.6). Ao iniciar:

- Verificar se existe `<projeto>/.codeflow/checkpoints/bootstrap-*.md` recente.
- Se sim: apresentar resumo do checkpoint e perguntar ao usuário se deseja retomar daquele ponto ou começar do zero.
- Se retomar: carregar fase em pausa, decisões tomadas (stack, padrão, targets). Continuar a partir da Fase indicada.
- Se começar do zero: deletar checkpoint antigo, reiniciar da Fase 0. Confirmar com o usuário que arquivos já criados em fases anteriores podem ser sobrescritos.

## Saídas válidas

- **Projeto criado:** estrutura mínima do projeto + três artefatos em `<projeto>/.codeflow/`, cada um passando nas regras de validação correspondentes. Resumo apresentado ao usuário com próximos passos.
- **Bootstrap abortado:** usuário interrompe em qualquer fase com pausa sem confirmar. Checkpoint preservado para retomada futura. Arquivos gerados em fases anteriores ficam no disco; usuário decide se descarta manualmente.
