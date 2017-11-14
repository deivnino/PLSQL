/**
* Name: RE_CAL_MET_GLOL_PER_FK.sql
* Referencia a la tabla CO532_PERIODO 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_re_cal_met_glo ADD CONSTRAINT re_cal_met_glol_per_fk FOREIGN KEY ( periodo_cod_per )
    REFERENCES admsisa.co532_periodo ( cod_per );
