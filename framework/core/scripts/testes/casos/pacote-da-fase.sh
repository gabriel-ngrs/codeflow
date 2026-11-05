# casos do pacote-da-fase.sh — lido por ../run-testes.sh (usa caso, tem, nao_tem, $SCRIPTS, $T)

d="$T/pacote-da-fase"
mkdir -p "$d"
pf="$SCRIPTS/pacote-da-fase.sh"

# spec_com_bloco <arquivo> <abertura> <bloco interno ou vazio> <fechamento ou vazio>
# A fase 1 tem um bloco de código com uma linha "# ..." no meio e o escopo travado depois dele.
spec_com_bloco() {
  local arq=$1 abre=$2 dentro=$3 fecha=$4
  {
    printf -- '---\nslug: sintetica\nstatus: active\nwave: single\n---\n\n# Spec sintética\n\n'
    printf '## Resumo executivo\n\nresumo.\n\n## 3. Critérios de aceite\n\n- **AC-1** — dado x, então y.\n\n'
    printf '## 5. Plano de desenvolvimento por fases\n\n### Fase 1 — com bloco\n- **id:** `1`\n- **Passos:**\n\n'
    printf '%s\n# comentario-dentro-do-bloco\n' "$abre"
    if [ -n "$dentro" ]; then printf '%s\n# outro-comentario\n%s\n' "$dentro" "${dentro:0:3}"; fi
    printf 'echo fim\n'
    if [ -n "$fecha" ]; then printf '%s\n' "$fecha"; fi
    printf '\n- **Escopo travado:** só AC-1.\n\n### Fase 2 — depois\n- **id:** `2`\n\n## 9. Riscos\n\n- Fase 1: nenhum.\n'
  } > "$arq"
}

spec_com_bloco "$d/simples.md" '```bash' '' '```'
caso 0 "cerca simples: sai 0" bash "$pf" "$d/simples.md" 1
tem "# comentario-dentro-do-bloco"
tem "- **Escopo travado:** só AC-1."
tem "- **AC-1** — dado x, então y."
nao_tem "### Fase 2 — depois"

spec_com_bloco "$d/aninhada-crases.md" '````markdown' '```bash' '````'
caso 0 "cerca de 4 crases com bloco de 3 dentro: sai 0" bash "$pf" "$d/aninhada-crases.md" 1
tem "# outro-comentario"
tem "- **Escopo travado:** só AC-1."

spec_com_bloco "$d/aninhada-tis.md" '~~~~' '~~~' '~~~~'
caso 0 "cerca de 4 tis com bloco de 3 dentro: sai 0" bash "$pf" "$d/aninhada-tis.md" 1
tem "# outro-comentario"
tem "- **Escopo travado:** só AC-1."

spec_com_bloco "$d/sem-fecho.md" '```bash' '' ''
caso 1 "cerca sem fecho: sai 1" bash "$pf" "$d/sem-fecho.md" 1
tem "sem fechamento"

caso 1 "fase inexistente: sai 1" bash "$pf" "$d/simples.md" 9
caso 2 "spec inacessível: sai 2" bash "$pf" "$d/nao-existe.md" 1
caso 3 "sem o id da fase: sai 3" bash "$pf" "$d/simples.md"

# laço nas specs reais da máquina, quando houver: cada fase sai 0 com o próprio heading
n=0
r=0
for s in "$HOME"/Projetos/*/.codeflow/specs/*/SPEC_*.md; do
  [ -f "$s" ] || continue
  case "$s" in */_TEMPLATES/*) continue ;; esac
  while IFS= read -r id; do
    n=$((n + 1))
    if ! bash "$pf" "$s" "$id" > "$d/real.out" 2>/dev/null || ! grep -q "^### Fase $id" "$d/real.out"; then
      printf '      | %s, fase %s\n' "$(basename "$s")" "$id"
      r=1
    fi
  done < <(awk '/^(```|~~~)/{c=!c} !c && /^### Fase /{print $3}' "$s")
done
if [ "$n" -gt 0 ]; then
  caso 0 "specs reais: as $n fases saem com o próprio bloco" test "$r" = 0
fi
