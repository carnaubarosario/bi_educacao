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