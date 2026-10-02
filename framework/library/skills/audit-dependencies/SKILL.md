---
versão: 1.0
status: experimental
atualizado: 2026-10-02
descrição: Checklist do auditor de dependências — pacotes desatualizados, abandonados, duplicados, sem uso ou com licença incompatível, e a saúde do lockfile.
---

# Skill: audit-dependencies

## Quando usar

Carregada pelo `/audit` quando a dimensão é `dependencies`. Cobre a saúde do que o projeto
**importa de fora**: versões, manutenção, licença, duplicação e o que está declarado sem uso.
Vulnerabilidade conhecida (CVE) também aparece aqui, mas a exploração e a triagem de alcance são do
`/security-sweep` — aqui ela entra como candidato com a referência.

## Princípio guia

Cada dependência é código que você não escreveu e vai manter assim mesmo. A pergunta não é "está
na última versão?", é "se ela parar amanhã, quanto do sistema para junto?".

## Protocolo

### 1. Réguas
- A política de dependências do projeto, se houver (versões fixadas, catálogo, licenças aceitas);
  as rules de segurança.
- O lockfile como fonte de verdade do que realmente está instalado.

### 2. O que procurar
- **Desatualizada:** atrás de versão major com correções relevantes, ou fora do suporte do
  mantenedor (fim de vida).
- **Abandonada:** sem lançamento nem atividade há muito tempo, arquivada, ou com um mantenedor só,
  em caminho crítico.
- **Vulnerável:** versão com aviso de segurança publicado (registrar o identificador; a triagem de
  alcance é do `/security-sweep`).
- **Sem uso:** declarada e nunca importada; ou importada e não declarada (dependência fantasma).
- **Duplicada:** duas bibliotecas para a mesma função; a mesma em versões diferentes no mesmo
  workspace.
- **Licença:** incompatível com o uso do projeto (ex.: copyleft forte em produto fechado), ou
  ausente.
- **Lockfile:** fora de sincronia com o manifesto de pacotes; instalação que não é reprodutível.

### 3. Ferramentas (só leitura, conforme o stack)
- O gerenciador de pacotes: `outdated`, `audit`, `why`/`ls` (ex.: `pnpm outdated`, `npm audit`,
  `pip list --outdated`).
- Varredor de vulnerabilidade (ex.: `osv-scanner`) e de licença (ex.: `license-checker`), se
  disponíveis.
- Detecção de dependência sem uso (ex.: `knip`, `depcheck`, `deptry`).

### 4. Severidade
- **Alta:** vulnerabilidade publicada em dependência alcançada por caminho exposto; licença
  incompatível em produto distribuído; dependência abandonada em caminho crítico.
- **Média:** major atrasada com correções relevantes; fim de vida próximo; lockfile dessincronizado.
- **Baixa:** dependência sem uso, duplicação sem conflito, minor atrasada.
- Destino: **melhoria**, em geral; **bug** quando a dependência já causa falha ou o lockfile quebra a
  instalação.

## Proibições durante esta skill

- Não atualizar, instalar nem remover pacote — só apontar.
- Não reportar "não está na última versão" sem dizer o que se perde por isso.
- Não decidir sobre licença em nome do dono: apontar a incompatibilidade e a regra.

## Saídas válidas

- Lista de candidatos de dependência, cada um com o pacote e a versão, onde é declarado e usado, a
  régua, a evidência (saída da ferramenta, data do último lançamento, licença), severidade e destino
  propostos.
- O inventário resumido (quantas diretas, quantas desatualizadas, quantas sem uso) como cobertura.
