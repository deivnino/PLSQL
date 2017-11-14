--------------------------------------------------------
--  DDL for Table DOCUMENTO_NOTIFICACION
--------------------------------------------------------

  CREATE TABLE "DOCUMENTO_NOTIFICACION" 
   (	"COD_DOC_NOTIFICACION" NUMBER(15,0), 
	"COD_DOC" NUMBER(5,0), 
	"COD_REPO" NUMBER(10,0), 
	"RUTA_REPO" VARCHAR2(400), 
	"ESTADO" NUMBER(20,0), 
	"NOTIFICACION_SOLICITUD" NUMBER(10,0), 
	"NOTIFICACION_FEC_NOTI" DATE
   ) ;

   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."COD_DOC_NOTIFICACION" IS 'Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."COD_DOC" IS 'codigo documento - Codigo SAI del documento que se esta solicitando.';
   
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."COD_REPO" IS 'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';
   
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."RUTA_REPO" IS 'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';
   
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."ESTADO" IS 'Tabla Dominio - Indicaria si ya fue cargado el archivo solicitado';
   
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."NOTIFICACION_SOLICITUD" IS 'Numero de solicitud que a la que se le esta haciendo la novedad.';
   
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."NOTIFICACION_FEC_NOTI" IS 'fecha notificacion - Fecha del sistema de cuando se esta generando la notificacion.';
   
   COMMENT ON TABLE "DOCUMENTO_NOTIFICACION"  IS 'Documento Notificacion - Tabla donde se registran los documentos que han sido solicitados en la notificacion para las inmobiliarias.';
   

--------------------------------------------------------
--  Constraints for Table DOCUMENTO_NOTIFICACION
--------------------------------------------------------

  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("COD_DOC_NOTIFICACION" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("COD_DOC" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("COD_REPO" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("RUTA_REPO" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("NOTIFICACION_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("NOTIFICACION_FEC_NOTI" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" ADD CONSTRAINT "DOCUMENTO_NOTIFICACION_PK" PRIMARY KEY ("COD_DOC_NOTIFICACION") ENABLE;

--------------------------------------------------------
--  DDL for Index DOCUMENTO_NOTIFICACION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "DOCUMENTO_NOTIFICACION__IDX" ON "DOCUMENTO_NOTIFICACION" ("COD_DOC_NOTIFICACION", "ESTADO") 
  ;

