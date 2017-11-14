--------------------------------------------------------
--  DDL for Table AUTORIZACION_DESOCUPACIOON
--------------------------------------------------------

  CREATE TABLE "AUTORIZACION_DESOCUPACIOON" 
   (	"CODIGO_AUT_DES" NUMBER(15,0), 
	"AREA_AUTO" VARCHAR2(10), 
	"FEC_AUTO" DATE DEFAULT SYSDATE, 
	"RESPONSABLE" NUMBER(10,0), 
	"ESTADO" NUMBER(20,0), 
	"OBSERVACION" VARCHAR2(400), 
	"TIPO_MOT" NUMBER(20,0), 
	"DESO_PEND_TIPO_OBS" NUMBER(20,0), 
	"DESO_PEND_DESOC_FEC_REGI" DATE, 
	"DESO_PEND_DESOC_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."CODIGO_AUT_DES" IS 'Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."AREA_AUTO" IS 'Area Autorizacion - Dominio que establece qe area va a realizar la autorización.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."FEC_AUTO" IS 'fecha autorizacion - Campo donde se almacena la fecha y la hora en el que se proceso la autorizacion.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."RESPONSABLE" IS 'Campo donde se almacena el codigo del reponsable de la autorizacion/rechazo del pendiente.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."ESTADO" IS 'Campo que indica el estado de la autorizacion,si fue aprobada o rechazada.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."OBSERVACION" IS 'Campo donde se registra la observacion realizada en la aprobacion o en el rechazo.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."TIPO_MOT" IS 'tipo motivo - Dominio que indica el motivo por el cual esta siendo rechazada la novedad pendiente.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."DESO_PEND_TIPO_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."DESO_PEND_DESOC_FEC_REGI" IS 'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';
   COMMENT ON TABLE "AUTORIZACION_DESOCUPACIOON"  IS 'Autorizacion Desocupacion - Tabla donde se registran las autorizaciones de desocupaciones realizadas,aprobar o rechazar segun sea el caso.';
   
--------------------------------------------------------
--  Constraints for Table AUTORIZACION_DESOCUPACIOON
--------------------------------------------------------

  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("CODIGO_AUT_DES" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("AREA_AUTO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("FEC_AUTO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("RESPONSABLE" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("DESO_PEND_TIPO_OBS" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("DESO_PEND_DESOC_FEC_REGI" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("DESO_PEND_DESOC_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" ADD CONSTRAINT "AUTORIZACION_DESOCUPACIOON_PK" PRIMARY KEY ("CODIGO_AUT_DES") ENABLE;

--------------------------------------------------------
--  DDL for Index AUTO_DESOCUPACIOON__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTO_DESOCUPACIOON__IDX" ON "AUTORIZACION_DESOCUPACIOON" ("DESO_PEND_TIPO_OBS", "DESO_PEND_DESOC_FEC_REGI", "DESO_PEND_DESOC_SOLICITUD") 
  ;

