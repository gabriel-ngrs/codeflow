---
versão: 1.0
status: estável
atualizado: 2026-05-23
escopo: universal
---

# Rule: naming

## Quando carregar

Workflows devem carregar esta rule quando a tarefa cria novos identificadores (funções, variáveis, classes, arquivos, módulos, endpoints) ou redige mensagens visíveis ao usuário final. Workflows de fix pontual em código existente podem omitir.

## Regras

- **Código em inglês:** identificadores de código — funções, variáveis, classes, módulos, arquivos — são em inglês. O ecossistema de bibliotecas e ferramentas é em inglês; misturar idiomas no identificador quebra leitura e completion.
- **Mensagens ao usuário em pt-BR:** strings visíveis ao usuário final — erros mostrados em UI, textos de e-mail, copy de botão, mensagens de CLI orientadas ao operador — são em pt-BR. O ponto de tradução fica em uma camada explícita (i18n, arquivo de strings, templates).
- **Consistência com a linguagem da stack:** convenções de caso (camelCase, snake_case, PascalCase, kebab-case) seguem o que é idiomático na linguagem usada. Não impor convenção de uma stack em outra.
- **Nome reflete intenção, não tipo:** `usuariosAtivos` ou `activeUsers` venceu `lista` ou `arr`. Quando o tipo é importante e o nome curto pode confundir, é aceitável anexar sufixo de tipo (`usersById` para map), mas o "o quê" vem antes do "como".

## Anti-regras

- Não misturar idiomas dentro de um único identificador (`getUsuario`, `salvarUserData`). Escolher um lado por contexto e seguir.
- Não usar abreviações opacas (`btn`, `mgr`, `ctx` fora de convenção conhecida). Nomes curtos são aceitáveis quando idiomáticos (`i` para índice em loop curto, `id` para identificador).
- Nunca traduzir literalmente nomes de APIs públicas, padrões consagrados ou termos do ecossistema (`getUser`, `Promise`, `Request`) para pt-BR. Manter o termo em inglês quando ele é o nome técnico padrão.
- Não inventar convenção própria que conflita com a da linguagem. Em Python, `MinhaClasse` em vez de `MyClass` viola PEP-8 e força quem lê a recalibrar.

## Exceções

- **Domínio com vocabulário em pt-BR:** quando o domínio tem terminologia consagrada em pt-BR sem tradução natural (`nota fiscal`, `cnpj`, `inscrição estadual`), o identificador pode usar o termo pt-BR. Continua valendo: o restante do código permanece em inglês e o termo em pt-BR aparece em camelCase/snake_case conforme a linguagem.
- **Código herdado com convenção própria estabelecida:** ao editar arquivo existente cuja convenção difere desta rule, manter a convenção local. Continua valendo: a divergência deve estar documentada em `manifest.md` ou em decision; novos arquivos seguem esta rule.
