@echo off

cd "%USERPROFILE%\Documents\Seguros Bolivar\CO_531_Indemnizaciones_Web\Lineas_Base\Incremento1_30102017\BaseDatos\EsquemaSai\Base Datos"
call sqlplus compilador/123456@XE_QA @CrearTablas.sql > LogCrearTablas.txt
call sqlplus compilador/123456@XE_QA @CrearTiposDatos.sql > LogCrearTiposDatos.txt
call sqlplus compilador/123456@XE_QA @CrearPackages.sql > LogCrearPackages.txt
call sqlplus compilador/123456@XE_QA @CrearSinonimos.sql > LogCrearSinonimos.txt
call sqlplus compilador/123456@XE_QA @CrearGrants.sql > LogCrearGrants.txt

