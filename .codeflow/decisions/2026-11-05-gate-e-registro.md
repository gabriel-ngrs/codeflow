---
versão: 1.1
status: estável
atualizado: 2026-11-05
data: 2026-11-05
workflow: implement-change
tags: [contrato, manifest, gate, spec, registro, scripts]
status_decisão: ativa
supersede: null
relaciona-com: [2026-10-05-aceleracao-do-ciclo, 2026-11-05-contexto-e-papeis]
---

# Decisões: esteira em camadas, fim de fase executável e registro mínimo

## Contexto

A pesquisa de tokens de 2026-11-02 mostrou que os projetos rodam o gate caro em todo PR, que o fim de fase depende
de o agente lembrar de validar e que o registro de execução custa commits e linhas que ninguém lê (commits só para
acertar sha, relatórios longos). Em 2026-11-05 o dono aprovou a lista inteira de mudanças. As que mexem no schema de
artefato de projeto (`framework/core/ARTIFACTS_SPEC.md` Parte 2), que pela constitution do repositório param no
dono, estão cobertas por essa aprovação por serem retrocompatíveis. Nenhum termo novo entra no `glossary.md`:
"esteira em camadas", "camada" e "base" ficam como texto descritivo. O plano está em
`.codeflow/changes/gate-e-registro/PLANO.md`.

## Decisões tomadas

### 1. Seção opcional `## Gate` no manifest (§2.3.4)
L0 no loop do agente, L1 como gate de merge, L2 pós-merge ou noturno; quem roda cada camada mora só em §2.3.4.
O L2 nunca some, só muda de hora. Sem `## Gate`, todo workflow faz o que fazia.

**Por quê:** os projetos rodavam o gate caro em todo PR; com as camadas, o barato roda sempre e o caro roda fora
do PR, sem deixar de rodar. A regra de quem roda cada camada num lugar só evita a errata repetida nos workflows.

**Alternativa rejeitada:** repetir a regra em cada workflow, ou tornar a seção obrigatória — a primeira espalha a
mesma regra em seis arquivos, a segunda quebraria todo manifest existente.

### 2. Retrocompatibilidade do schema
- `## Gate` é opcional; o manifest sem ela segue válido.
- A regra nova da spec (critério de conclusão de fase com comando entre crases) é **só aviso** (`⚠`): o
  `run-structural.sh` mantém o código de saída de toda spec antiga. Virar erro fica para uma versão seguinte,
  depois que as specs ativas migrarem.
- No relatório de execução, `base` entra como campo novo; `sha_inicial`, `sha_final` e `range` passam a
  opcionais. Relatório antigo, com o trio e sem `base`, segue válido e é avaliado pelo `range`.
- `range_avaliado` e `range_revisado` continuam, agora calculados pela `base` (`<merge-base>..<HEAD>`), sem campo novo.

**Por quê:** a aprovação do dono cobre o schema da Parte 2 por ser retrocompatível; nenhum `.codeflow/` existente
pode deixar de valer, e o gate `test` exige o mesmo código de saída do `run-structural.sh` nas specs reais.

**Alternativa rejeitada:** a regra nova como erro já nesta versão e a troca de `range_avaliado` por `base` mais
`head_avaliado` — ambas reprovariam ou invalidariam artefatos que hoje passam.

### 3. Exceção de saída do `fim-de-fase.sh --hook`
No modo Stop hook, o vermelho sai **2**, que o protocolo do hook entende como "devolver o agente ao trabalho", e o
erro de execução do próprio script sai **0**, para um defeito de ambiente não prender o agente. Fora do modo
`--hook`, as saídas seguem `ARTIFACTS_SPEC.md` §0.7 (0 verde, 1 vermelho, 2 erro de execução, 3 uso inválido).

**Por quê:** o Stop hook só devolve o agente ao trabalho com a saída 2; e um hook que prende o agente por defeito
de ambiente leva a desligá-lo. É divergência consciente de §0.7, restrita ao modo `--hook`.

**Alternativa rejeitada:** sair 2 também no erro de execução, como manda §0.7 — prenderia o agente por defeito de
ambiente, não por gate vermelho.

### 4. O que ficou fora
- Corte 36 (congelar o contrato na revisão de spec): sem superfície no framework; é dos workflows de projeto.
- Regra "nenhum `--no-verify`" e molde de `commit-msg`: o git não registra o `--no-verify`, então não há o que
  conferir por script.
- O `/goal` opcional do orquestrador fica descrito no `templates/hooks/README.md`.

**Por quê:** o framework não tem workflow universal de revisão ou de congelamento de spec; o `--no-verify` não
deixa rastro no histórico; e o molde de despacho é de outra mudança, que o pode citar depois.

**Alternativa rejeitada:** inventar um passo de congelamento no `create-spec`, conferir o `--no-verify` por
heurística de mensagem sem garantia, e criar `templates/orquestracao/` aqui, em conflito com a outra mudança.

## Próximos passos sugeridos

- Cada projeto consumidor escreve o próprio `## Gate` quando quiser tirar o gate caro do PR; o ganho de tempo
  chega aí.
- Migrar o critério de conclusão das specs ativas para o formato com comando; depois, numa versão seguinte, o
  aviso do `run-structural.sh` vira erro.
- O dono decide se o `glossary.md` (core) passa a citar `base` na definição do relatório de execução.
