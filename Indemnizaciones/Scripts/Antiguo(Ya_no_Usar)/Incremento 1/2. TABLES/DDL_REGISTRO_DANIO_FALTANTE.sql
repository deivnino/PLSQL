--------------------------------------------------------
--  DDL for Table REGISTRO_DANIO_FALTANTE
--------------------------------------------------------

  CREATE TABLE "REGISTRO_DANIO_FALTANTE" 
   (	"FEC_REP" DATE, 
	"FEC_MOR" DATE, 
	"VAL_ASEG" NUMBER(20,2), 
	"VAL_RECL" NUMBER(20,2), 
	"TIP_POL" VARCHAR2(200), 
	"PERIODO" VARCHAR2(10), 
	"ESTA_SINI" NUMBER(20,0), 
	"EST_PAG" NUMBER, 
	"OBSERVACION" VARCHAR2(200), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."FEC_REP" IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."FEC_MOR" IS 'fecha mora - Campo donde se registra la fecha de mora de el reporte de danios y faltantes.';
   
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."VAL_ASEG" IS 'val aseg - valor del amparo hogar asegurado';
   
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."VAL_RECL" IS 'valor reclamar - Campo donde se almacena el valor que va a ser reclamado.';
   
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."TIP_POL" IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';
   
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."PERIODO" IS 'Indica el periodo efectivo calculado en SAI.';
   
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."ESTA_SINI" IS 'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';
   
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."EST_PAG" IS 'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';
   
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."OBSERVACION" IS 'Campo donde se guarda la observacion de registro si se tiene.';
   
   COMMENT ON TABLE "REGISTRO_DANIO_FALTANTE"  IS 'Tabla donde se registran el reporte de daños y faltantes.';
   

--------------------------------------------------------
--  Constraints for Table REGISTRO_DANIO_FALTANTE
--------------------------------------------------------

  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("FEC_MOR" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("VAL_ASEG" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("VAL_RECL" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("ESTA_SINI" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("EST_PAG" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" ADD CONSTRAINT "REGISTRO_DANIO_FALTANTE_PK" PRIMARY KEY ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
