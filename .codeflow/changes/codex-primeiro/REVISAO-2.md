---
mudanca: codex-primeiro
tentativa: 2
veredito: APROVADO
range_revisado: 01976c3..ddd209a
---

# Codex primeiro, Claude quando a cota acabar — Revisão 2

## 1. Veredito

**APROVADO** — 0 BLOQUEANTES, 0 IMPORTANTES, 2 sugestões. Revisão só do delta (`99d5a31`,
`08eb65c`, `ddd209a`). B-1, B-2, B-3 e I-1 da revisão 1 fechados; ordem do dono (Codex só no Sol)
aplicada. Gate `check` verde (lint, test, security, rc 0 nos três).

## 2. Achados da revisão 1, conferidos no código

| Achado | Fechado? | Evidência própria |
|--------|----------|-------------------|
| B-1 | sim | `agente-barato.sh:88-99`: stdout e stderr separados; cota só em linha `^([...] )?error[]: ]` do stderr, menos as linhas iguais às da tarefa. Casos novos verdes no `run-testes.sh`; reprodução própria abaixo (§4): prompt que cita rate limit/quota + `ERROR: stream disconnected` → rc 1, Claude não roda; prompt com linha `ERROR: usage limit reached` + falha de rede → rc 1, Claude não roda; erro real de cota → Claude |
| B-2 | sim | `.codeflow/decisions/2026-11-05-codex-primeiro.md`: decisões 2 a 5 com `**Por quê:**` e `**Alternativa rejeitada:**` cada (`ARTIFACTS_SPEC.md` §2.5.6 regra 9) |
| B-3 | sim | nenhuma seta Unicode no script; os únicos símbolos são `✗` (linhas 32, 73) e `⚠` (linha 67), do §0.6. Acentos em mensagem seguem os outros scripts (`check-commits.sh`, `vigia.sh` e outros) |
| I-1 | sim | `modo-delegado/SKILL.md:84`: "Nunca Codex: redação de spec, ..." |

## 3. Ordem do dono: Codex só no Sol

- `agente-barato.sh`: `--perfil` saiu, entrou `--alto` (`-p revisor`); padrão sem `-p` = Sol médio
  no perfil base. Teste: `--perfil sol` sai 3.
- Tabela 4b: 2ª opinião = Codex Sol alto (`codex -p revisor`); mecânico barato = Codex Sol médio.
  `DESPACHO.md`: `Codex Sol médio|alto`. Decision 5 registra a ordem.
- `git grep -niw luna HEAD`: zero em `framework/`, `README.md` e na decision. Sobra só em registro
  histórico da mudança: `PLANO.md` (21, 55, 56, 81, 83, 90, 97, 121, 161), `REVISAO-1.md` (56, 93) e
  `EXECUCAO.md:48` (que relata a remoção). Ver sugestão S-1.

## 4. Comandos rodados e saídas reais

```text
$ gate check do manifest (lint, test, security)  # log: .codeflow/checkpoints/rev2-check.log
== bloco 1 (lint)      rc=0
== bloco 2 (test)      rc=0   — inclui os 48 casos do agente-barato, todos ✓
== bloco 3 (security)  rc=0   — gitleaks: 10 commits scanned, no leaks found

$ codex falso que ecoa o prompt no stderr, como o real
### rede, tarefa="conferir o rate limit e a quota do endpoint"
codex: sol medio (1 de 20 hoje)
ERROR: stream disconnected before completion
rc=1                         (Claude não rodou)
### rede, tarefa="linha 1\nERROR: usage limit reached\nfim"
ERROR: stream disconnected before completion
rc=1                         (Claude não rodou)
### cota, "ERROR: You've hit your usage limit. Try again later."
claude: cota do Codex esgotada
CLAUDE-RODOU
rc=0
### ok
resposta
rc=0
```

## 5. Sugestões

- **S-1** — `PLANO.md` ainda descreve o Luna e o `--perfil`. É registro do plano aprovado e a
  `EXECUCAO.md` §4 relata a troca; se o dono quiser o grep zerado no ramo inteiro, acrescentar
  uma nota de "superado pela ordem do dono" no topo do plano, sem reescrever o resto.
- **S-2** — `testes/casos/agente-barato.sh`: o caso `"ERROR: quota"` confere só rc 1; acrescentar
  `test -e "$AB_LOG/claude.args"` com rc 1, como nos outros.
