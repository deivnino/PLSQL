/**
* Name: CAL_ABOG_ATR_CALI_FK.sql
* Referencia a la tabla CO532_ATRI_CALIF 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_calif_abog ADD CONSTRAINT cal_abog_atr_cali_fk FOREIGN KEY ( atr_cal_cod_atrib,atributo_calificacion_cod_par )
    REFERENCES admsisa.co532_atri_calif ( cod_atrib,par_cal_abog_cod_par );
