--------------------------------------------------------
--  DDL for Table NOTIFICACION_CORREO
--------------------------------------------------------

  CREATE TABLE "NOTIFICACION_CORREO" 
   (	"COD_NOTI_CORR" NUMBER(15,0), 
	"DESTINATARIO" VARCHAR2(200), 
	"ASUNTO" VARCHAR2(200), 
	"CUERPO" VARCHAR2(400)
   ) ;

   COMMENT ON COLUMN "NOTIFICACION_CORREO"."COD_NOTI_CORR" IS 'codigo notificacion correo';
   
   COMMENT ON TABLE "NOTIFICACION_CORREO"  IS 'NOTIFICACION CORREO - Tabla donde se guardaran la informacion correspondiente al envio de correos electronicos.';
   
   
--------------------------------------------------------
--  Constraints for Table NOTIFICACION_CORREO
--------------------------------------------------------

  ALTER TABLE "NOTIFICACION_CORREO" ADD CONSTRAINT "NOTIFICACION_CORREO_PK" PRIMARY KEY ("COD_NOTI_CORR") ENABLE;
  ALTER TABLE "NOTIFICACION_CORREO" MODIFY ("COD_NOTI_CORR" NOT NULL ENABLE);
  ALTER TABLE "NOTIFICACION_CORREO" MODIFY ("DESTINATARIO" NOT NULL ENABLE);
  ALTER TABLE "NOTIFICACION_CORREO" MODIFY ("ASUNTO" NOT NULL ENABLE);
  ALTER TABLE "NOTIFICACION_CORREO" MODIFY ("CUERPO" NOT NULL ENABLE);

