/**
* Name: COMISION_PERIODO_FK.sql
* Referencia a la tabla CO532_PERIODO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_comision ADD CONSTRAINT comision_periodo_fk FOREIGN KEY ( periodo_cod_per )
    REFERENCES admsisa.co532_periodo ( cod_per );
