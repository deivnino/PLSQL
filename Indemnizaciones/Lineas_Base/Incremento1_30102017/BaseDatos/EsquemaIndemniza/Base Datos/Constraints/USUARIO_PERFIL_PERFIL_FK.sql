--------------------------------------------------------
--  Ref Constraints for Table USUARIO_PERFIL
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.USUARIO_PERFIL ADD CONSTRAINT USUARIO_PERFIL_PERFIL_FK FOREIGN KEY (PERFIL_COD_PERF)
	  REFERENCES INDEMNIZA.PERFIL (COD_PERF) ENABLE;
	  
