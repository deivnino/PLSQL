/**
* Name: REG_DIST_TI_DIST_FK.sql
* Referencia a la tabla CO532_TIP_DISTR 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_reg_dist ADD CONSTRAINT reg_dist_ti_dist_fk FOREIGN KEY ( tipo_distribucion_cod_tip_dis )
    REFERENCES admsisa.co532_tip_distr ( cod_tip_dis );
