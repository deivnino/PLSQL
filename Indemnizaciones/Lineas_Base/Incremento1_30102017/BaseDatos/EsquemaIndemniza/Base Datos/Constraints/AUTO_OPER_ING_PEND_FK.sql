--------------------------------------------------------
--  Ref Constraints for Table AUTORIZACION_OPERACION
--------------------------------------------------------
  
  ALTER TABLE INDEMNIZA.AUTORIZACION_OPERACION ADD CONSTRAINT AUTO_OPER_ING_PEND_FK FOREIGN KEY (ING_PEND_INGR_FEC_REGISTRO_ING, ING_PEND_INGR_SOLICITUD, ING_PEND_TIPO_OBS_ING)
	  REFERENCES INDEMNIZA.INGRESO_PENDIENTE (INGRESO_FEC_REGISTRO_ING, INGRESO_SOLICITUD, TIPO_OBS_ING) ENABLE;
	  