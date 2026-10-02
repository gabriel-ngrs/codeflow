---
versão: 1.0
status: experimental
atualizado: 2026-10-02
descrição: Checklist do auditor de dados e privacidade — dado pessoal em log e em fixture, isolamento entre clientes, retenção e LGPD, com o caminho do dado como evidência.
---

# Skill: audit-data-privacy

## Quando usar

Carregada pelo `/audit` quando a dimensão é `data-privacy`. Cobre o caminho do **dado pessoal e do
dado de cliente**: onde entra, por onde passa, onde fica, quem enxerga e quando sai. É a dimensão
de LGPD e de isolamento multi-tenant. Vulnerabilidade explorável (injeção, bypass de autenticação)
é do `/security-sweep`.

## Princípio guia

Dado pessoal vaza pelos lugares que ninguém olha: o log, a fixture, a mensagem de erro, o
relatório. Auditar privacidade é seguir o dado, não ler o código de cima a baixo.

## Protocolo

### 1. Réguas
- As rules de dados, segredos e privacidade do projeto; as ADRs de isolamento e de retenção;
  `~/.codeflow/framework/core/rules/security.md`.
- A LGPD como referência do que é dado pessoal e sensível: identificação, contato, documentos,
  saúde, localização, conteúdo de conversa.

### 2. O que procurar
- **Inventário:** onde o dado pessoal entra (formulário, API, integração) e onde é guardado.
- **Vazamento em log e telemetria:** dado pessoal ou conteúdo de conversa escrito em log, métrica,
  rastreio ou mensagem de erro sem máscara.
- **Dado real no repositório:** fixture, teste, seed, exemplo ou comentário com nome, telefone,
  documento ou conversa de pessoa real.
- **Isolamento:** consulta ou leitura sem o identificador do cliente/tenant; identificador lido de
  fonte que o usuário controla; cache ou fila compartilhada entre clientes.
- **Exposição:** resposta de API devolvendo mais campos do que a tela usa; dado sensível sem
  máscara para perfil que não deveria ver.
- **Retenção e eliminação:** dado guardado sem prazo, sem caminho de exclusão ou de exportação
  quando o projeto promete esses direitos.
- **Segredo:** credencial em código, config versionada ou log.

### 3. Ferramentas (só leitura, conforme o stack)
- Varredor de segredo do projeto (ex.: `gitleaks`), no conteúdo e no histórico.
- `grep` dirigido por padrões de dado pessoal (CPF, telefone, e-mail, nomes de campos sensíveis) em
  log, fixture, seed e teste.
- Os alvos de teste de isolamento ou de vazamento do projeto, se existirem, pelo manifest.

### 4. Severidade
- **Crítica:** dado de um cliente alcançando outro; segredo real e ativo exposto; dado pessoal real
  no repositório.
- **Alta:** dado pessoal em log ou mensagem de erro; resposta expondo campo sensível.
- **Média:** retenção sem prazo, máscara ausente em superfície interna.
- **Baixa:** inventário incompleto, documentação de tratamento desatualizada.
- Destino: **bug** para vazamento e isolamento; **melhoria** para retenção e documentação.

## Proibições durante esta skill

- Não copiar dado pessoal real, segredo ou conteúdo de conversa para o laudo — citar o local e o
  tipo do dado, nunca o valor.
- Não testar isolamento contra ambiente com dado real de cliente.
- Não alterar código nem dado.

## Saídas válidas

- Lista de candidatos de privacidade, cada um com o caminho do dado (entrada → onde vaza ou fica),
  `arquivo:linha`, a régua, a evidência sem o valor sensível, severidade e destino propostos.
- O inventário de onde o dado pessoal entra e onde fica, como cobertura.
