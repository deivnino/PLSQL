--------------------------------------------------------
--  DDL for Table DESISTIMIENTO
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.DESISTIMIENTO 
   (	FEC_REG DATE, 
	COD_SINI NUMBER(10,0), 
	FEC_DESI DATE, 
	PERIODO VARCHAR2(10), 
	TIPO_POLI VARCHAR2(200), 
	EST_SINI NUMBER(20,0), 
	EST_PAGO NUMBER(20,0), 
	SOLICITUD_SAI_SOLICITUD NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.DESISTIMIENTO.FEC_REG IS 'fecha registro - fecha del sistema en el que se esta haciendo el desistimiento.';
   
   COMMENT ON COLUMN INDEMNIZA.DESISTIMIENTO.COD_SINI IS 'codigo siniestro - Codigo del siniestro generado en SAI.';
   
   COMMENT ON COLUMN INDEMNIZA.DESISTIMIENTO.FEC_DESI IS 'fecha desistimiento - Campor donde se registra la fecha del desistimiento.';
   
   COMMENT ON COLUMN INDEMNIZA.DESISTIMIENTO.PERIODO IS 'Indica el periodo efectivo calculado en SAI.';
   
   COMMENT ON COLUMN INDEMNIZA.DESISTIMIENTO.TIPO_POLI IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';
   
   COMMENT ON COLUMN INDEMNIZA.DESISTIMIENTO.EST_SINI IS 'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';
   
   COMMENT ON COLUMN INDEMNIZA.DESISTIMIENTO.EST_PAGO IS 'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';
   
   COMMENT ON TABLE INDEMNIZA.DESISTIMIENTO  IS 'Tabla donde se registran los desistimientos que se realizen sobre una solicitud que se encuetre siniestrada.';
   
   
--------------------------------------------------------
--  Constraints for Table DESISTIMIENTO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.DESISTIMIENTO MODIFY (FEC_REG NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESISTIMIENTO MODIFY (COD_SINI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESISTIMIENTO MODIFY (FEC_DESI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESISTIMIENTO MODIFY (PERIODO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESISTIMIENTO MODIFY (TIPO_POLI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESISTIMIENTO MODIFY (EST_SINI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESISTIMIENTO MODIFY (EST_PAGO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESISTIMIENTO MODIFY (SOLICITUD_SAI_SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESISTIMIENTO ADD CONSTRAINT DESISTIMIENTO_PK PRIMARY KEY (FEC_REG, SOLICITUD_SAI_SOLICITUD) ENABLE;

