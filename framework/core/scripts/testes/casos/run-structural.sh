# casos do run-structural.sh — lido por ../run-testes.sh (usa caso, tem, conta, $SCRIPTS, $T)

d="$T/run-structural"
mkdir -p "$d"

# spec_sintetica <arquivo> <estilo do critério: prosa|comando|sem> <depende da fase 1>
spec_sintetica() {
  local arq=$1 estilo=$2 dep1=$3 i dep
  {
    printf -- '---\nslug: sintetica\nstatus: active\nwave: single\n---\n\n# Spec sintética\n\n'
    printf '## 5. Plano de desenvolvimento por fases\n\n'
    for i in 1 2 3; do
      case "$i" in 1) dep=$dep1 ;; 2) dep='`1`' ;; 3) dep='`2`' ;; esac
      printf '### Fase %s — passo %s\n- **id:** `%s`\n- **slug:** `passo-%s`\n- **Depende de:** %s\n' "$i" "$i" "$i" "$i" "$dep"
      case "$estilo" in
        prosa) printf -- '- **Critério de conclusão (gate):** testes verdes.\n' ;;
        comando) printf -- '- **Critério de conclusão (gate):** `bash testes/fase-%s.sh` passa; e o log fica limpo.\n' "$i" ;;
        sem) ;;
      esac
      printf '\n'
    done
    printf '## 6. Riscos\n\n- nenhum\n'
  } > "$arq"
}

spec_sintetica "$d/antiga.md" prosa nenhuma
caso 0 "spec antiga (critério em prosa) segue saindo 0" bash "$SCRIPTS/run-structural.sh" "$d/antiga.md"
conta "⚠ fase " 3
tem "⚠ fase 1: critério de conclusão sem comando entre crases"
tem "✓ §5 estruturalmente válida"

spec_sintetica "$d/nova.md" comando nenhuma
caso 0 "spec nova (critério com comando) sai 0" bash "$SCRIPTS/run-structural.sh" "$d/nova.md"
conta "⚠" 0

spec_sintetica "$d/sem-bullet.md" sem nenhuma
caso 0 "fase sem o bullet do critério sai 0" bash "$SCRIPTS/run-structural.sh" "$d/sem-bullet.md"
conta "⚠ fase " 3

spec_sintetica "$d/ciclo.md" comando '`3`'
caso 1 "spec malformada (ciclo) segue saindo 1" bash "$SCRIPTS/run-structural.sh" "$d/ciclo.md"
tem "✗ grafo de dependências tem ciclo"

spec_sintetica "$d/ciclo-prosa.md" prosa '`3`'
caso 1 "malformada e com critério em prosa: sai 1 e avisa" bash "$SCRIPTS/run-structural.sh" "$d/ciclo-prosa.md"
conta "⚠ fase " 3

# o código de saída não muda contra a versão de origin/main, quando o git a tem
if git -C "$SCRIPTS" show origin/main:framework/core/scripts/run-structural.sh > "$d/base.sh" 2>/dev/null; then
  for s in antiga nova sem-bullet ciclo ciclo-prosa; do
    bash "$d/base.sh" "$d/$s.md" >/dev/null 2>&1
    caso $? "mesmo código de saída de origin/main: $s" bash "$SCRIPTS/run-structural.sh" "$d/$s.md"
  done
fi

caso 3 "sem argumento sai 3" bash "$SCRIPTS/run-structural.sh"
