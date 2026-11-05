# casos do check-commits.sh — lido por ../run-testes.sh (usa caso, tem, $SCRIPTS, $T)

c="$T/check-commits"
mkdir -p "$c"
cc="$SCRIPTS/check-commits.sh"
g() { git -C "$c" -c user.name=teste -c user.email=teste@exemplo.invalid "$@"; }
commit() { printf '%s\n' "$RANDOM" >> "$c/arq"; g add arq; g commit -q -m "$1" ${2:+-m "$2"}; }
rodar() { (cd "$c" && bash "$cc" "$@"); }
porcelana() { [ -z "$(git -C "$c" status --porcelain)" ]; }

g init -q -b main
commit 'chore: base'
g checkout -q -b evolucao/x

commit 'feat(x): passo limpo'
caso 0 "intervalo limpo sai 0" rodar main
tem "✓ 1 commit(s)"
caso 0 "o script não escreve" porcelana

commit "feat(x): $(printf 'a%.0s' $(seq 1 80))"
caso 1 "assunto de 80+ caracteres sai 1" rodar main
tem "teto 72"
g reset -q --hard HEAD~1

commit 'atualiza coisas'
caso 1 "assunto fora de Conventional Commits sai 1" rodar main
tem "fora de Conventional Commits"
g reset -q --hard HEAD~1

commit 'docs(x): acerta os sha do relatório'
caso 1 "commit que acerta os sha sai 1" rodar main
tem "acertar sha"
g reset -q --hard HEAD~1

commit 'docs(x): ação com acento conta caractere, não byte, até o teto de 72'
caso 0 "assunto acentuado de até 72 caracteres sai 0" rodar main

g checkout -q -b bug/y main
commit 'fix(y): corrige a borda'
caso 1 "ramo bug/* sem Tamanho: sai 1" rodar main
tem "Tamanho: P|M|G"
commit 'test(y): cobre a borda' 'Tamanho: P'
caso 0 "ramo bug/* com Tamanho: P sai 0" rodar main
caso 1 "--ramo melhoria/z sem trailer no intervalo de evolucao/x sai 1" bash -c "cd '$c' && git checkout -q evolucao/x && bash '$cc' main --ramo melhoria/z"

caso 3 "sem argumento sai 3" rodar
caso 3 "base que não resolve sai 3" rodar nao-existe
caso 3 "opção desconhecida sai 3" rodar main --xyz
caso 2 "fora de um repositório git sai 2" bash -c "cd '$T' && mkdir -p sem-git && cd sem-git && GIT_CEILING_DIRECTORIES='$T' bash '$cc' main"
caso 0 "o script não escreve, depois de todos os casos" porcelana
