/**
* Name: BIT_SIN_SIN_FK.sql
* Referencia a la tabla CO532_SINIESTRO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_bita_sini ADD CONSTRAINT bit_sin_sin_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES admsisa.co532_siniestro ( cod_sin );
