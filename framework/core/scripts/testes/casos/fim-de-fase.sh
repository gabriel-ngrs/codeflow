# casos do fim-de-fase.sh — lido por ../run-testes.sh (usa caso, tem, nao_tem, $SCRIPTS, $T)

p="$T/fim-de-fase"
mkdir -p "$p/.codeflow/checkpoints"
git -C "$p" init -q
ff="$SCRIPTS/fim-de-fase.sh"
ativa="$p/.codeflow/checkpoints/fase-ativa"
log="$p/.codeflow/checkpoints/fim-de-fase-2.log"

fase_ativa() { printf 'spec=.codeflow/specs/x/SPEC_X.md\nfase=2\ncriterio=%s\n' "$1" > "$ativa"; }
manifest_l0() {
  printf '# Manifest do projeto: x\n\n## Gate\n\n| Camada | Quando | Comando | Tempo-alvo | Trava |\n|---|---|---|---|---|\n| L0 | loop | %s | 1 min | não |\n| L1 | PR | `true` | 5 min | não |\n\n## Padrões detectados\n' "$1" > "$p/.codeflow/manifest.md"
}
rodar() { (cd "$p" && bash "$ff" "$@"); }
rodar_stdin() { local e=$1; shift; (cd "$p" && printf '%s' "$e" | bash "$ff" "$@"); }

caso 0 "sem fase-ativa sai 0" rodar
tem "⚠ sem fase ativa"
caso 0 "sem fase-ativa, no --hook, sai 0" rodar_stdin '{}' --hook

fase_ativa 'true'
caso 0 "critério verde sai 0" rodar
tem "✓ critério da fase 2: true"
tem "⚠ sem L0"
caso 0 "o log foi gravado" test -s "$log"

fase_ativa 'echo saida-do-criterio; false'
caso 1 "critério vermelho sai 1" rodar
tem "✗ critério da fase 2"
caso 0 "o log guarda a saída e o código" grep -q 'código de saída: 1' "$log"
caso 2 "critério vermelho no --hook sai 2" rodar_stdin '{"stop_hook_active": false}' --hook
tem "saida-do-criterio"
tem "código de saída: 1"
caso 0 "stop_hook_active true sai 0 sem rodar" rodar_stdin '{"session_id":"x","stop_hook_active": true}' --hook
nao_tem "critério"

fase_ativa 'true'
manifest_l0 '`false`'
caso 1 "L0 vermelho do ## Gate sai 1" rodar
tem "✗ L0: false"
manifest_l0 '`true`'
caso 0 "L0 verde do ## Gate sai 0" rodar
tem "✓ L0: true"
manifest_l0 '`lint` (bloco acima)'
caso 0 "L0 que é nome de gate fica só com aviso" rodar
tem "⚠ o L0 aponta o gate"
rm -f "$p/.codeflow/manifest.md"

printf 'fase=2\n' > "$ativa"
caso 3 "fase-ativa sem criterio sai 3" rodar
caso 0 "fase-ativa sem criterio, no --hook, sai 0" rodar_stdin '{}' --hook
printf 'fase=../x\ncriterio=true\n' > "$ativa"
caso 3 "id de fase com barra sai 3" rodar

fase_ativa 'true'
chmod 000 "$ativa"
if [ ! -r "$ativa" ]; then
  caso 2 "fase-ativa ilegível sai 2" rodar
  caso 0 "fase-ativa ilegível, no --hook, sai 0" rodar_stdin '{}' --hook
fi
chmod 600 "$ativa"

caso 3 "argumento desconhecido sai 3" rodar --xyz
caso 3 "dois argumentos saem 3" rodar --hook a
