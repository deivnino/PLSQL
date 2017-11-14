--------------------------------------------------------
--  DDL for Table VAL_DOMINIO
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.VAL_DOMINIO 
   (	COD_VAL_DOMINIO NUMBER(15,0), 
	VALOR VARCHAR2(400), 
	ESTADO VARCHAR2(20), 
	DOMINIO_COD_DOMINIO NUMBER(15,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.VAL_DOMINIO.COD_VAL_DOMINIO IS 'Codigo Autoincremental de la tabla.';
   
   COMMENT ON COLUMN INDEMNIZA.VAL_DOMINIO.VALOR IS 'Posible valor que puede tomar el dominio.';
   
   COMMENT ON COLUMN INDEMNIZA.VAL_DOMINIO.ESTADO IS 'Dominio que indica el estado del dominio,si este esta activo o esta inactivo.';
   
   COMMENT ON COLUMN INDEMNIZA.VAL_DOMINIO.DOMINIO_COD_DOMINIO IS 'Codigo autoincremental de la tabla';
   
   COMMENT ON TABLE INDEMNIZA.VAL_DOMINIO  IS 'Tabla donde se almacenaran los posibles valores que puede tomar un dominio.';
   

--------------------------------------------------------
--  Constraints for Table VAL_DOMINIO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.VAL_DOMINIO MODIFY (COD_VAL_DOMINIO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.VAL_DOMINIO MODIFY (VALOR NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.VAL_DOMINIO MODIFY (ESTADO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.VAL_DOMINIO MODIFY (DOMINIO_COD_DOMINIO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.VAL_DOMINIO ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE INDEMNIZA.VAL_DOMINIO ADD CONSTRAINT VAL_DOMINIO_PK PRIMARY KEY (COD_VAL_DOMINIO) ENABLE;
