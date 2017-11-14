--------------------------------------------------------
--  DDL for Table SOLICITUD_SAI
--------------------------------------------------------

  CREATE TABLE "SOLICITUD_SAI" 
   (	"SOLICITUD" NUMBER(22,0), 
	"INQUILINO" VARCHAR2(100), 
	"DESTINACION" VARCHAR2(100), 
	"TIPO_INMU" VARCHAR2(100), 
	"POLIZA" NUMBER(22,0), 
	"DIRECCION" VARCHAR2(100), 
	"CIUDAD" VARCHAR2(100), 
	"CANON" NUMBER(20,2), 
	"ADMINISTRACION" NUMBER(20,2), 
	"CANO_ASEG" NUMBER(20,2), 
	"ADMI_ASEG" NUMBER(20,2), 
	"AMP_HOG_ASEG" NUMBER(20,2), 
	"AMP_INT_ASEG" NUMBER(20,2), 
	"NUEV_VAL_ASEG" NUMBER(20,2), 
	"FEC_NOVE" DATE, 
	"EST_SOLI" VARCHAR2(2), 
	"EST_SINI" VARCHAR2(2), 
	"EST_PAGO" VARCHAR2(2), 
	"FEC_MORA" DATE, 
	"FEC_INGR" DATE, 
	"FEC_ESTU" DATE, 
	"FEC_DESO" DATE, 
	"FEC_RETI" DATE, 
	"FEC_INI_CONT" DATE, 
	"TIP_IDENTIFICA" VARCHAR2(2), 
	"NUM_IDENTIFICA" NUMBER(12,0), 
	"EMAIL_INMOBILIARIA" VARCHAR2(100)
   ) ;

   COMMENT ON COLUMN "SOLICITUD_SAI"."SOLICITUD" IS 'Numero de la solicitud de SAI';
   
   COMMENT ON COLUMN "SOLICITUD_SAI"."DESTINACION" IS 'Comercial-Vivienda';
   
   COMMENT ON COLUMN "SOLICITUD_SAI"."TIPO_INMU" IS 'Apartamento-Local-Casa-Oficina';
   
   COMMENT ON COLUMN "SOLICITUD_SAI"."CANON" IS 'Validar';
   
   COMMENT ON TABLE "SOLICITUD_SAI"  IS 'Datos Basicos Sai Conexion - Tabla usada para consultar los datos basicos de SAI,cuan SAI este caido,esta tabla se ira actualizando a medida que se consulte la informacion en SAI. Actualiza constantemente la tabla con los datos de consulta de SAI,solo se usaria para consultas';


--------------------------------------------------------
--  Constraints for Table SOLICITUD_SAI
--------------------------------------------------------

  ALTER TABLE "SOLICITUD_SAI" MODIFY ("SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "SOLICITUD_SAI" ADD CONSTRAINT "SOLICITUD_SAI_PK" PRIMARY KEY ("SOLICITUD") ENABLE;

