Prompt drop SCHEDULER JOB CO532_JOB_INACTIVAR_GESTOR;
BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR');
END;
/

Prompt Scheduler Job CO532_JOB_INACTIVAR_GESTOR;
--
-- CO532_JOB_INACTIVAR_GESTOR  (Scheduler Job) 
--
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
      ,start_date      => TO_TIMESTAMP_TZ('2017/11/03 09:44:10.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzh:tzm')
      ,repeat_interval => 'FREQ=DAILY;BYDAY=MON,TUE,WED,THU,FRI,SAT;BYHOUR=23;BYMINUTE=0;BYSECOND=0'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'ADMSISA.CO532_PKG_TAREAS_PROGRAMADAS.CO532_LLAMADO'
      ,comments        => 'JOB QUE SE ENCARGA DE INACTIVAR LOS GESTORES.'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
     ,attribute => 'MAX_RUNS');
  BEGIN
    SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
      ( name      => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
       ,attribute => 'STOP_ON_WINDOW_CLOSE'
       ,value     => FALSE);
  EXCEPTION
    -- could fail if program is of type EXECUTABLE...
    WHEN OTHERS THEN
      NULL;
  END;
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'ADMSISA.CO532_JOB_INACTIVAR_GESTOR');
END;
/
