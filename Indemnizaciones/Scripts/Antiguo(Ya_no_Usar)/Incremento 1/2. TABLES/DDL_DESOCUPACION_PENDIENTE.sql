--------------------------------------------------------
--  DDL for Table DESOCUPACION_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "DESOCUPACION_PENDIENTE" 
   (	"TIPO_OBS" NUMBER(20,0), 
	"FEC_PEN" DATE DEFAULT SYSDATE, 
	"DESOCUPACION_FEC_REGI" DATE DEFAULT SYSDATE, 
	"DESOCUPACION_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "DESOCUPACION_PENDIENTE"."TIPO_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   
   COMMENT ON COLUMN "DESOCUPACION_PENDIENTE"."FEC_PEN" IS 'fecha pendiente - Fecha del sistema en la que el registro quedo en pendiente.';
   
   COMMENT ON COLUMN "DESOCUPACION_PENDIENTE"."DESOCUPACION_FEC_REGI" IS 'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';
   
   COMMENT ON TABLE "DESOCUPACION_PENDIENTE"  IS 'Desocupacion Pendiente - Tabla donde se registran las desocupaciones que no cumplieron con las reglas de negocio definidas y quedan pendietes a una auotorizacion.';
   

--------------------------------------------------------
--  Constraints for Table DESOCUPACION_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "DESOCUPACION_PENDIENTE" MODIFY ("TIPO_OBS" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION_PENDIENTE" MODIFY ("FEC_PEN" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION_PENDIENTE" MODIFY ("DESOCUPACION_FEC_REGI" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION_PENDIENTE" MODIFY ("DESOCUPACION_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION_PENDIENTE" ADD CONSTRAINT "DESOCUPACION_PENDIENTE_PK" PRIMARY KEY ("TIPO_OBS", "DESOCUPACION_FEC_REGI", "DESOCUPACION_SOLICITUD") ENABLE;

--------------------------------------------------------
--  DDL for Index DESOCUPACION_PENDIENTE__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "DESOCUPACION_PENDIENTE__IDXV1" ON "DESOCUPACION_PENDIENTE" ("DESOCUPACION_FEC_REGI", "DESOCUPACION_SOLICITUD") 
  ;
