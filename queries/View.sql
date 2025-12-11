CREATE VIEW Latrocino
as SELECT
    ae.id,
    id_sinesp_vde,
    data_referencia,
    vitimas_femininas,
    vitimas_masculinas,
    vitimas_nao_inform,
    total_vitimas
FROM AgregacaoEvento ae
JOIN TipoEvento te ON ae.tipo_evento_id = te.id
WHERE te.evento LIKE 'Roubo seguido de morte (latrocínio)';
