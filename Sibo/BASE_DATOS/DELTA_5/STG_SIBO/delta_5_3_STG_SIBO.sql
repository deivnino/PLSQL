BEGIN
EXECUTE IMMEDIATE 'drop table OFICINA_PAGO' ;
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/

CREATE TABLE OFICINA_PAGO (
       ID_RED VARCHAR2(4) NOT NULL,
       NOMBRE_RED VARCHAR2(50) ) ;

ALTER TABLE OFICINA_PAGO ADD CONSTRAINT OFICINA_PAGO_PK PRIMARY KEY (ID_RED);


insert into OFICINA_PAGO (ID_RED,NOMBRE_RED) values ('0060','AssendaRed') ;
insert into OFICINA_PAGO (ID_RED,NOMBRE_RED) values ('5661','MovilRed') ;
insert into OFICINA_PAGO (ID_RED,NOMBRE_RED) values ('5663','TVS') ;
insert into OFICINA_PAGO (ID_RED,NOMBRE_RED) values ('5665','Atlas') ;
insert into OFICINA_PAGO (ID_RED,NOMBRE_RED) values ('9734','ConexRed') ;
insert into OFICINA_PAGO (ID_RED,NOMBRE_RED) values ('9999','Todas las Oficinas') ;

---

BEGIN
EXECUTE IMMEDIATE 'drop table CONVENIO' ;
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/

CREATE TABLE CONVENIO (
       ID_CONVENIO         NUMBER(8) NOT NULL,
       NOMBRE_CONVENIO     VARCHAR2(100) NOT NULL,
       NIT_EMPRESA         VARCHAR2(100),
       CUENTA_EMPRESA      VARCHAR2(100),
       TIPO_CUENTA         VARCHAR2(100),
       NUMERO_CLIENTE_DAV  VARCHAR2(100),
       TIPO_IDENTIFICACION VARCHAR2(100));
       
ALTER TABLE CONVENIO ADD CONSTRAINT CONVENIO_PK PRIMARY KEY (ID_CONVENIO);

INSERT INTO CONVENIO (
    ID_CONVENIO,
    NOMBRE_CONVENIO,
    NIT_EMPRESA,
    CUENTA_EMPRESA,
    TIPO_CUENTA,
    NUMERO_CLIENTE_DAV,
    TIPO_IDENTIFICACION) 
    VALUES 
    (1,
    'Corporación Educación Superior - Regalías',
    '8600343137',
    '033569997910',
    'CC',
    '51222',
    '01'
    ); 

INSERT INTO CONVENIO (
    ID_CONVENIO,
    NOMBRE_CONVENIO,
    NIT_EMPRESA,
    CUENTA_EMPRESA,
    TIPO_CUENTA,
    NUMERO_CLIENTE_DAV,
    TIPO_IDENTIFICACION) 
    VALUES 
    (2,
    'Corporación Educación Superior - Fundación EPM',
    '8600343137',
    '033569997910',
    'CC',
    '51230',
    '01'
    );

INSERT INTO CONVENIO (
    ID_CONVENIO,
    NOMBRE_CONVENIO,
    NIT_EMPRESA,
    CUENTA_EMPRESA,
    TIPO_CUENTA,
    NUMERO_CLIENTE_DAV,
    TIPO_IDENTIFICACION) 
    VALUES 
    (3,
    'Corporación Educación Superior - Recursos Gobernación de Antioquia',
    '8600343137',
    '033569997910',
    'CC',
    '51230',
    '01'
    ); 

INSERT INTO CONVENIO (
    ID_CONVENIO,
    NOMBRE_CONVENIO,
    NIT_EMPRESA,
    CUENTA_EMPRESA,
    TIPO_CUENTA,
    NUMERO_CLIENTE_DAV,
    TIPO_IDENTIFICACION) 
    VALUES 
    (4,
    'Corporación Educación Superior -  Ocensa',
    '8600343137',
    '033569997910',
    'CC',
    '51233',
    '01'
    );