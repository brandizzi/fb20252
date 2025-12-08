CREATE TABLE TipoEvento (
    id                 SMALLSERIAL PRIMARY KEY,
    evento             VARCHAR(80) UNIQUE NOT NULL,
    tem_vitima         BOOLEAN NOT NULL,
    tem_faixa_etaria   BOOLEAN NOT NULL,
    tem_arma           BOOLEAN  NOT NULL,
    tem_peso           BOOLEAN NOT NULL,
    tem_objeto         BOOLEAN NOT NULL
);

CREATE TABLE OrgaoAgente (
    id    SMALLSERIAL PRIMARY KEY,
    orgao VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE Regiao (
    id   SMALLSERIAL PRIMARY KEY,
    nome VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE UF (
    id        SMALLSERIAL PRIMARY KEY,
    sigla     CHAR(2) UNIQUE NOT NULL,
    nome      VARCHAR(25) UNIQUE NOT NULL,
    regiao_id INTEGER NOT NULL REFERENCES Regiao(id)
);

CREATE TABLE Municipio (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(40) NOT NULL,
    uf_id INTEGER NOT NULL REFERENCES UF(id),
    UNIQUE (nome, uf_id)
);

CREATE TABLE Arma (
    id   SMALLSERIAL PRIMARY KEY,
    nome VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE FaixaEtaria (
    id    SMALLSERIAL PRIMARY KEY,
    faixa VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Formulario (
    id     SMALLSERIAL PRIMARY KEY,
    nome   VARCHAR(15) UNIQUE NOT NULL,
    numero INTEGER UNIQUE NOT NULL
);

CREATE TABLE Abrangencia (
    id          SMALLSERIAL PRIMARY KEY,
    abrangencia VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE AgregacaoEvento (
    id                 SERIAL PRIMARY KEY,
    id_sinesp_vde      INTEGER NOT NULL,
    data_referencia    DATE NOT NULL,
    vitimas_femininas  INTEGER,
    vitimas_masculinas INTEGER,
    vitimas_nao_inform INTEGER,
    total_vitimas      INTEGER,
    total_objetos      NUMERIC,
    total_peso         NUMERIC,
    tipo_evento_id     INTEGER NOT NULL REFERENCES TipoEvento(id),
    uf_id              INTEGER NOT NULL REFERENCES UF(id),
    municipio_id       INTEGER NOT NULL REFERENCES Municipio(id),
    abrangencia_id     INTEGER NOT NULL REFERENCES Abrangencia(id),
    formulario_id      INTEGER NOT NULL REFERENCES Formulario(id),
    orgao_agente_id    INTEGER REFERENCES OrgaoAgente(id),
    arma_id            INTEGER REFERENCES Arma(id),
    faixa_etaria_id    INTEGER REFERENCES FaixaEtaria(id)
);

CREATE TABLE PopulacaoUF (
    uf_id     INTEGER NOT NULL REFERENCES UF(id),
    ano       INTEGER NOT NULL,
    populacao INTEGER NOT NULL,
    PRIMARY KEY (uf_id, ano)
);

CREATE TABLE PopulacaoMunicipio (
    municipio_id INTEGER NOT NULL REFERENCES Municipio(id),
    ano          INTEGER NOT NULL,
    populacao    INTEGER NOT NULL,
    PRIMARY KEY (municipio_id, ano)
);

------------------------
--- IMPORTANDO DADOS ---
------------------------
COPY OrgaoAgente(orgao)
FROM '/var/lib/csv_dados/OrgaoAgente.csv'
WITH (FORMAT csv, HEADER true);

COPY TipoEvento(evento, tem_arma, tem_faixa_etaria, tem_peso, tem_objeto, tem_vitima)
FROM '/var/lib/csv_dados/TipoEvento.csv'
WITH (FORMAT csv, HEADER true);

COPY Arma(nome)
FROM '/var/lib/csv_dados/Arma.csv'
WITH (FORMAT csv, HEADER true);

COPY FaixaEtaria(faixa)
FROM '/var/lib/csv_dados/FaixaEtaria.csv'
WITH (FORMAT csv, HEADER true);

COPY Formulario(nome, numero)
FROM '/var/lib/csv_dados/Formulario.csv'
WITH (FORMAT csv, HEADER true);

COPY Abrangencia(abrangencia)
FROM '/var/lib/csv_dados/Abrangencia.csv'
WITH (FORMAT csv, HEADER true);

COPY Regiao(nome)
FROM '/var/lib/csv_dados/Regiao.csv'
WITH (FORMAT csv, HEADER true);

UPDATE Regiao SET nome = trim(nome);

-- Importando tabelas com chaves estrangeiras

-- UF
CREATE TEMP TABLE UF_staging (
	sigla  CHAR(2),
	nome   VARCHAR(25),
	regiao VARCHAR(15)
);

COPY UF_staging(sigla,nome,regiao)
FROM '/var/lib/csv_dados/UF.csv'
WITH (FORMAT csv, HEADER true);

INSERT INTO UF(sigla, nome, regiao_id)
SELECT s.sigla, s.nome, r.id
FROM UF_staging s
JOIN Regiao r on trim(s.regiao) = r.nome;

-- Município

-- Coloquei o constraint errado no nome do município
-- (ele deve ser único no estado, existem municípios
-- diferentes com o mesmo nome no país) então tive
-- de rodar os ajusted abaixo.
--ALTER TABLE Municipio
--DROP CONSTRAINT municipio_nome_key;
--
--ALTER TABLE Municipio
--ADD CONSTRAINT municipio_uf_id_nome_key UNIQUE (uf_id, nome);
--
--DROP TABLE Municipio_staging;

CREATE TEMP TABLE Municipio_staging (
	nome VARCHAR(40),
	uf   CHAR(2)
);

COPY Municipio_staging(nome, uf)
FROM '/var/lib/csv_dados/Municipio.csv'
WITH (FORMAT csv, HEADER true);

INSERT INTO Municipio(nome, uf_id)
SELECT m.nome, u.id
FROM Municipio_staging m
JOIN UF u on m.uf = u.sigla;

-- PopulacaoMunicipio
CREATE TEMP TABLE PopulacaoMunicipio_staging (
	ano INTEGER,
	uf   CHAR(2), -- Necessario para distinguir municípios homônimos
	municipio VARCHAR(40),
	populacao NUMERIC
);

-- Na primeria importação, notamos que faltaram trẽs linhas. Aqui, corrigimos
-- os erros que levaram a isso:
--
-- Município confirmado em 2023 que acabou fora de alguns de nossos CSVS
INSERT INTO Municipio (nome, uf_id)
VALUES (
	'BOA ESPERANÇA DO NORTE', 
	(SELECT id FROM UF WHERE sigla = 'MT') 
);
-- Município com nome errado no arquivo de 2021 do IBGE
UPDATE PopulacaoMunicipio_staging SET municipio = 'GRÃO-PARÁ' WHERE municipio = 'GRÃO PARÁ';

COPY PopulacaoMunicipio_staging(ano, uf, municipio, populacao)
FROM '/var/lib/csv_dados/PopulacaoMunicipio.csv'
WITH (FORMAT csv, HEADER true);

INSERT INTO PopulacaoMunicipio(municipio_id, ano, populacao)
SELECT m.id, pm.ano, CAST(pm.populacao AS INTEGER)
FROM PopulacaoMunicipio_staging pm
JOIN UF u ON pm.uf = u.sigla
JOIN Municipio m ON pm.municipio = m.nome AND u.id = m.uf_id;

-- PopulacaoUF

CREATE TEMP TABLE PopulacaoUF_staging (
    ano INTEGER,
    uf   CHAR(2),
    populacao NUMERIC
);

COPY PopulacaoUF_staging(ano, uf, populacao)
FROM '/var/lib/csv_dados/PopulacaoUF.csv'
WITH (FORMAT csv, HEADER true);

INSERT INTO PopulacaoUF(uf_id, ano, populacao)
SELECT u.id, pu.ano, CAST(pu.populacao AS INTEGER)
FROM PopulacaoUF_staging pu
JOIN UF u ON pu.uf = u.sigla;
CREATE TEMP TABLE AgregacaoEvento_staging (
    id_sinesp_vde      INTEGER,
    uf                 CHAR(2),
    municipio          VARCHAR(40),
    tipo_evento        VARCHAR(89),
    orgao_agente       VARCHAR(30),
    arma               VARCHAR(30),
    faixa_etaria       VARCHAR(30),
    data_referencia    DATE,
    vitimas_femininas  NUMERIC,
    vitimas_masculinas NUMERIC,
    vitimas_nao_inform NUMERIC,
    total_vitimas      NUMERIC,
    total_objetos      NUMERIC,
    total_peso         NUMERIC,
    abrangencia        VARCHAR(20),
    formulario         VARCHAR(20)
);

COPY AgregacaoEvento_staging (
    id_sinesp_vde,
    uf,
    municipio,
    tipo_evento,
    data_referencia,
    orgao_agente,
    arma,
    faixa_etaria,
    vitimas_femininas,
    vitimas_masculinas,
    vitimas_nao_inform,
    total_vitimas,
    total_objetos,
    total_peso,
    abrangencia,
    formulario
)
FROM '/var/lib/csv_dados/AgregacaoEvento.csv'
WITH (FORMAT csv, HEADER true);

-- AgregacaoEvento

INSERT INTO AgregacaoEvento(
    id_sinesp_vde,
    uf_id,
    municipio_id,
    tipo_evento_id,
    data_referencia,
    orgao_agente_id,
    arma_id,
    faixa_etaria_id,
    vitimas_femininas,
    vitimas_masculinas,
    vitimas_nao_inform,
    total_vitimas,
    total_objetos,
    total_peso,
    abrangencia_id,
    formulario_id
)
SELECT
    ae.id_sinesp_vde,
    u.id,
    m.id,
    te.id,
    data_referencia,
    oa.id,
    ar.id,
    fe.id,
    CAST(vitimas_femininas AS INTEGER),
    CAST(vitimas_masculinas AS INTEGER),
    CAST(vitimas_nao_inform AS INTEGER),
    CAST(total_vitimas AS INTEGER),
    total_objetos,
    total_peso,
    ab.id,
    form.id
FROM AgregacaoEvento_staging ae
JOIN UF u ON ae.uf = u.sigla
JOIN Municipio m ON ae.municipio = m.nome
JOIN TipoEvento te ON ae.tipo_evento = te.evento
LEFT OUTER JOIN OrgaoAgente oa ON ae.orgao_agente = oa.orgao
LEFT OUTER JOIN Arma ar ON ae.arma = ar.nome
LEFT OUTER JOIN FaixaEtaria fe ON ae.faixa_etaria = fe.faixa
JOIN Abrangencia ab ON ae.abrangencia = ab.abrangencia
JOIN Formulario form ON ae.formulario = form.nome;