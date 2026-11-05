---
mudanca: <slug>
status: executado
tentativa: 1
reprovacoes: 0
etapas_concluidas: [1]
base: <ramo remoto de origem, ex. origin/main>
---

<!-- Preenchido pelo IMPLEMENTADOR (/implement-change). É declaração, não prova:
     o REVISOR não confia nele e confere contra o código real.

     status: "executado" (primeira execução) ou "rework".
     Primeira execução: tentativa=1, reprovacoes=0, base = de onde o ramo nasceu.
     Rework: tentativa = anterior+1; reprovacoes = anterior+1; base = REUSAR a anterior.
     O intervalo é <merge-base de base e HEAD>..HEAD; o revisor o calcula, então não
       há sha a acertar depois. O relatório vai no último commit da mudança.
     Formato anterior (sha_inicial, sha_final, range) segue válido.
     Teto: 60 linhas de corpo, fora as saídas coladas.
     etapas_concluidas: ids das etapas do plano já commitadas e verdes — é o ponto
       de retomada se a execução parar no meio. -->

# <Título da mudança> — Relatório de execução

## 1. Resumo

(2–5 linhas — o que foi entregue.)

## 2. Etapas

| Etapa | Commit | Gate | Resultado |
|-------|--------|------|-----------|
| 1 — <nome> | `<sha>` (o commit que leva este relatório: "este") | `<comando>` | verde |

## 3. Arquivos (`git diff --stat <merge-base>..HEAD`)

```text
(cole a saída; o propósito vai ao lado só quando não é óbvio)
```

## 4. Desvios do plano

- (o que foi feito diferente do plano, e por quê. "Nenhum desvio" é resposta válida — se for verdade.)

## 5. Comandos rodados e saídas reais

```text
# comandos de validação do projeto: as últimas 20 linhas e o código de saída de cada
# um — nunca só "passou"; a saída inteira fica no log de .codeflow/checkpoints/
```

## 6. Critérios de aceite

| CA | Atendido? | Evidência (teste, comando, arquivo:linha) |
|----|-----------|--------------------------------------------|
| CA-1 | sim | ... |

## 7. No rework: o que mudou nesta tentativa

- (cada achado BLOQUEANTE da revisão anterior → o que foi feito → o `sha` que o fechou)

## 8. Dúvidas para o revisor

- (o que você não conseguiu provar, ou decidiu sem certeza)
