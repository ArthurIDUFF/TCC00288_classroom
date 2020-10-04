DO $$ BEGIN
    PERFORM drop_functions();
END $$;

DROP TABLE IF EXISTS bairro CASCADE;
CREATE TABLE bairro (
bairro_id integer,
nome varchar
);

INSERT INTO bairro VALUES(
1, 'Bairro dos Bobos');

INSERT INTO bairro VALUES(
2, '21 de Setembro');

INSERT INTO bairro VALUES(
3, 'Cruzeiroengo');

INSERT INTO bairro VALUES(
4, 'Hala Neves');

DROP TABLE IF EXISTS municipio CASCADE;
CREATE TABLE municipio(
municipio_id integer,
nome varchar
);

INSERT INTO municipio VALUES(
1, 'Mendecó');

INSERT INTO municipio VALUES(
2, 'Estreteria');

INSERT INTO municipio VALUES(
3, 'Gloomwood');

INSERT INTO municipio VALUES(
4, 'Ultrakill');

DROP TABLE IF EXISTS antena CASCADE;
CREATE TABLE antena(
antena_id integer,
bairro_id integer,
municipio_id integer
);

INSERT INTO antena VALUES(
1, 1, 1);

INSERT INTO antena VALUES(
2, 2, 2);

INSERT INTO antena VALUES(
3, 3, 3);

INSERT INTO antena VALUES(
4, 4, 4);

INSERT INTO antena VALUES(
5, 1, 1);

DROP TABLE IF EXISTS ligacao CASCADE;
CREATE TABLE ligacao(
ligacao_id integer,
numero_orig integer,
numero_dest integer,
antena_orig integer,
antena_dest integer,
inicio timestamp,
fim timestamp
);

INSERT INTO ligacao VALUES(
1, 021, 022, 1, 2, '2020-05-11 12:00:00', '2020-05-11 12:10:00');

INSERT INTO ligacao VALUES(
1, 021, 023, 1, 2, '2020-05-11 12:00:00', '2020-05-11 12:20:00');

INSERT INTO ligacao VALUES(
1, 021, 022, 1, 1, '2020-01-01 12:50:00', '2020-12-12 12:55:00');

DROP FUNCTION IF EXISTS ligavg(dh1 timestamp, dh2 timestamp) CASCADE;

CREATE FUNCTION ligavg(dh1 timestamp, dh2 timestamp) RETURNS 
TABLE(
baid integer,
munid integer,
act interval
) AS $$

DECLARE



BEGIN 

IF dh1 > dh2 THEN 
    RAISE EXCEPTION 'primeira data/hora deve ser menor que segunda data/hora';
END IF;

DROP TABLE IF EXISTS reg CASCADE;
CREATE TABLE reg(
baid integer,
munid integer,
act interval
);

INSERT INTO reg SELECT antena.bairro_id, antena.municipio_id, AVG(ligacao.fim - ligacao.inicio) AS act FROM antena, ligacao
WHERE (((ligacao.antena_dest = antena.antena_id) OR (ligacao.antena_orig = antena.antena_id)) 
AND (ligacao.fim <= dh2) AND (ligacao.inicio >= dh1)) 
GROUP BY antena.bairro_id, antena.municipio_id;

RETURN QUERY SELECT * FROM reg;

END; $$ LANGUAGE plpgsql;

SELECT * FROM ligavg('1900-01-01 12:00:00', '2021-12-12 12:00:00');