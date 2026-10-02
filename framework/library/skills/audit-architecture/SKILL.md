---
versão: 1.0
status: experimental
atualizado: 2026-10-02
descrição: Checklist do auditor de arquitetura — camadas, direção de dependências, fronteiras e contratos, e ADRs que o código deixou de cumprir.
---

# Skill: audit-architecture

## Quando usar

Carregada pelo `/audit` quando a dimensão é `architecture`. Cobre a forma do sistema: quem pode
depender de quem, onde cada coisa mora, e se as decisões de arquitetura registradas ainda são
verdade no código. Em projetos com fronteiras declaradas (contratos entre partes, portas e
adapters, multi-tenant), é a dimensão que as guarda.

## Princípio guia

Arquitetura é o que as ADRs prometeram e o código cumpre — ou não. Cada achado aponta a decisão
que foi quebrada; sem decisão escrita, o máximo é uma sugestão para registrar uma.

## Protocolo

### 1. Réguas
- As ADRs ativas do projeto (`.codeflow/decisions/`), o método e as rules de arquitetura e de
  fronteira do projeto, a constitution.
- O recorte de pastas e camadas que o projeto declarou (onde cada tipo de código deve morar).

### 2. O que procurar
- **Direção de dependência invertida:** domínio importando infraestrutura, camada interna
  conhecendo a externa, pacote compartilhado dependendo de app.
- **Fronteira atravessada:** código de um lado do contrato lendo detalhe interno do outro; tipo da
  fronteira escrito à mão em vez de derivado do contrato; dado externo entrando sem validação na
  borda.
- **Lugar errado:** regra de negócio na borda (controlador, handler, componente de tela),
  infraestrutura no domínio, configuração espalhada.
- **ADR descumprida:** a decisão diz uma coisa e o código faz outra — a ADR envelheceu (melhoria de
  documentação) ou o código desviou (achado de arquitetura).
- **Acoplamento:** ciclo entre módulos, módulo que todo mundo importa e que importa todo mundo,
  mudança pequena que exigiria tocar muitas áreas.
- **Fronteira de dados:** acesso a dado sem o identificador de isolamento que o projeto exige
  (quando multi-tenant).

### 3. Ferramentas (só leitura, conforme o stack)
- O verificador de dependências do projeto, se existir (ex.: `dependency-cruiser`, `eslint` de
  fronteiras, `import-linter`), e o grafo de importações que ele gera.
- `grep` dirigido: importações proibidas pela régua, por camada.

### 4. Severidade
- **Alta:** fronteira de contrato ou de isolamento atravessada; domínio dependendo de
  infraestrutura em caminho crítico.
- **Média:** ADR descumprida sem efeito imediato; ciclo entre módulos; regra no lugar errado.
- **Baixa:** arquivo fora do recorte de pastas sem efeito de dependência.
- Destino: **melhoria**, em geral; **bug** quando a violação já produz comportamento errado ou
  risco de dado.

## Proibições durante esta skill

- Não reportar violação de uma arquitetura que o projeto não declarou — sugerir registrar uma ADR é
  outra coisa.
- Não tratar ADR envelhecida como bug do código sem decidir qual dos dois está certo; registrar a
  divergência e o lado provável.
- Não propor reescrita; apontar a violação e a decisão quebrada.
- Não alterar código.

## Saídas válidas

- Lista de candidatos de arquitetura, cada um com `arquivo:linha`, a ADR ou rule quebrada, a
  evidência (a importação, o grafo, o trecho), severidade e destino propostos.
- Cobertura por camada ou módulo e as ferramentas rodadas.
