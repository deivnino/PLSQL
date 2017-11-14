--------------------------------------------------------
--  DDL for Table INGRESO_PENDIENTE
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.INGRESO_PENDIENTE 
   (	TIPO_OBS_ING NUMBER(20,0), 
	FEC_PEND DATE DEFAULT SYSDATE, 
	ESTADO NUMBER(20,0), 
	INGRESO_FEC_REGISTRO_ING DATE DEFAULT SYSDATE, 
	INGRESO_SOLICITUD NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.INGRESO_PENDIENTE.TIPO_OBS_ING IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes';
   
   COMMENT ON COLUMN INDEMNIZA.INGRESO_PENDIENTE.FEC_PEND IS 'fecha pendiente - Fecha en la cual el ingreso quedo pendiente.';
   
   COMMENT ON COLUMN INDEMNIZA.INGRESO_PENDIENTE.ESTADO IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';
   
   COMMENT ON COLUMN INDEMNIZA.INGRESO_PENDIENTE.INGRESO_FEC_REGISTRO_ING IS 'Fecha del sistema donde de cuado se esta realizando el registro.';
   
   COMMENT ON TABLE INDEMNIZA.INGRESO_PENDIENTE  IS 'Tabla donde se registran los ingresos pendientes,los que no cumplieron con las reglas de negocio definidas.';
   
   
--------------------------------------------------------
--  Constraints for Table INGRESO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.INGRESO_PENDIENTE MODIFY (TIPO_OBS_ING NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.INGRESO_PENDIENTE MODIFY (FEC_PEND NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.INGRESO_PENDIENTE MODIFY (ESTADO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.INGRESO_PENDIENTE MODIFY (INGRESO_FEC_REGISTRO_ING NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.INGRESO_PENDIENTE MODIFY (INGRESO_SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.INGRESO_PENDIENTE ADD CONSTRAINT INGRESO_PENDIENTE_PK PRIMARY KEY (INGRESO_FEC_REGISTRO_ING, INGRESO_SOLICITUD, TIPO_OBS_ING) ENABLE;

--------------------------------------------------------
--  DDL for Index INGRESO_PENDIENTE__IDXV1
--------------------------------------------------------

  CREATE INDEX INDEMNIZA.INGRESO_PENDIENTE__IDXV1 ON INDEMNIZA.INGRESO_PENDIENTE (INGRESO_FEC_REGISTRO_ING, INGRESO_SOLICITUD) 
  ;
--------------------------------------------------------
--  DDL for Index INGRESO_PENDIENTE__IDX
--------------------------------------------------------

  CREATE INDEX INDEMNIZA.INGRESO_PENDIENTE__IDX ON INDEMNIZA.INGRESO_PENDIENTE (TIPO_OBS_ING, ESTADO) 
  ;

