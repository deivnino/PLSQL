/**
* Name: DLL_CO532_EXCL_POL.sql
* Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_excl_pol (
    cod_exc_pol                      NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    poliza_cod_pol                   NUMBER(5) NOT NULL,
    tip_exc                          VARCHAR2(3) NOT NULL
);

ALTER TABLE admsisa.co532_excl_pol ADD CHECK (
    tip_exc IN (
        'EE','EM'
    )
);

COMMENT ON TABLE admsisa.co532_excl_pol IS
    'EXCLUSION POLIZA - Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.';

ALTER TABLE admsisa.co532_excl_pol ADD CONSTRAINT exclusion_poliza_pk PRIMARY KEY ( cod_exc_pol );