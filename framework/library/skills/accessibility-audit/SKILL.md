---
versão: 1.0
status: estável
atualizado: 2026-06-25
descrição: Protocolo de auditoria de acessibilidade de interface — teclado, leitor de tela, contraste e foco contra checklist WCAG.
---

# Skill: accessibility-audit

## Quando usar

Workflows devem carregar esta skill quando o passo produz ou altera interface com a qual o usuário interage (formulários, navegação, botões, modais, tabelas). Passos sem superfície interativa visível podem omitir.

## Princípio guia

Acessibilidade não é camada de verniz no fim — é a diferença entre a interface funcionar para todo mundo ou só para quem usa mouse e enxerga bem. Verificar contra critério objetivo, não contra impressão.

## Protocolo

### 1. Navegar só pelo teclado
- Percorrer a interface usando apenas Tab, Shift+Tab, Enter, Espaço e setas. Confirmar: ordem de foco segue a leitura, foco sempre visível, nada fica inalcançável, e não há armadilha de foco (entra num modal e não sai).

### 2. Checar semântica para leitor de tela
- Confirmar que cada elemento tem o papel certo: botão é `<button>` (não `<div>` clicável), imagem informativa tem `alt`, campo de formulário tem `<label>` associado, e regiões têm marcação (`header`, `nav`, `main`). Ícone sozinho que age como botão tem nome acessível.

### 3. Medir contraste
- Conferir cada par texto/fundo contra `wcag-checklist.md`: 4.5:1 para texto normal, 3:1 para texto grande e para elementos de UI/estado de foco. Marcar cada par que reprova com o valor medido.

### 4. Conferir estados e movimento
- Estados (erro, foco, desabilitado, selecionado) não dependem só de cor. Erro de formulário tem texto, não só borda vermelha. Animação respeita `prefers-reduced-motion`.

### 5. Consolidar contra o checklist
- Passar item a item do `wcag-checklist.md` (referência de critérios WCAG 2.2 AA) e marcar cada um como passa, reprova ou não-se-aplica.

## Proibições durante esta skill

- Não declarar acessível sem ter navegado pelo teclado de ponta a ponta (passo 1).
- Não transmitir informação só por cor (vermelho = erro sem texto, verde = ok sem rótulo).
- Não medir contraste "no olho" — usar o critério numérico do checklist.
- Não desabilitar foco visível (`outline: none`) sem repor um indicador equivalente.

## Saídas válidas

- **Relatório de auditoria** com cada item do `wcag-checklist.md` marcado passa / reprova / não-se-aplica.
- **Lista de violações** no formato `local — critério WCAG — o que está errado — correção proposta`, ordenada por gravidade (bloqueia uso primeiro).
