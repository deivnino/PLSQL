--------------------------------------------------------
--  DDL for Table MES_REGISTRADO
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.CONCEPTO_INGRESO (
    COD_CON_ING             NUMBER(10),
    COD_AMPARO              VARCHAR2(10 BYTE),
    COD_CONCEPTO            VARCHAR2(10 BYTE),
    NUEVO_VALOR             NUMBER(18,2),
    VALOR_ESTUDIO           NUMBER(18,2),
    ING_FEC_REGISTRO_ING    DATE,
    ING_SOL_SAI_SOLICITUD   NUMBER(10)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.CONCEPTO_INGRESO.COD_CON_ING IS 'Campo autoincremental de la tabla';
   
   COMMENT ON COLUMN INDEMNIZA.CONCEPTO_INGRESO.COD_AMPARO IS 'Codigo SAI del amparo asegurado';
   
   COMMENT ON COLUMN INDEMNIZA.CONCEPTO_INGRESO.COD_CONCEPTO IS 'Codigo SAI del concepto asegurado';
   
   COMMENT ON COLUMN INDEMNIZA.CONCEPTO_INGRESO.NUEVO_VALOR IS 'Valor que es digitado o seleccionado por el usuario en pantalla';
   
   COMMENT ON COLUMN INDEMNIZA.CONCEPTO_INGRESO.VALOR_ESTUDIO IS 'Valor que viene como estudio desde SAI';
   
   COMMENT ON COLUMN INDEMNIZA.CONCEPTO_INGRESO.ING_FEC_REGISTRO_ING IS 'campo de llave foroanea con la tabla de Ingresos, donde indica la fecha en que se realiza el ingreso';
   
   COMMENT ON COLUMN INDEMNIZA.CONCEPTO_INGRESO.ING_SOL_SAI_SOLICITUD IS 'campo de llave foroanea con la tabla de Ingresos, donde idica el numero de solicitud al que se le realizo el ingreso';
   
    COMMENT ON TABLE INDEMNIZA.CONCEPTO_INGRESO  IS 'Tabla donde se almacenan los conceptos asegurados que se envian a SAI.';
   
   
--------------------------------------------------------
--  Constraints for Table MES_REGISTRADO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO MODIFY (COD_CON_ING NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO MODIFY (COD_AMPARO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO MODIFY (COD_CONCEPTO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO MODIFY (NUEVO_VALOR NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO MODIFY (VALOR_ESTUDIO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO MODIFY (ING_FEC_REGISTRO_ING NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO MODIFY (ING_SOL_SAI_SOLICITUD NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.CONCEPTO_INGRESO ADD CONSTRAINT CONCEPTO_INGRESO_PK PRIMARY KEY ( COD_CON_ING ) ENABLE;


