<!-- Molde do codeflow (framework/library/templates/projeto/AGENTS.md), oferecido pelo /bootstrap.
     Teto: 8.000 caracteres e menos de 200 linhas. Este arquivo é lido em toda sessão: o que não
     vale para toda sessão mora em outro lugar. Apague este comentário ao preencher. -->

# <Projeto>

<O que é o projeto em duas ou três frases: para quem, o que faz, onde roda.>

## Invariantes

- <Regra que nunca se quebra, com a fonte: ADR, rule ou constitution do projeto.>
- <No máximo dez. O detalhe mora em `.codeflow/constitution.md`.>

## Ramos

- `<ramo-default>`: <o que entra nele e como (PR, revisão)>.
- Trabalho em `<prefixo>/<slug>`; nunca commitar direto no default.

## Comandos

Os comandos de validação moram no `.codeflow/manifest.md`. Ler só a seção, nunca o arquivo inteiro:

```bash
awk '/^## /{p=($0 ~ /^## (Comandos de validação|Gate|CI)/)} p' .codeflow/manifest.md
```

## Onde está o resto

- Regras e ramos do projeto: `.codeflow/constitution.md`.
- Decisões: `.codeflow/decisions/INDEX.md`. Arquitetura e histórico: `docs/`.
- Trabalho: pelos slash commands do codeflow (`/bugfix`, `/plan-change`, `/create-spec`, ...).

## O que não entra aqui

Nunca narrar bug, spec, fase nem histórico neste arquivo. Bug e mudança ficam no git e em `docs/`;
spec fica em `.codeflow/specs/`; procedimento longo vira skill ou workflow. Passou do teto, mover
o trecho para o lugar dele em vez de comprimir.
