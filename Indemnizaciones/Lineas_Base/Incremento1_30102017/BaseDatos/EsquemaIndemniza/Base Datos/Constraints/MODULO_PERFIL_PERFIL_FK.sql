--------------------------------------------------------
--  Ref Constraints for Table MODULO_PERFIL
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.MODULO_PERFIL ADD CONSTRAINT MODULO_PERFIL_PERFIL_FK FOREIGN KEY (PERFIL_COD_PERF)
	  REFERENCES INDEMNIZA.PERFIL (COD_PERF) ENABLE;
	  
