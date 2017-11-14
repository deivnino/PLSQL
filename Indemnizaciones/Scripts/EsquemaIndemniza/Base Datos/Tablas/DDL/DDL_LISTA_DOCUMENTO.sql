--------------------------------------------------------
--  DDL for Table LISTA_DOCUMENTO
--------------------------------------------------------

  CREATE TABLE "LISTA_DOCUMENTO" 
   (	"COD_LIST_DOC" NUMBER(15,0), 
	"COD_DOC" NUMBER(5,0), 
	"NOMBRE" VARCHAR2(200), 
	"APLICA" CHAR(1), 
	"COD_REPO" NUMBER(10,0), 
	"RUTA_REPO" VARCHAR2(400), 
	"SINIESTRO_FEC_REP" DATE, 
	"SINI_SOL_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "LISTA_DOCUMENTO"."COD_LIST_DOC" IS 'codigo lista documento - Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."COD_DOC" IS 'codigo documento - En este atribuo se almacena el codigo que tiene el documeno en SAI.';
   
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."NOMBRE" IS 'Nombre que tiene el documento en SAI.';
   
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."APLICA" IS 'Campo que indica si el documento aplica o no para el reporte de siniestro.';
   
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."COD_REPO" IS 'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';
   
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."RUTA_REPO" IS 'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';
   
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   
   COMMENT ON TABLE "LISTA_DOCUMENTO"  IS 'Lista Documento - Tabla donde se almacena la lista de documentos que se ingresa en el reporte de siniestros.';
   

--------------------------------------------------------
--  Constraints for Table LISTA_DOCUMENTO
--------------------------------------------------------

  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("COD_LIST_DOC" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("COD_DOC" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("APLICA" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("SINIESTRO_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("SINI_SOL_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" ADD CONSTRAINT "LISTA_DOCUMENTO_PK" PRIMARY KEY ("COD_LIST_DOC") ENABLE;

