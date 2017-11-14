/**
* Name: VAR_REG_REGDISN_FK.sql
* Referencia a la tabla CO532_REG_DIST 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_var_regl ADD CONSTRAINT var_reg_regdisn_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES admsisa.co532_reg_dist ( cod_reg_dis );
