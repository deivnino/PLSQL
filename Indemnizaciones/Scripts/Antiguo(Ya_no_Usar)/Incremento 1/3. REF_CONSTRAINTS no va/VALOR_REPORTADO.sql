--------------------------------------------------------
--  Ref Constraints for Table VALOR_REPORTADO
--------------------------------------------------------

  ALTER TABLE "VALOR_REPORTADO" ADD CONSTRAINT "VALOR_REPORTADO_SINIESTRO_FK" FOREIGN KEY ("SINIESTRO_FEC_REP", "SINI_SOL_SAI_SOLICITUD")
	  REFERENCES "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
