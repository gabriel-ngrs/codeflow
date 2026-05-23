---
versão: 1.0
status: estável
atualizado: 2026-05-23
escopo: universal
---

# Rule: code-quality

## Quando carregar

Workflows devem carregar esta rule quando a tarefa envolve criação ou modificação de código de produção, refatoração ou revisão de diff. Workflows puramente documentais podem omitir.

## Regras

- **Diff mínimo:** alterar apenas o necessário para cumprir o escopo declarado. Mudanças cosméticas em código adjacente exigem decision explícita ou ficam fora.
- **Funções pequenas:** cada função faz uma coisa e tem responsabilidade clara. Quando a função excede ~30 linhas ou exige rolagem para entender, extrair sub-funções.
- **Nomes expressivos:** identificadores declaram intenção. `calcularImpostoMensal` vence `calc1`; `usuariosAtivos` vence `lista`. Nomes vagos forçam o leitor a inferir comportamento.
- **Sem duplicação descontrolada:** três trechos repetidos sinalizam extração. Duas ocorrências podem ficar; padrões repetidos exigem helper, função ou abstração nomeada.

## Anti-regras

- Não refatorar trecho adjacente ao escopo só porque "está aqui mesmo". Refatoração vive em decision ou em workflow próprio.
- Não usar abreviações criptografadas (`usr`, `tmpVal`, `dt`) quando o nome completo é curto e claro.
- Não aceitar função longa com comentários de seção (`// parte 1`, `// parte 2`) — esses comentários são pedido implícito de extração.
- Nunca duplicar lógica de negócio em mais de um lugar do código sem registrar a duplicação como decisão consciente.

## Exceções

- **Performance crítica:** quando profiling demonstra que extração de função ou nome longo introduz custo mensurável, a forma compacta é aceitável. Continua valendo: o trecho compacto recebe comentário curto explicando o "por quê" da otimização.
- **Trecho gerado por ferramenta:** código autogerado (migrações, schemas, parsers) pode violar funções pequenas e nomes expressivos. Continua valendo: o trecho não é editado à mão; alterações vão na fonte do gerador.
