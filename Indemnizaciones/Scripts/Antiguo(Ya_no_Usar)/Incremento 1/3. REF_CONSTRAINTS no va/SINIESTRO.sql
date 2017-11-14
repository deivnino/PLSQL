--------------------------------------------------------
--  Ref Constraints for Table SINIESTRO
--------------------------------------------------------

  ALTER TABLE "SINIESTRO" ADD CONSTRAINT "SINIESTRO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
