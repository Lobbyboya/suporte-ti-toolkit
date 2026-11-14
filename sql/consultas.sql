-- Consultas de conferencia para um ERP de varejo.
-- Rodam sobre o esquema ficticio de esquema.sql. Todas sao somente leitura (SELECT).
-- Cada consulta responde a uma pergunta comum de chamado.

-- 1. "O produto nao passa no caixa" / "a nota foi rejeitada":
--    produtos ativos com cadastro incompleto (sem codigo de barras, sem NCM ou sem preco).
SELECT id, descricao,
       CASE WHEN codigo_barras IS NULL OR codigo_barras = '' THEN 'sem codigo de barras' END AS barras,
       CASE WHEN ncm IS NULL OR ncm = '' THEN 'sem NCM' END AS fiscal,
       CASE WHEN preco_venda IS NULL OR preco_venda <= 0 THEN 'sem preco' END AS preco
FROM produto
WHERE ativo = 1
  AND (codigo_barras IS NULL OR codigo_barras = ''
       OR ncm IS NULL OR ncm = ''
       OR preco_venda IS NULL OR preco_venda <= 0)
ORDER BY descricao;

-- 2. "O leitor passa um produto e aparece outro":
--    codigos de barras usados por mais de um produto ativo.
SELECT codigo_barras, COUNT(*) AS produtos, GROUP_CONCAT(descricao, ' | ') AS descricoes
FROM produto
WHERE ativo = 1 AND codigo_barras IS NOT NULL AND codigo_barras <> ''
GROUP BY codigo_barras
HAVING COUNT(*) > 1;

-- 3. "O estoque do sistema nao bate com a prateleira":
--    produtos com estoque negativo (venda sem entrada lancada).
SELECT p.id, p.descricao, e.quantidade
FROM estoque e
JOIN produto p ON p.id = e.produto_id
WHERE e.quantidade < 0
ORDER BY e.quantidade;

-- 4. "O fechamento do caixa deu diferenca":
--    vendas nao canceladas em que a soma dos pagamentos difere do total.
SELECT v.id, v.caixa, v.data_hora, v.total,
       COALESCE(SUM(vp.valor), 0) AS pago,
       ROUND(v.total - COALESCE(SUM(vp.valor), 0), 2) AS diferenca
FROM venda v
LEFT JOIN venda_pagamento vp ON vp.venda_id = v.id
WHERE v.cancelada = 0
GROUP BY v.id, v.caixa, v.data_hora, v.total
HAVING ROUND(v.total - COALESCE(SUM(vp.valor), 0), 2) <> 0
ORDER BY v.data_hora;

-- 5. Resumo do dia por caixa e forma de pagamento, para conferir com o fechamento.
SELECT v.caixa, vp.forma, COUNT(DISTINCT v.id) AS vendas, ROUND(SUM(vp.valor), 2) AS total
FROM venda v
JOIN venda_pagamento vp ON vp.venda_id = v.id
WHERE v.cancelada = 0 AND DATE(v.data_hora) = '2026-11-10'
GROUP BY v.caixa, vp.forma
ORDER BY v.caixa, vp.forma;
