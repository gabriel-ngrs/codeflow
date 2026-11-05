---
versão: 1.0
status: estável
atualizado: 2026-11-05
data: 2026-11-05
workflow: implement-change
tags: [spec, contrato, orquestracao, modelo, contexto, bootstrap]
status_decisão: ativa
supersede: null
relaciona-com: [2026-10-02-operacao-por-trilhas, 2026-10-05-aceleracao-do-ciclo]
---

# Decisões: contexto enxuto, modelo por papel e moldes de orquestração

## Contexto

A pesquisa de tokens de 2026-11-02 mediu onde o gasto dos agentes se concentra: o trio INDEX + constitution +
manifest lido por todo recruta, a spec inteira lida por fase, quase todas as chamadas em Opus high, recrutas
reabertos a cada rework e um Maestro que vive mais do que a tarefa. Em 2026-11-05 o dono aprovou a lista inteira
de mudanças. A aprovação cobre os pontos que, pelo regime do framework, param no dono: o contrato do
`framework/core/SPEC.md` (§3.7 e §10.9) e a política de modelo por papel. Nenhum termo novo entra no
`glossary.md`: "pacote da fase", "vigília" e "recruta" ficam como texto descritivo. O plano da mudança está em
`.codeflow/changes/contexto-e-papeis/PLANO.md`.

## Decisões tomadas

### 1. Sessão fresca por tarefa (emenda do `SPEC.md` §3.7)
A regra deixa de ser "uma sessão nova por invocação de workflow" e passa a ser "uma sessão nova por tarefa". A
correção da mesma tarefa (rework de fase reprovada, `AJUSTAR` de revisão, erro de registro) pode seguir na
sessão do executor enquanto o contexto couber. O avaliador e o revisor independentes rodam sempre em outra
sessão.
**Por quê:** o recruta reaberto a cada rework relê plano, spec e código que já tinha; a independência que
importa é a do avaliador, e ela não muda.
**Alternativa rejeitada:** manter o §3.7 literal e só recomendar o reuso nos roteiros, o que deixaria os
roteiros em conflito com o SPEC.

### 2. `CLAUDE.md` e `AGENTS.md` curtos pelo bootstrap (emenda do `SPEC.md` §10.9 e §2.5)
O §10.9 dizia que o codeflow nunca gera adapters na raiz do projeto. Passa a admitir uma exceção: num projeto
novo, o `bootstrap` **oferece** criar um `AGENTS.md` curto (≤ 8k chars, < 200 linhas) e um `CLAUDE.md` que só
importa `@AGENTS.md`, a partir de `framework/library/templates/projeto/`, e só escreve com "sim" explícito do
dono. O `discover` mede o tamanho dos que já existem e relata, sem editar. O §8.3 (workflow não toca
`CLAUDE.md`) continua valendo para todo o resto. A emenda é redigida aqui e aplicada na Etapa 4 do plano.
**Por quê:** o `CLAUDE.md` é lido em toda sessão; nos projetos medidos ele cresceu com narrativa de bug e de
spec. Um molde curto, oferecido e não imposto, corta esse custo sem o codeflow tomar o arquivo do projeto.
**Alternativa rejeitada:** manter o "nunca" e deixar cada projeto escrever o seu sem referência.

### 3. Modelo e esforço por papel (`modo-delegado` 4b)
Opus medium para executor, avaliador, revisor de mudança e conferente; Opus high para Maestro, redação e
revisão de spec, contrato, segurança e debug difícil. Escalada para high em duas falhas Lógicas seguidas, no
2º `REPROVADO` da mesma fase ou num sinal de risco da `change-sizing`. O Codex fica só como 2ª opinião na 1ª
rodada de revisão de spec, no máximo uma por spec, com retorno de até 15 linhas.
**Por quê:** a medição mostrou quase todas as chamadas em Opus high; medium custa cerca de um quarto a menos
com perda pequena, e a escalada cobre os casos de risco. Quem não segue a tabela continua em high.
**Alternativa rejeitada:** outro modelo menor para o executor, que fica fora até haver um A/B próprio.

### 4. Promoção dos moldes de orquestração a universais
`framework/library/templates/orquestracao/` nasce com `DESPACHO.md`, `CICLO-DO-RECRUTA.md` e `MAESTRO.md`, e
`framework/core/scripts/vigia.sh` nasce como script só leitura chamado por cron ou routine. São padrões que
dois projetos já praticavam nos próprios roteiros; a promoção a universal é aprovação do mantenedor, dada na
lista de 2026-11-05.
**Por quê:** o despacho era copiado de roteiro para roteiro, e a vigília feita pelo Maestro falhou duas vezes.
**Alternativa rejeitada:** deixar cada projeto manter a sua cópia.

## Próximos passos sugeridos
- Maestro: incluir a linha desta decision no `.codeflow/decisions/INDEX.md`.
- Orquestrador: A/B curto do avaliador em medium (refazer avaliações antigas) e medição de 2 fases com e sem o
  pacote da fase, antes de fixar a tabela e o pacote como padrão.
- Cada projeto: adotar os moldes de `framework/library/templates/orquestracao/` no próprio roteiro de
  orquestração, no ritmo dele; nada de projeto é reescrito.
- Deploy: `git pull --ff-only` em `~/.codeflow`, `setup-slash-commands.sh` e `setup-codex-skills.sh`; avisar
  os orquestradores de que o `modo-delegado` mudou.

## Notas
- O avaliador em medium é um risco declarado: o critério do veredito não muda.
- Desfazer: `git revert` dos commits da mudança; os workflows antigos continuam válidos.
