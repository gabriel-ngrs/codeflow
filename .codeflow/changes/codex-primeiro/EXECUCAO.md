---
mudanca: codex-primeiro
status: executado
tentativa: 1
reprovacoes: 0
etapas_concluidas: [1, 2]
base: origin/main
---

# Codex primeiro, Claude quando a cota acabar — Relatório de execução

## 1. Resumo

Novo `framework/core/scripts/agente-barato.sh`: roda a tarefa no `codex exec` (perfis sol,
luna, revisor; read-only salvo `--escrita`) e cai no `claude -p --effort medium` quando há
mensagem de cota, teto diário (padrão 20) ou falta do `codex`; `--contar` serve ao Maestro.
Tabela 4b do `modo-delegado` (1.4) e os moldes de orquestração com a política "Codex primeiro".

## 2. Etapas

| Etapa | Commit | Gate | Resultado |
|-------|--------|------|-----------|
| 1 — Script de fallback com teste | `9ac0a65` | `lint` + `run-testes.sh agente-barato` | verde |
| 2 — Política na tabela e nos moldes | `8aa0541` | `check` (lint, test, security) | verde |

## 3. Arquivos (`git diff --stat <merge-base>..HEAD`, sem o PLANO)

```text
README.md                                          |   6 +-
framework/core/SPEC.md                             |   5 +-
framework/core/scripts/agente-barato.sh            |  97 ++++++++++++++++++
.../core/scripts/testes/casos/agente-barato.sh     | 108 +++++++++++++++++++++
framework/library/skills/modo-delegado/SKILL.md    |  13 ++-
.../templates/orquestracao/CICLO-DO-RECRUTA.md     |   3 +
.../library/templates/orquestracao/DESPACHO.md     |   2 +-
.../library/templates/orquestracao/MAESTRO.md      |   3 +
8 files changed, 231 insertions(+), 6 deletions(-)
```

## 4. Desvios do plano

- Nenhum desvio. Os moldes de `orquestracao/` não têm frontmatter: nada a versionar neles.
- Fora, deliberadamente: o `manifest.md` ainda cita `SPEC.md 3.7` na stack (é do projeto, não
  do plano); risco nulo, só texto desatualizado.

## 5. Comandos rodados e saídas reais

```text
$ bash framework/core/scripts/testes/run-testes.sh agente-barato   # rc=0
✓ 40 verificações verdes
$ lint (bloco do manifest)   # rc=0
— MEMORY.md do projeto ausente: pula
✓ .codeflow/INDEX.md: 972 de 3000 caracteres
✓ .codeflow/constitution.md: 7692 de 8000 caracteres
✓ .codeflow/manifest.md: 7237 de 12000 caracteres
✓ ## Comandos de validação: 3206 de 4000 caracteres
✓ contexto fixo dentro dos tetos
$ test (bloco do manifest)   # rc=0 — log: .codeflow/checkpoints/codex-primeiro-test.log
  ✓ mesmo código de saída de origin/main: ciclo
  ✓ mesmo código de saída de origin/main: ciclo-prosa
  ✓ sem argumento sai 3
✓ 161 verificações verdes
$ security (bloco do manifest)   # rc=0
10:09PM INF 4 commits scanned.
10:09PM INF scan completed in 52.2ms
10:09PM INF no leaks found
```

## 6. Critérios de aceite

| CA | Atendido? | Evidência |
|----|-----------|-----------|
| CA-1 | sim | caso "codex ok sai 0", contador vale 1, claude não chamado |
| CA-2 | sim | casos "usage_limit_reached cai no claude", "rate limit (maiúscula)", "rc é o do claude"; args `-p --effort medium`; stdin não é terminal |
| CA-3 | sim | caso "sem codex vai ao claude" (PATH só com `ab-bin-sem-codex` e `/usr/bin:/bin`) |
| CA-4 | sim | casos "no teto vai ao claude", "abaixo do teto padrão tenta o codex", "teto padrão é 20" |
| CA-5 | sim | casos `--contar` (soma, sai 0; no teto sai 1 e não soma; não roda agente) |
| CA-6 | sim | "falha sem cota sai 1" sem chamar o claude; "sem codex e sem claude sai 2"; uso inválido sai 3 |
| CA-7 | sim | casos "perfil luna/sol/revisor" conferem os argumentos exatos do `codex` |
| CA-8 | sim | contador em `$XDG_CACHE_HOME/codeflow/codex-AAAA-MM-DD`; lint (stack de script) verde |
| CA-9 | sim | `framework/library/skills/modo-delegado/SKILL.md:80-90` |
| CA-10 | sim | `CICLO-DO-RECRUTA.md:23` (regra 7), `MAESTRO.md:25` (regra 8), `DESPACHO.md:6` |
| CA-11 | sim | `SPEC.md:195` (§2.2) e `:1537` (§7.3), versão 3.8; `README.md:99`, 1.6; `glossary.md` sem diff |

## 7. No rework: o que mudou nesta tentativa

- Não se aplica (primeira execução).

## 8. Dúvidas para o revisor

- A busca de cota (`usage_limit_reached|usage limit|rate limit|quota`) só roda quando o `codex`
  sai ≠ 0, para uma tarefa que fala de "quota" e dá certo não cair no Claude.
- O contador soma antes de rodar o Codex: um despacho que cai no Claude por cota também conta.
