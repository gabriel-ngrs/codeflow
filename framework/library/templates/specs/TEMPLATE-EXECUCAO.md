---
spec: <slug>
fase: <id>
slug_fase: <slug>
status: executado
tentativa: 1
reprovacoes: 0
sha_inicial: <sha>
sha_final: <sha>
range: <sha_inicial>..<sha_final>
---

<!-- Preenchido pelo EXECUTOR (/execute-spec-phase) ao final da fase. Serve de
     ponto de partida para o AVALIADOR — que NÃO confia nele e verifica contra o
     código real. Schema em ARTIFACTS_SPEC §2.9.

     status: "executado" (nova execução) ou "rework".
     Nova execução: tentativa=1, reprovacoes=0, sha_inicial = HEAD no início da fase.
     Rework: tentativa = anterior+1; reprovacoes = anterior+1 (o veredito
       não-APROVADO que motivou o rework); sha_inicial = REUSAR o do EXECUCAO
       anterior. range é sempre sha_inicial..sha_final (a fase inteira).
     Sem campo de branch: o pipeline trabalha na branch atual. -->

# FASE <id> — Relatório de execução

## 1. Resumo do que foi feito

(2–5 linhas — o incremento que a fase entregou.)

## 2. Arquivos CRIADOS

| Arquivo | Propósito |
|---------|-----------|
| `caminho/...` | ... |

## 3. Arquivos ALTERADOS

| Arquivo | O que mudou |
|---------|-------------|
| `caminho/...` | ... |

## 4. Confirmação do REUSO e decisões de design

- Reuso confirmado: (o que foi reaproveitado conforme §4 da spec, sem duplicar).
- Decisões de design e **qualquer desvio** da spec/rules: o quê, por quê, se foi
  conversado. "Nenhum desvio" é resposta válida — se for verdade.

## 5. Comandos rodados + saídas reais

> Rode os **comandos de validação do projeto** (do `.codeflow/manifest.md`; se um
> gate não existir, marque `[—]` com justificativa). Cole as **saídas reais** —
> nunca apenas "passou". Adapte aos gates que se aplicam a esta fase.

```text
# lint
...

# type-check
...

# testes (o subconjunto que prova esta fase)
...

# segurança (se aplicável)
...

# grep de segredo/PII (esperado: 0)
...
```

## 6. Critérios de aceite da fase (com evidência)

- [ ] AC-… — evidência: ...
- [ ] AC-… — evidência: ...

## 7. Definition of Done da fase

- [ ] Testes da fase verdes
- [ ] Comandos de validação do projeto limpos nos arquivos tocados (ou `[—]` justificado)
- [ ] Escopo travado respeitado (nenhuma violação BLOQUEANTE da §5)
- [ ] Nenhum segredo/PII em log/DTO/exceção
- [ ] Commits em pt-BR (Conventional Commits)

## 8. (Em rework) O que mudou nesta tentativa

(Quais achados BLOQUEANTES/IMPORTANTES da avaliação foram corrigidos e como.)

## 9. Itens em aberto / dúvidas para o avaliador

(O que ficou incerto, incompleto ou precisa de olhar externo. Seja honesto.)
