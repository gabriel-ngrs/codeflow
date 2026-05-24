---
versão: 1.0
status: estável
atualizado: 2026-05-23
descrição: Aprende um projeto existente e gera os artefatos iniciais do .codeflow/.
é_meta_skill: yes
granularidade: detalhado
---

# Meta-skill: discover

## Quando usar

Usuário invoca `/discover` em um projeto **existente** que ainda não tem `.codeflow/` populado (ou que precisa reaprender do zero). A meta-skill inspeciona o projeto, conduz entrevista qualificada, e gera os quatro artefatos iniciais: `constitution.md`, `manifest.md`, `INDEX.md` e `discovered.md`.

## Princípio guia

Descobrir vem antes de assumir. A inspeção silenciosa precede qualquer pergunta — perguntas só são feitas para resolver ambiguidades reais que a inspeção não consegue resolver. **Orientação: até cinco perguntas.** Não é limite duro: quando passar de cinco, a IA emite aviso ao usuário ("já fiz 5 perguntas; isso geralmente indica que a inspeção foi superficial — posso continuar perguntando, ou prefere que eu reinspecione antes?") e aguarda decisão antes da próxima pergunta. Passar de cinco com justificativa registrada em `## Limitações da inspeção` é aceitável (projetos genuinamente complexos existem); passar sem justificativa é débito técnico.

## Protocolo

### Fase 1 — Inspeção silenciosa

- Ler `README.md`, arquivos de configuração de stack (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, etc.), `Makefile`, `.gitignore`, e diretivas de CI se presentes.
- Mapear estrutura de pastas até três níveis. Identificar padrão arquitetural aparente (camadas, módulos, monolito vs serviços).
- Amostrar arquivos representativos de cada pasta principal (até cinco arquivos por pasta) para inferir estilo, convenções e padrões.
- Inspecionar últimos 30 commits para inferir cadência, estilo de mensagens e áreas ativas.
- Formar hipóteses explícitas sobre: stack, padrão arquitetural, regras invariantes aparentes, áreas sensíveis. Rotular cada hipótese como `confirmada-pela-inspeção`, `precisa-confirmação` ou `precisa-pergunta`.
- Gravar checkpoint ao fim da fase (`SPEC.md` §6.6).

### Fase 2 — Entrevista qualificada (orientação: até cinco perguntas)

- Selecionar as perguntas mais informativas dentre as hipóteses `precisa-pergunta`. Priorizar inspeção mais profunda sobre perguntar — perguntar é o caminho caro.
- Para cada pergunta: apresentar a hipótese, o que a inspeção encontrou, e a pergunta concreta com resposta binária ou enumerada quando possível.
- Pergunta ao usuário, aguardar resposta antes de prosseguir para a próxima.
- Registrar cada resposta literalmente — será incluída em `discovered.md`.
- **Aviso obrigatório ao chegar à 5ª pergunta:** antes de fazer a 6ª, exibir ao usuário a mensagem `"Já fiz 5 perguntas — isso geralmente indica que a inspeção foi superficial. Posso continuar perguntando (registrando a justificativa no discovered.md ## Limitações da inspeção), reinspecionar áreas específicas para tentar inferir sem perguntar, ou seguir para Fase 3 com as hipóteses restantes como [pendente]."`. Aguardar decisão antes de continuar.
- Se o usuário escolher continuar perguntando: registrar a justificativa explícita (passada pelo usuário ou inferida pela IA) em `## Limitações da inspeção` do discovered.md.
- Apresentar resumo das hipóteses confirmadas e refutadas, e **aguardar confirmação** do usuário antes de avançar para Fase 3. Esta pausa é obrigatória.
- Gravar checkpoint imediatamente antes da confirmação (`SPEC.md` §6.6.1).

#### Como tratar respostas de incerteza

O usuário nem sempre tem uma resposta clara. Aceitar literalmente as quatro variantes abaixo. **Não insistir, não re-perguntar, não improvisar** — comportamento errado quebra a confiança e leva a IA a inventar regras especulativas na constitution.

| Resposta do usuário | Ação da IA |
|---|---|
| `não sei` / `não tenho preferência` / `passa` | Hipótese vai para `discovered.md` como `[pendente]`. **NÃO** gerar regra correspondente em `constitution.md`. Adicionar ao `## Limitações da inspeção` (do discovered) como item a resolver em `/discover --refresh` futuro. |
| `o que você recomenda?` | Apresentar 2 ou 3 opções (A/B/C) com trade-offs sucintos baseados na inspeção. Aguardar escolha. A opção escolhida vira `[confirmada]`. Se o usuário pedir mais detalhe sobre alguma, **não conta como pergunta nova** — é continuação da mesma. |
| `usa o padrão` / `o que for mais comum` | Aplicar o default inferido pela inspeção (ou padrão idiomático da stack quando inspeção é inconclusiva). Marcar como `[confirmada por default]` no discovered, citando explicitamente qual default foi aplicado. |
| `depois eu decido` | Hipótese vai para `discovered.md` como `[pendente]`. Adicionar ao `## Lacunas conhecidas` do discovered como decisão futura. **NÃO** gerar regra em constitution. |

Cada uma dessas respostas **encerra a pergunta atual**. A IA segue para a próxima pergunta planejada (ou para o aviso de 5ª pergunta, se for o caso), sem retornar à mesma hipótese na mesma sessão.

### Fase 3 — Geração de constitution + manifest + INDEX

**Regra dura desta fase:** seguir os templates de `ARTIFACTS_SPEC.md` §2.1.5, §2.2.5 e §2.3.5 **literalmente** — títulos, nomes de seções e campos de frontmatter são vinculantes. Não renomear, não numerar, não traduzir, não improvisar. Os checklists abaixo são extratos das regras de validação §2.1.6, §2.2.6, §2.3.6 e existem porque execuções anteriores deste protocolo divergiram dos templates ao parafrasear nomes de seções.

#### 3a) `<projeto>/.codeflow/constitution.md` — schema §2.2.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado` (ISO), `projeto` (obrigatório — nome do projeto). Não inventar campos.

**Título exato:** `# Constitution do projeto: <nome>` — com dois pontos e `<nome>` idêntico ao valor de `projeto` no frontmatter.

**Seções obrigatórias, nesta ordem literal:**
1. `## Stack` — lista factual (linguagem, frameworks, banco, libs principais). Mesmo que repita o manifest, **não omitir**.
2. `## Padrão arquitetural` — nome do padrão (hexagonal, MVC, camadas, etc.) ou literal `Sem padrão definido — discutir com /discover --refresh`.
3. `## Regras invariantes específicas` — bullets imperativos verificáveis. No mínimo um, ou literal `Sem regras específicas além da constitution universal.`.
4. `## Áreas de alto risco` — caminhos concretos do projeto, não descrições genéricas.
5. `## Definition of Done específica` — extensões do DoD universal ou literal `Sem extensões.`. **Sempre presente**, nunca omitida.

Caminhos referenciados são relativos à raiz do projeto (sem `/` ou `~/`).

#### 3b) `<projeto>/.codeflow/manifest.md` — schema §2.3.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado`, `projeto` (não-vazio), `last_validated` (ISO), `validation_hash` (SHA-256 hexadecimal de 64 caracteres).

**Cálculo de `validation_hash`** — comando canônico (§2.3.3): `cat <arquivo1> <arquivo2> ... <arquivoN> 2>/dev/null | sha256sum | cut -d' ' -f1`. A ordem dos arquivos é a mesma que aparece em `## Arquivos críticos para freshness`. Arquivos ausentes contribuem como string vazia.

**Título exato:** `# Manifest do projeto: <nome>` — com dois pontos.

**Seções obrigatórias, nesta ordem literal:**
1. `## Stack identificada` — versões exatas (ex: `Python 3.11.5`, não `Python`).
2. `## Comandos make canônicos` — mapeia `check`, `test`, `lint`, `typecheck` para os comandos efetivos. Targets ausentes ficam como `[—]`. Os quatro sempre listados.
3. `## Padrões detectados` — bullets factuais (no mínimo três). Descritivo, nunca prescritivo (regras vão na constitution).
4. `## Arquivos críticos para freshness` — lista dos arquivos usados no `validation_hash`, na mesma ordem.
5. `## Notas de inspeção` — registrar data ISO da inspeção e a meta-skill que gerou (`discover` ou `bootstrap`).

#### 3c) `<projeto>/.codeflow/INDEX.md` — schema §2.1.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado`, `schema_version` em formato `X.Y`.

**Título exato:** `# INDEX do .codeflow/ do projeto` — sem sufixo com nome do projeto. (Variantes como `# INDEX do .codeflow/ do projeto <nome>` violam o schema.)

**Seções obrigatórias, nesta ordem literal:**
1. `## Leia sempre primeiro` — lista ordenada começando por `constitution.md` (item 1) e `manifest.md` (item 2), nesta ordem. Caminhos relativos a `.codeflow/` (escrever `constitution.md`, não `/home/...` nem `~/.../`).
2. `## Leia se relevante ao contexto` — inclui `discovered.md` (se existe) e `decisions/INDEX.md`.
3. `## Arquivos gerados automaticamente — não editar manualmente` — cita `checkpoints/*` e `decisions/<arquivo>.md` individuais.
4. `## Versão do schema e última atualização` — uma linha registrando `schema_version` e data ISO.

**Tamanho-alvo: 15–25 linhas.** Acima de 35 sinaliza inchaço (regra 2 de §2.1.6). Não criar seções extras (`Fora do .codeflow/`, `Áreas protegidas`, etc.) — essas informações vivem na constitution. INDEX é mapa de prioridade, não inventário.

#### 3d) Validação obrigatória antes de seguir

Para cada um dos três arquivos gerados:
1. Re-ler o arquivo do disco.
2. Confrontar **item por item** com a respectiva seção `§2.X.6` do `ARTIFACTS_SPEC.md` (validação) e `§2.X.3` (schema obrigatório).
3. Se algum item falhar: **regenerar o artefato inteiro** a partir do template §2.X.5, não corrigir parcialmente. Correções parciais tendem a deixar resíduos da versão anterior.
4. Só prosseguir para a Fase 4 quando os três arquivos passarem em todas as regras numeradas.
5. Gravar checkpoint ao fim da fase.

### Fase 4 — Geração de discovered.md e entrega

#### 4a) `<projeto>/.codeflow/discovered.md` — schema §2.4.3

**Frontmatter obrigatório:** `versão`, `status`, `atualizado`, `data_inspeção` (ISO), `meta_skill: discover` (valor fixo, literal), `superseded_by: null` (literal `null` no snapshot mais recente; nome de snapshot mais recente quando este for substituído). Não usar `gerado_por` nem outras variantes.

**Título exato:** `# Discovered: snapshot de <data>` — com a data idêntica ao `data_inspeção` do frontmatter.

**Seções obrigatórias, nesta ordem literal e sem numeração:**
1. `## O que foi inspecionado` — lista cronológica (no mínimo três itens).
2. `## Hipóteses formadas` — cada hipótese começa com rótulo **literal entre colchetes**: `[confirmada]`, `[refutada]` ou `[pendente]`. Não usar variantes como `confirmada-pela-inspeção`, `confirmada pelo usuário`, etc. — registrar a origem da confirmação no texto da hipótese, mas o rótulo de estado entre colchetes é vinculante.
3. `## Perguntas feitas ao usuário e respostas` — todas as perguntas feitas, cada uma com resposta declarada. Orientação de cinco; quando passar, registrar justificativa em `## Limitações da inspeção` (`SPEC.md` §4.4.2; `ARTIFACTS_SPEC.md` §2.4.6 regra 6).
4. `## Áreas marcadas como "não tocar"` — caminhos concretos do projeto ou literal `Nenhuma.`.
5. `## Artefatos gerados a partir deste discovered` — cita ao menos `constitution.md`, `manifest.md`, `INDEX.md`.

Seções extras (anexos, padrões qualitativos, lacunas) só são permitidas conforme `§2.4.4` (opcional) e **depois** das obrigatórias.

#### 4b) Validação e entrega

- Confrontar `discovered.md` item por item com `§2.4.6`. Em falha, regenerar do template §2.4.5 (não corrigir parcialmente).
- Apresentar ao usuário o resumo dos quatro artefatos gerados (caminho + tamanho de cada).
- Perguntar se algum precisa de ajuste antes de fechar (esta é a única pergunta da Fase 4 e não conta no limite de cinco da Fase 2).
- Aguardar resposta. Aplicar ajustes solicitados re-rodando a validação correspondente. Após confirmação final, encerrar.

## Proibições durante esta meta-skill

- Não pular o aviso ao chegar à 5ª pergunta. Continuar para a 6ª sem exibir a mensagem e aguardar decisão do usuário viola o protocolo.
- Não pular a Fase 1 (inspeção silenciosa). Perguntar sem inspecionar viola o princípio guia.
- Não reformular a mesma pergunta após uma resposta de incerteza (`não sei`, `passa`, `depois eu decido`) na mesma sessão. Hipótese vai para `[pendente]` e segue.
- Não gerar regra em `constitution.md` a partir de hipótese `[pendente]`. Constitution só ganha regra quando o usuário confirmou.
- Não gerar constitution com regras inferidas que o usuário não confirmou.
- Não gerar `manifest.md` com `validation_hash` baseado em arquivos que não foram inspecionados.
- Não inferir áreas "não tocar" sem confirmação explícita do usuário.
- Não modificar arquivos do projeto fora de `<projeto>/.codeflow/`. `discover` é leitura no projeto e escrita apenas no `.codeflow/`.

## Template de saída

Esta meta-skill gera quatro artefatos. Selecionar template conforme tipo:

- **`INDEX.md`:** template em `ARTIFACTS_SPEC.md` §2.1.5.
- **`constitution.md`:** template em `ARTIFACTS_SPEC.md` §2.2.5.
- **`manifest.md`:** template em `ARTIFACTS_SPEC.md` §2.3.5.
- **`discovered.md`:** template em `ARTIFACTS_SPEC.md` §2.4.5.

Substituir placeholders com valores coletados na inspeção e na entrevista. Datas em formato ISO `AAAA-MM-DD` no fuso local da máquina.

## Onde salvar

Todos os quatro artefatos vão para `<projeto>/.codeflow/`:

- `<projeto>/.codeflow/INDEX.md`
- `<projeto>/.codeflow/constitution.md`
- `<projeto>/.codeflow/manifest.md`
- `<projeto>/.codeflow/discovered.md`

Nenhum arquivo é gerado fora de `<projeto>/.codeflow/`. Estrutura de pastas do projeto não é modificada por esta meta-skill.

## Validação pós-geração

- Aplicar `ARTIFACTS_SPEC.md` §2.1.6 a `INDEX.md`.
- Aplicar `ARTIFACTS_SPEC.md` §2.2.6 a `constitution.md`.
- Aplicar `ARTIFACTS_SPEC.md` §2.3.6 a `manifest.md`.
- Aplicar `ARTIFACTS_SPEC.md` §2.4.6 a `discovered.md`.
- Verificar coerência entre arquivos: cada hipótese confirmada no `discovered.md` que vira regra invariante aparece também na `constitution.md`; cada stack/comando detectado e validado aparece no `manifest.md`.
- Apresentar resumo final ao usuário com caminhos dos quatro arquivos e contagem de regras/comandos/hipóteses.

## Retomada

`discover` é detalhado e usa checkpoints (`SPEC.md` §6.6). Ao iniciar:

- Verificar se existe `<projeto>/.codeflow/checkpoints/discover-*.md` recente.
- Se sim: apresentar resumo do checkpoint e perguntar ao usuário se deseja retomar daquele ponto ou começar do zero.
- Se retomar: carregar fase em pausa, ações já realizadas, decisões tomadas. Continuar a partir da Fase indicada.
- Se começar do zero: deletar checkpoint antigo, reiniciar Fase 1.

## Saídas válidas

- **Quatro artefatos gerados:** `INDEX.md`, `constitution.md`, `manifest.md`, `discovered.md` em `<projeto>/.codeflow/`, cada um passando nas regras de validação correspondentes. Resumo apresentado ao usuário.
- **Descoberta abortada:** usuário interrompe na Fase 2 ou Fase 3 sem aprovar. Checkpoint preservado para retomada futura. Nenhum arquivo final em `.codeflow/` é gerado neste caso.
