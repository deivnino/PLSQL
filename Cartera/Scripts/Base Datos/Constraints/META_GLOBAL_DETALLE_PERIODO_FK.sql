/**
* Name: META_GLOBAL_DETALLE_PERIODO_FK.sql
* Referencia a la tabla CO532_PERIODO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_meta_glob_det ADD CONSTRAINT meta_global_detalle_periodo_fk FOREIGN KEY ( periodo_cod_per )
    REFERENCES admsisa.co532_periodo ( cod_per );
