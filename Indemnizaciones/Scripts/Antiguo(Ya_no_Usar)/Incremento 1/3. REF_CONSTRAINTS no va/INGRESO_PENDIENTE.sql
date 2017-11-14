--------------------------------------------------------
--  Ref Constraints for Table INGRESO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "INGRESO_PENDIENTE" ADD CONSTRAINT "INGRESO_PENDIENTE_INGRESO_FK" FOREIGN KEY ("INGRESO_FEC_REGISTRO_ING", "INGRESO_SOLICITUD")
	  REFERENCES "INGRESO" ("FEC_REGISTRO_ING", "SOLICITUD_SAI_SOLICITUD") ENABLE;
