/**
* Name: DLL_CO532_VARIABLE.sql
* Tabla donde se almacena las variables existentes y sus respectivos valores
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_variable (
    tip_var       NUMBER NOT NULL,
    cod_var       VARCHAR2(50) NOT NULL,
    val_var       VARCHAR2(50) NOT NULL,
    estado        NUMBER NOT NULL,
    nom_cul_sai   VARCHAR2(100) NOT NULL,
    gestion       VARCHAR2(1) NOT NULL
);

ALTER TABLE admsisa.co532_variable ADD CHECK (
    tip_var IN (1,2,3,4,5,6,7,8,9,10,11,12)
);

ALTER TABLE admsisa.co532_variable ADD CHECK (
    estado IN (0,1)
);

COMMENT ON TABLE admsisa.co532_variable IS
    'Tabla donde se almacena las variables existentes y sus respectivos valores';

COMMENT ON COLUMN admsisa.co532_variable.cod_var IS
    'Codigo de la variable';

COMMENT ON COLUMN admsisa.co532_variable.gestion IS
    'Gestionada o no gestionada';
/
ALTER TABLE admsisa.co532_variable ADD CONSTRAINT variable_pk PRIMARY KEY ( tip_var,cod_var );