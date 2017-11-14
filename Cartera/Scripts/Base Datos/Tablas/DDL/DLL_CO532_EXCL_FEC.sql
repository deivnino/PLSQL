/**
* Name: DLL_CO532_EXCL_FEC.sql
* Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_excl_fec (
    cod_exc_fec                      NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    dia                              NUMBER(2) NOT NULL,
    hora                             DATE NOT NULL
);

COMMENT ON TABLE admsisa.co532_excl_fec IS
    'EXCLUSION FECHA - Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.';

ALTER TABLE admsisa.co532_excl_fec ADD CONSTRAINT exclusion_fecha_pk PRIMARY KEY ( cod_exc_fec );