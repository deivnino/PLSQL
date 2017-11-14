/**
* Name: DLL_CO532_DET_LLAV_CUMP.sql
* Tabla donde se alamcena la informacion que compone una llave de cumplimiento,por sus tipos de gestion
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_det_llav_cump (
    cod_det_cumpl          NUMBER(10) NOT NULL,
    llav_cumpl_cod_llave   NUMBER(5) NOT NULL,
    por_cump               NUMBER(3) NOT NULL,
    cod_tip_ges            NUMBER NOT NULL
);

ALTER TABLE admsisa.co532_det_llav_cump ADD CHECK (
    cod_tip_ges IN (
        1,2,3
    )
);

COMMENT ON TABLE admsisa.co532_det_llav_cump IS
    'DETALLE LLAVE CUMPLIMIENTO - Tabla donde se alamcena la informacion que compone una llave de cumplimiento,por sus tipos de gestion'
;

ALTER TABLE admsisa.co532_det_llav_cump ADD CONSTRAINT detalle_llave_cumplimiento_pk PRIMARY KEY ( cod_det_cumpl );