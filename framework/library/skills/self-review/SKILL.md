---
versão: 1.0
status: estável
atualizado: 2026-05-23
descrição: Protocolo de auto-revisão de diff antes de declarar tarefa concluída. Checklist objetivo, sinais de alerta.
---

# Skill: self-review

## Quando usar

Workflows devem carregar esta skill imediatamente antes de declarar tarefa concluída, antes de propor commit, ou ao terminar sequência de edições que mudou mais de um arquivo. Workflows de leitura ou diagnóstico sem produção de diff podem omitir.

## Princípio guia

Self-review é o último filtro antes do humano. Defeito encontrado agora custa segundos; defeito encontrado em revisão alheia custa horas e contexto. Auto-revisão honesta exige ler o diff como se fosse de outra pessoa.

## Protocolo

### 1. Reler o diff inteiro de uma vez
- Sem editar enquanto lê. Se aparecer impulso de mudar, anotar e seguir.

### 2. Aplicar o checklist objetivo
- O diff cobre o escopo declarado e nada mais? Há refatoração lateral?
- O diff é o mínimo necessário? Há linhas que poderiam ter ficado iguais?
- Há teste correspondente a cada mudança de comportamento?
- Os identificadores criados seguem a convenção do arquivo?
- Há comentário explicativo do "que faz"? (sinal de nome ruim ou função longa).
- Há secret, credencial, caminho local ou nome próprio vazado no diff?

### 3. Investigar sinais de alerta
- `TODO`/`FIXME` novos no diff sem justificativa.
- `try/except` amplo ou `catch (...)` sem ação no bloco.
- Validação de input desabilitada ou contornada.
- Teste novo que sempre passa ou foi marcado `skip`.

### 4. Decidir
- Tudo OK: declarar concluído e seguir para o passo final do workflow.
- Algo a corrigir: voltar ao código, corrigir, re-rodar self-review do início (o diff mudou).

## Proibições durante esta skill

- Não pular checklist por pressa ou por "ter certeza".
- Não declarar "OK" sem ter passado item a item do checklist.
- Não corrigir mid-review enquanto lê — anota e ajusta na fase 4.
- Não tratar self-review como cerimônia. Falhar é o resultado esperado parte do tempo.

## Saídas válidas

- **Aprovação para concluir** quando o checklist passou inteiro, com resumo de uma linha do que foi verificado.
- **Lista de correções pendentes** quando algum item falhou, no formato arquivo:linha — descrição do problema — ação proposta.
