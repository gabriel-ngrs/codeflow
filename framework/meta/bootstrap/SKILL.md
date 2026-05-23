---
versão: 1.0
status: estável
atualizado: 2026-05-23
descrição: Cria um projeto novo a partir de ideia, com estrutura mínima e artefatos do .codeflow/.
é_meta_skill: yes
granularidade: detalhado
---

# Meta-skill: bootstrap

## Quando usar

Usuário invoca `/bootstrap` quando quer criar um projeto **novo** a partir de uma ideia, sem código pré-existente. A meta-skill conduz coleta de requisitos, decide stack e estrutura, gera o esqueleto do projeto e os artefatos iniciais do `.codeflow/` (`constitution.md`, `manifest.md`, `INDEX.md`). Não gera `discovered.md` — não há projeto pré-existente a descobrir (`ARTIFACTS_SPEC.md` §2.4.1).

## Princípio guia

Projeto novo nasce com decisões mínimas explícitas: propósito, stack, padrão arquitetural, regras invariantes. O bootstrap não tenta antecipar features futuras — entrega o esqueleto suficiente para começar, com Makefile canônico e codeflow integrado. Decisões adiáveis ficam adiadas e documentadas como pendentes.

## Protocolo

### Fase 1 — Coleta de requisitos

- Pergunta ao usuário: nome do projeto (kebab-case), propósito em uma frase, tipo de projeto (CLI, biblioteca, serviço web, app desktop, etc.).
- Pergunta sobre licença pretendida (default sugerido: MIT) e idioma da documentação voltada ao usuário final.
- Pergunta se há restrições conhecidas: dependências proibidas, padrão arquitetural exigido, áreas sensíveis a planejar desde já.
- Apresentar plano de coleta (resumo das respostas) ao usuário e aguardar confirmação antes de avançar. Esta pausa é obrigatória.
- Gravar checkpoint ao fim da fase (`SPEC.md` §6.6).

### Fase 2 — Decisão de stack e estrutura

- Propor stack concreta (linguagem, versão, gerenciador de pacotes, framework principal se aplicável) compatível com tipo de projeto e restrições da Fase 1.
- Propor padrão arquitetural inicial (camadas mínimas, organização de pastas).
- Propor lista de targets do Makefile, mínimo cobrindo `check`, `test`, `lint`, `typecheck`.
- Pergunta ao usuário se aprova as propostas. Aceitar contraproposta e iterar até confirmação.
- Aguardar resposta final do usuário antes de avançar. Esta pausa é obrigatória.
- Gravar checkpoint ao fim da fase.

### Fase 3 — Geração de estrutura mínima do projeto

- Criar pastas conforme decisão da Fase 2.
- Criar `<projeto>/README.md` esqueleto (título, descrição em uma frase, seção de setup, seção de licença).
- Criar `<projeto>/Makefile` com os quatro targets canônicos (`check`, `test`, `lint`, `typecheck`). Cada target chama os comandos reais da stack escolhida, ou imprime `noop` quando ainda não há comando real definido.
- Criar `<projeto>/.gitignore` com entradas mínimas: artefatos de build da stack, `.codeflow/checkpoints/`, arquivos de IDE comuns.
- Criar `<projeto>/LICENSE` com texto da licença escolhida.
- Gravar checkpoint ao fim da fase.

### Fase 4 — Geração de artefatos do `.codeflow/`

- Gerar `<projeto>/.codeflow/constitution.md` aplicando o template de `ARTIFACTS_SPEC.md` §2.2.5. Incluir princípios derivados das restrições e decisões das Fases 1 e 2.
- Gerar `<projeto>/.codeflow/manifest.md` aplicando o template de `ARTIFACTS_SPEC.md` §2.3.5. Incluir: stack decidida, comandos make, padrões arquiteturais, arquivos críticos para freshness.
- Gerar `<projeto>/.codeflow/INDEX.md` aplicando o template de `ARTIFACTS_SPEC.md` §2.1.5. Listar `constitution.md` e `manifest.md` em `## Leia sempre primeiro`. **Não** referenciar `discovered.md` — bootstrap não o gera.
- Aplicar `## Validação pós-geração` em cada arquivo antes de avançar.
- Gravar checkpoint ao fim da fase.

### Fase 5 — Entrega e próximos passos

- Apresentar ao usuário o resumo: árvore de pastas criadas, arquivos gerados (raiz + `.codeflow/`), próximos passos sugeridos.
- Sugerir comandos imediatos: `git init` no projeto, primeiro commit, instalar dependências da stack.
- Aguardar resposta do usuário. Aplicar ajustes solicitados, re-rodar validação. Após confirmação final, encerrar.

## Proibições durante esta meta-skill

- Não gerar `discovered.md`. `bootstrap` cria projeto novo; não há descoberta. Confunde-se com `discover` (`ARTIFACTS_SPEC.md` §2.4.1).
- Não escolher stack sem confirmação explícita do usuário na Fase 2.
- Não criar arquivos de código de aplicação (módulos, componentes, endpoints) — apenas esqueleto mínimo. Features são responsabilidade de workflows posteriores.
- Não baixar dependências nem rodar instaladores. Bootstrap gera arquivos; o usuário roda comandos da stack.
- Não criar projeto em diretório que já contém arquivos. Bootstrap exige diretório vazio (ou criar novo diretório).
- Não inventar regras invariantes na constitution sem ancorar em decisão tomada nas Fases 1 ou 2.

## Template de saída

Esta meta-skill gera três artefatos do `.codeflow/` mais arquivos esqueleto do projeto. Selecionar template conforme tipo:

- **`INDEX.md`:** template em `ARTIFACTS_SPEC.md` §2.1.5.
- **`constitution.md`:** template em `ARTIFACTS_SPEC.md` §2.2.5.
- **`manifest.md`:** template em `ARTIFACTS_SPEC.md` §2.3.5.
- **Makefile, README.md, .gitignore, LICENSE:** esqueletos mínimos descritos na Fase 3, sem template formal.

Substituir placeholders com valores coletados nas Fases 1 e 2. Datas em formato ISO `AAAA-MM-DD` no fuso local da máquina.

## Onde salvar

Dois conjuntos de destinos:

- **Artefatos do codeflow** (gerados nesta meta-skill): `<projeto>/.codeflow/INDEX.md`, `<projeto>/.codeflow/constitution.md`, `<projeto>/.codeflow/manifest.md`.
- **Arquivos do projeto** (estrutura mínima): `<projeto>/README.md`, `<projeto>/Makefile`, `<projeto>/.gitignore`, `<projeto>/LICENSE`, e pastas decididas na Fase 2.

Nenhum arquivo é criado em `~/.codeflow/` por esta meta-skill.

## Validação pós-geração

- Aplicar `ARTIFACTS_SPEC.md` §2.1.6 a `INDEX.md`.
- Aplicar `ARTIFACTS_SPEC.md` §2.2.6 a `constitution.md`.
- Aplicar `ARTIFACTS_SPEC.md` §2.3.6 a `manifest.md`.
- Verificar que `INDEX.md` **não** referencia `discovered.md` (bootstrap não o gera).
- Verificar que `Makefile` tem os quatro targets canônicos (`check`, `test`, `lint`, `typecheck`).
- Verificar que `<projeto>/.codeflow/checkpoints/` está listado no `.gitignore` do projeto.
- Apresentar resumo final ao usuário com caminhos dos arquivos gerados.

## Retomada

`bootstrap` é detalhado e usa checkpoints (`SPEC.md` §6.6). Ao iniciar:

- Verificar se existe `<projeto>/.codeflow/checkpoints/bootstrap-*.md` recente.
- Se sim: apresentar resumo do checkpoint e perguntar ao usuário se deseja retomar daquele ponto ou começar do zero.
- Se retomar: carregar fase em pausa, decisões tomadas (stack, padrão, targets). Continuar a partir da Fase indicada.
- Se começar do zero: deletar checkpoint antigo, reiniciar Fase 1. Confirmar com o usuário que arquivos já criados em fases anteriores podem ser sobrescritos.

## Saídas válidas

- **Projeto criado:** estrutura mínima do projeto + três artefatos em `<projeto>/.codeflow/`, cada um passando nas regras de validação correspondentes. Resumo apresentado ao usuário com próximos passos.
- **Bootstrap abortado:** usuário interrompe em qualquer fase com pausa sem confirmar. Checkpoint preservado para retomada futura. Arquivos gerados em fases anteriores ficam no disco; usuário decide se descarta manualmente.
