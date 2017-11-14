/**
* Name: DLL_CO532_BITA_SINI.sql
* Tabla donde se almacena la informacion de los movimientos de los siniestros en el sistema
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_bita_sini (
    cod_bit_sin                      NUMBER(5) NOT NULL,
    siniestro_cod_sin                NUMBER(5) NOT NULL,
    gestor_cod_gest                  NUMBER(5),
    motivo_exclusion_cod_mot_exc     NUMBER(5),
    regla_distribucion_cod_reg_dis   NUMBER(5),
    fecha_real                       DATE DEFAULT SYSDATE NOT NULL
);

COMMENT ON TABLE admsisa.co532_bita_sini IS
    'BITACORA-SINIESTRO Tabla donde se almacena la informacion de los movimientos de los siniestros en el sistema';

ALTER TABLE admsisa.co532_bita_sini ADD CONSTRAINT bitacora_siniestro_pk PRIMARY KEY ( cod_bit_sin );