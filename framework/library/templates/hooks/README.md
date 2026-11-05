# Moldes de hooks

> Trechos prontos para o `.claude/settings.json` de um projeto consumidor. São **opt-in**: o `install.sh`
> não escreve o `.claude/settings.json` (`~/.codeflow/framework/core/SPEC.md` §3.9), e sem hook todo
> workflow faz o que já fazia. Quem liga é o dono do projeto.

## Moldes

| Molde | Para quê | Script |
|-------|----------|--------|
| `stop-fim-de-fase.json` | Stop hook que não deixa o executor encerrar com a fase vermelha | `~/.codeflow/framework/core/scripts/fim-de-fase.sh --hook` |

## Como ligar o `stop-fim-de-fase.json`

1. Copiar o bloco `"hooks"` do molde para o `.claude/settings.json` do projeto (ou para o
   `.claude/settings.local.json`, quando o hook é só da máquina). Se o arquivo já tem `"hooks"`, somar a
   entrada `"Stop"` às que existem, sem apagar as outras.
2. Conferir o `timeout` (segundos): ele fica **acima** do tempo-alvo do L0 do `## Gate` do manifest
   (`~/.codeflow/framework/core/ARTIFACTS_SPEC.md` §2.3.4) somado ao tempo do critério da fase. Hook mais
   lento que o timeout é cortado, e o agente tende a desligar o hook que o atrapalha.
3. Abrir uma sessão nova: o Claude Code lê os hooks na abertura.

## O que o hook faz

- Só age quando há `.codeflow/checkpoints/fase-ativa`, que o `/execute-spec-phase` grava no Passo 3 e apaga
  no fim (linhas `spec=`, `fase=` e `criterio=`, este com o comando do critério de conclusão da fase).
- Roda o comando do critério e o L0 do `## Gate`, se houver, e grava a saída em
  `.codeflow/checkpoints/fim-de-fase-<fase>.log`.
- Vermelho: sai 2 com o fim do log no stderr, e o agente volta ao trabalho com o erro na frente.
- Sai 0, sem prender o agente, quando o JSON de entrada traz `"stop_hook_active": true` (o agente já voltou
  uma vez por este hook), quando não há `fase-ativa` e quando o próprio script falha (defeito de ambiente).

## Confirmação opcional pelo orquestrador (`/goal`)

O Stop hook é a garantia; quem orquestra pode somar uma confirmação. Depois do despacho de uma fase, o
orquestrador manda ao terminal do executor um `/goal` com o critério dela, por exemplo:

```bash
maestri ask "<terminal do executor>" --raw "/goal o comando do critério da fase <id> passa\n"
```

O executor só encerra quando o objetivo é atingido. É opcional: sem `/goal`, o hook e o Passo 5 do
workflow seguem valendo.
