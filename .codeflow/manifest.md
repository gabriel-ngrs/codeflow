---
versão: 1.2
status: estável
atualizado: 2026-10-06
projeto: codeflow
last_validated: 2026-10-06
validation_hash: 13b3e50d2ca105785eaf63bb06066fe14f27a8741d700460698f702ce2aefc89
---

# Manifest do projeto: codeflow

## Stack identificada

- **Shell:** GNU bash 5.2.21 (mínimo declarado: 4.0, `framework/core/ARTIFACTS_SPEC.md` §0.9)
- **Controle de versão:** git 2.43.0
- **Utilitários:** GNU coreutils 9.4 (`sha256sum`, `grep`, `sed`, `awk`)
- **Varredura de segredo:** gitleaks 8.21.2 — binário da máquina, só no gate `security`
- **Pull request e merge:** gh 2.45.0
- **Contrato normativo:** `framework/core/SPEC.md` 3.4, `framework/core/ARTIFACTS_SPEC.md` 2.4
- **Lint de shell:** shellcheck não instalado

## Comandos de validação

| Gate        | Comando real do projeto                                              | Status |
|-------------|----------------------------------------------------------------------|--------|
| `check`     | `lint`, `test` e `security`, nesta ordem, parando na primeira falha  | ✓      |
| `lint`      | bloco `lint` abaixo                                                  | ✓      |
| `typecheck` | [—] sem linguagem tipada no repositório                              | [—]    |
| `test`      | bloco `test` abaixo                                                  | ✓      |
| `security`  | bloco `security` abaixo                                              | ✓      |

Todos rodam na raiz da worktree, sobre o ramo commitado.

```bash
# lint — sintaxe dos scripts, LF nos arquivos rastreados, stack de script, palavra-fraca nos .md que o ramo mudou
bash -n install.sh setup-*.sh framework/core/scripts/*.sh \
&& ! git ls-files -z | xargs -0 grep -lIU $'\r' \
&& ! grep -nwE 'jq|yq|python3?|node|go|rust|docker|podman|pbcopy|xclip' install.sh setup-*.sh framework/core/scripts/*.sh \
&& ! { git diff --name-only --diff-filter=d origin/main...HEAD -- 'framework/*.md' '.codeflow/*.md' \
         ':!framework/core/SPEC.md' ':!framework/core/ARTIFACTS_SPEC.md' ':!.codeflow/manifest.md' \
         ':!.codeflow/changes/' ':!.codeflow/audits/'; echo /dev/null; } \
     | xargs grep -niE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente'
```

```bash
# test — regressão do validador (origin/main x ramo, sobre as specs reais) e setup isolado em HOME temporário
(
  T=$(mktemp -d) && trap 'rm -rf "$T"' EXIT
  git show origin/main:framework/core/scripts/run-structural.sh > "$T/base.sh" || exit 2
  r=0
  for s in ~/Projetos/*/.codeflow/specs/*/SPEC_*.md; do
    case "$s" in */_TEMPLATES/*) continue ;; esac
    bash "$T/base.sh" "$s" >/dev/null 2>&1; a=$?
    bash framework/core/scripts/run-structural.sh "$s" >/dev/null 2>&1; b=$?
    [ "$a" = "$b" ] || { echo "✗ $(basename "$s"): origin/main=$a ramo=$b"; r=1; }
  done
  ln -s "$PWD" "$T/.codeflow" \
  && env -u CLAUDE_CONFIG_DIR -u AGENTS_HOME HOME="$T" bash setup-slash-commands.sh \
  && env -u CLAUDE_CONFIG_DIR -u AGENTS_HOME HOME="$T" bash setup-codex-skills.sh \
  && [ "$r" = 0 ]
)
```

```bash
# security — segredo nos commits do ramo; nome de cliente ou de pessoa nas linhas que o ramo acrescenta
# (imprime só o nome do arquivo, nunca o valor; a lista mora fora do repositório, chmod 600)
gitleaks git . --log-opts="origin/main..HEAD" --no-banner --redact --exit-code 1 \
&& test -s ~/.config/codeflow/nomes-proibidos.txt \
&& git diff -U0 --diff-filter=d origin/main...HEAD \
   | awk '/^\+\+\+ b\//{f=substr($0,7); next} /^\+/{print f "\t" substr($0,2)}' \
   | grep -iwFf ~/.config/codeflow/nomes-proibidos.txt | cut -f1 | sort -u | { ! grep .; }
```

## Padrões detectados

- **Estrutura:** `framework/core/` (contrato e core), `framework/library/` (16 workflows, 16 skills, moldes em `templates/specs/`, `templates/changes/`, `templates/audits/`), `framework/meta/` (5 meta-skills); scripts de instalação e setup na raiz.
- **Frontmatter:** os `.md` do framework abrem com `versão`, `status` e `atualizado`; itens criados em 2026-10-02 nascem `experimental`.
- **Referência ao framework:** por `~/.codeflow/...`, nunca por caminho absoluto.
- **Scripts:** saídas 0–3 e símbolos `✓`/`✗`/`⚠`; os de setup fixam `CODEFLOW="${HOME}/.codeflow"`, por isso o teste isolado troca o `HOME`.
- **Commits:** Conventional Commits em pt-BR em 75 de 77 commits; escopos mais usados `framework` e `andaime`; trailer `Co-Authored-By` em 49 de 77.
- **Fluxo até 2026-10-02:** só `main`, sem pull request, sem CI, sem hooks, sem proteção de ramo; uma tag, `v1.0.0`.

## Arquivos críticos para freshness

Hash `validation_hash` é computado sobre os arquivos abaixo, na ordem:

- `install.sh`
- `setup-slash-commands.sh`
- `setup-codex-skills.sh`
- `setup-codex-prompts.sh`
- `framework/core/scripts/run-structural.sh`
- `.gitignore`

## Notas de inspeção

- Inspeção de 2026-10-02, no formato de `discover`, preenchida à mão a partir do levantamento somente leitura da mesma data; `/discover` não rodou e não houve entrevista, por isso não há `discovered.md`.
- O repositório não tem `Makefile` nem manifesto de pacote; os arquivos críticos são os scripts, que definem a stack, e o `.gitignore`.
- Gates rodados em 2026-10-02 na worktree da trilha de evolução, sobre `origin/main`: `lint` ✓; `test` ✓ (52 specs reais sem divergência, setup isolado gerou 21 wrappers e 21 skills); `security` ✓.
- Linha de base: 7 das 52 specs reais reprovam no `run-structural.sh` de `origin/main` (formato anterior à §5 com fases). Por isso o gate `test` compara o código de saída de `origin/main` e do ramo, e não exige saída `0`.
- O gate `test` lê as specs de todos os projetos em `~/Projetos/` e só funciona na máquina do dono; a divergência sai só com o nome do arquivo da spec, sem o caminho do projeto.
- A varredura de nomes do gate `security` usa `~/.config/codeflow/nomes-proibidos.txt` (fora do repositório, `chmod 600`) e confere só as linhas que o ramo acrescenta: arquivos que o ramo toca já trazem nomes anteriores à regra (`framework/core/SPEC.md`, `README.md`, `LICENSE`, `setup-codex-skills.sh`, `setup-codex-prompts.sh`, `framework/core/ARTIFACTS_SPEC.md`), e varrer o arquivo inteiro reprovaria todo pull request por essa dívida.
