---
versão: 1.1
status: estável
atualizado: 2026-05-20
---

# PROMPTS.md — Prompts prontos por etapa de construção

Este documento é o quinto e último do andaime (`SPEC.md`, `ARTIFACTS_SPEC.md`, `BUILD_PLAN.md`, `VALIDATION.md`, **`PROMPTS.md`**). Sua função é entregar **prompts prontos para copiar e colar** no Claude Code (ou ferramenta de IA equivalente), um para cada etapa de `BUILD_PLAN.md`.

Cada prompt é autocontido: pode ser executado em sessão nova, sem dependência de prompts anteriores. Não há "prompt zero" de inicialização — esta decisão foi deliberada (ver §0.4).

## Parte 0 — Convenções

### 0.1 Estrutura fixa de cada prompt

Todo prompt segue **seis seções idênticas, na mesma ordem**, sem variação. A previsibilidade da estrutura é o que torna a execução assertiva: a IA aprende a estrutura no primeiro prompt e a aplica sem reinterpretar nos seguintes.

```
## Objetivo
[uma linha declarando o que a etapa entrega]

## Pré-leitura obrigatória
[lista de âncoras §X.Y específicas dos documentos do andaime]

## Tarefa
[instrução imperativa em 3 a 7 passos numerados]

## Critério de sucesso
[referência exata à seção do VALIDATION.md]

## Em caso de ambiguidade
[ações específicas, não "use bom senso"]

## Saída esperada
[o que apresentar ao mantenedor ao final]
```

Não modificar a estrutura. Cada seção sempre presente, mesmo que seja para registrar `Nenhuma.`.

### 0.2 Três comportamentos de fundo aplicáveis a todos os prompts

Estes três comportamentos são **invariantes** para toda execução. Não repetidos em cada prompt — assumidos como base. Se o Claude Code não os respeita, parar e reportar.

1. **Verificar pré-requisitos no disco antes de gerar.** Antes de criar qualquer arquivo, a IA confirma que os arquivos esperados pelas etapas anteriores existem. Se não existem, a IA não procede — interrompe e reporta ao mantenedor que a etapa anterior não foi cumprida.

2. **Validar antes de apresentar.** Após criar o(s) arquivo(s) da etapa, a IA executa os snippets do `VALIDATION.md` correspondentes (a seção indicada em **Critério de sucesso**). Apenas após todos passarem (e os itens de inspeção marcáveis terem sido marcados), a IA apresenta o resultado ao mantenedor para aprovação.

3. **Em ambiguidade, parar.** Quando o `BUILD_PLAN.md` ou o `ARTIFACTS_SPEC.md` deixam algo genuinamente aberto (ex: redação exata de um princípio, escolha entre duas formulações equivalentes), a IA não escolhe baseado em "boas práticas". Pergunta ao mantenedor. Esta é a regra mais importante e a mais comumente violada por IAs em modo "ajudar". Note: contagens explícitas (4 princípios invariantes, 12 termos no glossary, 4 distinções) **não** são ambiguidade — são vinculantes.

### 0.3 Como invocar um prompt

1. Abrir a etapa correspondente no `BUILD_PLAN.md` (ex: F2.1 — Constitution universal).
2. Localizar o prompt correspondente neste documento (ex: §P.2.1).
3. Copiar o **bloco de código markdown completo** (entre as cercas ```` ``` ````).
4. Colar no Claude Code como mensagem inicial da etapa.
5. Acompanhar a execução: a IA deve seguir os três comportamentos de fundo (§0.2). Intervir se desviar.

### 0.4 Por que não há "prompt zero" de inicialização

Considerei criar um "Prompt 0" que carregasse o contexto base (todos os documentos do andaime) antes da primeira etapa. Recuei porque:

- Cria dependência ordinal frágil: se a sessão da IA reseta, a IA esquece o contexto e etapas subsequentes falham silenciosamente.
- Conflita com o protocolo de retomada do `BUILD_PLAN.md` §3, que assume que cada etapa é re-executável independentemente.
- Carrega documentos em excesso, dispersando o foco da IA.

A solução é a **pré-leitura cirúrgica**: cada prompt declara exatamente quais seções dos documentos do andaime a IA deve ler (`Pré-leitura obrigatória`). Nada mais, nada menos. Sessão nova, retomada após interrupção, e execução isolada — todos funcionam igual.

### 0.5 Numeração

Prompts seguem a numeração das etapas do `BUILD_PLAN.md`:

- `§P.<fase>.<etapa>` corresponde à etapa `F<fase>.<etapa>`.

Exemplo: `§P.2.1` é o prompt para a etapa `F2.1` (Constitution universal).

### 0.6 Convenções nas instruções

- **"Ler" significa ler na íntegra** as seções listadas em `Pré-leitura obrigatória`, sem pular.
- **"Aplicar" significa seguir literalmente** o que a seção referenciada define, sem extrapolação.
- **"Validar" significa executar** os snippets do `VALIDATION.md`, conferir saída, e tratar falhas conforme `VALIDATION.md` §0.5.
- **"Apresentar" significa mostrar ao mantenedor** o que foi gerado, com resumo do que foi feito e resultados das validações.

---

## Parte 1 — Prompts por etapa

### §P.1.1 — Inicializar repositório do framework -Concluido

```markdown
## Objetivo
Inicializar o repositório git do framework codeflow em `~/Projetos/codeflow/`, com `.gitignore` mínimo e commit inicial.

## Pré-leitura obrigatória
- `andaime/BUILD_PLAN.md` §0.3 (ambiente de execução) e §F1.1 (esta etapa).
- `andaime/VALIDATION.md` §V.1.1 (critério de validação).

## Tarefa
1. Verificar estado físico inicial: `~/Projetos/codeflow/` **já existe** contendo apenas a subpasta `andaime/` com os cinco documentos; **não** é repositório git ainda. Executar `git -C ~/Projetos/codeflow rev-parse --git-dir 2>/dev/null` (deve falhar) e `ls ~/Projetos/codeflow` (deve listar apenas `andaime`). Se qualquer dessas verificações divergir, parar com PARADO e reportar.
2. Inicializar como repositório git: `cd ~/Projetos/codeflow && git init`.
3. Criar `.gitignore` na raiz com no mínimo as quatro entradas listadas em `BUILD_PLAN.md` §F1.1 ação 4.
4. Criar `LICENSE` na raiz com o **texto MIT padrão** (ano corrente, titular = `git config user.name`). Licença é definitiva — não há pendência.
5. Criar `andaime/EXECUTION_LOG.md` com cabeçalho inicial: frontmatter (`versão: 1.0`, `status: estável`, `atualizado: <hoje>`), título `# Execução do BUILD_PLAN — log incremental`, e uma seção `## Etapas` para registro incremental ao longo do build. Acrescentar entrada para F1.1 já concluída.
6. Fazer commit inicial com mensagem exata: `chore(init): inicializa repositório do codeflow`.

## Critério de sucesso
Executar todos os snippets de `VALIDATION.md` §V.1.1. Todos retornam `OK: §V.1.1`. Itens de inspeção marcados (LICENSE MIT presente, EXECUTION_LOG.md presente, git identity configurada).

## Em caso de ambiguidade
- Se `~/Projetos/codeflow/` contém conteúdo além de `andaime/`, ou já é repositório git: parar, reportar, perguntar ao mantenedor.
- Se `git config user.name` ou `user.email` retorna vazio: parar e pedir ao mantenedor para configurar antes.

## Saída esperada
Reportar ao mantenedor:
- Hash do commit inicial.
- Conteúdo do `.gitignore`.
- Confirmação de LICENSE MIT criada.
- Confirmação de `andaime/EXECUTION_LOG.md` criado com cabeçalho.
- Resultado da validação §V.1.1.
```

---

### §P.1.2 — Criar estrutura de pastas vazia -Concluido

```markdown
## Objetivo
Materializar a árvore de diretórios do framework conforme `SPEC.md` §2.2, com `.gitkeep` em cada pasta vazia.

## Pré-leitura obrigatória
- `andaime/SPEC.md` §2.2 (estrutura literal de pastas).
- `andaime/BUILD_PLAN.md` §F1.2.
- `andaime/VALIDATION.md` §V.1.2.

## Tarefa
1. Confirmar que a etapa F1.1 foi concluída: `~/Projetos/codeflow/` existe e tem commit inicial.
2. Criar todas as pastas listadas em `BUILD_PLAN.md` §F1.2 ação 1.
3. Adicionar `.gitkeep` vazio em cada pasta criada.
4. Comparar a árvore resultante com `SPEC.md` §2.2 literal. Pastas a mais ou a menos = falha.
5. Commit: `chore(structure): cria árvore de pastas conforme SPEC §2.2`.

## Critério de sucesso
Executar `VALIDATION.md` §V.1.2. Snippet retorna `OK: §V.1.2`. Item de inspeção (comparação com SPEC §2.2) marcado.

## Em caso de ambiguidade
- Se a comparação com `SPEC.md` §2.2 revelar discrepância: parar, listar as diferenças, perguntar ao mantenedor. Não criar pastas extras nem omitir pastas declaradas.
- Se alguma pasta já existe (de criação anterior): manter, não recriar nem alterar conteúdo.

## Saída esperada
- Lista de todas as pastas criadas.
- Output de `find ~/Projetos/codeflow -type d` para verificação visual contra `SPEC.md` §2.2.
- Hash do commit.
- Resultado da validação §V.1.2.
```

---

### §P.1.3 — Copiar documentos do andaime já produzidos -Concluido

```markdown
## Objetivo
Copiar `SPEC.md`, `ARTIFACTS_SPEC.md` e `BUILD_PLAN.md` para `~/Projetos/codeflow/andaime/`, e criar um `README.md` curto explicando o papel do andaime.

## Pré-leitura obrigatória
- `andaime/BUILD_PLAN.md` §F1.3.
- `andaime/VALIDATION.md` §V.1.3.
- `andaime/ARTIFACTS_SPEC.md` §0.2 (frontmatter universal — para o README.md do andaime).

## Tarefa
1. Confirmar que F1.2 foi concluída (pasta `andaime/` existe com `.gitkeep`).
2. Solicitar ao mantenedor os caminhos dos arquivos-fonte (SPEC.md, ARTIFACTS_SPEC.md, BUILD_PLAN.md). Não assumir caminhos — perguntar.
3. Copiar os três arquivos para `~/Projetos/codeflow/andaime/`, preservando nomes.
4. Criar `~/Projetos/codeflow/andaime/README.md` (10 a 15 linhas) que:
   - Tem frontmatter universal conforme `ARTIFACTS_SPEC.md` §0.2.
   - Explica o papel do andaime em uma frase.
   - Lista os cinco documentos previstos: SPEC, ARTIFACTS_SPEC, BUILD_PLAN, VALIDATION, PROMPTS.
   - Marca VALIDATION e PROMPTS como pendentes (serão adicionados na Fase 5).
5. Remover `.gitkeep` de `andaime/`.
6. Commit: `docs(andaime): adiciona SPEC, ARTIFACTS_SPEC e BUILD_PLAN`.

## Critério de sucesso
Executar `VALIDATION.md` §V.1.3. Todos os snippets retornam `OK: §V.1.3`. Itens de inspeção marcados.

## Em caso de ambiguidade
- Se os arquivos-fonte não estão acessíveis: parar e pedir ao mantenedor que disponibilize antes de prosseguir.
- Se algum dos três arquivos não passa nas verificações de frontmatter/encoding ao chegar em `andaime/`: parar, reportar a falha. Não corrigir os documentos do andaime sem aprovação — eles são fonte da verdade.

## Saída esperada
- Lista dos arquivos copiados com caminhos de origem e destino.
- Conteúdo do `README.md` do andaime criado.
- Hash do commit.
- Resultado da validação §V.1.3.
```

---

### §P.1.4 — Criar symlink `~/.codeflow/` → `~/Projetos/codeflow/` -Concluido

```markdown
## Objetivo
Estabelecer o caminho canônico `~/.codeflow/` apontando para o repositório de trabalho via symlink, sem duplicar conteúdo no disco.

## Pré-leitura obrigatória
- `andaime/BUILD_PLAN.md` §F1.4.
- `andaime/VALIDATION.md` §V.1.4.

## Tarefa
1. Verificar que `~/.codeflow` **não** existe ainda. Se existir, parar e reportar — pode ser instalação prévia que exige decisão de migração.
2. Criar o symlink: `ln -s ~/Projetos/codeflow ~/.codeflow`.
3. Verificar acessibilidade: `ls ~/.codeflow/andaime/SPEC.md` deve listar o arquivo.

## Critério de sucesso
Executar `VALIDATION.md` §V.1.4. Snippet retorna `OK: §V.1.4`. Item de inspeção marcado.

## Em caso de ambiguidade
- Se `~/.codeflow` existe como diretório (não symlink): parar, reportar. Decisão sobre como migrar é do mantenedor.
- Se `~/.codeflow` existe como symlink mas aponta para outro lugar: parar, reportar. Não sobrescrever sem aprovação.
- Se o aviso de cópias paralelas em §V.1.4 dispara: reportar os caminhos detectados ao mantenedor; aguardar decisão antes de prosseguir.

## Saída esperada
- Output de `readlink ~/.codeflow`.
- Confirmação de que `~/.codeflow/andaime/SPEC.md` é acessível.
- Resultado da validação §V.1.4 (incluindo eventuais avisos).
- Nota explicando que esta etapa não tem commit no repositório (symlink é configuração de ambiente).
```

---

### §P.2.1 — Constitution universal -Concluido

```markdown
## Objetivo
Criar `framework/core/constitution.md` conforme `ARTIFACTS_SPEC.md` §1.1.

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §0.1 a §0.7 (convenções gerais).
- `andaime/ARTIFACTS_SPEC.md` §1.1.1 a §1.1.7 (todas as 7 subseções da constitution universal).
- `andaime/ARTIFACTS_SPEC.md` Parte 3 (regras transversais).
- `andaime/SPEC.md` §4.1.1 (constitution universal) e §8.3 (política de falhas).
- `andaime/BUILD_PLAN.md` §F2.1.
- `andaime/VALIDATION.md` §V.2.1.

## Tarefa
1. Confirmar que F1.4 foi concluída (symlink `~/.codeflow/` ativo).
2. Aplicar o template literal do bloco `ARTIFACTS_SPEC.md` §1.1.5 como base estrutural.
3. Escrever conteúdo das cinco seções obrigatórias conforme `SPEC.md` §4.1.1 e §8.3:
   - `## Princípios invariantes`: **exatamente 4 princípios** — (a) diff mínimo; (b) declaração de escopo antes de modificar; (c) seguir convenções existentes; (d) comentários só registram "por quê" não-óbvio — mais um bullet final sobre mudanças quebradoras (detecção e documentação explícitas antes de aplicar).
   - `## Política de falhas`: as quatro categorias literais (Transitória, Lógica, Escopo, Ambiente). **Sem** o bloco PARADO embutido.
   - `## Formato PARADO`: formato literal de aborto, em seção independente.
   - `## Proibições absolutas`: alinhadas a `SPEC.md` §8.3 (framework alheio na raiz; configs globais; secrets/`.env`; pastas marcadas como protegidas).
   - `## Quando esta constitution se aplica`: escopo de carregamento (toda sessão de workflow) e relação com a constitution de projeto (estende, não substitui).
4. **Não criar** seção `## Definition of Done padrão` — decisão deliberada do `ARTIFACTS_SPEC.md`.
5. Salvar em `framework/core/constitution.md`. Remover `.gitkeep` de `framework/core/`.
6. Commit: `feat(core): adiciona constitution universal`.

## Critério de sucesso
Executar `VALIDATION.md` §V.2.1. Todos os snippets retornam `OK: §V.2.1`. Quatro itens de inspeção marcados.

## Em caso de ambiguidade
- Número de princípios invariantes: **4**, vinculante. Não perguntar.
- Redação exata dos princípios: propor uma versão ao mantenedor, aguardar aprovação antes de gravar.
- Conteúdo das quatro categorias de falha: seguir literalmente `SPEC.md` §8.3. Se a especificação não cobre algum aspecto, perguntar.

## Saída esperada
- Conteúdo completo do `constitution.md` gerado.
- Resultado de cada verificação automatizável de §V.2.1.
- Confirmação dos quatro itens de inspeção marcados.
- Hash do commit.
```

---

### §P.2.2 — Glossary -Concluido

```markdown
## Objetivo
Criar `framework/core/glossary.md` conforme `ARTIFACTS_SPEC.md` §1.2.

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §1.2.1 a §1.2.7.
- `andaime/ARTIFACTS_SPEC.md` Parte 3.
- `andaime/SPEC.md` §6.2 (glossary).
- `andaime/BUILD_PLAN.md` §F2.2.
- `andaime/VALIDATION.md` §V.2.2.
- `framework/core/constitution.md` (criado em F2.1) — para conferir coerência terminológica.

## Tarefa
1. Confirmar que F2.1 foi concluída (`constitution.md` existe e válido).
2. Aplicar o template do `ARTIFACTS_SPEC.md` §1.2.5 como base.
3. Título: `# Glossário do codeflow` (com acento — pt-BR).
4. Incluir **12 termos centrais** como sub-seções `### <termo>`, em **ordem alfabética pt-BR** (`ARTIFACTS_SPEC.md` §1.2.3):
   Agent, Artefato, Checkpoint, Constitution, Decision, Discovered, INDEX, Manifest, Meta-skill, Rule, Skill, Workflow.
5. Incluir **4 distinções** explícitas: Workflow vs Skill; Agent vs Skill; Rule vs Constitution; Decision vs Checkpoint.
6. Incluir nota de colisão na definição de Agent (conflito com termo usado por Cursor/Claude Code).
7. Cada definição: 2 a 4 linhas, sem hedges, sem auto-referência.
8. Salvar em `framework/core/glossary.md`. Commit: `feat(core): adiciona glossary universal`.

## Critério de sucesso
Executar `VALIDATION.md` §V.2.2. Todos os snippets retornam `OK: §V.2.2`. Quatro itens de inspeção marcados, com atenção especial à não-circularidade.

## Em caso de ambiguidade
- Redação exata de cada definição: propor versão ao mantenedor, aguardar aprovação.
- Coerência com termos usados em `constitution.md`: se há divergência, parar e perguntar qual fonte vence.
- Termos adicionais além dos 12 centrais e 4 distinções: não adicionar sem aprovação explícita.

## Saída esperada
- Conteúdo completo do `glossary.md` gerado.
- Lista dos 12 termos centrais e 4 distinções presentes.
- Confirmação visual de que nenhuma definição é circular.
- Resultado da validação §V.2.2.
- Hash do commit.
```

---

### §P.2.3 — EVOLUTION -Concluido

```markdown
## Objetivo
Criar `framework/core/EVOLUTION.md` conforme `ARTIFACTS_SPEC.md` §1.3.

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §1.3.1 a §1.3.7.
- `andaime/ARTIFACTS_SPEC.md` Parte 3.
- `andaime/SPEC.md` §6.3 (política de evolução).
- `andaime/BUILD_PLAN.md` §F2.3.
- `andaime/VALIDATION.md` §V.2.3.

## Tarefa
1. Confirmar que F2.2 foi concluída.
2. Aplicar o template do `ARTIFACTS_SPEC.md` §1.3.5 como base.
3. Criar as cinco seções literais conforme `SPEC.md` §6.3:
   - `## Promoção (skill/workflow de projeto → universal)`
   - `## Adição de rule`
   - `## Adição de meta-skill`
   - `## Mudança em arquivo do core (constitution, glossary, EVOLUTION)`
   - `## Anti-evolução`
4. Cada seção declara: condições objetivas + processo passo a passo + exemplos do que **não** justifica.
5. Critérios — **separados e independentes**:
   - **Promoção de skill ou workflow específico para universal:** uso real em **dois projetos distintos** (sem prazo mínimo). Operação: `git mv`. Versionamento: `bump minor`.
   - **Mudança em arquivo do core (constitution, glossary, EVOLUTION):** **período de transição de 30 dias** entre proposta e adoção. Versionamento: `bump major`.
   - Os dois critérios não se combinam em uma única regra.
6. Salvar em `framework/core/EVOLUTION.md`. Commit: `feat(core): adiciona política de evolução`.

## Critério de sucesso
Executar `VALIDATION.md` §V.2.3. Todos os snippets retornam `OK: §V.2.3`. Três itens de inspeção marcados.

## Em caso de ambiguidade
- Exemplos de anti-evolução a citar: propor lista ao mantenedor, aguardar aprovação.

## Saída esperada
- Conteúdo completo do `EVOLUTION.md` gerado.
- Confirmação de que as strings literais `dois projetos distintos`, `30 dias`, `git mv`, `bump minor`, `bump major` aparecem no arquivo.
- Resultado da validação §V.2.3.
- Hash do commit.
```

---

### §P.2.4 — Quatro rules seed -Concluido

```markdown
## Objetivo
Criar os quatro rules seed em `framework/core/rules/`: `code-quality.md`, `testing.md`, `security.md`, `naming.md`. Todos universais.

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §1.4.1 a §1.4.7 (todas as subseções de rules).
- `andaime/ARTIFACTS_SPEC.md` §1.4.5 (exemplo `testing.md` realista — usar como referência de forma).
- `andaime/ARTIFACTS_SPEC.md` Parte 3.
- `andaime/SPEC.md` §4.6 (rules).
- `andaime/BUILD_PLAN.md` §F2.4 (inclui sugestões de conteúdo).
- `andaime/VALIDATION.md` §V.2.4.

## Tarefa
1. Confirmar que F2.3 foi concluída.
2. Para cada um dos quatro temas, criar `framework/core/rules/<tema>.md`:
   - Frontmatter com campos universais + `escopo: universal`.
   - Cinco seções fixas: `# Rule: <tema>`, `## Quando carregar`, `## Regras`, `## Anti-regras`, `## Exceções`.
   - Pelo menos três regras, paridade aproximada com anti-regras.
   - Pelo menos uma exceção declarada (ou texto literal `Nenhuma.`).
3. Conteúdo agnóstico de stack (sem menção a pytest, Postgres, etc. — esses pertencem a rules de projeto).
4. Adotar os **conteúdos canônicos vinculantes** de `BUILD_PLAN.md` §F2.4 (vinculantes — o construtor tem liberdade apenas de redação, não de cobertura). Não pedir aprovação caso a caso para a escolha de temas.
5. Remover `.gitkeep` de `framework/core/rules/`. Commit: `feat(rules): adiciona quatro rules seed`.

## Critério de sucesso
Executar `VALIDATION.md` §V.2.4. Snippet retorna `OK: §V.2.4 (4 rules validados)`. Itens de inspeção marcados para os quatro arquivos.

## Em caso de ambiguidade
- Redação específica das regras: propor draft ao mantenedor após escrever, aguardar feedback. Cobertura dos quatro temas é vinculante; não perguntar sobre quais temas escrever.
- Se alguma regra parece se aproximar de stack específica: parar e perguntar — universalidade é critério duro.

## Saída esperada
- Conteúdo completo dos quatro arquivos.
- Tabela mostrando, para cada rule: número de regras, número de anti-regras, número de exceções.
- Resultado da validação §V.2.4.
- Hash do commit.
```

---

### §P.3.1 — Três skills seed -Concluido

```markdown
## Objetivo
Criar três skills universais seed em `framework/library/skills/`: `debug-protocol`, `handoff`, `self-review`. Cada uma como pasta com `SKILL.md`.

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §1.8.1 a §1.8.7 (todas as subseções de skills).
- `andaime/ARTIFACTS_SPEC.md` §1.8.5 (exemplo `debug-protocol` realista — usar como referência).
- `andaime/ARTIFACTS_SPEC.md` Parte 3.
- `andaime/SPEC.md` §4.3 (skills).
- `andaime/BUILD_PLAN.md` §F3.1.
- `andaime/VALIDATION.md` §V.3.1.

## Tarefa
1. Confirmar que F2.4 foi concluída (quatro rules em `framework/core/rules/`).
2. Para cada uma das três skills, criar `framework/library/skills/<nome>/SKILL.md`:
   - Frontmatter com campos universais + `descrição` (uma linha).
   - Seis seções fixas: `# Skill: <nome>`, `## Quando usar`, `## Princípio guia`, `## Protocolo`, `## Proibições durante esta skill`, `## Saídas válidas`.
   - **Sem** `## Definition of Done` (vedado em skill).
   - **Sem** `## LEIA TAMBÉM` (vedado em skill).
3. Conteúdo de cada skill:
   - `debug-protocol/SKILL.md`: aplicar literalmente o exemplo realista de `ARTIFACTS_SPEC.md` §1.8.5.
   - `handoff/SKILL.md`: protocolo de transferência de contexto entre sessões — formato fixo de saída, o que incluir, o que excluir.
   - `self-review/SKILL.md`: protocolo de auto-revisão de diff — checklist, perguntas a fazer ao próprio diff, sinais de alerta.
4. Remover `.gitkeep` de cada pasta. Commit: `feat(skills): adiciona três skills seed (debug-protocol, handoff, self-review)`.

## Critério de sucesso
Executar `VALIDATION.md` §V.3.1. Snippet retorna `OK: §V.3.1 (3 skills validadas)`. Itens de inspeção marcados para as três skills.

## Em caso de ambiguidade
- Para `handoff` e `self-review` (sem exemplo realista no ARTIFACTS_SPEC): propor draft completo ao mantenedor, aguardar aprovação antes de gravar.
- Se alguma skill parece querer referenciar outra skill: parar. Composição entre skills é anti-feature (SPEC §10.6).
- Limite de tentativas em `debug-protocol`: o exemplo do ARTIFACTS_SPEC §1.8.5 declara três. Manter este número, não mudar.

## Saída esperada
- Conteúdo completo dos três `SKILL.md`.
- Confirmação de que nenhum tem `## Definition of Done` ou `## LEIA TAMBÉM`.
- Resultado da validação §V.3.1.
- Hash do commit.
```

---

### §P.3.2 — Quatro workflows seed -Concluido

```markdown
## Objetivo
Criar os quatro workflows universais seed em `framework/library/workflows/`: `review-only` (magro), `bugfix` (médio), `feature-small` (médio), `refactor-safe` (médio).

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §1.5.1 a §1.5.7 (workflows magros).
- `andaime/ARTIFACTS_SPEC.md` §1.6.1 a §1.6.7 (workflows médios).
- `andaime/ARTIFACTS_SPEC.md` §1.5.5 (exemplo `review-only`) e §1.6.5 (exemplo `bugfix`).
- `andaime/ARTIFACTS_SPEC.md` Parte 3.
- `andaime/SPEC.md` §4.2 (workflows) e §5.2 a §5.3 (estruturas).
- `andaime/BUILD_PLAN.md` §F3.2 (incluindo tabela de classificação).
- `andaime/VALIDATION.md` §V.3.2.

## Tarefa
1. Confirmar que F3.1 foi concluída (três skills em `framework/library/skills/`).
2. Para cada workflow, aplicar a classificação de `BUILD_PLAN.md` §F3.2:
   - `review-only`: magro, `gera_decision: no`.
   - `bugfix`: médio, `gera_decision: auto`.
   - `feature-small`: médio, `gera_decision: auto`.
   - `refactor-safe`: médio, `gera_decision: no`.
3. Criar cada arquivo em `framework/library/workflows/<nome>.md`:
   - Frontmatter com campos universais + `granularidade`, `gera_decision`, `usa_checkpoints: no`, `politica_falhas: padrão`.
   - Seções fixas conforme granularidade.
   - `## LEIA TAMBÉM` com as quatro entradas obrigatórias + skills/rules relevantes.
4. Conteúdo:
   - `review-only.md`: aplicar literalmente o exemplo de `ARTIFACTS_SPEC.md` §1.5.5.
   - `bugfix.md`: aplicar literalmente o exemplo de `ARTIFACTS_SPEC.md` §1.6.5.
   - `feature-small.md` e `refactor-safe.md`: aplicar os **esqueletos de passos canônicos** declarados em `BUILD_PLAN.md` §F3.2 (vinculantes — liberdade apenas de redação dentro de cada passo).
5. Para cada workflow médio, verificar que `## LEIA TAMBÉM` aponta apenas para arquivos que **já existem** em `framework/core/` ou `framework/library/skills/`.
6. Remover `.gitkeep` de `framework/library/workflows/`. Commit: `feat(workflows): adiciona quatro workflows seed`.

## Critério de sucesso
Executar `VALIDATION.md` §V.3.2. Snippet retorna `OK: §V.3.2 (4 workflows validados)`. Cinco itens de inspeção marcados.

## Em caso de ambiguidade
- Para `feature-small` e `refactor-safe`: os esqueletos de passos do `BUILD_PLAN.md` §F3.2 são vinculantes; a redação interna de cada passo pode ser proposta ao mantenedor para revisão após escrita, não antes.
- Se algum workflow precisa referenciar skill ou rule que ainda não existe: parar e reportar. Não inventar referências.

## Saída esperada
- Conteúdo completo dos quatro arquivos.
- Tabela: nome, granularidade, número de passos, número de entradas em LEIA TAMBÉM, gera_decision.
- Resultado da validação §V.3.2.
- Hash do commit.
```

---

### §P.3.3 — Manter `framework/library/agents/` vazio

```markdown
## Objetivo
Confirmar explicitamente que nenhum agent seed é entregue no escopo inicial, conforme `SPEC.md` §4.5.4. Documentar a decisão.

## Pré-leitura obrigatória
- `andaime/SPEC.md` §4.5.4.
- `andaime/ARTIFACTS_SPEC.md` §1.10.1.
- `andaime/BUILD_PLAN.md` §F3.3.
- `andaime/VALIDATION.md` §V.3.3.

## Tarefa
1. Confirmar que F3.2 foi concluída.
2. Verificar que `framework/library/agents/` existe e contém apenas `.gitkeep`.
3. Editar o `.gitkeep` adicionando uma única linha de comentário documentando a decisão:
   `# Agents são criados sob demanda via meta-skill create-agent. Nenhum agent seed entregue no escopo inicial.`
4. Esta etapa não tem commit próprio. Mantê-la como parte do commit de F3.2 ou agrupar com F4.1.

## Critério de sucesso
Executar `VALIDATION.md` §V.3.3. Snippet retorna `OK: §V.3.3`. Item de inspeção marcado.

## Em caso de ambiguidade
- Se houver pressão para criar agent seed "para demonstração": recusar. SPEC §4.5.4 é explícito.
- Se a pasta tem qualquer arquivo `.md`: parar, reportar — algo foi criado fora do escopo do BUILD_PLAN.

## Saída esperada
- Output de `ls -la framework/library/agents/`.
- Conteúdo final do `.gitkeep` (com comentário).
- Resultado da validação §V.3.3.
```

---

### §P.4.1 — Três meta-skills `create-*`

```markdown
## Objetivo
Criar três meta-skills em `framework/meta/`: `create-workflow`, `create-skill`, `create-agent`. Granularidade média.

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §1.9.1 a §1.9.7 (todas as subseções de meta-skills).
- `andaime/ARTIFACTS_SPEC.md` §1.9.5 (exemplo `create-workflow` realista — usar como referência).
- `andaime/ARTIFACTS_SPEC.md` §1.5/§1.6/§1.7 (templates que `create-workflow` referencia).
- `andaime/ARTIFACTS_SPEC.md` §1.8 (template que `create-skill` referencia).
- `andaime/ARTIFACTS_SPEC.md` §1.10 (template que `create-agent` referencia).
- `andaime/ARTIFACTS_SPEC.md` Parte 3.
- `andaime/SPEC.md` §4.4 (meta-skills).
- `andaime/BUILD_PLAN.md` §F4.1.
- `andaime/VALIDATION.md` §V.4.1.

## Tarefa
1. Confirmar que F3.3 foi concluída.
2. Para cada uma das três meta-skills, criar `framework/meta/<nome>/SKILL.md`:
   - Frontmatter com campos universais + `descrição`, `é_meta_skill: yes`, `granularidade: médio`.
   - Nove seções obrigatórias conforme `ARTIFACTS_SPEC.md` §1.9.3.
   - Três seções exclusivas de meta-skill: `## Template de saída`, `## Onde salvar`, `## Validação pós-geração`.
3. Conteúdo:
   - `create-workflow/SKILL.md`: aplicar literalmente o exemplo de `ARTIFACTS_SPEC.md` §1.9.5.
   - `create-skill/SKILL.md`: estrutura análoga; `## Template de saída` referencia §1.8.5; `## Validação pós-geração` referencia §1.8.6.
   - `create-agent/SKILL.md`: estrutura análoga; `## Template de saída` referencia §1.10.5; `## Validação pós-geração` referencia §1.10.6. A meta-skill recusa criação se a tarefa pode ser realizada com skill regular.
4. Cada meta-skill começa o `## Protocolo` qualificando se a criação é necessária (anti-evolução do `SPEC.md` §6.3).
5. Remover `.gitkeep` de cada pasta. Commit: `feat(meta): adiciona três meta-skills create-*`.

## Critério de sucesso
Executar `VALIDATION.md` §V.4.1. Snippet retorna `OK: §V.4.1 (3 meta-skills create-* validadas)`. Itens de inspeção marcados.

## Em caso de ambiguidade
- Para `create-skill` e `create-agent` (sem exemplo literal no ARTIFACTS_SPEC): propor draft completo ao mantenedor, aguardar aprovação.
- Se o passo de qualificação inicial parece "pesado demais": manter. Anti-evolução exige fricção deliberada.

## Saída esperada
- Conteúdo completo dos três `SKILL.md`.
- Confirmação de que cada um referencia corretamente o ARTIFACTS_SPEC para o tipo gerado.
- Resultado da validação §V.4.1.
- Hash do commit.
```

---

### §P.4.2 — Duas meta-skills `discover` e `bootstrap`

```markdown
## Objetivo
Criar duas meta-skills detalhadas em `framework/meta/`: `discover` e `bootstrap`.

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §1.9.1 a §1.9.7 (foco nas regras de granularidade detalhada).
- `andaime/ARTIFACTS_SPEC.md` §2.1 a §2.4 (artefatos de projeto que `discover` e `bootstrap` geram).
- `andaime/ARTIFACTS_SPEC.md` Parte 3.
- `andaime/SPEC.md` §4.4.2 (limite de cinco perguntas em `discover`).
- `andaime/SPEC.md` §6.6 (checkpoints, para seção `## Retomada`).
- `andaime/BUILD_PLAN.md` §F4.2.
- `andaime/VALIDATION.md` §V.4.2.

## Tarefa
1. Confirmar que F4.1 foi concluída.
2. Criar `framework/meta/discover/SKILL.md`:
   - Frontmatter: `é_meta_skill: yes`, `granularidade: detalhado`.
   - Protocolo em **quatro fases**: Inspeção → Entrevista qualificada (no máximo 5 perguntas) → Geração de constitution + manifest + INDEX → Geração de discovered.md + entrega.
   - Pausa para confirmação do usuário entre Fase 2 e Fase 3.
   - `## Template de saída` referencia §2.1.5, §2.2.5, §2.3.5, §2.4.5.
   - `## Validação pós-geração` referencia §2.1.6, §2.2.6, §2.3.6, §2.4.6.
   - `## Onde salvar`: todos os artefatos em `<projeto>/.codeflow/`.
   - Seção opcional `## Retomada` documentando como detectar checkpoint e oferecer retomada.
3. Criar `framework/meta/bootstrap/SKILL.md`:
   - Frontmatter: `é_meta_skill: yes`, `granularidade: detalhado`.
   - Protocolo em **cinco fases**: Coleta de requisitos → Decisão de stack → Geração de estrutura mínima do projeto → Geração de artefatos do `.codeflow/` (sem discovered) → Entrega.
   - Pausa para confirmação em pelo menos duas fases.
   - `## Template de saída` referencia §2.1.5, §2.2.5, §2.3.5. **Não** referencia §2.4.
   - `## Validação pós-geração` referencia §2.1.6, §2.2.6, §2.3.6.
   - `## Onde salvar`: artefatos de `.codeflow/` em `<projeto>/.codeflow/`; arquivos de projeto em `<projeto>/`.
   - Seção opcional `## Retomada`.
4. Remover `.gitkeep` de cada pasta. Commit: `feat(meta): adiciona meta-skills discover e bootstrap`.

## Critério de sucesso
Executar `VALIDATION.md` §V.4.2. Snippet retorna `OK: §V.4.2 (2 meta-skills detalhadas validadas)`. Itens de inspeção marcados, incluindo número de fases e pausas para usuário.

## Em caso de ambiguidade
- Conteúdo das fases (especialmente perguntas exatas em `discover` e `bootstrap`): propor draft completo ao mantenedor, aguardar aprovação. Estas duas meta-skills são críticas — não improvisar.
- Limite de cinco perguntas em `discover`: manter rígido. Mais que cinco viola SPEC §4.4.2.
- Em `bootstrap`, se houver tentação de gerar `discovered.md`: parar. Bootstrap não gera discovered (não há projeto a descobrir).

## Saída esperada
- Conteúdo completo dos dois `SKILL.md`.
- Tabela: meta-skill, número de fases, pausas para usuário, artefatos gerados, seções LEIA TAMBÉM referenciadas.
- Resultado da validação §V.4.2.
- Hash do commit.
```

---

### §P.5.1 — Script `install.sh`

```markdown
## Objetivo
Criar `install.sh` na raiz do framework conforme `SPEC.md` §3.9.

## Pré-leitura obrigatória
- `andaime/SPEC.md` §3.9 (decisão completa + anti-decisão).
- `andaime/SPEC.md` §7 (decisões técnicas relacionadas a scripts).
- `andaime/ARTIFACTS_SPEC.md` §0.6 (símbolos) e §0.7 (códigos de saída).
- `andaime/ARTIFACTS_SPEC.md` §3.8 (stack permitida em scripts).
- `andaime/BUILD_PLAN.md` §F5.1.
- `andaime/VALIDATION.md` §V.5.1.

## Tarefa
1. Confirmar que F4.2 foi concluída.
2. Criar `~/Projetos/codeflow/install.sh` (bash, executável) com responsabilidades de `SPEC.md` §3.9:
   - Verificar pré-requisitos: `git` disponível, `~/.codeflow/` existe, diretório de execução é repositório git, Makefile presente (apenas aviso se ausente).
   - Criar `.codeflow/INDEX.md` (placeholder), `.codeflow/decisions/`, `.codeflow/checkpoints/`.
   - Adicionar `.codeflow/checkpoints/` ao `.gitignore` do projeto.
   - Imprimir mensagem com próximos passos (`/discover` ou `/bootstrap`).
3. Restrições (anti-decisão `SPEC.md` §3.9):
   - **Não** modificar `CLAUDE.md`, `AGENTS.md`, `README.md`, nenhum arquivo na raiz do projeto.
   - **Não** criar constitution.md, manifest.md, discovered.md.
   - **Não** rodar `git init`.
   - **Não** instalar dependências, não baixar nada.
4. Códigos de saída conforme `ARTIFACTS_SPEC.md` §0.7: 0 sucesso, 1 falha de regra, 2 erro de execução, 3 input inválido.
5. Símbolos `✓`/`✗`/`⚠` em mensagens (pt-BR).
6. Idempotência: rodar duas vezes não duplica nem corrompe.
7. Stack permitida: apenas bash + coreutils + git. Sem jq, python, node, etc.
8. `chmod +x install.sh`. Commit: `feat(install): adiciona script install.sh`.

## Critério de sucesso
Executar `VALIDATION.md` §V.5.1. Todos os snippets retornam `OK: §V.5.1`. Itens de inspeção marcados. Teste funcional em pasta temporária passa.

## Em caso de ambiguidade
- Texto exato da mensagem de próximos passos: propor texto ao mantenedor, aguardar aprovação.
- Se `shellcheck` reporta avisos não-bloqueantes: incluir no relatório, deixar mantenedor decidir.
- Se algum aspecto do `install.sh` não está coberto literalmente pelo SPEC §3.9: perguntar. Não inventar comportamento.

## Saída esperada
- Conteúdo completo do `install.sh`.
- Output do teste funcional em pasta temporária (estrutura criada, idempotência confirmada).
- Output do `shellcheck` se disponível.
- Resultado da validação §V.5.1.
- Hash do commit.
```

---

### §P.5.2 — README da raiz do framework

```markdown
## Objetivo
Criar `~/Projetos/codeflow/README.md` como manual de uso de alto nível, conforme `SPEC.md` §2.2.

## Pré-leitura obrigatória
- `andaime/SPEC.md` §2.2 (estrutura do framework).
- `andaime/ARTIFACTS_SPEC.md` §0.2 (frontmatter).
- `andaime/ARTIFACTS_SPEC.md` §3.1 a §3.3 (forma e idioma).
- `andaime/BUILD_PLAN.md` §F5.2.
- `andaime/VALIDATION.md` §V.5.2.

## Tarefa
1. Confirmar que F5.1 foi concluída.
2. Criar `~/Projetos/codeflow/README.md` (40 a 80 linhas) contendo:
   - Frontmatter universal.
   - Título e descrição curta do codeflow.
   - Quando usar.
   - Pré-requisitos (bash, git, make).
   - Instalação em projeto-alvo: `cd <projeto> && bash ~/.codeflow/install.sh`.
   - Primeiros passos pós-instalação: `/discover` ou `/bootstrap`.
   - Estrutura do framework (referência a `andaime/SPEC.md` §2.2).
   - Ponteiros para documentação detalhada (andaime/SPEC.md, ARTIFACTS_SPEC.md, BUILD_PLAN.md).
   - Como evoluir o framework (referência a `framework/core/EVOLUTION.md`).
   - Licença.
3. Linguagem: pt-BR. Tamanho-alvo: 40 a 80 linhas.
4. Commit: `docs(readme): adiciona README de raiz do framework`.

## Critério de sucesso
Executar `VALIDATION.md` §V.5.2. Todos os snippets retornam `OK: §V.5.2`. Três itens de inspeção marcados.

## Em caso de ambiguidade
- Conteúdo exato de cada seção do README: propor draft ao mantenedor, aguardar aprovação.
- Se a licença ainda não foi decidida (pendência de F1.1): registrar "A definir" no README e referenciar a pendência. Não escolher autonomamente.
- Tom do README: factual e curto. Sem prosa motivacional.

## Saída esperada
- Conteúdo completo do `README.md`.
- Resultado da validação §V.5.2.
- Hash do commit.
```

---

### §P.5.3 — Integrar VALIDATION.md e PROMPTS.md ao andaime

```markdown
## Objetivo
Adicionar `VALIDATION.md` e `PROMPTS.md` em `andaime/`, atualizando o README do andaime para remover marcações de pendência.

## Pré-leitura obrigatória
- `andaime/ARTIFACTS_SPEC.md` §0.2 (frontmatter).
- `andaime/BUILD_PLAN.md` §F5.3.
- `andaime/VALIDATION.md` §V.5.3.

## Tarefa
1. Confirmar que F5.2 foi concluída.
2. Solicitar ao mantenedor os caminhos dos arquivos-fonte `VALIDATION.md` e `PROMPTS.md`.
3. Copiar os dois arquivos para `~/Projetos/codeflow/andaime/`.
4. Atualizar `~/Projetos/codeflow/andaime/README.md` removendo as marcações de "pendente" dos dois documentos.
5. Commit: `docs(andaime): adiciona VALIDATION e PROMPTS`.

## Critério de sucesso
Executar `VALIDATION.md` §V.5.3. Snippet retorna `OK: §V.5.3`. Item de inspeção marcado.

## Em caso de ambiguidade
- Se os arquivos-fonte não estão acessíveis: parar e pedir ao mantenedor.
- Se algum dos dois arquivos falha em verificação de frontmatter ao chegar em `andaime/`: parar e reportar. Não corrigir documentos do andaime sem aprovação.

## Saída esperada
- Lista dos arquivos copiados.
- Confirmação de que o README do andaime não tem mais marcações de pendência.
- Resultado da validação §V.5.3.
- Hash do commit.
```

---

### §P.5.4 — Criar projeto de teste

```markdown
## Objetivo
Criar um projeto minimalista em `/tmp/codeflow-test/` (caminho fixo e vinculante) para exercitar `install.sh` e meta-skills críticos.

## Pré-leitura obrigatória
- `andaime/BUILD_PLAN.md` §F5.4.
- `andaime/VALIDATION.md` §V.5.4.

## Tarefa
1. Confirmar que F5.3 foi concluída.
2. Criar o diretório `/tmp/codeflow-test/` e inicializar como repositório git.
3. Criar Makefile minimalista com os quatro targets canônicos (`check`, `test`, `lint`, `typecheck`). Cada target imprime `noop` e retorna 0.
4. Criar `README.md` curto no projeto de teste, simulando projeto realista.
5. Configurar git (user.email e user.name temporários se necessário) e fazer commit inicial.

## Critério de sucesso
Executar `VALIDATION.md` §V.5.4. Snippet retorna `OK: §V.5.4`. Item de inspeção marcado.

## Em caso de ambiguidade
- Se `/tmp/codeflow-test/` já existe: parar e reportar. Não sobrescrever sem aprovação.
- Conteúdo do Makefile: manter mínimo. Cada target é `noop`. Não adicionar lógica real.

## Saída esperada
- Caminho do projeto de teste criado.
- Output de `tree` ou `ls -la` no projeto de teste.
- Resultado da validação §V.5.4.
```

---

### §P.5.5 — Executar `install.sh` no projeto de teste

```markdown
## Objetivo
Rodar `~/.codeflow/install.sh` no projeto de teste e verificar que cria a estrutura correta sem tocar em arquivos do projeto.

## Pré-leitura obrigatória
- `andaime/SPEC.md` §3.9 (anti-decisão — o que install.sh **não** deve fazer).
- `andaime/BUILD_PLAN.md` §F5.5.
- `andaime/VALIDATION.md` §V.5.5.

## Tarefa
1. Confirmar que F5.4 foi concluída (projeto de teste existe em `/tmp/codeflow-test/`).
2. Entrar no projeto: `cd /tmp/codeflow-test`.
3. Executar: `bash ~/.codeflow/install.sh`.
4. Inspecionar saída: lista de verificações com símbolos, mensagem final com próximos passos.
5. Verificar artefatos criados: `.codeflow/INDEX.md` (placeholder), `.codeflow/decisions/`, `.codeflow/checkpoints/`, `.gitignore` atualizado.
6. Verificar **não-modificação**: `git status` no projeto de teste mostra apenas `.codeflow/` e `.gitignore` (se novo) como mudanças. Nenhum outro arquivo modificado.
7. Executar `install.sh` uma segunda vez. Deve detectar instalação existente e não duplicar.

## Critério de sucesso
Executar `VALIDATION.md` §V.5.5. Snippet retorna `OK: §V.5.5`. Item de inspeção marcado.

## Em caso de ambiguidade
- Se `install.sh` falha em algum check: parar, reportar saída completa. Investigar se é problema do install.sh (volta a F5.1) ou do projeto de teste (volta a F5.4).
- Se `install.sh` modifica algum arquivo fora de `.codeflow/`: violação grave de SPEC §3.9. Parar imediatamente e reportar.

## Saída esperada
- Output completo da primeira execução do `install.sh`.
- Output da segunda execução (validação de idempotência).
- Output de `git status` no projeto de teste antes e depois.
- Resultado da validação §V.5.5.
```

---

### §P.5.6 — Exercitar `discover` (simulado) no projeto de teste

```markdown
## Objetivo
Validar que a meta-skill `discover` é executável conceitualmente, gerando os quatro artefatos previstos no projeto de teste.

## Pré-leitura obrigatória
- `framework/meta/discover/SKILL.md` (a meta-skill em si, criada em F4.2).
- `andaime/ARTIFACTS_SPEC.md` §2.1, §2.2, §2.3, §2.4 (formato dos artefatos gerados).
- `andaime/BUILD_PLAN.md` §F5.6.
- `andaime/VALIDATION.md` §V.5.6.

## Tarefa
1. Confirmar que F5.5 foi concluída.
2. Ler `framework/meta/discover/SKILL.md` na íntegra.
3. Aplicar o protocolo da meta-skill ao projeto de teste, atuando como se você fosse a IA executando a meta-skill:
   - Fase 1 — Inspeção: examinar Makefile, README, estrutura do projeto de teste.
   - Fase 2 — Entrevista (até 5 perguntas): perguntar ao mantenedor as cinco perguntas mais relevantes inferidas pela inspeção. Aguardar respostas.
   - Fase 3 — Geração de constitution + manifest + INDEX: criar três arquivos em `<projeto-teste>/.codeflow/`.
   - Fase 4 — Geração de discovered.md + entrega.
4. Para cada arquivo gerado, aplicar as regras de validação correspondentes: §2.1.6, §2.2.6, §2.3.6, §2.4.6 do ARTIFACTS_SPEC.
5. Se algum arquivo falha: indica problema na meta-skill `discover`, **não** no exercício. Corrigir `framework/meta/discover/SKILL.md`, commit com `fix(meta/discover): <descrição>`, repetir o exercício.

## Critério de sucesso
Executar `VALIDATION.md` §V.5.6. Snippet retorna `OK: §V.5.6`. Quatro itens de inspeção marcados.

## Em caso de ambiguidade
- Se a meta-skill `discover` tem instruções ambíguas que tornam impossível seguir mecanicamente: parar, registrar a ambiguidade, corrigir `discover/SKILL.md` antes de continuar.
- Se a entrevista exige mais de cinco perguntas para inferir o projeto de teste: parar — isso indica que `discover` foi mal escrita ou que o projeto de teste é complexo demais.

## Saída esperada
- Conteúdo completo dos quatro artefatos gerados em `<projeto-teste>/.codeflow/`.
- Resultado da validação de cada um (§2.1.6, §2.2.6, §2.3.6, §2.4.6).
- Resultado da validação §V.5.6.
- Se houve correção em `discover/SKILL.md`: hash do commit de correção.
```

---

### §P.5.7 — Limpeza, log de execução e tag de versão

```markdown
## Objetivo
Consolidar a construção: decidir destino do projeto de teste, registrar log de execução (opcional), criar tag `v1.0.0`.

## Pré-leitura obrigatória
- `andaime/BUILD_PLAN.md` §F5.7.
- `andaime/VALIDATION.md` §V.5.7.
- `andaime/VALIDATION.md` §V.T.1 a §V.T.8 (suite transversal — executar antes da tag).

## Tarefa
1. Confirmar que F5.6 foi concluída.
2. **Executar suite transversal completa**: `VALIDATION.md` §V.T.1 a §V.T.7. Se qualquer uma falha, parar e corrigir antes de prosseguir.
3. Perguntar ao mantenedor o destino do projeto de teste:
   - Opção A (default): deletar.
   - Opção B: arquivar em `~/Projetos/codeflow/exemplos/projeto-teste/` (exige decisão registrada).
4. Aguardar resposta. Aplicar a opção escolhida.
5. **Finalizar** `~/Projetos/codeflow/andaime/EXECUTION_LOG.md` (obrigatório; criado em F1.1 e atualizado a cada etapa concluída): preencher data de conclusão, garantir que todas as etapas executadas estejam registradas com status `[✓]`/`[—]`/`⚠` e notas sobre decisões tomadas.
6. Criar tag git anotada: `git tag -a v1.0.0 -m "Framework codeflow v1.0.0 — escopo inicial"`.
7. Confirmar com o mantenedor antes de fazer push para remoto (se configurado).

## Critério de sucesso
Executar `VALIDATION.md` §V.5.7. Snippet retorna `OK: §V.5.7`. Itens de inspeção marcados (incluindo: pelo menos um commit por etapa com `Commit sugerido` não-vazio — tipicamente ~14 commits). Suite transversal §V.T.1 a §V.T.7 todas com `OK`.

## Em caso de ambiguidade
- Destino do projeto de teste: perguntar antes de qualquer ação destrutiva.
- Se a suite transversal falha em qualquer ponto: parar imediatamente, reportar. Não criar a tag.
- Push para remoto: confirmar antes. Repositório pode ainda não ter remoto configurado.

## Saída esperada
- Resultado completo da suite transversal (§V.T.1 a §V.T.7).
- Decisão sobre o projeto de teste (deletado ou arquivado) registrada.
- Conteúdo final do `EXECUTION_LOG.md`.
- Output de `git tag -l v1.0.0` e `git log --oneline`.
- Resultado da validação §V.5.7.
- **Nota final**: framework codeflow v1.0.0 pronto para uso.
```

---

## Fim do PROMPTS.md
