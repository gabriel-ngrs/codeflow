---
mudanca: <slug>
tentativa: <n da tentativa revisada>
veredito: <APROVADO | AJUSTAR>
range_revisado: <sha_inicial>..<sha_final>
---

<!-- Preenchido pelo REVISOR (/review-change), em chat zerado. O revisor não
     altera código: só julga e registra.

     veredito: APROVADO quando não há nenhum BLOQUEANTE; AJUSTAR quando há ≥1.
     IMPORTANTE não segura o veredito — cada um sai com destino (corrigir agora,
     se for barato, ou registrar como melhoria). SUGESTÃO se descarta por padrão. -->

# <Título da mudança> — Revisão

## 1. Veredito

**<APROVADO | AJUSTAR>** — (1–2 linhas do porquê.)

## 2. Critérios de aceite, conferidos no código

| CA | Atendido? | Evidência própria (teste rodado, arquivo:linha) |
|----|-----------|--------------------------------------------------|
| CA-1 | ... | ... |

## 3. Conformidade com o plano

- Etapas entregues como planejado? Algo fora do escopo declarado? Desvios justificados?

## 4. Achados BLOQUEANTES

- **B-1** — `arquivo:linha` — o problema — a régua violada (CA, rule, ADR) — a correção sugerida

## 5. Achados IMPORTANTES

- **I-1** — `arquivo:linha` — o problema — destino: corrigir agora | registrar como melhoria

## 6. Sugestões

- (opcional; descartadas por padrão)

## 7. Comandos rodados e saídas reais

```text
# o que o revisor rodou ele mesmo, com a saída real
```

## 8. Divergências entre o relatório e o código

- (o que o relatório de execução afirma e o código não confirma; "nenhuma" se for o caso)
