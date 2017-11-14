/**
* Name: CALI_ABO_LOC_FK.sql
* Referencia a la tabla CO532_LOCALIZACION 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_calif_abog ADD CONSTRAINT cali_abo_loc_fk FOREIGN KEY ( localizacion_cod_loc )
    REFERENCES admsisa.co532_localizacion ( cod_loc );
