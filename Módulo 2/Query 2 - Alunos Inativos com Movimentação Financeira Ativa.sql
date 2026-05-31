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