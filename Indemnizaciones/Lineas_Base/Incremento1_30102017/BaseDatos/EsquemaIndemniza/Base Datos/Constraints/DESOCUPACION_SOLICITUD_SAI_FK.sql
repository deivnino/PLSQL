--------------------------------------------------------
--  Ref Constraints for Table DESOCUPACION
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.DESOCUPACION ADD CONSTRAINT DESOCUPACION_SOLICITUD_SAI_FK FOREIGN KEY (SOLICITUD_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SOLICITUD_SAI (SOLICITUD) ENABLE;
	  
	  
