SELECT 
	pm.ano,
	uf.sigla,
	m.nome,
	SUM(ae.total_vitimas) AS vitimas,
	MAX(pm.populacao) AS populacao,
	CAST(SUM(ae.total_vitimas) AS NUMERIC) / MAX(pm.populacao) * 100000 AS per_100000
FROM AgregacaoEvento ae
	JOIN TipoEvento te ON ae.tipo_evento_id = te.id
	JOIN UF uf ON ae.uf_id = uf.id
	JOIN Municipio m ON ae.municipio_id = m.id
	JOIN PopulacaoMunicipio pm ON 
		pm.municipio_id = m.id AND 
		m.uf_id = uf.id AND
		pm.ano = EXTRACT(YEAR FROM ae.data_referencia)
WHERE 
	te.tem_vitima AND 
	EXTRACT(YEAR FROM data_referencia) = 2024 AND
	pm.populacao > 100000
GROUP BY pm.ano, uf.sigla, m.nome
ORDER BY per_100000 DESC
FETCH FIRST 10 ROWS ONLY;