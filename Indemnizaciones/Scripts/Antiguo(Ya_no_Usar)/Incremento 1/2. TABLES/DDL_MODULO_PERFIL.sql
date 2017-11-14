--------------------------------------------------------
--  DDL for Table MODULO_PERFIL
--------------------------------------------------------

  CREATE TABLE "MODULO_PERFIL" 
   (	"MODULO_COD_MOD" NUMBER(5,0), 
	"PERFIL_COD_PERF" NUMBER(5,0)
   ) ;
   

   COMMENT ON TABLE "MODULO_PERFIL"  IS 'MODULO PERFIL - Tabla donde se asignan los modulos que va a tener un perfil determinado.';
   
   
--------------------------------------------------------
--  Constraints for Table MODULO_PERFIL
--------------------------------------------------------

  ALTER TABLE "MODULO_PERFIL" MODIFY ("MODULO_COD_MOD" NOT NULL ENABLE);
  ALTER TABLE "MODULO_PERFIL" MODIFY ("PERFIL_COD_PERF" NOT NULL ENABLE);
  ALTER TABLE "MODULO_PERFIL" ADD CONSTRAINT "MODULO_PERFIL_PK" PRIMARY KEY ("MODULO_COD_MOD", "PERFIL_COD_PERF") ENABLE;

