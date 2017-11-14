--------------------------------------------------------
--  DDL for Table DESOCUPACION
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.DESOCUPACION 
   (	FEC_REGI DATE, 
	FEC_DESO DATE, 
	TIP_POL VARCHAR2(200), 
	PERIODO VARCHAR2(10), 
	EST_SINI NUMBER(20,0), 
	EST_PAG NUMBER(20,0), 
	SOLICITUD_SAI_SOLICITUD NUMBER(10,0), 
	FEC_MOR DATE, 
	NUM_SINI NUMBER(20,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.DESOCUPACION.FEC_REGI IS 'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';
   
   COMMENT ON COLUMN INDEMNIZA.DESOCUPACION.FEC_DESO IS 'fecha desocupacion - Fecha en la cual se va a realizar la desocupacion.';
   
   COMMENT ON COLUMN INDEMNIZA.DESOCUPACION.TIP_POL IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';
   
   COMMENT ON COLUMN INDEMNIZA.DESOCUPACION.PERIODO IS 'Indica el periodo efectivo calculado en SAI.';
   
   COMMENT ON COLUMN INDEMNIZA.DESOCUPACION.EST_SINI IS 'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';
   
   COMMENT ON COLUMN INDEMNIZA.DESOCUPACION.EST_PAG IS 'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';
   
   COMMENT ON COLUMN INDEMNIZA.DESOCUPACION.FEC_MOR IS 'Fecha de mora del siniestro';
   
   COMMENT ON COLUMN INDEMNIZA.DESOCUPACION.NUM_SINI IS 'Numero del siniestro.';
   
   COMMENT ON TABLE INDEMNIZA.DESOCUPACION  IS 'Tabla donde se registran las desocupaciones que se van a realizar de manera colectiva e individual segun sea el caso.';
   

--------------------------------------------------------
--  Constraints for Table DESOCUPACION
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.DESOCUPACION MODIFY (FEC_REGI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESOCUPACION MODIFY (FEC_DESO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESOCUPACION MODIFY (PERIODO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESOCUPACION MODIFY (EST_SINI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESOCUPACION MODIFY (EST_PAG NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESOCUPACION MODIFY (SOLICITUD_SAI_SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESOCUPACION MODIFY (FEC_MOR NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESOCUPACION MODIFY (NUM_SINI NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DESOCUPACION ADD CONSTRAINT DESOCUPACION_PK PRIMARY KEY (FEC_REGI, SOLICITUD_SAI_SOLICITUD) ENABLE;

