SELECT
    CAST(data_hora_venda AS DATE) AS data,
    COUNT(DISTINCT id_pedido) AS pedidos,
    SUM(quantidade) AS unidades_vendidas,
    SUM(valor_venda) AS faturamento,
    SUM(lucro) AS lucro
FROM fato_vendas
WHERE status_pedido = 'CONCLUIDO'
GROUP BY CAST(data_hora_venda AS DATE)
ORDER BY data;
