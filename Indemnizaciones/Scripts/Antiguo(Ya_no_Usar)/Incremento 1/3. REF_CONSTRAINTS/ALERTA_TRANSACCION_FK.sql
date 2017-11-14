--------------------------------------------------------
--  Ref Constraints for Table ALERTA
--------------------------------------------------------

  ALTER TABLE "ALERTA" ADD CONSTRAINT "ALERTA_TRANSACCION_FK" FOREIGN KEY ("TRANSACCION_COD_TRAN")
	  REFERENCES "TRANSACCION" ("COD_TRAN") ENABLE;
	  
