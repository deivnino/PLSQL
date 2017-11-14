/**
* Name: DLL_CO532_PERIODO.sql
* Tabla donde se almacena los periodos implementados en el sistema
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_periodo (
    cod_per   NUMBER(5) NOT NULL,
    mes       VARCHAR2(10) NOT NULL,
    anio      VARCHAR2(4) NOT NULL
);

COMMENT ON TABLE admsisa.co532_periodo IS
    'Tabla donde se almacena los periodos implementados en el sistema';

ALTER TABLE admsisa.co532_periodo ADD CONSTRAINT periodo_pk PRIMARY KEY ( cod_per );