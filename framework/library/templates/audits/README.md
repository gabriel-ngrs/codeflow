# Templates da auditoria

> Moldes para a auditoria de repositório do codeflow. O `/audit` produz um **laudo por dimensão**
> (só candidatos); o `/verify-audit`, em chat zerado, confirma e produz o **consolidado**, que é a
> entrada das trilhas de bugs e de melhorias. A auditoria **não corrige nada** e **não registra nem
> numera** bug ou melhoria — isso é da trilha de destino.

## Moldes

| Molde | Vira | Gerado por |
|-------|------|------------|
| `LAUDO.md` | `.codeflow/audits/<AAAA-MM-DD>-<slug>/LAUDO-<dimensão>.md` | `/audit` |
| `CONSOLIDADO.md` | `.codeflow/audits/<AAAA-MM-DD>-<slug>/CONSOLIDADO.md` | `/verify-audit` |

## Dimensões

| Dimensão | Skill do auditor |
|----------|------------------|
| `code-quality` | `audit-code-quality` |
| `architecture` | `audit-architecture` |
| `tests` | `audit-tests` |
| `data-privacy` | `audit-data-privacy` |
| `living-docs` | `audit-living-docs` |
| `dependencies` | `audit-dependencies` |
| `interface` | `audit-interface` (só em projeto com interface gráfica) |
| segurança | **não é dimensão do `/audit`**: é o `/security-sweep`, que já faz a própria triagem |

## Fluxo

1. Um `/audit <dimensão>` por dimensão — podem rodar em paralelo, cada um num chat próprio.
2. `/verify-audit` sobre a pasta da auditoria, em chat zerado: confirma, deduplica, separa por destino.
3. O dono aprova o consolidado; as seções 3 e 4 vão para as trilhas de bugs e de melhorias.
