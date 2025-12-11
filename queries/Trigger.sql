CREATE FUNCTION numero_vitimas_faltando(ae AgregacaoEvento) RETURNS BOOLEAN
AS $$
BEGIN
    RETURN ae.vitimas_masculinas IS NULL OR
            ae.vitimas_femininas IS NULL OR
            ae.vitimas_nao_inform IS NULL OR
            ae.total_vitimas IS NULL;
END;
$$
LANGUAGE plpgsql;

CREATE FUNCTION garante_contagens() RETURNS TRIGGER
AS $$
DECLARE
    tipo_evento TipoEvento%ROWTYPE;
BEGIN
    SELECT * INTO tipo_evento
    FROM TipoEvento te
    WHERE NEW.tipo_evento_id = te.id;

    IF NEW.total_peso IS NULL AND tipo_evento.tem_peso THEN
        RAISE EXCEPTION 
            'Evento % exige peso mas total_peso é NULL',
            tipo_evento.evento;
    END IF;

    IF NEW.total_objetos IS NULL AND tipo_evento.tem_objeto THEN
        RAISE EXCEPTION 
            'Evento % exige total mas total é NULL', 
            tipo_evento.evento;
    END IF;

    IF numero_vitimas_faltando(NEW) AND tipo_evento.tem_vitima THEN
        RAISE EXCEPTION 
            'Evento % exige numero de vítimas mas uma ou mais colunas são NULL',
            tipo_evento.evento;
    END IF;

    IF NEW.faixa_etaria_id IS NULL AND tipo_evento.tem_faixa_etaria THEN
        RAISE EXCEPTION 
            'Evento % exige faixa etária mas faixa_etária é NULL', 
            tipo_evento.evento;
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER verifica_contagens
BEFORE INSERT OR UPDATE ON AgregacaoEvento
FOR EACH ROW EXECUTE FUNCTION  garante_contagens();
