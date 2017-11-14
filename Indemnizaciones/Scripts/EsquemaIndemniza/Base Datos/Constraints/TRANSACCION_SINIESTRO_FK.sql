--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_SINIESTRO_FK" FOREIGN KEY ("SINIESTRO_FEC_REP", "SINIESTRO_SOL_SAI_SOLICITUD")
	  REFERENCES "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
