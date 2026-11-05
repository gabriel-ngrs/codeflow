---
mudanca: contexto-e-papeis
tipo: conferencia-de-delta
base_aprovada: c16d16f
range_conferido: c16d16f..1771437
veredito: APROVADO
---

# Conferência do delta de contexto-e-papeis

**Veredito: APROVADO** — o delta (752cf26, 1771437) fecha o I-1 e o I-2 da revisão 2 sem regressão.

## Evidência (saída real, 2026-11-05)

1. `git diff --stat c16d16f..HEAD`: só `framework/core/scripts/pacote-da-fase.sh` (+23/−4) e os
   workflows `execute-spec-phase.md` e `evaluate-spec-phase.md` (2/2 linhas cada). Não há arquivo
   de teste versionado para o script; os casos abaixo foram montados fora do repositório.
2. Casos sintéticos: cerca ```` com ``` dentro e cerca ~~~~ com ~~~ e ``` dentro → rc=0, linhas de
   dentro, escopo travado e AC-3 inteiros, faixa da fase certa no rodapé (14–21 e 14–24); a base
   c16d16f truncava o primeiro caso (escopo travado ausente). Cerca ```` fechada só por ``` → rc=1,
   stdout vazio. Mesma saída em gawk e mawk.
3. Laço nas specs reais (`~/Projetos/*/.codeflow/specs/*/SPEC_*.md`, sem `_TEMPLATES`): 66 specs,
   493 fases, rc≠0 = 0, saída idêntica à de c16d16f em todas.
4. Gate `check` do `.codeflow/manifest.md`: lint rc=0, test rc=0, security rc=0 (gitleaks: 16
   commits, no leaks found).
5. Texto novo dos workflows: com saída ≠ 0 o pacote se apaga, a spec é lida por trecho e o fato vai
   para o relatório; "Nunca seguir com o pacote vazio" (execute) e "Nunca avaliar contra o pacote
   vazio" (evaluate). Nenhum trecho manda seguir com pacote vazio.
