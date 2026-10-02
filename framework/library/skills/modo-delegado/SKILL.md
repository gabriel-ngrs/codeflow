---
versão: 1.2
status: experimental
atualizado: 2026-10-02
descrição: Executar um workflow despachado por um orquestrador (Maestro) — gates humanos respondidos pelas decisões delegadas, o resto volta como PARADO, sem subagente, retorno curto.
---

# Skill: modo-delegado

## Quando usar

Carregar **antes do workflow** quando quem o invoca não é o dono no chat, e sim um **orquestrador** —
tipicamente o terminal Maestro de um workspace do Maestri, despachando um passo para um terminal
próprio. O sinal é o prompt de despacho começar com `MODO DELEGADO` e trazer o bloco de despacho
(orquestrador, ramo, workflow, decisões delegadas). Sem esse bloco, a skill não se aplica: o workflow
roda no modo normal, com o dono.

## Princípio guia

Quem invoca é o orquestrador, não o dono: toda pergunta que o workflow faria ao dono é respondida
pelas **decisões delegadas**, e o que elas não cobrem volta ao orquestrador — nunca vira palpite
silencioso, nunca vira pergunta esperando no terminal. A delegação troca **quem responde**, não
**o que é exigido**: gate duro continua duro.

## Protocolo

### 1. Situar-se antes de ler o workflow
- Ir para a raiz do repositório: `cd "$(git rev-parse --show-toplevel)"`. Os workflows usam caminhos
  relativos (`.codeflow/...`) e quebram fora dela.
- Conferir o ramo: tem de ser **o ramo declarado no despacho**. Se o ramo atual for outro, ou for
  `dev`/`main`/`master`, parar em `PARADO` — não trocar de ramo por conta própria.
- **Exceção — `Ramo: somente leitura`.** Quando o despacho declara isso (investigação, levantamento,
  leitura de código), o trabalho **não escreve no repositório**: a conferência de ramo não se aplica,
  e fica proibido editar arquivo versionado, commitar ou trocar de ramo. A saída vai para o caminho
  **fora do repositório** que o despacho indicar.
- Ler o bloco de despacho e guardar: o **nome do orquestrador**, o **workflow**, as **decisões
  delegadas** (numeradas) e as **regras do projeto** que vieram nele.

### 2. Cada gate humano do workflow passa por esta triagem
Quando o workflow mandar confirmar, perguntar ou aguardar o dono:
- **(a) As decisões delegadas cobrem o caso** → aplicar a decisão e registrar no relatório como
  "decisão N — por delegação, dada pelo orquestrador".
- **(b) Não cobrem, e a decisão é pequena** (reversível, dentro do escopo declarado, sem tocar gate
  duro) → seguir com a **opção conservadora** e registrar como "decisão pedida ao orquestrador", com
  a alternativa descartada. Ela sobe no retorno para o orquestrador ratificar ou corrigir.
- **(c) Não cobrem, e a decisão é de escopo, irreversível, ou toca gate duro** → parar em `PARADO`
  (formato da constitution), com as opções. O orquestrador decide ou leva ao dono e despacha de novo.

### 3. Gate duro não cede à delegação
- O que a constitution e as rules do projeto tratam como gate duro (segredo, dado real, mudança
  quebradora, ramo default, entre outros) **continua exigindo o que exige**. Uma decisão delegada que
  contradiga um gate duro é ignorada e reportada como `PARADO` — delegação não é atalho.

### 4. Um terminal, um trabalho — sem subagente
- Não usar a ferramenta de subagente (`Agent`/`Task`). Se o workflow pedir "um segundo agente" ou
  "verificação independente", isso **não** se faz aqui: registrar no retorno como pedido ao
  orquestrador, que despacha outro terminal.

### 5. Commit, e só commit
- Commitar no ramo do despacho, seguindo as rules de commit do projeto (inclusive a de atribuição).
- Adicionar ao commit **só os arquivos que o trabalho tocou**, pelo caminho (`git add <caminho>...`),
  e conferir com `git status` antes. Nunca `git add -A` nem `git add .`: a pasta pode ter arquivos
  locais (configuração, segredo, saída de ferramenta) que não são do trabalho.
  Se o workflow não commita por padrão e o despacho manda commitar, commitar.
- **Não** fazer push, abrir PR nem merge, a menos que o despacho mande explicitamente.

### 6. Duas saídas: o relatório em disco e o retorno curto
- **Relatório completo** — o resumo final do workflow (as cinco seções do `SPEC.md` §5.6.4), as
  decisões tomadas por delegação e as pedidas ao orquestrador vão para
  `.codeflow/checkpoints/relatorio-<workflow>-<AAAAMMDD-HHMM>.md`. A pasta já é ignorada pelo git e é
  própria de cada worktree.
- **Retorno ao orquestrador** — a **última mensagem** do terminal, no máximo **15 linhas**:

  ```
  ESTADO: CONCLUÍDO | PRECISA DE DECISÃO | PARADO
  Feito: <1–3 linhas>
  Commits: <sha curto — assunto>, ...
  Decisões pedidas ao orquestrador: <n — uma linha cada, ou "nenhuma">
  Pendências do dono: <o que só o dono faz, ou "nenhuma">
  Relatório: .codeflow/checkpoints/relatorio-<...>.md
  ```

- Se o despacho pedir retorno ativo, enviar o mesmo bloco com
  `maestri ask "<nome do orquestrador>" "<retorno>"`.

## Proibições durante esta skill

- Não fazer pergunta ao dono nem deixar o terminal esperando resposta — ou decide pela triagem do
  passo 2, ou para em `PARADO`.
- Não usar subagente.
- Não decidir escopo, nem nada irreversível, por conta própria — isso é o caso (c).
- Não trocar de ramo, nem trabalhar em `dev`, `main` ou `master`.
- Não fazer push, PR ou merge sem ordem explícita no despacho.
- Não usar `git add -A` nem `git add .` — só os caminhos que o trabalho tocou.
- Não colar segredo, credencial ou dado real no retorno, no relatório ou no canvas.
- Não mandar ao orquestrador o relatório inteiro: o detalhe fica em disco, o retorno tem até 15 linhas.

## Saídas válidas

- **Concluído:** trabalho commitado no ramo do despacho, relatório completo em
  `.codeflow/checkpoints/`, e retorno curto com `ESTADO: CONCLUÍDO`.
- **Precisa de decisão:** trabalho feito com decisões conservadoras pendentes de ratificação, listadas
  no retorno com `ESTADO: PRECISA DE DECISÃO`.
- **Parado:** reporte no formato `PARADO` da constitution dentro do retorno, com `ESTADO: PARADO` e as
  opções para o orquestrador.
