--------------------------------------------------------
--  Ref Constraints for Table INGRESO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.INGRESO ADD CONSTRAINT INGRESO_SOLICITUD_SAI_FK FOREIGN KEY (SOLICITUD_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SOLICITUD_SAI (SOLICITUD) ENABLE;
	  
	  
