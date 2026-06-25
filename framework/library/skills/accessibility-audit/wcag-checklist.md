# Referência: checklist WCAG 2.2 AA (arquivo auxiliar de `accessibility-audit`)

Lista de critérios objetivos consultada no Protocolo da skill `accessibility-audit`
(passos 3 e 5). Não é a norma completa — é o subconjunto AA que mais aparece em
interface de produto. Cada item se marca como **passa / reprova / não-se-aplica**.

## Perceptível

- **Texto alternativo:** imagem que carrega informação tem `alt` descritivo; imagem decorativa tem `alt=""`.
- **Contraste de texto:** texto normal ≥ 4.5:1; texto grande (≥ 24px, ou ≥ 19px bold) ≥ 3:1.
- **Contraste de não-texto:** bordas de campo, ícones informativos e indicador de foco ≥ 3:1 contra o fundo adjacente.
- **Cor não é o único canal:** estado/erro/link não dependem só de cor (há texto, ícone ou sublinhado).
- **Redimensionar texto:** layout sobrevive a zoom de 200% sem perder conteúdo ou função.
- **Reflow:** conteúdo usável em 320px de largura sem rolagem horizontal.

## Operável

- **Tudo pelo teclado:** toda ação possível com mouse é possível com teclado.
- **Sem armadilha de foco:** dá para entrar e sair de qualquer componente (modal, menu) pelo teclado.
- **Foco visível:** o elemento focado tem indicador claro e com contraste suficiente.
- **Ordem de foco:** a sequência de Tab segue a ordem lógica de leitura.
- **Alvo de toque:** área clicável de no mínimo 24×24px (WCAG 2.2, 2.5.8).
- **Movimento:** animação/auto-play respeita `prefers-reduced-motion` e pode ser pausada.

## Compreensível

- **Rótulo em campo:** todo campo de formulário tem `<label>` associado (não só placeholder).
- **Erro identificável:** erro de validação é descrito em texto e aponta o campo.
- **Foco previsível:** mudar o foco não dispara navegação ou submit inesperado.
- **Idioma:** a página declara `lang` correto.

## Robusto

- **Semântica correta:** botão é `<button>`, link é `<a>`; nada de `<div>` com `onClick` fazendo papel de controle.
- **Nome acessível:** controle só com ícone tem `aria-label` ou texto visualmente oculto.
- **Marcos de página:** `header`, `nav`, `main`, `footer` presentes para navegação por região.
- **Estado exposto:** componente com estado (aberto/selecionado/checado) expõe via atributo ARIA quando não há equivalente nativo.
