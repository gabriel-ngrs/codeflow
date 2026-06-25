---
versão: 1.0
status: estável
atualizado: 2026-06-25
descrição: Protocolo para tirar a "cara de IA" de uma interface — escolhas deliberadas em vez do centro estatístico do design.
---

# Skill: avoid-ai-look

## Quando usar

Workflows devem carregar esta skill quando o passo produz ou altera interface gráfica (componentes, telas, layout, CSS, e-mails HTML). Passos que tocam só backend, dados ou infra podem omitir.

## Princípio guia

Modelo sem direção converge para o centro estatístico do design e entrega a mesma cara genérica que todo mundo reconhece como "feito por IA". Fugir disso não é talento, é decisão: escolher cada fonte, cor e espaçamento por uma razão, não por ser o default.

## Protocolo

### 1. Identificar o contexto antes de decorar
- Antes de escolher estética, declarar em uma linha: público, tom (sério/lúdico/técnico) e uma referência concreta de produto que serve de norte. Sem isso, qualquer escolha vira default.

### 2. Caçar os sinais de "cara de IA" no que foi produzido
- Percorrer a interface e marcar cada ocorrência dos sinais clássicos: fonte default sem intenção (a mesma sans em tudo), gradiente roxo→azul de enfeite, card dentro de card dentro de card, texto cinza sobre fundo colorido, ícone em quadradinho arredondado acima de todo título, emoji como ícone, sombra genérica em tudo, tudo centralizado.
- Cada sinal vira um item: `local — sinal — por que destoa do contexto do passo 1`.

### 3. Substituir por escolha deliberada
- Para cada sinal marcado, trocar pelo equivalente justificado: tipografia com caráter coerente ao tom, paleta com intenção (uma cor de marca + neutros, não arco-íris), profundidade por hierarquia real (peso, tamanho, espaço) em vez de sombra padrão.
- A troca cita a razão ligada ao contexto, não "fica mais bonito".

### 4. Conferir distinção
- Pergunta final: trocada a logo, essa tela ainda poderia ser de qualquer SaaS genérico? Se sim, a personalidade ainda não apareceu — voltar ao passo 3 no ponto mais genérico.

## Proibições durante esta skill

- Não decidir estética antes de declarar contexto (passo 1).
- Não justificar uma escolha com "fica mais bonito" / "mais moderno" — a razão liga ao público e ao tom.
- Não empilhar efeito (gradiente + sombra + blur + borda colorida) para simular capricho; capricho é hierarquia, não acúmulo.
- Não silenciar um sinal detectado sem trocar ou registrar por que ele fica.

## Saídas válidas

- **Lista de sinais e trocas** no formato `local — sinal detectado — escolha deliberada que entrou no lugar`.
- **Veredito de distinção:** afirmação de que a interface sobrevive ao "teste da logo trocada", ou a lista dos pontos que ainda não sobrevivem.
