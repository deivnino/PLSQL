--------------------------------------------------------
--  Ref Constraints for Table SINIESTRO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.SINIESTRO_PENDIENTE ADD CONSTRAINT SINI_PEND_SINI_FK FOREIGN KEY (SINIESTRO_FEC_REP, SINIESTRO_SOLICITUD)
	  REFERENCES INDEMNIZA.SINIESTRO (FEC_REP, SOLICITUD_SAI_SOLICITUD) ENABLE;
	  
	  
