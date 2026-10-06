---
mudanca: <slug>
tentativa: <n da tentativa revisada>
veredito: <APROVADO | AJUSTAR | PENDENTE-EXTERNO>
range_revisado: <sha_inicial>..<sha_final>
---

<!-- Preenchido pelo REVISOR (/review-change), em chat zerado. O revisor não
     altera código: só julga e registra.

     veredito, por precedência AJUSTAR > PENDENTE-EXTERNO > APROVADO: AJUSTAR
     quando há ≥1 BLOQUEANTE (contada a escalada: IMPORTANTE da revisão
     anterior com destino "corrigir agora" que segue aberto — o mesmo
     IMPORTANTE pela 2ª vez —, ou 3+ IMPORTANTES abertos, vira BLOQUEANTE;
     o de destino "registrar como melhoria" fica aberto por decisão e não escala);
     PENDENTE-EXTERNO quando uma verificação depende de algo fora da mudança
     (cota, push/CI remoto, ação física do dono); senão APROVADO.
     Erro só de registro não entra no veredito.
     IMPORTANTE não segura o veredito — cada um sai com destino (corrigir agora,
     se for barato, ou registrar como melhoria). SUGESTÃO se descarta por padrão. -->

# <Título da mudança> — Revisão

## 1. Veredito

**<APROVADO | AJUSTAR | PENDENTE-EXTERNO>** — (1–2 linhas do porquê; em
PENDENTE-EXTERNO, a condição de fora e quem a resolve.)

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

## 7. Erros de registro

- (frontmatter, range, lista de arquivos, link — corrigidos pelo implementador num
  commit só de documento, sem nova revisão; "nenhum" se for o caso)

## 8. Comandos rodados e saídas reais

```text
# o que o revisor rodou ele mesmo, com a saída real
```

## 9. Divergências entre o relatório e o código

- (o que o relatório de execução afirma e o código não confirma; "nenhuma" se for o caso)
