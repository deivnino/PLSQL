/**
* Name: DLL_CO532_VALOR_REGLA.sql
* Tabla para guardar la auditoria del proceso de replicacion de siniestros desde SAI al sistema local
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_valor_regla (
    consecutivo      NUMBER(5) NOT NULL,
    reg_distr        NUMBER NOT NULL,
    tipo_var         NUMBER(5) NOT NULL,
    valor_variable   VARCHAR2(100) NOT NULL
);