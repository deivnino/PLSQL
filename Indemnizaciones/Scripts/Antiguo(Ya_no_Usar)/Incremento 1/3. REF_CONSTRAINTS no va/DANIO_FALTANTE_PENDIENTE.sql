--------------------------------------------------------
--  Ref Constraints for Table DANIO_FALTANTE_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" ADD CONSTRAINT "DAN_FALT_PEND_REG_DAN_FALT_FK" FOREIGN KEY ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD")
	  REFERENCES "REGISTRO_DANIO_FALTANTE" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
