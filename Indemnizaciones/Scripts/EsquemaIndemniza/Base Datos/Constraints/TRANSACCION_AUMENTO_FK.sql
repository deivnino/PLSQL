--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_AUMENTO_FK" FOREIGN KEY ("AUMENTO_FEC_AUMENTO", "AUM_SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "AUMENTO" ("FEC_AUMENTO", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
	  
