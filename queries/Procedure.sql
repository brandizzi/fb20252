CREATE PROCEDURE CRIAR_VIEWS_PARA_TIPOS_DE_EVENTOS() AS
$$
DECLARE
    te_id TipoEvento.id%TYPE;
    nome TipoEvento.evento%TYPE;
    nome_view TEXT;
    boa_noticia TEXT[] := ARRAY['Pessoa Localizada'];
BEGIN
    FOR te_id, nome, nome_view IN 
        SELECT 
            id,
            evento
        FROM TipoEvento te
        WHERE te.tem_vitima
    LOOP
         -- Definindo nome das views
        nome_view := TRANSLATE(nome, '- ãáâàéêíõóôú()', '__aaaaeeiooou');
        nome_view := 'V_' || nome_view;
        IF LENGTH(nome_view) > 64 THEN
            RAISE NOTICE '% truncated', nome_view;
            nome_view := SUBSTRING(nome_view, 1, 63);
        END IF;

        -- Criando a view
        EXECUTE format(
            'CREATE OR REPLACE VIEW %I AS
            SELECT
                ae.id,
                id_sinesp_vde,
                data_referencia,
                u.nome as uf,
                m.nome as municipio,
                ae.vitimas_femininas,
                ae.vitimas_masculinas,
                ae.vitimas_nao_inform,
                ae.total_vitimas
            FROM AgregacaoEvento ae
            JOIN TipoEvento te ON ae.tipo_evento_id = te.id
            JOIN UF u ON ae.uf_id = u.id
            LEFT OUTER JOIN Municipio m 
              ON ae.municipio_id = m.id AND m.uf_id = u.id
            WHERE te.id = %s',
            nome_view,
            te_id);

        -- Se a view não é um "crime" renomeamos colunas por
        -- naõ ter vítimas
        IF nome = ANY(boa_noticia) THEN
            EXECUTE format(
                'ALTER VIEW %I
                RENAME COLUMN vitimas_masculinas TO pessoas_masculinas;
                ALTER VIEW %I
                RENAME COLUMN vitimas_femininas TO pessoas_femininas;
                ALTER VIEW %I
                RENAME COLUMN vitimas_nao_inform TO pessoas_nao_inform;
                ALTER VIEW %I
                RENAME COLUMN total_vitimas TO total_pessoas;',
                nome_view, nome_view, nome_view, nome_view);
        END IF;

        -- SUcesso! 
        RAISE NOTICE '% criado para tipo evento do tipo %', nome_view, nome;
    END LOOP;
END;
$$
LANGUAGE plpgsql;
