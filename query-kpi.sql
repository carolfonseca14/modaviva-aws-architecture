SELECT
    COUNT(DISTINCT id_pedido) AS pedidos,
    SUM(quantidade) AS produtos_vendidos,
    SUM(valor_venda) AS faturamento,
    SUM(lucro) AS lucro
FROM fato_vendas
WHERE status_pedido = 'CONCLUIDO';
