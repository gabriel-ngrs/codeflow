#!/usr/bin/env bash
#
# check-contexto.sh — confere o tamanho do contexto fixo que todo agente relê.
#
# Roda na raiz do projeto (sobe até ela pelo git, quando há) e conta caracteres:
#   - `CLAUDE.md` ≤ 8.000; com `AGENTS.md` na raiz, os dois são iguais, ou o `CLAUDE.md`
#     só importa o outro (`@AGENTS.md`, molde `templates/projeto/`), e o `AGENTS.md`
#     também cabe no teto;
#   - `MEMORY.md` do projeto, em `<config do Claude>/projects/<raiz com - no lugar de
#     cada caractere fora de [A-Za-z0-9]>/memory/` (config: `$CLAUDE_CONFIG_DIR`, ou
#     `~/.claude`) ≤ 5.000;
#   - `.codeflow/INDEX.md` ≤ 3.000; `.codeflow/constitution.md` ≤ 8.000;
#   - `.codeflow/manifest.md` ≤ 12.000, e a seção `## Comandos de validação` ≤ 4.000
#     (`ARTIFACTS_SPEC.md` §2.3.7);
#   - cada `.codeflow/specs/*/SPEC_*.md` com `status: active` ≤ 60.000 — só aviso (⚠).
# Arquivo ausente se pula. Todo teto se troca por argumento.
#
# Somente leitura: não escreve nada.
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.7/§0.9.
# Códigos de saída: 0 dentro dos tetos, 1 teto estourado, 2 erro de execução,
# 3 uso inválido.

set -uo pipefail
export LC_ALL=C.UTF-8 2>/dev/null || true

usage() {
  cat <<'EOF'
Uso: bash ~/.codeflow/framework/core/scripts/check-contexto.sh [--<item> <teto>]...

Itens e tetos padrão (caracteres): --claude 8000, --memory 5000, --index 3000,
--constitution 8000, --manifest 12000, --comandos 4000, --spec 60000 (só aviso).
Saídas: 0 dentro dos tetos, 1 teto estourado, 2 erro de execução, 3 uso inválido.
EOF
}

t_claude=8000
t_memory=5000
t_index=3000
t_constitution=8000
t_manifest=12000
t_comandos=4000
t_spec=60000

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --claude|--memory|--index|--constitution|--manifest|--comandos|--spec)
      if [ "$#" -lt 2 ] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        printf '✗ %s pede um número de caracteres\n' "$1" >&2; usage >&2; exit 3
      fi
      printf -v "t_${1#--}" '%s' "$2"
      shift 2 ;;
    *) printf '✗ argumento inválido: %s\n' "$1" >&2; usage >&2; exit 3 ;;
  esac
done

raiz=$(git rev-parse --show-toplevel 2>/dev/null) || raiz=$PWD
cd "$raiz" || { printf '✗ não consegui entrar na raiz: %s\n' "$raiz" >&2; exit 2; }

falhas=0
chars() { wc -m < "$1" | tr -d ' '; }

# teto <rótulo> <arquivo> <teto> [aviso]
teto() {
  local n
  [ -f "$2" ] || { printf '— %s ausente: pula\n' "$1"; return 0; }
  [ -r "$2" ] || { printf '✗ %s sem permissão de leitura\n' "$1" >&2; exit 2; }
  n=$(chars "$2")
  if [ "$n" -le "$3" ]; then
    printf '✓ %s: %s de %s caracteres\n' "$1" "$n" "$3"
  elif [ "${4:-}" = aviso ]; then
    printf '⚠ %s: %s caracteres, acima de %s\n' "$1" "$n" "$3"
  else
    printf '✗ %s: %s caracteres, acima de %s\n' "$1" "$n" "$3"
    falhas=$((falhas + 1))
  fi
}

teto "CLAUDE.md" CLAUDE.md "$t_claude"
if [ -f AGENTS.md ] && [ -f CLAUDE.md ]; then
  if cmp -s CLAUDE.md AGENTS.md; then
    printf '✓ CLAUDE.md igual ao AGENTS.md\n'
  elif [ "$(tr -d '[:space:]' < CLAUDE.md)" = "@AGENTS.md" ]; then
    printf '✓ CLAUDE.md importa o AGENTS.md\n'
    teto "AGENTS.md" AGENTS.md "$t_claude"
  else
    printf '✗ CLAUDE.md difere do AGENTS.md (nem igual, nem só `@AGENTS.md`)\n'
    falhas=$((falhas + 1))
  fi
fi

config=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
pasta=$(printf '%s' "$raiz" | sed 's/[^A-Za-z0-9]/-/g')
teto "MEMORY.md do projeto" "$config/projects/$pasta/memory/MEMORY.md" "$t_memory"

teto ".codeflow/INDEX.md" .codeflow/INDEX.md "$t_index"
teto ".codeflow/constitution.md" .codeflow/constitution.md "$t_constitution"
teto ".codeflow/manifest.md" .codeflow/manifest.md "$t_manifest"

if [ -f .codeflow/manifest.md ]; then
  secao=$(awk '/^## /{p=($0 ~ /^## Comandos de validação[ \t]*$/)} p' .codeflow/manifest.md)
  if [ -n "$secao" ]; then
    n=$(printf '%s\n' "$secao" | wc -m | tr -d ' ')
    if [ "$n" -le "$t_comandos" ]; then
      printf '✓ ## Comandos de validação: %s de %s caracteres\n' "$n" "$t_comandos"
    else
      printf '✗ ## Comandos de validação: %s caracteres, acima de %s (histórico vai para ## Notas de inspeção)\n' "$n" "$t_comandos"
      falhas=$((falhas + 1))
    fi
  fi
fi

for s in .codeflow/specs/*/SPEC_*.md; do
  [ -f "$s" ] || continue
  case "$s" in */_TEMPLATES/*) continue ;; esac
  if awk 'NR==1 && $0!="---"{exit 1} NR>1 && $0=="---"{exit 1} /^status:[ \t]*active[ \t]*$/{a=1; exit 0} END{exit !a}' "$s"; then
    teto "$s (ativa)" "$s" "$t_spec" aviso
  fi
done

if [ "$falhas" -gt 0 ]; then
  printf '✗ %d teto(s) estourado(s)\n' "$falhas"
  exit 1
fi
printf '✓ contexto fixo dentro dos tetos\n'
exit 0
