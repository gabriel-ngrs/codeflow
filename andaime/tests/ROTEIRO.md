---
versão: 1.2
status: estável
atualizado: 2026-05-26
---

# Roteiro de testes manuais — codeflow

Roteiro para validar o framework em um **projeto real**, executado por você (humano). Substitui o teste sintético previsto em F5.6 (`/tmp/codeflow-test`), que era execução simulada por IA sobre projeto-cobaia.

**Cobertura:** v1.1 do roteiro cobre todos os artefatos seed do framework — 5 meta-skills, 4 workflows universais, 3 skills universais, 2 scripts shell. Testes 1, 1.5, 2, 3, 4, 8, 9, 10, 11, 12 são canônicos; 5 e 7 são opcionais. Teste 6 documenta desinstalação. **Camada comportamental** (julgamento sobre saída da IA) só é validável manualmente; **camada estrutural** (formato, paths, exit codes, idempotência) pode ser automatizada (ver §"Próximos passos após o teste").

## Pré-requisitos

1. **Projeto-alvo:** repositório git real ao qual você queira aplicar o codeflow.
   - Tamanho recomendado: pequeno a médio (alguns milhares de linhas).
   - Ter `Makefile` ou estar disposto a criar um simples durante o teste.
   - **Precaução:** crie um branch dedicado antes (`git checkout -b codeflow-test`). O codeflow só escreve em `.codeflow/` e `.gitignore`, mas a precaução é barata.

2. **Framework instalado:** `ls ~/.codeflow/` deve listar `andaime/`, `framework/`, `install.sh`. Se não, o symlink quebrou — refazer F1.4.

3. **Claude Code aberto no diretório do projeto-alvo** (não no `~/projetos/codeflow/`).

## Como invocar uma meta-skill, workflow ou skill

A partir de F5.8/F5.9, **workflows universais e meta-skills viram slash commands nativos** após `bash ~/.codeflow/setup-slash-commands.sh` (uma vez por máquina) — basta digitar `/bugfix`, `/discover`, `/create-workflow` etc.

Skills regulares (`debug-protocol`, `handoff`, `self-review`) **não** ganham slash command — são invocadas indiretamente por workflows via `LEIA TAMBÉM`, ou explicitamente por prompt quando for o caso:

> "Leia `~/.codeflow/framework/library/skills/<nome>/SKILL.md` e aplique o protocolo agora."

Caminhos absolutos por tipo (para referência ou fallback):

- Meta-skill: `~/.codeflow/framework/meta/<nome>/SKILL.md`
- Workflow universal: `~/.codeflow/framework/library/workflows/<nome>.md`
- Skill universal: `~/.codeflow/framework/library/skills/<nome>/SKILL.md`

## Convenções

- ✓ = passou; ⚠ = passou com ressalva; ✗ = falhou.
- Cada teste declara **Objetivo**, **Passos**, **Resultado esperado**, **O que reportar**, **Sinais de alerta**.
- Se um teste falha de forma bloqueante, pode parar e reportar — não precisa terminar todos.

### Tags de delegação

Cada passo e cada verificação carrega uma tag que indica quem executa:

- **`[IA]`** — passo determinístico (rodar shell, comparar output, checar formato/path). Delegue a uma sessão de Claude Code: cola o prompt canônico (ver §"Prompts de delegação" no final), recebe relatório ✓/✗ com evidência. Não exige sua presença durante a execução.
- **`[IA-EXTERNA]`** — verificação sobre o **comportamento ou saída** de uma execução de protocolo. Precisa rodar em **sessão nova de Claude Code**, sem ter lido o `SKILL.md` testado (evita conflito de interesse: a IA que executou o protocolo não pode auto-julgar se o seguiu). Cola o prompt canônico, recebe relatório.
- **`[HUMANO]`** — passo que exige seu julgamento sobre o projeto real, sua observação visual da UI do Claude Code, ou sua interação como usuário (responder perguntas de uma meta-skill, por exemplo). Não delegável.

Cobertura média estimada: ~55% `[IA]` direta, ~20% `[IA-EXTERNA]`, ~25% `[HUMANO]`.

---

## Teste 1 — `install.sh` em projeto real

**Objetivo:** confirmar que `install.sh` cria `.codeflow/` sem modificar nenhum arquivo do projeto além de `.gitignore`.

**Delegação:** `[IA]` 100%. Use o prompt §P1 (em "Prompts de delegação"). Você não precisa estar presente.

**Passos:**

1. `[IA]` `cd <projeto-alvo>` (pode ser projeto real ou tmpdir com `git init`).
2. `[IA]` `git status` — anota o estado.
3. `[IA]` `bash ~/.codeflow/install.sh` — observa a saída.
4. `[IA]` `git status` de novo.
5. `[IA]` `ls -la .codeflow/`
6. `[IA]` `grep codeflow .gitignore` — confirma entrada de `.codeflow/checkpoints/`.
7. `[IA]` `cat .codeflow/INDEX.md` — deve ser placeholder.
8. `[IA]` Rode uma 2ª vez: `bash ~/.codeflow/install.sh` (idempotência).

**Resultado esperado:**

- `[IA]` Mensagens pt-BR com `✓` em cada verificação; final cita `/discover` ou `/bootstrap`.
- `[IA]` `.codeflow/INDEX.md` (placeholder), `.codeflow/decisions/`, `.codeflow/checkpoints/` criados.
- `[IA]` `.gitignore` contém `.codeflow/checkpoints/`.
- `[IA]` `git status` mostra **apenas** `.codeflow/` e `.gitignore` como mudanças. Código-fonte, README, CLAUDE.md etc. intocados.
- `[IA]` 2ª execução: mensagens mudam para "já existe — preservado"; nada duplicado; `rc=0`.

**O que reportar:** `[IA]` saída completa das duas execuções, `git status` antes/depois, confirmação de não-modificação.

**Sinais de alerta (✗):** qualquer arquivo do projeto modificado fora de `.codeflow/`, `.gitignore` e (se aplicável) `.claude/commands/`; criação de `constitution.md`, `manifest.md` ou `discovered.md` (esses dependem de `/discover` ou `/bootstrap`, nunca de `install.sh`); chamada a `git init`.

---

## Teste 1.5 — Slash commands universais

**Objetivo:** confirmar que após rodar `setup-slash-commands.sh` os workflows e meta-skills aparecem como slash commands nativos em Claude Code (`/bugfix`, `/discover` etc.).

**Delegação:** ~95% `[IA]` + ~5% `[HUMANO]` (checagem visual no menu). Use o prompt §P1.5.

**Passos:**

1. `[IA]` Rode uma vez por máquina (idempotente): `bash ~/.codeflow/setup-slash-commands.sh`.
2. `[IA]` Liste os wrappers: `ls ~/.claude/commands/ | grep -E '(bugfix|feature-small|refactor-safe|review-only|discover|bootstrap|create-)'`.
3. `[IA]` Inspecione um wrapper: `cat ~/.claude/commands/bugfix.md` — deve ter 1 linha em pt-BR começando com `Leia ~/.codeflow/framework/library/workflows/bugfix.md`.
4. `[HUMANO]` Abra Claude Code em qualquer projeto. Digite `/` e confirme visualmente que `/bugfix`, `/discover`, `/create-workflow` aparecem na lista.
5. `[HUMANO]` (Opcional) Digite `/bugfix` em sessão fresca e verifique que o agente lê o workflow real e começa o protocolo.
6. `[IA]` Idempotência: rode `bash ~/.codeflow/setup-slash-commands.sh` de novo — saída muda para "preservado", nenhuma duplicação.

**Resultado esperado:**

- `[IA]` 9 wrappers em `~/.claude/commands/` (4 workflows seed + 5 meta-skills seed).
- `[IA]` Cada wrapper tem 1-2 linhas, referencia path absoluto em `~/.codeflow/framework/`.
- `[HUMANO]` Slash commands aparecem em Claude Code sem reiniciar.
- `[IA]` 2ª execução: 9 preservados, 0 criados, 0 duplicados.

**O que reportar:** `[IA]` saída do `setup-slash-commands.sh`; lista de `ls ~/.claude/commands/`; um exemplo de wrapper. `[HUMANO]` confirmação de que `/bugfix` aparece no menu do Claude Code.

**Sinais de alerta (✗):**

- Wrapper duplica conteúdo do workflow em vez de apontar para o path.
- Wrapper tem mais de 6 linhas.
- Slash command não aparece em Claude Code mesmo com wrapper presente (problema da ferramenta, não do codeflow — checar versão do Claude Code).

---

## Teste 2 — `discover` end-to-end (TESTE PRINCIPAL)

**Objetivo:** validar que a meta-skill `discover` gera quatro artefatos (`constitution.md`, `manifest.md`, `INDEX.md`, `discovered.md`) coerentes com a realidade do projeto.

**Delegação:** ~50% `[IA-EXTERNA]` (validação estrutural pós-execução) + ~50% `[HUMANO]` (executar o protocolo respondendo perguntas; julgar veracidade sobre o projeto). Use o prompt §P2 para a validação estrutural após a execução.

**Passos:**

1. `[HUMANO]` No Claude Code, no projeto-alvo, digite `/discover`.
2. `[HUMANO]` Observe a Fase 1 — Inspeção silenciosa. A IA deve ler arquivos, mapear estrutura, examinar commits **sem te interromper**.
3. `[HUMANO]` Conduza a Fase 2 — Entrevista. A IA deve fazer até **5 perguntas** como orientação (sem limite duro), específicas baseadas em hipóteses da inspeção. Se chegar à 5ª, deve emitir aviso. Force deliberadamente ao menos uma resposta de incerteza (`não sei` / `o que você recomenda` / `usa o padrão` / `depois eu decido`) para exercitar o vocabulário.
4. `[HUMANO]` Responda as perguntas; confirme o resumo na pausa pré-Fase 3.
5. `[HUMANO]` A IA gera `constitution.md`, `manifest.md`, `INDEX.md` em `<projeto>/.codeflow/`.
6. `[HUMANO]` A IA gera `discovered.md` e apresenta resumo final dos 4 arquivos.

**Resultado esperado:**

- `[HUMANO]` **Orientação ≤ 5 perguntas**, específicas, não genéricas; quando passar, aviso obrigatório seguido de justificativa em `## Limitações da inspeção` do discovered. Cada pergunta cita o que a inspeção encontrou que motivou.
- `[HUMANO]` **Pausa explícita** antes da Fase 3 aguardando sua confirmação.
- `[HUMANO]` `constitution.md` declara apenas regras que você **confirmou** ou que foram **observadas direto no código** (sem invenção). [HUMANO porque exige conhecer o projeto]
- `[IA-EXTERNA]` `manifest.md` tem `validation_hash` em hex de 64 caracteres; versões com número (não placeholders como `Python` solto).
- `[IA-EXTERNA]` `INDEX.md` lista `constitution.md` e `manifest.md` em "Leia sempre primeiro".
- `[IA-EXTERNA]` `discovered.md` contém seções: inspeção, hipóteses com rótulo `[confirmada]`/`[refutada]`/`[pendente]`, diálogo Q/R.
- `[IA-EXTERNA]` Para cada hipótese marcada `[pendente]`, **não** há regra correspondente na constitution.

**O que reportar:**

- `[IA-EXTERNA]` Estrutura de cada um dos 4 arquivos: presença de seções obrigatórias, formato do hash, rotulação das hipóteses.
- `[HUMANO]` A IA seguiu o protocolo? Como reagiu à resposta de incerteza?
- `[HUMANO]` Alguma pergunta foi desnecessária? Faltou alguma crítica?
- `[HUMANO]` Algum artefato contém afirmação **falsa** sobre o seu projeto?
- `[HUMANO]` Tempo aproximado da inspeção e da entrevista.

**Sinais de alerta (✗):**

- IA pula Fase 1 e vai direto perguntar.
- Mais de 5 perguntas **sem** o aviso intermediário e **sem** justificativa em `## Limitações da inspeção`.
- IA insiste/re-pergunta após resposta de incerteza (`não sei`, `passa`) em vez de marcar hipótese como `[pendente]` e seguir.
- IA gera regra em `constitution.md` baseada em hipótese `[pendente]`.
- Não pausa antes da Fase 3.
- `constitution.md` declara regras não-confirmadas.
- `manifest.md` afirma versões de bibliotecas que não estão no projeto.
- `validation_hash` ausente ou em formato errado.

---

## Teste 3 — Workflow `review-only`

**Objetivo:** workflow magro (sem decisão, leitura-only) funciona em diff real.

**Delegação:** ~70% `[IA]` (smoke + validação de "não modificou") + ~30% `[HUMANO]` (julgar utilidade da revisão).

**Passos:**

1. `[HUMANO]` Faça uma mudança pequena e real no projeto (edite uma função, corrija typo, mude comentário). **Não** faça commit ainda.
2. `[HUMANO]` Em Claude Code: digite `/review-only`.
3. `[HUMANO]` Observe a revisão emitida.

**Resultado esperado:**

- `[HUMANO]` Revisão estruturada conforme os passos do workflow.
- `[IA]` **Nenhum arquivo modificado** pela IA (`git status` mostra mesmas modificações de antes da execução).
- `[IA]` **Nenhum decision** gerado em `.codeflow/decisions/` (`gera_decision: no`).
- `[IA-EXTERNA]` A revisão menciona claramente as regras de `constitution.md` que aplicou (pode-se confirmar lendo o output).

**O que reportar:** `[HUMANO]` a revisão emitida + se a IA respeitou que não devia modificar + se a revisão foi útil ou genérica. `[IA]` `git status` + `ls .codeflow/decisions/` após execução.

**Sinais de alerta (✗):** IA propõe ou aplica edits no código; IA cria decision; IA ignora `constitution.md`.

---

## Teste 4 — `create-skill` (criar skill no nível de projeto)

**Objetivo:** validar que `create-skill` cria nova skill **a nível de projeto** (não universal) e faz qualificação antes de criar.

**Delegação:** ~70% `[IA]` (validar formato/path/ausência de wrapper) + ~20% `[IA-EXTERNA]` (qualificação ocorreu?) + ~10% `[HUMANO]` (escolher tarefa).

**Passos:**

1. `[HUMANO]` Pense em uma tarefa repetitiva específica do seu projeto não coberta por skill existente (ex: "validar formato de migração antes de aplicar", "preparar checklist de release").
2. `[HUMANO]` Em Claude Code: digite `/create-skill` e descreva a tarefa quando solicitado.
3. `[HUMANO]` A IA deve **primeiro qualificar**: a tarefa cabe em workflow ou rule existente? Skill é mesmo o tipo certo?
4. `[HUMANO]` Se sim, responde perguntas; IA gera `SKILL.md` em `<projeto>/.codeflow/skills/<X>/SKILL.md`.

**Resultado esperado:**

- `[IA-EXTERNA]` IA **qualifica antes** de criar (transcript mostra perguntas de qualificação antes de qualquer geração de arquivo).
- `[IA]` Skill criada em `<projeto>/.codeflow/skills/<X>/SKILL.md`, **não** em `~/.codeflow/framework/library/skills/`.
- `[IA]` 6 seções obrigatórias presentes; **sem** `## Definition of Done`; **sem** `## LEIA TAMBÉM` no formato proibido.
- `[IA]` Frontmatter com `descrição` em uma linha.
- `[IA]` **NÃO** existe wrapper em `~/.claude/commands/<X>.md` nem em `<projeto>/.claude/commands/<X>.md` — `ls ~/.claude/commands/ | grep <X>` retorna vazio.

**O que reportar:** `[IA]` skill gerada (caminho + conteúdo) + ausência de wrapper. `[HUMANO]` a qualificação inicial foi útil ou pulada?; a IA tentou pôr em `framework/library/`?

**Sinais de alerta (✗):**

- IA cria diretamente em `~/.codeflow/framework/library/skills/` (viola política de evolução — promoção exige uso em 2 projetos distintos, ver `framework/core/EVOLUTION.md`).
- IA não qualifica antes.
- Skill com `## Definition of Done` ou `## LEIA TAMBÉM`.

---

## Teste 5 (opcional) — Workflow `bugfix` com decision

**Objetivo:** workflow médio com geração automática de decision em pontos não-óbvios.

**Delegação:** ~60% `[IA]` (validar decision + DoD + teste novo) + ~10% `[IA-EXTERNA]` (workflow seguido?) + ~30% `[HUMANO]` (foi causa raiz ou superficial?).

**Passos:**

1. `[HUMANO]` Identifique (ou simule) um bug real no projeto.
2. `[HUMANO]` Em Claude Code: digite `/bugfix` e descreva o bug.
3. `[HUMANO]` Acompanhe os passos do workflow.

**Resultado esperado:**

- `[IA-EXTERNA]` Workflow segue o esqueleto (reprodução, isolamento, fix mínimo, teste) — verificável no transcript.
- `[IA]` Em escolhas não-óbvias, existe pelo menos um arquivo em `.codeflow/decisions/<data>-<titulo>.md` criado nesta sessão.
- `[IA]` Definition of Done verificada antes do "pronto" (`make check` ou equivalente verde).
- `[IA]` Teste de regressão adicionado cobrindo o caso reportado.

**O que reportar:** `[IA]` decisions criados + diff do teste + saída do `make check`. `[HUMANO]` a correção foi causa raiz ou cosmética?; decisions úteis ou ruidosos?

---

## Teste 7 (opcional) — Workflow de projeto com slash command

**Objetivo:** validar que workflow criado a nível de projeto vira slash command local automaticamente.

**Delegação:** ~80% `[IA]` (validar arquivo + wrapper + paths) + ~20% `[HUMANO]` (confirmação visual no menu, escopo local).

**Passos:**

1. `[HUMANO]` Em Claude Code, no projeto-alvo: digite `/create-workflow` e descreva o workflow específico do projeto.
2. `[HUMANO]` Confirme destino "projeto" (não universal). O arquivo deve aparecer em `<projeto>/.codeflow/workflows/<Z>.md`.
3. `[IA]` Rode `bash ~/.codeflow/install.sh` novamente no projeto.
4. `[IA]` Verifique que `<projeto>/.claude/commands/<Z>.md` foi criado.
5. `[HUMANO]` Em Claude Code, dentro do projeto, digite `/` e confirme visualmente que `/<Z>` aparece.
6. `[HUMANO]` Mude para outro projeto: `/<Z>` **não** deve aparecer ali (é local).

**Resultado esperado:**

- `[IA]` Workflow em `.codeflow/workflows/<Z>.md` (versionado no projeto).
- `[IA]` Wrapper em `.claude/commands/<Z>.md` referenciando o path absoluto do workflow (não `~/...`).
- `[HUMANO]` Slash command `/<Z>` disponível apenas dentro do projeto.
- `[IA]` `install.sh` exibe aviso sobre `.gitignore` para `.claude/commands/` mas não força.

**O que reportar:** `[IA]` workflow criado + output do `install.sh` na 2ª rodada + path do wrapper. `[HUMANO]` confirmação visual de que `/<Z>` é local.

---

## Teste 8 — Workflow `/feature-small` end-to-end

**Objetivo:** validar workflow médio que implementa feature pequena com decisions automáticas e self-review.

**Delegação:** ~60% `[IA]` (teste novo, decision, make check) + ~20% `[IA-EXTERNA]` (self-review aplicado no transcript?) + ~20% `[HUMANO]` (refactor lateral?).

**Passos:**

1. `[HUMANO]` Identifique uma feature pequena real no projeto (1-3 arquivos, interface clara, sem decisão arquitetural maior).
2. `[HUMANO]` Em Claude Code, no projeto-alvo: digite `/feature-small` e descreva a feature.
3. `[HUMANO]` Acompanhe o protocolo: a IA deve carregar `constitution.md` (universal + projeto) e rules relevantes, implementar o mínimo, adicionar teste, rodar `make check` (ou equivalente) e aplicar `self-review` antes do "pronto".

**Resultado esperado:**

- `[HUMANO]` Implementação cobre **exatamente** a feature pedida — sem refactor lateral, sem feature paralela, sem "while we're at it".
- `[IA]` Teste novo presente cobrindo o comportamento adicionado (verificável por `git diff` + execução).
- `[IA]` Em `.codeflow/decisions/` existe pelo menos um arquivo da sessão se houve escolha não-óbvia (`gera_decision: auto`).
- `[IA-EXTERNA]` Self-review aparece no transcript com ações explícitas (relê diff, checklist), não apenas menção.
- `[IA]` `make check` (ou comando canônico do projeto) verde antes do "pronto".

**O que reportar:** `[IA]` diff final + decisions criadas + saída do `make check`. `[IA-EXTERNA]` evidência do self-review no transcript. `[HUMANO]` algum refactor lateral indevido?

**Sinais de alerta (✗):**

- Refactor lateral fora do escopo declarado.
- Sem teste novo cobrindo a feature.
- Sem self-review antes de declarar pronto.
- Decision gerada para escolha trivial (ruído) ou ausente em escolha não-óbvia.
- IA ignora `constitution.md` ou rules relevantes.

---

## Teste 9 — Workflow `/refactor-safe`

**Objetivo:** validar workflow de refator com gate de cobertura — recusa quando suite é insuficiente.

**Delegação:** ~70% `[IA]` (suite, diff, ausência de decision) + ~20% `[IA-EXTERNA]` (recusa cenário B?) + ~10% `[HUMANO]` (escolher função coberta vs não-coberta).

**Passos:**

1. `[HUMANO]` **Cenário A (caminho feliz):** escolha uma função/módulo do projeto que tenha **cobertura de teste passando**. Em Claude Code: digite `/refactor-safe` e descreva (extrair função X, rename, divisão de função grande).
2. `[HUMANO]` Observe o protocolo: a IA deve confirmar cobertura antes de refatorar, rodar suite, aplicar mudança, rodar suite de novo.
3. `[HUMANO]` **Cenário B (gate de cobertura):** escolha um módulo propositalmente **sem testes** e peça refator nele.
4. `[HUMANO]` A IA deve **recusar** e redirecionar para `/feature-small` ou `/bugfix` para adicionar testes antes.

**Resultado esperado:**

- `[IA]` **Cenário A:** suite verde antes e depois (capturar exit code); diff minimalista (`git diff --stat`); nenhum decision gerado (`ls .codeflow/decisions/` sem arquivo novo).
- `[HUMANO]` **Cenário A:** comportamento observável idêntico (não é mais refator se mudou).
- `[IA-EXTERNA]` **Cenário B:** transcript contém recusa explícita citando ausência de cobertura; sugestão clara de próximo passo.

**O que reportar:** `[IA]` diff + saídas da suite (A) + decisions vazio. `[IA-EXTERNA]` texto da recusa (B). `[HUMANO]` comportamento preservado em A?

**Sinais de alerta (✗):**

- IA refatora sem checar cobertura.
- Diff muda comportamento observável (não é mais refator).
- Suite quebra após o refator.
- Decision criado em `.codeflow/decisions/` (refactor-safe é `gera_decision: no`).
- IA inclui melhorias oportunistas não-pedidas.
- IA **não** recusa no cenário B (refatora sem cobertura).

---

## Teste 10 — `/bootstrap` (projeto novo do zero)

**Objetivo:** validar meta-skill que cria projeto novo sem código pré-existente — contraparte do `/discover`.

**Delegação:** ~70% `[IA-EXTERNA]` (validar estrutura gerada) + ~15% `[HUMANO]` (executar fases interativas, julgar coerência) + ~15% `[IA]` (setup tmpdir).

**Passos:**

1. `[IA]` Em pasta vazia: `mkdir /tmp/codeflow-bootstrap-test && cd /tmp/codeflow-bootstrap-test && git init`.
2. `[HUMANO]` **Não** rode `install.sh` antes — `/bootstrap` cuida da estrutura.
3. `[HUMANO]` Abra Claude Code nessa pasta.
4. `[HUMANO]` Digite `/bootstrap` e descreva nome do projeto e propósito quando perguntado.
5. `[HUMANO]` A IA deve passar pelas **5 fases**, com pausas obrigatórias em Fase 1, 2 e 5:
   - Fase 1: coleta nome, propósito, tipo (CLI/lib/serviço/app/etc.), licença, idioma.
   - Fase 2: decide stack com base nas respostas; pede confirmação.
   - Fase 3: gera estrutura mínima (não só `.codeflow/`).
   - Fase 4: gera artefatos do `.codeflow/`: `constitution.md`, `manifest.md`, `INDEX.md`.
   - Fase 5: pausa final apresentando estado e próximos passos.
6. `[IA]` Verifique:
   - `ls -la` mostra arquivos do projeto + `.codeflow/`.
   - `test -f .codeflow/discovered.md && echo PRESENTE || echo AUSENTE` deve imprimir `AUSENTE` (esse arquivo **não** é gerado por bootstrap — `ARTIFACTS_SPEC.md` §2.4.1).
   - `cat Makefile` mostra 4 targets canônicos (check, test, lint, typecheck).

**Resultado esperado:**

- `[HUMANO]` 5 fases executadas com pausas em 1, 2, 5 observáveis na sessão.
- `[HUMANO]` Estrutura mínima coerente com o tipo de projeto declarado (não esqueleto genérico).
- `[IA]` Makefile canônico presente com os 4 targets.
- `[IA]` 3 artefatos em `.codeflow/`: `constitution.md`, `manifest.md`, `INDEX.md`. **NÃO** existe `discovered.md`.
- `[IA-EXTERNA]` `manifest.md` com versões reais decididas durante a Fase 2 (não placeholders); frontmatter completo; validation_hash em 64 hex.
- `[HUMANO]` `constitution.md` com regras mínimas declaradas, sem invenção sobre o domínio.

**O que reportar:** `[IA]` `tree -L 2 -a` + conteúdo dos 3 artefatos + confirmação de ausência de `discovered.md`. `[HUMANO]` observação das pausas + tempo total.

**Sinais de alerta (✗):**

- IA gera `discovered.md` (viola `ARTIFACTS_SPEC.md` §2.4.1 — bootstrap não inspeciona porque não há código pré-existente).
- Sem pausa nas Fases 1, 2, ou 5.
- Estrutura genérica que ignora o tipo de projeto declarado.
- Sem Makefile canônico (ou Makefile com targets diferentes dos 4).
- Constitution especulando regras não-confirmadas.
- IA pula a Fase 2 (escolhe stack sem confirmar).

---

## Teste 11 — `/create-agent` (foco em recusa)

**Objetivo:** validar que `create-agent` **recusa** criação quando skill regular bastaria — anti-padrão §1.10.7 do `ARTIFACTS_SPEC.md`.

**Delegação:** ~30% `[IA]` (validar ausência/presença de arquivos e wrappers) + ~40% `[IA-EXTERNA]` (recusa fez sentido?) + ~30% `[HUMANO]` (conduzir as duas tentativas).

**Passos:**

1. `[HUMANO]` **Tentativa 1 — esperada recusa:** em Claude Code digite `/create-agent` e proponha: *"criar um agent que aplique nosso checklist de revisão de código"*. (Esta tarefa **não** exige isolamento mecânico — skill regular basta.)
2. `[HUMANO]` A IA deve **qualificar** e **recusar**, redirecionando para `/create-skill`.
3. `[IA]` Verifique que nenhum arquivo de agent foi criado nesta tentativa.
4. `[HUMANO]` **Tentativa 2 — esperada aprovação:** digite `/create-agent` e proponha: *"criar um agent read-only que faça auditoria de dependências, sem capacidade de modificar nenhum arquivo do projeto"*. (Justifica isolamento mecânico — restrição de ferramentas a leitura.)
5. `[HUMANO]` A IA deve prosseguir e gerar o agent.
6. `[IA]` `ls ~/.claude/commands/ | grep <nome-do-agent>` deve retornar vazio — agents não ganham slash command.

**Resultado esperado:**

- `[IA-EXTERNA]` **Tentativa 1:** transcript contém recusa explícita citando que skill regular basta; sugere `/create-skill`.
- `[IA]` **Tentativa 1:** nenhum arquivo de agent criado (procurar em `~/.codeflow/framework/library/agents/` e `<projeto>/.codeflow/agents/`).
- `[IA]` **Tentativa 2:** arquivo de agent gerado em path correto.
- `[IA-EXTERNA]` **Tentativa 2:** arquivo contém seção de escopo de ferramentas restrito declarado.
- `[IA]` **Tentativa 2:** nenhum wrapper de slash command criado.

**O que reportar:** `[IA-EXTERNA]` texto da recusa (tentativa 1) + conteúdo do agent (tentativa 2). `[IA]` listagens de arquivos. `[HUMANO]` a recusa foi convincente?

**Sinais de alerta (✗):**

- IA cria agent para a tentativa 1 (deveria recusar — anti-padrão §1.10.7).
- IA recusa também a tentativa 2 (excesso de zelo).
- Agent gerado sem seção de escopo de ferramentas explícita.
- Agent ganhou slash command em `~/.claude/commands/`.

---

## Teste 12 — Skills carregadas (`handoff` + `self-review`)

**Objetivo:** validar que skills universais são **lidas e aplicadas** por workflows, não apenas citadas no `LEIA TAMBÉM`.

**Delegação:** ~30% `[IA]` (validação de formato) + ~40% `[IA-EXTERNA]` (campos do handoff vs SKILL.md; checklist self-review vs SKILL.md) + ~30% `[HUMANO]` (observar execução durante o workflow).

### Parte A — `self-review`

**Passos:**

1. `[HUMANO]` Rode `/feature-small` ou `/bugfix` no projeto-alvo (pode aproveitar o Teste 8).
2. `[HUMANO]` Imediatamente antes de a IA declarar "pronto", observe se ela aplica o protocolo de `self-review` de forma **visível**: reler o diff inteiro, aplicar checklist objetivo.
3. `[HUMANO]` Se houver dúvida, pergunte: *"qual checklist exato você aplicou?"*. Anote a resposta.

**Resultado esperado:**

- `[HUMANO]` Self-review é executado durante a sessão, não só citado. Ações observáveis: relê diff, lista verificações, declara achados.
- `[IA-EXTERNA]` Checklist citado/aplicado bate item a item com os passos de `~/.codeflow/framework/library/skills/self-review/SKILL.md`.

**Sinais de alerta (✗):**

- `[HUMANO]` IA diz "fiz self-review" sem ação visível.
- `[IA-EXTERNA]` Checklist citado difere do conteúdo do `SKILL.md`.

### Parte B — `handoff`

**Passos:**

1. `[HUMANO]` Crie uma situação de trabalho parcial real: rode `/feature-small` ou similar e **interrompa** quando estiver pela metade.
2. `[HUMANO]` Instrua: *"Termine esta sessão com um handoff conforme `~/.codeflow/framework/library/skills/handoff/SKILL.md`."*
3. `[HUMANO]` A IA deve gerar arquivo/bloco de handoff.

**Resultado esperado:**

- `[IA-EXTERNA]` Handoff segue o formato fixo do `SKILL.md`: estado em uma linha, próximo passo concreto, decisões em aberto. Conciso. Sem campos inventados.
- `[IA-EXTERNA]` Próximo passo é físico e específico (arquivo + ação ou comando), não "continuar trabalho".

**Sinais de alerta (✗):**

- `[IA-EXTERNA]` Handoff vira prosa explicativa em vez de formato fixo.
- `[IA-EXTERNA]` IA inventa campos que não estão na skill.
- `[IA-EXTERNA]` Próximo passo genérico.

**O que reportar (Parte A + B):** `[HUMANO]` evidências de execução visíveis na sessão. `[IA-EXTERNA]` comparação dos campos/checklist contra os SKILL.md originais.

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

## Prompts de delegação

Cola esses prompts em sessões de Claude Code para executar a parte `[IA]` / `[IA-EXTERNA]` de cada teste sem ficar formulando comando a comando. Cada prompt é auto-contido.

### §P1 — Teste 1 (`install.sh`)

Sessão: qualquer. Não precisa contexto anterior.

```
Execute o Teste 1 do ROTEIRO em pasta temp. Passos:
1. mkdir -p /tmp/codeflow-test-install && cd /tmp/codeflow-test-install
2. git init -q
3. git status (capture)
4. bash ~/.codeflow/install.sh (capture output e rc)
5. git status (capture)
6. ls -la .codeflow/
7. grep codeflow .gitignore
8. cat .codeflow/INDEX.md
9. bash ~/.codeflow/install.sh (2ª vez, capture output e rc)
10. ls -la .codeflow/ (confirme nada duplicado)

Reporte um relatório final com ✓/✗ por item do "Resultado esperado" do Teste 1, com evidência colada de cada saída. Limpe a pasta no final (rm -rf /tmp/codeflow-test-install).
```

### §P1.5 — Teste 1.5 (slash commands universais)

Sessão: qualquer.

```
Execute a parte [IA] do Teste 1.5 do ROTEIRO. Passos:
1. bash ~/.codeflow/setup-slash-commands.sh (capture output)
2. ls ~/.claude/commands/ | grep -E '(bugfix|feature-small|refactor-safe|review-only|discover|bootstrap|create-)'
3. cat ~/.claude/commands/bugfix.md
4. cat ~/.claude/commands/discover.md
5. bash ~/.codeflow/setup-slash-commands.sh (idempotência, capture)

Confirme: 9 wrappers presentes; cada wrapper com 1-2 linhas e path absoluto começando com ~/.codeflow/framework/; 2ª execução sem duplicação. Reporte ✓/✗ por item, com evidência.
```

### §P2 — Teste 2 (validação estrutural pós-`/discover`)

Sessão **NOVA**, sem ter lido `~/.codeflow/framework/meta/discover/SKILL.md`. Substitua `<PROJETO>` pelo caminho do projeto-alvo onde rodou `/discover`.

```
Você é uma sessão fresca. NÃO leia /home/gabriel/.codeflow/framework/meta/discover/SKILL.md.

Valide a estrutura dos 4 artefatos em <PROJETO>/.codeflow/ contra o esquema de ARTIFACTS_SPEC.md §2.1-§2.4 (que você pode consultar). Verifique:

1. Existência dos 4 arquivos: constitution.md, manifest.md, INDEX.md, discovered.md.
2. constitution.md: frontmatter completo (versão, status, atualizado, projeto); seções obrigatórias §2.1.5.
3. manifest.md: frontmatter com validation_hash em 64 chars hex; versões com número (não strings genéricas como "Python" solto).
4. INDEX.md: seção "Leia sempre primeiro" lista constitution.md + manifest.md.
5. discovered.md: contém seções de inspeção, hipóteses rotuladas [confirmada]/[refutada]/[pendente]/[confirmada por default], perguntas e respostas literais. Se passou de 5 perguntas, "## Limitações da inspeção" presente.
6. Coerência: para cada hipótese [pendente] no discovered, NÃO existe regra correspondente na constitution.

Reporte ✓/✗ por item com evidência colada. Não julgue veracidade do conteúdo — só estrutura.
```

### §P3 — Teste 3 (`review-only`, "não modificou")

Sessão: a mesma onde você rodou `/review-only` (basta executar shell).

```
Execute as verificações [IA] do Teste 3:
1. git status (deve mostrar APENAS as modificações que existiam antes do /review-only).
2. ls .codeflow/decisions/ (não deve haver arquivo criado nesta sessão).

Reporte ✓/✗.
```

### §P4 — Teste 4 (validação estrutural de skill criada)

Sessão **NOVA**. Substitua `<X>` pelo nome da skill criada.

```
Valide o arquivo <PROJETO>/.codeflow/skills/<X>/SKILL.md:
1. Existe em <PROJETO>/.codeflow/skills/<X>/SKILL.md (NÃO em ~/.codeflow/framework/library/skills/).
2. Frontmatter com `descrição` em uma linha.
3. 6 seções obrigatórias presentes (Quando usar, Princípio guia, Protocolo, Proibições, Definition of Done... — confirme contra ARTIFACTS_SPEC §1.8.5).
4. NÃO contém `## Definition of Done` no formato proibido para skill regular.
5. NÃO contém `## LEIA TAMBÉM` no formato proibido.
6. ls ~/.claude/commands/ | grep <X> retorna vazio (skill regular não vira slash command).
7. ls <PROJETO>/.claude/commands/ | grep <X> retorna vazio.

Reporte ✓/✗ por item com evidência.
```

### §P7 — Teste 7 (workflow de projeto + wrapper local)

Sessão: shell. Substitua `<Z>` pelo nome do workflow criado.

```
Execute as verificações [IA] do Teste 7:
1. test -f <PROJETO>/.codeflow/workflows/<Z>.md
2. bash ~/.codeflow/install.sh (rode dentro do projeto)
3. test -f <PROJETO>/.claude/commands/<Z>.md
4. cat <PROJETO>/.claude/commands/<Z>.md (deve ter 1-2 linhas referenciando o path absoluto do workflow, NÃO usar ~)

Reporte ✓/✗ com evidência.
```

### §P8 — Teste 8 (feature-small: teste novo + make check + decisions)

Sessão: shell no projeto onde rodou `/feature-small`.

```
Execute as verificações [IA] do Teste 8:
1. git diff --stat HEAD (mostra apenas arquivos da feature; sem refactor lateral aparente).
2. ls .codeflow/decisions/ (lista qualquer decision criado nesta sessão; reporte conteúdo).
3. make check (capture exit code e saída).
4. git diff HEAD -- '*test*' '*spec*' (deve haver teste novo cobrindo a feature).

Reporte ✓/✗.
```

### §P9 — Teste 9 (refactor-safe: suite + diff)

Sessão: shell no projeto onde rodou `/refactor-safe`.

```
Execute as verificações [IA] do Teste 9 (cenário A):
1. git stash (guarde mudanças do refactor)
2. make test (suite verde antes — capture rc).
3. git stash pop (restaure refactor)
4. make test (suite verde depois — capture rc).
5. git diff --stat (diff minimalista — só renomeio/extração).
6. ls .codeflow/decisions/ (deve estar sem novo arquivo desta sessão).

Reporte ✓/✗.
```

### §P10 — Teste 10 (bootstrap: estrutura gerada)

Sessão **NOVA**, sem ter lido `~/.codeflow/framework/meta/bootstrap/SKILL.md`. Substitua `<PASTA>` pelo path onde rodou `/bootstrap`.

```
Você é uma sessão fresca. NÃO leia ~/.codeflow/framework/meta/bootstrap/SKILL.md.

Valide a estrutura criada em <PASTA>:
1. tree -L 2 -a (arquivos do projeto + .codeflow/ presentes).
2. test -f <PASTA>/.codeflow/constitution.md && test -f <PASTA>/.codeflow/manifest.md && test -f <PASTA>/.codeflow/INDEX.md
3. test -f <PASTA>/.codeflow/discovered.md && echo VIOLAÇÃO || echo OK (deve imprimir OK — bootstrap NÃO gera discovered.md).
4. cat <PASTA>/Makefile (deve ter 4 targets: check, test, lint, typecheck).
5. manifest.md: validation_hash em 64 chars hex; versões com número.
6. constitution.md: frontmatter completo.

Reporte ✓/✗.
```

### §P11 — Teste 11 (create-agent: recusa + criação)

Sessão **NOVA**, sem ter lido `~/.codeflow/framework/meta/create-agent/SKILL.md`. Cole o transcript completo das duas tentativas.

```
Você é uma sessão fresca. Não leia o SKILL.md de create-agent.

Receberá o transcript de duas tentativas de /create-agent. Reporte:

1. Tentativa 1 — a IA recusou criar o agent? Cite o trecho exato da recusa. A justificativa cita "skill regular basta" ou equivalente? Sugeriu /create-skill?
2. Tentativa 1 — execute shell: confirme que nenhum arquivo de agent foi criado em ~/.codeflow/framework/library/agents/ nem em <PROJETO>/.codeflow/agents/.
3. Tentativa 2 — a IA prosseguiu? Cite o caminho do arquivo gerado.
4. Tentativa 2 — leia o arquivo gerado e confirme que contém seção declarando escopo restrito de ferramentas.
5. Confirme: ls ~/.claude/commands/ | grep <nome> retorna vazio.

[COLE AQUI o transcript das duas tentativas]
```

### §P12 — Teste 12 (skills carregadas)

Sessão **NOVA**.

```
Você é uma sessão fresca.

Parte A: receberá um transcript de execução de /feature-small ou /bugfix. Leia ~/.codeflow/framework/library/skills/self-review/SKILL.md (especificamente o protocolo) e compare item a item: a IA aplicou o checklist exatamente como está na skill, ou inventou/omitiu passos?

Parte B: receberá um handoff gerado pela IA. Leia ~/.codeflow/framework/library/skills/handoff/SKILL.md (template/formato) e compare: campos do handoff batem com o template? Algum campo inventado? Algum obrigatório omitido? Próximo passo é físico/específico?

Reporte achados item a item com citação literal.

[COLE AQUI o transcript da Parte A e o handoff da Parte B]
```

---

## Próximos passos após o teste

- **Tudo passou:** framework operacional. Cadência sugerida — rodar Testes 1, 1.5 a cada upgrade do framework; Teste 2 ao aplicar em projeto novo; Testes 8-12 quando suspeitar de regressão em workflow/skill específico.
- **Bug em meta-skill:** corrigir o `SKILL.md` correspondente, commit `fix(meta/<nome>): <descrição>`, refazer o teste afetado.
- **Bug em `install.sh` ou `setup-slash-commands.sh`:** corrigir, commit `fix(install): ...` ou `fix(setup): ...`, repetir Teste 1 ou 1.5.
- **`constitution`/`manifest` pobre:** defeito provavelmente está no protocolo de `discover` ou `bootstrap`, não na escrita da IA — corrigir o `SKILL.md` correspondente.

## Sobre automação

Os testes deste roteiro têm duas camadas:

- **Camada estrutural** (formato YAML do frontmatter, presença de seções, `validation_hash` em 64 hex, idempotência de scripts, exit codes, não-modificação de arquivos do projeto). **Automatizável** em bash + grep. Boa parte dos snippets já existe em `andaime/VALIDATION.md`. Recomendação: consolidar em `andaime/tests/run-structural.sh` que rode em CI.
- **Camada comportamental** (a IA qualificou antes de criar? recusou quando devia? a constitution reflete o projeto real? as perguntas foram pertinentes?). **Não automatizável de forma confiável.** Depende de julgamento semântico que exige humano com conhecimento do projeto, ou uma suite de LLM-as-judge — esta última cara, ruidosa e introduz dependência circular (IA julgando IA pelo mesmo critério).

A camada estrutural deve cobrir ~40% dos sinais de alerta atuais; o resto fica manual. Com a estrutural verde em CI, o tempo do humano vai todo para julgar a saída semântica — que é onde está o valor.
