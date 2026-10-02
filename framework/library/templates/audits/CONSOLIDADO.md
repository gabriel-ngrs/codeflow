---
auditoria: <AAAA-MM-DD>-<slug>
data: <AAAA-MM-DD>
dimensoes: [<dimensão>, ...]
candidatos: <n>
confirmados: <n>
falsos_positivos: <n>
---

<!-- Preenchido pelo VERIFICADOR (/verify-audit), em chat zerado: confirma ou
     descarta cada candidato dos laudos, junta duplicatas entre dimensões e
     separa por destino. As seções 3 e 4 são a ENTRADA das outras trilhas —
     a de bugs (ex.: /batch-bugfix) e a de melhorias (ex.: /plan-change).
     Quem registra e numera é a trilha de destino, não esta auditoria. -->

# Auditoria <AAAA-MM-DD>-<slug> — Consolidado

## 1. Placar

| Dimensão | Candidatos | Confirmados | Não-explorável / sem impacto | Falsos positivos |
|----------|------------|-------------|------------------------------|------------------|
| ... | ... | ... | ... | ... |

Taxa de falso positivo da rodada: <n>/<total>.

## 2. Resumo para o dono

(3–6 linhas: o que mais pesa, em linguagem de produto e de risco.)

## 3. Para a trilha de bugs

| id | título | severidade | `arquivo:linha` | como reproduzir / evidência | origem |
|----|--------|------------|-----------------|-----------------------------|--------|
| A1 | ... | alta | ... | ... | <DIM>-3 |

## 4. Para a trilha de melhorias

| id | título | tipo | severidade | `arquivo:linha` | o que fazer | origem |
|----|--------|------|------------|-----------------|-------------|--------|
| M1 | ... | melhoria | média | ... | ... | <DIM>-1, <DIM>-4 |

## 5. Descartados

| origem | motivo (a barreira que o invalida, ou por que não tem impacto) |
|--------|-----------------------------------------------------------------|
| <DIM>-2 | ... |

## 6. Cobertura e limites

- (o que as dimensões cobriram, o que ficou de fora e por quê)
