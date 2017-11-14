/**
* Name: DLL_CO532_ASIGNACION.sql
* Tabla donde se almacena las asignaciones de los siniestros a los gestores
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_asignacion (
    siniestro_cod_sin   NUMBER(5) NOT NULL,
    gestor_cod_gest     NUMBER(5) NOT NULL
);

COMMENT ON TABLE admsisa.co532_asignacion IS
    'ASIGNACION-Tabla donde se almacena las asignaciones de los siniestros a los gestores';

ALTER TABLE admsisa.co532_asignacion ADD CONSTRAINT asignacion_pk PRIMARY KEY ( siniestro_cod_sin,gestor_cod_gest);