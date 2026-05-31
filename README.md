# 📊 BI Educação — EduMetrics

Projeto de Business Intelligence para o setor educacional, desenvolvido como case técnico para a vaga de **Analista de Dados (BI & Analytics)** na **Scalare Data Solutions**. O case foi aprovado na avaliação técnica.

O objetivo foi auditar a qualidade dos dados de uma rede de escolas parceiras e extrair indicadores operacionais prioritários para a diretoria, cobrindo desde inconsistências cadastrais até inadimplência financeira e desempenho acadêmico.

---

## 🗂️ Estrutura do Repositório

```
bi_educacao/
├── Modulo1/                        # Excel — Auditoria de qualidade e faixa de desempenho
│   ├── LuccaCarnauba_modulo1.xlsx  # Base resolvida com log_erros e faixa_desempenho
│   ├── Script_Leitura.ipynb        # Script Python para validação automatizada
│   └── requirements.txt
├── Modulo2/                        # SQL — Análises financeiras e acadêmicas
│   ├── Queries_Analiticas.sql      # Consolidação de todas as queries com comentários
│   ├── Query1_Inadimplencia.sql    # Indicadores de inadimplência por escola
│   ├── Query2_Alunos_Inativos.sql  # Alunos inativos com movimentação financeira ativa
│   └── Query3_Ranking_Academico.sql# Top 3 alunos por escola com Window Functions
├── Modulo3/                        # Dashboard BI
│   ├── Dashboard_EducaAnalytics.pbix
│   ├── Campos_Calculados_Looker.txt
│   ├── Resumo_EducaAnalytics.pdf
│   └── Imagens/
│       ├── Dashboard_Looker_Studio.png
│       └── Dashboard_Power_BI.png
├── Modulo4/
│   └── Analise_Escrita.pdf         # Análise de risco e plano de mitigação em 30 dias
├── Documentacoes/
│   ├── Documentacao_Complementar.pdf
│   ├── Documentacao_Medidas_DAX.xlsx
│   └── Documentacao_Script_Python.pdf
└── Script_View.sql                 # View analítica consolidada
```

---

## 🔍 Módulo 1 — Excel: Auditoria de Qualidade

A base `dados_alunos` foi auditada sem tratamento prévio. As ações realizadas foram:

- Criação da aba `log_erros` registrando inconsistências por linha, coluna, tipo de problema e valor encontrado.
- Criação da coluna `faixa_desempenho` com a seguinte lógica:

| Faixa | Critério |
|---|---|
| Alto | nota ≥ 8 |
| Médio | 5 ≤ nota < 8 |
| Baixo | nota < 5 |
| Inválido | vazio, não numérico ou fora do intervalo 0–10 |

- Script Python complementar (`Script_Leitura.ipynb`) para leitura e validação automatizada da base com pandas e openpyxl.

---

## 🛢️ Módulo 2 — SQL: Saúde Financeira e Operacional

**Banco:** PostgreSQL | **Schema:** 6 tabelas — `escolas`, `alunos`, `turmas`, `matriculas`, `pagamentos`, `avaliacoes`

### Query 1 — Análise de Inadimplência
Indicadores gerais de inadimplência por escola, com remoção de duplicidades via `ROW_NUMBER()` e validação de consistência entre `status` e `data_pagamento`.

> **Achado:** Colégio Horizonte com ~40% de inadimplência; Colégio Futuro com maior valor absoluto pendente.

### Query 2 — Alunos Inativos com Movimentação Financeira Ativa
Cruzamento entre o campo `ativo` da tabela `alunos` e registros recentes em `pagamentos`, identificando inconsistências entre os controles acadêmico e financeiro.

> **Achado:** Alunos marcados como inativos ainda possuindo cobranças ativas, indicando risco jurídico e operacional.

### Query 3 — Ranking Acadêmico
Top 3 alunos por escola com base na média das notas, usando `DENSE_RANK()` para tratamento justo de empates — alunos com média igual recebem a mesma posição.

---

## 📈 Módulo 3 — Dashboard BI

**Ferramentas:** Power BI + Looker Studio

🔗 [Acessar dashboard no Looker Studio](https://datastudio.google.com/reporting/d6142069-5699-4d2e-917e-fb42e3cdb2f9)

O painel apresenta um resumo executivo com 3 visualizações prioritárias:

| Visualização | Justificativa |
|---|---|
| Taxa de inadimplência por escola | Identifica unidades com risco financeiro imediato |
| Alunos inativos com movimentação financeira | Expõe inconsistência operacional e risco jurídico |
| Ranking acadêmico por escola | Apoia decisões de alocação pedagógica |

---

## ✍️ Módulo 4 — Análise Escrita

O maior risco identificado foi de **governança operacional e qualidade dos dados**: alunos marcados como inativos ainda possuíam movimentação financeira ativa, indicando desconexão entre os controles acadêmico e financeiro — com potencial de gerar cobranças indevidas, perda de receita e riscos jurídicos.

**Plano de mitigação em 30 dias:** implementar rotina de auditoria cadastral e financeira conciliando status acadêmico, matrículas e pagamentos, com criação de alertas automáticos para identificação de inconsistências operacionais.

---

## 🛠️ Stack

| Camada | Tecnologia |
|---|---|
| Planilha | Excel + Python (pandas, openpyxl) |
| Banco de Dados | PostgreSQL |
| Queries | SQL com Window Functions (DENSE_RANK, ROW_NUMBER) |
| Visualização | Power BI + Looker Studio |
| Versionamento | Git / GitHub |
