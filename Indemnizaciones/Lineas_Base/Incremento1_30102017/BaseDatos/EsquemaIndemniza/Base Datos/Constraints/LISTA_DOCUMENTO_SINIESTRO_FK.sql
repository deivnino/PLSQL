--------------------------------------------------------
--  Ref Constraints for Table LISTA_DOCUMENTO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.LISTA_DOCUMENTO ADD CONSTRAINT LISTA_DOCUMENTO_SINIESTRO_FK FOREIGN KEY (SINIESTRO_FEC_REP, SINI_SOL_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SINIESTRO (FEC_REP, SOLICITUD_SAI_SOLICITUD) ENABLE;
	  
	  
