---
versão: 1.0
status: experimental
atualizado: 2026-10-02
granularidade: médio
gera_decision: no
usa_checkpoints: no
politica_falhas: padrão
---

# Workflow: audit

## Quando usar
Auditar o repositório (ou um alvo dentro dele) em **uma dimensão**: `code-quality`, `architecture`, `tests`, `data-privacy`, `living-docs`, `dependencies` ou `interface`. Um auditor, uma dimensão, um laudo — várias dimensões rodam em paralelo, cada uma num chat próprio. O auditor **só levanta candidatos**, com régua e evidência, em `.codeflow/audits/<AAAA-MM-DD>-<slug>/LAUDO-<dimensão>.md`; quem confirma é o `/verify-audit`, em chat zerado. Argumentos: a dimensão, o alvo e o `<slug>` da auditoria.

## Quando NÃO usar
- Para **segurança** → `/security-sweep`, que já mapeia, caça e faz a própria triagem.
- Para **corrigir** o que se achou → as trilhas de bug e de mudança (`/bugfix`, `/batch-bugfix`, `/plan-change`). Este workflow não altera código.
- Para revisar um diff ou PR específico → `/review-change` ou a revisão do pipeline de spec.
- Para confirmar candidatos → `/verify-audit`.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/library/skills/audit-<dimensão>/SKILL.md (a skill da dimensão auditada — só ela)
- ~/.codeflow/framework/library/skills/accessibility-audit/SKILL.md e visual-consistency/SKILL.md (carregar só na dimensão `interface`)
- ~/.codeflow/framework/library/templates/audits/LAUDO.md (o molde)
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/rules/ e .codeflow/decisions/INDEX.md (a régua do projeto)

## Antes de começar
- Data canônica: `date +%F` via Bash; não inferir de memória. Pasta da auditoria: `.codeflow/audits/<AAAA-MM-DD>-<slug>/`.
- Carregar as decisions ATIVAS cujas tags cruzem a dimensão. **A régua do projeto vence a genérica**: a skill diz o que procurar; as rules e ADRs do projeto dizem o que é errado aqui.
- O auditor trabalha em **somente leitura** sobre o código. Saída bruta de ferramenta vai para um diretório temporário **fora** do repositório e é apagada no fim.

## Protocolo

### Passo 1 — Fixar alvo e régua
- Delimitar o alvo em uma frase (o repositório inteiro, ou os caminhos indicados) e o que fica de fora.
- Listar a régua: as rules universais e do projeto, as ADRs e os documentos que valem para a dimensão. **Achado sem régua não entra** — opinião não é achado.
- Gate: alvo e régua escritos no laudo.

### Passo 2 — Mapear a cobertura
- Inventariar as áreas do alvo relevantes para a dimensão (módulos, camadas, pacotes, documentos) numa tabela de cobertura. Toda área começa `não verificado`.
- Gate: tabela de cobertura montada.

### Passo 3 — Caçar
- **Ferramentas determinísticas primeiro**, as que o projeto já tem ou a skill indica para o stack, só de leitura. Registrar comando e resultado resumido.
- Depois, **leitura dirigida** pelo checklist da skill, área por área, marcando a cobertura.
- Cada candidato: `arquivo:linha`, o problema em uma frase, a régua violada, a evidência (trecho, saída, contagem), severidade proposta (crítica, alta, média, baixa) e destino proposto (bug, se o sistema faz algo errado ou arriscado hoje; melhoria, se é dívida ou fragilidade).
- Gate: toda área do alvo `verificado` ou com motivo de não ter sido.

### Passo 4 — Conferir o próprio laudo
- Reler cada candidato contra o código: o caminho existe, a linha é aquela, a régua é a certa. Juntar duplicatas da mesma causa num candidato só.
- Descartar o que não tem régua ou evidência. Não promover nada a "confirmado" — isso é do verificador.
- Gate: candidatos únicos, cada um com régua e evidência.

### Passo 5 — Gravar o laudo
- Preencher `LAUDO-<dimensão>.md` a partir do molde, com a seção de **limites** honesta. Apagar a saída bruta temporária.
- Commitar o laudo — **salvo quando quem invoca declarar que commita em lote** (auditores em paralelo no mesmo checkout não commitam ao mesmo tempo). Nenhum código alterado.

## Definition of Done
- [ ] Alvo e régua escritos; nenhum achado sem régua.
- [ ] Cobertura mapeada e fechada (cada área verificada ou com motivo).
- [ ] Ferramentas determinísticas rodadas onde existem (ou `[—]` justificado), só leitura, saída bruta fora do repositório e apagada.
- [ ] Cada candidato com `arquivo:linha`, régua, evidência, severidade e destino propostos; duplicatas juntadas.
- [ ] `LAUDO-<dimensão>.md` gravado a partir do molde, com limites; commitado (ou entregue a quem commita em lote); nenhum código alterado.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4, com a contagem de candidatos por severidade. Em **Próximos passos**, o `/verify-audit` em chat zerado.
