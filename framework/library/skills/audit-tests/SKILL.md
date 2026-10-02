---
versão: 1.0
status: experimental
atualizado: 2026-10-02
descrição: Checklist do auditor de testes — o que não tem teste, teste que não testa nada, teste frágil e critério de aceite sem prova.
---

# Skill: audit-tests

## Quando usar

Carregada pelo `/audit` quando a dimensão é `tests`. Cobre se os testes **protegem** o sistema:
o que está descoberto, o que está coberto só na aparência, e o que quebra por motivo errado.
Cobertura percentual é pista, não régua.

## Princípio guia

Um teste vale pelo bug que ele pegaria. Teste que passa com o código quebrado é pior que nenhum:
dá a confiança e não a proteção.

## Protocolo

### 1. Réguas
- `~/.codeflow/framework/core/rules/testing.md` e as rules de teste do projeto.
- Os critérios de aceite das specs e dos planos de mudança: cada CA prometido deveria ter um teste
  que o prova.
- As áreas críticas que o projeto declara (dinheiro, dado pessoal, isolamento, autorização).

### 2. O que procurar
- **Descoberto:** caminho crítico sem teste nenhum; regra de negócio só testada pelo caminho feliz;
  tratamento de erro nunca exercitado.
- **Teste vazio:** sem asserção, asserção que sempre passa, `mock` que substitui justamente o que
  deveria ser testado, teste que só confere que a função foi chamada.
- **Teste que mente:** nome que promete um caso e corpo que testa outro; teste desligado (`skip`,
  `only` esquecido) sem motivo escrito.
- **Frágil:** dependente de hora, ordem, rede, sleep ou estado compartilhado; intermitente conhecido
  sem registro.
- **CA sem prova:** critério de aceite de spec ou plano fechado sem teste correspondente.
- **Pirâmide torta:** só ponta a ponta onde caberia unitário rápido, ou só unitário onde a
  integração é que quebra.

### 3. Ferramentas (só leitura, conforme o stack)
- A suíte do projeto com relatório de cobertura, se o projeto já tem o alvo (pelo manifest) — para
  achar o descoberto, não para perseguir percentual.
- `grep` por `skip`, `only`, `todo`, testes sem `expect`/`assert`.
- Teste de mutação (ex.: `stryker`, `mutmut`) num módulo crítico, se o custo couber e o projeto
  já o tiver configurado.

### 4. Severidade
- **Alta:** área crítica (dinheiro, dado, isolamento, autorização) sem teste ou com teste vazio.
- **Média:** regra de negócio só no caminho feliz; CA sem prova; teste intermitente.
- **Baixa:** teste com nome enganoso, duplicado, ou lento sem necessidade.
- Destino: **melhoria**; **bug** só quando o teste esconde um defeito que se reproduz.

## Proibições durante esta skill

- Não usar percentual de cobertura como achado por si só.
- Não escrever teste nem consertar teste — só apontar.
- Não rodar a suíte em modo que altere dados reais ou ambiente compartilhado.

## Saídas válidas

- Lista de candidatos de teste, cada um com o caminho de código desprotegido ou o teste defeituoso
  (`arquivo:linha`), a régua, a evidência, severidade e destino propostos.
- Cobertura por área e o que a ferramenta mostrou.
