--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRAN_REG_DAN_FALT_FK" FOREIGN KEY ("REG_DANIO_FALT_FEC_REP", "REG_DAN_FAL_SOL_SAI_SOLICITUD")
	  REFERENCES "REGISTRO_DANIO_FALTANTE" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
