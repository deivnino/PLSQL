/**
* Name: LIQUIDADOR_LOCALIZACION_FK.sql
* Referencia a la tabla CO532_LOCALIZACION 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_liquidador ADD CONSTRAINT liquidador_localizacion_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES admsisa.co532_localizacion ( cod_loc );
