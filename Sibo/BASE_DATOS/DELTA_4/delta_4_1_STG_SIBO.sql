-- WAAB: altera la tabla proceso pago y crea la tabla secuencia disponible usada
alter table proceso_pago add (total_registros number(38) null, monto_total number(38) null ); 
/

alter table proceso_pago add (INDICADOR_MENSAJE varchar2(1) null ); 
/

CREATE TABLE SECUENCIA_DISP_USADA (  
              SECUENCIA_USADA VARCHAR2(7)) ;
/			  
              
ALTER TABLE SECUENCIA_DISP_USADA ADD CONSTRAINT SECUENCIA_DISP_USADA_PK PRIMARY
    KEY (SECUENCIA_USADA);
/

insert into ESTADO_PAGO (ID_EST_PAGO,DES_EST_PAGO) values (6, 'Retransmitido'); 
/

update parametros_sibo
   set VALOR_PARAMETRO = '/log_SIBO/generados/'
 where NOMBRE_PARAMETRO = 'FTP_GENERADO_DISPERSION' ;
/ 

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'FTP_TRANSMITIDOS_GOANYWHERE','/export/home/crmcarga/dispersionDaviplata/transmitidosGoAnywhere','Ruta remota transmitidos go anywhere');
/

insert into parametros_sibo (ID_PARAMETRO,
NOMBRE_PARAMETRO,
VALOR_PARAMETRO,
DESCRIPCION_PARAM) 
values (seq_parametros_sibo.nextval,'FTP_COPIA_TRANSMITIDOS','/export/home/crmcarga/dispersionDaviplata/copiaTransmitidos','Ruta remota copia archivos transmitidos');
/

update parametros_sibo
   set VALOR_PARAMETRO = '/archivos_dispersion/'
 where NOMBRE_PARAMETRO = 'LOCAL_GENERADO_DISPERSION' ;
/ 

insert into TIPO_ARCHIVO (IDTIPOARCHIVO, NOMBRETIPOARCHIVO, SEPARADOR, TABLAINSERCION, IDENTIFICADOR, SECUENCIA) VALUES (6,'CONDICIONALES',';','CONDICIONALES','6','SEQ_CONDICIONAL');
/
Insert into PARAMETROS_SIBO (ID_PARAMETRO,NOMBRE_PARAMETRO,VALOR_PARAMETRO,DESCRIPCION_PARAM) values (SEQ_PARAMETROS_SIBO.nextval,'FTP_USERNAME','crmcarga','NOMBRE DE USUARIO FTP');
/
Insert into PARAMETROS_SIBO (ID_PARAMETRO,NOMBRE_PARAMETRO,VALOR_PARAMETRO,DESCRIPCION_PARAM) values (SEQ_PARAMETROS_SIBO.nextval,'FTP_HOST','90.4.0.184','HOST FTP');
/
Insert into PARAMETROS_SIBO (ID_PARAMETRO,NOMBRE_PARAMETRO,VALOR_PARAMETRO,DESCRIPCION_PARAM) values (SEQ_PARAMETROS_SIBO.nextval,'FTP_PORT','22','PUERTO FTP');
/
Insert into PARAMETROS_SIBO (ID_PARAMETRO,NOMBRE_PARAMETRO,VALOR_PARAMETRO,DESCRIPCION_PARAM) values (SEQ_PARAMETROS_SIBO.nextval,'FTP_PASSWORD','temp123','CONTRASENA DE USUARIO FTP');
/
Insert into PARAMETROS_SIBO (ID_PARAMETRO,NOMBRE_PARAMETRO,VALOR_PARAMETRO,DESCRIPCION_PARAM) values (SEQ_PARAMETROS_SIBO.nextval,'FTP_PATH','/export/home/crmcarga/GeneracionCSV/Preliquidacion','RUTA FTP PARA GENERACION DE ARCHIVOS');  
/
Insert into PARAMETROS_SIBO (ID_PARAMETRO,NOMBRE_PARAMETRO,VALOR_PARAMETRO,DESCRIPCION_PARAM) values (SEQ_PARAMETROS_SIBO.nextval,'PRELIQUIDACION_RUTAFICHERO','/GeneracionCSV/Preliquidacion/','RUTA DE GENERACION DE ARCHIVOS PARA LAS PRELIQUIDACIONES');
/
Insert into PARAMETROS_SIBO (ID_PARAMETRO,NOMBRE_PARAMETRO,VALOR_PARAMETRO,DESCRIPCION_PARAM) values (SEQ_PARAMETROS_SIBO.nextval,'PERIODO_MINUTOS_REVISION_PENDIENTES','5','PERIODO_MINUTOS_REVISION_PENDIENTES');
/

-- Ajuste package dispersion por cambio de codificacion de tipo archivo
create or replace PACKAGE PKG_PROCESOS_PAGOS
AS
  /*****************************************************************************
  APLICACION:           SIBO DAVIPLATA
  NOMBRE:               PKG_PROCESOS_PAGOS
  PROPOSITO:            Este paquete se encarga de agrupar todas las funciones y/o
  procedimientos utilizados para el proceso de pago Daviplata.
  DISEÑADO POR:         ASESOFTWARE
  DESARROLLADO POR:     WILSON ALBORNOZ
  REVISIONES:
  Versión      Fecha         Autor                               Descripción
  ---------    ----------    --------------------------------    --------------
  1.0          2017-01-06    Wilson Albornoz Benitez             Creación Procedimiento.
  ******************************************************************************/


  PROCEDURE PRC_GEN_DISPERSION_DVP(P_IDCARGUE           IN NUMBER,
                                   P_FECHA_ENVIO        IN VARCHAR2,
                                   P_NIT_EMPRESA        IN VARCHAR2,
                                   P_CONSECUTIVO_ENVIO  IN NUMBER,
                                   P_INDICADOR_MENSAJE  IN VARCHAR2,
                                   P_SALIDA             OUT NUMBER);

  PROCEDURE PRC_ACT_DISPERSION_DVP(P_IDCARGUE           IN NUMBER,
                                   P_FECHA_ENVIO        IN VARCHAR2,
                                   P_CONSECUTIVO_ENVIO  IN NUMBER,
                                   P_INDICADOR_MENSAJE  IN VARCHAR2,
                                   P_SALIDA             OUT NUMBER);

END PKG_PROCESOS_PAGOS;
/
create or replace PACKAGE BODY PKG_PROCESOS_PAGOS
AS
  /*****************************************************************************
  APLICACION:           SIBO DAVIPLATA
  NOMBRE:               PKG_PROCESOS_PAGOS
  PROPOSITO:            Este paquete se encarga de agrupar todas las funciones y/o
  procedimientos utilizados para el proceso de pago Daviplata.
  DISEÃ‘ADO POR:         ASESOFTWARE
  DESARROLLADO POR:     WILSON ALBORNOZ
  REVISIONES:
  Version      Fecha         Autor                               Descripcion
  ---------    ----------    --------------------------------    --------------
  1.0          2017-01-06    Wilson Albornoz Benitez             Creacion Procedimiento.
  ******************************************************************************/
  PROCEDURE PRC_GEN_DISPERSION_DVP(P_IDCARGUE           IN NUMBER,
                                   P_FECHA_ENVIO        IN VARCHAR2,
                                   P_NIT_EMPRESA        IN VARCHAR2,
                                   P_CONSECUTIVO_ENVIO  IN NUMBER,
                                   P_INDICADOR_MENSAJE  IN VARCHAR2,
                                   P_SALIDA             OUT NUMBER)
  /*****************************************************************************
  Procedimiento encargado de poblar la tabla de del archivo de dispersion de
  Daviplata.
  ******************************************************************************/
  IS
   CURSOR  CUR_REG_MFEA  IS
   SELECT PMFEA.TIPOID AS TIPOID,
          PMFEA.DOCUMENTO AS DOCUMENTO,
          SAL.IDDAVIPLATA AS NUMERO_DAVIPLATA,
          PMFEA.VALORTOTAL AS VALOR_NOVEDAD
     FROM PRELIQ_MFEA PMFEA,
          REL_PRELIQ_TIPOPAGO RPT,
          SALDOS SAL
    WHERE RPT.IDCARGUE = PMFEA.IDCARGUE
      AND RPT.IDPRELIQ = PMFEA.IDPRELIQ
      AND SAL.TIPOID = PMFEA.TIPOID
      AND SAL.DOCUMENTO = PMFEA.DOCUMENTO
      AND SAL.IDCARGUE = (SELECT MAX(SAL2.IDCARGUE)
                           FROM SALDOS SAL2)
      AND RPT.IDTIPOPAGO = 1 -- Daviplata
      AND RPT.IDCARGUE = P_IDCARGUE ;

  CURSOR  CUR_REG_OTROS IS
   SELECT OTR.TIPOID AS TIPOID,
          OTR.DOCUMENTO AS DOCUMENTO,
          SAL.IDDAVIPLATA AS NUMERO_DAVIPLATA,
          OTR.VALORTOTAL AS VALOR_NOVEDAD
     FROM PRELIQ_OTROS OTR,
          REL_PRELIQ_TIPOPAGO RPT,
          SALDOS SAL
    WHERE RPT.IDCARGUE = OTR.IDCARGUE
      AND RPT.IDPRELIQ = OTR.IDPRELIQ
      AND SAL.TIPOID = OTR.TIPOID
      AND SAL.DOCUMENTO = OTR.DOCUMENTO
      AND SAL.IDCARGUE = (SELECT MAX(SAL2.IDCARGUE)
                           FROM SALDOS SAL2)
      AND RPT.IDTIPOPAGO = 1 -- Daviplata
      AND RPT.IDCARGUE = P_IDCARGUE ;

   CURSOR CUR_REG_UARIV IS
   SELECT PU.TIPOID AS TIPOID,
          PU.DOCUMENTO AS DOCUMENTO,
          SAL.IDDAVIPLATA AS NUMERO_DAVIPLATA,
          PU.VALORTOTAL AS VALOR_NOVEDAD
     FROM PRELIQ_UARIV PU,
          REL_PRELIQ_TIPOPAGO RPT,
          SALDOS SAL
    WHERE RPT.IDCARGUE = PU.IDCARGUE
      AND RPT.IDPRELIQ = PU.IDPRELIQ
      AND SAL.TIPOID = PU.TIPOID
      AND SAL.DOCUMENTO = PU.DOCUMENTO
      AND SAL.IDCARGUE = (SELECT MAX(SAL2.IDCARGUE)
                           FROM SALDOS SAL2)
      AND RPT.IDTIPOPAGO = 1 -- Daviplata
      AND RPT.IDCARGUE = P_IDCARGUE ;

      P_TIPARCHIVO     NUMBER:=0;

  BEGIN
     SELECT  B.IDTIPOARCHIVO
       INTO    P_TIPARCHIVO
       FROM    RESUMEN_CARGUE B
      WHERE   B.IDCARGUE = P_IDCARGUE;

      IF P_TIPARCHIVO = 4 THEN
        FOR OT IN CUR_REG_OTROS LOOP
         insert into DISPERSION_DAVIPLATA (
                ID_DIS_DAVIPLATA,
                IDCARGUE,
                NIT_EMPRESA,
                FECHA_ENVIO,
                CONSECUTIVO_ENVIO,
                TIPO_IDENTIFICACION,
                NUM_IDENTIFICACION_CLI,
                NUMERO_TARJETA,
                NUMERO_CUENTA,
                TIPO_NOVEDAD,
                VALOR_NOVEDAD,
                INDICADOR_MENSAJE,
                DISPONIBLE,
                CODIGO_ERROR)
        values (
                SEQ_DISPERSION_DAVIPLATA.NEXTVAL,
                P_IDCARGUE,
                LPAD(P_NIT_EMPRESA,15,'0'),
                P_FECHA_ENVIO,
                LPAD(P_CONSECUTIVO_ENVIO,5,'0'),
                LPAD(OT.TIPOID,2,'0'),
                LPAD(OT.DOCUMENTO,15,'0'),
                RPAD(OT.NUMERO_DAVIPLATA,19,'0'),
                RPAD(' ',19,' '),
                '0',
                RPAD(LPAD(OT.VALOR_NOVEDAD,15,'0'),17,'0'),
                P_INDICADOR_MENSAJE,
                LPAD(' ',27,' '),
                LPAD(' ',3,' ')
        );
        END LOOP;
      ELSIF P_TIPARCHIVO = 3 THEN
        FOR MF IN CUR_REG_MFEA LOOP
          insert into DISPERSION_DAVIPLATA (
                ID_DIS_DAVIPLATA,
                IDCARGUE,
                NIT_EMPRESA,
                FECHA_ENVIO,
                CONSECUTIVO_ENVIO,
                TIPO_IDENTIFICACION,
                NUM_IDENTIFICACION_CLI,
                NUMERO_TARJETA,
                NUMERO_CUENTA,
                TIPO_NOVEDAD,
                VALOR_NOVEDAD,
                INDICADOR_MENSAJE,
                DISPONIBLE,
                CODIGO_ERROR)
        values (
                SEQ_DISPERSION_DAVIPLATA.NEXTVAL,
                P_IDCARGUE,
                LPAD(P_NIT_EMPRESA,15,'0'),
                P_FECHA_ENVIO,
                LPAD(P_CONSECUTIVO_ENVIO,5,'0'),
                LPAD(MF.TIPOID,2,'0'),
                LPAD(MF.DOCUMENTO,15,'0'),
                RPAD(MF.NUMERO_DAVIPLATA,19,'0'),
                RPAD(' ',19,' '),
                '0',
                RPAD(LPAD(MF.VALOR_NOVEDAD,15,'0'),17,'0'),
                P_INDICADOR_MENSAJE,
                LPAD(' ',27,' '),
                LPAD(' ',3,' ')
          );
        END LOOP;
      ELSIF P_TIPARCHIVO = 2 THEN
        FOR UA IN CUR_REG_UARIV LOOP
          insert into DISPERSION_DAVIPLATA (
                ID_DIS_DAVIPLATA,
                IDCARGUE,
                NIT_EMPRESA,
                FECHA_ENVIO,
                CONSECUTIVO_ENVIO,
                TIPO_IDENTIFICACION,
                NUM_IDENTIFICACION_CLI,
                NUMERO_TARJETA,
                NUMERO_CUENTA,
                TIPO_NOVEDAD,
                VALOR_NOVEDAD,
                INDICADOR_MENSAJE,
                DISPONIBLE,
                CODIGO_ERROR)
        values (
                SEQ_DISPERSION_DAVIPLATA.NEXTVAL,
                P_IDCARGUE,
                LPAD(P_NIT_EMPRESA,15,'0'),
                P_FECHA_ENVIO,
                LPAD(P_CONSECUTIVO_ENVIO,5,'0'),
                LPAD(UA.TIPOID,2,'0'),
                LPAD(UA.DOCUMENTO,15,'0'),
                RPAD(UA.NUMERO_DAVIPLATA,19,'0'),
                RPAD(' ',19,' '),
                '0',
                RPAD(LPAD(UA.VALOR_NOVEDAD,15,'0'),17,'0'),
                P_INDICADOR_MENSAJE,
                LPAD(' ',27,' '),
                LPAD(' ',3,' ')
          );
        END LOOP;
      END IF;
      P_SALIDA := 1 ;
      EXCEPTION WHEN OTHERS THEN
           P_SALIDA := 0;

  END PRC_GEN_DISPERSION_DVP;

  PROCEDURE PRC_ACT_DISPERSION_DVP(P_IDCARGUE           IN NUMBER,
                                   P_FECHA_ENVIO        IN VARCHAR2,
                                   P_CONSECUTIVO_ENVIO  IN NUMBER,
                                   P_INDICADOR_MENSAJE  IN VARCHAR2,
                                   P_SALIDA             OUT NUMBER)
  IS
  BEGIN

  UPDATE DISPERSION_DAVIPLATA
   SET CONSECUTIVO_ENVIO = LPAD(P_CONSECUTIVO_ENVIO,5,'0'),
       FECHA_ENVIO = P_FECHA_ENVIO ,
       INDICADOR_MENSAJE = P_INDICADOR_MENSAJE
  WHERE IDCARGUE = P_IDCARGUE ;

  EXCEPTION WHEN OTHERS THEN
           P_SALIDA := 0;

  END PRC_ACT_DISPERSION_DVP ;

END PKG_PROCESOS_PAGOS;
/







