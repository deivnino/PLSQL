/**
* Name: DLL_CO532_NOTIFICACION.sql
* Tabla donde se almacena las platillas implementadas para las notificaciones
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_notificacion (
    cod_noti   NUMBER(5) NOT NULL
);

COMMENT ON TABLE admsisa.co532_notificacion IS
    'Tabla donde se almacena las platillas implementadas para las notificaciones';

ALTER TABLE admsisa.co532_notificacion ADD CONSTRAINT notificacion_pk PRIMARY KEY ( cod_noti );