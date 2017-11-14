/**
* Name: DLL_CO532_RANG_LIQU.sql
* Tabla donde se almacena los rangos de liquidacion que se aplican por gestor y sus cumplimientos de gestion
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_rang_liqu (
    cod_ran_liq          NUMBER(5) NOT NULL,
    nom_rang             VARCHAR2(50) NOT NULL,
    por_cump             NUMBER(3) NOT NULL,
    porc_com             NUMBER(3) NOT NULL,
    val_cump             NUMBER(15,2) NOT NULL,
    val_com              NUMBER(15,2) NOT NULL,
    area                 NUMBER(5) NOT NULL,
    cod_tip_gest         NUMBER NOT NULL,
    liquidador_cod_liq   NUMBER(5) NOT NULL
);

ALTER TABLE admsisa.co532_rang_liqu ADD CHECK (
    cod_tip_gest IN (
        1,2,3
    )
);

COMMENT ON TABLE admsisa.co532_rang_liqu IS
    'RANGO LIQUIDADOR - Tabla donde se almacena los rangos de liquidacion que se aplican por gestor y sus cumplimientos de gestion';

ALTER TABLE admsisa.co532_rang_liqu ADD CONSTRAINT rango_liquidacion_pk PRIMARY KEY ( cod_ran_liq );