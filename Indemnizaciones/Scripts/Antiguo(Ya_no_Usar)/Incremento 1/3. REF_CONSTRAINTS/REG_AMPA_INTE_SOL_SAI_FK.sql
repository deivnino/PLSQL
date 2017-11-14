--------------------------------------------------------
--  Ref Constraints for Table REGISTRO_AMPARO_INTEGRAL
--------------------------------------------------------

  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" ADD CONSTRAINT "REG_AMPA_INTE_SOL_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
	  
