---
versão: 1.0
status: estável
atualizado: 2026-06-25
descrição: Protocolo para tornar as decisões visuais sistemáticas — espaçamento, tipografia, cor e hierarquia derivados de uma escala, não escolhidos a esmo.
---

# Skill: visual-consistency

## Quando usar

Workflows devem carregar esta skill quando o passo cria ou altera mais de um elemento visual que precisa conviver na mesma interface (telas, conjunto de componentes, página). Ajuste de um único valor isolado pode omitir.

## Princípio guia

Valor arbitrário é o que faz uma interface parecer remendada: um padding de 13px aqui, 17px ali, três tons de cinza quase iguais. Sistema resolve isso na raiz — quando tudo deriva de uma escala, consistência vira o caminho de menor esforço, não disciplina manual.

## Protocolo

### 1. Identificar (ou estabelecer) as escalas
- Localizar no projeto as escalas vigentes: espaçamento (ex: 4/8/12/16/24/32…), tipografia (tamanhos e pesos), cores (tokens semânticos: superfície, texto, borda, marca, estados) e raios/sombras. Se não existem, propor uma escala mínima antes de seguir — decisão ad hoc sem escala vira dívida.

### 2. Conferir espaçamento contra a escala
- Percorrer paddings, margins e gaps. Cada valor fora da escala vira um item para alinhar ao degrau mais próximo, salvo razão explícita (ex: alinhamento óptico).

### 3. Conferir tipografia
- Tamanhos e pesos saem da escala tipográfica, não de números soltos. Confirmar ritmo vertical coerente (line-height proporcional) e que não há mais níveis de tamanho do que a hierarquia precisa.

### 4. Conferir cor por token semântico
- Cada cor usada referencia um token de papel (texto, superfície, borda, estado), não um hex cravado no componente. Marcar hex solto e tons quase-duplicados (dois cinzas a 2% de distância) para consolidar.

### 5. Conferir hierarquia
- Em cada tela, confirmar que existe um único elemento primário óbvio e que a ordem de leitura (tamanho, peso, espaço, cor) reflete a importância real. Tudo com o mesmo peso = nenhuma hierarquia.

## Proibições durante esta skill

- Não introduzir valor fora da escala sem razão registrada.
- Não cravar hex direto no componente quando existe (ou cabe) token semântico.
- Não criar um quarto tom de cinza quase igual aos três existentes — consolidar.
- Não deixar dois ou mais elementos disputando o papel de primário na mesma tela.

## Saídas válidas

- **Lista de desvios** no formato `local — valor encontrado — degrau/token da escala que deveria usar`.
- **Resumo de escalas** quando a interface não tinha sistema: as escalas mínimas propostas (espaçamento, tipografia, cor) que passam a reger os elementos tocados.
