--------------------------------------------------------
--  Ref Constraints for Table MES_REGISTRADO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.MES_REGISTRADO ADD CONSTRAINT MES_REGISTRADO_SINIESTRO_FK FOREIGN KEY (SINIESTRO_FEC_REP, SINI_SOL_SAI_SOLICITUD)
	  REFERENCES INDEMNIZA.SINIESTRO (FEC_REP, SOLICITUD_SAI_SOLICITUD) ENABLE;
	  
