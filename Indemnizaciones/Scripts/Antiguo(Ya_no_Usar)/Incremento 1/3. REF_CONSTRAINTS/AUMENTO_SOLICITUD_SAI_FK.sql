--------------------------------------------------------
--  Ref Constraints for Table AUMENTO
--------------------------------------------------------

  ALTER TABLE "AUMENTO" ADD CONSTRAINT "AUMENTO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
	  
