-- **********************************************************************
-- * Nombre: aumentarTamanoConcepto                                     *
-- * Descripci�n:                                                       *
-- * Autores: Alfonso Pimienta                                          *
-- * Fecha de Creaci�n: 03/01/2017                                      *
-- * Versi�n: 1.0                                                       *
-- * Empresa: Asesoftware S.A.S.                                        *
-- **********************************************************************

SPOOL install_sibodvp.log
PROMPT 'Creaci�n Tablas ..'
@ ../Script/Tablas/SCRIPT_SIBO_TABLAS.sql
PROMPT 'Creaci�n secuencias...'
@ ../Script/Secuencias/SCRIPT_SIBO_SEQ.sql
PROMPT 'Creaci�n trigger.'
@ ../Script/Trigger/SCRIPT_SIBO_PARAMETROS_SIBO_TRG.sql
@ ../Script/Trigger/SCRIPT_SIBO_TIPO_ARCHIVO_TRG.sql
PROMPT 'Creaci�n datos.'
@ ../Script/Datos/SCRIPT_SIBO_DATOS.sql
PROMPT 'Creaci�n Procedimientos ..'
@ ../Script/procedimientos/PRC_CARGAR_DATOS_SIBO_DINAMIC.sql
@ ../Script/procedimientos/PRC_CARGAR_ERRORES_SIBO.sql
@ ../Script/procedimientos/PRC_CREACION_USUARIO_SIBO.sql
@ ../Script/procedimientos/OTROS_PRC.sql
PROMPT 'Creaci�n Paquetes ..'
@ ../Script/paquetes/PKG_CARGUE_ARCHIVOS.sql
@ ../Script/paquetes/PKG_EJECUTA_CARGUES.sql
@ ../Script/paquetes/PKG_UTILITARIOS.sql
@ ../Script/paquetes/PKG_PROCESOS_PAGOS.sql
PROMPT 'Creaci�n Indices ..'
@ ../Script/Indices/Indices.sql
PROMPT 'Instalaci�n finalizada.'
SPOOL OFF
