/**
* Name: CALIFICACION_ABOGADO_GESTOR_FK.sql
* Referencia a la tabla CO532_GESTOR 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_calif_abog ADD CONSTRAINT calificacion_abogado_gestor_fk FOREIGN KEY ( gestor_cod_gest )
    REFERENCES admsisa.co532_gestor ( cod_gest );
