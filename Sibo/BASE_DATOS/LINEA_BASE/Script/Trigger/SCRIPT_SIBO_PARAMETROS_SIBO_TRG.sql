create or replace TRIGGER PARAMETROS_SIBO_TRG 
BEFORE INSERT ON PARAMETROS_SIBO 
FOR EACH ROW 
BEGIN
  <<COLUMN_SEQUENCES>>
  BEGIN
    IF INSERTING AND :NEW.ID_PARAMETRO IS NULL THEN
      SELECT SEQ_PARAMETROS_SIBO.NEXTVAL INTO :NEW.ID_PARAMETRO FROM SYS.DUAL;
    END IF;
  END COLUMN_SEQUENCES;
END PARAMETROS_SIBO_TRG;
/