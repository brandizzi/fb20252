INSERT INTO AgregacaoEvento (
    id_sinesp_vde, uf_id, municipio_id, tipo_evento_id, data_referencia,
	orgao_agente_id, arma_id, faixa_etaria_id, vitimas_femininas,
	vitimas_masculinas, vitimas_nao_inform,	total_vitimas, total_objetos,
	total_peso, abrangencia_id, formulario_id
)
VALUES (
    9999, (SELECT id FROM UF WHERE sigla = 'DF'), NULL,
	(SELECT id FROM TipoEvento te  WHERE evento = 'Pessoa Desaparecida'),
    '2025-01-01', NULL, NULL, NULL,
    10,   -- Vítimas masculinas
    NULL, -- Vítimas femininas (deveria ter sido informado)
    2,    -- Vítimas de gênero não informado
    12,   -- Total de vítimas
    NULL,  NULL, (SELECT id FROM Abrangencia),
    (SELECT id FROM Formulario WHERE numero = 1)
);
