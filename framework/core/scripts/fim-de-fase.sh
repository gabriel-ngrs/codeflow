#!/usr/bin/env bash
#
# fim-de-fase.sh — confere o critério de conclusão da fase ativa e o L0 do projeto.
#
# Lê `.codeflow/checkpoints/fase-ativa` (linhas `chave=valor`: `spec`, `fase`, `criterio`),
# roda o comando do critério e, se o manifest tem `## Gate`, o comando da linha L0 (o
# primeiro trecho entre crases da coluna Comando). Grava a saída inteira em
# `.codeflow/checkpoints/fim-de-fase-<fase>.log` e imprime o resumo.
#
# Roda na raiz do repositório (sobe até ela pelo git, quando há). Não escreve nada além
# do log. L0 que é só o nome de um gate do manifest (`lint`, `check`...) não é comando:
# fica com aviso, para rodar à parte.
#
# Modo `--hook` (Stop hook do Claude Code, molde em `templates/hooks/`): lê o JSON do
# stdin com grep; com `"stop_hook_active": true`, sem `fase-ativa` ou com erro de
# execução, sai 0 sem prender o agente; com o gate vermelho, sai 2 com o fim do log no
# stderr, o que devolve o agente ao trabalho. A exceção de saída está na decision
# `2026-11-05-gate-e-registro`.
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.7/§0.9/§2.3.4/§2.8.3.
# Códigos de saída (fora do --hook): 0 verde ou sem fase ativa, 1 vermelho,
# 2 erro de execução, 3 uso inválido.

set -uo pipefail

usage() {
  cat <<'EOF'
Uso: bash ~/.codeflow/framework/core/scripts/fim-de-fase.sh [--hook]

Roda o critério de conclusão da fase em .codeflow/checkpoints/fase-ativa e o L0 do
## Gate do manifest; grava .codeflow/checkpoints/fim-de-fase-<fase>.log.
Saídas: 0 verde ou sem fase ativa, 1 vermelho, 2 erro de execução, 3 uso inválido.
Com --hook: 2 no vermelho; 0 em todo o resto.
EOF
}

hook=0
case "$#:${1:-}" in
  0:) ;;
  1:--hook) hook=1 ;;
  1:-h|1:--help) usage; exit 0 ;;
  *) printf '✗ argumento inválido: %s\n' "$*" >&2; usage >&2; exit 3 ;;
esac

# erro de execução: no --hook não prende o agente
erro() {
  printf '✗ %s\n' "$1" >&2
  if [ "$hook" = 1 ]; then exit 0; fi
  exit 2
}

if [ "$hook" = 1 ] && [ ! -t 0 ]; then
  entrada=$(cat 2>/dev/null || true)
  if printf '%s' "$entrada" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
    exit 0
  fi
fi

raiz=$(git rev-parse --show-toplevel 2>/dev/null) || raiz=$PWD
cd "$raiz" || erro "não consegui entrar na raiz: $raiz"

ativa=.codeflow/checkpoints/fase-ativa
if [ ! -f "$ativa" ]; then
  [ "$hook" = 1 ] || printf '⚠ sem fase ativa (%s ausente): nada a conferir\n' "$ativa"
  exit 0
fi
[ -r "$ativa" ] || erro "$ativa sem permissão de leitura"

valor() { grep -m1 "^$1=" "$ativa" | cut -d= -f2-; }
spec=$(valor spec)
fase=$(valor fase)
criterio=$(valor criterio)

if [ -z "$fase" ] || [ -z "$criterio" ]; then
  printf '✗ %s sem `fase=` ou sem `criterio=`\n' "$ativa" >&2
  if [ "$hook" = 1 ]; then exit 0; fi
  exit 3
fi
case "$fase" in
  *[!A-Za-z0-9._-]*)
    printf '✗ id de fase inválido em %s: %s\n' "$ativa" "$fase" >&2
    if [ "$hook" = 1 ]; then exit 0; fi
    exit 3 ;;
esac

# L0: primeira célula entre crases da coluna Comando da linha L0 de ## Gate
l0=""
if [ -f .codeflow/manifest.md ]; then
  l0=$(awk -F'|' '
    /^## / { g = ($0 ~ /^## Gate[ \t]*$/); next }
    g && $2 ~ /^[ \t]*L0[ \t]*$/ {
      if (match($4, /`[^`]+`/)) print substr($4, RSTART + 1, RLENGTH - 2)
      exit
    }' .codeflow/manifest.md)
fi

log=".codeflow/checkpoints/fim-de-fase-$fase.log"
: > "$log" 2>/dev/null || erro "não consegui gravar $log"

rodar() {
  # rodar <rótulo> <comando>: anexa a saída ao log e devolve o código do comando
  local rc
  {
    printf '## %s: %s\n' "$1" "$2"
    bash -c "$2" </dev/null 2>&1
    rc=$?
    printf 'código de saída: %d\n\n' "$rc"
    return "$rc"
  } >> "$log"
}

{
  printf '# fim-de-fase %s — %s\n' "$fase" "$(date '+%Y-%m-%dT%H:%M:%S%z')"
  printf 'spec: %s\n\n' "${spec:-[—]}"
} >> "$log" || erro "não consegui gravar $log"

verde=1
if rodar "critério" "$criterio"; then
  printf '✓ critério da fase %s: %s\n' "$fase" "$criterio"
else
  printf '✗ critério da fase %s: %s\n' "$fase" "$criterio"
  verde=0
fi

case "$l0" in
  "") printf '⚠ sem L0 no ## Gate do manifest: só o critério foi conferido\n' ;;
  check|lint|typecheck|test|security)
    printf '⚠ o L0 aponta o gate `%s` do manifest, não um comando: rodá-lo à parte\n' "$l0" ;;
  *)
    if rodar "L0" "$l0"; then
      printf '✓ L0: %s\n' "$l0"
    else
      printf '✗ L0: %s\n' "$l0"
      verde=0
    fi ;;
esac

printf 'log: %s\n' "$log"

if [ "$verde" = 1 ]; then
  exit 0
fi
if [ "$hook" = 1 ]; then
  {
    printf '✗ fim de fase %s vermelho; últimas linhas de %s:\n' "$fase" "$log"
    tail -n 20 "$log"
  } >&2
  exit 2
fi
exit 1
