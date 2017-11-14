--------------------------------------------------------
--  DDL for Table NOTIFICACION
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.NOTIFICACION 
   (	SOLICITUD NUMBER(10,0), 
	FEC_NOTI DATE
   ) ;
   

   COMMENT ON COLUMN INDEMNIZA.NOTIFICACION.SOLICITUD IS 'Numero de solicitud que a la que se le esta haciendo la novedad.';
   
   COMMENT ON COLUMN INDEMNIZA.NOTIFICACION.FEC_NOTI IS 'fecha notificacion - Fecha del sistema de cuando se esta generando la notificacion.';
   
   COMMENT ON TABLE INDEMNIZA.NOTIFICACION  IS 'Tabla donde se registran las solicitudes de notificaciones que se requieren por parte de la inmobiliaria.';
   
   
--------------------------------------------------------
--  Constraints for Table NOTIFICACION
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.NOTIFICACION MODIFY (SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.NOTIFICACION MODIFY (FEC_NOTI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.NOTIFICACION ADD CONSTRAINT NOTIFICACION_PK PRIMARY KEY (SOLICITUD, FEC_NOTI) ENABLE;
