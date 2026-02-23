/* ---------------------------------------------------------------------------
   Desafio Final BI — Projeto 2 (GEO)
   Banco: desafiofinal

   Tabelas / joins (conforme seu DESCRIBE):
   torder.customer_idcustomer -> customer.idcustomer
   customer.city_idcity       -> city.idcity
   city.state_idstate         -> state.idstate
   state.country_idcountry    -> country.idcountry

   torder.priority_idpriority -> priority.idpriority

   Observação do enunciado:
   - "custo de envio mais caro": considerar cada envio (= cada pedido),
     então primeiro somamos shippingCost por pedido e depois tiramos a média por país.
--------------------------------------------------------------------------- */

USE desafiofinal;

-- =========================================================
-- (7) Para quantos países distintos a empresa realizou pedidos em todos os anos?
-- =========================================================
SELECT
  COUNT(DISTINCT co.country) AS qtd_paises_distintos
FROM torder o
JOIN customer cu ON cu.idcustomer = o.customer_idcustomer
JOIN city ci ON ci.idcity = cu.city_idcity
JOIN state st ON st.idstate = ci.state_idstate
JOIN country co ON co.idcountry = st.country_idcountry;

-- =========================================================
-- (8) Ranking de países por quantidade de pedidos (todos os anos)
--     + posição do Brazil
-- =========================================================

-- 8A) Pedidos por país (ranking)
SELECT
  co.country,
  COUNT(DISTINCT o.idorder) AS qtd_pedidos
FROM torder o
JOIN customer cu ON cu.idcustomer = o.customer_idcustomer
JOIN city ci ON ci.idcity = cu.city_idcity
JOIN state st ON st.idstate = ci.state_idstate
JOIN country co ON co.idcountry = st.country_idcountry
GROUP BY co.country
ORDER BY qtd_pedidos DESC, co.country;

-- 8B) Posição do Brazil (rank simples, sem window function)
--     Regra de desempate:
--     - Se houver empate em qtd_pedidos, este cálculo devolve "1 + nº de países com MAIS pedidos"
--       (ou seja, empate compartilha a mesma posição).
SELECT
  1 + (
    SELECT COUNT(*)
    FROM (
      SELECT
        co2.country,
        COUNT(DISTINCT o2.idorder) AS qtd_pedidos
      FROM torder o2
      JOIN customer cu2 ON cu2.idcustomer = o2.customer_idcustomer
      JOIN city ci2 ON ci2.idcity = cu2.city_idcity
      JOIN state st2 ON st2.idstate = ci2.state_idstate
      JOIN country co2 ON co2.idcountry = st2.country_idcountry
      GROUP BY co2.country
      HAVING COUNT(DISTINCT o2.idorder) >
        (
          SELECT COUNT(DISTINCT ob.idorder)
          FROM torder ob
          JOIN customer cub ON cub.idcustomer = ob.customer_idcustomer
          JOIN city cib ON cib.idcity = cub.city_idcity
          JOIN state stb ON stb.idstate = cib.state_idstate
          JOIN country cob ON cob.idcountry = stb.country_idcountry
          WHERE cob.country = 'Brazil'
        )
    ) x
  ) AS posicao_brazil;

-- =========================================================
-- (10) Qual país possui, em média, o custo de envio mais caro?
--      (considerar cada envio = cada pedido; somar shippingCost por pedido)
-- =========================================================

-- 10A) País com maior custo médio de envio por pedido
SELECT
  t.country,
  ROUND(AVG(t.shipping_por_pedido), 2) AS media_shipping_por_pedido
FROM (
  SELECT
    o.idorder,
    co.country,
    SUM(s.shippingCost) AS shipping_por_pedido
  FROM torder o
  JOIN sales s ON s.order_idorder = o.idorder
  JOIN customer cu ON cu.idcustomer = o.customer_idcustomer
  JOIN city ci ON ci.idcity = cu.city_idcity
  JOIN state st ON st.idstate = ci.state_idstate
  JOIN country co ON co.idcountry = st.country_idcountry
  GROUP BY o.idorder, co.country
) t
GROUP BY t.country
ORDER BY media_shipping_por_pedido DESC
LIMIT 1;

-- (Extra) Top 10 países com maior custo médio de envio por pedido
SELECT
  t.country,
  ROUND(AVG(t.shipping_por_pedido), 2) AS media_shipping_por_pedido
FROM (
  SELECT
    o.idorder,
    co.country,
    SUM(s.shippingCost) AS shipping_por_pedido
  FROM torder o
  JOIN sales s ON s.order_idorder = o.idorder
  JOIN customer cu ON cu.idcustomer = o.customer_idcustomer
  JOIN city ci ON ci.idcity = cu.city_idcity
  JOIN state st ON st.idstate = ci.state_idstate
  JOIN country co ON co.idcountry = st.country_idcountry
  GROUP BY o.idorder, co.country
) t
GROUP BY t.country
ORDER BY media_shipping_por_pedido DESC
LIMIT 10;

-- =========================================================
-- (11) Qual a prioridade de entrega preferida dos brasileiros?
-- =========================================================
SELECT
  p.priority,
  COUNT(DISTINCT o.idorder) AS qtd_pedidos
FROM torder o
JOIN priority p ON p.idpriority = o.priority_idpriority
JOIN customer cu ON cu.idcustomer = o.customer_idcustomer
JOIN city ci ON ci.idcity = cu.city_idcity
JOIN state st ON st.idstate = ci.state_idstate
JOIN country co ON co.idcountry = st.country_idcountry
WHERE co.country = 'Brazil'
GROUP BY p.priority
ORDER BY qtd_pedidos DESC
LIMIT 1;

/* Fim */
