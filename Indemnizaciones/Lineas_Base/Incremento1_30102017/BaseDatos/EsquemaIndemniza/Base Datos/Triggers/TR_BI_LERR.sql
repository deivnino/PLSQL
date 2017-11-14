--------------------------------------------------------
--  DDL for Trigger TR_BI_LERR
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "INDEMNIZA.TR_BI_LERR" 
   before insert on "LOG_ERROR" 
   for each row 
begin  
   if inserting then 
      if :NEW."ID_LOG" is null then 
         select SEQ_LOGERROR.nextval into :NEW."ID_LOG" from dual; 
      end if; 
   end if; 
end;
/
ALTER TRIGGER "TR_BI_LERR" ENABLE;
