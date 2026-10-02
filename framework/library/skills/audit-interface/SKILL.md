---
versão: 1.0
status: experimental
atualizado: 2026-10-02
descrição: Checklist do auditor de interface — acessibilidade, consistência visual, estados de tela (carregando, vazio, erro, offline) e texto de interface, só em projeto com interface gráfica.
---

# Skill: audit-interface

## Quando usar

Carregada pelo `/audit` quando a dimensão é `interface`, **só em projeto com interface gráfica**.
O workflow carrega junto as skills `accessibility-audit` e `visual-consistency`, que têm os
critérios detalhados; esta skill organiza a varredura do repositório inteiro e o formato dos
candidatos. Projeto sem interface gráfica não roda esta dimensão.

## Princípio guia

A tela é onde o usuário encontra todos os outros problemas. Auditar interface é passar por cada
estado de cada tela — inclusive os que ninguém desenha: o vazio, o erro, o lento, o sem rede.

## Protocolo

### 1. Réguas
- As skills `accessibility-audit` (WCAG) e `visual-consistency` (os tokens e componentes do projeto).
- O design system ou os componentes base do projeto; as rules de interface do projeto.

### 2. O que procurar
- **Acessibilidade:** controle sem nome acessível, imagem sem texto alternativo, contraste
  insuficiente, foco invisível ou preso, ordem de tabulação quebrada, formulário sem rótulo ou sem
  mensagem de erro associada.
- **Estados de tela:** carregando, vazio, erro e — quando o produto promete — offline; cada tela tem
  os quatro? Erro mostrado como texto técnico ao usuário?
- **Consistência:** cor, espaçamento ou tipografia fora dos tokens; componente recriado em vez de
  reusar o do design system; o mesmo padrão resolvido de dois jeitos.
- **Responsividade:** tela que quebra em largura de celular, rolagem horizontal, alvo de toque
  pequeno demais.
- **Texto de interface:** mensagem ambígua, rótulo que não diz a ação, termos inconsistentes entre
  telas.

### 3. Ferramentas (só leitura, conforme o stack)
- O lint de acessibilidade do projeto (ex.: `eslint-plugin-jsx-a11y`), se configurado.
- Execução em navegador com verificador automático (ex.: `axe`), contra o ambiente de
  desenvolvimento local — nunca contra produção com dado real.
- Busca por cor, tamanho e espaçamento literais fora dos tokens.

### 4. Severidade
- **Alta:** fluxo principal inacessível por teclado ou leitor de tela; estado de erro que deixa o
  usuário sem saída; tela quebrada no celular em fluxo principal.
- **Média:** estado vazio ou carregando ausente; contraste insuficiente em texto secundário;
  componente duplicado.
- **Baixa:** desvio de token sem efeito perceptível; texto inconsistente.
- Destino: **bug** quando o usuário não consegue concluir a tarefa; **melhoria** no resto.

## Proibições durante esta skill

- Não rodar verificação de interface contra produção ou com dado real.
- Não reportar gosto estético sem régua (token, componente, critério WCAG).
- Não alterar código nem estilo.

## Saídas válidas

- Lista de candidatos de interface, cada um com a tela e o estado, `arquivo:linha` do componente, a
  régua (critério WCAG, token, componente), a evidência (captura, saída da ferramenta), severidade e
  destino propostos.
- Cobertura por tela e por estado.
