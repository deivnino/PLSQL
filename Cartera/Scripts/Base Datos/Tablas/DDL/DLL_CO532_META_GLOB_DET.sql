/**
* Name: DLL_CO532_META_GLOB_DET.sql
* Tabla donde se almacena el detalle de la meta global por sucursal y periodo
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_meta_glob_det (
    cod_met_glo_det           NUMBER(5) NOT NULL,
    meta_global_cod_met_glo   NUMBER(5) NOT NULL,
    periodo_cod_per           NUMBER(5) NOT NULL,
    valor                     NUMBER(15,2) NOT NULL,
    localizacion_cod_loc      VARCHAR(5) NOT NULL
);

COMMENT ON TABLE admsisa.co532_meta_glob_det IS
    'META GLOBAL DETALLE - Tabla donde se almacena el detalle de la meta global por sucursal y periodo';

CREATE UNIQUE INDEX meta_global_detalle__idx ON
    admsisa.co532_meta_glob_det ( localizacion_cod_loc ASC );

CREATE UNIQUE INDEX meta_global_detalle__idxv1 ON
    admsisa.co532_meta_glob_det ( periodo_cod_per ASC );

ALTER TABLE admsisa.co532_meta_glob_det ADD CONSTRAINT meta_global_detalle_pk PRIMARY KEY ( cod_met_glo_det );
