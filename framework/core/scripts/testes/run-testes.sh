#!/usr/bin/env bash
#
# run-testes.sh — casos dos scripts de `framework/core/scripts/`, com fixtures sintéticas.
#
# Cada arquivo de `casos/*.sh` é lido por este script e usa as funções abaixo:
#   caso <rc esperado> <descrição> <comando...>  roda o comando e confere o código de saída;
#                                                 a saída (stdout e stderr) fica em $SAIDA
#   tem <texto>        a última saída contém o texto (fixo)
#   nao_tem <texto>    a última saída não contém o texto
#   conta <texto> <n>  o texto aparece em exatamente n linhas da última saída
# Variáveis: $SCRIPTS (pasta dos scripts), $T (pasta temporária, apagada no fim).
#
# Uso: bash framework/core/scripts/testes/run-testes.sh [<nome-do-caso>...]
#   sem argumento roda todos os casos; com nomes, só `casos/<nome>.sh`.
# Não escreve fora da pasta temporária.
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.7/§0.9.
# Códigos de saída: 0 todos verdes, 1 algum caso vermelho, 2 erro de execução, 3 caso inexistente.

set -uo pipefail

dir=$(cd "$(dirname "$0")" && pwd) || exit 2
SCRIPTS=$(cd "$dir/.." && pwd) || exit 2
T=$(mktemp -d) || { printf '✗ mktemp falhou\n' >&2; exit 2; }
trap 'rm -rf "$T"' EXIT
SAIDA="$T/.saida"
total=0
falhas=0
grupo=""

caso() {
  local esperado=$1 desc=$2 rc
  shift 2
  total=$((total + 1))
  "$@" > "$SAIDA" 2>&1
  rc=$?
  if [ "$rc" = "$esperado" ]; then
    printf '  ✓ %s\n' "$desc"
  else
    printf '  ✗ %s: esperado rc=%s, veio rc=%s\n' "$desc" "$esperado" "$rc"
    sed 's/^/      | /' "$SAIDA" | tail -n 10
    falhas=$((falhas + 1))
  fi
}

_confere() {
  # _confere <ok 0|1> <descrição>
  total=$((total + 1))
  if [ "$1" = 0 ]; then
    printf '  ✓ %s\n' "$2"
  else
    printf '  ✗ %s\n' "$2"
    sed 's/^/      | /' "$SAIDA" | tail -n 10
    falhas=$((falhas + 1))
  fi
}
tem() { grep -qF -- "$1" "$SAIDA"; _confere $? "saída contém: $1"; }
nao_tem() { ! grep -qF -- "$1" "$SAIDA"; _confere $? "saída não contém: $1"; }
conta() {
  local n
  n=$(grep -cF -- "$1" "$SAIDA")
  [ "$n" = "$2" ]
  _confere $? "saída tem $2 linha(s) com: $1 (veio $n)"
}

if [ "$#" -gt 0 ]; then
  lista=()
  for nome in "$@"; do
    [ -f "$dir/casos/$nome.sh" ] || { printf '✗ caso inexistente: %s\n' "$nome" >&2; exit 3; }
    lista+=("$dir/casos/$nome.sh")
  done
else
  lista=("$dir"/casos/*.sh)
fi

for c in "${lista[@]}"; do
  grupo=$(basename "$c" .sh)
  printf '%s\n' "$grupo"
  # shellcheck source=/dev/null
  . "$c"
done

if [ "$falhas" -gt 0 ]; then
  printf '✗ %d de %d verificações vermelhas\n' "$falhas" "$total"
  exit 1
fi
printf '✓ %d verificações verdes\n' "$total"
exit 0
