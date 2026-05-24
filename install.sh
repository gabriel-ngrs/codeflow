#!/usr/bin/env bash
#
# install.sh — instala o codeflow no projeto-alvo.
#
# Cria a estrutura mínima `.codeflow/` (INDEX placeholder, decisions/, checkpoints/),
# adiciona `.codeflow/checkpoints/` ao `.gitignore` do projeto e imprime próximos
# passos. Não modifica nenhum arquivo na raiz do projeto além do `.gitignore`.
#
# Conforme `SPEC.md` §3.9 (decisão e anti-decisão) e §7 (decisões técnicas).
# Códigos de saída: 0 sucesso, 1 falha de regra, 2 erro de execução, 3 input inválido.

set -euo pipefail

SUCESSO="✓"
FALHA="✗"
AVISO="⚠"

print_ok()    { printf '%s %s\n' "$SUCESSO" "$1"; }
print_falha() { printf '%s %s\n' "$FALHA"   "$1" >&2; }
print_aviso() { printf '%s %s\n' "$AVISO"   "$1"; }

usage() {
  cat <<'EOF'
Uso: bash ~/.codeflow/install.sh

Roda na raiz do projeto-alvo. Não aceita argumentos.
EOF
}

if [ "$#" -gt 0 ]; then
  print_falha "Argumentos não suportados."
  usage >&2
  exit 3
fi

echo "codeflow — instalação no projeto-alvo"
echo

# --- Pré-requisitos -----------------------------------------------------------

# 1. git disponível
if ! command -v git >/dev/null 2>&1; then
  print_falha "git não está disponível no PATH. Instale antes de continuar."
  exit 2
fi
print_ok "git disponível."

# 2. ~/.codeflow/ existe
CODEFLOW_HOME="${HOME}/.codeflow"
if [ ! -d "$CODEFLOW_HOME" ]; then
  print_falha "${CODEFLOW_HOME}/ ausente. Clone o framework antes de rodar o install."
  exit 1
fi
print_ok "${CODEFLOW_HOME}/ presente."

# 3. Diretório atual é repositório git
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  print_falha "Diretório atual não é repositório git."
  echo "  Sugestão: inicialize o repositório do projeto antes de instalar o codeflow."
  exit 1
fi
print_ok "Diretório atual é repositório git."

# 4. Makefile (apenas aviso)
if [ -f Makefile ]; then
  print_ok "Makefile presente."
else
  print_aviso "Makefile ausente. Recomendado para targets canônicos (check, test, lint, typecheck)."
fi

echo

# --- Criação da estrutura .codeflow/ ------------------------------------------

mkdir -p .codeflow/decisions .codeflow/checkpoints

# INDEX.md (placeholder, idempotente)
if [ -f .codeflow/INDEX.md ]; then
  print_ok ".codeflow/INDEX.md já existe — preservado."
else
  cat > .codeflow/INDEX.md <<'EOF'
---
versão: 1.0
status: experimental
atualizado: 2026-05-23
schema_version: 1.0
---

# INDEX do .codeflow/ do projeto

## Placeholder

Este INDEX é um placeholder criado por `install.sh`. Para popular com conteúdo
real, invoque uma das meta-skills do framework:

- `/discover` — projeto existente: descobre estrutura e gera constitution,
  manifest e INDEX definitivos.
- `/bootstrap` — projeto novo: cria estrutura mínima e os artefatos iniciais
  do `.codeflow/`.
EOF
  print_ok ".codeflow/INDEX.md criado (placeholder)."
fi

print_ok ".codeflow/decisions/ presente."
print_ok ".codeflow/checkpoints/ presente."

# --- .gitignore (idempotente) -------------------------------------------------

GITIGNORE_ENTRY=".codeflow/checkpoints/"

if [ ! -f .gitignore ]; then
  printf '%s\n' "$GITIGNORE_ENTRY" > .gitignore
  print_ok ".gitignore criado com ${GITIGNORE_ENTRY}."
elif grep -qxF "$GITIGNORE_ENTRY" .gitignore || grep -qxF ".codeflow/checkpoints" .gitignore; then
  print_ok ".gitignore já lista ${GITIGNORE_ENTRY}."
else
  printf '%s\n' "$GITIGNORE_ENTRY" >> .gitignore
  print_ok "${GITIGNORE_ENTRY} adicionado ao .gitignore."
fi

# --- Slash commands de projeto (sincronização local) -------------------------
#
# Se o projeto já tem workflows próprios em .codeflow/workflows/, gera wrappers
# correspondentes em .claude/commands/ deste projeto. Conforme SPEC.md §3.6.1
# e ARTIFACTS_SPEC.md §1.11. Idempotente. Não remove órfãos (projetos
# compartilhados podem ter wrappers de outros mantenedores).

PROJ_WORKFLOWS_DIR=".codeflow/workflows"
PROJ_CMD_DIR=".claude/commands"

if [ -d "$PROJ_WORKFLOWS_DIR" ] && ls "$PROJ_WORKFLOWS_DIR"/*.md >/dev/null 2>&1; then
  mkdir -p "$PROJ_CMD_DIR"
  proj_abs=$(pwd)
  n_proj_created=0
  n_proj_preserved=0

  for wf in "$PROJ_WORKFLOWS_DIR"/*.md; do
    [ -f "$wf" ] || continue
    wf_name=$(basename "$wf" .md)
    wrapper="${PROJ_CMD_DIR}/${wf_name}.md"
    new_body="Leia ${proj_abs}/${wf} e execute o protocolo descrito ali, aplicando ao projeto atual. Carregue todos os arquivos listados em ## LEIA TAMBÉM antes de começar."

    if [ -f "$wrapper" ] && [ "$(cat "$wrapper" 2>/dev/null)" = "$new_body" ]; then
      n_proj_preserved=$((n_proj_preserved + 1))
    else
      printf '%s\n' "$new_body" > "$wrapper"
      n_proj_created=$((n_proj_created + 1))
    fi
  done

  echo
  print_ok "${PROJ_CMD_DIR}/ sincronizado (${n_proj_created} novo(s), ${n_proj_preserved} preservado(s))."
  if ! grep -qE '\.claude/' .gitignore 2>/dev/null && ! grep -qE '\.claude/commands' .gitignore 2>/dev/null; then
    print_aviso ".claude/commands/ NÃO foi adicionado ao .gitignore — decida caso a caso (projetos compartilhados podem ou não versionar wrappers locais)."
  fi
fi

# --- Mensagem final -----------------------------------------------------------

echo
printf '%s %s\n' "$SUCESSO" "Instalação concluída."
echo
echo "Próximos passos:"
echo "  - Projeto existente: invoque /discover"
echo "  - Projeto novo:      invoque /bootstrap"
echo

exit 0
