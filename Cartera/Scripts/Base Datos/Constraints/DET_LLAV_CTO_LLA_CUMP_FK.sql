/**
* Name: DET_LLAV_CTO_LLA_CUMP_FK.sql
* Referencia a la tabla CO532_LLAV_CUMPL 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_det_llav_cump ADD CONSTRAINT det_llav_cto_lla_cump_fk FOREIGN KEY ( llav_cumpl_cod_llave )
    REFERENCES admsisa.co532_llav_cumpl ( cod_llave );
