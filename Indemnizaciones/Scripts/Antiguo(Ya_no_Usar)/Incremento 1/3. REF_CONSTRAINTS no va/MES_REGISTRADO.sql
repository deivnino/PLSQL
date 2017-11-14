--------------------------------------------------------
--  Ref Constraints for Table MES_REGISTRADO
--------------------------------------------------------

  ALTER TABLE "MES_REGISTRADO" ADD CONSTRAINT "MES_REGISTRADO_SINIESTRO_FK" FOREIGN KEY ("SINIESTRO_FEC_REP", "SINI_SOL_SAI_SOLICITUD")
	  REFERENCES "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
