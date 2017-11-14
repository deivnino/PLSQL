/**
* Name: DLL_CO532_BITA_SIST.sql
* Tabla donde se almacena los movimientos de bitacora del sistemas
* Author: Oracle DataModeler
*/
CREATE TABLE admsisa.co532_bita_sist (
    cod_bita      NUMBER(5) NOT NULL,
    tip_mov       VARCHAR2(15) NOT NULL,
    observacion   VARCHAR2(255) NOT NULL,
    fecha         DATE NOT NULL,
    usuario       VARCHAR2(50) NOT NULL,
    rol           VARCHAR2(250) NOT NULL,
    pagina        VARCHAR2(250) NOT NULL
);

ALTER TABLE admsisa.co532_bita_sist ADD CHECK (
    tip_mov IN (
        'D','I','U'
    )
);

COMMENT ON TABLE admsisa.co532_bita_sist IS
    'Tabla donde se almacena los movimientos de bitacora del sistemas';

COMMENT ON COLUMN admsisa.co532_bita_sist.observacion IS
    'Observacion de la bitacora';

COMMENT ON COLUMN admsisa.co532_bita_sist.usuario IS
    'Usuario que realizó el movimiento';

COMMENT ON COLUMN admsisa.co532_bita_sist.rol IS
    'rol del usuario';

COMMENT ON COLUMN admsisa.co532_bita_sist.pagina IS
    'pagina o xhtml donde se ejecuto el proceso';

ALTER TABLE admsisa.co532_bita_sist ADD CONSTRAINT bitacora_sistema_pk PRIMARY KEY (cod_bita);