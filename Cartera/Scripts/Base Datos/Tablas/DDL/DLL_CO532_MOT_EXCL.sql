/**
* Name: DLL_CO532_MOT_EXCL.sql
* Tabla donde se almacena los motivos de exclusion
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_mot_excl (
    cod_mot_exc   NUMBER(5) NOT NULL,
    nom_mot_exc   VARCHAR2(60) NOT NULL
);

COMMENT ON TABLE admsisa.co532_mot_excl IS
    'MOTIVO EXCLUSION - Tabla donde se almacena los motivos de exclusion';

ALTER TABLE admsisa.co532_mot_excl ADD CONSTRAINT motivo_exclusion_pk PRIMARY KEY ( cod_mot_exc );
