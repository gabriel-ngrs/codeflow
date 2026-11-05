#!/usr/bin/env bash
#
# check-commits.sh — confere os commits do ramo contra as regras de registro.
#
# Intervalo: `<merge-base de base e HEAD>..HEAD`, sem os commits de merge (o assunto
# deles é do git ou da plataforma). Regras:
#   - assunto com até 72 caracteres, no formato Conventional Commits
#     (`<tipo>(<escopo>)?!?: <assunto>`);
#   - em ramo `bug/*`, `melhoria/*` ou `chore/*`, ao menos um commit do intervalo traz a
#     linha `Tamanho: P`, `Tamanho: M` ou `Tamanho: G` (skill `change-sizing` §5);
#   - nenhum commit só para acertar sha ou range (`ARTIFACTS_SPEC.md` §2.9.7).
#
# Somente leitura: não escreve no repositório nem fora dele.
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.7/§0.9.
# Códigos de saída: 0 intervalo limpo, 1 regra violada, 2 erro de execução (fora de um
# repositório git), 3 uso inválido (sem base, ou base que não resolve).

set -uo pipefail
export LC_ALL=C.UTF-8 2>/dev/null || true

usage() {
  cat <<'EOF'
Uso: bash ~/.codeflow/framework/core/scripts/check-commits.sh <base> [--ramo <nome>]

Confere os commits de <merge-base de base e HEAD>..HEAD: assunto até 72 caracteres
em Conventional Commits, trailer Tamanho: nos ramos bug/*, melhoria/* e chore/*,
nenhum commit só para acertar sha. --ramo troca o nome do ramo conferido (padrão: o atual).
Saídas: 0 limpo, 1 regra violada, 2 erro de execução, 3 uso inválido.
EOF
}

base=""
ramo=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --ramo) [ "$#" -ge 2 ] || { usage >&2; exit 3; }; ramo=$2; shift 2 ;;
    -*) printf '✗ opção desconhecida: %s\n' "$1" >&2; usage >&2; exit 3 ;;
    *) [ -z "$base" ] || { printf '✗ mais de uma base\n' >&2; usage >&2; exit 3; }; base=$1; shift ;;
  esac
done
if [ -z "$base" ]; then
  printf '✗ argumento inválido: informe a base (ex.: origin/main).\n' >&2
  usage >&2
  exit 3
fi

git rev-parse --git-dir >/dev/null 2>&1 || { printf '✗ fora de um repositório git\n' >&2; exit 2; }
git rev-parse --verify --quiet "$base^{commit}" >/dev/null || { printf '✗ base não resolve: %s\n' "$base" >&2; exit 3; }
mb=$(git merge-base "$base" HEAD) || { printf '✗ sem merge-base entre %s e HEAD\n' "$base" >&2; exit 2; }
[ -n "$ramo" ] || ramo=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)

falhas=0
n=0
tamanho=0
tipos='feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert'

while IFS= read -r sha; do
  [ -n "$sha" ] || continue
  n=$((n + 1))
  curto=$(git rev-parse --short "$sha")
  assunto=$(git log -1 --format=%s "$sha")
  if [ "${#assunto}" -gt 72 ]; then
    printf '✗ %s: assunto com %d caracteres (teto 72): %s\n' "$curto" "${#assunto}" "$assunto"
    falhas=$((falhas + 1))
  fi
  if ! printf '%s' "$assunto" | grep -Eq "^($tipos)(\([^()]+\))?!?: [^ ]"; then
    printf '✗ %s: assunto fora de Conventional Commits: %s\n' "$curto" "$assunto"
    falhas=$((falhas + 1))
  fi
  if printf '%s' "$assunto" | grep -Eiq '(acert|corrig)[a-z]* (o |os )?(sha|range)'; then
    printf '✗ %s: commit só para acertar sha ou range: %s\n' "$curto" "$assunto"
    falhas=$((falhas + 1))
  fi
  if git log -1 --format=%B "$sha" | grep -Eq '^Tamanho: (P|M|G)[[:space:]]*$'; then
    tamanho=1
  fi
done < <(git rev-list --no-merges "$mb..HEAD")

case "$ramo" in
  bug/*|melhoria/*|chore/*)
    if [ "$n" -gt 0 ] && [ "$tamanho" = 0 ]; then
      printf '✗ ramo %s: nenhum commit do intervalo traz `Tamanho: P|M|G`\n' "$ramo"
      falhas=$((falhas + 1))
    fi ;;
esac

if [ "$falhas" -gt 0 ]; then
  printf '✗ %d problema(s) em %d commit(s) de %s..HEAD\n' "$falhas" "$n" "$(git rev-parse --short "$mb")"
  exit 1
fi
printf '✓ %d commit(s) de %s..HEAD conferidos\n' "$n" "$(git rev-parse --short "$mb")"
exit 0
