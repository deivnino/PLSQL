/**
* Name: COMISION_LOCALIZACION_FK.sql
* Referencia a la tabla CO532_LOCALIZACION 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_comision ADD CONSTRAINT comision_localizacion_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES admsisa.co532_localizacion ( cod_loc );
