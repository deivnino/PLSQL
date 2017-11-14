--------------------------------------------------------
--  Ref Constraints for Table USUARIO_PERFIL
--------------------------------------------------------

  ALTER TABLE "USUARIO_PERFIL" ADD CONSTRAINT "USUARIO_PERFIL_PERFIL_FK" FOREIGN KEY ("PERFIL_COD_PERF")
	  REFERENCES "PERFIL" ("COD_PERF") ENABLE;
	  
