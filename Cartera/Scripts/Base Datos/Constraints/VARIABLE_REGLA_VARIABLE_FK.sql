/**
* Name: VARIABLE_REGLA_VARIABLE_FK.sql
* Referencia a la tabla CO532_VARIABLE 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_var_regl ADD CONSTRAINT variable_regla_variable_fk FOREIGN KEY ( variable_tip_var,variable_cod_var )
    REFERENCES admsisa.co532_variable ( tip_var,cod_var );
