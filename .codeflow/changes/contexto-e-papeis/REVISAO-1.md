---
mudanca: contexto-e-papeis
tentativa: 1
veredito: AJUSTAR
range_revisado: f97932e..784a85d
---

# Contexto enxuto e modelo por papel — Revisão

## 1. Veredito

**AJUSTAR**: há 1 BLOQUEANTE. O `pacote-da-fase.sh` trata como heading uma linha `# ...` que está dentro
de bloco de código. Com isso, o bloco da fase sai truncado sem nenhum aviso, e o executor perde o escopo
travado e os AC que vêm depois do bloco de código. Além disso, há 3 IMPORTANTES abertos, que pela regra
de escalada também contam como BLOQUEANTE. O resto da entrega está conforme: o gate `check` está verde e
os CA 1 a 4 e 7 a 13 foram conferidos com prova própria.

## 2. Critérios de aceite, conferidos no código

| CA | Atendido? | Evidência própria (teste rodado, arquivo:linha) |
|----|-----------|--------------------------------------------------|
| CA-1 | sim | `## LEIA TAMBÉM` com `.codeflow/INDEX.md`: só `audit.md` e `create-spec.md`. Os 14 que citam o manifest usam a expressão `awk`. `spec-status.md` não cita o trio. `ideacao.md` não tem diff desde `6dae155` |
| CA-2 | sim | No manifest daqui, a expressão devolve só `## Comandos de validação`, com 52 linhas, a seção inteira. A variante com stack devolve Stack, Comandos e Padrões. Numa entrada sintética, `## Gate` e `## CI` saem junto |
| CA-3 | sim | `ARTIFACTS_SPEC.md:820` (com a exceção do `spec-status`, ratificada pelo Maestro), `:879`, `:1032`, `:1506` e `:2002`; `create-workflow/SKILL.md:87`. As quatro entradas antigas continuam válidas (`:820`) |
| CA-4 | sim | Wrappers gerados em `HOME` temporário: slash 16 novos e 0 antigos; codex 32 novos e 0 antigos. Um `bugfix.md` antigo foi atualizado e um `orquestrar-x.md` escrito à mão ficou intocado. `install.sh` ensaiado em `$T` com `HOME="$T"`: rc=0, wrapper novo criado, `velho.md` e `orquestrar-x.md` preservados (listados como divergentes, sem reescrita) |
| CA-5 | sim, com B-1 | 493 fases das 66 specs reais: rc=0, saída com frontmatter, TL;DR, `### Fase <id>` e rodapé; árvore igual antes e depois. Fase inexistente dá rc=1 sem stdout; sem argumento, rc=3; id vazio, rc=3; arquivo inexistente, rc=2 |
| CA-6 | sim | Spec sintética: AC-1 e FR-1 (com a linha de continuação) saem com o texto da spec; `⚠ FR-9 citado na fase e não encontrado` sai no rodapé com rc=0 |
| CA-7 | sim | `grep 'íntegra'` no `execute-spec-phase.md` não acha nada; `evaluate-spec-phase.md:42` grava e lê o pacote e diz que "pode conferir contra a spec inteira", e a DoD está em `:84`; `grep stash` vazio. O critério do veredito (Passo 4) não tem diff |
| CA-8 | sim | `implement-change.md:40`, `execute-spec-phase.md:41` (degrau 1: "A spec manda; não corte requisito") e `bugfix.md:37`. Os três têm a escada de 5 degraus, o "Nunca corte" e a linha do relatório |
| CA-9 | sim | `modo-delegado/SKILL.md:37` guarda a linha `Modelo:`; leitura por trecho em `:60` (4a); tabela, escalada e Codex em `:69` (4b); `grep -c Sonnet` = 0 |
| CA-10 | sim | `DESPACHO.md` com `Modelo:` e 1280 bytes; `CICLO-DO-RECRUTA.md` regras 2 e 4; `MAESTRO.md` regras 1 a 3. `vigia.sh` em repositório descartável: parado dá rc=1, avanço rc=0, sem argumento rc=3, limite inválido rc=3, ramo ou estado inexistente rc=2; `git status`, HEAD e mtime iguais |
| CA-11 | sim | `SPEC.md:513` (§3.7), §2.5 (`:292-293`) e `:1818` (§10.9). Os hunks do `SPEC.md` não alcançam a §8.3. A decision existe e não tem linha no `decisions/INDEX.md` (contagem 0) |
| CA-12 | sim | `AGENTS.md`: 1440 bytes e 37 linhas; `CLAUDE.md` = `@AGENTS.md`; bootstrap Fase 3 e Proibições ("só com sim"); discover Fase 1 mede e Fase 4b "nunca edita" |
| CA-13 | sim | `SPEC.md` §2.2 e `README.md:90-97` atualizados; todo `.md` tocado que tem frontmatter de framework está em `atualizado: 2026-11-05`; `git diff` do core, de `templates/specs/` e do manifest vazio; nenhum hunk entre `### 2.8` e `### 2.11`; `check` verde (§8) |

## 3. Conformidade com o plano

- As 4 etapas foram entregues como planejado, e todo arquivo tocado está no mapa do plano (§4). Os desvios
  estão declarados no `EXECUCAO.md` §4 e são justificáveis. A exceção do `spec-status` no §1.5.3 foi
  ratificada pelo Maestro (decisão 3 do despacho).
- Nada fora do escopo: o core está intocado, assim como §2.8 a §2.10, `templates/specs/` e o manifest.
- Atenção (a): os wrappers de projeto preservados não quebram. O `install.sh` não reescreve wrapper
  existente, e o `setup-slash-commands.sh` só regrava nomes de workflow universal em `~/.claude/commands/`.
  O `orquestrar-*` escrito à mão ficou intocado no ensaio.
- Atenção (b): falha na entrada com bloco de código (B-1). Nas 493 fases reais, o pacote traz o bloco
  inteiro, o escopo travado e os AC/FR citados. Os contratos da §4 chegam pelas linhas do rodapé, com a
  instrução de abri-las (`execute-spec-phase.md` Passo 3).
- Atenção (c): atendida. A regra YAGNI não manda cortar validação, tratamento de erro, segurança nem
  critério; os quatro estão no "Nunca corte" ou em "mantém validação e tratamento de erro" (S-4).
- Atenção (d): atendida. Nenhum caminho absoluto nas linhas acrescentadas (`grep -E '/home/|/Users/'`
  vazio), e a varredura de nomes do gate `security` está limpa.

## 4. Achados BLOQUEANTES

- **B-1**: `framework/core/scripts/pacote-da-fase.sh:69-73`, usado em `:66` e `:85`. A função `nivel_h` não
  sabe se a linha está dentro de um bloco de código. Assim, uma linha `# comentário` dentro de um bloco
  ` ```bash ` da fase vira heading de nível 1 e encerra o bloco da fase (`:85`) e a seção `## 5` (`fim_secao`).
  O efeito aparece na spec sintética (§8): somem `make test`, o bullet inteiro do **Escopo travado** e o AC-2
  citado nele. O rodapé informa a faixa já truncada (`21–24`, `## 5. Plano: 20–24`), e as linhas 25 a 30
  ficam sem nenhum ponteiro e sem `⚠`. Nenhuma das 66 specs reais tem hoje `#` dentro de bloco de código,
  mas o molde de spec não proíbe esse caso, e os blocos bash deste framework usam comentário `# ...`. A
  régua violada: o pacote não pode deixar o executor sem o escopo travado e os AC da fase (PLANO §4, linha
  do script, e §7 risco 2; atenção b do despacho). O defeito vale também para o avaliador, que usa o mesmo
  pacote. **Correção:** em `nivel_h` e no laço `{ L[NR] = $0 }`, marcar quais linhas estão dentro de bloco
  de código (alternar o estado em `^(```|~~~)`) e devolver 0 nessas linhas. Somar o caso da spec sintética
  ao teste do script e repetir o laço sobre as 66 specs.

## 5. Achados IMPORTANTES

- **I-1**: `framework/core/SPEC.md:927`, `:931-934` e `:1454`. O §5.1 continua dizendo que "a IA é instruída
  a ler todos os arquivos listados" e que a ordem de carga traz o INDEX e o manifest inteiros. O §6.7.1 diz
  que "a IA é instruída a ler o INDEX antes de qualquer outro artefato". Isso contradiz o novo
  `ARTIFACTS_SPEC.md` §1.5.3 e o wrapper novo dentro do próprio contrato. Não invalida nenhum artefato,
  porque a ordem é "orientativa", mas deixa duas leituras do contrato. **Destino: corrigir agora**, apontando
  o §5.1 e o §6.7.1 para o §1.5.3, uma frase cada.
- **I-2**: `implement-change.md:40`, `execute-spec-phase.md:41` e `bugfix.md:37`. A seção YAGNI entrou como
  `### Menor mudança que resolve (YAGNI)` dentro de `## Protocolo`. O schema dos workflows médios
  (`ARTIFACTS_SPEC.md` §1.6.3, item 6) define o Protocolo como "passos sequenciais como sub-seções
  `### Passo N — <nome>`", e nenhum outro workflow tem `###` fora de Passo no Protocolo. A contagem da regra
  §1.6.6.4 continua entre 4 e 7. **Destino: corrigir agora**, movendo o bloco para `## Antes de começar`
  (é uma regra que vale para a tarefa inteira), sem mudar o texto.
- **I-3**: `.codeflow/decisions/2026-11-05-contexto-e-papeis.md:64` e `:34`. A decision viola o
  `ARTIFACTS_SPEC.md` §2.5.6, regras 8 e 9. Tem `## Consequências` no lugar de `## Próximos passos
  sugeridos` e usa `**Alternativa descartada:**` no lugar de `**Alternativa rejeitada:**`, nas 4 decisões.
  As 4 decisions anteriores seguem o schema. **Destino: corrigir agora** (renomear o heading e o
  rótulo; o conteúdo de "Consequências" cabe em "Próximos passos sugeridos" ou numa seção extra depois).

Escalada: com 3 IMPORTANTES abertos ao mesmo tempo, o conjunto conta como BLOQUEANTE (review-change,
Passo 3). O veredito já é AJUSTAR por causa do B-1.

## 6. Sugestões

- **S-1**: a expressão `awk` casa por prefixo: `## Gateway` e `## CIdade` também saem. O risco é baixo,
  porque o schema do manifest (§2.3) tem seções fixas. Fechar com `( |$)` depois do grupo.
- **S-2**: `ARTIFACTS_SPEC.md:2002` diz que o `audit` recalcula o `validation_hash`, mas o `audit.md` não
  tem nenhum passo de hash. Isso segue o CA-3 literal, mas descreve um comportamento que não existe.
- **S-3**: depois do deploy, todo wrapper de projeto gerado antes desta mudança vai aparecer no `install.sh`
  como "divergente". É o comportamento esperado; o aviso de deploy do plano (§7) precisa dizer isso.
- **S-4**: no "Nunca corte" da YAGNI, "tratamento de erro que evita perda de dados" é mais estreito do que
  "tratamento de erro". Nada manda cortar, mas trocar por "tratamento de erro existente ou que evita perda de
  dados" tira a ambiguidade.
- **S-5**: a 4b do `modo-delegado` cita Opus, Codex e `claude --model`, o que esbarra em `ARTIFACTS_SPEC.md`
  §3.10, regra 37 (ferramenta de IA em conteúdo neutro). A política de modelo foi aprovada pelo dono (D2),
  e a skill já era do Maestri. Fica só registrado.
- **S-6**: `templates/orquestracao/` e `templates/projeto/` estão sem o `README.md` que as outras pastas de
  `templates/` têm. Os moldes sem frontmatter seguem o precedente: moldes carregam o frontmatter do artefato
  que geram, e `CLAUDE.md`/`AGENTS.md` não têm frontmatter.

## 7. Erros de registro

- Nenhum. O `range` e os arquivos do `EXECUCAO.md` batem com o código; as linhas citadas nos CA conferem.

## 8. Comandos rodados e saídas reais

```text
# gate check do manifest, na raiz da worktree, HEAD 11cddb2 (origin/main = f94bc19; diffs por merge-base)
lint=0
test=0          # 66 specs: nenhuma linha "✗ ... origin/main=a ramo=b"; setup-slash 16 + codex-skills 21 criados
INF 7 commits scanned. / INF no leaks found
security=0      # gitleaks limpo; varredura de nomes nas linhas acrescentadas: nenhum arquivo
# (1ª tentativa deu security=1 por um `set -o pipefail` que acrescentei ao script de ensaio, e que inverte o
#  `grep` sem casamento; rodado de novo como o manifest manda, deu 0)

# CA-1
INDEX em LEIA TAMBÉM: audit.md, create-spec.md
16 workflows; ideacao: sem diff

# CA-2
## Comandos de validação     (52 linhas = a seção inteira)
variante: ## Stack identificada / ## Comandos de validação / ## Padrões detectados
sintético: ## Gate a / ## CI b / ## Comandos de validação d
armadilha (S-1): ## CIdade z / ## Gateway y

# CA-4 — HOME temporário
slash=0 cskills=0 cprompts=0
✓ /bugfix atualizado.        (antigo → novo)
orquestrar-x.md: "Leia .codeflow/workflows/orquestrar-x.md e execute o protocolo"   (intocado)
slash antigos: 0 novos: 16 | codex novos: 32 antigos: 0
# install.sh em $T/proj, HOME="$T"
install rc=0
✓ .claude/commands/ sincronizado (1 novo(s), 2 preservado(s)).
⚠ 2 wrapper(s) preservado(s) com conteúdo diferente do gerado — não reescritos ...
    .claude/commands/orquestrar-x.md
    .claude/commands/velho.md
novo.md: Leia <$T>/proj/.codeflow/workflows/novo.md e execute ... como cada item manda (...) antes de começar.

# CA-5 — pacote-da-fase.sh sobre as specs reais
fases=493 falhas=0 sem_tldr=0
árvore igual
inexistente rc=1 | sem arg rc=3 | arquivo rc=2 | id vazio rc=3
# '#' dentro de bloco de código em alguma spec real: nenhuma

# CA-6 e B-1 — spec sintética (Fase 1 com bloco bash contendo "# comentário" e escopo travado depois)
### Fase 1 — um
- **Testes:** cobre AC-1 e FR-1; FR-9 não existe.
- Passos: rodar
<cerca de código bash>            ← corta aqui: some "make test", o "Escopo travado" e o AC-2
## Itens citados na fase (texto da spec)
- **AC-1** — dado A então B
- **FR-1** — faz A
  continua A
- ## 5. Plano: 20–24 (a fase 1 está nas linhas 21–24)      ← faixa truncada; 25–30 sem ponteiro
- ⚠ FR-9 citado na fase e não encontrado na spec
rc=0

# CA-10 — vigia.sh em repositório descartável
✗ sem avanço há 3600823 min (limite 30)   parado rc=1
✓ avanço há 0 min (limite 30)             avanço rc=0
sem arg rc=3 | limite inválido rc=3 | ramo inexistente rc=2 | estado inexistente rc=2
repo igual depois das chamadas

# CA-12 / CA-13
DESPACHO.md 1280 bytes | AGENTS.md 37 linhas 1440 bytes | CLAUDE.md = @AGENTS.md
core + templates/specs + manifest: diff vazio | ARTIFACTS hunks: 2,4,820,879,1032,1506,1686,1705,1734,1748,1999
decision no decisions/INDEX.md: 0

# Parte 3, arquivo por arquivo (os 34 do diff)
BOM / CRLF / sem LF final / controle: nenhum
sem frontmatter: os 5 moldes de templates/orquestracao e templates/projeto (precedente: S-6)
caminho absoluto, TODO/FIXME: nenhum | comentário HTML: só no molde AGENTS.md (precedente: molde PLANO.md)

# §2.5.6 da decision (I-3)
2026-11-05-contexto-e-papeis.md: ## Contexto|## Decisões tomadas|## Consequências| rej=0 desc=4
(as 4 anteriores: ...|## Próximos passos sugeridos| rej≥3)

# §1.6.3 (I-2): ### fora de Passo dentro de ## Protocolo
bugfix.md, execute-spec-phase.md, implement-change.md: ### Menor mudança que resolve (YAGNI)   (nenhum outro)

# só informação: merge-tree origin/main x HEAD
CONFLICT (content): Merge conflict in framework/library/workflows/refactor.md
```

## 9. Divergências entre o relatório e o código

- `EXECUCAO.md` CA-5 diz "493 fases ... com saída 0 ... heading e rodapé": confere. Mas o relatório não
  testou o bloco de código dentro da fase, e é aí que o pacote quebra (B-1).
- `EXECUCAO.md` §5 registra `6 commits scanned` no gitleaks. A revisão viu 7, porque o range agora inclui
  `11cddb2`. Não é divergência de código.
