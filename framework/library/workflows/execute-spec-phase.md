---
versão: 1.2
status: estável
atualizado: 2026-06-14
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: execute-spec-phase

## Quando usar
Executar a **próxima fase pendente** de uma spec gerada por `/create-spec` (em `.codeflow/specs/<slug>/SPEC_<NAME>.md`), deixando-a **pronta para avaliação** por `/evaluate-spec-phase`. Uma fase por execução: lê a spec e os documentos referenciados, executa só a fase da vez, **commita** o trabalho e grava o relatório `FASE-<N>-<slug>-EXECUCAO.md` (com frontmatter machine-readable e range de commits). Também opera em **modo rework**: ao receber uma avaliação REPROVADA/COM RESSALVAS, corrige a mesma fase. Pré-requisito: a spec tem `## 5. Plano de desenvolvimento por fases`.

## Quando NÃO usar
- Para criar a spec → use `/create-spec`.
- Para avaliar a fase executada → use `/evaluate-spec-phase` (em chat zerado).
- Para executar várias fases de uma vez → **uma fase por execução**; rode de novo após a fase atual ser APROVADA.
- Para spec sem plano de fases (`§5`) → não há o que executar em fatias.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (carregar decisions ATIVAS cujas tags cruzem o domínio da fase)

## Antes de começar
Identificar a spec que o usuário pediu (por caminho ou slug em `.codeflow/specs/`). Se o usuário colou uma avaliação (`FASE-N-*-AVALIACAO.md` com `veredito: REPROVADO` ou `RESSALVAS`), o alvo é o **rework** dessa fase. Se a fase tocar áreas com decisions arquivadas, carregar as decisions ATIVAS por tag antes de implementar.

## Protocolo

### Passo 1 — Carregar a spec e o contexto
- Localizar `.codeflow/specs/<slug>/SPEC_<NAME>.md` e lê-lo **na íntegra** — atenção a §4 (abordagem), §5 (plano de fases) e ao escopo travado / violações bloqueantes de cada fase.
- Ler os documentos referenciados (`linked_adr`, rules, decisions ativas, `.codeflow/manifest.md`) e inspecionar os seams de código citados em §4. **Não escrever nada ainda.**
- Gate: spec encontrada e §5 interpretada como lista ordenada de fases.

### Passo 2 — Determinar a fase-alvo (estado por frontmatter, não por prosa)
- Para cada fase de §5, ler o **frontmatter** dos artefatos em `artefatos/` (campos `fase:`, `status:`, `tentativa:` no EXECUCAO; `fase:`, `veredito:` no AVALIACAO) — nunca inferir estado de texto livre. Classificar: **pendente** (sem EXECUCAO para aquela `fase:`); **aguardando avaliação** (tem EXECUCAO da tentativa atual sem AVALIACAO correspondente); **reprovada** (AVALIACAO com `veredito: REPROVADO` ou `veredito: RESSALVAS`); **concluída** (`veredito: APROVADO`).
- Selecionar o alvo nesta ordem: (1) avaliação reprovada colada pelo usuário → **rework** dessa fase; (2) primeira fase **reprovada** → rework; (3) última fase **aguardando avaliação** → **parar** e pedir `/evaluate-spec-phase` antes de avançar; (4) primeira fase **pendente** → nova execução; (5) todas concluídas → **parar** (spec concluída).
- **Teto de rework:** se a fase-alvo já acumulou **3 tentativas** reprovadas (`tentativa` no EXECUCAO), **parar** e escalar ao owner com o resumo dos achados recorrentes — não tentar uma 4ª vez sozinho.
- Gate: um único alvo definido (rework ou nova execução), ou parada limpa/escalonamento.

### Passo 3 — Preparar e marcar o início
- Reler o bloco da fase-alvo em §5. Em rework, ler também os achados BLOQUEANTES/IMPORTANTES da AVALIACAO. Confirmar que os **caminhos de "Arquivos alterados" existem** no repo (se a spec citou caminho inexistente, parar e apontar — não inventar).
- Conferir dependências (fases anteriores concluídas); se faltar, **parar** e relatar. Criar `artefatos/` se não existir.
- **Branch de trabalho:** se a branch atual for a default/`main`, criar/trocar para a branch de trabalho da spec (`spec/<slug>`, ou a indicada em `.codeflow/manifest.md`). Nunca commitar na default/`main`.
- **SHA inicial:** em **nova execução**, anotar o HEAD atual como `sha_inicial` (início ORIGINAL da fase). Em **rework**, **reusar** o `sha_inicial` do EXECUCAO existente (não redefinir).
- Gate: pré-requisitos satisfeitos, branch de trabalho ativa, `artefatos/` existe, `sha_inicial` conhecido.

### Passo 4 — Executar a fase (TDD, escopo fechado)
- Nova execução: implementar **somente** os passos da fase-alvo, tocando apenas os arquivos que ela declara (diff mínimo). Rework: corrigir **apenas** os achados da avaliação, sem ampliar escopo.
- Seguir TDD: teste vermelho → implementação → verde, conforme a subseção "Testes" da fase. Respeitar o escopo travado declarado na fase.
- **Não** iniciar nenhuma fase posterior nem antecipar trabalho dela.
- Gate: passos implementados (ou achados corrigidos); testes da fase passam.

### Passo 5 — Validar
- Executar `make check` (ou os alvos equivalentes de `.codeflow/manifest.md`) e aplicar `self-review` no diff.
- Se `make check` falhar: aplicar a política de falhas da constitution.
- Gate: `make check` retornou zero e self-review limpo.

### Passo 6 — Commitar a fase
- Commitar o trabalho na branch de trabalho (Conventional Commits em pt-BR; um ou mais commits lógicos). Não commitar na default/`main`.
- Anotar o `sha_final` = HEAD atual. O **range canônico da fase é sempre `sha_inicial..sha_final`** (início original → HEAD), de modo que em rework o avaliador veja a fase inteira, não só os commits de conserto.
- Gate: trabalho commitado; `range` conhecido.

### Passo 7 — Gerar o relatório pronto para avaliação
- Escrever (ou, em rework, atualizar incrementando `tentativa`) `.codeflow/specs/<slug>/artefatos/FASE-<N>-<slug-da-fase>-EXECUCAO.md` com este **frontmatter machine-readable** seguido do corpo:

  ```markdown
  ---
  spec: <slug>
  fase: <N>
  slug_fase: <slug-da-fase>
  status: executado            # executado | rework
  tentativa: <n>
  sha_inicial: <sha>           # início ORIGINAL da fase
  sha_final: <sha>
  range: <sha_inicial>..<sha_final>
  ---
  ```
  Corpo: resumo do que foi feito; tabela de arquivos CRIADOS/ALTERADOS (caminho + propósito); confirmação do REUSO; decisões de design e **qualquer desvio** da spec/rules com justificativa; comandos rodados + **saídas reais** (linters/test/`make check`); checklist dos ACs/critério de conclusão, cada item **com evidência**; (em rework) o que mudou nesta tentativa; dúvidas para o avaliador.
- **Commitar o relatório** (`.codeflow/specs/` é versionado): commit separado do de código.
- Ser **honesto** sobre o que não ficou pronto — será conferido contra o código real por um revisor independente. As decisões da fase ficam registradas **neste relatório**, não em artefato paralelo.
- Apresentar o resumo final e instruir: avaliar a fase com `/evaluate-spec-phase` em **chat zerado**.

## Definition of Done
- [ ] Spec lida na íntegra (incl. escopo travado) e documentos referenciados carregados (Passo 1).
- [ ] Fase-alvo determinada por frontmatter; teto de rework respeitado (Passo 2).
- [ ] Dependências e caminhos verificados; branch de trabalho ativa; `sha_inicial` anotado (Passo 3).
- [ ] Apenas a fase-alvo executada/corrigida, dentro do escopo; nenhuma fase posterior tocada (Passo 4).
- [ ] Testes da fase passam; `make check` retornou zero; self-review aplicado (Passo 5).
- [ ] Trabalho commitado na branch de trabalho; `range = sha_inicial..sha_final` (Passo 6).
- [ ] Relatório `FASE-<N>-<slug>-EXECUCAO.md` gravado com frontmatter machine-readable e commitado (Passo 7).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
