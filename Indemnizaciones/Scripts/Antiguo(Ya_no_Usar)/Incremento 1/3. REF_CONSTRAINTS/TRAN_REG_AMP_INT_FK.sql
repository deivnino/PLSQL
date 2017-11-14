--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRAN_REG_AMP_INT_FK" FOREIGN KEY ("REG_AMPARO_INTEGRAL_FEC_REP", "REG_AMP_INTE_SOL_SAI_SOLICITUD")
	  REFERENCES "REGISTRO_AMPARO_INTEGRAL" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
	  
