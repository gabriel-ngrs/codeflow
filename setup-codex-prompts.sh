#!/usr/bin/env bash
# setup-codex-prompts.sh — registra workflows e meta-skills do codeflow como
# custom prompts no Codex, via wrappers em <codex-home>/prompts/.
#
# Uso:
#   bash ~/.codeflow/setup-codex-prompts.sh
#   bash ~/.codeflow/setup-codex-prompts.sh --project-dir ~/Projetos/ICC
#   bash ~/.codeflow/setup-codex-prompts.sh --project-dir ~/Projetos/ICC --project-prefix icc
#   CODEX_HOME=~/.codex-dev bash ~/.codeflow/setup-codex-prompts.sh
#
# O destino é resolvido nesta ordem: --codex-home <path>, depois a env var
# CODEX_HOME, depois o default ~/.codex. Em qualquer caso, os prompts vão para
# <codex-home>/prompts/. No Codex, a invocação fica /prompts:<nome>.
#
# Idempotente. Restrições: não toca em .claude/ nem em ~/.claude/. Só escreve em
# <codex-home>/prompts/. Não modifica ~/.codeflow/framework/ — apenas lê.

set -u

CODEFLOW="${HOME}/.codeflow"
CODEX_HOME_OVERRIDE=""
PROJECT_DIR=""
PROJECT_PREFIX=""
FORCE=0
DRY_RUN=0

SUCESSO="✓"
FALHA="✗"
AVISO="⚠"

usage() {
  cat <<'EOF'
Uso: bash ~/.codeflow/setup-codex-prompts.sh [opções]

Opções:
  --project-dir <path>      Também registra workflows de <path>/.codeflow/workflows/.
  --project-prefix <nome>   Prefixo dos prompts de projeto (default: nome da pasta em kebab-case).
  --codex-home <path>       Diretório home do Codex (default: CODEX_HOME ou ~/.codex).
  --force                   Sobrescreve prompts homônimos que não foram gerados pelo codeflow.
  --dry-run                 Mostra o que seria feito sem escrever arquivos.
  -h, --help                Mostra esta ajuda.

Exemplos:
  bash ~/.codeflow/setup-codex-prompts.sh
  bash ~/.codeflow/setup-codex-prompts.sh --project-dir ~/Projetos/ICC --project-prefix icc
EOF
}

expand_path() {
  case "$1" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s/%s\n' "$HOME" "${1#~/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-dir)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
        printf '%s --project-dir exige um caminho como argumento.\n' "$FALHA" >&2
        exit 3
      fi
      PROJECT_DIR="$(expand_path "$2")"; shift 2 ;;
    --project-dir=*)
      PROJECT_DIR="$(expand_path "${1#--project-dir=}")"
      if [ -z "$PROJECT_DIR" ]; then
        printf '%s --project-dir= exige valor não-vazio.\n' "$FALHA" >&2
        exit 3
      fi
      shift ;;
    --project-prefix)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
        printf '%s --project-prefix exige um nome como argumento.\n' "$FALHA" >&2
        exit 3
      fi
      PROJECT_PREFIX="$(slugify "$2")"; shift 2 ;;
    --project-prefix=*)
      PROJECT_PREFIX="$(slugify "${1#--project-prefix=}")"
      if [ -z "$PROJECT_PREFIX" ]; then
        printf '%s --project-prefix= exige valor não-vazio.\n' "$FALHA" >&2
        exit 3
      fi
      shift ;;
    --codex-home)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
        printf '%s --codex-home exige um caminho como argumento.\n' "$FALHA" >&2
        exit 3
      fi
      CODEX_HOME_OVERRIDE="$(expand_path "$2")"; shift 2 ;;
    --codex-home=*)
      CODEX_HOME_OVERRIDE="$(expand_path "${1#--codex-home=}")"
      if [ -z "$CODEX_HOME_OVERRIDE" ]; then
        printf '%s --codex-home= exige valor não-vazio.\n' "$FALHA" >&2
        exit 3
      fi
      shift ;;
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      printf '%s argumento inválido: %s\n' "$FALHA" "$1" >&2
      exit 3 ;;
  esac
done

if [ -n "$CODEX_HOME_OVERRIDE" ]; then
  CODEX_HOME_DIR="$CODEX_HOME_OVERRIDE"
elif [ -n "${CODEX_HOME:-}" ]; then
  CODEX_HOME_DIR="$(expand_path "$CODEX_HOME")"
else
  CODEX_HOME_DIR="${HOME}/.codex"
fi
PROMPTS_DIR="${CODEX_HOME_DIR}/prompts"

echo "codeflow — sincronização de prompts do Codex"
echo

if [ ! -d "${CODEFLOW}/framework" ]; then
  printf '%s %s/framework/ ausente — exponha o framework em ~/.codeflow antes de sincronizar.\n' "$FALHA" "$CODEFLOW" >&2
  echo "  Exemplo: ln -s ~/Projetos/codeflow ~/.codeflow"
  exit 1
fi
printf '%s %s/framework/ presente.\n' "$SUCESSO" "$CODEFLOW"

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$PROMPTS_DIR" || {
    printf '%s não foi possível criar %s/.\n' "$FALHA" "$PROMPTS_DIR" >&2
    exit 2
  }
fi
printf '%s %s/ pronto.\n' "$SUCESSO" "$PROMPTS_DIR"
echo

n_created=0
n_updated=0
n_preserved=0
n_skipped=0
errors=0

write_prompt() {
  name="$1"
  description="$2"
  source_path="$3"
  body="$4"
  prompt="${PROMPTS_DIR}/${name}.md"
  new_body="$(printf -- '---\ndescription: %s\ncodeflow-generated: setup-codex-prompts.sh\ncodeflow-source: %s\n---\n\n%s\n' "$description" "$source_path" "$body")"

  if [ -f "$prompt" ]; then
    current="$(cat "$prompt" 2>/dev/null || printf '')"
    if [ "$current" = "$new_body" ]; then
      printf '%s /prompts:%s preservado.\n' "$SUCESSO" "$name"
      n_preserved=$((n_preserved + 1))
      return
    fi
    if ! grep -qF 'codeflow-generated: setup-codex-prompts.sh' "$prompt" 2>/dev/null && [ "$FORCE" -eq 0 ]; then
      printf '%s /prompts:%s existe e não foi gerado pelo codeflow — pulado (use --force para sobrescrever).\n' "$AVISO" "$name"
      n_skipped=$((n_skipped + 1))
      return
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '%s /prompts:%s seria atualizado.\n' "$AVISO" "$name"
    else
      printf '%s\n' "$new_body" > "$prompt" || { errors=$((errors + 1)); return; }
      printf '%s /prompts:%s atualizado.\n' "$SUCESSO" "$name"
    fi
    n_updated=$((n_updated + 1))
  else
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '%s /prompts:%s seria criado.\n' "$AVISO" "$name"
    else
      printf '%s\n' "$new_body" > "$prompt" || { errors=$((errors + 1)); return; }
      printf '%s /prompts:%s criado.\n' "$SUCESSO" "$name"
    fi
    n_created=$((n_created + 1))
  fi
}

for f in "${CODEFLOW}/framework/library/workflows"/*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f" .md)"
  display_path="~/.codeflow/framework/library/workflows/${name}.md"
  write_prompt \
    "$name" \
    "codeflow workflow ${name}" \
    "$display_path" \
    "Leia ${display_path} e execute o protocolo descrito ali, aplicando ao projeto atual. Carregue todos os arquivos listados em ## LEIA TAMBÉM antes de começar."
done

for d in "${CODEFLOW}/framework/meta"/*/; do
  [ -d "$d" ] || continue
  skill="${d}SKILL.md"
  [ -f "$skill" ] || continue
  name="$(basename "${d%/}")"
  display_path="~/.codeflow/framework/meta/${name}/SKILL.md"
  write_prompt \
    "$name" \
    "codeflow meta-skill ${name}" \
    "$display_path" \
    "Leia ${display_path} e execute o protocolo da meta-skill no projeto atual. Carregue arquivos referenciados antes de começar."
done

if [ -n "$PROJECT_DIR" ]; then
  if [ ! -d "$PROJECT_DIR" ]; then
    printf '%s projeto não encontrado: %s\n' "$FALHA" "$PROJECT_DIR" >&2
    exit 2
  fi
  project_abs="$(cd "$PROJECT_DIR" 2>/dev/null && pwd -P)" || {
    printf '%s não foi possível resolver o caminho do projeto: %s\n' "$FALHA" "$PROJECT_DIR" >&2
    exit 2
  }
  project_workflows="${project_abs}/.codeflow/workflows"

  if [ -z "$PROJECT_PREFIX" ]; then
    PROJECT_PREFIX="$(slugify "$(basename "$project_abs")")"
  fi
  if [ -z "$PROJECT_PREFIX" ]; then
    printf '%s prefixo de projeto vazio após normalização.\n' "$FALHA" >&2
    exit 3
  fi

  echo
  if [ -d "$project_workflows" ] && ls "$project_workflows"/*.md >/dev/null 2>&1; then
    for f in "$project_workflows"/*.md; do
      [ -f "$f" ] || continue
      wf_name="$(basename "$f" .md)"
      prompt_name="${PROJECT_PREFIX}-${wf_name}"
      source_path="${project_abs}/.codeflow/workflows/${wf_name}.md"
      write_prompt \
        "$prompt_name" \
        "codeflow workflow de projeto ${PROJECT_PREFIX}/${wf_name}" \
        "$source_path" \
        "Leia ${source_path} e execute o protocolo descrito ali, aplicando ao projeto atual. Carregue todos os arquivos listados em ## LEIA TAMBÉM antes de começar."
    done
  else
    printf '%s nenhum workflow de projeto encontrado em %s/.\n' "$AVISO" "$project_workflows"
  fi
fi

echo
echo "Resumo:"
echo "  criados:     ${n_created}"
echo "  atualizados: ${n_updated}"
echo "  preservados: ${n_preserved}"
echo "  pulados:     ${n_skipped}"

if [ "$errors" -gt 0 ]; then
  echo
  printf '%s %s erro(s) durante a sincronização.\n' "$FALHA" "$errors" >&2
  exit 2
fi

echo
printf '%s Sincronização concluída. Reinicie o Codex ou abra um chat novo para recarregar /prompts:.\n' "$SUCESSO"
