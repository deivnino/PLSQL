--------------------------------------------------------
--  Ref Constraints for Table DESOCUPACION_PENDIENTE
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.DESOCUPACION_PENDIENTE ADD CONSTRAINT DESO_PEND_DESO_FK FOREIGN KEY (DESOCUPACION_FEC_REGI, DESOCUPACION_SOLICITUD)
	  REFERENCES INDEMNIZA.DESOCUPACION (FEC_REGI, SOLICITUD_SAI_SOLICITUD) ENABLE;
	  
	  
