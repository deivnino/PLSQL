--------------------------------------------------------
--  DDL for Trigger TR_AUTO_DESOCUPA
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "INDEMNIZA.TR_AUTO_DESOCUPA" 
   before insert on "AUTORIZACION_DESOCUPACIOON" 
   for each row 
begin  
   if inserting then 
      if :NEW."CODIGO_AUT_DES" is null then 
         select SEC_AUTO_DESOCU.nextval into :NEW."CODIGO_AUT_DES" from dual; 
      end if; 
   end if; 
end;
/
ALTER TRIGGER "TR_AUTO_DESOCUPA" ENABLE;
