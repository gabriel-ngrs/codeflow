---
versão: 1.0
status: estável
atualizado: 2026-05-23
descrição: Protocolo de transferência de contexto entre sessões. Arquivo de handoff em formato fixo, sem prosa.
---

# Skill: handoff

## Quando usar

Workflows devem carregar esta skill ao final de sessão que deixa trabalho parcialmente concluído, antes de troca de contexto longa, ou quando o usuário pede explicitamente "deixa registrado para continuar depois". Workflows que terminam a tarefa por completo na própria sessão podem omitir.

## Princípio guia

Handoff bom permite retomar sem reconstruir contexto. Handoff omisso ou vago obriga a próxima sessão a pagar de novo o custo de orientação — e geralmente perde decisões que pareciam óbvias no momento.

## Protocolo

### 1. Resumir estado atual em uma linha
- Frase única que responde "o que está pronto e o que ainda não está".

### 2. Listar próximo passo concreto
- Comando, arquivo a editar ou pergunta a responder. Sem genéricos ("continuar trabalho"); sempre o próximo movimento físico.

### 3. Registrar decisões em aberto
- Toda escolha adiada que afeta o próximo passo. Para cada uma: a opção considerada, o que falta para decidir, quem decide.

### 4. Listar arquivos tocados na sessão
- Caminho relativo + uma linha sobre o que mudou em cada um.

### 5. Registrar comandos para retomar
- Lista literal de comandos (checkout de branch, ativar venv, rodar servidor de dev) necessários para reproduzir o ambiente da sessão.

## Proibições durante esta skill

- Não escrever handoff genérico ("trabalhei em várias coisas hoje").
- Não omitir bloqueio ou decisão adiada por achar que "lembra depois".
- Não substituir lista de arquivos por "ver git status" — listar explicitamente, mesmo que o git status repita.
- Não incluir narrativa do trabalho. Handoff é estado, não diário.

## Saídas válidas

- **Arquivo de handoff** em formato fixo com as cinco seções acima. Tipicamente em `.codeflow/checkpoints/handoff-<timestamp>.md` ou arquivo equivalente declarado pelo workflow invocador.
