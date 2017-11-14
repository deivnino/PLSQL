/**
* Name: DETE_HIS_DIST_GEST_FK.sql
* Referencia a la tabla CO532_GESTOR 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_det_hist_distr ADD CONSTRAINT dete_his_dist_gest_fk FOREIGN KEY ( cod_gest_cap )
    REFERENCES admsisa.co532_gestor ( cod_gest );
