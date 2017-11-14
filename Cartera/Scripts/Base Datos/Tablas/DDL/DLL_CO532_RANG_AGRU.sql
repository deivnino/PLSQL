/**
* Name: DLL_CO532_RANG_AGRU.sql
* Tabla donde se almacena los rangos de agrupaciones creados en el sistema
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_rang_agru (
    cod_ran_agr   NUMBER(5) NOT NULL,
    tip_ran       NUMBER NOT NULL,
    nom_ran       VARCHAR2(15) NOT NULL,
    val_ini       NUMBER(15,2) NOT NULL,
    val_fin       NUMBER(15,2) NOT NULL
);

ALTER TABLE admsisa.co532_rang_agru ADD CHECK (
    tip_ran IN (
        0,1,2,3
    )
);

COMMENT ON TABLE admsisa.co532_rang_agru IS
    'RANGO AGRUPACION - Tabla donde se almacena los rangos de agrupaciones creados en el sistema';

ALTER TABLE admsisa.co532_rang_agru ADD CONSTRAINT rango_agrupacion_pk PRIMARY KEY ( cod_ran_agr );