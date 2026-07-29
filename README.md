---
versão: 1.3
status: estável
atualizado: 2026-07-29
---

# codeflow

Framework de workflows e skills para IA pareada com mantenedor humano. Define
princípios invariantes, vocabulário e protocolos de execução universais,
deixando ao projeto-alvo apenas o que é específico dele.

## Quando usar

Use o codeflow em projetos onde uma IA executa tarefas estruturadas — correção
de bug (`/bugfix`) e o pipeline de spec (especificar, executar e avaliar uma
feature fase a fase, com `/create-spec`, `/execute-spec-phase`,
`/evaluate-spec-phase` e `/spec-status`) — e você quer respostas consistentes,
diff mínimo e decisões registradas.

## Pré-requisitos

- bash 4.0 ou superior.
- git (qualquer versão recente).
- Make (opcional; usado para targets canônicos no projeto-alvo).
- Uma ferramenta de IA que execute slash commands.

## Instalação em um projeto-alvo

Na raiz do projeto onde você quer usar o codeflow:

```
cd <projeto>
bash ~/.codeflow/install.sh
```

O script cria a estrutura `.codeflow/` mínima, adiciona
`.codeflow/checkpoints/` ao `.gitignore`, e imprime próximos passos. Não toca
em nenhum outro arquivo do projeto.

## Primeiros passos pós-instalação

- Projeto existente: invoque `/discover` para inspecionar o projeto, conduzir
  entrevista qualificada (no máximo cinco perguntas) e gerar `constitution.md`,
  `manifest.md`, `INDEX.md` e `discovered.md` em `<projeto>/.codeflow/`.
- Projeto novo: invoque `/bootstrap` para criar estrutura mínima e os
  artefatos iniciais do `.codeflow/` a partir de uma ideia.

## Workflows no Codex

O adapter principal de Codex usa skills locais em `~/.agents/skills/`. A
invocação no Codex fica com `$<nome>` ou pelo menu `/skills`:

```
bash ~/.codeflow/setup-codex-skills.sh
```

Depois reinicie o Codex ou abra um chat novo. No dia a dia:

```
$bugfix Corrija o bug descrito...
$create-spec Quero especificar...
$execute-spec-phase Execute a fase 2...
```

Para workflows específicos de um projeto, registre-os com prefixo para evitar
colisão com comandos universais:

```
bash ~/.codeflow/setup-codex-skills.sh --project-dir ~/Projetos/ICCNC --project-prefix iccnc
```

A invocação fica:

```
$iccnc-<workflow>
```

Custom prompts em `~/.codex/prompts/` são mantidos apenas como adapter de
compatibilidade para builds que exponham `/prompts:<nome>`. Na CLI local
0.146.0, o caminho funcional é skills.

## Estrutura do framework

A árvore completa está descrita em `framework/core/SPEC.md` §2.2. Em alto nível:

- `framework/core/` — constitution, glossary, EVOLUTION, rules universais, os
  contratos normativos de runtime (`SPEC.md`, `ARTIFACTS_SPEC.md`) e o validador
  estrutural (`scripts/run-structural.sh`).
- `framework/meta/` — meta-skills (`discover`, `bootstrap`, `create-*`).
- `framework/library/` — skills e workflows universais seed.
- `install.sh` — script de instalação em projeto-alvo.
- `setup-slash-commands.sh` — sincroniza wrappers para Claude Code.
- `setup-codex-skills.sh` — sincroniza skills locais para Codex.
- `setup-codex-prompts.sh` — sincroniza prompts customizados para builds de
  Codex que exponham `/prompts:<nome>`.

## Documentação detalhada

- `framework/core/SPEC.md` — fonte da verdade sobre arquitetura e decisões.
- `framework/core/ARTIFACTS_SPEC.md` — formato exato de cada arquivo do framework.
- `framework/core/EVOLUTION.md` — política de evolução do framework.

## Como evoluir o framework

A política de evolução está em `framework/core/EVOLUTION.md`: promoção de
artefatos de projeto para universais, adição de rules, adição de meta-skills,
mudança no core e anti-evolução.

## Licença

MIT. Veja `LICENSE` na raiz do repositório.
