---
spec: <slug>
fase: <id>
slug_fase: <slug>
status: executado
tentativa: 1
reprovacoes: 0
base: <ramo remoto de origem, ex. origin/main, ou sha da ponta no início da fase>
---

<!-- Preenchido pelo EXECUTOR (/execute-spec-phase) ao final da fase. Serve de
     ponto de partida para o AVALIADOR — que NÃO confia nele e verifica contra o
     código real. Schema em ARTIFACTS_SPEC §2.9.

     status: "executado" (nova execução) ou "rework".
     Nova execução: tentativa=1, reprovacoes=0, base = de onde a fase partiu.
     Rework: tentativa = anterior+1; reprovacoes = anterior+1 (o REPROVADO
       que motivou o rework); base = REUSAR a do EXECUCAO anterior.
     O intervalo da fase é <merge-base de base e HEAD>..HEAD; o avaliador o
       calcula, então não há sha a acertar depois. O relatório vai no último
       commit da fase, junto do código ou logo depois.
     Formato anterior (sha_inicial, sha_final, range) segue válido.
     Teto: 60 linhas de corpo, fora as saídas coladas.
     Sem campo de branch: o pipeline trabalha na branch atual. -->

# FASE <id> — Relatório de execução

## 1. Resumo do que foi feito

(2–5 linhas — o incremento que a fase entregou.)

## 2. Commits da fase

(Um por linha, por assunto, na ordem do `git log --oneline <merge-base>..HEAD`.
O commit que leva este relatório entra pelo assunto, sem sha.)

- `<tipo>(<escopo>): <assunto>`

## 3. Arquivos (`git diff --stat <merge-base>..HEAD`)

```text
(cole a saída; o propósito vai ao lado só quando não é óbvio)
```

## 4. Confirmação do REUSO e decisões de design

- Reuso confirmado: (o que foi reaproveitado conforme §4 da spec, sem duplicar).
- Decisões de design e **qualquer desvio** da spec/rules: o quê, por quê, se foi
  conversado. "Nenhum desvio" é resposta válida — se for verdade.

## 5. Herdados

(IMPORTANTES abertos de fases anteriores destinados a esta fase — ARTIFACTS_SPEC
§2.11.5. Corrigi-los é escopo autorizado da fase. Um por linha; o avaliador
confere, e o que ficar aberto vira BLOQUEANTE. "nenhum", se não houver.)

- `FASE <id> I-<n>` — o problema — resolvido em `<sha>` | não resolvido: <motivo>

## 6. Comandos rodados + saídas reais

> Rode os **comandos de validação do projeto** (do `.codeflow/manifest.md`; se um
> gate não existir, marque `[—]` com justificativa). Cole as **saídas reais** —
> nunca apenas "passou". Cada saída: as **últimas 20 linhas** e o código de saída;
> a inteira fica no log de `.codeflow/checkpoints/` (o do `fim-de-fase.sh`, quando
> a fase o rodou). Adapte aos gates que se aplicam a esta fase.

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

## 7. Critérios de aceite da fase (com evidência)

- [ ] AC-… — evidência: ...
- [ ] AC-… — evidência: ...

## 8. Definition of Done da fase

- [ ] Testes da fase verdes
- [ ] Comandos de validação do projeto limpos nos arquivos tocados (ou `[—]` justificado)
- [ ] Escopo travado respeitado (nenhuma violação BLOQUEANTE da §5)
- [ ] Nenhum segredo/PII em log/DTO/exceção
- [ ] Commits em pt-BR (Conventional Commits)

## 9. (Em rework) O que mudou nesta tentativa

(Quais achados BLOQUEANTES/IMPORTANTES da avaliação foram corrigidos e como.)

## 10. Itens em aberto / dúvidas para o avaliador

(O que ficou incerto, incompleto ou precisa de olhar externo. Seja honesto.)
