/**
* Name: DLL_CO532_PAGO.sql
* Tabla donde se almacena los pagos realizados a los siniestros
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_pago (
    cod_pag             NUMBER(5) NOT NULL,
    valor               NUMBER(15,2) NOT NULL,
    cod_tip_ges         NUMBER NOT NULL,
    gestor_cod_gest     NUMBER(5) NOT NULL,
    siniestro_cod_sin   NUMBER(10) NOT NULL
);

ALTER TABLE admsisa.co532_pago ADD CHECK (
    cod_tip_ges IN (
        1,2,3
    )
);

COMMENT ON TABLE admsisa.co532_pago IS
    'Tabla donde se almacena los pagos realizados a los siniestros';

ALTER TABLE admsisa.co532_pago ADD CONSTRAINT pago_pk PRIMARY KEY (cod_pag);