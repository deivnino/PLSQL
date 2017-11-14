/**
* Name: DLL_CO532_HIST_DISTR.sql
* Tabla donde se almacena historiales de distribucion realizadas en el sistema
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_hist_distr (
    cod_his_dis                     NUMBER(5) NOT NULL,
    fecha                           DATE NOT NULL,
    tipo_distribucion_cod_tip_dis   NUMBER(5),
    reg_dist                        NUMBER,
    descripcion                     VARCHAR2(200) NOT NULL,
    usuario                         VARCHAR2(50) NOT NULL
);

COMMENT ON TABLE admsisa.co532_hist_distr IS
    'HISTORIAL DISTRIBUCION - Tabla donde se almacena historiales de distribucion realizadas en el sistema';

COMMENT ON COLUMN admsisa.co532_hist_distr.tipo_distribucion_cod_tip_dis IS
    'Algoritmo de distribucion';

COMMENT ON COLUMN admsisa.co532_hist_distr.reg_dist IS
    'Regla de distribucion aplicada';

ALTER TABLE admsisa.co532_hist_distr ADD CONSTRAINT historico_distribucion_pk PRIMARY KEY ( cod_his_dis );