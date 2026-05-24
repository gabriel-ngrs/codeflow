---
versão: 1.0
status: estável
atualizado: 2026-05-23
---

# Roteiro de testes manuais — codeflow

Roteiro para validar o framework em um **projeto real**, executado por você (humano). Substitui o teste sintético previsto em F5.6 (`/tmp/codeflow-test`), que era execução simulada por IA sobre projeto-cobaia.

## Pré-requisitos

1. **Projeto-alvo:** repositório git real ao qual você queira aplicar o codeflow.
   - Tamanho recomendado: pequeno a médio (alguns milhares de linhas).
   - Ter `Makefile` ou estar disposto a criar um simples durante o teste.
   - **Precaução:** crie um branch dedicado antes (`git checkout -b codeflow-test`). O codeflow só escreve em `.codeflow/` e `.gitignore`, mas a precaução é barata.

2. **Framework instalado:** `ls ~/.codeflow/` deve listar `andaime/`, `framework/`, `install.sh`. Se não, o symlink quebrou — refazer F1.4.

3. **Claude Code aberto no diretório do projeto-alvo** (não no `~/projetos/codeflow/`).

## Como invocar uma meta-skill, workflow ou skill

O codeflow **ainda não registra slash-commands automaticamente** em Claude Code. Cada artefato é invocado manualmente, instruindo o agente a ler o arquivo:

> "Leia `~/.codeflow/framework/meta/<nome>/SKILL.md` e execute o protocolo descrito, aplicando ao projeto atual."

Substitua o caminho conforme o tipo:

- Meta-skill: `~/.codeflow/framework/meta/<nome>/SKILL.md`
- Workflow universal: `~/.codeflow/framework/library/workflows/<nome>.md`
- Skill universal: `~/.codeflow/framework/library/skills/<nome>/SKILL.md`

## Convenções

- ✓ = passou; ⚠ = passou com ressalva; ✗ = falhou.
- Cada teste declara **Objetivo**, **Passos**, **Resultado esperado**, **O que reportar**, **Sinais de alerta**.
- Se um teste falha de forma bloqueante, pode parar e reportar — não precisa terminar todos.

---

## Teste 1 — `install.sh` em projeto real

**Objetivo:** confirmar que `install.sh` cria `.codeflow/` sem modificar nenhum arquivo do projeto além de `.gitignore`.

**Passos:**

1. `cd <projeto-alvo>`
2. `git status` — anote o estado.
3. `bash ~/.codeflow/install.sh` — observe a saída.
4. `git status` de novo.
5. `ls -la .codeflow/`
6. `grep codeflow .gitignore` — confirme entrada de `.codeflow/checkpoints/`.
7. `cat .codeflow/INDEX.md` — deve ser placeholder.
8. Rode uma 2ª vez: `bash ~/.codeflow/install.sh` (idempotência).

**Resultado esperado:**

- Mensagens pt-BR com `✓` em cada verificação; final cita `/discover` ou `/bootstrap`.
- `.codeflow/INDEX.md` (placeholder), `.codeflow/decisions/`, `.codeflow/checkpoints/` criados.
- `.gitignore` contém `.codeflow/checkpoints/`.
- `git status` mostra **apenas** `.codeflow/` e `.gitignore` como mudanças. Código-fonte, README, CLAUDE.md etc. intocados.
- 2ª execução: mensagens mudam para "já existe — preservado"; nada duplicado; `rc=0`.

**O que reportar:** saída completa das duas execuções, `git status` antes/depois, confirmação de não-modificação.

**Sinais de alerta (✗):** qualquer arquivo do projeto modificado fora de `.codeflow/`, `.gitignore` e (se aplicável) `.claude/commands/`; criação de `constitution.md`, `manifest.md` ou `discovered.md` (esses dependem de `/discover` ou `/bootstrap`, nunca de `install.sh`); chamada a `git init`.

---

## Teste 1.5 — Slash commands universais

**Objetivo:** confirmar que após rodar `setup-slash-commands.sh` os workflows e meta-skills aparecem como slash commands nativos em Claude Code (`/bugfix`, `/discover` etc.).

**Passos:**

1. Rode uma vez por máquina (idempotente): `bash ~/.codeflow/setup-slash-commands.sh`.
2. Liste os wrappers: `ls ~/.claude/commands/ | grep -E '(bugfix|feature-small|refactor-safe|review-only|discover|bootstrap|create-)'`.
3. Inspecione um wrapper: `cat ~/.claude/commands/bugfix.md` — deve ter 1 linha em pt-BR começando com `Leia ~/.codeflow/framework/library/workflows/bugfix.md`.
4. Abra Claude Code em qualquer projeto. Digite `/` e confirme que `/bugfix`, `/discover`, `/create-workflow` aparecem na lista.
5. (Opcional) Digite `/bugfix` em sessão fresca e verifique que o agente lê o workflow real e começa o protocolo.
6. Idempotência: rode `bash ~/.codeflow/setup-slash-commands.sh` de novo — saída muda para "preservado", nenhuma duplicação.

**Resultado esperado:**

- 9 wrappers em `~/.claude/commands/` (4 workflows seed + 5 meta-skills seed).
- Cada wrapper tem 1-2 linhas, referencia path absoluto em `~/.codeflow/framework/`.
- Slash commands aparecem em Claude Code sem reiniciar.
- 2ª execução: 9 preservados, 0 criados, 0 duplicados.

**O que reportar:** saída do `setup-slash-commands.sh`; lista de `ls ~/.claude/commands/`; um exemplo de wrapper; confirmação de que `/bugfix` aparece no Claude Code.

**Sinais de alerta (✗):**

- Wrapper duplica conteúdo do workflow em vez de apontar para o path.
- Wrapper tem mais de 6 linhas.
- Slash command não aparece em Claude Code mesmo com wrapper presente (problema da ferramenta, não do codeflow — checar versão do Claude Code).

---

## Teste 2 — `discover` end-to-end (TESTE PRINCIPAL)

**Objetivo:** validar que a meta-skill `discover` gera quatro artefatos (`constitution.md`, `manifest.md`, `INDEX.md`, `discovered.md`) coerentes com a realidade do projeto.

**Passos:**

1. No Claude Code, no projeto-alvo, instrua:
   > "Leia `~/.codeflow/framework/meta/discover/SKILL.md` e execute o protocolo no projeto atual."
2. A IA deve fazer **Fase 1 — Inspeção silenciosa** (lê arquivos, mapeia estrutura, examina commits) **sem te interromper**.
3. A IA deve fazer **Fase 2 — Entrevista** com no máximo **5 perguntas**, baseadas em hipóteses específicas formadas na inspeção. Deve **pausar aguardando sua confirmação** antes da Fase 3.
4. Responda as perguntas; confirme o resumo.
5. A IA gera `constitution.md`, `manifest.md`, `INDEX.md` em `<projeto>/.codeflow/`.
6. A IA gera `discovered.md` e apresenta resumo final dos 4 arquivos.

**Resultado esperado:**

- **≤ 5 perguntas**, específicas, não genéricas. Cada uma cita o que a inspeção encontrou que motivou a pergunta.
- **Pausa explícita** antes da Fase 3 aguardando sua confirmação.
- `constitution.md` declara apenas regras que você **confirmou** ou que foram **observadas direto no código** (sem invenção).
- `manifest.md` lista versões reais da stack (`Python 3.11.5`, não `Python`), e tem `validation_hash` em hex de 64 caracteres.
- `INDEX.md` lista `constitution.md` e `manifest.md` em "Leia sempre primeiro".
- `discovered.md` registra inspeção, hipóteses (cada uma com rótulo `[confirmada]`/`[refutada]`/`[pendente]`), e o diálogo Q/R.

**O que reportar:**

- Conteúdo dos 4 arquivos.
- A IA seguiu o protocolo sem improvisar?
- Alguma pergunta foi desnecessária? Faltou alguma crítica?
- Algum artefato contém afirmação **falsa** sobre o projeto?
- Tempo aproximado da inspeção e da entrevista.

**Sinais de alerta (✗):**

- IA pula Fase 1 e vai direto perguntar.
- Mais de 5 perguntas.
- Não pausa antes da Fase 3.
- `constitution.md` declara regras não-confirmadas.
- `manifest.md` afirma versões de bibliotecas que não estão no projeto.
- `validation_hash` ausente ou em formato errado.

---

## Teste 3 — Workflow `review-only`

**Objetivo:** workflow magro (sem decisão, leitura-only) funciona em diff real.

**Passos:**

1. Faça uma mudança pequena e real no projeto (edite uma função, corrija typo, mude comentário). **Não** faça commit ainda.
2. Em Claude Code:
   > "Leia `~/.codeflow/framework/library/workflows/review-only.md` e aplique ao meu `git diff` atual."
3. Observe a revisão emitida.

**Resultado esperado:**

- Revisão estruturada conforme os passos do workflow.
- **Nenhum arquivo modificado** pela IA (review-only é leitura).
- **Nenhum decision** gerado em `.codeflow/decisions/` (`gera_decision: no`).
- A IA carregou `constitution.md` (universal + projeto) e os rules relevantes antes da revisão (pode confirmar perguntando).

**O que reportar:** a revisão emitida; a IA respeitou que não devia modificar código?; a revisão foi útil ou genérica?

**Sinais de alerta (✗):** IA propõe ou aplica edits no código; IA cria decision; IA ignora `constitution.md`.

---

## Teste 4 — `create-skill` (criar skill no nível de projeto)

**Objetivo:** validar que `create-skill` cria nova skill **a nível de projeto** (não universal) e faz qualificação antes de criar.

**Passos:**

1. Pense em uma tarefa repetitiva específica do seu projeto não coberta por skill existente (ex: "validar formato de migração antes de aplicar", "preparar checklist de release").
2. Em Claude Code:
   > "Leia `~/.codeflow/framework/meta/create-skill/SKILL.md` e crie uma skill chamada `<X>` que faça `<Y>` neste projeto."
3. A IA deve **primeiro qualificar**: a tarefa cabe em workflow ou rule existente? Skill é mesmo o tipo certo?
4. Se sim, faz perguntas, gera `SKILL.md` em `<projeto>/.codeflow/skills/<X>/SKILL.md` e valida.

**Resultado esperado:**

- IA **qualifica antes** de criar (não vai direto criar).
- Skill criada em `<projeto>/.codeflow/skills/<X>/SKILL.md`, **não** em `~/.codeflow/framework/library/skills/`.
- 6 seções obrigatórias, **sem** `## Definition of Done`, **sem** `## LEIA TAMBÉM`.
- Frontmatter com `descrição` (uma linha).
- **NÃO** é gerado wrapper em `~/.claude/commands/<X>.md` nem em `<projeto>/.claude/commands/<X>.md` — skills regulares não viram slash command (`SPEC.md` §3.6.1). Verifique: `ls ~/.claude/commands/ | grep <X>` deve ser vazio.

**O que reportar:** a skill gerada; a qualificação inicial foi útil ou pulada?; a IA tentou pôr em `framework/library/`?

**Sinais de alerta (✗):**

- IA cria diretamente em `~/.codeflow/framework/library/skills/` (viola política de evolução — promoção exige uso em 2 projetos distintos, ver `framework/core/EVOLUTION.md`).
- IA não qualifica antes.
- Skill com `## Definition of Done` ou `## LEIA TAMBÉM`.

---

## Teste 5 (opcional) — Workflow `bugfix` com decision

**Objetivo:** workflow médio com geração automática de decision em pontos não-óbvios.

**Passos:**

1. Identifique (ou simule) um bug real no projeto.
2. Em Claude Code:
   > "Leia `~/.codeflow/framework/library/workflows/bugfix.md` e aplique para corrigir: `<descrição do bug>`."
3. Acompanhe os passos.

**Resultado esperado:**

- Workflow segue o esqueleto (reprodução, isolamento, fix mínimo, teste).
- Em escolhas não-óbvias (ex: qual abordagem entre duas), gera arquivo em `.codeflow/decisions/<data>-<titulo>.md`.
- Definition of Done verificada antes de declarar pronto.

**O que reportar:** a correção fez sentido?; quantos decisions foram gerados — úteis ou ruidosos?; workflow respeitou os passos?

---

## Teste 7 (opcional) — Workflow de projeto com slash command

**Objetivo:** validar que workflow criado a nível de projeto vira slash command local automaticamente.

**Passos:**

1. Em Claude Code, no projeto-alvo:
   > "Leia `~/.codeflow/framework/meta/create-workflow/SKILL.md` e crie um workflow chamado `<Z>` específico deste projeto."
2. Confirme destino "projeto" (não universal). O arquivo deve aparecer em `<projeto>/.codeflow/workflows/<Z>.md`.
3. Rode `bash ~/.codeflow/install.sh` novamente no projeto.
4. Verifique que `<projeto>/.claude/commands/<Z>.md` foi criado.
5. Em Claude Code, dentro do projeto, digite `/` e confirme que `/<Z>` aparece.
6. Mude para outro projeto: `/<Z>` **não** deve aparecer ali (é local).

**Resultado esperado:**

- Workflow em `.codeflow/workflows/<Z>.md` (versionado no projeto).
- Wrapper em `.claude/commands/<Z>.md` referenciando o path absoluto do workflow.
- Slash command `/<Z>` disponível apenas dentro do projeto.
- `install.sh` sugere decisão sobre `.gitignore` para `.claude/commands/` mas não força.

**O que reportar:** o workflow criado; output do `install.sh` na 2ª rodada; confirmação de que `/<Z>` é local.

---

## Teste 6 — Desinstalação manual

Para remover o codeflow do projeto após o teste:

1. `rm -rf .codeflow/`
2. Edite `.gitignore` removendo a linha `.codeflow/checkpoints/` (ou apague o `.gitignore` se foi criado só pelo install).

Não há `uninstall.sh` — a desinstalação é trivial.

---

## Como reportar os achados

Para cada teste, registre:

```
### Teste N — <nome>
Status: ✓ / ⚠ / ✗
Notas:
- <observação>
Sinais de alerta encontrados:
- <se algum>
```

Achados consolidados ao final:

- **Bugs encontrados** — lista numerada, com indicação de qual artefato corrigir (`install.sh`? `meta/discover/SKILL.md`? rule específica?).
- **Atritos de UX** — pontos onde a IA hesita, pergunta demais, perde tempo.
- **Sugestões de melhoria.**

Salve o relatório em `andaime/tests/RELATORIO-<data>.md` para histórico.

---

## Próximos passos após o teste

- **Tudo passou:** pode prosseguir para F5.7 (suite transversal `§V.T.*` + tag `v1.0.0`).
- **Bug em meta-skill:** corrigir o `SKILL.md` correspondente, commit `fix(meta/<nome>): <descrição>`, opcionalmente refazer o teste.
- **Bug em `install.sh`:** corrigir, commit `fix(install): ...`, repetir Teste 1.
- **`constitution`/`manifest` pobre:** defeito provavelmente está no protocolo de `discover`, não na escrita da IA — corrigir `framework/meta/discover/SKILL.md`.
