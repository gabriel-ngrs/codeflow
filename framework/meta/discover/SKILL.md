---
versão: 1.3
status: estável
atualizado: 2026-06-18
descrição: Aprende um projeto existente e gera os artefatos iniciais do .codeflow/.
é_meta_skill: yes
granularidade: detalhado
---

# Meta-skill: discover

> **Specs de runtime:** as referências a `ARTIFACTS_SPEC.md §x` (templates e validação) e a `SPEC.md §x` ao longo deste protocolo apontam para `~/.codeflow/framework/core/ARTIFACTS_SPEC.md` e `~/.codeflow/framework/core/SPEC.md`. Leia os templates literais de lá — não parafraseie de memória.

## Quando usar

Usuário invoca `/discover` em um projeto **existente** para aprender o projeto e gerar (ou regenerar) os quatro artefatos iniciais do `.codeflow/`: `constitution.md`, `manifest.md`, `INDEX.md` e `discovered.md`. Há dois modos, decididos no Pré-flight (Fase 0):

- **Onboarding** — `.codeflow/` existe mas só com o placeholder do `install.sh` (sem `constitution.md`/`manifest.md` reais). Caminho normal: inspecionar, entrevistar e gerar os quatro artefatos do zero.
- **Refresh** — `.codeflow/` já tem artefatos reais e o usuário quer reaprender (stack mudou, manifest desatualizado, hipóteses `[pendente]` a resolver). Invocado por `/discover --refresh`, ou por `/discover` quando o Pré-flight detecta artefatos populados e o usuário confirma reaprender. O refresh **arquiva o `discovered.md` atual como snapshot datado** antes de regenerar (Fase 4a).

A meta-skill é leitura no projeto e escrita apenas em `<projeto>/.codeflow/`. Pré-requisito: `install.sh` já rodou (existe `<projeto>/.codeflow/`). Se não existir, abortar e instruir o usuário a rodar `bash ~/.codeflow/install.sh` primeiro.

## Princípio guia

Descobrir vem antes de assumir. A inspeção silenciosa precede qualquer pergunta — perguntas só existem para resolver ambiguidades **reais** que a inspeção não conseguiu resolver. Não fabricar pergunta para bater cota: perguntar sobre algo que a inspeção já respondeu é ruído, e inventar ambiguidade inexistente é a mesma alucinação que esta meta-skill combate.

**Alvo: cinco perguntas substantivas, sem teto superior.** Cinco é a expectativa para um onboarding sério, não um corte para terminar rápido. A inspeção rasa é o erro mais comum — antes de concluir que poucas perguntas bastam, confirme que a inspeção foi mesmo a fundo (todas as pastas principais amostradas, configs lidas, commits inspecionados). **Fechar com menos de cinco perguntas é permitido apenas quando a inspeção genuinamente resolveu as ambiguidades** — e nesse caso é obrigatório registrar em `## Limitações da inspeção` do `discovered.md` o que foi inferido sem perguntar e por quê (a ausência de nota com menos de cinco perguntas é, por `ARTIFACTS_SPEC.md` §2.4.6 regra 6, sinal de entrevista rasa e reprova a validação). Não há limite superior; a partir de dez perguntas a IA faz uma pausa de sanidade (descrita na Fase 2) para checar fadiga do usuário, mas pode seguir perguntando se ainda houver ambiguidade real.

## Protocolo

### Fase 0 — Pré-flight e escolha de modo

Antes de inspecionar, estabelecer o terreno. Esta fase é leitura e decisão; não gera artefato.

1. **Data canônica:** obter a data de hoje executando `date +%F` via Bash. Usar esse valor em todos os campos de data (`atualizado`, `data_inspeção`, `last_validated`). **Não** inferir a data de memória — sessão fresca pode ter noção errada de "hoje".
2. **Pré-requisito de instalação:** confirmar que `<projeto>/.codeflow/` existe. Se não existir, abortar com a mensagem: `".codeflow/ ausente — rode bash ~/.codeflow/install.sh na raiz do projeto antes de /discover."` Não criar a estrutura manualmente; isso é trabalho do `install.sh`.
3. **Detectar estado do `.codeflow/`** e escolher o modo:
   - **Onboarding** — `INDEX.md` é o placeholder do `install.sh` (contém a seção `## Placeholder` / a frase "criado por `install.sh`") **e** não existem `constitution.md` nem `manifest.md`. Seguir o fluxo normal (Fases 1→4), gerando os quatro artefatos do zero.
   - **Refresh** — já existem `constitution.md` e/ou `manifest.md` reais (não-placeholder). Então:
     - Se a invocação foi `/discover --refresh`: prosseguir em modo refresh.
     - Se foi `/discover` sem flag: **parar e avisar** — `"Este projeto já tem .codeflow/ populado (constitution.md/manifest.md). Reaprender vai regenerar os quatro artefatos e arquivar o discovered.md atual como snapshot datado. Confirma o refresh? (edições manuais na constitution serão sobrescritas — revise antes se necessário.)"`. Aguardar confirmação explícita. Sem confirmação, encerrar sem tocar em nada.
4. **Aviso de sobrescrita (apenas refresh):** a constitution/manifest/INDEX atuais serão regenerados a partir da nova inspeção+entrevista. Se o usuário mantém edições manuais nesses arquivos, recomendar que ele as revise/preserve antes de prosseguir. O `discovered.md` atual nunca é perdido — é arquivado (Fase 4a), não sobrescrito.

### Fase 1 — Inspeção silenciosa

- Ler `README.md`, arquivos de configuração de stack (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, etc.), `Makefile`, `.gitignore`, e diretivas de CI se presentes.
- Mapear estrutura de pastas até três níveis. Identificar padrão arquitetural aparente (camadas, módulos, monolito vs serviços).
- Amostrar arquivos representativos de cada pasta principal (até cinco arquivos por pasta) para inferir estilo, convenções e padrões.
- Inspecionar últimos 30 commits para inferir cadência, estilo de mensagens e áreas ativas.
- Formar hipóteses explícitas sobre: stack, padrão arquitetural, regras invariantes aparentes, áreas sensíveis. Rotular cada hipótese como `confirmada-pela-inspeção`, `precisa-confirmação` ou `precisa-pergunta`.
- Gravar checkpoint ao fim da fase (`SPEC.md` §6.6).

### Fase 2 — Entrevista qualificada (alvo: cinco perguntas, sem teto)

- Selecionar as perguntas mais informativas dentre as hipóteses `precisa-pergunta`. Priorizar inspeção mais profunda sobre perguntar — perguntar é o caminho caro, mas cobertura insuficiente é pior.
- **Alvo de cinco perguntas:** mire em pelo menos cinco perguntas substantivas. Encerrar abaixo de cinco só é legítimo quando a inspeção genuinamente resolveu as ambiguidades — e exige registrar em `## Limitações da inspeção` o que foi inferido sem perguntar e por quê (sem essa nota, menos de cinco reprova a validação §2.4.6 regra 6). Antes de encurtar, prefira reinspecionar a fabricar pergunta de baixo valor. Não há teto: projetos com vários domínios, multi-tenancy, muitas migrations ou muitos serviços justificam dez ou mais perguntas.
- Para cada pergunta: apresentar a hipótese, o que a inspeção encontrou, e a pergunta concreta com resposta binária ou enumerada quando possível.
- Pergunta ao usuário, aguardar resposta antes de prosseguir para a próxima.
- Registrar cada resposta literalmente — será incluída em `discovered.md`.
- **Pausa de sanidade ao chegar à 10ª pergunta:** antes de fazer a 11ª, exibir ao usuário a mensagem `"Já fiz 10 perguntas. Posso continuar perguntando (registrando a justificativa no discovered.md ## Limitações da inspeção), reinspecionar áreas específicas para tentar inferir sem perguntar, ou seguir para Fase 3 com as hipóteses restantes como [pendente]."`. Aguardar decisão antes de continuar. Esta pausa é sobre fadiga e ponto de parada — não é um corte: se há ambiguidade real, seguir perguntando é o esperado.
- Se o usuário escolher continuar perguntando além de dez: registrar a justificativa explícita (passada pelo usuário ou inferida pela IA) em `## Limitações da inspeção` do discovered.md.
- Apresentar resumo das hipóteses confirmadas e refutadas, e **aguardar confirmação** do usuário antes de avançar para Fase 3. Esta pausa é obrigatória.
- Gravar checkpoint imediatamente antes da confirmação (`SPEC.md` §6.6.1).

#### Como tratar respostas de incerteza

O usuário nem sempre tem uma resposta clara. Aceitar literalmente as quatro variantes abaixo. **Não insistir, não re-perguntar, não improvisar** — comportamento errado quebra a confiança e leva a IA a inventar regras especulativas na constitution.

| Resposta do usuário | Ação da IA |
|---|---|
| `não sei` / `não tenho preferência` / `passa` | Hipótese vai para `discovered.md` como `[pendente]`. **NÃO** gerar regra correspondente em `constitution.md`. Adicionar ao `## Limitações da inspeção` (do discovered) como item a resolver em `/discover --refresh` futuro. |
| `o que você recomenda?` | Apresentar 2 ou 3 opções (A/B/C) com trade-offs sucintos baseados na inspeção. Aguardar escolha. A opção escolhida vira `[confirmada]`. Se o usuário pedir mais detalhe sobre alguma, **não conta como pergunta nova** — é continuação da mesma. Se mesmo após as opções o usuário não escolher (`não sei`, `tanto faz`), tratar como incerteza: hipótese vai para `[pendente]` e segue, sem insistir. |
| `usa o padrão` / `o que for mais comum` | Aplicar o default inferido pela inspeção (ou padrão idiomático da stack quando inspeção é inconclusiva). Rotular `[confirmada]` no discovered (rótulo literal — **não** escrever `[confirmada por default]`) e citar no **texto** da hipótese qual default foi aplicado e por quê. |
| `depois eu decido` | Hipótese vai para `discovered.md` como `[pendente]`. Adicionar ao `## Limitações da inspeção` do discovered como decisão futura a resolver em `/discover --refresh`. **NÃO** gerar regra em constitution. |

Cada uma dessas respostas **encerra a pergunta atual**. A IA segue para a próxima pergunta planejada (ou para a pausa de sanidade da 10ª pergunta, se for o caso), sem retornar à mesma hipótese na mesma sessão.

### Fase 3 — Geração de constitution + manifest + INDEX

**Regra dura desta fase:** seguir os templates de `ARTIFACTS_SPEC.md` §2.1.5, §2.2.5 e §2.3.5 **literalmente** — títulos, nomes de seções e campos de frontmatter são vinculantes. Não renomear, não numerar, não traduzir, não improvisar. Os checklists abaixo são extratos das regras de validação §2.1.6, §2.2.6, §2.3.6 e existem porque execuções anteriores deste protocolo divergiram dos templates ao parafrasear nomes de seções.

#### 3a) `<projeto>/.codeflow/constitution.md` — schema §2.2.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado` (ISO), `projeto` (obrigatório — nome do projeto). Não inventar campos.

**Título exato:** `# Constitution do projeto: <nome>` — com dois pontos e `<nome>` idêntico ao valor de `projeto` no frontmatter.

**Seções obrigatórias, nesta ordem literal:**
1. `## Stack` — lista factual (linguagem, frameworks, banco, libs principais). Mesmo que repita o manifest, **não omitir**.
2. `## Padrão arquitetural` — nome do padrão (hexagonal, MVC, camadas, etc.) ou literal `Sem padrão definido — discutir com /discover --refresh`.
3. `## Regras invariantes específicas` — bullets imperativos verificáveis. No mínimo um, ou literal `Sem regras específicas além da constitution universal.`.
4. `## Áreas de alto risco` — caminhos concretos do projeto, não descrições genéricas. **Distinção:** "alto risco" é código que *pode* ser tocado, mas com cautela extra (migrations, auth, pagamentos); é diferente de "não tocar" (off-limits), que vive só no `discovered.md` §2.4 e exige declaração explícita do usuário. Não duplicar: um caminho off-limits não é "alto risco", é fora de escopo.
5. `## Definition of Done específica` — extensões do DoD universal ou literal `Sem extensões.`. **Sempre presente**, nunca omitida.

Caminhos referenciados são relativos à raiz do projeto (sem `/` ou `~/`).

#### 3b) `<projeto>/.codeflow/manifest.md` — schema §2.3.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado`, `projeto` (não-vazio), `last_validated` (ISO, = data da Fase 0), `validation_hash` (SHA-256 hexadecimal de 64 caracteres).

**Cálculo de `validation_hash` — REGRA DURA, anti-alucinação:** o hash **tem de ser computado executando o comando via Bash e colando a saída literal**. Um LLM não calcula SHA-256 de cabeça; escrever 64 caracteres hex "plausíveis" de memória é fabricar freshness falsa e está **proibido**. Comando canônico (§2.3.3):

```bash
cat <arquivo1> <arquivo2> ... <arquivoN> 2>/dev/null | sha256sum | cut -d' ' -f1
```

A lista e a ordem dos arquivos são **exatamente** as declaradas na seção `## Arquivos críticos para freshness` (decididas no item 4 abaixo). Arquivos ausentes contribuem como string vazia (o `2>/dev/null` engole o erro). Rodar o comando depois de escrever a seção 4, e copiar o resultado para o frontmatter.

**Título exato:** `# Manifest do projeto: <nome>` — com dois pontos.

**Seções obrigatórias, nesta ordem literal:**
1. `## Stack identificada` — versões exatas (ex: `Python 3.11.5`, não `Python`). Registrar a versão observada na inspeção (lockfile, `.tool-versions`, `engines`, runtime de CI); se não for observável, registrar a declarada na config e anotar que é a declarada, não a resolvida.
2. `## Comandos de validação` — mapear cada gate (`check`, `lint`, `typecheck`, `test`, `security`) para o **comando real** do projeto. **Só registrar comando que apareça literalmente** em `package.json` (scripts), `pyproject.toml`, `Makefile`, `justfile`, ou config de CI — citar de onde veio. **Proibido inventar** comando que "deveria" existir: gate sem comando com evidência fica `[—]`. Não presumir `make` nem `npm test` por hábito; registrar o efetivo (ex: `npm test`, `pytest --cov`, `cargo test`, alvo `make`). Os cinco gates sempre listados. `check` é o agregador que roda a sequência.
   - **Multi-stack (monorepo):** se o projeto tem mais de uma stack com gates distintos (ex: backend Python + frontend TS), registrar o comando por componente — seja prefixando o caminho (`(api) pytest` / `(web) npm test`), seja apontando para o runner agregador real do repo. Não achatar stacks diferentes num comando único que não existe. Se o mapeamento por componente não for inferível com segurança, marcar `[—]` e anotar em `## Notas de inspeção`.
3. `## Padrões detectados` — bullets factuais (no mínimo três). Descritivo, nunca prescritivo (regras vão na constitution). Título literal `## Padrões detectados` (origem `discover`); **não** usar `## Padrões definidos` (esse é do `bootstrap`).
4. `## Arquivos críticos para freshness` — os arquivos cujo conteúdo, se mudar, torna o manifest obsoleto. **Critério de seleção (§2.3.3):** manifest(s) de stack (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`…), lockfile(s) correspondentes, `Makefile`/`justfile`, e configs de linter/formatter/typecheck (`.eslintrc*`, `ruff.toml`, `.ruff.toml`, `tsconfig.json`, etc.) **que de fato existem no projeto**. Listar apenas arquivos inspecionados; a ordem aqui é a ordem usada no `cat` do hash.
5. `## Notas de inspeção` — registrar a data ISO da inspeção (Fase 0) e a meta-skill que gerou (`discover`).

#### 3c) `<projeto>/.codeflow/INDEX.md` — schema §2.1.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado`, `schema_version` em formato `X.Y`.

**Título exato:** `# INDEX do .codeflow/ do projeto` — sem sufixo com nome do projeto. (Variantes como `# INDEX do .codeflow/ do projeto <nome>` violam o schema.)

**Seções obrigatórias, nesta ordem literal:**
1. `## Leia sempre primeiro` — lista ordenada começando por `constitution.md` (item 1) e `manifest.md` (item 2), nesta ordem. Caminhos relativos a `.codeflow/` (escrever `constitution.md`, não `/home/...` nem `~/.../`).
2. `## Leia se relevante ao contexto` — inclui `discovered.md` (se existe), `roteiro.md` (se existe, de `/ideacao`) e `decisions/INDEX.md`.
3. `## Arquivos gerados automaticamente — não editar manualmente` — cita `checkpoints/*` e `decisions/<arquivo>.md` individuais.
4. `## Versão do schema e última atualização` — uma linha registrando `schema_version` e data ISO.

**Tamanho-alvo: 15–25 linhas.** Acima de 35 sinaliza inchaço (regra 2 de §2.1.6). Não criar seções extras (`Fora do .codeflow/`, `Áreas protegidas`, etc.) — essas informações vivem na constitution. INDEX é mapa de prioridade, não inventário.

#### 3d) Validação obrigatória antes de seguir

Para cada um dos três arquivos gerados:
1. Re-ler o arquivo do disco.
2. Confrontar **item por item** com a respectiva seção `§2.X.6` do `ARTIFACTS_SPEC.md` (validação) e `§2.X.3` (schema obrigatório).
3. Se algum item falhar: **regenerar o artefato inteiro** a partir do template §2.X.5, não corrigir parcialmente. Correções parciais tendem a deixar resíduos da versão anterior.
4. **Específico do manifest:** re-executar o comando de `validation_hash` (mesma lista, mesma ordem de `## Arquivos críticos para freshness`) via Bash e confirmar que a saída é **idêntica** ao valor no frontmatter. Divergência = hash fabricado ou lista mudou: corrigir o frontmatter com a saída real antes de seguir.
5. Só prosseguir para a Fase 4 quando os três arquivos passarem em todas as regras numeradas.
6. Gravar checkpoint ao fim da fase.

### Fase 4 — Geração de discovered.md e entrega

#### 4a-0) Arquivar o snapshot anterior (apenas no modo refresh)

Em modo refresh, o `discovered.md` atual **não é sobrescrito** — é congelado como snapshot histórico antes de gerar o novo (`SPEC.md` §4.7.1; `ARTIFACTS_SPEC.md` §2.4.1). Passos:

1. Ler o `discovered.md` existente e pegar seu `data_inspeção` (chamá-lo `<data_antiga>`).
2. Copiar o arquivo para `<projeto>/.codeflow/discovered-<data_antiga>.md` (preservar todo o conteúdo e o título `# Discovered: snapshot de <data_antiga>` inalterados).
3. No arquivo arquivado, trocar o frontmatter `superseded_by: null` por `superseded_by: discovered.md` — o snapshot vivo mais recente fica sempre em `discovered.md` (§2.4.6 regra 10). Snapshots datados pré-existentes já apontam para `discovered.md` e não precisam ser re-tocados.
4. Prosseguir para 4a) escrevendo o **novo** `discovered.md` com `superseded_by: null`.

Em modo onboarding (não há `discovered.md` prévio) este passo é pulado.

#### 4a) `<projeto>/.codeflow/discovered.md` — schema §2.4.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado`, `data_inspeção` (ISO, = data da Fase 0), `meta_skill: discover` (valor fixo, literal), `superseded_by: null` (o snapshot vivo é sempre `discovered.md` e leva `null`; o `null` só vira `discovered.md` na cópia arquivada de 4a-0). Não usar `gerado_por` nem outras variantes.

**Título exato:** `# Discovered: snapshot de <data>` — com a data idêntica ao `data_inspeção` do frontmatter.

**Seções obrigatórias, nesta ordem literal e sem numeração:**
1. `## O que foi inspecionado` — lista cronológica (no mínimo três itens).
2. `## Hipóteses formadas` — cada hipótese começa com rótulo **literal entre colchetes**: exatamente `[confirmada]`, `[refutada]` ou `[pendente]` — três valores, nenhum outro. A origem da confirmação (inspeção, usuário, default) vai no **texto** da hipótese, **nunca dentro dos colchetes**. As etiquetas de trabalho da Fase 1 (`confirmada-pela-inspeção`, `precisa-confirmação`, `precisa-pergunta`) são internas e **não** vão para o discovered — mapeie cada uma para o rótulo literal ao escrever.
   - **Forma correta:** `[confirmada] Multi-tenancy via header X-Tenant-ID (confirmada pelo usuário na pergunta 3).` · `[confirmada] Pydantic em entrada e saída de endpoint (default idiomático aplicado — usuário respondeu "usa o padrão").` · `[pendente] Estratégia de cache — usuário respondeu "depois eu decido".`
   - **Forma incorreta (proibida):** `[confirmada por usuário]` · `[confirmada — divergente da memória local]` · `[confirmada pela inspeção]` · `[confirmada por default]` · `[pendente de decisão]`. Qualquer texto dentro dos colchetes além das três palavras literais é desvio de schema.
3. `## Perguntas feitas ao usuário e respostas` — todas as perguntas feitas, cada uma com resposta declarada. Alvo de cinco; abaixo disso exige nota de inspeção conclusiva em `## Limitações da inspeção`, e ao passar de dez registrar justificativa na mesma seção (`SPEC.md` §4.4.2; `ARTIFACTS_SPEC.md` §2.4.6 regra 6).
4. `## Áreas marcadas como "não tocar"` — caminhos concretos do projeto ou literal `Nenhuma.`.
5. `## Artefatos gerados a partir deste discovered` — cita ao menos `constitution.md`, `manifest.md`, `INDEX.md`.

Seções extras (anexos, padrões qualitativos, lacunas) só são permitidas conforme `§2.4.4` (opcional) e **depois** das obrigatórias.

#### 4b) Validação e entrega

- Confrontar `discovered.md` item por item com `§2.4.6`. Em falha, regenerar do template §2.4.5 (não corrigir parcialmente).
- Apresentar ao usuário o resumo dos quatro artefatos gerados (caminho + tamanho de cada).
- Perguntar se algum precisa de ajuste antes de fechar (esta é a única pergunta da Fase 4 e não conta no alvo de cinco da Fase 2).
- Aguardar resposta. Aplicar ajustes solicitados re-rodando a validação correspondente. Após confirmação final, encerrar.

## Proibições durante esta meta-skill

- Não pular a Fase 0 (pré-flight): rodar sem confirmar que `.codeflow/` existe, sem obter a data via `date +%F`, ou regenerar artefatos populados sem confirmação do usuário viola o protocolo.
- Não encerrar a entrevista abaixo de cinco perguntas sem (a) inspeção genuinamente conclusiva e (b) a nota correspondente em `## Limitações da inspeção`. E não fabricar pergunta de baixo valor só para bater o alvo de cinco — inventar ambiguidade é alucinação.
- Não pular a pausa de sanidade ao chegar à 10ª pergunta. Continuar para a 11ª sem exibir a mensagem e aguardar decisão do usuário viola o protocolo.
- Não pular a Fase 1 (inspeção silenciosa). Perguntar sem inspecionar viola o princípio guia.
- Não reformular a mesma pergunta após uma resposta de incerteza (`não sei`, `passa`, `depois eu decido`) na mesma sessão. Hipótese vai para `[pendente]` e segue.
- Não gerar regra em `constitution.md` a partir de hipótese `[pendente]`. Constitution só ganha regra quando o usuário confirmou.
- Não gerar constitution com regras inferidas que o usuário não confirmou.
- **Não escrever `validation_hash` de memória.** O hash é sempre a saída literal do comando `sha256sum` rodado via Bash sobre os arquivos de `## Arquivos críticos para freshness`. Fabricar 64 hex "plausíveis" é proibido.
- **Não inventar comando de validação.** Só registrar gate cujo comando aparece em config real do projeto (com fonte); o resto fica `[—]`.
- Não inferir áreas "não tocar" sem confirmação explícita do usuário.
- Em refresh, não sobrescrever nem apagar o `discovered.md` anterior: arquivá-lo como `discovered-<data_antiga>.md` (Fase 4a-0) antes de gerar o novo.
- Não modificar arquivos do projeto fora de `<projeto>/.codeflow/`. `discover` é leitura no projeto e escrita apenas no `.codeflow/`.

## Template de saída

Esta meta-skill gera quatro artefatos. Selecionar template conforme tipo:

- **`INDEX.md`:** template em `ARTIFACTS_SPEC.md` §2.1.5.
- **`constitution.md`:** template em `ARTIFACTS_SPEC.md` §2.2.5.
- **`manifest.md`:** template em `ARTIFACTS_SPEC.md` §2.3.5.
- **`discovered.md`:** template em `ARTIFACTS_SPEC.md` §2.4.5.

Substituir placeholders com valores coletados na inspeção e na entrevista. Datas em formato ISO `AAAA-MM-DD`, sempre a obtida na Fase 0 via `date +%F` — nunca inferida de memória.

## Onde salvar

Todos os quatro artefatos vão para `<projeto>/.codeflow/`:

- `<projeto>/.codeflow/INDEX.md`
- `<projeto>/.codeflow/constitution.md`
- `<projeto>/.codeflow/manifest.md`
- `<projeto>/.codeflow/discovered.md`

Em modo refresh, há ainda o snapshot arquivado `<projeto>/.codeflow/discovered-<data_antiga>.md` (Fase 4a-0).

Nenhum arquivo é gerado fora de `<projeto>/.codeflow/`. Estrutura de pastas do projeto não é modificada por esta meta-skill.

## Validação pós-geração

- Aplicar `ARTIFACTS_SPEC.md` §2.1.6 a `INDEX.md`.
- Aplicar `ARTIFACTS_SPEC.md` §2.2.6 a `constitution.md`.
- Aplicar `ARTIFACTS_SPEC.md` §2.3.6 a `manifest.md`.
- Aplicar `ARTIFACTS_SPEC.md` §2.4.6 a `discovered.md`.
- Verificar coerência entre arquivos, em ambas as direções (não só prosa — confrontar item a item):
  - **discovered → constitution:** toda hipótese `[confirmada]` de natureza normativa vira uma regra em `## Regras invariantes específicas` da constitution, ou é explicitamente registrada como não-normativa. Nenhuma hipótese `[pendente]`/`[refutada]` gera regra.
  - **constitution → discovered:** toda regra em `## Regras invariantes específicas` rastreia até uma hipótese `[confirmada]`. Regra sem hipótese de origem = regra inventada → remover.
  - **manifest ↔ realidade:** cada item de `## Stack identificada` e cada comando em `## Comandos de validação` foi observado na inspeção (com fonte citável). Nenhum comando sem evidência.
  - **discovered → não tocar:** cada caminho em `## Áreas marcadas como "não tocar"` foi declarado pelo usuário (não inferido).
- Apresentar resumo final ao usuário com caminhos dos quatro arquivos e contagem de regras/comandos/hipóteses (e, em refresh, o nome do snapshot arquivado).

## Retomada

`discover` é detalhado e usa checkpoints (`SPEC.md` §6.6). Ao iniciar:

- Verificar se existe `<projeto>/.codeflow/checkpoints/discover-*.md` recente.
- Se sim: apresentar resumo do checkpoint e perguntar ao usuário se deseja retomar daquele ponto ou começar do zero.
- Se retomar: carregar fase em pausa, ações já realizadas, decisões tomadas. Continuar a partir da Fase indicada.
- Se começar do zero: deletar checkpoint antigo, reiniciar da Fase 0.

## Saídas válidas

- **Onboarding concluído:** quatro artefatos (`INDEX.md`, `constitution.md`, `manifest.md`, `discovered.md`) gerados em `<projeto>/.codeflow/`, cada um passando nas regras de validação correspondentes. Resumo apresentado ao usuário.
- **Refresh concluído:** o `discovered.md` anterior foi arquivado como `discovered-<data_antiga>.md` (com `superseded_by: discovered.md`) e os quatro artefatos foram regenerados e validados. Resumo apresentado com o nome do snapshot arquivado.
- **Abortado no pré-flight:** `.codeflow/` ausente, ou usuário não confirmou o refresh de artefatos populados. Nada é escrito.
- **Descoberta abortada:** usuário interrompe na Fase 2 ou Fase 3 sem aprovar. Checkpoint preservado para retomada futura. Nenhum artefato final é gerado; em refresh, o `discovered.md` original permanece intocado (o arquivamento só ocorre na Fase 4a, após a aprovação da Fase 2).
