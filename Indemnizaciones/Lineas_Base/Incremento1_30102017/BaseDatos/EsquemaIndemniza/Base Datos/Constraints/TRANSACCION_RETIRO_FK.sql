--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.TRANSACCION ADD CONSTRAINT TRANSACCION_RETIRO_FK FOREIGN KEY (RETIRO_FECHA_RETIRO, RETI_SOLICITUD_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.RETIRO (FECHA_RETIRO, SOLICITUD_SAI_SOLICITUD) ENABLE;
	  
	  
