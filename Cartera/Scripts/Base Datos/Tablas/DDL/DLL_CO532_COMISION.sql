/**
* Name: DLL_CO532_COMISION.sql
* Tabla donde se almacena la informacion que indica una calculo de comisiones para la entidad
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_comision (
    localizacion_cod_loc   VARCHAR(5) NOT NULL,
    periodo_cod_per        NUMBER(5) NOT NULL,
    cod_tip_gest           NUMBER NOT NULL
);

ALTER TABLE admsisa.co532_comision ADD CHECK (
    cod_tip_gest IN (
        1,2,3
    )
);

COMMENT ON TABLE admsisa.co532_comision IS
    'Tabla donde se almacena la informacion que indica una calculo de comisiones para la entidad';

ALTER TABLE admsisa.co532_comision ADD CONSTRAINT comision_pk PRIMARY KEY ( localizacion_cod_loc,periodo_cod_per );
