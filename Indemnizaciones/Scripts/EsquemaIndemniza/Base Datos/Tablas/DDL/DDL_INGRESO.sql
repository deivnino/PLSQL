--------------------------------------------------------
--  DDL for Table INGRESO
--------------------------------------------------------

  CREATE TABLE "INGRESO" 
   (	"FEC_REGISTRO_ING" DATE, 
	"FEC_INGRESO" DATE, 
	"CAN_ARRENDAMIENTO" NUMBER(20,2), 
	"VAL_ADMINISTRACION" NUMBER(20,2), 
	"PERIODO" VARCHAR2(10), 
	"ESTADO" NUMBER, 
	"TIPO_IVA" NUMBER(20,0), 
	"VAL_AMP_INTEGRAL" NUMBER(20,0), 
	"METRAJE_AMP_HOGAR" NUMBER(20,2), 
	"VAL_AMP_HOGAR" NUMBER(20,2), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "INGRESO"."FEC_REGISTRO_ING" IS 'Fecha del sistema donde de cuado se esta realizando el registro.';
   
   COMMENT ON COLUMN "INGRESO"."FEC_INGRESO" IS 'fecha ingreso  - Fecha en la que se realizó el ingreso.';
   
   COMMENT ON COLUMN "INGRESO"."CAN_ARRENDAMIENTO" IS 'canon arrendamiento - Valor del canon de arrendamiento asegurado.';
   
   COMMENT ON COLUMN "INGRESO"."VAL_ADMINISTRACION" IS 'valor administracion - Valor del cuota de administración asegurado.';
   
   COMMENT ON COLUMN "INGRESO"."PERIODO" IS 'Indica el periodo efectivo calculado en SAI.';
   
   COMMENT ON COLUMN "INGRESO"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';
   
   COMMENT ON COLUMN "INGRESO"."TIPO_IVA" IS 'Tabla Dominio - Dominio que indica el tipo de iva que va a tener como ingreso,si aplica o no.';
   
   COMMENT ON COLUMN "INGRESO"."VAL_AMP_INTEGRAL" IS 'Tabla Dominio - valor amparo integral - Valor del amapro integral,el cual se va a asegurar';
   
   COMMENT ON COLUMN "INGRESO"."METRAJE_AMP_HOGAR" IS 'Valor del mentraje del inmueble que se va a asegurar por amparo hogar.';
   
   COMMENT ON COLUMN "INGRESO"."VAL_AMP_HOGAR" IS 'Valor que se va a asegurar como amaparo hogar.';
   
   COMMENT ON TABLE "INGRESO"  IS 'Tabla donde se registran los ingresos de las solicitudes.';
   
  ALTER TABLE INDEMNIZA.INGRESO ADD TIP_AUM NUMBER(10,0) NOT NULL;
  ALTER TABLE INDEMNIZA.INGRESO ADD MON_AUM NUMBER(18,2) NOT NULL;
   

 --------------------------------------------------------
--  Constraints for Table INGRESO
--------------------------------------------------------

  ALTER TABLE "INGRESO" MODIFY ("FEC_REGISTRO_ING" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("FEC_INGRESO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("CAN_ARRENDAMIENTO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("VAL_ADMINISTRACION" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" ADD CONSTRAINT "INGRESO_PK" PRIMARY KEY ("FEC_REGISTRO_ING", "SOLICITUD_SAI_SOLICITUD") ENABLE;
