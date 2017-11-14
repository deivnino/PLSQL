-- Creacion de usuario propietario del esquema PARA QUARTZ
CREATE USER STG_SIBO_QUARTZ IDENTIFIED BY D3F45LT2016 DEFAULT TABLESPACE SIBO_DATOS;
ALTER  USER STG_SIBO_QUARTZ QUOTA 1024M ON SIBO_DATOS; 
ALTER  USER STG_SIBO_QUARTZ QUOTA 1024M ON SIBO_INDICES; 

GRANT CREATE SESSION TO STG_SIBO_QUARTZ;
GRANT CREATE TABLE TO STG_SIBO_QUARTZ;
GRANT CREATE TRIGGER TO  STG_SIBO_QUARTZ;
GRANT CREATE JOB TO STG_SIBO_QUARTZ;
GRANT CREATE SEQUENCE TO STG_SIBO_QUARTZ;
GRANT CREATE VIEW TO STG_SIBO_QUARTZ;
GRANT CREATE MATERIALIZED VIEW TO STG_SIBO_QUARTZ;
GRANT CREATE SYNONYM TO STG_SIBO_QUARTZ;
GRANT CREATE PROCEDURE TO  STG_SIBO_QUARTZ;