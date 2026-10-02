---
versão: 1.0
status: experimental
atualizado: 2026-10-02
descrição: Checklist do auditor de qualidade de código — duplicação, complexidade, código morto, tratamento de erro e padrões do projeto não seguidos, com régua e evidência.
---

# Skill: audit-code-quality

## Quando usar

Carregada pelo `/audit` quando a dimensão é `code-quality`. Cobre o que torna o código caro de
manter ou fácil de quebrar. **Não** cobre formatação e estilo, que o linter e o formatador do
projeto já garantem, nem arquitetura (dimensão `architecture`).

## Princípio guia

Qualidade aqui é o que custa caro amanhã: a regra repetida em três lugares, o erro engolido, o
caminho que ninguém entende. Se o linter pega, não é achado de auditoria — é configuração de linter.

## Protocolo

### 1. Réguas
- `~/.codeflow/framework/core/rules/code-quality.md` e `naming.md`; as rules de código do projeto.
- As convenções que o próprio código já estabeleceu: o padrão dominante é régua para a exceção.

### 2. O que procurar
- **Duplicação de lógica** (não de texto): a mesma regra de negócio, validação ou cálculo escrita
  em mais de um lugar, com risco de divergir.
- **Complexidade:** função longa demais para o que faz, aninhamento profundo, muitos parâmetros,
  condicional que mistura responsabilidades.
- **Tratamento de erro:** `catch` vazio ou genérico que engole, erro convertido em sucesso, retorno
  de falha ignorado, ausência de tratamento na borda com o mundo externo.
- **Código morto:** exportação sem uso, ramo inalcançável, flag que nunca muda, arquivo órfão.
- **Tipagem frouxa** onde o projeto exige rigor: `any`, conversão forçada, dado externo usado sem
  validar.
- **Valores mágicos:** número ou texto de negócio literal no código onde o projeto pede
  configuração.
- **Padrão quebrado:** um módulo que faz do jeito que nenhum outro faz, sem motivo escrito.
- **Comentário que mente** sobre o código ao lado.

### 3. Ferramentas (só leitura, conforme o stack)
- O linter e o type-check do projeto (pelo manifest), para ver o que já está coberto.
- Detecção de duplicação (ex.: `jscpd`), de exportação sem uso (ex.: `knip`, `ts-prune`, `vulture`),
  de complexidade (ex.: `eslint` com regra de complexidade, `radon`), quando disponíveis.

### 4. Severidade
- **Alta:** erro engolido em caminho de dado ou de dinheiro; regra de negócio duplicada que já
  divergiu.
- **Média:** duplicação que pode divergir, complexidade que esconde bug provável, tipagem frouxa
  na borda.
- **Baixa:** código morto, nome enganoso, comentário desatualizado.
- Destino: quase sempre **melhoria**; **bug** quando o problema já produz comportamento errado.

## Proibições durante esta skill

- Não reportar o que o linter ou o formatador do projeto já pegam.
- Não reportar preferência pessoal sem régua ("eu faria diferente").
- Não reportar duplicação de texto que não é duplicação de regra.
- Não alterar código.

## Saídas válidas

- Lista de candidatos de qualidade, cada um com `arquivo:linha`, régua, evidência, severidade e
  destino propostos, para o laudo da dimensão.
- Cobertura por área e as ferramentas rodadas, com o resultado resumido.
