--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------
  ALTER TABLE INDEMNIZA.TRANSACCION ADD CONSTRAINT TRAN_LOG_SERV_SIMI_FK FOREIGN KEY (LOG_SERV_SIMI_COD_LOG_SERV)
	  REFERENCES INDEMNIZA.LOG_SERVICIO_SIMI (COD_LOG_SERV) ENABLE;
	  
	  