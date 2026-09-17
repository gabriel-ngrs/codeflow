---
versão: 1.0
status: estável
atualizado: 2026-09-17
descrição: Triagem de achado de segurança — reproduzir, classificar (confirmado/não-explorável/falso positivo), atribuir severidade. Derruba a taxa de falso positivo antes do achado virar ticket.
---

# Skill: triagem-de-achado

## Quando usar

Workflows devem carregar esta skill sempre que um scanner de segurança, agente ofensivo ou revisão
adversária produz **candidatos** a vulnerabilidade que precisam ser separados entre real e ruído
antes de virar relatório, ticket ou fix. É a etapa que fica entre "a ferramenta apontou X" e "X é um
problema que vamos tratar". Carregada pelo `/security-sweep` e por qualquer workflow que consuma
saída de ferramenta de segurança.

## Princípio guia

Um achado não confirmado é uma hipótese, não uma vulnerabilidade. O que decide se uma ferramenta de
segurança serve não é quantos achados ela cospe, e sim quantos **se sustentam** quando alguém tenta
reproduzir. Triar é tentar provar o achado — e registrar honestamente quando ele não se prova.

## Protocolo

### 1. Ler o candidato contra o código real
- Abrir o arquivo e a linha que o achado aponta. Ler o trecho e seus chamadores, não só a mensagem
  do scanner.
- Reconstituir a alegação em uma frase: **quem** (ator/entrada), **o quê** (operação), **por que
  seria explorável** (que barreira falta ou falha).

### 2. Tentar reproduzir — o teste de existência
- **Achado em código estático (SAST, IDOR lógico, authz):** traçar o caminho da entrada não confiável
  até o sink. Se existir guarda (validação, `@Roles`, checagem de posse, escape, binding
  parametrizado) que **quebra** o caminho, o achado não se sustenta. Se o caminho chega ao sink sem
  barreira, é candidato confirmado.
- **Achado de segredo (gitleaks):** verificar se o valor é real e ativo (não `.env.example`, não
  fixture, não placeholder). Segredo real e ativo → **para tudo**: rotacionar antes de seguir
  (rule `adversarial-testing`).
- **Achado de dependência (osv-scanner/npm audit):** confirmar que o caminho vulnerável da lib é
  de fato **alcançado** pelo projeto e que a versão instalada está no range afetado. CVE em código
  morto ou em caminho não usado é severidade menor, não falso positivo — registrar como tal.
- **Onde couber, escrever um teste-guarda ou PoC mínimo:** um teste que falha por causa da falha
  (uma requisição que não deveria passar e passa, um payload que vaza dado). Só rodar PoC ativo
  contra alvo vivo com a autorização e o ambiente efêmero exigidos pela rule `adversarial-testing`.

### 3. Classificar
Cada candidato termina em exatamente um veredito:
- **`confirmado`** — reproduzido ou com caminho de exploração provado no código. Entra no ledger.
- **`não-explorável-no-contexto`** — a falha existe no abstrato mas uma barreira do sistema a torna
  inexplorável aqui (rota interna sem exposição, dado não sensível, versão fora do range). Registrar
  **com o motivo** — é cobertura, não lixo.
- **`falso-positivo`** — a ferramenta errou; o caminho não existe. Registrar para calibrar a
  ferramenta e medir a taxa.

### 4. Atribuir severidade ao que foi confirmado
- Estimar impacto (o que o atacante ganha) × alcance (quem consegue disparar) × pré-condições.
  Faixas: **crítica / alta / média / baixa**. Vazamento entre clientes (quebra de isolamento
  multi-tenant), RCE e bypass de autenticação são crítica por padrão.
- Registrar a severidade com uma frase de justificativa, não só o rótulo.

## Proibições durante esta skill

- Não promover candidato a `confirmado` sem ter traçado o caminho até o sink ou reproduzido — "o
  scanner disse" não é confirmação.
- Não descartar candidato como `falso-positivo` por conveniência ou pressa; a barreira que o
  invalida tem que ser nomeada.
- Não colar segredo real, payload de exploração ou dump sensível em log, ticket público ou saída
  versionada em claro.
- Não rodar PoC ativo contra alvo exposto à rede sem a autorização da rule `adversarial-testing`.
- Não inflar severidade para dar peso ao relatório nem deflacionar para fechar mais rápido.

## Saídas válidas

- Uma lista de candidatos, cada um com: alegação em uma frase, veredito (`confirmado` /
  `não-explorável-no-contexto` / `falso-positivo`), o motivo do veredito, e — para confirmados —
  severidade justificada e o teste-guarda/PoC (ou o caminho no código que prova a exploração).
- Uma contagem de calibração: quantos candidatos entraram, quantos se sustentaram — a **taxa de
  falso positivo** da rodada, que alimenta a decisão sobre a ferramenta.
