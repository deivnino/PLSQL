/**
* Name: DLL_CO532_LLAV_CUMPL.sql
* Tabla donde se almacena las llaves de cumplimiento implementada en los pagos de comisiones
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_llav_cumpl (
    cod_llave              NUMBER(5) NOT NULL,
    localizacion_cod_loc   VARCHAR2(5) NOT NULL,
    periodo_cod_per        NUMBER(5) NOT NULL,
    por_castigo            NUMBER(3) NOT NULL,
    estado                 NUMBER NOT NULL
);

COMMENT ON TABLE admsisa.co532_llav_cumpl IS
    'LLAVE CUMPLIMIENTO - Tabla donde se almacena las llaves de cumplimiento implementada en los pagos de comisiones';

ALTER TABLE co532_llav_cumpl ADD CHECK (estado IN (0,1));

ALTER TABLE admsisa.co532_llav_cumpl ADD CONSTRAINT llave_cumplimiento_pk PRIMARY KEY ( cod_llave );
