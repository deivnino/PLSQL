--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_DESISTIMIENTO_FK" FOREIGN KEY ("DESISTIMIENTO_FEC_REG", "DESIS_SOL_SAI_SOLICITUD")
	  REFERENCES "DESISTIMIENTO" ("FEC_REG", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
	  
