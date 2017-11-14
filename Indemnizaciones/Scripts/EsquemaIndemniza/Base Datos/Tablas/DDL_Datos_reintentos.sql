--Alter Table INDEMNIZA.Datos_Reintentos
-- Drop Primary Key Cascade;
--
--Drop Table INDEMNIZA.Datos_Reintentos Cascade Constraints;

Create Table INDEMNIZA.Datos_Reintentos
(
  FEC_REP        DATE,
  Solicitud      NUMBER(10),
  OBJ_SINIESTRO  ADMSISA.TY_RPRTE_SNSTRO

)
Nested Table  OBJ_SINIESTRO.T_Conceptos Store As T_Conceptos
Nested Table OBJ_SINIESTRO.T_Servicios Store As T_Servicios
Nested Table OBJ_SINIESTRO.T_Doctos Store As T_Doctos

Result_Cache (Mode Default)
Storage    (
            Buffer_Pool      Default
            Flash_Cache      Default
            Cell_Flash_Cache Default
           )
Logging 
Nocompress 
Nocache
Noparallel
Nomonitoring
/

Comment On COLUMN INDEMNIZA.Datos_Reintentos.FEC_REP Is 'Fecha en que se genera el reporte de siniestro'
/

Comment On COLUMN INDEMNIZA.Datos_Reintentos.Solicitud Is 'Numero de solicitud que se siniestra '
/

Comment On COLUMN INDEMNIZA.Datos_Reintentos.OBJ_SINIESTRO Is 'Objeto definido con la estructura necesaria para procesar un siniestro'
/



Alter Table INDEMNIZA.Datos_Reintentos Add (
  Constraint Datos_reintentos_PK
  Primary Key
  (FEC_REP, Solicitud)
  Enable Validate)
/