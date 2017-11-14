--------------------------------------------------------
--  DDL for Table AUMENTO
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.AUMENTO 
   (	FEC_AUMENTO DATE, 
	CANO_ARRENDA_AUME NUMBER(20,2), 
	VAL_ADMIN_AUM NUMBER(20,2), 
	PERIODO VARCHAR2(10), 
	ESTADO NUMBER(20,0), 
	SOLICITUD_SAI_SOLICITUD NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.AUMENTO.FEC_AUMENTO IS 'fecha aumento - Fecha en la cual se esta realizando el aumento.';
   COMMENT ON COLUMN INDEMNIZA.AUMENTO.CANO_ARRENDA_AUME IS 'canon arrendamiento aumento - Valor del canon de arrendamiento que esta siendo aumentado';
   COMMENT ON COLUMN INDEMNIZA.AUMENTO.VAL_ADMIN_AUM IS 'valor administracion aumento - Valor de administracion que esta siendo aumentado';
   COMMENT ON COLUMN INDEMNIZA.AUMENTO.PERIODO IS 'Indica el periodo calculado en SAI en el cual se hace el aumento.';
   COMMENT ON COLUMN INDEMNIZA.AUMENTO.ESTADO IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';
   COMMENT ON TABLE INDEMNIZA.AUMENTO  IS 'Tabla donde se registran los aumentos que se le van a realizar a una solicitud.';

--------------------------------------------------------
--  Constraints for Table AUMENTO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.AUMENTO MODIFY (FEC_AUMENTO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUMENTO MODIFY (CANO_ARRENDA_AUME NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUMENTO MODIFY (VAL_ADMIN_AUM NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUMENTO MODIFY (PERIODO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUMENTO MODIFY (ESTADO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUMENTO MODIFY (SOLICITUD_SAI_SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUMENTO ADD CONSTRAINT AUMENTO_PK PRIMARY KEY (FEC_AUMENTO, SOLICITUD_SAI_SOLICITUD) ENABLE;


