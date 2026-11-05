#!/usr/bin/env bash
#
# vigia.sh — diz se uma frente de orquestração avançou nos últimos <limite> minutos.
#
# Avanço é o mais recente entre o mtime do arquivo de estado (o PLANO da frente) e o
# horário do último commit de cada ramo indicado. Imprime a idade de cada um.
#
# Read-only: só lê o mtime do arquivo e o `git log` dos ramos; não escreve nada.
# Quem avisa (ex.: `maestri notify`) é o cron ou a routine que chama o script, nunca
# o script: o `maestri` está fora da stack permitida (`ARTIFACTS_SPEC.md` §0.9).
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.7/§0.9.
# Códigos de saída: 0 houve avanço, 1 parado acima do limite, 2 erro de execução, 3 uso inválido.

set -euo pipefail

usage() {
  cat <<'EOF'
Uso: bash ~/.codeflow/framework/core/scripts/vigia.sh [--limite <minutos>] <arquivo-de-estado> [<ramo>...]

Roda na raiz do repositório quando há ramos. Limite padrão: 30 minutos.
Saídas: 0 houve avanço, 1 parado acima do limite, 2 erro de execução, 3 uso inválido.
EOF
}

uso_invalido() {
  printf '✗ %s\n' "$1" >&2
  usage >&2
  exit 3
}

limite=30
if [ "${1:-}" = "--limite" ]; then
  [ "$#" -ge 2 ] || uso_invalido "informe os minutos depois de --limite."
  limite="$2"
  shift 2
fi
case "$limite" in
  ''|*[!0-9]*) uso_invalido "limite inválido: '$limite' (minutos, inteiro)." ;;
esac
[ "$#" -ge 1 ] || uso_invalido "informe o arquivo de estado."

estado="$1"
shift

if [ ! -e "$estado" ]; then
  printf '✗ arquivo de estado inacessível: %s\n' "$estado" >&2
  exit 2
fi

agora=$(date +%s)
mtime=$(stat -c %Y -- "$estado") || exit 2
recente=$mtime
printf '%s: %d min\n' "$estado" $(( (agora - mtime) / 60 ))

for ramo in "$@"; do
  if ! t=$(git log -1 --format=%ct "$ramo" -- 2>/dev/null) || [ -z "$t" ]; then
    printf '✗ ramo inacessível: %s\n' "$ramo" >&2
    exit 2
  fi
  printf '%s: %d min\n' "$ramo" $(( (agora - t) / 60 ))
  if [ "$t" -gt "$recente" ]; then recente=$t; fi
done

idade=$(( (agora - recente) / 60 ))
if [ "$idade" -gt "$limite" ]; then
  printf '✗ sem avanço há %d min (limite %d)\n' "$idade" "$limite"
  exit 1
fi
printf '✓ avanço há %d min (limite %d)\n' "$idade" "$limite"
