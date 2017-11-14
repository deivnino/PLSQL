--------------------------------------------------------
--  Ref Constraints for Table AUMENTO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.AUMENTO ADD CONSTRAINT AUMENTO_SOLICITUD_SAI_FK FOREIGN KEY (SOLICITUD_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SOLICITUD_SAI (SOLICITUD) ENABLE;
	  
