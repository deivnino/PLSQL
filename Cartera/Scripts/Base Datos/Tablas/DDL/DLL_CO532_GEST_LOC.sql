/**
* Name: DLL_CO532_GEST_LOC.sql
* Tabla donde se almacena las ciudades o sucursales a las cuales pertenece un gestor
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_gest_loc (
    consecutivo            NUMBER(5) NOT NULL,
    gestor_cod_gest        NUMBER(5) NOT NULL,
    localizacion_cod_loc   varchar(5)
);

COMMENT ON TABLE admsisa.co532_gest_loc IS
    'GESTOR LOCALIZACION - Tabla donde se almacena las ciudades o sucursales a las cuales pertenece un gestor';
/
ALTER TABLE admsisa.co532_gest_loc ADD CONSTRAINT gestor_localizacion_pk PRIMARY KEY (consecutivo);