--------------------------------------------------------
--  Ref Constraints for Table SERVICIO_PUBLICO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.SERVICIO_PUBLICO ADD CONSTRAINT SERV_PUB_REG_AMP_INTE_FK FOREIGN KEY (REG_AMP_INTE_FEC_REP, REG_AMP_INT_SOLICITUD)
	  REFERENCES INDEMNIZA.REGISTRO_AMPARO_INTEGRAL (FEC_REP, SOLICITUD_SAI_SOLICITUD) ENABLE;
	  
