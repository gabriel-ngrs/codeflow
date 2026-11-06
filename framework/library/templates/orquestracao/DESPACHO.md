MODO DELEGADO — antes de tudo, leia e siga ~/.codeflow/framework/library/skills/modo-delegado/SKILL.md.
Orquestrador: <nome do terminal do Maestro>
Pasta: <worktree> — comece com `cd <worktree>`.
Ramo: <ramo> (já aberto; não troque) | somente leitura
Workflow: /<workflow> sobre <alvo>
Modelo: <papel> · <Opus · medium|high | Codex Sol médio|alto> (tabela 4b do modo-delegado)
Decisões delegadas:
  1. <decisão que responde um gate do workflow>
Regras de todo despacho:
  1. Só a pasta e o ramo acima; sem push, PR nem merge; nunca trocar de ramo, nem stash, nem rebase.
  2. `git add` só pelos caminhos tocados; Conventional Commits do projeto, com o trailer dele.
  3. Nunca perguntar ao dono: o que as decisões não cobrem segue a triagem do modo-delegado.
  4. Ler por trecho (`grep -n` e `sed -n`); documento existente muda por Edit, não reescrito.
  5. Nenhum segredo, dado real nem nome de cliente em arquivo versionado ou no retorno.
  6. Retorno em até 15 linhas; o detalhe fica em `.codeflow/checkpoints/`.
Regras do projeto: <só as que o modo-delegado e o workflow não trazem>
Commitar ao fim: sim | não
Contexto (leia por trecho): <caminhos e seções, nunca "leia tudo">
Ao terminar (CONCLUÍDO, PRECISA DE DECISÃO ou PARADO): `maestri ask "<orquestrador>" "<retorno>"`.
