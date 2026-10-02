---
mudanca: <slug>
tipo: <melhoria | feature>
tamanho: <pequena | media>
status: proposto
aprovado_por: <quem aprovou, quando aprovado>
aprovado_em: <AAAA-MM-DD, quando aprovado>
registro: <caminho do registro de origem no projeto, se houver>
---

<!-- Preenchido pelo PLANEJADOR (/plan-change). Ninguém implementa antes de o
     dono aprovar: o /implement-change exige status: aprovado.

     status: "proposto" (escrito, aguardando o dono) ou "aprovado".
     Quem aprova é o dono; quem troca o campo é ele, ou o orquestrador com a
     aprovação dele registrada (aprovado_por, aprovado_em).
     tamanho: pequena = 1 etapa; media = 2 a 4 etapas. Grande não tem plano
     aqui — vira spec. -->

# <Título da mudança> — Plano

## 1. Objetivo

(2–4 linhas: o que muda para quem usa ou mantém o sistema, e por quê.)

## 2. Fora de escopo

- (o que esta mudança **não** faz — e para onde vai, se for trabalho de outro dia)

## 3. Classificação (skill `change-sizing`)

| Sinal | Valor | Evidência |
|-------|-------|-----------|
| Etapas | ... | ... |
| Áreas tocadas | ... | ... |
| Contrato / fronteira | ... | ... |
| Migração | ... | ... |
| ADR nova | não | — |
| Comportamento percebido | ... | ... |

## 4. Mapa do código

| Caminho | NOVO / ALTERADO / REUSADO | Para quê |
|---------|---------------------------|----------|
| `caminho/...` | ... | ... |

> Todo caminho ALTERADO ou REUSADO existe no repositório (conferido ao escrever).

## 5. Critérios de aceite

- **CA-1** — Dado ..., quando ..., então ... (testável)
- **CA-2** — ...

## 6. Etapas

<!-- Pequena: uma etapa. Média: 2 a 4, na ordem de execução; cada uma termina
     verde e commitada, e não depende de etapa posterior. -->

### Etapa 1 — <nome>
- **Faz:** (passos a nível de arquivo — o quê e onde)
- **Arquivos:** `caminho/...`
- **Testes:** (qual teste nasce vermelho e fica verde; contra o quê)
- **Cobre:** CA-1
- **Gate:** `<comando de validação do projeto que tem de sair verde>`

## 7. Riscos e como desfazer

- (o que pode dar errado e como se reverte; "nenhum relevante" é resposta válida se for verdade)

## 8. Como a revisão vai provar

- (os comandos e as reproduções que o revisor vai rodar para conferir cada CA)
