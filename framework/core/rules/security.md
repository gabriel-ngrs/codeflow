---
versão: 1.0
status: estável
atualizado: 2026-05-23
escopo: universal
---

# Rule: security

## Quando carregar

Workflows devem carregar esta rule quando a tarefa envolve entrada externa, autenticação, autorização, persistência de dados sensíveis, dependências de terceiros ou qualquer trecho exposto à rede. Workflows que só leem código ou ajustam documentação podem omitir.

## Regras

- **Validação de input:** toda entrada vinda de usuário, API externa ou arquivo deve ser validada antes de uso. Validar formato, faixa, presença e contexto. Confiar em dado externo é vetor de injeção, deserialização insegura e comportamento indefinido.
- **Secrets fora do git:** chaves, tokens, senhas e credenciais nunca são commitados. Vivem em `.env` (ignorado), gerenciador de secrets ou variáveis de ambiente do runtime. Qualquer detecção de secret no diff bloqueia o commit.
- **Autenticação e autorização explícitas:** todo endpoint ou comando que toca recurso protegido declara, no próprio código, quem pode acessá-lo. Decisão "default open" é proibida; padrão é negar e abrir caso a caso.
- **Dependências externas com cautela:** ao adicionar nova biblioteca, verificar manutenção ativa, escopo de uso e licença. Atualizações de dependência são revisadas antes de aplicar. Pin de versão é regra; floating versions são exceção justificada.

## Anti-regras

- Não confiar em validação só do lado do cliente. Validação client-side é conveniência; validação server-side é a barreira de segurança.
- Não logar dados sensíveis (senhas, tokens, PII completa). Logs vazam por meios imprevistos — assumir que tudo logado é potencialmente público.
- Não construir queries, comandos ou HTML por concatenação de string com input externo. Usar bindings parametrizados, escapes específicos do contexto ou bibliotecas de templating.
- Nunca commitar arquivo `.env`, chave privada ou credencial mesmo "só por enquanto". Histórico do git é eterno; remover depois exige reescrever história.

## Exceções

- **Ambiente local de desenvolvimento isolado:** secrets fictícios e credenciais de teste podem viver em arquivos versionados quando claramente marcados (`.env.example`, `fixtures/`). Continua valendo: o arquivo não contém valores reais e o nome deixa claro que é exemplo.
- **Endpoint público intencional:** rotas declaradamente abertas (`/health`, `/version`, landing pages) dispensam autorização. Continua valendo: a abertura é decisão explícita registrada em decision ou comentário curto no próprio código.
