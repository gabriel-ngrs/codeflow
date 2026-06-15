---
versão: 1.6
status: experimental
atualizado: 2026-06-15
granularidade: magro
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: spec-status

## Quando usar
Mostrar o progresso de uma spec gerada por `/create-spec`: quais fases estão pendentes, aguardando avaliação, reprovadas ou concluídas, e qual é o próximo passo. Read-only — **não modifica nada**; lê os artefatos na branch atual. Não executa nem avalia.

## Quando NÃO usar
- Para executar a próxima fase → use `/execute-spec-phase`.
- Para avaliar uma fase → use `/evaluate-spec-phase`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/ARTIFACTS_SPEC.md (§2.8.6 gate estrutural; §2.11 máquina de estados da fase)
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md

## Protocolo

### Passo 1 — Carregar a spec e os artefatos
**Trabalhar na branch atual** (o pipeline não troca de branch — os artefatos vivem na branch onde a spec foi criada e executada). Localizar `.codeflow/specs/<slug>/SPEC_<NAME>.md`; se não existir nesta branch, **abortar** avisando que a spec não foi encontrada aqui (pode estar em outra branch — confirme em qual branch o trabalho da spec vive), para não produzir uma tabela silenciosamente errada. Se faltar `## 5. Plano de desenvolvimento por fases`, **abortar** (spec sem plano de fases — nada a reportar). **Gate estrutural da §5 (determinístico, antes de classificar fases):** rodar `bash ~/.codeflow/framework/core/scripts/run-structural.sh .codeflow/specs/<slug>/SPEC_<NAME>.md` (read-only); exit `1` (§5 malformada, ARTIFACTS_SPEC §2.8.6) → **abortar**, colar a saída e indicar correção por `/create-spec`; exit `2`/`3` → parar. Extrair as fases de §5 (com `id` e `Depende de`). Ler o frontmatter de cada `FASE-*-EXECUCAO.md` (`fase`, `tentativa`, `reprovacoes`) e `FASE-*-AVALIACAO.md` (`fase`, `tentativa`, `veredito`, `score`), casando os dois pelo `id`. Read-only: não modificar arquivos.

### Passo 2 — Classificar cada fase e reportar
Para cada fase de §5, derivar **um único** estado (**pendente** / **aguardando avaliação** / **reprovada** / **concluída**) conforme a definição canônica de **ARTIFACTS_SPEC §2.11** (máquina de estados da fase): pareamento EXECUCAO↔AVALIACAO pela `tentativa` e elegibilidade por deps concluídas (`id`). Não redefinir os estados aqui; só `APROVADO` conclui, `RESSALVAS`/`REPROVADO` mantêm a fase em **reprovada** (rework). A coluna `Reprovações` reflete o campo `reprovacoes` do EXECUCAO (conta vereditos não-APROVADO; §2.9.3). Apresentar a tabela `Fase (id) | Estado | Tentativa | Reprovações | Score | Próximo passo` e o próximo comando: reprovada → `/execute-spec-phase`; aguardando → `/evaluate-spec-phase`; 1ª pendente com dependências (ids) concluídas → `/execute-spec-phase`; pendente bloqueada → indicar o `id` faltante; todas concluídas → "spec concluída".

## Definition of Done
- [ ] Na branch atual; spec localizada, `run-structural.sh` retornou `0` (gate da §5) e fases de §5 extraídas (ou abortado se a spec não está nesta branch, ou §5 ausente/malformada).
- [ ] Cada fase classificada pelo frontmatter dos artefatos (não por prosa, conforme §2.11), pareando EXECUCAO/AVALIACAO pela `tentativa`.
- [ ] Tabela de progresso + próximo passo apresentados; nada modificado.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
