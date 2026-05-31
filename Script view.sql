-- ============================================================
-- VIEW ANALÍTICA CONSOLIDADA | EDUCAÇÃO
--
-- Objetivo:
-- Consolidar indicadores financeiros, acadêmicos e operacionais
-- em uma única camada analítica para consumo no Power BI.
--
-- Observação:
-- A criação da VIEW não pôde ser executada devido às permissões
-- restritas do ambiente disponibilizado no case.
--
-- Mesmo assim, a estrutura foi proposta para demonstrar uma
-- possível camada analítica consolidada.
-- ============================================================

WITH pagamentos_agg AS (

    SELECT
        p.aluno_id,

        COUNT(p.pagamento_id) AS total_pagamentos,

        COUNT(*) FILTER (
            WHERE p.status = 'pendente'
        ) AS pagamentos_pendentes,

        ROUND(
            COUNT(*) FILTER (
                WHERE p.status = 'pendente'
            )::numeric
            / NULLIF(COUNT(*), 0) * 100,
            2
        ) AS taxa_inadimplencia_aluno,

        COALESCE(
            SUM(p.valor),
            0
        ) AS valor_total_pagamentos,

        COALESCE(
            SUM(p.valor) FILTER (
                WHERE p.status = 'pendente'
            ),
            0
        ) AS valor_pendente,

        MAX(p.mes_ref) AS ultimo_mes_referencia,

        MAX(p.data_pagamento) AS ultimo_pagamento

    FROM pagamentos p

    GROUP BY
        p.aluno_id
),

avaliacoes_agg AS (

    SELECT
        av.aluno_id,

        ROUND(
            AVG(av.nota),
            2
        ) AS media_aluno,

        MAX(av.nota) AS maior_nota_aluno,

        MIN(av.nota) AS menor_nota_aluno,

        COUNT(av.avaliacao_id) AS total_avaliacoes

    FROM avaliacoes av

    GROUP BY
        av.aluno_id
)

SELECT
    e.escola_id,
    e.nome AS escola,
    e.cidade,
    e.tipo,

    a.aluno_id,
    a.nome AS aluno,

    a.data_matricula,
    a.ativo,

    t.serie,
    t.turno,

    m.ano_letivo,

    COALESCE(pa.total_pagamentos, 0)
        AS total_pagamentos,

    COALESCE(pa.pagamentos_pendentes, 0)
        AS pagamentos_pendentes,

    COALESCE(pa.taxa_inadimplencia_aluno, 0)
        AS taxa_inadimplencia_aluno,

    COALESCE(pa.valor_total_pagamentos, 0)
        AS valor_total_pagamentos,

    COALESCE(pa.valor_pendente, 0)
        AS valor_pendente,

    pa.ultimo_mes_referencia,

    pa.ultimo_pagamento,

    COALESCE(av.media_aluno, 0)
        AS media_aluno,

    COALESCE(av.maior_nota_aluno, 0)
        AS maior_nota_aluno,

    COALESCE(av.menor_nota_aluno, 0)
        AS menor_nota_aluno,

    COALESCE(av.total_avaliacoes, 0)
        AS total_avaliacoes,

    CASE
        WHEN pa.taxa_inadimplencia_aluno >= 50
            THEN 'Alto Risco'

        WHEN pa.taxa_inadimplencia_aluno >= 25
            THEN 'Médio Risco'

        ELSE 'Baixo Risco'
    END AS classificacao_risco_financeiro,

    CASE
        WHEN av.media_aluno >= 8
            THEN 'Alto Desempenho'

        WHEN av.media_aluno >= 6
            THEN 'Desempenho Médio'

        ELSE 'Baixo Desempenho'
    END AS classificacao_desempenho

FROM alunos a

JOIN escolas e
    ON e.escola_id = a.escola_id

LEFT JOIN matriculas m
    ON m.aluno_id = a.aluno_id

LEFT JOIN turmas t
    ON t.turma_id = m.turma_id

LEFT JOIN pagamentos_agg pa
    ON pa.aluno_id = a.aluno_id

LEFT JOIN avaliacoes_agg av
    ON av.aluno_id = a.aluno_id;