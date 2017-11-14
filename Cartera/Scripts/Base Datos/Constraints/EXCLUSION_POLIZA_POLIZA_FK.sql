/**
* Name: EXCLUSION_POLIZA_POLIZA_FK.sql
* Referencia a la tabla CO532_POLIZA 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_excl_pol ADD CONSTRAINT exclusion_poliza_poliza_fk FOREIGN KEY ( poliza_cod_pol )
    REFERENCES admsisa.co532_poliza ( cod_pol );
