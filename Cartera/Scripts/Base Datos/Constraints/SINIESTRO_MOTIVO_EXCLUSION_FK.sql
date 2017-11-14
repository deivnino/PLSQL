/**
* Name: SINIESTRO_MOTIVO_EXCLUSION_FK.sql
* Referencia a la tabla CO532_MOT_EXCL 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_siniestro ADD CONSTRAINT siniestro_motivo_exclusion_fk FOREIGN KEY ( motivo_exclusion_cod_mot_exc )
    REFERENCES admsisa.co532_mot_excl ( cod_mot_exc );
