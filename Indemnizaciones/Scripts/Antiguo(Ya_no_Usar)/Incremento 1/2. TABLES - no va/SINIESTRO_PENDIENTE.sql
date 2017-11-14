--------------------------------------------------------
--  DDL for Table SINIESTRO_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "SINIESTRO_PENDIENTE" 
   (	"TIP_OBS" NUMBER(20,0), 
	"FEC_PEND" DATE DEFAULT SYSDATE, 
	"SINIESTRO_FEC_REP" DATE DEFAULT SYSDATE, 
	"SINIESTRO_SOLICITUD" NUMBER(10,0), 
	"FEC_OBJECION" DATE
   ) ;

   COMMENT ON COLUMN "SINIESTRO_PENDIENTE"."TIP_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   
   COMMENT ON COLUMN "SINIESTRO_PENDIENTE"."FEC_PEND" IS 'fecha pendiente -  Fecha del sistema en la que el registro quedo en pendiente.';
   
   COMMENT ON COLUMN "SINIESTRO_PENDIENTE"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   
   COMMENT ON TABLE "SINIESTRO_PENDIENTE"  IS 'SINIESTRO PENDIENTE - Tabla donde se almacenan los siniestros pendients,los que no cumplieron con las reglas de negocio definidas,y quedan pendietes a ser verificadas.';
   
   
--------------------------------------------------------
--  Constraints for Table SINIESTRO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("FEC_OBJECION" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("TIP_OBS" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("FEC_PEND" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("SINIESTRO_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("SINIESTRO_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" ADD CONSTRAINT "SINIESTRO_PENDIENTE_PK" PRIMARY KEY ("SINIESTRO_FEC_REP", "SINIESTRO_SOLICITUD", "TIP_OBS") ENABLE;

--------------------------------------------------------
--  DDL for Index SINIESTRO_PENDIENTE__IDX
--------------------------------------------------------

  CREATE INDEX "SINIESTRO_PENDIENTE__IDX" ON "SINIESTRO_PENDIENTE" ("TIP_OBS") 
  ;
--------------------------------------------------------
--  DDL for Index SINIESTRO_PENDIENTE__IDXV1
--------------------------------------------------------

  CREATE INDEX "SINIESTRO_PENDIENTE__IDXV1" ON "SINIESTRO_PENDIENTE" ("SINIESTRO_FEC_REP", "SINIESTRO_SOLICITUD") 
  ;

