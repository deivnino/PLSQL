/**
* Name: DLL_CO532_LIQUIDADOR.sql
* Tabla donde se almacena la informacion de liquidador 
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_liquidador (
    cod_liq                NUMBER(5) NOT NULL,
    porcentaje             NUMBER(3) NOT NULL,
    val_max_com_pag        NUMBER(15,2) NOT NULL,
    val_tot_car_are        NUMBER(15,2) NOT NULL,
    pro_val_met_glo        NUMBER(15,2) NOT NULL,
    pro_met_mes_car        NUMBER(15,2),
    pro_met_mes_jur        NUMBER(15,2),
    cod_tip_gest           NUMBER NOT NULL,
    periodo_cod_per        NUMBER(5) NOT NULL,
    localizacion_cod_loc   VARCHAR(5) NOT NULL
);

ALTER TABLE admsisa.co532_liquidador ADD CHECK (
    cod_tip_gest IN (
        1,2,3
    )
);

COMMENT ON TABLE admsisa.co532_liquidador IS
    'Tabla donde se almacena la informacion de liquidador';

ALTER TABLE admsisa.co532_liquidador ADD CONSTRAINT liquidador_pk PRIMARY KEY ( cod_liq );