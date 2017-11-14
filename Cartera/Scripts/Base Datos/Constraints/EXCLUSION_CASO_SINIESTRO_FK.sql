/**
* Name: EXCLUSION_CASO_SINIESTRO_FK.sql
* Referencia a la tabla CO532_SINIESTRO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_excl_cas ADD CONSTRAINT exclusion_caso_siniestro_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES admsisa.co532_siniestro ( cod_sin );
