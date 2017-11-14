/**
* Name: COMISION_DETALLE_GESTOR_FK.sql
* Referencia a la tabla CO532_GESTOR 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_comis_deta ADD CONSTRAINT comision_detalle_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES admsisa.co532_gestor ( cod_gest );
