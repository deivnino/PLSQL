--------------------------------------------------------
--  Ref Constraints for Table RETIRO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.RETIRO ADD CONSTRAINT RETIRO_SOLICITUD_SAI_FK FOREIGN KEY (SOLICITUD_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SOLICITUD_SAI (SOLICITUD) ENABLE;
	  
