---
auditoria: <AAAA-MM-DD>-<slug>
dimensao: <code-quality | architecture | tests | data-privacy | living-docs | dependencies | interface>
alvo: <o que foi auditado, em uma frase>
data: <AAAA-MM-DD>
candidatos: <n>
---

<!-- Preenchido por um AUDITOR (/audit), uma dimensão por laudo. Tudo aqui é
     CANDIDATO: quem confirma é o /verify-audit, em chat zerado. O auditor não
     altera código. A saída bruta de ferramenta fica fora do repositório. -->

# Auditoria <AAAA-MM-DD>-<slug> — <dimensão>

## 1. Alvo e régua

- **Alvo:** (o que entrou e o que ficou de fora)
- **Régua:** (as rules, ADRs e documentos do projeto contra os quais se julgou — achado sem régua não entra)

## 2. Cobertura

| Área | Estado | Observação |
|------|--------|------------|
| `caminho/...` | verificado / não verificado / fora do alvo | ... |

## 3. Ferramentas rodadas

| Ferramenta | Comando | Resultado resumido |
|------------|---------|--------------------|
| ... | `...` | ... |

## 4. Candidatos

| id | `arquivo:linha` | o problema | régua violada | evidência | severidade proposta | destino proposto |
|----|-----------------|------------|---------------|-----------|---------------------|------------------|
| <DIM>-1 | ... | ... | ... | ... | crítica / alta / média / baixa | bug / melhoria |

## 5. Limites desta auditoria

- (o que não deu para verificar, e por quê — vale mais que um placar inflado)
