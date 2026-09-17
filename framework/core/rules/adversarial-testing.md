---
versão: 1.0
status: estável
atualizado: 2026-09-17
escopo: universal
---

# Rule: adversarial-testing

## Quando carregar

Workflows devem carregar esta rule quando a tarefa envolve **procurar vulnerabilidades**, rodar
ferramenta de teste de segurança ofensivo, agente autônomo de pentest, fuzzing, ou qualquer
técnica que exercite o alvo como um atacante faria. Workflows de revisão de código puramente
defensiva (ler e apontar) podem carregar a rule `security` em vez desta; esta rule governa o ato
de **atacar** para validar.

## Regras

- **Autorização escrita antes de tocar alvo vivo.** Código-fonte próprio em disco pode ser varrido
  livremente. Mas qualquer alvo que **executa** — instância de servidor, endpoint de rede, banco,
  site de cliente já entregue — só é testado com autorização escrita e escopo declarado. Site de
  cliente entregue nunca é varrido sem cláusula contratual que o permita.
- **Nunca contra produção nem contra dado real.** Teste ativo roda contra ambiente **efêmero** com
  **dados sintéticos**. Produção, base com PII, e credenciais reais estão fora de escopo por
  padrão; incluí-los exige decision explícita do owner, não é presumido.
- **Teto de esforço declarado antes de começar.** Todo agente autônomo ou varredura que consome
  recurso medido (token de API, tempo de máquina, chamadas a serviço externo) roda com um limite
  explícito — `--max-budget`, `--max-turns`, timeout, ou equivalente. Sem teto declarado, não roda.
- **Achado de ferramenta é hipótese, não fato.** Nenhuma saída de scanner ou de agente vira ticket,
  commit ou relatório final sem passar por triagem que tente **reproduzir** o achado. A taxa de
  falso positivo medida é o que decide se a ferramenta serve.
- **Segredo descoberto é tratado como vazado.** Se a varredura expõe uma credencial real (em código,
  histórico ou config), o processo para: a credencial é rotacionada antes de qualquer outra coisa, e
  o achado não é colado em log, ticket público ou saída versionada em claro.

## Anti-regras

- Não apontar um agente ofensivo para um host ou URL "só para ver o que dá" sem escopo e autorização
  escritos — varredura sem autorização é ilegal na maioria das jurisdições, mesmo contra alvo que
  parece ser "de teste".
- Não reportar o número bruto de achados de um scanner como se fossem vulnerabilidades. O número que
  importa é quantos **se sustentaram** na triagem manual.
- Não deixar artefato de varredura (relatório com payloads, dump de rota, PoC executável) dentro de
  diretório versionado sem revisar o que ele contém — relatório de pentest é material sensível.
- Não rodar teste ativo (que mande requisição, tente payload, force login) contra qualquer coisa
  exposta à rede sem a pausa de autorização, ainda que o código-alvo seja seu.

## Exceções

- **Análise estática de código próprio:** ler o próprio repositório e rodar scanner estático
  (SAST, secrets, dependências) sobre o código em disco dispensa a autorização escrita — não há alvo
  vivo sendo exercitado. Continua valendo: segredo real encontrado é tratado como vazado.
- **Ambiente de laboratório declarado:** um alvo montado explicitamente como laboratório de teste
  (contêiner efêmero, dados sintéticos, isolado da rede) pode ser exercitado ativamente sem cláusula
  contratual, desde que o owner o declare como laboratório na abertura do trabalho.
