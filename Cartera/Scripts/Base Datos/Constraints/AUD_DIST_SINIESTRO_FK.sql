/**
* Name: AUD_DIST_SINIESTRO_FK.sql
* Referencia a la tabla CO532_SINIESTRO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_aud_dist ADD CONSTRAINT aud_dist_siniestro_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES admsisa.co532_siniestro ( cod_sin );
