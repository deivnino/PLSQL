/**
* Name: DLL_CO532_SINIESTRO.sql
* Tabla donde se almacena la informacion de los siniestros existentes en el sistema
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_siniestro (
    cod_sin                          NUMBER(10) NOT NULL,
    poliza                           NUMBER(20) NOT NULL,
    sucursal                         VARCHAR2(5) NOT NULL,
    tip_prod                         NUMBER(5) NOT NULL,
    subti_prod                       VARCHAR2(3) NOT NULL,
    est_sin                          VARCHAR2(3) NOT NULL,
    est_pag                          VARCHAR2(3) NOT NULL,
    tip_amp                          VARCHAR2(3) NOT NULL,
    tip_pol                          VARCHAR2(2) NOT NULL,
    area                             VARCHAR2(3) NOT NULL,
    ubicacion                        VARCHAR2(3) NOT NULL,
    est_ali                          VARCHAR2(5) NOT NULL,
    val_cap                          NUMBER(15,2),
    val_col                          NUMBER(15,2),
    motivo_exclusion_cod_mot_exc     NUMBER(5),
    fecha_proceso                    DATE,
    cod_tip_ges                      NUMBER NOT NULL,
    tip_exc                          VARCHAR2(2),
    rang_fecha                       VARCHAR2(5),
    rang_mora                        VARCHAR2(5),
    rang_din                         VARCHAR2(5),
    fecha_ing                        DATE,
    fecha_mora                       DATE,
    regla_distribucion_cod_reg_dis   NUMBER(5),
    fech_desoc                       DATE,
	CONSTRAINT co532_siniestro_pk PRIMARY KEY (cod_sin)
);
COMMENT ON TABLE admsisa.co532_siniestro IS
    'Tabla donde se almacena la informacion de los siniestros existentes en el sistema';

COMMENT ON COLUMN admsisa.co532_siniestro.cod_tip_ges IS
    'TIPO DE GESTION DEL SINIESTRO';

COMMENT ON COLUMN admsisa.co532_siniestro.tip_exc IS
    'Tipo de exclusion';

COMMENT ON COLUMN admsisa.co532_siniestro.rang_fecha IS
    'Rango De fecha del siniestro cuando se distribuye';

COMMENT ON COLUMN admsisa.co532_siniestro.fecha_ing IS
    'Fecha de ingreso siniestro';

COMMENT ON COLUMN admsisa.co532_siniestro.fecha_mora IS
    'fecha Mora Siniestro';

COMMENT ON COLUMN admsisa.co532_siniestro.fech_desoc IS
    'Fecha de desocupacion';
/
CREATE UNIQUE INDEX admsisa.co532_siniestro_idx ON
    admsisa.co532_siniestro (motivo_exclusion_cod_mot_exc ASC );
  
ALTER TABLE admsisa.co532_siniestro ADD CHECK (
    cod_tip_ges IN (1,2,3)
);