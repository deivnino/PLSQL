--------------------------------------------------------
--  Ref Constraints for Table AUMENTO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "AUMENTO_PENDIENTE" ADD CONSTRAINT "AUMENTO_PENDIENTE_AUMENTO_FK" FOREIGN KEY ("AUMENTO_FEC_AUMENTO", "AUMENTO_SOLICITUD")
	  REFERENCES "AUMENTO" ("FEC_AUMENTO", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
