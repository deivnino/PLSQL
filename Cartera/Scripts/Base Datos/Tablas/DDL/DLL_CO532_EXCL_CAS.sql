/**
* Name: DLL_CO532_EXCL_CAS.sql
* Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_excl_cas (
    cod_exc_cas                      NUMBER(5) NOT NULL,
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    siniestro_cod_sin                NUMBER(5) NOT NULL,
    nombre                           VARCHAR2(50) NOT NULL,
    tipo_excl                        VARCHAR2(3) NOT NULL
);

ALTER TABLE admsisa.co532_excl_cas ADD CHECK (
    tipo_excl IN (
        'EE','EM'
    )
);

COMMENT ON TABLE admsisa.co532_excl_cas IS
    'EXCLUSION CASO - Tabla donde se almacena la forma de exclusion implementada por la regla de distribucion.';

ALTER TABLE admsisa.co532_excl_cas ADD CONSTRAINT exclusion_caso_pk PRIMARY KEY ( cod_exc_cas );