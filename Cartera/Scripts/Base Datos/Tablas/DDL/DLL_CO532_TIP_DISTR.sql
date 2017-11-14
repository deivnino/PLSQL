/**
* Name: DLL_CO532_TIP_DISTR.sql
* Tabla donde se almacena los tipos de distribucion parametrizados
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_tip_distr (
    cod_tip_dis   NUMBER(5) NOT NULL,
    nom_tip_dis   VARCHAR2(100) NOT NULL,
    tip_agru      VARCHAR2(10) NOT NULL,
    tip_ran       NUMBER,
    estado        NUMBER NOT NULL
);

ALTER TABLE admsisa.co532_tip_distr ADD CHECK (
    tip_ran IN (
        0,1,2,3
    )
);

ALTER TABLE admsisa.co532_tip_distr ADD CHECK (
    estado IN (
        0,1
    )
);

COMMENT ON TABLE admsisa.co532_tip_distr IS
    'TIPO DISTRIBUCION - Tabla donde se almacena los tipos de distribucion parametrizados';

COMMENT ON COLUMN admsisa.co532_tip_distr.tip_ran IS
    'tipo de rango';

ALTER TABLE admsisa.co532_tip_distr ADD CONSTRAINT tipo_distribucion_pk PRIMARY KEY ( cod_tip_dis );