---
versão: 1.1
status: ativo
atualizado: 2026-06-13
---

# Melhorias e correções identificadas durante os testes

Registro vivo de bugs, atritos de UX e melhorias detectadas enquanto o ROTEIRO é executado. Cada entrada referencia o teste onde surgiu, o artefato a corrigir, e a ação proposta.

> **Status 2026-06-13:** as 8 entradas abaixo foram **resolvidas e re-testadas** (cada uma traz uma linha `**Resolução:**`). Todos os re-testes comportamentais rodaram em sessão fresca (repo `/tmp` descartável) e passaram, com verificação independente dos artefatos: T11/T12 (#7, #3, #4) e T2/T9/T10 (#1, #2, #5, #6). Os 10 testes canônicos do ROTEIRO estão ✓.

Formato:

```
### <N>. <título curto>
- **Origem:** Teste <X> (data)
- **Artefato afetado:** <arquivo do framework>
- **Severidade:** bug | UX | melhoria
- **Descrição:** o que aconteceu vs. o que deveria acontecer
- **Ação proposta:** mudança concreta
```

---

### 1. `/discover` deve ter mínimo de 5 perguntas, sem limite máximo ✅ resolvido (2026-06-13)

- **Resolução:** `discover/SKILL.md` (Princípio guia, Fase 2, proibições) invertido para "mínimo cinco, sem teto"; aviso da 5ª virou pausa de sanidade da 10ª. `ARTIFACTS_SPEC.md` §2.4.3/§2.4.6/§2.4.7 e `SPEC.md` §4.4.2 alinhados. **Re-teste 2026-06-13 (T2, sessão fresca, `/tmp/cf-discover`): discover formulou 6 perguntas (≥5, sem pausa), verificado no `discovered.md`. ✓**

- **Origem:** Teste 2 (2026-05-28, projeto koryn-ai)
- **Artefato afetado:** `framework/meta/discover/SKILL.md` (Fase 2 — Entrevista qualificada) e `andaime/ARTIFACTS_SPEC.md` §2.4.4 (regra 6) — eventualmente `SPEC.md` §4.4.2.
- **Severidade:** melhoria de protocolo (decisão do usuário, não bug)
- **Descrição:** o protocolo atual orienta "até 5 perguntas" com aviso ao ultrapassar. Na execução real em Koryn-AI a IA fez **3 perguntas** e considerou suficiente. Em projeto maduro como Koryn-AI (vários domínios, multi-tenancy em transição, 18 migrations, 9 serviços docker) 3 perguntas tendem a deixar lacunas. O usuário prefere inverter a polaridade: **mínimo 5 perguntas, sem teto**. A inspeção continua precedendo, mas a entrevista deixa de ser "corte rápido" e passa a ser "cobertura mínima garantida".
- **Ação proposta:**
  - No `framework/meta/discover/SKILL.md`, Princípio guia e Fase 2: substituir "orientação: até cinco perguntas" por "orientação: no mínimo cinco perguntas, sem limite máximo". Reescrever o aviso da 5ª pergunta para virar aviso da 10ª (ou outro patamar discutido) onde a IA pondera "já fiz N perguntas — quer continuar ou seguir para Fase 3 com hipóteses como `[pendente]`?".
  - Em `andaime/ARTIFACTS_SPEC.md` §2.4.4 regra 6, atualizar de "Orientação: até cinco perguntas" para "no mínimo cinco perguntas; sem teto duro".
  - Decidir se `SPEC.md` §4.4.2 também precisa de atualização (provavelmente sim, por coerência).
  - Atualizar o Teste 2 do ROTEIRO para refletir o novo mínimo nos critérios de "O que deve aparecer" e "Sinais de problema".

---

### 5. `/refactor-safe` oferece "aceitar o risco e seguir" como opção válida ao bater no gate de cobertura ✅ resolvido (2026-06-13)

- **Resolução:** `refactor-safe.md` Passo 1 ganhou gate de cobertura duro (só (a) adicionar testes ou (b) cancelar; sem override verbal). Regra promovida à constitution universal `## Política de falhas` → "Gates duros não admitem override conversacional". **Re-teste 2026-06-13 (T9 cenário B, sessão fresca, `/tmp/cf-refactor`): ao refatorar `report.py` sem cobertura, recusou; insistência verbal "aceito o risco, vai mesmo assim" NÃO destravou; só ofereceu (a)/(b); `report.py` intocado. ✓**

- **Origem:** Teste 9 cenário B (2026-05-28, projeto koryn-ai, `csv_processor.py` sem testes)
- **Artefato afetado:** `framework/library/workflows/refactor-safe.md` (Passo 1 — Snapshot de testes existentes).
- **Severidade:** dilui a regra dura do gate
- **Descrição:** quando bateu no gate de cobertura, a IA recusou refatorar **e aplicou o formato `PARADO`** corretamente, mas ofereceu três opções: (1) `/feature-small` para adicionar testes primeiro, (2) **"aceitar o risco explicitamente e seguir mesmo sem testes — exige tua confirmação direta"**, (3) cancelar. A opção 2 não devia existir: o `refactor-safe.md` é explícito no "Quando NÃO usar" que cobertura insuficiente exige adicionar testes **antes** de refatorar. Ao oferecer override por confirmação verbal, a IA transforma um gate duro em soft — se o usuário disser "vai mesmo assim", o workflow vira `/refactor-yolo`. O gate existe justamente para não ter atalho.
- **Ação proposta:**
  - Em `framework/library/workflows/refactor-safe.md` Passo 1, reforçar: "Sem cobertura, **só** há dois caminhos: (a) adicionar testes via `/feature-small`/`/bugfix` e retomar; (b) cancelar. Confirmação verbal não destrava o gate. Para refator sem cobertura, abrir decision arquitetural dedicada antes — não é cabível dentro deste workflow."
  - Considerar adicionar essa mesma regra como parte da constitution universal sob `## Política de falhas`, categoria "Escopo" — "Gates duros de workflow não admitem override conversacional. Override exige decision registrada antes da próxima invocação."

---

### 4. Workflow não gera decision quando IA **conscientemente diverge da constitution** para seguir vizinhança ✅ resolvido (2026-06-13)

- **Resolução:** `feature-small.md` e `bugfix.md` Passo 6 ganharam gatilho explícito "Divergência consciente da constitution → sempre gerar decision". `self-review/SKILL.md` ganhou item de checklist que bloqueia o "pronto" se há divergência sem decision.

- **Origem:** Teste 8 (2026-05-28, projeto koryn-ai, endpoint `GET /me/quotes/count`)
- **Artefato afetado:** `framework/library/workflows/feature-small.md` (Passo 3 — Implementar) e `framework/core/constitution.md` universal (critério "quando gerar decision em `gera_decision: auto`"). Possivelmente reforço no `framework/library/skills/self-review/SKILL.md`.
- **Severidade:** bug de critério (silencia conflito relevante entre código e constitution)
- **Descrição:** o `/feature-small` no Koryn-AI implementou endpoint que **retorna `dict` solto** (`{"success": ..., "data": {...}, "message": ...}`) em vez de Pydantic model. A constitution do projeto declara como regra invariante: *"Validação de entrada e saída de endpoint é feita por Pydantic. Endpoints retornam Pydantic models, nunca dicts soltos."* A IA **reconheceu o conflito explicitamente** no self-review: *"Retorno como dict (convenção real do código — quotes.py, users.py também fazem assim, embora a constitution declare Pydantic; mantida consistência com vizinhança)."* Mas **não gerou decision** em `.codeflow/decisions/`, mesmo o workflow sendo `gera_decision: auto`. Esse é exatamente o cenário canônico de trade-off não-óbvio: "constitution vs convenção real do código" — sem decision, daqui a alguns meses outro dev lê a constitution, reescreve o endpoint pra usar Pydantic, quebra o padrão real, e ninguém entende por quê. Pior: a pergunta legítima — *a constitution está errada ou o código está em débito?* — fica sem resposta registrada.
- **Ação proposta:**
  - Em `framework/library/workflows/feature-small.md` (e nos outros workflows com `gera_decision: auto`), adicionar critério explícito: "**Sempre gerar decision quando a implementação diverge conscientemente de uma regra invariante da constitution** — seja para seguir convenção real do código, seja por trade-off técnico. A decision registra: qual regra, qual divergência, por que, e qual debt fica em aberto (corrigir constitution ou corrigir código)".
  - Em `framework/library/skills/self-review/SKILL.md`, adicionar item ao checklist: "Algum diff viola regra invariante da constitution? Se sim, decision foi gerado? Se não — bloquear o `pronto`."
  - Eventualmente promover esse critério a rule universal `decision-trigger` (parente de `naming` / `code-quality`), já que vale para todos os workflows que produzem código.

---

### 3. `bugfix` não registra decision quando faz escolha após `não sei` do usuário ✅ resolvido (2026-06-13)

- **Resolução:** `bugfix.md` e `feature-small.md` Passo 6 ganharam gatilho "Default após incerteza do usuário → gerar decision"; `self-review/SKILL.md` reforça com item de checklist.

- **Origem:** Teste 5 (2026-05-28, projeto koryn-ai, bug controlado de status code)
- **Artefato afetado:** `framework/library/workflows/bugfix.md` (Passo de fix + critério `gera_decision: auto`) — possivelmente reforço em `framework/library/skills/debug-protocol/SKILL.md`.
- **Severidade:** observação / melhoria de critério (não bug claro — comportamento é defensável)
- **Descrição:** durante o `/bugfix`, a IA fez uma pergunta sobre qual status code usar (409 vs 400 vs 422). O usuário respondeu `Não sei`. A IA aplicou default justificado (409 + `EMAIL_ALREADY_REGISTERED` no formato `CODE_UPPER_SNAKE` da constitution) — comportamento correto herdado do path de incerteza do `discover`. **Mas não gerou decision** em `.codeflow/decisions/`, justificando como "restaurar HEAD + alinhar à constitution, sem trade-off arquitetural". A justificativa é defensável (409 era o valor original do HEAD), mas o critério "auto" do workflow não tem regra clara sobre **quando uma escolha após incerteza do usuário merece decision**. Em vácuo argumentativo, IAs vão variar (esta declinou; outra poderia ter gerado). O caso é especialmente sensível porque a IA também ofereceu "Posso gerar uma se preferir" — sinal de que ela mesma achou borderline.
- **Ação proposta:**
  - Em `framework/library/workflows/bugfix.md`, adicionar critério explícito: "Se a IA aplicou default após o usuário responder `não sei`/`o que você recomenda?`, gerar decision curto registrando o default escolhido e a justificativa — para que futuros leitores entendam por que esse status (e não outro) ficou no código". Alternativa: deixar critério em "auto" mas exemplificar o caso no `## Antes de começar` do workflow.
  - Avaliar se vale subir o critério para o nível universal (rule de `decision-trigger`) já que afeta vários workflows com `gera_decision: auto`.

---

### 2. Rótulos de hipóteses em `discovered.md` devem ser literais `[confirmada]` / `[refutada]` / `[pendente]` ✅ resolvido (2026-06-13)

- **Resolução:** corrigido bug na própria skill (a tabela de incerteza mandava escrever `[confirmada por default]`). `discover/SKILL.md` Fase 4a e `ARTIFACTS_SPEC.md` §2.4 ganharam quadro "forma correta vs. incorreta" e anti-padrão "rótulo com texto extra dentro dos colchetes". **Re-teste 2026-06-13 (T2, sessão fresca): 8 hipóteses no `discovered.md`, todas com rótulo literal `[confirmada]`/`[pendente]`, zero texto extra nos colchetes — inclusive o caso "usa o padrão" ficou `[confirmada]` (origem no texto). Verificado por grep no arquivo. ✓**

- **Origem:** Teste 2 (2026-05-28, projeto koryn-ai — observado em **2 rodadas independentes** do `/discover`)
- **Artefato afetado:** `framework/meta/discover/SKILL.md` (Fase 4a) — possivelmente reforço de exemplo no `andaime/ARTIFACTS_SPEC.md` §2.4.5 (template).
- **Severidade:** bug leve recorrente (desvio de schema, conteúdo correto)
- **Descrição:** o `discovered.md` recebe rótulos com variantes proibidas em vez dos literais `[confirmada]` / `[refutada]` / `[pendente]`. A regra é explícita no `ARTIFACTS_SPEC.md` §2.4.6 ("rótulo entre colchetes é vinculante") e no próprio `discover/SKILL.md` Fase 4a ("Não usar variantes como `confirmada-pela-inspeção`, `confirmada pelo usuário`, etc. — registrar a origem da confirmação no texto da hipótese, mas o rótulo de estado entre colchetes é vinculante"). A IA segue o conteúdo (texto da hipótese registra a origem) mas mistura origem com rótulo.
- **Evidência acumulada:**
  - Rodada 1 (apagada): 3 ocorrências de `[confirmada por usuário]`.
  - Rodada 2 (atual em `Koryn-Ai/.codeflow/discovered.md`): `[confirmada — divergente da memória local]` (linha 34), `[confirmada pelo usuário]` (linhas 35 e 36) — total 3 ocorrências, em formatos diferentes da 1ª rodada.
  - Recorrência em rodadas independentes indica que a regra no `SKILL.md` está visível mas não impressiva o suficiente.
- **Ação proposta:**
  - Reforçar a regra no `framework/meta/discover/SKILL.md` Fase 4a com exemplo positivo e negativo lado a lado (já está descrita, mas a IA passou por cima). Mover para mais próximo do template, ou destacar como bloco de aviso.
  - Avaliar se o template literal em `andaime/ARTIFACTS_SPEC.md` §2.4.5 deveria começar com um quadro do tipo "Forma correta vs. forma incorreta" para os rótulos. Hoje só mostra exemplos certos; explicitar o errado pode prevenir.
  - Corrigir manualmente o `discovered.md` atual do Koryn-AI (trocar `[confirmada por usuário]` → `[confirmada]`, deixando a origem no texto) — opcional, baixo impacto, mas útil para o teste rodar limpo.

---

### 6. `/bootstrap` rotula como "Padrões detectados" uma arquitetura apenas *decidida*, e gera entrypoint apontando para módulo inexistente ✅ resolvido (2026-06-13)

- **Resolução:** `ARTIFACTS_SPEC.md` §2.3 agora define a 4ª seção do manifest como dependente da origem: `## Padrões detectados` (discover) vs `## Padrões definidos` (bootstrap, verbos prospectivos). `bootstrap/SKILL.md` Fase 4/validação atualizado; Fase 5 passou a avisar sobre entrypoint apontando módulo inexistente (`pip install -e` cria console-script quebrado). **Re-teste 2026-06-13 (T10, sessão fresca, `/tmp/cf-bootstrap`, projeto `tsconv`): manifest gerou `## Padrões definidos` com verbos prospectivos; sem `discovered.md`; Fase 5 avisou do entrypoint `tsconv.cli:main` apontando módulo inexistente. Verificado no arquivo. ✓**

- **Origem:** Teste 10 (2026-06-05, projeto novo `tsconv` em `~/projetos/codeflow-bootstrap-test`)
- **Artefato afetado:** `framework/meta/bootstrap/SKILL.md` (Fase 4 — geração do `manifest.md`) e `andaime/ARTIFACTS_SPEC.md` §2.3.5 (template do manifest, seção `## Padrões detectados`).
- **Severidade:** UX / clareza (não bug — esqueleto é válido)
- **Descrição:** o `manifest.md` gerado pelo bootstrap usa o cabeçalho `## Padrões detectados` (herdado do template, que foi pensado para o `/discover`, onde há código a inspecionar) e ali afirma: *"núcleo puro (`convert.py`) separado da camada de I/O (`cli.py`), estabelecido pelo bootstrap"*. Mas esses arquivos **não existem** — é arquitetura *decidida* na Fase 2, não *detectada*. No bootstrap nada é detectado: tudo é decisão prospectiva. Some-se a isso que o `pyproject.toml` declara `[project.scripts] tsconv = "tsconv.cli:main"` apontando para um módulo (`cli.py`) que ainda não existe — um `pip install -e ".[dev]"` cria um console-script quebrado até a feature ser implementada por um workflow posterior. Coerente com "é só esqueleto", mas a palavra "detectados" num projeto recém-nascido é enganosa para quem lê o manifest depois.
- **Ação proposta:**
  - No `framework/meta/bootstrap/SKILL.md` Fase 4, instruir que no manifest gerado por bootstrap a seção seja rotulada `## Padrões definidos` (ou `## Padrões adotados`) em vez de `## Padrões detectados`, e que o texto use verbos prospectivos ("a estabelecer", "definido como meta") para estruturas ainda não materializadas em arquivos.
  - Avaliar em `andaime/ARTIFACTS_SPEC.md` §2.3.5 se o template do manifest precisa de uma variante para bootstrap vs. discover (o título da seção muda conforme a origem). Hoje há um template único; bootstrap e discover compartilham, e a semântica "detectado" só vale para discover.
  - Decidir se o entrypoint quebrado no `pyproject.toml` é aceitável (esqueleto honesto) ou se a Fase 5 deveria avisar explicitamente que `pip install -e` falhará/criará script inválido até a feature existir. Hoje a nota da Fase 5 só menciona o `pytest exit 5`, não o console-script.

---

### 7. `/create-agent` não recusa quando uma skill bastaria — "read-only ⇒ isolamento mecânico" racionaliza qualquer tarefa de revisão/auditoria ✅ resolvido (2026-06-13)

- **Resolução:** `create-agent/SKILL.md` Princípio guia + Passo 1 ganharam o teste de contraste (read-only conveniência → skill; read-only necessidade mecânica → agent) com as duas condições obrigatórias (separável em lote **E** ferramenta de mutação tentadora a excluir) e a tabela "checklist de revisão → recusar" vs "auditoria de deps → aprovar". `ARTIFACTS_SPEC.md` §1.10.7 reforçado. **Re-teste 2026-06-13 (sessão fresca, `/tmp`): T1 agora recusa o checklist e redireciona para `/create-skill`; T2 aprova a auditoria com `Bash` excluído. ✓**

- **Origem:** Teste 11 Tentativa 1 (2026-06-05, projeto koryn-ai — proposta "agent que aplica nosso checklist de revisão de código")
- **Artefato afetado:** `framework/meta/create-agent/SKILL.md` (Passo 1 — Qualificar a necessidade) e `andaime/ARTIFACTS_SPEC.md` §1.10.7 (anti-padrão "Agent que duplica skill").
- **Severidade:** bug de critério (falha o objetivo central do teste — a recusa)
- **Descrição:** a Tentativa 1 é o caso canônico que o `/create-agent` **deveria recusar** e redirecionar para `/create-skill` (§1.10.7: se a sub-tarefa é realizável com disciplina, use skill). Em vez de recusar, a IA **emendou direto pra criar** o agent `revisor-checklist`, fabricando justificativa de isolamento: *"um revisor que pode alterar o que revisa anula a revisão"* + *"forma veredito em contexto próprio"*. Um checklist de revisão **é aplicável com disciplina** (uma skill que diz "só revise, não edite" resolve) — a restrição read-only é *desejável*, não uma *necessidade mecânica*. A IA nem ofereceu a opção de skill nem ponderou recusa; passou por cima do Passo 1.
- **O problema mais profundo (fronteira T1/T2 subespecificada):** a Tentativa 2 (auditoria de dependências read-only) **também é read-only** e **deve ser aprovada** — e de fato passou limpa. Então "read-only" **não pode** ser o critério que distingue "recusar" (T1) de "aprovar" (T2). A IA usou para T1 quase o mesmo argumento que valida a T2. O critério atual do Passo 1 ("exige garantia mecânica de não-modificação?") responde "sim" para qualquer tarefa de revisão/auditoria, porque toda revisão "fica melhor" read-only. Falta um teste afiado que separe *"read-only é conveniência"* (→ skill) de *"read-only é necessidade mecânica genuína"* (→ agent). O que de fato distingue o `auditor-dependencias` aprovado: (a) é tarefa **separável em lote** com saída autocontida, e (b) a tentação concreta de "consertar enquanto audita" (`pip install`, regenerar lockfile) exige excluir **Bash por inteiro** — uma restrição que disciplina não cobre bem. O checklist de revisão não tem nenhum desses: roda inline no workflow que já tem o diff, e não há ferramenta de mutação tentadora além da disciplina de "não edite".
- **Ação proposta:**
  - Em `framework/meta/create-agent/SKILL.md` Passo 1, adicionar um teste de contraste explícito: "Pergunte-se: *a versão skill desta tarefa seria insegura ou impraticável?* Se uma skill com a instrução 'apenas observe/revise, não modifique' resolveria com disciplina, **recuse** — read-only por conveniência não justifica agent. Agent só quando: a tarefa é separável em lote com saída autocontida **E** existe uma ferramenta de mutação concretamente tentadora (ex.: `Bash` capaz de `pip install`/migração) que precisa ser removida na camada da ferramenta."
  - Acrescentar os dois casos como exemplos lado a lado no `SKILL.md`: "checklist de revisão → skill (recusar agent)" vs. "auditoria de dependências read-only → agent (Bash excluído por inteiro)". São quase idênticos na superfície; o exemplo ensina a distinção.
  - Em `andaime/ARTIFACTS_SPEC.md` §1.10.7, reforçar o anti-padrão "Agent que duplica skill" com a frase: "Restrição read-only desejável ≠ restrição read-only necessária. Se disciplina ('não edite') basta, é skill."

---

### 8. Meta-skills referenciam `ARTIFACTS_SPEC.md` / `SPEC.md` que não são instalados em `~/.codeflow/framework/` ✅ resolvido (2026-06-13)

- **Resolução:** `git mv andaime/{SPEC,ARTIFACTS_SPEC}.md → framework/core/` (contratos normativos de runtime, não andaime). README raiz, `andaime/README.md`, `SPEC.md` §2.2 (árvore) e o glossário atualizados; cada consumidor de runtime (5 meta-skills, 4 workflows, glossary) ganhou ponteiro de path resolvível para `~/.codeflow/framework/core/`. Build docs (BUILD_PLAN/VALIDATION/PROMPTS/EXECUTION_LOG) mantidos com path antigo por serem registro histórico. O ROTEIRO já apontava para `framework/core/ARTIFACTS_SPEC.md` — agora correto.

- **Origem:** Teste 11 Tentativa 2 (2026-06-05, koryn-ai) — observado também de leve no Teste 10
- **Artefato afetado:** `install.sh` (o que é copiado para `~/.codeflow/`) e/ou todos os `framework/meta/*/SKILL.md` que citam `ARTIFACTS_SPEC.md §x` e `SPEC.md §x` sem path resolvível.
- **Severidade:** bug de instalação / degradação silenciosa de comportamento
- **Descrição:** os `SKILL.md` das meta-skills referenciam `ARTIFACTS_SPEC.md` (templates §1.10.5, §2.x.5) e `SPEC.md` como fonte autoritativa, mas **nenhum dos dois é instalado em `~/.codeflow/framework/`**. O `ARTIFACTS_SPEC.md` só existe em `~/.codeflow/andaime/ARTIFACTS_SPEC.md`; `SPEC.md` não foi localizado no instalado. Na Tentativa 2 a IA **declarou explicitamente** que não achou o spec e **caiu para um fallback**: usou o `revisor-checklist.md` já existente no projeto (gerado na Tentativa 1, que falhou!) como template autoritativo. Deu certo por sorte (o arquivo segue as 5 seções), mas o template canônico ficou inacessível — comportamento degradado e silencioso. No Teste 10 a IA conseguiu achar o spec porque buscou na pasta `andaime/`, mas isso depende de a IA decidir vasculhar; a referência nua `ARTIFACTS_SPEC.md §1.10.5` não resolve sozinha a partir de `~/.codeflow/framework/meta/`.
- **Ação proposta:**
  - Decidir o contrato: ou (a) `install.sh`/empacotamento copia `ARTIFACTS_SPEC.md` (e `SPEC.md` se for fonte de runtime) para `~/.codeflow/framework/core/`, ou (b) os `SKILL.md` passam a referenciar o path real instalado (ex.: `~/.codeflow/andaime/ARTIFACTS_SPEC.md`).
  - Se o spec é material de *andaime* (teste/dev) e **não** deve ir para runtime, então os `SKILL.md` não podem depender dele — os templates §x.5 precisam ser embutidos/duplicados nos próprios `SKILL.md`, ou num arquivo de templates instalado junto.
  - Cobre também a referência errada do ROTEIRO/skills a `~/.codeflow/framework/core/ARTIFACTS_SPEC.md` (path que não existe), já anotada nos Testes 2 e 10.

---
