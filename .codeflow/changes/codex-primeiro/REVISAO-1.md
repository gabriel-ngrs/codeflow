---
mudanca: codex-primeiro
tentativa: 1
veredito: AJUSTAR
range_revisado: 799971f..e27a757
---

# Codex primeiro, Claude quando a cota acabar — Revisão

## 1. Veredito

**AJUSTAR** — 3 BLOQUEANTES, 1 IMPORTANTE, 3 sugestões. Gate `check` verde e os 40 casos do
script verdes, mas o fallback cai no Claude em falha comum quando a tarefa cita cota, a decision
fere a §2.5.6 e a saída do script usa seta Unicode (§0.6).

## 2. Critérios de aceite, conferidos no código

| CA | Atendido? | Evidência própria (teste rodado, arquivo:linha) |
|----|-----------|--------------------------------------------------|
| CA-1 | sim | `run-testes.sh agente-barato` verde; `agente-barato.sh:88-97` |
| CA-2 | sim | casos cota/rate; `agente-barato.sh:74` (`-p --effort medium`, `</dev/null`); flags conferidas no `claude --help` |
| CA-3 | sim | caso "sem codex vai ao claude"; `agente-barato.sh:78` |
| CA-4 | sim | casos de teto; `agente-barato.sh:79` |
| CA-5 | sim | casos `--contar`; `agente-barato.sh:65-69` |
| CA-6 | **não, em parte** | rc 1/2/3 verdes, mas ver B-1: falha comum com a tarefa citando "rate limit" cai no Claude |
| CA-7 | sim | casos de perfil; `agente-barato.sh:81-85`; `-p`, `-s`, `-c` existem no `codex exec --help` |
| CA-8 | sim | contador só um inteiro, `0644`, em `$XDG_CACHE_HOME/codeflow/codex-AAAA-MM-DD`; lint verde |
| CA-9 | sim | `modo-delegado/SKILL.md:80-90` (ver I-1) |
| CA-10 | sim | `CICLO-DO-RECRUTA.md:23-25`, `MAESTRO.md:25-27`, `DESPACHO.md:6` |
| CA-11 | sim | `SPEC.md:195` e `:1537`, 3.8; `README.md:99`, 1.6; `glossary.md`, `constitution.md`, `EVOLUTION.md` sem diff |

## 3. Conformidade com o plano

- Duas etapas entregues como planejado. Fora do mapa: `.codeflow/manifest.md` (só a versão do
  `SPEC.md` na stack, commit `e27a757`) e a decision; ambos coerentes com a mudança.
- Pontos de atenção do despacho: (a) falha — B-1; (b) ok, a lista "Nunca Codex" cobre segurança,
  spec, contrato, debug e execução de fase (ver I-1 sobre a redação); (c) ok, o contador guarda só
  um inteiro e o temporário (`mktemp`, 0600) sai no `trap`; (d) ok, nenhum caminho absoluto nem
  nome nas linhas acrescentadas (grep e gate `security`).

## 4. Achados BLOQUEANTES

- **B-1** — `framework/core/scripts/agente-barato.sh:90-92` — a busca de cota roda sobre stdout e
  stderr juntos do `codex`, e o `codex exec` ecoa o prompt; uma tarefa que cita "quota" ou "rate
  limit" e falha por motivo comum (rede, briefing) cai no Claude. Reproduzido: `codex` falso que
  ecoa a tarefa e sai 1 com `ERROR: stream disconnected` → `→ claude (cota do Codex esgotada)`,
  rc 0. Régua: CA-6 e ponto (a) do despacho. Correção: buscar só em linha de erro (ex.:
  `^(ERROR|error)[: ].*(usage_limit_reached|usage limit|rate limit|quota)`) ou excluir o eco do
  prompt; caso de teste com `codex` falso que ecoa a tarefa.
- **B-2** — `.codeflow/decisions/2026-11-05-codex-primeiro.md:33-44` — as decisões 2, 3 e 4 não
  têm `**Por quê:**` (2, 3, 4) nem `**Alternativa rejeitada:**` (3, 4). Régua: `ARTIFACTS_SPEC.md`
  §2.5.6 regra 9 e §2.5.3. Correção: completar; as alternativas já estão no `PLANO.md` §7
  (decisões 3, 4 e 6).
- **B-3** — `framework/core/scripts/agente-barato.sh:73,89` — a saída usa `→`, seta Unicode.
  Régua: `ARTIFACTS_SPEC.md` §0.6 e Parte 3 regra 22 (nenhum outro script usa). Correção: texto sem
  símbolo (`codex luna (1 de 20 hoje)`) ou `⚠` na queda para o Claude.

## 5. Achados IMPORTANTES

- **I-1** — `framework/library/skills/modo-delegado/SKILL.md:80,83` — "Nunca Codex: spec" convive
  com a linha Codex Sol "1ª rodada de revisão de spec"; quem lê pode tomar uma pela outra.
  Escrever "redação de spec" (ou "spec, salvo a 2ª opinião acima"). Destino: corrigir agora, no
  rework.

## 6. Sugestões

- `agente-barato.sh:56-62` — dois despachos simultâneos leem o mesmo valor e somam 1 só; aceitável
  para um teto aproximado.
- `agente-barato.sh:47` — tarefa que começa por `-` sai 3; aceitar `--` antes da tarefa.
- `README.md:98-99` — falta a vírgula depois do item do `check-commits.sh` na enumeração.

## 7. Erros de registro

- `EXECUCAO.md` §4 diz que o `manifest.md` ficou de fora, mas o `e27a757` o atualizou depois;
  ajustar a frase.

## 8. Comandos rodados e saídas reais

```text
$ check do manifest (lint, test, security), na raiz — log: .codeflow/checkpoints/review-codex-primeiro-check.log
✓ 6 commit(s) de 799971f..HEAD conferidos
✓ contexto fixo dentro dos tetos
lint rc=0
✓ 161 verificações verdes
test rc=0
INF 6 commits scanned.
INF no leaks found
security rc=0
$ bash framework/core/scripts/testes/run-testes.sh agente-barato
✓ 40 verificações verdes   # rc=0
$ codex falso (ecoa a tarefa em stderr, "ERROR: stream disconnected", sai 1)
$ agente-barato.sh "conferir o rate limit do endpoint"
→ codex luna (1 de 20 hoje)
→ claude (cota do Codex esgotada)
SAIDA-CLAUDE
rc=0
$ git diff -U0 origin/main..HEAD | grep '^+' | grep -E '/home/|/Users/|/mnt/'   # rc=1, nada
$ git diff --quiet origin/main..HEAD -- framework/core/{glossary,constitution,EVOLUTION}.md   # core sem diff
```

## 9. Divergências entre o relatório e o código

- `EXECUCAO.md` §6 dá CA-6 como atendido; vale para o `codex` falso dos testes, não para um que
  ecoa o prompt (B-1).
- `EXECUCAO.md` §4 e o `e27a757` (erro de registro acima).
