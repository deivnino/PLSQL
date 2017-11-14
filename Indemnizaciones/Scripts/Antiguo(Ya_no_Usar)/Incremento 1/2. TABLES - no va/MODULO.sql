--------------------------------------------------------
--  DDL for Table MODULO
--------------------------------------------------------

  CREATE TABLE "MODULO" 
   (	"COD_MOD" NUMBER(5,0), 
	"NOMBRE" VARCHAR2(200)
   ) ;

   
   COMMENT ON COLUMN "MODULO"."COD_MOD" IS 'codigo modulo - Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN "MODULO"."NOMBRE" IS 'aCampo donde se almacena el nombre del modulo.';
   
   COMMENT ON TABLE "MODULO"  IS 'Tabla donde se almacenan las opciones/modulos que tendra la aplicacion';
   

--------------------------------------------------------
--  Constraints for Table MODULO
--------------------------------------------------------

  ALTER TABLE "MODULO" MODIFY ("COD_MOD" NOT NULL ENABLE);
  ALTER TABLE "MODULO" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "MODULO" ADD CONSTRAINT "MODULO_PK" PRIMARY KEY ("COD_MOD") ENABLE;

