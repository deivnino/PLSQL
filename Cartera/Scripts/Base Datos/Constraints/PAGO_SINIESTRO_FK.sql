/**
* Name: PAGO_SINIESTRO_FK.sql
* Referencia a la tabla CO532_SINIESTRO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_pago ADD CONSTRAINT pago_siniestro_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES admsisa.co532_siniestro ( cod_sin );
