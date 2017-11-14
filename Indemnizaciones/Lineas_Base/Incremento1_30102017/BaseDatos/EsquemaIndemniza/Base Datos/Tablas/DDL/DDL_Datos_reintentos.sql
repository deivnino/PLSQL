--Alter Table INDEMNIZA.Datos_Reintentos
-- Drop Primary Key Cascade;
--
--Drop Table INDEMNIZA.Datos_Reintentos Cascade Constraints;

CREATE TABLE INDEMNIZA.Datos_Reintentos(
  FEC_REP        DATE,
  Solicitud      NUMBER(10),
  OBJ_SINIESTRO  TY_RPRTE_SNSTRO,
  CONSTRAINT Datos_reintentos_PK PRIMARY KEY (FEC_REP, Solicitud)
)
NESTED TABLE OBJ_SINIESTRO.T_Conceptos Store As T_Conceptos
NESTED TABLE OBJ_SINIESTRO.T_Servicios Store As T_Servicios
NESTED TABLE OBJ_SINIESTRO.T_Doctos Store As T_Doctos
/
COMMENT ON COLUMN INDEMNIZA.Datos_Reintentos.FEC_REP 
  IS 'Fecha en que se genera el reporte de siniestro';
COMMENT ON COLUMN INDEMNIZA.Datos_Reintentos.Solicitud 
  IS 'Numero de solicitud que se siniestra';
COMMENT ON COLUMN INDEMNIZA.Datos_Reintentos.OBJ_SINIESTRO 
  IS 'Objeto definido con la estructura necesaria para procesar un siniestro';
/

