---
versão: 1.0
status: estável
atualizado: 2026-05-23
descrição: Entrevista o usuário e gera definição de subagente com escopo de ferramentas restrito.
é_meta_skill: yes
granularidade: médio
---

# Meta-skill: create-agent

> **Specs de runtime:** as referências a `ARTIFACTS_SPEC.md §x` (template e validação) e a `SPEC.md §x` ao longo deste protocolo apontam para `~/.codeflow/framework/core/ARTIFACTS_SPEC.md` e `~/.codeflow/framework/core/SPEC.md`. Leia o template literal de lá — não parafraseie de memória.

## Quando usar

Usuário invoca `/create-agent` quando identifica necessidade de isolar uma sub-tarefa em contexto próprio com restrição mecânica de ferramentas. A meta-skill conduz a entrevista, gera o arquivo no formato correto e o salva no caminho apropriado.

## Princípio guia

Agent é mais caro de operar do que skill e justificável apenas quando a sub-tarefa exige garantia mecânica de isolamento ou restrição de ferramentas. Disciplina não basta — o agent restringe na camada da ferramenta de IA. Se skill regular bastaria, recusar e redirecionar.

**Cuidado com a armadilha do read-only.** Quase toda tarefa de revisão ou auditoria "fica melhor" read-only — mas *desejável* não é *necessário*. Restrição read-only por **conveniência** (uma skill que diz "apenas revise, não edite" resolveria com disciplina) **não** justifica agent. Restrição read-only por **necessidade mecânica** (existe uma ferramenta de mutação concretamente tentadora que precisa ser removida na camada da ferramenta) justifica. O viés default desta meta-skill é **recusar** — só prosseguir quando o teste de contraste do Passo 1 passa de forma inequívoca.

## Protocolo

### Passo 1 — Qualificar a necessidade (justificar isolamento)

**Teste de contraste (aplicar antes de qualquer outra coisa):** pergunte-se *"a versão skill desta tarefa seria insegura ou impraticável?"* Se uma skill com a instrução "apenas observe/revise, não modifique" resolveria com disciplina, **recuse** e redirecione para `/create-skill` — read-only por conveniência não justifica agent.

Só prosseguir quando **as duas** condições abaixo forem verdadeiras (ambas, não uma):
1. **Separável em lote com saída autocontida** — a tarefa roda de ponta a ponta sozinha e entrega um veredito/relatório fechado, não um passo inline dentro do workflow chamador (que já tem o diff e o contexto na mão).
2. **Ferramenta de mutação concretamente tentadora** — existe uma capacidade específica (ex.: `Bash` capaz de `pip install`, regenerar lockfile, rodar migração) cuja tentação de "consertar enquanto audita" é real e precisa ser **removida na camada da ferramenta**, porque disciplina ("não rode isso") não cobre bem. Excluir *uma ferramenta inteira* é a marca do isolamento genuíno.

Se qualquer uma das duas falhar, **recusar** e redirecionar para criar skill regular (`ARTIFACTS_SPEC.md` §1.10.7 anti-padrão "Agent que duplica skill"). "Para garantir qualidade", "para não modificar por engano" ou "para ficar isolado" **não** são justificativas — disciplina cobre todas.

**Dois casos quase idênticos na superfície, decisões opostas:**

| Proposta | Decisão | Por quê |
|---|---|---|
| "Agent que aplica nosso checklist de revisão de código" | **Recusar → skill** | Read-only é *desejável*, não *necessário*. Roda inline no workflow que já tem o diff. Não há ferramenta de mutação tentadora além da disciplina "não edite". Uma skill "apenas revise" resolve. |
| "Agent read-only de auditoria de dependências, sem poder modificar arquivos" | **Aprovar → agent** | Separável em lote com saída autocontida **E** a tentação concreta de "consertar enquanto audita" (`pip install`, regenerar lockfile) exige excluir `Bash` por inteiro — restrição que disciplina não cobre. |

Ambas são "read-only". O que decide **não** é o read-only — é o teste de contraste acima. Se você se pegar fabricando uma justificativa de isolamento para uma tarefa de revisão ("um revisor que pode editar anula a revisão"), pare: isso vale para *toda* revisão e é exatamente o sinal de que uma skill basta.

### Passo 2 — Identificar escopo
- Perguntar: o agent é específico de stack ou domínio deste projeto?
  - Sim → escopo de projeto.
- Perguntar: o agent já foi (ou claramente será) útil em dois projetos distintos?
  - Sim → escopo universal, após confirmar critérios de `EVOLUTION.md`.
- Caso contrário → projeto por padrão. No escopo inicial do framework, nenhum agent universal é entregue (`SPEC.md` §4.5.4).

### Passo 3 — Coletar metadata e estrutura
- Nome do agent (kebab-case, sugerido pelo usuário; vira nome do arquivo `.md`).
- Propósito: o que o agent faz e por que existe **como agent** (justificativa de isolamento ou restrição). A palavra "isolamento" ou "restrição" deve aparecer.
- Lista positiva e fechada de ferramentas permitidas (ex: Read, Glob, Grep).
- System prompt literal (será inserido em bloco de código).
- Instruções de invocação (passos concretos do workflow chamador).

### Passo 4 — Verificar coerência de ferramentas
- Conferir que a lista de ferramentas permitidas não inclui tools mutuamente contraditórias ao propósito (ex: agent "somente leitura" não pode listar Edit, Write ou Bash).
- Conferir que a lista é positiva e fechada (sem "tudo exceto X").

### Passo 5 — Determinar destino
- Agent de projeto: `<projeto>/.codeflow/agents/<nome>.md`.
- Agent universal: `~/.codeflow/framework/library/agents/<nome>.md`.
- Confirmar com o usuário o destino antes de gerar.

### Passo 6 — Gerar arquivo conforme template
- Aplicar `## Template de saída` substituindo placeholders pelos valores coletados.

### Passo 7 — Validar e apresentar
- Aplicar `## Validação pós-geração`. Se qualquer check falha, corrigir antes de apresentar.
- **Nota informativa:** agents **não** ganham slash command próprio. São invocados de dentro de workflows que os chamam pelo nome (`SPEC.md` §4.5.2). Não executar `setup-slash-commands.sh` para agent — ele ignora `framework/library/agents/` por design (`SPEC.md` §3.6.1).

## Proibições durante esta meta-skill

- Não gerar agent quando skill regular resolveria. A meta-skill **recusa** criação nesse caso (`ARTIFACTS_SPEC.md` §1.10.7).
- Não aceitar `## Ferramentas permitidas` como declaração negativa ("tudo exceto X"). Sempre lista positiva fechada.
- Não inserir system prompt em prosa fora de bloco de código.
- Não criar agent universal sem confirmação explícita do usuário e aderência a `EVOLUTION.md`.
- Não criar agent seed para "demonstração" — agents nascem de necessidade concreta.

## Template de saída

Aplicar o template literal de `ARTIFACTS_SPEC.md` §1.10.5.

Substituir placeholders: `<nome>`, `<escopo>`, `<propósito>`, `<ferramentas-permitidas>`, `<system-prompt>`, `<como-invocar>`.

A estrutura resultante segue as cinco seções obrigatórias de agent conforme `ARTIFACTS_SPEC.md` §1.10.3: `# Agent: <nome>`, `## Propósito`, `## Ferramentas permitidas`, `## System prompt`, `## Como invocar`.

## Onde salvar

- Agent de projeto: `<projeto>/.codeflow/agents/<nome>.md`.
- Agent universal: `~/.codeflow/framework/library/agents/<nome>.md`.

Agent é arquivo único `.md` (não pasta), diferente de skill e meta-skill. Critério: agent específico de stack ou domínio do projeto → projeto. Agent agnóstico e com uso real em dois ou mais projetos → universal (somente após critérios da `EVOLUTION.md` serem satisfeitos).

## Validação pós-geração

- Aplicar regras de validação de `ARTIFACTS_SPEC.md` §1.10.6 ao arquivo gerado.
- Verificar que `## Propósito` declara explicitamente por que agent (não skill), com a palavra "isolamento" ou "restrição" presente.
- Verificar que `## Ferramentas permitidas` é lista positiva em bullets `-`, sem declarações negativas.
- Verificar que `## System prompt` contém o prompt literal em bloco de código markdown.
- Verificar coerência entre `escopo` no frontmatter e localização do arquivo (`ARTIFACTS_SPEC.md` §3.9 regra 33).
- Apresentar resumo do agent gerado ao usuário antes de finalizar, com o caminho do arquivo.

## Saídas válidas

- **Agent gerado:** arquivo `.md` no caminho declarado, passando todas as regras de validação de `ARTIFACTS_SPEC.md` §1.10.6. Resumo apresentado ao usuário.
- **Agent recusado (Passo 1):** mensagem ao usuário explicando por que a sub-tarefa não justifica agent, com sugestão de criar skill regular em vez.
