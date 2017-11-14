--------------------------------------------------------
--  Ref Constraints for Table DESOCUPACION
--------------------------------------------------------

  ALTER TABLE "DESOCUPACION" ADD CONSTRAINT "DESOCUPACION_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
	  
	  
