---
versão: 1.0
status: experimental
granularidade: detalhado
gera_decision: no
usa_checkpoints: yes
politica_falhas: padrão
---

# Workflow: ideacao

## Princípio guia
Uma ideia vira produto quando o **o quê** e o **por quê** ficam explícitos antes do **como**. Este workflow amadurece a ideia em diálogo — clareza, mercado, escopo, prioridade — e a materializa num **roteiro de desenvolvimento** (`roteiro.md`, `ARTIFACTS_SPEC.md §2.12`): o norte que depois é fatiado em specs. Pesquisa de mercado é rotulada por procedência: nada de número ou concorrente inventado. Decisão de produto em aberto fica registrada como aberta, nunca chutada.

## Quando usar
Tirar uma ideia do papel: clarificar o que se quer construir, investigar mercado e concorrentes, definir o MVP, priorizar o que fazer, e produzir o `roteiro.md`. Serve para **projeto novo** (greenfield — o workflow cria a pasta do projeto) e para **projeto existente** que ainda não tem um norte de produto documentado (escreve o roteiro no `.codeflow/` que já existe). Pré-requisito: o owner está disponível para o diálogo — este workflow é conversacional por natureza.

A cadeia natural: `/ideacao` (produz `roteiro.md`) → `/bootstrap` (scaffolda o projeto consumindo o roteiro) → `/create-spec` (transforma um item do `## Backlog priorizado` em spec) → `/execute-spec-phase`.

## Quando NÃO usar
- Para criar o esqueleto técnico do projeto (pastas, stack, comandos) → isso é `/bootstrap`. Ideação decide produto, não encanamento.
- Para transformar um item já claro em spec executável → vá direto a `/create-spec`; ele aceita qualquer necessidade, venha do roteiro ou não.
- Para uma feature isolada e óbvia, sem ambiguidade de produto → roteiro é overhead; especifique direto.
- Para descobrir um projeto existente com código (stack, padrões, regras) → isso é `/discover`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/ARTIFACTS_SPEC.md §2.12 (schema do roteiro — ler o template literal, não parafrasear)
- ~/.codeflow/framework/core/constitution.md
- .codeflow/constitution.md (se o projeto já existe)
- .codeflow/roteiro.md (se já existe — este workflow o revisa, não o recria do zero)

## Estrutura do workflow
Seis fases sequenciais com checkpoint ao fim de cada uma. Pausa para o owner em três momentos: confirmação do nome/escopo inicial (Fase 1), validação do recorte de MVP (Fase 4) e aprovação do roteiro final (Fase 6). A última fase gera **um único documento** — `roteiro.md` — em `<projeto>/.codeflow/`. (Este workflow é `gera_decision: no`: decisões de produto vivem dentro do próprio roteiro, em `## Decisões em aberto`.)

## Retomada
`ideacao` usa checkpoints (`SPEC.md` §6.6). Ao iniciar, verificar se existe `<projeto>/.codeflow/checkpoints/ideacao-*.md` recente: se sim, apresentar o resumo e perguntar ao owner se deseja retomar daquele ponto ou começar do zero. Retomar carrega a fase em pausa e as decisões já tomadas; começar do zero deleta o checkpoint antigo.

## Fase 1 — Pré-flight e enquadramento da ideia

### Objetivo
Preparar o terreno e capturar a ideia bruta, estabelecendo onde o roteiro vai morar.

### Ações
1. **Data canônica:** obter a data de hoje com `date +%F` via Bash; usar em todos os campos de data. Não inferir de memória.
2. **Capturar a ideia** do owner literalmente: que produto, para quem, que dor resolve. Não julgar ainda — só registrar.
3. **Detectar o modo:**
   - **Existente** — o cwd já é um projeto com `.codeflow/constitution.md`. O roteiro será escrito em `./.codeflow/roteiro.md`. Não criar pasta nova. Se já existe `roteiro.md`, este workflow o **revisa** (bump de `versão`), não o recria.
   - **Greenfield** — o cwd não é um projeto inicializado (típico: você está em `~/projetos/`). Derivar um **nome** em kebab-case a partir da ideia, **confirmar o nome com o owner**, e criar `./<nome>/` com `mkdir -p <nome>/.codeflow/checkpoints`. O projeto e o roteiro passam a viver em `<nome>/`. Daqui em diante, `<projeto>` = essa pasta.
4. Redigir um parágrafo de "ideia em uma frase" + o público-alvo inicial e **apresentar ao owner para confirmação** antes de aprofundar.

### Checkpoint
Gravar `<projeto>/.codeflow/checkpoints/ideacao-<timestamp>.md` com: ideia bruta, modo (existente/greenfield), nome/pasta do projeto, frase-síntese e público inicial, e a confirmação do owner.

## Fase 2 — Clarificação da ideia

### Objetivo
Amadurecer a ideia por diálogo socrático: expor premissas, tensões e o problema real por trás do pedido.

### Ações
1. Fazer perguntas que **abram** a ideia: qual é a dor concreta, como o público resolve isso hoje, o que torna esta solução melhor, qual a hipótese de valor central.
2. Para cada resposta, refletir de volta o que foi entendido e ajustar — o objetivo é convergir num enquadramento que o owner reconheça como fiel.
3. Separar **problema** (a dor) de **solução** (o produto): registrar os dois, sem colapsar um no outro.
4. Anotar premissas que, se falsas, derrubam a ideia — entram em `## Riscos e premissas` na Fase 6.

### Checkpoint
Atualizar o checkpoint com: problema central, hipótese de valor, premissas críticas, e o enquadramento acordado.

## Fase 3 — Pesquisa de mercado e concorrentes

### Objetivo
Situar a ideia no mercado **sem inventar dados** — esta é a fase de maior risco de alucinação.

### Ações
1. Levantar concorrentes/alternativas (incluindo "fazer na mão" e "não fazer nada") e o panorama de demanda.
2. **Regra dura de procedência:** toda afirmação factual (número, concorrente, tendência) carrega `[verificado: <fonte>]` quando há fonte real, ou `[não verificado]` quando é hipótese. **Proibido** apresentar dado inventado como fato. Se houver ferramenta de busca web disponível, usar e **citar a fonte**; sem ela, tudo que não vier do owner é `[não verificado]`.
3. Destacar onde a ideia se diferencia e onde é fraca frente às alternativas — honestamente, mesmo quando desconfortável.

### Checkpoint
Atualizar o checkpoint com: concorrentes/alternativas, afirmações com seus rótulos de procedência, e o diferencial competitivo.

## Fase 4 — Escopo, personas e riscos

### Objetivo
Recortar o MVP: o menor produto que valida a hipótese de valor, com fronteira explícita.

### Ações
1. Definir as personas/segmentos do primeiro corte.
2. Listar o que **entra** no MVP e, explicitamente, o que fica **fora** — o fora-de-escopo é tão importante quanto o escopo.
3. Consolidar riscos (técnico, de mercado, de execução) e as premissas da Fase 2.
4. **Apresentar o recorte de MVP ao owner e aguardar confirmação** — esta pausa é obrigatória. Escopo aberto material não é chutado: ou o owner decide, ou vira item em `## Decisões em aberto`.

### Checkpoint
Atualizar o checkpoint com: personas, escopo do MVP, fora-de-escopo, riscos/premissas, e a confirmação do owner.

## Fase 5 — Priorização e marcos

### Objetivo
Ordenar o trabalho: marcos de entrega e o backlog que vira spec.

### Ações
1. Definir os **marcos** em grão grosso (marco → objetivo), em ordem de entrega. Não é o plano de fases da spec — é o mapa do produto.
2. Decompor o MVP em um **backlog priorizado** de fatias acionáveis — cada item é algo que `/create-spec` consegue transformar em spec. Atribuir prioridade a cada um e marcá-los `a fatiar`.
3. Conferir que cada item é uma fatia concreta (ex: "extração de texto de URL"), não um desejo vago ("melhorar a experiência").

### Checkpoint
Atualizar o checkpoint com: marcos ordenados e backlog priorizado com prioridades.

## Fase 6 — Geração de artefatos

### Objetivo
Escrever o `roteiro.md` final no formato canônico, validá-lo e entregar.

### Ações
1. **Gerar `<projeto>/.codeflow/roteiro.md`** seguindo o template de `ARTIFACTS_SPEC.md §2.12.5` **literalmente** — frontmatter (`versão`, `status`, `atualizado` = data da Fase 1, `projeto`), título `# Roteiro do projeto: <nome>`, e as dez seções obrigatórias na ordem de §2.12.3. Em modo "existente" com roteiro pré-existente: **revisar** o arquivo e fazer bump de `versão` (não datar nem criar `roteiro-<data>.md` — roteiro é vivo, §2.12.7).
2. **Validar item por item** contra `ARTIFACTS_SPEC.md §2.12.6`: dez seções na ordem; afirmações de mercado todas rotuladas; fora-de-escopo explícito; backlog com prioridade e estado de fatiamento; nenhum plano de fases técnico. Em falha, **regenerar o artefato inteiro** a partir do template, não corrigir parcialmente.
3. Se o projeto já tem `INDEX.md`, acrescentar `roteiro.md` em `## Leia se relevante ao contexto`.
4. **Apresentar o roteiro ao owner** (caminho + resumo das seções) e aguardar aprovação ou ajustes. Aplicar ajustes re-rodando a validação.
5. Concluído com sucesso, deletar os checkpoints da execução. Sugerir o próximo passo da cadeia: `/bootstrap` (greenfield) para scaffoldar consumindo o roteiro, ou `/create-spec` apontando um item do backlog.

## Proibições durante este workflow
- Não inventar dados de mercado: concorrente, número ou tendência sem `[verificado: <fonte>]` é alucinação; na dúvida, `[não verificado]`.
- Não pular a clarificação (Fase 2) nem a confirmação do MVP (Fase 4): perguntar é o trabalho deste workflow, não atrito a evitar.
- Não escrever plano de execução técnico (arquivos, passos, testes, fases de implementação) no roteiro — isso é spec (`/create-spec`).
- Não declarar regra invariante ("toda senha é hasheada com X") no roteiro — isso é constitution (`/discover --refresh` ou edição da constitution).
- Não chutar decisão de produto material: ou o owner decide, ou fica em `## Decisões em aberto`.
- Não criar código de aplicação, dependências ou estrutura de pastas técnica — ideação produz **um documento**.
- Não datar o roteiro nem encadear `superseded_by`: roteiro é vivo, revisões bumpam `versão`.
- Não inferir datas de memória — toda data vem do `date +%F` da Fase 1.

## Definition of Done
- [ ] Data obtida via `date +%F`; modo (existente/greenfield) detectado; em greenfield, pasta `<nome>/` criada com o owner confirmando o nome (Fase 1).
- [ ] Ideia clarificada em diálogo: problema separado de solução, premissas críticas registradas (Fase 2).
- [ ] Mercado pesquisado com **toda** afirmação rotulada `[verificado: <fonte>]` ou `[não verificado]` (Fase 3).
- [ ] MVP recortado com fora-de-escopo explícito, confirmado pelo owner (Fase 4).
- [ ] Marcos ordenados e backlog priorizado de fatias acionáveis (Fase 5).
- [ ] `<projeto>/.codeflow/roteiro.md` gerado a partir do template §2.12.5, passando em todas as regras de §2.12.6; `INDEX.md` atualizado se existir.
- [ ] Roteiro aprovado pelo owner; checkpoints da execução deletados.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
