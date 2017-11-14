/**
* Name: DLL_CO532_COMIS_DETA.sql
* Tabla donde se almacena la informacion de las comisiones liquidadas en el mes (por gestor)
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_comis_deta (
    cod_com_det        NUMBER(5) NOT NULL,
    gestor_cod_gest    NUMBER(5) NOT NULL,
    val_dist           NUMBER(15) NOT NULL,
    meta               NUMBER(15) NOT NULL,
    cumplimiento       NUMBER(15) NOT NULL,
    porc_cumpl         NUMBER(3) NOT NULL,
    comision           NUMBER(15) NOT NULL,
    comision_cod_loc   VARCHAR(5) NOT NULL,
    comision_cod_per   NUMBER(5) NOT NULL,
    porc_castigo       NUMBER(3) NOT NULL
);

COMMENT ON TABLE admsisa.co532_comis_deta IS
    'COMISION DETALLE-tabla donde se almacena la informacion de las comisiones liquidadas en el mes (por gestor)';

ALTER TABLE admsisa.co532_comis_deta ADD CONSTRAINT comision_detalle_pk PRIMARY KEY ( cod_com_det );