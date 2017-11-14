-- Creacion procedure creacion de usuarios
create or replace PROCEDURE PRC_CREACION_USUARIO_SIBO(P_USERNAME VARCHAR2,
                                                      P_PASSWORD VARCHAR2,
                                                      P_PRIMER_NOMBRE VARCHAR2,
                                                      P_SEGUNDO_NOMBRE VARCHAR2,
                                                      P_PRIMER_APELLIDO VARCHAR2,
                                                      P_SEGUNDO_APELLIDO VARCHAR2)
/*****************************************************************************
 APLICACION:           SIBO DAVIPLATA
 NOMBRE:               PRC_CREACION_USUARIO_SIBO
 PROPOSITO:            Este procedimiento se encarga de recibir los datos de un 
                       usuario para crearlo en el sistema SIBO, aplicando un
                       hash sha-256 al password.

 PARAMETROS: 
 ENTRADA:              P_USERNAME - Obligatorio
                       P_PASSWORD - Obligatorio
                       P_PRIMER_NOMBRE - Obligatorio
                       P_SEGUNDO_NOMBRE - No obligatorio, se envia NULL
                       P_PRIMER_APELLIDO - Obligatorio
                       P_SEGUNDO_APELLIDO - No obligatorio, se envia NULL
 SALIDA:               Ninguno

 DISE脩ADO POR:         ASESOFTWARE
 DESARROLLADO POR:     WILSON ALBORNOZ

 REVISIONES:
 Versi贸n      Fecha         Autor                               Descripci贸n
 ---------    ----------    --------------------------------    --------------
 1.0          2017-01-04    Wilson Albornoz Benitez             Creaci贸n Procedimiento.
 ******************************************************************************/                                                  
IS
 V_PASSWORD_RAW RAW(128) := utl_raw.cast_to_raw(P_PASSWORD);
 V_PASSWORD_HASH RAW(2048);
BEGIN
  dbms_output.put_line('Inicia creacion de usuario');
  V_PASSWORD_HASH := dbms_crypto.hash(V_PASSWORD_RAW, dbms_crypto.HASH_SH256);
  dbms_output.put_line('Password hash ' || V_PASSWORD_HASH);
  
  insert into autenticacion 
  (USERNAME,
   PASSWORD,
   PRIMER_NOMBRE,
   SEGUNDO_NOMBRE,
   PRIMER_APELLIDO,
   SEGUNDO_APELLIDO)
  values
  (P_USERNAME,
  V_PASSWORD_HASH,
  P_PRIMER_NOMBRE,
  P_SEGUNDO_NOMBRE,
  P_PRIMER_APELLIDO,
  P_SEGUNDO_APELLIDO);  
  commit;
  dbms_output.put_line('USUARIO CREADO EXITOSAMENTE');
  EXCEPTION WHEN OTHERS THEN
     rollback ;
     dbms_output.put_line('ERROR CREANDO EL USUARIO - '||SQLCODE||' -ERROR- '||SQLERRM);
     raise_application_error(-20001,'ERROR CREANDO EL USUARIO - '||SQLCODE||' -ERROR- '||SQLERRM);
END;
/
create or replace PROCEDURE PRC_REINICIO_DIARIO_SECUENCIAS
/*****************************************************************************
 APLICACION:           SIBO DAVIPLATA
 NOMBRE:               PRC_REINICIO_DIARIO_SECUENCIAS
 PROPOSITO:            Este procedimiento se encarga de reiniciar las secuencias
                       diarias para los procesos de cargue y proceso 

 PARAMETROS           
 ENTRADA:              Ninguno 
 SALIDA:               Ninguno

 DISE脩ADO POR:         ASESOFTWARE
 DESARROLLADO POR:     WILSON ALBORNOZ

 REVISIONES:
 Versi贸n      Fecha         Autor                               Descripci贸n
 ---------    ----------    --------------------------------    --------------
 1.0          2017-01-05    Wilson Albornoz Benitez             Creaci贸n Procedimiento.
 ******************************************************************************/                                                  
IS
BEGIN
  execute immediate   'DROP SEQUENCE SEQ_DISPE_DIA_DAVIPLATA';
  execute immediate   'CREATE SEQUENCE SEQ_DISPE_DIA_DAVIPLATA MINVALUE 100 MAXVALUE 999 INCREMENT BY 1 START WITH 100';
  execute immediate   'DROP SEQUENCE SEQ_NUMERO_CARGUE_DIARIO';
  execute immediate   'CREATE SEQUENCE SEQ_NUMERO_CARGUE_DIARIO MINVALUE 1 MAXVALUE 999 INCREMENT BY 1 START WITH 1';
END;
/
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name             => 'SIBO_REINICIO_SEC',
   job_type             => 'PLSQL_BLOCK',
   job_action           => 'BEGIN PRC_REINICIO_DIARIO_SECUENCIAS(); END;',
   start_date           => TRUNC(SYSDATE) + 1/24,
   repeat_interval      => 'FREQ=DAILY',
   enabled              =>  TRUE,
   comments             => 'Reinicio diario de secuencias');
   EXCEPTION WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE('Error en la creaci髇 del job'|| sqlcode);
END;
/