/**
* Name: EXCL_MON_REG_DIST_FK.sql
* Referencia a la tabla CO532_REG_DIST 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_excl_mont ADD CONSTRAINT excl_mon_reg_dist_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES admsisa.co532_reg_dist ( cod_reg_dis );
	