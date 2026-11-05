---
mudanca: contexto-e-papeis
status: executado
tentativa: 1
reprovacoes: 0
etapas_concluidas: [1, 2, 3, 4]
sha_inicial: f97932e
sha_final: 784a85d
range: f97932e..784a85d
---

<!-- Preenchido pelo IMPLEMENTADOR (/implement-change). É declaração, não prova:
     o REVISOR não confia nele e confere contra o código real. -->

# Contexto enxuto e modelo por papel — Relatório de execução

## 1. Resumo

Os workflows deixam de ler o INDEX (fica no `create-spec` e no `audit`) e leem do manifest só a seção, por uma
expressão `awk`. O wrapper manda carregar o `## LEIA TAMBÉM` "como cada item manda". O executor e o avaliador de
fase leem o pacote do `pacote-da-fase.sh`. O `modo-delegado` ganha leitura por trecho, escrita por edição e a
tabela papel → modelo. Nascem os moldes de orquestração, o `vigia.sh` e os moldes `CLAUDE.md`/`AGENTS.md`
oferecidos pelo bootstrap. `SPEC.md` §3.7, §2.5 e §10.9 são emendados, com decision. Implementação, fase e bugfix
ganham a seção YAGNI.

## 2. Etapas

| Etapa | Commit | Gate | Resultado |
|-------|--------|------|-----------|
| 1 — Contexto enxuto, wrapper e regras transversais | `2196fe9` | `lint` + `test` + ensaio do `install.sh` | verde |
| 2 — Pacote da fase | `ff1a826` | `lint` + laço sobre as specs reais | verde |
| 3 — Modelo por papel e molde de orquestração | `b599d04` | `lint` + teste do `vigia.sh` | verde |
| 4 — CLAUDE.md enxuto e catálogo | `784a85d` | `check` (lint, test, security) | verde |

## 3. Arquivos criados e alterados

| Arquivo | Criado / alterado | Propósito |
|---------|-------------------|-----------|
| `framework/library/workflows/*.md` (15; `ideacao` intocado) | alterado | INDEX fora (salvo `create-spec`, `audit`); manifest por seção; `spec-status` sem o trio |
| `framework/library/workflows/{implement-change,execute-spec-phase,bugfix}.md` | alterado | seção "Menor mudança que resolve (YAGNI)" |
| `framework/library/workflows/execute-spec-phase.md`, `evaluate-spec-phase.md` | alterado | pacote da fase (Passos 1 e 3, DoD); avaliador sem stash e com direito à spec inteira |
| `framework/core/ARTIFACTS_SPEC.md` | alterado | §1.5.3, §1.5.6, §1.6.6, §1.9: três entradas; §1.11.3 e §1.11.5: literal do wrapper; §2.3.3: hash |
| `framework/meta/create-workflow/SKILL.md` | alterado | validação das três entradas |
| `setup-slash-commands.sh`, `setup-codex-skills.sh`, `setup-codex-prompts.sh`, `install.sh` | alterado | texto novo do wrapper |
| `framework/core/scripts/pacote-da-fase.sh` | criado | recorte da spec por fase |
| `framework/core/scripts/vigia.sh` | criado | vigília só leitura |
| `framework/library/skills/modo-delegado/SKILL.md` | alterado | §1 `Modelo:`, 4a e 4b |
| `framework/library/templates/orquestracao/{DESPACHO,CICLO-DO-RECRUTA,MAESTRO}.md` | criado | moldes de orquestração |
| `framework/library/templates/projeto/{CLAUDE,AGENTS}.md` | criado | moldes curtos do bootstrap |
| `framework/meta/bootstrap/SKILL.md`, `framework/meta/discover/SKILL.md` | alterado | oferta com "sim"; medição e relato |
| `framework/core/SPEC.md` | alterado | §2.2, §2.5, §3.7, §10.9, frontmatter |
| `README.md` | alterado | scripts e moldes novos; frontmatter |
| `.codeflow/decisions/2026-11-05-contexto-e-papeis.md` | criado | aprovação do dono, emendas e promoção; sem linha no INDEX |

## 4. Desvios do plano

- **Exceção do `spec-status` na regra das três entradas.** O plano tira o trio inteiro do `spec-status` e, ao
  mesmo tempo, faz a regra exigir três entradas. Para não deixar o `spec-status` inválido, o §1.5.3 diz que
  workflow que só lê frontmatter de artefatos dispensa a constitution de projeto e o manifest (decisão pedida ao
  orquestrador).
- **Duas linhas do corpo dos workflows**, além do `## LEIA TAMBÉM`: `execute-spec-phase` Passo 1 ("os comandos do
  manifest") e `create-spec` Protocolo 1 ("as seções de stack e padrões"), que mandavam ler o manifest.
- **§1.11.3 do ARTIFACTS_SPEC** ganhou a mesma frase do literal: o plano citava §1.11 sem a subseção.
- **`SPEC.md` §2.2:** o rótulo de `scripts/` passou de "validadores" para "scripts" read-only, porque os novos
  não validam.
- **`pacote-da-fase.sh`:** além dos prefixos do plano, expande `AC-B1/B2` em `AC-B1` e `AC-B2` (forma usada nas
  specs reais); a fase inexistente sai 1 sem nada no stdout.
- **YAGNI:** o primeiro degrau foi ajustado por workflow: "o plano exige isto?" no `implement-change`, "a correção
  do bug exige isto?" no `bugfix` e "a spec manda; não corte requisito" no `execute-spec-phase`. A linha do grep
  dos chamadores ficou só no `bugfix`.
- **`templates/orquestracao/` e `templates/projeto/` sem `README.md`**, que o plano não pedia.
- Ficou de fora, deliberadamente (YAGNI): o pacote não puxa os FR citados dentro de um AC (só os citados na fase).

## 5. Comandos rodados e saídas reais

```text
# Etapa 1 — vermelho antes, verde depois
$ grep -l '\.codeflow/INDEX.md' framework/library/workflows/*.md
framework/library/workflows/audit.md
framework/library/workflows/create-spec.md
$ grep -rn 'Carregue todos os arquivos' setup-*.sh install.sh framework/core/ARTIFACTS_SPEC.md   # vazio
$ grep -n stash framework/library/workflows/evaluate-spec-phase.md                               # vazio
$ awk '/^## /{p=($0 ~ /^## (Comandos de validação|Gate|CI)/)} p' .codeflow/manifest.md | grep '^## '
## Comandos de validação
$ (variante com stack) | grep '^## '
## Stack identificada
## Comandos de validação
## Padrões detectados
$ printf '# x\n## Gate\na\n## CI\nb\n## Outro\nc\n' | awk '<expressão>'
## Gate
a
## CI
b
# wrappers em HOME temporário
slash: 16 com texto novo, 0 antigos
codex-skills: 16 novos
prompts rc=0 16 novos
# install.sh num projeto descartável em $T, HOME="$T"
install rc=0
novo:  Leia $T/proj/.codeflow/workflows/novo.md e execute o protocolo descrito ali, aplicando ao projeto atual. Carregue os arquivos de ## LEIA TAMBÉM como cada item manda (só a seção indicada; os condicionais só quando a condição vale) antes de começar.
velho: Leia velho e execute. Carregue todos os arquivos listados em ## LEIA TAMBÉM antes de começar.   (preservado)

# Etapa 2 — laço sobre as specs reais (saída em /dev/null) e casos de saída
fases testadas: 493
✓ teste do pacote verde
mawk difs=0            # mesma saída em gawk 5.2 e mawk 1.3.4, uma fase por spec
stdout no rc1: 0

# Etapa 3 — vigia.sh em repositório descartável (saídas 0, 1, 2, 3; git status e HEAD iguais)
✓ teste do vigia verde
$ wc -c DESPACHO.md
1280
$ grep -c Sonnet framework/library/skills/modo-delegado/SKILL.md
0

# Etapa 4
AGENTS: 1440 chars, 37 linhas; @AGENTS em CLAUDE: 1
sem data de hoje:      # vazio
core:                  # vazio (constitution, glossary, EVOLUTION, templates/specs/, manifest)
# check sobre o ramo commitado
lint ✓
test ✓
INF 6 commits scanned. / INF no leaks found
security ✓
check=0
```

## 6. Critérios de aceite

| CA | Atendido? | Evidência (teste, comando, arquivo:linha) |
|----|-----------|--------------------------------------------|
| CA-1 | sim | grep do INDEX só em `create-spec` e `audit`; 14 workflows com a expressão `awk`; `spec-status` sem o trio; `ideacao` sem diff |
| CA-2 | sim | saídas do `awk` acima (só `## Comandos de validação`; `Gate`/`CI` saem juntos; variante com stack e padrões) |
| CA-3 | sim | `ARTIFACTS_SPEC.md:820`, `:879`, `:1032`, `:1506`, `:2002`; `create-workflow/SKILL.md:87` |
| CA-4 | sim | grep vazio de "Carregue todos"; wrappers gerados em HOME temporário; ensaio do `install.sh` |
| CA-5 | sim | 493 fases das 66 specs com saída 0, frontmatter, TL;DR (quando a spec tem), heading e rodapé; saídas 1, 2 e 3 |
| CA-6 | sim | a fase `B.1` de uma spec real traz AC-B1, AC-B2 e AC-B3; spec sintética com `FR-9` ausente dá `⚠ FR-9` com saída 0 |
| CA-7 | sim | `execute-spec-phase.md` Passos 1 e 3 e DoD; `evaluate-spec-phase.md` Passo 1 e DoD; `grep stash` vazio |
| CA-8 | sim | `implement-change.md:40`, `bugfix.md:37`, `execute-spec-phase.md:41` |
| CA-9 | sim | `modo-delegado/SKILL.md:37` (`Modelo:`), `:60` (4a), `:69` (4b, tabela, escalada, Codex); `grep -c Sonnet` = 0 |
| CA-10 | sim | três moldes em `templates/orquestracao/`; teste do `vigia.sh` (1 parado, 0 avanço, repo igual) |
| CA-11 | sim | `SPEC.md:513` (§3.7), §2.5, `:1818` (§10.9); §8.3 sem diff; decision sem linha no `decisions/INDEX.md` |
| CA-12 | sim | `AGENTS.md` 1440 chars, 37 linhas; `CLAUDE.md` = `@AGENTS.md`; bootstrap Fase 3 e Proibições; discover Fases 1 e 4b |
| CA-13 | sim | `SPEC.md` §2.2, `README.md:90-97`; todo arquivo do diff com frontmatter em `atualizado: 2026-11-05`; `check` verde; core intocado |

## 7. No rework: o que mudou nesta tentativa

- Não se aplica (primeira execução).

## 8. Dúvidas para o revisor

- A exceção do `spec-status` no §1.5.3 (desvio 1) é leitura minha da intenção do plano.
- O teste do `pacote-da-fase.sh` roda sobre as specs de `~/Projetos/*`, fora do repositório: o revisor precisa da
  mesma máquina para repetir o laço. O script de teste está no relatório do recruta, não versionado.
- O `vigia.sh` usa `stat -c %Y` (GNU coreutils), como o plano pede; não roda no `stat` do BSD.
- A medição com e sem pacote (2 fases) e o A/B do avaliador em medium são pós-passos do orquestrador.
