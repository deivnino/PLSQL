/**
* Name: DLL_CO532_GESTOR.sql
* Tabla donde se almacena los gestores
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_gestor (
    cod_gest         NUMBER(5) NOT NULL,
    cod_rei          VARCHAR2(6) NOT NULL,
    tipo_iden        VARCHAR2(4) NOT NULL,
    identificacion   VARCHAR2(20) NOT NULL,
    nombre           VARCHAR2(100) NOT NULL,
    email            VARCHAR2(50),
    est_gest         VARCHAR2(10) NOT NULL,
    cod_tip_gestor   NUMBER NOT NULL
);

COMMENT ON TABLE admsisa.co532_gestor IS
    'Tabla donde se almacena los gestores';

ALTER TABLE admsisa.co532_gestor ADD CHECK (
    est_gest IN ('A','I')
);

COMMENT ON COLUMN admsisa.co532_gestor.tipo_iden IS
    'tipo de identificacion del gestor';

COMMENT ON COLUMN admsisa.co532_gestor.identificacion IS
    'Identificacion del gestor';
/
ALTER TABLE admsisa.co532_gestor ADD CONSTRAINT gestor_pk PRIMARY KEY ( cod_gest );