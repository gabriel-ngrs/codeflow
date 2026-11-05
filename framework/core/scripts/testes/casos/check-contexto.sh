# casos do check-contexto.sh — lido por ../run-testes.sh (usa caso, tem, nao_tem, $SCRIPTS, $T)

h="$T/check-contexto-home"
p="$h/Projetos/proj.x"
mkdir -p "$p/.codeflow/specs/s1"
git -C "$p" init -q
ck="$SCRIPTS/check-contexto.sh"
mem="$h/.claude/projects/$(printf '%s' "$p" | sed 's/[^A-Za-z0-9]/-/g')/memory"
mkdir -p "$mem"
rodar() { (cd "$p" && env -u CLAUDE_CONFIG_DIR HOME="$h" bash "$ck" "$@"); }
texto() { head -c "$2" /dev/zero | tr '\0' 'x' > "$1"; }

caso 0 "projeto vazio sai 0" rodar
tem "ausente: pula"

texto "$p/CLAUDE.md" 8000
caso 0 "CLAUDE.md de 8.000 sai 0" rodar
texto "$p/CLAUDE.md" 8001
caso 1 "CLAUDE.md de 8.001 sai 1" rodar
tem "✗ CLAUDE.md: 8001"
caso 0 "teto por argumento muda o veredito" rodar --claude 9000

texto "$p/CLAUDE.md" 100
texto "$p/AGENTS.md" 101
caso 1 "AGENTS.md diferente sai 1" rodar
tem "difere do AGENTS.md"
cp "$p/AGENTS.md" "$p/CLAUDE.md"
caso 0 "AGENTS.md igual sai 0" rodar
printf '@AGENTS.md\n' > "$p/CLAUDE.md"
caso 0 "CLAUDE.md que só importa o AGENTS.md sai 0" rodar
tem "importa o AGENTS.md"
texto "$p/AGENTS.md" 8001
caso 1 "o AGENTS.md importado também tem teto" rodar
rm -f "$p/AGENTS.md" "$p/CLAUDE.md"

texto "$mem/MEMORY.md" 5001
caso 1 "MEMORY.md de 5.001 sai 1" rodar
tem "✗ MEMORY.md do projeto: 5001"
caso 0 "--memory 6000 aceita" rodar --memory 6000
rm -f "$mem/MEMORY.md"

texto "$p/.codeflow/INDEX.md" 3001
caso 1 "INDEX de 3.001 sai 1" rodar
rm -f "$p/.codeflow/INDEX.md"
texto "$p/.codeflow/constitution.md" 8001
caso 1 "constitution de 8.001 sai 1" rodar
rm -f "$p/.codeflow/constitution.md"

{ printf '# Manifest do projeto: x\n\n## Comandos de validação\n\n'; head -c 4001 /dev/zero | tr '\0' 'x'; printf '\n\n## Padrões detectados\n\n- a\n'; } > "$p/.codeflow/manifest.md"
caso 1 "## Comandos de validação acima de 4.000 sai 1" rodar
tem "✗ ## Comandos de validação"
caso 0 "--comandos 5000 aceita" rodar --comandos 5000
texto "$p/.codeflow/manifest.md" 12001
caso 1 "manifest de 12.001 sai 1" rodar
rm -f "$p/.codeflow/manifest.md"

{ printf -- '---\nslug: s1\nstatus: active\n---\n'; head -c 60001 /dev/zero | tr '\0' 'x'; } > "$p/.codeflow/specs/s1/SPEC_S1.md"
caso 0 "SPEC ativa de 60.001 só avisa" rodar
tem "⚠ .codeflow/specs/s1/SPEC_S1.md (ativa)"
sed -i 's/^status: active$/status: done/' "$p/.codeflow/specs/s1/SPEC_S1.md"
caso 0 "SPEC concluída não entra" rodar
nao_tem "SPEC_S1.md"

caso 3 "argumento desconhecido sai 3" rodar --xyz
caso 3 "teto não numérico sai 3" rodar --claude muito
foto() { find "$p" "$h/.claude" -path "$p/.git" -prune -o -type f -print | sort | xargs sha256sum | sha256sum; }
antes=$(foto)
rodar >/dev/null 2>&1
caso 0 "o script não escreve nada" test "$antes" = "$(foto)"
