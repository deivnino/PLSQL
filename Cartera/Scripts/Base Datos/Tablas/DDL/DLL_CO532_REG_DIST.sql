/**
* Name: DLL_CO532_REG_DIST.sql
* Tabla donde se almacena,las reglas de distribucion parametrizadas en el sistema
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_reg_dist (
    cod_reg_dis                     NUMBER(5) NOT NULL,
    tipo_distribucion_cod_tip_dis   NUMBER(5) NOT NULL,
    tip_gest                        VARCHAR2(140) NOT NULL,
    per_reg                         VARCHAR2(4) NOT NULL,
    mes_per                         NUMBER(2),
    tip_rec                         VARCHAR2(4) NOT NULL,
    estado                          NUMBER NOT NULL,
    prioridad                       NUMBER(2) NOT NULL
);

ALTER TABLE admsisa.co532_reg_dist ADD CHECK (
    per_reg IN (
        'CES','ESN','ESV'
    )
);

ALTER TABLE admsisa.co532_reg_dist ADD CHECK (
    tip_rec IN (
        'C','K','KC'
    )
);

ALTER TABLE admsisa.co532_reg_dist ADD CHECK (
    estado IN (
        0,1
    )
);

COMMENT ON TABLE admsisa.co532_reg_dist IS
    'REGLA DISTRIBUCION - Tabla donde se almacena,las reglas de distribucion parametrizadas en el sistema';

ALTER TABLE admsisa.co532_reg_dist ADD CONSTRAINT regla_distribucion_pk PRIMARY KEY ( cod_reg_dis );