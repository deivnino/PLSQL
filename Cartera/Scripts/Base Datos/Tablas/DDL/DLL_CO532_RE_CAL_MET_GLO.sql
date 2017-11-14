/**
* Name: DLL_CO532_RE_CAL_MET_GLO.sql
* Tabla donde se almacena los recalculos de las comisiones mensualmente en caso de que no se cumpla las metas
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_re_cal_met_glo (
    cod_rec                   NUMBER(5) NOT NULL,
    meta_global_cod_met_glo   NUMBER(5) NOT NULL,
    periodo_cod_per           NUMBER(5) NOT NULL
);

COMMENT ON TABLE admsisa.co532_re_cal_met_glo IS
    'RE CALCULO META GLOBAL - Tabla donde se almacena los recalculos de las comisiones mensualmente en caso de que no se cumpla las metas'
;

ALTER TABLE admsisa.co532_re_cal_met_glo ADD CONSTRAINT re_calculo_meta_global_pk PRIMARY KEY ( cod_rec );