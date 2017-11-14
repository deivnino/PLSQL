--------------------------------------------------------
--  Ref Constraints for Table MODULO_PERFIL
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.MODULO_PERFIL ADD CONSTRAINT MODULO_PERFIL_MODULO_FK FOREIGN KEY (MODULO_COD_MOD)
	  REFERENCES INDEMNIZA.MODULO (COD_MOD) ENABLE;
	  
	  
