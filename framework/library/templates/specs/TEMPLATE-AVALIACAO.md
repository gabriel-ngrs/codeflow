---
spec: <slug>
fase: <id>
slug_fase: <slug>
tentativa: <n da tentativa avaliada>
veredito: <APROVADO | REPROVADO | PENDENTE-EXTERNO>
range_avaliado: <sha_inicial>..<sha_final>
---

<!-- Preenchido pelo AVALIADOR (/evaluate-spec-phase) num chat ZERADO e separado
     do que executou. O relatório de execução é ponto de partida, NÃO fonte de
     verdade: verifique tudo contra o código real. Schema em ARTIFACTS_SPEC §2.10.

     fase/slug_fase/tentativa vêm do EXECUCAO avaliado (reusar verbatim).
     score e threshold são opcionais e só informam (podem ir no frontmatter);
     não decidem o veredito.
     Escalada (§2.10.3, definição única): vira BLOQUEANTE (a) o mesmo
     IMPORTANTE pela 2ª vez — o IMPORTANTE de uma avaliação anterior da mesma
     fase (rework), ou herdado destinado à fase, que segue aberto; (b) 3+
     IMPORTANTES abertos ao mesmo tempo.
     Veredito por precedência estrita REPROVADO > PENDENTE-EXTERNO > APROVADO:
       REPROVADO se há ≥1 BLOQUEANTE (contada a escalada);
       senão PENDENTE-EXTERNO se um gate depende de algo fora da fase
         (cota, push/CI remoto, ação física do dono, outra fase antes);
       senão APROVADO — os IMPORTANTES abertos viram herdados (§2.11.5).
     Erro só de registro não entra no veredito. -->

# FASE <id> — Avaliação independente

## 1. Veredito

**Veredito:** <APROVADO | REPROVADO | PENDENTE-EXTERNO> — (1–2 linhas do porquê; em
PENDENTE-EXTERNO, a condição de fora e quem a resolve.)

Checklist de leitura (nota opcional): conformidade com a fase (ACs, escopo
travado) · arquitetura e dependências · segurança/LGPD/multi-tenant · reuso ·
padrões de domínio · local e nomes · qualidade de código · testes · migration
safety (se aplicável).

## 2. Herdados e IMPORTANTES anteriores conferidos

(cada herdado destinado a esta fase e, em rework, cada IMPORTANTE da avaliação
anterior da fase → resolvido (evidência própria) ou
aberto. Aberto vira BLOQUEANTE (escalada (a)). "nenhum", se for o caso.)

## 3. Achados BLOQUEANTES

(arquivo:linha + correção sugerida. Só o que afeta correção, requisito,
contrato, escopo travado, segurança ou dado — mais a escalada.)

## 4. Achados IMPORTANTES

- **I-1** — `arquivo:linha` — o problema — a correção sugerida

(com APROVADO, viram herdados da fase de destino.)

## 5. Sugestões

(melhorias não-bloqueantes.)

## 6. Erros de registro

(frontmatter, range, lista de arquivos, link. O executor corrige num commit só
de documento, sem nova avaliação.)

## 7. Comandos rodados + saídas reais

> O avaliador roda **ele mesmo** os comandos de validação do projeto (do
> `manifest.md`); não acredita no relatório. Cole as saídas reais.

```text
...
```

## 8. Itens da fase / DoD não atendidos

(o que ficou faltando frente à §5 e §9 da spec.)

## 9. Divergências entre o relatório e o código real

(onde o EXECUCAO declarou algo que o código não confirma.)
