---
versão: 1.2
status: estável
atualizado: 2026-05-23
---

# VALIDATION.md — Procedimentos de validação por etapa

Este documento é o quarto do andaime (`SPEC.md`, `ARTIFACTS_SPEC.md`, `BUILD_PLAN.md`, **`VALIDATION.md`**, `PROMPTS.md`). Sua função é detalhar **como executar** as validações referenciadas pelo `BUILD_PLAN.md` no campo `Validação` de cada etapa.

Onde o `ARTIFACTS_SPEC.md` declara **quais regras** cada tipo de arquivo deve satisfazer (§1.1.6, §1.2.6, etc.) e o `BUILD_PLAN.md` aponta **quando** cada validação se aplica, este documento entrega os **comandos concretos** que o Claude Code executa.

## Parte 0 — Convenções gerais

### 0.1 Identificação das seções

As seções seguem a numeração das etapas do `BUILD_PLAN.md`:

- `§V.<fase>.<etapa>` corresponde à validação da etapa `F<fase>.<etapa>` do BUILD_PLAN.

Exemplo: `§V.2.1` valida a etapa `F2.1` (constitution universal).

### 0.2 Estrutura de cada seção de validação

Cada `§V.X.Y` segue cinco blocos fixos:

1. **Arquivo(s) validado(s)** — caminho exato dos arquivos cobertos pela etapa.
2. **Regras aplicáveis** — referência cruzada às regras do `ARTIFACTS_SPEC.md`. Inclui regras específicas do tipo (§1.X.6, §2.X.6) e regras transversais relevantes (Parte 3, §3.X).
3. **Verificações automatizáveis** — snippets bash que verificam regras mecanicamente. Cada snippet declara: o que verifica, o comando, e o resultado esperado.
4. **Verificações por inspeção** — regras que exigem leitura humana ou inferência semântica (ex: "linguagem imperativa", "definição não-circular"). Listadas como checklist para o validador.
5. **Critério de aprovação** — condição agregada que precisa ser verdadeira para a etapa estar validada. Tipicamente: "todas as verificações automatizáveis retornam zero" + "todas as verificações por inspeção marcadas como [✓]".

### 0.3 Convenções dos snippets bash

- **Diretório de trabalho assumido:** `~/Projetos/codeflow/` (raiz do repositório do framework). Quando um snippet exige outro diretório, é declarado explicitamente no início.
- **Stack permitida:** bash + coreutils + git + openssl, conforme `SPEC.md` §7.3 e `ARTIFACTS_SPEC.md` §0.9. Nenhum snippet usa `jq`, `yq`, `python`, etc.
- **Códigos de saída:** snippets retornam `0` quando passam, `1` quando falham. Sem códigos intermediários — diagnóstico fica no `stderr` do próprio snippet.
- **Variáveis convencionais:**
  - `$FILE` — caminho do arquivo sendo validado (definido pelo snippet ou pelo invocador).
  - `$FRAMEWORK` — `~/Projetos/codeflow` (ou `~/.codeflow` quando equivalente).
- **Encoding:** snippets assumem `LANG=C.UTF-8` ou equivalente. Definir explicitamente no início da sessão de validação se necessário.

### 0.4 Helpers reutilizáveis

Os snippets nas seções subsequentes assumem disponibilidade de quatro helpers comuns. Não são funções bash declaradas (ver Decisão 3 do BUILD_PLAN); são **padrões de comando** que aparecem repetidamente:

**Verificar frontmatter universal** (`versão`, `status`, `atualizado`):
```bash
awk '
  /^---$/ { count++; if (count==2) exit }
  count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
  count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
  count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
  END { exit (v && s && a) ? 0 : 1 }
' "$FILE"
```

**Verificar ausência de palavras-fraca** (conforme `ARTIFACTS_SPEC.md` §3.5 regra 20):
```bash
! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE"
```

**Verificar encoding UTF-8 e ausência de CRLF** (conforme `ARTIFACTS_SPEC.md` §3.1 regras 1 e 2):
```bash
file "$FILE" | grep -q 'UTF-8' && ! grep -lU $'\r' "$FILE"
```

**Verificar trailing newline** (regra 3):
```bash
test "$(tail -c 1 "$FILE" | xxd -p)" = "0a"
```

Cada vez que um destes padrões aparece nas seções subsequentes, referência abreviada é usada (ex: `# helper: frontmatter universal`).

### 0.5 Política de falha em validação

- **Verificação automatizável falha:** a etapa **não passou**. Não declarar `[✓]` no log de execução. Investigar, corrigir o artefato, repetir a validação.
- **Verificação por inspeção marcada como `[—]` (pulada):** exige justificativa registrada. Validação aceita o status mas o pulo precisa de motivo objetivo.
- **Verificação por inspeção em dúvida:** equivale a falha. Em dúvida sobre se "linguagem é imperativa o suficiente", recusar — recriar o conteúdo até ter certeza.

### 0.6 Como invocar a validação

Cada seção é executável de forma independente. O Claude Code, ao terminar uma etapa do BUILD_PLAN, abre a seção correspondente do VALIDATION.md, copia os snippets, executa, e marca o resultado.

Não existe um único comando `validate.sh` consolidado — esta decisão foi registrada no preâmbulo deste documento. Se necessidade emergir, a construção de tal script é tema de evolução futura, conforme `framework/core/EVOLUTION.md`.

---

## Parte 1 — Validações por etapa

### §V.1.1 — Inicializar repositório do framework

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/.git/` (diretório)
- `~/Projetos/codeflow/.gitignore`

**Regras aplicáveis:**
- Nenhuma regra do ARTIFACTS_SPEC se aplica (etapa de infraestrutura git).
- `BUILD_PLAN.md` §F1.1 lista verificações mínimas próprias.

**Verificações automatizáveis:**

```bash
# 1. Repositório git inicializado, com commit inicial
cd ~/Projetos/codeflow
git rev-parse HEAD >/dev/null 2>&1 || { echo "FALHA: sem commit inicial"; exit 1; }

# 2. .gitignore presente e com entradas mínimas
test -f .gitignore || { echo "FALHA: .gitignore ausente"; exit 1; }
for pat in '.DS_Store' '*.swp' '*.bak' '*~'; do
  grep -qF "$pat" .gitignore || { echo "FALHA: padrão '$pat' ausente em .gitignore"; exit 1; }
done

# 3. Working tree limpo
test -z "$(git status --porcelain)" || { echo "FALHA: working tree sujo"; exit 1; }

echo "OK: §V.1.1"
```

**Verificações por inspeção:**
- [ ] `LICENSE` presente na raiz com o **texto MIT padrão** (linha "MIT License" no topo e parágrafo "Permission is hereby granted, free of charge..." presente). Sem pendência.
- [ ] `andaime/EXECUTION_LOG.md` presente, com frontmatter válido (`versão`, `status`, `atualizado`) e título `# Execução do BUILD_PLAN — log incremental`. Criado nesta etapa e atualizado ao longo do build até F5.7.
- [ ] `git config user.name` e `git config user.email` retornam valores não-vazios (configuração de identidade do mantenedor).

**Verificações automatizáveis adicionais:**

```bash
# LICENSE com texto MIT
test -f ~/Projetos/codeflow/LICENSE || { echo "FALHA: LICENSE ausente"; exit 1; }
grep -q 'MIT License' ~/Projetos/codeflow/LICENSE \
  || { echo "FALHA: LICENSE não contém 'MIT License'"; exit 1; }
grep -q 'Permission is hereby granted' ~/Projetos/codeflow/LICENSE \
  || { echo "FALHA: LICENSE não contém parágrafo MIT padrão"; exit 1; }

# EXECUTION_LOG presente
test -f ~/Projetos/codeflow/andaime/EXECUTION_LOG.md \
  || { echo "FALHA: EXECUTION_LOG.md ausente"; exit 1; }
grep -q '^# Execução do BUILD_PLAN — log incremental$' ~/Projetos/codeflow/andaime/EXECUTION_LOG.md \
  || { echo "FALHA: EXECUTION_LOG.md sem título canônico"; exit 1; }
```

**Critério de aprovação:** todos os snippets automatizáveis retornam zero; os três itens de inspeção marcados como `[✓]`.

---

### §V.1.2 — Criar estrutura de pastas vazia

**Arquivo(s) validado(s):**
- Árvore de diretórios em `~/Projetos/codeflow/framework/` e `~/Projetos/codeflow/andaime/`.

**Regras aplicáveis:**
- `SPEC.md` §2.2 (estrutura literal).
- `BUILD_PLAN.md` §F1.2.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow

# Pastas obrigatórias conforme SPEC.md §2.2
pastas=(
  framework/core/rules
  framework/meta/discover
  framework/meta/bootstrap
  framework/meta/create-workflow
  framework/meta/create-skill
  framework/meta/create-agent
  framework/library/skills/debug-protocol
  framework/library/skills/handoff
  framework/library/skills/self-review
  framework/library/workflows
  andaime
)

faltando=0
for p in "${pastas[@]}"; do
  if [ ! -d "$p" ]; then
    echo "FALHA: pasta ausente: $p"
    faltando=1
  fi
done
[ $faltando -eq 0 ] || exit 1

# Cada pasta vazia (sem conteúdo significativo) tem .gitkeep
for p in "${pastas[@]}"; do
  # Conta arquivos não-ocultos na pasta
  count=$(find "$p" -maxdepth 1 -type f ! -name '.gitkeep' | wc -l)
  if [ "$count" -eq 0 ] && [ ! -f "$p/.gitkeep" ]; then
    echo "FALHA: $p está vazia mas sem .gitkeep"
    exit 1
  fi
done

echo "OK: §V.1.2"
```

**Verificações por inspeção:**
- [ ] Nenhuma pasta fora da árvore declarada em `SPEC.md` §2.2 foi criada. Verificar com `find ~/Projetos/codeflow -type d` e comparar com a árvore literal do SPEC.

**Critério de aprovação:** o snippet automatizável retorna zero; o item de inspeção marcado como `[✓]`.

---

### §V.1.3 — Copiar documentos do andaime já produzidos

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/andaime/SPEC.md`
- `~/Projetos/codeflow/andaime/ARTIFACTS_SPEC.md`
- `~/Projetos/codeflow/andaime/BUILD_PLAN.md`
- `~/Projetos/codeflow/andaime/README.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §0.2 (frontmatter universal nos arquivos do andaime).
- `ARTIFACTS_SPEC.md` §3.1 (forma do arquivo).
- `BUILD_PLAN.md` §F1.3.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow/andaime

# 1. Quatro arquivos presentes
for f in SPEC.md ARTIFACTS_SPEC.md BUILD_PLAN.md README.md; do
  test -f "$f" || { echo "FALHA: $f ausente"; exit 1; }
done

# 2. Frontmatter universal válido em cada um
for f in SPEC.md ARTIFACTS_SPEC.md BUILD_PLAN.md README.md; do
  FILE="$f"
  awk '
    /^---$/ { count++; if (count==2) exit }
    count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
    count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
    count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
    END { exit (v && s && a) ? 0 : 1 }
  ' "$FILE" || { echo "FALHA: frontmatter inválido em $f"; exit 1; }
done

# 3. Encoding UTF-8 e ausência de CRLF
for f in SPEC.md ARTIFACTS_SPEC.md BUILD_PLAN.md README.md; do
  file "$f" | grep -q 'UTF-8' || { echo "FALHA: $f não é UTF-8"; exit 1; }
  ! grep -lU $'\r' "$f" >/dev/null || { echo "FALHA: $f contém CRLF"; exit 1; }
done

# 4. README.md cita os cinco documentos previstos
for doc in SPEC ARTIFACTS_SPEC BUILD_PLAN VALIDATION PROMPTS; do
  grep -qF "$doc" README.md || { echo "FALHA: README.md não cita $doc"; exit 1; }
done

echo "OK: §V.1.3"
```

**Verificações por inspeção:**
- [ ] `README.md` declara papel do andaime de forma clara e curta (10 a 15 linhas).
- [ ] `VALIDATION.md` e `PROMPTS.md` aparecem em `README.md` (marcados como pendentes nesta etapa; serão integrados em F5.3).

**Critério de aprovação:** todos os snippets retornam zero; itens de inspeção marcados.

---

### §V.1.4 — Criar symlink `~/.codeflow/` → `~/Projetos/codeflow/`

**Arquivo(s) validado(s):**
- `~/.codeflow` (link simbólico).

**Regras aplicáveis:**
- `BUILD_PLAN.md` §F1.4.
- `ARTIFACTS_SPEC.md` §3.4 (caminhos canônicos).

**Verificações automatizáveis:**

```bash
# 1. Symlink existe
test -L ~/.codeflow || { echo "FALHA: ~/.codeflow não é symlink"; exit 1; }

# 2. Resolve para um diretório que aparenta ser o repositório codeflow.
# Verificação por estrutura, não por path literal — o nome físico da pasta
# (~/Projetos/codeflow, ~/projetos/codeflow, ~/dev/codeflow, etc.) varia
# entre máquinas, e a abstração canônica do framework é ~/.codeflow/.
target=$(readlink ~/.codeflow)
resolved=$(cd ~/.codeflow 2>/dev/null && pwd -P)
test -n "$resolved" || { echo "FALHA: ~/.codeflow não resolve para diretório acessível (target: $target)"; exit 1; }
test -d "$resolved/andaime" && test -d "$resolved/framework" \
  || { echo "FALHA: $resolved não contém andaime/ e framework/ (target do symlink: $target)"; exit 1; }

# 3. Conteúdo acessível via symlink
test -f ~/.codeflow/andaime/SPEC.md || { echo "FALHA: andaime/SPEC.md inacessível via symlink"; exit 1; }
test -d ~/.codeflow/framework/core || { echo "FALHA: framework/core inacessível via symlink"; exit 1; }

# 4. Sem cópia paralela do framework fora do repositório de trabalho.
# Usa o path resolvido do symlink como referência canônica em vez de path literal,
# para suportar localizações distintas entre máquinas.
copias=$(find "$HOME" -maxdepth 6 -name 'constitution.md' -path '*/framework/core/*' 2>/dev/null \
         | grep -v "^${resolved}/" \
         | grep -v "$HOME/.codeflow" \
         | head -3)
if [ -n "$copias" ]; then
  echo "AVISO: cópias paralelas detectadas (verificar manualmente):"
  echo "$copias"
fi

echo "OK: §V.1.4"
```

**Verificações por inspeção:**
- [ ] `readlink ~/.codeflow` retorna o caminho esperado (visualmente conferido).

**Critério de aprovação:** snippets retornam zero; item de inspeção marcado. O aviso de cópias paralelas é informativo — não bloqueia, mas exige decisão registrada se detectado.

---

### §V.2.1 — Constitution universal

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/core/constitution.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §1.1.6 (10 regras específicas).
- `ARTIFACTS_SPEC.md` Parte 3 (regras transversais 1–35, com 36–39 para anti-padrões).
- `SPEC.md` §4.1.1, §8.3.

**Verificações automatizáveis:**

```bash
FILE=~/Projetos/codeflow/framework/core/constitution.md

# 1. Arquivo existe e é legível
test -f "$FILE" || { echo "FALHA: arquivo ausente"; exit 1; }

# 2. Frontmatter universal válido (helper)
awk '
  /^---$/ { count++; if (count==2) exit }
  count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
  count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
  count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
  END { exit (v && s && a) ? 0 : 1 }
' "$FILE" || { echo "FALHA: frontmatter inválido"; exit 1; }

# 3. Encoding UTF-8, sem CRLF, com trailing newline
file "$FILE" | grep -q 'UTF-8' || { echo "FALHA: não é UTF-8"; exit 1; }
! grep -lU $'\r' "$FILE" >/dev/null || { echo "FALHA: contém CRLF"; exit 1; }
test "$(tail -c 1 "$FILE" | xxd -p)" = "0a" || { echo "FALHA: sem trailing newline"; exit 1; }

# 4. Título correto (§1.1.6 regra 2)
grep -q '^# Constitution universal do codeflow$' "$FILE" \
  || { echo "FALHA: título ausente ou incorreto"; exit 1; }

# 5. As cinco seções obrigatórias presentes (§1.1.6 regra 3)
secoes=(
  '^## Princípios invariantes$'
  '^## Política de falhas$'
  '^## Formato PARADO$'
  '^## Proibições absolutas$'
  '^## Quando esta constitution se aplica$'
)
for s in "${secoes[@]}"; do
  grep -qE "$s" "$FILE" || { echo "FALHA: seção ausente: $s"; exit 1; }
done

# 6. Ordem das seções (§1.1.6 regra 3)
ordem_obtida=$(grep -E '^## ' "$FILE" | head -5)
ordem_esperada='## Princípios invariantes
## Política de falhas
## Formato PARADO
## Proibições absolutas
## Quando esta constitution se aplica'
test "$ordem_obtida" = "$ordem_esperada" \
  || { echo "FALHA: ordem das seções incorreta"; echo "obtido:"; echo "$ordem_obtida"; exit 1; }

# 7. Quatro proibições absolutas (§1.1.6 regra 7)
# Extrai conteúdo entre '## Proibições absolutas' e próximo '## '. Padrão de flag
# evita o bug do range awk '/start/,/end/' quando start também casa com end.
n_proib=$(awk '/^## Proibições absolutas$/{flag=1; next} /^## /{flag=0} flag' "$FILE" \
          | grep -cE '^- (Não|Nunca|Jamais)')
test "$n_proib" -ge 4 || { echo "FALHA: menos de 4 proibições com 'Não/Nunca/Jamais'"; exit 1; }

# 8. Quatro categorias de falha (§1.1.6 regra 5)
for cat in 'Transitória' 'Lógica' 'Escopo' 'Ambiente'; do
  awk '/^## Política de falhas$/{flag=1; next} /^## /{flag=0} flag' "$FILE" \
    | grep -q "$cat" \
    || { echo "FALHA: categoria '$cat' ausente em Política de falhas"; exit 1; }
done

# 9. Formato PARADO (§1.1.6 regra 6) — palavra literal presente
awk '/^## Formato PARADO$/{flag=1; next} /^## /{flag=0} flag' "$FILE" \
  | grep -q 'PARADO' \
  || { echo "FALHA: palavra PARADO ausente na seção"; exit 1; }

# 10. Palavras-fraca ausentes (regra transversal 20)
! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
  >/dev/null || { echo "FALHA: palavras-fraca presentes"; exit 1; }

# 11. Sem TODO/FIXME/XXX (regra transversal 38)
! grep -E 'TODO|FIXME|XXX' "$FILE" >/dev/null \
  || { echo "FALHA: marcadores TODO/FIXME/XXX presentes"; exit 1; }

# 12. Tamanho razoável (§1.1.6 regra 9) — entre 40 e 80 linhas
n=$(wc -l < "$FILE")
test "$n" -ge 40 && test "$n" -le 80 \
  || { echo "AVISO: tamanho $n linhas, alvo 40-80"; }

echo "OK: §V.2.1"
```

**Verificações por inspeção:**
- [ ] **Linguagem imperativa** em todas as regras (§1.1.6 regra 4). Cada bullet/parágrafo declara obrigação clara, sem hedges.
- [ ] **Conteúdo agnóstico de stack** (§1.1.6 regra 8). Nenhuma menção a Python, Go, JavaScript, etc.
- [ ] **Coerência com SPEC §4.1.1 e §8.3**: princípios e política de falhas refletem literalmente o que o SPEC define, sem extrapolação.
- [ ] **Definition of Done padrão ausente** (decisão registrada durante construção do ARTIFACTS_SPEC).

**Critério de aprovação:** todos os snippets retornam zero; quatro itens de inspeção marcados como `[✓]`.

---

### §V.2.2 — Glossary

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/core/glossary.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §1.2.6 (10 regras específicas).
- `ARTIFACTS_SPEC.md` Parte 3.
- `SPEC.md` §6.2.

**Verificações automatizáveis:**

```bash
FILE=~/Projetos/codeflow/framework/core/glossary.md

# 1-3. Existência + frontmatter + forma (helpers padrão)
test -f "$FILE" || { echo "FALHA: arquivo ausente"; exit 1; }
awk '
  /^---$/ { count++; if (count==2) exit }
  count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
  count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
  count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
  END { exit (v && s && a) ? 0 : 1 }
' "$FILE" || { echo "FALHA: frontmatter inválido"; exit 1; }
file "$FILE" | grep -q 'UTF-8' && ! grep -lU $'\r' "$FILE" >/dev/null \
  || { echo "FALHA: encoding/CRLF"; exit 1; }

# 4. Título (§1.2.6 regra 2) — em pt-BR com acento
grep -q '^# Glossário do codeflow$' "$FILE" \
  || { echo "FALHA: título ausente ou incorreto"; exit 1; }

# 5. 12 termos centrais presentes como sub-seções ### (§1.2.6 regra 4), em ordem alfabética pt-BR
termos=(Agent Artefato Checkpoint Constitution Decision Discovered INDEX Manifest Meta-skill Rule Skill Workflow)
for t in "${termos[@]}"; do
  grep -qE "^### $t$" "$FILE" \
    || { echo "FALHA: termo '$t' ausente como sub-seção"; exit 1; }
done
# Ordem: extrair termos na ordem em que aparecem e comparar com a esperada
# Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
ordem_obtida=$(awk '/^## Termos centrais$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -E '^### ' | sed 's/^### //')
ordem_esperada=$(printf '%s\n' "${termos[@]}")
test "$ordem_obtida" = "$ordem_esperada" \
  || { echo "FALHA: termos fora da ordem alfabética pt-BR esperada"; echo "obtido:"; echo "$ordem_obtida"; exit 1; }

# 6. 4 distinções presentes (§1.2.6 regra 5)
distincoes=(
  'Workflow vs Skill'
  'Agent vs Skill'
  'Rule vs Constitution'
  'Decision vs Checkpoint'
)
for d in "${distincoes[@]}"; do
  grep -qF "$d" "$FILE" \
    || { echo "FALHA: distinção '$d' ausente"; exit 1; }
done

# 7. Nota de colisão de Agent (§1.2.6 regra 5)
# Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
awk '/^### Agent$/{flag=1; next} /^### /{flag=0} flag' "$FILE" \
  | grep -qiE 'colisão|cursor|claude code' \
  || { echo "FALHA: nota de colisão em Agent ausente"; exit 1; }

# 8. Palavras-fraca ausentes
! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
  >/dev/null || { echo "FALHA: palavras-fraca presentes"; exit 1; }

# 9. Tamanho razoável — entre 100 e 180 linhas (12 termos + 4 distinções + cabeçalho)
n=$(wc -l < "$FILE")
test "$n" -ge 100 && test "$n" -le 180 \
  || { echo "AVISO: tamanho $n linhas, alvo 100-180"; }

# 10. Sem TODO/FIXME
! grep -E 'TODO|FIXME|XXX' "$FILE" >/dev/null \
  || { echo "FALHA: marcadores TODO/FIXME/XXX presentes"; exit 1; }

echo "OK: §V.2.2"
```

**Verificações por inspeção:**
- [ ] **Não-circularidade** das definições (§1.2.6 regra 8). Nenhum termo usa sua própria palavra-chave para se definir. Exemplo de violação: "Constitution: documento que estabelece a constitution do framework".
- [ ] **Definições objetivas** (§1.2.6 regra 6): duas a quatro linhas por termo, sem hedges, sem "tipicamente"/"geralmente".
- [ ] **Coerência terminológica com SPEC §6.2**: vocabulário do glossary bate com o usado no resto do framework.
- [ ] **Agent inclui nota de colisão** declarando explicitamente o conflito com termo usado por Cursor/Claude Code.

**Critério de aprovação:** todos os snippets retornam zero; quatro itens de inspeção marcados.

---

### §V.2.3 — EVOLUTION

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/core/EVOLUTION.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §1.3.6 (10 regras específicas).
- `ARTIFACTS_SPEC.md` Parte 3.
- `SPEC.md` §6.3.

**Verificações automatizáveis:**

```bash
FILE=~/Projetos/codeflow/framework/core/EVOLUTION.md

# 1-3. Existência + frontmatter + forma
test -f "$FILE" || { echo "FALHA: arquivo ausente"; exit 1; }
awk '
  /^---$/ { count++; if (count==2) exit }
  count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
  count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
  count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
  END { exit (v && s && a) ? 0 : 1 }
' "$FILE" || { echo "FALHA: frontmatter inválido"; exit 1; }
file "$FILE" | grep -q 'UTF-8' && ! grep -lU $'\r' "$FILE" >/dev/null \
  || { echo "FALHA: encoding/CRLF"; exit 1; }

# 4. Título (§1.3.6 regra 2)
grep -q '^# Política de evolução do codeflow$' "$FILE" \
  || { echo "FALHA: título ausente ou incorreto"; exit 1; }

# 5. Cinco seções literais (§1.3.6 regra 3)
secoes=(
  '^## Promoção'
  '^## Adição de rule$'
  '^## Adição de meta-skill$'
  '^## Mudança em arquivo do core'
  '^## Anti-evolução$'
)
for s in "${secoes[@]}"; do
  grep -qE "$s" "$FILE" || { echo "FALHA: seção ausente: $s"; exit 1; }
done

# 6. Strings críticas literais presentes (§1.3.6 regra 5)
for token in '30 dias' 'git mv' 'bump minor' 'bump major'; do
  grep -qF "$token" "$FILE" \
    || { echo "FALHA: token literal '$token' ausente"; exit 1; }
done

# 7. Critério de "dois ou mais projetos" presente (§1.3.6 regra 4)
grep -qE 'dois|2.*projeto' "$FILE" \
  || { echo "FALHA: critério de promoção (dois projetos) ausente"; exit 1; }

# 8. Anti-evolução tem exemplos concretos
# Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
# Como Anti-evolução é a última seção, /^## /{flag=0} pode nunca disparar — flag fica em 1
# até o fim do arquivo, o que é o comportamento desejado.
awk '/^## Anti-evolução$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -qE '^- ' \
  || { echo "FALHA: Anti-evolução sem bullets"; exit 1; }

# 9. Palavras-fraca ausentes
! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
  >/dev/null || { echo "FALHA: palavras-fraca presentes"; exit 1; }

# 10. Tamanho razoável — entre 50 e 120 linhas
n=$(wc -l < "$FILE")
test "$n" -ge 50 && test "$n" -le 120 \
  || { echo "AVISO: tamanho $n linhas, alvo 50-120"; }

echo "OK: §V.2.3"
```

**Verificações por inspeção:**
- [ ] **Cada uma das cinco seções tem critérios objetivos** (§1.3.6 regra 6): condições para a mudança ser permitida + processo passo a passo + exemplos do que não justifica.
- [ ] **Anti-evolução nomeia padrões reconhecíveis** (não generalidades): por exemplo, "criação preventiva", "promoção sem uso real em dois projetos".
- [ ] **Coerência com SPEC §6.3**: critérios refletem literalmente o que o SPEC define.

**Critério de aprovação:** todos os snippets retornam zero; três itens de inspeção marcados.

---

### §V.2.4 — Quatro rules seed

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/core/rules/code-quality.md`
- `~/Projetos/codeflow/framework/core/rules/testing.md`
- `~/Projetos/codeflow/framework/core/rules/security.md`
- `~/Projetos/codeflow/framework/core/rules/naming.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §1.4.6 (10 regras específicas, aplicadas a cada arquivo).
- `ARTIFACTS_SPEC.md` Parte 3.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow/framework/core/rules

falhas=0
for tema in code-quality testing security naming; do
  FILE="${tema}.md"
  echo "--- Validando rule: $tema"

  # 1. Existência
  test -f "$FILE" || { echo "  FALHA: arquivo ausente"; falhas=$((falhas+1)); continue; }

  # 2. Frontmatter com escopo: universal
  awk '
    /^---$/ { count++; if (count==2) exit }
    count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
    count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
    count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
    count==1 && /^escopo: universal$/ { e=1 }
    END { exit (v && s && a && e) ? 0 : 1 }
  ' "$FILE" || { echo "  FALHA: frontmatter inválido (incluindo escopo: universal)"; falhas=$((falhas+1)); }

  # 3. Encoding/CRLF/trailing newline
  file "$FILE" | grep -q 'UTF-8' || { echo "  FALHA: não é UTF-8"; falhas=$((falhas+1)); }

  # 4. Título no formato exato (§1.4.6 regra 2)
  grep -q "^# Rule: ${tema}$" "$FILE" \
    || { echo "  FALHA: título incorreto"; falhas=$((falhas+1)); }

  # 5. Quatro seções fixas (§1.4.6 regra 3)
  for s in '^## Quando carregar$' '^## Regras$' '^## Anti-regras$' '^## Exceções$'; do
    grep -qE "$s" "$FILE" \
      || { echo "  FALHA: seção ausente: $s"; falhas=$((falhas+1)); }
  done

  # 6. Pelo menos três regras (§1.4.6 regra 4)
  # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
  n_regras=$(awk '/^## Regras$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -cE '^- ')
  test "$n_regras" -ge 3 \
    || { echo "  FALHA: menos de 3 regras ($n_regras)"; falhas=$((falhas+1)); }

  # 7. Anti-regras com forma negativa (§1.4.6 regra 6)
  n_anti=$(awk '/^## Anti-regras$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -cE '^- (Não|Nunca|Jamais)')
  test "$n_anti" -ge 1 \
    || { echo "  FALHA: nenhuma anti-regra começa com Não/Nunca/Jamais"; falhas=$((falhas+1)); }

  # 8. Exceções: pelo menos uma declarada ou texto literal "Nenhuma."
  # Exceções é a última seção; padrão de flag deixa flag=1 até o fim do arquivo.
  n_excecoes=$(awk '/^## Exceções$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -cE '^- |^Nenhuma\.$')
  test "$n_excecoes" -ge 1 \
    || { echo "  FALHA: Exceções sem itens nem texto 'Nenhuma.'"; falhas=$((falhas+1)); }

  # 9. Palavras-fraca ausentes
  ! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
    >/dev/null || { echo "  FALHA: palavras-fraca presentes"; falhas=$((falhas+1)); }
done

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.2.4 (4 rules validados)"
else
  echo "FALHA: $falhas problema(s) em rules"
  exit 1
fi
```

**Verificações por inspeção (para cada rule):**
- [ ] **Conteúdo agnóstico de stack** (§1.4.6 regra 8). Nenhuma referência a pytest, Jest, Postgres, etc. — esses pertencem a rules de projeto.
- [ ] **Paridade aproximada entre regras e anti-regras** (§1.4.6 regra 5).
- [ ] **Cada exceção tem condição + justificativa + o que continua valendo** (§1.4.6 spec da seção). Exceções genéricas tipo "casos especiais" violam.

**Critério de aprovação:** snippet retorna zero (falhas == 0); itens de inspeção marcados para os quatro arquivos.

---

### §V.3.1 — Três skills seed

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/library/skills/debug-protocol/SKILL.md`
- `~/Projetos/codeflow/framework/library/skills/handoff/SKILL.md`
- `~/Projetos/codeflow/framework/library/skills/self-review/SKILL.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §1.8.6 (10 regras específicas, aplicadas a cada arquivo).
- `ARTIFACTS_SPEC.md` Parte 3.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow/framework/library/skills

falhas=0
for nome in debug-protocol handoff self-review; do
  FILE="${nome}/SKILL.md"
  echo "--- Validando skill: $nome"

  # 1. Pasta em kebab-case com SKILL.md em maiúsculas (§1.8.6 regra 2)
  test -d "$nome" || { echo "  FALHA: pasta ausente"; falhas=$((falhas+1)); continue; }
  test -f "$FILE" || { echo "  FALHA: SKILL.md ausente"; falhas=$((falhas+1)); continue; }

  # 2. Frontmatter com descrição (§1.8.6 regra 1)
  awk '
    /^---$/ { count++; if (count==2) exit }
    count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
    count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
    count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
    count==1 && /^descrição: .+/ { d=1 }
    END { exit (v && s && a && d) ? 0 : 1 }
  ' "$FILE" || { echo "  FALHA: frontmatter inválido"; falhas=$((falhas+1)); }

  # 3. Encoding/CRLF
  file "$FILE" | grep -q 'UTF-8' || { echo "  FALHA: não é UTF-8"; falhas=$((falhas+1)); }

  # 4. Título correto (§1.8.6 regra 3)
  grep -q "^# Skill: ${nome}$" "$FILE" \
    || { echo "  FALHA: título incorreto"; falhas=$((falhas+1)); }

  # 5. Seis seções obrigatórias (§1.8.6 regra 4)
  for s in '^## Quando usar$' '^## Princípio guia$' '^## Protocolo$' '^## Proibições durante esta skill$' '^## Saídas válidas$'; do
    grep -qE "$s" "$FILE" \
      || { echo "  FALHA: seção ausente: $s"; falhas=$((falhas+1)); }
  done

  # 6. SEM Definition of Done (§1.8.6 regra 5)
  ! grep -qE '^## Definition of Done' "$FILE" \
    || { echo "  FALHA: ## Definition of Done presente (vedado em skill)"; falhas=$((falhas+1)); }

  # 7. SEM LEIA TAMBÉM (§1.8.6 regra 6)
  ! grep -qE '^## LEIA TAMBÉM' "$FILE" \
    || { echo "  FALHA: ## LEIA TAMBÉM presente (vedado em skill)"; falhas=$((falhas+1)); }

  # 8. Proibições com forma negativa (§1.8.6 regra 8)
  # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
  n_proib=$(awk '/^## Proibições durante esta skill$/{flag=1; next} /^## /{flag=0} flag' "$FILE" \
            | grep -cE '^- (Não|Nunca|Jamais)')
  test "$n_proib" -ge 1 \
    || { echo "  FALHA: nenhuma proibição com Não/Nunca/Jamais"; falhas=$((falhas+1)); }

  # 9. Palavras-fraca ausentes
  ! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
    >/dev/null || { echo "  FALHA: palavras-fraca presentes"; falhas=$((falhas+1)); }
done

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.3.1 (3 skills validadas)"
else
  echo "FALHA: $falhas problema(s) em skills"
  exit 1
fi
```

**Verificações por inspeção (para cada skill):**
- [ ] **Princípio guia curto** (1 a 3 frases). Filosofia, não dissertação.
- [ ] **Saídas válidas declaram tipos**, não conteúdo específico (§1.8.7 anti-padrão).
- [ ] **Skill não invoca outra skill** (`SPEC.md` §10.6 — composição entre skills é anti-feature).
- [ ] **Conteúdo de cada skill bate com o propósito**: `debug-protocol` aplica protocolo anti-loop com limite de tentativas; `handoff` define formato de transferência de contexto; `self-review` define checklist de auto-revisão de diff.

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados para as três skills.

---

### §V.3.2 — Quatro workflows seed

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/library/workflows/review-only.md` (magro)
- `~/Projetos/codeflow/framework/library/workflows/bugfix.md` (médio)
- `~/Projetos/codeflow/framework/library/workflows/feature-small.md` (médio)
- `~/Projetos/codeflow/framework/library/workflows/refactor-safe.md` (médio)

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §1.5.6 (workflows magros).
- `ARTIFACTS_SPEC.md` §1.6.6 (workflows médios).
- `ARTIFACTS_SPEC.md` Parte 3.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow/framework/library/workflows

# Mapa nome → granularidade esperada
declare -A granul=(
  [review-only]=magro
  [bugfix]=médio
  [feature-small]=médio
  [refactor-safe]=médio
)

falhas=0
for nome in "${!granul[@]}"; do
  FILE="${nome}.md"
  esperado="${granul[$nome]}"
  echo "--- Validando workflow: $nome (esperado: $esperado)"

  # 1. Existência
  test -f "$FILE" || { echo "  FALHA: arquivo ausente"; falhas=$((falhas+1)); continue; }

  # 2. Frontmatter universal + granularidade correta
  awk -v esp="$esperado" '
    /^---$/ { count++; if (count==2) exit }
    count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
    count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
    count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
    count==1 && $1 == "granularidade:" && $2 == esp { g=1 }
    count==1 && /^gera_decision: (yes|no|auto)$/ { gd=1 }
    count==1 && /^usa_checkpoints: no$/ { uc=1 }
    count==1 && /^politica_falhas: padrão$/ { pf=1 }
    END { exit (v && s && a && g && gd && uc && pf) ? 0 : 1 }
  ' "$FILE" || { echo "  FALHA: frontmatter inválido (incluindo granularidade $esperado)"; falhas=$((falhas+1)); }

  # 3. Encoding/CRLF
  file "$FILE" | grep -q 'UTF-8' || { echo "  FALHA: não é UTF-8"; falhas=$((falhas+1)); }

  # 4. Título
  grep -q "^# Workflow: ${nome}$" "$FILE" \
    || { echo "  FALHA: título incorreto"; falhas=$((falhas+1)); }

  # 5. Seções obrigatórias comuns
  for s in '^## Quando usar' '^## Quando NÃO usar' '^## LEIA TAMBÉM' '^## Protocolo' '^## Definition of Done' '^## Resumo final'; do
    grep -qE "$s" "$FILE" \
      || { echo "  FALHA: seção ausente: $s"; falhas=$((falhas+1)); }
  done

  # 5b. Workflows médios também exigem '## Antes de começar' (§1.6.3); workflows magros NÃO têm essa seção.
  if [ "$esperado" = "médio" ]; then
    grep -qE '^## Antes de começar' "$FILE" \
      || { echo "  FALHA: workflow médio sem '## Antes de começar'"; falhas=$((falhas+1)); }
  fi

  # 6. LEIA TAMBÉM inclui as quatro entradas obrigatórias
  # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
  for entrada in \
    'framework/core/constitution.md' \
    '.codeflow/INDEX.md' \
    '.codeflow/constitution.md' \
    '.codeflow/manifest.md'; do
    awk '/^## LEIA TAMBÉM$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -qF "$entrada" \
      || { echo "  FALHA: LEIA TAMBÉM sem '$entrada'"; falhas=$((falhas+1)); }
  done

  # 7. Pelo menos um passo no Protocolo
  n_passos=$(grep -cE '^### Passo [0-9]+' "$FILE")
  test "$n_passos" -ge 1 \
    || { echo "  FALHA: nenhum '### Passo N' no Protocolo"; falhas=$((falhas+1)); }

  # 8. Workflows médios: 4-7 passos; magros: pelo menos 1
  if [ "$esperado" = "médio" ]; then
    test "$n_passos" -ge 4 && test "$n_passos" -le 7 \
      || { echo "  FALHA: médio com $n_passos passos (esperado 4-7)"; falhas=$((falhas+1)); }
  fi

  # 9. Sem ## Fase N (reservado para detalhados)
  ! grep -qE '^## Fase [0-9]+' "$FILE" \
    || { echo "  FALHA: '## Fase N' presente (vedado em magro/médio)"; falhas=$((falhas+1)); }

  # 10. Sem ## Proibições durante este workflow (reservado para detalhados)
  ! grep -qE '^## Proibições durante este workflow' "$FILE" \
    || { echo "  FALHA: '## Proibições durante este workflow' presente"; falhas=$((falhas+1)); }

  # 11. Definition of Done com pelo menos um checkbox
  # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
  awk '/^## Definition of Done$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -qE '^- \[ \]' \
    || { echo "  FALHA: Definition of Done sem checkboxes '- [ ]'"; falhas=$((falhas+1)); }

  # 12. Médios incluem make check (ou marcação [—])
  if [ "$esperado" = "médio" ]; then
    grep -qE 'make check|make [a-z]+|\[—\]' "$FILE" \
      || { echo "  FALHA: workflow médio sem referência a make check"; falhas=$((falhas+1)); }
  fi

  # 13. Palavras-fraca ausentes
  ! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
    >/dev/null || { echo "  FALHA: palavras-fraca presentes"; falhas=$((falhas+1)); }
done

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.3.2 (4 workflows validados)"
else
  echo "FALHA: $falhas problema(s) em workflows"
  exit 1
fi
```

**Verificações por inspeção:**
- [ ] **Referências em `## LEIA TAMBÉM` apontam para arquivos existentes**: todas as skills e rules citadas existem em `framework/core/` ou `framework/library/skills/`.
- [ ] **`gera_decision` coerente com a natureza do workflow**: `review-only` é `no`; `bugfix` e `feature-small` são `auto`; `refactor-safe` é `no`.
- [ ] **`## Antes de começar` referencia decisions/INDEX em workflows médios** (§1.6.6 regra 7).
- [ ] **Sem conversa estruturada com usuário** durante execução (anti-padrão §1.6.7 — pertence a workflows detalhados).
- [ ] **Sem `## Princípio guia`** (seção exclusiva de workflows detalhados).

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados para os quatro workflows.

---

### §V.3.3 — Manter `framework/library/agents/` vazio

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/library/agents/` (diretório).

**Regras aplicáveis:**
- `SPEC.md` §4.5.4 (nenhum agent seed entregue).
- `ARTIFACTS_SPEC.md` §1.10.1.
- `BUILD_PLAN.md` §F3.3.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow/framework/library/agents

# 1. Pasta existe
test -d . || { echo "FALHA: pasta agents/ ausente"; exit 1; }

# 2. Sem arquivos .md (nenhum agent entregue)
n_agents=$(find . -maxdepth 1 -name '*.md' -type f | wc -l)
test "$n_agents" -eq 0 \
  || { echo "FALHA: $n_agents agent(s) presente(s), esperado 0"; exit 1; }

# 3. .gitkeep presente
test -f .gitkeep || { echo "FALHA: .gitkeep ausente"; exit 1; }

echo "OK: §V.3.3"
```

**Verificações por inspeção:**
- [ ] Decisão de não-entrega registrada (em `.gitkeep` como comentário, no log de execução, ou no commit).

**Critério de aprovação:** snippet retorna zero; item de inspeção marcado.

---

### §V.4.1 — Três meta-skills `create-*`

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/meta/create-workflow/SKILL.md`
- `~/Projetos/codeflow/framework/meta/create-skill/SKILL.md`
- `~/Projetos/codeflow/framework/meta/create-agent/SKILL.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §1.9.6 (10 regras específicas, aplicadas a cada arquivo).
- `ARTIFACTS_SPEC.md` Parte 3.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow/framework/meta

falhas=0
for nome in create-workflow create-skill create-agent; do
  FILE="${nome}/SKILL.md"
  echo "--- Validando meta-skill: $nome"

  # 1. Pasta + SKILL.md (§1.9.6 regra 2)
  test -d "$nome" || { echo "  FALHA: pasta ausente"; falhas=$((falhas+1)); continue; }
  test -f "$FILE" || { echo "  FALHA: SKILL.md ausente"; falhas=$((falhas+1)); continue; }

  # 2. Frontmatter com descrição, é_meta_skill: yes, granularidade: médio
  awk '
    /^---$/ { count++; if (count==2) exit }
    count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
    count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
    count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
    count==1 && /^descrição: .+/ { d=1 }
    count==1 && /^é_meta_skill: yes$/ { e=1 }
    count==1 && /^granularidade: médio$/ { g=1 }
    END { exit (v && s && a && d && e && g) ? 0 : 1 }
  ' "$FILE" || { echo "  FALHA: frontmatter inválido"; falhas=$((falhas+1)); }

  # 3. Encoding
  file "$FILE" | grep -q 'UTF-8' || { echo "  FALHA: não é UTF-8"; falhas=$((falhas+1)); }

  # 4. Título correto (§1.9.6 regra 3)
  grep -q "^# Meta-skill: ${nome}$" "$FILE" \
    || { echo "  FALHA: título incorreto"; falhas=$((falhas+1)); }

  # 5. Seções herdadas de skill + exclusivas de meta-skill
  for s in '^## Quando usar$' '^## Princípio guia$' '^## Protocolo$' '^## Saídas válidas$'; do
    grep -qE "$s" "$FILE" \
      || { echo "  FALHA: seção ausente: $s"; falhas=$((falhas+1)); }
  done

  # 6. Três seções exclusivas de meta-skill (§1.9.6 regra 5) + Proibições durante esta meta-skill
  for s in '^## Template de saída$' '^## Onde salvar$' '^## Validação pós-geração$' '^## Proibições durante esta meta-skill$'; do
    grep -qE "$s" "$FILE" \
      || { echo "  FALHA: seção exclusiva ausente: $s"; falhas=$((falhas+1)); }
  done

  # 7. Template de saída tem bloco de código ou referência a ARTIFACTS_SPEC (§1.9.6 regra 6)
  # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
  # Regex tolera backticks intermediários (markdown idiomático: `ARTIFACTS_SPEC.md` §).
  awk '/^## Template de saída$/{flag=1; next} /^## /{flag=0} flag' "$FILE" \
    | grep -qE '```|ARTIFACTS_SPEC\.md`? §' \
    || { echo "  FALHA: Template de saída sem bloco de código nem referência a §"; falhas=$((falhas+1)); }

  # 8. Onde salvar tem caminho concreto (§1.9.6 regra 7)
  # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
  awk '/^## Onde salvar$/{flag=1; next} /^## /{flag=0} flag' "$FILE" \
    | grep -qE '~/.codeflow|\.codeflow/' \
    || { echo "  FALHA: Onde salvar sem caminho concreto"; falhas=$((falhas+1)); }

  # 9. Validação pós-geração com pelo menos 3 checks (§1.9.6 regra 8)
  # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
  n_checks=$(awk '/^## Validação pós-geração$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -cE '^- ')
  test "$n_checks" -ge 3 \
    || { echo "  FALHA: Validação pós-geração com $n_checks itens (mín 3)"; falhas=$((falhas+1)); }

  # 10. SEM Definition of Done
  ! grep -qE '^## Definition of Done' "$FILE" \
    || { echo "  FALHA: ## Definition of Done presente (vedado em meta-skill)"; falhas=$((falhas+1)); }

  # 11. Palavras-fraca
  ! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
    >/dev/null || { echo "  FALHA: palavras-fraca presentes"; falhas=$((falhas+1)); }
done

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.4.1 (3 meta-skills create-* validadas)"
else
  echo "FALHA: $falhas problema(s) em meta-skills"
  exit 1
fi
```

**Verificações por inspeção:**
- [ ] **Cada meta-skill referencia o ARTIFACTS_SPEC corretamente** para o tipo de artefato que gera: `create-workflow` referencia §1.5/§1.6/§1.7; `create-skill` referencia §1.8; `create-agent` referencia §1.10.
- [ ] **Cada meta-skill qualifica a necessidade antes de gerar** (anti-evolução §6.3): o primeiro passo do protocolo verifica se a criação é justificada.
- [ ] **`create-agent` recusa criação quando skill bastaria** (§1.10.7 anti-padrão).

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados.

---

### §V.4.2 — Duas meta-skills `discover` e `bootstrap`

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/framework/meta/discover/SKILL.md`
- `~/Projetos/codeflow/framework/meta/bootstrap/SKILL.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §1.9.6 + adições para granularidade detalhada (§1.9.6 regra 9).
- `ARTIFACTS_SPEC.md` Parte 3.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow/framework/meta

falhas=0
for nome in discover bootstrap; do
  FILE="${nome}/SKILL.md"
  echo "--- Validando meta-skill detalhada: $nome"

  # 1. Pasta + SKILL.md
  test -d "$nome" && test -f "$FILE" \
    || { echo "  FALHA: pasta ou SKILL.md ausente"; falhas=$((falhas+1)); continue; }

  # 2. Frontmatter com granularidade: detalhado
  awk '
    /^---$/ { count++; if (count==2) exit }
    count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
    count==1 && /^é_meta_skill: yes$/ { e=1 }
    count==1 && /^granularidade: detalhado$/ { g=1 }
    END { exit (v && e && g) ? 0 : 1 }
  ' "$FILE" || { echo "  FALHA: frontmatter sem granularidade: detalhado"; falhas=$((falhas+1)); }

  # 3. Título
  grep -q "^# Meta-skill: ${nome}$" "$FILE" \
    || { echo "  FALHA: título incorreto"; falhas=$((falhas+1)); }

  # 4. Pelo menos 3 fases no Protocolo (§1.9.6 regra 9)
  n_fases=$(grep -cE '^### Fase [0-9]+' "$FILE")
  test "$n_fases" -ge 3 \
    || { echo "  FALHA: $n_fases fases (mín 3 para detalhado)"; falhas=$((falhas+1)); }

  # 5. Pelo menos uma pausa para usuário documentada
  grep -qiE 'aguardar confirmação|pergunta ao usuário|apresentar plano|aguardar resposta' "$FILE" \
    || { echo "  FALHA: nenhuma pausa para usuário declarada"; falhas=$((falhas+1)); }

  # 6. Três seções exclusivas de meta-skill + Proibições durante esta meta-skill
  for s in '^## Template de saída$' '^## Onde salvar$' '^## Validação pós-geração$' '^## Proibições durante esta meta-skill$'; do
    grep -qE "$s" "$FILE" \
      || { echo "  FALHA: seção exclusiva ausente: $s"; falhas=$((falhas+1)); }
  done

  # 7. Onde salvar referencia <projeto>/.codeflow/ (não ~/.codeflow/)
  # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
  awk '/^## Onde salvar$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -qE '\.codeflow/' \
    || { echo "  FALHA: Onde salvar sem referência a .codeflow/"; falhas=$((falhas+1)); }

  # 8. discover gera 4 artefatos (INDEX, constitution, manifest, discovered)
  if [ "$nome" = "discover" ]; then
    for artefato in INDEX constitution manifest discovered; do
      grep -qiE "$artefato" "$FILE" \
        || { echo "  FALHA: discover não menciona $artefato"; falhas=$((falhas+1)); }
    done
  fi

  # 9. bootstrap gera 3 artefatos do .codeflow/ (INDEX, constitution, manifest) e NÃO menciona discovered como gerado
  if [ "$nome" = "bootstrap" ]; then
    for artefato in INDEX constitution manifest; do
      grep -qiE "$artefato" "$FILE" \
        || { echo "  FALHA: bootstrap não menciona $artefato"; falhas=$((falhas+1)); }
    done
    # bootstrap PODE mencionar discovered (para esclarecer que NÃO gera), mas Validação pós-geração não referencia §2.4
    # Padrão de flag evita o bug do range awk '/start/,/end/' quando start também casa com end.
    # Regex tolera backticks intermediários (markdown idiomático: `ARTIFACTS_SPEC.md` §2.4).
    awk '/^## Validação pós-geração$/{flag=1; next} /^## /{flag=0} flag' "$FILE" | grep -qE 'ARTIFACTS_SPEC\.md`? §2\.4' \
      && { echo "  FALHA: bootstrap referencia §2.4 (discovered) em validação"; falhas=$((falhas+1)); }
  fi

  # 10. Palavras-fraca
  ! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
    >/dev/null || { echo "  FALHA: palavras-fraca presentes"; falhas=$((falhas+1)); }
done

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.4.2 (2 meta-skills detalhadas validadas)"
else
  echo "FALHA: $falhas problema(s) em meta-skills detalhadas"
  exit 1
fi
```

**Verificações por inspeção:**
- [ ] **`discover` tem 4 fases**: Inspeção → Entrevista → Geração de constitution/manifest/INDEX → Geração de discovered.md.
- [ ] **`bootstrap` tem 5 fases**: Coleta de requisitos → Decisão de stack → Geração de estrutura do projeto → Geração de artefatos do `.codeflow/` → Entrega.
- [ ] **`discover` faz no máximo 5 perguntas ao usuário** (`SPEC.md` §4.4.2 limite literal).
- [ ] **`bootstrap` pausa em pelo menos 2 fases**.
- [ ] **Seção opcional `## Retomada` presente** em ambas (recomendado para detalhadas conforme `ARTIFACTS_SPEC.md` §1.9.4).

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados.

---

### §V.5.1 — Script `install.sh`

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/install.sh`

**Regras aplicáveis:**
- `SPEC.md` §3.9 (decisão completa + anti-decisão).
- `SPEC.md` §7 (decisões técnicas).
- `ARTIFACTS_SPEC.md` §0.7 (códigos de saída) e §3.8 (stack permitida em scripts).

**Verificações automatizáveis:**

```bash
FILE=~/Projetos/codeflow/install.sh

# 1. Arquivo existe e é executável
test -f "$FILE" || { echo "FALHA: install.sh ausente"; exit 1; }
test -x "$FILE" || { echo "FALHA: install.sh não é executável"; exit 1; }

# 2. Shebang correto
head -1 "$FILE" | grep -qE '^#!/(usr/)?bin/(env )?bash$' \
  || { echo "FALHA: shebang ausente ou não é bash"; exit 1; }

# 3. shellcheck passa (se disponível)
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$FILE" || { echo "FALHA: shellcheck reportou problemas"; exit 1; }
else
  echo "AVISO: shellcheck não disponível; pulando verificação"
fi

# 4. Stack permitida: não usa jq, yq, python, node, etc.
for proibido in jq yq python python3 node go cargo docker podman; do
  if grep -qE "\\b${proibido}\\b" "$FILE"; then
    echo "FALHA: install.sh referencia ferramenta proibida: $proibido"
    exit 1
  fi
done

# 5. Códigos de saída esperados presentes (exit 0/1/2/3)
for code in 0 1; do
  grep -qE "exit ${code}\b" "$FILE" \
    || { echo "AVISO: install.sh não usa explicitamente exit $code"; }
done

# 6. Teste funcional em pasta temporária
TESTDIR=$(mktemp -d)
cd "$TESTDIR"
git init >/dev/null 2>&1
git config user.email "test@local" >/dev/null
git config user.name "test" >/dev/null
echo "test" > README.md
git add . && git commit -m "init" >/dev/null

# Executar install.sh
bash "$FILE" >/tmp/install_out.log 2>&1
rc=$?
test "$rc" -eq 0 || { echo "FALHA: install.sh retornou $rc em projeto de teste"; cat /tmp/install_out.log; rm -rf "$TESTDIR"; exit 1; }

# 7. Verificar artefatos criados
test -f .codeflow/INDEX.md || { echo "FALHA: .codeflow/INDEX.md não criado"; rm -rf "$TESTDIR"; exit 1; }
test -d .codeflow/decisions || { echo "FALHA: .codeflow/decisions/ não criado"; rm -rf "$TESTDIR"; exit 1; }
test -d .codeflow/checkpoints || { echo "FALHA: .codeflow/checkpoints/ não criado"; rm -rf "$TESTDIR"; exit 1; }

# 8. .gitignore atualizado
grep -qE '\.codeflow/checkpoints' .gitignore \
  || { echo "FALHA: .gitignore sem .codeflow/checkpoints/"; rm -rf "$TESTDIR"; exit 1; }

# 9. Não modificou README.md
md5_before=$(md5sum README.md 2>/dev/null || md5 -q README.md 2>/dev/null)
echo "test" | md5sum >/dev/null # placeholder; o md5 já foi capturado antes do install
# Mais robusto: git status mostra README.md como inalterado
test -z "$(git status --porcelain README.md)" \
  || { echo "FALHA: install.sh modificou README.md"; rm -rf "$TESTDIR"; exit 1; }

# 10. Idempotência: rodar novamente não falha nem corrompe
bash "$FILE" >/tmp/install_out2.log 2>&1
rc2=$?
test "$rc2" -eq 0 || { echo "FALHA: segunda execução retornou $rc2"; cat /tmp/install_out2.log; rm -rf "$TESTDIR"; exit 1; }

rm -rf "$TESTDIR"
echo "OK: §V.5.1"
```

**Verificações por inspeção:**
- [ ] **Mensagens em pt-BR** com símbolos `✓`/`✗`/`⚠` conforme `ARTIFACTS_SPEC.md` §0.6.
- [ ] **Mensagem final cita próximos passos**: invocar `/discover` (projeto existente) ou `/bootstrap` (projeto novo).
- [ ] **Não chama `git init`** (anti-decisão `SPEC.md` §3.9).
- [ ] **Não instala dependências, não baixa nada** (anti-decisão).

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados.

---

### §V.5.2 — README da raiz do framework

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/README.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §0.2 (frontmatter), §3.1–§3.3 (forma e idioma).
- `BUILD_PLAN.md` §F5.2.

**Verificações automatizáveis:**

```bash
FILE=~/Projetos/codeflow/README.md

# 1. Existe
test -f "$FILE" || { echo "FALHA: README.md ausente"; exit 1; }

# 2. Frontmatter universal
awk '
  /^---$/ { count++; if (count==2) exit }
  count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
  count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
  count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
  END { exit (v && s && a) ? 0 : 1 }
' "$FILE" || { echo "FALHA: frontmatter inválido"; exit 1; }

# 3. Tamanho dentro do alvo (40-80 linhas)
n=$(wc -l < "$FILE")
test "$n" -ge 40 && test "$n" -le 80 \
  || { echo "AVISO: tamanho $n linhas, alvo 40-80"; }

# 4. Referências internas ao andaime existem
for doc in andaime/SPEC.md andaime/ARTIFACTS_SPEC.md andaime/BUILD_PLAN.md; do
  grep -qF "$doc" "$FILE" \
    || { echo "FALHA: README não referencia $doc"; exit 1; }
  test -f ~/Projetos/codeflow/"$doc" \
    || { echo "FALHA: README referencia $doc mas arquivo não existe"; exit 1; }
done

# 5. Cita comando de instalação
grep -qE 'bash.*install\.sh|install\.sh' "$FILE" \
  || { echo "FALHA: README não cita install.sh"; exit 1; }

# 6. Cita próximos passos /discover ou /bootstrap
grep -qE '/discover|/bootstrap' "$FILE" \
  || { echo "FALHA: README não cita /discover ou /bootstrap"; exit 1; }

# 7. Sem palavras-fraca
! grep -iE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' "$FILE" \
  >/dev/null || { echo "AVISO: palavras-fraca presentes (README pode tolerar; verificar contexto)"; }

echo "OK: §V.5.2"
```

**Verificações por inspeção:**
- [ ] **README é introdução curta** (40-80 linhas), não tutorial completo.
- [ ] **Idioma pt-BR** consistente.
- [ ] **Estrutura coerente** com convenções de README (título, descrição, instalação, uso, links para docs).

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados.

---

### §V.5.3 — Integrar VALIDATION.md e PROMPTS.md ao andaime

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/andaime/VALIDATION.md`
- `~/Projetos/codeflow/andaime/PROMPTS.md`
- `~/Projetos/codeflow/andaime/README.md` (atualizado)

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §0.2 (frontmatter).
- `BUILD_PLAN.md` §F5.3.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow/andaime

# 1. Cinco arquivos do andaime presentes
for f in SPEC.md ARTIFACTS_SPEC.md BUILD_PLAN.md VALIDATION.md PROMPTS.md README.md; do
  test -f "$f" || { echo "FALHA: $f ausente"; exit 1; }
done

# 2. Frontmatter válido em VALIDATION.md e PROMPTS.md
for f in VALIDATION.md PROMPTS.md; do
  FILE="$f"
  awk '
    /^---$/ { count++; if (count==2) exit }
    count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
    count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
    count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
    END { exit (v && s && a) ? 0 : 1 }
  ' "$FILE" || { echo "FALHA: frontmatter inválido em $f"; exit 1; }
done

# 3. README.md não menciona "pendente" para VALIDATION ou PROMPTS
! grep -iE '(VALIDATION|PROMPTS).*pendente|pendente.*(VALIDATION|PROMPTS)' README.md \
  || { echo "FALHA: README ainda marca VALIDATION ou PROMPTS como pendente"; exit 1; }

echo "OK: §V.5.3"
```

**Verificações por inspeção:**
- [ ] `andaime/README.md` lista os cinco documentos sem marcações de pendência.

**Critério de aprovação:** snippet retorna zero; item de inspeção marcado.

---

### §V.5.4 — Criar projeto de teste

**Arquivo(s) validado(s):**
- Diretório do projeto de teste em `/tmp/codeflow-test/` (caminho fixo e vinculante; sem indireção).

**Regras aplicáveis:**
- `BUILD_PLAN.md` §F5.4.

**Verificações automatizáveis:**

```bash
# Caminho do projeto de teste — FIXO em /tmp/codeflow-test
TESTPROJ=/tmp/codeflow-test

# 1. Diretório existe
test -d "$TESTPROJ" || { echo "FALHA: projeto de teste $TESTPROJ ausente"; exit 1; }

# 2. É repositório git
test -d "$TESTPROJ/.git" || { echo "FALHA: $TESTPROJ não é repositório git"; exit 1; }

# 3. Makefile presente com targets canônicos
test -f "$TESTPROJ/Makefile" || { echo "FALHA: Makefile ausente"; exit 1; }
for target in check test lint typecheck; do
  grep -qE "^${target}:" "$TESTPROJ/Makefile" \
    || { echo "FALHA: target '$target' ausente no Makefile"; exit 1; }
done

# 4. Working tree limpo
test -z "$(cd "$TESTPROJ" && git status --porcelain)" \
  || { echo "FALHA: working tree do projeto de teste sujo"; exit 1; }

echo "OK: §V.5.4"
```

**Verificações por inspeção:**
- [ ] Projeto de teste é minimalista (não simula projeto real de produção). Suficiente apenas para exercitar `install.sh` e `discover`.

**Critério de aprovação:** snippet retorna zero; item de inspeção marcado.

---

### §V.5.5 — Executar `install.sh` no projeto de teste

**Arquivo(s) validado(s):**
- Estrutura `.codeflow/` no projeto de teste.

**Regras aplicáveis:**
- `SPEC.md` §3.9.
- `BUILD_PLAN.md` §F5.5.

**Verificações automatizáveis:**

```bash
TESTPROJ=/tmp/codeflow-test
cd "$TESTPROJ"

# 1. Estrutura .codeflow/ criada
test -f .codeflow/INDEX.md || { echo "FALHA: .codeflow/INDEX.md ausente"; exit 1; }
test -d .codeflow/decisions || { echo "FALHA: .codeflow/decisions/ ausente"; exit 1; }
test -d .codeflow/checkpoints || { echo "FALHA: .codeflow/checkpoints/ ausente"; exit 1; }

# 2. INDEX.md é placeholder (ainda não tem conteúdo real — isso vem com /discover)
grep -qE 'Placeholder|placeholder' .codeflow/INDEX.md \
  || { echo "AVISO: INDEX.md já tem conteúdo (esperado placeholder até /discover rodar)"; }

# 3. .gitignore atualizado
grep -qE '\.codeflow/checkpoints' .gitignore \
  || { echo "FALHA: .gitignore sem .codeflow/checkpoints/"; exit 1; }

# 4. Nenhum arquivo fora de .codeflow/ e .gitignore foi modificado
# (Verificação relativa: apenas .codeflow/ e .gitignore devem aparecer como mudanças não-commitadas)
unexpected=$(git status --porcelain | grep -vE '^\?\? \.codeflow/|^\?\? \.gitignore|^ M \.gitignore' || true)
test -z "$unexpected" \
  || { echo "FALHA: arquivos inesperados modificados:"; echo "$unexpected"; exit 1; }

# 5. Constitution, manifest, discovered NÃO criados (esses dependem de /discover)
test ! -f .codeflow/constitution.md || { echo "FALHA: constitution.md criado prematuramente (install.sh anti-decisão)"; exit 1; }
test ! -f .codeflow/manifest.md || { echo "FALHA: manifest.md criado prematuramente"; exit 1; }
test ! -f .codeflow/discovered.md || { echo "FALHA: discovered.md criado prematuramente"; exit 1; }

# 6. Segunda execução é idempotente
bash ~/.codeflow/install.sh >/tmp/install2.log 2>&1
rc=$?
test "$rc" -eq 0 || { echo "FALHA: segunda execução retornou $rc"; cat /tmp/install2.log; exit 1; }

echo "OK: §V.5.5"
```

**Verificações por inspeção:**
- [ ] **Saída do `install.sh`** lista verificações com símbolos `✓`/`⚠` e termina com mensagem de próximos passos.

**Critério de aprovação:** snippet retorna zero; item de inspeção marcado.

---

### §V.5.6 — Exercitar `discover` (simulado) no projeto de teste

**Arquivo(s) validado(s):**
- `.codeflow/INDEX.md` (atualizado)
- `.codeflow/constitution.md`
- `.codeflow/manifest.md`
- `.codeflow/discovered.md`

**Regras aplicáveis:**
- `ARTIFACTS_SPEC.md` §2.1.6 (INDEX), §2.2.6 (constitution), §2.3.6 (manifest), §2.4.6 (discovered).
- `BUILD_PLAN.md` §F5.6.

**Verificações automatizáveis:**

```bash
TESTPROJ=/tmp/codeflow-test
cd "$TESTPROJ"

# 1. Quatro artefatos presentes
for f in INDEX.md constitution.md manifest.md discovered.md; do
  test -f ".codeflow/$f" || { echo "FALHA: .codeflow/$f ausente"; exit 1; }
done

# 2. INDEX.md NÃO é mais placeholder
! grep -qE 'Placeholder' .codeflow/INDEX.md \
  || { echo "FALHA: INDEX.md ainda é placeholder após /discover"; exit 1; }

# 3. INDEX.md tem schema_version (§2.1.6 regra 1)
awk '/^---$/{c++} c==1 && /^schema_version:/{found=1} c==2{exit} END{exit found?0:1}' \
  .codeflow/INDEX.md \
  || { echo "FALHA: INDEX.md sem schema_version no frontmatter"; exit 1; }

# 4. constitution.md tem campo projeto (§2.2.6 regra 1)
awk '/^---$/{c++} c==1 && /^projeto:/{found=1} c==2{exit} END{exit found?0:1}' \
  .codeflow/constitution.md \
  || { echo "FALHA: constitution.md sem campo 'projeto'"; exit 1; }

# 5. manifest.md tem validation_hash em formato hex 64 chars (§2.3.6 regra 1)
hash=$(awk '/^---$/{c++} c==1 && /^validation_hash:/{print $2} c==2{exit}' .codeflow/manifest.md)
echo "$hash" | grep -qE '^[a-f0-9]{64}$' \
  || { echo "FALHA: validation_hash inválido em manifest.md (obtido: $hash)"; exit 1; }

# 5b. validation_hash recalculado pela fórmula canônica de ARTIFACTS_SPEC §2.3.3
# (cat <arquivos> 2>/dev/null | sha256sum | cut -d' ' -f1) bate com o registrado
# no frontmatter. Arquivos extraídos da seção "## Arquivos críticos para freshness"
# do próprio manifest, na ordem literal declarada.
arquivos_freshness=$(awk '/^## Arquivos críticos para freshness/,/^## /' .codeflow/manifest.md \
  | grep -E '^- `' | sed -E 's/^- `([^`]+)`.*/\1/')
if [ -n "$arquivos_freshness" ]; then
  # shellcheck disable=SC2086
  hash_recalc=$(cat $arquivos_freshness 2>/dev/null | sha256sum | cut -d' ' -f1)
  test "$hash_recalc" = "$hash" \
    || { echo "FALHA: validation_hash registrado ($hash) difere do recalculado ($hash_recalc)"; exit 1; }
fi

# 6. discovered.md tem meta_skill: discover (§2.4.6 regra 1)
awk '/^---$/{c++} c==1 && /^meta_skill: discover$/{found=1} c==2{exit} END{exit found?0:1}' \
  .codeflow/discovered.md \
  || { echo "FALHA: discovered.md sem meta_skill: discover"; exit 1; }

# 7. INDEX.md cita constitution.md e manifest.md
for ref in constitution.md manifest.md; do
  grep -qF "$ref" .codeflow/INDEX.md \
    || { echo "FALHA: INDEX.md não cita $ref"; exit 1; }
done

# 8. Todos os artefatos têm encoding UTF-8
for f in INDEX.md constitution.md manifest.md discovered.md; do
  file ".codeflow/$f" | grep -q 'UTF-8' \
    || { echo "FALHA: $f não é UTF-8"; exit 1; }
done

echo "OK: §V.5.6"
```

**Verificações por inspeção:**
- [ ] **Constitution gerada coerente com o projeto de teste**: stack declarada corresponde ao que o projeto realmente tem (Makefile mínimo, sem outras dependências).
- [ ] **Manifest reflete inspeção real**: `## Stack identificada` lista o que existe; `## Comandos make canônicos` mapeia os 4 targets canônicos do Makefile minimal.
- [ ] **Discovered registra inspeção e hipóteses** com rótulos `[confirmada]`/`[refutada]`/`[pendente]`.
- [ ] **No máximo 5 perguntas** em `## Perguntas feitas ao usuário e respostas` no discovered.

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados.

---

### §V.5.7 — Documentar wiring de slash commands em SPEC e ARTIFACTS_SPEC

**Arquivo(s) validado(s):**
- `andaime/SPEC.md` (subseção §3.6.1 acrescentada).
- `andaime/ARTIFACTS_SPEC.md` (subseção §1.11 acrescentada).
- `framework/core/glossary.md` (entrada "Wrapper" acrescentada).

**Regras aplicáveis:**
- `BUILD_PLAN.md` §F5.7.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow

# 1. SPEC.md §3.6.1 presente
grep -qE '^#### 3\.6\.1 Implementação em Claude Code' andaime/SPEC.md \
  || { echo "FALHA: SPEC.md §3.6.1 ausente"; exit 1; }

# 2. SPEC §3.6.1 cita ~/.claude/commands/
awk '/^#### 3\.6\.1/{flag=1; next} /^#### /{flag=0} flag' andaime/SPEC.md \
  | grep -qE '~/\.claude/commands' \
  || { echo "FALHA: SPEC.md §3.6.1 não documenta ~/.claude/commands/"; exit 1; }

# 3. SPEC §3.6.1 cita .claude/commands/ de projeto
awk '/^#### 3\.6\.1/{flag=1; next} /^#### /{flag=0} flag' andaime/SPEC.md \
  | grep -qE '<projeto>/\.claude/commands|\.claude/commands.*projeto' \
  || { echo "FALHA: SPEC.md §3.6.1 não documenta wrapper de projeto"; exit 1; }

# 4. ARTIFACTS_SPEC.md §1.11 presente
grep -qE '^### 1\.11 Wrappers de slash command' andaime/ARTIFACTS_SPEC.md \
  || { echo "FALHA: ARTIFACTS_SPEC.md §1.11 ausente"; exit 1; }

# 5. §1.11 contém exemplo preenchido para /bugfix
awk '/^### 1\.11 /{flag=1; next} /^### /{flag=0} flag' andaime/ARTIFACTS_SPEC.md \
  | grep -qE 'bugfix' \
  || { echo "FALHA: ARTIFACTS_SPEC.md §1.11 sem exemplo /bugfix"; exit 1; }

# 6. Glossary contém entrada "Wrapper"
grep -qE '^### Wrapper' framework/core/glossary.md \
  || { echo "AVISO: glossary sem entrada 'Wrapper' — documentar omissão se intencional"; }

echo "OK: §V.5.7"
```

**Verificações por inspeção:**
- [ ] SPEC §3.6.1 cobre os cinco pontos: mecanismo, mapeamento, conteúdo do wrapper, setup universal (F5.8), setup de projeto (F5.9).
- [ ] ARTIFACTS_SPEC §1.11 cobre localização, schema, exemplo, validação, anti-padrão.

**Critério de aprovação:** snippet retorna zero (item 6 é AVISO, não FALHA); itens de inspeção marcados.

---

### §V.5.8 — Criar `setup-slash-commands.sh` e auto-sync em meta-skills

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/setup-slash-commands.sh` (executável).
- `framework/meta/create-workflow/SKILL.md` (atualizado).
- `~/.claude/commands/<nome>.md` (wrappers gerados).

**Regras aplicáveis:**
- `BUILD_PLAN.md` §F5.8.
- `ARTIFACTS_SPEC.md` §3.9.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow

# 1. Script existe e é executável
test -x setup-slash-commands.sh \
  || { echo "FALHA: setup-slash-commands.sh ausente ou não-executável"; exit 1; }

# 2. Roda sem erro
bash setup-slash-commands.sh >/tmp/sscmd1.log 2>&1
rc=$?
test "$rc" -eq 0 \
  || { echo "FALHA: setup-slash-commands.sh retornou $rc"; cat /tmp/sscmd1.log; exit 1; }

# 3. Wrapper criado para cada workflow universal
for f in framework/library/workflows/*.md; do
  name=$(basename "$f" .md)
  test -f "$HOME/.claude/commands/$name.md" \
    || { echo "FALHA: wrapper ~/.claude/commands/$name.md ausente"; exit 1; }
done

# 4. Wrapper criado para cada meta-skill seed
for d in framework/meta/*/; do
  name=$(basename "$d")
  test -f "$HOME/.claude/commands/$name.md" \
    || { echo "FALHA: wrapper ~/.claude/commands/$name.md (meta) ausente"; exit 1; }
done

# 5. Idempotência: segunda execução retorna 0
bash setup-slash-commands.sh >/tmp/sscmd2.log 2>&1
rc=$?
test "$rc" -eq 0 \
  || { echo "FALHA: segunda execução retornou $rc"; cat /tmp/sscmd2.log; exit 1; }

# 6. create-workflow/SKILL.md referencia setup-slash-commands.sh
grep -qE 'setup-slash-commands\.sh' framework/meta/create-workflow/SKILL.md \
  || { echo "FALHA: create-workflow não referencia setup-slash-commands.sh"; exit 1; }

# 7. Wrapper aponta para path correto (cita o arquivo real)
sample=$(ls ~/.claude/commands/*.md 2>/dev/null | head -1)
if [ -n "$sample" ]; then
  grep -qE '~/\.codeflow/framework/' "$sample" \
    || { echo "FALHA: wrapper $sample não referencia ~/.codeflow/framework/"; exit 1; }
fi

echo "OK: §V.5.8"
```

**Verificações por inspeção:**
- [ ] Saída do script lista cada wrapper com símbolo (`✓ criado`, `✓ preservado`, `⚠ órfão`).
- [ ] `create-workflow/SKILL.md` instrui claramente quando rodar o script (após criar workflow universal).

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados.

---

### §V.5.9 — Estender `install.sh` para slash commands de projeto + atualizar ROTEIRO

**Arquivo(s) validado(s):**
- `~/Projetos/codeflow/install.sh` (estendido).
- `andaime/tests/ROTEIRO.md` (ampliado).

**Regras aplicáveis:**
- `BUILD_PLAN.md` §F5.9.
- `SPEC.md` §3.9 (anti-decisão preservada).

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow

# 1. install.sh menciona .claude/commands/
grep -qE '\.claude/commands' install.sh \
  || { echo "FALHA: install.sh não menciona .claude/commands/"; exit 1; }

# 2. install.sh menciona .codeflow/workflows
grep -qE '\.codeflow/workflows' install.sh \
  || { echo "FALHA: install.sh não sincroniza .codeflow/workflows/"; exit 1; }

# 3. install.sh continua executável
test -x install.sh || { echo "FALHA: install.sh perdeu execução"; exit 1; }

# 4. Idempotência preservada: rodar 2x em pasta de teste limpa
TMP=$(mktemp -d)
cd "$TMP"
git init -q
echo ".PHONY: check"$'\n'"check:"$'\n\t'"@true" > Makefile
git add Makefile && git -c user.email=t@t -c user.name=t commit -q -m init

bash ~/Projetos/codeflow/install.sh >/tmp/inst1.log 2>&1
rc1=$?
bash ~/Projetos/codeflow/install.sh >/tmp/inst2.log 2>&1
rc2=$?
test "$rc1" -eq 0 -a "$rc2" -eq 0 \
  || { echo "FALHA: install.sh não-idempotente (rc1=$rc1 rc2=$rc2)"; exit 1; }

# 5. Nenhum arquivo do projeto fora de .codeflow/, .gitignore, .claude/commands/ modificado
unexpected=$(cd "$TMP" && git status --porcelain \
  | grep -vE '^\?\? \.codeflow/|^\?\? \.gitignore|^ M \.gitignore|^\?\? \.claude/' || true)
test -z "$unexpected" \
  || { echo "FALHA: install.sh violou SPEC §3.9: $unexpected"; exit 1; }

cd ~/Projetos/codeflow
rm -rf "$TMP"

# 6. ROTEIRO.md contém Teste 1.5
grep -qE 'Teste 1\.5' andaime/tests/ROTEIRO.md \
  || { echo "FALHA: ROTEIRO.md sem Teste 1.5"; exit 1; }

# 7. ROTEIRO.md contém Teste 7
grep -qE '^## Teste 7' andaime/tests/ROTEIRO.md \
  || { echo "FALHA: ROTEIRO.md sem Teste 7"; exit 1; }

echo "OK: §V.5.9"
```

**Verificações por inspeção:**
- [ ] `install.sh` mantém saída em pt-BR com símbolos `✓`/`⚠`/`✗`.
- [ ] `install.sh` não força adicionar `.claude/commands/` ao `.gitignore` do projeto (decisão fica com mantenedor).

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados.

---

### §V.5.10 — Limpeza, log de execução e tag de versão

**Arquivo(s) validado(s):**
- Tag git `v1.0.0` no repositório do framework.
- `andaime/EXECUTION_LOG.md` (obrigatório).

**Regras aplicáveis:**
- `BUILD_PLAN.md` §F5.10.

**Verificações automatizáveis:**

```bash
cd ~/Projetos/codeflow

# 1. Tag v1.0.0 presente
git tag -l v1.0.0 | grep -q v1.0.0 \
  || { echo "FALHA: tag v1.0.0 ausente"; exit 1; }

# 2. Working tree limpo
test -z "$(git status --porcelain)" \
  || { echo "FALHA: working tree sujo no encerramento"; exit 1; }

# 3. Mensagem da tag não é vazia
msg=$(git tag -l -n99 v1.0.0)
test -n "$msg" \
  || { echo "FALHA: tag v1.0.0 sem mensagem"; exit 1; }

# 4. EXECUTION_LOG.md OBRIGATÓRIO, com frontmatter válido e título canônico
FILE=andaime/EXECUTION_LOG.md
test -f "$FILE" || { echo "FALHA: EXECUTION_LOG.md ausente (obrigatório)"; exit 1; }
awk '
  /^---$/ { count++; if (count==2) exit }
  count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
  count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
  count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
  END { exit (v && s && a) ? 0 : 1 }
' "$FILE" || { echo "FALHA: EXECUTION_LOG.md sem frontmatter válido"; exit 1; }
grep -q '^# Execução do BUILD_PLAN — log incremental$' "$FILE" \
  || { echo "FALHA: EXECUTION_LOG.md sem título canônico"; exit 1; }

# 5. Decisão sobre projeto de teste registrada (deletado ou arquivado)
TESTPROJ=/tmp/codeflow-test
if [ -d "$TESTPROJ" ]; then
  test -d ~/Projetos/codeflow/exemplos/projeto-teste 2>/dev/null \
    || echo "AVISO: $TESTPROJ ainda existe e não foi arquivado em exemplos/"
fi

# 6. Pelo menos um commit por etapa que declara "Commit sugerido" não-vazio.
# Critério qualitativo: ≈14 commits esperados (varia conforme execução real).
# Verificação mínima: contagem de commits antes da tag deve ser >= 10.
n_commits=$(git rev-list --count v1.0.0)
test "$n_commits" -ge 13 \
  || { echo "FALHA: apenas $n_commits commits até v1.0.0 (esperado pelo menos 13, idealmente ~17 com F5.7-F5.9)"; exit 1; }

echo "OK: §V.5.10"
```

**Verificações por inspeção:**
- [ ] **Pelo menos um commit por etapa do BUILD_PLAN que declara `Commit sugerido` não-vazio** (tipicamente ~17 commits no total, incluindo F5.7-F5.9) antes da tag `v1.0.0`. A contagem exata depende de quantas etapas justificaram commit próprio na execução real; não há número rígido.
- [ ] **Mensagens de commit seguem o padrão** `<tipo>(<escopo>): <mensagem>` declarado no BUILD_PLAN.

**Critério de aprovação:** snippet retorna zero; itens de inspeção marcados.

---

## Parte 2 — Validações transversais

Esta parte agrupa validações que cruzam múltiplos arquivos ou aplicam regras gerais (`ARTIFACTS_SPEC.md` Parte 3). Devem ser executadas:

- Ao fim de cada fase do BUILD_PLAN, como sanity check antes de seguir para a próxima fase.
- Antes da criação da tag `v1.0.0` em §V.5.7.
- Manualmente, sempre que o mantenedor suspeita de drift entre arquivos.

### §V.T.1 — Forma de todos os arquivos `.md`

**Escopo:** todos os `.md` em `framework/`, `andaime/`, e raiz do repositório.

**Regras aplicáveis:** `ARTIFACTS_SPEC.md` §3.1 (regras 1–5).

```bash
cd ~/Projetos/codeflow

falhas=0
while IFS= read -r f; do
  # Pular .gitkeep e SKILL.md vazios eventualmente em construção
  test -s "$f" || continue

  # Encoding UTF-8
  if ! file "$f" | grep -q 'UTF-8'; then
    echo "FALHA encoding: $f"
    falhas=$((falhas+1))
  fi

  # Sem CRLF
  if grep -lU $'\r' "$f" >/dev/null 2>&1; then
    echo "FALHA CRLF: $f"
    falhas=$((falhas+1))
  fi

  # Trailing newline
  if [ "$(tail -c 1 "$f" | xxd -p)" != "0a" ]; then
    echo "FALHA trailing newline: $f"
    falhas=$((falhas+1))
  fi
done < <(find . -type f -name '*.md' -not -path './.git/*')

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.T.1 — forma OK em todos os .md"
else
  echo "FALHA: §V.T.1 — $falhas problema(s) de forma"
  exit 1
fi
```

---

### §V.T.2 — Frontmatter universal em todos os artefatos

**Escopo:** todos os `.md` exceto checkpoints (que têm template específico em `ARTIFACTS_SPEC.md` §2.7.3) e `.gitkeep`.

**Regras aplicáveis:** `ARTIFACTS_SPEC.md` §3.2 (regras 6–12).

```bash
cd ~/Projetos/codeflow

falhas=0
while IFS= read -r f; do
  test -s "$f" || continue

  # Pular checkpoints
  case "$f" in
    *.codeflow/checkpoints/*) continue ;;
  esac

  FILE="$f"
  if ! awk '
    /^---$/ { count++; if (count==2) exit }
    count==1 && /^versão: [0-9]+\.[0-9]+$/ { v=1 }
    count==1 && /^status: (estável|experimental|deprecated)$/ { s=1 }
    count==1 && /^atualizado: [0-9]{4}-[0-9]{2}-[0-9]{2}$/ { a=1 }
    END { exit (v && s && a) ? 0 : 1 }
  ' "$FILE"; then
    echo "FALHA frontmatter: $FILE"
    falhas=$((falhas+1))
  fi
done < <(find . -type f -name '*.md' -not -path './.git/*')

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.T.2 — frontmatter OK em todos os artefatos"
else
  echo "FALHA: §V.T.2 — $falhas arquivo(s) com frontmatter inválido"
  exit 1
fi
```

---

### §V.T.3 — Ausência de palavras-fraca

**Escopo:** todos os `.md` do framework (não do andaime — andaime é meta-documentação e pode tolerar nuance).

**Regras aplicáveis:** `ARTIFACTS_SPEC.md` §3.5 regra 20.

```bash
cd ~/Projetos/codeflow

if grep -irlE 'preferencialmente|recomendado|sugere-se|pode considerar|idealmente' framework/ 2>/dev/null; then
  echo "FALHA: §V.T.3 — palavras-fraca presentes nos arquivos acima"
  exit 1
fi
echo "OK: §V.T.3 — ausência de palavras-fraca em framework/"
```

---

### §V.T.4 — Sem marcadores TODO/FIXME/XXX

**Escopo:** todos os arquivos do framework e do andaime.

**Regras aplicáveis:** `ARTIFACTS_SPEC.md` §3.10 regra 38.

```bash
cd ~/Projetos/codeflow

if grep -rE '\b(TODO|FIXME|XXX)\b' framework/ andaime/ 2>/dev/null; then
  echo "FALHA: §V.T.4 — marcadores TODO/FIXME/XXX presentes"
  exit 1
fi
echo "OK: §V.T.4 — sem marcadores TODO/FIXME/XXX"
```

---

### §V.T.5 — Sem caminhos absolutos hardcoded

**Escopo:** todos os `.md` e `.sh` em `framework/`.

**Regras aplicáveis:** `ARTIFACTS_SPEC.md` §3.10 regra 36.

```bash
cd ~/Projetos/codeflow

# Detectar /home/, /Users/, ou caminho absoluto começando com / em arquivos do framework
# Exceções: linhas de comentário começando com #, e referências dentro de blocos de código
# Heurística simples: relata e deixa para inspeção humana decidir

suspeitos=$(grep -rEn '(^|[^`])(/home/|/Users/)' framework/ 2>/dev/null | grep -v '^[^:]*:[^:]*:#' || true)
if [ -n "$suspeitos" ]; then
  echo "AVISO: §V.T.5 — possíveis caminhos absolutos detectados:"
  echo "$suspeitos"
  echo "Inspeção manual necessária. Caminhos absolutos legítimos: nenhum (sempre usar ~/.codeflow/ ou caminho relativo)."
  exit 1
fi
echo "OK: §V.T.5 — sem caminhos absolutos hardcoded"
```

---

### §V.T.6 — Referências `LEIA TAMBÉM` apontam para arquivos existentes

**Escopo:** todos os workflows e meta-skills que têm seção `## LEIA TAMBÉM`.

**Regras aplicáveis:** `ARTIFACTS_SPEC.md` §1.5.6 regra 5, §1.6.6 regra 6.

```bash
cd ~/Projetos/codeflow

falhas=0
while IFS= read -r workflow; do
  # Extrair conteúdo da seção LEIA TAMBÉM
  refs=$(awk '/^## LEIA TAMBÉM$/,/^## /' "$workflow" \
         | grep -E '^- ' \
         | sed -E 's/^- //;s/ .*//')

  while IFS= read -r ref; do
    [ -z "$ref" ] && continue

    # Resolver caminhos:
    # ~/.codeflow/... → ~/Projetos/codeflow/...
    # .codeflow/... → caminho relativo ao projeto-alvo (não validável aqui; pular)
    case "$ref" in
      ~/.codeflow/*)
        path="${ref/#~\/.codeflow/$HOME/Projetos/codeflow}"
        # Resolver SKILL.md em pastas
        if [ ! -f "$path" ]; then
          echo "FALHA: $workflow referencia $ref mas $path não existe"
          falhas=$((falhas+1))
        fi
        ;;
      .codeflow/*)
        # Referências a artefatos de projeto não são validáveis no framework
        :
        ;;
    esac
  done <<< "$refs"
done < <(find framework -type f -name '*.md')

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.T.6 — referências LEIA TAMBÉM resolvem"
else
  echo "FALHA: §V.T.6 — $falhas referência(s) quebrada(s)"
  exit 1
fi
```

---

### §V.T.7 — Stack permitida em scripts

**Escopo:** todos os `.sh` em `framework/` e na raiz.

**Regras aplicáveis:** `ARTIFACTS_SPEC.md` §3.8 regra 27.

```bash
cd ~/Projetos/codeflow

proibidos='\b(jq|yq|python|python3|node|npm|yarn|go|cargo|docker|podman|pbcopy|xclip)\b'
falhas=0
while IFS= read -r script; do
  if grep -qE "$proibidos" "$script"; then
    echo "FALHA: $script usa ferramenta fora da stack permitida"
    grep -nE "$proibidos" "$script" | head -3
    falhas=$((falhas+1))
  fi
done < <(find . -type f -name '*.sh' -not -path './.git/*')

if [ "$falhas" -eq 0 ]; then
  echo "OK: §V.T.7 — stack permitida respeitada"
else
  echo "FALHA: §V.T.7 — $falhas script(s) com ferramenta proibida"
  exit 1
fi
```

---

### §V.T.8 — Suite completa (gate de release)

**Escopo:** consolidação de §V.T.1 a §V.T.7 mais validações por etapa relevantes.

**Quando executar:** antes de criar a tag `v1.0.0` (§V.5.7).

```bash
cd ~/Projetos/codeflow

echo "==== Suite transversal completa ===="
echo

# Verificação adicional: pelo menos um commit por etapa com Commit sugerido não-vazio.
# Critério qualitativo (≈14 commits). Aviso, não erro, se abaixo do mínimo.
n_commits=$(git log --oneline | wc -l)
if [ "$n_commits" -lt 10 ]; then
  echo "AVISO: histórico tem $n_commits commits (esperado ao menos um por etapa com Commit sugerido — ≈14)"
fi

echo
echo "==== Suite transversal: execute manualmente §V.T.1 a §V.T.7 ===="
```

**Nota:** a consolidação plena (um único script orquestrador que invoca os snippets de §V.T.1 a §V.T.7 em sequência) é deliberadamente deixada para evolução futura, conforme decisão registrada no preâmbulo deste documento (§0.6). Por ora, a "suite" é o conjunto manual das seções §V.T.1 a §V.T.7.

---

---

## Fim do VALIDATION.md
