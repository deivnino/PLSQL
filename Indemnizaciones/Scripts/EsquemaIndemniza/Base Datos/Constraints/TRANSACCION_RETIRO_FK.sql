--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_RETIRO_FK" FOREIGN KEY ("RETIRO_FECHA_RETIRO", "RETI_SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "RETIRO" ("FECHA_RETIRO", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
	  
