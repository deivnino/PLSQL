/**
* Name: AUD_DIST_HIST_DISTR_FK.sql
* Referencia a la tabla CO532_HIST_DISTR 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_aud_dist ADD CONSTRAINT aud_dist_hist_distr_fk FOREIGN KEY ( hist_distr_cod_his_dis )
    REFERENCES admsisa.co532_hist_distr ( cod_his_dis );
