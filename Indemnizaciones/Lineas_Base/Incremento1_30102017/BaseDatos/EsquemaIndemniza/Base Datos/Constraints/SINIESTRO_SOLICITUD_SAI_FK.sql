--------------------------------------------------------
--  Ref Constraints for Table SINIESTRO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.SINIESTRO ADD CONSTRAINT SINIESTRO_SOLICITUD_SAI_FK FOREIGN KEY (SOLICITUD_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SOLICITUD_SAI (SOLICITUD) ENABLE;
	  
