---
mudanca: audit-enxugar
tentativa: 1
veredito: APROVADO
range_revisado: 2cee6df..9cb6551
---

<!-- Preenchido pelo REVISOR (/review-change), em chat zerado. O revisor não
     altera código: só julga e registra.

     veredito, por precedência AJUSTAR > PENDENTE-EXTERNO > APROVADO: AJUSTAR
     quando há ≥1 BLOQUEANTE (contada a escalada: IMPORTANTE da revisão
     anterior com destino "corrigir agora" que segue aberto — o mesmo
     IMPORTANTE pela 2ª vez —, ou 3+ IMPORTANTES abertos, vira BLOQUEANTE;
     o de destino "registrar como melhoria" fica aberto por decisão e não escala);
     PENDENTE-EXTERNO quando uma verificação depende de algo fora da mudança
     (cota, push/CI remoto, ação física do dono); senão APROVADO.
     Erro só de registro não entra no veredito.
     IMPORTANTE não segura o veredito — cada um sai com destino (corrigir agora,
     se for barato, ou registrar como melhoria). SUGESTÃO se descarta por padrão. -->

# Dimensão `enxugar` da auditoria — Revisão

## 1. Veredito

**APROVADO** — zero BLOQUEANTE: os oito CA conferidos no código, os oito arquivos do diff batem com o
mapa do plano, e o gate `check` sai verde na raiz da worktree. Um IMPORTANTE (defasagem descritiva do
`.codeflow/manifest.md`) sai como Herdado, com destino "registrar como melhoria".

## 2. Critérios de aceite, conferidos no código

| CA | Atendido? | Evidência própria (teste rodado, arquivo:linha) |
|----|-----------|--------------------------------------------------|
| CA-1 | sim | `.codeflow/decisions/2026-11-05-audit-enxugar.md:24-27` (anti-regra da `EVOLUTION.md`, "Promoção" e "Anti-evolução", conferidas em `EVOLUTION.md:11-15` e `:74-83`), `:31-38` (decisão do dono de 2026-11-05), `:40-43` (`experimental`), `:45-52` (revisão 2027-02-05 = hoje + 3 meses; critério de saída: remover ou rebaixar); `decisions/INDEX.md` fora do diff (comando na §8) |
| CA-2 | sim | `framework/library/skills/audit-enxugar/SKILL.md` — §1.8.6 regra a regra: (1) `descrição` numa linha, `:5`; (2) pasta kebab, `SKILL.md`; (3) `# Skill: audit-enxugar`, `:8`, bate com a pasta; (4) seis seções na ordem, `:10,20,25,96,105`; (5) sem DoD; (6) sem LEIA TAMBÉM; (7) princípio com duas frases, `:22-23`; (8) seis bullets "Não ...", `:98-103`; (9) saídas por tipo, `:107-110`; (10) sem auxiliar na pasta. `versão: 1.0`, `status: experimental`, `:2-3` |
| CA-3 | sim | `SKILL.md:36-38` (`npx --no-install`, `pnpm exec`, `yarn`; ausente → `[—]` com o comando), `:39` (saída em `mktemp -d` fora do repo), `:40-45` (knip: `--reporter json`, `--workspace`, `--production`, `--dependencies`/`--files`/`--exports`), `:46-47` (jscpd: `--min-lines`, `--reporters json`, `--output "$T/..."`), `:48-52` (eslint: `complexity`, `max-depth`, `max-lines-per-function`, `--format json`; sonarjs só com o plugin), `:98-99` (proíbe instalar e autofix) |
| CA-4 | sim | `SKILL.md:55-57` — por pacote: LOC, knip por tipo, % do jscpd, top 20 complexas com `arquivo:linha`, na seção 3 do laudo; `:58-59` comparação na rodada seguinte e critério de encerramento |
| CA-5 | sim | `SKILL.md:63-70` — uso dinâmico (string, config, reflexão, import dinâmico, rota por convenção), dependência fora do código (scripts, CI, build, teste, deploy), export público, entrada por convenção, cliente antigo que **nunca** sai; `:71-72` quatro classes; `:73-75` "deixar" com motivo vira `knip.json`/`.jscpd.json` no lote 0 (`:81`) |
| CA-6 | sim | `SKILL.md:78-79` (categoria × pacote, ~300 linhas ou ~20–30 itens), `:80-81` (ordem dependências → órfãos → exports → duplicação → complexidade), `:82-83` (`/refactor` puro, PR por lote), `:84-85` (rede do manifest, parar no primeiro vermelho), `:86` (caracterização), `:103` (não "consertar" teste), `:87-89` (`/simplify` só nos lotes de duplicação e complexidade, `[—]` sem a ferramenta; remoção pura não roda) |
| CA-7 | sim | `audit.md:14` lista `enxugar`, e `audit.md:24` carrega `audit-<dimensão>` (resolve para `audit-enxugar` sem outra mudança); `templates/audits/README.md:26`; `LAUDO.md:3`; `refactor.md:17` (lote em modo puro, consolidado como escopo) e `refactor.md:32` (LEIA TAMBÉM condicional) |
| CA-8 | sim | `SPEC.md:200` (linha da skill) e frontmatter 3.5/2026-11-05; §3.5 conferido (decisão de organização plana, nada a pagar); `README.md:21-22` e 1.4/2026-11-05; `audit.md` 1.1, `refactor.md` 1.2; `LAUDO.md` e `templates/audits/README.md` sem frontmatter de versão; core intocado; nomes proibidos zero; `check` verde (§8) |

## 3. Conformidade com o plano

- As três etapas foram entregues como planejado, uma por commit (`e6845d9`, `c4f39ae`, `9cb6551`), e o
  diff fora de `.codeflow/changes/` toca exatamente os oito caminhos NOVO/ALTERADO do mapa (§4 do plano).
- Nada fora do escopo: nenhuma ferramenta instalada, protocolo de `audit`/`verify-audit`/`refactor` mudado só
  na linha de encaixe, `audit-code-quality` e `audit-dependencies` intocados, moldes sem campo novo (só o
  valor `enxugar` na lista de `dimensao`), nenhum termo novo no glossary, nenhum wrapper novo (o setup
  isolado gera os mesmos wrappers de workflow; skill não vira slash command).
- Desvios declarados no relatório (citar "Promoção" além de "Anti-evolução"; `yarn` como executor; proibir
  `--fix-type` e `--allow-remove-files`) são de redação, coerentes com o plano e conferidos no texto.
- Ensaio no papel (§8 do plano): `/audit` com dimensão `enxugar` carrega só `audit-enxugar` por
  `audit.md:24`; a skill roda só o que existe (`:36-38`); o destino de cada candidato já traz o lote
  (`:78`) que o `/refactor` executa (`refactor.md:17,32`).

## 4. Achados BLOQUEANTES

- nenhum

## 5. Achados IMPORTANTES

- **I-1** — `.codeflow/manifest.md:19` e `:76` — a descrição do repositório ficou defasada: a linha 19 cita
  `SPEC.md` 3.4 (o ramo leva a 3.5) e a linha 76 conta "16 skills" (agora são 17, com `audit-enxugar`).
  Classificação da nota do implementador: é texto descritivo do manifest, não contrato nem gate — os blocos
  `lint`/`test`/`security` e o `validation_hash` (que não cobre `SPEC.md` nem a contagem) seguem corretos —
  e o manifest está fora do mapa do plano. Régua: freshness do manifest. Destino: **registrar como
  melhoria** (próximo `/discover` ou a trilha de auditoria; atualizar as duas linhas juntas). Não escala.

## 6. Sugestões

- `SKILL.md:87-89` — `/simplify` é comando de uma ferramenta de IA específica; a Parte 3, regra 37, do
  `ARTIFACTS_SPEC.md` pede conteúdo agnóstico. O texto já condiciona ("quando a ferramenta de IA o oferece;
  senão `[—]`") e o CA-6 o exige; numa revisão da skill, descrever a capacidade ("simplificação automática
  do diff") com `/simplify` como exemplo.

## 7. Erros de registro

- `PLANO.md` §4 descreve o `SPEC.md` §3.5 como "lista só workflows universais"; o §3.5 é a decisão de
  organização "universais planas + projetos isolados". A conclusão ("nada a pagar") se mantém; só a
  descrição está imprecisa.
- `.codeflow/decisions/2026-11-05-audit-enxugar.md` sem linha no `decisions/INDEX.md` (Parte 3, regra 30):
  esperado por regra do despacho — a linha é do Maestro. Não é erro do implementador; fica como pendência.

## 8. Comandos rodados e saídas reais

```text
$ git rev-parse --short origin/main
6dae155
$ git merge-base --is-ancestor 9cb6551 HEAD && echo ancestral-ok
ancestral-ok
$ git diff --stat 6dae155..HEAD -- . ':!.codeflow/changes/'
 .codeflow/decisions/2026-11-05-audit-enxugar.md |  66 ++++++++++++++
 README.md                                       |   7 +-
 framework/core/SPEC.md                          |   5 +-
 framework/library/skills/audit-enxugar/SKILL.md | 110 ++++++++++++++++++++++++
 framework/library/templates/audits/LAUDO.md     |   2 +-
 framework/library/templates/audits/README.md    |   1 +
 framework/library/workflows/audit.md            |   6 +-
 framework/library/workflows/refactor.md         |   7 +-
 8 files changed, 192 insertions(+), 12 deletions(-)

# gate check do .codeflow/manifest.md (blocos extraídos do manifest e rodados na ordem, na raiz da worktree)
lint=0
  atualizados: 0
  preservados: 0
  pulados:     0
✓ Sincronização concluída. Reinicie o Codex ou abra um chat novo para recarregar as skills.
(divergências origin/main x ramo no run-structural: 0)
test=0
INF 7 commits scanned.
INF scan completed in 123ms
INF no leaks found
security=0        (inclui a varredura de nomes proibidos nas linhas acrescentadas: nenhum)

$ git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md \
    framework/core/EVOLUTION.md .codeflow/decisions/INDEX.md | wc -l
0

$ grep -n '^#\{1,2\} ' framework/library/skills/audit-enxugar/SKILL.md
8:# Skill: audit-enxugar
10:## Quando usar
20:## Princípio guia
25:## Protocolo
96:## Proibições durante esta skill
105:## Saídas válidas
$ ls framework/library/skills/audit-enxugar/
SKILL.md
$ ls framework/library/skills | wc -l
17

# Parte 3 do ARTIFACTS_SPEC.md, arquivo por arquivo (encoding/BOM, CR, newline final, absoluto, TODO, HTML, palavra-fraca)
.codeflow/decisions/2026-11-05-audit-enxugar.md: UTF-8 bom=não cr=0 eof=uma \n abs=0 todo=0 html=0 fraca=0
README.md:                                      UTF-8 bom=não cr=0 eof=uma \n abs=0 todo=0 html=0 fraca=0
framework/core/SPEC.md:                         UTF-8 bom=não cr=0 eof=uma \n abs=1 todo=0 html=0 fraca=2
framework/library/skills/audit-enxugar/SKILL.md: UTF-8 bom=não cr=0 eof=uma \n abs=0 todo=0 html=0 fraca=0
framework/library/templates/audits/LAUDO.md:    UTF-8 bom=não cr=0 eof=uma \n abs=0 todo=0 html=1 fraca=0
framework/library/templates/audits/README.md:   UTF-8 bom=não cr=0 eof=uma \n abs=0 todo=0 html=0 fraca=0
framework/library/workflows/audit.md:           UTF-8 bom=não cr=0 eof=uma \n abs=0 todo=0 html=0 fraca=0
framework/library/workflows/refactor.md:        UTF-8 bom=não cr=0 eof=uma \n abs=0 todo=0 html=0 fraca=0
(os achados de SPEC.md e LAUDO.md são anteriores ao ramo: nas linhas acrescentadas pelo diff, o único
 casamento do grep foi "todos" contra TODO, falso positivo; SPEC.md em origin/main já tinha fraca=2)

# §2.5.6 na decision: seis campos específicos presentes; nome = data do frontmatter (2026-11-05);
# status_decisão: ativa; supersede: null; relaciona-com aponta para 2026-10-02-operacao-por-trilhas.md (existe);
# tags kebab-case; "# Decisões: ..."; quatro seções na ordem; quatro "### N." com Por quê e Alternativa rejeitada.
# workflow: implement-change tem gera_decision: auto, e divergência consciente do core é gatilho declarado.

$ git status --short
(vazio)
```

## 9. Divergências entre o relatório e o código

- nenhuma — o que o `EXECUCAO.md` afirma (arquivos, versões, linhas citadas, saídas dos gates) bate com o
  código e com as saídas que o revisor obteve.
