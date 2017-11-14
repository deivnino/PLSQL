--------------------------------------------------------
--  DDL for Table DOMINIO
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.DOMINIO 
   (	COD_DOMINIO NUMBER(15,0), 
	NOMBRE VARCHAR2(200), 
	ESTADO VARCHAR2(20)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.DOMINIO.COD_DOMINIO IS 'Codigo autoincremental de la tabla';
   
   COMMENT ON COLUMN INDEMNIZA.DOMINIO.NOMBRE IS 'Campo que indica el nombre que va a tener el dominio.';
   
   COMMENT ON COLUMN INDEMNIZA.DOMINIO.ESTADO IS 'Dominio que indica el estado del dominio,si este esta activo o esta inactivo.';
   
   COMMENT ON TABLE INDEMNIZA.DOMINIO  IS 'Tabla donde se crearan los dominios que se haran uso en el sistema.';
   
--------------------------------------------------------
--  DDL for Index DOMINIO__IDX
--------------------------------------------------------

  CREATE INDEX INDEMNIZA.DOMINIO__IDX ON INDEMNIZA.DOMINIO (COD_DOMINIO, ESTADO) 
  ;
--------------------------------------------------------
--  Constraints for Table DOMINIO
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.DOMINIO ADD CONSTRAINT DOMINIO_PK PRIMARY KEY (COD_DOMINIO) ENABLE;
  ALTER TABLE INDEMNIZA.DOMINIO ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE INDEMNIZA.DOMINIO MODIFY (ESTADO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DOMINIO MODIFY (NOMBRE NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.DOMINIO MODIFY (COD_DOMINIO NOT NULL ENABLE);
