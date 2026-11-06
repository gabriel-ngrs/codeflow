# casos do agente-barato.sh — lido por ../run-testes.sh (usa caso, tem, nao_tem, $SCRIPTS, $T)

ab="$SCRIPTS/agente-barato.sh"
b="$T/ab-bin"
bs="$T/ab-bin-sem-codex"
mkdir -p "$b" "$bs"
# codex falso: grava os argumentos e ecoa o prompt no stderr, como o real; o modo vem de
# $AB_CODEX (ok, cota, rate, falha, quota-na-saida)
cat > "$b/codex" <<'FALSO'
#!/usr/bin/env bash
printf "%s\n" "$*" > "$AB_LOG/codex.args"
printf "user\n%s\n" "${!#}" >&2
case "${AB_CODEX:-ok}" in
  ok) echo "SAIDA-CODEX" ;;
  cota) echo "ERROR: usage_limit_reached" >&2; exit 1 ;;
  rate) echo "[2026-11-05T10:00:00] ERROR: Rate Limit exceeded" >&2; exit 1 ;;
  falha) echo "erro de briefing"; echo "ERROR: stream disconnected" >&2; exit 1 ;;
  quota-na-saida) echo "a quota do plano acabou (texto da tarefa)"; exit 1 ;;
esac
FALSO
cat > "$b/claude" <<'FALSO'
#!/usr/bin/env bash
printf '%s\n' "$*" > "$AB_LOG/claude.args"
[ -t 0 ] && echo "STDIN-TERMINAL"
echo "SAIDA-CLAUDE"
exit "${AB_CLAUDE_RC:-0}"
FALSO
chmod +x "$b/codex" "$b/claude"
cp "$b/claude" "$bs/claude"
AB_LOG="$T/ab-log"
mkdir -p "$AB_LOG"
cont="$T/ab-cache/codeflow/codex-$(date +%F)"
base="/usr/bin:/bin"
ab_rodar() { env PATH="$b:$base" HOME="$T" XDG_CACHE_HOME="$T/ab-cache" AB_LOG="$AB_LOG" bash "$ab" "$@"; }
ab_sem() { env PATH="$bs:$base" HOME="$T" XDG_CACHE_HOME="$T/ab-cache" AB_LOG="$AB_LOG" bash "$ab" "$@"; }
ab_limpa() { rm -f "$AB_LOG"/*.args "$cont"; }

# CA-1 e CA-8: Codex ok, contador sobe, Claude não roda
ab_limpa
caso 0 "codex ok sai 0" ab_rodar "tarefa um"
tem "SAIDA-CODEX"
nao_tem "SAIDA-CLAUDE"
caso 0 "contador do dia em XDG_CACHE_HOME vale 1" grep -qx 1 "$cont"
caso 1 "claude não foi chamado" test -e "$AB_LOG/claude.args"

# CA-7: Codex só Sol; médio é o perfil base, alto é -p revisor; read-only salvo --escrita
caso 0 "sol médio: sem -p, read-only" grep -qx "exec -s read-only tarefa um" "$AB_LOG/codex.args"
caso 0 "--alto" ab_rodar --alto "t"
tem "codex: sol alto (2 de 20 hoje)"
caso 0 "alto: -p revisor" grep -qx "exec -s read-only -p revisor t" "$AB_LOG/codex.args"
caso 0 "--alto com escrita" ab_rodar --alto --escrita "t"
caso 0 "escrita: workspace-write" grep -qx "exec -s workspace-write -p revisor t" "$AB_LOG/codex.args"
caso 3 "--perfil não existe mais" ab_rodar --perfil sol "t"

# CA-2: mensagem de cota cai no Claude
ab_limpa
AB_CODEX=cota
export AB_CODEX
caso 0 "usage_limit_reached cai no claude" ab_rodar "tarefa dois"
tem "SAIDA-CLAUDE"
nao_tem "STDIN-TERMINAL"
caso 0 "claude -p --effort medium com a tarefa" grep -qx -- '-p --effort medium tarefa dois' "$AB_LOG/claude.args"
AB_CODEX=rate
caso 0 "rate limit (maiúscula) cai no claude" ab_rodar "t"
tem "SAIDA-CLAUDE"
AB_CLAUDE_RC=1
export AB_CLAUDE_RC
caso 1 "rc é o do claude" ab_rodar "t"
unset AB_CLAUDE_RC

# CA-6: falha sem cota não cai no Claude
ab_limpa
AB_CODEX=falha
caso 1 "falha sem cota sai 1" ab_rodar "t"
tem "erro de briefing"
caso 1 "falha sem cota não chama o claude" test -e "$AB_LOG/claude.args"
caso 1 "prompt que cita rate limit e quota, erro comum, sai 1" ab_rodar "conferir o rate limit e a quota do endpoint"
nao_tem "SAIDA-CLAUDE"
caso 1 "eco do prompt não chama o claude" test -e "$AB_LOG/claude.args"
caso 1 "prompt numa linha de ERROR: quota, erro comum, sai 1" ab_rodar "ERROR: quota"
AB_CODEX=quota-na-saida
caso 1 "quota na saída da tarefa (stdout) não cai no claude" ab_rodar "t"
tem "a quota do plano acabou"
caso 1 "saída da tarefa não chama o claude" test -e "$AB_LOG/claude.args"
unset AB_CODEX

# CA-3: sem codex vai direto ao Claude
ab_limpa
caso 0 "sem codex vai ao claude" ab_sem "t"
tem "SAIDA-CLAUDE"
rm "$bs/claude"
caso 2 "sem codex e sem claude sai 2" ab_sem "t"

# CA-4: teto do dia
ab_limpa
mkdir -p "$(dirname "$cont")"
echo 3 > "$cont"
caso 0 "no teto vai ao claude" ab_rodar --teto 3 "t"
tem "SAIDA-CLAUDE"
caso 1 "no teto não chama o codex" test -e "$AB_LOG/codex.args"
echo 19 > "$cont"
caso 0 "abaixo do teto padrão tenta o codex" ab_rodar "t"
tem "SAIDA-CODEX"
caso 0 "teto padrão é 20" ab_rodar "t"
tem "SAIDA-CLAUDE"

# CA-5: --contar
ab_limpa
caso 0 "--contar abaixo do teto sai 0" ab_rodar --contar --teto 2
caso 0 "--contar soma 1" grep -qx 1 "$cont"
caso 0 "--contar de novo sai 0" ab_rodar --contar --teto 2
caso 1 "--contar no teto sai 1" ab_rodar --contar --teto 2
caso 0 "--contar no teto não soma" grep -qx 2 "$cont"
caso 1 "--contar não roda agente" test -e "$AB_LOG/codex.args"

# CA-6: uso inválido
caso 3 "sem tarefa sai 3" ab_rodar
caso 3 "opção desconhecida sai 3" ab_rodar --xis "t"
caso 3 "teto inválido sai 3" ab_rodar --teto x "t"
unset AB_LOG
