---
versão: 1.0
status: estável
atualizado: 2026-05-23
descrição: Entrevista o usuário e gera skill nova no formato correto.
é_meta_skill: yes
granularidade: médio
---

# Meta-skill: create-skill

## Quando usar

Usuário invoca `/create-skill` quando identifica necessidade de nova skill universal ou de projeto. A meta-skill conduz a entrevista, gera o arquivo no formato correto e o salva no caminho apropriado.

## Princípio guia

Skill nova cobre um protocolo repetível com princípio guia claro. A entrevista qualifica antes de gerar: se a necessidade é uma regra estática, criar rule; se é uma sequência de passos com decisões abertas, criar workflow; se cabe como instrução modular reaproveitável por múltiplos workflows, então skill.

## Protocolo

### Passo 1 — Qualificar a necessidade
- Perguntar: o conhecimento a registrar é reaproveitável por mais de um workflow? Tem princípio guia próprio? Não é apenas uma regra estática?
- Se a resposta é "regra estática", redirecionar para criar rule em vez de skill.
- Se a resposta é "passos com decisões abertas", redirecionar para criar workflow em vez de skill.
- Se nenhuma das duas condições afirmativas se aplica, recusar e sugerir resolver ad hoc.

### Passo 2 — Identificar escopo
- Perguntar: a skill é específica de stack, domínio ou padrão deste projeto?
  - Sim → escopo de projeto.
- Perguntar: a skill já foi (ou claramente será) útil em dois projetos distintos?
  - Sim → escopo universal, após confirmar critérios de `EVOLUTION.md`.
- Caso contrário → projeto por padrão (promoção a universal acontece via EVOLUTION).

### Passo 3 — Coletar metadata e estrutura
- Nome da skill (kebab-case, sugerido pelo usuário; vira nome da pasta).
- Descrição em uma linha (frontmatter).
- Princípio guia (frase única que orienta o protocolo).
- Lista de passos do protocolo (numerados, imperativos).
- Proibições durante a skill.
- Saídas válidas.

### Passo 4 — Determinar destino
- Skill universal: `~/.codeflow/framework/library/skills/<nome>/SKILL.md`.
- Skill de projeto: `<projeto>/.codeflow/skills/<nome>/SKILL.md`.
- Confirmar com o usuário o destino antes de gerar.

### Passo 5 — Gerar arquivo conforme template
- Aplicar `## Template de saída` substituindo placeholders pelos valores coletados.

### Passo 6 — Validar e apresentar
- Aplicar `## Validação pós-geração`. Se qualquer check falha, corrigir antes de apresentar.
- **Nota informativa:** skills regulares **não** ganham slash command próprio. São carregadas via `## LEIA TAMBÉM` de workflows (`SPEC.md` §4.3.4). Não executar `setup-slash-commands.sh` para skill — ele ignora `framework/library/skills/` por design (`SPEC.md` §3.6.1).

## Proibições durante esta meta-skill

- Não gerar skill sem qualificar a necessidade no Passo 1.
- Não criar skill que faça o papel de rule (regra estática) ou de workflow (passos com decisões abertas).
- Não incluir `## Definition of Done` nem `## LEIA TAMBÉM` no arquivo gerado — ambos são vedados em skill (`ARTIFACTS_SPEC.md` §1.8).
- Não criar skill universal sem confirmação explícita do usuário e aderência a `EVOLUTION.md`.

## Template de saída

Aplicar o template literal de `ARTIFACTS_SPEC.md` §1.8.5.

Substituir placeholders: `<nome>`, `<descrição>`, `<princípio-guia>`, `<passos>`, `<proibições>`, `<saídas>`.

A estrutura resultante segue as seis seções obrigatórias de skill conforme `ARTIFACTS_SPEC.md` §1.8.3: `# Skill: <nome>`, `## Quando usar`, `## Princípio guia`, `## Protocolo`, `## Proibições durante esta skill`, `## Saídas válidas`.

## Onde salvar

- Skill de projeto: `<projeto>/.codeflow/skills/<nome>/SKILL.md`.
- Skill universal: `~/.codeflow/framework/library/skills/<nome>/SKILL.md`.

Critério: skill específica de stack ou domínio do projeto → projeto. Skill agnóstica e com uso real em dois ou mais projetos → universal (somente após critérios da `EVOLUTION.md` serem satisfeitos).

## Validação pós-geração

- Aplicar regras de validação de `ARTIFACTS_SPEC.md` §1.8.6 ao arquivo gerado.
- Verificar que a pasta da skill contém apenas `SKILL.md` (ou arquivos auxiliares declarados).
- Verificar que `SKILL.md` está em maiúsculas e o nome da pasta em kebab-case bate com o título.
- Verificar que não há `## Definition of Done` nem `## LEIA TAMBÉM` no arquivo.
- Apresentar resumo da skill gerada ao usuário antes de finalizar, com o caminho do arquivo.

## Saídas válidas

- **Skill gerada:** arquivo `SKILL.md` no caminho declarado, passando todas as regras de validação de `ARTIFACTS_SPEC.md` §1.8.6. Resumo apresentado ao usuário.
- **Skill recusada (Passo 1):** mensagem ao usuário explicando por que a necessidade não cabe como skill, com sugestão alternativa (criar rule, criar workflow, resolver ad hoc).
