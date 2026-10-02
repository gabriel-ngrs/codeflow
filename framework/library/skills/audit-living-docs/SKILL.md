---
versão: 1.0
status: experimental
atualizado: 2026-10-02
descrição: Checklist do auditor de documentação viva — o que CLAUDE.md, AGENTS.md, INDEX, manifest, ADRs, roadmap e READMEs afirmam e o código não faz mais.
---

# Skill: audit-living-docs

## Quando usar

Carregada pelo `/audit` quando a dimensão é `living-docs`. Cobre os documentos que **agentes e
pessoas leem para trabalhar**: instruções de agente (`CLAUDE.md`, `AGENTS.md`), o `.codeflow/`
(INDEX, constitution, manifest, rules, decisions, índices de specs, bugs e melhorias), roadmap e
READMEs. Num projeto operado por IA, documento desatualizado vira código errado.

## Princípio guia

Documento vivo é uma afirmação sobre o código. A auditoria testa cada afirmação contra o código e
os comandos — a que não se sustenta é achado, por mais bem escrita que seja.

## Protocolo

### 1. Réguas
- O próprio código, os comandos do projeto e o histórico do git são a verdade; o documento é a
  afirmação a conferir.
- As regras do projeto sobre documentos vivos (cópias que precisam ser idênticas, gates de
  coerência, convenções de índice).

### 2. O que procurar
- **Comando que não existe ou não faz o que diz:** alvo do manifest ou do README que sumiu, mudou de
  nome ou sai com outro comportamento.
- **Caminho morto:** arquivo, pasta ou símbolo citado que não existe mais.
- **Estado envelhecido:** "pendente", "em andamento", "ainda não existe" sobre algo que já foi
  feito — ou o contrário.
- **ADR e código divergentes:** a decisão descreve um comportamento que o código já não tem.
- **Índice incoerente:** linha de spec, bug ou melhoria com status diferente do arquivo dela;
  contador (`proximo_numero`) que não bate; número repetido.
- **Cópias que divergiram:** documentos que o projeto exige idênticos (ex.: `CLAUDE.md` e
  `AGENTS.md`).
- **Instrução de agente perigosa:** algo que manda o agente fazer o que as rules atuais proíbem.

### 3. Ferramentas (só leitura)
- Os gates de documento do projeto, se existirem (coerência de estado, comparação de cópias).
- Para cada comando e caminho citado: conferir que existe (`test -e`, `make -n`, `grep` pela
  definição). Rodar comando de diagnóstico só quando for seguro e só de leitura.

### 4. Severidade
- **Alta:** instrução de agente que leva a violar rule (segredo, dado real, ramo); comando citado
  que faz coisa diferente e destrutiva.
- **Média:** comando ou caminho morto em documento de uso diário; índice incoerente; ADR divergente.
- **Baixa:** estado envelhecido em documento histórico; README desatualizado em detalhe.
- Destino: **melhoria** (de documentação), em geral; **bug** quando o documento induz erro que já
  aconteceu.

## Proibições durante esta skill

- Não reescrever documento — apontar a afirmação falsa e a verdade verificada.
- Não reportar estilo de escrita como achado.
- Não tratar documento histórico (laudo antigo, relatório de fase) como documento vivo: ele registra
  o que era verdade naquela data.
- Não alterar arquivo nenhum.

## Saídas válidas

- Lista de candidatos de documentação, cada um com o documento e a linha, a afirmação, a verdade
  verificada (com a evidência), severidade e destino propostos.
- Cobertura por documento.
