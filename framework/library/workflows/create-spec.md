---
versão: 1.0
status: estável
atualizado: 2026-06-14
granularidade: detalhado
gera_decision: no
usa_checkpoints: yes
politica_falhas: padrão
---

# Workflow: create-spec

## Princípio guia
Uma spec nasce de sondagem do código real, não de suposição. Descreve **o quê**, **por quê** e **como executar** — incluindo um **plano de desenvolvimento por fases** detalhado e separado, de modo que um agente de IA leia este único documento e execute as fases uma a uma até concluir. Decisão de escopo aberta é resolvida com o owner antes de escrever, nunca chutada.

## Quando usar
Transformar uma necessidade ou descrição do usuário (ex: "integração WhatsApp via Evolution API") em uma **spec robusta e assertiva** no formato `.devgabriel` do Gabriel, ancorada na arquitetura e nos padrões do repositório atual. Pré-requisitos: o repositório alvo tem `.codeflow/` inicializado (rode `/bootstrap` antes, se não tiver) e o owner está disponível para confirmar escopo e resolver Open Questions durante a execução.

## Quando NÃO usar
- Para executar/implementar as fases de uma spec já escrita → este workflow **produz** o documento executável; a execução de cada fase é feita depois (manualmente ou por `/feature-small` por fase).
- Para corrigir/ampliar uma spec já escrita sem novas decisões abertas → editar direto, sem workflow.
- Quando a necessidade é trivial (uma função, um typo de regra) → resolver ad hoc; spec é overhead.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/code-quality.md
- ~/.codeflow/framework/library/skills/self-review/SKILL.md
- ~/.codeflow/framework/library/skills/handoff/SKILL.md
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (carregar decisions ATIVAS cujas tags cruzem o domínio da necessidade)

## Estrutura do workflow
Quatro fases sequenciais com checkpoint ao fim de cada uma. Pausa para o owner em duas: confirmação de escopo (Fase 1) e resolução de Open Questions (Fase 3). A última fase gera **um único documento** — a spec — em sua própria subpasta sob `.codeflow/specs/`.

## Fase 1 — Enquadramento da necessidade

### Objetivo
Converter a descrição livre do usuário em um enquadramento estruturado e acordar a fronteira de escopo **antes** de qualquer escrita.

### Ações
1. Ler a necessidade do usuário literalmente; extrair: problema central, resultado desejado, atores/contextos citados.
2. Inferir os metadados-semente da spec: `type` (feature/refactor/infra/...), `domain` (backend/frontend/infra), `bounded_context` provável, `size`/`priority` aproximados — marcando o que é palpite a confirmar.
3. Derivar um `slug` em kebab-case e um título curto candidato.
4. Redigir 1 parágrafo de "escopo proposto" + uma lista explícita de **fora de escopo** (o que esta spec deliberadamente não cobre).
5. **Apresentar o enquadramento ao owner e aguardar confirmação** do escopo, da fronteira fora-de-escopo e do slug/título antes de avançar.

### Checkpoint
Gravar `.codeflow/checkpoints/create-spec-<timestamp>.md` com: necessidade original, metadados-semente, slug/título, escopo proposto, fora-de-escopo, e a resposta do owner.

## Fase 2 — Sondagem do codebase e arquitetura

### Objetivo
Ancorar a spec na realidade do repositório: o que já existe e deve ser reusado, o que é genuinamente novo, e quais padrões/regras são invioláveis.

### Ações
1. Mapear a arquitetura relevante: camadas, ports/adapters, módulos, convenções de nomes e rotas, ferramentas (consultar `.codeflow/manifest.md` e o código).
2. Localizar **seams existentes** que a necessidade deve plugar (precedentes, enums extensíveis, tabelas genéricas, registries) — o "molde de referência" mais próximo já implementado.
3. Levantar ADRs, rules e decisions que restringem a solução (segurança, isolamento de tenant, RBAC, LGPD, migrations — o que se aplicar).
4. Construir o **mapa NOVO vs. REUSADO vs. REMOVIDO**: o que a spec constrói, o que reusa sem duplicar, o que (se algo) remove.
5. Anotar os **princípios invioláveis** que a spec deve declarar (derivados das rules/ADRs, não inventados).

### Checkpoint
Atualizar `.codeflow/checkpoints/create-spec-<timestamp>.md` com: arquitetura mapeada, seams/precedentes, ADRs/rules/decisions aplicáveis, mapa NOVO/REUSADO/REMOVIDO, princípios invioláveis.

## Fase 3 — Resolução de decisões abertas

### Objetivo
Tornar a spec **assertiva**: nenhuma ambiguidade de escopo material fica como chute.

### Ações
1. Consolidar as Open Questions reais — escolhas de design com mais de um caminho viável e impacto relevante (ex: modelo de hosting, oficial vs. não-oficial, template-only vs. texto livre).
2. Para cada uma, propor a recomendação fundamentada na sondagem da Fase 2 e a(s) alternativa(s) rejeitada(s).
3. **Apresentar as Open Questions ao owner e aguardar a decisão** de cada uma. Aplicar a política de falhas se o owner não decidir: registrar a OQ como aberta na spec em vez de chutar.
4. Registrar cada resolução com data e justificativa (vira a marcação "RESOLVIDO" na seção Open Questions da spec).

### Checkpoint
Atualizar `.codeflow/checkpoints/create-spec-<timestamp>.md` com: cada Open Question, a recomendação, a decisão do owner (ou "permanece aberta") e a justificativa.

## Fase 4 — Geração de artefatos

### Objetivo
Escrever a spec final — **um único documento autoexecutável** — no formato canônico, incluindo o plano de fases.

### Ações
1. Decompor a abordagem técnica (§4) em **fases ordenadas e executáveis**: cada fase entrega um incremento testável, declara seus arquivos/passos/testes/critério de conclusão e respeita as dependências (uma fase não pressupõe trabalho de uma fase posterior). Granularidade-alvo: 3 a 8 fases; fase grande demais para um agente executar de uma vez deve ser subdividida.
2. Criar a subpasta da spec `.codeflow/specs/<slug>/` (uma subpasta por spec) e escrever dentro dela **o único arquivo** `SPEC_<NAME>.md`, seguindo **exatamente** o esqueleto abaixo (formato `.devgabriel` do agendia, **com** o "Plano de desenvolvimento por fases" detalhado; a DoD tem gate por etapa). Nenhum outro arquivo é criado.

   ```markdown
   ---
   id: <FEAT-XXXX ou null>        # opcional; só se o projeto usa numeração
   slug: <slug>
   title: "<título descritivo longo>"
   type: feature | refactor | infra | ...
   status: draft
   priority: P0|P1|P2|P3
   size: S|M|L|XL
   risk_level: GREEN|YELLOW|RED
   domain: backend|frontend|infra|...
   bounded_context: <contexto>
   cross_context: [<outros contextos>]
   created_at: <AAAA-MM-DD>
   updated_at: <AAAA-MM-DD>
   owner: <owner>
   linked_adr: [<ADRs aplicáveis>]
   depends_on: []
   blocks: []
   ---

   # <ID — título curto>

   > **Nota de planning (<data>):** spec construída após sondagem do codebase.
   > Declarar o ponto central: o que já existe e é reusado vs. o que é novo.
   > Declarar explicitamente o que está **fora do escopo desta spec**.

   ## Resumo executivo (TL;DR)
   Tabela O quê / Por quê / Backend-Infra / Frontend / Decisão / Tamanho.

   ## Sumário
   Lista numerada das seções abaixo (incluindo o Plano de desenvolvimento por fases).

   ## 1. Problema e contexto
   Contexto real do repositório; por que a necessidade existe; o seam existente.
   ### 1.x Princípios invioláveis
   Lista numerada dos princípios derivados de rules/ADRs (Fase 2).

   ## 2. Requisitos
   Funcionais (FR-N) e Não-funcionais (NFR-N), cada um numerado e testável.

   ## 3. Critérios de aceite
   Given/When/Then por critério (AC-N), rastreáveis aos FR/NFR.

   ## 4. Abordagem técnica
   Mapa NOVO vs. REUSADO (vs. REMOVIDO) + detalhamento por área. É o desenho do
   "o quê fazer", que a §5 transforma em sequência executável.

   ## 5. Plano de desenvolvimento por fases
   > Cada fase é executável de forma isolada por um agente de IA lendo só este
   > documento: TDD (teste vermelho → implementação → verde → lint/type →
   > regressão). Ordem obrigatória; não iniciar a Fase N+1 sem o critério de
   > conclusão da Fase N verde.

   ### Fase 1 — <nome> *(esforço ≈Xh)*
   - **Objetivo:** o incremento que esta fase entrega.
   - **Depende de:** fases anteriores / pré-requisitos (ou "nenhuma").
   - **Arquivos novos:** caminhos. **Arquivos alterados:** caminhos.
   - **Passos:** 1) … 2) … — instruções acionáveis o bastante para executar sem
     reabrir decisões (decisões já estão em §4 e §8).
   - **Testes:** o que provar, mapeado aos AC-N relevantes.
   - **Critério de conclusão (gate):** condição verificável de pronto.

   ### Fase 2 — <nome> *(esforço ≈Xh)*
   (mesma estrutura; repetir por fase — alvo 3 a 8 fases.)

   ## 6. Riscos
   Tabela: # | Risco | Prob. | Impacto | Mitigação.

   ## 7. Rollout
   Como entra em produção, flags, ordem, rollback.

   ## 8. Open Questions
   Cada OQ com status RESOLVIDO (decisão + data + justificativa) ou aberta (Fase 3).

   ## 9. Definition of Done (gate por etapa)
   Checklist de prontidão com gate por fase (cada fase só fecha com seu critério
   de conclusão verde) + os itens globais transversais (testes, lint/type,
   segurança/PII, sem regressão). Cada item objetivo e verificável.
   ```

3. Validar a spec gerada com a skill `self-review`: cada FR tem AC; cada princípio inviolável vem de uma rule/ADR real; **cada fase de §5 é executável isoladamente** (tem arquivos, passos, testes e critério de conclusão) e respeita as dependências; segredos/PII não aparecem em exemplos.
4. Apresentar o resumo final e, com a spec aprovada, deletar os checkpoints da execução. As decisões de escopo e Open Questions já ficam registradas **dentro da própria spec** (§8); este workflow não gera artefato separado.

### Checkpoint
Estado final persistido no único artefato versionável (`.codeflow/specs/<slug>/SPEC_<NAME>.md`); com a spec aprovada, `.codeflow/checkpoints/create-spec-<timestamp>.md` é deletado (workflow concluído).

## Proibições durante este workflow
- Não escrever a spec antes da confirmação de escopo do owner (Fase 1).
- Não escrever fases vagas ou não-executáveis: cada fase da §5 declara arquivos, passos, testes e critério de conclusão, e não pressupõe trabalho de uma fase posterior. Fase que um agente não conseguiria executar lendo só a spec é defeito.
- Não inventar princípios invioláveis, ADRs ou padrões que não existem no repositório; cada um vem da sondagem da Fase 2.
- Não chutar Open Question material: ou o owner decide, ou fica registrada como aberta.
- Não escrever código de produção nem migrations; este workflow produz **um único documento** (a spec), nada mais.
- Não gerar artefatos paralelos (decision, ROTEIRO, checklist, pasta `artefatos/`): a subpasta `.codeflow/specs/<slug>/` contém só `SPEC_<NAME>.md`.
- Não vazar segredo/PII em exemplos da spec.

## Definition of Done
- [ ] Escopo e fora-de-escopo confirmados pelo owner (Fase 1).
- [ ] Codebase sondado; mapa NOVO/REUSADO/REMOVIDO e princípios invioláveis derivados do código real (Fase 2).
- [ ] Open Questions materiais resolvidas pelo owner ou registradas como abertas (Fase 3).
- [ ] Subpasta própria `.codeflow/specs/<slug>/` criada, contendo **só** `SPEC_<NAME>.md` (documento único).
- [ ] A spec contém o "Plano de desenvolvimento por fases" (3–8 fases), cada fase executável isoladamente por um agente — com arquivos, passos, testes e critério de conclusão — e a DoD da spec tem gate por etapa.
- [ ] Cada FR tem ao menos um AC correspondente; cada princípio rastreia a uma rule/ADR.
- [ ] `self-review` aplicado à spec.
- [ ] Checkpoints da execução deletados (workflow concluído com sucesso).

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
