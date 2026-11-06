---
versão: 1.0
status: experimental
atualizado: 2026-11-05
data: 2026-11-05
workflow: implement-change
tags: [scripts, contrato, modelo, custo]
status_decisão: ativa
supersede: null
relaciona-com: [2026-11-05-contexto-e-papeis]
---

# Decisões: Codex primeiro, Claude quando a cota acabar

## Contexto

O dono pediu em 2026-11-05 que as tarefas curtas de conferência e as mecânicas fossem primeiro ao Codex e
caíssem no Claude quando a cota do Codex acabasse, para poupar a cota da Anthropic. O orquestrador cobriu a
mudança pelas decisões D2 (política de modelo e contrato do `SPEC.md`) e D3 (nenhum termo novo no glossary).
O plano está em `.codeflow/changes/codex-primeiro/PLANO.md`.

## Decisões tomadas

### 1. Exceção de dependência na §7.3 do `SPEC.md`
`framework/core/scripts/agente-barato.sh` chama `codex` e `claude`. A exceção fica declarada na §7.3: eles são a
carga do script, não ferramenta da lógica, que segue só bash e coreutils.

**Por quê:** a §7.3 exige decisão explícita para dependência fora da lista; o script não tem sentido sem os
agentes que despacha, e sem nenhum dos dois ele sai 2.

**Alternativa rejeitada:** script fora do framework — deixaria o fallback sem teste nem catálogo.

### 2. Script que escreve em `core/scripts/`
A §2.2 chama os scripts de read-only; a linha do `agente-barato.sh` diz que ele grava o contador do dia em
`~/.cache/codeflow` e roda agentes.

**Alternativa rejeitada:** pasta nova de scripts, por um arquivo só.

### 3. Contador e teto
O script soma o contador ao despachar o Codex; `--contar` soma para o Maestro (rc 0 abaixo do teto, 1 no teto).
Teto padrão de 20 despachos por dia, ajustável com `--teto`, até o dono medir a cota.

### 4. Falha do Codex sem mensagem de cota não cai no Claude
Sai 1 com a saída do Codex. Cair em toda falha gastaria Claude em erro de briefing.

## Próximos passos sugeridos

- Medir a cota real do Codex e ajustar o teto padrão.
