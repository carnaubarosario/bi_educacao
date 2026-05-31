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