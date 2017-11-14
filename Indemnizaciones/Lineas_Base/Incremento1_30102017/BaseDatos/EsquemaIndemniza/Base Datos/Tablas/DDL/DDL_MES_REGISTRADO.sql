--------------------------------------------------------
--  DDL for Table MES_REGISTRADO
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.MES_REGISTRADO 
   (	MES DATE, 
	CAN_ASEG NUMBER(18,2), 
	RECU_CAN NUMBER(18,2), 
	TOT_CAN NUMBER(18,2), 
	ADM_ASEG NUMBER(18,2), 
	RECU_ADMI NUMBER(18,2), 
	TOT_ADMI NUMBER(18,2), 
	TOTAL_MES NUMBER(18,2), 
	SINIESTRO_FEC_REP DATE DEFAULT SYSDATE, 
	SINI_SOL_SAI_SOLICITUD NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.MES IS 'Mes que se va a reportar.';
   
   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.CAN_ASEG IS 'canon asegurado - Valor de canon asegurado para el mes que se va a reportar.';
   
   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.RECU_CAN IS 'recuperacion canon - Valor de recuperacion para le canon de arrendamiento para el mes reportado.';
   
   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.TOT_CAN IS 'total canon - Valor total de la suma de canon de arredamiento asegurado mas el valor de la recuperacion por mes.';
   
   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.ADM_ASEG IS 'administracion asegurado - Valor de la cuota de administracion asegurada para el mes que se va a reportar.';
   
   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.RECU_ADMI IS 'recuperacion administracion - Valor de recuperacion para la cuota de administracion  para el mes reportado.';
   
   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.TOT_ADMI IS 'total administracion - Valor total de la suma de la cuota de administracion asegurado mas el valor de la recuperacion por mes.';
   
   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.TOTAL_MES IS 'Valor total por mes reportado, que es compuesto por la suma del total canon y el total administracion.';
   
   COMMENT ON COLUMN INDEMNIZA.MES_REGISTRADO.SINIESTRO_FEC_REP IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   
   COMMENT ON TABLE INDEMNIZA.MES_REGISTRADO  IS 'MES REGISTRADO - Tabla donde se almacenan los meses que se van a reportar,segun la fecha de mora ingresada.';
   
   
--------------------------------------------------------
--  Constraints for Table MES_REGISTRADO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (MES NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (CAN_ASEG NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (RECU_CAN NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (TOT_CAN NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (ADM_ASEG NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (RECU_ADMI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (TOT_ADMI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (TOTAL_MES NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (SINIESTRO_FEC_REP NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO MODIFY (SINI_SOL_SAI_SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.MES_REGISTRADO ADD CONSTRAINT MES_REGISTRADO_PK PRIMARY KEY (MES, SINIESTRO_FEC_REP, SINI_SOL_SAI_SOLICITUD) ENABLE;


