---
mudanca: aceleracao-do-ciclo
tentativa: 2
veredito: APROVADO
range_revisado: af22ea5..301c389
---

<!-- Preenchido pelo REVISOR (/review-change), em chat zerado. O revisor não
     altera código: só julga e registra.

     veredito: APROVADO quando não há nenhum BLOQUEANTE; AJUSTAR quando há ≥1.
     IMPORTANTE não segura o veredito — cada um sai com destino (corrigir agora,
     se for barato, ou registrar como melhoria). SUGESTÃO se descarta por padrão. -->

# Aceleração do ciclo (R1, R3, R8) — Revisão

## 1. Veredito

**APROVADO** — zero BLOQUEANTE. B-1, B-2 e I-1 da REVISAO-1 estão resolvidos no código (`4bb991f`,
`301c389`), sem contradição nova entre workflows, moldes e `ARTIFACTS_SPEC.md`; a retrocompatibilidade
segue provada e o gate `check` sai verde. Ficam 2 IMPORTANTES, ambos gêmeas que o rework não alcançou
(R2), e 2 sugestões.

## 2. Critérios de aceite, conferidos no código

| CA | Atendido? | Evidência própria (teste rodado, arquivo:linha) |
|----|-----------|--------------------------------------------------|
| CA-1 | sim | `framework/core/ARTIFACTS_SPEC.md:2852-2856` (precedência; `APROVADO` com zero BLOQUEANTE; IMPORTANTES abertos viram herdados; score e threshold não decidem); `evaluate-spec-phase.md:65` |
| CA-2 | sim | `ARTIFACTS_SPEC.md:2850`, agora a **definição única** da escalada: (a) IMPORTANTE de avaliação anterior da mesma fase (rework) ou herdado destinado à fase que segue aberto; (b) 3 ou mais abertos. Citada verbatim por `evaluate-spec-phase.md:64`, `TEMPLATE-AVALIACAO.md:17-20`, `execute-spec-phase.md:74` e `:2951` (§2.11.5) |
| CA-3 | sim | `ARTIFACTS_SPEC.md:2854` (condições), `:2935-2938` (estado próprio, reavaliação na mesma tentativa), `:2943` (não conta para o teto); `execute-spec-phase.md` linha 4 da tabela; `evaluate-spec-phase.md:37` |
| CA-4 | sim | `ARTIFACTS_SPEC.md:2838` (`RESSALVAS` legado = `APROVADO`), §2.10.4 (score, scorecard e 8 seções antigas válidos), §2.9.3 (EXECUCAO sem Herdados válido; `reprovacoes` nunca decresce), §2.8.4/§2.8.6 (`quality_gate` opcional). `run-structural.sh` fora do diff e sem `quality_gate`/`threshold`/`veredito` (grep vazio). Nos consumidores: 12 AVALIACAO `RESSALVAS` e 412 `APROVADO`, todas válidas pela §2.10.6; 45 ledgers sem a coluna `reaberturas` valem `0` (`batch-bugfix.md`). Gate `test`: 55 specs reais, 0 divergência |
| CA-5 | sim | `double-check.md` Passo 3 (`reaberturas` < 2 reabre e soma; = 2 → `bloqueado`); `batch-bugfix.md`, formato do ledger |
| CA-6 | sim | `change-sizing/SKILL.md` protocolo 4 e 5 (P: uma frase, uma área, nenhum sinal de risco; destino direto; trailer `Tamanho: P`; dúvida P/M vai a M) |
| CA-7 | sim | `plan-change.md` Passo 5; `create-spec.md` "Quando NÃO usar"; `bugfix.md` Passo 6 (lista fechada); `refactor.md` `gera_decision: auto` e Fase 6; `SPEC.md:1333` alinhado (I-1 da REVISAO-1) |
| CA-8 | sim | LEIA TAMBÉM de `execute-spec-phase`, `evaluate-spec-phase`, `spec-status` e `ideacao` com o `sed` da seção; `create-spec.md` ação 4 roda o `run-structural.sh`; resumo final dos workflows tocados com o título e as cinco seções |
| CA-9 | sim | gate `check` verde na §7, rodado uma vez, na raiz, em `7abbea0` |

## 3. Conformidade com o plano

- Rework restrito aos achados: `4bb991f` (B-1, B-2: §2.10.3, §2.11.5, `evaluate-spec-phase`,
  `execute-spec-phase`, `review-change`, `REVISAO.md`, `TEMPLATE-AVALIACAO.md` e a decision) e `301c389`
  (I-1: `SPEC.md` §6.5.1). Nada fora do mapa do plano; `7abbea0` só atualiza o `EXECUCAO.md`.
- **B-1 resolvido:** uma definição na §2.10.3 ("definição única; workflows e moldes a citam"); o grep
  `pela 2ª vez|deixado para trás|ainda aberto|segue aberto` em `framework/` só acha a definição e as
  citações dela. No ciclo de mudança, `review-change.md:55` e `REVISAO.md:12-15` dizem o mesmo: só escala
  o de destino "corrigir agora"; "registrar como melhoria" não escala.
- **B-2 resolvido** nos passos operacionais: `execute-spec-phase.md:66` e `evaluate-spec-phase.md:37`
  dizem "a **primeira** fase … que depende da fase de origem; outra dependente não os recebe", como a
  §2.11.5 e a decision (item 4). Sobra uma paráfrase antiga no parágrafo de abertura (I-1 abaixo).
- **I-1 da REVISAO-1 resolvido** em `SPEC.md:1333`. Sobram gêmeas no `ARTIFACTS_SPEC.md` (I-2 abaixo).
- Regras do repositório: core intocado (`constitution.md`, `glossary.md`, `EVOLUTION.md`, `scripts/`,
  `install.sh`, `setup-*.sh` fora do diff); catálogo pago (as versões dos itens tocados no rework já
  tinham subido nesta mudança, no mesmo dia, sem release entre elas); `decisions/INDEX.md` intocado;
  assuntos dos commits do rework com 66, 66 e 69 caracteres, Conventional Commits em pt-BR,
  `Co-Authored-By` nos três; nenhum caminho absoluto acrescentado; gate `security` sem segredo nem nome
  proibido.
- Mudança de schema: aprovada pelo dono em 2026-10-05 (decisão delegada 1) e retrocompatível (CA-4).

## 4. Achados BLOQUEANTES

- nenhum.

## 5. Achados IMPORTANTES

- **I-1** — gêmeas de B-1/B-2 que o rework não alcançou (R2: corrigir as ocorrências gêmeas no mesmo passo):
  - `framework/library/workflows/execute-spec-phase.md:14` — "resolve também os IMPORTANTES **herdados**
    das fases de que depende": é a paráfrase que B-2 apontou (todas as dependências, não a primeira
    dependente). Não bloqueia porque o Passo 3 (`:66`) é explícito e vence na execução; mas um executor
    que leia só a abertura assume herdados que não são dele.
  - `framework/core/ARTIFACTS_SPEC.md:2883` — o exemplo da §2.10.5 é de `tentativa: 2` (rework) e a seção
    se chama "Herdados conferidos", só com os herdados; pela §2.10.3 (seção 2), em rework ela confere
    também os IMPORTANTES da avaliação t1. O exemplo é o que o agente copia ao gerar análogos.
  - Correção: em `:14`, "os IMPORTANTES herdados destinados a ela (ARTIFACTS_SPEC §2.11.5)"; em `:2883`,
    "## Herdados e IMPORTANTES anteriores conferidos" com uma linha para a t1 ("nenhum IMPORTANTE em t1",
    ou o item resolvido).
  - Destino: **corrigir agora** (duas linhas).

- **I-2** — gêmeas do I-1 da REVISAO-1 (o gatilho "não-trivial" que saiu do `bugfix`):
  - `framework/core/ARTIFACTS_SPEC.md:2261` (§2.5.1) — `gera_decision: auto` gera "quando a IA julga
    necessário (tipicamente: mudança não-trivial, …)", em contraste com `SPEC.md:1333` ("pelos gatilhos
    que o workflow declara") e com as listas fechadas de `bugfix`, `batch-bugfix`, `implement-change` e
    `refactor`.
  - `framework/core/ARTIFACTS_SPEC.md:1010` — o exemplo preenchido de workflow (§1.6.5, que é o
    `bugfix`) ainda traz o gatilho "mudança não-trivial".
  - Não bloqueia: o workflow declara a própria lista e ela vence. Correção: em `:2261`, "pelos gatilhos
    que o workflow declara (ex.: default após incerteza do dono, divergência consciente da
    constitution, mudança quebradora aprovada)"; em `:1010`, o texto do Passo 6 do `bugfix.md` atual.
  - Destino: **corrigir agora** (duas linhas).

Os dois destinos "corrigir agora" mexem em `framework/`; a constitution do projeto
(`.codeflow/constitution.md:28`) só dispensa nova revisão para commit de documento de registro depois da
revisão aprovada. Então o commit de correção pede uma revisão limpa do próprio diff antes do merge — ou o
orquestrador troca o destino para "registrar como melhoria" e mergeia sobre `7abbea0` + esta revisão.

## 6. Sugestões

- `framework/library/workflows/implement-change.md:47` — "IMPORTANTE deixado aberto reaparece e vira
  BLOQUEANTE" lê-se certo pelo contexto (só os de destino "corrigir agora"), mas não cita a escalada do
  `review-change` (Passo 3), que é a definição; citá-la evita a terceira redação.
- As três sugestões da REVISAO-1 (teto no `create-spec.md:95`, ressalva da constitution do projeto no
  `review-change.md:61`, `spec-status.md:33` citando §2.9.3 fora do trecho que lê) seguem abertas;
  descartadas por padrão, como o `EXECUCAO.md` (§7) registra.

## 7. Comandos rodados e saídas reais

```text
# independência e range
$ git merge-base --is-ancestor 301c389 HEAD && echo ancestor-ok   → ancestor-ok
$ git merge-base --is-ancestor af22ea5 HEAD && echo base-ok       → base-ok
HEAD=7abbea0 origin/main=be1e70b

# gate check do .codeflow/manifest.md (lint, test, security, nesta ordem), uma vez, na raiz da
# worktree, em 7abbea0, árvore limpa; os três blocos extraídos do manifest sem edição
== lint
lint rc=0
== test
(…cauda do setup isolado em HOME temporário…)
Resumo:
  criados:     21
  atualizados: 0
  preservados: 0
  pulados:     0

✓ Sincronização concluída. Reinicie o Codex ou abra um chat novo para recarregar as skills.
test rc=0
== security
INF 10 commits scanned.
INF scan completed in 40.6ms
INF no leaks found
security rc=0
(git status --short depois: vazio)

# specs que o gate test comparou (mesmo glob do bloco, sem rodá-lo de novo)
specs comparadas pelo gate test: 55        (test rc=0 ⇒ nenhuma linha "✗ … origin/main=… ramo=…")

# core, scripts e setup intocados
$ git diff --name-only origin/main...HEAD -- framework/core/constitution.md framework/core/glossary.md \
    framework/core/EVOLUTION.md framework/core/scripts/ install.sh 'setup-*.sh'
(vazio)
$ grep -n 'quality_gate\|threshold\|scorer\|RESSALVAS\|veredito' framework/core/scripts/run-structural.sh
(vazio, rc=1)

# legado nos consumidores (só contagem)
$ grep -h '^veredito:' ~/Projetos/*/.codeflow/specs/*/artefatos/*AVALIACAO*.md | sort | uniq -c
    412 APROVADO · 12 RESSALVAS · 4 REPROVADO · 4 valores fora do enum antigo, anteriores a esta mudança
$ ls ~/Projetos/*/.codeflow/bug-batches/*.md | wc -l   → 45 (sem a coluna reaberturas; valem 0)

# gêmeas
$ grep -rn 'pela 2ª vez\|deixado para trás\|ainda aberto\|segue aberto' framework/ .codeflow/decisions/
  → só ARTIFACTS_SPEC.md:2850 (definição) e as citações: :2951, evaluate-spec-phase.md:64,
    execute-spec-phase.md:74, TEMPLATE-AVALIACAO.md:18-19, review-change.md:55, REVISAO.md:13-14, decision:37-38
$ grep -rn 'de que depende\|deixado aberto' framework/
  → execute-spec-phase.md:14 (I-1), implement-change.md:47 (sugestão)
$ grep -rn 'mudança arquitetural\|não-trivial' framework/
  → ARTIFACTS_SPEC.md:1010 e :2261 (I-2); :166 e :1045 usam "não-trivial" em outro sentido

# commits do rework
66 4bb991f fix(veredito): uma definição da escalada e um destino dos herdados
66 301c389 fix(spec): exemplo de gera_decision auto sem o gatilho não-trivial
69 7abbea0 docs(changes): registra o rework da aceleração do ciclo (tentativa 2)
Co-Authored-By nos três; git diff af22ea5..HEAD | grep -c '^+.*/home/' → 0; decisions/INDEX.md fora do diff
```

## 8. Divergências entre o relatório e o código

- `EXECUCAO.md` §7, B-1: "uma definição só … citada por evaluate-spec-phase, execute-spec-phase,
  TEMPLATE-AVALIACAO" — confere; mas o exemplo da §2.10.5 do mesmo arquivo não acompanhou (I-1).
- `EXECUCAO.md` §7, B-2: "execute-spec-phase e evaluate-spec-phase seguem a §2.11.5" — confere nos
  passos; a abertura do `execute-spec-phase.md:14` ainda diz "das fases de que depende" (I-1).
- `EXECUCAO.md` §7, I-1: "alinhado aos gatilhos do bugfix" — confere em `SPEC.md:1333`; as gêmeas do
  `ARTIFACTS_SPEC.md` ficaram (I-2).
- Fora isso, nenhuma: o `check`, o core intocado e os arquivos declarados batem com o código.
