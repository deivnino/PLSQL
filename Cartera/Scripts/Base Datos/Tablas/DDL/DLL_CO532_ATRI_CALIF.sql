/**
* Name: DLL_CO532_ATRI_CALIF.sql
* Tabla donde se almacena el atributo de calificacion de los abogados externos
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_atri_calif (
    cod_atrib              NUMBER(5) NOT NULL,
    nom_atri               VARCHAR2(50) NOT NULL,
    par_cal_abog_cod_par   NUMBER(2) NOT NULL
);

COMMENT ON TABLE admsisa.co532_atri_calif IS
    'Atributo de calificacion de los abogados externos';

ALTER TABLE admsisa.co532_atri_calif ADD CONSTRAINT atributo_calificacion_pk PRIMARY KEY ( cod_atrib,par_cal_abog_cod_par );