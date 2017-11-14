/**
* Name: DET_HIST_DIST_HIS_DIS_FK.sql
* Referencia a la tabla CO532_HIST_DISTR 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_det_hist_distr ADD CONSTRAINT det_hist_dist_his_dis_fk FOREIGN KEY ( his_dist_cod_his_dis )
    REFERENCES admsisa.co532_hist_distr ( cod_his_dis );
