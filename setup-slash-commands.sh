#!/usr/bin/env bash
# setup-slash-commands.sh — registra workflows e meta-skills universais
# do codeflow como slash commands custom em Claude Code, via wrappers
# em ~/.claude/commands/. Conforme SPEC.md §3.6.1 e ARTIFACTS_SPEC.md §1.11.
#
# Uso:
#   bash ~/.codeflow/setup-slash-commands.sh           # sincroniza, avisa órfãos
#   bash ~/.codeflow/setup-slash-commands.sh --prune   # também remove órfãos
#
# Idempotente. Restrições: só toca em ~/.claude/commands/. Não modifica
# nada em ~/.codeflow/framework/ — apenas lê.

set -u

CODEFLOW="${HOME}/.codeflow"
CMD_DIR="${HOME}/.claude/commands"
PRUNE=0

for arg in "$@"; do
  case "$arg" in
    --prune) PRUNE=1 ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "✗ argumento inválido: $arg" >&2
      exit 3
      ;;
  esac
done

echo "codeflow — sincronização de slash commands"
echo

# 1. Pré-requisitos
if [ ! -d "${CODEFLOW}/framework" ]; then
  echo "✗ ${CODEFLOW}/framework/ ausente — instalação do codeflow não encontrada." >&2
  exit 1
fi
echo "✓ ${CODEFLOW}/framework/ presente."

mkdir -p "${CMD_DIR}"
echo "✓ ${CMD_DIR}/ pronto."
echo

# 2. Coletar fontes (workflows universais + meta-skills seed)
declare -a SOURCES_NAMES=()
declare -a SOURCES_PATHS=()
declare -a SOURCES_KINDS=()

for f in "${CODEFLOW}/framework/library/workflows"/*.md; do
  [ -f "$f" ] || continue
  name=$(basename "$f" .md)
  SOURCES_NAMES+=("$name")
  SOURCES_PATHS+=("$f")
  SOURCES_KINDS+=("workflow")
done

for d in "${CODEFLOW}/framework/meta"/*/; do
  [ -d "$d" ] || continue
  skill="${d}SKILL.md"
  [ -f "$skill" ] || continue
  name=$(basename "${d%/}")
  SOURCES_NAMES+=("$name")
  SOURCES_PATHS+=("$skill")
  SOURCES_KINDS+=("meta-skill")
done

if [ "${#SOURCES_NAMES[@]}" -eq 0 ]; then
  echo "⚠ nenhum workflow ou meta-skill encontrado em ${CODEFLOW}/framework/."
  exit 0
fi

# 3. Sincronizar wrappers
n_created=0
n_preserved=0
n_updated=0
errors=0

for i in "${!SOURCES_NAMES[@]}"; do
  name="${SOURCES_NAMES[$i]}"
  source_path="${SOURCES_PATHS[$i]}"
  kind="${SOURCES_KINDS[$i]}"
  wrapper="${CMD_DIR}/${name}.md"

  # Substituir HOME por ~ no path para o conteúdo do wrapper.
  # Usa prefix removal + concatenação manual (mais robusto que ${var/#H/~}
  # cuja substituição com ~ é tratada como tilde expansion em alguns bash).
  relative_from_home="${source_path#${HOME}/}"
  display_path="~/${relative_from_home}"

  if [ "$kind" = "workflow" ]; then
    new_body="Leia ${display_path} e execute o protocolo descrito ali, aplicando ao projeto atual. Carregue todos os arquivos listados em ## LEIA TAMBÉM antes de começar."
  else
    new_body="Leia ${display_path} e execute o protocolo da meta-skill no projeto atual. Carregue arquivos referenciados antes de começar."
  fi

  if [ -f "$wrapper" ]; then
    current=$(cat "$wrapper" 2>/dev/null || echo "")
    if [ "$current" = "$new_body" ]; then
      echo "✓ /${name} preservado."
      n_preserved=$((n_preserved + 1))
    else
      printf '%s\n' "$new_body" > "$wrapper" || { errors=$((errors + 1)); continue; }
      echo "✓ /${name} atualizado."
      n_updated=$((n_updated + 1))
    fi
  else
    printf '%s\n' "$new_body" > "$wrapper" || { errors=$((errors + 1)); continue; }
    echo "✓ /${name} criado."
    n_created=$((n_created + 1))
  fi
done

echo

# 4. Detectar órfãos: wrappers em ~/.claude/commands/ que apontam para
# ~/.codeflow/framework/ mas para arquivos que não existem mais.
n_orphans=0
n_pruned=0

for w in "${CMD_DIR}"/*.md; do
  [ -f "$w" ] || continue
  refpath=$(grep -oE '~/\.codeflow/framework/[^ ]+' "$w" | head -1 || true)
  [ -n "$refpath" ] || continue
  abspath="${refpath/#\~/${HOME}}"
  if [ ! -f "$abspath" ]; then
    n_orphans=$((n_orphans + 1))
    if [ "$PRUNE" -eq 1 ]; then
      rm -f "$w" && { echo "✗ órfão removido: $(basename "$w")"; n_pruned=$((n_pruned + 1)); }
    else
      echo "⚠ órfão: $(basename "$w") aponta para arquivo inexistente (${refpath})"
    fi
  fi
done

# 5. Resumo
echo
echo "Resumo:"
echo "  criados:     ${n_created}"
echo "  atualizados: ${n_updated}"
echo "  preservados: ${n_preserved}"
if [ "$PRUNE" -eq 1 ]; then
  echo "  órfãos removidos: ${n_pruned}"
else
  echo "  órfãos detectados: ${n_orphans} (rode com --prune para remover)"
fi

if [ "$errors" -gt 0 ]; then
  echo
  echo "✗ ${errors} erro(s) durante a sincronização." >&2
  exit 2
fi

echo
echo "✓ Sincronização concluída."
