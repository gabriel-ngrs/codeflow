---
versão: 1.1
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
3. A IA deve fazer **Fase 2 — Entrevista** com até **5 perguntas** como orientação (sem limite duro), baseadas em hipóteses específicas formadas na inspeção. Se chegar à 5ª, deve emitir aviso e perguntar se vale continuar perguntando ou reinspecionar. Deve aceitar respostas de incerteza (`não sei`, `o que você recomenda`, `usa o padrão`, `depois eu decido`) sem improvisar. Deve **pausar aguardando sua confirmação** antes da Fase 3.
4. Responda as perguntas; confirme o resumo.
5. A IA gera `constitution.md`, `manifest.md`, `INDEX.md` em `<projeto>/.codeflow/`.
6. A IA gera `discovered.md` e apresenta resumo final dos 4 arquivos.

**Resultado esperado:**

- **Orientação ≤ 5 perguntas**, específicas, não genéricas; quando passar, aviso obrigatório seguido de justificativa em `## Limitações da inspeção` do discovered. Cada pergunta cita o que a inspeção encontrou que motivou.
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

## Teste 8 — Workflow `/feature-small` end-to-end

**Objetivo:** validar workflow médio que implementa feature pequena com decisions automáticas e self-review.

**Passos:**

1. Identifique uma feature pequena real no projeto (1-3 arquivos, interface clara, sem decisão arquitetural maior).
2. Em Claude Code, no projeto-alvo:
   > `/feature-small` — descrever a feature em uma frase quando solicitado.
3. Acompanhe o protocolo: a IA deve carregar `constitution.md` (universal + projeto) e rules relevantes (`code-quality`, `testing`, `naming`), implementar o mínimo, adicionar teste, rodar `make check` (ou equivalente) e aplicar `self-review` antes de declarar pronto.

**Resultado esperado:**

- Implementação cobre **exatamente** a feature pedida — sem refactor lateral, sem feature paralela, sem "while we're at it".
- Teste novo cobre o comportamento adicionado.
- Em escolha não-óbvia (onde colocar a função, padrão A vs B), gera decision em `.codeflow/decisions/<data>-<titulo>.md` (`gera_decision: auto`).
- IA aplica self-review visivelmente antes do "pronto" (relê diff, verifica escopo, checklist objetivo).
- `make check` (ou comando canônico do projeto) verde antes do "pronto".

**O que reportar:** diff final; decisions criadas (úteis ou ruidosas?); evidência do self-review; algum refactor lateral indevido?

**Sinais de alerta (✗):**

- Refactor lateral fora do escopo declarado.
- Sem teste novo cobrindo a feature.
- Sem self-review antes de declarar pronto.
- Decision gerada para escolha trivial (ruído) ou ausente em escolha não-óbvia.
- IA ignora `constitution.md` ou rules relevantes.

---

## Teste 9 — Workflow `/refactor-safe`

**Objetivo:** validar workflow de refator com gate de cobertura — recusa quando suite é insuficiente.

**Passos:**

1. **Cenário A (caminho feliz):** escolha uma função/módulo do projeto que tenha **cobertura de teste passando**. Em Claude Code:
   > `/refactor-safe` — extrair função `X` de `<arquivo>` (ou rename, ou divisão de função grande).
2. Observe o protocolo: a IA deve confirmar cobertura antes de refatorar, rodar suite, aplicar mudança, rodar suite de novo.
3. **Cenário B (gate de cobertura):** escolha um módulo propositalmente **sem testes** e peça refator nele.
4. A IA deve **recusar** e redirecionar para `/feature-small` ou `/bugfix` para adicionar testes antes.

**Resultado esperado:**

- **Cenário A:** suite verde antes e depois; diff minimalista (apenas o renomeio/extração); nenhuma mudança de comportamento; nenhum decision gerado (`gera_decision: no`).
- **Cenário B:** recusa explícita citando ausência de cobertura; sugestão clara de próximo passo.

**O que reportar:** comportamento nas duas situações; diff antes/depois (cenário A); texto da recusa (cenário B).

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

**Passos:**

1. Em pasta vazia: `mkdir /tmp/codeflow-bootstrap-test && cd /tmp/codeflow-bootstrap-test && git init`.
2. **Não** rode `install.sh` antes — `/bootstrap` cuida da estrutura.
3. Abra Claude Code nessa pasta.
4. Instrua:
   > `/bootstrap` — quando perguntado, descrever nome do projeto e propósito em uma frase.
5. A IA deve passar pelas **5 fases**, com pausas obrigatórias em Fase 1, 2 e 5:
   - Fase 1: coleta nome, propósito, tipo (CLI/lib/serviço/app/etc.), licença, idioma.
   - Fase 2: decide stack com base nas respostas; pede confirmação.
   - Fase 3: gera estrutura mínima (não só `.codeflow/`).
   - Fase 4: gera artefatos do `.codeflow/`: `constitution.md`, `manifest.md`, `INDEX.md`.
   - Fase 5: pausa final apresentando estado e próximos passos.
6. Verifique:
   - `ls -la` mostra arquivos do projeto + `.codeflow/`.
   - `ls .codeflow/discovered.md` deve **falhar** (esse arquivo **não** é gerado por bootstrap — `ARTIFACTS_SPEC.md` §2.4.1).
   - `cat Makefile` mostra 4 targets canônicos (check, test, lint, typecheck).

**Resultado esperado:**

- 5 fases executadas com pausas em 1, 2, 5.
- Estrutura mínima coerente com o tipo de projeto declarado (não esqueleto genérico).
- Makefile canônico presente.
- 3 artefatos em `.codeflow/`: `constitution.md`, `manifest.md`, `INDEX.md`. **NÃO** existe `discovered.md`.
- `manifest.md` com versões reais decididas durante a Fase 2 (não placeholders).
- `constitution.md` com regras mínimas declaradas, sem invenção.

**O que reportar:** estrutura final do projeto (`tree -L 2 -a`); conteúdo dos 3 artefatos; confirmação de ausência de `discovered.md`; tempo total.

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

**Passos:**

1. **Tentativa 1 — esperada recusa:** em Claude Code:
   > `/create-agent` — criar um agent que aplique nosso checklist de revisão de código.
   (Esta tarefa **não** exige isolamento mecânico nem restrição de ferramentas — skill regular basta.)
2. A IA deve **qualificar** (perguntar se há necessidade de isolamento mecânico ou contexto isolado) e, ao não encontrar justificativa, **recusar** e redirecionar para `/create-skill`.
3. **Tentativa 2 — esperada aprovação:** peça um agent legítimo:
   > `/create-agent` — criar um agent read-only que faça auditoria de dependências, sem capacidade de modificar nenhum arquivo do projeto.
4. Aqui a tarefa justifica isolamento mecânico (restrição de ferramentas a leitura). A IA deve prosseguir, gerar agent em path correto, com escopo de ferramentas restrito explicitamente declarado.
5. Verifique: `ls ~/.claude/commands/ | grep <nome-do-agent>` deve ser **vazio** — agents não ganham slash command.

**Resultado esperado:**

- **Tentativa 1:** recusa explícita citando que skill regular basta; sugere `/create-skill`. Não cria nada.
- **Tentativa 2:** prossegue, gera agent com escopo de ferramentas restrito declarado no arquivo. Não gera wrapper de slash command.

**O que reportar:** texto da recusa (tentativa 1); arquivo de agent gerado (tentativa 2) com seção de ferramentas restritas; confirmação de ausência de slash command.

**Sinais de alerta (✗):**

- IA cria agent para a tentativa 1 (deveria recusar — anti-padrão §1.10.7).
- IA recusa também a tentativa 2 (excesso de zelo).
- Agent gerado sem seção de escopo de ferramentas explícita.
- Agent ganhou slash command em `~/.claude/commands/`.

---

## Teste 12 — Skills carregadas (`handoff` + `self-review`)

**Objetivo:** validar que skills universais são **lidas e aplicadas** por workflows, não apenas citadas no `LEIA TAMBÉM`.

### Parte A — `self-review`

**Passos:**

1. Rode `/feature-small` ou `/bugfix` no projeto-alvo (pode aproveitar o Teste 8).
2. Imediatamente antes de a IA declarar "pronto", observe se ela aplica o protocolo de `self-review` de forma **visível**: reler o diff inteiro, aplicar checklist objetivo (escopo coberto e nada mais? diff é mínimo? refactor lateral?).
3. Se houver dúvida, pergunte: "qual checklist exato você aplicou?". A resposta deve corresponder aos passos de `~/.codeflow/framework/library/skills/self-review/SKILL.md`, não invenção.

**Resultado esperado:**

- Self-review é executado, não só citado. Ações observáveis: relê diff, lista verificações do checklist, declara achados (se algum) antes de "pronto".

**Sinais de alerta (✗):**

- IA diz "fiz self-review" sem qualquer ação visível.
- Checklist citado difere do conteúdo do `SKILL.md`.

### Parte B — `handoff`

**Passos:**

1. Crie uma situação de trabalho parcial real: rode `/feature-small` ou similar e **interrompa** quando estiver pela metade.
2. Instrua:
   > "Termine esta sessão com um handoff conforme `~/.codeflow/framework/library/skills/handoff/SKILL.md`."
3. A IA deve gerar arquivo/bloco de handoff em **formato fixo**: estado atual em uma linha, próximo passo concreto (arquivo + ação ou comando), decisões em aberto, sem prosa.

**Resultado esperado:**

- Handoff seguindo o formato fixo do `SKILL.md`. Conciso. Sem campos inventados, sem narração.
- Próximo passo é físico e específico (não "continuar trabalho").

**Sinais de alerta (✗):**

- Handoff vira prosa explicativa em vez de formato fixo.
- IA inventa campos que não estão na skill.
- Próximo passo genérico ("continuar implementação").

**O que reportar (Parte A + B):** evidências de execução (não apenas menção) das duas skills; campos do handoff vs campos da skill original.

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

- **Tudo passou:** framework operacional. Cadência sugerida — rodar Testes 1, 1.5 a cada upgrade do framework; Teste 2 ao aplicar em projeto novo; Testes 8-12 quando suspeitar de regressão em workflow/skill específico.
- **Bug em meta-skill:** corrigir o `SKILL.md` correspondente, commit `fix(meta/<nome>): <descrição>`, refazer o teste afetado.
- **Bug em `install.sh` ou `setup-slash-commands.sh`:** corrigir, commit `fix(install): ...` ou `fix(setup): ...`, repetir Teste 1 ou 1.5.
- **`constitution`/`manifest` pobre:** defeito provavelmente está no protocolo de `discover` ou `bootstrap`, não na escrita da IA — corrigir o `SKILL.md` correspondente.

## Sobre automação

Os testes deste roteiro têm duas camadas:

- **Camada estrutural** (formato YAML do frontmatter, presença de seções, `validation_hash` em 64 hex, idempotência de scripts, exit codes, não-modificação de arquivos do projeto). **Automatizável** em bash + grep. Boa parte dos snippets já existe em `andaime/VALIDATION.md`. Recomendação: consolidar em `andaime/tests/run-structural.sh` que rode em CI.
- **Camada comportamental** (a IA qualificou antes de criar? recusou quando devia? a constitution reflete o projeto real? as perguntas foram pertinentes?). **Não automatizável de forma confiável.** Depende de julgamento semântico que exige humano com conhecimento do projeto, ou uma suite de LLM-as-judge — esta última cara, ruidosa e introduz dependência circular (IA julgando IA pelo mesmo critério).

A camada estrutural deve cobrir ~40% dos sinais de alerta atuais; o resto fica manual. Com a estrutural verde em CI, o tempo do humano vai todo para julgar a saída semântica — que é onde está o valor.
