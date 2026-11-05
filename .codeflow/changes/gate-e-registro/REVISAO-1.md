---
mudanca: gate-e-registro
tentativa: 1
veredito: AJUSTAR
range_revisado: 3d09c77..0359e1e
---

# Esteira em camadas, fim de fase executável e registro mínimo — Revisão

## 1. Veredito

**AJUSTAR** — 1 BLOQUEANTE (a decision nova não segue o schema de §2.5.3/§2.5.6), 2 IMPORTANTES, 2 sugestões.
O código, os scripts e os CA estão atendidos; o rework é só de documento.

## 2. Critérios de aceite, conferidos no código

| CA | Atendido? | Evidência própria (teste rodado, arquivo:linha) |
|----|-----------|--------------------------------------------------|
| CA-1, CA-2 | sim | `ARTIFACTS_SPEC.md` §2.3.4 (regra única); bullet com §2.3.4 nos seis workflows; "Sem `## Gate`, vale…" em cada um |
| CA-3 | sim | §2.3.7 (anti-padrão de 4.000); `check-contexto.sh:101-112`; caso 4.001 → 1 no `run-testes.sh` |
| CA-4, CA-12 | sim | `run-structural.sh:69,81-85,197`; casos antiga/nova/sem-bullet/ciclo; spec real: 3 ⚠, rc 0 no ramo e em `origin/main` |
| CA-5 | sim | `SPEC_TEMPLATE.md` (bullet do critério); `create-spec.md` Fase 4, item 1 |
| CA-6, CA-7 | sim | `fim-de-fase.sh`; reproduzido à parte: vermelho no `--hook` → 2; log não gravável → 0 no `--hook` e 2 fora; `stop_hook_active` → 0 |
| CA-8, CA-9 | sim | §2.9.3, §2.9.6 regras 1 e 5, §2.10.1; `casos/registro.sh`; EXECUCAO antigo `aceleracao-do-ciclo` atende às regras relidas e `sha_final` é ancestral do HEAD |
| CA-10, CA-11 | sim | §2.9.1, §2.9.3, §2.9.7; moldes; `execute-spec-phase` Passo 2 linha 6 e Passo 7; `implement-change` Passo 5 |
| CA-13, CA-14 | sim | casos dos dois `check-*`; `check-commits.sh` sem argumento → 3; `git status --porcelain` vazio depois dos dois |
| CA-15 | sim | `SPEC.md` §2.2 e árvore; §3.5 sem workflow novo; `README.md`; frontmatter subiu em todo item versionado; gate `check` verde |

## 3. Conformidade com o plano

- As quatro etapas entregues; arquivos dentro do mapa da §4, mais `casos/pacote-da-fase.sh` e `casos/registro.sh` (desvios 2 e 3, justificados).
- Ratificados pelo Maestro e conferidos: L0 que é nome de gate fica com ⚠ (`fim-de-fase.sh:125-128`); `CLAUDE.md` só com `@AGENTS.md` (`check-contexto.sh:84-86`); merges fora (`check-commits.sh:79`).
- Retrocompatibilidade: `run-structural.sh` não lê EXECUCAO; a dele é a de spec, e o código de saída não muda (casos + laço nas specs reais). `## Gate` opcional: todo bullet novo começa com "Com `## Gate`" e o texto anterior segue para quem não a tem.
- Core intocado (`git diff --name-only` vazio). O `glossary.md` com o trio de sha é sabido e fica fora (despacho, item 5).

## 4. Achados BLOQUEANTES

- **B-1** — `.codeflow/decisions/2026-11-05-gate-e-registro.md:25,51` — a decision tem `## Consequências` no lugar de `## Próximos passos sugeridos`, e nenhuma das quatro decisões traz `**Por quê:**` nem `**Alternativa rejeitada:**` — régua: `ARTIFACTS_SPEC.md` §2.5.3 e §2.5.6, regras 8 e 9 — correção: renomear a seção para `## Próximos passos sugeridos` (ex.: migrar as specs ativas para o critério com comando; virar o ⚠ em erro; atualizar o `glossary.md` por proposta própria) e dar a cada `### N.` o `**Por quê:**` e a `**Alternativa rejeitada:**` (as do §7 do plano servem: 3 → "sair 2 também no erro de execução"; 4 → "conferir `--no-verify` por heurística de mensagem").

## 5. Achados IMPORTANTES

- **I-1** — `framework/library/workflows/execute-spec-phase.md:121` — `fase-ativa` só se apaga "feito o relatório"; a fase que para em `PARADO` (ou falha de Ambiente) antes do Passo 7 deixa o arquivo, e com o Stop hook ligado toda sessão seguinte no projeto roda o critério ao parar e volta uma vez — destino: corrigir agora (um bullet: apagar `fase-ativa` também ao parar; o mesmo no `implement-change` Passo 3).
- **I-2** — `framework/core/SPEC.md:904` — a descrição do EXECUCAO ainda diz frontmatter com "`range` de commits"; o contrato agora pede `base` (ou o trio antigo) — destino: corrigir agora.

## 6. Sugestões

- Não há validador de EXECUCAO em script; a retrocompatibilidade do trio de sha se prova por leitura (feita aqui), não por caso de teste. Um caso fica para quando houver o validador.
- `templates/hooks/README.md:21` e `fim-de-fase.sh:14` citam a ferramenta pelo nome (§3.10, regra 37); aceitável, porque o molde é o `.claude/settings.json` dela.

## 7. Erros de registro

- `EXECUCAO.md` §3 conta 34 arquivos e 1269 inserções: o `--stat` foi tirado antes do commit do próprio relatório (são 35 com ele). Não muda o veredito.

## 8. Comandos rodados e saídas reais

```text
$ gate check (blocos lint, test, security do manifest, nesta ordem; log em .codeflow/checkpoints/revisao-check.log)
✓ 7 commit(s) de 3d09c77..HEAD conferidos
✓ ## Comandos de validação: 3206 de 4000 caracteres
✓ contexto fixo dentro dos tetos
exit lint=0
  ✓ mesmo código de saída de origin/main: ciclo-prosa
  ✓ sem argumento sai 3
✓ 121 verificações verdes
exit test=0
INF 7 commits scanned.  INF no leaks found
exit security=0
$ run-structural.sh numa spec real antiga: origin/main rc=0; ramo: 3 ⚠ + "✓ §5 estruturalmente válida", rc=0
$ fim-de-fase.sh --hook: vermelho rc=2; checkpoints sem escrita rc=0 (fora do hook rc=2); stop_hook_active rc=0
$ check-commits.sh origin/main rc=0; check-contexto.sh rc=0; check-commits.sh sem argumento rc=3
$ git status --porcelain → vazio; core (constitution, glossary, EVOLUTION) → diff vazio
$ sha256 dos arquivos críticos = validation_hash do manifest (49800c81…); 16 workflows, 17 skills, 5 meta-skills, 6 pastas de moldes
```

## 9. Divergências entre o relatório e o código

- Nenhuma no código. O relatório não cita a forma da decision, que é o B-1.
