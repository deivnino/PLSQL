/**
* Name: EXCL_EST_FECH_A_D_FK.sql
* Referencia a la tabla CO532_REG_DIST 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_excl_est_fec ADD CONSTRAINT excl_est_fech_a_d_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES admsisa.co532_reg_dist ( cod_reg_dis );
