--------------------------------------------------------
--  DDL for Table PERFIL
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.PERFIL 
   (	COD_PERF NUMBER(15,0), 
	NOMBRE VARCHAR2(200)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.PERFIL.COD_PERF IS 'codigo perfil - Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN INDEMNIZA.PERFIL.NOMBRE IS 'Campor donde se guarda el nombre del perfil.';
   
   COMMENT ON TABLE INDEMNIZA.PERFIL  IS 'Tabla donde se registran los perfiles que se van a manejar en la aplicacion.';
   

--------------------------------------------------------
--  Constraints for Table PERFIL
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.PERFIL MODIFY (COD_PERF NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.PERFIL MODIFY (NOMBRE NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.PERFIL ADD CONSTRAINT PERFIL_PK PRIMARY KEY (COD_PERF) ENABLE;

  