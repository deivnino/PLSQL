--------------------------------------------------------
--  Ref Constraints for Table VAL_DOMINIO
--------------------------------------------------------

  ALTER TABLE "VAL_DOMINIO" ADD CONSTRAINT "VAL_DOMINIO_DOMINIO_FK" FOREIGN KEY ("DOMINIO_COD_DOMINIO")
	  REFERENCES "DOMINIO" ("COD_DOMINIO") ENABLE;
