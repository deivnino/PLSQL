--------------------------------------------------------
--  DDL for Table VALOR_REPORTADO
--------------------------------------------------------

  CREATE TABLE "VALOR_REPORTADO" 
   (	"COD_VAL_REPOR" NUMBER(15,0), 
	"TIP_CON" NUMBER(20,0), 
	"PER_INI" DATE, 
	"PER_FIN" DATE, 
	"VAL_REPO" NUMBER(18,2), 
	"SINIESTRO_FEC_REP" DATE, 
	"SINI_SOL_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "VALOR_REPORTADO"."COD_VAL_REPOR" IS 'codigo valor reportado - Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN "VALOR_REPORTADO"."TIP_CON" IS 'tipo concepto - Dominio que indica el tipo de concepto del pago: REM01,RM,01,02';
   
   COMMENT ON COLUMN "VALOR_REPORTADO"."PER_INI" IS 'periodo inicio - Fecha de inicio del valor reportado del siniestro.';
   
   COMMENT ON COLUMN "VALOR_REPORTADO"."PER_FIN" IS 'periodo fin - Fecha fin del valor reportado del siniestro.';
   
   COMMENT ON COLUMN "VALOR_REPORTADO"."VAL_REPO" IS 'valor reportado';
   
   COMMENT ON COLUMN "VALOR_REPORTADO"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   
   COMMENT ON TABLE "VALOR_REPORTADO"  IS 'VALOR REPORTADO - Tabla donde se ingresan los valores que se van a reportar en SAI (valores de desfase,valores de reporte de siniestro,Valores por Recueracion).';
   
   
--------------------------------------------------------
--  Constraints for Table VALOR_REPORTADO
--------------------------------------------------------

  ALTER TABLE "VALOR_REPORTADO" MODIFY ("COD_VAL_REPOR" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("TIP_CON" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("PER_INI" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("PER_FIN" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("VAL_REPO" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("SINIESTRO_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("SINI_SOL_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" ADD CONSTRAINT "VALOR_REPORTADO_PK" PRIMARY KEY ("COD_VAL_REPOR") ENABLE;

