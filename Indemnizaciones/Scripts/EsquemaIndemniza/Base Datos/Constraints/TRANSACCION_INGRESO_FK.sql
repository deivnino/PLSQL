--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_INGRESO_FK" FOREIGN KEY ("INGRESO_FEC_REGISTRO_ING", "ING_SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "INGRESO" ("FEC_REGISTRO_ING", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
	  
