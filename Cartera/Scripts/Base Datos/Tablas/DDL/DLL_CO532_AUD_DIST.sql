/**
* Name: DLL_CO532_AUD_DIST.sql
* Tabla donde se almacena la auditoria de la distribucion
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_aud_dist (
    hist_distr_cod_his_dis   NUMBER(5) NOT NULL,
    siniestro_cod_sin        NUMBER(10),
    cod_aud                  NUMBER(10,2) NOT NULL,
    paso                     NUMBER(2) NOT NULL,
    fecha                    DATE NOT NULL,
    funcion                  VARCHAR2(250) NOT NULL,
    observacion              VARCHAR2(250) NOT NULL
);

COMMENT ON COLUMN admsisa.co532_aud_dist.hist_distr_cod_his_dis IS
    'Codigo de distribucion Realizada por el Sistema';

COMMENT ON COLUMN admsisa.co532_aud_dist.siniestro_cod_sin IS
    'CODIGO DEL SINIESTRO';

COMMENT ON COLUMN admsisa.co532_aud_dist.cod_aud IS
    'Consecutivo';

COMMENT ON COLUMN admsisa.co532_aud_dist.paso IS
    'PASO DE EJECUCION';

COMMENT ON COLUMN admsisa.co532_aud_dist.fecha IS
    'fecha de proceso';

COMMENT ON COLUMN admsisa.co532_aud_dist.funcion IS
    'descripcion de ejecucion';

COMMENT ON COLUMN admsisa.co532_aud_dist.observacion IS
    'detalle de la ejecucion';

ALTER TABLE admsisa.co532_aud_dist ADD CONSTRAINT co532_aud_distribucion_pk PRIMARY KEY ( cod_aud );
