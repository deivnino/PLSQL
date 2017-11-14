/**
* Name: RE_CAL_MEA_GLL_M_GLOBAL_FK.sql
* Referencia a la tabla CO532_META_GLOB 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_re_cal_met_glo ADD CONSTRAINT re_cal_mea_gll_m_global_fk FOREIGN KEY ( meta_global_cod_met_glo )
    REFERENCES admsisa.co532_meta_glob ( cod_met_glo );
