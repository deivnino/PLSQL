/**
* Name: DLL_CO532_CALIF_ABOG.sql
* Tabla se almacena la calificacion de los abogados
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_calif_abog (
    cod_calif_abo                   NUMBER(8) NOT NULL,
    fecha_vig                       DATE NOT NULL,
    gestor_cod_gest                 NUMBER(5) NOT NULL,
    localizacion_cod_loc            VARCHAR(5) NOT NULL,
    estado                          NUMBER NOT NULL,
    atr_cal_cod_atrib               NUMBER(5) NOT NULL,
    atributo_calificacion_cod_par   NUMBER(2) NOT NULL,
    valor_cal                       NUMBER(5) NOT NULL
);

ALTER TABLE admsisa.co532_calif_abog ADD CHECK (
    estado IN (
        0,1
    )
);

COMMENT ON TABLE admsisa.co532_calif_abog IS
    'calificacion de los abogados';

ALTER TABLE admsisa.co532_calif_abog ADD CONSTRAINT calificacion_abogado_pk PRIMARY KEY ( cod_calif_abo );