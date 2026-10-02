---
versão: 1.0
status: estável
atualizado: 2026-10-02
data: 2026-10-02
workflow: manual
tags: [operacao, trilhas, ramos, merge, deploy, wrappers, atribuicao, core]
status_decisão: ativa
supersede: null
relaciona-com: []
---

# Decisões: operação do repositório do codeflow por trilhas

## Contexto

Até 2026-10-02 o framework era editado direto no clone principal, que os symlinks de `~/.codeflow` expõem a todos os projetos: 77 commits lineares em `main`, nenhum pull request, sem CI, sem hooks, sem proteção de ramo. Cada edição valia para todos os projetos antes mesmo do commit. O dono passou a operar os projetos no Maestri, com um orquestrador por trilha despachando cada passo para um terminal próprio; dois projetos consumidores já operam assim, e o precedente é a ADR-73 de um deles. Esta decision registra as decisões do dono de 2026-10-02 para o repositório do framework, tomadas fora de workflow (fundação manual do `.codeflow/`, por isso `workflow: manual`), e a divergência dos wrappers de projeto com `framework/core/ARTIFACTS_SPEC.md` §1.11.6.

## Decisões tomadas

### 1. Três workspaces: hub, Evolução e Auditoria
O clone principal é o **hub**: ali o dono fala com o orquestrador sobre trabalho entre projetos, sem trocar de ramo, e ele só recebe `git pull --ff-only` depois de um merge. A **Evolução** (worktree `codeflow-wt/evolucao`) leva toda mudança no framework — bug, melhoria, feature, workflow ou skill novo — por um caminho só. A **Auditoria** (worktree `codeflow-wt/auditoria`) confere a coerência do framework consigo mesmo e colhe nos projetos o que se repetiu e merece virar universal; entrega lista para a Evolução. Os roteiros são `.codeflow/workflows/orquestrar-evolucao.md` e `.codeflow/workflows/orquestrar-auditoria.md`.
**Por quê:** o clone principal é produção — trocar de ramo, fazer `stash` ou deixar edição pendente nele muda o framework de todos os projetos na hora. Bug e melhoria seguem o mesmo ciclo aqui (texto normativo e scripts), e não há interface nem ambiente para uma trilha de QA.
**Alternativa rejeitada:** cinco trilhas como nos projetos consumidores (Spec, Bugs, Melhorias, Auditoria, QA), com a Spec morando no clone principal. Spec e QA não têm caso de uso aqui, e nenhuma trilha pode morar no clone principal.

### 2. Ramo por tarefa, pull request e merge pelo orquestrador
Cada tarefa num ramo nascido de `origin/main` (`evolucao/<slug>`, `chore/auditoria-<AAAA-MM-DD>-<slug>` — o slug evita colisão entre duas rodadas no mesmo dia), pull request para `main` e merge pelo orquestrador da trilha com `gh pr merge <n> --merge` — nunca squash, nunca rebase —, depois de revisão em terminal limpo com os gates de `.codeflow/manifest.md`, inclusive em pull request só de documentos. Commit só de documento depois da revisão aprovada (o laudo da revisão, a linha do índice) não pede nova revisão; trazer `origin/main` para o ramo pede o gate `check` de novo, por um revisor limpo. O ramo é apagado à mão (`deleteBranchOnMerge` está desligado).
**Por quê:** não há CI, proteção de ramo nem segundo humano; a revisão por quem não viu o trabalho nascer, com a saída real dos gates, é o único gate. O merge commit preserva os `sha` que relatórios e decisions citam.
**Alternativa rejeitada:** merge só com o dono presente. O dono quer autonomia, e o merge em `main` é reversível; o que não é reversível (core, mudança grande) continua com ele (decisões 6 e 8).

### 3. O deploy fecha o merge
Depois do merge: `git pull --ff-only` no clone principal e os pós-passos — setup de wrappers quando o conjunto de workflows ou meta-skills universais mudou ou quando mudaram os próprios scripts de setup, aviso de re-rodar `install.sh` nos projetos quando os moldes de spec ou o próprio `install.sh` mudaram, e aviso aos orquestradores dos projetos consumidores de que o framework mudou para todos ao mesmo tempo. Pull request só de documentos de `.codeflow/` não muda o framework ao vivo e dispensa o aviso.
**Por quê:** nada do que se commita numa worktree chega a `~/.codeflow` antes do pull; e o pull é um deploy simultâneo para todas as trilhas em curso nos projetos, que releem os arquivos a cada despacho.
**Alternativa rejeitada:** deixar o pull para o dono, quando lembrar. O framework ao vivo ficaria atrás de `main` sem ninguém saber.

### 4. O repositório continua público
`framework/core/SPEC.md` §3.3 passa a dizer "público". Todo pull request passa pelo gate `security` de `.codeflow/manifest.md`: `gitleaks git` dos commits do ramo e varredura das linhas que o ramo acrescenta contra a lista de nomes de projeto consumidor, de cliente e de pessoa em `~/.config/codeflow/nomes-proibidos.txt` — fora do repositório, `chmod 600`, porque publicar a lista exporia os nomes. A varredura imprime só o nome do arquivo, nunca o valor; varre linhas acrescentadas, não arquivos inteiros, porque arquivos do framework já trazem nomes anteriores a esta regra.
**Por quê:** o repositório já é público no GitHub, e o SPEC dizia o contrário. Sendo público, segredo ou nome de cliente num commit fica exposto.
**Alternativa rejeitada:** tornar o repositório privado para casar com o SPEC.

### 5. Atribuição a IA permitida
O commit leva o trailer `Co-Authored-By` da ferramenta de IA; o pull request leva o rodapé de geração dela. A regra está na constitution do projeto, que a skill `modo-delegado` manda seguir.
**Por quê:** é a prática da maior parte do histórico (49 de 77 commits), e a `modo-delegado` exige uma regra de atribuição que não existia.
**Alternativa rejeitada:** proibir a atribuição.

### 6. Mudança no core é gate duro
`framework/core/constitution.md`, `framework/core/glossary.md` e `framework/core/EVOLUTION.md` só mudam por decision própria, 30 dias e bump major (`framework/core/EVOLUTION.md`). Nenhum orquestrador aprova sozinho, e decisão delegada não destrava.
**Por quê:** o core muda o comportamento de toda sessão em todos os projetos, e o regime já foi furado uma vez (regra nova na constitution universal sem bump nem decision).
**Alternativa rejeitada:** deixar a Evolução tratar o core como qualquer outro arquivo, com revisão em terminal limpo.

### 7. Toda mudança paga o catálogo
Na mesma entrega: a árvore de `framework/core/SPEC.md` §2.2, a lista de §3.5, `README.md`, o termo novo em `framework/core/glossary.md` e o frontmatter dos arquivos tocados.
**Por quê:** o catálogo ficou defasado (a árvore do SPEC lista 9 workflows e 2 skills; existem 16 e 16) porque os commits recentes pularam esse passo.
**Alternativa rejeitada:** deixar o catálogo para a trilha de Auditoria corrigir em lote.

### 8. Mudança grande para no dono
O que a skill `change-sizing` classifica como grande, ou o que muda schema de artefato de projeto (`framework/core/ARTIFACTS_SPEC.md` Parte 2), para em `PARADO` para o dono. Não há trilha de spec.
**Por quê:** essa mudança quebra artefatos que os projetos já têm; o framework nunca usou o pipeline de spec em si mesmo, e não há caso que o justifique hoje.
**Alternativa rejeitada:** abrir uma trilha de Spec latente agora.

### 9. Wrappers de projeto com caminho relativo
`.claude/commands/orquestrar-evolucao.md` e `.claude/commands/orquestrar-auditoria.md` citam `.codeflow/workflows/orquestrar-<trilha>.md` por caminho relativo, escritos à mão. Isso diverge da letra de `framework/core/ARTIFACTS_SPEC.md` §1.11.6 regra 2 (caminho absoluto para `<projeto>/.codeflow/`) e do anti-padrão de §1.11.7 sobre wrapper escrito à mão. `install.sh` não roda neste repositório.
**Por quê:** cada worktree tem a própria cópia do roteiro; o caminho relativo resolve na worktree onde o comando roda. O caminho absoluto apontaria todas as worktrees para uma pasta só, e o `install.sh` o escreveria com a pasta onde rodou, sobrescrevendo o wrapper. Os dois projetos consumidores que operam por trilhas usam o mesmo caminho relativo.
**Alternativa rejeitada:** seguir a letra de §1.11.6 regra 2 com caminho absoluto, ou corrigir o ARTIFACTS_SPEC neste mesmo pull request. A correção do ARTIFACTS_SPEC é mudança de contrato e vai para a Evolução como item próprio.

### 10. A regressão do validador compara `origin/main` e o ramo
O gate `test` roda o `run-structural.sh` de `origin/main` e o do ramo sobre todas as specs reais dos projetos e reprova quando o código de saída diverge.
**Por quê:** 7 das 52 specs reais reprovam no validador de `origin/main` (formato anterior à §5 com fases); exigir saída `0` deixaria o gate vermelho sem mudança nenhuma.
**Alternativa rejeitada:** rodar o validador só no ramo e exigir saída `0` em todas as specs.

### 11. Decision escrita por recruta nasce sem linha no índice
A decision que um recruta escreve durante a tarefa nasce sem linha em `decisions/INDEX.md`; o orquestrador da trilha escreve a linha no fechamento, imediatamente antes do commit do índice. Isso diverge do anti-padrão de `framework/core/ARTIFACTS_SPEC.md` §2.5.7, que manda o workflow responsável atualizar decision e índice juntos.
**Por quê:** as duas trilhas trabalham em worktrees paralelas; dois recrutas editando o mesmo `INDEX.md` em ramos diferentes geram conflito no merge e contagem errada em `total_decisions`. Um só escritor do índice por trilha, no fechamento, elimina o conflito.
**Alternativa rejeitada:** seguir a letra de §2.5.7 e deixar cada recruta atualizar o índice no mesmo passo da decision.

## Próximos passos sugeridos

- Levar à Evolução a correção de `framework/core/ARTIFACTS_SPEC.md` §1.11.6 regra 2 para aceitar caminho relativo em wrapper de projeto.
- Levar à Auditoria os nomes anteriores à decisão 4 em arquivos versionados do framework (`README.md`, `LICENSE`, `framework/core/SPEC.md`, `framework/core/ARTIFACTS_SPEC.md`, `setup-codex-skills.sh`, `setup-codex-prompts.sh`), achados pela varredura de arquivo inteiro.
- Primeira lista da Auditoria: as seis inconsistências do levantamento de 2026-10-02 (catálogo defasado, frontmatter que não acompanha a edição, regra nova no core sem o regime do EVOLUTION, contradição entre §0.4 e §3.3 regra 16 do ARTIFACTS_SPEC, adapter de prompts dessincronizado, moldes de spec copiados divergentes).
