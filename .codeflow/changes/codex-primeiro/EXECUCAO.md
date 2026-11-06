---
mudanca: codex-primeiro
status: rework
tentativa: 2
reprovacoes: 1
etapas_concluidas: [1, 2]
base: origin/main
---

# Codex primeiro, Claude quando a cota acabar — Relatório de execução

## 1. Resumo

Novo `framework/core/scripts/agente-barato.sh`: roda a tarefa no `codex exec` (Sol médio
no perfil base, Sol alto com `--alto`; read-only salvo `--escrita`) e cai no `claude -p --effort medium` quando há
mensagem de cota na linha de erro do Codex, teto diário (padrão 20) ou falta do `codex`; `--contar` serve ao Maestro.
Tabela 4b do `modo-delegado` (1.4) e os moldes de orquestração com a política "Codex primeiro".

## 2. Etapas

| Etapa | Commit | Gate | Resultado |
|-------|--------|------|-----------|
| 1 — Script de fallback com teste | `9ac0a65` | `lint` + `run-testes.sh agente-barato` | verde |
| 2 — Política na tabela e nos moldes | `8aa0541` | `check` (lint, test, security) | verde |
| Rework 2 — script (B-1, B-3, só Sol) | `99d5a31` | `run-testes.sh agente-barato` | verde |
| Rework 2 — tabela, molde e decision (B-2, I-1, só Sol) | `08eb65c` | `check` | verde |

## 3. Arquivos (`git diff --stat <merge-base>..HEAD`, sem o PLANO)

```text
.codeflow/decisions/2026-11-05-codex-primeiro.md   |  72 +++++++++++++
.codeflow/manifest.md                              |   4 +-
README.md                                          |   8 +-
framework/core/SPEC.md                             |   5 +-
framework/core/scripts/agente-barato.sh            | 101 +++++++++++++++++
.../core/scripts/testes/casos/agente-barato.sh     | 120 +++++++++++++++++++++
framework/library/skills/modo-delegado/SKILL.md    |  15 ++-
.../templates/orquestracao/CICLO-DO-RECRUTA.md     |   3 +
.../library/templates/orquestracao/DESPACHO.md     |   2 +-
.../library/templates/orquestracao/MAESTRO.md      |   3 +
10 files changed, 324 insertions(+), 9 deletions(-)
```

## 4. Desvios do plano

- Nenhum desvio. Os moldes de `orquestracao/` não têm frontmatter: nada a versionar neles.
- O `manifest.md` passou a citar o `SPEC.md` 3.8 em `e27a757`, por pedido do orquestrador.
- Ordem do dono no rework: o Codex usa só o Sol (médio ou alto); o Luna e o `--perfil` saem e
  entra `--alto`. Muda o CA-7 e o CA-9 do plano: cobertos pela ordem, não por desvio meu.

## 5. Comandos rodados e saídas reais

```text
$ bash framework/core/scripts/testes/run-testes.sh agente-barato   # rc=0
✓ 48 verificações verdes
$ lint (bloco do manifest)   # rc=0
— MEMORY.md do projeto ausente: pula
✓ .codeflow/INDEX.md: 972 de 3000 caracteres
✓ .codeflow/constitution.md: 7692 de 8000 caracteres
✓ .codeflow/manifest.md: 7237 de 12000 caracteres
✓ ## Comandos de validação: 3206 de 4000 caracteres
✓ contexto fixo dentro dos tetos
$ test (bloco do manifest)   # rc=0 — log: .codeflow/checkpoints/codex-primeiro-test.log
  ✓ mesmo código de saída de origin/main: ciclo-prosa
  ✓ sem argumento sai 3
✓ 169 verificações verdes
$ security (bloco do manifest)   # rc=0
10:19PM INF 9 commits scanned.
10:19PM INF scan completed in 42.9ms
10:19PM INF no leaks found
```

## 6. Critérios de aceite

| CA | Atendido? | Evidência |
|----|-----------|-----------|
| CA-1 | sim | caso "codex ok sai 0", contador vale 1, claude não chamado |
| CA-2 | sim | casos "usage_limit_reached cai no claude", "rate limit (maiúscula)", "rc é o do claude"; args `-p --effort medium`; stdin não é terminal |
| CA-3 | sim | caso "sem codex vai ao claude" (PATH só com `ab-bin-sem-codex` e `/usr/bin:/bin`) |
| CA-4 | sim | casos "no teto vai ao claude", "abaixo do teto padrão tenta o codex", "teto padrão é 20" |
| CA-5 | sim | casos `--contar` (soma, sai 0; no teto sai 1 e não soma; não roda agente) |
| CA-6 | sim | "falha sem cota sai 1", "prompt que cita rate limit e quota, erro comum, sai 1", "quota na saída da tarefa (stdout) não cai no claude"; "sem codex e sem claude sai 2"; uso inválido sai 3 |
| CA-7 | sim (Sol só) | casos "sol médio: sem -p", "alto: -p revisor", "escrita: workspace-write", "--perfil não existe mais" |
| CA-8 | sim | contador em `$XDG_CACHE_HOME/codeflow/codex-AAAA-MM-DD`; lint (stack de script) verde |
| CA-9 | sim | `framework/library/skills/modo-delegado/SKILL.md:80-90` |
| CA-10 | sim | `CICLO-DO-RECRUTA.md:23` (regra 7), `MAESTRO.md:25` (regra 8), `DESPACHO.md:6` |
| CA-11 | sim | `SPEC.md:195` (§2.2) e `:1537` (§7.3), versão 3.8; `README.md:99`, 1.6; `glossary.md` sem diff |

## 7. No rework: o que mudou nesta tentativa

- B-1 (cota pelo eco do prompt) → busca só na linha de erro do stderr, sem as linhas da tarefa; 3 casos novos → `99d5a31`.
- B-3 (seta Unicode) → saída `codex: sol medio (...)` e `claude: <motivo>` → `99d5a31`.
- B-2 (decision sem Por quê/Alternativa) → decisões 2 a 4 completas, decisão 5 nova → `08eb65c`.
- I-1 ("Nunca Codex: spec") → "redação de spec" → `08eb65c`.
- Ordem do dono (só Sol) → script, testes, tabela 4b, `DESPACHO.md`, decision → `99d5a31`, `08eb65c`.
- Sugestão do README (vírgula) → `99d5a31`. Não feitas: `--` antes da tarefa e trava do contador (opcionais).

## 8. Dúvidas para o revisor

- A busca de cota só roda quando o `codex` sai diferente de 0, e só em linha do stderr que começa
  por `ERROR`/`error` (com ou sem `[data] ` antes). Se o Codex mudar o formato do erro, o fallback
  não dispara e a tarefa sai 1 (visível).
- O contador soma antes de rodar o Codex: um despacho que cai no Claude por cota também conta.
