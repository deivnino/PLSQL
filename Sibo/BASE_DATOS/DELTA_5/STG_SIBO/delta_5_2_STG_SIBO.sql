create or replace PACKAGE PKG_LIQUIDACION
 /*****************************************************************************
  APLICACION:           SIBO DAVIPLATA
  NOMBRE:               PKG_LIQUIDACION
  PROPOSITO:            Este paquete se encarga de agrupar todas las funciones
                        relacionadas con el proceso de validacion de tipo de 
                        pago
  DISEÑADO POR:         ASESOFTWARE
  DESARROLLADO POR:     WILSON ALBORNOZ
  REVISIONES:
  Version      Fecha         Autor                               Descripcion
  ---------    ----------    --------------------------------    --------------
  1.0          2017-01-31    Wilson Albornoz Benitez             Creacion Procedimiento.
  ******************************************************************************/
AS
 
  /******
  * Proceso a invocar desde Java: Recibe el id del proceso de cargue 
  */
  PROCEDURE PRC_VALIDAR_TIPO_PAGO(P_IDCARGUE IN NUMBER,
                                  P_USUARIO VARCHAR);
                                  --P_SALIDA OUT NUMBER) ;
  
  PROCEDURE FUNC_INSERTA_LIQUIDACION(P_IDPRELIQ IN NUMBER,
                                     P_IDCARGUE IN NUMBER,
                                     P_TIPO_PAGO IN NUMBER,
                                     P_IDDAVIPLATA IN NUMBER,
                                     P_VALORTOTAL IN NUMBER) ;
 
  PROCEDURE FUNC_OBTIENE_TIPO_PAGO(P_TIPOID IN VARCHAR,
                                   P_DOCUMENTO IN NUMBER,
                                   P_TIPO_PAGO OUT NUMBER,
                                   P_IDDAVIPLATA OUT NUMBER) ;                                  
                                  
  PROCEDURE FUNC_EXISTE_LISTAR_110(P_TIPOID IN VARCHAR,
                                   P_DOCUMENTO IN NUMBER,
                                   P_EXISTE    OUT NUMBER) ;
                                   
  PROCEDURE FUNC_EXISTE_LISTAR_DIF110(P_TIPOID IN VARCHAR,
                                      P_DOCUMENTO IN NUMBER,
                                      P_EXISTE    OUT NUMBER) ;
                                      
  PROCEDURE FUNC_EXISTE_SALDOS(P_TIPOID IN VARCHAR,
                               P_DOCUMENTO IN NUMBER,
                               P_EXISTE    OUT NUMBER,
                               P_IDDAVIPLATA OUT NUMBER) ;

  PROCEDURE PRC_EJECUTA_JOB(P_IDCARGUE IN NUMBER,
                                  P_USUARIO VARCHAR,
                                  P_SALIDA OUT NUMBER);
                                  
END PKG_LIQUIDACION ;
/
create or replace PACKAGE body PKG_LIQUIDACION
AS

  PROCEDURE PRC_VALIDAR_TIPO_PAGO(P_IDCARGUE IN NUMBER,
                                  P_USUARIO VARCHAR)
                                  --P_SALIDA OUT NUMBER)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    CURSOR CUR_REG_MFEA
    IS
      SELECT PMFEA.TIPOID AS TIPOID,
        PMFEA.DOCUMENTO   AS DOCUMENTO,
        PMFEA.IDPRELIQ    AS IDPRELIQ,
        PMFEA.VALORTOTAL  AS VALORTOTAL
      FROM PRELIQ_MFEA PMFEA
      WHERE PMFEA.IDCARGUE = P_IDCARGUE ;
    CURSOR CUR_REG_OTROS
    IS
      SELECT OTR.TIPOID AS TIPOID,
             OTR.DOCUMENTO   AS DOCUMENTO,
             OTR.IDPRELIQ    AS IDPRELIQ,
             OTR.VALORTOTAL  AS VALORTOTAL
      FROM PRELIQ_OTROS OTR
      WHERE OTR.IDCARGUE = P_IDCARGUE ;
    
    CURSOR CUR_REG_UARIV
    IS
      SELECT PU.TIPOID AS TIPOID,
        PU.DOCUMENTO   AS DOCUMENTO,
        PU.IDPRELIQ    AS IDPRELIQ,
        PU.VALORTOTAL  AS VALORTOTAL
      FROM PRELIQ_UARIV PU
      WHERE PU.IDCARGUE = P_IDCARGUE ;
    
    V_TIPO_PAGO NUMBER := 0;
    V_IDDAVIPLATA NUMBER := 0;
    V_TIPARCHIVO NUMBER := 0 ;
    V_FECHA_ACTUAL DATE := NULL ;
  BEGIN
    SELECT B.IDTIPOARCHIVO
    INTO V_TIPARCHIVO
    FROM RESUMEN_CARGUE B
    WHERE B.IDCARGUE = P_IDCARGUE;
    IF V_TIPARCHIVO  = 4 THEN
      FOR OT IN CUR_REG_OTROS
      LOOP
        -- Obtiene el tipo de pago, y el id daviplata
        FUNC_OBTIENE_TIPO_PAGO(OT.TIPOID, OT.DOCUMENTO,V_TIPO_PAGO,V_IDDAVIPLATA);
        -- Crea el registro de de la liquidacion el rel_preliq_tipo_pago
        FUNC_INSERTA_LIQUIDACION(OT.IDPRELIQ, P_IDCARGUE, V_TIPO_PAGO, V_IDDAVIPLATA,OT.VALORTOTAL) ;
      END LOOP;
    ELSIF V_TIPARCHIVO = 3 THEN
      FOR MF IN CUR_REG_MFEA
      LOOP
        -- Obtiene el tipo de pago, y el id daviplata
        FUNC_OBTIENE_TIPO_PAGO(MF.TIPOID, MF.DOCUMENTO,V_TIPO_PAGO,V_IDDAVIPLATA);
        -- Crea el registro de de la liquidacion el rel_preliq_tipo_pago
        FUNC_INSERTA_LIQUIDACION(MF.IDPRELIQ, P_IDCARGUE, V_TIPO_PAGO, V_IDDAVIPLATA,MF.VALORTOTAL) ;
      END LOOP;
    ELSIF V_TIPARCHIVO = 2 THEN
      FOR UA IN CUR_REG_UARIV
      LOOP
        -- Obtiene el tipo de pago, y el id daviplata
        FUNC_OBTIENE_TIPO_PAGO(UA.TIPOID, UA.DOCUMENTO,V_TIPO_PAGO,V_IDDAVIPLATA);
        -- Crea el registro de de la liquidacion el rel_preliq_tipo_pago
        FUNC_INSERTA_LIQUIDACION(UA.IDPRELIQ, P_IDCARGUE, V_TIPO_PAGO, V_IDDAVIPLATA,UA.VALORTOTAL) ;
      END LOOP;
    END IF;
    
    --Si el proceso termina ok, cambia el estado y crea el registro historico
    UPDATE RESUMEN_CARGUE RES
       SET RES.ID_ESTADO = 1
     WHERE RES.IDCARGUE = P_IDCARGUE ; 
    -- Crea el historico de estado
    SELECT SYSDATE INTO V_FECHA_ACTUAL FROM DUAL ;
    
    INSERT INTO HIST_ESTADO_PROCESO
        (
          ID_HISTORIA,
          IDCARGE,
          ID_ESTADO,
          USERNAME,
          FECHA
        )
        VALUES
        (
          SEQ_HIST_ESTADO_PROCESO.NEXTVAL,
          P_IDCARGUE,
          1,
          P_USUARIO,
          V_FECHA_ACTUAL
        );
    
    COMMIT;
    
/*    
    DECLARE
      V_URL_WSDL             VARCHAR2(1000);
      V_MENSAJE_SOAP_REQUEST VARCHAR2(1000);
      V_SOAPACTION           VARCHAR2(200);
      V_T_ERRORES            VARCHAR2(200);
    BEGIN
      --90.29.1.210
      V_URL_WSDL             := 'http://90.29.1.210:7001/SiboAppWeb/WsActualizaValidacionTipoPagoService';
      V_MENSAJE_SOAP_REQUEST := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.sibo.davivienda.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <ws:actualizarValidacion>
         <!--Optional:-->
         <arg0>199</arg0>
      </ws:actualizarValidacion>
   </soapenv:Body>
</soapenv:Envelope>';
      V_SOAPACTION           := 'actualizarValidacion';
      
      V_T_ERRORES            := NULL;
      

  PKG_UTILITARIOS.REPORTA_ERROR (  P_TIPO => 'ws', DESCRIPCION => 'inicia el llamado al ws') ;  

      PKG_UTILITARIOS.PRC_INVOVAR_WEB_SERVICE ( V_URL_WSDL => V_URL_WSDL, V_MENSAJE_SOAP_REQUEST => V_MENSAJE_SOAP_REQUEST, V_SOAPACTION => V_SOAPACTION, V_T_ERRORES => V_T_ERRORES) ;

  PKG_UTILITARIOS.REPORTA_ERROR (  P_TIPO => 'ws', DESCRIPCION => 'termina el llamado al ws') ;      
  
    END;
*/

    
  EXCEPTION
  WHEN OTHERS THEN
   null;
   -- ROLLBACK;
  END PRC_VALIDAR_TIPO_PAGO ;
  
  PROCEDURE FUNC_INSERTA_LIQUIDACION(P_IDPRELIQ IN NUMBER,
                                     P_IDCARGUE IN NUMBER,
                                     P_TIPO_PAGO IN NUMBER,
                                     P_IDDAVIPLATA IN NUMBER,
                                     P_VALORTOTAL IN NUMBER)
  IS
  BEGIN
    INSERT INTO REL_PRELIQ_TIPOPAGO
          (
            IDRELPRELIQ,
            IDCARGUE,
            IDPRELIQ,
            IDTIPOPAGO,
            ID_DAVIPLATA,
            VALOR_TOTAL
          )
            VALUES
          (
              SEQ_REL_PRELIQ_TIPOPAGO.NEXTVAL,
              P_IDCARGUE,
              P_IDPRELIQ,
              P_TIPO_PAGO,
              P_IDDAVIPLATA,
              P_VALORTOTAL
          );
     EXCEPTION WHEN OTHERS THEN
       Raise_Application_Error (-20343, 'Error insertando la liquidacion');
  END FUNC_INSERTA_LIQUIDACION;
  
  PROCEDURE FUNC_OBTIENE_TIPO_PAGO(P_TIPOID      IN VARCHAR,
                                   P_DOCUMENTO   IN NUMBER,
                                   P_TIPO_PAGO   OUT NUMBER,
                                   P_IDDAVIPLATA OUT NUMBER)
  IS
    DVP     CONSTANT INT := 1 ;
    GIRO    CONSTANT INT := 2;
    NOPAGAR CONSTANT INT := 3 ;
    
    V_EXISTE_LISTA_R110 NUMBER := 0;
    V_EXISTE_LISTA_DIF110 NUMBER := 0 ;
    V_EXISTE_SALDOS NUMBER := 0 ;
    V_IDDAVIPLATA NUMBER := NULL;
  BEGIN
       FUNC_EXISTE_LISTAR_110(P_TIPOID, P_DOCUMENTO, V_EXISTE_LISTA_R110);
       IF (V_EXISTE_LISTA_R110 = 1) THEN 
          P_TIPO_PAGO := NOPAGAR; 
       ELSE 
          FUNC_EXISTE_LISTAR_DIF110(P_TIPOID,P_DOCUMENTO,V_EXISTE_LISTA_DIF110);
          FUNC_EXISTE_SALDOS(P_TIPOID,P_DOCUMENTO,V_EXISTE_SALDOS,V_IDDAVIPLATA);
          IF (V_EXISTE_LISTA_DIF110 = 1 AND V_EXISTE_SALDOS =1 ) THEN 
            P_TIPO_PAGO := GIRO; 
          ELSIF (V_EXISTE_SALDOS = 1)  THEN 
            P_TIPO_PAGO := DVP;
            P_IDDAVIPLATA := V_IDDAVIPLATA ;
          ELSE 
            P_TIPO_PAGO := GIRO; 
          END IF ;
       END IF ;
  END FUNC_OBTIENE_TIPO_PAGO;
  
  PROCEDURE FUNC_EXISTE_LISTAR_110(P_TIPOID    IN VARCHAR,
                                   P_DOCUMENTO IN NUMBER,
                                   P_EXISTE OUT NUMBER)
  IS
  BEGIN
    SELECT 1
    INTO P_EXISTE
    FROM LISTAS_R RES
    WHERE LPAD(RES.TIPOIDENTIFICACION,2,'0') = LPAD(P_TIPOID,2,'0')
    AND RES.IDENTIFICACION                   = P_DOCUMENTO
    AND RES.IDENTIFICADORNODESEADO           = '100'
    AND RES.IDCARGUE                         =
      (SELECT MAX(RES2.IDCARGUE) FROM LISTAS_R RES2
      ) ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    P_EXISTE := 0;
  END FUNC_EXISTE_LISTAR_110 ;
  
  PROCEDURE FUNC_EXISTE_LISTAR_DIF110(P_TIPOID    IN VARCHAR,
                                      P_DOCUMENTO IN NUMBER,
                                      P_EXISTE OUT NUMBER)
  IS
  BEGIN
    SELECT 1
    INTO P_EXISTE
    FROM LISTAS_R RES
    WHERE LPAD(RES.TIPOIDENTIFICACION,2,'0') = LPAD(P_TIPOID,2,'0')
    AND RES.IDENTIFICACION                   = P_DOCUMENTO
    AND RES.IDENTIFICADORNODESEADO          <> '100'
    AND RES.IDCARGUE                         =
      (SELECT MAX(RES2.IDCARGUE) FROM LISTAS_R RES2
      ) ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    P_EXISTE := 0;
  END FUNC_EXISTE_LISTAR_DIF110 ;
  
  PROCEDURE FUNC_EXISTE_SALDOS(P_TIPOID    IN VARCHAR,
                               P_DOCUMENTO IN NUMBER,
                               P_EXISTE OUT NUMBER,
                               P_IDDAVIPLATA OUT NUMBER)
  IS
  BEGIN
    SELECT 1,
      SAL.IDDAVIPLATA
    INTO P_EXISTE,
      P_IDDAVIPLATA
    FROM SALDOS SAL
    WHERE LPAD(SAL.TIPOID,2,'0') = LPAD(P_TIPOID,2,'0')
    AND SAL.DOCUMENTO            = P_DOCUMENTO
    AND SAL.IDCARGUE             =
      (SELECT MAX(SAL2.IDCARGUE) FROM SALDOS SAL2
      ) ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    P_EXISTE      := 0;
    P_IDDAVIPLATA := NULL;
  END FUNC_EXISTE_SALDOS ;
  
  PROCEDURE PRC_EJECUTA_JOB(P_IDCARGUE IN NUMBER,
                                  P_USUARIO VARCHAR,
                                  P_SALIDA OUT NUMBER)
  IS
    VJOBNUM BINARY_INTEGER;
  BEGIN

    SYS.DBMS_JOB.SUBMIT(VJOBNUM,
    'DECLARE
        P_IDCARGUE NUMBER := '       ||P_IDCARGUE||';' ||
        'P_USUARIO VARCHAR2(200) := '''|| P_USUARIO||''';' ||
      'BEGIN
        PKG_LIQUIDACION.PRC_VALIDAR_TIPO_PAGO(
          P_IDCARGUE => P_IDCARGUE,
          P_USUARIO => P_USUARIO
    );
    END;'
    );
    P_SALIDA := 1;
  END PRC_EJECUTA_JOB;
  
END PKG_LIQUIDACION;
/
