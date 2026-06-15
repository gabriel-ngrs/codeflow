---
spec: <slug>
fase: <id>
slug_fase: <slug>
tentativa: <n da tentativa avaliada>
veredito: <APROVADO | RESSALVAS | REPROVADO>
score: <0.0-10.0>
threshold: <threshold usado>
range_avaliado: <sha_inicial>..<sha_final>
---

<!-- Preenchido pelo AVALIADOR (/evaluate-spec-phase) num chat ZERADO e separado
     do que executou. O relatório de execução é ponto de partida, NÃO fonte de
     verdade: verifique tudo contra o código real. Schema em ARTIFACTS_SPEC §2.10.

     fase/slug_fase/tentativa vêm do EXECUCAO avaliado (reusar verbatim).
     threshold = o valor efetivamente usado (quality_gate da spec ou override).
     Veredito por precedência estrita REPROVADO > RESSALVAS > APROVADO:
       REPROVADO se score < threshold OU há ≥1 BLOQUEANTE;
       senão RESSALVAS se há ≥1 IMPORTANTE;
       senão APROVADO. Só APROVADO conclui a fase. -->

# FASE <id> — Avaliação independente

## 1. Veredito e score

**Veredito:** <APROVADO | RESSALVAS | REPROVADO> · **Score:** <0.0–10.0> / threshold <X>

## 2. Scorecard

| # | Dimensão | Peso | Nota (0–5) | Evidência (arquivo:linha ou saída) |
|---|----------|------|------------|------------------------------------|
| 1 | Conformidade com a fase — ACs e escopo travado | 3 | | |
| 2 | Arquitetura e direção de dependências | 3 | | |
| 3 | Segurança / LGPD / multi-tenant | 3 | | |
| 4 | Reusar/espelhar, não duplicar | 3 | | |
| 5 | Padrões de domínio/aplicação | 2 | | |
| 6 | Local e nomes dos arquivos | 2 | | |
| 7 | Qualidade de código | 2 | | |
| 8 | Testes e cobertura | 2 | | |
| 9 | Migration safety (se aplicável) | 2 | | |

## 3. Achados BLOQUEANTES

(arquivo:linha + correção sugerida. BLOQUEANTE sempre reprova, qualquer score.)

## 4. Achados IMPORTANTES

(arquivo:linha + correção sugerida. ≥1 IMPORTANTE → no mínimo RESSALVAS.)

## 5. Sugestões

(melhorias não-bloqueantes.)

## 6. Comandos rodados + saídas reais

> O avaliador roda **ele mesmo** os comandos de validação do projeto (do
> `manifest.md`); não acredita no relatório. Cole as saídas reais.

```text
...
```

## 7. Itens da fase / DoD não atendidos

(o que ficou faltando frente à §5 e §9 da spec.)

## 8. Divergências entre o relatório e o código real

(onde o EXECUCAO declarou algo que o código não confirma.)
