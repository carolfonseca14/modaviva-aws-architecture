SELECT
    categoria,
    SUM(quantidade) AS unidades_vendidas,
    SUM(valor_venda) AS faturamento,
    SUM(lucro) AS lucro
FROM fato_vendas
WHERE status_pedido = 'CONCLUIDO'
GROUP BY categoria
ORDER BY faturamento DESC;
