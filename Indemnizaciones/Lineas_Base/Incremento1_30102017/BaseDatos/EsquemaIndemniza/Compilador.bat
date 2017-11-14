@echo off
cd "%USERPROFILE%\Documents\Seguros Bolivar\CO_531_Indemnizaciones_Web\Lineas_Base\Incremento1_30102017\BaseDatos\EsquemaIndemniza\Base Datos"
REM call sqlplus compilador/123456@XE_QA  @CrearSecuencias.sql > LogCrearSecuencias.txt
REM call sqlplus compilador/123456@XE_QA  @CrearTablas.sql > LogCrearTablas.txt
REM call sqlplus compilador/123456@XE_QA  @CrearConstraints.sql > LogCrearConstraints.txt
REM call sqlplus compilador/123456@XE_QA  @CrearTriggers.sql > LogCrearTriggers.txt
REM call sqlplus compilador/123456@XE_QA  @CrearProcedimientos.sql > LogCrearProcedimientos.txt
call sqlplus compilador/123456@XE_QA  @CrearSinonimos.sql > LogCrearSinonimos.txt
call sqlplus compilador/123456@XE_QA  @CrearGrants.sql > LogCrearGrants.txt

