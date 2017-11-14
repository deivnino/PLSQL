BEGIN
EXECUTE IMMEDIATE 'drop table SECUENCIA_GIRO_USADA' ;
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/

CREATE TABLE SECUENCIA_GIRO_USADA (  
             SECUENCIA_USADA VARCHAR2(15)) ;
              
ALTER TABLE SECUENCIA_GIRO_USADA ADD CONSTRAINT SECUENCIA_GIRO_USADA_PK PRIMARY
    KEY (SECUENCIA_USADA);

BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_GIRO_DIA_VI';
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/
CREATE SEQUENCE SEQ_GIRO_DIA_VI START WITH 1 INCREMENT BY 1 ;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_GIRO_DIA_MF';
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/
CREATE SEQUENCE SEQ_GIRO_DIA_MF START WITH 1 INCREMENT BY 1 ;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_GIRO_DIA_OT';
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/
CREATE SEQUENCE SEQ_GIRO_DIA_OT START WITH 1 INCREMENT BY 1 ;

-- Actualizo el procedure que se encarga de reiniciar las secuencias diarias

create or replace PROCEDURE PRC_REINICIO_DIARIO_SECUENCIAS
/*****************************************************************************
 APLICACION:           SIBO DAVIPLATA
 NOMBRE:               PRC_REINICIO_DIARIO_SECUENCIAS
 PROPOSITO:            Este procedimiento se encarga de reiniciar las secuencias
                       diarias para los procesos de cargue y proceso 

 PARAMETROS           
 ENTRADA:              Ninguno 
 SALIDA:               Ninguno

 DISEÑADO POR:         ASESOFTWARE
 DESARROLLADO POR:     WILSON ALBORNOZ

 REVISIONES:
 Version      Fecha         Autor                               Descripcion
 ---------    ----------    --------------------------------    --------------
 1.0          2017-01-05    Wilson Albornoz Benitez             Creacion Procedimiento.
 ******************************************************************************/                                                  
IS
BEGIN
  execute immediate   'DROP SEQUENCE SEQ_DISPE_DIA_DAVIPLATA';
  execute immediate   'CREATE SEQUENCE SEQ_DISPE_DIA_DAVIPLATA MINVALUE 100 MAXVALUE 999 INCREMENT BY 1 START WITH 100';
  execute immediate   'DROP SEQUENCE SEQ_NUMERO_CARGUE_DIARIO';
  execute immediate   'CREATE SEQUENCE SEQ_NUMERO_CARGUE_DIARIO MINVALUE 1 MAXVALUE 999 INCREMENT BY 1 START WITH 1';
  
  execute immediate   'DROP SEQUENCE SEQ_GIRO_DIA_VI';
  execute immediate   'CREATE SEQUENCE SEQ_GIRO_DIA_VI MINVALUE 1 MAXVALUE 99 INCREMENT BY 1 START WITH 1';
  
  execute immediate   'DROP SEQUENCE SEQ_GIRO_DIA_MF';
  execute immediate   'CREATE SEQUENCE SEQ_GIRO_DIA_MF MINVALUE 1 MAXVALUE 99 INCREMENT BY 1 START WITH 1';
  
  execute immediate   'DROP SEQUENCE SEQ_GIRO_DIA_OT';
  execute immediate   'CREATE SEQUENCE SEQ_GIRO_DIA_OT MINVALUE 1 MAXVALUE 99 INCREMENT BY 1 START WITH 1';
END;
/
BEGIN
EXECUTE IMMEDIATE 'drop table ARCHIVO_GIRO' ;
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/
CREATE TABLE ARCHIVO_GIRO (
            ID_ARCH_GIRO NUMBER(38) NOT NULL,
            IDCARGUE NUMBER(38,0) NOT NULL,
            CONSECUTIVO_PROCESO_PAGO VARCHAR2(25) NOT NULL,
            TR VARCHAR2(2),
            TIPO_ID VARCHAR2(2),
            NUMERO_ID VARCHAR2(16),
            NOMBRE_TERCERO VARCHAR2(40),
            TIPO_ID_AUTORIZADO VARCHAR2(2),
            CODIGO_BENEFICIARIO VARCHAR2(16),
            NOMBRE_AUTORIZADO VARCHAR2(40),
            OFICINA_AUTORIZADA VARCHAR2(4),
            VALOR_PAGO VARCHAR2(18),
            IDENTIFICADOR_TRANSACCION VARCHAR2(6),
            NUMERO_AUTORIZACION VARCHAR2(6),
            FORMA_PAGO_BENEF VARCHAR2(1),
            RES_PROC_ASUM_VALORES VARCHAR2(4),
            MENSAJE_RESPUESTA VARCHAR2(40),
            FECHA_COBRO_PAGO VARCHAR2(8) ) ;
            
ALTER TABLE ARCHIVO_GIRO ADD CONSTRAINT ARCHIVO_GIRO_PK  PRIMARY
    KEY (ID_ARCH_GIRO);
    
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ARCHIVO_GIRO';
EXCEPTION WHEN OTHERS THEN
NULL;
END;
/
CREATE SEQUENCE SEQ_ARCHIVO_GIRO START WITH 1 INCREMENT BY 1 ;

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_RC','RC','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_COD_SERVICIO','PPVH','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_COD_SUB_SERVICIO','PPVH','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_COD_BANCO','000051','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_COD_OPERADOR','0000','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_COD_NO_PROCESADO','9999','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_FECHA_GENERACION','00000000','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_HORA_GENERACION','000000','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_INDICADOR_INSCRIPCION','00','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_OFI_RECAUDO','00000000','Encabezado archivo pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_TR','TR','Detalle archivo de pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_TIPO_ID_AUTORIZADO','00','Detalle archivo de pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_NOMBRE_AUTORIZADO','0000000000000000000000000000000000000000','Detalle archivo de pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_OFI_AUTORIZADA','00','Detalle archivo de pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_NUM_AUTORIZACION','000000','Detalle archivo de pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_FORMA_PAGO_BENEFICIARIO','E','Detalle archivo de pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_RES_ASU_VALORES','9999','Detalle archivo de pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_MSJ_RESPUESTA','0000000000000000000000000000000000000000','Detalle archivo de pagos');

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'CONST_GIRO_FEC_COBRO_PAGO','00000000','Detalle archivo de pagos');

