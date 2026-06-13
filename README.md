---
versão: 1.0
status: estável
atualizado: 2026-05-23
---

# codeflow

Framework de workflows e skills para IA pareada com mantenedor humano. Define
princípios invariantes, vocabulário e protocolos de execução universais,
deixando ao projeto-alvo apenas o que é específico dele.

## Quando usar

Use o codeflow em projetos onde uma IA executa tarefas estruturadas (bugfix,
feature pequena, revisão, refactor seguro) e você quer respostas consistentes,
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

## Estrutura do framework

A árvore completa está descrita em `framework/core/SPEC.md` §2.2. Em alto nível:

- `framework/core/` — constitution, glossary, EVOLUTION, rules universais e os
  contratos normativos de runtime (`SPEC.md`, `ARTIFACTS_SPEC.md`).
- `framework/meta/` — meta-skills (`discover`, `bootstrap`, `create-*`).
- `framework/library/` — skills e workflows universais seed.
- `andaime/` — documentos de construção (BUILD_PLAN, VALIDATION, PROMPTS,
  EXECUTION_LOG). Não fazem parte do framework instalado.
- `install.sh` — script de instalação em projeto-alvo.

## Documentação detalhada

- `framework/core/SPEC.md` — fonte da verdade sobre arquitetura e decisões.
- `framework/core/ARTIFACTS_SPEC.md` — formato exato de cada arquivo do framework.
- `andaime/BUILD_PLAN.md` — como o framework foi construído, etapa por etapa.

## Como evoluir o framework

A política de evolução está em `framework/core/EVOLUTION.md`: promoção de
artefatos de projeto para universais, adição de rules, adição de meta-skills,
mudança no core e anti-evolução.

## Licença

MIT. Veja `LICENSE` na raiz do repositório.
