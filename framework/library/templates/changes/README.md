# Templates do ciclo de mudança

> Moldes preenchíveis para o ciclo de mudança do codeflow — melhorias e features **pequenas e
> médias**. Os workflows `/plan-change`, `/implement-change` e `/review-change` **copiam o molde e
> preenchem** em vez de gerar o formato do zero. Mudança grande não passa por aqui: vira spec.

## Moldes

| Molde | Vira | Gerado por |
|-------|------|------------|
| `PLANO.md` | `.codeflow/changes/<slug>/PLANO.md` | `/plan-change` |
| `EXECUCAO.md` | `.codeflow/changes/<slug>/EXECUCAO.md` | `/implement-change` |
| `REVISAO.md` | `.codeflow/changes/<slug>/REVISAO-<tentativa>.md` | `/review-change` |

O `<slug>` é kebab-case e vem de quem invoca — o registro do projeto, quando houver (ex.:
`melhoria-016-sobras-da-spec-017`).

## Fluxo (planejador → dono → implementador → revisor independente)

1. **`/plan-change`** classifica o pedido (skill `change-sizing`), sonda o código e escreve o
   `PLANO.md` com `status: proposto`. Mudança grande para aqui e vai para spec.
2. **O dono aprova o plano.** O `status` vira `aprovado`, com quem e quando.
3. **`/implement-change`** executa as etapas do plano em ordem — TDD, um commit por etapa, o gate
   de cada etapa verde — e grava o `EXECUCAO.md`.
4. **`/review-change`**, num **chat zerado**, confere contra o código real, roda a validação do
   projeto e grava a `REVISAO-<tentativa>.md`: `APROVADO` (zero BLOQUEANTE), `AJUSTAR` ou
   `PENDENTE-EXTERNO` (a verificação depende de algo fora da mudança: revisar de novo a mesma
   tentativa depois, sem rework e sem contar para o teto).
5. **`AJUSTAR`** → os BLOQUEANTES voltam ao implementador (rework) → nova revisão em chat zerado.
   Teto: duas reprovações; na terceira, o dono decide.

> O relatório de execução é **declaração, não prova**. Quem gerencia a branch é quem invoca: o ciclo
> trabalha na branch atual e não troca de branch.
