-- **********************************************************************
-- * Nombre: Instalacion delta 4                                     *
-- * Descripción:                                                       *
-- * Autor: Andres David Niño                                          *
-- * Fecha de Creación: 27/01/2017                                      *
-- * Versión: 1.0                                                       *
-- * Empresa: Asesoftware S.A.S.                                        *
-- **********************************************************************

SPOOL install_Delta4_STG_SIBO.log
PROMPT 'Instalacion delta 4 ..'
@ ../Entrega/delta4/delta_4_1_STG_SIBO.sql
@ ../Entrega/delta4/delta_4_2_STG_SIBO.sql
@ ../Entrega/delta4/delta_4_3_MotivosRechazos_STG_SIBO.sql
@ ../Entrega/delta4/delta_4_6_Tipo_documento_STG_SIBO
PROMPT 'Instalación finalizada.'
SPOOL OFF
