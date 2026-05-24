---
versão: 0.1
status: rascunho
atualizado: 2026-05-24
tipo: backlog de ideias
---

# New_Ideas — backlog de workflows, skills e agents para evolução do codeflow

Catálogo de candidatos a artefatos do framework, agrupados por domínio. Cada item declara **o que é**, **para que serve** e **quando usar**. Nada aqui é normativo — é insumo para `/create-workflow`, `/create-skill` ou `/create-agent` quando o item passar pelo filtro de necessidade real (acontecer ao menos 2× na prática).

Convenção: workflow expõe slash command (`/nome`); skill é módulo carregado por workflows via `LEIA TAMBÉM`; agent é subprocesso com isolamento mecânico de ferramentas.

---

## Sumário

- [A. Desenvolvimento de software (universal)](#a-desenvolvimento-de-software-universal)
- [B. Frontend](#b-frontend)
- [C. Design (UI/UX visual)](#c-design-uiux-visual)
- [D. Produto](#d-produto)
- [E. Interação com usuário (UX writing, conversão, onboarding)](#e-interação-com-usuário-ux-writing-conversão-onboarding)
- [F. Análise de dados](#f-análise-de-dados)
- [G. Machine Learning / IA](#g-machine-learning--ia)
- [Notas de priorização](#notas-de-priorização)

---

## A. Desenvolvimento de software (universal)

Cobre o ciclo: planejar → especificar → implementar → testar → revisar → lançar → operar → aprender.

### Workflows

- **`/plan-feature`** — produz plano de execução escrito (escopo, decisões, decomposição em entregas, riscos) sem escrever código. Usar antes de feature grande ou quando há ambiguidade que `/feature-small` não absorve.
- **`/spec-feature`** — escreve especificação formal (user stories ou EARS + critérios de aceitação) antes da implementação. Usar quando a feature será implementada por outra pessoa/sessão, ou exige aprovação prévia.
- **`/spike`** — investigação time-boxed para validar abordagem desconhecida; entrega nota técnica + protótipo descartável. Usar quando a decisão depende de descobrir algo (viabilidade, performance, API externa).
- **`/feature-large`** — implementa feature que toca múltiplos módulos, contratos públicos ou exige decision dedicada. Usar quando `/feature-small` não dá conta; consome o plano de `/plan-feature`.
- **`/migrate`** — migração estruturada entre versões de framework, lib ou API (em fases, com rollback). Usar para upgrade de major, troca de dependência crítica, mudança de schema.
- **`/add-tests`** — adicionar/aumentar cobertura em código existente sem alterar comportamento. Usar antes de refatoração arriscada ou ao herdar área sem testes.
- **`/triage-bug`** — triagem de bug reportado: reprodução, severidade, owner; decide se vira `/bugfix` ou backlog. Usar como entrada para qualquer bug vindo de fora.
- **`/security-audit`** — auditoria pontual focada (input validation, autz, segredos, deps vulneráveis). Usar antes de release sensível ou após feature que toca dados de usuário.
- **`/perf-investigation`** — investigar gargalo de performance (profiling, hipótese, medição). Usar quando há reclamação concreta ou métrica regredida.
- **`/api-design`** — desenhar contrato de API (REST/GraphQL/RPC) antes de implementar; cobre versionamento, erros, paginação. Usar para endpoint novo público ou contrato entre serviços.
- **`/db-schema-change`** — mudança de schema com migration forward + rollback + plano de deploy. Usar para qualquer ALTER em tabela com dados em produção.
- **`/pre-release`** — checklist canônico antes de cortar release (versão, changelog, testes, migrations, doc). Usar antes de toda tag/deploy de produção.
- **`/hotfix`** — correção urgente em produção: fix mínimo, teste de regressão, rollback explícito. Usar para incidente ativo; não para bug comum.
- **`/post-mortem`** — produz post-mortem estruturado (timeline, causa raiz, ação corretiva, lições). Usar após incidente com impacto observável.
- **`/onboard-codebase`** — primeira imersão estruturada num codebase desconhecido: mapa, pontos de entrada, glossário. Usar ao herdar projeto ou entrar em área nova.

### Skills

- **`root-cause`** — protocolo de análise causal (5 porquês + verificação por hipótese). Carregada por `/bugfix`, `/post-mortem`, `/triage-bug`.
- **`pr-message`** — formato canônico de descrição de PR (contexto, mudança, teste, risco, rollback). Carregada por workflows que terminam em PR.
- **`changelog-entry`** — formato de entrada de changelog (Keep-a-Changelog). Carregada por `/pre-release` e `/hotfix`.
- **`risk-assessment`** — avalia blast radius e reversibilidade antes de ação arriscada. Carregada por `/migrate`, `/hotfix`, `/pre-release`, `/db-schema-change`.
- **`dep-update`** — estratégia para atualizar dependência (patch/minor/major, pin vs range, ordem de teste, leitura de changelog upstream). Usada em manutenção e por `/migrate`.
- **`code-archeology`** — protocolo para entender código legado antes de modificar (git log/blame, leitura top-down, identificação de owners). Carregada por `/bugfix` e `/refactor-safe` em área desconhecida.
- **`adr-record`** — formato de Architecture Decision Record (contexto, decisão, consequências, alternativas). Carregada por `/plan-feature` e `/api-design`.
- **`commit-discipline`** — protocolo de commits atômicos (um motivo por commit, mensagem que explica o porquê). Carregada por workflows que terminam em múltiplos commits.
- **`ci-debug`** — diagnóstico de pipeline CI quebrado (logs, reprodução local, bisseção). Carregada por `/bugfix` quando o sintoma é "CI vermelho".

### Agents

- **`diff-reviewer`** — read-only; recebe apenas o diff (sem o contexto que o produziu) e devolve revisão. Isolamento evita viés do autor. Usar como segunda opinião antes do PR sair.
- **`spec-extractor`** — read-only; lê área grande de código legado e devolve spec/sumário estruturado. Usar antes de `/migrate` ou `/refactor-safe` em área pouco conhecida.

### QA / Garantia de qualidade

Sub-bloco dedicado a teste, qualidade e prevenção de regressão. Cabe no A porque atravessa todo o ciclo de desenvolvimento — não é especialidade isolada.

#### Workflows

- **`/qa-test-plan`** — produz plano de teste antes de testar (escopo, casos, ambientes, dados, critérios de aceitação). Usar antes de validar feature não-trivial ou ao receber área nova para testar.
- **`/qa-exploratory`** — conduz sessão de teste exploratório com charter (foco, time-box, achados registrados). Usar quando a suite automatizada não cobre criatividade do usuário ou em feature recém-saída.
- **`/qa-bug-report`** — escreve bug report estruturado (ambiente, passos, esperado vs observado, evidência, severidade, frequência). Usar para registrar qualquer defeito que não vire fix imediato.
- **`/qa-regression-suite`** — adiciona/atualiza casos na suite de regressão para a área afetada por mudança recente. Usar após `/bugfix` (cada bug corrigido vira teste) e após `/feature-large`.
- **`/qa-acceptance-test`** — deriva testes de aceitação executáveis a partir de critérios da spec/PRD. Usar como ponte entre `/spec-feature` ou `/prd-write` e a implementação.
- **`/qa-smoke`** — executa smoke test do caminho feliz mínimo, pré e pós-deploy. Usar antes de toda promoção a produção e imediatamente depois.
- **`/qa-load-test`** — desenha e executa teste de carga (perfil de tráfego, ramp-up, SLO, observações). Usar antes de evento de tráfego previsto ou após mudança em hot path.
- **`/qa-contract-test`** — escreve teste de contrato entre serviços (consumer-driven, estilo Pact). Usar quando dois serviços compartilham contrato versionável e quebra silenciosa custa caro.

#### Skills

- **`test-pyramid`** — disciplina de alocação de testes (muitos unit, alguns integration, poucos E2E) com critério para escolher o nível ao adicionar teste novo. Carregada por `/add-tests`, `/qa-test-plan`, `/qa-regression-suite`.
- **`flaky-test-protocol`** — diagnóstico e remediação de teste flaky sem cair em "marcar como skip"; investiga causa (concorrência, ordem, dependência externa, dado não-determinístico). Carregada por `/ci-debug` e `/add-tests`.
- **`bug-severity`** — classificação objetiva de severidade (S1 produção quebrada → S4 cosmético) com critérios e SLA. Carregada por `/qa-bug-report` e `/triage-bug`.
- **`boundary-testing`** — protocolo de teste de fronteira (limites numéricos, vazio/cheio, off-by-one, unicode, fuso horário, datas-limite). Carregada por `/add-tests` e `/qa-acceptance-test`.
- **`test-data-isolation`** — isolamento de dados entre testes (sem interdependência, sem ordem implícita, fixtures determinísticas, cleanup). Carregada por `/add-tests` e `/qa-regression-suite`.
- **`repro-minimization`** — reduzir caso de reprodução ao mínimo (bisseção, remoção progressiva de variáveis até o sintoma desaparecer). Carregada por `/qa-bug-report`, `/bugfix`, `/triage-bug`.

#### Agents

- **`regression-detector`** — read-only; compara comportamento entre baseline (main) e branch (mesma suite, mesmo input) e reporta divergências. Isolamento evita auto-justificativa por quem fez a mudança. Usar como gate em `/refactor-safe` e `/migrate`.

---

## B. Frontend

Cobre componente, estado, performance, acessibilidade, responsividade.

### Workflows

- **`/component-build`** — cria componente novo com props tipadas, estados (loading/empty/error/success), acessibilidade básica e teste. Usar para qualquer componente reutilizável novo no design system ou na app.
- **`/ui-refactor`** — refatora UI sem regressão visual (snapshot/visual diff antes-depois). Usar para reorganizar componente sem mudar comportamento.
- **`/accessibility-audit`** — auditoria WCAG (contraste, foco, ARIA, navegação por teclado, leitor de tela). Usar antes de release de tela nova ou em cadência.
- **`/responsive-check`** — verifica comportamento em breakpoints (mobile, tablet, desktop) e densidades. Usar ao finalizar tela ou componente com layout.
- **`/perf-frontend`** — investiga Core Web Vitals (LCP, INP, CLS) + bundle size + render path. Usar quando há regressão de Lighthouse ou queixa de lentidão.
- **`/state-management`** — escolhe e aplica padrão de estado (local, contexto, store global) com justificativa. Usar quando estado começa a vazar entre componentes ou duplicar.
- **`/form-build`** — cria formulário com validação, estados de erro, acessibilidade e submissão idempotente. Usar para qualquer formulário não-trivial (>2 campos com regras).

### Skills

- **`design-tokens`** — regras para consumir tokens (cores, espaçamentos, tipografia, raio) em vez de valores hardcoded. Carregada por `/component-build` e `/ui-refactor`.
- **`a11y-checklist`** — checklist objetivo de acessibilidade por componente (label, role, foco visível, contraste). Carregada por `/component-build`, `/form-build`, `/accessibility-audit`.
- **`semantic-html`** — protocolo para escolher elemento HTML certo antes de div (button vs link, lista vs sequência de divs, etc.). Carregada por `/component-build`.
- **`render-discipline`** — evitar re-render desnecessário (memo, key, dependências de hooks). Carregada por `/perf-frontend` e `/component-build` em componente sensível.

### Agents

- **`visual-diff-reviewer`** — read-only; compara screenshots antes/depois e reporta diferenças não-intencionais. Usar como gate em `/ui-refactor`.

---

## C. Design (UI/UX visual)

Cobre crítica de mockup, sistema de design, heurísticas, fluxo.

### Workflows

- **`/design-review`** — revisa mockup ou tela contra o sistema de design + heurísticas (Nielsen, Fitts, Hick). Usar ao receber design novo antes de implementar.
- **`/design-system-extend`** — adiciona componente/token novo ao design system com justificativa, variações e documentação. Usar quando padrão recorrente justifica promoção.
- **`/wireframe`** — produz wireframe textual estruturado de um fluxo (telas, transições, estados). Usar como ponte entre `/spec-feature` e o desenho visual.
- **`/usability-heuristics`** — aplica as 10 heurísticas de Nielsen numa tela existente e reporta gaps. Usar como auditoria de UX leve antes de pesquisa formal.

### Skills

- **`color-contrast`** — calcula contraste WCAG e sugere ajuste mínimo para conformidade. Carregada por `/design-review` e `/accessibility-audit`.
- **`hierarchy-discipline`** — regras de hierarquia visual (tamanho, peso, posição, cor) — uma ação primária por tela. Carregada por `/design-review`.
- **`information-density`** — protocolo para balancear densidade vs respiração (espaçamento, agrupamento, divisores). Carregada por `/design-review`.

---

## D. Produto

Cobre descoberta, especificação de produto, priorização, métricas.

### Workflows

- **`/discovery-interview`** — roteiro de entrevista com usuário para validar problema (perguntas abertas, sem propor solução). Usar antes de especificar feature nova com hipótese frágil.
- **`/prd-write`** — escreve Product Requirements Document curto (problema, usuário, métrica, escopo, fora-do-escopo, riscos). Usar para iniciativa que exige alinhamento entre múltiplos stakeholders.
- **`/jtbd`** — preenche canvas Jobs To Be Done (situação, motivação, resultado esperado). Usar para enquadrar oportunidade antes de definir solução.
- **`/opportunity-tree`** — mapeia oportunidades a partir de outcome (Teresa Torres): outcome → oportunidades → soluções → experimentos. Usar em planejamento de quarter ou descoberta contínua.
- **`/roadmap-plan`** — prioriza backlog com método explícito (RICE, MoSCoW, WSJF) e gera roadmap defensável. Usar em cadência de planejamento (mensal/trimestral).
- **`/metric-define`** — define métrica north star + métricas de guarda + segmentações. Usar ao lançar feature mensurável ou novo produto.

### Skills

- **`assumption-mapping`** — lista assumptions implícitas de uma decisão de produto e classifica (desejabilidade, viabilidade, factibilidade). Carregada por `/prd-write`, `/jtbd`, `/opportunity-tree`.
- **`user-story-format`** — formato canônico de user story (como X, quero Y, para Z) + critérios de aceitação testáveis. Carregada por `/prd-write` e `/spec-feature`.
- **`hypothesis-format`** — formato de hipótese de produto (acreditamos que X, para Y, resultando em Z; saberemos por W). Carregada por `/discovery-interview` e `/ab-test-design`.

---

## E. Interação com usuário (UX writing, conversão, onboarding)

Cobre o que o usuário lê, o que ele faz na primeira vez, e os estados que ele encontra fora do caminho feliz.

### Workflows

- **`/ux-copy-review`** — revisa microcopy (botões, mensagens de erro, vazios, confirmações) por voz/tom, clareza e ação. Usar antes de release de tela com texto novo.
- **`/onboarding-flow`** — desenha fluxo de primeira-vez (tempo até valor, fricções, momentos de aha). Usar para feature/produto novo onde o primeiro uso define adoção.
- **`/error-state`** — desenha tratamento de erro (mensagem, causa, ação de recuperação). Usar ao implementar feature que pode falhar visivelmente.
- **`/empty-state`** — desenha tela vazia (explicação + CTA para sair do vazio). Usar para qualquer lista/dashboard/área que começa vazia.
- **`/conversion-review`** — analisa fricções num fluxo de conversão (formulário, checkout, signup) e propõe correções priorizadas. Usar quando há funnel com queda mensurável.

### Skills

- **`voice-tone`** — regras de voz/tom do produto (formal/informal, ativa/passiva, vocabulário proibido). Carregada por `/ux-copy-review` e `/onboarding-flow`.
- **`microcopy-patterns`** — padrões testados (botão verbo+objeto; erro causa+ação; vazio explicação+CTA). Carregada por `/ux-copy-review`, `/error-state`, `/empty-state`.
- **`a11y-copy`** — texto acessível (alt útil, label descritivo, evitar "clique aqui", linguagem simples). Carregada por `/ux-copy-review` e `/accessibility-audit`.
- **`form-friction`** — checklist de fricções comuns em formulário (campos opcionais marcados, validação inline, mensagens de erro específicas). Carregada por `/form-build` e `/conversion-review`.

---

## F. Análise de dados

Cobre exploração, consulta, dashboard, experimentação, investigação de métrica, qualidade.

### Workflows

- **`/data-explore`** — EDA inicial em dataset novo (qualidade, distribuição, missing, outliers, correlações). Usar ao receber fonte de dados nova antes de qualquer análise.
- **`/sql-query-build`** — traduz pergunta de negócio em query SQL com validação por amostra. Usar para consulta ad hoc que será revisada ou reutilizada.
- **`/dashboard-build`** — monta dashboard com métricas, filtros, drill-down e contexto explicativo. Usar para dashboard que será consumido por mais de uma pessoa.
- **`/ab-test-design`** — desenha experimento A/B (hipótese, MDE, tamanho de amostra, duração, métricas primárias e de guarda). Usar antes de qualquer experimento de produto.
- **`/metric-investigation`** — investiga mudança suspeita em métrica (segmentar, decompor, descartar hipóteses). Usar quando dashboard mostra anomalia inexplicada.
- **`/data-quality-check`** — checa qualidade de dataset ou pipeline (completude, frescor, consistência, distribuição). Usar em cadência ou antes de tomada de decisão crítica.
- **`/report-write`** — produz relatório analítico (pergunta, método, achados, limitações, ação recomendada). Usar para entregar análise a stakeholder não-técnico.

### Skills

- **`sql-style`** — convenções SQL (CTEs sobre subqueries aninhadas, nomes explícitos, formatação). Carregada por `/sql-query-build` e `/dashboard-build`.
- **`chart-choice`** — escolher gráfico certo por intenção (comparação, distribuição, composição, evolução, relação). Carregada por `/dashboard-build` e `/report-write`.
- **`statistical-honesty`** — protocolo contra erros comuns (p-hacking, Simpson, regressão à média, intervalos de confiança). Carregada por `/ab-test-design`, `/metric-investigation`, `/report-write`.
- **`data-contract`** — formato de contrato de dado entre produtor e consumidor (schema, frescor, SLA). Carregada por `/dashboard-build` e `/data-quality-check`.

### Agents

- **`query-sandboxer`** — read-only no DB; recebe pergunta e devolve query + amostra de resultado, sem capacidade de escrita. Usar para exploração em base de produção onde acidente custa caro.

---

## G. Machine Learning / IA

Cobre baseline, dados, treino, avaliação, deploy, drift, e a faixa específica de LLM/RAG/prompts.

### Workflows

- **`/ml-baseline`** — produz baseline (regra simples, modelo trivial) antes de qualquer complexidade. Usar ao iniciar projeto de ML para estabelecer piso de comparação.
- **`/ml-feature-engineering`** — pipeline de features reprodutível (definição, fonte, transformação, versionamento). Usar antes de treinar modelo que será mantido.
- **`/ml-train-experiment`** — roda experimento com tracking (hiperparâmetros, métricas, artefatos, seed). Usar para qualquer treino que precisará ser comparado.
- **`/ml-eval`** — avalia modelo em métricas + slices (subgrupos, casos limite, vieses). Usar antes de promover modelo a produção.
- **`/ml-deploy`** — empacota e serve modelo com latência medida, contrato de input/output e monitoramento básico. Usar quando experimento vira sistema.
- **`/ml-drift-check`** — detecta drift de dados, conceito ou performance em produção. Usar em cadência e ao receber alerta de regressão.
- **`/rag-build`** — constrói pipeline RAG (ingestão, chunking, embedding, retrieval, geração) com eval. Usar para sistema de Q&A sobre corpus específico.
- **`/prompt-iterate`** — itera prompt com suite de avaliação objetiva (não vibe). Usar quando prompt é parte de produto e precisa estabilidade.
- **`/llm-eval`** — monta suite de avaliação para LLM (golden set, métricas, regressões). Usar antes de trocar modelo ou prompt em produção.

### Skills

- **`data-leakage`** — checagens contra vazamento entre splits (train/val/test), entre features e target, temporal. Carregada por `/ml-train-experiment` e `/ml-eval`.
- **`reproducibility`** — seeds, versionamento de dados, ambiente fixado, semente de embaralhamento. Carregada por `/ml-train-experiment` e `/rag-build`.
- **`prompt-discipline`** — estrutura de prompt (papel, contexto, exemplos, instrução, formato de saída) e anti-padrões. Carregada por `/prompt-iterate` e `/rag-build`.
- **`eval-set-curation`** — protocolo para construir golden set (cobertura, dificuldade, atualização, anotação). Carregada por `/llm-eval` e `/ml-eval`.
- **`hallucination-guard`** — técnicas para reduzir/detectar alucinação (grounding, citação, abstenção). Carregada por `/rag-build` e `/prompt-iterate`.
- **`token-economy`** — análise de custo/latência de prompt em produção (tokens entrada/saída, cache, batching). Carregada por `/prompt-iterate` e `/ml-deploy` quando o modelo é LLM.

### Agents

- **`ml-experiment-runner`** — agent isolado que executa experimento de treino em contexto próprio, sem contaminar a sessão principal com logs/métricas intermediárias. Usar para experimento longo cujo resultado importa, mas cujo processo não.
- **`eval-judge`** — agent isolado que aplica rubrica de avaliação a saídas de LLM, sem ver o prompt original (evita viés). Usar em `/llm-eval` para julgamento estruturado.

---

## Notas de priorização

Nem tudo aqui precisa virar artefato. Sugestão de ordem de implementação, do mais transversal ao mais especializado:

1. **Bloco A (dev universal)** — preenche o ciclo que o framework já cobre parcialmente. Maior alavancagem por item.
2. **Skills transversais de A** — `pr-message`, `risk-assessment`, `root-cause` são carregadas por muitos workflows; ganho composto.
3. **Bloco F (dados)** — analítica geralmente convive com dev em times pequenos; alto retorno se o time olha métrica.
4. **Bloco G (ML/IA)** — só faz sentido se há projeto de ML ativo. Priorizar `prompt-iterate` e `llm-eval` se há LLM em produto.
5. **Blocos B, C, D, E (frontend/design/produto/UX)** — priorizar conforme o perfil do time. Em time fullstack, `component-build` e `accessibility-audit` (B) geralmente vêm antes dos blocos de design/produto puros.

**Filtro para promover ideia daqui a artefato real:** a tarefa aconteceu ≥2 vezes na prática, com risco de inconsistência sem protocolo. Caso contrário, resolver ad hoc — o framework não recompensa especulação (vide princípio de `/create-workflow`).
