/**
* Name: DLL_CO532_EXCL_MONT.sql
* Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_excl_mont (
    cod_exc_mon                      NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    minimo                           NUMBER(11) NOT NULL,
    maximo                           NUMBER(11) NOT NULL,
    tip_excl                         VARCHAR2(3) NOT NULL
);

ALTER TABLE admsisa.co532_excl_mont ADD CHECK (
    tip_excl IN (
        'EE','EM'
    )
);

COMMENT ON TABLE admsisa.co532_excl_mont IS
    'EXCLUSION RANGOS DE MONTOS - Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.';

ALTER TABLE admsisa.co532_excl_mont ADD CONSTRAINT exclusion_montos_pk PRIMARY KEY ( cod_exc_mon );