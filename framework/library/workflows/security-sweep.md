---
versão: 1.0
status: experimental
atualizado: 2026-09-17
granularidade: detalhado
gera_decision: yes
usa_checkpoints: yes
politica_falhas: padrão
---

# Workflow: security-sweep

## Princípio guia
Uma varredura de segurança séria não é uma lista de achados — é um mapa do que foi coberto, com que
confiança, e quais achados **se sustentaram** quando alguém tentou reproduzi-los. Mapear a superfície
de ataque precede caçar; caçar precede validar; validar precede reportar. Achado de ferramenta é
hipótese até a triagem prová-lo, e nada ativo toca alvo vivo sem autorização e ambiente efêmero.

## Quando usar
Fazer uma passada pesada de busca de vulnerabilidades sobre um projeto **seu**: mapear a superfície de
ataque, rodar os scanners estáticos, caçar adversarialmente por dimensão (authz/IDOR, injection,
segredos, dependências, autenticação, SSRF, lógica de negócio) e entregar um lote de achados
**confirmados** com a taxa de falso positivo medida. Serve tanto para um app quanto para uma API,
biblioteca ou serviço. Pré-requisitos: o repositório tem `.codeflow/` inicializado (rode `/discover`
antes, se não tiver), o alvo é código seu (ou você tem autorização escrita), e o owner está disponível
para confirmar escopo e autorização na abertura. A saída alimenta `/batch-bugfix` → `/double-check`.

## Quando NÃO usar
- Para uma revisão defensiva leve de um diff ou PR (ler e apontar, sem caçar) → use `/security-review`
  (built-in) ou a skill `code-reviewer`.
- Para **corrigir** vulnerabilidades já levantadas → use `/batch-bugfix` (lote) ou `/bugfix` (avulso);
  este workflow só descobre e valida, não aplica fix.
- Para testar um alvo de terceiro (site de cliente já entregue, host que não é seu) sem autorização
  escrita → não usar; é problema jurídico (rule `adversarial-testing`).
- Para um único bug de segurança já reproduzível e localizado → resolva com `/bugfix`; o cerimonial
  daqui é overhead.

## LEIA TAMBÉM
- ~/.codeflow/framework/core/constitution.md
- ~/.codeflow/framework/core/rules/security.md
- ~/.codeflow/framework/core/rules/adversarial-testing.md
- ~/.codeflow/framework/core/rules/testing.md
- ~/.codeflow/framework/library/skills/triagem-de-achado/SKILL.md
- ~/.codeflow/framework/library/skills/debug-protocol/SKILL.md
- ~/.codeflow/framework/library/workflows/batch-bugfix.md (formato do ledger de saída)
- .codeflow/INDEX.md
- .codeflow/constitution.md
- .codeflow/manifest.md
- .codeflow/decisions/INDEX.md (filtrar pela tag `security`)

## Estrutura do workflow
Seis fases sequenciais com checkpoint ao fim de cada uma. Pausa obrigatória para o owner na Fase 1
(escopo e autorização) e antes de qualquer teste **ativo** contra instância viva na Fase 5. As Fases 2
a 4 constroem e preenchem um **ledger de cobertura** (cada superfície começa como `não verificado` e
termina como `candidato` ou `descartado, com motivo`). A última fase gera o ledger de achados, a
decision e o resumo. Mapear precede caçar; validar precede reportar.

## Retomada
`security-sweep` usa checkpoints (`SPEC.md` §6.6). Ao iniciar, verificar se existe
`.codeflow/checkpoints/security-sweep-*.md` recente: se sim, apresentar o resumo (escopo, fase em
pausa, mapa de superfície, candidatos já triados) e perguntar ao owner se deseja retomar daquele ponto
ou começar do zero. Retomar carrega o escopo autorizado, o mapa de ataque e os vereditos de triagem já
fechados; começar do zero deleta o checkpoint antigo.

## Fase 1 — Escopo e autorização

### Objetivo
Fixar o que será varrido, com que profundidade, e confirmar que o alvo pode ser testado — antes de
qualquer leitura ofensiva.

### Ações
1. **Data canônica:** obter a data de hoje com `date +%F` via Bash; usar em todos os campos de data.
   Não inferir de memória.
2. **Delimitar o alvo** em uma frase: qual app/módulo/superfície entra (ex.: "a API `apps/api` e o
   fluxo de sync offline") e o que fica explicitamente de fora.
3. **Escolher a profundidade** com o owner: `estática` (só código em disco + scanners; nenhum alvo
   vivo tocado) ou `ativa` (inclui PoC contra instância **efêmera** local, dados sintéticos). Ativa
   exige o ambiente de laboratório da rule `adversarial-testing`.
4. **Confirmar autorização** (rule `adversarial-testing`): o alvo é código seu? Se o escopo incluir
   qualquer alvo que executa e não é seu (instância exposta, site de cliente), **parar** e exigir
   autorização escrita antes de seguir. Produção e dado real ficam fora por padrão.
5. **Declarar o teto de esforço:** tempo/atenção da passada e, se houver ferramenta paga no meio, o
   `--max-budget`/limite explícito.
6. **Apresentar o enquadramento (alvo, profundidade, autorização, teto) ao owner e aguardar
   confirmação** antes de investigar.

### Checkpoint
Gravar `.codeflow/checkpoints/security-sweep-<timestamp>.md` com: alvo (entra/fica de fora),
profundidade escolhida, estado da autorização, teto declarado, e a confirmação do owner.

## Fase 2 — Mapa de superfície de ataque

### Objetivo
Entender por onde se ataca antes de atacar: enumerar entradas, fronteiras de confiança e dados
sensíveis, e montar o esqueleto do ledger de cobertura.

### Ações
1. **Enumerar pontos de entrada:** rotas/endpoints HTTP, handlers de sync, argumentos de CLI, uploads,
   webhooks, consumidores de fila, jobs, e todo ponto que lê dado externo (config, env, arquivo).
2. **Mapear o modelo de autorização:** como o projeto decide quem pode o quê — guards, roles, checagem
   de posse/escopo, isolamento entre clientes (multi-tenant). Anotar onde a decisão é tomada.
3. **Marcar os dados sensíveis e as fronteiras de confiança:** PII, credenciais, segredos, dados de um
   cliente que não podem cruzar para outro. Onde o dado não confiável vira ação confiável.
4. **Montar o ledger de cobertura:** listar cada superfície × dimensão relevante (ex.: "rota
   `GET /produtores/:id/frnc` × IDOR") como uma linha em estado `não verificado`. Esse esqueleto é o
   que as Fases 3 e 4 vão preencher.

### Checkpoint
Atualizar o checkpoint com: mapa de entradas, modelo de authz, dados sensíveis/fronteiras, e o ledger
de cobertura inicial (todas as linhas `não verificado`).

## Fase 3 — Varredura determinística

### Objetivo
Colher o sinal barato e determinístico dos scanners estáticos antes de gastar raciocínio adversário.

### Ações
1. **Segredos** — rodar `gitleaks` sobre a árvore de trabalho e o histórico (`gitleaks dir .` e
   `gitleaks git .`, ou `gitleaks detect --source .` conforme a versão), saída em JSON.
2. **SAST** — rodar `semgrep scan --config auto` (ou packs fixados: `p/owasp-top-ten`,
   `p/security-audit`, `p/secrets`), saída em JSON/SARIF.
3. **Dependências** — rodar `osv-scanner scan -r .` e o audit do gerenciador do projeto
   (`npm audit` / `pnpm audit` / equivalente), saída em JSON.
4. **Lint de segurança do próprio projeto**, se houver (`eslint-plugin-security`, checagem de
   fronteiras, `contract:check`) — rodar os comandos do `.codeflow/manifest.md`.
5. **Onde gravar a saída bruta:** todo relatório de scanner (`.json`/`.sarif`/dumps) vai para um
   diretório de trabalho **fora do controle de versão** — o scratchpad da sessão ou um `.codeflow/`
   path já no `.gitignore`. Nunca dentro de diretório versionado. Essa saída é **apagada na Fase 6**;
   só o ledger curado é versionado.
6. **Normalizar** todas as saídas numa lista única de candidatos, cada um com arquivo:linha, regra e
   severidade bruta. Não julgar ainda — julgar é a Fase 5. Marcar no ledger de cobertura as linhas que
   cada scanner tocou.

### Validação
Cada scanner rodou e produziu saída parseável (ou registrou-se por que não se aplica — ex.: projeto
sem lockfile dispensa `osv-scanner`). Scanner que falha por ambiente (rede, versão) é anotado como
lacuna de cobertura, não silenciado.

### Checkpoint
Atualizar o checkpoint com: comandos rodados e seu resultado, lista bruta de candidatos normalizada, e
as lacunas de cobertura (scanner que não rodou e por quê).

## Fase 4 — Caça adversária guiada

### Objetivo
Fazer o papel do agente ofensivo: raciocinar como atacante sobre o mapa da Fase 2, dimensão por
dimensão, indo onde o scanner estático não alcança (lógica de negócio, encadeamento, authz de objeto).

### Ações
1. **Percorrer o ledger de cobertura por dimensão**, e para cada superfície perguntar como um atacante:
   - **Authz de objeto / IDOR:** o ator A alcança o objeto de B? O isolamento entre clientes
     (multi-tenant) se sustenta em toda rota que lê ou escreve dado de cliente?
   - **Injection:** SQL/NoSQL, comando, template, deserialização — entrada não confiável chega a um
     sink sem binding/escape?
   - **Autenticação e sessão:** fluxo de login, reset de senha, JWT, expiração, força bruta.
   - **Controle de acesso em rotas que mudam estado:** POST/PATCH/DELETE checam permissão no servidor,
     não só na UI?
   - **SSRF e saída não confiável:** o serviço faz requisição a URL derivada de input?
   - **Exposição de config/segredo** além do que o gitleaks pega; **mass assignment**; **lógica de
     negócio** que o scanner não modela.
2. **Fechar cada linha do ledger de cobertura:** de `não verificado` para `candidato` (com a alegação)
   ou `descartado` (com a barreira que o invalida — guard, binding, escopo). Descartar **com motivo
   nomeado** é cobertura, não lixo.
3. Anotar candidatos que só se confirmam com teste ativo (dependem de instância viva) para a Fase 5,
   respeitando a profundidade autorizada na Fase 1.

### Checkpoint
Atualizar o checkpoint com: o ledger de cobertura preenchido (cada linha `candidato`/`descartado` com
motivo), a lista consolidada de candidatos (scanners + caça), e os que exigem teste ativo.

## Fase 5 — Validação e triagem

### Objetivo
Separar real de ruído aplicando a skill `triagem-de-achado`: reproduzir cada candidato, classificar e
medir a taxa de falso positivo.

### Ações
1. Para cada candidato (Fases 3 e 4), aplicar o protocolo da skill `triagem-de-achado`: traçar o
   caminho até o sink ou escrever um teste-guarda/PoC que falha por causa da falha.
2. **Teste ativo só sob autorização:** se a confirmação exige disparar requisição/payload contra
   instância viva, **parar e confirmar com o owner** que a profundidade `ativa` e o laboratório
   efêmero da Fase 1 estão valendo. Nada ativo contra alvo exposto à rede sem isso.
3. **Segredo real e ativo encontrado:** parar o fluxo, sinalizar ao owner para rotacionar antes de
   seguir (rule `adversarial-testing`), e não colar o valor em claro em lugar nenhum.
4. Fechar cada candidato em um veredito: `confirmado` (com severidade justificada e o teste/caminho),
   `não-explorável-no-contexto` (com o motivo) ou `falso-positivo`.
5. **Medir a taxa de falso positivo** da rodada: quantos candidatos entraram, quantos se sustentaram —
   por scanner e no total. É o número que calibra as ferramentas.

### Checkpoint
Atualizar o checkpoint com: veredito de cada candidato, severidades dos confirmados, a taxa de falso
positivo medida, e qualquer segredo sinalizado para rotação.

## Fase 6 — Geração de artefatos

### Objetivo
Entregar o lote de achados confirmados no formato que `/batch-bugfix` consome, registrar a decisão e
finalizar.

### Ações
1. **Gerar o ledger** em `.codeflow/bug-batches/security-<slug>-<data>.md` (data da Fase 1) no formato
   do `/batch-bugfix`: uma linha por achado **confirmado** (`# | item | o que era | repro/teste-guarda
   | fix sugerido | verificação`), e uma seção **Cobertura** listando o que foi `descartado` e o que
   ficou como lacuna. Os confirmados entram com `status: pendente` para o `/batch-bugfix` recolher.
2. **Gerar decision** em `.codeflow/decisions/<data>-<titulo>.md` com a tag `security`, registrando:
   escopo e profundidade autorizados, ferramentas usadas, cobertura obtida, número de achados
   confirmados por severidade, e a **taxa de falso positivo por ferramenta** — o insumo para decidir se
   cada scanner merece ficar no fluxo.
3. Atualizar `.codeflow/decisions/INDEX.md`.
4. **Encaminhar** os confirmados: apontar que o próximo passo é `/batch-bugfix` sobre o ledger gerado,
   e depois `/double-check` para verificar cada fix.
5. **Apagar a saída bruta dos scanners** (os `.json`/`.sarif`/dumps da Fase 3): ela cumpriu o papel de
   alimentar a triagem e não é versionada. O que fica é o ledger curado e a decision.
6. Apresentar o resumo final no formato fixo de cinco seções. Concluído com sucesso, deletar os
   checkpoints da execução.

## Proibições durante este workflow
- Não rodar teste ativo (requisição, payload, força de login) contra qualquer alvo exposto à rede sem
  a pausa de autorização da Fase 1 e o ambiente efêmero — código seu em disco não autoriza atacar um
  host vivo.
- Não varrer alvo de terceiro (site de cliente entregue, host que não é seu) sem autorização escrita.
- Não reportar achado bruto de scanner como vulnerabilidade sem passar pela triagem da Fase 5.
- Não colar segredo real, payload de exploração ou dump sensível em log, ticket ou arquivo versionado
  em claro.
- Não gravar saída bruta de scanner dentro de diretório versionado: ela vive em scratch fora do git e
  é apagada na Fase 6. Só o ledger curado é versionado.
- Não aplicar fix de produção aqui: este workflow descobre e valida; corrigir é `/batch-bugfix`.
- Não pular a Fase 2 (mapa) e sair caçando — sem superfície mapeada não há cobertura, só achados
  soltos.
- Não descartar candidato como falso-positivo sem nomear a barreira que o invalida.
- Não inferir datas de memória — toda data vem do `date +%F` da Fase 1.

## Definition of Done
- [ ] Data obtida via `date +%F`; alvo, profundidade e autorização confirmados pelo owner (Fase 1).
- [ ] Superfície de ataque mapeada e ledger de cobertura montado (Fase 2).
- [ ] Scanners rodados (segredos, SAST, dependências) e candidatos normalizados; lacunas anotadas
      (Fase 3).
- [ ] Caça adversária percorreu o ledger por dimensão; cada linha fechada como `candidato`/`descartado
      com motivo` (Fase 4).
- [ ] Cada candidato triado via `triagem-de-achado`; confirmados com severidade; taxa de falso positivo
      medida (Fase 5).
- [ ] Ledger de achados gerado no formato `/batch-bugfix`; decision com tag `security` (escopo,
      cobertura, FP por ferramenta); `decisions/INDEX.md` atualizado; checkpoints deletados (Fase 6).
- [ ] Nenhum teste ativo rodou fora da autorização; nenhum segredo real colado em claro.

## Resumo final
Apresentar nas cinco seções fixas do `SPEC.md` §5.6.4.
