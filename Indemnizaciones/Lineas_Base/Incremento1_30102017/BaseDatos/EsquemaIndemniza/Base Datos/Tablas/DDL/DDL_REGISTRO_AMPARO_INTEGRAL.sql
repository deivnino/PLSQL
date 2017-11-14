--------------------------------------------------------
--  DDL for Table REGISTRO_AMPARO_INTEGRAL
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL 
   (	FEC_REP DATE, 
	TIPO_POLI VARCHAR2(200), 
	FECHA_MORA DATE, 
	TOT_RECL NUMBER(20,2), 
	EST_SINI NUMBER(20,0), 
	EST_PAGO NUMBER(20,0), 
	SOLICITUD_SAI_SOLICITUD NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.REGISTRO_AMPARO_INTEGRAL.FEC_REP IS 'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';
   
   COMMENT ON COLUMN INDEMNIZA.REGISTRO_AMPARO_INTEGRAL.TIPO_POLI IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrando la desocupacion,colectiva/individual';
   
   COMMENT ON COLUMN INDEMNIZA.REGISTRO_AMPARO_INTEGRAL.FECHA_MORA IS 'fec mora - Campo donde se registra la fecha de mora que se va a ingresar.';
   
   COMMENT ON COLUMN INDEMNIZA.REGISTRO_AMPARO_INTEGRAL.TOT_RECL IS 'total reclamar - Campo donde se registra el valor total que se va a reclamar.';
   
   COMMENT ON COLUMN INDEMNIZA.REGISTRO_AMPARO_INTEGRAL.EST_SINI IS 'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';
   
   COMMENT ON COLUMN INDEMNIZA.REGISTRO_AMPARO_INTEGRAL.EST_PAGO IS 'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro';
   
   COMMENT ON TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL  IS 'REGI AMPA INTE - Tabla donde se registra los reportes de amparo integral.';
   

--------------------------------------------------------
--  Constraints for Table REGISTRO_AMPARO_INTEGRAL
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL MODIFY (FEC_REP NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL MODIFY (FECHA_MORA NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL MODIFY (TOT_RECL NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL MODIFY (EST_SINI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL MODIFY (EST_PAGO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL MODIFY (SOLICITUD_SAI_SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.REGISTRO_AMPARO_INTEGRAL ADD CONSTRAINT REGISTRO_AMPARO_INTEGRAL_PK PRIMARY KEY (FEC_REP, SOLICITUD_SAI_SOLICITUD) ENABLE;
