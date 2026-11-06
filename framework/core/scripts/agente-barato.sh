#!/usr/bin/env bash
#
# agente-barato.sh — roda uma tarefa não interativa no Codex primeiro e cai no Claude quando a
# cota do Codex acaba, o teto diário estoura ou o `codex` não está instalado.
#
# Grava o contador de despachos Codex do dia em
# `${XDG_CACHE_HOME:-$HOME/.cache}/codeflow/codex-AAAA-MM-DD` (um inteiro). Falha do Codex
# sem mensagem de cota não cai no Claude: repassa a saída e sai 1.
# `codex` e `claude` são a carga do script, não a lógica (exceção declarada no `SPEC.md` §7.3).
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.7/§0.9.
# Códigos de saída: rc do agente que rodou (0 ok); com --contar, 0 abaixo do teto e 1 no teto;
# 1 falha do Codex sem cota, 2 erro de execução (nenhum agente), 3 uso inválido.

set -uo pipefail

usage() {
  cat <<'USO'
Uso: bash ~/.codeflow/framework/core/scripts/agente-barato.sh [--perfil sol|luna|revisor] [--escrita] [--teto <n>] "<tarefa>"
     bash ~/.codeflow/framework/core/scripts/agente-barato.sh --contar [--teto <n>]

--perfil   sol (-p sol, esforço high), luna (padrão, perfil base), revisor (-p revisor).
--escrita  sandbox workspace-write (padrão: read-only).
--teto     despachos Codex por dia (padrão: 20).
--contar   só soma 1 ao contador do dia: sai 0 abaixo do teto, 1 no teto (não soma).
USO
}

uso_invalido() {
  printf '✗ %s\n' "$1" >&2
  usage >&2
  exit 3
}

perfil=luna
sandbox=read-only
teto=20
contar=0
tarefa=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --perfil) [ "$#" -ge 2 ] || uso_invalido "informe o perfil."; perfil=$2; shift 2 ;;
    --escrita) sandbox=workspace-write; shift ;;
    --teto) [ "$#" -ge 2 ] || uso_invalido "informe o teto."; teto=$2; shift 2 ;;
    --contar) contar=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) uso_invalido "opção desconhecida: $1" ;;
    *) [ -z "$tarefa" ] || uso_invalido "uma tarefa só, entre aspas."; tarefa=$1; shift ;;
  esac
done
case "$perfil" in sol|luna|revisor) ;; *) uso_invalido "perfil inválido: '$perfil'." ;; esac
case "$teto" in ''|*[!0-9]*) uso_invalido "teto inválido: '$teto' (inteiro)." ;; esac
[ "$contar" = 1 ] || [ -n "$tarefa" ] || uso_invalido "informe a tarefa."

cache="${XDG_CACHE_HOME:-$HOME/.cache}/codeflow"
contador="$cache/codex-$(date +%F)"
usados=0
[ -s "$contador" ] && usados=$(cat "$contador")
case "$usados" in *[!0-9]*) usados=0 ;; esac

soma() {
  mkdir -p "$cache" && printf '%d\n' $((usados + 1)) > "$contador"
}

if [ "$contar" = 1 ]; then
  [ "$usados" -lt "$teto" ] || { printf '⚠ teto do Codex: %d de %d hoje\n' "$usados" "$teto" >&2; exit 1; }
  soma || exit 2
  exit 0
fi

claude_roda() {
  command -v claude >/dev/null || { printf '✗ nem codex nem claude disponíveis\n' >&2; exit 2; }
  printf '→ claude (%s)\n' "$1" >&2
  claude -p --effort medium "$tarefa" </dev/null
  exit $?
}

command -v codex >/dev/null || claude_roda "codex ausente"
[ "$usados" -lt "$teto" ] || claude_roda "teto diário de $teto atingido"

args=(exec -s "$sandbox")
case "$perfil" in
  sol) args+=(-p sol -c model_reasoning_effort=high) ;;
  revisor) args+=(-p revisor) ;;
esac
saida=$(mktemp) || exit 2
trap 'rm -f "$saida"' EXIT
soma || exit 2
printf '→ codex %s (%d de %d hoje)\n' "$perfil" $((usados + 1)) "$teto" >&2
codex "${args[@]}" "$tarefa" </dev/null > "$saida" 2>&1
rc=$?
if [ "$rc" != 0 ] && grep -qiE 'usage_limit_reached|usage limit|rate limit|quota' "$saida"; then
  claude_roda "cota do Codex esgotada"
fi
cat "$saida"
[ "$rc" = 0 ] || exit 1
exit 0
