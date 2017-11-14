/**
* Name: EXC_POL_REG_DIS_FK.sql
* Referencia a la tabla CO532_REG_DIST 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_excl_pol ADD CONSTRAINT exc_pol_reg_dis_fk FOREIGN KEY ( regla_distribucion_cod_reg_dis )
    REFERENCES admsisa.co532_reg_dist ( cod_reg_dis );
