/**
* Name: DLL_CO532_INACT_GEST.sql
* Tabla donde se almacena las inactivaciones programadas para los gestores
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_inact_gest (
    cod_ina_ges       NUMBER(5) NOT NULL,
    gestor_cod_gest   NUMBER(5) NOT NULL,
    fec_ini           DATE NOT NULL,
    fec_fin           DATE NOT NULL,
    est_ant           VARCHAR2(10) NOT NULL,
    motivo            VARCHAR2(200) NOT NULL,
    estado_inac       NUMBER NOT NULL
);

ALTER TABLE admsisa.co532_inact_gest ADD CHECK (
    est_ant IN (
        'A','I'
    )
);

ALTER TABLE admsisa.co532_inact_gest ADD CHECK (
    estado_inac IN (
        0,1
    )
);

COMMENT ON TABLE admsisa.co532_inact_gest IS
    'INACTIVACION GESTOR - Tabla donde se almacena las inactivaciones programadas para los gestores';

COMMENT ON COLUMN admsisa.co532_inact_gest.est_ant IS
    'estado que tenia el gestor en el momento de la programacion de la inactivacion';

COMMENT ON COLUMN admsisa.co532_inact_gest.estado_inac IS
    'estado de la inactivacion... Activo= pendiente de ejecucion Inactivo= ya se ejecuto la inactivacion';

ALTER TABLE admsisa.co532_inact_gest ADD CONSTRAINT inactivacion_gestor_pk PRIMARY KEY ( cod_ina_ges );