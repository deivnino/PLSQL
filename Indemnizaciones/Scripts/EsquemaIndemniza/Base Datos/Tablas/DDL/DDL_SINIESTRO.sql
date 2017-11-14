--------------------------------------------------------
--  DDL for Table SINIESTRO
--------------------------------------------------------

  CREATE TABLE "SINIESTRO" 
   (	"FEC_REP" DATE, 
	"COD_SINI_SAI" NUMBER(10,0), 
	"FEC_MORA" DATE, 
	"FEC_INI_CONT" DATE, 
	"FEC_FIN_CONT" DATE, 
	"PERIODO" VARCHAR2(10), 
	"TIP_POL" VARCHAR2(200), 
	"TIPO_REP_SINI" VARCHAR2(30), 
	"CUOT_ADM" CHAR(1), 
	"EST_PAGO" NUMBER(20,0), 
	"EST_SINI" NUMBER(20,0), 
	"CANO_ARRE_REPO" NUMBER(20,2), 
	"VAL_ADMI_REPO" NUMBER(20,2), 
	"OBSERVACION" VARCHAR2(400), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "SINIESTRO"."FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   
   COMMENT ON COLUMN "SINIESTRO"."COD_SINI_SAI" IS 'codigo siniestro SAI - Campo donde se almancena el numero del reporte de siniestro generado en SAI.';
   
   COMMENT ON COLUMN "SINIESTRO"."FEC_MORA" IS 'fecha mora - Fehca de mora que se esta reportando en el siniestro';
   
   COMMENT ON COLUMN "SINIESTRO"."FEC_INI_CONT" IS 'fecha inicio contrato - Fecha de inicio de cuando se inicia el contrato';
   
   COMMENT ON COLUMN "SINIESTRO"."FEC_FIN_CONT" IS 'fecha fin contrato - Fecha de fin de cuando se inicia el contrato';
   
   COMMENT ON COLUMN "SINIESTRO"."PERIODO" IS 'Indica el periodo efectivo calculado en SAI.';
   
   COMMENT ON COLUMN "SINIESTRO"."TIP_POL" IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrando la desocupacion,colectiva/individual';
   
   COMMENT ON COLUMN "SINIESTRO"."TIPO_REP_SINI" IS 'tipo reporte siniestro - Dominio donde se indica el tipo de reporte de siniestro (Personalizado,Masivo)';
   
   COMMENT ON COLUMN "SINIESTRO"."CUOT_ADM" IS 'cuota administracion - campo que indica si se va a reportar o no la cuota de administracion.';
   
   COMMENT ON COLUMN "SINIESTRO"."EST_PAGO" IS 'Tabla dominio que indica el estado del pago del siniestro.';
   
   COMMENT ON COLUMN "SINIESTRO"."EST_SINI" IS 'Tabla dominio que indica el estado del siniestro';
   
   COMMENT ON COLUMN "SINIESTRO"."CANO_ARRE_REPO" IS 'canon arrendamiento reportado - Valor usado para el reporte individual.';
   
   COMMENT ON COLUMN "SINIESTRO"."VAL_ADMI_REPO" IS 'valor administracion reportado - Valor usado para el reporte individual';
   
   COMMENT ON TABLE "SINIESTRO"  IS 'Tabla donde se registran el reporte de siniestros personalizado y masivo segun sea el caso.';
   

 --------------------------------------------------------
--  Constraints for Table SINIESTRO
--------------------------------------------------------

  ALTER TABLE "SINIESTRO" MODIFY ("FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("COD_SINI_SAI" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("FEC_MORA" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("TIP_POL" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("TIPO_REP_SINI" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("CUOT_ADM" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("EST_PAGO" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("EST_SINI" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" ADD CHECK (
    tipo_rep_sini IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "SINIESTRO" ADD CONSTRAINT "SINIESTRO_PK" PRIMARY KEY ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;

