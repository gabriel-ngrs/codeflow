---
mudanca: gate-e-registro
status: executado
tentativa: 1
reprovacoes: 0
etapas_concluidas: [1, 2, 3, 4]
base: origin/main
---

# Esteira em camadas, fim de fase executável e registro mínimo — Relatório de execução

## 1. Resumo

`## Gate` (L0/L1/L2) opcional no manifest, com quem roda cada camada em `ARTIFACTS_SPEC.md` §2.3.4; critério de
fase com comando, aviso no `run-structural.sh` (código de saída mantido) e `fim-de-fase.sh` com modo Stop hook;
`base` no lugar dos sha, relatório no último commit, teto de 60 linhas; `check-commits.sh` e `check-contexto.sh`;
`run-testes.sh` com 121 verificações, chamado pelo gate `test`. Antes da Etapa 1, merge de `origin/main` (a651ed4).

## 2. Etapas

| Etapa | Commit | Gate | Resultado |
|-------|--------|------|-----------|
| 1 — Esteira em camadas | `ce34b18` | `lint` | verde |
| 2 — Fim de fase executável | `c9df0fe` | `lint`, `test` | verde |
| 3 — Registro mínimo | `6635438` | `lint` | verde |
| 4 — Checagens e catálogo | `f65ded8` | `check` (lint, test, security) | verde |

## 3. Arquivos (`git diff --stat <merge-base>..HEAD`)

34 arquivos, 1269 inserções, 109 remoções: os do mapa da §4 do plano, mais `scripts/testes/casos/pacote-da-fase.sh`
e `casos/registro.sh` (desvios 2 e 3). Saída inteira em `.codeflow/checkpoints/gate-check-20261105.log`.

## 4. Desvios do plano

1. Merge de `origin/main` por ordem do orquestrador: as versões de partida eram `SPEC.md` 3.6 e `ARTIFACTS_SPEC.md`
   2.6, então os bumps foram para 3.7 e 2.7 (o plano previa 3.5 e 2.6).
2. Herdado do complemento: casos do `pacote-da-fase.sh` (cerca simples, aninhada de 4 crases e de 4 tis, cerca sem
   fecho → 1, laço nas specs reais) em `casos/pacote-da-fase.sh`; e, no manifest, a linha do contrato e a contagem da
   estrutura (17 skills, seis pastas de moldes).
3. Etapa 3 ganhou `casos/registro.sh`: o intervalo pela `base` traz só os commits e arquivos da tarefa, com merge do
   main no meio (o plano pedia o teste num repo temporário, sem dizer onde mora).
4. `fim-de-fase.sh`: L0 que é só o nome de um gate do manifest (`lint`, `check`...) fica com aviso, sem rodar; o L0
   deste repositório é o bloco `lint`.
5. `check-contexto.sh`: `CLAUDE.md` que só importa `@AGENTS.md` (molde de `templates/projeto/` vindo do main) passa,
   e o `AGENTS.md` importado também tem o teto de 8.000; igualdade literal segue aceita.
6. `check-commits.sh`: commits de merge ficam fora (assunto do git ou da plataforma); `--ramo` opcional.

## 5. Comandos rodados e saídas reais

```text
lint: ✓ 6 commit(s) de 3d09c77..HEAD conferidos; ✓ ## Comandos de validação: 3206 de 4000; exit lint=0
test: ✓ 121 verificações verdes; regressão do run-structural.sh sem ✗ nas specs reais; exit test=0
security: INF 6 commits scanned. INF no leaks found; exit security=0
run-structural.sh numa spec real antiga: 3 ⚠, "✓ §5 estruturalmente válida", rc=0 no ramo e em origin/main
core: git diff --name-only origin/main...HEAD -- constitution glossary EVOLUTION → vazio
git status --porcelain depois de check-commits.sh origin/main e check-contexto.sh → vazio
```

## 6. Critérios de aceite

| CA | Atendido? | Evidência |
|----|-----------|-----------|
| CA-1, CA-2 | sim | `ARTIFACTS_SPEC.md` §2.3.4–§2.3.6; um bullet com §2.3.4 em cada um dos seis workflows |
| CA-3 | sim | §2.3.7 (anti-padrão) e `casos/check-contexto.sh` (4.001 → 1) |
| CA-4, CA-12 | sim | `casos/run-structural.sh` (antiga → 0 e 3 ⚠; ciclo → 1; mesmo rc de origin/main) e o laço do `test` |
| CA-5 | sim | `SPEC_TEMPLATE.md:103`; `create-spec.md` Fase 4, item 1 |
| CA-6, CA-7 | sim | `casos/fim-de-fase.sh` (0/1/2/3, `--hook` 2 com o log no stderr, `stop_hook_active` → 0, ilegível → 0 no hook) |
| CA-8, CA-9 | sim | §2.9.3, §2.9.6 regras 1 e 5, §2.10.1, §2.10.3; `casos/registro.sh` |
| CA-10, CA-11 | sim | §2.9.1, §2.9.3, §2.9.7; moldes; `execute-spec-phase` Passo 2 (linha 6) e Passo 7; `implement-change` Passo 5 |
| CA-13, CA-14 | sim | `casos/check-commits.sh` e `casos/check-contexto.sh` (incluindo "o script não escreve") |
| CA-15 | sim | `SPEC.md` §2.2, §3.5 conferida, `README.md`, frontmatter; gate `check` verde |

## 7. No rework: o que mudou nesta tentativa

- não se aplica (primeira execução).

## 8. Dúvidas para o revisor

- O `glossary.md` (core) define o relatório de execução com `sha_inicial`, `sha_final` e `range`; com `base`, a
  definição fica incompleta. Não foi tocado (core): é pendência do dono.
- O laço do `pacote-da-fase.sh` e o do `run-structural.sh` leem as specs de `~/Projetos/*`: só repetem nesta máquina.
- Os `.md` dos quatro workflows partilhados com `contexto-e-papeis` receberam bullets e trocas de frase nos passos
  citados; o Passo 2 do `evaluate-spec-phase` foi reescrito em três bullets (o do range virou o da `base`).
