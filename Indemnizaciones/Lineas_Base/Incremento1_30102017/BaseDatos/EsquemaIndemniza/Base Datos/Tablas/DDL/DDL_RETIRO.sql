--------------------------------------------------------
--  DDL for Table RETIRO
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.RETIRO 
   (	FECHA_RETIRO DATE, 
	PERIODO DATE, 
	ESTADO NUMBER(20,0), 
	SOLICITUD_SAI_SOLICITUD NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.RETIRO.FECHA_RETIRO IS 'fecha retiro - fecha el cual se hizo el retiro.';
   
   COMMENT ON COLUMN INDEMNIZA.RETIRO.PERIODO IS 'Indica el periodo calculado en SAI en al cual se hace el retiro.';
   
   COMMENT ON COLUMN INDEMNIZA.RETIRO.ESTADO IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';
   
   COMMENT ON TABLE INDEMNIZA.RETIRO  IS 'Tabla donde se registraran los retiros del seguro a uno solicitud.';
   

--------------------------------------------------------
--  Constraints for Table RETIRO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.RETIRO MODIFY (FECHA_RETIRO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.RETIRO MODIFY (PERIODO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.RETIRO MODIFY (ESTADO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.RETIRO MODIFY (SOLICITUD_SAI_SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.RETIRO ADD CONSTRAINT RETIRO_PK PRIMARY KEY (FECHA_RETIRO, SOLICITUD_SAI_SOLICITUD) ENABLE;
