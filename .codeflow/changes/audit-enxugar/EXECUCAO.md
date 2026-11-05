---
mudanca: audit-enxugar
status: executado
tentativa: 1
reprovacoes: 0
etapas_concluidas: [1, 2, 3]
sha_inicial: 2cee6df
sha_final: 9cb6551
range: 2cee6df..9cb6551
---

<!-- Preenchido pelo IMPLEMENTADOR (/implement-change), em modo delegado. É
     declaração, não prova: o REVISOR confere contra o código real. -->

# Dimensão `enxugar` da auditoria — Relatório de execução

## 1. Resumo

Nasce a skill universal `audit-enxugar` (experimental), a dimensão `enxugar` do `/audit`: knip, jscpd e
eslint só como relatório e sem baixar nada, linha de base por pacote, confirmação de cada candidato e plano
de lotes executados pelo `/refactor` em modo puro. A exceção à anti-evolução está registrada em decision
(sem linha no INDEX), e o encaixe e o catálogo foram pagos em seis arquivos.

## 2. Etapas

| Etapa | Commit | Gate | Resultado |
|-------|--------|------|-----------|
| 1 — Decision da exceção à anti-evolução | `e6845d9` | `lint` do manifest | verde |
| 2 — Skill `audit-enxugar` pela `create-skill` | `c4f39ae` | `lint` do manifest | verde |
| 3 — Encaixe na família `/audit` e catálogo | `9cb6551` | `check` do manifest (lint, test, security) | verde |

## 3. Arquivos criados e alterados

| Arquivo | Criado / alterado | Propósito |
|---------|-------------------|-----------|
| `.codeflow/decisions/2026-11-05-audit-enxugar.md` | criado | exceção à anti-evolução; experimental; revisão 2027-02-05 com critério de saída; encaixe como dimensão |
| `framework/library/skills/audit-enxugar/SKILL.md` | criado | a dimensão: réguas e fronteira, ferramentas, linha de base, confirmação, lotes, severidade |
| `framework/library/workflows/audit.md` | alterado (1.0 → 1.1) | `enxugar` na lista de dimensões |
| `framework/library/workflows/refactor.md` | alterado (1.1 → 1.2) | lote do laudo `enxugar` em modo puro; LEIA TAMBÉM condicional |
| `framework/library/templates/audits/README.md` | alterado | linha `enxugar` → `audit-enxugar` |
| `framework/library/templates/audits/LAUDO.md` | alterado | `enxugar` em `dimensao` |
| `framework/core/SPEC.md` | alterado (3.4 → 3.5) | §2.2: linha da skill na árvore de `library/skills/` |
| `README.md` | alterado (1.3 → 1.4) | a auditoria por dimensão cita enxugar o código existente |

## 4. Desvios do plano

- Nenhum desvio de escopo. Detalhes de redação: a decision cita as duas seções da `EVOLUTION.md` que
  pedem uso em dois projetos ("Promoção" e "Anti-evolução"), porque a "Anti-evolução" fala em workflow
  universal e a "Promoção" é a que cobre skill. A skill acrescenta `yarn <ferramenta>` aos executores
  locais e proíbe também `--fix-type` e `--allow-remove-files`, flags de autofix do knip.
- A entrevista da `create-skill` foi respondida pela §6 do plano (decisão delegada 1); o Passo 4 salvou
  no caminho relativo da worktree, nunca em `~/.codeflow/`.

## 5. Comandos rodados e saídas reais

```text
# Etapa 1
$ git diff --name-only origin/main...HEAD -- .codeflow/decisions/INDEX.md
(vazio)
$ grep -c 'experimental\|revisão\|EVOLUTION' .codeflow/decisions/2026-11-05-audit-enxugar.md
12
$ lint   → saída 0

# Etapa 2 (§1.8.6)
$ grep -n '^#\{1,2\} ' framework/library/skills/audit-enxugar/SKILL.md
8:# Skill: audit-enxugar
10:## Quando usar
20:## Princípio guia
25:## Protocolo
96:## Proibições durante esta skill
105:## Saídas válidas
$ ! grep -n '^## Definition of Done\|^## LEIA TAMBÉM' ...   → ok (nenhuma)
$ grep -n -- '--fix' ...
99:- Não rodar `--fix`, `--fix-type`, `--allow-remove-files` nem qualquer autofix.
$ grep -n 'no-install\|\[—\]' ...   → linhas 18, 37, 38, 88, 98, 109
$ ls framework/library/skills/audit-enxugar/   → SKILL.md
$ lint   → saída 0

# Etapa 3
$ grep -c enxugar <arquivo>
audit.md: 1 | refactor.md: 2 | templates/audits/README.md: 1 | LAUDO.md: 1 | SPEC.md: 1 | README.md: 1
$ git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md framework/core/EVOLUTION.md .codeflow/decisions/INDEX.md
(vazio)
$ check (blocos do manifest, sobre o ramo commitado)
lint=0
test=0      (setup isolado: "✓ Sincronização concluída"; 21 wrappers criados, nenhum de skill)
security=0  (gitleaks: "6 commits scanned ... no leaks found"; nomes proibidos: nenhum)
```

## 6. Critérios de aceite

| CA | Atendido? | Evidência (teste, comando, arquivo:linha) |
|----|-----------|--------------------------------------------|
| CA-1 | sim | decision com frontmatter do repositório; decisões 1 (anti-regra e decisão do dono), 2 (experimental), 3 (revisão 2027-02-05 e critério de saída), 4 (encaixe); INDEX intocado |
| CA-2 | sim | as 10 regras da §1.8.6: descrição numa linha (`SKILL.md:5`), pasta kebab e `SKILL.md`, título bate, seis seções na ordem, sem DoD nem LEIA TAMBÉM, princípio com duas frases, proibições negativas, saídas por tipo, sem auxiliar |
| CA-3 | sim | `SKILL.md:34-50` — knip (`--reporter json`, `--workspace`, `--production`, `--dependencies/--files/--exports`), jscpd (`--min-lines`, `--reporters json`, `--output` fora do repo), eslint (três regras; sonarjs só com plugin); `--no-install`/`pnpm exec`; `[—]` com comando; `SKILL.md:98-99` proíbe instalar e autofix |
| CA-4 | sim | `SKILL.md:54-59` — LOC, contagem do knip por tipo, % do jscpd, top 20 por complexidade, na seção 3 do laudo |
| CA-5 | sim | `SKILL.md:61-75` — uso dinâmico, dependência fora do código, export público, entrada por convenção, cliente antigo (nunca sai); quatro classes; "deixar" vira `knip.json`/`.jscpd.json` no lote 0 |
| CA-6 | sim | `SKILL.md:77-89` — lote por categoria × pacote, ~300 linhas ou ~20–30 itens, ordem dependências → órfãos → exports → duplicação → complexidade; `/refactor` puro, rede do manifest, parar no vermelho, caracterização, PR por lote, `/simplify` só nos lotes de duplicação e complexidade |
| CA-7 | sim | `audit.md` lista `enxugar`; `templates/audits/README.md` com a linha; `LAUDO.md:3`; `refactor.md` "Quando usar" e LEIA TAMBÉM condicional |
| CA-8 | sim | SPEC §2.2 com a skill (3.5); §3.5 conferido (só workflows, nenhum nasce); README 1.4; frontmatters atualizados; core intocado; `check` verde |

## 7. No rework: o que mudou nesta tentativa

- (não se aplica — primeira execução)

## 8. Dúvidas para o revisor

- `.codeflow/manifest.md:19` ainda cita `SPEC.md` 3.4. O manifest não está no mapa do plano e tem
  `validation_hash`; ficou como está — atualizar é do próximo `/discover` ou da trilha de auditoria.
- A árvore do `SPEC.md` §2.2 já estava defasada (só `debug-protocol` e `self-review`); a linha nova entra
  em ordem alfabética, sem pagar a defasagem anterior (fora de escopo, §2 do plano).
- Verificação independente (`/review-change` em chat zerado) não roda aqui: é do orquestrador despachar.
