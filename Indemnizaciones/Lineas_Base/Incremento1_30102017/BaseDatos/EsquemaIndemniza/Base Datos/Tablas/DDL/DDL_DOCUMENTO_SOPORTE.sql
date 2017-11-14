--------------------------------------------------------
--  DDL for Table DOCUMENTO_SOPORTE
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.DOCUMENTO_SOPORTE 
   (	COD_DOC_SOP NUMBER(15,0), 
	NOMBRE VARCHAR2(200), 
	COD_REPO NUMBER(10,0), 
	RUTA_REPO VARCHAR2(400), 
	REG_DAN_FALT_FEC_REP DATE, 
	REG_DAN_FALT_SOLICITUD NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.DOCUMENTO_SOPORTE.COD_DOC_SOP IS 'codigo documento soporte - Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN INDEMNIZA.DOCUMENTO_SOPORTE.NOMBRE IS 'Campo donde se almacena el nombre del documento.';
   
   COMMENT ON COLUMN INDEMNIZA.DOCUMENTO_SOPORTE.COD_REPO IS 'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';
   
   COMMENT ON COLUMN INDEMNIZA.DOCUMENTO_SOPORTE.RUTA_REPO IS 'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';
   
   COMMENT ON COLUMN INDEMNIZA.DOCUMENTO_SOPORTE.REG_DAN_FALT_FEC_REP IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   
   COMMENT ON TABLE INDEMNIZA.DOCUMENTO_SOPORTE  IS 'DOCUMENTO SOPORTE - Tabla donde se almacenan los documentos soportes que se adjuntan en el reporte de daño y faltantes.';
   
   
  
--------------------------------------------------------
--  Constraints for Table DOCUMENTO_SOPORTE
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.DOCUMENTO_SOPORTE ADD CONSTRAINT DOCUMENTO_SOPORTE_PK PRIMARY KEY (COD_DOC_SOP) ENABLE;
  ALTER TABLE INDEMNIZA.DOCUMENTO_SOPORTE MODIFY (COD_DOC_SOP NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DOCUMENTO_SOPORTE MODIFY (NOMBRE NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DOCUMENTO_SOPORTE MODIFY (COD_REPO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DOCUMENTO_SOPORTE MODIFY (RUTA_REPO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DOCUMENTO_SOPORTE MODIFY (REG_DAN_FALT_FEC_REP NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DOCUMENTO_SOPORTE MODIFY (REG_DAN_FALT_SOLICITUD NOT NULL ENABLE);
