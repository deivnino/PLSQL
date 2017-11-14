/**
* Name: ASIGNACION_SINIESTRO_FK.sql
* Referencia a la tabla CO532_SINIESTRO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_asignacion ADD CONSTRAINT asignacion_siniestro_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES admsisa.co532_siniestro ( cod_sin );
