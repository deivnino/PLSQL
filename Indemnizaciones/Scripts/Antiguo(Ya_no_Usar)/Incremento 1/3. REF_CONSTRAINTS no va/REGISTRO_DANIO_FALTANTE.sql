--------------------------------------------------------
--  Ref Constraints for Table REGISTRO_DANIO_FALTANTE
--------------------------------------------------------

  ALTER TABLE "REGISTRO_DANIO_FALTANTE" ADD CONSTRAINT "REG_DAN_FALT_SOL_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
