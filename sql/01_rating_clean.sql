USE desafiofinal;

DROP TABLE IF EXISTS rating_clean;

CREATE TABLE rating_clean (
  idorder VARCHAR(15) NOT NULL,
  rating  TINYINT NULL,
  PRIMARY KEY (idorder)
);

INSERT INTO rating_clean (idorder, rating)
SELECT
  TRIM(`COL 1`) AS idorder,
  CAST(TRIM(`COL 2`) AS UNSIGNED) AS rating
FROM rating
WHERE TRIM(`COL 2`) REGEXP '^[0-5]$'
  AND `COL 1` IS NOT NULL
  AND TRIM(`COL 1`) <> '';

SELECT COUNT(*) AS qtd_rating_clean
FROM rating_clean;

SELECT COUNT(*) AS ratings_com_pedido
FROM rating_clean r
JOIN torder o ON o.idorder = r.idorder;

SELECT COUNT(DISTINCT o.idorder) AS total_pedidos_2014
FROM torder o
WHERE YEAR(o.orderDate) = 2014;

SELECT COUNT(DISTINCT o.idorder) AS pedidos_2014_com_avaliacao
FROM torder o
JOIN rating_clean r ON r.idorder = o.idorder
WHERE YEAR(o.orderDate) = 2014;

SELECT
  100.0 * COUNT(DISTINCT r.idorder) / COUNT(DISTINCT o.idorder) AS pct_pedidos_2014_avaliados
FROM torder o
LEFT JOIN rating_clean r ON r.idorder = o.idorder
WHERE YEAR(o.orderDate) = 2014;

SELECT
  YEAR(o.orderDate) AS ano,
  AVG(r.rating)     AS media_rating,
  COUNT(*)          AS qtd_avaliacoes
FROM rating_clean r
JOIN torder o ON o.idorder = r.idorder
GROUP BY YEAR(o.orderDate)
ORDER BY ano;