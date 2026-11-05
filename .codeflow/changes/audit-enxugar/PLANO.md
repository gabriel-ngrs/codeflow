---
mudanca: audit-enxugar
tipo: feature
tamanho: media
status: aprovado
aprovado_por: dono (lista de 05/11)
aprovado_em: 2026-11-05
registro: pacote de tokens aprovado pelo dono em 2026-11-05 (lista inteira, D1 e D5 do plano do Maestro da trilha de evolução); base na pesquisa de tokens de 2026-11-02, seções "Enxugar o código que JÁ existe" e "Rotina para o código existente"
---

<!-- Preenchido pelo PLANEJADOR (/plan-change), em modo delegado. Pela decisão
     delegada 1 (D1 do Maestro), o plano não espera o dono: o Maestro troca o
     status para aprovado (aprovado_por: dono (lista de 05/11), aprovado_em).
     tamanho: media = 3 etapas. -->

# Dimensão `enxugar` da auditoria — Plano

## 1. Objetivo

Dar aos projetos consumidores um caminho seguro para **enxugar o código que já existe**: ferramentas
determinísticas listam os candidatos sem LLM (arquivos, exports e dependências sem uso; duplicação;
complexidade), o agente confirma cada um contra o código real, e a remoção sai em lotes pequenos — uma
categoria, um pacote, ~300 linhas por PR — com typecheck, testes e build como rede. Hoje o framework só
tem "código morto" como item de baixa severidade no `audit-code-quality`, sem linha de base, sem ordem de
risco e sem regra de lote; pedir "enxugue o repo" a um agente sem lista de candidatos é o modo que a
pesquisa manda evitar.

**Encaixe escolhido: uma dimensão nova da família `/audit`** — skill `audit-enxugar` e a entrada
`enxugar` no workflow `audit`. Ela reaproveita, sem mudar o protocolo de nenhum: o `/audit` (somente
leitura, cobertura, ferramentas primeiro, saída bruta fora do repositório, laudo pelo molde), o
`/verify-audit` (confirmação em chat zerado, consolidado, taxa de falso positivo), os moldes `LAUDO.md` e
`CONSOLIDADO.md` e o `/refactor` em modo **puro** para executar cada lote (rede verde antes do primeiro
toque, passo a passo, `self-review`). Um workflow próprio repetiria esses quatro; a alternativa foi
descartada. Por ser skill e não workflow, não nasce slash command nem wrapper novo.

**Granularidade.** Um laudo `enxugar` por alvo (o repositório ou um pacote/workspace). Um **lote** é uma
categoria × um pacote, até ~300 linhas removidas ou ~20–30 itens, e vira **uma** execução do `/refactor`
em modo puro e **um** PR. Lote 0 de cada pacote é a config de ignorar (o que o agente julgou intencional).

**Gatilhos.** (a) o dono, ou o orquestrador da trilha de auditoria do projeto, inclui a dimensão
`enxugar` numa rodada; (b) projeto JS/TS — `knip` e `eslint` só se aplicam ali; em outra stack, só o
`jscpd` e o equivalente que o projeto já tiver, ou a dimensão sai `[—]`; (c) repetir por rodada até o
placar estabilizar (duas rodadas seguidas sem candidato "remover agora" na mesma área). Ligar o `knip` no
CI do projeto como alerta depois disso é decisão de cada projeto, fora deste plano.

## 2. Fora de escopo

- Qualquer outro item do pacote de tokens (trecho YAGNI nos workflows de execução, tetos de contexto,
  gate e registro) — estão nas worktrees `evolucao` e `-gate`.
- Instalar `knip`, `jscpd`, `eslint-plugin-sonarjs` ou qualquer ferramenta, aqui ou nos projetos: a skill
  descreve os comandos; ferramenta ausente vira `[—]` com o comando que o dono roda, se quiser.
- Mudar o protocolo do `audit`, do `verify-audit` ou do `refactor` além da linha de encaixe; mudar o
  `audit-code-quality` e o `audit-dependencies` (a sobreposição em código morto e dependência sem uso fica
  para a deduplicação do `/verify-audit`, Passo 2).
- Campos novos nos moldes `LAUDO.md` e `CONSOLIDADO.md` (anti-evolução: campo opcional "pode ser útil").
  A linha de base vai na seção 3 do laudo; o plano de lotes, no destino proposto da seção 4.
- Core (`framework/core/constitution.md`, `glossary.md`, `EVOLUTION.md`) e termo novo no glossary:
  "placar", "lote" e "linha de base" ficam como texto descritivo.
- `.codeflow/workflows/orquestrar-auditoria.md` deste repositório: o codeflow é bash e Markdown, a
  dimensão não se aplica a ele.
- A linha da decision no `decisions/INDEX.md` (é do Maestro) e a defasagem anterior do catálogo
  (`SPEC.md` §2.2 sem o ciclo de mudança nem as skills de auditoria; `ARTIFACTS_SPEC.md` §1.8.1): item da
  trilha de auditoria.

## 3. Classificação (skill `change-sizing`)

| Sinal | Valor | Evidência |
|-------|-------|-----------|
| Tipo | feature | o framework não tem hoje inventário determinístico de remoção nem regra de lote; o `audit-code-quality` §2 só lista "código morto" como candidato avulso de severidade baixa |
| Etapas | 3 | decision → skill → encaixe e catálogo; cada uma verde e commitada sozinha |
| Áreas tocadas | 2 camadas (library; contrato só no catálogo) + `.codeflow/decisions/` | `.codeflow/constitution.md`, "Padrão arquitetural" |
| Contrato / fronteira | compatível | `SPEC.md` §2.2 ganha uma linha de catálogo; `LAUDO.md` ganha o valor `enxugar` na lista de `dimensao` (aditivo; o molde não está na Parte 2 do `ARTIFACTS_SPEC.md`); nenhum artefato existente fica inválido |
| Migração | não | nenhum `.codeflow/` de projeto precisa ser reescrito |
| ADR nova | não (decision de registro) | exceção à anti-evolução decidida pelo dono em 2026-11-05 (`EVOLUTION.md`, "Anti-evolução": exige decision com justificativa e revisão trimestral) |
| Comportamento percebido | novo, porém isolado | dimensão opcional; só roda quando pedida; nenhum workflow existente muda de comportamento |
| Sinal de risco | nenhum | sem segredo, dado real, deploy de produção nem schema da Parte 2 |

## 4. Mapa do código

| Caminho | NOVO / ALTERADO / REUSADO | Para quê |
|---------|---------------------------|----------|
| `.codeflow/decisions/<AAAA-MM-DD>-audit-enxugar.md` | NOVO | exceção à anti-evolução: universal sem uso real em 2 projetos, por decisão do dono; nasce `experimental`; revisão trimestral; sem linha no INDEX |
| `framework/library/skills/audit-enxugar/SKILL.md` | NOVO | a dimensão: comandos das ferramentas, linha de base, confirmação de cada candidato, cuidados, plano de lotes e regras de execução do lote |
| `framework/meta/create-skill/SKILL.md` | REUSADO | meta-skill que gera a skill (entrevista respondida pela §6, Etapa 2) |
| `framework/core/ARTIFACTS_SPEC.md` | REUSADO | §1.8.3 e §1.8.6: schema e validação da skill |
| `framework/library/workflows/audit.md` | ALTERADO | `enxugar` na lista de dimensões de "Quando usar"; frontmatter 1.0 → 1.1 |
| `framework/library/workflows/refactor.md` | ALTERADO | "Quando usar": o lote do laudo `enxugar` entra em modo puro; "LEIA TAMBÉM": a skill `audit-enxugar`, só quando o pedido é um lote desse laudo; frontmatter 1.1 → 1.2 |
| `framework/library/templates/audits/README.md` | ALTERADO | linha `enxugar` → `audit-enxugar` na tabela de dimensões (sem frontmatter de versão) |
| `framework/library/templates/audits/LAUDO.md` | ALTERADO | `enxugar` na lista do campo `dimensao` (sem frontmatter de versão) |
| `framework/library/workflows/verify-audit.md` | REUSADO | confirma os candidatos do laudo `enxugar` como os de qualquer dimensão |
| `framework/library/templates/audits/CONSOLIDADO.md` | REUSADO | os confirmados vão para a lista de melhorias, já com o lote |
| `framework/library/skills/safe-refactor/SKILL.md`, `self-review/SKILL.md` | REUSADO | rede e revisão de cada lote, via `/refactor` |
| `framework/library/skills/audit-code-quality/SKILL.md`, `audit-dependencies/SKILL.md` | REUSADO | conferidos: a fronteira com `enxugar` fica escrita na skill nova, não nelas |
| `framework/core/SPEC.md` | ALTERADO | §2.2: linha `audit-enxugar/SKILL.md` na árvore de `library/skills/`; frontmatter 3.4 → 3.5 |
| `framework/core/SPEC.md` §3.5 | REUSADO | conferido: lista só workflows universais e nenhum nasce; nada a pagar |
| `README.md` | ALTERADO | "Quando usar": a auditoria por dimensão inclui enxugar o código existente; frontmatter 1.3 → 1.4 |
| `.codeflow/manifest.md` | REUSADO | gates `lint` e `check` das etapas |

> Todo caminho ALTERADO ou REUSADO existe no repositório (conferido ao escrever, em 2026-11-05).

## 5. Critérios de aceite

- **CA-1** — Dado o `.codeflow/decisions/`, quando a Etapa 1 termina, então existe
  `<AAAA-MM-DD>-audit-enxugar.md` no formato das decisions do repositório, com: a anti-regra que a
  mudança contraria (`EVOLUTION.md`, "Anti-evolução" — universal sem uso em 2 projetos), a decisão do dono
  de 2026-11-05 como justificativa, o item nascendo `experimental`, a data da revisão trimestral e o
  critério de saída (sem uso real em 2 projetos na revisão → remover ou rebaixar a skill de projeto); e o
  `decisions/INDEX.md` não muda.
- **CA-2** — Dado `framework/library/skills/audit-enxugar/SKILL.md`, quando validado pela §1.8.6 do
  `ARTIFACTS_SPEC.md`, então passa nas 10 regras: `descrição` numa linha, `status: experimental`,
  `versão: 1.0`, as seis seções na ordem, sem `## Definition of Done` nem `## LEIA TAMBÉM`, princípio guia
  de uma a três frases, proibições com bullet imperativo negativo, saídas por tipo.
- **CA-3** — Dado a skill, quando o auditor chega às ferramentas, então ela descreve os comandos do
  `knip` (`--reporter json`, `--workspace`, `--production`, `--dependencies`/`--files`/`--exports`), do
  `jscpd` (`--min-lines`, `--reporters json`, saída fora do repositório) e do `eslint` (`complexity`,
  `max-depth`, `max-lines-per-function`; `sonarjs` só se o projeto já tem o plugin) como **relatório**;
  roda só o que o projeto já tem, sem baixar (`npx --no-install`, `pnpm exec`); ferramenta ausente vira
  `[—]` com o comando para o dono; e proíbe `--fix`, autofix e instalar ferramenta.
- **CA-4** — Dado a skill, quando ela registra a linha de base, então pede, por pacote: linhas de código,
  contagem do `knip` por tipo, porcentagem de duplicação do `jscpd` e as 20 funções mais complexas, na
  seção 3 do laudo, para a rodada seguinte comparar.
- **CA-5** — Dado um candidato da ferramenta, quando o auditor o confirma, então a skill manda conferir:
  o nome em string, config, reflexão ou rota por convenção (uso dinâmico); scripts, CI e config da
  ferramenta de build que usam a dependência; export público de pacote consumido por outro pacote, app ou
  repositório; entrada por convenção (handler, worker, plugin carregado por nome); e código de migração,
  sync ou versão de schema que só roda em cliente antigo — esse nunca sai por "não ter uso". Cada
  candidato termina em remover agora, extrair helper, simplificar ou deixar; o "deixar" leva o motivo e
  vira entrada da config de ignorar (`knip.json` `ignore`/`ignoreDependencies`/`entry`, `.jscpd.json`
  `ignore`) no lote 0, em vez de voltar na próxima rodada.
- **CA-6** — Dado os candidatos confirmados, quando o auditor monta o destino proposto, então cada um leva
  o lote: uma categoria e um pacote por lote, até ~300 linhas ou ~20–30 itens, na ordem dependências →
  arquivos órfãos → exports → duplicação → complexidade; e a skill fixa a execução do lote: `/refactor`
  em modo puro, typecheck, testes e build do manifest como rede, parar no primeiro vermelho sem "consertar"
  teste, área sem cobertura não remove sem teste de caracterização, PR só daquele lote, e `/simplify` sobre
  o diff no fim **só dos lotes que reescrevem código** (duplicação e complexidade; quando a ferramenta de
  IA o oferece, senão `[—]`) — os lotes só de remoção não rodam `/simplify`.
- **CA-7** — Dado o `/audit` com a dimensão `enxugar`, quando ele carrega a skill da dimensão, então o
  `audit.md` lista `enxugar`, o `templates/audits/README.md` tem a linha `enxugar` → `audit-enxugar`, o
  `LAUDO.md` aceita `enxugar` em `dimensao`, e o `refactor.md` carrega `audit-enxugar` só quando o pedido
  é um lote desse laudo.
- **CA-8** — Dado o ramo, quando a Etapa 3 termina, então o catálogo está pago (`SPEC.md` §2.2 com a
  skill; §3.5 conferido; `README.md`; frontmatter `versão` e `atualizado` de cada arquivo tocado que o
  tem), nenhum arquivo do core foi tocado, nenhum nome de cliente ou de pessoa entrou, e o gate `check`
  do manifest sai verde.

## 6. Etapas

### Etapa 1 — Decision da exceção à anti-evolução
- **Faz:** obtém a data com `date +%F` e cria `.codeflow/decisions/<AAAA-MM-DD>-audit-enxugar.md` no
  formato das decisions existentes (frontmatter `versão`, `status`, `atualizado`, `data`,
  `workflow: implement-change`, `tags: [anti-evolucao, auditoria, enxugar, experimental]`,
  `status_decisão: ativa`, `supersede: null`, `relaciona-com: [2026-10-02-operacao-por-trilhas]`).
  Decisões: (1) a skill nasce universal sem o uso real em dois projetos, por decisão do dono em
  2026-11-05 (lista aprovada do pacote de tokens), contra a anti-regra da `EVOLUTION.md`; (2) nasce
  `experimental`; (3) revisão em três meses (data = a de hoje + 3 meses), e sem uso real em dois projetos
  até lá ela é removida ou rebaixada a skill de projeto; (4) o encaixe como dimensão do `/audit`, com a
  alternativa descartada (workflow próprio sobre o `refactor`). Sem linha no `decisions/INDEX.md`.
- **Arquivos:** `.codeflow/decisions/<AAAA-MM-DD>-audit-enxugar.md`
- **Testes:** `git diff --name-only origin/main...HEAD -- .codeflow/decisions/INDEX.md` vazio;
  `grep -n 'experimental\|revisão\|EVOLUTION' <decision>` acha as três partes do CA-1.
- **Cobre:** CA-1
- **Gate:** bloco `lint` do `.codeflow/manifest.md`

### Etapa 2 — Skill `audit-enxugar` pela meta-skill `create-skill`
- **Faz:** roda a meta-skill `create-skill` lendo-a da worktree (`framework/meta/create-skill/SKILL.md`),
  com a entrevista respondida pelas decisões deste plano, sem perguntar ao dono:
  - Passo 1 (qualificar): skill, não workflow — os passos com decisão aberta já são do `/audit`,
    `/verify-audit` e `/refactor`; a skill é a capacidade "enxugar" que dois workflows carregam.
  - Passo 2 (escopo): universal, pela decision da Etapa 1.
  - Passo 3 (metadata): nome `audit-enxugar`; descrição em uma linha ("Checklist do auditor de enxugar —
    candidatos a remoção por ferramenta determinística, confirmação de cada um e plano de lotes pequenos
    de remoção"); princípio guia: a ferramenta lista, o agente confirma, o lote pequeno remove, e o teste
    decide; protocolo: (1) réguas e fronteira com `code-quality` e `dependencies`; (2) ferramentas e
    comandos (CA-3); (3) linha de base (CA-4); (4) confirmação de cada candidato e cuidados (CA-5);
    (5) plano de lotes e execução do lote, para o `/refactor` (CA-6); (6) severidade — baixa por padrão,
    média quando a duplicação já divergiu ou a complexidade esconde bug provável; destino melhoria.
    Proibições: não instalar nem baixar ferramenta; não rodar `--fix` nem autofix; não alterar código no
    `/audit`; não remover migração, sync ou versão de schema por falta de uso; não misturar categorias ou
    pacotes num lote; não afrouxar teste para o lote passar. Saídas: lista de candidatos com lote e
    destino; linha de base por pacote; entradas propostas para a config de ignorar.
  - Passo 4 (destino): `framework/library/skills/audit-enxugar/SKILL.md` — o caminho relativo da
    worktree, nunca `~/.codeflow/`.
  - Passos 5–6: template literal de `ARTIFACTS_SPEC.md` §1.8.5 e validação §1.8.6; frontmatter
    `versão: 1.0`, `status: experimental`, `atualizado` = data da etapa. Texto descritivo sem nome de
    projeto consumidor (os cuidados citam "app com sync offline" e "pacote consumido por outros", não o
    projeto) e sem palavra-fraca do gate `lint`.
- **Arquivos:** `framework/library/skills/audit-enxugar/SKILL.md`
- **Testes:** as 10 regras da §1.8.6 conferidas uma a uma — `grep -n '^#\{1,2\} '` mostra o título e as
  seis seções na ordem; `! grep -n '^## Definition of Done\|^## LEIA TAMBÉM'`; `grep -n -- '--fix'` só
  na proibição; `grep -n 'no-install\|\[—\]'` acha a regra de não baixar; o checklist do CA-5 e a ordem
  do CA-6 conferidos por leitura.
- **Cobre:** CA-2, CA-3, CA-4, CA-5, CA-6
- **Gate:** bloco `lint` do `.codeflow/manifest.md`

### Etapa 3 — Encaixe na família `/audit` e catálogo
- **Faz:** `audit.md` — `enxugar` na lista de dimensões de "Quando usar"; `templates/audits/README.md`
  — linha `enxugar` | `audit-enxugar (projeto JS/TS; outra stack só com as ferramentas que tiver)`;
  `templates/audits/LAUDO.md` — `enxugar` no campo `dimensao`; `refactor.md` — em "Quando usar", uma
  frase: um lote do laudo `enxugar` roda aqui em modo puro, e o lote aprovado no consolidado é o
  escopo; em "LEIA TAMBÉM", `audit-enxugar/SKILL.md` com "(só quando o pedido é um lote do laudo
  `enxugar`)"; `SPEC.md` §2.2 — linha da skill na árvore de `library/skills/`; `README.md` — a frase da
  auditoria por dimensão cita enxugar o código existente; frontmatter `versão` e `atualizado` de
  `audit.md`, `refactor.md`, `SPEC.md` e `README.md`.
- **Arquivos:** `framework/library/workflows/audit.md`, `framework/library/workflows/refactor.md`,
  `framework/library/templates/audits/README.md`, `framework/library/templates/audits/LAUDO.md`,
  `framework/core/SPEC.md`, `README.md`
- **Testes:** `grep -n 'enxugar'` nos seis arquivos acha uma ocorrência de encaixe em cada;
  `git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md framework/core/EVOLUTION.md`
  vazio; gate `test` (o `run-structural.sh` não muda, e o setup isolado não gera wrapper novo — skill não
  vira slash command).
- **Cobre:** CA-7, CA-8
- **Gate:** `check` do `.codeflow/manifest.md` (lint, test, security)

## 7. Riscos e como desfazer

- **Falso positivo do `knip` em projeto com entrada dinâmica** (worker, rota por arquivo, plugin por
  nome) vira remoção errada. Barreira: confirmação item a item (CA-5), `/verify-audit` em chat zerado,
  lote pequeno com typecheck, testes e build, e o diff só de remoção que se reverte com `git revert`.
- **Código de cliente antigo** (migração, sync, versão de schema) parece sem uso e não é. A skill proíbe
  removê-lo por falta de uso; o caso vai para "deixar" com motivo.
- **Sobreposição com `code-quality` e `dependencies`** gera candidato duplicado na mesma rodada: o
  `/verify-audit` deduplica entre dimensões (Passo 2); a fronteira fica escrita na skill nova.
- **`/simplify` não existe em toda ferramenta de IA**: registrado `[—]`; o `self-review` do `/refactor`
  segue valendo.
- **Exceção à anti-evolução sem uso real**: a decision fixa revisão em três meses e o critério de saída.
- Desfazer: `git revert` dos três commits de etapa; nenhum artefato de projeto é reescrito e nenhum
  wrapper nasce, então o deploy não pede `setup-slash-commands.sh` nem `install.sh` — só o aviso aos
  orquestradores de que o framework mudou.

## 8. Como a revisão vai provar

- Ler o diff contra os CA; conferir a skill pela §1.8.6 do `ARTIFACTS_SPEC.md`, regra por regra.
- Rodar o gate `check` do manifest na raiz da worktree e anexar a saída real.
- Conferir o core intocado:
  `git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md framework/core/EVOLUTION.md`
  vazio; e o INDEX das decisions intocado: `git diff --name-only origin/main...HEAD -- .codeflow/decisions/INDEX.md` vazio.
- Ensaiar a leitura: seguir o `/audit` com dimensão `enxugar` no papel — ele carrega só
  `audit-enxugar`, a skill manda rodar só o que existe, e o destino de cada candidato já traz o lote que
  o `/refactor` vai executar.
