/**
* Name: MET_GLO_DETE_ME_GLL_FK.sql
* Referencia a la tabla CO532_META_GLOB 
* Author: Oracle DataModeler
*/

ALTER TABLE admsisa.co532_meta_glob_det ADD CONSTRAINT met_glo_dete_me_gll_fk FOREIGN KEY ( meta_global_cod_met_glo )
    REFERENCES admsisa.co532_meta_glob ( cod_met_glo );
