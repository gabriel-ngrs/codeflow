---
versão: 1.1
status: experimental
atualizado: 2026-10-05
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: plan-change

## Quando usar
Planejar uma **melhoria** (mudar, ajustar ou melhorar o que já existe) ou uma **feature** (capacidade nova), **pequena ou média**, antes de qualquer código. Classifica o pedido com a skill `change-sizing`, sonda o código real e escreve `.codeflow/changes/<slug>/PLANO.md` com critérios de aceite e etapas, a partir do molde. O plano nasce `status: aprovado` quando o **pedido é claro** (Passo 5); senão sai `status: proposto` e só vira trabalho depois que o dono o aprova. É o primeiro dos três workflows do ciclo de mudança (`/plan-change` → `/implement-change` → `/review-change`).

## Quando NÃO usar
- Para mudança **grande** (G: fases, fronteira quebrada, migração destrutiva, ADR nova) → `/create-spec`, ou a trilha de spec do projeto. Este workflow detecta e para.
- Para mudança **direta** (P: o diff cabe numa frase, uma área, nenhum sinal de risco — skill `change-sizing`) → sem plano: implementar direto, com o teste do que mudou, o check verde, `self-review` e o trailer `Tamanho: P` no commit. Este workflow detecta e para.
- Para **bug** (o sistema faz algo diferente do prometido) → `/bugfix`.
- Para mudança de **regra de negócio** sem decisão do dono → registrar e decidir antes; não é código ainda.
- Para executar um plano já aprovado → `/implement-change`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/library/skills/change-sizing/SKILL.md
- ~/.codeflow/framework/library/templates/changes/PLANO.md (o molde — copiar, não parafrasear)
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md (os comandos de validação que viram os gates das etapas)
- .codeflow/rules/ (as aplicáveis à área tocada)

## Antes de começar
- Identificar o pedido: o texto do dono ou o registro do projeto (ex.: `.codeflow/melhorias/NNN-*.md`), e o `<slug>` da mudança, em kebab-case. Se `.codeflow/changes/<slug>/` já existir, **parar** e avisar — não sobrescrever plano.
- Consultar `.codeflow/decisions/INDEX.md` e carregar as decisions ATIVAS cujas tags cruzem a área da mudança.
- Trabalhar na branch atual; se ela for a default (`main`/`master`), avisar e pedir confirmação antes de commitar.

## Protocolo

### Passo 1 — Classificar o pedido
- Aplicar a skill `change-sizing`: é deste ciclo? Qual o tipo (melhoria ou feature)? Qual o tamanho, sinal por sinal, com evidência?
- **Grande (G)** → parar no formato PARADO da constitution, com a classificação e a recomendação de ir para spec. **Direta (P)** → parar sem escrever plano, com a classificação e o destino direto. **Bug, regra de negócio ou configuração** → parar com a trilha certa.
- Gate: tipo e tamanho definidos (M: pequena ou média), cada sinal com evidência.

### Passo 2 — Sondar o código real
- Mapear onde a mudança encosta: seams, precedentes, convenções, testes existentes. Montar o mapa NOVO / ALTERADO / REUSADO.
- **Guard:** todo caminho ALTERADO ou REUSADO **existe** no repositório — conferir, não inventar. Preferir reusar a duplicar (rule `code-quality`).
- Gate: mapa do código montado; nenhum caminho citado inexistente.

### Passo 3 — Escrever critérios e etapas
- Copiar o molde `PLANO.md` para `.codeflow/changes/<slug>/PLANO.md` e preencher.
- Critérios de aceite em Dado/Quando/Então, testáveis, cobrindo as bordas que as rules do projeto exigem.
- **Pequena: uma etapa. Média: duas a quatro**, na ordem de execução. Cada etapa: o que faz a nível de arquivo, os testes que nascem vermelhos, os CA que cobre e o **gate** — um comando real do manifest. Nenhuma etapa depende de etapa posterior.
- Gate: todas as seções do molde preenchidas.

### Passo 4 — Conferir o plano contra si mesmo
- Todo CA é coberto por pelo menos uma etapa; todo gate é um comando que existe no projeto; todo caminho existe; o fora-de-escopo está escrito.
- Se a conferência mostrar que a mudança não cabe em quatro etapas, ou tocou fronteira de forma não compatível, **reclassificar** (Passo 1) — provavelmente é grande.
- Gate: conferência limpa, ou reclassificação feita.

### Passo 5 — Definir a aprovação e commitar
- **Pedido claro** — o pedido do dono diz o quê e o porquê, e o plano não deixou decisão para ele: nenhuma Open Question, nenhuma regra de negócio, nenhuma escolha de escopo entre alternativas, nenhuma reclassificação no Passo 4. Pedido claro → o plano nasce `status: aprovado`, com `aprovado_por: pedido claro do dono`, `aprovado_em` = data de hoje e a origem do pedido em `registro`. Senão → `status: proposto`, e as decisões abertas vão listadas no resumo para o dono.
- Commitar só o plano (Conventional Commits do projeto). Não escrever código de produção.
- Apresentar o resumo final com o plano em poucas linhas e instruir: `aprovado` → `/implement-change`; `proposto` → **o dono aprova** (o `status` vira `aprovado`, com `aprovado_por` e `aprovado_em`), depois `/implement-change`.

## Definition of Done
- [ ] Pedido classificado pela `change-sizing`, com evidência por sinal; direta (P), grande (G), bug e regra parados com o destino certo.
- [ ] Mapa do código montado; todo caminho citado existe.
- [ ] `PLANO.md` preenchido a partir do molde: CA testáveis; uma etapa (pequena) ou duas a quatro (média), cada uma com testes e gate real.
- [ ] Plano conferido contra si mesmo (CA cobertos, gates reais, fora-de-escopo escrito).
- [ ] Plano commitado com `status: aprovado` (pedido claro) ou `status: proposto` (decisão aberta para o dono); nenhum código de produção alterado.

## Resumo final
Apresentar no formato do resumo final do `SPEC.md` §5.6.4, sem abrir o arquivo para isso: o título `## ✓ CONCLUÍDO: <workflow> — <escopo>` e as cinco seções, na ordem — `### O que foi feito`, `### Checklist Definition of Done`, `### Riscos e notas`, `### Próximos passos sugeridos`, `### Decisão registrada (se aplicável)`. Em **Próximos passos**, o `/implement-change` — antes dele, a aprovação do dono quando o plano saiu `proposto`.
