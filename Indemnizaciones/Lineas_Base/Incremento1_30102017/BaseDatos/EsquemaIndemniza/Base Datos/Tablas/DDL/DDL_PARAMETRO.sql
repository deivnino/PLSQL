--------------------------------------------------------
--  DDL for Table PARAMETRO
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.PARAMETRO 
   (	COD_PARA NUMBER(15,0), 
	DESCRIPCION VARCHAR2(200), 
	VALOR NVARCHAR2(200), 
	ESTADO VARCHAR2(20)
   ) ;

   
   COMMENT ON COLUMN INDEMNIZA.PARAMETRO.COD_PARA IS 'codigo parametro';
   
   COMMENT ON TABLE INDEMNIZA.PARAMETRO  IS 'Tabla encargada de guardar los parametros que se van a usar en el sistema.';
   

--------------------------------------------------------
--  Constraints for Table PARAMETRO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.PARAMETRO MODIFY (COD_PARA NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.PARAMETRO MODIFY (DESCRIPCION NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.PARAMETRO MODIFY (VALOR NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.PARAMETRO MODIFY (ESTADO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.PARAMETRO ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE INDEMNIZA.PARAMETRO ADD CONSTRAINT PARAMETRO_PK PRIMARY KEY (COD_PARA) ENABLE;
