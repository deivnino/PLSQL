/**
* Name: DLL_CO532_LOCALIZACION.sql
* Tabla donde se almacena las localizaciones posibles a implementar en el sistem ciudad/surcursal
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_localizacion (
    cod_loc            VARCHAR(5)NOT NULL,
    nom_loc            VARCHAR2(50) NOT NULL,
    tip_loc            NUMBER(2) NOT NULL,
    variable_tip_var   NUMBER,
    variable_cod_var   VARCHAR2(50)
);
COMMENT ON TABLE admsisa.co532_localizacion IS
    'Tabla donde se almacena las localizaciones posibles a implementar en el sistem ciudad/surcursal';

COMMENT ON COLUMN admsisa.co532_localizacion.cod_loc IS
    'Copnsecutivo.';

COMMENT ON COLUMN admsisa.co532_localizacion.variable_tip_var IS
    'Tipo de referencia';

COMMENT ON COLUMN admsisa.co532_localizacion.variable_cod_var IS
    'Codigo de la variable Sucursal';

ALTER TABLE admsisa.co532_localizacion ADD CHECK (
    variable_tip_var IN (1,2,3,4,5,6,7,8,9,10,11,12)
);
/
ALTER TABLE admsisa.co532_localizacion ADD CONSTRAINT localizacion_pk PRIMARY KEY (cod_loc);
