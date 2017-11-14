-- **********************************************************************
-- * Nombre: aumentarTamanoConcepto                                     *
-- * Descripción:                                                       *
-- * Autores: Alfonso Pimienta                                          *
-- * Fecha de Creación: 03/01/2017                                      *
-- * Versión: 1.0                                                       *
-- * Empresa: Asesoftware S.A.S.                                        *
-- **********************************************************************

SPOOL install_sibodvp.log
PROMPT 'Incia desinstalción ..'
@ ../Script/Tablas/Desinstalar/Script_Desinstalar_tablas.sql
PROMPT 'Creación secuencias...'
--@ ../Script/Secuencias/SCRIPT_SIBO_SEQ.sql
--PROMPT 'Creación trigger.'
--@ ../Script/Trigger/SCRIPT_SIBO_PARAMETROS_SIBO_TRG.sql
--@ ../Script/Trigger/SCRIPT_SIBO_TIPO_ARCHIVO_TRG.sql
--PROMPT 'Creación datos.'
--@ ../Script/Datos/SCRIPT_SIBO_DATOS.sql
--PROMPT 'Creación Procedimientos ..'
--@ ../Script/procedimientos/PRC_CARGAR_DATOS_SIBO_DINAMIC.sql
--@ ../Script/procedimientos/PRC_CARGAR_ERRORES_SIBO.sql
--PROMPT 'Creación Paquetes ..'
--@ ../Script/paquetes/PKG_CARGUE_ARCHIVOS.sql
--@ ../Script/paquetes/PKG_EJECUTA_CARGUES.sql
--@ ../Script/paquetes/PKG_UTILITARIOS.sql
--PROMPT 'Asignación de Permisos.'
--@ ../Script/Permisos/SCRIPT_PERMISO.sql

PROMPT 'Desinstalación finalizada.'
SPOOL OFF
