#!/usr/bin/env bash
#
# agente-barato.sh — roda uma tarefa não interativa no Codex primeiro e cai no Claude quando a
# cota do Codex acaba, o teto diário estoura ou o `codex` não está instalado.
#
# Grava o contador de despachos Codex do dia em
# `${XDG_CACHE_HOME:-$HOME/.cache}/codeflow/codex-AAAA-MM-DD` (um inteiro). Falha do Codex
# sem mensagem de cota não cai no Claude: repassa a saída e sai 1. A cota se reconhece só na
# linha de erro do Codex (stderr), nunca na saída da tarefa nem no eco do prompt.
# O Codex roda sempre o Sol: médio no perfil base, alto com --alto (`-p revisor`).
# `codex` e `claude` são a carga do script, não a lógica (exceção declarada no `SPEC.md` §7.3).
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.7/§0.9.
# Códigos de saída: rc do agente que rodou (0 ok); com --contar, 0 abaixo do teto e 1 no teto;
# 1 falha do Codex sem cota, 2 erro de execução (nenhum agente), 3 uso inválido.

set -uo pipefail

usage() {
  cat <<'USO'
Uso: bash ~/.codeflow/framework/core/scripts/agente-barato.sh [--alto] [--escrita] [--teto <n>] "<tarefa>"
     bash ~/.codeflow/framework/core/scripts/agente-barato.sh --contar [--teto <n>]

--alto     Sol alto (-p revisor); padrão: Sol médio (perfil base do ~/.codex/config.toml).
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

alto=0
sandbox=read-only
teto=20
contar=0
tarefa=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --alto) alto=1; shift ;;
    --escrita) sandbox=workspace-write; shift ;;
    --teto) [ "$#" -ge 2 ] || uso_invalido "informe o teto."; teto=$2; shift 2 ;;
    --contar) contar=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) uso_invalido "opção desconhecida: $1" ;;
    *) [ -z "$tarefa" ] || uso_invalido "uma tarefa só, entre aspas."; tarefa=$1; shift ;;
  esac
done
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
  printf "claude: %s\n" "$1" >&2
  claude -p --effort medium "$tarefa" </dev/null
  exit $?
}

command -v codex >/dev/null || claude_roda "codex ausente"
[ "$usados" -lt "$teto" ] || claude_roda "teto diario de $teto atingido"

args=(exec -s "$sandbox")
esforco=medio
[ "$alto" = 1 ] && { args+=(-p revisor); esforco=alto; }
saida=$(mktemp) && erro=$(mktemp) || exit 2
trap 'rm -f "$saida" "$erro"' EXIT
soma || exit 2
printf 'codex: sol %s (%d de %d hoje)\n' "$esforco" $((usados + 1)) "$teto" >&2
codex "${args[@]}" "$tarefa" </dev/null > "$saida" 2> "$erro"
rc=$?
# Cota só pelo erro do próprio Codex: linha de erro no stderr, nunca a saída da tarefa (stdout)
# nem o eco do prompt (linhas iguais às da tarefa ficam fora).
if [ "$rc" != 0 ] \
  && grep -iE '^(\[[^]]*\] *)?error[]: ]' "$erro" | grep -vxF -f <(printf '%s\n' "$tarefa") \
     | grep -qiE 'usage_limit_reached|usage limit|rate limit|quota'; then
  claude_roda "cota do Codex esgotada"
fi
cat "$saida"
cat "$erro" >&2
[ "$rc" = 0 ] || exit 1
exit 0
