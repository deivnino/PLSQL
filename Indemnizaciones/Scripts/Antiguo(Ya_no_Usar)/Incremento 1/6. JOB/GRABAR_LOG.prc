Create Or Replace Procedure  Grabar_Log(pi_mensaje In varchar2)
Is 
Pragma AUTONOMOUS_TRANSACTION;
Begin
Insert Into Log_Error
Values (1,'Job_Reintentos',Sysdate, pi_mensaje);


End  Grabar_Log;
