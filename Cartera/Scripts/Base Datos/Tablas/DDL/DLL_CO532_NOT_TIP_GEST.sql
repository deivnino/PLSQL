/**
* Name: DLL_CO532_NOT_TIP_GEST.sql
* Tabla donde se almacena las notificaciones usadas por tipos de gestor
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_not_tip_gest (
    cod_noti_gest           NUMBER(5) NOT NULL,
    notificacion_cod_noti   NUMBER(5) NOT NULL,
    cod_tip_ges             NUMBER NOT NULL
);

ALTER TABLE admsisa.co532_not_tip_gest ADD CHECK (
    cod_tip_ges IN (
        1,2
    )
);

COMMENT ON TABLE admsisa.co532_not_tip_gest IS
    'NOTIFICACION TIPO GESTOR - Tabla donde se almacena las notificaciones usadas por tipos de gestor';

ALTER TABLE admsisa.co532_not_tip_gest ADD CONSTRAINT notificacion_tipo_gestor_pk PRIMARY KEY ( cod_noti_gest );