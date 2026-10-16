SELECT
    CASE
        WHEN id_campanha IS NULL THEN 'Fora de campanha'
        ELSE 'Em campanha'
    END AS periodo,
    COUNT(DISTINCT id_pedido) AS pedidos,
    SUM(valor_venda) AS faturamento,
    SUM(lucro) AS lucro
FROM fato_vendas
WHERE status_pedido = 'CONCLUIDO'
GROUP BY
    CASE
        WHEN id_campanha IS NULL THEN 'Fora de campanha'
        ELSE 'Em campanha'
    END
ORDER BY periodo;
