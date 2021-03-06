--CREATE TRIGGER SECUENCIA RANGO DE AGRUPACION

CREATE OR REPLACE TRIGGER TRG_RANG_AGRU_COD_RAN_AGR
  BEFORE INSERT ON RANG_AGRU 
  FOR EACH ROW
BEGIN
  :new.COD_RAN_AGR  := SEC_RANG_AGRU.NEXTVAL;
END;

--CREATE TRIGGER SECUENCIA BITACORA DEL SISTEMA

CREATE OR REPLACE TRIGGER TRG_BITA_SIST
  BEFORE INSERT ON BITA_SIST 
  FOR EACH ROW
BEGIN
  :new.COD_BITA  := SEC_BITA_SIST.NEXTVAL;
END;
