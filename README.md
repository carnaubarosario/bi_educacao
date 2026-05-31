📊 BI Educação - Análise de Escolas

Projeto de Business Intelligence para o setor educacional com foco em auditoria de dados, análise financeira e desempenho acadêmico. O objetivo foi auditar a qualidade dos dados de uma rede de escolas parceiras e extrair indicadores operacionais prioritários, cobrindo inconsistências cadastrais, inadimplência financeira e desempenho acadêmico.

🗂️ Estrutura do Repositório
bi_educacao/
├── Modulo1/                          # Excel — Auditoria e faixa de desempenho
│   ├── LuccaCarnauba_modulo1.xlsx    # Base resolvida com log_erros e faixa_desempenho
│   ├── Script_Leitura.ipynb          # Script Python para validação automatizada
│   └── requirements.txt
├── Modulo2/                          # SQL — Análises financeiras e acadêmicas
│   ├── Queries_Analiticas.sql        # Consolidação de todas as queries
│   ├── Query1_Inadimplencia.sql
│   ├── Query2_Alunos_Inativos.sql
│   └── Query3_Ranking_Academico.sql
├── Modulo3/                          # Dashboard BI
│   ├── Dashboard_EducaAnalytics.pbix
│   ├── Campos_Calculados_Looker.txt
│   ├── Resumo_EducaAnalytics.pdf
│   └── Imagens/
│       ├── Dashboard_Looker_Studio.png
│       └── Dashboard_Power_BI.png
├── Modulo4/
│   └── Analise_Escrita.pdf           # Análise de risco e plano de mitigação
├── Documentacoes/
│   ├── Documentacao_Complementar.pdf
│   ├── Documentacao_Medidas_DAX.xlsx
│   └── Documentacao_Script_Python.pdf
└── Script_View.sql                   # Proposta de view analítica consolidada

🛢️ Conexão com o Banco de Dados
O banco é um PostgreSQL hospedado no Supabase, disponibilizado em modo leitura.
String de conexão:
postgresql://candidato.crebcpokyhcfjqkdwytt:senha_candidato_scalare@aws-0-us-west-2.pooler.supabase.com:6543/postgres
Ferramentas recomendadas: DBeaver, TablePlus ou DataGrip.
No DBeaver, crie uma nova conexão PostgreSQL e preencha os campos com os dados acima, ou cole diretamente a string de conexão no campo JDBC URL.
Schema disponível — 6 tabelas
TabelaDescriçãoescolasCadastro das unidades (id, nome, cidade, tipo)alunosCadastro de alunos com status ativo/inativoturmasTurmas por escola, série e turnomatriculasRelacionamento aluno × turma × ano letivopagamentosMensalidades com status pago/pendente/isentoavaliacoesNotas por disciplina, bimestre e ano

📋 Desafios Propostos
Módulo 1 — Excel: Auditoria de Qualidade
A base dados_alunos foi fornecida sem tratamento prévio. Os desafios foram:

Auditoria de qualidade: criar a aba log_erros registrando inconsistências por linha, coluna, tipo de problema e valor encontrado.
Faixa de desempenho: criar a coluna faixa_desempenho na base, classificando os alunos conforme a nota.
Insight: identificar o dado que exige maior atenção operacional.

Módulo 2 — SQL: Saúde Financeira e Operacional
Com acesso somente leitura ao banco PostgreSQL, os desafios foram:

Saúde financeira: analisar inadimplência geral, identificar alunos inativos com rotinas financeiras ativas e detectar duplicidades sistêmicas.
Qualidade de ensino: gerar ranking dos Top 3 alunos por escola usando Window Functions.

Módulo 3 — Dashboard BI

Projetar um resumo executivo com no máximo 3 visualizações, justificando a prioridade estratégica de cada indicador.

Módulo 4 — Análise Escrita

Identificar o maior risco de governança encontrado e propor um plano de mitigação em 30 dias.


🔍 Como Foi Desenvolvido
Módulo 1 — Excel
A faixa de desempenho foi criada diretamente no Excel com a fórmula:
excel=SE(OU(G2="";NÃO(ÉNÚM(G2));G2<0;G2>10);"Inválido";SE(G2<5;"Baixo";SE(G2<8;"Médio";"Alto")))
A fórmula trata quatro situações de erro antes de classificar: campo vazio, valor não numérico, nota abaixo de 0 e nota acima de 10. Registros inválidos foram documentados na aba log_erros.
Além da abordagem manual no Excel, foi desenvolvido um script Python (Script_Leitura.ipynb) com pandas e openpyxl para automatizar a leitura e validação da base, documentado em Documentacoes/Documentacao_Script_Python.pdf.

Módulo 2 — SQL
Todas as queries foram construídas com CTEs encadeadas para separar claramente cada etapa da lógica. Cada arquivo possui comentários explicativos no cabeçalho e conclusões numéricas ao final.

Módulo 3 — Dashboard
O dashboard foi desenvolvido em duas ferramentas: Power BI (arquivo .pbix disponível no repositório) e Looker Studio (link público abaixo). Os campos calculados utilizados no Looker estão documentados em Modulo3/Campos_Calculados_Looker.txt.

🔗 [Acessar dashboard no Looker Studio](https://datastudio.google.com/reporting/d6142069-5699-4d2e-917e-fb42e3cdb2f9)

🛠️ Queries SQL — Detalhamento
Query 1 — Análise de Inadimplência por Escola
Arquivo: Query1_Inadimplencia.sql
Lógica:

Duplicidades removidas via ROW_NUMBER() particionando por aluno_id, mes_ref, status e valor.
Inadimplência calculada sobre a base deduplificada.
Consistência entre status e data_pagamento validada — pagamentos pendentes devem ter data_pagamento nula.
Cada escola recebe classificação de risco (Acima da média, Abaixo da média, Na média) comparada à taxa geral.

Conclusão: 720 pagamentos registrados, 193 pendentes — taxa geral de inadimplência de 26,8%. O Colégio Horizonte apresentou ~40% de inadimplência e ~R$ 33.600 em valores a receber. O Colégio Futuro, apesar de taxa abaixo da média, concentra o maior valor absoluto pendente da operação.

Query 2 — Alunos Inativos com Movimentação Financeira Ativa
Arquivo: Query2_Alunos_Inativos.sql
Lógica:

Alunos com ativo = FALSE cruzados com a tabela de pagamentos.
Critério de atividade financeira: pagamentos com status = 'pendente' ou pagamentos realizados nos últimos 90 dias a partir da maior data da base.
O período de 90 dias foi calculado dinamicamente via CTE data_referencia, evitando hardcode de datas.
Resultado agrupado por aluno, com totais de movimentações, valor pendente e distribuição por turno e série.

Conclusão: 6 alunos inativos com movimentação financeira ativa, totalizando R$ 36.330 movimentados e R$ 26.250 em valor pendente. Alunos do 1º ano representam 66,67% dos casos. Escolas envolvidas: Colégio Futuro, Instituto EduTech, Escola Conecta, Colégio Horizonte e Centro Educacional Viva.

Query 3 — Ranking Acadêmico: Top 3 por Escola
Arquivo: Query3_Ranking_Academico.sql
Lógica:

Média individual calculada com AVG() agrupado por aluno.
Ranking por escola gerado com DENSE_RANK() OVER (PARTITION BY escola ORDER BY media_aluno DESC).
Ranking geral gerado com DENSE_RANK() OVER (ORDER BY media_aluno DESC).
DENSE_RANK foi escolhido no lugar de ROW_NUMBER para que alunos com médias iguais recebam a mesma posição, sem penalização por empate.
Filtro WHERE ranking_escola <= 3 aplicado no SELECT final.

Conclusão: Centro Educacional Viva apresentou a maior média geral entre as escolas. Os 3 melhores alunos individualmente pertencem à Escola Conecta — que concentra talentos de ponta mas não sustenta a performance de forma consistente em toda a turma. Hugo Cavalcanti (Escola Conecta) se destaca por estar no top 3 geral de médias e ter nota máxima 10.

Script View — Camada Analítica Consolidada
Arquivo: Script_View.sql
Proposta de view analítica que desnormaliza todas as tabelas em uma única camada pronta para consumo no Power BI, com indicadores calculados por aluno: taxa de inadimplência, valor pendente, média acadêmica, classificação de risco financeiro e classificação de desempenho.

A criação da view não foi executada devido às permissões restritas do ambiente (somente leitura), mas a estrutura foi proposta para demonstrar uma possível camada analítica de produção.


📈 Dashboard BI
Ferramentas: Power BI + Looker Studio
🔗 [Acessar dashboard no Looker Studio](https://datastudio.google.com/reporting/d6142069-5699-4d2e-917e-fb42e3cdb2f9)

Visualização                                                                  Justificativa
Taxa de inadimplência por escola                                Identifica unidades com risco financeiro imediato
Alunos inativos com movimentação financeira                      Expõe inconsistência operacional e risco jurídico
Ranking acadêmico por escola                                          Apoia decisões de alocação pedagógica

✍️ Análise de Risco — Módulo 4
O maior risco identificado foi de governança operacional e qualidade dos dados: alunos marcados como inativos ainda possuíam movimentação financeira ativa, indicando desconexão entre os controles acadêmico e financeiro — com potencial de gerar cobranças indevidas, perda de receita e riscos jurídicos. O Colégio Horizonte apresentou ~40% de inadimplência, enquanto o Colégio Futuro concentrou o maior valor pendente absoluto.

Plano de mitigação em 30 dias: implementar rotina de auditoria cadastral e financeira conciliando status acadêmico, matrículas e pagamentos, com criação de alertas automáticos para identificação de inconsistências operacionais.

🛠️ Stack
- Excel 
- Python
- PostgreSQL
- Queries com Window Functions
- Power BI
- Looker Studio
- GitHub
