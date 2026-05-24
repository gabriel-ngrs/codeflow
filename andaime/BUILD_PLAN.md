---
versão: 1.1
status: estável
atualizado: 2026-05-20
---

# BUILD_PLAN.md — Plano de construção do codeflow

Este documento é o terceiro do andaime (`SPEC.md`, `ARTIFACTS_SPEC.md`, **`BUILD_PLAN.md`**, `VALIDATION.md`, `PROMPTS.md`). Sua função é dizer **em que ordem** o Claude Code (ou qualquer agente equivalente) deve construir o codeflow, com quais dependências entre etapas, e como verificar conclusão de cada uma.

Onde este documento diz **o quê** e **quando**, o `ARTIFACTS_SPEC.md` diz **como cada arquivo deve parecer** e o `VALIDATION.md` (próximo documento) diz **como verificar** cada regra. Cada etapa abaixo cita as seções aplicáveis dos outros documentos por número.

## Parte 0 — Convenções gerais

### 0.1 Identificação de etapas

Toda etapa tem identificador `F<fase>.<etapa>`, por exemplo `F2.3` é a terceira etapa da segunda fase. Identificadores são estáveis: uma etapa removida ou movida não tem seu número reaproveitado.

### 0.2 Estrutura de cada etapa

Cada etapa é descrita em seis blocos fixos:

1. **Objetivo** — uma frase declarando o que a etapa entrega.
2. **Pré-requisitos** — etapas anteriores que precisam estar concluídas; arquivos que precisam existir.
3. **Ações** — operações concretas a executar, em ordem. Cada ação cita as seções de `ARTIFACTS_SPEC.md` que governam o arquivo gerado.
4. **Validação** — referência ao `VALIDATION.md` §V.X (a ser preenchida pelo próximo documento do andaime).
5. **Gate de progressão** — condição objetiva que precisa ser verdadeira para a etapa estar concluída. Sem isso, não avançar.
6. **Commit sugerido** — mensagem de commit que marca a conclusão da etapa no git do framework. Formato: `<tipo>(<escopo>): <mensagem>`.

### 0.3 Ambiente de execução

- **Localização do framework em construção:** `~/Projetos/codeflow/` (repositório de trabalho).
- **Localização do framework instalado:** `~/.codeflow/` (symlink para `~/Projetos/codeflow/`, criado na Fase 1).
- **Localização do projeto de teste:** decidida na Fase 5 (pasta temporária; não é projeto real).
- **Stack permitida:** bash + coreutils + git + openssl, conforme `SPEC.md` §7.3 e `ARTIFACTS_SPEC.md` §0.9.

### 0.4 Símbolos de status de etapa

Durante a execução, o Claude Code pode marcar cada etapa em um log de execução. Os símbolos são exatamente os definidos em `ARTIFACTS_SPEC.md` §0.6:

- `[ ]` — etapa pendente
- `[✓]` — etapa concluída e validada
- `[—]` — etapa pulada com justificativa registrada
- `⚠` — etapa concluída com aviso (validação passou, mas requer atenção)
- `✗` — etapa falhou (rollback necessário)

### 0.5 Política de falhas durante a construção

A política universal de falhas (`SPEC.md` §8.3) aplica-se também à construção do framework:

- **Falha de validação em uma etapa:** parar imediatamente. Não avançar para a próxima etapa. Aplicar formato PARADO documentado na constitution universal.
- **Falha transitória (rede, disco temporariamente cheio):** retry com backoff, máximo de três tentativas.
- **Falha lógica (arquivo gerado não passa nas regras de validação):** corrigir o arquivo antes de avançar; não acumular dívida.
- **Falha de escopo (etapa exige decisão que o BUILD_PLAN não cobre):** parar e perguntar ao mantenedor antes de inventar.

### 0.6 Retomada após interrupção

Se a sessão do Claude Code é interrompida, retomar consultando o log de execução das etapas. A última etapa com status `[ ]` ou `[—]` (após uma com `[✓]`) é a próxima a executar. Em dúvida, perguntar ao mantenedor antes de assumir.

A Parte 3 deste documento detalha o protocolo de retomada.

---

## Parte 1 — Visão geral das fases

A construção é organizada em **cinco fases** sequenciais, contendo um total de **23 etapas**. Cada fase termina em um estado verificável e commit limpo no git do framework.

### Fase 1 — Andaime físico (4 etapas)

Cria o esqueleto: repositório git, estrutura de pastas vazia, documentos do andaime já produzidos copiados para `~/.codeflow/andaime/`, e symlink `~/.codeflow/` → `~/Projetos/codeflow/`.

Saída: estrutura de pastas conforme `SPEC.md` §2.2, repositório git inicializado, documentos do andaime (SPEC, ARTIFACTS_SPEC, BUILD_PLAN) presentes em `~/.codeflow/andaime/`.

### Fase 2 — Núcleo conceitual (4 etapas)

Preenche `framework/core/`: a constitution universal, o glossary, EVOLUTION.md, e os quatro rules seed.

Saída: oito arquivos em `framework/core/`, todos validados conforme `ARTIFACTS_SPEC.md` §1.1 a §1.4.

### Fase 3 — Biblioteca (3 etapas)

Preenche `framework/library/`: três skills seed (`debug-protocol`, `handoff`, `self-review`) e quatro workflows seed (`bugfix`, `feature-small`, `refactor-safe`, `review-only`).

Saída: três pastas de skill com `SKILL.md`, quatro arquivos de workflow.

### Fase 4 — Meta-skills (2 etapas)

Preenche `framework/meta/`: as cinco meta-skills seed (`discover`, `bootstrap`, `create-workflow`, `create-skill`, `create-agent`).

Saída: cinco pastas de meta-skill com `SKILL.md`.

### Fase 5 — Empacotamento e validação fim-a-fim (10 etapas)

Cria `install.sh`, `README.md` da raiz, copia VALIDATION.md e PROMPTS.md (gerados em paralelo a esta fase) para `andaime/`, executa instalação em projeto de teste, exercita os caminhos críticos (`/discover`, `/bootstrap` simulados), **documenta e implementa o wiring de slash commands** (via wrappers em `~/.claude/commands/` e `<projeto>/.claude/commands/`), e marca o framework como pronto.

Saída: framework instalado em projeto de teste, paths críticos exercitados sem falha, slash commands `/bugfix`, `/discover` etc. funcionais nativamente.

### Mapa de dependências entre fases

```
Fase 1 (andaime físico)
    ↓
Fase 2 (núcleo)  ←─── glossary é pré-req para todas as outras fases (validação de termos)
    ↓
Fase 3 (biblioteca)  ←─── skills e workflows referenciam constitution e rules
    ↓
Fase 4 (meta-skills)  ←─── meta-skills referenciam ARTIFACTS_SPEC e a estrutura inteira
    ↓
Fase 5 (empacotamento + teste fim-a-fim)
```

Dependências mais finas dentro de cada fase são declaradas no campo **Pré-requisitos** de cada etapa.

---

## Parte 2 — Detalhamento etapa por etapa

### Fase 1 — Andaime físico

#### Etapa F1.1 — Inicializar repositório do framework

**Objetivo:** criar `~/Projetos/codeflow/` como repositório git, com `.gitignore` mínimo e commit inicial vazio.

**Pré-requisitos:**
- Diretório `~/Projetos/codeflow/` **já existe** contendo apenas a subpasta `andaime/` com os cinco documentos do andaime. Nenhum outro conteúdo, e o diretório **não é** ainda um repositório git.
- `git` instalado e configurado com `user.name` e `user.email`.

**Ações:**
1. Verificar estado do diretório: `git -C ~/Projetos/codeflow rev-parse --git-dir 2>/dev/null` deve **falhar** (ainda não é repo git), e `ls ~/Projetos/codeflow` deve listar apenas `andaime`. Se houver qualquer outro conteúdo, parar e reportar (formato PARADO) — não tentar conciliar automaticamente.
2. Entrar no diretório: `cd ~/Projetos/codeflow`.
3. Inicializar repositório: `git init`.
4. Criar `.gitignore` na raiz contendo no mínimo: `.DS_Store`, `*.swp`, `*.bak`, `*~`. Não incluir nada do framework em si — todo o conteúdo do framework é versionado.
5. Criar `LICENSE` na raiz com o **texto MIT padrão** (ano corrente, titular = nome do mantenedor configurado em `git config user.name`). Licença é definitiva; não há pendência a registrar.
6. Criar `andaime/EXECUTION_LOG.md` com cabeçalho inicial: frontmatter (`versão`, `status`, `atualizado`), título `# Execução do BUILD_PLAN — log incremental`, e uma linha por etapa concluída a ser preenchida ao longo do build. O log é obrigatório e acompanha o build até F5.10.
7. Commit inicial: `git add . && git commit -m "chore(init): inicializa repositório do codeflow"`.

**Validação:** `VALIDATION.md` §V.1.1 (a definir).

Verificações mínimas executáveis nesta etapa:
- `git -C ~/Projetos/codeflow rev-parse HEAD` retorna hash válido.
- `~/Projetos/codeflow/.gitignore` existe e contém pelo menos as quatro entradas listadas.
- `git -C ~/Projetos/codeflow status` retorna `nothing to commit, working tree clean`.

**Gate de progressão:** repositório inicializado, commit inicial presente, working tree limpo.

**Commit sugerido:** `chore(init): inicializa repositório do codeflow`.

---

#### Etapa F1.2 — Criar estrutura de pastas vazia

**Objetivo:** materializar a árvore de diretórios conforme `SPEC.md` §2.2, com placeholders `.gitkeep` em cada pasta que ainda não tem conteúdo.

**Pré-requisitos:** F1.1 concluída.

**Ações:**
1. Criar pastas conforme `SPEC.md` §2.2:
   ```
   framework/core/rules/
   framework/meta/discover/
   framework/meta/bootstrap/
   framework/meta/create-workflow/
   framework/meta/create-skill/
   framework/meta/create-agent/
   framework/library/skills/debug-protocol/
   framework/library/skills/handoff/
   framework/library/skills/self-review/
   framework/library/workflows/
   andaime/
   ```
2. Em cada pasta criada, adicionar arquivo `.gitkeep` vazio. Isto garante que o git rastreie as pastas mesmo antes de terem conteúdo, e o Claude Code pode validar a estrutura imediatamente.
3. Commit: `git add . && git commit -m "chore(structure): cria árvore de pastas conforme SPEC §2.2"`.

**Validação:** `VALIDATION.md` §V.1.2 (a definir).

Verificações mínimas:
- Cada uma das pastas listadas existe e contém pelo menos `.gitkeep`.
- Nenhuma pasta fora da árvore declarada em `SPEC.md` §2.2 foi criada.
- `tree ~/Projetos/codeflow/framework/` (ou `find` equivalente) reproduz a estrutura literal do SPEC.

**Gate de progressão:** árvore de pastas completa, validada por comparação com `SPEC.md` §2.2.

**Commit sugerido:** `chore(structure): cria árvore de pastas conforme SPEC §2.2`.

---

#### Etapa F1.3 — Copiar documentos do andaime já produzidos

**Objetivo:** copiar `SPEC.md`, `ARTIFACTS_SPEC.md` e este `BUILD_PLAN.md` para `~/Projetos/codeflow/andaime/`. `VALIDATION.md` e `PROMPTS.md` ainda não existem e serão adicionados na Fase 5.

**Pré-requisitos:** F1.2 concluída. Arquivos-fonte do andaime acessíveis no sistema do mantenedor.

**Ações:**
1. Copiar `SPEC.md` para `~/Projetos/codeflow/andaime/SPEC.md`.
2. Copiar `ARTIFACTS_SPEC.md` para `~/Projetos/codeflow/andaime/ARTIFACTS_SPEC.md`.
3. Copiar este `BUILD_PLAN.md` para `~/Projetos/codeflow/andaime/BUILD_PLAN.md`.
4. Criar `~/Projetos/codeflow/andaime/README.md` curto (10 a 15 linhas) explicando o papel do andaime e listando os cinco documentos previstos (com `VALIDATION.md` e `PROMPTS.md` marcados como pendentes).
5. Remover `.gitkeep` de `andaime/` (já tem conteúdo).
6. Commit: `git add . && git commit -m "docs(andaime): adiciona SPEC, ARTIFACTS_SPEC e BUILD_PLAN"`.

**Validação:** `VALIDATION.md` §V.1.3 (a definir).

Verificações mínimas:
- Três arquivos do andaime presentes em `andaime/`.
- `andaime/README.md` existe e cita os cinco documentos previstos.
- Cada arquivo do andaime tem frontmatter válido conforme `ARTIFACTS_SPEC.md` §0.2.

**Gate de progressão:** três documentos do andaime versionados em `andaime/`, com README explicativo presente.

**Commit sugerido:** `docs(andaime): adiciona SPEC, ARTIFACTS_SPEC e BUILD_PLAN`.

---

#### Etapa F1.4 — Criar symlink `~/.codeflow/` → `~/Projetos/codeflow/`

**Objetivo:** estabelecer o caminho canônico `~/.codeflow/` que toda referência interna usa, sem duplicar conteúdo no disco.

**Pré-requisitos:** F1.3 concluída.

**Ações:**
1. Verificar que `~/.codeflow` não existe ainda (`test ! -e ~/.codeflow`). Se existir, parar e perguntar ao mantenedor antes de prosseguir — pode ser instalação prévia que exige decisão de migração.
2. Criar o symlink: `ln -s ~/Projetos/codeflow ~/.codeflow`.
3. Verificar que `~/.codeflow/framework/core/` é acessível via symlink: `ls -la ~/.codeflow/framework/core/`.

**Validação:** `VALIDATION.md` §V.1.4 (a definir).

Verificações mínimas:
- `readlink ~/.codeflow` retorna `~/Projetos/codeflow` (ou equivalente absoluto).
- `ls ~/.codeflow/andaime/SPEC.md` lista o arquivo com sucesso (symlink funciona).
- Nenhuma cópia paralela de conteúdo do framework existe fora de `~/Projetos/codeflow/`.

**Gate de progressão:** symlink funciona; `~/.codeflow/` é acessível e aponta para o repositório de trabalho.

**Commit sugerido:** nenhum (symlink não é parte do repositório; é configuração de ambiente). Registrar no log de execução com nota explicativa.

---

### Fase 2 — Núcleo conceitual

A ordem dentro desta fase respeita dependência lexical: a constitution é a fonte primária, o glossary serve a tudo que vem depois, EVOLUTION define o processo de mudança subsequente, e as rules estendem temas específicos da constitution.

#### Etapa F2.1 — Constitution universal

**Objetivo:** criar `framework/core/constitution.md` no formato definido por `ARTIFACTS_SPEC.md` §1.1.

**Pré-requisitos:** F1.4 concluída.

**Ações:**
1. Ler `ARTIFACTS_SPEC.md` §1.1.1 a §1.1.7.
2. Aplicar o template literal do bloco §1.1.5 como base.
3. Escrever conteúdo conforme `SPEC.md` §4.1.1 e §8.3, com **5 seções `##` na ordem fixa** (ver `ARTIFACTS_SPEC.md` §1.1.3):
   - **`## Princípios invariantes`**: **exatamente 4 princípios** — (a) diff mínimo; (b) declaração de escopo antes de modificar; (c) seguir convenções existentes; (d) comentários só registram "por quê" não-óbvio — mais um bullet final tratando de mudanças quebradoras.
   - **`## Política de falhas`**: as quatro categorias (transitória, lógica, escopo, ambiente) com tratamento de cada uma. **Não** contém o bloco PARADO (vive em seção separada).
   - **`## Formato PARADO`**: o formato literal de aborto, em seção independente.
   - **`## Proibições absolutas`**: alinhadas a `SPEC.md` §8.3 (framework alheio na raiz; configs globais; secrets/`.env`; pastas marcadas como protegidas).
   - **`## Quando esta constitution se aplica`**: escopo de carregamento e relação com a constitution de projeto (estende, não substitui).
   - **`## Definition of Done padrão`** **não** entra aqui. Definition of Done é responsabilidade de cada workflow.
4. Salvar em `framework/core/constitution.md`.
5. Remover `.gitkeep` de `framework/core/` (já tem conteúdo significativo).

**Validação:** `VALIDATION.md` §V.2.1, aplicando as 10 regras de `ARTIFACTS_SPEC.md` §1.1.6.

**Gate de progressão:** constitution passa nas 10 regras de `ARTIFACTS_SPEC.md` §1.1.6 e nas regras transversais da Parte 3 do mesmo documento.

**Commit sugerido:** `feat(core): adiciona constitution universal`.

---

#### Etapa F2.2 — Glossary

**Objetivo:** criar `framework/core/glossary.md` no formato definido por `ARTIFACTS_SPEC.md` §1.2.

**Pré-requisitos:** F2.1 concluída.

**Ações:**
1. Ler `ARTIFACTS_SPEC.md` §1.2.1 a §1.2.7.
2. Conforme `ARTIFACTS_SPEC.md` §1.2.3, incluir:
   - **12 termos centrais**, em **ordem alfabética pt-BR**: Agent, Artefato, Checkpoint, Constitution, Decision, Discovered, INDEX, Manifest, Meta-skill, Rule, Skill, Workflow.
   - **4 distinções** explícitas: Workflow vs Skill; Agent vs Skill; Rule vs Constitution; Decision vs Checkpoint.
   - **1 termo com colisão** (Agent): definição com nota de colisão com termo usado por Cursor/Claude Code.
3. Título do arquivo: `# Glossário do codeflow` (com acento — pt-BR).
4. Cada definição: duas a quatro linhas, sem hedges, sem auto-referência (regra de não-circularidade da §1.2.7).
5. Salvar em `framework/core/glossary.md`.

**Validação:** `VALIDATION.md` §V.2.2, aplicando as 10 regras de `ARTIFACTS_SPEC.md` §1.2.6.

**Gate de progressão:** glossary tem todos os 12 termos centrais (em ordem alfabética), 4 distinções, definição de Agent com nota de colisão. Nenhuma definição é circular.

**Commit sugerido:** `feat(core): adiciona glossary universal`.

---

#### Etapa F2.3 — EVOLUTION

**Objetivo:** criar `framework/core/EVOLUTION.md` no formato definido por `ARTIFACTS_SPEC.md` §1.3.

**Pré-requisitos:** F2.2 concluída.

**Ações:**
1. Ler `ARTIFACTS_SPEC.md` §1.3.1 a §1.3.7.
2. Aplicar a estrutura de cinco seções literais conforme `SPEC.md` §6.3:
   - `## Promoção (skill/workflow de projeto → universal)`
   - `## Adição de rule`
   - `## Adição de meta-skill`
   - `## Mudança em arquivo do core (constitution, glossary, EVOLUTION)`
   - `## Anti-evolução`
3. Cada seção inclui: condições objetivas para a mudança ser permitida, processo passo a passo, e exemplos do que **não** justifica a mudança.
4. Critérios canônicos — **separados e independentes**:
   - **Promoção de skill ou workflow específico para universal:** uso real em **dois projetos distintos** (sem prazo mínimo associado a esta promoção). Operacionalmente: `git mv` do arquivo, bump de versão **minor**.
   - **Mudança em arquivo do core (constitution, glossary, EVOLUTION):** **período de transição de 30 dias** entre proposta documentada e adoção efetiva. Bump de versão **major**.
   - Os dois critérios são distintos; não combinar em uma única regra.
5. Salvar em `framework/core/EVOLUTION.md`.

**Validação:** `VALIDATION.md` §V.2.3, aplicando as 10 regras de `ARTIFACTS_SPEC.md` §1.3.6.

**Gate de progressão:** EVOLUTION tem as cinco seções literais. Critérios objetivos aparecem como strings exatas: `dois projetos distintos`, `30 dias`, `git mv`, `bump minor`, `bump major`.

**Commit sugerido:** `feat(core): adiciona política de evolução`.

---

#### Etapa F2.4 — Quatro rules seed

**Objetivo:** criar os quatro rules seed em `framework/core/rules/`: `code-quality.md`, `testing.md`, `security.md`, `naming.md`.

**Pré-requisitos:** F2.3 concluída.

**Ações:**
1. Ler `ARTIFACTS_SPEC.md` §1.4.1 a §1.4.7.
2. Para cada um dos quatro temas (`code-quality`, `testing`, `security`, `naming`), criar arquivo `framework/core/rules/<tema>.md` aplicando:
   - Frontmatter com campos universais + `escopo: universal`.
   - Cinco seções fixas: `# Rule: <tema>`, `## Quando carregar`, `## Regras`, `## Anti-regras`, `## Exceções`.
   - Pelo menos três regras em `## Regras`.
   - Pelo menos uma anti-regra para cada regra (paridade).
   - Pelo menos uma exceção declarada, ou texto literal `Nenhuma.`.
3. Todos os quatro arquivos universais — sem referência a stack específica.
4. Remover `.gitkeep` de `framework/core/rules/`.

**Conteúdo canônico das rules seed (vinculante; o construtor tem liberdade apenas de redação):**

- **`code-quality.md`**: diff mínimo, funções pequenas, nomes expressivos, ausência de duplicação descontrolada.
- **`testing.md`**: todo código novo tem teste; bugfix tem teste de regressão; teste descreve comportamento; teste é determinístico (já tem exemplo realista em `ARTIFACTS_SPEC.md` §1.4.5).
- **`security.md`**: validação de input; secrets não vão para git; tratamento de auth; tratamento de dependências externas com cautela.
- **`naming.md`**: nomes em inglês para código; nomes pt-BR para mensagens ao usuário; consistência com convenções da linguagem da stack.

F2.4 **não** depende de aprovação caso a caso do mantenedor sobre cada rule — adotar estes temas e cobertura como dados; revisão é feita após escrita.

**Validação:** `VALIDATION.md` §V.2.4, aplicando as 10 regras de `ARTIFACTS_SPEC.md` §1.4.6 a cada um dos quatro arquivos.

**Gate de progressão:** quatro arquivos presentes, cada um passando individualmente nas regras de validação.

**Commit sugerido:** `feat(rules): adiciona quatro rules seed`.

---

### Fase 3 — Biblioteca

Skills antes de workflows: workflows fazem referência a skills via `## LEIA TAMBÉM`. Se workflows são escritos antes das skills existirem, ficam apontando para arquivos ausentes — ruído e risco de drift.

#### Etapa F3.1 — Três skills seed

**Objetivo:** criar três skills universais seed em `framework/library/skills/`: `debug-protocol`, `handoff`, `self-review`. Cada uma como pasta contendo `SKILL.md`.

**Pré-requisitos:** F2.4 concluída.

**Ações:**
1. Ler `ARTIFACTS_SPEC.md` §1.8.1 a §1.8.7.
2. Para cada skill, criar `framework/library/skills/<nome>/SKILL.md` aplicando:
   - Frontmatter com campos universais + `descrição` (uma linha).
   - Seis seções fixas: `# Skill: <nome>`, `## Quando usar`, `## Princípio guia`, `## Protocolo`, `## Proibições durante esta skill`, `## Saídas válidas`.
   - **Sem** `## Definition of Done` (vedado em skill, §1.8.6 regra 5).
   - **Sem** `## LEIA TAMBÉM` (vedado em skill, §1.8.6 regra 6).
3. Conteúdo:
   - **`debug-protocol/SKILL.md`**: aplicar exatamente o exemplo realista de `ARTIFACTS_SPEC.md` §1.8.5 (protocolo anti-loop, uma hipótese por vez, limite de três tentativas).
   - **`handoff/SKILL.md`**: protocolo para transferir contexto entre sessões — quando preparar handoff, formato fixo de saída, o que incluir e o que excluir.
   - **`self-review/SKILL.md`**: protocolo para a IA revisar seu próprio diff antes de apresentar — checklist mínimo, perguntas a fazer ao próprio diff, sinais de alerta.
4. Remover `.gitkeep` de cada pasta de skill após criação do `SKILL.md`.

**Validação:** `VALIDATION.md` §V.3.1, aplicando as 10 regras de `ARTIFACTS_SPEC.md` §1.8.6 a cada um dos três arquivos.

**Gate de progressão:** três pastas presentes, cada uma com `SKILL.md` passando individualmente nas regras de validação. Nenhuma skill referencia outra skill (anti-padrão §1.8.7).

**Commit sugerido:** `feat(skills): adiciona três skills seed (debug-protocol, handoff, self-review)`.

---

#### Etapa F3.2 — Quatro workflows seed

**Objetivo:** criar os quatro workflows universais seed em `framework/library/workflows/`: `review-only`, `bugfix`, `feature-small`, `refactor-safe`.

**Pré-requisitos:** F3.1 concluída.

**Ações:**
1. Ler `ARTIFACTS_SPEC.md` §1.5 (magros), §1.6 (médios) — workflows detalhados não entram nesta etapa.
2. Para cada workflow, criar `framework/library/workflows/<nome>.md` aplicando:
   - Frontmatter com campos universais + `granularidade`, `gera_decision`, `usa_checkpoints`, `politica_falhas`.
   - Seções fixas conforme granularidade.
   - `## LEIA TAMBÉM` com as quatro entradas obrigatórias (constitution universal, INDEX, constitution de projeto, manifest) mais skills e rules relevantes.

**Classificação por granularidade:**

| Workflow         | Granularidade | gera_decision | Justificativa                                                 |
|------------------|---------------|---------------|---------------------------------------------------------------|
| `review-only`    | magro         | no            | Sem modificação de arquivos; sem decisões intermediárias.     |
| `bugfix`         | médio         | auto          | Decisão se registra ou não depende da natureza do bug.        |
| `feature-small`  | médio         | auto          | Features triviais não precisam de decision; outras precisam.  |
| `refactor-safe`  | médio         | no            | Refactor preserva comportamento; não há decisão arquitetural.  |

**Conteúdo de referência:**

- **`review-only.md`**: usar exemplo realista de `ARTIFACTS_SPEC.md` §1.5.5 como base.
- **`bugfix.md`**: usar exemplo realista de `ARTIFACTS_SPEC.md` §1.6.5 como base.
- **`feature-small.md`** — esqueleto de passos **canônico** (vinculante; o construtor tem liberdade apenas de redação): 1) Confirmar escopo; 2) Desenhar interface; 3) Implementar; 4) Testar; 5) Validar; 6) Resumir.
- **`refactor-safe.md`** — esqueleto de passos **canônico** (vinculante; o construtor tem liberdade apenas de redação): 1) Snapshot de testes existentes; 2) Identificar refatoração; 3) Aplicar mudança; 4) Confirmar testes passam idênticos; 5) Validar; 6) Resumir.

3. Remover `.gitkeep` de `framework/library/workflows/`.

**Validação:** `VALIDATION.md` §V.3.2, aplicando as 10 regras de `ARTIFACTS_SPEC.md` §1.5.6 (magro) ou §1.6.6 (médios) conforme granularidade de cada workflow.

**Gate de progressão:** quatro arquivos presentes, cada um passando nas regras de validação correspondentes à sua granularidade. Todas as referências em `## LEIA TAMBÉM` apontam para arquivos que existem em `framework/core/` ou `framework/library/skills/` (criados nas etapas F2.1–F2.4 e F3.1).

**Commit sugerido:** `feat(workflows): adiciona quatro workflows seed`.

---

#### Etapa F3.3 — Manter `framework/library/agents/` vazio

**Objetivo:** confirmar explicitamente que nenhum agent seed é entregue no escopo inicial, conforme `SPEC.md` §4.5.4 e `ARTIFACTS_SPEC.md` §1.10.1.

**Pré-requisitos:** F3.2 concluída.

**Ações:**
1. Verificar que `framework/library/agents/` existe e contém apenas `.gitkeep`.
2. Adicionar ao `.gitkeep` uma nota literal (ainda válida como arquivo vazio para git, mas o conteúdo serve como documentação): comentário de uma linha explicando "Agents são criados sob demanda via meta-skill `create-agent`. Nenhum agent seed entregue no escopo inicial."
3. Esta etapa não tem commit próprio — junta-se à etapa F3.2 ou à F4.1.

**Validação:** `VALIDATION.md` §V.3.3.

Verificação mínima:
- `ls framework/library/agents/` retorna apenas `.gitkeep` (eventualmente com a nota).

**Gate de progressão:** pasta presente, sem agents, decisão registrada.

**Commit sugerido:** consolidado em F3.2 ou F4.1.

---

### Fase 4 — Meta-skills

As cinco meta-skills do escopo inicial dividem-se em dois grupos por complexidade. Construir o grupo simples primeiro permite exercitar o template antes de enfrentar `discover` e `bootstrap`, que são detalhados e mais longos.

#### Etapa F4.1 — Três meta-skills `create-*`

**Objetivo:** criar `create-workflow`, `create-skill`, `create-agent` em `framework/meta/`. Estas são meta-skills de granularidade média.

**Pré-requisitos:** F3.3 concluída.

**Ações:**
1. Ler `ARTIFACTS_SPEC.md` §1.9.1 a §1.9.7.
2. Para cada uma, criar `framework/meta/<nome>/SKILL.md` aplicando:
   - Frontmatter com campos universais + `descrição`, `é_meta_skill: yes`, `granularidade: médio`.
   - Nove seções obrigatórias conforme §1.9.3.
   - As três seções exclusivas de meta-skill: `## Template de saída`, `## Onde salvar`, `## Validação pós-geração`.

**Conteúdo de referência:**

- **`create-workflow/SKILL.md`**: aplicar o exemplo realista de `ARTIFACTS_SPEC.md` §1.9.5.
- **`create-skill/SKILL.md`**: estrutura similar. Qualifica necessidade, determina escopo (universal vs projeto), gera arquivo conforme `ARTIFACTS_SPEC.md` §1.8. `## Template de saída` referencia §1.8.5; `## Validação pós-geração` referencia §1.8.6.
- **`create-agent/SKILL.md`**: qualifica necessidade (justificar isolamento, não apenas restrição), gera arquivo conforme `ARTIFACTS_SPEC.md` §1.10. `## Template de saída` referencia §1.10.5; `## Validação pós-geração` referencia §1.10.6. A meta-skill **recusa** criação se a tarefa pode ser realizada com skill regular.

3. Remover `.gitkeep` de cada pasta de meta-skill.

**Validação:** `VALIDATION.md` §V.4.1, aplicando as 10 regras de `ARTIFACTS_SPEC.md` §1.9.6 a cada uma das três meta-skills.

**Gate de progressão:** três pastas presentes, cada uma com `SKILL.md` passando individualmente nas regras de validação. Cada meta-skill referencia o ARTIFACTS_SPEC corretamente para o tipo de artefato que gera.

**Commit sugerido:** `feat(meta): adiciona três meta-skills create-*`.

---

#### Etapa F4.2 — Duas meta-skills `discover` e `bootstrap`

**Objetivo:** criar `discover` e `bootstrap` em `framework/meta/`. Estas são meta-skills de granularidade detalhada, com fases e checkpoints.

**Pré-requisitos:** F4.1 concluída.

**Ações:**
1. Ler `ARTIFACTS_SPEC.md` §1.9 novamente, atentando às adições para granularidade detalhada (presença de fases `### Fase N` em `## Protocolo` e opcionalmente seção `## Retomada`).
2. Criar `framework/meta/discover/SKILL.md`:
   - Frontmatter com `é_meta_skill: yes`, `granularidade: detalhado`.
   - Protocolo em quatro fases: **Inspeção** → **Entrevista qualificada** (orientação: até cinco perguntas, conforme `SPEC.md` §4.4.2; sem limite duro — aviso obrigatório ao chegar à 5ª, com vocabulário canônico para respostas de incerteza) → **Geração de constitution + manifest + INDEX** → **Geração de discovered.md + entrega**.
   - Pausa para confirmação do usuário entre Fase 2 e Fase 3.
   - `## Template de saída` referencia múltiplos templates: §2.2.5 (constitution), §2.3.5 (manifest), §2.1.5 (INDEX), §2.4.5 (discovered).
   - `## Validação pós-geração` referencia §2.1.6, §2.2.6, §2.3.6, §2.4.6 — cada artefato gerado tem seu conjunto de regras.
   - `## Onde salvar` declara: todos os artefatos vão para `<projeto>/.codeflow/`.
   - Seção opcional `## Retomada` declarando como detectar checkpoint existente e oferecer retomada.

3. Criar `framework/meta/bootstrap/SKILL.md`:
   - Frontmatter com `é_meta_skill: yes`, `granularidade: detalhado`.
   - Protocolo em cinco fases: **Coleta de requisitos** (perguntas sobre tipo de projeto, stack, propósito) → **Decisão de stack e estrutura** → **Geração de estrutura mínima do projeto** (Makefile com targets canônicos, gitignore, README esqueleto) → **Geração de artefatos do `.codeflow/`** (constitution, manifest, INDEX — mas **não** discovered, conforme `ARTIFACTS_SPEC.md` §2.4.1) → **Entrega e instruções de próximos passos**.
   - Pausa para confirmação em pelo menos duas fases (após coleta e antes de geração; entre estrutura do projeto e artefatos do `.codeflow/`).
   - `## Template de saída` referencia §2.1.5, §2.2.5, §2.3.5. **Não** referencia §2.4 — bootstrap não gera discovered.
   - `## Validação pós-geração` referencia §2.1.6, §2.2.6, §2.3.6.
   - `## Onde salvar` declara: artefatos do `.codeflow/` em `<projeto>/.codeflow/`; arquivos do projeto (Makefile, gitignore, README) em `<projeto>/`.
   - Seção opcional `## Retomada` (mesmo padrão de `discover`).

4. Remover `.gitkeep` de cada pasta de meta-skill.

**Validação:** `VALIDATION.md` §V.4.2, aplicando as 10 regras de `ARTIFACTS_SPEC.md` §1.9.6 a cada uma das duas meta-skills, mais verificação específica de granularidade detalhada (presença de fases, checkpoints, pausa para usuário).

**Gate de progressão:** duas pastas presentes, cada uma com `SKILL.md` passando nas regras. Cada meta-skill tem pelo menos três fases declaradas. Cada uma tem pelo menos uma pausa para o usuário documentada.

**Commit sugerido:** `feat(meta): adiciona meta-skills discover e bootstrap`.

---

### Fase 5 — Empacotamento e validação fim-a-fim

Esta fase fecha o framework: cria `install.sh`, escreve o README da raiz, integra `VALIDATION.md` e `PROMPTS.md` (gerados em paralelo) no andaime, e exercita os caminhos críticos em um projeto de teste.

#### Etapa F5.1 — Script `install.sh`

**Objetivo:** criar `install.sh` na raiz do framework conforme `SPEC.md` §3.9.

**Pré-requisitos:** F4.2 concluída.

**Ações:**
1. Ler `SPEC.md` §3.9 e §7 (decisões técnicas relacionadas a scripts) na íntegra.
2. Criar `~/Projetos/codeflow/install.sh` com as seguintes responsabilidades (conforme `SPEC.md` §3.9):
   - Verificar pré-requisitos:
     - `git` disponível.
     - `~/.codeflow/` existe (symlink ou diretório).
     - Diretório de execução é um repositório git inicializado (executar `git rev-parse --git-dir`; se falhar, abortar com instrução clara).
     - Makefile presente na raiz do projeto-alvo (apenas aviso se ausente, não bloqueia).
   - Criar estrutura `.codeflow/`:
     - `.codeflow/INDEX.md` (placeholder com texto literal `Placeholder. Rode /discover ou /bootstrap para gerar.`).
     - `.codeflow/decisions/`.
     - `.codeflow/checkpoints/`.
   - Adicionar `.codeflow/checkpoints/` ao `.gitignore` do projeto (criar `.gitignore` se ausente).
   - Imprimir mensagem com próximos passos: invocar `/discover` (projeto existente) ou `/bootstrap` (projeto novo).
3. Restrições do `install.sh` conforme `SPEC.md` §3.9 (anti-decisão):
   - **Não** modifica `CLAUDE.md`, `AGENTS.md`, `README.md`, ou qualquer arquivo na raiz do projeto-alvo.
   - **Não** cria `constitution.md`, `manifest.md`, `discovered.md` — esses dependem de conhecimento do projeto.
   - **Não** roda `git init`.
   - **Não** instala dependências, não baixa nada, não modifica nada fora de `.codeflow/`.
4. Saída do script:
   - Códigos de saída conforme `ARTIFACTS_SPEC.md` §0.7: `0` sucesso; `1` falha de regra (pré-requisito ausente); `2` erro de execução; `3` input inválido.
   - Símbolos de status conforme `ARTIFACTS_SPEC.md` §0.6: `✓`, `✗`, `⚠`.
5. Idempotência: rodar duas vezes não cria duplicatas, não sobrescreve sem confirmação (conforme `SPEC.md` §7).
6. `chmod +x install.sh`.

**Validação:** `VALIDATION.md` §V.5.1.

Verificações mínimas:
- `install.sh` executável.
- Roda sem erro em pasta de teste vazia + `git init`.
- Roda duas vezes consecutivas sem duplicar nem corromper.
- Não modifica arquivos fora de `.codeflow/`.
- `shellcheck install.sh` retorna sem erro (avisos podem ser tolerados, justificados).

**Gate de progressão:** `install.sh` executável, idempotente, passa em `shellcheck`, e em teste manual cria estrutura correta em pasta vazia.

**Commit sugerido:** `feat(install): adiciona script install.sh`.

---

#### Etapa F5.2 — README da raiz do framework

**Objetivo:** criar `~/Projetos/codeflow/README.md` como manual de uso de alto nível conforme `SPEC.md` §2.2.

**Pré-requisitos:** F5.1 concluída.

**Ações:**
1. Criar `README.md` na raiz contendo:
   - Título e descrição curta do codeflow (uma a três linhas).
   - Quando usar o codeflow (uma a duas frases).
   - Pré-requisitos: bash, git, Make (opcional mas recomendado).
   - Instalação em projeto-alvo: `cd <projeto> && bash ~/.codeflow/install.sh`.
   - Primeiros passos pós-instalação: `/discover` ou `/bootstrap`.
   - Estrutura do framework (referência a `andaime/SPEC.md` §2.2).
   - Ponteiros para documentação detalhada: `andaime/SPEC.md` (fonte da verdade), `andaime/ARTIFACTS_SPEC.md` (formato dos arquivos), `andaime/BUILD_PLAN.md` (como o framework foi construído).
   - Como evoluir o framework: ler `framework/core/EVOLUTION.md`.
   - Licença.
2. Tamanho-alvo: 40 a 80 linhas. README é introdução, não tutorial completo.
3. Linguagem: pt-BR, conforme `ARTIFACTS_SPEC.md` §0.4.

**Validação:** `VALIDATION.md` §V.5.2.

Verificações mínimas:
- README existe na raiz.
- Frontmatter universal presente.
- Tamanho dentro do alvo.
- Links internos para `andaime/` apontam para arquivos existentes.

**Gate de progressão:** README presente, dentro do alvo de tamanho, com referências internas válidas.

**Commit sugerido:** `docs(readme): adiciona README de raiz do framework`.

---

#### Etapa F5.3 — Integrar VALIDATION.md e PROMPTS.md ao andaime

**Objetivo:** quando `VALIDATION.md` e `PROMPTS.md` forem gerados pelos próximos passos do andaime (fora do escopo de execução do Claude Code, geralmente gerados pelo mantenedor com ajuda do agente), copiá-los para `~/Projetos/codeflow/andaime/`.

**Pré-requisitos:** F5.2 concluída. Arquivos `VALIDATION.md` e `PROMPTS.md` disponíveis no sistema do mantenedor (geração desses arquivos é responsabilidade fora do BUILD_PLAN).

**Ações:**
1. Copiar `VALIDATION.md` para `~/Projetos/codeflow/andaime/VALIDATION.md`.
2. Copiar `PROMPTS.md` para `~/Projetos/codeflow/andaime/PROMPTS.md`.
3. Atualizar `andaime/README.md` removendo a marcação de "pendente" desses dois documentos.
4. Commit: `docs(andaime): adiciona VALIDATION e PROMPTS`.

**Validação:** `VALIDATION.md` §V.5.3.

Verificações mínimas:
- Cinco arquivos do andaime presentes em `andaime/`: SPEC, ARTIFACTS_SPEC, BUILD_PLAN, VALIDATION, PROMPTS.
- `andaime/README.md` não menciona arquivos como pendentes.

**Gate de progressão:** andaime completo com cinco documentos. README atualizado.

**Commit sugerido:** `docs(andaime): adiciona VALIDATION e PROMPTS`.

---

#### Etapa F5.4 — Criar projeto de teste

**Objetivo:** criar um projeto-alvo minimalista em `/tmp/codeflow-test/` para exercitar `install.sh` e os meta-skills críticos. Caminho é fixo e vinculante.

**Pré-requisitos:** F5.3 concluída.

**Ações:**
1. Criar diretório: `mkdir -p /tmp/codeflow-test`.
2. Entrar e inicializar git: `cd /tmp/codeflow-test && git init`.
3. Criar Makefile minimalista com os quatro targets canônicos (`check`, `test`, `lint`, `typecheck`), cada um imprimindo "noop" e retornando 0. Suficiente para `install.sh` detectar.
4. Criar arquivo `README.md` curto no projeto de teste, para simular projeto realista.
5. Fazer commit inicial.

**Validação:** `VALIDATION.md` §V.5.4.

Verificações mínimas:
- Projeto de teste existe e é repositório git.
- Makefile presente com quatro targets canônicos.
- Working tree limpo.

**Gate de progressão:** projeto de teste pronto para receber `install.sh`.

**Commit sugerido:** nenhum no framework (projeto de teste é externo).

---

#### Etapa F5.5 — Executar `install.sh` no projeto de teste

**Objetivo:** rodar o instalador no projeto de teste e verificar que cria estrutura correta sem tocar em arquivos do projeto.

**Pré-requisitos:** F5.4 concluída.

**Ações:**
1. No projeto de teste, executar: `bash ~/.codeflow/install.sh`.
2. Inspecionar saída: deve listar verificações com símbolos `✓`/`⚠` e terminar com mensagem de próximos passos (`/discover` ou `/bootstrap`).
3. Verificar artefatos criados:
   - `.codeflow/INDEX.md` (placeholder).
   - `.codeflow/decisions/` (pasta).
   - `.codeflow/checkpoints/` (pasta).
   - `.gitignore` contém `.codeflow/checkpoints/`.
4. Verificar **não-modificação**: `git status` no projeto de teste mostra apenas `.codeflow/` e (eventualmente) `.gitignore` como novos. Nenhum outro arquivo modificado.
5. Executar `install.sh` uma segunda vez: deve detectar instalação existente e não duplicar nem corromper.

**Validação:** `VALIDATION.md` §V.5.5.

Verificações mínimas:
- Estrutura `.codeflow/` criada conforme `SPEC.md` §3.9.
- `.gitignore` atualizado.
- Nenhum arquivo fora de `.codeflow/` e `.gitignore` modificado.
- Segunda execução é idempotente.

**Gate de progressão:** `install.sh` exercitado com sucesso em projeto de teste, atendendo todas as restrições de `SPEC.md` §3.9.

**Commit sugerido:** nenhum no framework (validação operacional).

---

#### Etapa F5.6 — Exercitar `discover` (simulado) no projeto de teste

**Objetivo:** validar que `framework/meta/discover/SKILL.md` é executável conceitualmente — a IA, lendo o `SKILL.md`, consegue executar o protocolo e gerar os artefatos previstos. Esta etapa não exige ferramenta de IA real; pode ser feita manualmente pelo mantenedor seguindo o protocolo da meta-skill como roteiro.

**Pré-requisitos:** F5.5 concluída.

**Ações:**
1. Ler `framework/meta/discover/SKILL.md` na íntegra.
2. Seguir o protocolo da meta-skill aplicado ao projeto de teste:
   - Fase 1 — Inspeção: examinar Makefile, README, estrutura mínima do projeto de teste.
   - Fase 2 — Entrevista qualificada: como o projeto de teste é minimalista, registrar respostas óbvias.
   - Fase 3 — Geração: criar `.codeflow/constitution.md`, `.codeflow/manifest.md`, atualizar `.codeflow/INDEX.md` (substituindo o placeholder).
   - Fase 4 — Geração de `.codeflow/discovered.md` e entrega.
3. Para cada arquivo gerado, aplicar as regras correspondentes de `ARTIFACTS_SPEC.md`: §2.1.6 (INDEX), §2.2.6 (constitution), §2.3.6 (manifest), §2.4.6 (discovered).
4. Se algum arquivo gerado falha em validação, isso indica problema no `SKILL.md` da meta-skill `discover`, não no exercício. Corrigir a meta-skill e repetir.

**Validação:** `VALIDATION.md` §V.5.6.

Verificações mínimas:
- Quatro artefatos gerados: INDEX, constitution, manifest, discovered.
- Cada um passa nas regras de validação correspondentes.
- INDEX substituiu o placeholder corretamente.

**Gate de progressão:** `discover` exercitado, quatro artefatos gerados e validados em projeto de teste.

**Commit sugerido:** nenhum no framework. Se houve correção na meta-skill, commit dessa correção: `fix(meta/discover): corrige <descrição da correção>`.

---

#### Etapa F5.7 — Documentar wiring de slash commands em SPEC e ARTIFACTS_SPEC

**Objetivo:** fechar o gap entre a decisão arquitetural de `SPEC.md` §3.6 (workflows via slash commands) e a implementação concreta. Amendar `SPEC.md` §3.6 com seção "Implementação", e acrescentar schema do wrapper em `ARTIFACTS_SPEC.md`.

**Pré-requisitos:** F5.6 concluída.

**Ações:**
1. Editar `SPEC.md` §3.6 acrescentando subseção **"3.6.1 Implementação em Claude Code"** documentando:
   - Mecanismo: wrappers em `~/.claude/commands/<nome>.md` (universal) e `<projeto>/.claude/commands/<nome>.md` (projeto).
   - Mapeamento: nome do arquivo do workflow ↔ nome do slash command ↔ nome do wrapper.
   - Conteúdo do wrapper: 2-4 linhas em pt-BR instruindo a IA a ler o arquivo real e executar o protocolo, carregando `## LEIA TAMBÉM`.
   - Ferramenta de setup universal: `setup-slash-commands.sh` na raiz do framework (F5.8).
   - Ferramenta de setup de projeto: estendida em `install.sh` (F5.9).
   - Adapter para outras ferramentas (Codex, Cursor): mecanismo análogo, fora do escopo da v1.0.0.
2. Editar `ARTIFACTS_SPEC.md` acrescentando nova subseção **§1.11 Wrappers de slash command** com:
   - Localização (`~/.claude/commands/<nome>.md` ou `<projeto>/.claude/commands/<nome>.md`).
   - Schema mínimo (sem frontmatter obrigatório; corpo: 2-4 linhas).
   - Exemplo preenchido para `/bugfix`.
   - Regras de validação (uma única referência a path absoluto do workflow/meta-skill correspondente).
   - Anti-padrão: duplicar conteúdo do workflow no wrapper.
3. Atualizar glossário (`framework/core/glossary.md`) acrescentando termo **Wrapper** se ainda não houver — definição curta (2-4 linhas) referenciando SPEC §3.6.1.

**Validação:** `VALIDATION.md` §V.5.7.

Verificações mínimas:
- `SPEC.md` §3.6.1 presente, com as cinco subsubseções listadas (mecanismo, mapeamento, conteúdo, setup universal, setup de projeto).
- `ARTIFACTS_SPEC.md` §3.9 presente com schema e exemplo.
- `framework/core/glossary.md` contém entrada "Wrapper" (ou justificativa documentada para omissão).

**Gate de progressão:** wiring documentado tanto como decisão (SPEC §3.6.1) quanto como artefato (ARTIFACTS_SPEC §3.9).

**Commit sugerido:** `docs(spec): documenta wiring de slash commands (§3.6.1 + §3.9)`.

---

#### Etapa F5.8 — Criar `setup-slash-commands.sh` e auto-sync em meta-skills

**Objetivo:** entregar o script que materializa o wiring universal documentado em F5.7, e embutir auto-sync nas meta-skills que criam workflows.

**Pré-requisitos:** F5.7 concluída.

**Ações:**
1. Criar `~/Projetos/codeflow/setup-slash-commands.sh` (bash, executável) com responsabilidades:
   - Verificar pré-requisitos: `~/.codeflow/` existe; `~/.claude/commands/` existe (criar se ausente).
   - Listar workflows universais em `~/.codeflow/framework/library/workflows/*.md`.
   - Listar meta-skills em `~/.codeflow/framework/meta/*/SKILL.md` (apenas as que devem ter slash command — todas as cinco seed, conforme SPEC §4.4).
   - Para cada workflow/meta-skill, gerar (ou recriar idempotentemente) `~/.claude/commands/<nome>.md` no formato definido por `ARTIFACTS_SPEC.md` §3.9.
   - Detectar wrappers órfãos em `~/.claude/commands/` que apontam para arquivos do codeflow inexistentes; remover com confirmação (ou via flag `--prune`).
   - Imprimir resumo em pt-BR com símbolos `✓`/`⚠`/`✗` (criados, preservados, removidos, erros).
2. Restrições análogas a `install.sh` (`SPEC.md` §3.9):
   - Não modificar nada além de `~/.claude/commands/`.
   - Não tocar em arquivos do framework (`~/.codeflow/framework/`) — só lê.
   - Stack permitida: bash + coreutils.
3. Códigos de saída e símbolos conforme `ARTIFACTS_SPEC.md` §0.6 e §0.7.
4. Atualizar `framework/meta/create-workflow/SKILL.md` acrescentando passo final no protocolo:
   - "Se o workflow gerado é universal, executar `bash ~/.codeflow/setup-slash-commands.sh` ao final para registrar o slash command. Se é de projeto, o `install.sh` já cuida na próxima vez que rodar (ou pode-se rodar manualmente em `<projeto>/`)."
5. Atualizar `framework/meta/create-skill/SKILL.md` e `framework/meta/create-agent/SKILL.md` apenas com nota informativa: skills regulares não ganham slash command (carregadas via `LEIA TAMBÉM`); agents também não (invocados por workflows).
6. `chmod +x setup-slash-commands.sh`.

**Validação:** `VALIDATION.md` §V.5.8.

Verificações mínimas:
- `setup-slash-commands.sh` executável.
- Roda sem erro com framework instalado.
- Wrapper criado para cada workflow universal e cada meta-skill seed.
- Segunda execução é idempotente.
- `create-workflow/SKILL.md` referencia `setup-slash-commands.sh` no protocolo.

**Gate de progressão:** script executável, idempotente, com wrappers gerados para todos os workflows e meta-skills seed; meta-skill `create-workflow` atualizada.

**Commit sugerido:** `feat(install): adiciona setup-slash-commands.sh + auto-sync em create-workflow`.

---

#### Etapa F5.9 — Estender `install.sh` para slash commands de projeto + atualizar ROTEIRO

**Objetivo:** garantir que workflows e skills criados a nível de projeto (`<projeto>/.codeflow/workflows/`) ganhem slash commands locais automaticamente via `install.sh` do projeto. Atualizar `andaime/tests/ROTEIRO.md` para incluir verificação de slash commands.

**Pré-requisitos:** F5.8 concluída.

**Ações:**
1. Editar `~/Projetos/codeflow/install.sh` acrescentando bloco que, após criar `.codeflow/`:
   - Se `<projeto>/.codeflow/workflows/` existe e não está vazia, gera wrappers correspondentes em `<projeto>/.claude/commands/<nome>.md` (criar diretório se ausente).
   - Análogo opcional para `<projeto>/.codeflow/skills/`: apenas se houver skill com flag explícita de slash command (skills regulares **não** ganham; mantém disciplina do SPEC §4.3).
   - Idempotente: wrappers existentes não são duplicados; órfãos podem ser ignorados (não remover automaticamente a nível de projeto — projetos compartilhados podem ter wrappers de outros mantenedores).
   - Adicionar `.claude/commands/` ao `.gitignore` do projeto **apenas se o projeto não versionar `.codeflow/`** (caso a caso — opção segura: não adicionar; deixar mantenedor decidir).
2. Atualizar `andaime/tests/ROTEIRO.md`:
   - Acrescentar **Teste 1.5 — Verificar slash commands universais**: após Teste 1 (install.sh), o usuário roda `bash ~/.codeflow/setup-slash-commands.sh` e verifica que `/bugfix`, `/discover` aparecem no Claude Code.
   - Acrescentar verificação no Teste 4 (`create-skill`) de que skill de projeto **não** gera slash command (validar comportamento).
   - Acrescentar **Teste 7 (opcional) — Workflow de projeto com slash command**: criar workflow de projeto via `/create-workflow`, rodar `install.sh` novamente, verificar que slash command local aparece.

**Validação:** `VALIDATION.md` §V.5.9.

Verificações mínimas:
- `install.sh` contém bloco de sync de slash commands de projeto.
- `install.sh` continua idempotente (rodar duas vezes não duplica nada).
- `install.sh` continua respeitando anti-decisão SPEC §3.9 (não tocar em arquivos do projeto fora de `.codeflow/`, `.gitignore` e agora `.claude/commands/`).
- `andaime/tests/ROTEIRO.md` contém os novos testes 1.5 e 7.

**Gate de progressão:** `install.sh` estendido, idempotente, com restrições preservadas; ROTEIRO ampliado.

**Commit sugerido:** `feat(install): sincroniza slash commands de projeto + atualiza ROTEIRO`.

---

#### Etapa F5.10 — Limpeza, log de execução e tag de versão

**Objetivo:** consolidar a construção: deletar projeto de teste, finalizar log de execução, criar tag git inicial.

**Pré-requisitos:** F5.9 concluída.

**Ações:**
1. **Decidir** sobre o projeto de teste:
   - Opção A (recomendada): deletar `/tmp/codeflow-test/`. Foi temporário.
   - Opção B: arquivar como exemplo de saída esperada em `~/Projetos/codeflow/exemplos/projeto-teste/`. Requer decisão registrada (não é parte do framework canônico, mas pode ser útil para futura referência).
2. Finalizar `~/Projetos/codeflow/andaime/EXECUTION_LOG.md` (**obrigatório**; criado em F1.1 e atualizado a cada etapa concluída ao longo do build). Conteúdo final: data de início, data de conclusão, etapa por etapa com status `[✓]`/`[—]`/`⚠`, e notas sobre decisões tomadas durante a execução.
3. Criar tag git: `git tag -a v1.0.0 -m "Framework codeflow v1.0.0 — escopo inicial"`.
4. Push do repositório para remoto (se configurado).

**Validação:** `VALIDATION.md` §V.5.10.

Verificações mínimas:
- Tag `v1.0.0` presente: `git tag -l v1.0.0` retorna a tag.
- Working tree limpo.
- **Pelo menos um commit por etapa que declara `Commit sugerido` não-vazio** (≈17 commits, incluindo as 3 etapas novas F5.7-F5.9) presente antes da tag `v1.0.0`. A contagem exata depende de quantas etapas justificam commit próprio na execução real; o critério é qualitativo (toda etapa com commit sugerido tem ao menos um commit correspondente), não numérico.
- EXECUTION_LOG.md presente, versionado, e finalizado.

**Gate de progressão:** repositório do framework em estado entregável; tag de versão criada; nenhuma pendência.

**Commit sugerido:** `chore(release): tag v1.0.0 — escopo inicial completo` (ou apenas a tag, sem commit adicional).

---

---

## Parte 3 — Protocolo de retomada

A construção do framework pode ser interrompida por motivos diversos: sessão da IA encerrada, limite de contexto, intervenção manual do mantenedor, falha de validação que exige investigação fora do BUILD_PLAN. Esta parte define como retomar sem ambiguidade.

### 3.1 Princípios

- **Estado autoritativo é o disco**, não a memória da sessão. Toda retomada começa por inspecionar o estado real do repositório do framework.
- **Em dúvida, parar e perguntar.** Adivinhar o ponto de retomada gera regressão pior que esperar confirmação.
- **Nunca refazer etapa concluída.** Reexecutar etapa idempotente é desperdício; reexecutar etapa não-idempotente é perigoso.

### 3.2 Inspeção inicial de estado

Ao retomar, o Claude Code executa esta sequência **antes de tocar em qualquer arquivo**:

1. Verificar que `~/.codeflow/` existe e aponta para `~/Projetos/codeflow/`:
   ```
   readlink ~/.codeflow
   ```
   Se ausente ou aponta para outro lugar, problema é anterior à F1.4 — escalar ao mantenedor.

2. Listar commits do repositório:
   ```
   git -C ~/Projetos/codeflow log --oneline
   ```

3. Listar conteúdo do framework por pasta:
   ```
   find ~/.codeflow/framework -type f -name '*.md' | sort
   find ~/.codeflow/framework -type f -name '*.sh' | sort
   find ~/.codeflow/andaime -type f | sort
   ```

4. Verificar working tree:
   ```
   git -C ~/Projetos/codeflow status
   ```
   Working tree sujo (modificações não commitadas) indica etapa interrompida em meio à execução. Resolver antes de avançar.

### 3.3 Mapa de "qual arquivo indica qual etapa concluída"

A presença e o estado dos arquivos abaixo é o critério canônico para considerar cada etapa concluída. Se um arquivo está presente e passa nas regras de validação de seu tipo, a etapa correspondente está concluída.

| Etapa | Arquivos-prova                                                                |
|-------|-------------------------------------------------------------------------------|
| F1.1  | `~/Projetos/codeflow/.git/`, `~/Projetos/codeflow/.gitignore`                 |
| F1.2  | Pastas conforme `SPEC.md` §2.2, cada uma com `.gitkeep`                       |
| F1.3  | `andaime/SPEC.md`, `andaime/ARTIFACTS_SPEC.md`, `andaime/BUILD_PLAN.md`, `andaime/README.md` |
| F1.4  | `readlink ~/.codeflow` retorna o caminho do repositório                       |
| F2.1  | `framework/core/constitution.md` validado conforme §1.1.6                     |
| F2.2  | `framework/core/glossary.md` validado conforme §1.2.6                         |
| F2.3  | `framework/core/EVOLUTION.md` validado conforme §1.3.6                        |
| F2.4  | Quatro arquivos em `framework/core/rules/` validados conforme §1.4.6          |
| F3.1  | Três `SKILL.md` em `framework/library/skills/`, validados conforme §1.8.6     |
| F3.2  | Quatro `.md` em `framework/library/workflows/`, validados conforme §1.5.6/§1.6.6 |
| F3.3  | `framework/library/agents/` contém apenas `.gitkeep`                          |
| F4.1  | Três `SKILL.md` em `framework/meta/{create-workflow,create-skill,create-agent}/` validados conforme §1.9.6 |
| F4.2  | Dois `SKILL.md` em `framework/meta/{discover,bootstrap}/` validados conforme §1.9.6 |
| F5.1  | `~/Projetos/codeflow/install.sh` executável, passa em `shellcheck`            |
| F5.2  | `~/Projetos/codeflow/README.md` presente e validado                           |
| F5.3  | `andaime/VALIDATION.md` e `andaime/PROMPTS.md` presentes                      |
| F5.4  | Projeto de teste presente (caminho declarado no log de execução)              |
| F5.5  | `.codeflow/` criado no projeto de teste, sem outros arquivos modificados      |
| F5.6  | Quatro artefatos gerados no `.codeflow/` do projeto de teste, validados      |
| F5.7  | `SPEC.md` §3.6.1 e `ARTIFACTS_SPEC.md` §1.11 presentes; glossary com "Wrapper" |
| F5.8  | `~/Projetos/codeflow/setup-slash-commands.sh` executável e idempotente; `create-workflow/SKILL.md` referencia o script |
| F5.9  | `install.sh` sincroniza `.codeflow/workflows/` em `.claude/commands/` do projeto; `andaime/tests/ROTEIRO.md` com Teste 1.5 e Teste 7 |
| F5.10 | Tag `v1.0.0` presente no repositório                                          |

### 3.4 Decisão de próxima etapa

Após inspeção (3.2) e cruzamento com a tabela (3.3), o Claude Code identifica a **última etapa concluída**. A próxima etapa a executar é a imediatamente subsequente, conforme numeração `F<fase>.<etapa>`.

Casos especiais:

- **Salto inexplicado:** se a etapa N+1 parece concluída mas a etapa N não, isto é inconsistência. Parar e perguntar ao mantenedor antes de prosseguir. Possível causa: execução manual fora de ordem; possível solução: registrar no log e seguir, ou voltar e completar N.
- **Etapa parcialmente concluída:** arquivo existe mas falha em validação. Tratar como pendente (etapa não concluída); refazer a partir das ações.
- **Working tree sujo no início:** verificar com `git diff`. Se as mudanças correspondem à etapa em execução, completar (testar e commitar). Se as mudanças são desconhecidas (não fazem parte de nenhuma etapa do BUILD_PLAN), parar e perguntar ao mantenedor.

### 3.5 Reportar antes de retomar

Antes de executar a próxima etapa, o Claude Code reporta ao mantenedor:

- Estado detectado (resumo da inspeção em 3.2).
- Última etapa identificada como concluída.
- Próxima etapa a executar.
- Quaisquer inconsistências detectadas (3.4 — casos especiais).

Aguardar confirmação explícita do mantenedor antes de prosseguir, exceto quando o mantenedor declarou previamente que retomadas devem ser automáticas.

### 3.6 Política de falhas durante retomada

Mesma da §0.5: falha de validação em etapa em execução interrompe a retomada imediatamente, formato PARADO é aplicado, próxima ação aguarda decisão do mantenedor.

---

## Fim do BUILD_PLAN.md
