# Ciclo do recruta

> Molde para o roteiro de orquestração do projeto: como o Maestro abre, reaproveita e dispensa
> os terminais que executam o trabalho (os recrutas). O projeto copia o trecho para o próprio
> roteiro e ajusta nomes e limites. A independência que importa é a do avaliador, e ela não muda.

## Regras

1. **Um recruta por tarefa.** Tarefa é uma fase de spec, uma mudança (`/plan-change` →
   `/implement-change`) ou um lote de bugs. O recruta abre com o modelo e o esforço do papel
   (tabela 4b do `modo-delegado`) e recebe o despacho do molde `DESPACHO.md`.
2. **A correção da mesma tarefa volta ao mesmo recruta**, sem `/clear`, enquanto o contexto dele
   couber (referência: abaixo de ~200k tokens). Rework de fase reprovada, `AJUSTAR` de revisão e
   erro de registro são a mesma tarefa: o recruta já tem o código e o plano no contexto.
3. **O avaliador e o revisor ficam sempre em outro terminal**, em sessão nova: `/evaluate-spec-phase`
   e `/review-change` nunca rodam no terminal de quem executou.
4. **Dispensar no `ESTADO: CONCLUÍDO`.** Tarefa concluída e commitada, o recruta é dispensado
   (`maestri dismiss`), não fica ocioso com o contexto cheio. Nunca deixar recruta parado mais de
   1 h com contexto cheio.
5. **`/clear` só antes de uma tarefa nova** no mesmo terminal, e só quando ele não for dispensado.
6. **Escalada:** se o retorno pede "escalar para high", a mesma tarefa reabre em high (terminal novo
   ou `/effort high` antes do despacho); a correção segue nesse terminal.
7. **Codex sem cota troca para Claude.** Se o `maestri check` de um recruta Codex mostra
   `usage_limit_reached` (ou erro de cota ou limite), trocar no mesmo terminal com
   `maestri recruit "<nome>" --preset "Claude Médio" --replace "<nome>"` e reenviar o despacho.

## Sequência típica

```
despacha executor (medium) → retorno CONCLUÍDO → despacha avaliador (outro terminal, medium)
  ├─ APROVADO → dispensa os dois
  └─ REPROVADO/AJUSTAR → a correção volta ao MESMO executor (sem /clear) → nova avaliação em
     terminal novo; teto e escalada como no workflow
```
