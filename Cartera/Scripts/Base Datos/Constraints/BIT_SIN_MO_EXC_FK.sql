/**
* Name: BIT_SIN_MO_EXC_FK.sql
* Referencia a la tabla CO532_MOT_EXCL 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_bita_sini ADD CONSTRAINT bit_sin_mo_exc_fk FOREIGN KEY ( motivo_exclusion_cod_mot_exc )
    REFERENCES admsisa.co532_mot_excl ( cod_mot_exc );
