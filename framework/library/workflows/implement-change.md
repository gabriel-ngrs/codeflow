---
versão: 1.2
status: experimental
atualizado: 2026-10-06
granularidade: médio
gera_decision: auto
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: implement-change

## Quando usar
Executar um plano **aprovado** de melhoria ou feature (`.codeflow/changes/<slug>/PLANO.md`, `status: aprovado`), etapa por etapa, na ordem do plano: TDD, só os arquivos da etapa, o gate da etapa verde, **um commit por etapa**. Grava o relatório `EXECUCAO.md` para a revisão independente. Também opera em **modo rework**: recebida uma `REVISAO-<n>.md` com `veredito: AJUSTAR`, corrige os BLOQUEANTES dela e os IMPORTANTES com destino "corrigir agora".

## Quando NÃO usar
- Sem plano aprovado → `/plan-change`: o plano nasce `aprovado` quando o pedido é claro; senão, espera a aprovação do dono. Plano `proposto` não se executa.
- Para mudança direta (P, skill `change-sizing`) → sem plano: implementar direto, com o trailer `Tamanho: P` no commit.
- Para revisar a mudança → `/review-change`, em chat zerado.
- Para bug → `/bugfix`. Para spec → `/execute-spec-phase`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- ~/.codeflow/framework/library/skills/safe-refactor/SKILL.md (carregar quando uma etapa reestrutura código existente)
- ~/.codeflow/framework/library/skills/avoid-ai-look/SKILL.md, accessibility-audit/SKILL.md e visual-consistency/SKILL.md (carregar quando a mudança toca interface gráfica)
- ~/.codeflow/framework/library/templates/changes/EXECUCAO.md (o molde)
- .codeflow/constitution.md
- .codeflow/manifest.md — **só os comandos**, nunca o arquivo inteiro: `awk '/^## /{p=($0 ~ /^## (Comandos de validação|Gate|CI)/)} p' .codeflow/manifest.md`

## Antes de começar
- Ler o `PLANO.md` **na íntegra**. Se `status` não for `aprovado`, **parar**: nada se implementa sem aprovação — a do dono, ou a de pedido claro que o `/plan-change` registrou em `aprovado_por`.
- Modo: sem `EXECUCAO.md` → primeira execução, a partir da etapa 1. `EXECUCAO.md` com `etapas_concluidas` incompleto → retomar na primeira etapa não concluída. `REVISAO-<n>.md` com `AJUSTAR` → **rework**; se `reprovacoes >= 2`, **parar** e escalar ao dono (teto do ciclo; só `AJUSTAR` conta). `REVISAO-<n>.md` com `PENDENTE-EXTERNO` não é rework nem conta para o teto: resolvida a condição de fora, a mesma tentativa volta à revisão. Erros de registro apontados pela revisão se corrigem num commit só de documento, sem rework.
- Consultar `.codeflow/decisions/INDEX.md` e carregar as decisions ATIVAS das áreas tocadas. Trabalhar na branch atual; se for a default, confirmar antes de commitar.

## Protocolo

### Menor mudança que resolve (YAGNI)
Vale para toda etapa. Antes de escrever, ler o código que a etapa toca e listar o que ela alcança (chamadores, testes, fixtures, config, exports). Escada, parando no primeiro degrau que resolve:
1. O plano exige isto? Se não, não fazer, e citar em uma linha no relatório.
2. Já existe no repositório (helper, componente, padrão)? Reusar.
3. A biblioteca padrão ou um recurso nativo resolve? Usar.
4. Uma dependência já instalada resolve? Usar. Nunca adicionar dependência por poucas linhas.
5. Senão, o mínimo que funciona.
- Sem abstração, wrapper, opção, config ou código "para depois". Remover é melhor que adicionar; manter as camadas e convenções existentes.
- Econômico na solução, nunca na mudança: terminar os chamadores, testes e fixtures que a mudança quebrar.
- Lógica nova (ramo, laço, parser, dinheiro, segurança) leva um teste pequeno que falha se ela quebrar. Código movido ou mesclado mantém validação e tratamento de erro.
- **Nunca corte:** critério de aceite do plano, validação em fronteira (entrada externa), tratamento de erro que evita perda de dados, segurança, acessibilidade, sincronização e modo offline.
- No `EXECUCAO.md`, uma linha: o que ficou deliberadamente de fora e o risco, se houver.

### Passo 1 — Preparar
- Conferir que os caminhos ALTERADOS e REUSADOS do plano existem. Se o plano citou caminho inexistente, parar e apontar — não inventar.
- Anotar `sha_inicial` = HEAD (primeira execução) ou **reusar** o do `EXECUCAO.md` (retomada e rework).
- Gate: plano aprovado, caminhos conferidos, `sha_inicial` conhecido.

### Passo 2 — Executar cada etapa, em ordem
- Para cada etapa ainda não concluída: teste vermelho → implementação → verde, tocando **só** os arquivos da etapa (diff mínimo). Em rework, corrigir **só** os BLOQUEANTES da revisão e os IMPORTANTES com destino "corrigir agora" — IMPORTANTE deixado aberto reaparece e vira BLOQUEANTE.
- Rodar o **gate da etapa**. Falha Lógica → retentar com o erro como contexto, limite de duas tentativas (constitution); falha de Escopo ou Ambiente → parar.
- **Commitar a etapa** (Conventional Commits do projeto), adicionando só os arquivos dela, e marcar o id em `etapas_concluidas`. Não antecipar trabalho da etapa seguinte.
- Gate: cada etapa verde e commitada antes da próxima.

### Passo 3 — Validar a mudança inteira
- Rodar os comandos de validação do projeto (do manifest) que provam o conjunto — não a suíte inteira por reflexo; a validação final é do revisor (`/review-change`, Passo 2). Gate ausente → `[—]` com justificativa.
- Aplicar a skill `self-review` ao diff `sha_inicial..HEAD`, conferindo que tudo cai no escopo do plano.
- Gate: validação verde (ou `[—]` justificado) e self-review limpo.

### Passo 4 — Desvios e decisions
- Todo desvio do plano vai para o relatório, com o porquê. Desvio que muda escopo ou CA → parar e devolver ao dono, em vez de seguir.
- `gera_decision: auto`: gerar decision em `.codeflow/decisions/` nos mesmos gatilhos do `/bugfix`: default aplicado depois de incerteza do dono, ou divergência consciente de uma rule ou da constitution. O porquê das demais escolhas vai no corpo do commit da etapa.
- Gate: desvios declarados; decision gerada se aplicável.

### Passo 5 — Relatório
- Preencher `.codeflow/changes/<slug>/EXECUCAO.md` a partir do molde: etapas com commit e gate, arquivos, desvios, **saídas reais**, cada CA com evidência, dúvidas para o revisor. Em rework: `tentativa` + 1, `reprovacoes` + 1, `sha_inicial` reusado, e a seção do que mudou nesta tentativa com o `sha` de cada achado fechado.
- Commitar o relatório separado do código. Instruir: `/review-change` em **chat zerado**.

## Definition of Done
- [ ] Plano `aprovado` lido na íntegra; modo (primeira execução, retomada ou rework) definido pelo estado dos artefatos.
- [ ] Cada etapa executada em ordem, com TDD, gate verde e **um commit por etapa**; nada fora do escopo do plano.
- [ ] Comandos de validação do projeto verdes (ou `[—]` justificado); self-review aplicado ao diff inteiro.
- [ ] Desvios declarados; decision gerada se aplicável.
- [ ] `EXECUCAO.md` gravado a partir do molde, com saídas reais e evidência por CA, e commitado.

## Resumo final
Apresentar no formato do resumo final do `SPEC.md` §5.6.4, sem abrir o arquivo para isso: o título `## ✓ CONCLUÍDO: <workflow> — <escopo>` e as cinco seções, na ordem — `### O que foi feito`, `### Checklist Definition of Done`, `### Riscos e notas`, `### Próximos passos sugeridos`, `### Decisão registrada (se aplicável)`. Em **Próximos passos**, o `/review-change` em chat zerado.
