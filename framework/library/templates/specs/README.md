# Templates do pipeline de spec

> Moldes preenchíveis para o pipeline de spec do codeflow. O `install.sh` copia
> esta pasta para `<projeto>/.codeflow/specs/_TEMPLATES/`. Os workflows
> `/create-spec`, `/execute-spec-phase` e `/evaluate-spec-phase` **copiam o
> molde e preenchem** em vez de gerar o formato do zero — isso evita alucinação
> de estrutura.

Os contratos normativos (schema, campos obrigatórios, regras de validação) vivem
em `~/.codeflow/framework/core/ARTIFACTS_SPEC.md` §2.8–§2.11. Estes templates são
a **materialização preenchível** desses schemas; em caso de divergência, o
`ARTIFACTS_SPEC.md` vence.

## Moldes

| Molde | Vira | Gerado por |
|-------|------|------------|
| `SPEC_TEMPLATE.md` | `specs/<slug>/SPEC_<NAME>.md` | `/create-spec` |
| `TEMPLATE-EXECUCAO.md` | `specs/<slug>/artefatos/FASE-<id>-<slug>-EXECUCAO.md` | `/execute-spec-phase` |
| `TEMPLATE-AVALIACAO.md` | `specs/<slug>/artefatos/FASE-<id>-<slug>-AVALIACAO.md` | `/evaluate-spec-phase` |

## Fluxo (executor → avaliador independente)

1. **`/create-spec`** sonda o repositório e produz a spec (`SPEC_<NAME>.md`) com o
   plano de desenvolvimento por fases (§5). Trabalha **na branch em que você já
   está** — o pipeline não cria nem troca de branch.
2. **`/execute-spec-phase`** executa **uma fase por vez** (a próxima pendente —
   sem nenhum artefato, é a Fase 1), valida com os **comandos de validação do
   projeto** (do `manifest.md`, não um `make check` presumido), commita e grava o
   relatório `FASE-…-EXECUCAO.md`.
3. **`/evaluate-spec-phase`**, num **chat zerado e separado**, lê o relatório como
   ponto de partida mas **verifica contra o código real**, roda as verificações e
   emite um veredito (`APROVADO` / `RESSALVAS` / `REPROVADO`).
4. **`RESSALVAS`/`REPROVADO`** → achados voltam ao executor → corrige → reavalia.
   **`APROVADO`** → próxima fase.

> O relatório é **declaração, não prova**. O avaliador não confia nele — confere
> contra o código. Tudo acontece na branch atual; quem gerencia a branch é você.
