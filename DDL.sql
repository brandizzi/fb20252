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