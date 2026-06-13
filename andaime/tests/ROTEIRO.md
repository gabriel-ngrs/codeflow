---
versão: 2.0
status: estável
atualizado: 2026-05-28
---

# Roteiro de testes manuais — codeflow

Roteiro para **você (humano)** testar o framework do começo ao fim em um projeto real. Cada teste descreve o que você faz, o que deve aparecer e o que indica problema. Use uma sessão do Claude Code para apoiar (tirar dúvida, comparar saída contra o esperado) — mas a execução e o julgamento são seus.

**Cobertura:** 12 testes que exercitam os 5 meta-skills, 4 workflows universais, 3 skills universais e os 2 scripts shell que vêm como seed do framework. Testes 1 a 4 e 8 a 12 são canônicos; 5, 6 e 7 são opcionais.

## Status atual da execução

Última sessão: **2026-05-28**, projeto **koryn-ai** (`~/projetos/Koryn-Ai`).

| # | Teste | Status | Notas |
|---|---|---|---|
| 1 | `install.sh` em projeto real | ✓ | — |
| 1.5 | Slash commands universais | ✓ | — |
| 2 | `/discover` em projeto existente | ⚠ | 2 rodadas; path de incerteza ✓ na 2ª. Achados #1 e #2 em `melhorias-fix.md`. |
| 3 | `/review-only` | ✓ | — |
| 4 | `/create-skill` | ✓ | Gerou `multi-tenant-audit` em `<koryn-ai>/.codeflow/skills/`. |
| 5 | `/bugfix` *(opc)* | ✓ | Bug controlado de status code 409. Achado #3 em `melhorias-fix.md`. |
| 6 | Desinstalação *(opc)* | — | Pulado até terminar todos os testes no projeto. |
| 7 | Workflow de projeto + slash local *(opc)* | — | Pulado. |
| 8 | `/feature-small` | ⚠ | Endpoint `GET /me/quotes/count`. Achado #4 em `melhorias-fix.md`. |
| 9 | `/refactor-safe` | ⚠ | Cenário A ✓; cenário B recusou mas ofereceu override indevido. Achado #5 em `melhorias-fix.md`. |
| 10 | `/bootstrap` em projeto novo | ⚠ | 2026-06-05, projeto `tsconv` em `~/projetos/codeflow-bootstrap-test`. Estrutural 100% ✓ (sem `discovered.md`, hash 64 hex, 4 targets, 5 seções de cada artefato, pausas Fase 1/2/5 ✓). Achado #6 em `melhorias-fix.md` (manifest diz "Padrões detectados" para arquitetura só decidida + entrypoint aponta módulo inexistente). |
| 11 | `/create-agent` (foco em recusa) | ✓ | **Re-teste 2026-06-13** (sessão fresca, repo `/tmp` descartável) após correção do #7. **T1 passou:** recusou o checklist de revisão e redirecionou para `/create-skill` (era a falha original). **T2 passou:** `dependency-auditor` gerado com `Bash` excluído. Ressalva: os dois casos agora constam como exemplos literais na tabela do SKILL — teste em parte "ensinado", mas o critério (2 condições) é sólido e a recusa ocorre. |
| 12 | Skills carregadas (`handoff` + `self-review`) | ✓ | **Re-teste 2026-06-13** (sessão fresca, repo `/tmp`). Parte A: `/feature-small` aplicou self-review visível item a item (incluindo os 2 itens novos dos #3/#4), `make check` exit 0, sem decision espúria. Parte B: handoff nas 5 seções fixas, próximo passo físico, sem prosa. |

**Achados:** as 8 entradas de `andaime/tests/melhorias-fix.md` foram **resolvidas nos artefatos do framework em 2026-06-13** (cada uma com linha `**Resolução:**`). Os re-testes comportamentais **T11 e T12 foram re-executados em 2026-06-13** em sessão fresca (repo `/tmp` descartável) e **passaram** — todos os 12 testes canônicos estão ✓/⚠ (sem ✗). T6/T7 permanecem opcionais/pulados.

**Estado do koryn-ai entre sessões:**
- `.codeflow/` populado (constitution, manifest, INDEX, discovered, skill `multi-tenant-audit`).
- Arquivos novos do Teste 8 mantidos (não revertidos): `src/backend/app/api/v1/endpoints/me.py`, `src/backend/tests/test_me_quotes_count.py`, e modificações em `src/backend/app/api/v1/__init__.py`, `src/backend/tests/conftest.py`, `src/backend/tests/test_multitenancy.py` (refator do T9 cenário A).
- Bug controlado do Teste 5 já foi revertido.
- Sessão fica numa branch dedicada `codeflow-test` — quando quiser merge ou descarte, decida você.

**Como retomar:** abre o Claude Code no `~/projetos/codeflow` (este repo, do framework) e diz "vamos continuar do Teste 12". O T12 (skills `handoff`+`self-review`) é o **último pendente** e roda **no koryn-ai** — não precisa de pasta nova. O T10 já foi: a pasta de teste `~/projetos/codeflow-bootstrap-test` pode ser apagada (`rm -rf`).

## Antes de começar

### Pré-requisitos

1. **Framework instalado** em `~/.codeflow/`. Confira:
   ```
   ls ~/.codeflow/
   ```
   Deve listar `andaime/`, `framework/`, `install.sh`, `setup-slash-commands.sh`. Se faltar, refaça a instalação do framework.

2. **Slash commands sincronizados** uma vez por máquina:
   ```
   bash ~/.codeflow/setup-slash-commands.sh
   ```
   Esse passo é validado pelo Teste 1.5 — você vai rodar de novo lá.

3. **Projeto-alvo:** um repositório git real de tamanho pequeno a médio, ao qual você queira aplicar o codeflow. Crie um branch dedicado antes (`git checkout -b codeflow-test`) — o codeflow só escreve em `.codeflow/`, `.gitignore` e (se você usar workflows de projeto) `.claude/commands/`, mas a precaução custa nada.

4. **Claude Code aberto na raiz do projeto-alvo** — nunca dentro de `~/projetos/codeflow/` (você ia testar o framework no próprio framework).

### Como invocar cada artefato

- **Workflows** (`/bugfix`, `/feature-small`, `/refactor-safe`, `/review-only`) e **meta-skills** (`/discover`, `/bootstrap`, `/create-skill`, `/create-workflow`, `/create-agent`) viram **slash commands nativos** após `setup-slash-commands.sh`. Basta digitar `/<nome>` no Claude Code.
- **Skills universais** (`debug-protocol`, `handoff`, `self-review`) **não** ganham slash command. Elas são carregadas indiretamente por workflows (via `## LEIA TAMBÉM`) ou explicitamente quando você pede:
  > "Leia `~/.codeflow/framework/library/skills/<nome>/SKILL.md` e aplique o protocolo agora."

### Como usar a sessão Claude Code de apoio

Em qualquer teste, se você quiser conferir se uma saída está correta sem ter que ler o `ARTIFACTS_SPEC.md` inteiro, basta colar a saída na sessão de apoio e pedir uma comparação direta. Exemplo:

> "Cola aqui o `manifest.md` que foi gerado pelo `/discover` e me diz se o `validation_hash` tem 64 caracteres hex e se todas as 5 seções obrigatórias do schema §2.3 do `ARTIFACTS_SPEC.md` estão presentes na ordem certa."

A sessão de apoio é **leitura/comparação** — quem executa o protocolo testado é outra sessão (a do projeto-alvo). Isso evita que a mesma IA que executou também se julgue.

### Como reportar

Para cada teste:
- ✓ passou — comportamento bate com o esperado.
- ⚠ passou com ressalva — funcionou mas algo estranho aconteceu (anote o quê).
- ✗ falhou — algum sinal de problema da seção "Sinais de problema" disparou.

Ao final, salve um relatório em `andaime/tests/RELATORIO-<data>.md` com:
- status de cada teste,
- bugs encontrados (e qual artefato precisa correção: `install.sh`? `meta/<nome>/SKILL.md`? `workflows/<nome>.md`?),
- atritos de UX (onde a IA hesitou, perguntou demais, perdeu tempo),
- sugestões de melhoria.

---

## Teste 1 — `install.sh` em projeto real ✓ (2026-05-28, koryn-ai)

**O que valida:** o `install.sh` cria `.codeflow/` sem encostar em nada do projeto além de `.gitignore`. É idempotente.

**O que você faz:**

1. Numa pasta temporária (mais seguro que rodar direto no projeto-alvo na primeira vez):
   ```
   mkdir -p /tmp/codeflow-test-install && cd /tmp/codeflow-test-install
   git init -q
   ```
2. Anota o estado: `git status`.
3. Roda: `bash ~/.codeflow/install.sh` — observa a saída.
4. Confere o que mudou: `git status`.
5. Inspeciona o que foi criado:
   ```
   ls -la .codeflow/
   grep codeflow .gitignore
   cat .codeflow/INDEX.md
   ```
6. **Roda de novo** (idempotência): `bash ~/.codeflow/install.sh`.
7. Limpa quando terminar: `cd ~ && rm -rf /tmp/codeflow-test-install`.

**O que deve aparecer:**

- Saída em pt-BR com `✓` em cada verificação; última linha aponta para `/discover` ou `/bootstrap`.
- `.codeflow/INDEX.md` criado (placeholder), `.codeflow/decisions/`, `.codeflow/checkpoints/` presentes.
- `.gitignore` contém `.codeflow/checkpoints/`.
- `git status` mostra **apenas** `.codeflow/` e `.gitignore` como mudanças.
- Na 2ª execução: mensagens viram "já existe — preservado", nada duplicado, exit code 0.

**Sinais de problema (✗):**

- Algum arquivo do projeto modificado fora de `.codeflow/`, `.gitignore` (ou `.claude/commands/` se você já tinha workflows de projeto).
- `install.sh` cria `constitution.md`, `manifest.md` ou `discovered.md` — esses devem vir só do `/discover` ou `/bootstrap`.
- `install.sh` chama `git init` (deveria recusar quando não é repo git).
- Não é idempotente (a 2ª execução duplica algo ou falha).

---

## Teste 1.5 — Slash commands universais ✓ (2026-05-28, koryn-ai)

**O que valida:** depois de `setup-slash-commands.sh`, os 4 workflows e as 5 meta-skills aparecem como slash commands nativos no Claude Code (`/bugfix`, `/discover`, `/create-workflow` etc.).

**O que você faz:**

1. `bash ~/.codeflow/setup-slash-commands.sh` — anota a saída.
2. Confere os wrappers criados:
   ```
   ls ~/.claude/commands/ | grep -E '(bugfix|feature-small|refactor-safe|review-only|discover|bootstrap|create-)'
   ```
3. Espia um wrapper:
   ```
   cat ~/.claude/commands/bugfix.md
   cat ~/.claude/commands/discover.md
   ```
   Cada um deve ter 1 linha, em pt-BR, começando com `Leia ~/.codeflow/framework/...` e mandando executar o protocolo.
4. **Visualmente:** abra o Claude Code em qualquer projeto, digite `/` e confirme que `/bugfix`, `/discover`, `/create-workflow` aparecem na lista de comandos.
5. (Opcional) Em sessão fresca, digite `/bugfix` e verifique que o Claude lê o workflow real e começa o protocolo.
6. **Idempotência:** roda `bash ~/.codeflow/setup-slash-commands.sh` de novo. A saída muda para "preservado", nada se duplica.

**O que deve aparecer:**

- 9 wrappers em `~/.claude/commands/` (4 workflows + 5 meta-skills).
- Cada wrapper tem 1-2 linhas e referencia um path em `~/.codeflow/framework/`.
- Slash commands aparecem no menu do Claude Code sem precisar reiniciar.
- 2ª execução: 9 preservados, 0 criados.

**Sinais de problema (✗):**

- Wrapper duplica o conteúdo do workflow em vez de só apontar o path.
- Wrapper tem mais de 6 linhas.
- Slash command não aparece no menu do Claude Code mesmo com o wrapper presente (provavelmente é a versão do Claude Code, não o codeflow — verifique).

---

## Teste 2 — `/discover` em projeto existente *(teste principal)* ⚠ (2026-05-28, koryn-ai — 2 rodadas; path de incerteza ✓ na 2ª; ver melhorias-fix.md #1 e #2)

**O que valida:** o `/discover` inspeciona o projeto, faz orientação de até 5 perguntas e gera 4 artefatos coerentes — `constitution.md`, `manifest.md`, `INDEX.md` e `discovered.md`.

**O que você faz:**

1. No Claude Code aberto no projeto-alvo, digite `/discover`.
2. **Fase 1 — Inspeção silenciosa:** a IA deve ler arquivos, mapear estrutura, examinar commits **sem te interromper**. Observe se ela faz isso ou pula direto pra perguntar.
3. **Fase 2 — Entrevista:** a IA deve fazer **até 5 perguntas** específicas, cada uma com contexto de "o que a inspeção encontrou". Se chegar à 5ª, deve emitir um aviso antes de fazer a 6ª.
4. **Force ao menos uma resposta de incerteza** numa das perguntas: responda `não sei`, `o que você recomenda?`, `usa o padrão` ou `depois eu decido`. Observe se a IA respeita (marca como `[pendente]` ou aplica default), em vez de re-perguntar.
5. Responda o resto das perguntas; confirme o resumo na pausa antes da Fase 3.
6. Espere a IA gerar `constitution.md`, `manifest.md`, `INDEX.md`, `discovered.md` em `.codeflow/`.
7. **Valide os 4 arquivos.** Abra cada um e confira (ou cole na sessão de apoio para comparar contra `~/.codeflow/framework/core/ARTIFACTS_SPEC.md`):

   **`constitution.md`:**
   - Frontmatter com `versão`, `status`, `atualizado`, `projeto`.
   - Título exato: `# Constitution do projeto: <nome>`.
   - Cinco seções na ordem: `## Stack`, `## Padrão arquitetural`, `## Regras invariantes específicas`, `## Áreas de alto risco`, `## Definition of Done específica`.
   - Só declara regras que **você confirmou** ou que estão observáveis direto no código. Nada inventado sobre o seu projeto.

   **`manifest.md`:**
   - Frontmatter com `validation_hash` em **64 caracteres hex**.
   - Versões com número real (ex: `Python 3.11.5`, não só `Python`).
   - Cinco seções na ordem: `## Stack identificada`, `## Comandos make canônicos`, `## Padrões detectados`, `## Arquivos críticos para freshness`, `## Notas de inspeção`.

   **`INDEX.md`:**
   - Título exato: `# INDEX do .codeflow/ do projeto` (sem sufixo com nome).
   - `## Leia sempre primeiro` lista `constitution.md` (item 1) e `manifest.md` (item 2).
   - Tem 15-25 linhas.

   **`discovered.md`:**
   - Seções: `## O que foi inspecionado`, `## Hipóteses formadas`, `## Perguntas feitas ao usuário e respostas`, `## Áreas marcadas como "não tocar"`, `## Artefatos gerados a partir deste discovered`.
   - Hipóteses rotuladas literalmente entre colchetes: `[confirmada]`, `[refutada]`, `[pendente]`.
   - Para cada hipótese `[pendente]`: **não** existe regra correspondente em `constitution.md`.

**O que reportar:**

- A IA seguiu Fase 1 → Fase 2 → pausa → Fase 3 → Fase 4?
- Como reagiu à resposta de incerteza (respeitou ou insistiu)?
- Alguma pergunta foi desnecessária ou faltou alguma crítica?
- Algum dos 4 artefatos contém afirmação **falsa** sobre o projeto?
- Tempo aproximado de inspeção + entrevista.

**Sinais de problema (✗):**

- IA pula Fase 1 (vai direto pra pergunta sem inspecionar).
- Passa de 5 perguntas sem o aviso intermediário e sem justificativa em `## Limitações da inspeção` no `discovered.md`.
- Re-pergunta depois de uma resposta de incerteza (`não sei`, `passa`).
- Gera regra em `constitution.md` baseada em hipótese ainda `[pendente]`.
- Não pausa antes da Fase 3.
- `validation_hash` ausente ou em formato errado (não 64 hex).
- `manifest.md` cita versões de bibliotecas que não existem no projeto.

---

## Teste 3 — Workflow `/review-only` ✓ (2026-05-28, koryn-ai)

**O que valida:** workflow magro de revisão. Não modifica nada, não gera decision.

**O que você faz:**

1. Faça uma mudança pequena e real no projeto (edite uma função, corrija typo, mude comentário). **Não** commita.
2. No Claude Code: `/review-only`.
3. Observe a revisão emitida.
4. Depois, no terminal:
   ```
   git status
   ls .codeflow/decisions/
   ```

**O que deve aparecer:**

- Revisão estruturada conforme os passos do workflow, citando regras de `constitution.md` quando aplicáveis.
- `git status` mostra **as mesmas modificações que existiam antes** do `/review-only` (a IA não tocou em nada).
- `.codeflow/decisions/` **não** ganhou arquivo novo nesta sessão (workflow é `gera_decision: no`).

**Sinais de problema (✗):**

- IA propõe ou aplica edits no código.
- IA cria decision.
- IA ignora a `constitution.md` (revisão genérica, sem referência ao projeto).

---

## Teste 4 — `/create-skill` (skill no nível do projeto) ✓ (2026-05-28, koryn-ai/multi-tenant-audit)

**O que valida:** `create-skill` qualifica antes de criar, salva no projeto (não no framework universal), gera o formato certo e **não** cria slash command.

**O que você faz:**

1. Pense em uma tarefa repetitiva específica do seu projeto que **não** é coberta por skill existente (ex: "validar formato de migração antes de aplicar", "preparar checklist de release").
2. `/create-skill` no Claude Code. Descreva a tarefa quando perguntar.
3. **Observe a qualificação:** a IA deve primeiro perguntar se a necessidade não cabe melhor em rule (regra estática) ou workflow (sequência com decisões). Só depois propõe criar skill.
4. Se for skill mesmo, ela vai gerar o arquivo.
5. Confira:
   ```
   ls <projeto>/.codeflow/skills/<X>/SKILL.md
   ls ~/.claude/commands/ | grep <X>
   ls <projeto>/.claude/commands/ | grep <X>
   ```
6. Abra o `SKILL.md` e confira:
   - Frontmatter com `descrição` em uma linha.
   - 6 seções obrigatórias do schema §1.8.5 do `ARTIFACTS_SPEC.md` (cole na sessão de apoio se preferir comparar lá).
   - **Não** tem `## Definition of Done` (skill regular não usa esse formato).
   - **Não** tem `## LEIA TAMBÉM` no formato proibido.

**O que deve aparecer:**

- Skill em `<projeto>/.codeflow/skills/<X>/SKILL.md`, **não** em `~/.codeflow/framework/library/skills/`.
- Nenhum wrapper em `~/.claude/commands/<X>.md` nem em `<projeto>/.claude/commands/<X>.md` — `ls | grep` volta vazio.
- Qualificação aconteceu antes da geração.

**Sinais de problema (✗):**

- IA criou direto em `~/.codeflow/framework/library/skills/` (viola política de evolução — promoção exige uso em 2+ projetos, ver `framework/core/EVOLUTION.md`).
- IA não qualifica antes (pula direto pra gerar).
- Skill criada com `## Definition of Done` ou `## LEIA TAMBÉM` no formato proibido.
- Ganhou slash command.

---

## Teste 5 *(opcional)* — Workflow `/bugfix` com decision ✓ (2026-05-28, koryn-ai bug controlado — ver melhorias-fix.md #3)

**O que valida:** workflow médio que reproduz, isola, corrige causa raiz, adiciona teste e gera decision em escolhas não-óbvias.

**O que você faz:**

1. Identifique (ou simule) um bug real no projeto.
2. `/bugfix` no Claude Code. Descreva o bug.
3. Acompanhe os passos do workflow.
4. Ao final:
   ```
   ls .codeflow/decisions/
   make check         # ou comando equivalente do projeto
   git diff -- '*test*' '*spec*'
   ```

**O que deve aparecer:**

- Workflow segue o esqueleto: reprodução → isolamento → fix mínimo → teste novo.
- Em escolhas não-óbvias: pelo menos um arquivo em `.codeflow/decisions/<data>-<titulo>.md`.
- Definition of Done verificada antes de declarar pronto (`make check` ou equivalente verde).
- Teste de regressão novo cobrindo o caso reportado.
- A correção atacou causa raiz, não só o sintoma.

**Sinais de problema (✗):**

- Correção cosmética (esconde o sintoma).
- Sem teste novo.
- Sem decision em escolha que claramente exigiria registro.
- `make check` ficou vermelho e a IA declarou pronto mesmo assim.

---

## Teste 6 *(opcional)* — Desinstalação manual

**O que valida:** dá pra remover o codeflow de um projeto sem deixar lixo.

**O que você faz:**

1. `rm -rf .codeflow/`
2. Edite `.gitignore` removendo a linha `.codeflow/checkpoints/` (ou apague o `.gitignore` se ele só foi criado pelo `install.sh`).
3. Se você criou workflows de projeto e wrappers locais: `rm -rf .claude/commands/` (decida caso a caso se quer remover só os wrappers gerados ou tudo).

Não há `uninstall.sh` — a desinstalação é trivial e isso é por design.

---

## Teste 7 *(opcional)* — Workflow de projeto + slash command local

**O que valida:** workflow criado a nível de projeto vira slash command **local** automaticamente (só aparece dentro daquele projeto).

**O que você faz:**

1. No Claude Code, no projeto-alvo: `/create-workflow` e descreva um workflow específico do projeto.
2. Confirme destino "projeto" (não universal). O arquivo deve aparecer em `<projeto>/.codeflow/workflows/<Z>.md`.
3. Roda `bash ~/.codeflow/install.sh` de novo dentro do projeto. Esse re-run vai gerar o wrapper local.
4. Verifica:
   ```
   ls <projeto>/.codeflow/workflows/<Z>.md
   cat <projeto>/.claude/commands/<Z>.md
   ```
5. No Claude Code dentro do projeto, digite `/` e confirme que `/<Z>` aparece no menu.
6. Mude para outro projeto: `/<Z>` **não** deve aparecer ali (é local, não universal).

**O que deve aparecer:**

- Workflow em `.codeflow/workflows/<Z>.md` versionado no projeto.
- Wrapper em `.claude/commands/<Z>.md` referenciando o **path absoluto** do workflow (não usa `~/`).
- Slash command `/<Z>` aparece só dentro do projeto.
- `install.sh` exibe aviso sobre `.gitignore` para `.claude/commands/` mas não força.

**Sinais de problema (✗):**

- Wrapper local usa `~/` no path (devia ser absoluto pra apontar pro próprio projeto).
- `/<Z>` aparece em outros projetos (vazou pra escopo universal).

---

## Teste 8 — Workflow `/feature-small` end-to-end ⚠ (2026-05-28, koryn-ai/GET-me-quotes-count — ver melhorias-fix.md #4)

**O que valida:** workflow médio que implementa feature pequena com decisions automáticas em escolhas não-óbvias e self-review antes do "pronto".

**O que você faz:**

1. Identifique uma feature pequena real no projeto (1-3 arquivos, interface clara, sem decisão arquitetural maior).
2. `/feature-small`. Descreva a feature.
3. Acompanhe o protocolo: a IA deve carregar `constitution.md` (universal + projeto) e rules relevantes, implementar o mínimo, adicionar teste, rodar `make check` (ou equivalente) e aplicar `self-review` antes de declarar pronto.
4. Ao final:
   ```
   git diff --stat HEAD
   ls .codeflow/decisions/
   make check
   git diff HEAD -- '*test*' '*spec*'
   ```

**O que deve aparecer:**

- Implementação cobre **exatamente** a feature pedida — sem refactor lateral, sem feature paralela, sem "while we're at it".
- Teste novo cobrindo o comportamento adicionado (visível no diff).
- Em `.codeflow/decisions/`: pelo menos um arquivo desta sessão se houve escolha não-óbvia (`gera_decision: auto`).
- Self-review aparece visivelmente no transcript (a IA relê o diff, lista verificações, declara achados) — não basta mencionar "fiz self-review".
- `make check` (ou comando canônico do projeto) verde antes do "pronto".

**Sinais de problema (✗):**

- Refactor lateral fora do escopo declarado.
- Sem teste novo cobrindo a feature.
- Sem self-review visível antes do "pronto" (só uma menção textual).
- Decision gerada para escolha trivial (ruído) ou ausente em escolha claramente não-óbvia.
- IA ignora `constitution.md` ou rules carregadas.

---

## Teste 9 — Workflow `/refactor-safe` (com gate de cobertura) ⚠ (2026-05-28, koryn-ai — cenário A ✓; cenário B recusou mas ofereceu override; ver melhorias-fix.md #5)

**O que valida:** workflow de refator. Suite verde antes e depois. **Recusa** quando a área não tem cobertura suficiente.

**O que você faz:**

### Cenário A — caminho feliz

1. Escolha uma função ou módulo do projeto que **tenha cobertura de teste passando**.
2. `/refactor-safe`. Descreva (extrair função X, rename, dividir função grande).
3. Observe: a IA deve confirmar cobertura antes de refatorar, rodar suite, aplicar mudança, rodar suite de novo.
4. Ao final:
   ```
   git diff --stat
   make test         # capture exit code
   ls .codeflow/decisions/
   ```

### Cenário B — gate de cobertura

1. Escolha um módulo propositalmente **sem testes** e peça refator nele.
2. A IA deve **recusar** e redirecionar para `/feature-small` ou `/bugfix` para adicionar testes primeiro.

**O que deve aparecer:**

- **Cenário A:** suite verde antes e depois (exit 0 nos dois pontos); diff minimalista; comportamento observável **idêntico** (não é mais refator se mudou); nenhum decision novo (`refactor-safe` é `gera_decision: no`).
- **Cenário B:** recusa explícita no transcript citando ausência de cobertura; sugestão clara de próximo passo.

**Sinais de problema (✗):**

- IA refatora sem checar cobertura.
- Diff muda comportamento observável.
- Suite quebra depois do refator.
- Decision criado em `.codeflow/decisions/`.
- IA incluiu melhorias oportunistas não pedidas.
- IA **não** recusa no cenário B (refatora sem cobertura mesmo assim).

---

## Teste 10 — `/bootstrap` em projeto novo do zero

**O que valida:** contraparte do `/discover` para projeto **novo**, sem código pré-existente. Não gera `discovered.md`.

**O que você faz:**

1. Pasta vazia:
   ```
   mkdir /tmp/codeflow-bootstrap-test && cd /tmp/codeflow-bootstrap-test
   git init -q
   ```
2. **Não** rode `install.sh` antes — `/bootstrap` cuida da estrutura inteira.
3. Abra Claude Code nessa pasta.
4. `/bootstrap`. Descreva nome e propósito do projeto quando perguntado.
5. A IA deve passar pelas **5 fases**, com **pausas obrigatórias** em Fase 1, 2 e 5:
   - **Fase 1:** coleta nome, propósito, tipo (CLI/lib/serviço/app/etc.), licença, idioma.
   - **Fase 2:** decide stack com base nas respostas e pede confirmação.
   - **Fase 3:** gera estrutura mínima do projeto (não só `.codeflow/`).
   - **Fase 4:** gera artefatos do `.codeflow/`: `constitution.md`, `manifest.md`, `INDEX.md`.
   - **Fase 5:** pausa final apresentando o estado e próximos passos.
6. Ao final, no terminal:
   ```
   ls -la
   test -f .codeflow/discovered.md && echo VIOLAÇÃO || echo OK
   cat Makefile
   ```
7. Confere os 3 artefatos como no Teste 2 (frontmatter, seções, validation_hash 64 hex).
8. Limpa: `cd ~ && rm -rf /tmp/codeflow-bootstrap-test`.

**O que deve aparecer:**

- 5 fases com pausas visíveis em 1, 2, 5.
- Estrutura mínima **coerente com o tipo de projeto declarado** (CLI vira CLI; biblioteca vira biblioteca; não esqueleto genérico).
- `Makefile` com os 4 targets canônicos: `check`, `test`, `lint`, `typecheck`.
- 3 artefatos em `.codeflow/`: `constitution.md`, `manifest.md`, `INDEX.md`.
- `discovered.md` **não existe** — o teste com `test -f ... && echo VIOLAÇÃO || echo OK` deve imprimir `OK`.
- `manifest.md` com versões reais decididas na Fase 2 (não placeholders) e `validation_hash` em 64 hex.

**Sinais de problema (✗):**

- IA gera `discovered.md` (viola `ARTIFACTS_SPEC.md` §2.4.1 — bootstrap não inspeciona porque não há código pré-existente).
- Sem pausa nas Fases 1, 2 ou 5.
- Estrutura genérica que ignora o tipo de projeto declarado.
- Sem `Makefile` ou `Makefile` com targets diferentes dos 4 canônicos.
- `constitution.md` especulando regras não-confirmadas.
- IA pula a Fase 2 (escolhe stack sem confirmar).

---

## Teste 11 — `/create-agent` (foco em recusa)

**O que valida:** `create-agent` **recusa** criação quando skill regular bastaria — anti-padrão §1.10.7 do `ARTIFACTS_SPEC.md`.

**O que você faz:**

### Tentativa 1 — esperada recusa

1. `/create-agent`. Proponha:
   > "criar um agent que aplique nosso checklist de revisão de código"

   Essa tarefa **não** exige isolamento mecânico — skill regular basta.
2. A IA deve **qualificar e recusar**, redirecionando para `/create-skill`.
3. Confere que nenhum agent foi criado:
   ```
   ls ~/.codeflow/framework/library/agents/ 2>/dev/null
   ls <projeto>/.codeflow/agents/ 2>/dev/null
   ```

### Tentativa 2 — esperada aprovação

1. `/create-agent`. Proponha:
   > "criar um agent read-only que faça auditoria de dependências, sem capacidade de modificar nenhum arquivo do projeto"

   Justifica isolamento (restrição mecânica de ferramentas a leitura).
2. A IA deve prosseguir e gerar o agent.
3. Confere:
   ```
   ls <projeto>/.codeflow/agents/
   ls ~/.claude/commands/ | grep <nome-do-agent>     # deve voltar vazio
   ```
4. Abra o arquivo do agent gerado e confirme que tem seção declarando **escopo de ferramentas restrito** (a lista de ferramentas que ele pode usar é menor que a padrão).

**O que deve aparecer:**

- **Tentativa 1:** recusa explícita citando que skill regular basta + sugestão de `/create-skill`. Nenhum arquivo de agent criado.
- **Tentativa 2:** agent gerado em path correto, com seção de escopo de ferramentas restrito.
- Em ambas: nenhum slash command criado (agents não viram slash command).

**Sinais de problema (✗):**

- IA cria agent para a tentativa 1 (deveria recusar — anti-padrão §1.10.7).
- IA recusa também a tentativa 2 (excesso de zelo).
- Agent gerado sem seção de escopo de ferramentas explícita.
- Agent ganhou slash command em `~/.claude/commands/`.

---

## Teste 12 — Skills carregadas (`handoff` + `self-review`)

**O que valida:** as skills universais são **lidas e aplicadas** pelos workflows, não só citadas no `## LEIA TAMBÉM`.

### Parte A — `self-review` aplicado em workflow

**O que você faz:**

1. Rode `/feature-small` ou `/bugfix` no projeto-alvo (pode reaproveitar o Teste 8).
2. Imediatamente antes da IA declarar "pronto", observe se ela aplica o protocolo de `self-review` **visivelmente**: relê o diff inteiro, aplica checklist objetivo (escopo, mínimo necessário, testes), declara achados.
3. Se tiver dúvida, pergunte direto na sessão:
   > "Qual checklist exato do `self-review` você aplicou? Cite cada item."
4. Compare a resposta com `~/.codeflow/framework/library/skills/self-review/SKILL.md` (pode colar na sessão de apoio para comparação item a item).

**O que deve aparecer:**

- Self-review executado durante a sessão, com ações observáveis (relê diff, lista verificações, declara achados).
- O checklist citado bate item por item com o `SKILL.md` original — sem invenção, sem omissão.

**Sinais de problema (✗):**

- IA diz "fiz self-review" sem ação visível.
- Checklist citado difere do conteúdo real do `SKILL.md` (campos inventados ou itens omitidos).

### Parte B — `handoff` em trabalho parcial

**O que você faz:**

1. Crie uma situação de trabalho parcial real: rode `/feature-small` (ou outro) e **interrompa pela metade** dizendo que vai parar.
2. Instrua:
   > "Termine esta sessão com um handoff conforme `~/.codeflow/framework/library/skills/handoff/SKILL.md`."
3. A IA deve gerar arquivo/bloco de handoff.
4. Compare o handoff com o template em `~/.codeflow/framework/library/skills/handoff/SKILL.md` (sessão de apoio ajuda).

**O que deve aparecer:**

- Handoff no formato fixo da skill: **estado em uma linha**, **próximo passo concreto**, **decisões em aberto**. Conciso, sem prosa explicativa.
- **Próximo passo é físico e específico:** arquivo + ação ou comando exato. Não vale "continuar trabalho" nem "seguir implementação".

**Sinais de problema (✗):**

- Handoff vira prosa explicativa em vez de formato fixo.
- IA inventa campos que não estão na skill.
- "Próximo passo" genérico, não acionável.

---

## Cadência sugerida depois do teste

- **Tudo passou:** framework operacional. Refaça:
  - Testes 1 e 1.5 a cada upgrade do framework.
  - Teste 2 ao aplicar o codeflow em projeto novo.
  - Testes 8 a 12 quando suspeitar de regressão em workflow ou skill específico.
- **Bug em meta-skill:** corrigir o `SKILL.md` correspondente, commit `fix(meta/<nome>): <descrição>`, refazer só o teste afetado.
- **Bug em `install.sh` ou `setup-slash-commands.sh`:** corrigir, commit `fix(install): ...` ou `fix(setup): ...`, repetir Teste 1 ou 1.5.
- **`constitution`/`manifest` pobre:** defeito está provavelmente no protocolo de `discover` ou `bootstrap`, não na escrita da IA — corrigir o `SKILL.md` correspondente.

## Sobre automação (opcional, futuro)

Os testes têm duas camadas:

- **Estrutural** — formato YAML do frontmatter, presença de seções, `validation_hash` em 64 hex, idempotência de scripts, exit codes, não-modificação de arquivos. **Automatizável** em bash + grep; boa parte dos snippets já existe em `andaime/VALIDATION.md`. Consolidar em `andaime/tests/run-structural.sh` daria CI gratuita.
- **Comportamental** — a IA qualificou antes de criar? recusou quando devia? a `constitution.md` reflete o projeto real? as perguntas foram pertinentes? **Não automatizável de forma confiável** — depende de julgamento semântico, que continua sendo seu.

Com a estrutural verde em CI, o tempo manual vai todo para julgar comportamento, que é onde está o valor.
