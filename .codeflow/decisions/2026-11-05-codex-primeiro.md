---
versão: 1.1
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

**Por quê:** o script é do framework, com teste e catálogo como os outros; o que escreve é só um inteiro em
cache, regenerável, fora do repositório.

**Alternativa rejeitada:** pasta nova de scripts, por um arquivo só.

### 3. Contador e teto
O script soma o contador ao despachar o Codex; `--contar` soma para o Maestro (rc 0 abaixo do teto, 1 no teto).
Teto padrão de 20 despachos por dia, ajustável com `--teto`, até o dono medir a cota.

**Por quê:** Maestro e script contam no mesmo arquivo, então o teto vale para os dois caminhos; um padrão deixa o
script usável sem configuração enquanto a cota real não é medida.

**Alternativa rejeitada:** o script só ler o contador (o Maestro somaria sozinho e os despachos do script
ficariam fora da conta), e teto sem padrão, exigindo `--teto` em toda chamada.

### 4. Falha do Codex sem mensagem de cota não cai no Claude
Sai 1 com a saída do Codex. A cota se reconhece só na linha de erro do próprio Codex (stderr), nunca na
saída da tarefa nem no eco do prompt.

**Por quê:** cair em toda falha gastaria Claude em erro de briefing ou de rede; buscar a cota no texto todo
faria uma tarefa que cita "quota" ou "rate limit" cair no Claude sem a cota ter acabado.

**Alternativa rejeitada:** cair no Claude em qualquer falha, e buscar a mensagem de cota em toda a saída.

### 5. Codex só no Sol, médio ou alto
O Codex roda sempre o Sol: médio no perfil base do `~/.codex/config.toml` (PR só de documento e tarefa
mecânica), alto com `-p revisor` (2ª opinião e conferência de delta). O script expõe só `--alto`.

**Por quê:** ordem do dono, passada pelo orquestrador em 2026-11-05: um modelo só, com o esforço trocado
pela tarefa.

**Alternativa rejeitada:** um modelo Codex para o mecânico e outro para a revisão, com `--perfil` no script.

## Próximos passos sugeridos

- Medir a cota real do Codex e ajustar o teto padrão.
