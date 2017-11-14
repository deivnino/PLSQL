--------------------------------------------------------
--  Ref Constraints for Table DESISTIMIENTO
--------------------------------------------------------

  ALTER TABLE "DESISTIMIENTO" ADD CONSTRAINT "DESISTIMIENTO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
