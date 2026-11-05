---
versão: 1.0
status: experimental
atualizado: 2026-11-05
descrição: Checklist do auditor de enxugar — candidatos a remoção por ferramenta determinística, confirmação de cada um e plano de lotes pequenos de remoção.
---

# Skill: audit-enxugar

## Quando usar

Carregada pelo `/audit` quando a dimensão é `enxugar`: listar e confirmar o que o código **já existente**
carrega sem uso — dependências, arquivos órfãos, exports — e onde ele se repete ou se complica demais, com
linha de base e plano de lotes. Carregada também pelo `/refactor`, em modo puro, quando o pedido é **um
lote** de um laudo `enxugar` aprovado no consolidado: aí valem só o passo 5 e as proibições.

Aplica-se a projeto JS/TS, onde `knip` e `eslint` existem; em outra stack, só o `jscpd` e o equivalente
que o projeto já tiver, ou a dimensão sai `[—]` no laudo.

## Princípio guia

A ferramenta lista, o agente confirma, o lote pequeno remove, e o teste decide. Candidato sem confirmação
contra o código real não sai do repositório, e remoção sem rede verde não entra.

## Protocolo

### 1. Réguas e fronteira
- Régua: `~/.codeflow/framework/core/rules/code-quality.md`, as rules de código do projeto e as ADRs que
  declaram entrada, export público ou código mantido de propósito.
- Fronteira com `code-quality`: lá entra o candidato avulso de qualidade (erro engolido, tipagem frouxa,
  valor mágico); aqui entra o **inventário de remoção** com contagem e lote. Fronteira com `dependencies`:
  lá entram versão, manutenção, licença e CVE; aqui só a dependência declarada **sem uso**. O que aparecer
  nas duas dimensões na mesma rodada o `/verify-audit` deduplica (Passo 2).

### 2. Ferramentas, só como relatório
- Rodar só o que o projeto já tem instalado, pelo executor do próprio projeto e sem baixar nada:
  `npx --no-install <ferramenta>`, `pnpm exec <ferramenta>` ou `yarn <ferramenta>`. Ferramenta ausente
  vira `[—]` na seção 3 do laudo, com o comando que o dono roda se quiser instalá-la.
- Saída bruta num diretório temporário **fora** do repositório (`T=$(mktemp -d)`), apagado no fim.
- **knip** (arquivos, exports e dependências sem uso):
  - `knip --reporter json > "$T/knip.json"` no repositório inteiro; `--workspace <pacote>` para um pacote
    de monorepo.
  - `knip --production` para achar o que nenhuma entrada de produção usa (teste e script de dev ficam de
    fora).
  - Por categoria, para montar os lotes: `knip --dependencies`, `knip --files`, `knip --exports`.
- **jscpd** (duplicação): `jscpd <pasta-do-pacote> --min-lines 8 --reporters json --output "$T/jscpd"`;
  ajustar `--min-lines` no primeiro uso e registrar o valor escolhido.
- **eslint** (complexidade), como ranking, com as regras na linha de comando e o resultado em JSON:
  `eslint <pasta> --rule 'complexity: [warn, 10]' --rule 'max-depth: [warn, 4]'
  --rule 'max-lines-per-function: [warn, 80]' --format json > "$T/eslint.json"`. As regras do
  `eslint-plugin-sonarjs` (`cognitive-complexity`, `no-identical-functions`) só entram se o projeto já tem
  o plugin.

### 3. Linha de base, por pacote
- Registrar na seção 3 do laudo, por pacote: linhas de código; contagem do `knip` por tipo (dependências,
  devDependencies, arquivos, exports, tipos); porcentagem de duplicação do `jscpd`; e as 20 funções mais
  complexas, com `arquivo:linha` e o valor.
- A rodada seguinte compara com estes números. A dimensão se encerra quando duas rodadas seguidas não
  trazem candidato "remover agora" na mesma área.

### 4. Confirmar cada candidato contra o código real
- Para cada item da ferramenta, conferir antes de propor a remoção:
  - **uso dinâmico:** o nome aparece em string, arquivo de config, reflexão, import dinâmico ou rota por
    convenção de pasta;
  - **dependência fora do código:** scripts do `package.json`, CI, config da ferramenta de build, de teste
    ou de deploy usam o pacote;
  - **export público:** o export pertence a pacote consumido por outro pacote, app ou repositório;
  - **entrada por convenção:** handler, worker, plugin ou comando carregado pelo nome;
  - **cliente antigo:** código de migração, sync ou versão de schema que só roda em cliente desatualizado
    (app com sync offline, por exemplo) — esse **nunca** sai por "não ter uso".
- Cada candidato termina numa de quatro classes: **remover agora**, **extrair helper** (duplicação),
  **simplificar** (complexidade) ou **deixar**.
- O "deixar" leva o motivo em uma frase e vira entrada proposta da config de ignorar —
  `knip.json` (`ignore`, `ignoreDependencies`, `entry`) ou `.jscpd.json` (`ignore`) —, para não voltar na
  rodada seguinte.

### 5. Plano de lotes e execução do lote
- Cada candidato confirmado leva, no destino proposto da seção 4 do laudo, o seu **lote**: uma categoria e
  um pacote por lote, até ~300 linhas removidas ou ~20–30 itens.
- Ordem dos lotes, do mais seguro ao mais arriscado: dependências → arquivos órfãos → exports →
  duplicação → complexidade. O **lote 0** de cada pacote é a config de ignorar, com as entradas do "deixar".
- Execução de cada lote, já fora do `/audit`: um `/refactor` em modo **puro**, com o lote aprovado no
  consolidado como escopo, e um PR só daquele lote.
  - Rede: o typecheck, os testes e o build do manifest do projeto, verdes antes do primeiro toque e depois
    de cada passo; parar no primeiro vermelho.
  - Área sem cobertura de teste não remove nem reescreve sem antes ganhar teste de caracterização.
  - Nos lotes que reescrevem código (duplicação e complexidade), rodar `/simplify` sobre o diff no fim,
    quando a ferramenta de IA o oferece; senão, `[—]` no relatório. Os lotes só de remoção não rodam
    `/simplify`.

### 6. Severidade e destino
- **Baixa** por padrão: dependência, arquivo ou export sem uso.
- **Média:** duplicação que já divergiu entre as cópias, ou complexidade que esconde bug provável.
- Destino: **melhoria**, já com o lote.

## Proibições durante esta skill

- Não instalar nem baixar ferramenta, nem pelo `npx` sem `--no-install`.
- Não rodar `--fix`, `--fix-type`, `--allow-remove-files` nem qualquer autofix.
- Não alterar código durante o `/audit`: a remoção é do `/refactor`, lote a lote.
- Não remover código de migração, sync ou versão de schema por falta de uso.
- Não misturar categorias nem pacotes num mesmo lote.
- Não afrouxar, apagar ou "consertar" teste para o lote passar.

## Saídas válidas

- Lista de candidatos confirmados, cada um com `arquivo:linha`, classe, evidência da confirmação,
  severidade, destino e lote propostos, para o laudo da dimensão.
- Linha de base por pacote, para a seção de ferramentas do laudo, com os comandos rodados ou `[—]`.
- Entradas propostas para a config de ignorar, com o motivo de cada uma, como conteúdo do lote 0.
