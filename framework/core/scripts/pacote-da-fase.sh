#!/usr/bin/env bash
#
# pacote-da-fase.sh — imprime o recorte de uma spec que a execução e a avaliação de
# UMA fase precisam, em vez da spec inteira.
#
# Imprime em stdout, nesta ordem: o frontmatter; `## Resumo executivo`; a subseção
# `### 1.x Princípios invioláveis`; o bloco `### Fase <id>` (até o próximo `##`/`###`);
# o item de cada AC/CA/FR/NFR/R citado no bloco (do id até a linha em branco ou o
# próximo item); as linhas da §9 que citam a fase; e um rodapé com as linhas de cada
# seção `##` omitida, para abrir por `sed -n '<a>,<b>p'`. Id citado que não é achado,
# ou seção esperada que falta, aparece no rodapé com ⚠, sem derrubar a saída.
#
# Read-only: lê só o arquivo indicado; não escreve em disco. Quem quiser o pacote
# em arquivo redireciona a saída (ex.: para `.codeflow/checkpoints/`).
#
# Conforme `SPEC.md` §7.2/§7.3 e `ARTIFACTS_SPEC.md` §0.7/§0.9.
# Linhas dentro de bloco de código (``` ou ~~~) nunca contam como heading nem como item;
# bloco aberto sem fechamento torna o recorte não confiável e sai 1, sem stdout.
#
# Códigos de saída: 0 sucesso, 1 fase inexistente ou recorte não confiável, 2 arquivo
# inacessível, 3 uso inválido.

set -euo pipefail

usage() {
  cat <<'EOF'
Uso: bash ~/.codeflow/framework/core/scripts/pacote-da-fase.sh <caminho-do-SPEC.md> <id-da-fase>

Imprime o pacote da fase <id> (ex.: 3, B.2) da spec indicada.
Saídas: 0 ok, 1 fase inexistente ou recorte não confiável, 2 arquivo inacessível,
3 uso inválido.
EOF
}

if [ "$#" -ne 2 ] || [ -z "$2" ]; then
  printf '✗ argumento inválido: informe o caminho da spec e o id da fase.\n' >&2
  usage >&2
  exit 3
fi

spec="$1"
fase="$2"

if [ ! -f "$spec" ] || [ ! -r "$spec" ]; then
  printf '✗ spec inacessível: %s\n' "$spec" >&2
  exit 2
fi

awk -v FASE="$fase" -v SPEC="$spec" '
function inicio_id(s, id,   c) {
  # s começa com id, e o caractere seguinte não continua o id
  if (substr(s, 1, length(id)) != id) return 0
  c = substr(s, length(id) + 1, 1)
  if (c ~ /[A-Za-z0-9_]/) return 0
  if (c == "." && substr(s, length(id) + 2, 1) ~ /[0-9]/) return 0
  return 1
}
function cita_fase(s,   i, rest, antes) {
  # a linha cita a fase como "Fase <id>", "**<id>**" ou "`<id>`"
  rest = s
  while ((i = index(rest, FASE)) > 0) {
    antes = substr(rest, 1, i - 1)
    if ((antes ~ /Fase $/ || antes ~ /\*\*$/ || antes ~ /`$/) && inicio_id(substr(rest, i), FASE)) return 1
    rest = substr(rest, i + length(FASE))
  }
  return 0
}
function imprime(a, b,   i) { for (i = a; i <= b; i++) print L[i] }
function fim_secao(a, nivel,   i) {
  # última linha da seção que começa em a: até o próximo heading de nível <= nivel
  for (i = a + 1; i <= N; i++) { h = nivel_h(i); if (h && h <= nivel) return i - 1 }
  return N
}
function nivel_h(i) {
  # nível do heading markdown da linha i (1 a 6), ou 0 se ela não é heading ou está em bloco de código
  if (C[i] || !match(L[i], /^#+ /)) return 0
  return RLENGTH - 1
}
function indent(s) { match(s, /^[ \t]*/); return RLENGTH }
{
  # C[NR] = 1 na cerca (``` ou ~~~) e dentro dela: ali "# ..." é código, não heading
  L[NR] = $0
  if (cerca == "" && match($0, /^[ \t]*(```|~~~)/)) { cerca = substr($0, RSTART + RLENGTH - 3, 3); ini_cerca = NR; C[NR] = 1 }
  else if (cerca != "") { C[NR] = 1; if ($0 ~ ("^[ \t]*" cerca)) cerca = "" }
}
END {
  if (cerca != "") {
    printf "✗ bloco de código aberto na linha %d sem fechamento em %s: o recorte da fase não é confiável\n", ini_cerca, SPEC > "/dev/stderr"
    exit 1
  }
  N = NR
  # 1. bloco da fase, antes de imprimir qualquer coisa (fase inexistente sai 1 sem stdout)
  fm_fim = 0
  if (L[1] == "---") for (i = 2; i <= N; i++) if (L[i] == "---") { fm_fim = i; break }
  fa = 0
  for (i = fm_fim + 1; i <= N; i++)
    if (!C[i] && substr(L[i], 1, 9) == "### Fase " && inicio_id(substr(L[i], 10), FASE)) { fa = i; break }
  if (!fa) { printf "✗ fase %s não encontrada em %s\n", FASE, SPEC > "/dev/stderr"; exit 1 }
  for (fb = fa + 1; fb <= N; fb++) { h = nivel_h(fb); if (h && h <= 3) break }
  fb--

  # 2. frontmatter
  if (fm_fim) { imprime(1, fm_fim); print "" }
  else aviso[++na] = "⚠ frontmatter ausente"

  # 3. resumo executivo e princípios (í em alternância: awk que conta bytes não casa [ií])
  ra = 0; pa = 0
  for (i = fm_fim + 1; i <= N; i++) {
    if (!ra && !C[i] && L[i] ~ /^## Resumo executivo/) ra = i
    if (!pa && !C[i] && L[i] ~ /^### .*Princ(i|í)pios inviol/) pa = i
  }
  if (ra) { rb = fim_secao(ra, 2); imprime(ra, rb); print "" } else aviso[++na] = "⚠ seção ## Resumo executivo ausente"
  if (pa) { pb = fim_secao(pa, 3); imprime(pa, pb); print "" } else aviso[++na] = "⚠ subseção ### Princípios invioláveis ausente"

  imprime(fa, fb); print ""

  # 4. ids citados no bloco (AC-B1/B2 vale como AC-B1 e AC-B2)
  nid = 0
  for (i = fa; i <= fb; i++) {
    s = L[i]
    while (match(s, /(^|[^A-Za-z0-9_])(AC|CA|FR|NFR|R)-[A-Za-z0-9]+(\.[0-9]+)*/)) {
      tok = substr(s, RSTART, RLENGTH); sub(/^[^A-Z]/, "", tok)
      pref = substr(tok, 1, index(tok, "-"))
      s = substr(s, RSTART + RLENGTH)
      if (!(tok in visto)) { visto[tok] = 1; ids[++nid] = tok }
      while (match(s, /^\/[A-Za-z0-9]+/)) {
        tok = pref substr(s, 2, RLENGTH - 1); s = substr(s, RLENGTH + 1)
        if (!(tok in visto)) { visto[tok] = 1; ids[++nid] = tok }
      }
    }
  }
  if (nid) print "## Itens citados na fase (texto da spec)\n"
  for (k = 1; k <= nid; k++) {
    id = ids[k]; achou = 0
    for (i = fm_fim + 1; i <= N && !achou; i++) {
      if ((i >= fa && i <= fb) || C[i]) continue
      s = L[i]; tipo = ""
      if (s ~ /^[ \t]*[-*] \*\*/) { t = s; sub(/^[ \t]*[-*] \*\*/, "", t); if (inicio_id(t, id)) tipo = "item" }
      else if (s ~ /^\|/) { t = s; sub(/^\|[ \t]*\**/, "", t); if (inicio_id(t, id)) tipo = "linha" }
      else if (nivel_h(i) >= 3) { t = s; sub(/^#+ +/, "", t); if (inicio_id(t, id)) tipo = "heading" }
      if (tipo == "") continue
      achou = 1; print s
      if (tipo == "item") {
        ind = indent(s)
        for (j = i + 1; j <= N; j++) {
          if ((!C[j] && L[j] ~ /^[ \t]*$/) || nivel_h(j) || (!C[j] && L[j] ~ /^\|/)) break
          if (!C[j] && L[j] ~ /^[ \t]*([-*]|[0-9]+\.) / && indent(L[j]) <= ind) break
          print L[j]
        }
      } else if (tipo == "heading") {
        for (j = i + 1; j <= N && !nivel_h(j); j++) print L[j]
      }
      print ""
    }
    if (!achou) aviso[++na] = "⚠ " id " citado na fase e não encontrado na spec"
  }

  # 5. linhas da §9 que citam a fase
  na9 = 0
  for (i = fm_fim + 1; i <= N; i++) if (!C[i] && L[i] ~ /^## 9[. ]/) { na9 = i; break }
  if (na9) {
    nb9 = fim_secao(na9, 2); cab = 0
    for (i = na9 + 1; i <= nb9; i++) if (cita_fase(L[i])) {
      if (!cab) { print "## Linhas da §9 que citam a fase\n"; cab = 1 }
      print L[i]
    }
    if (cab) print ""
  } else aviso[++na] = "⚠ seção ## 9 ausente"

  # 6. rodapé: seções ## omitidas, com as linhas
  printf "## Seções omitidas (abrir por `sed -n '\''<a>,<b>p'\'' %s`)\n\n", SPEC
  for (i = fm_fim + 1; i <= N; i++) if (nivel_h(i) == 2 && i != ra) {
    b = fim_secao(i, 2); nota = ""
    if (fa > i && fa <= b) nota = " (a fase " FASE " está nas linhas " fa "–" fb ")"
    if (pa > i && pa <= b) nota = nota " (princípios nas linhas " pa "–" pb ")"
    printf "- %s: %d–%d%s\n", L[i], i, b, nota
  }
  for (k = 1; k <= na; k++) print "- " aviso[k]
}' "$spec"
