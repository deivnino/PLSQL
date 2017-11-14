/**
* Name: MET_GLOL_DET_LOC_FK.sql
* Referencia a la tabla CO532_LOCALIZACION 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_meta_glob_det ADD CONSTRAINT met_glol_det_loc_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES admsisa.co532_localizacion ( cod_loc );
