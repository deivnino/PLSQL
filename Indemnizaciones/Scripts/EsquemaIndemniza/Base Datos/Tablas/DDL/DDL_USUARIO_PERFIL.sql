--------------------------------------------------------
--  DDL for Table USUARIO_PERFIL
--------------------------------------------------------

  CREATE TABLE "USUARIO_PERFIL" 
   (	"COD_USU" NUMBER(5,0), 
	"PERFIL_COD_PERF" NUMBER(5,0)
   ) ;

   COMMENT ON COLUMN "USUARIO_PERFIL"."COD_USU" IS 'codigo usuario - Campo donde se alamcena el codigo del usuario que se le va asignar el perfil.';
   
   COMMENT ON TABLE "USUARIO_PERFIL"  IS 'USUARIO PERFIL - Tabla donde se asignaran los perfiles por usuario de la  aplicacion.';
   

--------------------------------------------------------
--  Constraints for Table USUARIO_PERFIL
--------------------------------------------------------

  ALTER TABLE "USUARIO_PERFIL" MODIFY ("COD_USU" NOT NULL ENABLE);
  ALTER TABLE "USUARIO_PERFIL" MODIFY ("PERFIL_COD_PERF" NOT NULL ENABLE);
  ALTER TABLE "USUARIO_PERFIL" ADD CONSTRAINT "USUARIO_PERFIL_PK" PRIMARY KEY ("PERFIL_COD_PERF") ENABLE;
