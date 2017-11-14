--------------------------------------------------------
--  Ref Constraints for Table DESISTIMIENTO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.DESISTIMIENTO ADD CONSTRAINT DESISTIMIENTO_SOLICITUD_SAI_FK FOREIGN KEY (SOLICITUD_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SOLICITUD_SAI (SOLICITUD) ENABLE;
	  
