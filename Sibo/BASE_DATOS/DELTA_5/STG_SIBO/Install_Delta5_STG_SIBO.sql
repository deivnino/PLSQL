-- **********************************************************************
-- * Nombre: Instalacion delta 5                                   *
-- * Descripci�n:                                                       *
-- * Autor: Andres Felipe Herrera                                         *
-- * Fecha de Creaci�n: 31/01/2017                                      *
-- * Versi�n: 1.0                                                       *                     *
-- **********************************************************************

SPOOL Install_Delta5_STG_SIBO.log
PROMPT 'Instalacion delta 5 ..'
@ delta_5_1_STG_SIBO.sql
@ delta_5_2_STG_SIBO.sql
@ delta_5_3_STG_SIBO.sql
@ delta_5_4_STG_SIBO.sql
@ delta_5_5_STG_SIBO.sql
-- Dejar siempre el de permisos como ultimo archivo a llamar
@ delta_PermisosUsuarioConexion.sql
PROMPT 'Instalaci�n finalizada.'
SPOOL OFF