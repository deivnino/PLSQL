/**
* Name: DLL_CO532_DET_HIST_DISTR.sql
* Tabla donde se almacena la informacion detallada de loas distribuciones ejecutadas por el sistema
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_det_hist_distr (
    cod_det_hist_dis       NUMBER(5) NOT NULL,
    his_dist_cod_his_dis   NUMBER(5) NOT NULL,
    siniestro_cod_sin      NUMBER(10) NOT NULL,
    sucursal               VARCHAR2(5) NOT NULL,
    tipo_prod              NUMBER(5) NOT NULL,
    subtip_prod            VARCHAR2(3) NOT NULL,
    est_sin                VARCHAR2(3) NOT NULL,
    est_pag                VARCHAR2(3) NOT NULL,
    tip_amp                VARCHAR2(3) NOT NULL,
    tip_pol                VARCHAR2(2) NOT NULL,
    area                   VARCHAR2(3) NOT NULL,
    ubicacion              VARCHAR2(3) NOT NULL,
    est_ali                VARCHAR2(5) NOT NULL,
    val_cap                NUMBER(15,2),
    val_col                NUMBER(15,2),
    cod_gest_cap           NUMBER(5),
    cod_gest_col           NUMBER(5),
    fecha_proceso          DATE,
    cod_tip_gest           NUMBER(1),
    tipo_excl              VARCHAR2(2),
    rang_fecha             VARCHAR2(5),
    rang_mora              VARCHAR2(5),
    rang_din               VARCHAR2(5),
    fech_ing               DATE,
    fecha_mora             DATE,
    fech_desoc             DATE,
    poliza                 NUMBER(20)
);

COMMENT ON TABLE admsisa.co532_det_hist_distr IS
    'DETALLE HISTORIAL DISTRIBUCION - tabla donde se almacena la informacion detallada de loas distribuciones ejecutadas por el sistema'
;

COMMENT ON COLUMN admsisa.co532_det_hist_distr.tipo_excl IS
    'tipo de exclusion';

COMMENT ON COLUMN admsisa.co532_det_hist_distr.rang_fecha IS
    'Rango de fecha';

COMMENT ON COLUMN admsisa.co532_det_hist_distr.rang_din IS
    'Rango de Dinero';

COMMENT ON COLUMN admsisa.co532_det_hist_distr.fecha_mora IS
    'Fecha de mora del siniestro';

COMMENT ON COLUMN admsisa.co532_det_hist_distr.fech_desoc IS
    'Fecha de desocupacion';

ALTER TABLE admsisa.co532_det_hist_distr ADD CONSTRAINT det_hist_dist_pk PRIMARY KEY ( cod_det_hist_dis );