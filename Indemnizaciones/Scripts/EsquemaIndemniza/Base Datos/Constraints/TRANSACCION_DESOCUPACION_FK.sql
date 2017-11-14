--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_DESOCUPACION_FK" FOREIGN KEY ("DESOCUPACION_FEC_REGI", "DESO_SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "DESOCUPACION" ("FEC_REGI", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
