/* ---------------------------------------------------------------------------
   Desafio Final BI — Projeto 2 (CORE)
   Banco: desafiofinal

   Este arquivo responde (sem depender de país/geo):
   - Período da base de pedidos
   - Total geral de pedidos
   - Total de pedidos em 2014
   - Meses com maior volume de pedidos (sazonalidade) -> contratação temporária
   - Crescimento % de vendas 2013 -> 2014 (campo sales)
   - Produto mais vendido (por faturamento - SUM(sales))
   - Subcategoria menos vendida (por faturamento - SUM(sales))
   - Produto que deveria parar de comercializar (menor SUM(profit))

   Observação:
   - Tabelas principais: torder (pedidos) e sales (itens).
   - Em sales: o campo sales já representa o valor total do item (já * quantidade).
--------------------------------------------------------------------------- */

USE desafiofinal;

-- =========================================================
-- (1) A base de dados compreende pedidos realizados em que período?
-- =========================================================
SELECT
  MIN(o.orderDate) AS dt_inicio,
  MAX(o.orderDate) AS dt_fim
FROM torder o;

-- =========================================================
-- (2) Qual o total geral de pedidos na base de dados?
-- =========================================================
SELECT
  COUNT(DISTINCT o.idorder) AS total_geral_pedidos
FROM torder o;

-- =========================================================
-- (3) Qual o total de pedidos apenas no ano de 2014?
-- =========================================================
SELECT
  COUNT(DISTINCT o.idorder) AS total_pedidos_2014
FROM torder o
WHERE YEAR(o.orderDate) = 2014;

-- =========================================================
-- (14) Tendência: quantidade de pedidos por ano (para a questão de múltipla escolha)
-- =========================================================
SELECT
  YEAR(o.orderDate) AS ano,
  COUNT(DISTINCT o.idorder) AS qtd_pedidos
FROM torder o
GROUP BY YEAR(o.orderDate)
ORDER BY ano;

-- =========================================================
-- (4) Em quais meses indicar contratação de temporários?
--     Estratégia: ver pico por mês (somando todos os anos) e também por mês/ano.
-- =========================================================

-- 4A) Pedidos por mês (agregado em todos os anos)
SELECT
  MONTH(o.orderDate) AS mes_num,
  COUNT(DISTINCT o.idorder) AS qtd_pedidos
FROM torder o
GROUP BY MONTH(o.orderDate)
ORDER BY qtd_pedidos DESC;

-- 4B) Pedidos por mês/ano (para enxergar sazonalidade e picos por ano)
SELECT
  YEAR(o.orderDate) AS ano,
  MONTH(o.orderDate) AS mes_num,
  COUNT(DISTINCT o.idorder) AS qtd_pedidos
FROM torder o
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate)
ORDER BY ano, mes_num;

-- =========================================================
-- (5) Crescimento % de vendas de 2013 para 2014 (apenas campo sales)
-- =========================================================
SELECT
  v.vendas_2013,
  v.vendas_2014,
  ROUND(100.0 * (v.vendas_2014 - v.vendas_2013) / v.vendas_2013, 2) AS pct_crescimento_2013_2014
FROM (
  SELECT
    SUM(CASE WHEN YEAR(o.orderDate) = 2013 THEN s.sales ELSE 0 END) AS vendas_2013,
    SUM(CASE WHEN YEAR(o.orderDate) = 2014 THEN s.sales ELSE 0 END) AS vendas_2014
  FROM sales s
  JOIN torder o ON o.idorder = s.order_idorder
) v;

-- =========================================================
-- (6) Qual o produto mais vendido da empresa em todos anos?
--     Definição adotada: mais vendido por faturamento (SUM(sales)).
-- =========================================================
SELECT
  p.idproduct,
  p.productName,
  ROUND(SUM(s.sales), 2) AS total_sales
FROM sales s
JOIN product p ON p.idproduct = s.product_idproduct
GROUP BY p.idproduct, p.productName
ORDER BY total_sales DESC
LIMIT 1;

-- (Extra) Top 10 produtos por faturamento
SELECT
  p.productName,
  ROUND(SUM(s.sales), 2) AS total_sales
FROM sales s
JOIN product p ON p.idproduct = s.product_idproduct
GROUP BY p.productName
ORDER BY total_sales DESC
LIMIT 10;

-- =========================================================
-- (12) Qual a subcategoria de produtos menos vendida em todos os anos?
--     Definição adotada: menor faturamento (SUM(sales)).
-- =========================================================
SELECT
  sc.idsubCategory,
  sc.subCategory,
  ROUND(SUM(s.sales), 2) AS total_sales
FROM sales s
JOIN product p ON p.idproduct = s.product_idproduct
JOIN subcategory sc ON sc.idsubCategory = p.subCategory_idsubCategory
GROUP BY sc.idsubCategory, sc.subCategory
ORDER BY total_sales ASC
LIMIT 1;

-- =========================================================
-- (13) Considerando o lucro (profit), qual produto a empresa deveria parar de comercializar?
--     Critério: produto com MENOR lucro total (SUM(profit)) no período.
-- =========================================================
SELECT
  p.idproduct,
  p.productName,
  ROUND(SUM(s.profit), 2) AS lucro_total
FROM sales s
JOIN product p ON p.idproduct = s.product_idproduct
GROUP BY p.idproduct, p.productName
ORDER BY lucro_total ASC
LIMIT 1;

-- (Extra) Produtos com lucro total negativo (se existirem)
SELECT
  p.productName,
  ROUND(SUM(s.profit), 2) AS lucro_total
FROM sales s
JOIN product p ON p.idproduct = s.product_idproduct
GROUP BY p.productName
HAVING SUM(s.profit) < 0
ORDER BY lucro_total ASC;
