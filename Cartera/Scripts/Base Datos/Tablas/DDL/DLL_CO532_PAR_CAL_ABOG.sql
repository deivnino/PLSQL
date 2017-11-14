/**
* Name: DLL_CO532_PAR_CAL_ABOG.sql
* Tabla donde se almacena los parametros de calificacion de abogados externos por porcentaje
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_par_cal_abog (
    cod_par     NUMBER(2) NOT NULL,
    nom_par     VARCHAR2(80) NOT NULL,
    porc_peso   NUMBER(3) NOT NULL
);

COMMENT ON TABLE admsisa.co532_par_cal_abog IS
    'PARAMETRO CALIFICACION PESO - Tabla donde se almacena los parametros de calificacion de abogados externos por porcentaje';

ALTER TABLE admsisa.co532_par_cal_abog ADD CONSTRAINT pao_cal_abo_pk PRIMARY KEY (cod_par);
