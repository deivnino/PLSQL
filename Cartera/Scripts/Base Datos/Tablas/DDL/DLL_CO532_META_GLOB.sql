/**
* Name: DLL_CO532_META_GLOB.sql
* Tabla donde se almacena la informacion de las metas globales
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_meta_glob (
    cod_met_glo    NUMBER(5) NOT NULL,
    ani_vig        NUMBER(4) NOT NULL,
    total          NUMBER(15,2) NOT NULL,
    "Select"       VARCHAR2(250) NOT NULL,
    cod_tip_gest   NUMBER NOT NULL
);

ALTER TABLE admsisa.co532_meta_glob ADD CHECK (
    cod_tip_gest IN (
        1,2,3
    )
);

COMMENT ON TABLE admsisa.co532_meta_glob IS
    'META GLOBAL - Tabla donde se almacena la informacion de las metas globales';

ALTER TABLE admsisa.co532_meta_glob ADD CONSTRAINT meta_global_pk PRIMARY KEY ( cod_met_glo );