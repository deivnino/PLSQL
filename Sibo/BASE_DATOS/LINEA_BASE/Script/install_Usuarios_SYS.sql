-----SYS
CREATE TABLESPACE SIBO_DATOS DATAFILE '+DG_SIBO' SIZE 10G AUTOEXTEND ON NEXT 512M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

CREATE TABLESPACE SIBO_INDICES DATAFILE '+DG_SIBO' SIZE 5G AUTOEXTEND ON NEXT 512M MAXSIZE UNLIMITED
LOGGING
ONLINE
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
BLOCKSIZE 8K
SEGMENT SPACE MANAGEMENT AUTO
FLASHBACK ON;

CREATE USER STG_SIBO IDENTIFIED BY D3F45LT2016 DEFAULT TABLESPACE SIBO_DATOS;
ALTER  USER STG_SIBO QUOTA 1024M ON SIBO_DATOS; 
ALTER  USER STG_SIBO QUOTA 1024M ON SIBO_INDICES; 
CREATE USER C_STG_SIBO IDENTIFIED BY D3F45LT2016 DEFAULT TABLESPACE SIBO_DATOS;
ALTER  USER C_STG_SIBO QUOTA 1024M ON SIBO_DATOS;
ALTER  USER C_STG_SIBO QUOTA 1024M ON SIBO_INDICES;
CREATE USER STG_STAGE IDENTIFIED BY D3F45LT2016 DEFAULT TABLESPACE SIBO_DATOS;
ALTER  USER STG_STAGE QUOTA 1024M ON SIBO_DATOS;
ALTER  USER STG_STAGE QUOTA 1024M ON SIBO_INDICES;

GRANT CREATE SESSION TO STG_SIBO;
GRANT CREATE TABLE TO STG_SIBO;
GRANT CREATE TRIGGER TO  STG_SIBO;
GRANT EXECUTE ON dbms_crypto   TO  STG_SIBO;
GRANT CREATE JOB TO STG_SIBO;
GRANT CREATE SEQUENCE TO STG_SIBO;
GRANT CREATE VIEW TO STG_SIBO;
GRANT CREATE MATERIALIZED VIEW TO STG_SIBO;
GRANT CREATE SYNONYM TO STG_SIBO;
GRANT CREATE PROCEDURE TO  STG_SIBO;

GRANT CREATE SESSION TO C_STG_SIBO;
GRANT CREATE SESSION TO STG_STAGE;
GRANT CREATE TABLE TO C_STG_SIBO;
GRANT CREATE TABLE TO STG_STAGE;
