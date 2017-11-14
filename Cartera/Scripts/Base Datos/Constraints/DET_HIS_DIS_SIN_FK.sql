/**
* Name: DET_HIS_DIS_SIN_FK.sql
* Referencia a la tabla CO532_SINIESTRO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_det_hist_distr ADD CONSTRAINT det_his_dis_sin_fk FOREIGN KEY ( siniestro_cod_sin )
    REFERENCES admsisa.co532_siniestro ( cod_sin );
