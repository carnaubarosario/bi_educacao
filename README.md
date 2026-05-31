# 📊 BI Educação — Análise de Escolas

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue?logo=postgresql)
![Python](https://img.shields.io/badge/Python-3.8%2B-yellow?logo=python)
![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811?logo=powerbi&logoColor=black)
![Looker Studio](https://img.shields.io/badge/Looker-Studio-4285F4?logo=googleanalytics&logoColor=white)
![Excel](https://img.shields.io/badge/Excel-Avançado-217346?logo=microsoftexcel&logoColor=white)
![Status](https://img.shields.io/badge/Status-Concluído-brightgreen)

Projeto de Business Intelligence para o setor educacional com foco em **auditoria de dados**, **análise financeira** e **desempenho acadêmico**. O objetivo foi auditar a qualidade dos dados de uma rede de escolas parceiras e extrair indicadores operacionais prioritários, cobrindo inconsistências cadastrais, inadimplência financeira e ranking acadêmico.

---

## 📌 Visão Geral

| | |
|---|---|
| **Escolas analisadas** | 5 unidades |
| **Pagamentos registrados** | 720 |
| **Taxa geral de inadimplência** | 26,8% |
| **Alunos inativos com movimentação financeira** | 6 alunos / R$ 26.250 pendentes |
| **Ferramentas** | PostgreSQL · Excel · Python · Power BI · Looker Studio |

---

## 🗂️ Estrutura do Repositório

```
bi_educacao/
├── Modulo1/                           # Excel — Auditoria e faixa de desempenho
│   ├── LuccaCarnauba_modulo1.xlsx     # Base resolvida com log_erros e faixa_desempenho
│   ├── Script_Leitura.ipynb           # Script Python para validação automatizada
│   └── requirements.txt
│
├── Modulo2/                           # SQL — Análises financeiras e acadêmicas
│   ├── Queries_Analiticas.sql         # Consolidação de todas as queries
│   ├── Query1_Inadimplencia.sql       # Inadimplência geral e por escola
│   ├── Query2_Alunos_Inativos.sql     # Alunos inativos com movimentação financeira ativa
│   └── Query3_Ranking_Academico.sql   # Top 3 alunos por escola com Window Functions
│
├── Modulo3/                           # Dashboard BI
│   ├── Dashboard_EducaAnalytics.pbix  # Arquivo Power BI
│   ├── Campos_Calculados_Looker.txt   # Campos calculados utilizados no Looker Studio
│   ├── Resumo_EducaAnalytics.pdf
│   └── Imagens/
│       ├── Dashboard_Looker_Studio.png
│       └── Dashboard_Power_BI.png
│
├── Modulo4/
│   └── Analise_Escrita.pdf            # Análise de risco e plano de mitigação em 30 dias
│
├── Documentacoes/
│   ├── Documentacao_Complementar.pdf
│   ├── Documentacao_Medidas_DAX.xlsx
│   └── Documentacao_Script_Python.pdf
│
└── Script_View.sql                    # Proposta de view analítica consolidada
```

---

## 🛢️ Banco de Dados

O banco é um **PostgreSQL** com acesso somente leitura, composto por 6 tabelas:

| Tabela | Descrição |
|---|---|
| `escolas` | Cadastro das unidades — id, nome, cidade, tipo (pública/privada) |
| `alunos` | Cadastro de alunos com flag ativo/inativo e data de matrícula |
| `turmas` | Turmas por escola, série e turno |
| `matriculas` | Relacionamento aluno × turma × ano letivo |
| `pagamentos` | Mensalidades com status pago / pendente / isento |
| `avaliacoes` | Notas por disciplina, bimestre e ano |

**Ferramenta recomendada para conexão:** DBeaver, TablePlus ou DataGrip.

**String de conexão:**
postgresql://candidato.crebcpokyhcfjqkdwytt:senha_candidato_scalare@aws-0-us-west-2.pooler.supabase.com:6543/postgres

No DBeaver, crie uma nova conexão PostgreSQL e preencha os campos com os dados acima, ou cole diretamente a string de conexão no campo JDBC URL.
---

## 📋 Desafios Propostos

### Módulo 1 — Excel: Auditoria de Qualidade

A base `dados_alunos` foi fornecida sem nenhum tratamento prévio.

1. **Auditoria de qualidade** — criar a aba `log_erros` registrando inconsistências por linha, coluna, tipo de problema e valor encontrado.
2. **Faixa de desempenho** — criar a coluna `faixa_desempenho` classificando cada aluno pela nota.
3. **Insight** — identificar o dado que exige maior atenção operacional.

### Módulo 2 — SQL: Saúde Financeira e Operacional

4. **Saúde financeira** — analisar inadimplência geral, identificar alunos inativos com rotinas financeiras ativas e detectar duplicidades sistêmicas.
5. **Qualidade de ensino** — gerar ranking Top 3 alunos por escola com Window Functions.

### Módulo 3 — Dashboard BI

6. Projetar um resumo executivo com no máximo 3 visualizações, justificando a prioridade estratégica de cada painel.

### Módulo 4 — Análise Escrita

7. Identificar o maior risco de governança e propor plano de mitigação em 30 dias.

---

## 🔍 Como Foi Desenvolvido

### Módulo 1 — Excel

A coluna `faixa_desempenho` foi criada com a fórmula abaixo, que trata quatro situações de erro antes de classificar: campo vazio, valor não numérico, nota abaixo de 0 e nota acima de 10.

```excel
=SE(OU(G2="";NÃO(ÉNÚM(G2));G2<0;G2>10);"Inválido";SE(G2<5;"Baixo";SE(G2<8;"Médio";"Alto")))
```

| Faixa | Critério |
|---|---|
| **Alto** | nota ≥ 8 |
| **Médio** | 5 ≤ nota < 8 |
| **Baixo** | nota < 5 |
| **Inválido** | vazio, não numérico ou fora do intervalo 0–10 |

Registros inválidos foram documentados na aba `log_erros`. Um script Python complementar (`Script_Leitura.ipynb`) foi desenvolvido com pandas e openpyxl para automatizar a leitura e validação da base.

### Módulo 2 — SQL

Todas as queries foram construídas com **CTEs encadeadas** para separar claramente cada etapa da lógica. Cada arquivo contém comentários explicativos no cabeçalho e conclusões numéricas ao final.

### Módulo 3 — Dashboard

Desenvolvido em duas ferramentas: **Power BI** (arquivo `.pbix` disponível no repositório) e **Looker Studio** (link público abaixo). Os campos calculados do Looker estão documentados em `Modulo3/Campos_Calculados_Looker.txt`.

---

## 🛠️ Queries SQL — Detalhamento

### Query 1 — Inadimplência por Escola

**Lógica:**
- Duplicidades removidas via `ROW_NUMBER()` particionando por `aluno_id`, `mes_ref`, `status` e `valor`.
- Inadimplência calculada sobre a base deduplificada.
- Consistência entre `status` e `data_pagamento` validada — pagamentos pendentes devem ter `data_pagamento` nula.
- Cada escola recebe classificação de risco comparada à taxa geral: `Acima da média`, `Abaixo da média` ou `Na média`.

**Resultado:**
> 720 pagamentos · 193 pendentes · taxa geral de **26,8%**
> Colégio Horizonte: **~40% de inadimplência** · ~R$ 33.600 a receber
> Colégio Futuro: taxa abaixo da média, porém **maior valor absoluto pendente**

---

### Query 2 — Alunos Inativos com Movimentação Financeira Ativa

**Lógica:**
- Alunos com `ativo = FALSE` cruzados com a tabela de pagamentos.
- Critério de atividade financeira: `status = 'pendente'` **ou** pagamento realizado nos últimos 90 dias.
- Período de 90 dias calculado dinamicamente via CTE `data_referencia` — sem hardcode de datas.
- Resultado agrupado por aluno com totais de movimentações, valor pendente e distribuição por turno e série.

**Resultado:**
> 6 alunos inativos com movimentação ativa · R$ 36.330 movimentados · **R$ 26.250 pendentes**
> Alunos do 1º ano: **66,67%** dos casos
> Escolas: Colégio Futuro · Instituto EduTech · Escola Conecta · Colégio Horizonte · Centro Educacional Viva

---

### Query 3 — Ranking Acadêmico: Top 3 por Escola

**Lógica:**
- Média individual calculada com `AVG()` agrupado por aluno.
- Ranking por escola via `DENSE_RANK() OVER (PARTITION BY escola ORDER BY media_aluno DESC)`.
- Ranking geral via `DENSE_RANK() OVER (ORDER BY media_aluno DESC)`.
- `DENSE_RANK` escolhido no lugar de `ROW_NUMBER` para que alunos com médias iguais recebam a mesma posição — sem penalização por empate.

**Resultado:**
> Centro Educacional Viva: **maior média geral entre as escolas**
> Top 3 alunos individualmente: todos da **Escola Conecta** — alta concentração de talentos, mas sem consistência em toda a turma
> **Hugo Cavalcanti** (Escola Conecta): top 3 geral de médias + nota máxima 10

---

### Script View — Camada Analítica Consolidada

Proposta de view que desnormaliza todas as tabelas em uma única camada pronta para consumo no Power BI, com indicadores por aluno: taxa de inadimplência, valor pendente, média acadêmica, classificação de risco financeiro e classificação de desempenho.

> A view não foi executada devido às permissões restritas do ambiente (somente leitura), mas a estrutura foi proposta para demonstrar uma camada analítica de produção.



## 📈 Dashboard

🔗 [Acessar dashboard no Looker Studio](https://datastudio.google.com/reporting/d6142069-5699-4d2e-917e-fb42e3cdb2f9)

![Dashboard Looker Studio](https://raw.githubusercontent.com/carnaubarosario/bi_educacao/main/Imagens%20Dashboard/An%C3%A1lise%20de%20Alunos%20e%20Escolas%20-%20Looker%20Studio.png)

![Dashboard Power BI](https://raw.githubusercontent.com/carnaubarosario/bi_educacao/main/Imagens%20Dashboard/An%C3%A1lise%20de%20Alunos%20e%20Escolas%20-%20Power%20BI.png)



| Visualização | Justificativa Estratégica |
|---|---|
| Taxa de inadimplência por escola | Identifica unidades com risco financeiro imediato |
| Alunos inativos com movimentação financeira | Expõe inconsistência operacional e risco jurídico |
| Ranking acadêmico por escola | Apoia decisões de alocação pedagógica |

---

## ✍️ Análise de Risco

O maior risco identificado foi de **governança operacional e qualidade dos dados**: alunos marcados como inativos ainda possuíam movimentação financeira ativa, indicando desconexão entre os controles acadêmico e financeiro — com potencial de gerar cobranças indevidas, perda de receita e riscos jurídicos.

**Plano de mitigação em 30 dias:** implementar rotina de auditoria cadastral e financeira conciliando status acadêmico, matrículas e pagamentos, com criação de alertas automáticos para identificação de inconsistências operacionais.

---

## 🛠️ Stack

| Camada | Tecnologia |
|---|---|
| Planilha | Excel + Python (pandas, openpyxl) |
| Banco de Dados | PostgreSQL |
| Queries | SQL com CTEs e Window Functions (DENSE_RANK, ROW_NUMBER) |
| Visualização | Power BI + Looker Studio |
| Versionamento | Git / GitHub |
