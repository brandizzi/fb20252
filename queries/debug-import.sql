SELECT * FROM Municipio m
WHERE m.id IN (
	SELECT
	   m.id
	FROM AgregacaoEvento_staging ae
	JOIN UF u ON ae.uf = u.sigla
	LEFT OUTER JOIN Municipio m ON ae.municipio = m.nome  m.uf_id = u.id
	JOIN TipoEvento te ON ae.tipo_evento = te.evento
	LEFT OUTER JOIN OrgaoAgente oa ON ae.orgao_agente = oa.orgao
	LEFT OUTER JOIN Arma ar ON ae.arma = ar.nome
	LEFT OUTER JOIN FaixaEtaria fe ON ae.faixa_etaria = fe.faixa
	JOIN Abrangencia ab ON ae.abrangencia = ab.abrangencia
	JOIN Formulario form ON ae.formulario = form.nome
	GROUP BY m.id, ae.data_referencia, ae.municipio, ae.tipo_evento
	HAVING COUNT(*) > 1
)
ORDER BY m.nome;

