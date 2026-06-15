#!/usr/bin/env bash
#
# run-structural.sh — valida a estrutura da §5 (plano de fases) de um SPEC_<NAME>.md.
#
# Aplica as regras estruturais de `ARTIFACTS_SPEC.md` §2.8.6 que os consumidores do
# pipeline (execute-spec-phase, evaluate-spec-phase, spec-status) pressupõem ao
# classificar fases: ids de fase únicos, heading `### Fase <id>` igual ao bullet
# `id`, todo `id` citado em "Depende de" existe na §5, grafo de dependências
# acíclico, 3–8 fases por track, `wave: multi` exige ao menos um id `<TRACK>.<n>`
# (e `single`/`null` exige ids inteiros) e slug em kebab-case.
#
# Read-only: lê apenas o arquivo indicado; não modifica a working tree nem o repo.
# Assume o formato canônico emitido por `/create-spec` (bullets com o valor entre
# crases, ex.: `- **id:** ` + `A.1` entre crases).
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.6/§0.7/§2.8.6.
# Códigos de saída: 0 sucesso, 1 falha de regra (§5 malformada), 2 erro de execução, 3 input inválido.

set -euo pipefail

SUCESSO="✓"
FALHA="✗"

usage() {
  cat <<'EOF'
Uso: bash ~/.codeflow/framework/core/scripts/run-structural.sh <caminho-do-SPEC.md>

Valida a estrutura da §5 (plano de fases) da spec indicada.
Saídas: 0 ok, 1 §5 malformada, 2 erro de execução, 3 input inválido.
EOF
}

if [ "$#" -ne 1 ]; then
  printf '%s argumento inválido: informe exatamente o caminho da spec.\n' "$FALHA" >&2
  usage >&2
  exit 3
fi

spec="$1"

if [ ! -f "$spec" ]; then
  printf '%s arquivo não encontrado ou inacessível: %s\n' "$FALHA" "$spec" >&2
  exit 2
fi

rc=0
awk -v OK="$SUCESSO" -v NOK="$FALHA" '
  BEGIN { fm=0; in_s5=0; np=0; wave=""; cur=0 }

  # frontmatter: capturar wave
  NR==1 && $0=="---" { fm=1; next }
  fm==1 && $0=="---" { fm=0; next }
  fm==1 {
    if ($0 ~ /^wave:[ \t]*/) { w=$0; sub(/^wave:[ \t]*/,"",w); gsub(/[ \t]+$/,"",w); wave=tolower(w) }
    next
  }

  # limites da §5
  $0 ~ /^## 5\./ { in_s5=1; next }
  in_s5==1 && $0 ~ /^## / { in_s5=0 }

  # cabeçalho de fase (ignora `### Track ...`, que não é fase)
  in_s5==1 && $0 ~ /^### Fase[ \t]+/ {
    np++; cur=np
    h=$0; sub(/^### Fase[ \t]+/,"",h); split(h, p, /[ \t]+/); hid[cur]=p[1]
    bid[cur]=""; slg[cur]=""; dep[cur]=""
    next
  }

  in_s5==1 && cur>0 && $0 ~ /^- \*\*id:\*\*/ && bid[cur]=="" {
    if (match($0, /`[^`]+`/)) bid[cur]=substr($0,RSTART+1,RLENGTH-2)
    next
  }
  in_s5==1 && cur>0 && $0 ~ /^- \*\*slug:\*\*/ && slg[cur]=="" {
    if (match($0, /`[^`]+`/)) slg[cur]=substr($0,RSTART+1,RLENGTH-2)
    next
  }
  in_s5==1 && cur>0 && $0 ~ /^- \*\*Depende de:\*\*/ && dep[cur]=="" {
    rest=$0; d=""
    while (match(rest, /`[^`]+`/)) {
      tok=substr(rest,RSTART+1,RLENGTH-2)
      d=(d==""?tok:d" "tok)
      rest=substr(rest,RSTART+RLENGTH)
    }
    dep[cur]=d   # vazio = "nenhuma"
    next
  }

  END {
    fail=0

    if (np==0) { printf "%s §5 sem fases (`### Fase <id> — …` não encontrado)\n", NOK; exit 1 }

    # ids presentes + unicidade
    for (i=1;i<=np;i++) {
      id=bid[i]
      if (id=="") { printf "%s fase %d sem bullet `id`\n", NOK, i; fail=1; continue }
      cnt[id]++
    }
    dupmsg=""
    for (id in cnt) if (cnt[id]>1) dupmsg=(dupmsg==""?id:dupmsg", "id)
    if (dupmsg!="") { printf "%s ids de fase duplicados: %s\n", NOK, dupmsg; fail=1 }
    else printf "%s ids de fase únicos (%d fases)\n", OK, np

    # heading == bullet id
    hb=1
    for (i=1;i<=np;i++) {
      if (bid[i]=="") continue
      if (hid[i]!=bid[i]) { printf "%s heading `### Fase %s` != bullet id `%s`\n", NOK, hid[i], bid[i]; hb=0; fail=1 }
    }
    if (hb) printf "%s heading de cada fase casa com o bullet `id`\n", OK

    # slug kebab-case
    sk=1
    for (i=1;i<=np;i++) {
      s=slg[i]
      if (s=="") { printf "%s fase `%s` sem bullet `slug`\n", NOK, bid[i]; sk=0; fail=1; continue }
      if (s !~ /^[a-z0-9]+(-[a-z0-9]+)*$/) { printf "%s slug não-kebab-case na fase `%s`: `%s`\n", NOK, bid[i], s; sk=0; fail=1 }
    }
    if (sk) printf "%s todos os slugs são kebab-case\n", OK

    # wave x formato de id
    multi_ok=0; intids=1
    for (i=1;i<=np;i++) {
      if (bid[i] ~ /^[A-Za-z]+\.[0-9]+$/) multi_ok=1
      if (bid[i] !~ /^[0-9]+$/) intids=0
    }
    if (wave=="multi") {
      if (multi_ok) printf "%s wave: multi com ao menos um id `<TRACK>.<n>`\n", OK
      else { printf "%s wave: multi mas nenhum id no formato `<TRACK>.<n>`\n", NOK; fail=1 }
    } else {
      wlbl=(wave==""?"null":wave)
      if (intids) printf "%s wave: %s com ids inteiros\n", OK, wlbl
      else { printf "%s wave: %s exige ids inteiros, mas há id `<TRACK>.<n>`\n", NOK, wlbl; fail=1 }
    }

    # "Depende de" referencia ids existentes
    de=1
    for (i=1;i<=np;i++) {
      n=split(dep[i], ds, / /)
      for (j=1;j<=n;j++) {
        if (ds[j]=="") continue
        if (!(ds[j] in cnt)) { printf "%s fase `%s` depende de `%s`, que não existe na §5\n", NOK, bid[i], ds[j]; de=0; fail=1 }
      }
    }
    if (de) printf "%s todo `id` em \"Depende de\" existe na §5\n", OK

    # 3–8 fases por track
    for (i=1;i<=np;i++) {
      if (bid[i] ~ /^[A-Za-z]+\.[0-9]+$/) { tk=bid[i]; sub(/\..*$/,"",tk) } else tk="_single"
      tcnt[tk]++
    }
    te=1
    for (tk in tcnt) {
      lbl=(tk=="_single"?"single-track":"track "tk)
      if (tcnt[tk]<3 || tcnt[tk]>8) { printf "%s %s tem %d fases (exigido 3–8)\n", NOK, lbl, tcnt[tk]; te=0; fail=1 }
    }
    if (te) printf "%s cada track tem 3–8 fases\n", OK

    # grafo de dependências acíclico (Kahn)
    for (i=1;i<=np;i++) { vrt[bid[i]]=1; indeg[bid[i]]+=0 }
    for (i=1;i<=np;i++) {
      n=split(dep[i], ds, / /)
      for (j=1;j<=n;j++) {
        if (ds[j]=="") continue
        if (ds[j] in vrt) {            # aresta ds[j] -> bid[i]
          adj[ds[j]]=(adj[ds[j]]==""?bid[i]:adj[ds[j]]" "bid[i])
          indeg[bid[i]]++
        }
      }
    }
    total=0; for (k in vrt) total++
    removed=0; changed=1
    while (changed) {
      changed=0
      for (k in vrt) {
        if (gone[k]) continue
        if (indeg[k]==0) {
          gone[k]=1; removed++; changed=1
          m=split(adj[k], outs, / /)
          for (j=1;j<=m;j++) if (outs[j]!="") indeg[outs[j]]--
        }
      }
    }
    if (removed<total) { printf "%s grafo de dependências tem ciclo (%d de %d fases envolvidas)\n", NOK, total-removed, total; fail=1 }
    else printf "%s grafo de dependências acíclico\n", OK

    if (fail) exit 1
    printf "%s §5 estruturalmente válida\n", OK
    exit 0
  }
' "$spec" || rc=$?

exit "$rc"
