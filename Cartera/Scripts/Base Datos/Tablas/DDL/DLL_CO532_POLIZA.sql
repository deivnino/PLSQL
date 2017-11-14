/**
* Name: DLL_CO532_POLIZA.sql
* Tabla donde se almacena las polizas existentes en el sistema
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_poliza (
    cod_pol   NUMBER(5) NOT NULL,
    nombre    VARCHAR2(50) NOT NULL
);

COMMENT ON TABLE admsisa.co532_poliza IS
    'Tabla donde se almacena las polizas existentes en el sistema';

ALTER TABLE admsisa.co532_poliza ADD CONSTRAINT poliza_pk PRIMARY KEY ( cod_pol );