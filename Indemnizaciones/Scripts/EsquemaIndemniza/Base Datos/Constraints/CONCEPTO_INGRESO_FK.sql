--------------------------------------------------------
--  Ref Constraints for Table ALERTA
--------------------------------------------------------
  
  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO ADD CONSTRAINT CONCEPTO_INGRESO_INGRESO_FK FOREIGN KEY ( ING_FEC_REGISTRO_ING,ING_SOL_SAI_SOLICITUD )
    REFERENCES INGRESO ( FEC_REGISTRO_ING,SOLICITUD_SAI_SOLICITUD );
	  
