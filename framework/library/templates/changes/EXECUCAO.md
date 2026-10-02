---
mudanca: <slug>
status: executado
tentativa: 1
reprovacoes: 0
etapas_concluidas: [1]
sha_inicial: <sha>
sha_final: <sha>
range: <sha_inicial>..<sha_final>
---

<!-- Preenchido pelo IMPLEMENTADOR (/implement-change). É declaração, não prova:
     o REVISOR não confia nele e confere contra o código real.

     status: "executado" (primeira execução) ou "rework".
     Primeira execução: tentativa=1, reprovacoes=0, sha_inicial = HEAD antes da etapa 1.
     Rework: tentativa = anterior+1; reprovacoes = anterior+1; sha_inicial = REUSAR o
       anterior. range é sempre sha_inicial..sha_final (a mudança inteira).
     etapas_concluidas: ids das etapas do plano já commitadas e verdes — é o ponto
       de retomada se a execução parar no meio. -->

# <Título da mudança> — Relatório de execução

## 1. Resumo

(2–5 linhas — o que foi entregue.)

## 2. Etapas

| Etapa | Commit | Gate | Resultado |
|-------|--------|------|-----------|
| 1 — <nome> | `<sha>` | `<comando>` | verde |

## 3. Arquivos criados e alterados

| Arquivo | Criado / alterado | Propósito |
|---------|-------------------|-----------|
| `caminho/...` | ... | ... |

## 4. Desvios do plano

- (o que foi feito diferente do plano, e por quê. "Nenhum desvio" é resposta válida — se for verdade.)

## 5. Comandos rodados e saídas reais

```text
# comandos de validação do projeto, com a saída real — nunca só "passou"
```

## 6. Critérios de aceite

| CA | Atendido? | Evidência (teste, comando, arquivo:linha) |
|----|-----------|--------------------------------------------|
| CA-1 | sim | ... |

## 7. No rework: o que mudou nesta tentativa

- (cada achado BLOQUEANTE da revisão anterior → o que foi feito → o `sha` que o fechou)

## 8. Dúvidas para o revisor

- (o que você não conseguiu provar, ou decidiu sem certeza)
