-- ============================================================
-- Query 1 - Indicador geral de inadimplência e consistência financeira
--
-- Lógica:
-- Considero como inadimplência os pagamentos com status = 'pendente'.
-- Além disso, valido a consistência entre status e data_pagamento,
-- considerando que pagamentos pendentes devem possuir
-- data_pagamento nula.
--
-- Também realizo uma contagem geral de valores nulos na coluna
-- data_pagamento para avaliar a qualidade e consistência do
-- preenchimento financeiro da base.
--
-- Conclusão no final da query
-- ============================================================

WITH pagamentos_marcados AS (

    SELECT
        p.*,

        ROW_NUMBER() OVER (
            PARTITION BY aluno_id, mes_ref, status, valor
            ORDER BY pagamento_id
        ) AS ordem_registro

    FROM pagamentos p
),

pagamentos_sem_duplicidade AS (

    SELECT *
    FROM pagamentos_marcados
    WHERE ordem_registro = 1
),

indicador_geral AS (

    SELECT
        COUNT(*) AS total_pagamentos_geral,

        COUNT(*) FILTER (
            WHERE status = 'pendente'
        ) AS pagamentos_pendentes_geral,

        ROUND(
            COUNT(*) FILTER (
                WHERE status = 'pendente'
            )::numeric / NULLIF(COUNT(*), 0) * 100,
            2
        ) AS taxa_inadimplencia_geral,

        COUNT(*) FILTER (
            WHERE data_pagamento IS NULL
        ) AS pagamentos_sem_data_pagamento,

        COUNT(*) FILTER (
            WHERE status = 'pendente'
              AND data_pagamento IS NULL
        ) AS pendentes_sem_pagamento,

        COUNT(*) FILTER (
            WHERE status = 'pago'
              AND data_pagamento IS NULL
        ) AS pagos_sem_data_pagamento

    FROM pagamentos_sem_duplicidade
),

indicador_escola AS (

    SELECT
        e.nome AS escola,
        e.cidade,
        e.tipo,

        COUNT(*) AS total_pagamentos_escola,

        COUNT(*) FILTER (
            WHERE p.status = 'pendente'
        ) AS pagamentos_pendentes_escola,

        ROUND(
            COUNT(*) FILTER (
                WHERE p.status = 'pendente'
            )::numeric / NULLIF(COUNT(*), 0) * 100,
            2
        ) AS taxa_inadimplencia_escola,

        COALESCE(
            SUM(p.valor) FILTER (
                WHERE p.status = 'pendente'
            ),
            0
        ) AS valor_pendente_escola

    FROM pagamentos_sem_duplicidade p

    JOIN alunos a
        ON a.aluno_id = p.aluno_id

    JOIN escolas e
        ON e.escola_id = a.escola_id

    GROUP BY
        e.nome,
        e.cidade,
        e.tipo
)

SELECT
    ie.escola,
    ie.cidade,
    ie.tipo,

    ie.total_pagamentos_escola,
    ie.pagamentos_pendentes_escola,
    ie.taxa_inadimplencia_escola,

    ig.total_pagamentos_geral,
    ig.pagamentos_pendentes_geral,
    ig.taxa_inadimplencia_geral,

    ig.pagamentos_sem_data_pagamento,
    ig.pendentes_sem_pagamento,
    ig.pagos_sem_data_pagamento,

    ROUND(
        ie.taxa_inadimplencia_escola - ig.taxa_inadimplencia_geral,
        2
    ) AS diferenca_vs_media_geral,

    ie.valor_pendente_escola,

    CASE
        WHEN ie.taxa_inadimplencia_escola > ig.taxa_inadimplencia_geral
            THEN 'Acima da média geral'

        WHEN ie.taxa_inadimplencia_escola < ig.taxa_inadimplencia_geral
            THEN 'Abaixo da média geral'

        ELSE 'Na média geral'
    END AS classificacao_risco

FROM indicador_escola ie

CROSS JOIN indicador_geral ig

ORDER BY
    ie.taxa_inadimplencia_escola DESC,
    ie.valor_pendente_escola DESC;

-- ============================================================
-- Conclusão:
--
-- Foram registrados 720 pagamentos, sendo 193 pendentes,
-- representando uma taxa geral de inadimplência de 26,8%.
--
-- A escola futuro apresenta taxa de inadimplência abaixo da média,
-- porém com o mais alto valor a receber entre todas as escolas analisadas.
-- Sugere-se uma auditoria de controle de contas para verificar quais é a concentração
-- dos maiores débitos, além do fortalecimento do processo de cobrança formal
--
-- A escola Horizonte apresentou o maior índice de inadimplência
-- entre as unidades analisadas, com aproximadamente 40% de
-- pagamentos pendentes e cerca de R$ 33.600 em valores a receber.
--
-- O cenário indica necessidade de priorização operacional da unidade,
-- especialmente em processos de cobrança e recuperação financeira.
-- Ações como automação de cobranças, campanhas de renegociação e
-- acompanhamento recorrente da inadimplência podem contribuir para
-- redução do indicador.
--
-- Não foram encontradas inconsistências entre status e
-- data_pagamento, indicando consistência da regra financeira
-- aplicada na base analisada.
-- ============================================================

-- ============================================================
-- Query 2 - Alunos inativos com rotina financeira ativa ou recente
--
-- Lógica:
-- Identifico alunos marcados como inativos que ainda possuem
-- movimentação financeira pendente ou pagamentos recentes.
--
-- Para a análise, considero como atividade financeira:
--
-- 1. Pagamentos pendentes
-- 2. Pagamentos realizados nos últimos 90 dias da base
--
-- O objetivo é identificar possíveis inconsistências operacionais
-- entre o status acadêmico do aluno e sua movimentação financeira.
-- ============================================================

WITH data_referencia AS (

    SELECT
        MAX(mes_ref) AS maior_data_base
    FROM pagamentos
),

base_alunos_inativos AS (

    SELECT
        a.aluno_id,
        a.nome AS aluno,
        e.nome AS escola,
        e.cidade,
        t.serie,
        t.turno,
        a.ativo,

        p.pagamento_id,
        p.status,
        p.valor,
        p.mes_ref,
        p.data_pagamento

    FROM alunos a

    JOIN pagamentos p
        ON p.aluno_id = a.aluno_id

    JOIN escolas e
        ON e.escola_id = a.escola_id

    LEFT JOIN matriculas m
        ON m.aluno_id = a.aluno_id

    LEFT JOIN turmas t
        ON t.turma_id = m.turma_id

    WHERE a.ativo = FALSE
      AND (
            p.status = 'pendente'
            OR p.data_pagamento >= (
                SELECT maior_data_base - INTERVAL '90 days'
                FROM data_referencia
            )
      )
),

resumo_aluno AS (

    SELECT
        aluno_id,
        aluno,
        escola,
        cidade,
        serie,
        turno,
        ativo,

        COUNT(pagamento_id) AS total_movimentacoes,

        COUNT(*) FILTER (
            WHERE status = 'pendente'
        ) AS pagamentos_pendentes,

        COUNT(*) FILTER (
            WHERE status = 'pago'
              AND data_pagamento >= (
                  SELECT maior_data_base - INTERVAL '90 days'
                  FROM data_referencia
              )
        ) AS pagamentos_recentes,

        SUM(valor) AS valor_total_movimentado,

        SUM(valor) FILTER (
            WHERE status = 'pendente'
        ) AS valor_pendente,

        MAX(mes_ref) AS ultimo_mes_ref

    FROM base_alunos_inativos

    GROUP BY
        aluno_id,
        aluno,
        escola,
        cidade,
        serie,
        turno,
        ativo
),

total_inativos AS (

    SELECT
        COUNT(DISTINCT aluno_id) AS total_alunos_inativos
    FROM resumo_aluno
),

resumo_turno AS (

    SELECT
        turno,

        COUNT(DISTINCT aluno_id) AS alunos_inativos_turno,

        ROUND(
            COUNT(DISTINCT aluno_id)::numeric
            / NULLIF((SELECT total_alunos_inativos FROM total_inativos), 0) * 100,
            2
        ) AS percentual_inativos_turno

    FROM resumo_aluno

    GROUP BY
        turno
),

resumo_serie AS (

    SELECT
        serie,

        COUNT(DISTINCT aluno_id) AS alunos_inativos_serie,

        ROUND(
            COUNT(DISTINCT aluno_id)::numeric
            / NULLIF((SELECT total_alunos_inativos FROM total_inativos), 0) * 100,
            2
        ) AS percentual_inativos_serie

    FROM resumo_aluno

    GROUP BY
        serie
)

SELECT
    ra.aluno_id,
    ra.aluno,
    ra.escola,
    ra.cidade,
    ra.serie,
    ra.turno,
    ra.ativo,

    ra.total_movimentacoes,
    ra.pagamentos_pendentes,
    ra.pagamentos_recentes,
    ra.valor_total_movimentado,
    ra.valor_pendente,
    ra.ultimo_mes_ref,

    rt.alunos_inativos_turno,
    rt.percentual_inativos_turno,

    rs.alunos_inativos_serie,
    rs.percentual_inativos_serie

FROM resumo_aluno ra

LEFT JOIN resumo_turno rt
    ON rt.turno = ra.turno

LEFT JOIN resumo_serie rs
    ON rs.serie = ra.serie

ORDER BY
    ra.valor_pendente DESC,
    ra.valor_total_movimentado DESC;


-- ============================================================
-- Conclusão:
--
-- Foram encontrados 6 alunos com status de inativos e rotinas financeiras ativas
-- ou recentes em um período de 90 dias definidos em critério adotado para esta análise.
--
-- Os alunos inativos encontrados foram: Henrique Alves e Diego Pereira do Colégio Futuro,
-- Queila Torres do Instituto EduTech, Fernando Melo da Escola Conecta, Eduardo Queiroz 
-- do Colégio Horizonte e Samuel Macedo do Centro Educacional Viva. O valor total movimentado
-- por esses alunos no período de 90 dias é de R$36.330 e R$26.250 de valor pendente.
--
-- Os alunos do 1º ano apresentam o maior percentual de inativos, representando 4 alunos no total
-- e 66,67% dos alunos inativos. 
--
-- O cenário indica possível desalinhamento entre o cadastro acadêmico e a rotina financeira das escolas. 
-- Recomenda-se revisão cadastral dos alunos identificados, validação da situação acadêmica junto às unidades 
-- e acompanhamento dos débitos pendentes para regularização financeira.
-- ============================================================

-- ============================================================
-- Query 3 - Qualidade de ensino e alunos destaque
--
-- Objetivo:
-- Identificar os alunos com melhor desempenho acadêmico e
-- comparar a performance média das escolas.
--
-- A análise considera:
-- - média geral das escolas
-- - maiores notas individuais
-- - alunos com maiores médias
-- - Top 3 alunos por escola
--
-- O objetivo é avaliar tanto excelência individual quanto
-- consistência acadêmica das unidades.
--
-- Para o ranqueamento dos alunos foi utilizada a função
-- DENSE_RANK(), permitindo que alunos com a mesma média
-- recebam a mesma posição no ranking.
--
-- Essa abordagem foi escolhida para evitar penalização de
-- alunos com desempenho equivalente e manter coerência na
-- classificação acadêmica.
--
-- Exemplo:
-- Caso dois alunos possuam média 9,5, ambos receberão
-- posição 1 no ranking, e o próximo aluno será classificado
-- como posição 2.
-- ============================================================

WITH desempenho_alunos AS (

    SELECT
        a.aluno_id,
        a.nome AS aluno,

        e.nome AS escola,
        e.cidade,
        e.tipo,

        COUNT(av.avaliacao_id) AS total_avaliacoes,

        ROUND(AVG(av.nota), 2) AS media_aluno,

        MAX(av.nota) AS maior_nota_aluno,

        MIN(av.nota) AS menor_nota_aluno

    FROM avaliacoes av

    JOIN alunos a
        ON a.aluno_id = av.aluno_id

    JOIN escolas e
        ON e.escola_id = a.escola_id

    GROUP BY
        a.aluno_id,
        a.nome,
        e.nome,
        e.cidade,
        e.tipo
),

media_escola AS (

    SELECT
        escola,

        ROUND(
            AVG(media_aluno),
            2
        ) AS media_geral_escola,

        MAX(maior_nota_aluno) AS maior_nota_escola

    FROM desempenho_alunos

    GROUP BY
        escola
),

ranking_escola AS (

    SELECT
        da.*,

        me.media_geral_escola,

        me.maior_nota_escola,

        DENSE_RANK() OVER (
            PARTITION BY da.escola
            ORDER BY da.media_aluno DESC
        ) AS ranking_escola,

        DENSE_RANK() OVER (
            ORDER BY da.media_aluno DESC
        ) AS ranking_geral

    FROM desempenho_alunos da

    JOIN media_escola me
        ON me.escola = da.escola
)

SELECT
    escola,
    cidade,
    tipo,

    aluno,

    total_avaliacoes,

    media_aluno,

    maior_nota_aluno,

    menor_nota_aluno,

    media_geral_escola,

    maior_nota_escola,

    ranking_escola,

    ranking_geral

FROM ranking_escola

WHERE ranking_escola <= 3

ORDER BY
    media_geral_escola DESC,
    escola,
    ranking_escola;


-- ============================================================
-- Conclusão:
--
-- Após a análise das 20 avaliações realizadas:
--
-- O Centro Educacional Viva apresentou a maior média geral entre as escolas, porém os 3 alunos individualmente mais bem ranqueados 
-- pertencem à Escola Conecta, ou seja, a Escola Conecta concentra talentos de ponta, mas não sustenta essa performance de 
-- forma consistente em toda a turma
-- 
-- Os alunos William Albuquerque do Centro Educacional Viva, Hugo Cavalcanti e Leonardo Vieira da Escola Conecta são os top 3 alunos
-- com melhores médias, com 8,18, 8,14 e 8,12 de média, respectivamente. Já os alunos Hugo Cavalcanti da Escola Conecta,
-- Marina Gomes do Colégio Futuro e Thiago Cardoso do Instituto EduTech obtiveram as maiores notas individuais 
-- entre os alunos analisados, todos com nota 10.
--
-- O aluno Hugo Cavalcanti merece o maior destaque entre todos os top 3 alunos das escolas analisadas. Hugo está no top 3 geral
-- de médias e também tem nota máxima. 
-- 
-- O Centro Educacional Viva, Escola Conecta, Colégio Futuro e Instituto EduTech apresentam médias muito próximas, com diferença
-- máxima de 0,34 na média.

-- De forma geral, as escolas apresentaram médias próximas uma das outras, com exceção do Colégio Horizonte, apresentando diferença
-- de aproximadamente 2 pontos abaixo das demais escolas.
--
-- Recomenda-se investigar práticas pedagógicas, acompanhamento extraclasse, frequência e evolução das notas por disciplina,
-- especialmente no Colégio Horizonte, antes de propor ações corretivas específicas.
-- ============================================================