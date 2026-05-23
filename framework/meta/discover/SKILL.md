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

Descobrir vem antes de assumir. A inspeção silenciosa precede qualquer pergunta — perguntas só são feitas para resolver ambiguidades reais que a inspeção não consegue resolver. Limite duro: cinco perguntas no total. Mais que isso indica que a inspeção foi superficial.

## Protocolo

### Fase 1 — Inspeção silenciosa

- Ler `README.md`, arquivos de configuração de stack (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, etc.), `Makefile`, `.gitignore`, e diretivas de CI se presentes.
- Mapear estrutura de pastas até três níveis. Identificar padrão arquitetural aparente (camadas, módulos, monolito vs serviços).
- Amostrar arquivos representativos de cada pasta principal (até cinco arquivos por pasta) para inferir estilo, convenções e padrões.
- Inspecionar últimos 30 commits para inferir cadência, estilo de mensagens e áreas ativas.
- Formar hipóteses explícitas sobre: stack, padrão arquitetural, regras invariantes aparentes, áreas sensíveis. Rotular cada hipótese como `confirmada-pela-inspeção`, `precisa-confirmação` ou `precisa-pergunta`.
- Gravar checkpoint ao fim da fase (`SPEC.md` §6.6).

### Fase 2 — Entrevista qualificada (máximo cinco perguntas)

- Selecionar no máximo **cinco** perguntas mais informativas dentre as hipóteses `precisa-pergunta`. Limite duro de `SPEC.md` §4.4.2.
- Para cada pergunta: apresentar a hipótese, o que a inspeção encontrou, e a pergunta concreta com resposta binária ou enumerada quando possível.
- Pergunta ao usuário, aguardar resposta antes de prosseguir para a próxima.
- Registrar cada resposta literalmente — será incluída em `discovered.md`.
- Apresentar resumo das hipóteses confirmadas e refutadas, e **aguardar confirmação** do usuário antes de avançar para Fase 3. Esta pausa é obrigatória.
- Gravar checkpoint imediatamente antes da confirmação (`SPEC.md` §6.6.1).

### Fase 3 — Geração de constitution + manifest + INDEX

- Gerar `<projeto>/.codeflow/constitution.md` aplicando o template de `ARTIFACTS_SPEC.md` §2.2.5. Incluir apenas regras confirmadas pela inspeção ou pelo usuário. Sem regras especulativas.
- Gerar `<projeto>/.codeflow/manifest.md` aplicando o template de `ARTIFACTS_SPEC.md` §2.3.5. Incluir: stack detectada, comandos make canônicos, padrões arquiteturais, arquivos críticos para freshness.
- Gerar `<projeto>/.codeflow/INDEX.md` aplicando o template de `ARTIFACTS_SPEC.md` §2.1.5. Listar `constitution.md` e `manifest.md` em `## Leia sempre primeiro`.
- Aplicar `## Validação pós-geração` em cada arquivo antes de avançar.
- Gravar checkpoint ao fim da fase.

### Fase 4 — Geração de discovered.md e entrega

- Gerar `<projeto>/.codeflow/discovered.md` aplicando o template de `ARTIFACTS_SPEC.md` §2.4.5. Registrar: o que foi inspecionado, hipóteses formadas (com rótulo final), perguntas feitas ao usuário e respostas, áreas marcadas como "não tocar", artefatos gerados.
- Apresentar ao usuário o resumo dos quatro artefatos gerados, cada um com caminho e tamanho. Pergunta ao usuário se algum precisa de ajuste antes de fechar.
- Aguardar resposta. Aplicar ajustes solicitados, re-rodar validação. Após confirmação final, encerrar.

## Proibições durante esta meta-skill

- Não fazer mais que cinco perguntas ao usuário em toda a execução. Limite duro de `SPEC.md` §4.4.2.
- Não pular a Fase 1 (inspeção silenciosa). Perguntar sem inspecionar viola o princípio guia.
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
