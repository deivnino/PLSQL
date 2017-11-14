--------------------------------------------------------
--  Ref Constraints for Table INGRESO
--------------------------------------------------------

  ALTER TABLE "INGRESO" ADD CONSTRAINT "INGRESO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
