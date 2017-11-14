/**
* Name: RA_LIN_LIR_FK.sql
* Referencia a la tabla CO532_LIQUIDADOR 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_rang_liqu ADD CONSTRAINT ra_lin_lir_fk FOREIGN KEY ( liquidador_cod_liq )
    REFERENCES admsisa.co532_liquidador ( cod_liq );
