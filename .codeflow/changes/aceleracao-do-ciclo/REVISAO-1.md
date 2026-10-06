---
mudanca: aceleracao-do-ciclo
tentativa: 1
veredito: AJUSTAR
range_revisado: af22ea5..103ac6d
---

<!-- Preenchido pelo REVISOR (/review-change), em chat zerado. O revisor não
     altera código: só julga e registra.

     veredito: APROVADO quando não há nenhum BLOQUEANTE; AJUSTAR quando há ≥1.
     IMPORTANTE não segura o veredito — cada um sai com destino (corrigir agora,
     se for barato, ou registrar como melhoria). SUGESTÃO se descarta por padrão. -->

# Aceleração do ciclo (R1, R3, R8) — Revisão

## 1. Veredito

**AJUSTAR** — 2 BLOQUEANTES, ambos contradição entre workflow, molde e `ARTIFACTS_SPEC.md` no tema
herdados/escalada da R1 (critério 2 do despacho); 1 IMPORTANTE, 3 sugestões. A retrocompatibilidade
pedida (nenhum `.codeflow/` deixa de valer, `run-structural.sh` sem mudança) está provada, e R3 e R8
entraram como o plano diz. As correções são de texto, pequenas.

## 2. Critérios de aceite, conferidos no código

| CA | Atendido? | Evidência própria (teste rodado, arquivo:linha) |
|----|-----------|--------------------------------------------------|
| CA-1 | sim | `framework/core/ARTIFACTS_SPEC.md:2852-2856` (precedência; `APROVADO` com zero BLOQUEANTE; score/threshold não decidem); `evaluate-spec-phase.md:65` |
| CA-2 | sim, como o CA está escrito | `ARTIFACTS_SPEC.md:2850` (herdado aberto e 3+ IMPORTANTES escalam). Mas a regra "o mesmo IMPORTANTE 2 vezes" da R1 tem quatro definições diferentes: B-1 |
| CA-3 | sim | `ARTIFACTS_SPEC.md:2854` (condições), `:2935-2938` (estado próprio, reavaliação na mesma tentativa), `:2943` (não conta para o teto); `execute-spec-phase.md` linha 4 da tabela; `evaluate-spec-phase.md:37` (escolhe a fase pendente externo) |
| CA-4 | sim | `ARTIFACTS_SPEC.md:2838` (legado `RESSALVAS` = `APROVADO`), `:2864` (score, scorecard e 8 seções antigas válidos), `:2756` (EXECUCAO sem Herdados válido), `:2741` (`reprovacoes` nunca decresce), `:2643` e `:2700` (`quality_gate` opcional). `run-structural.sh` não lê `quality_gate`, `threshold` nem veredito (grep vazio) e não está no diff. Nos consumidores há 12 AVALIACAO com `veredito: RESSALVAS` e 9 sem `score`: todas continuam válidas pela §2.10.6 nova. Gate `test`: 55 specs reais, 0 divergência |
| CA-5 | sim | `double-check.md:49` (`reaberturas` < 2 reabre e soma; = 2 → `bloqueado`); `batch-bugfix.md:36` e o formato do ledger (coluna `reaberturas`, ausente = `0`) |
| CA-6 | sim | `change-sizing/SKILL.md:59-75` (P: uma frase, uma área, nenhum sinal de risco; destino direto com teste, check, `self-review` e trailer `Tamanho: P`; dúvida P/M vai a M) |
| CA-7 | sim | `plan-change.md:61` (pedido claro → `aprovado`, `aprovado_por: pedido claro do dono`); `implement-change.md` "Antes de começar"; `create-spec.md:22` (só G); `bugfix.md:66` (sem "não-trivial"); `refactor.md:6` (`gera_decision: auto`) e Fase 6 |
| CA-8 | sim | LEIA TAMBÉM dos quatro workflows cita só a seção, com o `sed`; rodei os três `sed`: §2.9–§2.11 = 232 linhas (de `### 2.9` a `### 2.12`), §2.11 = 38, §2.12 = 133 (até `## Parte 3`), o arquivo inteiro tem 3176. `create-spec.md:95` roda o `run-structural.sh` antes do commit. Resumo final dos 12 workflows tocados com o título e as cinco seções |
| CA-9 | sim | gate `check` verde na §7 (lint, test com 55 specs e 0 divergência, security) |

## 3. Conformidade com o plano

- As três etapas entraram como planejado, um commit verde cada (`c3b36a8`, `43435ab`, `ba1ea45`), mais a
  correção `103ac6d`, dentro do escopo da etapa 1 e declarada.
- Fora do mapa: só `.codeflow/manifest.md` (versões do contrato), declarado como desvio; e a proposta ao
  glossary saiu em decision própria (o plano previa dentro da decision principal), também declarado.
- Regras do repositório: core intocado (`git diff --name-only origin/main...HEAD` sobre `constitution.md`,
  `glossary.md`, `EVOLUTION.md`, `scripts/`, `install.sh`, `setup-*.sh` vazio); catálogo pago no item
  tocado (frontmatter `versão`/`atualizado` de todos os workflows, skill, `SPEC.md` 3.3 e
  `ARTIFACTS_SPEC.md` 2.3; `README.md` e `SPEC.md` §2.2/§3.5 sem item desatualizado pela mudança);
  decisions sem linha no INDEX; assuntos de commit com 57 a 67 caracteres, Conventional Commits em pt-BR,
  `Co-Authored-By` em todos; gate `security` sem nome proibido.
- Mudança de schema: aprovada pelo dono em 2026-10-05 (decisão delegada 1) e retrocompatível (CA-4).

## 4. Achados BLOQUEANTES

- **B-1** — "o mesmo IMPORTANTE pela 2ª vez" (R1) tem quatro definições que se contradizem:
  - `framework/core/ARTIFACTS_SPEC.md:2850`, `evaluate-spec-phase.md:64` e `TEMPLATE-AVALIACAO.md:17`:
    só o **herdado** não resolvido escala;
  - `framework/library/workflows/execute-spec-phase.md:74`: "IMPORTANTE deixado para trás [no rework]
    reaparece e vira BLOQUEANTE" — regra que o contrato e o avaliador não aplicam;
  - `framework/library/workflows/review-change.md:55`: só o IMPORTANTE anterior com destino "corrigir agora";
  - `framework/library/templates/changes/REVISAO.md:13`: **qualquer** IMPORTANTE da revisão anterior ainda aberto.

  Falha concreta: (a) fase com `REPROVADO` por 1 BLOQUEANTE e 1 IMPORTANTE; o rework só corrige o
  BLOQUEANTE; o avaliador, pela §2.10.3, vê o IMPORTANTE como novo e aprova — o executor foi instruído
  de outra forma, e a R1 ("o mesmo IMPORTANTE aparecendo 2 vezes") não se cumpre. (b) No ciclo de
  mudança, um IMPORTANTE com destino "registrar como melhoria" fica aberto de propósito; o revisor que
  segue o molde o escala e dá `AJUSTAR`, o que segue o workflow não.
  Régua: critério 2 do despacho (contradição entre workflow, molde e `ARTIFACTS_SPEC.md`); R1.
  Correção sugerida (regra da costura, R2: uma definição só, citada pelos demais): na §2.10.3, escalada
  (a) passa a ser "o IMPORTANTE de uma avaliação anterior da **mesma fase** (rework) ou herdado destinado
  à fase que segue aberto"; `evaluate-spec-phase.md:64` e `TEMPLATE-AVALIACAO.md:17` repetem a mesma
  frase; no ciclo de mudança, alinhar `REVISAO.md:13` a `review-change.md:55` (só "corrigir agora"),
  já que "registrar como melhoria" é aberto por decisão. Grep das gêmeas: `grep -rn 'pela 2ª vez\|deixado\|ainda aberto' framework/`.

- **B-2** — destino dos herdados contraditório entre o contrato e os dois workflows de spec.
  `framework/core/ARTIFACTS_SPEC.md:2949` (e a decision, item 4): o herdado vai para **a primeira fase**,
  na ordem textual da §5, cujo `Depende de` cita a fase de origem. `framework/library/workflows/execute-spec-phase.md:66`
  e `framework/library/workflows/evaluate-spec-phase.md:37` explicam "herdados destinados à fase" como
  "os IMPORTANTES abertos das avaliações `APROVADO` das fases **de que ela depende**" — todos os
  dependentes, não o primeiro.
  Falha concreta: A tem dependentes B e C (B primeiro), aprovada com I-1. Pelo contrato, I-1 vai só para
  B. Pelos workflows, o executor de C também o assume, e em ondas paralelas (R4) B e C corrigem o mesmo
  ponto em worktrees diferentes; o avaliador de C, se C não o listou, conta "herdado omitido = aberto"
  (§2.9.7) e escala para BLOQUEANTE — `REPROVADO` espúrio, rework e teto consumidos à toa.
  Régua: critério 2 do despacho; a própria decision (item 4) rejeita a ambiguidade em ondas.
  Correção sugerida: nos dois trechos, trocar a paráfrase por "os IMPORTANTES abertos cuja fase de
  destino, pela §2.11.5, é esta (a primeira dependente da fase de origem na ordem da §5)".

## 5. Achados IMPORTANTES

- **I-1** — `framework/core/SPEC.md:1333` — o exemplo de `gera_decision: auto` diz "bugfix com mudança
  arquitetural gera"; o `bugfix.md:66` agora tem lista fechada (default após incerteza, divergência da
  constitution) e manda o porquê para o commit. Ocorrência gêmea do gatilho removido que ficou para trás
  (R2: corrigir as gêmeas no mesmo passo). Destino: **corrigir agora**, no rework (uma linha: trocar o
  exemplo por "bugfix comum não gera; default após incerteza do dono ou divergência da constitution gera").

## 6. Sugestões

- `framework/library/workflows/create-spec.md:95` — "corrigir a §5 e rodar de novo, até `0`" não tem
  teto; citar a política de falhas da constitution (2 tentativas lógicas, depois parar).
- `framework/library/workflows/review-change.md:61` — o commit que corrige IMPORTANTE depois de
  `APROVADO` é código sem nova revisão; neste repositório a constitution do projeto só dispensa nova
  revisão para commit **de documento** depois da revisão. Dizer que a constitution do projeto prevalece
  quando exigir nova revisão (responde à dúvida 2 do executor).
- `framework/library/workflows/spec-status.md:33` cita `§2.9.3`, fora do trecho que ele lê (só §2.11);
  trocar por §2.11.4, que já explica o `reprovacoes`.

## 7. Comandos rodados e saídas reais

```text
# independência e range
$ git merge-base --is-ancestor 103ac6d HEAD && echo ancestor-ok   → ancestor-ok
$ git merge-base --is-ancestor af22ea5 HEAD && echo base-ok       → base-ok
$ git rev-parse --short HEAD; git rev-parse --short origin/main   → 1cca6a4 / be1e70b (merge-base be1e70b)

# core, scripts e setup intocados
$ git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md \
    framework/core/EVOLUTION.md framework/core/scripts/ install.sh 'setup-*.sh'
(vazio)
$ grep -n 'quality_gate\|threshold\|scorer\|RESSALVAS\|veredito' framework/core/scripts/run-structural.sh
(vazio)

# gate check do .codeflow/manifest.md, uma vez, na raiz da worktree, em 1cca6a4 (árvore limpa)
== lint
lint rc=0
== test
specs comparadas: 55, divergências: 0
(setup-slash-commands.sh em HOME temporário: criados 21, atualizados 0, órfãos 0 — ✓ Sincronização concluída.)
(setup-codex-skills.sh em HOME temporário: criados 21, pulados 0 — ✓ Sincronização concluída.)
test rc=0
== security
INF 6 commits scanned.
INF scan completed in 34.3ms
INF no leaks found
security rc=0

# comandos de seção citados pelos workflows
$ sed -n '/^### 2\.9 /,/^### 2\.12 /p' framework/core/ARTIFACTS_SPEC.md   → 232 linhas, de "### 2.9 Relatório de execução" a "### 2.12 Roteiro"
$ sed -n '/^### 2\.11 /,/^### 2\.12 /p' framework/core/ARTIFACTS_SPEC.md  → 38 linhas, de "### 2.11 Máquina de estados" a "### 2.12 Roteiro"
$ sed -n '/^### 2\.12 /,/^## Parte 3/p' framework/core/ARTIFACTS_SPEC.md  → 133 linhas, de "### 2.12 Roteiro" a "## Parte 3"
(cada âncora aparece uma vez só no arquivo)

# artefatos legados nos projetos consumidores (só contagem)
$ grep -h '^veredito:' ~/Projetos/*/.codeflow/specs/*/artefatos/*AVALIACAO*.md | sort | uniq -c
    412 APROVADO · 12 RESSALVAS · 4 REPROVADO · 4 valores fora do enum antigo, anteriores a esta mudança
$ grep -L '^score:' .../*AVALIACAO*.md | wc -l   → 9

# assuntos dos commits do range: 57, 59, 65, 67, 67 caracteres; Co-Authored-By em todos
```

## 8. Divergências entre o relatório e o código

- CA-2 "sim" no relatório: vale para o CA como escrito, mas a escalada da R1 ficou com definições
  divergentes entre contrato, workflows e molde (B-1).
- §8 do relatório, dúvida 1 (fechamento sem avaliador): conforme a R1 ("o executor da próxima fase,
  **ou o fechamento**, resolve"); não é achado.
- Fora isso, nenhuma: o `check`, os `sed` de seção, o core intocado e os arquivos declarados batem com o código.
