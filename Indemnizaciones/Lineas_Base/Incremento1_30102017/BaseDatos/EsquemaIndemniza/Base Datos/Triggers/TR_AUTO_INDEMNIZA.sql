--------------------------------------------------------
--  DDL for Trigger TR_AUTO_INDEMNIZA
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "INDEMNIZA.TR_AUTO_INDEMNIZA" 
   before insert on AUTORIZACION_INDEMNIZACION
   for each row 
begin  
   if inserting then 
      if :NEW."COD_AUT_IND" is null then 
         select SEC_AUTO_INDEN.nextval into :NEW."COD_AUT_IND" from dual; 
      end if; 
   end if; 
end;
/
ALTER TRIGGER "TR_AUTO_INDEMNIZA" ENABLE;
