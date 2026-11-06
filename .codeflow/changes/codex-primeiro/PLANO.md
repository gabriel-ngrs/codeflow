---
mudanca: codex-primeiro
tipo: melhoria
tamanho: media
status: proposto
aprovado_por: <quem aprovou, quando aprovado>
aprovado_em: <AAAA-MM-DD, quando aprovado>
registro: pedido do dono de 2026-11-05 ("Codex primeiro enquanto houver cota, Claude quando acabar"); plano do orquestrador de 2026-11-05, decisões D1, D2 e D3
---

<!-- Preenchido pelo PLANEJADOR (/plan-change), em modo delegado. Pela D1 do
     orquestrador, o plano não espera nova aprovação do dono: o orquestrador
     troca o status para aprovado. Sai "proposto" porque leva decisões pequenas
     para ele ratificar (§7). -->

# Codex primeiro, Claude quando a cota acabar — Plano

## 1. Objetivo

Poupar a cota da Anthropic: as tarefas curtas de conferência e as mecânicas vão primeiro ao Codex
(Sol ou Luna) e caem no Claude sozinhas quando a cota do Codex acaba ou o teto diário estoura.
Edita a tabela 4b do `modo-delegado` e os moldes de orquestração do PR #7; o único arquivo novo é o
script de fallback para tarefa não interativa, com o teste dele.

## 2. Fora de escopo

- Qualquer outro item do pacote de tokens.
- Codex em spec, orquestração, contrato, debug difícil, execução de fase e segurança/pentest (a
  OpenAI bloqueia): continua Opus, como na tabela.
- Medir a cota real do Codex: o teto diário nasce com um padrão e o dono ajusta.
- Termo novo no `glossary.md` (core, D3): "Codex primeiro" fica como texto descritivo.

## 3. Classificação (skill `change-sizing`)

| Sinal | Valor | Evidência |
|-------|-------|-----------|
| Etapas | 2 (média) | script com teste; texto da política nos moldes |
| Áreas tocadas | 3 (média) | `framework/core/scripts/`, `framework/library/skills/modo-delegado/`, `framework/library/templates/orquestracao/` (+ catálogo) |
| Contrato / fronteira | compatível (média) | `SPEC.md` §7.3 ganha a exceção declarada do script (chama `codex`/`claude`); nada muda para quem não usa |
| Migração | não | — |
| ADR nova | não | — |
| Comportamento percebido | novo, isolado | só o Maestro e quem chamar o script novo |

Sinal de risco: política de gasto e contrato do `SPEC.md` — cobertos pela D2 (política de modelo
aprovada; contrato do `SPEC.md`). Conclusão: **melhoria, M média**.

## 4. Mapa do código

| Caminho | NOVO / ALTERADO / REUSADO | Para quê |
|---------|---------------------------|----------|
| `framework/core/scripts/agente-barato.sh` | NOVO | `codex exec` com fallback para `claude -p`; contador e teto diário |
| `framework/core/scripts/testes/casos/agente-barato.sh` | NOVO | casos com `codex` e `claude` falsos no `PATH` |
| `framework/core/scripts/testes/run-testes.sh` | REUSADO | `caso`, `tem`, `nao_tem`, `$T` |
| `framework/core/scripts/vigia.sh` | REUSADO | precedente de cabeçalho, `usage`, saídas 0-3 |
| `framework/library/skills/modo-delegado/SKILL.md` | ALTERADO | tabela 4b: linhas Codex Sol / Codex Luna, lista "nunca Codex", fallback e orçamento; versão 1.3 → 1.4 |
| `framework/library/templates/orquestracao/DESPACHO.md` | ALTERADO | linha `Modelo:` aceita Codex Sol/Luna |
| `framework/library/templates/orquestracao/CICLO-DO-RECRUTA.md` | ALTERADO | regra de troca no `usage_limit_reached` |
| `framework/library/templates/orquestracao/MAESTRO.md` | ALTERADO | regra do orçamento diário (`agente-barato.sh --contar`) |
| `framework/core/SPEC.md` | ALTERADO | §2.2 (linha do script na árvore), §7.3 (exceção declarada), frontmatter 3.7 → 3.8 |
| `README.md` | ALTERADO | lista de scripts; frontmatter 1.5 → 1.6 |

§3.5 do `SPEC.md` (organização universais × projetos) não lista scripts nem skills por nome:
conferido, nada a mudar; o pagamento do catálogo fica na §2.2 e no `README.md`.

> Todo caminho ALTERADO ou REUSADO existe no repositório (conferido ao escrever).

## 5. Critérios de aceite

- **CA-1** — Dado um `codex` falso que sai 0, quando roda `agente-barato.sh "<tarefa>"`, então a
  saída do Codex aparece, o `claude` falso não é chamado, o contador do dia sobe 1 e o rc é 0.
- **CA-2** — Dado um `codex` falso que imprime `usage_limit_reached` (ou "usage limit" / "rate
  limit" / "quota", sem diferenciar maiúscula), quando roda o script, então a mesma tarefa vai ao
  `claude -p --effort medium`, com `</dev/null`, e o rc é o do Claude.
- **CA-3** — Dado `PATH` sem `codex`, quando roda o script, então vai direto ao Claude (rc do Claude).
- **CA-4** — Dado contador do dia ≥ teto (`--teto <n>`, padrão 20), quando roda o script, então não
  chama o Codex e vai ao Claude; sem arquivo de contador, tenta o Codex.
- **CA-5** — Dado `--contar`, quando o contador está abaixo do teto, então soma 1 e sai 0; no teto,
  não soma e sai 1 (o Maestro usa isso para escolher Codex ou o preset Claude).
- **CA-6** — Dado `codex` falso que falha sem mensagem de cota, então o script **não** cai no Claude:
  repassa a saída e sai 1. Sem `codex` e sem `claude`, sai 2. Sem tarefa, ou opção desconhecida,
  ou `--perfil` fora de `sol|luna|revisor`, sai 3.
- **CA-7** — Dado `--perfil sol`, então o `codex` recebe `exec -p sol -c model_reasoning_effort=high`;
  `--perfil revisor`, `-p revisor`; padrão (`luna`), sem `-p`. Sempre `-s read-only`, salvo
  `--escrita` (`-s workspace-write`).
- **CA-8** — O contador mora em `${XDG_CACHE_HOME:-$HOME/.cache}/codeflow/codex-AAAA-MM-DD`
  (um inteiro); nos testes, `HOME` e `XDG_CACHE_HOME` apontam para `$T`. O script só usa bash e
  coreutils na lógica e passa no `lint` (nenhuma palavra proibida da linha de stack).
- **CA-9** — A tabela 4b do `modo-delegado` diz, em texto curto: Codex Sol (`codex -p sol -c
  model_reasoning_effort=high`) só para a 2ª opinião da 1ª rodada de revisão de spec e a conferência
  de delta pós-rework; Codex Luna (perfil base, medium; `-p revisor` = Luna high) só para revisão de
  PR só de documento e tarefas mecânicas (registrar bug/índice, contar, conferir consistência, rodar
  o gate e resumir a saída); a lista "nunca Codex"; o fallback (recruta e script) e o orçamento.
- **CA-10** — `CICLO-DO-RECRUTA.md` manda, ao ver `usage_limit_reached` (ou erro de cota/limite) no
  `maestri check`, trocar no mesmo terminal com
  `maestri recruit "<nome>" --preset "Claude Médio" --replace "<nome>"` e reenviar o despacho;
  `MAESTRO.md` traz a regra do teto diário com `agente-barato.sh --contar`; `DESPACHO.md` aceita
  `Codex Sol|Codex Luna` na linha `Modelo:`.
- **CA-11** — Catálogo pago: `SPEC.md` §2.2 lista o script, §7.3 declara a exceção (o script
  despacha `codex`/`claude`, que são a carga dele, não ferramenta de parsing), frontmatter do
  `SPEC.md`, do `README.md` e do `modo-delegado` atualizados; `glossary.md` intocado.

## 6. Etapas

### Etapa 1 — Script de fallback com teste
- **Faz:** caso de teste primeiro (vermelho: script inexistente); depois `agente-barato.sh`:
  `usage`; opções `--perfil`, `--escrita`, `--teto`, `--contar`; contador do dia; `command -v codex`;
  `codex exec ... "$tarefa" </dev/null` com a saída num temporário (`mktemp`), `grep -qiE` de cota;
  fallback `claude -p --effort medium "$tarefa" </dev/null`; uma linha em stderr dizendo qual agente
  rodou e por quê. Linha do script no `SPEC.md` §2.2, exceção no §7.3, `README.md`, frontmatters.
- **Arquivos:** `framework/core/scripts/agente-barato.sh`,
  `framework/core/scripts/testes/casos/agente-barato.sh`, `framework/core/SPEC.md`, `README.md`.
- **Testes:** `casos/agente-barato.sh` cria `$T/bin/codex` e `$T/bin/claude` falsos (gravam os
  argumentos num arquivo e imprimem um marcador) e roda com `env PATH="$T/bin:$PATH" HOME="$T"
  XDG_CACHE_HOME="$T/cache"`; um caso por CA-1 a CA-8. O caso "sem codex" usa um `PATH` só com
  `$T/bin-sem-codex` e as ferramentas de base.
- **Cobre:** CA-1 a CA-8, CA-11 (parte do script).
- **Gate:** `check` do manifest (`lint`, `test` com `run-testes.sh`, `security`).

### Etapa 2 — Política "Codex primeiro" na tabela e nos moldes
- **Faz:** na tabela 4b, a linha "2ª opinião" vira Codex Sol (também conferência de delta pós-rework)
  e entra a linha Codex Luna (PR só de documento, mecânico); abaixo, três bullets curtos: "Nunca
  Codex", "Fallback" (recruta: troca pelo preset Claude Médio; não interativo: `agente-barato.sh`) e
  "Orçamento" (teto diário pelo `--contar`). Moldes: `DESPACHO.md` (linha `Modelo:`),
  `CICLO-DO-RECRUTA.md` (regra 7, troca no limite), `MAESTRO.md` (regra 8, teto diário).
  Frontmatter do `modo-delegado` 1.3 → 1.4; `README.md`/`SPEC.md` se a Etapa 1 não tiver pago.
- **Arquivos:** `framework/library/skills/modo-delegado/SKILL.md`,
  `framework/library/templates/orquestracao/{DESPACHO,CICLO-DO-RECRUTA,MAESTRO}.md`.
- **Testes:** sem teste automático (texto); conferência por `grep -n` dos literais de CA-9/CA-10 e
  o `lint` (palavra-fraca nos `.md` do ramo).
- **Cobre:** CA-9, CA-10, CA-11.
- **Gate:** `check` do manifest.

## 7. Riscos e como desfazer

- **Mensagem de cota do Codex muda de texto** → o fallback não dispara e a tarefa falha com rc 1
  (visível, não silenciosa). O padrão de busca fica numa linha só do script, fácil de ajustar.
- **Teto padrão errado** (20/dia) → só desloca gasto entre Codex e Claude; o dono ajusta com
  `--teto`. Desfazer tudo: reverter os dois commits; nada persiste além do contador em cache.

### Decisões pedidas ao orquestrador
1. **Exceção da §7.3 no `SPEC.md`:** a §0.9/§7.3 exige decisão explícita para dependência fora da
   lista; o script chama `codex` e `claude` (a carga, não a lógica). Proposta: declarar a exceção
   na §7.3 (coberta pela D2, contrato do `SPEC.md`). Alternativa descartada: script fora do framework.
2. **Script em `core/scripts/`, que a §2.2 chama de "read-only":** ele grava o contador em
   `~/.cache/codeflow/` e roda agentes. Proposta: a linha do script na §2.2 diz isso. Alternativa
   descartada: pasta nova de scripts.
3. **O script também soma o contador** quando roda o Codex (não só lê), para Maestro e script
   contarem no mesmo arquivo; e oferece `--contar` para o Maestro. Alternativa: só ler.
4. **Teto padrão 20 despachos/dia** até o dono medir a cota semanal. Alternativa: sem padrão
   (exigir `--teto`).
5. **Sintaxe do Maestri:** o pedido escreve `maestri recruit --replace "<nome>" --preset ...`; o
   `maestri recruit --help` exige o nome novo posicional: `maestri recruit "<nome>" --preset
   "Claude Médio" --replace "<nome>"`. O molde usa a forma do `--help`.
6. **Falha do Codex sem mensagem de cota não cai no Claude** (sai 1): o pedido só manda cair por
   cota ou ausência; cair em toda falha gastaria Claude em erro de briefing.

## 8. Como a revisão vai provar

- `bash framework/core/scripts/testes/run-testes.sh agente-barato` — verde, um caso por CA-1 a CA-8.
- `check` do manifest verde no ramo.
- `grep -n 'Codex Sol\|Codex Luna\|usage_limit_reached\|--contar' framework/library/skills/modo-delegado/SKILL.md framework/library/templates/orquestracao/*.md` — CA-9/CA-10.
- `grep -n 'agente-barato' framework/core/SPEC.md README.md` e `git diff origin/main -- framework/core/glossary.md` vazio — CA-11.
