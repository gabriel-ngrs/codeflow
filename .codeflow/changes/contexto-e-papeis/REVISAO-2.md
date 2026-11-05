---
mudanca: contexto-e-papeis
tentativa: 2
veredito: APROVADO
range_revisado: f97932e..26db5bc
---

# Contexto enxuto e modelo por papel — Revisão

## 1. Veredito

**APROVADO**: nenhum BLOQUEANTE. O rework da revisão 1 fechou o B-1, o I-1, o I-2 e o I-3. O merge do
`origin/main` manteve as duas mudanças em `refactor.md` e não perdeu linha do main nos outros três arquivos.
O gate `check` está verde. Ficam 2 IMPORTANTES, os dois no caminho do pacote da fase, com destino "corrigir
agora" num commit próprio antes do PR, sem nova revisão.

## 2. Critérios de aceite, conferidos no código

| CA | Atendido? | Evidência própria (teste rodado, arquivo:linha) |
|----|-----------|--------------------------------------------------|
| CA-1 | sim | `## LEIA TAMBÉM` com `.codeflow/INDEX.md`: só `audit.md` e `create-spec.md`. Nenhum workflow tem `- .codeflow/manifest.md` sem a expressão. Os 14 que citam o manifest usam o `awk`. `spec-status` sem o trio, pela exceção do §1.5.3 (decisão 3). `ideacao` sem diff |
| CA-2 | sim | No manifest daqui, a expressão devolve só `## Comandos de validação`. A variante devolve Stack, Comandos e Padrões. A revisão 1 já provou `## Gate` e `## CI` numa entrada sintética, e a expressão não mudou |
| CA-3 | sim | `ARTIFACTS_SPEC.md` §1.5.6 regra 5 e §1.6.6 regra 6 exigem as três entradas e dizem que o INDEX "não invalida". Hunks em `:820`, `:879`, `:1032`, `:1506` e `:1999`. `SPEC.md` §5.1 e §6.7.1 agora seguem o §1.5.3 (I-1) |
| CA-4 | sim | O literal é igual nos 6 pontos dos geradores e nos 3 do §1.11 (`uniq -c`). `grep 'Carregue todos'` vazio. O gate `test` gerou os wrappers em `HOME` temporário. O `install.sh`, ensaiado em `$T/proj` com `HOME="$T"`, saiu com rc=0, criou o `novo.md` com o texto novo e preservou `velho.md` e `orquestrar-x.md` com o mesmo md5 |
| CA-5 | sim | Laço próprio: 66 specs e 493 fases, nenhuma falha, cada uma com o `### Fase <id>` e o rodapé. Cerca sem fechamento sai 1, sem stdout. Os casos 1, 2 e 3 de uso foram provados na revisão 1, e o trecho do script não mudou |
| CA-6 | sim | Spec sintética: AC-1, FR-1 e AC-2 (este com um bloco de código dentro) saem com o texto da spec. `⚠ FR-9` aparece no rodapé com rc=0 |
| CA-7 | sim | `execute-spec-phase.md:54` e `:77`, `evaluate-spec-phase.md:42` e `:84`. `grep 'na íntegra'` e `grep stash` vazios. O diff do `evaluate-spec-phase` só toca o Passo 4 em linha de contexto |
| CA-8 | sim | A seção está em `## Antes de começar` em `implement-change.md:38`, `execute-spec-phase.md:39` e `bugfix.md:35`, com a escada de 5 degraus, o "Nunca corte" e a linha do relatório. O texto é o mesmo de antes do I-2 (diff por linha) |
| CA-9 | sim | `modo-delegado/SKILL.md:37`, `:70` e `:89` (`Modelo:`). `grep -c Sonnet` = 0. Arquivo sem diff desde a revisão 1 |
| CA-10 | sim | `vigia.sh` em repositório descartável: parado rc=1, avanço rc=0, sem argumento rc=3, ramo inexistente rc=2. Repositório igual depois |
| CA-11 | sim | `SPEC.md:514` (§3.7 "por tarefa"), `:1819` (§10.9, exceção com "sim"). `:146` (§8.3) continua dizendo que nunca modifica `CLAUDE.md`. Decision sem linha no `decisions/INDEX.md` (contagem 0) |
| CA-12 | sim | `AGENTS.md` com 1440 bytes e 37 linhas. `CLAUDE.md` = `@AGENTS.md`. Bootstrap e discover sem diff desde a revisão 1 |
| CA-13 | sim | `SPEC.md:190-203` e `README.md:94-98`. Todo `.md` do diff com frontmatter está em `atualizado: 2026-11-05`, com `versão` X.Y e `status` válidos. Diff vazio no core, em `templates/specs/` e no manifest. Nenhum hunk do `ARTIFACTS_SPEC.md` entre `### 2.8` (`:2590`) e `### 2.11` (`:2921`). `check` verde (§8) |

## 3. Conformidade com o plano

- **Rework da revisão 1.**
  - B-1, fechado: o caso da revisão 1 (`#` e `##` em blocos ```` ``` ```` e `~~~` dentro da fase e de um AC)
    agora sai inteiro, com o escopo travado, o AC-2 e a faixa certa no rodapé (§8). Fica um resíduo, o I-1
    abaixo.
  - I-1, fechado: `SPEC.md` §5.1 e §6.7.1.
  - I-2, fechado: o bloco foi para `## Antes de começar`, e nenhum workflow tem `###` fora de Passo no
    Protocolo.
  - I-3, fechado: a decision tem `## Contexto`, `## Decisões tomadas`, `## Próximos passos sugeridos` e
    `## Notas`, com 4 `**Alternativa rejeitada:**`. O frontmatter tem as mesmas chaves das outras 5.
  - Nenhum IMPORTANTE da revisão 1 segue aberto, então não há escalada.
- **Merge do `origin/main`** (`26db5bc`).
  - `refactor.md` tem as duas mudanças: a linha da skill `audit-enxugar` (`:32`) e o manifest por seção
    (`:34`), sem o `.codeflow/INDEX.md`.
  - Em `README.md`, `SPEC.md` e `audit.md`, toda linha que sai em `origin/main..HEAD` é mudança deste ramo.
    Nenhuma linha do audit-enxugar se perdeu: a dimensão `enxugar` está em `README.md:22`, `SPEC.md:206` e
    `audit.md:14`.
  - As versões a mais (README 1.5, SPEC 3.6, audit 1.2 e refactor 1.3) seguem a decisão 6.
- **Atenção (a):** os wrappers preservados ficaram intactos no ensaio do `install.sh` (md5 igual). Os geradores
  da máquina não mudaram desde a revisão 1.
- **Atenção (b):** o pacote traz o escopo travado e os AC nas 493 fases reais e no caso do B-1. Os contratos
  (§4) chegam pelo rodapé, com a ordem de abri-los. Ficam duas lacunas: a cerca aninhada (I-1) e o caminho
  sem saída 0 nos workflows (I-2).
- **Atenção (c):** atendida. O "Nunca corte" dos três workflows cobre validação em fronteira, tratamento de
  erro que evita perda de dados e segurança. O do `execute-spec-phase` cobre também o critério de aceite da
  spec. O "código movido mantém validação e tratamento de erro" segue lá. Nenhuma linha manda cortar.
- **Atenção (d):** atendida. Não há `/home/` nem `/Users/` nas linhas acrescentadas dos 34 arquivos, e a
  varredura de nomes do gate `security` está limpa.
- Nada fora do escopo. Os arquivos do rework estão no mapa do plano (`pacote-da-fase.sh`, os três workflows,
  `SPEC.md` e a decision).

## 4. Achados BLOQUEANTES

- Nenhum.

## 5. Achados IMPORTANTES

- **I-1**: `framework/core/scripts/pacote-da-fase.sh:83-84`. O script não fecha a cerca pela regra do
  CommonMark.
  - **O problema:** ao abrir, ele guarda só os 3 primeiros caracteres da cerca, e qualquer linha que comece
    por eles a fecha. Numa cerca de 4 crases (```` ```` ````) que contém um bloco de 3, o ```` ```bash ````
    de dentro fecha a de fora. A `# ...` seguinte volta a contar como heading, e o bloco da fase sai truncado
    com rc=0 e sem aviso: o B-1, na forma aninhada. Na spec sintética `s3` (§8), o pacote para em
    ```` ```bash ```` e perde o **Escopo travado**.
  - **Alcance:** nenhuma das 66 specs reais tem cerca de 4 ou mais caracteres, e a cerca simples (o B-1
    pedido) está coberta. Por isso fica como IMPORTANTE, não BLOQUEANTE.
  - **A régua:** o pacote não pode deixar o executor sem o escopo travado (PLANO §4 e §7, risco 2; atenção b).
  - **A correção:**
    - ao abrir, guardar o caractere e o comprimento da cerca (`/^[ \t]*(`{3,}|~{3,})/`);
    - fechar só com o mesmo caractere, comprimento maior ou igual e nada além de espaço depois;
    - somar o caso `s3` ao teste.
  - **Destino:** corrigir agora, num commit próprio antes do PR, sem nova revisão.
- **I-2**: `execute-spec-phase.md:77` e `evaluate-spec-phase.md:42`. Os workflows não dizem o que fazer
  quando o `pacote-da-fase.sh` sai com código diferente de 0.
  - **O problema:** o rework deu à saída 1 um segundo sentido, "recorte não confiável" (cerca sem fechamento).
    Com o `>` do comando, o `.codeflow/checkpoints/pacote-<slug>-<id>.md` fica vazio. O aviso vai para o
    stderr, mas o passo manda "gravar e lê-lo", sem um caminho alternativo. O executor pode tratar o caso
    como "fase inexistente" e parar, ou seguir com o arquivo vazio.
  - **A régua:** atenção (b), o executor nunca fica sem os AC e os contratos da fase.
  - **A correção:** uma frase em cada um dos dois passos: "se o script sair ≠ 0, ler o bloco da fase e os
    itens citados pela linha do `grep -n '^### Fase'`, e registrar o aviso no relatório".
  - **Destino:** corrigir agora, no mesmo commit do I-1.

## 6. Sugestões

- As sugestões S-1 a S-6 da revisão 1 seguem como estavam, descartadas por padrão. A S-3 é o aviso de deploy:
  depois do deploy, os wrappers de projeto antigos aparecem no `install.sh` como "divergentes". O ensaio desta
  revisão mostrou isso de novo. Esse aviso tem de ir para a Fase 7.
- `execute-spec-phase.md` tem 135 linhas (124 no `origin/main`), acima da faixa de 60 a 100 do §1.6.6
  regra 2. Já estava acima antes desta mudança. Fica para a Auditoria.

## 7. Erros de registro

- Nenhum. O `range` (`f97932e..26db5bc`) cobre os commits do rework e o merge. `3330ada` é só o
  `EXECUCAO.md`. Os commits e arquivos do §7 do `EXECUCAO.md` batem com o código.

## 8. Comandos rodados e saídas reais

```text
# origem: origin/main = merge-base = f94bc19; 26db5bc é ancestral do HEAD (3330ada)

# gate check do manifest (blocos lint, test e security extraídos para o scratchpad $S), na raiz da worktree
lint=0
test=0        # nenhuma linha "✗ ... origin/main=a ramo=b"; setup-slash e codex-skills em HOME temporário
              # ("criados: 21"; "✓ Sincronização concluída.")
INF 13 commits scanned. / INF no leaks found
security=0
árvore igual  # git status --short antes e depois

# CA-5 — laço próprio sobre as specs reais
specs=66 fases=493 falhas=0
cercas de 4+ caracteres nas specs reais: 0 | specs com cerca ``` ou ~~~: 23

# B-1 — spec sintética s1 (bloco ```bash com "# comentário" e "## outro", bloco ~~~ com "# til",
#        AC-2 com bloco de código, Escopo travado depois dos blocos)
### Fase 1 — um
...
```bash / # comentário / ## outro / make test / ```
~~~ / # til / ~~~
- **Escopo travado:** só X; ver AC-2.
## Itens citados na fase: AC-1, FR-1, AC-2 (com o bloco e "continua C")
## Linhas da §9: - [ ] Fase 1 verde
- ## 5. Plano: 17–31 (a fase 1 está nas linhas 18–29)
- ⚠ FR-9 citado na fase e não encontrado na spec
rc=0 | git status igual

# cerca sem fechamento (s2)
✗ bloco de código aberto na linha 6 sem fechamento em $S/s2.md: o recorte da fase não é confiável
aberta rc=1 stdout=0

# I-1 — cerca de 4 crases com bloco de 3 dentro (s3)
### Fase 1 — um
````md
```bash
                 ← para aqui: somem "# comentario", o fechamento e o "Escopo travado"
rc=0

# ```bash dentro de cerca ``` (s4): fecha cedo, a próxima ``` abre sem fechar → rc=1 (falha ruidosa)

# I-2 (rev. 1) — c8baeba: linhas -/+ que diferem, tirado o rótulo do bloco
só as três linhas "Vale para ..." (mudou o markup, não o texto)

# I-3 (rev. 1) — a decision e as 5 anteriores
2026-11-05-contexto-e-papeis.md: mesmas chaves | ## Contexto|## Decisões tomadas|## Próximos passos sugeridos|## Notas|
Alternativa rejeitada: :34 :45 :54 :62 | decisions/INDEX.md: 0 linhas

# merge — refactor.md
:32 audit-enxugar/SKILL.md (só quando o pedido é um lote do laudo `enxugar`)
:34 .codeflow/manifest.md — só a stack, os padrões e os comandos ... awk ...
.codeflow/INDEX.md: ausente
versões base/main/pré-merge/HEAD: README 1.3/1.4/1.4/1.5 | SPEC 3.4/3.5/3.5/3.6 | audit 1.0/1.1/1.1/1.2 | refactor 1.1/1.2/1.2/1.3

# CA-4 — install.sh em $T/proj, HOME="$T"
rc=0
✓ .claude/commands/ sincronizado (1 novo(s), 2 preservado(s)).
⚠ 2 wrapper(s) preservado(s) com conteúdo diferente do gerado — não reescritos ...
    .claude/commands/orquestrar-x.md
    .claude/commands/velho.md
.claude/commands/orquestrar-x.md: OK   (md5 igual)
.claude/commands/velho.md: OK
novo.md: Leia <T>/proj/.codeflow/workflows/novo.md e execute ... como cada item manda (só a seção indicada; ...) antes de começar.
literal: 6 ocorrências iguais nos geradores; "Carregue todos": 0

# CA-10 — vigia.sh em repositório descartável
parado=1 avanço=0 semarg=3 ramo=2 | repo igual

# Parte 3, arquivo por arquivo (34 do diff, fora .codeflow/changes/)
BOM / CRLF / sem LF final / LF duplo / controle / # no frontmatter: nenhum
versão X.Y, status válido, atualizado 2026-11-05: todos os que têm frontmatter
sem frontmatter: os 5 moldes de templates/orquestracao e templates/projeto (precedente da S-6 da rev. 1)
caminho absoluto / TODO / FIXME nas linhas acrescentadas: nenhum

# §x.6 por tipo
workflows (16): título, granularidade, usa_checkpoints, três entradas (spec-status pela exceção), passos
  (magro ≥1; médio 5–7; detalhados 4–6 fases), nenhum ### fora de Passo no Protocolo, DoD com - [ ]: conforme
skill modo-delegado (§1.8.6): seções na ordem, sem DoD nem LEIA TAMBÉM: conforme
meta-skills bootstrap, discover, create-workflow (§1.9.6): é_meta_skill, as nove seções, Template/Onde salvar/Validação: conforme
decision (§2.5.6): conforme (I-3 da rev. 1)
```

## 9. Divergências entre o relatório e o código

- `EXECUCAO.md` §7 diz que o B-1 foi fechado "em todos os pontos que leem heading". Isso vale para a cerca
  simples. Com a cerca aninhada, a detecção da cerca ainda falha (I-1).
- `EXECUCAO.md` §7 registra `12 commits scanned`. A revisão viu 13, porque o range lido pelo gitleaks agora
  inclui `3330ada`. Não é divergência de código.
