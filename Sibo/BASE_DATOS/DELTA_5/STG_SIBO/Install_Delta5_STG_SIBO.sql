-- **********************************************************************
-- * Nombre: Instalacion delta 5                                   *
-- * Descripción:                                                       *
-- * Autor: Andres Felipe Herrera                                         *
-- * Fecha de Creación: 31/01/2017                                      *
-- * Versión: 1.0                                                       *                     *
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
PROMPT 'Instalación finalizada.'
SPOOL OFF