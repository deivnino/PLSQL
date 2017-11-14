/**
* Name: DLL_CO532_VAR_REGL.sql
* Tabla donde se almacena las variables implementadas en la regla de distribucion
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_var_regl (
    regla_distribucion_cod_reg_dis   NUMBER(5) NOT NULL,
    cod_var_reg                      NUMBER(5) NOT NULL,
    variable_tip_var                 NUMBER NOT NULL,
    variable_cod_var                 VARCHAR2(50) NOT NULL
);

ALTER TABLE admsisa.co532_var_regl ADD CHECK (
    variable_tip_var IN (
        1,2,3,4,5,6,7,8,9,10,11,12
    )
);

COMMENT ON TABLE admsisa.co532_var_regl IS
    'VARIABLE REGLA - Tabla donde se almacena las variables implementadas en la regla de distribucion';

ALTER TABLE admsisa.co532_var_regl ADD CONSTRAINT variable_regla_pk PRIMARY KEY ( cod_var_reg,regla_distribucion_cod_reg_dis );