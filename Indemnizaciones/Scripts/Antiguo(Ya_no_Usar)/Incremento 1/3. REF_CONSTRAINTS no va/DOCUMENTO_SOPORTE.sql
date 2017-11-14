--------------------------------------------------------
--  Ref Constraints for Table DOCUMENTO_SOPORTE
--------------------------------------------------------

  ALTER TABLE "DOCUMENTO_SOPORTE" ADD CONSTRAINT "DOC_SOP_REG_DAN_FALT_FK" FOREIGN KEY ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD")
	  REFERENCES "REGISTRO_DANIO_FALTANTE" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
