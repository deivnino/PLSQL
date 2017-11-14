/**
* Name: COMISION_DETALLE_COMISION_FK.sql
* Referencia a la tabla CO532_COMISION 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_comis_deta ADD CONSTRAINT comision_detalle_comision_fk FOREIGN KEY ( comision_cod_loc,comision_cod_per )
    REFERENCES admsisa.co532_comision ( localizacion_cod_loc,periodo_cod_per );
