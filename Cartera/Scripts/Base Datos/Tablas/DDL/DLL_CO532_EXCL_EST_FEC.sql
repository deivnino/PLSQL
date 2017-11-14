/**
* Name: DLL_CO532_EXCL_EST_FEC.sql
* Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_excl_est_fec (
    cod_exc_est_fec                  NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    est_sin                          NUMBER NOT NULL,
    fecha                            DATE NOT NULL
);

ALTER TABLE admsisa.co532_excl_est_fec ADD CHECK (
    est_sin IN (
        1,2,3
    )
);

COMMENT ON TABLE admsisa.co532_excl_est_fec IS
    'EXCLUSION ESTADO FECHA - Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.';

ALTER TABLE admsisa.co532_excl_est_fec ADD CONSTRAINT exclusion_estado_fecha_pk PRIMARY KEY ( cod_exc_est_fec );