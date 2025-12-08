SELECT * FROM TipoEvento WHERE tem_vitima;

SELECT EXTRACT(YEAR FROM data_referencia) AS ano, uf.sigla, SUM(ae.total_vitimas) AS vitimas FROM AgregacaoEvento ae
JOIN TipoEvento te ON ae.tipo_evento_id = te.id
JOIN UF uf ON ae.uf_id = uf.id
WHERE te.tem_vitima AND EXTRACT(YEAR FROM data_referencia) = 2024
GROUP BY uf.sigla, ano
ORDER BY vitimas DESC
FETCH FIRST 10 ROWS ONLY;