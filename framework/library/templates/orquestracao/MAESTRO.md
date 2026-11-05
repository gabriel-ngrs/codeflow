# Maestro

> Molde para o roteiro de orquestração do projeto: como vive o terminal que planeja, despacha e
> integra (o Maestro). O projeto copia o trecho para o próprio roteiro e ajusta os nomes.

## Regras

1. **Um Maestro novo por spec ou por lote.** O Maestro não atravessa specs: começa lendo o PLANO
   da frente, que é a memória dele, e não a conversa anterior.
2. **O PLANO é a memória.** Decisões, frentes e o diário ficam no PLANO, atualizado por Edit ou por
   acréscimo. Um Maestro que entra no lugar de outro lê o PLANO e segue, sem reconstruir pela
   conversa.
3. **A conversa com o dono fica separada do Maestro que despacha.** O dono fala num terminal
   próprio (ou no chat); o Maestro recebe as decisões já tomadas, registradas no PLANO. Assim o
   contexto do Maestro não carrega a conversa inteira.
4. **Antes de uma espera longa** (prevista acima de ~50 min, ex.: CI, revisão de outro terminal),
   `/compact` ou passar o bastão: registrar no diário do PLANO onde parou e encerrar; o próximo
   Maestro retoma pelo PLANO.
5. **`maestri ask` sempre em segundo plano**, para o Maestro não ficar bloqueado esperando um
   recruta.
6. **Status numa fonte só:** o diário do PLANO. Notas no canvas, resumos e retornos são gerados a
   partir dele, nunca mantidos à mão em paralelo.
7. **Vigília fora do Maestro.** Quem vigia é o cron ou a routine do Maestri, não um passo do
   roteiro: eles rodam o `vigia.sh` e, quando ele sai 1, chamam `maestri notify`.

## Vigília com `vigia.sh`

```bash
# a cada 15 min; avisa quando a frente passa de 30 min sem commit nem mudança no PLANO
bash ~/.codeflow/framework/core/scripts/vigia.sh --limite 30 <PLANO.md> <ramo>...
case $? in
  1) maestri notify "<frente> sem avanço há mais de 30 min" ;;
  2|3) maestri notify "<frente>: vigia.sh falhou (erro ou uso), conferir" ;;
esac
```

O script só lê: o `git log -1 --format=%ct` de cada ramo e o mtime do PLANO. Saídas: 0 houve
avanço dentro do limite; 1 parado acima do limite; 2 erro de execução; 3 uso inválido. O aviso
não é dele, porque `maestri` está fora da stack permitida em scripts.
