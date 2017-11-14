--------------------------------------------------------
--  Ref Constraints for Table RETIRO
--------------------------------------------------------

  ALTER TABLE "RETIRO" ADD CONSTRAINT "RETIRO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
