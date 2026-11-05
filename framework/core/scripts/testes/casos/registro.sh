# casos do intervalo pela `base` (ARTIFACTS_SPEC §2.9.3 e §2.10.1) — lido por ../run-testes.sh

r="$T/registro"
mkdir -p "$r"
g() { git -C "$r" -c user.name=teste -c user.email=teste@exemplo.invalid "$@"; }
g init -q -b main
printf 'a\n' > "$r/a"; g add a; g commit -q -m 'chore: base'
g checkout -q -b melhoria/x
printf 'b\n' > "$r/b"; g add b; g commit -q -m 'feat(x): etapa 1'
g checkout -q main
printf 'c\n' > "$r/c"; g add c; g commit -q -m 'chore: main andou'
g checkout -q melhoria/x
g merge -q --no-edit main
printf 'd\n' > "$r/d"; g add d; g commit -q -m 'docs(x): etapa 2 e relatório'

intervalo() { local mb; mb=$(git -C "$r" merge-base "$1" HEAD) && git -C "$r" log --oneline "$mb..HEAD"; }
caso 0 "base main: o log do intervalo sai" intervalo main
tem "feat(x): etapa 1"
tem "docs(x): etapa 2 e relatório"
nao_tem "chore: main andou"
nao_tem "chore: base"
tem "Merge branch"
conta "" 3

diff_stat() { local mb; mb=$(git -C "$r" merge-base main HEAD) && git -C "$r" diff --stat "$mb..HEAD"; }
caso 0 "o diff --stat do intervalo só traz os arquivos da tarefa" diff_stat
tem "b |"
tem "d |"
nao_tem "c |"
