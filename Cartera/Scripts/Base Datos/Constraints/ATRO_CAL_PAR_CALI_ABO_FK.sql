/**
* Name: ATRO_CAL_PAR_CALI_ABO_FK.sql
* Referencia a la tabla CO532_PAR_CAL_ABOG 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_atri_calif ADD CONSTRAINT atro_cal_par_cali_abo_fk FOREIGN KEY ( par_cal_abog_cod_par )
    REFERENCES admsisa.co532_par_cal_abog ( cod_par );
