--------------------------------------------------------
--  Ref Constraints for Table REGISTRO_DANIO_FALTANTE
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.REGISTRO_DANIO_FALTANTE ADD CONSTRAINT REG_DAN_FALT_SOL_SAI_FK FOREIGN KEY (SOLICITUD_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SOLICITUD_SAI (SOLICITUD) ENABLE;
	  
