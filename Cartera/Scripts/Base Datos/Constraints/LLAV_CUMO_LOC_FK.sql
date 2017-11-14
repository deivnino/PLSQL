/**
* Name: LLAV_CUMO_LOC_FK.sql
* Referencia a la tabla CO532_LOCALIZACION 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_llav_cumpl ADD CONSTRAINT llav_cumo_loc_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES admsisa.co532_localizacion ( cod_loc );
