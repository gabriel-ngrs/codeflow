---
versão: 1.0
status: experimental
atualizado: 2026-10-02
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: verify-audit

## Quando usar
Confirmar, em **chat zerado**, os candidatos de uma auditoria: os laudos `LAUDO-*.md` de `.codeflow/audits/<AAAA-MM-DD>-<slug>/` (e, se houver, o ledger de um `/security-sweep` da mesma rodada). Cada candidato é tentado contra o código real e termina **confirmado**, **sem impacto no contexto** ou **falso positivo**; os confirmados são deduplicados entre dimensões e separados por destino no `CONSOLIDADO.md` — a entrada das trilhas de bugs e de melhorias.

## Quando NÃO usar
- No chat de um dos auditores → quebra a independência. Abra um chat novo.
- Para levantar candidatos → `/audit`. Para corrigir → as trilhas de bug e de mudança.
- Para registrar ou numerar bugs e melhorias → isso é da trilha de destino; o consolidado só entrega a lista.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/library/skills/triagem-de-achado/SKILL.md (o método — reproduzir, classificar, atribuir severidade — vale para achado de qualquer dimensão, não só de segurança)
- ~/.codeflow/framework/library/skills/debug-protocol/SKILL.md
- ~/.codeflow/framework/library/templates/audits/CONSOLIDADO.md (o molde)
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/rules/ e .codeflow/decisions/INDEX.md (a régua do projeto)

## Antes de começar
- **Independência:** se você escreveu algum dos laudos nesta sessão, parar e pedir um chat novo.
- Ler todos os laudos da pasta e listar os candidatos com a origem (`<dimensão>-<n>`). Sem laudo, nada a verificar: parar.
- Carregar as rules e as decisions ATIVAS que os laudos citam como régua.

## Protocolo

### Passo 1 — Verificar cada candidato
- Aplicar o método da skill `triagem-de-achado`: abrir o `arquivo:linha`, reconstituir a alegação, **tentar provar** — traçar o caminho no código, rodar o teste ou a ferramenta que reproduz, conferir a régua citada.
- Veredito por candidato: **confirmado** (provado), **sem impacto no contexto** (existe, mas uma barreira nomeada o neutraliza aqui) ou **falso positivo** (não se sustenta). O motivo é obrigatório nos três.
- Gate: nenhum candidato sem veredito e motivo.

### Passo 2 — Deduplicar entre dimensões
- Juntar confirmados com a mesma causa vindos de dimensões diferentes (ex.: o mesmo módulo violando a arquitetura e sem teste) num item só, com todas as origens.
- Gate: cada causa aparece uma vez.

### Passo 3 — Severidade final e destino
- Severidade final pela skill de triagem (impacto × alcance × pré-condições), com uma frase de justificativa — pode subir ou descer em relação à proposta do auditor.
- Destino: **bug** (o sistema faz algo errado ou arriscado hoje) ou **melhoria** (dívida, fragilidade, documento desatualizado). Para bug, a reprodução ou a evidência que a trilha de bugs vai reexecutar.
- Gate: todo confirmado com severidade justificada e destino.

### Passo 4 — Rodar a validação do projeto
- Rodar os comandos de validação do manifest como linha de base da rodada (o estado de partida das correções que virão). Gate ausente → `[—]` justificado. Não corrigir nada.
- Gate: linha de base registrada com saída real.

### Passo 5 — Gravar o consolidado
- Preencher `CONSOLIDADO.md` a partir do molde: placar por dimensão e a **taxa de falso positivo**, o resumo para o dono, a lista para bugs, a lista para melhorias, os descartados com motivo, a cobertura e os limites somados.
- Commitar os laudos e o consolidado — salvo quando quem invoca declarar que commita. Instruir: o dono aprova; as seções 3 e 4 vão para as trilhas de destino.

## Definition of Done
- [ ] Independência garantida; todos os laudos da pasta lidos.
- [ ] Cada candidato com veredito (confirmado, sem impacto, falso positivo) e motivo nomeado.
- [ ] Confirmados deduplicados entre dimensões, com severidade justificada e destino; bugs com reprodução ou evidência.
- [ ] Validação do projeto rodada como linha de base (ou `[—]` justificado); nenhum código alterado.
- [ ] `CONSOLIDADO.md` gravado a partir do molde, com placar, taxa de falso positivo e limites; commitado (ou entregue a quem commita).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4, com o placar e a taxa de falso positivo. Em **Próximos passos**, a aprovação do dono e as trilhas de destino.
