--------------------------------------------------------
--  Ref Constraints for Table ALERTA
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.ALERTA ADD CONSTRAINT ALERTA_TRANSACCION_FK FOREIGN KEY (TRANSACCION_COD_TRAN)
	  REFERENCES INDEMNIZA.TRANSACCION (COD_TRAN) ENABLE;
	  
