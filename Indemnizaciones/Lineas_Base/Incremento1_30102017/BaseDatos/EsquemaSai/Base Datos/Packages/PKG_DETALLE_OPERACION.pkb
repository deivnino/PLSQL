create or replace package admsisa.PKG_DETALLE_OPERACION is

 TYPE T_DATOS_CONTRATO IS RECORD(
    P_SOLICITUD       RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
    P_POLIZA          RSGOS_VGNTES.RVI_NMRO_PLZA%TYPE,
    P_CLASE           RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE,
    P_RAMO            RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
    P_FECHA_INICIO_C  DATE,
    P_TIPO_AUMENTO_C  DATOS_CONTRATOS.TIPO_AUMENTO_CANON%TYPE,
    P_PORCENTAJE_C    NUMBER,
    P_FECHA_INICIO_A  DATE,
    P_TIPO_AUMENTO_A  DATOS_CONTRATOS.TIPO_AUMENTO_CANON%TYPE,
    P_PORCENTAJE_A    NUMBER,
    P_IVA_COMERCIAL   DATOS_CONTRATOS.INCLUYE_IVA_COMERCIAL%TYPE
    );

 FUNCTION FUN_VALOR_INGRESO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                             P_AMPARO    RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                             P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE) RETURN NUMBER;

 FUNCTION FUN_OBTENER_AUMENTO (P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE,
                                P_FECHA_AUMENTO DATE) RETURN NUMBER;

 FUNCTION FUN_INCREMENTO_SUGERIDO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                   P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE,
                                   P_FECHA_AUMENTO DATE,
                                   P_DESTINO       SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                                   P_TIPO_AUMENTO  DATOS_CONTRATOS.TIPO_AUMENTO_CANON%TYPE) RETURN NUMBER;

 FUNCTION FUN_AUMENTO_ANUAL (P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                              P_AMPARO    RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                              P_FECHA_AUMENTO DATE) RETURN NUMBER;


  PROCEDURE PRC_BUSCAR_TASA_REINGRESO(P_AMPARO        IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                                  P_RAMO          IN AMPROS_PRDCTO.APR_RAM_CDGO%TYPE,
                                  P_CLASE         IN PLZAS.POL_CDGO_CLSE%TYPE,
                                  P_SUCURSAL      IN SCRSL.SUC_CDGO%TYPE,
                                  P_COMPANIA      IN SCRSL.SUC_CIA_CDGO%TYPE,
                                  P_POLIZA        IN PLZAS.POL_NMRO_PLZA%TYPE,
                                  P_SOLICITUD     IN NUMBER,
                                  TASA            IN OUT NUMBER,
                                  TIPO_TASA       IN OUT VARCHAR2,
                                  PORC_DESCUENTO  IN OUT NUMBER,
                                  VALOR_ASEGURADO IN OUT NUMBER,
                                  CUOTAS          OUT NUMBER,
                                  INCLUYE_IVA     IN OUT VARCHAR2,
                                  MENSAJE         IN OUT NUMBER);


  PROCEDURE PRC_VALIDAR_SEGURO(SOLICITUD NUMBER, CONCEPTO VARCHAR2);

  PROCEDURE PRC_REINGRESO_SEGURO(P_AMPARO              IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                        P_SOLICITUD         IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                        P_POLIZA            IN PLZAS.POL_NMRO_PLZA%TYPE,
                        P_CLASE             IN PLZAS.POL_CDGO_CLSE%TYPE,
                        P_RAMO              IN PLZAS.POL_RAM_CDGO%TYPE,
                        P_COMPANIA          IN PLZAS.POL_SUC_CIA_CDGO%TYPE,
                        P_SUCURSAL          IN PLZAS.POL_SUC_CDGO%TYPE,
                        P_DESTINO           IN SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                        P_CIUDAD            IN DIRECCIONES.DI_DIVPOL_CODIGO%TYPE,
                        P_NOVEDAD_REINGRESO IN VARCHAR2,
                        P_MODULO            IN MODULOS.MDL_CDGO%TYPE,
                        P_USUARIO           IN USRIOS.USR_CDGO_USRIO%TYPE,
                        P_PERIODO           IN VARCHAR2);

  FUNCTION VALIDAR_NOVEDAD_CUOTA(SOLICITUD NUMBER,FECHA_NOVEDAD DATE,
                                 AMPARO    VARCHAR2,CERTIFICADO NUMBER,
                                 POLIZA    NUMBER, CLASE VARCHAR2,
                                 RAMO      VARCHAR2,NOVEDAD VARCHAR2) RETURN VARCHAR2;


  Procedure BORRAR_DEV_PRIMAS(SOLICITUD     NUMBER,
                            POLIZA          NUMBER,
                            SUCURSAL        VARCHAR2,
                            COMPANIA        VARCHAR2,
                            FECHA_NOVEDAD   DATE,
                            CLASE_POLIZA    VARCHAR2,
                            RAMO            VARCHAR2,
                            DEVOLUCION      NUMBER,
                            MENSAJE         IN OUT VARCHAR2,
                            USUARIO         VARCHAR2,
                            NOVEDAD         VARCHAR2,
                            AMPARO          VARCHAR2,
                            PERIODO         VARCHAR2);


  PROCEDURE BORRAR_HISTORICOS (NOVEDAD VARCHAR2,
                            SOLICITUD NUMBER,
                            POLIZA NUMBER,
                            CLASE_POLIZA VARCHAR2,
                            RAMO VARCHAR2,
                            CONCEPTO VARCHAR2,
                            AMPARO VARCHAR2,
                            CERTIFICADO NUMBER,
                            NOVEDAD_REVERSO  VARCHAR2);

  PROCEDURE BORRAR_HISTORICOS_POR_RETIRO (NOVEDAD VARCHAR2,
                            SOLICITUD NUMBER,
                            POLIZA NUMBER,
                            CLASE_POLIZA VARCHAR2,
                            RAMO VARCHAR2,
                            CONCEPTO VARCHAR2,
                            AMPARO VARCHAR2,
                            CERTIFICADO NUMBER,
                            NOVEDAD_REVERSO  VARCHAR2);

  PROCEDURE BORRAR_SUSPENSION_PAGOS_RETIRO(
                     RAMO IN VARCHAR2 ,
                     SOLICITUD IN NUMBER,
                     AMPARO   IN VARCHAR2,
                     MENSAJE IN OUT VARCHAR2 ,
                     MODULO  VARCHAR2 ,
                     USUARIO  VARCHAR2 );

  PROCEDURE BORRAR_NOVEDAD (FECHA_NOVEDAD DATE,
                            NOVEDAD VARCHAR2,
                           SOLICITUD NUMBER,
                            POLIZA NUMBER,
                            CLASE_POLIZA VARCHAR2,
                            RAMO VARCHAR2,
                            AMPARO VARCHAR2);

  PROCEDURE BORRAR_REGISTROS (NOVEDAD VARCHAR2,
                            P_SOLICITUD NUMBER,
                            POLIZA NUMBER,
                            CLASE_POLIZA VARCHAR2,
                            RAMO VARCHAR2,
                            CONCEPTO VARCHAR2,
                            AMPARO VARCHAR2);

  PROCEDURE FUN_LEVANTA_SUSPENSION(P_SOLICITUD  NUMBER);

  PROCEDURE VALIDA_SINIESTRO(SOLICITUD NUMBER,MENSAJE OUT VARCHAR2);

  PROCEDURE INGRESA_CUOTAS_AMPARO(P_SOLICITUD SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                                P_POLIZA PLZAS.POL_NMRO_PLZA%TYPE,
                                P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                                P_CLSE_PLZA PLZAS.POL_CDGO_CLSE%TYPE,
                                P_RAM_CDGO PLZAS.POL_RAM_CDGO%TYPE,
                                P_PERIODO VARCHAR2);

  PROCEDURE REVERSO_VALORES_PRIMAS (NOVEDAD VARCHAR2, POLIZA NUMBER, CLASE_POLIZA VARCHAR2,RAMO VARCHAR2,
                          AMPARO VARCHAR2,CERTIFICADO NUMBER, SOLICITUD NUMBER, PRIMA_NETA_ANT IN OUT NUMBER,
                          PRIMA_NETA IN OUT NUMBER, PRIMA_TOTAL_ANT IN OUT NUMBER,  PRIMA_TOTAL IN OUT NUMBER,
                          PRIMA_ANUAL_ANT IN OUT NUMBER, PRIMA_ANUAL IN OUT NUMBER, VALOR_ASEGURADO_ANT NUMBER,
                          VALOR_ASEGURADO NUMBER,  IVA NUMBER, IVA_PRIMA_ANT IN OUT NUMBER, IVA_PRIMA IN OUT NUMBER,
                          RETRO_NETA NUMBER,  RETRO_ANUAL NUMBER, RETRO_TOTAL NUMBER, IVA_RETRO NUMBER,
                          RETRO_NETA_ANT NUMBER, RETRO_ANUAL_ANT NUMBER, RETRO_TOTAL_ANT NUMBER, IVA_RETRO_ANT NUMBER,
                          PERIODO VARCHAR2, CUOTAS NUMBER, ENTRO IN OUT NUMBER, USUARIO VARCHAR2,
                          MENSAJE IN OUT VARCHAR2, CESION IN VARCHAR2, NOVEDAD_REVERSO VARCHAR2);

  PROCEDURE ACTUALIZA_AMPAROS_BORRADO (NOVEDAD VARCHAR2, SOLICITUD NUMBER,POLIZA NUMBER, CLASE_POLIZA VARCHAR2,
                             RAMO VARCHAR2, CONCEPTO VARCHAR2, CERTIFICADO NUMBER, AMPARO VARCHAR2,
                             VALOR_ANT NUMBER, VALOR NUMBER, USUARIO VARCHAR2, MENSAJE IN OUT VARCHAR2);


  PROCEDURE AMPAROS_BORRADO (NOVEDAD VARCHAR2, SOLICITUD NUMBER,  POLIZA NUMBER,  CLASE_POLIZA VARCHAR2,
                   RAMO VARCHAR2,    AMPARO VARCHAR2,   CERTIFICADO NUMBER,  VALOR_ASEGURADO_ANT NUMBER,
                   VALOR_ASEGURADO NUMBER,   PRIMA_NETA_ANT NUMBER,  PRIMA_NETA NUMBER,
                   PRIMA_NETA_ANUAL NUMBER,  PRIMA_ANUAL_ANT NUMBER, PRIMA_ANUAL NUMBER,
                   TIPO_TASA VARCHAR2,   TASA NUMBER, TPO_DEDUCIBLE VARCHAR2, PORC_DEDUCIBLE NUMBER,
                   MNMO_DEDUCIBLE NUMBER,  TPO_IDEN VARCHAR2,  NMRO_IDEN NUMBER, PORC_DESCUENTO NUMBER,
                   IVA NUMBER,  ENTRO IN OUT NUMBER, USUARIO VARCHAR2, FECHA_NOVEDAD DATE,
                   MENSAJE IN OUT VARCHAR2);

  PROCEDURE REVERSO_ACTUALIZA_VALOR (NOVEDAD VARCHAR2,  SOLICITUD NUMBER,
                           POLIZA NUMBER,CLASE_POLIZA VARCHAR2, RAMO VARCHAR2,
                           CERTIFICADO NUMBER, CONCEPTO VARCHAR2, AMPARO VARCHAR2,
                           VALOR_ANT NUMBER, VALOR NUMBER, USUARIO VARCHAR2,
                           MENSAJE IN OUT VARCHAR2);

  PROCEDURE REVERSO_RETROACTIVIDAD(FECHA_LIQUIDACION IN OUT DATE, PERIODO IN VARCHAR2,
    PRIMA_NETA IN NUMBER, PRIMA_ANUAL IN NUMBER, PRIMA_TOTAL IN NUMBER, IVA_PRIMA IN NUMBER,
    PRIMA_NETA_ANT IN NUMBER, PRIMA_ANUAL_ANT IN NUMBER, PRIMA_TOTAL_ANT IN NUMBER,
    IVA_PRIMA_ANT IN NUMBER,DESCUENTO IN NUMBER, DESCUENTO_ANT IN NUMBER,PRIMA_RETRO_NETA IN OUT NUMBER, PRIMA_RETRO_ANUAL IN OUT NUMBER,
    PRIMA_RETRO_TOTAL IN OUT NUMBER, IVA_RETRO IN OUT NUMBER,
    PRIMA_RETRO_NETA_ANT IN OUT NUMBER, PRIMA_RETRO_ANUAL_ANT IN OUT NUMBER,
    PRIMA_RETRO_TOTAL_ANT IN OUT NUMBER,IVA_RETRO_ANT IN OUT NUMBER, MODULO IN VARCHAR2, CESION IN VARCHAR2,
    MENSAJE IN OUT VARCHAR2,NOVEDAD IN VARCHAR2);


  PROCEDURE REVERSO_NOVEDADES(SOLICITUD IN NUMBER ,  POLIZA IN NUMBER ,  CLASE_POLIZA IN VARCHAR2 ,
                              RAMO IN VARCHAR2 ,  SUCURSAL IN VARCHAR2,  COMPANIA  IN VARCHAR2,
                              FECHA_NOVEDAD IN OUT DATE ,  AMPARO IN VARCHAR2 ,  CONCEPTO IN VARCHAR2 ,
                              VALOR_ANT IN NUMBER ,  CERTIFICADO IN NUMBER ,
                              VALOR IN NUMBER ,    NOVEDAD IN VARCHAR2 ,  ENTRO IN OUT NUMBER ,  MODULO IN VARCHAR2,
                              MENSAJE IN  OUT VARCHAR2 ,  USUARIO IN VARCHAR2,  CESION  IN VARCHAR2,  COBRAR  in VARCHAR2,
                              NOVEDAD_REVERSO VARCHAR2);


  PROCEDURE METODO_AUMENTOS_SIN (P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE);

  PROCEDURE METODO_AUMENTOS_CONTRATO (P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                      P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE);


  PROCEDURE CREAR_DATOS_CONTRATO (P_SOLICITUD     RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                  P_POLIZA        RSGOS_VGNTES.RVI_NMRO_PLZA%TYPE,
                                  P_CLASE         RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE,
                                  P_RAMO          RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
                                  P_CONCEPTO      RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE,
                                  P_DESTINO       SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                                  P_FECHA_INICIO  DATE,
                                  P_TIPO_AUMENTO  VARCHAR2,
                                  P_PORCENTAJE    NUMBER,
                                  P_IVA_COMERCIAL VARCHAR2);

  PROCEDURE SIN_DATOS_CONTRATO (P_SOLICITUD     RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                  P_POLIZA        RSGOS_VGNTES.RVI_NMRO_PLZA%TYPE,
                                  P_CLASE         RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE,
                                  P_RAMO          RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
                                  P_FECHA_INICIO  DATE,
                                  P_TIPO_AUMENTO  VARCHAR2,
                                  P_PORCENTAJE    NUMBER,
                                  P_IVA_COMERCIAL VARCHAR2);

  PROCEDURE INSERTAR_TABLA_AUMENTOS;

  PROCEDURE INSERTAR_TABLA_VIVIENDA;

  PROCEDURE INSERTAR_TABLA_VIVIENDA(P_SOLICITUD NUMBER);

  PROCEDURE INSERTAR_TABLA_COMERCIAL;

  PROCEDURE ACTUALIZAR_TABLA_CONTRATOS(P_DATOS IN T_DATOS_CONTRATO);

  PROCEDURE PRC_REINGRESA_CONTRATO (P_SOLICITUD IN RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE);
  
  PROCEDURE PRC_PROYECTA_AUMENTOS;
  
  PROCEDURE PRC_AUMENTOS_NUEVOAÑO(P_AÑO IN OUT NUMBER);

end PKG_DETALLE_OPERACION;
/
CREATE OR REPLACE PACKAGE BODY admsisa.PKG_DETALLE_OPERACION is

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 13/03/2014
  -- FUN_TRAER_FECHA
  -- Purpose : Función que obtiene el valor de ingreso del concepto dado
  -- como parámeetro
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_VALOR_INGRESO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                             P_AMPARO    RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                             P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE) RETURN NUMBER IS


    V_VALOR                  NUMBER;

  BEGIN

     BEGIN
        SELECT R.RNV_VLOR
          INTO V_VALOR
          FROM RSGOS_RCBOS_NVLOR R
         WHERE R.RNV_NMRO_ITEM   = P_SOLICITUD
           AND R.RNV_CDGO_AMPRO  = P_AMPARO
           AND R.RNV_CNCPTO_VLOR = P_CONCEPTO
           AND R.RNV_FCHA_NVDAD  = ( SELECT MIN(G.RNV_FCHA_NVDAD)
                                       FROM RSGOS_RCBOS_NVLOR G
                                      WHERE R.RNV_NMRO_ITEM   = G.RNV_NMRO_ITEM
                                        AND R.RNV_CDGO_AMPRO  = G.RNV_CDGO_AMPRO
                                        AND R.RNV_CNCPTO_VLOR = G.RNV_CNCPTO_VLOR);
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         BEGIN
          SELECT N.RVNV_VLOR
            INTO V_VALOR
            FROM RSGOS_VGNTES_NVLOR N
           WHERE N.RVNV_NMRO_ITEM   = P_SOLICITUD
             AND N.RVNV_CDGO_AMPRO  = P_AMPARO
             AND N.RVNV_CNCPTO_VLOR = P_CONCEPTO
             AND N.RVNV_FCHA_NVDAD  = (SELECT MIN(G.RVNV_FCHA_NVDAD)
                                         FROM RSGOS_VGNTES_NVLOR G
                                        WHERE N.RVNV_NMRO_ITEM   = G.RVNV_NMRO_ITEM
                                          AND N.RVNV_CDGO_AMPRO  = G.RVNV_CDGO_AMPRO
                                          AND N.RVNV_CNCPTO_VLOR = G.RVNV_CNCPTO_VLOR);
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                V_VALOR:= 0;
             WHEN OTHERS THEN
                V_VALOR:= 0;
          END;
       WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20501,SQLERRM);
      END;

      RETURN(V_VALOR);


  END FUN_VALOR_INGRESO;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 01/11/2012 03:33:30 p.m.
  -- FUN_TRAER_FECHA
  -- Purpose : Función que trae la fecha del período en que se encuentra
  -- la póliza.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_TRAER_FECHA(P_POLIZA  IN NUMBER,
                       P_RAMO    IN VARCHAR2,
                       P_CLASE   IN VARCHAR2,
                       P_NOVEDAD IN VARCHAR2,
                       P_MENSAJE OUT VARCHAR2) RETURN DATE IS

    CERTIFICADO   NUMBER(10);
    FECHA         DATE;
    PERIODO       VARCHAR2(6);
    FECHA_PERIODO DATE;
    NUMERO        NUMBER;
    ESTADO        PLZAS.POL_ESTADO_PLZA%TYPE;

  BEGIN
    BEGIN
      SELECT POL_NMRO_CRTFCDO, POL_ESTADO_PLZA
        INTO CERTIFICADO, ESTADO
        FROM PLZAS
       WHERE POL_NMRO_PLZA = P_POLIZA
         AND POL_CDGO_CLSE = P_CLASE
         AND POL_RAM_CDGO = P_RAMO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_MENSAJE := 'No se enecuntra la póliza';
      WHEN OTHERS THEN
        P_MENSAJE := 'Error al consultar la póliza.';
    END;
    IF CERTIFICADO != 0 THEN
      BEGIN
        SELECT CER_FCHA_DSDE_ACTUAL
          INTO FECHA
          FROM CRTFCDOS
         WHERE CER_NMRO_CRTFCDO = CERTIFICADO
           AND CER_NMRO_PLZA = P_POLIZA
           AND CER_CLSE_PLZA = P_CLASE
           AND CER_RAM_CDGO = P_RAMO;

        PERIODO       := BUSCAR_PERIODO(P_MENSAJE);
        FECHA_PERIODO := TO_DATE('01' || PERIODO, 'DDMMYYYY');
        IF FECHA < FECHA_PERIODO THEN
          IF ESTADO = 'R' AND P_NOVEDAD = '06' THEN
            NULL;
          ELSIF ESTADO = 'V' THEN
            -- SE INCLUYE PARA LAS POLIZAS QUE REVOCAN Y VUELVEN A DEJARLAS
            -- VIGENTES. AL REVOCARLAS EL SISTEMA NO GENERA CERTIFICADO FUTURO Y CUANDO LAS VUELVEN
            -- VIGENTES NO TIENE CERTIFICADO ACTUAL Y FALLA EL INGRESO DE LA NOVEDAD. 09/11/2006.SPPC.
            BEGIN
              INSERTAR_CERTIFICADO(P_POLIZA, P_CLASE, P_RAMO, PERIODO, FECHA);
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE:= SQLERRM;
            END;
          ELSE
            P_MENSAJE := 'El certificado de la póliza es de un período atrás. Consulte al administrador del sistema.';
          END IF;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          P_MENSAJE := 'No encontro certificado.';
        WHEN OTHERS THEN
          P_MENSAJE := 'Error al consultar el certficado de la póliza.';
      END;
    ELSE
      PERIODO := BUSCAR_PERIODO(P_MENSAJE);
      FECHA   := TO_DATE('01' || PERIODO, 'DDMMYYYY');
      BEGIN
        SELECT COUNT(8)
          INTO NUMERO
          FROM CRTFCDOS, PLZAS
         WHERE CER_FCHA_DSDE_ACTUAL = FECHA
           AND CER_ESTDO_PRDCCION IN ('20', '30', '50')
           AND CER_NMRO_PLZA = POL_NMRO_PLZA
           AND CER_CLSE_PLZA = POL_CDGO_CLSE
           AND CER_RAM_CDGO = POL_RAM_CDGO
           AND POL_TPOPLZA = 'C'
           AND POL_ESTADO_PLZA = 'V';
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := 'Error: consultando si se ha cerrado el periodo vigente';
      END;
      IF NVL(NUMERO, 0) > 0 THEN
        FECHA := ADD_MONTHS(FECHA, 1);
      END IF;
    END IF;
    RETURN(FECHA);
  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 27/03/2014
  -- FUN_OBTENER_AUMENTO
  -- Purpose : Función que trae el valor del concepto en año dado como
  -- parámetro de acuerdo a los datos de aumentos del contrato de
  -- arrendamiento.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_OBTENER_AUMENTO (P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE,
                                P_FECHA_AUMENTO DATE) RETURN NUMBER IS

     V_VALOR_AUMENTO NUMBER;
     V_IVA        VARCHAR2(1);

  BEGIN

    SELECT D.INCLUYE_IVA_COMERCIAL
     INTO V_IVA
     FROM DATOS_CONTRATOS D
    WHERE D.SOLICITUD    = P_SOLICITUD;

    IF NVL(V_IVA,'N')  = 'S' THEN
     SELECT A.TOTAL_VALOR
       INTO V_VALOR_AUMENTO
       FROM AUMENTOS_CONTRATOS A
      WHERE A.SOLICITUD = P_SOLICITUD
        AND A.CONCEPTO  = P_CONCEPTO
        AND TO_NUMBER(TO_CHAR(A.FECHA_AUMENTO,'YYYY')) =   TO_NUMBER(TO_CHAR(P_FECHA_AUMENTO,'YYYY')) ;
   ELSE
     SELECT A.VALOR_SIN_IVA
       INTO V_VALOR_AUMENTO
       FROM AUMENTOS_CONTRATOS A
      WHERE A.SOLICITUD = P_SOLICITUD
        AND A.CONCEPTO  = P_CONCEPTO
        AND TO_NUMBER(TO_CHAR(A.FECHA_AUMENTO,'YYYY')) =   TO_NUMBER(TO_CHAR(P_FECHA_AUMENTO,'YYYY')) ;

   END IF;

     RETURN(V_VALOR_AUMENTO);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(0);
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501,'No encuentra valores en la tabla para verificar el aumento. ');
  END;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 28/05/2014
  -- FUN_INCREMENTO_SUGERIDO
  -- Purpose : Función que trae el valor sugerido del concepto en la fecha
  -- dada de acuerdo a la tabla de datos del contrato, sino tiene destinación
  -- o reajuste debe traer el valor asegurado incrementado en el porcentaje
  -- dado como parámetro para aumentos.
  -- Modificado por:
  --
  --
  /***********************************************************************/

 FUNCTION FUN_INCREMENTO_SUGERIDO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                   P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE,
                                   P_FECHA_AUMENTO DATE,
                                   P_DESTINO       SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                                   P_TIPO_AUMENTO  DATOS_CONTRATOS.TIPO_AUMENTO_CANON%TYPE) RETURN NUMBER IS

    V_VALOR_AUMENTO NUMBER;
    V_COMPANIA      SCRSL.SUC_CIA_CDGO%TYPE;
    V_SUCURSAL      SCRSL.SUC_CDGO%TYPE;
    V_PARAMETRO     NUMBER;


  BEGIN

    V_VALOR_AUMENTO :=  FUN_OBTENER_AUMENTO (P_SOLICITUD,P_CONCEPTO,P_FECHA_AUMENTO);

    IF NVL(P_DESTINO,'S') NOT IN ('V','C')  OR P_TIPO_AUMENTO = '10' THEN

        SELECT P.POL_SUC_CDGO, P.POL_SUC_CIA_CDGO
          INTO V_SUCURSAL,V_COMPANIA
          FROM RSGOS_VGNTES R,PLZAS P
         WHERE R.RVI_NMRO_ITEM = P_SOLICITUD
           AND R.RVI_NMRO_PLZA = P.POL_NMRO_PLZA
           AND R.RVI_CLSE_PLZA = P.POL_CDGO_CLSE
           AND R.RVI_RAM_CDGO  = P.POL_RAM_CDGO;

          SELECT PAR_VLOR2
            INTO V_PARAMETRO
            FROM PRMTROS
           WHERE PAR_CDGO = '2'
             AND PAR_MDLO = '2'
             AND PAR_VLOR1 = 9
             AND PAR_SUC_CDGO = V_SUCURSAL
             AND PAR_SUC_CIA_CDGO = V_COMPANIA;


          IF V_VALOR_AUMENTO = 0 THEN

            BEGIN
             SELECT R.RVL_VLOR
               INTO V_VALOR_AUMENTO
               FROM RSGOS_VGNTES_AVLOR R
              WHERE R.RVL_NMRO_ITEM   = P_SOLICITUD
                AND R.RVL_CNCPTO_VLOR = P_CONCEPTO;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 V_VALOR_AUMENTO := 0;
            END;

          END IF;

          V_VALOR_AUMENTO := ROUND(V_VALOR_AUMENTO + (V_VALOR_AUMENTO * V_PARAMETRO / 100),0);

    END IF;

    RETURN(V_VALOR_AUMENTO);

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501,SQLERRM);
  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 03/04/2014
  -- FUN_AUMENTO_ANUAL
  -- Purpose : Función que trae el valor del concepto en el útimo  año dado como
  -- parámetro de acuerdo a los datos de aumentos del contrato de
  -- arrendamiento.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_AUMENTO_ANUAL (P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                              P_AMPARO    RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                              P_FECHA_AUMENTO DATE) RETURN NUMBER IS

     V_VALOR_AUMENTO NUMBER;
     V_FECHA_INICIAL DATE;

  BEGIN

     V_FECHA_INICIAL := ADD_MONTHS(P_FECHA_AUMENTO,-11);

     SELECT SUM(NVL(R.RIVN_VLOR_DFRNCIA,0))
       INTO V_VALOR_AUMENTO
       FROM RSGOS_VGNTES_NVDDES R
      WHERE RIVN_NMRO_ITEM = P_SOLICITUD
        AND RIVN_CDGO_AMPRO = P_AMPARO
        AND RIVN_TPO_NVDAD = '04'
        AND TRUNC(RIVN_FCHA_NVDAD) >= TRUNC(V_FECHA_INICIAL)
        AND TRUNC(RIVN_FCHA_NVDAD) <= TRUNC(ADD_MONTHS(P_FECHA_AUMENTO,-1));


     RETURN(V_VALOR_AUMENTO);

  EXCEPTION
    WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20501,'No encuentra los valores de aumento de una año atrás. ');

  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 01/11/2012 03:33:30 p.m.
  -- PRC_REACTIVAR_PAGO
  -- Purpose : Procedimiento que realiza la liquidación de cobro de primas
  -- de los reisgos que tiene diferente tipo de tasa a la Mensual ni unica.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_COBRO_REINGRESO(P_AMPARO            IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                            P_SOLICITUD         IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                            P_POLIZA            IN PLZAS.POL_NMRO_PLZA%TYPE,
                            P_CLASE             IN PLZAS.POL_CDGO_CLSE%TYPE,
                            P_RAMO              IN PLZAS.POL_RAM_CDGO%TYPE,
                            P_TIPO_TASA         VARCHAR2,
                            P_TASA              NUMBER,
                            P_VALOR_ASEGURADO   NUMBER,
                            P_INCLUYE_IVA       VARCHAR2,
                            P_PORC_DESCUENTO    NUMBER,
                            P_FECHA_LIQUIDACION DATE,
                            P_CERTIFICADO       NUMBER,
                            P_PERIODO           VARCHAR2,
                            P_MENSAJE           OUT VARCHAR2,
                            P_USUARIO           USRIOS.USR_CDGO_USRIO%TYPE) IS

    PRORRATA              NUMBER := 1;
    IVA_RETRO             NUMBER(18, 2) := 0;
    IVA_RETRO_ANT         NUMBER(18, 2) := 0;
    DESCUENTO             NUMBER(18, 2) := 0;
    IVA                   NUMBER(18, 2);
    FECHA_S               DATE;
    FECHA_N               DATE;
    PRIMA_NETA            NUMBER := 0;
    PRIMA_TOTAL           NUMBER := 0;
    IVA_PRIMA             NUMBER := 0;
    IVA_RETRO             NUMBER := 0;
    IVA_RETRO_ANT         NUMBER := 0;
    FECHA_COBRO           DATE;
    VALOR_COBRAR          NUMBER(18, 2);
    ANTICIPADO            NUMBER(1) := 0;

    PERIODO_TASA  NUMBER(4);
    MESES         NUMBER(4);
    FECHA         DATE;
    PRIMA         NUMBER;
  BEGIN

    -- Trae el porcentaje de IVA definido
    BEGIN
      SELECT PAR_VLOR2
        INTO IVA
        FROM PRMTROS
       WHERE PAR_CDGO = '4'
         AND PAR_MDLO = '6'
         AND PAR_VLOR1 = '01'
         AND PAR_FCHA_CREACION = (SELECT MAX(PAR_FCHA_CREACION)
                                    FROM PRMTROS
                                   WHERE PAR_VLOR1 = '01'
                                     AND PAR_MDLO = '6'
                                     AND PAR_CDGO = '4');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_MENSAJE := 'ERROR EN LA BUSQUEDA DEL IVA';
        ROLLBACK;
        RETURN;
      WHEN OTHERS THEN
        P_MENSAJE := 'ERROR EN LA BUSQUEDA DEL IVA';
        ROLLBACK;
        RETURN;
    END;

    IF P_TIPO_TASA NOT IN ('M', 'U') THEN

      /*******************************************************************************
      **************/
      /* CALCULO DE LAS PRIMAS PARA CADA UNO DE LOS AMPAROS BASICOS        */
      /*******************************************************************************
      **************/

      IF P_TIPO_TASA = 'U' THEN
        PRIMA := (P_VALOR_ASEGURADO * P_TASA) / 100;
      ELSE

        PRIMA := ((P_VALOR_ASEGURADO * P_TASA) / 100) * PRORRATA;
      END IF;
      DESCUENTO     := (PRIMA * P_PORC_DESCUENTO) / 100;

      /* VERIFICAR SI LA TARIFA DEL AMPARO INCLUYE IVA O NO */

      IF P_INCLUYE_IVA = 'N' THEN
        PRIMA           := PRIMA - DESCUENTO;
        PRIMA_NETA      := PRIMA;
        IVA_PRIMA       := (PRIMA * IVA) / 100;
        PRIMA_TOTAL     := PRIMA + IVA_PRIMA;
      ELSE
        PRIMA           := PRIMA - DESCUENTO;
        PRIMA_NETA      := PRIMA * (100 / (IVA + 100));
        IVA_PRIMA       := (PRIMA_NETA * (IVA / 100));
        PRIMA_TOTAL     := PRIMA;
      END IF;

      FECHA_N := TO_DATE(TO_CHAR(P_FECHA_LIQUIDACION, 'DD/MM/YYYY') || ' ' ||
                         '02:18:00',
                         'DD/MM/YYYY HH:MI:SS');

      IF P_TIPO_TASA = 'U' THEN
        PERIODO_TASA    := 1;
      ELSIF P_TIPO_TASA = 'A' THEN
        FECHA_S         := ADD_MONTHS(FECHA_N, 12);
        PERIODO_TASA    := 12;
      ELSIF P_TIPO_TASA = 'S' THEN
        FECHA_S         := ADD_MONTHS(FECHA_N, 6);
        PERIODO_TASA    := 6;
      ELSIF P_TIPO_TASA = 'T' THEN
        FECHA_S         := ADD_MONTHS(FECHA_N, 3);
        PERIODO_TASA    := 3;
      ELSIF P_TIPO_TASA = 'B' THEN
        FECHA_S         := ADD_MONTHS(FECHA_N, 2);
        PERIODO_TASA    := 2;
      END IF;

      BEGIN
        SELECT MAX(REN_FCHA_NVDAD), REN_VLOR_DFRNCIA
          INTO FECHA_COBRO, VALOR_COBRAR
          FROM RSGOS_RCBOS_NVDAD
         WHERE REN_NMRO_ITEM = P_SOLICITUD
           AND REN_NMRO_PLZA = P_POLIZA
           AND REN_CLSE_PLZA = P_CLASE
           AND REN_RAM_CDGO = P_RAMO
           AND REN_CDGO_AMPRO = '01'
           AND REN_TPO_NVDAD = '14'
         group by REN_VLOR_DFRNCIA;

        MESES           := MONTHS_BETWEEN(FECHA_COBRO, P_FECHA_LIQUIDACION);
        PRIMA_NETA      := PRIMA_NETA * MESES / PERIODO_TASA;
        IVA_PRIMA       := IVA_PRIMA * MESES / PERIODO_TASA;
        PRIMA_TOTAL     := PRIMA;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ANTICIPADO := 1;
        WHEN OTHERS THEN
          P_MENSAJE := 'Error al encontrar el cobro anticipado de la prima.';
          ROLLBACK;
          RETURN;

      END;

      FECHA := TO_DATE('01' || '/' || SUBSTR(P_PERIODO, 1, 2) || '/' ||
                       SUBSTR(P_PERIODO, 3, 4) || ' ' || '01:07:00',
                       'DD/MM/YYYY HH:MI:SS');

      IF ANTICIPADO = 0 THEN
        /*COBRA LA DIFERENCIA ENTRE EL MES DE LA NOVEDAD Y EL MES ANTERIOR A LA SIGUIENTE FECHA DE COBRO DEL RIESGO*/
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + PRIMA_NETA
           WHERE RIVN_NMRO_ITEM = P_SOLICITUD
             AND RIVN_NMRO_PLZA = P_POLIZA
             AND RIVN_CLSE_PLZA = P_CLASE
             AND RIVN_RAM_CDGO = P_RAMO
             AND RIVN_CDGO_AMPRO = P_AMPARO
             AND RIVN_TPO_NVDAD = '13'
             AND TRUNC(RIVN_FCHA_NVDAD) = TRUNC(FECHA);

          IF SQL%NOTFOUND THEN
            INSERT INTO RSGOS_VGNTES_NVDDES
              (RIVN_FCHA_NVDAD,
               RIVN_CDGO_AMPRO,
               RIVN_RAM_CDGO,
               RIVN_NMRO_ITEM,
               RIVN_NMRO_PLZA,
               RIVN_CLSE_PLZA,
               RIVN_TPO_NVDAD,
               RIVN_VLOR_DFRNCIA,
               RIVN_FCHA_MDFCCION,
               RIVN_USRIO)
            VALUES
              (FECHA,
               P_AMPARO,
               P_RAMO,
               P_SOLICITUD,
               P_POLIZA,
               P_CLASE,
               '13',
               PRIMA_NETA,
               FECHA,
               P_USUARIO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'ERROR INSERTANDO COBRO PARA EL TIPO DE TASA.' ||
                       P_TIPO_TASA || ' ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        /* ACTUALIZA EL CERTFICADO CON LA DIFERENCIA POR COBRAR*/
        BEGIN
          UPDATE CRTFCDOS
             SET CER_VLOR_PRMA_NTA   = CER_VLOR_PRMA_NTA + PRIMA_NETA,
                 CER_VLOR_PRMA_TTAL  = CER_VLOR_PRMA_TTAL + PRIMA_TOTAL,
                 CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA + P_VALOR_ASEGURADO,
                 CER_VLOR_IVA        = CER_VLOR_IVA + IVA_PRIMA
           WHERE CER_NMRO_CRTFCDO = P_CERTIFICADO
             AND CER_NMRO_PLZA = P_POLIZA
             AND CER_CLSE_PLZA = P_CLASE
             AND CER_RAM_CDGO = P_RAMO;
          IF SQL%NOTFOUND THEN
            P_MENSAJE := 'ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
            ROLLBACK;
            RETURN;
          END IF;
        END;

        /* REGISTRA EL SIGUIENTE COBRO QUE DEBE TENER EL RIESGO*/
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_NMRO_PLZA = P_POLIZA
           WHERE RIVN_NMRO_ITEM = P_SOLICITUD
             AND RIVN_NMRO_PLZA = P_POLIZA
             AND RIVN_CLSE_PLZA = P_CLASE
             AND RIVN_RAM_CDGO = P_RAMO
             AND RIVN_CDGO_AMPRO = P_AMPARO
             AND RIVN_TPO_NVDAD = '14'
             AND TRUNC(RIVN_FCHA_NVDAD) = TRUNC(FECHA_COBRO);
          IF SQL%NOTFOUND THEN
            INSERT INTO RSGOS_VGNTES_NVDDES
              (RIVN_FCHA_NVDAD,
               RIVN_CDGO_AMPRO,
               RIVN_RAM_CDGO,
               RIVN_NMRO_ITEM,
               RIVN_NMRO_PLZA,
               RIVN_CLSE_PLZA,
               RIVN_TPO_NVDAD,
               RIVN_VLOR_DFRNCIA,
               RIVN_FCHA_MDFCCION,
               RIVN_USRIO)
            VALUES
              (FECHA_COBRO,
               P_AMPARO,
               P_RAMO,
               P_SOLICITUD,
               P_POLIZA,
               P_CLASE,
               '14',
               VALOR_COBRAR,
               FECHA_COBRO,
               P_USUARIO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'ERROR INSERTANDO COBRO SIGUIENTE PARA EL TIPO DE TASA.' ||
                       P_TIPO_TASA || ' ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      ELSE

        /* REALIZA EL COBRO INICIAL PUES EL REISGO VIENE DE UNA TASA DIFERENTE*/

        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + PRIMA_NETA
           WHERE RIVN_NMRO_ITEM = P_SOLICITUD
             AND RIVN_NMRO_PLZA = P_POLIZA
             AND RIVN_CLSE_PLZA = P_CLASE
             AND RIVN_RAM_CDGO = P_RAMO
             AND RIVN_CDGO_AMPRO = P_AMPARO
             AND RIVN_TPO_NVDAD = '13'
             AND TRUNC(RIVN_FCHA_NVDAD) = TRUNC(FECHA);

          IF SQL%NOTFOUND THEN
            INSERT INTO RSGOS_VGNTES_NVDDES
              (RIVN_FCHA_NVDAD,
               RIVN_CDGO_AMPRO,
               RIVN_RAM_CDGO,
               RIVN_NMRO_ITEM,
               RIVN_NMRO_PLZA,
               RIVN_CLSE_PLZA,
               RIVN_TPO_NVDAD,
               RIVN_VLOR_DFRNCIA,
               RIVN_FCHA_MDFCCION,
               RIVN_USRIO)
            VALUES
              (FECHA,
               P_AMPARO,
               P_RAMO,
               P_SOLICITUD,
               P_POLIZA,
               P_CLASE,
               '13',
               PRIMA_NETA,
               FECHA,
               P_USUARIO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'ERROR INSERTANDO COBRO PARA EL TIPO DE TASA.' ||
                       P_TIPO_TASA || ' ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        /* ACTUALIZA EL CERTFICADO CON LA DIFERENCIA POR COBRAR*/
        BEGIN
          UPDATE CRTFCDOS
             SET CER_VLOR_PRMA_NTA   = CER_VLOR_PRMA_NTA + PRIMA_NETA,
                 CER_VLOR_PRMA_TTAL  = CER_VLOR_PRMA_TTAL + PRIMA_TOTAL,
                 CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA + P_VALOR_ASEGURADO,
                 CER_VLOR_IVA        = CER_VLOR_IVA + IVA_PRIMA
           WHERE CER_NMRO_CRTFCDO = P_CERTIFICADO
             AND CER_NMRO_PLZA = P_POLIZA
             AND CER_CLSE_PLZA = P_CLASE
             AND CER_RAM_CDGO = P_RAMO;
          IF SQL%NOTFOUND THEN
            P_MENSAJE := 'ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
            ROLLBACK;
            RETURN;
          END IF;
        END;

        /* REGISTRA EL SIGUIENTE COBRO QUE DEBE TENER EL RIESGO*/
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_NMRO_PLZA = P_POLIZA
           WHERE RIVN_NMRO_ITEM = P_SOLICITUD
             AND RIVN_NMRO_PLZA = P_POLIZA
             AND RIVN_CLSE_PLZA = P_CLASE
             AND RIVN_RAM_CDGO = P_RAMO
             AND RIVN_CDGO_AMPRO = P_AMPARO
             AND RIVN_TPO_NVDAD = '14'
             AND TRUNC(RIVN_FCHA_NVDAD) = TRUNC(FECHA_S);
          IF SQL%NOTFOUND THEN
            INSERT INTO RSGOS_VGNTES_NVDDES
              (RIVN_FCHA_NVDAD,
               RIVN_CDGO_AMPRO,
               RIVN_RAM_CDGO,
               RIVN_NMRO_ITEM,
               RIVN_NMRO_PLZA,
               RIVN_CLSE_PLZA,
               RIVN_TPO_NVDAD,
               RIVN_VLOR_DFRNCIA,
               RIVN_FCHA_MDFCCION,
               RIVN_USRIO)
            VALUES
              (FECHA_S,
               P_AMPARO,
               P_RAMO,
               P_SOLICITUD,
               P_POLIZA,
               P_CLASE,
               '14',
               PRIMA_NETA,
               FECHA_S,
               P_USUARIO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'ERROR INSERTANDO COBRO SIGUIENTE PARA EL TIPO DE TASA.' ||
                       P_TIPO_TASA || ' ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;

    END IF;
  END PRC_COBRO_REINGRESO;



  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 01/11/2012 03:33:30 p.m.
  -- PRC_REACTIVAR_PAGO
  -- Purpose : Procedimiento que verifica si la solicitud quedo con un
  -- siniestro suspendido para reactivar el giro de siniestro de la solicitud
  -- desde la fecha en que qeudó retirado hasta el período actual.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_REACTIVAR_PAGOS(SOLICITUD     IN NUMBER,
                            AMPARO        IN VARCHAR2,
                            MENSAJE       IN OUT VARCHAR2,
                            P_SUCURSAL    IN SCRSL.SUC_CDGO%TYPE,
                            P_COMPANIA    IN SCRSL.SUC_CIA_CDGO%TYPE,
                            P_USUARIO     IN USRIOS.USR_CDGO_USRIO%TYPE) IS

    CURSOR C_SINIESTROS IS
      SELECT SNA_NMRO_SNSTRO,
             SNA_FCHA_SNSTRO,
             SNA_NMRO_PLZA,
             SNA_CLSE_PLZA,
             SNA_RAM_CDGO
        FROM AVSOS_SNSTROS
       WHERE SNA_NMRO_ITEM = SOLICITUD
         AND SNA_ESTDO_SNSTRO IN ('01', '02')
         AND SNA_ESTDO_PGO IN ('02', '04')
         AND EXISTS (SELECT *
                FROM SSPNSNES_SNSTROS
               WHERE SSN_NMRO_SNSTRO = SNA_NMRO_SNSTRO
                 AND SSN_CDGO_AMPRO = AMPARO
                 AND SSN_CDGO_SSPNSION = '21')
         AND NOT EXISTS (SELECT *
                FROM SSPNSNES_SNSTROS
               WHERE SSN_NMRO_SNSTRO = SNA_NMRO_SNSTRO
                 AND SSN_CDGO_AMPRO = AMPARO
                 AND SSN_CDGO_SSPNSION <> '21')
         AND NOT EXISTS (SELECT *
                FROM OBJCNES_SNSTROS
               WHERE OBS_NMRO_SNSTRO = SNA_NMRO_SNSTRO
                 AND OBS_TPO = 'O'
                 AND OBS_SUBSANA = 'N');

    CURSOR C_LIQUIDACIONES(SOLICI NUMBER, SNSTRO NUMBER) IS
      SELECT LQD_FCHA_PGO,
             LQT_TPO_LQDCION,
             LQT_FCHA_DSDE,
             LQT_FCHA_HSTA,
             LQT_ESTDO_LQDCION,
             LQT_PRDO,
             LQT_SERIE
        FROM LQDCNES, LQDCNES_DTLLE
       WHERE LQD_NMRO_SLCTUD = SOLICI
         AND LQT_NMRO_SLCTUD = LQD_NMRO_SLCTUD
         AND LQT_TPO_LQDCION = LQD_TPO_LQDCION
         AND LQT_PRDO = LQD_PRDO
         AND LQT_ESTDO_LQDCION IN ('01', '02')
         AND LQT_NMRO_SNSTRO = SNSTRO;

    T_SNA_NMRO_SNSTRO   NUMBER(10);
    T_SNA_FCHA_SNSTRO   DATE;
    T_LQD_FCHA_PGO      DATE;
    T_LQT_TPO_LQDCION   VARCHAR2(2);
    T_LQT_FCHA_DSDE     DATE;
    T_LQT_FCHA_HSTA     DATE;
    T_LQT_ESTDO_LQDCION VARCHAR2(2);
    T_SNA_NMRO_PLZA     NUMBER(10);
    T_SNA_CLSE_PLZA     VARCHAR2(2);
    T_SNA_RAM_CDGO      VARCHAR2(2);
    PROX_FECHA          DATE;
    FECHA_HASTA         DATE;
    FECHA_HASTA_C       VARCHAR2(11);
    PERIODO             VARCHAR2(6);
    T_LQT_PRDO          VARCHAR2(6);
    T_LQT_SERIE         NUMBER(8);
    limite              number;
    meses_pago          number;
    anomes_desde        date;
    anomes_hasta        date;
    meses_a_pagar       number;
    fecha_hasta_1       date;
    fecha_desdel        date;
    fecha_hastal        date;

  BEGIN

    OPEN C_SINIESTROS;
    LOOP
      FETCH C_SINIESTROS
        INTO T_SNA_NMRO_SNSTRO,
             T_SNA_FCHA_SNSTRO,
             T_SNA_NMRO_PLZA,
             T_SNA_CLSE_PLZA,
             T_SNA_RAM_CDGO;
      IF C_SINIESTROS%NOTFOUND THEN
        EXIT;
      ELSE
        OPEN C_LIQUIDACIONES(SOLICITUD, T_SNA_NMRO_SNSTRO);
        LOOP
          FETCH C_LIQUIDACIONES
            INTO T_LQD_FCHA_PGO,
                 T_LQT_TPO_LQDCION,
                 T_LQT_FCHA_DSDE,
                 T_LQT_FCHA_HSTA,
                 T_LQT_ESTDO_LQDCION,
                 T_LQT_PRDO,
                 T_LQT_SERIE;
          IF C_LIQUIDACIONES%NOTFOUND THEN
            EXIT;
          ELSE
            IF T_LQT_ESTDO_LQDCION = '01' THEN
              BEGIN
                UPDATE LQDCNES_DTLLE
                   SET LQT_ESTDO_LQDCION = '02'
                 WHERE LQT_NMRO_SLCTUD = SOLICITUD
                   AND LQT_TPO_LQDCION = T_LQT_TPO_LQDCION
                   AND LQT_PRDO = T_LQT_PRDO
                   AND LQT_SERIE = T_LQT_SERIE;
                IF SQL%NOTFOUND THEN
                  RAISE_APPLICATION_ERROR(-20501,'PROBLEMAS ACTUALIZANDO EL ESTADO DE LA LIQUIDACION');
                  RETURN;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20501,'PROBLEMAS ACTUALIZANDO EL ESTADO DE LA LIQUIDACION');
                  RETURN;
              END;
            END IF;
            BEGIN
              PROX_FECHA := PKG_SINIESTROS.FUN_FCHA_PAGO(T_SNA_NMRO_PLZA,
                                                         T_SNA_CLSE_PLZA,
                                                         T_SNA_RAM_CDGO,
                                                         PERIODO);
              IF PROX_FECHA IS NULL THEN
                RAISE_APPLICATION_ERROR(-20501,'No encontro fecha de pago...');
                RETURN;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20501,'Error. No encontro fecha de pago...' ||SQLERRM);

                RETURN;
            END;

            IF LAST_DAY(TO_DATE('01' || TO_CHAR(T_LQT_FCHA_HSTA, 'MMYYYY'),
                                'DDMMYYYY')) = T_LQT_FCHA_HSTA THEN
              FECHA_HASTA := LAST_DAY(PROX_FECHA);
            ELSIF TO_CHAR(T_LQT_FCHA_HSTA, 'DD') IN ('28', '29', '30', '31') THEN
              IF LAST_DAY(PROX_FECHA) = '28' THEN
                FECHA_HASTA := LAST_DAY(PROX_FECHA);
              ELSIF LAST_DAY(PROX_FECHA) = '29' AND
                    TO_CHAR(T_LQT_FCHA_HSTA, 'DD') = '28' THEN
                FECHA_HASTA_C := TO_CHAR(T_LQT_FCHA_HSTA, 'DD') ||
                                 TO_CHAR(PROX_FECHA, 'MMYYYY');
                FECHA_HASTA   := TO_DATE(FECHA_HASTA_C, 'DDMMYYYY');
              ELSIF LAST_DAY(PROX_FECHA) = '29' AND
                    TO_CHAR(T_LQT_FCHA_HSTA, 'DD') IN ('29', '30', '31') THEN
                FECHA_HASTA := LAST_DAY(PROX_FECHA);
              END IF;
            ELSE
              FECHA_HASTA_C := TO_CHAR(T_LQT_FCHA_HSTA, 'DD') ||
                               TO_CHAR(PROX_FECHA, 'MMYYYY');
              FECHA_HASTA   := TO_DATE(FECHA_HASTA_C, 'DDMMYYYY');
            END IF;

            fecha_desdel := T_LQT_FCHA_DSDE;
            fecha_hastal := FECHA_HASTA;

            BEGIN
              SELECT LIR_LMTE_INDMNZCION, LIR_CNTDAD_PGOS
                INTO limite, meses_pago
                FROM LMTES_IND_RSGOS
               WHERE LIR_NMRO_ITEM = SOLICITUD
                 AND LIR_FCHA_MRA = T_SNA_FCHA_SNSTRO
                 AND LIR_NMRO_PLZA = T_SNA_NMRO_PLZA
                 AND LIR_CLSE_PLZA = T_SNA_CLSE_PLZA
                 AND LIR_RAM_CDGO = T_SNA_RAM_CDGO;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20501,'Hubo problemas trayendo el numero de pagos...');
                RETURN;
            END;

            SELECT LAST_DAY(FECHA_DESDEl) into anomes_desde FROM dual;

            SELECT LAST_DAY(fecha_hastal) into anomes_hasta FROM dual;

            SELECT ROUND(months_between(anomes_hasta, anomes_desde))
              INTO meses_a_pagar
              FROM dual;

            IF (meses_a_pagar + meses_pago) > limite THEN
              SELECT ADD_MONTHS(T_LQT_FCHA_DSDE, (limite - meses_pago)) - 1
                INTO FECHA_HASTA_1
                FROM DUAL;
              IF FECHA_HASTA_1 <= FECHA_DESDEl THEN
                RAISE_APPLICATION_ERROR(-20501,'El limite ya fue superado no se efectuará ningun pago Indemnizatorio...');
                RETURN;
              ELSE
                fecha_hastal := FECHA_HASTA_1;
              END IF;
            END IF;




            PKG_NVDDES_INDMNZCNES.PR_ORDEN_PAGO(SOLICITUD,
                                                    T_SNA_FCHA_SNSTRO,
                                                    T_SNA_RAM_CDGO,
                                                    T_SNA_NMRO_SNSTRO,
                                                    P_SUCURSAL,
                                                    P_COMPANIA,
                                                    T_SNA_NMRO_PLZA,
                                                    T_SNA_CLSE_PLZA,
                                                    MENSAJE,
                                                    P_USUARIO,
                                                    T_LQT_FCHA_DSDE,
                                                    fecha_hastal);
            IF MENSAJE IS NOT NULL THEN
              RAISE_APPLICATION_ERROR(-20501,MENSAJE);
              RETURN;
            END IF;
            BEGIN
              UPDATE SSPNSNES_SNSTROS
                 SET SSN_FCHA_LVNTE_SSPNSION = SYSDATE
               WHERE SSN_NMRO_SNSTRO = T_SNA_NMRO_SNSTRO
                 AND SSN_CDGO_SSPNSION = '21'
                 AND SSN_FCHA_LVNTE_SSPNSION IS NULL;
              IF SQL%NOTFOUND THEN
                NULL;
              END IF;

            END;

          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 01/11/2012 03:33:30 p.m.
  -- PRC_COPIAR_NOVEDADES
  -- Purpose : Procedimiento que copia las novedades que tiene el riesgo
  -- en el histórico de novedades a las novedades vigentes.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_COPIAR_NOVEDADES(SOLICITUD   IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                             POLIZA      IN PLZAS.POL_NMRO_PLZA%TYPE,
                             CLASE       IN PLZAS.POL_CDGO_CLSE%TYPE,
                             RAMO        IN PLZAS.POL_RAM_CDGO%TYPE,
                             AMPARO      IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                             CERTIFICADO IN CRTFCDOS.CER_NMRO_CRTFCDO%TYPE,
                             MENSAJE     OUT VARCHAR2) IS

    CURSOR NOVEDADES IS
      SELECT *
        FROM RSGOS_RCBOS_NVDAD
       WHERE REN_CDGO_AMPRO = AMPARO
         AND REN_NMRO_ITEM = SOLICITUD
         AND REN_NMRO_CRTFCDO = CERTIFICADO
         AND REN_NMRO_PLZA = POLIZA
         AND REN_CLSE_PLZA = CLASE
         AND REN_RAM_CDGO = RAMO
         AND REN_TPO_NVDAD != '02';
    CURSOR VALORES(FECHA DATE) IS
      SELECT *
        FROM RSGOS_RCBOS_NVLOR
       WHERE RNV_FCHA_NVDAD = FECHA
         AND RNV_CDGO_AMPRO = AMPARO
         AND RNV_NMRO_ITEM = SOLICITUD
         AND RNV_NMRO_CRTFCDO = CERTIFICADO
         AND RNV_NMRO_PLZA = POLIZA
         AND RNV_CLSE_PLZA = CLASE
         AND RNV_RAM_CDGO = RAMO;

  BEGIN
    FOR REG_NOVEDADES IN NOVEDADES LOOP
      BEGIN
        INSERT INTO RSGOS_VGNTES_NVDDES
        VALUES
          (REG_NOVEDADES.REN_FCHA_NVDAD,
           REG_NOVEDADES.REN_CDGO_AMPRO,
           REG_NOVEDADES.REN_RAM_CDGO,
           REG_NOVEDADES.REN_NMRO_ITEM,
           REG_NOVEDADES.REN_NMRO_PLZA,
           REG_NOVEDADES.REN_CLSE_PLZA,
           REG_NOVEDADES.REN_TPO_NVDAD,
           REG_NOVEDADES.REN_VLOR_DFRNCIA,
           REG_NOVEDADES.REN_FCHA_MDFCCION,
           REG_NOVEDADES.REN_USRIO);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          MENSAJE := 'Error al insertar en vigentes novedades ' || SQLERRM;
      END;
      FOR REG_VALORES IN VALORES(REG_NOVEDADES.REN_FCHA_NVDAD) LOOP
        BEGIN
          INSERT INTO RSGOS_VGNTES_NVLOR
          VALUES
            (REG_VALORES.RNV_FCHA_NVDAD,
             REG_VALORES.RNV_CDGO_AMPRO,
             REG_VALORES.RNV_RAM_CDGO,
             REG_VALORES.RNV_NMRO_ITEM,
             REG_VALORES.RNV_NMRO_PLZA,
             REG_VALORES.RNV_CLSE_PLZA,
             REG_VALORES.RNV_CNCPTO_VLOR,
             REG_VALORES.RNV_VLOR,
             REG_VALORES.RNV_USRIO,
             REG_VALORES.RNV_FCHA_MDFCCION);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            MENSAJE := 'Error al insertar en vigentes novedades ' || SQLERRM;
        END;
      END LOOP;
    END LOOP;
  END;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 01/11/2012 03:33:30 p.m.
  -- PRC_VALIDAR_SEGURO
  -- Purpose : Procedimiento que valida que un concepto para una solicitud
  -- no este ingresado pues no se podría hacer el reingreso.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_BUSCAR_TASA_REINGRESO(P_AMPARO        IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                                  P_RAMO          IN AMPROS_PRDCTO.APR_RAM_CDGO%TYPE,
                                  P_CLASE         IN PLZAS.POL_CDGO_CLSE%TYPE,
                                  P_SUCURSAL      IN SCRSL.SUC_CDGO%TYPE,
                                  P_COMPANIA      IN SCRSL.SUC_CIA_CDGO%TYPE,
                                  P_POLIZA        IN PLZAS.POL_NMRO_PLZA%TYPE,
                                  P_SOLICITUD     IN NUMBER,
                                  TASA            IN OUT NUMBER,
                                  TIPO_TASA       IN OUT VARCHAR2,
                                  PORC_DESCUENTO  IN OUT NUMBER,
                                  VALOR_ASEGURADO IN OUT NUMBER,
                                  CUOTAS          OUT NUMBER,
                                  INCLUYE_IVA     IN OUT VARCHAR2,
                                  MENSAJE         IN OUT NUMBER) IS

    CURSOR TASAS IS
      SELECT TAP_TSA_BSCA,
             TAP_TPO_TSA,
             TAP_DSCNTO_TMDOR,
             TAP_NMRO_CUOTAS,
             TAP_INCLYE_IVA
        FROM TRFA_AMPROS_PRDCTO
       WHERE TAP_CDGO_AMPRO = P_AMPARO
         AND TAP_RAM_CDGO = P_RAMO
         AND TAP_SUC_CDGO = P_SUCURSAL
         AND TAP_CIA_CDGO = P_COMPANIA
         AND TAP_TPO_PLZA = 'C';
    CURSOR TASAS_POLIZAS IS
      SELECT RRA_TSA_AMPRO, RRA_TPO_TSA
        FROM RSGOS_RCBOS_AMPRO
       WHERE RRA_CDGO_AMPRO =P_AMPARO
         AND RRA_NMRO_ITEM = 0
         AND RRA_NMRO_PLZA = P_POLIZA
         AND RRA_CLSE_PLZA = P_CLASE
         AND RRA_RAM_CDGO = P_RAMO
         AND RRA_FCHA_MDFCCION =
             (SELECT MAX(RRA_FCHA_MDFCCION)
                FROM RSGOS_RCBOS_AMPRO
               WHERE RRA_CDGO_AMPRO = P_AMPARO
                 AND RRA_NMRO_ITEM = P_SOLICITUD
                 AND RRA_NMRO_PLZA = P_POLIZA
                 AND RRA_CLSE_PLZA = P_CLASE
                 AND RRA_RAM_CDGO = P_RAMO);
    CURSOR TASAS_RIESGO IS
      SELECT RRA_TSA_AMPRO,
             RRA_PRCNTJE_DDCBLE,
             RRA_TPO_TSA,
             RRA_VLOR_ASGRDO_FLTNTE
        FROM RSGOS_RCBOS_AMPRO
       WHERE RRA_CDGO_AMPRO = P_AMPARO
         AND RRA_NMRO_ITEM = P_SOLICITUD
         AND RRA_NMRO_PLZA = P_POLIZA
         AND RRA_CLSE_PLZA = P_CLASE
         AND RRA_RAM_CDGO = P_RAMO
         AND RRA_FCHA_MDFCCION =
             (SELECT MAX(RRA_FCHA_MDFCCION)
                FROM RSGOS_RCBOS_AMPRO
               WHERE RRA_CDGO_AMPRO = P_AMPARO
                 AND RRA_NMRO_ITEM = P_SOLICITUD
                 AND RRA_NMRO_PLZA = P_POLIZA
                 AND RRA_CLSE_PLZA = P_CLASE
                 AND RRA_RAM_CDGO = P_RAMO);

    DEDUCIBLE     NUMBER(4, 2) := 0;
    TASA_POLIZA   NUMBER(8, 5) := 0;
    TASA_RIESGO   NUMBER(8, 5) := 0;
    TIPO_POLIZA   VARCHAR2(1);
    TIPO_RIESGO   VARCHAR2(1);

  BEGIN
    OPEN TASAS;
    FETCH TASAS
      INTO TASA, TIPO_TASA, PORC_DESCUENTO, CUOTAS, INCLUYE_IVA;
    IF TASAS%NOTFOUND THEN
      MENSAJE := 'ERROR EN LA TASA DEL AMPARO BASICO.';
      RETURN;
    END IF;
    CLOSE TASAS;

    /*******************************************************************************
    **************/
    /* BUSCAR SI LA TASA DE LA POLIZA ES LA MISMA QUE LA TASA GLOBAL PARA CADA UNO
    DE LOS AMPAROS*/
    /*******************************************************************************
    **************/
    OPEN TASAS_POLIZAS;
    FETCH TASAS_POLIZAS
      INTO TASA_POLIZA, TIPO_POLIZA;
    IF TASAS_POLIZAS%NOTFOUND THEN
      NULL;
    END IF;
    CLOSE TASAS_POLIZAS;
    IF TASA_POLIZA != 0 THEN
      IF TASA_POLIZA != TASA THEN
        TASA := TASA_POLIZA;
      END IF;
    END IF;
    IF TIPO_POLIZA IS NOT NULL THEN
      IF TIPO_POLIZA != TIPO_TASA THEN
        TIPO_TASA := TIPO_POLIZA;
      END IF;
    END IF;

    /*******************************************************************************
    **************/
    /* BUSCAR SI LA TASA DEL RIESGO ES LA MISMA QUE LA TASA RESULTANTE DE LA
    COMPARACION CON LA  */
    /* POLIZA PARA CADA UNO DE LOS AMPAROS            */
    /*******************************************************************************
    **************/
    OPEN TASAS_RIESGO;
    FETCH TASAS_RIESGO
      INTO TASA_RIESGO, DEDUCIBLE, TIPO_RIESGO, VALOR_ASEGURADO;
    IF TASAS_RIESGO%NOTFOUND THEN
      NULL;
    END IF;
    CLOSE TASAS_RIESGO;
    IF TASA_RIESGO != 0 THEN
      IF TASA_RIESGO != TASA THEN
        TASA := TASA_RIESGO;
      END IF;
    END IF;

    IF TIPO_RIESGO IS NOT NULL THEN
      IF TIPO_RIESGO != TIPO_TASA THEN
        TIPO_TASA := TIPO_RIESGO;
      END IF;
    END IF;
  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 01/11/2012 03:33:30 p.m.
  -- PRC_VALIDAR_SEGURO
  -- Purpose : Procedimiento que valida que un concepto para una solicitud
  -- no este ingresado pues no se podría hacer el reingreso.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_VALIDAR_SEGURO(SOLICITUD NUMBER, CONCEPTO VARCHAR2) IS
    SOL NUMBER;
  BEGIN
    BEGIN
      SELECT RVA_NMRO_ITEM
        INTO SOL
        FROM RSGOS_VGNTES_AMPRO
       WHERE RVA_NMRO_ITEM = SOLICITUD
         AND RVA_CDGO_AMPRO = CONCEPTO;

       RAISE_APPLICATION_ERROR(-20501,'LA SOLICITUD SE ENCUENTRA ASEGURADA POR EL AMPARO Y EL CONCEPTO.  VERIFIQUE LA NOVEDAD');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

    END;

  END;

  --
  --
  --
  PROCEDURE FUN_LEVANTA_SUSPENSION(P_SOLICITUD  NUMBER) IS

  CURSOR C_DEUDAS IS
    SELECT *
      FROM DDAS_VGNTES_ARRNDMNTOS, AVSOS_SNSTROS
     WHERE DVA_NMRO_SLCTUD = P_SOLICITUD
       AND DVA_ESTDO = '01'
       AND SNA_NMRO_ITEM = DVA_NMRO_SLCTUD
       AND SNA_FCHA_SNSTRO = DVA_FCHA_MRA;

  R_DEUDAS      C_DEUDAS%ROWTYPE;

  BEGIN
    OPEN C_DEUDAS;
    LOOP
      FETCH C_DEUDAS INTO R_DEUDAS;
      IF C_DEUDAS%NOTFOUND THEN
        EXIT;
      END IF;

      BEGIN
        UPDATE SSPNSNES_SNSTROS SSN
           SET SSN.SSN_FCHA_LVNTE_SSPNSION = SYSDATE
         WHERE SSN.SSN_NMRO_SNSTRO =  R_DEUDAS.SNA_NMRO_SNSTRO
           AND SSN.SSN_CDGO_SSPNSION = '21'
           AND SSN.SSN_FCHA_ACTLZCION = (SELECT MAX(SS.SSN_FCHA_ACTLZCION)
                                           FROM SSPNSNES_SNSTROS SS
                                          WHERE SSN.SSN_NMRO_SNSTRO =  SS.SSN_NMRO_SNSTRO
                                            AND SSN.SSN_CDGO_SSPNSION = SS.SSN_CDGO_SSPNSION);
      EXCEPTION
         WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20507,'Error actualizando el levante de la suspensión.');
      END;
    END LOOP;
    CLOSE C_DEUDAS;

END;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 01/11/2012 03:33:30 p.m.
  -- PRC_REINGRESO_SEGURO
  -- Purpose : Procedimiento que reingresa un riesgo al seguor. Si se dal
  -- reingreso desde el amparo básico, se debe reingresar con todos los
  -- amparos con los que se retiro.
  -- Si el amparo es un adicional sólo reingresa el amparo adicional.
  -- El reingreso debe cobrar las primas retroactivas desde el período de
  -- la fecha del retiro hasta la fecha del período actual.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_REINGRESO_SEGURO(P_AMPARO              IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                        P_SOLICITUD         IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                        P_POLIZA            IN PLZAS.POL_NMRO_PLZA%TYPE,
                        P_CLASE             IN PLZAS.POL_CDGO_CLSE%TYPE,
                        P_RAMO              IN PLZAS.POL_RAM_CDGO%TYPE,
                        P_COMPANIA          IN PLZAS.POL_SUC_CIA_CDGO%TYPE,
                        P_SUCURSAL          IN PLZAS.POL_SUC_CDGO%TYPE,
                        P_DESTINO           IN SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                        P_CIUDAD            IN DIRECCIONES.DI_DIVPOL_CODIGO%TYPE,
                        P_NOVEDAD_REINGRESO IN VARCHAR2,
                        P_MODULO            IN MODULOS.MDL_CDGO%TYPE,
                        P_USUARIO           IN USRIOS.USR_CDGO_USRIO%TYPE,
                        P_PERIODO           IN VARCHAR2) IS

      CURSOR C_AMPAROS(AMPARO_REING VARCHAR2) IS
        SELECT A.APR_CDGO_AMPRO,A.APR_TPO_AMPRO
          FROM AMPROS_PRDCTO A
         WHERE A.APR_RAM_CDGO = P_RAMO
           AND A.APR_CDGO_AMPRO LIKE AMPARO_REING
         ORDER BY 1;

      CURSOR VALORES_ANTERIORES(AMPARO_CURSOR VARCHAR2) IS
        SELECT RAV_CNCPTO_VLOR, RAV_VLOR
          FROM RSGOS_RCBOS_AVLOR, VLRES_PRDCTO
         WHERE RAV_CDGO_AMPRO =AMPARO_CURSOR
           AND RAV_CDGO_AMPRO NOT IN ('02', '03')
           AND RAV_NMRO_ITEM = P_SOLICITUD
           AND RAV_NMRO_PLZA = P_POLIZA
           AND RAV_CLSE_PLZA = P_CLASE
           AND RAV_RAM_CDGO = P_RAMO
           AND VPR_RAM_CDGO = P_RAMO
           AND RAV_CNCPTO_VLOR = VPR_CDGO
           AND trunc(RAV_FCHA_MDFCCION) =
               (SELECT trunc(MAX(RAV_FCHA_MDFCCION))
                  FROM RSGOS_RCBOS_AVLOR
                 WHERE RAV_CDGO_AMPRO = AMPARO_CURSOR
                   AND RAV_CDGO_AMPRO NOT IN ('02', '03')
                   AND RAV_NMRO_ITEM = P_SOLICITUD
                   AND RAV_NMRO_PLZA = P_POLIZA
                   AND RAV_CLSE_PLZA = P_CLASE
                   AND RAV_RAM_CDGO = P_RAMO);

      RECHAZO         VARCHAR2(3);
      DESCRIPCION     VARCHAR2(1000);
      MENSAJE         VARCHAR2(2000) := NULL;
      CERTIFICADO     NUMBER(10);
      ENTRO           NUMBER;
      TIPO            VARCHAR2(1);
      TASA            NUMBER(5, 2);
      TIPO_TASA       VARCHAR2(1);
      VALOR_ASEGURADO NUMBER(18, 2);
      INCLUYE_IVA     VARCHAR2(1);
      CUOTAS          NUMBER(4);
      PORC_DESCUENTO  NUMBER(5, 2);
      V_MENSAJE_INF   VARCHAR2(500);
      V_ASEGURADO     NUMBER;
      R_AMP           C_AMPAROS%ROWTYPE;
      V_FECHA_NOVEDAD DATE;
      CONCEPTO        RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE;
      VALOR           NUMBER;
      AMPARO_REING    VARCHAR2(10);


    BEGIN

       V_FECHA_NOVEDAD := FUN_TRAER_FECHA(P_POLIZA,P_RAMO,P_CLASE,P_NOVEDAD_REINGRESO,MENSAJE);
       IF MENSAJE IS NOT NULL THEN
         RAISE_APPLICATION_ERROR(-20501,MENSAJE);
       END IF;


      IF P_AMPARO = '01' THEN
         AMPARO_REING:= '%';
      ELSE
         AMPARO_REING:= P_AMPARO;
      END IF;

        open C_AMPAROS(AMPARO_REING);

        LOOP
          fetch C_AMPAROS
            into R_AMP;
          exit when C_AMPAROS%notfound;

          OPEN VALORES_ANTERIORES(R_AMP.APR_CDGO_AMPRO);
          ENTRO := 0;
          LOOP
            FETCH VALORES_ANTERIORES
              INTO CONCEPTO, VALOR;
            IF VALORES_ANTERIORES%NOTFOUND THEN
              EXIT;
            ELSE
              /* TRAE LA TASA Y EL TIPO DE TASA DEL RIESGO RETIRADO */
                PRC_BUSCAR_TASA_REINGRESO(R_AMP.APR_CDGO_AMPRO,
                                      P_RAMO,
                                      P_CLASE,
                                      P_SUCURSAL,
                                      P_COMPANIA,
                                      P_POLIZA,
                                      P_SOLICITUD,
                                      TASA,
                                      TIPO_TASA,
                                      PORC_DESCUENTO,
                                      VALOR_ASEGURADO,
                                      CUOTAS,
                                      INCLUYE_IVA,
                                      MENSAJE);

              IF MENSAJE IS NOT NULL THEN
                RAISE_APPLICATION_ERROR(-20501,MENSAJE);
              END IF;

              --IF CONCEPTO <> '02' THEN   MANTIS 14280 13/03/2013. FALLA CUANDO LOS AMPAROS TIENEN MAS DE UN CONCEPTO NO SOLO BASICO.
              IF ENTRO = 0 THEN
                 --PRC_VALIDAR_SEGURO(P_SOLICITUD, CONCEPTO);  MANTIS 14280 DAP-SPP 13/03/2013 SE COMPARA EL AMPARO NO EL CONCEPTO.
                 PRC_VALIDAR_SEGURO(P_SOLICITUD, R_AMP.APR_CDGO_AMPRO);
              END IF;

              IF ENTRO = 0 THEN
                PKG_OPERACION.PRC_VALIDA_MANUAL('N',
                                                P_NOVEDAD_REINGRESO,
                                                P_SOLICITUD,
                                                P_POLIZA,
                                                P_CLASE,
                                                P_RAMO,
                                                R_AMP.APR_CDGO_AMPRO,
                                                V_FECHA_NOVEDAD,
                                                CERTIFICADO,
                                                CONCEPTO,
                                                VALOR,
                                                P_COMPANIA,
                                                P_SUCURSAL,
                                                R_AMP.APR_TPO_AMPRO,
                                                RECHAZO,
                                                MENSAJE,
                                                P_MODULO,
                                                P_USUARIO,
                                                V_MENSAJE_INF,
                                                V_ASEGURADO,
                                                'N',
                                                P_DESTINO,
                                                P_CIUDAD,'S',NULL,NULL);
              END IF;

              IF RECHAZO IS NOT NULL THEN
                BEGIN
                  SELECT RCN_TPO_CDGO, RCN_DSCRPCION
                    INTO TIPO, DESCRIPCION
                    FROM RCHZOS_NVDDES
                   WHERE RCN_CDGO = RECHAZO
                     AND RCN_RAM_CDGO = P_RAMO;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20503,'El código arrojado como error no existe. Consulte al administrador del sistema.');
                END;

                 IF TIPO = 'E' THEN
                   RAISE_APPLICATION_ERROR(-20504,'No se puede realizar el reingreso al seguro. ' || DESCRIPCION);
                   MENSAJE := 'ERROR';
                 END IF;

               END IF;

                    PKG_OPERACION.PRC_NOVEDADES(P_SOLICITUD,
                                                P_POLIZA,
                                                P_CLASE,
                                                P_RAMO,
                                                P_SUCURSAL,
                                                P_COMPANIA,
                                                V_FECHA_NOVEDAD,
                                                R_AMP.APR_CDGO_AMPRO,
                                                CONCEPTO,
                                                0,
                                                CERTIFICADO,
                                                VALOR,
                                                --P_NOVEDAD_INGRESO,
                                               P_NOVEDAD_REINGRESO,
                                                ENTRO,
                                                P_MODULO,
                                                MENSAJE,
                                                P_USUARIO,
                                                'NO',
                                                'SI',
                                                P_PERIODO,
                                                TIPO_TASA,
                                                TASA,
                                                'N');
                      IF MENSAJE IS NOT NULL THEN
                        RAISE_APPLICATION_ERROR(-20501, MENSAJE);
                        EXIT;
                      END IF;

                      PRC_COPIAR_NOVEDADES(P_SOLICITUD,
                                       P_POLIZA,
                                       P_CLASE,
                                       P_RAMO,
                                       R_AMP.APR_CDGO_AMPRO,
                                       CERTIFICADO,
                                       MENSAJE);

                      IF MENSAJE IS NOT NULL THEN
                         RAISE_APPLICATION_ERROR(-20501,MENSAJE);
                         EXIT;
                      END IF;


                      IF ENTRO = 0 THEN
                        insertar_auditoria('RSGOS_VGNTES_NVDDES',
                                           to_char(sysdate),
                                           R_AMP.APR_CDGO_AMPRO,
                                           P_RAMO,
                                           TO_CHAR(P_SOLICITUD),
                                           TO_CHAR(P_POLIZA),
                                           P_NOVEDAD_REINGRESO,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           'RIVN_VLOR_DFRNCIA',
                                           TO_CHAR(0),
                                           TO_CHAR(VALOR),
                                           P_MODULO,
                                           P_USUARIO,
                                           SYSDATE,
                                           'Reingreso al seguro',
                                           MENSAJE);
                      END IF;
                      ENTRO   := 1;
                      RECHAZO := NULL;
           END IF;
          END LOOP;
          CLOSE VALORES_ANTERIORES;


          IF R_AMP.APR_CDGO_AMPRO = '01' THEN
             PRC_REINGRESA_CONTRATO(P_SOLICITUD);
          END IF;

          /* COBRA LAS PRIMAS DESDE LA FECHA DE RETIRO HASTA EL MES ANTERIOR DEL SIGUIENTE COBRO.*/
          /* ESTE CASO SOLAMENTE PARA LOS RIESGOS CUYO TIPO DE TASA SEA DIFERENTE A LA MENSUAL   */



      /*    COBRO_REINGRESO(R_AMP.APR_CDGO_AMPRO,
                          P_SOLICITUD,
                          P_POLIZA,
                          P_CLASE,
                          P_RAMO,
                          P_COMPANIA,
                          P_SUCURSAL,
                          TIPO_TASA,
                          TASA,
                          VALOR_ASEGURADO,
                          INCLUYE_IVA,
                          PORC_DESCUENTO,
                          V_FECHA_NOVEDAD,
                          CERTIFICADO,
                          P_PERIODO,
                          MENSAJE,
                          P_USUARIO);
          IF MENSAJE IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20501,MENSAJE);
          END IF;
        */
        END LOOP;
        CLOSE C_AMPAROS;

        /*Se debe incluir el procedimiento que reactiva los pagos de siniestros de los vigentes. */
        BEGIN
         --mantis # 25000 para activar el pago
          PKG_LIQUIDACION_ORDEN_PAGO.PRC_ACTIVA_COBERTURA(P_SOLICITUD,
                                                          P_COMPANIA,
                                                          P_SUCURSAL,
                                                          P_USUARIO);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20501, 'Error en ativar la cobertura ..' || sqlerrm);
        END;

        -- Mantis #12778 para el caso hubo Reingreso al seguro y no se levanto la suspensión . GGM. 17/01/2013

        FUN_LEVANTA_SUSPENSION(P_SOLICITUD);


        IF MENSAJE IS NULL THEN
          COMMIT;
        END IF;

    END;

    -- PROCESO DE BORRADO DE NOVEDADES CREADO POR DAVID AGUIRRE
    -- SE PASO LOS PROCEDIMIENTOS DEL PAQUETE PKG_REVERSION_NOVEDADES QUE EL CREO

    FUNCTION VALIDAR_NOVEDAD_CUOTA(SOLICITUD NUMBER,
                                   FECHA_NOVEDAD DATE,
                                   AMPARO VARCHAR2,
                                   CERTIFICADO NUMBER,
                                   POLIZA NUMBER,
                                   CLASE VARCHAR2,
                                   RAMO VARCHAR2,
                                   NOVEDAD VARCHAR2) RETURN VARCHAR2 IS
   FECHA DATE;
  BEGIN
  -- SE ELIMINA ESTO PORQUE EL INGRESO DE SOLO CUOTA DE ADMON GUARDABA EN ESTA TABLA
  -- PARA SABER QUE SE HIZÓ ESTA NOVEDAD. COMO SE CAMBIÓ LA FORMA DE NOVEDADES Y AHORA INGRESA
  -- PARA EL NORMAL. SOLO SE PUEDE VALIDAR CON LAS DOS NOVEDADES DE INGRESO.
/* SELECT NVC_FCHA_NVDAD
  INTO FECHA
  FROM NVDDES_CTA
 WHERE NVC_CDGO_AMPRO         = AMPARO
   AND NVC_NMRO_ITEM          = SOLICITUD
   AND NVC_NMRO_PLZA          = POLIZA
   AND NVC_CLSE_PLZA          = CLASE
   AND NVC_RAM_CDGO           = RAMO
   AND NVC_TPO_NVDAD          = NOVEDAD
   AND NVC_FCHA_NVDAD         = FECHA_NOVEDAD
   AND NVC_NMRO_CRTFCDO       = CERTIFICADO;*/

   SELECT RIVN_FCHA_NVDAD
     INTO FECHA
     FROM RSGOS_VGNTES_NVDDES
    WHERE RIVN_NMRO_ITEM = SOLICITUD
      AND RIVN_NMRO_PLZA = POLIZA
      AND RIVN_CLSE_PLZA = CLASE
      AND RIVN_CDGO_AMPRO = AMPARO
      AND RIVN_TPO_NVDAD = '01';

     RETURN('N');

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN('N');
 WHEN TOO_MANY_ROWS THEN
   RETURN('S');
END;

Procedure BORRAR_DEV_PRIMAS(SOLICITUD     NUMBER,
                            POLIZA        NUMBER,
                            SUCURSAL      VARCHAR2,
                            COMPANIA VARCHAR2,
                            FECHA_NOVEDAD DATE,
                            CLASE_POLIZA  VARCHAR2,
                            RAMO          VARCHAR2,
                            DEVOLUCION    NUMBER,
                            MENSAJE IN OUT   VARCHAR2,
                            USUARIO       VARCHAR2,
                            NOVEDAD       VARCHAR2,
                            AMPARO       VARCHAR2,
                            PERIODO       VARCHAR2)
IS
 CERTIFICADO NUMBER;
 incluye varchar2(1);
 PRIMA_NETA NUMBER(18,2);
 PRIMA_TOTAL NUMBER(18,2);
 IVA_PRIMA NUMBER(18,2);
 IVA NUMBER;
 FECHA DATE;
Begin

-- LIQUIDAR LA DEVOLUCION SEGUN SI INCLUYE IVA O NO LA TARIFA DEL AMPARO

  Begin
      Select TAP_INCLYE_IVA into incluye
        from  TRFA_AMPROS_PRDCTO
       where  TAP_CDGO_AMPRO     = AMPARO
         and  TAP_RAM_CDGO       = RAMO
         and  TAP_SUC_CDGO       = SUCURSAL
         and  TAP_CIA_CDGO       = COMPANIA;
      Exception When no_data_found then
          mensaje := 'No se puede conocer si la tarifa del amparo incluye iva o no.';
  End;

 -- Trae el porcentaje de IVA definido
    BEGIN
     SELECT PAR_VLOR2 INTO IVA
       FROM PRMTROS
      WHERE PAR_CDGO = '4'
        AND PAR_MDLO = '6'
        AND PAR_VLOR1= '01'
        AND PAR_FCHA_CREACION = (SELECT MAX(PAR_FCHA_CREACION) FROM PRMTROS
                  WHERE PAR_VLOR1='01'
                                AND PAR_MDLO='6'
                   AND PAR_CDGO='4');
     EXCEPTION WHEN NO_DATA_FOUND THEN
       MENSAJE:='ERROR EN LA BUSQUEDA DEL IVA';
       ROLLBACK;
       RETURN;
     WHEN OTHERS THEN
       MENSAJE:='ERROR EN LA BUSQUEDA DEL IVA';
       ROLLBACK;
       RETURN;
    END;

   IF INCLUYE = 'N' THEN
      PRIMA_NETA  := DEVOLUCION;
      IVA_PRIMA   := (DEVOLUCION * IVA ) / 100;
      PRIMA_TOTAL := DEVOLUCION + IVA_PRIMA;
    ELSE
      PRIMA_NETA  := DEVOLUCION;
      IVA_PRIMA   := PRIMA_NETA * (IVA /100);
      PRIMA_TOTAL := DEVOLUCION + IVA_PRIMA;
    END IF;


BUSCAR_CERTIFICADO(POLIZA, CLASE_POLIZA, RAMO, CERTIFICADO);

 Update Crtfcdos
        set cer_vlor_prma_nta=cer_vlor_prma_nta + PRIMA_NETA,
            cer_vlor_prma_ttal=cer_vlor_prma_ttal + PRIMA_TOTAL,
            cer_vlor_iva=cer_vlor_iva + IVA_PRIMA
 where cer_nmro_crtfcdo = CERTIFICADO
 AND   cer_nmro_plza=POLIZA
 and   cer_clse_plza=CLASE_POLIZA
 and   cer_ram_cdgo=RAMO;
 If sql%notfound Then
    MENSAJE:='ERROR ACTUALIZACION DE LA DEVOLUCION';
    return;
 End If;


/* INSERTA LA NOVEDAD DE DEVOLUCION DE PRIMAS*/
  Begin
   delete Rsgos_Vgntes_Nvddes
    where rivn_nmro_item  = SOLICITUD
      and rivn_nmro_plza  = POLIZA
      and rivn_clse_plza  = CLASE_POLIZA
      and rivn_ram_cdgo   = RAMO
      and rivn_cdgo_ampro = AMPARO
      and rivn_tpo_nvdad  = NOVEDAD
      and to_char(rivn_fcha_nvdad,'mmyyyy') = PERIODO;
    If sql%notfound Then
       mensaje:='ERROR BORRANDO NOVEDADES';
       return;
    End If;
  End;
End BORRAR_DEV_PRIMAS;


PROCEDURE BORRAR_HISTORICOS (NOVEDAD VARCHAR2,
                            SOLICITUD NUMBER,
                            POLIZA NUMBER,
                            CLASE_POLIZA VARCHAR2,
                            RAMO VARCHAR2,
                            CONCEPTO VARCHAR2,
                            AMPARO VARCHAR2,
                            CERTIFICADO NUMBER,
          NOVEDAD_REVERSO  VARCHAR2)
IS
 NOVEDAD_RETIRO         VARCHAR2(2):= '02';
 NOVEDAD_REINGRESO      VARCHAR2(2):='05';
 CONTADOR        NUMBER:= 0;
BEGIN

  IF NOVEDAD = NOVEDAD_RETIRO AND  NOVEDAD_REVERSO != NOVEDAD_REINGRESO THEN
    DELETE FROM RSGOS_RCBOS_NVLOR
    WHERE RNV_CDGO_AMPRO = AMPARO
    AND   RNV_NMRO_ITEM =  SOLICITUD
    AND   RNV_NMRO_PLZA  = POLIZA
    AND   RNV_CLSE_PLZA  = CLASE_POLIZA
    AND   RNV_RAM_CDGO    = RAMO
--    AND   RNV_CNCPTO_VLOR = CONCEPTO
    AND   RNV_NMRO_CRTFCDO = CERTIFICADO;

    DELETE FROM RSGOS_RCBO_VLOR
    WHERE RHV_NMRO_CRTFCDO = CERTIFICADO
      AND RHV_NMRO_ITEM   =  SOLICITUD
      AND RHV_NMRO_PLZA    = POLIZA
      AND RHV_RAM_CDGO    = RAMO
      AND RHV_CDGO_AMPRO  = AMPARO
      AND RHV_CLSE_PLZA    = CLASE_POLIZA;
--    AND   RHV_CNCPTO_VLOR = CONCEPTO;
   BEGIN
    SELECT COUNT (8) INTO CONTADOR
    FROM RSGOS_RCBOS_NVLOR
    WHERE RNV_CDGO_AMPRO = AMPARO
    AND   RNV_NMRO_ITEM =  SOLICITUD
    AND   RNV_NMRO_PLZA  = POLIZA
    AND   RNV_CLSE_PLZA  = CLASE_POLIZA
    AND   RNV_RAM_CDGO    = RAMO
    AND   RNV_NMRO_CRTFCDO = CERTIFICADO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       CONTADOR :=0;
  END;
--    IF CONTADOR = 0 THEN
       DELETE FROM RSGOS_RCBOS_NVDAD
       WHERE REN_CDGO_AMPRO = AMPARO
       AND   REN_NMRO_ITEM   = SOLICITUD
       AND   REN_NMRO_PLZA  = POLIZA
       AND   REN_CLSE_PLZA  = CLASE_POLIZA
       AND   REN_RAM_CDGO  = RAMO
       AND   REN_NMRO_CRTFCDO = CERTIFICADO;
--       AND   REN_TPO_NVDAD    = NOVEDAD;
       DELETE FROM RSGOS_RCBOS_AVLOR
       WHERE RAV_CDGO_AMPRO  = AMPARO
       AND   RAV_NMRO_ITEM   =  SOLICITUD
       AND   RAV_NMRO_PLZA    = POLIZA
       AND   RAV_CLSE_PLZA    = CLASE_POLIZA
       AND   RAV_RAM_CDGO    = RAMO
--       AND  RAV_CNCPTO_VLOR = CONCEPTO
       AND  RAV_NMRO_CRTFCDO  = CERTIFICADO;
       DELETE  FROM RSGOS_RCBOS_AMPRO
       WHERE RRA_CDGO_AMPRO  = AMPARO
       AND   RRA_NMRO_ITEM   = SOLICITUD
       AND   RRA_NMRO_PLZA  = POLIZA
       AND   RRA_CLSE_PLZA  = CLASE_POLIZA
       AND   RRA_RAM_CDGO    = RAMO
       AND   RRA_NMRO_CRTFCDO = CERTIFICADO;
  BEGIN
    SELECT COUNT(8)INTO CONTADOR
    FROM RSGOS_RCBOS_AMPRO
    WHERE   RRA_NMRO_ITEM   = SOLICITUD
    AND   RRA_NMRO_PLZA  = POLIZA
    AND   RRA_CLSE_PLZA  = CLASE_POLIZA
    AND   RRA_RAM_CDGO    = RAMO
    AND   RRA_NMRO_CRTFCDO = CERTIFICADO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       CONTADOR :=0;
  END;
    IF CONTADOR = 0 THEN
       DELETE FROM RSGOS_RCBO_VLOR
        WHERE RHV_NMRO_CRTFCDO = CERTIFICADO
          AND RHV_NMRO_ITEM   =  SOLICITUD
          AND RHV_NMRO_PLZA    = POLIZA
          AND RHV_RAM_CDGO    = RAMO
          AND RHV_CLSE_PLZA    = CLASE_POLIZA;

       DELETE FROM RSGOS_RCBOS_NITS
       WHERE   RRN_NMRO_PLZA  = POLIZA
       AND     RRN_NMRO_ITEM  =  SOLICITUD
       AND     RRN_CLSE_PLZA  = CLASE_POLIZA
       AND     RRN_RAM_CDGO    = RAMO
       AND     RRN_NMRO_CRTFCDO = CERTIFICADO;

       DELETE  FROM RSGOS_RCBOS
       WHERE   RIR_NMRO_ITEM    = SOLICITUD
       AND   RIR_NMRO_CRTFCDO = CERTIFICADO
       AND   RIR_NMRO_PLZA  = POLIZA
       AND   RIR_CLSE_PLZA  = CLASE_POLIZA
       AND   RIR_RAM_CDGO    = RAMO;
    END IF;
   END IF;

   -- SE INCLUYE PARA LOS REINGRESOS QUE BORRE LAS CUOTAS DE AMPAROS ADICIONALES
   -- QUE SE INCLUYERON. SPPC. 27/03/2014. MANTIS # 20111.
   IF NOVEDAD_REVERSO != NOVEDAD_REINGRESO THEN
     DELETE RSGOS_RCBOS_NVDAD  R
     WHERE   REN_NMRO_ITEM   = SOLICITUD
       AND   REN_NMRO_PLZA  = POLIZA
       AND   REN_CLSE_PLZA  = CLASE_POLIZA
       AND   REN_RAM_CDGO  = RAMO
       AND   REN_CDGO_AMPRO = AMPARO
       AND   REN_NMRO_CRTFCDO = CERTIFICADO
       AND REN_TPO_NVDAD = '11';
   END IF;
END BORRAR_HISTORICOS;


PROCEDURE BORRAR_HISTORICOS_POR_RETIRO (NOVEDAD VARCHAR2,
                            SOLICITUD NUMBER,
                            POLIZA NUMBER,
                            CLASE_POLIZA VARCHAR2,
                            RAMO VARCHAR2,
                            CONCEPTO VARCHAR2,
                            AMPARO VARCHAR2,
                            CERTIFICADO NUMBER,
          NOVEDAD_REVERSO  VARCHAR2)
IS
 NOVEDAD_RETIRO         VARCHAR2(2):= '02';
 NOVEDAD_REINGRESO      VARCHAR2(2):='05';
 CONTADOR        NUMBER:= 0;
BEGIN

    DELETE FROM RSGOS_RCBOS_NVLOR
    WHERE RNV_CDGO_AMPRO = AMPARO
    AND   RNV_NMRO_ITEM =  SOLICITUD
    AND   RNV_NMRO_PLZA  = POLIZA
    AND   RNV_CLSE_PLZA  = CLASE_POLIZA
    AND   RNV_RAM_CDGO    = RAMO
    AND   RNV_NMRO_CRTFCDO = CERTIFICADO;

    DELETE FROM RSGOS_RCBO_VLOR
    WHERE   RHV_NMRO_ITEM   =  SOLICITUD
    AND   RHV_NMRO_PLZA    = POLIZA
    AND   RHV_CLSE_PLZA    = CLASE_POLIZA
    AND   RHV_RAM_CDGO    = RAMO
    AND   RHV_CDGO_AMPRO =  AMPARO
    AND   RHV_NMRO_CRTFCDO = CERTIFICADO;

    DELETE FROM RSGOS_RCBOS_NVDAD
      WHERE  REN_CDGO_AMPRO = AMPARO
       AND   REN_NMRO_ITEM   = SOLICITUD
       AND   REN_NMRO_PLZA  = POLIZA
       AND   REN_CLSE_PLZA  = CLASE_POLIZA
       AND   REN_RAM_CDGO  = RAMO
       AND   REN_NMRO_CRTFCDO = CERTIFICADO;

       DELETE FROM RSGOS_RCBOS_AVLOR
       WHERE  RAV_CDGO_AMPRO  = AMPARO
       AND    RAV_NMRO_ITEM   =  SOLICITUD
       AND   RAV_NMRO_PLZA    = POLIZA
       AND   RAV_CLSE_PLZA    = CLASE_POLIZA
       AND   RAV_RAM_CDGO    = RAMO
       AND  RAV_NMRO_CRTFCDO  = CERTIFICADO;

       DELETE  FROM RSGOS_RCBOS_AMPRO
       WHERE RRA_CDGO_AMPRO  = AMPARO
       AND   RRA_NMRO_ITEM   = SOLICITUD
       AND   RRA_NMRO_PLZA  = POLIZA
       AND   RRA_CLSE_PLZA  = CLASE_POLIZA
       AND   RRA_RAM_CDGO    = RAMO
       AND   RRA_NMRO_CRTFCDO = CERTIFICADO;

  BEGIN
    SELECT COUNT(8)INTO CONTADOR
    FROM RSGOS_RCBOS_AMPRO
    WHERE   RRA_NMRO_ITEM   = SOLICITUD
    AND   RRA_NMRO_PLZA  = POLIZA
    AND   RRA_CLSE_PLZA  = CLASE_POLIZA
    AND   RRA_RAM_CDGO    = RAMO
    AND   RRA_NMRO_CRTFCDO = CERTIFICADO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       CONTADOR :=0;
  END;
    IF CONTADOR = 0 THEN
       DELETE FROM RSGOS_RCBO_VLOR
       WHERE   RHV_NMRO_ITEM   =  SOLICITUD
       AND   RHV_NMRO_PLZA    = POLIZA
       AND   RHV_CLSE_PLZA    = CLASE_POLIZA
       AND   RHV_RAM_CDGO    = RAMO
       AND   RHV_NMRO_CRTFCDO     = CERTIFICADO;

       DELETE FROM RSGOS_RCBOS_NITS
       WHERE   RRN_NMRO_PLZA  = POLIZA
       AND     RRN_NMRO_ITEM  =  SOLICITUD
       AND     RRN_CLSE_PLZA  = CLASE_POLIZA
       AND     RRN_RAM_CDGO    = RAMO
       AND     RRN_NMRO_CRTFCDO = CERTIFICADO;

       DELETE  FROM RSGOS_RCBOS
       WHERE   RIR_NMRO_ITEM    = SOLICITUD
       AND   RIR_NMRO_CRTFCDO = CERTIFICADO
       AND   RIR_NMRO_PLZA  = POLIZA
       AND   RIR_CLSE_PLZA  = CLASE_POLIZA
       AND   RIR_RAM_CDGO    = RAMO;

    END IF;


END BORRAR_HISTORICOS_POR_RETIRO;


PROCEDURE BORRAR_SUSPENSION_PAGOS_RETIRO(
  RAMO IN VARCHAR2 ,
  SOLICITUD IN NUMBER,
  AMPARO   IN VARCHAR2,
  MENSAJE IN OUT VARCHAR2 ,
  MODULO  VARCHAR2 ,
  USUARIO  VARCHAR2 )
IS

 CURSOR SINIESTROS IS
  SELECT SNA_NMRO_SNSTRO,SNA_FCHA_SNSTRO,SNA_ESTDO_SNSTRO
    FROM AVSOS_SNSTROS,AMPROS_SNSTROS
   WHERE SNA_NMRO_ITEM = SOLICITUD
     AND SNA_ESTDO_SNSTRO IN ('01','02','05','07','08')
     AND AMS_CDGO_AMPRO  = AMPARO
     AND AMS_RAM_CDGO    = RAMO
     AND AMS_NMRO_SNSTRO = SNA_NMRO_SNSTRO
     AND AMS_FCHA_MRA    = SNA_FCHA_SNSTRO;

  MENSAJE1 VARCHAR2(50);
  SINIESTRO AVSOS_SNSTROS.SNA_NMRO_SNSTRO%TYPE;
  FECHA_MORA AVSOS_SNSTROS.SNA_FCHA_SNSTRO%TYPE;
  ESTADO AVSOS_SNSTROS.SNA_ESTDO_SNSTRO%TYPE;

  BEGIN
   OPEN SINIESTROS;
   LOOP
    FETCH SINIESTROS INTO SINIESTRO,FECHA_MORA,ESTADO;
    IF SINIESTROS%NOTFOUND THEN
      EXIT;
    ELSE
     IF ESTADO = '02' THEN
       BEGIN
        UPDATE AVSOS_SNSTROS
           SET SNA_ESTDO_PGO    = '01'
         WHERE SNA_RAM_CDGO     = RAMO
           AND SNA_NMRO_ITEM    = SOLICITUD
           AND SNA_FCHA_SNSTRO  = FECHA_MORA;
      EXCEPTION
         WHEN OTHERS THEN
           MENSAJE := 'ERROR ACTUALIZANDO SINIESTRO';
      END;
     ELSIF ESTADO = '01' THEN
       BEGIN
        UPDATE AVSOS_SNSTROS
           SET SNA_ESTDO_PGO    = '00'
         WHERE SNA_RAM_CDGO     = RAMO
           AND SNA_NMRO_ITEM    = SOLICITUD
           AND SNA_FCHA_SNSTRO  = FECHA_MORA;
      EXCEPTION
         WHEN OTHERS THEN
           MENSAJE := 'ERROR ACTUALIZANDO SINIESTRO';
      END;
     END IF;
     BEGIN
       DELETE SSPNSNES_SNSTROS
        WHERE SSN_NMRO_SNSTRO   = SINIESTRO
          AND SSN_RAM_CDGO      = RAMO
          AND SSN_CDGO_AMPRO    = AMPARO
          AND SSN_CDGO_SSPNSION = '21';
     EXCEPTION
       WHEN OTHERS THEN
         MENSAJE :='ERROR EN SSPNSNES_SNSTROS ';
     END;
   END IF;
 END LOOP;
 CLOSE SINIESTROS;
END BORRAR_SUSPENSION_PAGOS_RETIRO;

PROCEDURE BORRAR_NOVEDAD (FECHA_NOVEDAD DATE,
                            NOVEDAD VARCHAR2,
                           SOLICITUD NUMBER,
                            POLIZA NUMBER,
                            CLASE_POLIZA VARCHAR2,
                            RAMO VARCHAR2,
                            AMPARO VARCHAR2)
IS
   CURSOR RSGOS_AMP IS
    SELECT RVL_CNCPTO_VLOR, RVL_VLOR
    FROM RSGOS_VGNTES_AVLOR
    WHERE RVL_NMRO_ITEM = SOLICITUD
      AND RVL_CDGO_AMPRO = AMPARO;

  valor_aumento    number(18,2);
  CONCEPTO         VARCHAR2(4);
  valor_nvlor      number(18,2);
  valor_aumento1   number(18,2);

BEGIN
  -- DAP. 20/11/2012 MANTIS 11118
  begin
                  select RIVN_VLOR_DFRNCIA
                   INTO valor_aumento
                  from RSGOS_VGNTES_NVDDES
               WHERE RIVN_NMRO_ITEM  = SOLICITUD
                  AND RIVN_NMRO_PLZA  = POLIZA
                 AND RIVN_CLSE_PLZA  = CLASE_POLIZA
                AND RIVN_RAM_CDGO   = RAMO
                AND RIVN_CDGO_AMPRO = AMPARO
                AND RIVN_TPO_NVDAD  = '04'
                AND TRUNC(RIVN_FCHA_NVDAD) = FECHA_NOVEDAD;
  EXCEPTION WHEN OTHERS THEN
                  valor_aumento := 0;
 end;
  if valor_aumento is null then
                 valor_aumento := 0;
  end if;
   begin
      SELECT SUM(RVNV_VLOR) INTO valor_nvlor
      FROM RSGOS_VGNTES_NVLOR
      WHERE RVNV_NMRO_ITEM  = SOLICITUD
        AND RVNV_NMRO_PLZA  = POLIZA
        AND RVNV_CLSE_PLZA  = CLASE_POLIZA
        AND RVNV_RAM_CDGO   = RAMO
        AND RVNV_CDGO_AMPRO = AMPARO
        AND TRUNC(RVNV_FCHA_NVDAD) = FECHA_NOVEDAD;
    EXCEPTION WHEN OTHERS THEN
                  valor_nvlor := 0;
   end;
  if valor_aumento = valor_nvlor then
    begin
     DELETE RSGOS_VGNTES_NVLOR
      WHERE RVNV_NMRO_ITEM  = SOLICITUD
        AND RVNV_NMRO_PLZA  = POLIZA
        AND RVNV_CLSE_PLZA  = CLASE_POLIZA
        AND RVNV_RAM_CDGO   = RAMO
        AND RVNV_CDGO_AMPRO = AMPARO
        AND TRUNC(RVNV_FCHA_NVDAD) = FECHA_NOVEDAD;
     if sql%notfound then
                  null;
     end if;
    end;
  else
                 open RSGOS_AMP;
                 loop  fetch RSGOS_AMP INTO CONCEPTO, valor_aumento1;
                                 exit when RSGOS_AMP%NOTFOUND;
        begin
                    update RSGOS_VGNTES_NVLOR set rvnv_vlor = valor_aumento1
           WHERE RVNV_NMRO_ITEM  = SOLICITUD
            AND RVNV_NMRO_PLZA  = POLIZA
            AND RVNV_CLSE_PLZA  = CLASE_POLIZA
            AND RVNV_RAM_CDGO   = RAMO
            AND RVNV_CDGO_AMPRO = AMPARO
            AND RVNV_CNCPTO_VLOR = CONCEPTO
            AND TRUNC(RVNV_FCHA_NVDAD) = FECHA_NOVEDAD;
        exception when others then
                  null;
                  end;

                 end loop;

  end if;
  BEGIN
     DELETE RSGOS_VGNTES_NVDDES
      WHERE RIVN_NMRO_ITEM  = SOLICITUD
        AND RIVN_NMRO_PLZA  = POLIZA
        AND RIVN_CLSE_PLZA  = CLASE_POLIZA
        AND RIVN_RAM_CDGO   = RAMO
        AND RIVN_CDGO_AMPRO = AMPARO
        AND RIVN_TPO_NVDAD  = '04'
        AND TRUNC(RIVN_FCHA_NVDAD) = FECHA_NOVEDAD;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20904, 'Error borrando registros de NOVEDADES de AUMENTO.'||SQLERRM);
  END;

END;


PROCEDURE BORRAR_REGISTROS (NOVEDAD VARCHAR2,
                            P_SOLICITUD NUMBER,
                            POLIZA NUMBER,
                            CLASE_POLIZA VARCHAR2,
                            RAMO VARCHAR2,
                            CONCEPTO VARCHAR2,
                            AMPARO VARCHAR2)
IS
 NOVEDAD_RETIRO         VARCHAR2(2):= '02';
 NOVEDAD_REINGRESO      VARCHAR2(2):='05';
 CONTADOR        NUMBER:= 0;
BEGIN
  BEGIN
  IF NOVEDAD = NOVEDAD_RETIRO THEN
    DELETE FROM RSGOS_VGNTES_NVLOR
    WHERE  RVNV_NMRO_ITEM =  P_SOLICITUD
    AND   RVNV_NMRO_PLZA  = POLIZA
    AND   RVNV_CLSE_PLZA  = CLASE_POLIZA
    AND   RVNV_RAM_CDGO    = RAMO
    AND   RVNV_CDGO_AMPRO = AMPARO
    AND   RVNV_CNCPTO_VLOR = CONCEPTO;
    DELETE FROM RSGOS_VGNTES_VLRES
    WHERE   RVV_NMRO_ITEM   =  P_SOLICITUD
    AND   RVV_NMRO_PLZA    = POLIZA
    AND   RVV_CLSE_PLZA    = CLASE_POLIZA
    AND   RVV_RAM_CDGO    = RAMO
    AND   RVV_CNCPTO_VLOR = CONCEPTO;
    DELETE FROM RSGOS_VGNTES_AVLOR
     WHERE   RVL_CDGO_AMPRO       = AMPARO
       AND   RVL_NMRO_ITEM        =  P_SOLICITUD
       AND   RVL_NMRO_PLZA    = POLIZA
       AND   RVL_CLSE_PLZA    = CLASE_POLIZA
       AND   RVL_RAM_CDGO    = RAMO
       AND   RVL_CNCPTO_VLOR      = CONCEPTO;

   BEGIN
    SELECT COUNT (8) INTO CONTADOR
    FROM RSGOS_VGNTES_NVLOR
    WHERE  RVNV_NMRO_ITEM =  P_SOLICITUD
    AND   RVNV_NMRO_PLZA  = POLIZA
    AND   RVNV_CLSE_PLZA  = CLASE_POLIZA
    AND   RVNV_RAM_CDGO    = RAMO
    AND   RVNV_CDGO_AMPRO = AMPARO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       CONTADOR :=0;
  END;
    IF CONTADOR = 0 THEN
       DELETE FROM RSGOS_VGNTES_NVDDES
       WHERE  RIVN_NMRO_ITEM   = P_SOLICITUD
       AND   RIVN_NMRO_PLZA  = POLIZA
       AND   RIVN_CLSE_PLZA  = CLASE_POLIZA
       AND   RIVN_RAM_CDGO  = RAMO
       AND   RIVN_CDGO_AMPRO = AMPARO;
       DELETE FROM RSGOS_VGNTES_AVLOR
       WHERE RVL_CDGO_AMPRO       = AMPARO
         AND RVL_NMRO_ITEM    =  P_SOLICITUD
         AND   RVL_NMRO_PLZA    = POLIZA
         AND   RVL_CLSE_PLZA    = CLASE_POLIZA
         AND   RVL_RAM_CDGO    = RAMO
         AND   RVL_CNCPTO_VLOR      = CONCEPTO;
       BEGIN
         SELECT COUNT(8)INTO CONTADOR
           FROM RSGOS_VGNTES_AVLOR
          WHERE RVL_CDGO_AMPRO       = AMPARO
            AND RVL_NMRO_ITEM   =  P_SOLICITUD
          AND   RVL_NMRO_PLZA    = POLIZA
          AND   RVL_CLSE_PLZA    = CLASE_POLIZA
          AND   RVL_RAM_CDGO    = RAMO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          CONTADOR := 0;
      END;
      IF CONTADOR = 0 THEN
       DELETE  FROM RSGOS_VGNTES_AMPRO
       WHERE   RVA_CDGO_AMPRO  = AMPARO
       AND   RVA_RAM_CDGO    = RAMO
       AND   RVA_NMRO_ITEM   = P_SOLICITUD
       AND   RVA_NMRO_PLZA  = POLIZA
       AND   RVA_CLSE_PLZA  = CLASE_POLIZA;
     END IF;
       DELETE FROM RSGOS_VGNTES_VLRES
       WHERE   RVV_NMRO_ITEM   =  P_SOLICITUD
       AND   RVV_NMRO_PLZA    = POLIZA
       AND   RVV_CLSE_PLZA    = CLASE_POLIZA
       AND   RVV_RAM_CDGO    = RAMO
       AND   RVV_CNCPTO_VLOR = CONCEPTO;
    END IF;
  BEGIN
    SELECT COUNT(8)INTO CONTADOR
    FROM RSGOS_VGNTES_AMPRO
    WHERE   RVA_NMRO_ITEM   = P_SOLICITUD
    AND   RVA_NMRO_PLZA  = POLIZA
    AND   RVA_CLSE_PLZA  = CLASE_POLIZA
    AND   RVA_RAM_CDGO    = RAMO;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       CONTADOR :=0;
  END;

    IF CONTADOR = 0 THEN
       -- SE INCLUYE PARA LAS NUEVAS TABLAS QUE EXISTEN EN OPERACION. SPPC. 10/04/2014
       DELETE AUMENTOS_CONTRATOS A
        WHERE A.SOLICITUD = P_SOLICITUD;

       DELETE DATOS_CONTRATOS D
        WHERE D.SOLICITUD = P_SOLICITUD;

       DELETE FROM RSGOS_VGNTES_VLRES
       WHERE   RVV_NMRO_ITEM   =  P_SOLICITUD
       AND   RVV_NMRO_PLZA    = POLIZA
       AND   RVV_CLSE_PLZA    = CLASE_POLIZA
       AND   RVV_RAM_CDGO    = RAMO;
       DELETE FROM RSGOS_VGNTES_NITS
       WHERE     RVN_NMRO_ITEM  =  P_SOLICITUD
       AND     RVN_NMRO_PLZA  = POLIZA
       AND     RVN_CLSE_PLZA  = CLASE_POLIZA
       AND     RVN_RAM_CDGO    = RAMO;
       DELETE SLCTDES_VGNTES
       WHERE SVI_NMRO_ITEM   = P_SOLICITUD;
       DELETE  FROM RSGOS_VGNTES
       WHERE RVI_NMRO_ITEM    = P_SOLICITUD
       AND   RVI_NMRO_PLZA  = POLIZA
       AND   RVI_CLSE_PLZA  = CLASE_POLIZA
       AND   RVI_RAM_CDGO    = RAMO;
    END IF;
   END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20903, 'Error borrando registros del seguro de arrendamiento'||SQLERRM);
   END;

END BORRAR_REGISTROS;


PROCEDURE VALIDA_SINIESTRO(SOLICITUD NUMBER,MENSAJE OUT VARCHAR2) IS

  CURSOR C_SINIESTRO IS
    SELECT SNA_NMRO_ITEM
      FROM AVSOS_SNSTROS,DDAS_VGNTES_ARRNDMNTOS
     WHERE SNA_NMRO_ITEM = SOLICITUD
       AND SNA_ESTDO_SNSTRO != '06'
       AND SNA_NMRO_ITEM = DVA_NMRO_SLCTUD
       AND SNA_FCHA_SNSTRO = DVA_FCHA_MRA
       AND DVA_ESTDO = '01';

NUMERO   NUMBER;

BEGIN
   OPEN C_SINIESTRO;
   LOOP
     FETCH C_SINIESTRO INTO NUMERO;
     IF C_SINIESTRO%NOTFOUND THEN
       EXIT;
     END IF;
     MENSAJE := 'La Solicitud ya presenta siniestros, no puede Borrar la novedad.';
     RETURN;
   END LOOP;
   CLOSE C_SINIESTRO;
END;

PROCEDURE INGRESA_CUOTAS_AMPARO(P_SOLICITUD SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                                P_POLIZA PLZAS.POL_NMRO_PLZA%TYPE,
                                P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                                P_CLSE_PLZA PLZAS.POL_CDGO_CLSE%TYPE,
                                P_RAM_CDGO PLZAS.POL_RAM_CDGO%TYPE,
                                P_PERIODO VARCHAR2) IS

  CURSOR C_CUOTAS IS
    SELECT REN_FCHA_NVDAD,REN_FCHA_MDFCCION,REN_VLOR_DFRNCIA
      FROM RSGOS_RCBOS_NVDAD
     WHERE REN_CDGO_AMPRO   = P_AMPARO
       AND REN_NMRO_ITEM    = P_SOLICITUD
       AND REN_CLSE_PLZA    = P_CLSE_PLZA
       AND REN_RAM_CDGO     = P_RAM_CDGO
       AND REN_TPO_NVDAD    = '11';


PRIMERA_CUOTA   DATE;
SEGUNDA_CUOTA  DATE;
CUOTA    RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE;

BEGIN
  OPEN C_CUOTAS;
  LOOP
    FETCH C_CUOTAS INTO PRIMERA_CUOTA,SEGUNDA_CUOTA,CUOTA;
    IF C_CUOTAS%NOTFOUND THEN
      EXIT;
    END IF;
    IF TO_CHAR(PRIMERA_CUOTA,'MMYYYY') >= P_PERIODO OR TO_CHAR(SEGUNDA_CUOTA,'MMYYYY') >= P_PERIODO THEN
      BEGIN
        INSERT INTO RSGOS_VGNTES_NVDDES
         VALUES(PRIMERA_CUOTA,P_AMPARO,P_RAM_CDGO,P_SOLICITUD,P_POLIZA,P_CLSE_PLZA,'11',
                CUOTA,SEGUNDA_CUOTA,USER);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          --MOSTRAR_MENSAJE('Error insertando la cuota de amparos adicionales. '||P_AMPARO||' '||SQLERRM,'E',TRUE);
          RAISE_APPLICATION_ERROR(-20902, 'Error insertando la cuota de amparos adicionales. '||P_AMPARO||' '||SQLERRM);
      END;
    END IF;
  END LOOP;
  CLOSE C_CUOTAS;

END INGRESA_CUOTAS_AMPARO;


PROCEDURE REVERSO_VALORES_PRIMAS (NOVEDAD VARCHAR2, POLIZA NUMBER, CLASE_POLIZA VARCHAR2,RAMO VARCHAR2,
                          AMPARO VARCHAR2,CERTIFICADO NUMBER, SOLICITUD NUMBER, PRIMA_NETA_ANT IN OUT NUMBER,
                          PRIMA_NETA IN OUT NUMBER, PRIMA_TOTAL_ANT IN OUT NUMBER,  PRIMA_TOTAL IN OUT NUMBER,
                          PRIMA_ANUAL_ANT IN OUT NUMBER, PRIMA_ANUAL IN OUT NUMBER, VALOR_ASEGURADO_ANT NUMBER,
                          VALOR_ASEGURADO NUMBER,  IVA NUMBER, IVA_PRIMA_ANT IN OUT NUMBER, IVA_PRIMA IN OUT NUMBER,
                          RETRO_NETA NUMBER,  RETRO_ANUAL NUMBER, RETRO_TOTAL NUMBER, IVA_RETRO NUMBER,
                          RETRO_NETA_ANT NUMBER, RETRO_ANUAL_ANT NUMBER, RETRO_TOTAL_ANT NUMBER, IVA_RETRO_ANT NUMBER,
                          PERIODO VARCHAR2, CUOTAS NUMBER, ENTRO IN OUT NUMBER, USUARIO VARCHAR2,
                          MENSAJE IN OUT VARCHAR2, CESION IN VARCHAR2, NOVEDAD_REVERSO VARCHAR2)
IS
 NOVEDAD_RETIRO            VARCHAR2(2):= '02';
 NOVEDAD_INGRESO          VARCHAR2(2):= '01';
 NOVEDAD_REINGRESO        VARCHAR2(2):= '05';
 NOVEDAD_AUMENTO          VARCHAR2(2):= '04';
 NOVEDAD_CESION           VARCHAR2(2):= '06';
 NOVEDAD_CAMBIO           VARCHAR2(2):= '07';
 NUMERO_NOVEDADES          NUMBER:= 0;
 NUMERO_RIESGOS           NUMBER :=0;
 CONTADOR                  NUMBER;
 FECHA                     DATE;
 CUOTA                     NUMBER;
 PRIMA                    NUMBER(18,2);
 PRIMA_ANT                NUMBER(18,2);
 PRIMA_TOT                 NUMBER(18,2);
 PRIMA_TOT_ANT            NUMBER(18,2);
 IV_PRIMA                  NUMBER(18,2);
 IV_PRIMA_ANT             NUMBER(18,2);

BEGIN

  IF ENTRO = 0 THEN
    NUMERO_NOVEDADES := -1;
  END IF;
  --mostrar_mensaje('en reverso valores primas','e',false);
  IF NOVEDAD_REVERSO = NOVEDAD_AUMENTO THEN
    BEGIN
      UPDATE RSMEN_NVDDES_CRTFCDO
         SET RNC_VLOR_PRMA=RNC_VLOR_PRMA - PRIMA_NETA_ANT + PRIMA_NETA,
             RNC_VLOR_ASGRDO=RNC_VLOR_ASGRDO - VALOR_ASEGURADO_ANT,
             RNC_NMERO_NVDDES=RNC_NMERO_NVDDES + NUMERO_NOVEDADES
       WHERE RNC_NMRO_CRTFCDO = CERTIFICADO
         AND RNC_NMRO_PLZA = POLIZA
         AND RNC_CLSE_PLZA  = CLASE_POLIZA
         AND RNC_RAM_CDGO = RAMO
         AND RNC_CDGO_AMPRO = AMPARO
         AND RNC_TPO_NVDAD = NOVEDAD_REVERSO;
    EXCEPTION
      WHEN OTHERS THEN
         MENSAJE:='ERROR EN ACTUALIZACION NOVEDADES CERTIFICADO'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    IF SQL%NOTFOUND THEN
      BEGIN
        INSERT INTO RSMEN_NVDDES_CRTFCDO
                    (RNC_NMRO_PLZA,    RNC_CLSE_PLZA,    RNC_RAM_CDGO,
                      RNC_CDGO_AMPRO,  RNC_TPO_NVDAD,    RNC_NMRO_CRTFCDO,
                     RNC_VLOR_PRMA,    RNC_VLOR_ASGRDO,  RNC_NMERO_NVDDES,
                     RNC_USRIO,        RNC_FCH_MDFCCION)
              VALUES(POLIZA,          CLASE_POLIZA,      RAMO,
                     AMPARO,          NOVEDAD_REVERSO,  CERTIFICADO,
                     PRIMA_NETA - PRIMA_NETA_ANT ,      VALOR_ASEGURADO,
                     NUMERO_NOVEDADES,  USUARIO,         SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE:='ERROR EN INSERCION NOVEDADES CERTIFICADO'||' '||SQLERRM;
          ROLLBACK;
          RETURN;
          END;
      END IF;
  ELSIF CESION = 'SI' AND NOVEDAD_REVERSO!=NOVEDAD_CAMBIO AND NOVEDAD_REVERSO!=NOVEDAD_RETIRO THEN
    BEGIN
       UPDATE RSMEN_NVDDES_CRTFCDO
          SET RNC_VLOR_PRMA=RNC_VLOR_PRMA - PRIMA_NETA_ANT + PRIMA_NETA,
              RNC_VLOR_ASGRDO=RNC_VLOR_ASGRDO - VALOR_ASEGURADO_ANT,
              RNC_NMERO_NVDDES=RNC_NMERO_NVDDES + NUMERO_NOVEDADES
        WHERE RNC_NMRO_CRTFCDO = CERTIFICADO
          AND RNC_NMRO_PLZA = POLIZA
          AND RNC_CLSE_PLZA  = CLASE_POLIZA
          AND RNC_RAM_CDGO = RAMO
          AND RNC_CDGO_AMPRO = AMPARO
          AND RNC_TPO_NVDAD = NOVEDAD_INGRESO;
    EXCEPTION
      WHEN OTHERS THEN
         MENSAJE:='ERROR EN ACTUALIZACION NOVEDADES CERTIFICADO'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    IF SQL%NOTFOUND THEN
      BEGIN
        INSERT INTO RSMEN_NVDDES_CRTFCDO
                   (RNC_NMRO_PLZA,    RNC_CLSE_PLZA,    RNC_RAM_CDGO,
                     RNC_CDGO_AMPRO,    RNC_TPO_NVDAD,    RNC_NMRO_CRTFCDO,
                    RNC_VLOR_PRMA,    RNC_VLOR_ASGRDO,  RNC_NMERO_NVDDES,
                    RNC_USRIO,    RNC_FCH_MDFCCION)
             VALUES(POLIZA,    CLASE_POLIZA,    RAMO,
                    AMPARO,    NOVEDAD_INGRESO,    CERTIFICADO,
                    PRIMA_NETA - PRIMA_NETA_ANT ,  VALOR_ASEGURADO,    NUMERO_NOVEDADES,
                    USUARIO,           SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE:='ERROR EN INSERCION NOVEDADES CERTIFICADO'||' '||SQLERRM;
          ROLLBACK;
          RETURN;
       END;
    END IF;
  ELSIF NOVEDAD_REVERSO = NOVEDAD_CAMBIO THEN
    BEGIN
      UPDATE RSMEN_NVDDES_CRTFCDO
         SET RNC_VLOR_PRMA=RNC_VLOR_PRMA + PRIMA_NETA_ANT - PRIMA_NETA,
             RNC_VLOR_ASGRDO=RNC_VLOR_ASGRDO - VALOR_ASEGURADO,
             RNC_NMERO_NVDDES=RNC_NMERO_NVDDES + NUMERO_NOVEDADES
       WHERE RNC_NMRO_CRTFCDO = CERTIFICADO
         AND RNC_NMRO_PLZA = POLIZA
         AND RNC_CLSE_PLZA  = CLASE_POLIZA
         AND RNC_RAM_CDGO = RAMO
         AND RNC_CDGO_AMPRO = AMPARO
         AND RNC_TPO_NVDAD = NOVEDAD_RETIRO;
    EXCEPTION
      WHEN OTHERS THEN
        MENSAJE:='ERROR EN ACTUALIZACION NOVEDADES CERTIFICADO'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;

-- Si borran el cambio de de inmueble y habian cuotas pendientes por cobrar de amparos adicionales
-- se deben ingresar de nuevo.

    IF CUOTAS > 1 THEN
       INGRESA_CUOTAS_AMPARO(SOLICITUD,POLIZA,AMPARO,CLASE_POLIZA,RAMO,PERIODO);
    END IF;
  ELSIF NOVEDAD_REVERSO = NOVEDAD_RETIRO THEN
    BEGIN
      UPDATE RSMEN_NVDDES_CRTFCDO
         SET RNC_VLOR_PRMA=RNC_VLOR_PRMA + PRIMA_NETA_ANT - PRIMA_NETA,
             RNC_VLOR_ASGRDO=RNC_VLOR_ASGRDO - VALOR_ASEGURADO,
             RNC_NMERO_NVDDES=RNC_NMERO_NVDDES + NUMERO_NOVEDADES
       WHERE RNC_NMRO_CRTFCDO = CERTIFICADO
         AND RNC_NMRO_PLZA = POLIZA
         AND RNC_CLSE_PLZA  = CLASE_POLIZA
         AND RNC_RAM_CDGO = RAMO
         AND RNC_CDGO_AMPRO = AMPARO
         AND RNC_TPO_NVDAD = NOVEDAD_RETIRO;
    EXCEPTION
      WHEN OTHERS THEN
        MENSAJE:='ERROR EN ACTUALIZACION NOVEDADES CERTIFICADO'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
  ELSE
    BEGIN
      UPDATE RSMEN_NVDDES_CRTFCDO
         SET RNC_VLOR_PRMA=RNC_VLOR_PRMA - PRIMA_NETA_ANT + PRIMA_NETA,
             RNC_VLOR_ASGRDO=RNC_VLOR_ASGRDO - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             RNC_NMERO_NVDDES=RNC_NMERO_NVDDES + NUMERO_NOVEDADES
       WHERE RNC_NMRO_CRTFCDO = CERTIFICADO
         AND RNC_NMRO_PLZA = POLIZA
         AND RNC_CLSE_PLZA  = CLASE_POLIZA
         AND RNC_RAM_CDGO = RAMO
         AND RNC_CDGO_AMPRO = AMPARO
         AND RNC_TPO_NVDAD = NOVEDAD_REVERSO;
    EXCEPTION
       WHEN OTHERS THEN
         MENSAJE:='ERROR EN ACTUALIZACION RESUMEN CERTIFICADO'||' '||SQLERRM;
         ROLLBACK;
         RETURN;
    END;
    IF SQL%NOTFOUND THEN
      BEGIN
        INSERT INTO RSMEN_NVDDES_CRTFCDO
                   (RNC_NMRO_PLZA,    RNC_CLSE_PLZA,    RNC_RAM_CDGO,
                     RNC_CDGO_AMPRO,    RNC_TPO_NVDAD,    RNC_NMRO_CRTFCDO,
                    RNC_VLOR_PRMA,    RNC_VLOR_ASGRDO,  RNC_NMERO_NVDDES,
                    RNC_USRIO,    RNC_FCH_MDFCCION)
             VALUES(POLIZA,    CLASE_POLIZA,    RAMO,
                    AMPARO,    NOVEDAD_REVERSO,    CERTIFICADO,
                    PRIMA_NETA - PRIMA_NETA_ANT ,  VALOR_ASEGURADO,    NUMERO_NOVEDADES,
                    USUARIO,           SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE:='ERROR EN INSERCION RESUMEN CERTIFICADO'||' '||SQLERRM;
          ROLLBACK;
          RETURN;
       END;
    END IF;
  END IF;

-- Actualizar acumulados amparo
  IF ENTRO = 0 THEN
    IF NOVEDAD = NOVEDAD_RETIRO THEN
      NUMERO_RIESGOS := -1;
    ELSIF NOVEDAD = NOVEDAD_INGRESO OR NOVEDAD = NOVEDAD_REINGRESO THEN
      NUMERO_RIESGOS := 1;
    END IF;
  ELSE
    NUMERO_RIESGOS := 0;
  END IF;
  IF AMPARO != '01' AND NOVEDAD = NOVEDAD_RETIRO  AND NOVEDAD_REVERSO = NOVEDAD_INGRESO THEN
    PRIMA := PRIMA_NETA / CUOTAS;
    PRIMA_ANT := PRIMA_NETA_ANT/CUOTAS;
    PRIMA_TOT := PRIMA_TOTAL / CUOTAS;
    PRIMA_TOT_ANT := PRIMA_TOTAL_ANT/CUOTAS;
    IV_PRIMA     := IVA_PRIMA/CUOTAS;
    IV_PRIMA_ANT  := IVA_PRIMA_ANT/CUOTAS;
    BEGIN
      UPDATE ACMLDOS_AMPRO
         SET ACA_NMRO_RSGOS =ACA_NMRO_RSGOS + NUMERO_RIESGOS,
             ACA_VLOR_ASGRDO=ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             ACA_PRMA_NTA    =ACA_PRMA_NTA - PRIMA_ANT + PRIMA
       WHERE ACA_NMRO_PLZA=POLIZA
         AND ACA_RAM_CDGO = RAMO
         AND ACA_CLSE_PLZA = CLASE_POLIZA
         AND ACA_CDGO_AMPRO=AMPARO
         AND ACA_NMRO_CRTFCDO=CERTIFICADO;
    EXCEPTION
      WHEN OTHERS THEN
        MENSAJE:='ERROR EN ACTUALIZACION ACUMULADOS AMPARO'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO ACMLDOS_AMPRO
                      (ACA_NMRO_CRTFCDO,      ACA_NMRO_PLZA,    ACA_CLSE_PLZA,
                       ACA_RAM_CDGO,      ACA_CDGO_AMPRO,
                       ACA_NMRO_RSGOS,      ACA_VLOR_ASGRDO,    ACA_PRMA_NTA,
                       ACA_USRIO,        ACA_FCHA_ACTLZCION)
                VALUES(CERTIFICADO,      POLIZA,      CLASE_POLIZA,
                        RAMO,        AMPARO,
                       1,        VALOR_ASEGURADO,         PRIMA_NETA - PRIMA_NETA_ANT,
                        USUARIO,      SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE:='ERROR EN INSERCION ACUMULADOS AMPARO';
            ROLLBACK;
            RETURN;
        END;
    END IF;
  ELSIF AMPARO != '01' AND NOVEDAD = NOVEDAD_RETIRO  AND NOVEDAD_REVERSO = NOVEDAD_REINGRESO THEN
    BEGIN
      PRIMA := 0;
      PRIMA_ANT := 0;
      PRIMA_TOT := 0;
      PRIMA_TOT_ANT := 0;
      IV_PRIMA     := 0;
      IV_PRIMA_ANT  := 0;
      UPDATE ACMLDOS_AMPRO
         SET ACA_NMRO_RSGOS =ACA_NMRO_RSGOS + NUMERO_RIESGOS,
             ACA_VLOR_ASGRDO=ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO
       WHERE ACA_NMRO_PLZA=POLIZA
         AND ACA_RAM_CDGO = RAMO
         AND ACA_CLSE_PLZA = CLASE_POLIZA
         AND   ACA_CDGO_AMPRO=AMPARO
         AND  ACA_NMRO_CRTFCDO=CERTIFICADO;
    EXCEPTION
      WHEN OTHERS THEN
         MENSAJE:='ERROR EN ACTUALIZACION ACUMULADOS AMPARO'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    IF SQL%NOTFOUND THEN
       BEGIN
          INSERT INTO ACMLDOS_AMPRO
                      (ACA_NMRO_CRTFCDO,      ACA_NMRO_PLZA,    ACA_CLSE_PLZA,
                       ACA_RAM_CDGO,      ACA_CDGO_AMPRO,
                       ACA_NMRO_RSGOS,      ACA_VLOR_ASGRDO,    ACA_PRMA_NTA,
                       ACA_USRIO,        ACA_FCHA_ACTLZCION)
                VALUES(CERTIFICADO,      POLIZA,      CLASE_POLIZA,
                        RAMO,        AMPARO,
                       1,        VALOR_ASEGURADO,         PRIMA_NETA - PRIMA_NETA_ANT,
                        USUARIO,      SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE:='ERROR EN INSERCION ACUMULADOS AMPARO';
            ROLLBACK;
            RETURN;
        END;

    END IF;
  ELSIF CESION = 'SI' THEN
    IF AMPARO = '01' THEN
      BEGIN
        UPDATE ACMLDOS_AMPRO
           SET ACA_NMRO_RSGOS =ACA_NMRO_RSGOS + NUMERO_RIESGOS,
               ACA_VLOR_ASGRDO=ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               ACA_PRMA_NTA    =ACA_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA
         WHERE ACA_NMRO_PLZA=POLIZA
           AND ACA_RAM_CDGO = RAMO
           AND ACA_CLSE_PLZA = CLASE_POLIZA
           AND ACA_CDGO_AMPRO=AMPARO
           AND ACA_NMRO_CRTFCDO=CERTIFICADO;
      EXCEPTION
        WHEN OTHERS THEN
           MENSAJE:='ERROR EN ACTUALIZACION RESUMEN CERTIFICADO'||' '||SQLERRM;
          ROLLBACK;
          RETURN;
      END;
      IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO ACMLDOS_AMPRO
                      (ACA_NMRO_CRTFCDO,      ACA_NMRO_PLZA,    ACA_CLSE_PLZA,
                       ACA_RAM_CDGO,      ACA_CDGO_AMPRO,
                       ACA_NMRO_RSGOS,      ACA_VLOR_ASGRDO,    ACA_PRMA_NTA,
                       ACA_USRIO,        ACA_FCHA_ACTLZCION)
                VALUES(CERTIFICADO,      POLIZA,      CLASE_POLIZA,
                        RAMO,        AMPARO,
                       1,        VALOR_ASEGURADO,         PRIMA_NETA - PRIMA_NETA_ANT,
                        USUARIO,      SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE:='ERROR EN INSERCION ACUMULADOS AMPARO';
            ROLLBACK;
            RETURN;
        END;
      END IF;
    ELSE
      BEGIN
        UPDATE ACMLDOS_AMPRO
           SET ACA_NMRO_RSGOS =ACA_NMRO_RSGOS + NUMERO_RIESGOS,
               ACA_VLOR_ASGRDO=ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO
         WHERE ACA_NMRO_PLZA=POLIZA
           AND ACA_RAM_CDGO = RAMO
           AND ACA_CLSE_PLZA = CLASE_POLIZA
           AND ACA_CDGO_AMPRO=AMPARO
           AND ACA_NMRO_CRTFCDO=CERTIFICADO;
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE:='ERROR EN ACTUALIZACION ACUMULADOS AMPARO'||' '||SQLERRM;
          ROLLBACK;
          RETURN;
      END;
      IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO ACMLDOS_AMPRO
                     (ACA_NMRO_CRTFCDO,      ACA_NMRO_PLZA,    ACA_CLSE_PLZA,
                      ACA_RAM_CDGO,      ACA_CDGO_AMPRO,
                      ACA_NMRO_RSGOS,      ACA_VLOR_ASGRDO,    ACA_PRMA_NTA,
                      ACA_USRIO,        ACA_FCHA_ACTLZCION)
               VALUES(CERTIFICADO,      POLIZA,      CLASE_POLIZA,
                       RAMO,        AMPARO,
                      1,        VALOR_ASEGURADO,        0,
                       USUARIO,      SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE:='ERROR EN INSERCION ACUMULADOS AMPARO';
            ROLLBACK;
            RETURN;
        END;
      END IF;
    END IF;
  ELSIF CUOTAS = 1 THEN
    BEGIN
      UPDATE ACMLDOS_AMPRO
         SET ACA_NMRO_RSGOS =ACA_NMRO_RSGOS + NUMERO_RIESGOS,
             ACA_VLOR_ASGRDO=ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             ACA_PRMA_NTA    =ACA_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA
       WHERE ACA_NMRO_PLZA=POLIZA
         AND ACA_RAM_CDGO = RAMO
         AND ACA_CLSE_PLZA = CLASE_POLIZA
         AND ACA_CDGO_AMPRO=AMPARO
         AND ACA_NMRO_CRTFCDO=CERTIFICADO;
    EXCEPTION
      WHEN OTHERS THEN
         MENSAJE:='ERROR EN ACTUALIZACION ACUMULADOS AMPARO'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
    IF SQL%NOTFOUND THEN
      BEGIN
        INSERT INTO ACMLDOS_AMPRO
                   (ACA_NMRO_CRTFCDO,      ACA_NMRO_PLZA,    ACA_CLSE_PLZA,
                    ACA_RAM_CDGO,      ACA_CDGO_AMPRO,
                    ACA_NMRO_RSGOS,      ACA_VLOR_ASGRDO,    ACA_PRMA_NTA,
                    ACA_USRIO,        ACA_FCHA_ACTLZCION)
             VALUES(CERTIFICADO,      POLIZA,      CLASE_POLIZA,
                     RAMO,        AMPARO,
                    1,        VALOR_ASEGURADO,         PRIMA_NETA - PRIMA_NETA_ANT,
                     USUARIO,      SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE:='ERROR EN INSERCION ACUMULADOS AMPARO';
          ROLLBACK;
          RETURN;
      END;
    END IF;
  END IF;

/***************************************************************************************/
/* ACTUALIZAR POLIZAS CON EL VALOR ASEGURADO Y LA PRIMA RESULTANTE          */
/***************************************************************************************/
  IF AMPARO = '01' THEN
    BEGIN
      UPDATE PLZAS
         SET POL_NMRO_RSGOS_VGNTES = POL_NMRO_RSGOS_VGNTES + NUMERO_RIESGOS,
             POL_NMRO_RSGOS = POL_NMRO_RSGOS + NUMERO_RIESGOS,
             POL_VLOR_ASGRDO_FLTNTE = POL_VLOR_ASGRDO_FLTNTE - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             POL_VLOR_ASGRDO_TTAL = POL_VLOR_ASGRDO_TTAL - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             POL_VLO_ASEGRBLE = POL_VLO_ASEGRBLE - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             POL_VLOR_PRMA_TTAL =  POL_VLOR_PRMA_TTAL - PRIMA_TOTAL_ANT + PRIMA_TOTAL,
             POL_VLOR_PRMA_ANUAL = POL_VLOR_PRMA_ANUAL - PRIMA_ANUAL_ANT + PRIMA_ANUAL,
             POL_VLOR_PRMA_NTA =   POL_VLOR_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA,
             POL_NMRO_CRTFCDO = CERTIFICADO,
             POL_PRCNTJE_IVA = IVA,
             POL_VLOR_IVA    = POL_VLOR_IVA - IVA_PRIMA_ANT + IVA_PRIMA
       WHERE POL_NMRO_PLZA = POLIZA
         AND POL_CDGO_CLSE = CLASE_POLIZA
         AND POL_RAM_CDGO  = RAMO;
    EXCEPTION
       WHEN OTHERS THEN
         MENSAJE:='ERROR EN ACTUALIZACION DE POLIZAS'||' '||SQLERRM;
         ROLLBACK;
         RETURN;
    END;
    IF SQL%NOTFOUND THEN
      MENSAJE:='ERROR EN LA ACTUALIZACION DE POLIZAS';
      ROLLBACK;
      RETURN;
    END IF;
  END IF;

/***************************************************************************************/
/* GUARDA LA PRIMA RETROACTIVA PARA MOSTRARLA EN LA RELACION DE ASEGURADOS.            */
/* SOLO EXISTE PRIMA RETROACTIVA PARA EL AMPARO BASICO               */
/***************************************************************************************/

  IF AMPARO = '01' AND NOVEDAD = NOVEDAD_INGRESO THEN
    BEGIN
      FECHA := TO_DATE('01'||'/'||SUBSTR(PERIODO,1,2)||'/'||SUBSTR(PERIODO,3,4)||' '||'01:03:00','DD/MM/YYYY HH:MI:SS');
      UPDATE RSGOS_VGNTES_NVDDES
         SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA - RETRO_NETA_ANT + RETRO_NETA
       WHERE RIVN_NMRO_ITEM = SOLICITUD
         AND RIVN_NMRO_PLZA = POLIZA
         AND RIVN_CLSE_PLZA = CLASE_POLIZA
         AND RIVN_RAM_CDGO = RAMO
         AND RIVN_CDGO_AMPRO = AMPARO
         AND RIVN_TPO_NVDAD = '12';
      IF SQL%NOTFOUND THEN
        INSERT INTO RSGOS_VGNTES_NVDDES
                   (RIVN_FCHA_NVDAD,  RIVN_CDGO_AMPRO, RIVN_RAM_CDGO, RIVN_NMRO_ITEM,
                    RIVN_NMRO_PLZA,  RIVN_CLSE_PLZA,  RIVN_TPO_NVDAD, RIVN_VLOR_DFRNCIA,
                    RIVN_FCHA_MDFCCION, RIVN_USRIO             )
             VALUES(FECHA,  AMPARO,   RAMO,  SOLICITUD,
                    POLIZA,   CLASE_POLIZA,   '12', RETRO_NETA - RETRO_NETA_ANT,
                    SYSDATE,   USUARIO);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        MENSAJE := 'ERROR INSERTANDO RETROACTIVIDAD DEL AMPARO.'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
  END IF;
  IF NOVEDAD = NOVEDAD_INGRESO THEN
    IF CESION = 'NO' THEN
      IF CUOTAS > 1 THEN
        PRIMA_NETA := PRIMA_NETA / CUOTAS;
        IVA_PRIMA  := IVA_PRIMA / CUOTAS;
        PRIMA_TOTAL := PRIMA_TOTAL / CUOTAS;
        PRIMA_ANUAL := PRIMA_ANUAL / CUOTAS;
        PRIMA_NETA_ANT  := PRIMA_NETA_ANT / CUOTAS;
        IVA_PRIMA_ANT   := IVA_PRIMA_ANT / CUOTAS;
        PRIMA_TOTAL_ANT := PRIMA_TOTAL_ANT / CUOTAS;
        PRIMA_ANUAL_ANT := PRIMA_ANUAL_ANT / CUOTAS;
        BEGIN
          UPDATE ACMLDOS_AMPRO
             SET ACA_NMRO_RSGOS =ACA_NMRO_RSGOS + NUMERO_RIESGOS,
                 ACA_VLOR_ASGRDO=ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
                 ACA_PRMA_NTA    =ACA_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA
           WHERE ACA_NMRO_PLZA=POLIZA
             AND ACA_RAM_CDGO = RAMO
             AND ACA_CLSE_PLZA = CLASE_POLIZA
             AND ACA_CDGO_AMPRO=AMPARO
             AND ACA_NMRO_CRTFCDO=CERTIFICADO;
          IF SQL%NOTFOUND THEN
            BEGIN
              INSERT INTO ACMLDOS_AMPRO
                         (ACA_NMRO_CRTFCDO,      ACA_NMRO_PLZA,    ACA_CLSE_PLZA,
                          ACA_RAM_CDGO,      ACA_CDGO_AMPRO,
                          ACA_NMRO_RSGOS,      ACA_VLOR_ASGRDO,    ACA_PRMA_NTA,
                          ACA_USRIO,        ACA_FCHA_ACTLZCION)
                   VALUES(CERTIFICADO,      POLIZA,      CLASE_POLIZA,
                           RAMO,        AMPARO,
                          1,        VALOR_ASEGURADO,         PRIMA_NETA - PRIMA_NETA_ANT,
                           USUARIO,      SYSDATE);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE:='ERROR EN INSERCION ACUMULADOS AMPARO';
                ROLLBACK;
                RETURN;
            END;
          END IF;
        END;
        CONTADOR := 1;
        FECHA := TO_DATE('01'||'/'||SUBSTR(PERIODO,1,2)||'/'||SUBSTR(PERIODO,3,4)||' '||'01:02:00','DD/MM/YYYY HH:MI:SS');
        WHILE CONTADOR < CUOTAS LOOP
          BEGIN
            UPDATE RSGOS_VGNTES_NVDDES
               SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + PRIMA_NETA
             WHERE RIVN_NMRO_ITEM = SOLICITUD
               AND RIVN_NMRO_PLZA = POLIZA
               AND RIVN_CLSE_PLZA = CLASE_POLIZA
               AND RIVN_RAM_CDGO = RAMO
               AND RIVN_CDGO_AMPRO = AMPARO
               AND RIVN_TPO_NVDAD = '11';
            IF SQL%NOTFOUND THEN
              INSERT INTO RSGOS_VGNTES_NVDDES
                         (RIVN_FCHA_NVDAD,  RIVN_CDGO_AMPRO, RIVN_RAM_CDGO, RIVN_NMRO_ITEM,
                          RIVN_NMRO_PLZA,  RIVN_CLSE_PLZA,  RIVN_TPO_NVDAD, RIVN_VLOR_DFRNCIA,
                          RIVN_FCHA_MDFCCION, RIVN_USRIO             )
                   VALUES(FECHA,  AMPARO,   RAMO,  SOLICITUD,
                          POLIZA,   CLASE_POLIZA,   '11', PRIMA_NETA,
                          SYSDATE,   USUARIO);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR INSERTANDO CUOTAS DEL AMPARO.'||' '||SQLERRM;
              ROLLBACK;
              RETURN;
          END;
          CONTADOR := CONTADOR + 1;
          FECHA := FECHA + 1;
        END LOOP;
      END IF;
    END IF;
  END IF;

/***************************************************************************************/
/* Actualiza el certificado para el periodo actual.               */
/* No puede actualizar el certificado si se retira un amparo adicional.                */
/***************************************************************************************/
  IF NOVEDAD = NOVEDAD_RETIRO AND NOVEDAD_REVERSO != NOVEDAD_CESION AND AMPARO != '01' THEN
    BEGIN
      UPDATE CRTFCDOS
         SET CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             CER_VLOR_PRMA_NTA = CER_VLOR_PRMA_NTA - PRIMA_ANT + PRIMA,
             CER_VLOR_PRMA_TTAL = CER_VLOR_PRMA_TTAL - PRIMA_TOT_ANT + PRIMA_TOT,
             CER_VLOR_IVA = CER_VLOR_IVA - IV_PRIMA_ANT + IV_PRIMA
       WHERE CER_NMRO_CRTFCDO = CERTIFICADO
         AND CER_NMRO_PLZA = POLIZA
         AND CER_CLSE_PLZA = CLASE_POLIZA
         AND CER_RAM_CDGO = RAMO;
      IF SQL%NOTFOUND THEN
        MENSAJE:='ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
        ROLLBACK;
        RETURN;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        MENSAJE:='ERROR EN ACTUALIZACION CERTIFICADOS'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
  ELSIF NOVEDAD = NOVEDAD_RETIRO AND CESION='SI' AND AMPARO != '01' THEN
    BEGIN
      UPDATE CRTFCDOS
         SET CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO
       WHERE CER_NMRO_CRTFCDO = CERTIFICADO
         AND CER_NMRO_PLZA = POLIZA
         AND CER_CLSE_PLZA = CLASE_POLIZA
         AND CER_RAM_CDGO = RAMO;
      IF SQL%NOTFOUND THEN
        MENSAJE:='ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
        ROLLBACK;
        RETURN;
      END IF;
    EXCEPTION
       WHEN OTHERS THEN
         MENSAJE:='ERROR EN ACTUALIZACION CERTIFICADOS'||' '||SQLERRM;
         ROLLBACK;
         RETURN;
    END;
  ELSIF NOVEDAD = NOVEDAD_REINGRESO AND AMPARO != '01' THEN
    BEGIN
      UPDATE CRTFCDOS
         SET CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO         WHERE CER_NMRO_CRTFCDO = CERTIFICADO
         AND CER_NMRO_PLZA = POLIZA
         AND CER_CLSE_PLZA = CLASE_POLIZA
         AND CER_RAM_CDGO = RAMO;
      IF SQL%NOTFOUND THEN
        MENSAJE:='ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
        ROLLBACK;
        RETURN;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
         MENSAJE:='ERROR EN ACTUALIZACION CERTIFICADOS'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
    END;
  ELSE
    BEGIN
      UPDATE CRTFCDOS
         SET CER_VLOR_PRMA_NTA = CER_VLOR_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA - RETRO_NETA_ANT + RETRO_NETA,
             CER_VLOR_PRMA_TTAL = CER_VLOR_PRMA_TTAL - PRIMA_TOTAL_ANT + PRIMA_TOTAL - RETRO_TOTAL_ANT + RETRO_TOTAL,
             CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             CER_VLOR_IVA = CER_VLOR_IVA - IVA_PRIMA_ANT + IVA_PRIMA - IVA_RETRO_ANT + IVA_RETRO
       WHERE CER_NMRO_CRTFCDO = CERTIFICADO
         AND CER_NMRO_PLZA = POLIZA
         AND CER_CLSE_PLZA = CLASE_POLIZA
         AND CER_RAM_CDGO = RAMO;
      IF SQL%NOTFOUND THEN
        MENSAJE:='ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
        ROLLBACK;
        RETURN;
      END IF;
    END;
  END IF;
  ENTRO := 1;

END REVERSO_VALORES_PRIMAS;


PROCEDURE ACTUALIZA_AMPAROS_BORRADO (NOVEDAD VARCHAR2, SOLICITUD NUMBER,POLIZA NUMBER, CLASE_POLIZA VARCHAR2,
                             RAMO VARCHAR2, CONCEPTO VARCHAR2, CERTIFICADO NUMBER, AMPARO VARCHAR2,
                             VALOR_ANT NUMBER, VALOR NUMBER, USUARIO VARCHAR2, MENSAJE IN OUT VARCHAR2)
IS
 NOVEDAD_RETIRO         VARCHAR2(2):= '02';
 NOVEDAD_AUMENTO       VARCHAR2(2):='04';
 NOVEDAD_REINGRESO           VARCHAR2(2):='05';
 CNCPTO_VLOR         VARCHAR2(4);
 VLOR           NUMBER;
 fecha_max      date;
 CoNCePTO_v         VARCHAR2(4);
 VaLOR_v           NUMBER;

ITEM NUMBER(10);
BEGIN

IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) THEN
     BEGIN
      SELECT  RVL_CNCPTO_VLOR,RVL_VLOR
        INTO  CNCPTO_VLOR, VLOR
        FROM RSGOS_VGNTES_AVLOR
       WHERE RVL_CDGO_AMPRO  = AMPARO
         AND RVL_NMRO_ITEM   = SOLICITUD
         AND RVL_NMRO_PLZA   = POLIZA
     AND RVL_CLSE_PLZA   = CLASE_POLIZA
   AND RVL_RAM_CDGO    = RAMO
         AND RVL_CNCPTO_VLOR = CONCEPTO;
   EXCEPTION WHEN NO_DATA_FOUND THEN
        MENSAJE:='LA SOLICITUD NO HA SIDO INGRESADA EN EL SEGURO1'||' '||SQLERRM;
        ROLLBACK;
        RETURN;
      END;
     UPDATE RSGOS_RCBOS_AVLOR
       SET  RAV_VLOR  = VLOR,
         RAV_USRIO  = USUARIO,
  RAV_FCHA_MDFCCION  = SYSDATE
      WHERE  RAV_CDGO_AMPRO  = AMPARO
        AND RAV_NMRO_ITEM  = SOLICITUD
        AND RAV_NMRO_PLZA  = POLIZA
        AND RAV_CLSE_PLZA  = CLASE_POLIZA
  AND RAV_RAM_CDGO  = RAMO
  AND RAV_CNCPTO_VLOR  = CONCEPTO
  AND RAV_NMRO_CRTFCDO  = CERTIFICADO;
     IF SQL%NOTFOUND THEN
     BEGIN
     INSERT INTO RSGOS_RCBOS_AVLOR
     ( RAV_NMRO_CRTFCDO ,  RAV_CDGO_AMPRO ,  RAV_RAM_CDGO ,    RAV_NMRO_ITEM,
       RAV_NMRO_PLZA    ,    RAV_CLSE_PLZA  ,  RAV_CNCPTO_VLOR,    RAV_VLOR     ,
       RAV_USRIO        ,  RAV_FCHA_MDFCCION      )
     VALUES (CERTIFICADO ,  AMPARO,    RAMO,        SOLICITUD,
            POLIZA,    CLASE_POLIZA,  CNCPTO_VLOR,    VLOR,
           USUARIO,    SYSDATE);
    EXCEPTION WHEN OTHERS THEN
     MENSAJE:='ERROR INSERCION HISTORICO RSGOS_RCBOS_AVLOR CUOTA'||' '||SQLERRM;
     ROLLBACK;
     RETURN;
    END;
  END IF;
END IF;
IF NOVEDAD != NOVEDAD_RETIRO THEN
UPDATE RSGOS_VGNTES_AVLOR
   SET RVL_VLOR       = RVL_VLOR - VALOR_ANT + VALOR,
   RVL_USRIO      = USUARIO,
   RVL_FCHA_MDFCCION  = SYSDATE
 WHERE RVL_CDGO_AMPRO    = AMPARO
   AND RVL_NMRO_ITEM    = SOLICITUD
   AND RVL_NMRO_PLZA    = POLIZA
   AND RVL_CLSE_PLZA    = CLASE_POLIZA
   AND RVL_RAM_CDGO    = RAMO
   AND RVL_CNCPTO_VLOR    = CONCEPTO;
 IF SQL%NOTFOUND THEN
   IF NOVEDAD = NOVEDAD_REINGRESO THEN
  begin
--mostrar_mensaje('antes de amp','e',false);
    SELECT R1.RRA_NMRO_ITEM into ITEM
                                        FROM  RSGOS_RCBOS_AMPRO   R1
                                       WHERE R1.RRA_CDGO_AMPRO  = AMPARO
                                         AND R1.RRA_NMRO_ITEM   = SOLICITUD
                                   AND R1.RRA_NMRO_PLZA   = POLIZA
                                   AND R1.RRA_CLSE_PLZA   = CLASE_POLIZA
                                   AND R1.RRA_RAM_CDGO   = RAMO
           and r1.rra_nmro_crtfcdo=certificado;
   exception when others then
               MENSAJE:='ERROR NO DATOS EN REINGRESO RSGOS_VGNTES_AMPRO '||' '||SQLERRM;
               ROLLBACK;
               RETURN;


end;


BEGIN
   SELECT R1.RvI_NMRO_ITEM into ITEM
   FROM  RSGOS_VGNTES   R1
   WHERE R1.RVI_NMRO_ITEM   = SOLICITUD
     AND R1.RVI_NMRO_PLZA   = POLIZA
     AND R1.RVI_CLSE_PLZA   = CLASE_POLIZA
     AND R1.RVI_RAM_CDGO   = RAMO;
exception when others then
  MENSAJE:='ERROR NO DATOS EN REINGRESO RSGOS_VGNTES '||' '||SQLERRM;
  ROLLBACK;
  RETURN;

END;

BEGIN
SELECT R1.RvA_NMRO_ITEM into ITEM
  FROM  RSGOS_VGNTES_AMPRO   R1
 WHERE R1.RVA_CDGO_AMPRO  = AMPARO
   AND R1.RVA_NMRO_ITEM   = SOLICITUD
   AND R1.RVA_NMRO_PLZA   = POLIZA
   AND R1.RVA_CLSE_PLZA   = CLASE_POLIZA
   AND R1.RVA_RAM_CDGO   = RAMO
   AND r1.rVa_nmro_crtfcdo=certificado;
exception when others then
    MENSAJE:='ERROR NO DATOS EN REINGRESO RSGOS_VGNTES_AMPRO '||' '||SQLERRM;
    ROLLBACK;
    RETURN;

END;

begin

   SELECT MAX(R1.RAV_FCHA_MDFCCION) into fecha_max
     FROM  RSGOS_RCBOS_AVLOR   R1
    WHERE R1.RAV_CDGO_AMPRO  = AMPARO
      AND R1.RAV_NMRO_ITEM   = SOLICITUD
      AND R1.RAV_NMRO_PLZA   = POLIZA
      AND R1.RAV_CLSE_PLZA   = CLASE_POLIZA
      AND R1.RAV_RAM_CDGO   = RAMO
      AND R1.RAV_CNCPTO_VLOR = CONCEPTO;

   exception when others then
      MENSAJE:='ERROR NO DATOS EN REINGRESO fecha maxima RSGOS_VGNTES_AVLOR CANON'||' '||SQLERRM;
      ROLLBACK;
      RETURN;

end;

begin
  SELECT RAV_CNCPTO_VLOR,
     RAV_VLOR
into concepto_v,
valor_v
    FROM RSGOS_RCBOS_AVLOR
   WHERE RAV_CDGO_AMPRO = AMPARO
           AND RAV_NMRO_ITEM  = SOLICITUD
     AND RAV_NMRO_PLZA  = POLIZA
     AND RAV_CLSE_PLZA  = CLASE_POLIZA
     AND RAV_RAM_CDGO   = RAMO
     AND RAV_CNCPTO_VLOR = CONCEPTO
           AND RAV_FCHA_MDFCCION =   fecha_max;
     EXCEPTION
           WHEN NO_DATA_FOUND THEN
               MENSAJE:='ERROR NO DATOS EN cons RSGOS_VGNTES_AVLOR CANON'||' '||SQLERRM;
               ROLLBACK;
               RETURN;
          WHEN TOO_MANY_ROWS THEN
               MENSAJE:='ERROR VARIOS REGISTROS EN cons RSGOS_VGNTES_AVLOR CANON'||' '||SQLERRM;
               ROLLBACK;
               RETURN;
          WHEN DUP_VAL_ON_INDEX THEN
               MENSAJE:='ERROR REGISTRO DUPLICADO EN cons RSGOS_VGNTES_AVLOR CANON'||' '||SQLERRM;
               ROLLBACK;
               RETURN;
         WHEN VALUE_ERROR THEN
               MENSAJE:='VALOR ERROR EN cons RSGOS_VGNTES_AVLOR CANON'||' '||SQLERRM;
               ROLLBACK;
               RETURN;
         WHEN OTHERS THEN
               MENSAJE:='ERROR consulta RSGOS_rcbos_AVLOR CANON...'||' '||AMPARO || ' '||SQLERRM;
               ROLLBACK;
               RETURN;
     END;

  BEGIN
    INSERT INTO RSGOS_VGNTES_AVLOR
        (RVL_CDGO_AMPRO ,  RVL_RAM_CDGO ,  RVL_NMRO_ITEM,
         RVL_NMRO_PLZA ,  RVL_CLSE_PLZA  ,  RVL_CNCPTO_VLOR,
         RVL_VLOR     ,  RVL_USRIO      ,  RVL_FCHA_MDFCCION)
    values(AMPARO,    RAMO,      SOLICITUD,
           POLIZA,    CLASE_POLIZA,  concepto_v,
           valor_v,usuario,sysdate);
  exception WHEN OTHERS THEN
      MENSAJE:='ERROR REINGRESO RSGOS_VGNTES_AVLOR CANON...'||' '||AMPARO || ' '||SQLERRM;
      ROLLBACK;
      RETURN;
    END;
ELSE
    BEGIN
     INSERT INTO RSGOS_VGNTES_AVLOR
     (RVL_CDGO_AMPRO,    RVL_RAM_CDGO,    RVL_NMRO_ITEM,
      RVL_NMRO_PLZA,    RVL_CLSE_PLZA,    RVL_CNCPTO_VLOR,
      RVL_VLOR,      RVL_USRIO,      RVL_FCHA_MDFCCION)
      VALUES(AMPARO,    RAMO,        SOLICITUD,
             POLIZA,    CLASE_POLIZA,    CONCEPTO,
             VALOR,    USUARIO,      SYSDATE);
     EXCEPTION WHEN OTHERS THEN
      MENSAJE:='ERROR INSERCION RSGOS_VGNTES_AVLOR AMPARO';
      ROLLBACK;
      RETURN;
     END;
   END IF;
 END IF;
END IF;

END ACTUALIZA_AMPAROS_BORRADO;



PROCEDURE AMPAROS_BORRADO (NOVEDAD VARCHAR2, SOLICITUD NUMBER,  POLIZA NUMBER,  CLASE_POLIZA VARCHAR2,
                   RAMO VARCHAR2,    AMPARO VARCHAR2,   CERTIFICADO NUMBER,  VALOR_ASEGURADO_ANT NUMBER,
                   VALOR_ASEGURADO NUMBER,   PRIMA_NETA_ANT NUMBER,  PRIMA_NETA NUMBER,
                   PRIMA_NETA_ANUAL NUMBER,  PRIMA_ANUAL_ANT NUMBER, PRIMA_ANUAL NUMBER,
                   TIPO_TASA VARCHAR2,   TASA NUMBER, TPO_DEDUCIBLE VARCHAR2, PORC_DEDUCIBLE NUMBER,
                   MNMO_DEDUCIBLE NUMBER,  TPO_IDEN VARCHAR2,  NMRO_IDEN NUMBER, PORC_DESCUENTO NUMBER,
                   IVA NUMBER,  ENTRO IN OUT NUMBER, USUARIO VARCHAR2, FECHA_NOVEDAD DATE,
                   MENSAJE IN OUT VARCHAR2)
IS
 NOVEDAD_RETIRO          VARCHAR2(2):= '02';
 NOVEDAD_AUMENTO   VARCHAR2(2):='04';
 NOVEDAD_REINGRESO       VARCHAR2(2):='05';
 TIPO                    VARCHAR2(2);
 IDEN               PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
 VLOR_ASGRDO_FLTNTE   NUMBER(18,2);
 VLOR_ASGRDO_TTAL   NUMBER(18,2);
 FECHA_ULT_AUM           DATE;
 PRMA_NTA           NUMBER(18,2);
 PRMA_ANUAL     NUMBER(18,2);
 DESDE       DATE;
 HASTA        DATE;
 DIAS       NUMBER(8);
 TPO_DDCBLE              VARCHAR2(5);
 TSA       NUMBER;
 TPO_TSA           VARCHAR2(1);
 DDCBLE                   NUMBER;
 INDCE                   NUMBER;
 MNMO_DDCBLE     NUMBER;
 BSE_INDCE     NUMBER;
 DSCNTO                  NUMBER(4,2);
 RCRGO       NUMBER(4,2);
 BASE_INDICE             NUMBER:=0;
 PORC_INDICE             NUMBER:=0;
 PORCENTAJE_RECARGO      NUMBER(4,2);
ITEM NUMBER(10);
BEGIN
--mostrar_mensaje('entro es '||to_char(entro),'e',false);
  IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) AND ENTRO = 0 THEN
    BEGIN
     SELECT RVA_PRS_NMRO_IDNTFCCION, RVA_PRS_TPO_IDNTFCCION, RVA_VLOR_ASGRDO_TTAL,
      RVA_VLOR_ASGRDO_FLTNTE,   RVA_VLOR_PRMA_NTA,   RVA_VLOR_PRMA_ANUAL,
            RVA_FCHA_DSDE_ACTUAL,   RVA_FCHA_HSTA_ACTUAL,   RVA_DIAS_VGNCIA_ACTUAL,
      RVA_TPO_TSA,     RVA_TSA_AMPRO,     RVA_PRCNTJE_DDCBLE,
         RVA_TPO_DDCBLE,      RVA_MNMO_DDCBLE,        RVA_PRCNTJE_INDCE,
      RVA_VLOR_BSE_INDCE,      RVA_PRCNTJE_DSCNTO,  RVA_PRCNTJE_RCRGO
       INTO     IDEN,                  TIPO,      VLOR_ASGRDO_TTAL,
    VLOR_ASGRDO_FLTNTE,  PRMA_NTA,    PRMA_ANUAL,
    DESDE,      HASTA,      DIAS,
    TPO_TSA,    TSA,      DDCBLE,
    TPO_DDCBLE,    MNMO_DDCBLE,    INDCE,
    BSE_INDCE,    DSCNTO,      RCRGO
       FROM RSGOS_VGNTES_AMPRO
      WHERE RVA_CDGO_AMPRO    = AMPARO
        AND RVA_RAM_CDGO    = RAMO
        AND RVA_NMRO_ITEM    = SOLICITUD
        AND RVA_NMRO_PLZA    = POLIZA
        AND RVA_CLSE_PLZA    = CLASE_POLIZA;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         MENSAJE := 'LA SOLICITUD NO HA SIDO INGRESADA AL SEGURO';
         ROLLBACK;
         RETURN;
     END;
    UPDATE   RSGOS_RCBOS_AMPRO
       SET   RRA_NMRO_IDNTFCCION   = IDEN,
    RRA_TPO_IDNTFCCION     = TIPO,
        RRA_VLOR_ASGRDO_TTAL  = VLOR_ASGRDO_TTAL,
    RRA_VLOR_ASGRDO_FLTNTE  = VLOR_ASGRDO_FLTNTE,
    RRA_VLOR_PRMA_NTA  = PRMA_NTA,
    RRA_VLOR_PRMA_ANUAL  = PRMA_ANUAL,
        RRA_FCHA_DSDE_ACTUAL  = DESDE,
    RRA_FCHA_HSTA_ACTUAL  = HASTA,
       RRA_DIAS_VGNCIA_ACTUAL  = DIAS,
    RRA_TPO_TSA     = TPO_TSA,
        RRA_TSA_AMPRO    = TSA,
    RRA_PRCNTJE_DDCBLE   = DDCBLE,
    RRA_TPO_DDCBLE    = TPO_DDCBLE,
    RRA_MNMO_DDCBLE    = MNMO_DDCBLE,
        RRA_PRCNTJE_INDCE    = INDCE,
    RRA_VLOR_BSE_INDCE  = BSE_INDCE,
    RRA_USRIO    = USUARIO,
    RRA_FCHA_MDFCCION   = SYSDATE,
        RRA_PRCNTJE_DSCNTO  = DSCNTO,
    RRA_PRCNTJE_RCRGO    = RCRGO
    WHERE    RRA_CDGO_AMPRO    = AMPARO
      AND    RRA_NMRO_ITEM    = SOLICITUD
      AND  RRA_NMRO_PLZA    = POLIZA
      AND       RRA_CLSE_PLZA    = CLASE_POLIZA
      AND  RRA_RAM_CDGO    = RAMO
      AND       RRA_NMRO_CRTFCDO             = CERTIFICADO;
   IF SQL%NOTFOUND THEN
     BEGIN
      INSERT INTO RSGOS_RCBOS_AMPRO
       (RRA_CDGO_AMPRO,      RRA_RAM_CDGO    ,    RRA_NMRO_ITEM  ,    RRA_NMRO_PLZA ,
        RRA_CLSE_PLZA,      RRA_NMRO_IDNTFCCION  ,   RRA_TPO_IDNTFCCION   ,  RRA_NMRO_CRTFCDO ,
        RRA_VLOR_ASGRDO_TTAL,    RRA_VLOR_ASGRDO_FLTNTE,  RRA_VLOR_PRMA_NTA ,  RRA_VLOR_PRMA_ANUAL,
        RRA_FCHA_DSDE_ACTUAL,    RRA_FCHA_HSTA_ACTUAL,   RRA_DIAS_VGNCIA_ACTUAL, RRA_TPO_TSA  ,
        RRA_TSA_AMPRO,      RRA_PRCNTJE_DDCBLE ,  RRA_TPO_DDCBLE   ,  RRA_MNMO_DDCBLE,
        RRA_PRCNTJE_INDCE,    RRA_VLOR_BSE_INDCE ,  RRA_USRIO ,      RRA_FCHA_MDFCCION ,
        RRA_PRCNTJE_DSCNTO,    RRA_PRCNTJE_RCRGO)
      VALUES(AMPARO,      RAMO,        SOLICITUD,      POLIZA,
      CLASE_POLIZA,    IDEN,        TIPO,        CERTIFICADO,
     VLOR_ASGRDO_TTAL,  VLOR_ASGRDO_FLTNTE,  PRMA_NTA,      PRMA_ANUAL,
     DESDE,      HASTA,      DIAS,        TPO_TSA,
     TSA,        DDCBLE,      TPO_DDCBLE,      MNMO_DDCBLE,
     INDCE,      BSE_INDCE,      USUARIO,      SYSDATE,
     DSCNTO,      RCRGO);
    EXCEPTION WHEN OTHERS THEN
     MENSAJE:='ERROR INSERCION HISTORICO RSGOS_RCBOS_AMPRO'||' '||SQLERRM;
     ROLLBACK;
     RETURN;
    END;
  END IF;
END IF;

IF NOVEDAD = NOVEDAD_AUMENTO THEN
   BEGIN
     SELECT MAX(RIVN_FCHA_NVDAD)
       INTO FECHA_ULT_AUM
       FROM RSGOS_VGNTES_NVDDES
      WHERE RIVN_NMRO_ITEM  = SOLICITUD
        AND RIVN_NMRO_PLZA  = POLIZA
        AND RIVN_CLSE_PLZA  = CLASE_POLIZA
        AND RIVN_RAM_CDGO   = RAMO
        AND RIVN_CDGO_AMPRO = AMPARO
        AND RIVN_TPO_NVDAD  = '04'
        AND RIVN_FCHA_NVDAD < FECHA_NOVEDAD;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        FECHA_ULT_AUM := FECHA_NOVEDAD;
   END;
   IF FECHA_ULT_AUM IS NULL THEN
     BEGIN
       SELECT MIN(RIVN_FCHA_NVDAD)
         INTO FECHA_ULT_AUM
         FROM RSGOS_VGNTES_NVDDES
        WHERE RIVN_NMRO_ITEM  = SOLICITUD
          AND RIVN_NMRO_PLZA  = POLIZA
          AND RIVN_CLSE_PLZA  = CLASE_POLIZA
          AND RIVN_RAM_CDGO   = RAMO
          AND RIVN_CDGO_AMPRO = AMPARO
          AND RIVN_TPO_NVDAD  = '01'
          AND RIVN_FCHA_NVDAD < FECHA_NOVEDAD;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FECHA_ULT_AUM := FECHA_NOVEDAD;
     END;
   END IF;
   IF FECHA_ULT_AUM IS NULL THEN
     FECHA_ULT_AUM := FECHA_NOVEDAD;
   END IF;
   UPDATE RSGOS_VGNTES_AMPRO
     SET RVA_NMRO_CRTFCDO  = CERTIFICADO,
   RVA_VLOR_ASGRDO_TTAL  = RVA_VLOR_ASGRDO_TTAL - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
         RVA_VLOR_ASGRDO_FLTNTE = RVA_VLOR_ASGRDO_FLTNTE - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
   RVA_VLOR_PRMA_NTA  = RVA_VLOR_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA,
   RVA_VLOR_PRMA_ANUAL  = RVA_VLOR_PRMA_ANUAL - PRIMA_ANUAL_ANT  + PRIMA_ANUAL,
   RVA_FCHA_DSDE_ACTUAL  = FECHA_ULT_AUM,
   RVA_FCHA_HSTA_ACTUAL   = FECHA_NOVEDAD,
   RVA_TSA_AMPRO    = TASA,
   RVA_TPO_DDCBLE    = TPO_DEDUCIBLE,
   RVA_MNMO_DDCBLE  = MNMO_DEDUCIBLE,
   RVA_PRCNTJE_INDCE  = PORC_INDICE,
   RVA_VLOR_BSE_INDCE  = BASE_INDICE,
   RVA_USRIO    = USUARIO,
   RVA_FCHA_MDFCCION  = SYSDATE,
   RVA_PRCNTJE_DSCNTO  = PORC_DESCUENTO,
    RVA_PRCNTJE_RCRGO  = PORCENTAJE_RECARGO,
   RVA_PRCNTJE_DDCBLE     = IVA
   WHERE RVA_CDGO_AMPRO    = AMPARO
     AND RVA_RAM_CDGO    = RAMO
     AND RVA_NMRO_ITEM    = SOLICITUD
     AND RVA_NMRO_PLZA    = POLIZA
     AND RVA_CLSE_PLZA    = CLASE_POLIZA;
  IF SQL%NOTFOUND THEN
    BEGIN
     INSERT INTO RSGOS_VGNTES_AMPRO
     (RVA_CDGO_AMPRO,    RVA_RAM_CDGO,    RVA_NMRO_ITEM,
      RVA_NMRO_PLZA,    RVA_CLSE_PLZA,    RVA_PRS_NMRO_IDNTFCCION,
      RVA_PRS_TPO_IDNTFCCION,  RVA_NMRO_CRTFCDO,    RVA_VLOR_ASGRDO_TTAL,
      RVA_VLOR_ASGRDO_FLTNTE,  RVA_VLOR_PRMA_NTA,  RVA_VLOR_PRMA_ANUAL,
      RVA_FCHA_DSDE_ACTUAL,  RVA_FCHA_HSTA_ACTUAL,  RVA_DIAS_VGNCIA_ACTUAL,
      RVA_TPO_TSA,    RVA_TSA_AMPRO,    RVA_PRCNTJE_DDCBLE,
      RVA_TPO_DDCBLE,    RVA_MNMO_DDCBLE,    RVA_PRCNTJE_INDCE,
      RVA_VLOR_BSE_INDCE,  RVA_USRIO,      RVA_FCHA_MDFCCION,
      RVA_PRCNTJE_DSCNTO,  RVA_PRCNTJE_RCRGO)
     VALUES(AMPARO,    RAMO,        SOLICITUD,
            POLIZA,    CLASE_POLIZA,          NMRO_IDEN,
            TPO_IDEN,    CERTIFICADO,    VALOR_ASEGURADO,
            VALOR_ASEGURADO,   PRIMA_NETA-PRIMA_NETA_ANT,    PRIMA_ANUAL-PRIMA_ANUAL_ANT,
            FECHA_ULT_AUM,  FECHA_NOVEDAD,      0,
            TIPO_TASA,    TASA,        IVA,
            TPO_DEDUCIBLE,  MNMO_DEDUCIBLE,    PORC_INDICE,
            BASE_INDICE,  USUARIO,      SYSDATE,
            PORC_DESCUENTO,        PORCENTAJE_RECARGO);
     EXCEPTION WHEN OTHERS THEN
      MENSAJE:='ERROR INSERCION RSGOS_VGNTES_AMPRO';
      ROLLBACK;
      RETURN;
    END;
  END IF;
ELSE
UPDATE RSGOS_VGNTES_AMPRO
     SET RVA_NMRO_CRTFCDO  = CERTIFICADO,
   RVA_VLOR_ASGRDO_TTAL  = RVA_VLOR_ASGRDO_TTAL - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
         RVA_VLOR_ASGRDO_FLTNTE = RVA_VLOR_ASGRDO_FLTNTE - VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
   RVA_VLOR_PRMA_NTA  = RVA_VLOR_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA,
   RVA_VLOR_PRMA_ANUAL  = RVA_VLOR_PRMA_ANUAL - PRIMA_ANUAL_ANT  + PRIMA_ANUAL,
   RVA_TSA_AMPRO    = TASA,
   RVA_TPO_DDCBLE    = TPO_DEDUCIBLE,
   RVA_MNMO_DDCBLE  = MNMO_DEDUCIBLE,
   RVA_PRCNTJE_INDCE  = PORC_INDICE,
   RVA_VLOR_BSE_INDCE  = BASE_INDICE,
   RVA_USRIO    = USUARIO,
   RVA_FCHA_MDFCCION  = SYSDATE,
   RVA_PRCNTJE_DSCNTO  = PORC_DESCUENTO,
    RVA_PRCNTJE_RCRGO  = PORCENTAJE_RECARGO,
   RVA_PRCNTJE_DDCBLE     = IVA
   WHERE RVA_CDGO_AMPRO    = AMPARO
     AND RVA_RAM_CDGO    = RAMO
     AND RVA_NMRO_ITEM    = SOLICITUD
     AND RVA_NMRO_PLZA    = POLIZA
     AND RVA_CLSE_PLZA    = CLASE_POLIZA;
  IF SQL%NOTFOUND THEN
--    mostrar_mensaje('antes de VIG ','e',false);
BEGIN
SELECT R1.RvI_NMRO_ITEM into ITEM
                                        FROM  RSGOS_VGNTES   R1
                                       WHERE R1.RVI_NMRO_ITEM   = SOLICITUD
                                   AND R1.RVI_NMRO_PLZA   = POLIZA
                                   AND R1.RVI_CLSE_PLZA   = CLASE_POLIZA
                                   AND R1.RVI_RAM_CDGO   = RAMO;
exception when others then
               MENSAJE:='ERROR NO DATOS EN REINGRESO RSGOS_VGNTES '||' '||SQLERRM;
               ROLLBACK;
               RETURN;


end;

    BEGIN

     INSERT INTO RSGOS_VGNTES_AMPRO
     (RVA_CDGO_AMPRO,    RVA_RAM_CDGO,    RVA_NMRO_ITEM,
      RVA_NMRO_PLZA,    RVA_CLSE_PLZA,    RVA_PRS_NMRO_IDNTFCCION,
      RVA_PRS_TPO_IDNTFCCION,  RVA_NMRO_CRTFCDO,    RVA_VLOR_ASGRDO_TTAL,
      RVA_VLOR_ASGRDO_FLTNTE,  RVA_VLOR_PRMA_NTA,  RVA_VLOR_PRMA_ANUAL,
      RVA_FCHA_DSDE_ACTUAL,  RVA_FCHA_HSTA_ACTUAL,  RVA_DIAS_VGNCIA_ACTUAL,
      RVA_TPO_TSA,    RVA_TSA_AMPRO,    RVA_PRCNTJE_DDCBLE,
      RVA_TPO_DDCBLE,    RVA_MNMO_DDCBLE,    RVA_PRCNTJE_INDCE,
      RVA_VLOR_BSE_INDCE,  RVA_USRIO,      RVA_FCHA_MDFCCION,
      RVA_PRCNTJE_DSCNTO,  RVA_PRCNTJE_RCRGO)
     VALUES(AMPARO,    RAMO,        SOLICITUD,
            POLIZA,    CLASE_POLIZA,          NMRO_IDEN,
            TPO_IDEN,    CERTIFICADO,    VALOR_ASEGURADO,
            VALOR_ASEGURADO,   PRIMA_NETA-PRIMA_NETA_ANT,    PRIMA_ANUAL-PRIMA_ANUAL_ANT,
            FECHA_NOVEDAD,  FECHA_NOVEDAD,      0,
            TIPO_TASA,    TASA,        IVA,
            TPO_DEDUCIBLE,  MNMO_DEDUCIBLE,    PORC_INDICE,
            BASE_INDICE,  USUARIO,      SYSDATE,
            PORC_DESCUENTO,        PORCENTAJE_RECARGO);
      if sql%notfound then
         RAISE_APPLICATION_ERROR(-20900, 'No se pudo insertar en RSGOS_VGNTES_AMPRO.');
      end if;
     EXCEPTION WHEN OTHERS THEN
      --MOSTRAR_MENSAJE('AQUIIII '||SQLERRM,'E',FALSE);
      RAISE_APPLICATION_ERROR(-20901, 'Error en AMPAROS_BORRADO.'||SQLERRM);
      MENSAJE:='ERROR INSERCION RSGOS_VGNTES_AMPRO';
      ROLLBACK;
      RETURN;
    END;
  END IF;

END IF;

END AMPAROS_BORRADO;


PROCEDURE REVERSO_ACTUALIZA_VALOR (NOVEDAD VARCHAR2,
                           SOLICITUD NUMBER,
                           POLIZA NUMBER,
                           CLASE_POLIZA VARCHAR2,
                           RAMO VARCHAR2,
                           CERTIFICADO NUMBER,
                           CONCEPTO VARCHAR2,
                           AMPARO VARCHAR2,
                           VALOR_ANT NUMBER,
                           VALOR NUMBER,
                           USUARIO VARCHAR2,
                           MENSAJE IN OUT VARCHAR2)
IS

  NOVEDAD_RETIRO            VARCHAR2(2):= '02';
  NOVEDAD_AUMENTO     VARCHAR2(2):='04';
  CNCPTO_VLOR            VARCHAR2(4);
  VLOR            NUMBER;
  NOVEDAD_REINGRESO         VARCHAR2(2):='05';

BEGIN
   IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) THEN
     BEGIN
       SELECT RVV_CNCPTO_VLOR,RVV_VLOR
         INTO CNCPTO_VLOR, VLOR
         FROM RSGOS_VGNTES_VLRES
        WHERE RVV_NMRO_ITEM   = SOLICITUD
          AND RVV_NMRO_PLZA   = POLIZA
          AND RVV_CLSE_PLZA   = CLASE_POLIZA
          AND RVV_RAM_CDGO    = RAMO
          AND RVV_CNCPTO_VLOR = CONCEPTO;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        MENSAJE:='LA SOLICITUD NO HA SIDO INGRESADA EN EL SEGURO '||CONCEPTO ||' '||SQLERRM;
        ROLLBACK;
        RETURN;
      END;
    UPDATE RSGOS_RCBO_VLOR
        SET RHV_VLOR    =  VALOR_ANT,
      RHV_FCHA_MDFCCION = SYSDATE,
      RHV_USRIO  = USUARIO
      WHERE RHV_NMRO_ITEM  = SOLICITUD
        AND RHV_NMRO_PLZA  = POLIZA
        AND RHV_CLSE_PLZA  = CLASE_POLIZA
        AND RHV_RAM_CDGO   = RAMO
        AND RHV_CDGO_AMPRO  = AMPARO
        AND RHV_CNCPTO_VLOR  = CONCEPTO
        AND RHV_NMRO_CRTFCDO  = CERTIFICADO;
     IF SQL%NOTFOUND THEN
  BEGIN
       INSERT INTO RSGOS_RCBO_VLOR
    ( RHV_NMRO_CRTFCDO ,  RHV_NMRO_ITEM ,    RHV_CNCPTO_VLOR ,  RHV_RAM_CDGO ,
          RHV_CDGO_AMPRO,   RHV_NMRO_PLZA ,    RHV_CLSE_PLZA ,  RHV_VLOR,
      RHV_FCHA_MDFCCION , RHV_USRIO)
       VALUES (CERTIFICADO,  SOLICITUD,      CONCEPTO,  RAMO ,
      AMPARO,        POLIZA,       CLASE_POLIZA,  VALOR_ANT,
        SYSDATE,    USUARIO);
       IF SQL%NOTFOUND THEN
         MENSAJE:='ERROR INSERCION HISTORICO RSGOS_RCBO_VLOR'||' '||SQLERRM;
         ROLLBACK;
         RETURN;
       END IF;
       EXCEPTION
       WHEN OTHERS THEN
           NULL;
       END;
    END IF;
   END IF;
IF NOVEDAD != NOVEDAD_RETIRO THEN
  --MOSTRAR_MENSAJE(VALOR_ANT||' '||VALOR,'E',FALSE);
     UPDATE RSGOS_VGNTES_VLRES
       SET  RVV_VLOR     = RVV_VLOR - VALOR_ANT + VALOR,
            RVV_USRIO    = USUARIO,
    RVV_FCHA_MDFCCION = SYSDATE
      WHERE RVV_NMRO_ITEM   = SOLICITUD
    AND RVV_NMRO_PLZA  = POLIZA
    AND RVV_CLSE_PLZA  = CLASE_POLIZA
    AND RVV_RAM_CDGO  = RAMO
          AND RVV_CNCPTO_VLOR   = CONCEPTO;
     IF SQL%NOTFOUND THEN
      IF NOVEDAD = NOVEDAD_REINGRESO THEN
       BEGIN
       INSERT INTO RSGOS_VGNTES_VLRES
               (RVV_NMRO_ITEM,    RVV_CNCPTO_VLOR   ,  RVV_RAM_CDGO ,
                 RVV_NMRO_PLZA ,  RVV_CLSE_PLZA   ,  RVV_VLOR     ,
                RVV_FCHA_MDFCCION ,  RVV_USRIO)
       SELECT  SOLICITUD ,  RHV_CNCPTO_VLOR ,    RAMO ,
               POLIZA ,   CLASE_POLIZA,    RHV_VLOR,
               SYSDATE ,  USUARIO
         FROM  RSGOS_RCBO_VLOR
        WHERE  RHV_NMRO_ITEM   = SOLICITUD
          AND  RHV_NMRO_PLZA   = POLIZA
          AND  RHV_CLSE_PLZA   = CLASE_POLIZA
          AND  RHV_RAM_CDGO   = RAMO
          AND  RHV_CNCPTO_VLOR = CONCEPTO
          AND  RHV_NMRO_CRTFCDO = CERTIFICADO;
        EXCEPTION WHEN OTHERS THEN
          MENSAJE:='VERIFIQUE EL SEGURO. PROBABLEMETE NO SE HIZO RETIRO DEL AMPARO '||AMPARO ;
          ROLLBACK;
          RETURN;

       END;
      ELSE
       BEGIN
        INSERT INTO RSGOS_VGNTES_VLRES
        (RVV_NMRO_ITEM,    RVV_NMRO_PLZA,    RVV_CLSE_PLZA,
         RVV_RAM_CDGO,    RVV_CNCPTO_VLOR,    RVV_VLOR,
         RVV_USRIO,    RVV_FCHA_MDFCCION)
        VALUES(SOLICITUD,  POLIZA,      CLASE_POLIZA,
               RAMO,    CONCEPTO,      VALOR,
               USUARIO,    SYSDATE);
        EXCEPTION WHEN OTHERS THEN
          MENSAJE:='ERROR EN RIESGOS VIGENTES VALORES'||' '||SQLERRM;
          ROLLBACK;
          RETURN;
        END;
       END IF;
     END IF;
 END IF;

END REVERSO_ACTUALIZA_VALOR;



PROCEDURE REVERSO_RETROACTIVIDAD(FECHA_LIQUIDACION IN OUT DATE, PERIODO IN VARCHAR2,
PRIMA_NETA IN NUMBER, PRIMA_ANUAL IN NUMBER, PRIMA_TOTAL IN NUMBER, IVA_PRIMA IN NUMBER,
PRIMA_NETA_ANT IN NUMBER, PRIMA_ANUAL_ANT IN NUMBER, PRIMA_TOTAL_ANT IN NUMBER,
IVA_PRIMA_ANT IN NUMBER,DESCUENTO IN NUMBER, DESCUENTO_ANT IN NUMBER,PRIMA_RETRO_NETA IN OUT NUMBER, PRIMA_RETRO_ANUAL IN OUT NUMBER,
PRIMA_RETRO_TOTAL IN OUT NUMBER, IVA_RETRO IN OUT NUMBER,
PRIMA_RETRO_NETA_ANT IN OUT NUMBER, PRIMA_RETRO_ANUAL_ANT IN OUT NUMBER,
PRIMA_RETRO_TOTAL_ANT IN OUT NUMBER,IVA_RETRO_ANT IN OUT NUMBER, MODULO IN VARCHAR2, CESION IN VARCHAR2,
MENSAJE IN OUT VARCHAR2,NOVEDAD IN VARCHAR2)
IS

 NOVEDAD_RETIRO VARCHAR2(2):= '02';
 MESES NUMBER;
 FECHA_ACTUAL DATE;
 DIA VARCHAR2(2);
 MES VARCHAR2(2);
 ANO VARCHAR2(4);

BEGIN
    /*********************************************************************************************/
    /* CALCULAR SI EXISTE RETROACTIVIDAD PARA LA LIQUIDACION DE LAS PRIMAS*/
  /*********************************************************************************************/

MESES := 0;
IF NOVEDAD != NOVEDAD_RETIRO THEN
  IF PRIMA_ANUAL != 0 THEN
   IF  TO_DATE(TO_CHAR(FECHA_LIQUIDACION,'MMYYYY'),'MMYYYY') < TO_DATE(PERIODO,'MMYYYY') THEN
     FECHA_ACTUAL := TO_DATE('01'||'/'||SUBSTR(PERIODO,1,2)||'/'||SUBSTR(PERIODO,3,4),'DD/MM/YYYY');
     FECHA_ACTUAL := LAST_DAY(FECHA_ACTUAL);
     meses := FU_RESTA_MES30(FECHA_ACTUAL,FECHA_LIQUIDACION,MENSAJE)/30;
     PRIMA_RETRO_NETA := PRIMA_NETA * (MESES - 1);
     PRIMA_RETRO_ANUAL := PRIMA_ANUAL * (MESES - 1);
     PRIMA_RETRO_TOTAL := PRIMA_TOTAL * (MESES - 1);
     IVA_RETRO         := IVA_PRIMA * (MESES - 1);
     PRIMA_RETRO_NETA_ANT := PRIMA_NETA_ANT * (MESES - 1);
     PRIMA_RETRO_ANUAL_ANT := PRIMA_ANUAL_ANT * (MESES - 1);
     PRIMA_RETRO_TOTAL_ANT := PRIMA_TOTAL_ANT * (MESES - 1);
     IVA_RETRO_ANT         := IVA_PRIMA_ANT * (MESES - 1);
     DIA := TO_CHAR(FECHA_LIQUIDACION,'DD');
     MES := TO_CHAR(FECHA_LIQUIDACION,'MM');
     ANO := TO_CHAR(FECHA_LIQUIDACION,'YYYY');
     FECHA_LIQUIDACION := TO_DATE(DIA||'/'||MES||'/'||ANO||' '||'01:01:00','DD/MM/YYYY HH:MI:SS');
    IF MODULO = '3' THEN
      IF PRIMA_NETA < PRIMA_NETA_ANT THEN
        PRIMA_RETRO_NETA := 0;
        PRIMA_RETRO_ANUAL := 0;
        PRIMA_RETRO_TOTAL := 0;
        IVA_RETRO         := 0;
        PRIMA_RETRO_NETA_ANT := 0;
        PRIMA_RETRO_ANUAL_ANT := 0;
        PRIMA_RETRO_TOTAL_ANT := 0;
        IVA_RETRO_ANT         := 0;
        FECHA_LIQUIDACION := FECHA_LIQUIDACION;
       END IF;
    END IF;
    IF CESION = 'SI' THEN
        PRIMA_RETRO_NETA := 0;
        PRIMA_RETRO_ANUAL := 0;
        PRIMA_RETRO_TOTAL := 0;
        IVA_RETRO         := 0;
        PRIMA_RETRO_NETA_ANT := 0;
        PRIMA_RETRO_ANUAL_ANT := 0;
        PRIMA_RETRO_TOTAL_ANT := 0;
        IVA_RETRO_ANT         := 0;
    END IF;
   ELSIF TO_DATE(TO_CHAR(FECHA_LIQUIDACION,'MMYYYY'),'MMYYYY') > TO_DATE(PERIODO,'MMYYYY') THEN
     MENSAJE :='La fecha de la Novedad no puede ser mayor al periodo actual.';
   END IF;
  END IF;
ELSE
  IF PRIMA_ANUAL_ANT != 0 THEN
   IF  TO_DATE(TO_CHAR(FECHA_LIQUIDACION,'MMYYYY'),'MMYYYY') < TO_DATE(PERIODO,'MMYYYY') THEN
     FECHA_ACTUAL := TO_DATE('01'||'/'||SUBSTR(PERIODO,1,2)||'/'||SUBSTR(PERIODO,3,4),'DD/MM/YYYY');
     FECHA_ACTUAL := LAST_DAY(FECHA_ACTUAL);
     meses := FU_RESTA_MES30(FECHA_ACTUAL,FECHA_LIQUIDACION,MENSAJE)/30;
     PRIMA_RETRO_NETA := PRIMA_NETA * (MESES - 1);
     PRIMA_RETRO_ANUAL := PRIMA_ANUAL * (MESES - 1);
     PRIMA_RETRO_TOTAL := PRIMA_TOTAL * (MESES - 1);
     IVA_RETRO         := IVA_PRIMA * (MESES - 1);
     PRIMA_RETRO_NETA_ANT := PRIMA_NETA_ANT * (MESES - 1);
     PRIMA_RETRO_ANUAL_ANT := PRIMA_ANUAL_ANT * (MESES - 1);
     PRIMA_RETRO_TOTAL_ANT := PRIMA_TOTAL_ANT * (MESES - 1);
     IVA_RETRO_ANT         := IVA_PRIMA_ANT * (MESES - 1);
     DIA := TO_CHAR(FECHA_LIQUIDACION,'DD');
     MES := TO_CHAR(FECHA_LIQUIDACION,'MM');
     ANO := TO_CHAR(FECHA_LIQUIDACION,'YYYY');
     FECHA_LIQUIDACION := TO_DATE(DIA||'/'||MES||'/'||ANO||' '||'01:01:00','DD/MM/YYYY HH:MI:SS');
    IF MODULO = '3' THEN
      IF PRIMA_NETA < PRIMA_NETA_ANT THEN
        PRIMA_RETRO_NETA := 0;
        PRIMA_RETRO_ANUAL := 0;
        PRIMA_RETRO_TOTAL := 0;
        IVA_RETRO         := 0;
        PRIMA_RETRO_NETA_ANT := 0;
        PRIMA_RETRO_ANUAL_ANT := 0;
        PRIMA_RETRO_TOTAL_ANT := 0;
        IVA_RETRO_ANT         := 0;
        FECHA_LIQUIDACION := FECHA_LIQUIDACION;
       END IF;
    END IF;
    IF CESION = 'SI' THEN
        PRIMA_RETRO_NETA := 0;
        PRIMA_RETRO_ANUAL := 0;
        PRIMA_RETRO_TOTAL := 0;
        IVA_RETRO         := 0;
        PRIMA_RETRO_NETA_ANT := 0;
        PRIMA_RETRO_ANUAL_ANT := 0;
        PRIMA_RETRO_TOTAL_ANT := 0;
        IVA_RETRO_ANT         := 0;
    END IF;
   ELSIF TO_DATE(TO_CHAR(FECHA_LIQUIDACION,'MMYYYY'),'MMYYYY') > TO_DATE(PERIODO,'MMYYYY') THEN
     MENSAJE :='La fecha de la Novedad no puede ser mayor al periodo actual.';
   END IF;
  END IF;
END IF;

END REVERSO_RETROACTIVIDAD;


PROCEDURE REVERSO_NOVEDADES(SOLICITUD IN NUMBER ,  POLIZA IN NUMBER ,  CLASE_POLIZA IN VARCHAR2 ,
  RAMO IN VARCHAR2 ,  SUCURSAL IN VARCHAR2,  COMPANIA  IN VARCHAR2,  FECHA_NOVEDAD IN OUT DATE ,
  AMPARO IN VARCHAR2 ,  CONCEPTO IN VARCHAR2 ,  VALOR_ANT IN NUMBER ,  CERTIFICADO IN NUMBER ,
  VALOR IN NUMBER ,    NOVEDAD IN VARCHAR2 ,  ENTRO IN OUT NUMBER ,  MODULO IN VARCHAR2,
  MENSAJE IN  OUT VARCHAR2 ,  USUARIO IN VARCHAR2,  CESION  IN VARCHAR2,  COBRAR  in VARCHAR2,
  NOVEDAD_REVERSO VARCHAR2) IS

     PERIODO            VARCHAR2(6);
   MENSAJE2           VARCHAR2(1000);
   TPO_IDEN           VARCHAR2(2);
   IVA                PLZAS.POL_PRCNTJE_IVA%TYPE;
   NMRO_IDEN          PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
   TASA_GENERAL       NUMBER(5,3);
   TASA               NUMBER(8,5);
   VALOR_ASEGURADO    NUMBER(16,2);
   DIAS_PERIODO       NUMBER(2) := 30;
   DIAS_VIGENCIA      NUMBER(2) := 30;
   PRORRATA           NUMBER(10,5);
   TIPO_TASA          VARCHAR2(1);
   DESCUENTO          NUMBER(4,2);
   TIPO_VALOR         VARCHAR2(1);
   VALOR_BASE         VARCHAR2(4);
   SUMA               VARCHAR2(1):='S';
   SMTRIA_RSGO        VARCHAR2(1) := 'N';
   SMTRIA_PLZA        VARCHAR2(1) := 'N';
   TIENE_DEDUCIBLE    VARCHAR2(1) := 'N';
   PORC_DEDUCIBLE     NUMBER := 0;
   TPO_DEDUCIBLE      VARCHAR2(5);
   FECHA              DATE;
   CUOTAS             NUMBER   := 0;
   PRIMA_NETA         NUMBER:=0;
   MNMO_DEDUCIBLE     NUMBER := 0;
   PRIMA_NETA_ANUAL   NUMBER:=0;
   PRIMA_ANUAL        NUMBER:=0;
   PRIMA_ANUAL_ANT    NUMBER:=0;
   PRIMA_NETA_ANT     NUMBER := 0;
   PRIMA_TOTAL        NUMBER:=0;
   PRIMA_TOTAL_ANT    NUMBER:=0;
   PRIMA_TTAL_ANT     NUMBER := 0;
   IVA_PRIMA          NUMBER:=0;
   IVA_PRIMA_ANT      NUMBER:=0;
   RETRO_NETA         NUMBER:=0;
   RETRO_ANUAL        NUMBER:=0;
   RETRO_TOTAL        NUMBER:=0;
   IVA_RETRO          NUMBER:=0;
   RETRO_NETA_ANT     NUMBER:=0;
   RETRO_ANUAL_ANT    NUMBER:=0;
   RETRO_TOTAL_ANT    NUMBER:=0;
   RETRO_DESCUENTO    NUMBER :=0;
   RETRO_DESCUENTO_ANT NUMBER:= 0;
   IVA_RETRO_ANT       NUMBER:=0;
   VALOR_ASEGURADO_ANT NUMBER:=0;
   VALOR_DESCUENTO     NUMBER:=0;
   VALOR_DESCUENTO_ANT NUMBER:=0;
   PRIMER              VARCHAR2(10);
   PRIMER_DIA          DATE;
   ULTIMO_DIA          DATE;
   DIAS_MES            NUMBER;
   PORC_DESCUENTO      NUMBER:=0;
   NOVEDAD_AUMENTO     VARCHAR2(2):='04';


   CURSOR TASAS (AMPARO VARCHAR2) IS
      SELECT TAP_TSA_BSCA, TAP_TPO_TSA, TAP_DSCNTO_TMDOR, TAP_NMRO_CUOTAS
       FROM TRFA_AMPROS_PRDCTO
      WHERE TAP_CDGO_AMPRO = AMPARO
        AND TAP_RAM_CDGO = RAMO
        AND TAP_SUC_CDGO = SUCURSAL
        AND TAP_CIA_CDGO = COMPANIA
        AND TAP_TPO_PLZA = 'C';

   CURSOR VALORES (VALOR VARCHAR2) IS
      SELECT VPR_TPO_VLOR, VPR_SMTORIA_RSGO_SN, VPR_SMTORIA_PLZA_SN,VPR_VLOR_BASE
        FROM VLRES_PRDCTO
       WHERE VPR_CDGO = VALOR
       AND VPR_RAM_CDGO = RAMO;

    CURSOR VALORES_NOVEDADES  IS
      SELECT MAX(RVNV_FCHA_NVDAD), RVNV_CNCPTO_VLOR, RVNV_VLOR, RVNV_USRIO, RVNV_FCH_MDFCCION
        FROM RSGOS_VGNTES_NVLOR
        WHERE RVNV_CDGO_AMPRO = AMPARO
       AND RVNV_RAM_CDGO  = RAMO
      AND RVNV_NMRO_ITEM = SOLICITUD
     AND RVNV_NMRO_PLZA = POLIZA
          AND RVNV_CLSE_PLZA = CLASE_POLIZA
     GROUP BY RVNV_FCHA_NVDAD, RVNV_CNCPTO_VLOR, RVNV_VLOR,
           RVNV_USRIO, RVNV_FCH_MDFCCION;
  BEGIN

  -- Asignar prorrata
     PRORRATA :=TRUNC(DIAS_VIGENCIA / DIAS_PERIODO,5);
  -- Trae numero identificacion inquilino principal
    BEGIN
      SELECT ARR_TPO_IDNTFCCION, ARR_NMRO_IDNTFCCION INTO TPO_IDEN, NMRO_IDEN
        FROM ARRNDTRIOS
       WHERE ARR_NMRO_SLCTUD = SOLICITUD;
      EXCEPTION WHEN NO_DATA_FOUND THEN
       MENSAJE:='NO SE PUEDE ENCONTRAR EL ARRENDATARIO DE LA SOLICITUD';
       RETURN;
    END;
  -- Periodo Actual
    PERIODO := BUSCAR_PERIODO(MENSAJE2);
    IF MENSAJE2 IS NOT NULL THEN
       MENSAJE := MENSAJE2;
       RETURN;
    END IF;
    PRIMER := '01'||PERIODO;
    PRIMER_DIA := TO_DATE(PRIMER,'DDMMYYYY');
    ULTIMO_DIA := LAST_DAY(PRIMER_DIA);
    DIAS_MES   := TO_NUMBER(TO_CHAR(ULTIMO_DIA,'DD'));
  -- Trae el ultimo certificado abierto para la poliza de la solicitud
  -- Busqueda tasas para cada amparo
      OPEN TASAS (AMPARO);
      FETCH TASAS INTO TASA_GENERAL, TIPO_TASA, DESCUENTO,CUOTAS;
      IF TASAS%NOTFOUND THEN
          MENSAJE:='ERROR EN LA TASA DEL AMPARO '|| AMPARO ||sqlerrm;
          ROLLBACK;
          RETURN;
      END IF;
      CLOSE TASAS;
      IF TASA != 0 THEN
        TASA_GENERAL := TASA;
      END IF;
  -- Determinar que valores suman al riesgo y a la poliza
       OPEN VALORES(CONCEPTO);
       FETCH VALORES INTO  TIPO_VALOR, SMTRIA_RSGO,SMTRIA_PLZA,
       VALOR_BASE;
       IF VALORES%NOTFOUND THEN
         MENSAJE:='ERROR EN DATOS DEL VALOR '|| CONCEPTO;
         ROLLBACK;
         RETURN;
       END IF;
       CLOSE VALORES;
       VALOR_ASEGURADO  := VALOR;
       VALOR_ASEGURADO_ANT := VALOR_ANT;
  -- Trae deducibles del amparo y si se suman para el valor asegurado
     BEGIN
      SELECT APR_SMA_VLOR_ASGRDO_SN, APR_TNE_DDCBLE_SN, APR_PRCNTJE_DDCBLE
             ,APR_TPO_DDCBLE,
             APR_VLOR_DDCBLE_MNMO
       INTO SUMA, TIENE_DEDUCIBLE, PORC_DEDUCIBLE, TPO_DEDUCIBLE,
            MNMO_DEDUCIBLE
       FROM AMPROS_PRDCTO
       WHERE APR_CDGO_AMPRO = AMPARO;
       EXCEPTION WHEN NO_DATA_FOUND THEN
        MENSAJE:='ERROR EN AMPARO '|| AMPARO ;
        ROLLBACK;
        RETURN;
     END;
  -- Trae el porcentaje de IVA definido
    BEGIN
     SELECT PAR_VLOR2 INTO IVA
       FROM PRMTROS
      WHERE PAR_CDGO = '4'
        AND PAR_MDLO = '6'
        AND PAR_VLOR1= '01'
        AND PAR_FCHA_CREACION = (SELECT MAX(PAR_FCHA_CREACION) FROM PRMTROS
                  WHERE PAR_VLOR1='01'
                                AND PAR_MDLO='6'
                   AND PAR_CDGO='4');
     EXCEPTION WHEN NO_DATA_FOUND THEN
       MENSAJE:='ERROR EN LA BUSQUEDA DEL IVA';
       ROLLBACK;
       RETURN;
     WHEN OTHERS THEN
       MENSAJE:='ERROR EN LA BUSQUEDA DEL IVA';
       ROLLBACK;
       RETURN;
    END;

  -- Calculo de las primas para el amparo
    PKG_OPERACION.PRC_LIQUIDACION(SOLICITUD,RAMO,POLIZA,FECHA_NOVEDAD,CLASE_POLIZA,AMPARO,CONCEPTO,
            VALOR_ANT,VALOR,IVA,PERIODO,USUARIO,PRIMA_NETA_ANT, PRIMA_NETA,PRIMA_TOTAL_ANT,
            PRIMA_TOTAL,PRIMA_ANUAL_ANT,PRIMA_ANUAL,IVA_PRIMA_ANT,IVA_PRIMA,PORC_DESCUENTO,
            CUOTAS,MENSAJE2,TASA,tipo_tasa,null,null,SUCURSAL,COMPANIA,novedad_reverso);
    IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
    END IF;

-- traer la fecha de retiro de la solicitud.
   TRAER_FECHA_RETIRO(FECHA_NOVEDAD,PERIODO,SOLICITUD,RAMO,POLIZA,CLASE_POLIZA,AMPARO,NOVEDAD,MENSAJE);

-- verificar si la fecha de la novedad es anterior  a la del periodo actual, para calcular
-- la prima retroactiva.
   REVERSO_RETROACTIVIDAD(FECHA_NOVEDAD,PERIODO,PRIMA_NETA,PRIMA_ANUAL,PRIMA_TOTAL,IVA_PRIMA,
   PRIMA_NETA_ANT,PRIMA_ANUAL_ANT,PRIMA_TOTAL_ANT,IVA_PRIMA_ANT,VALOR_DESCUENTO,VALOR_DESCUENTO_ANT,
   RETRO_NETA,RETRO_ANUAL,RETRO_TOTAL,IVA_RETRO,RETRO_NETA_ANT,RETRO_ANUAL_ANT,RETRO_TOTAL_ANT,
   IVA_RETRO_ANT,MODULO,CESION,MENSAJE2,NOVEDAD);
   IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
   END IF;



  -- Ingreso novedades segun el tipo
     PKG_OPERACION.PRC_INGRESOS(NOVEDAD,SOLICITUD,POLIZA,CLASE_POLIZA,RAMO,FECHA_NOVEDAD
  ,CERTIFICADO,
              NMRO_IDEN,TPO_IDEN,VALOR_ASEGURADO,VALOR_ANT,VALOR,PRIMA_NETA_ANT,
              PRIMA_NETA,PRIMA_ANUAL_ANT,PRIMA_ANUAL,ENTRO,USUARIO,MENSAJE2);
   IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
   END IF;


  -- Actualiza valores del riesgo
      REVERSO_ACTUALIZA_VALOR(NOVEDAD,SOLICITUD,POLIZA,CLASE_POLIZA,RAMO,CERTIFICADO
  ,CONCEPTO,AMPARO,VALOR_ANT,VALOR,USUARIO,MENSAJE2);
   IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
   END IF;

--   Actualiza el concepto que agrupa el valor
     PKG_OPERACION.PRC_ACTUALIZA_VALORES(NOVEDAD,SOLICITUD,POLIZA,CLASE_POLIZA,RAMO,CERTIFICADO
  ,CONCEPTO,
                       AMPARO,VALOR_ANT,VALOR,ENTRO,USUARIO,MENSAJE2);
   IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
   END IF;


  -- Ingresa arrendatarios en el riesgo
     PKG_OPERACION.PRC_ARRENDATARIOS(NOVEDAD,SOLICITUD,POLIZA,CLASE_POLIZA,RAMO,AMPARO,CONCEPTO,CERTIFICADO
  ,ENTRO,
                USUARIO,MENSAJE2);
   IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
   END IF;


  -- Crea el valor para el amparo
     AMPAROS_BORRADO(NOVEDAD,SOLICITUD,POLIZA,CLASE_POLIZA,RAMO,AMPARO,CERTIFICADO
    ,VALOR_ASEGURADO_ANT,
             VALOR_ASEGURADO,PRIMA_NETA_ANT,PRIMA_NETA,PRIMA_NETA_ANUAL
               ,PRIMA_ANUAL_ANT,
             PRIMA_ANUAL,TIPO_TASA,TASA,TPO_DEDUCIBLE,PORC_DEDUCIBLE
  ,MNMO_DEDUCIBLE,TPO_IDEN,
             NMRO_IDEN,PORC_DESCUENTO,IVA,ENTRO,USUARIO,FECHA_NOVEDAD,MENSAJE2);

   IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
   END IF;



-- Actualiza los valores para el amparo
      ACTUALIZA_AMPAROS_BORRADO(NOVEDAD,SOLICITUD,POLIZA,CLASE_POLIZA,RAMO,CONCEPTO
  ,CERTIFICADO,
                        AMPARO,VALOR_ANT,VALOR,USUARIO,MENSAJE2);
   IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
   END IF;


  -- Actualizar valores asegurados y de primas para los ingresos al seguro

begin
     REVERSO_VALORES_PRIMAS(NOVEDAD,POLIZA,CLASE_POLIZA,RAMO,AMPARO,CERTIFICADO,SOLICITUD,
  PRIMA_NETA_ANT,
                    PRIMA_NETA,PRIMA_TOTAL_ANT,PRIMA_TOTAL,PRIMA_ANUAL_ANT
  ,PRIMA_ANUAL,
                    VALOR_ASEGURADO_ANT,VALOR_ASEGURADO,IVA,IVA_PRIMA_ANT
  ,IVA_PRIMA,RETRO_NETA,RETRO_ANUAL,
   RETRO_TOTAL,IVA_RETRO,RETRO_NETA_ANT,RETRO_ANUAL_ANT,RETRO_TOTAL_ANT,IVA_RETRO_ANT,PERIODO,CUOTAS,
                    ENTRO,USUARIO,MENSAJE2,CESION,NOVEDAD_REVERSO);



   IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
   END IF;

    EXCEPTION
       WHEN OTHERS THEN
          MENSAJE:='ERROR EN ACTUALIZACION NOVEDADES CERTIFICADO'||' '||SQLERRM;
    ROLLBACK;
    RETURN;
    END;


      BORRAR_REGISTROS(NOVEDAD,SOLICITUD,POLIZA,CLASE_POLIZA,RAMO,CONCEPTO
  ,AMPARO);

     insertar_auditoria('RSGOS_VGNTES_AVLOR','CNCPTO_VLO',NOVEDAD,to_char(solicitud),NULL,NULL,NULL,NULL,
     NULL,NULL,NULL,CONCEPTO,TO_CHAR(VALOR_ANT),TO_CHAR(VALOR),MODULO,
     USUARIO,SYSDATE,'BORRADO DE NOVEDADES',MENSAJE);

  END REVERSO_NOVEDADES;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 13/03/2014
  --  METODO_AUMENTOS_SIN
  -- Purpose : Crear la tabla de aumentos de cada contrato del seguro.
  -- Para que quede los aumentos anuales que un riesgo debería tener.
  -- de acuerdo a un procentaje ya que no existen los datos del contrato
  -- de arrendamiento.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE METODO_AUMENTOS_SIN (P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE) IS

     CURSOR C_SOLICITUDES IS
        SELECT R.RVI_NMRO_ITEM SOLICITUD ,R.RVI_NMRO_PLZA POLIZA,R.RVI_CLSE_PLZA CLASE,
               R.RVI_RAM_CDGO RAMO, A.RVL_CNCPTO_VLOR CONCEPTO
          FROM RSGOS_VGNTES R, RSGOS_VGNTES_AVLOR A
         WHERE R.RVI_NMRO_ITEM = P_SOLICITUD
           AND R.RVI_NMRO_ITEM = A.RVL_NMRO_ITEM
           AND A.RVL_CDGO_AMPRO ='01'
         ORDER BY R.RVI_NMRO_ITEM;

     R_SOL                      C_SOLICITUDES%ROWTYPE;
     V_PORCENTAJE               NUMBER;
     V_FECHA_INGRESO            DATE;
     V_VALOR                    NUMBER;
     V_FECHA                    DATE;
     V_AÑO                      NUMBER;
     V_SECUENCIA                NUMBER;
     V_VALOR_CANON              NUMBER;
     V_VALOR_CUOTA              NUMBER;
     V_SECUENCIA_CON            NUMBER;

  BEGIN

      SELECT PAR_VLOR2
        INTO V_PORCENTAJE
        FROM PRMTROS
       WHERE PAR_CDGO = '2'
         AND PAR_MDLO = '2'
         AND PAR_VLOR1 = 9
         AND PAR_SUC_CDGO = '2501'
         AND PAR_SUC_CIA_CDGO = '40';



     SELECT SEQ_CONTRATOS.NEXTVAL INTO V_SECUENCIA_CON FROM DUAL;
     open C_SOLICITUDES;
     loop
       fetch C_SOLICITUDES into R_SOL;
       exit when C_SOLICITUDES%notfound;
          V_FECHA_INGRESO := FECHA_INGRESO_SEG(R_SOL.SOLICITUD,R_SOL.POLIZA, R_SOL.CLASE, R_SOL.RAMO,'01');

           -- BUSCA EL VALOR DEL CONCEPTO CON EL CUAL SE INGRESO EL RIESGO.


           V_VALOR := NVL(FUN_VALOR_INGRESO( R_SOL.SOLICITUD,'01',R_SOL.CONCEPTO),0);
           IF R_SOL.CONCEPTO = '01' THEN
             V_VALOR_CANON := V_VALOR;
           ELSE
             V_VALOR_CUOTA := V_VALOR;
           END IF;

           IF R_SOL.CONCEPTO = '01' THEN
             INSERT INTO DATOS_CONTRATOS
             VALUES(V_SECUENCIA_CON,P_SOLICITUD,R_SOL.POLIZA,R_SOL.CLASE,R_SOL.RAMO,V_FECHA_INGRESO,12,12,
             V_VALOR_CANON,2,V_PORCENTAJE,USER,SYSDATE,V_VALOR_CUOTA,2,V_PORCENTAJE,V_FECHA_INGRESO,NULL,NULL,'N','N');
           ELSE
             UPDATE DATOS_CONTRATOS
                SET CUOTA_INICIAL = V_VALOR_CUOTA
              WHERE SECUENCIA_CONTRATO = V_SECUENCIA_CON;
           END IF;

          IF V_VALOR > 0 THEN
            SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;
            INSERT INTO AUMENTOS_CONTRATOS
            VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_SOL.CONCEPTO,V_FECHA_INGRESO,V_VALOR,0,V_VALOR,0,'S',USER,SYSDATE,NULL,NULL);

            -- DEBE CREAR LA TABLA DE AUMENTOS PARA CADA RIESGO ASEGURADO.
            V_FECHA := ADD_MONTHS(V_FECHA_INGRESO,12);
            V_AÑO := TO_NUMBER(TO_CHAR(V_FECHA,'YYYY'));

            WHILE V_AÑO <= TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) LOOP

              V_VALOR := ROUND(V_VALOR + (V_VALOR * V_PORCENTAJE/100),0);
              SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;

              INSERT INTO AUMENTOS_CONTRATOS
              VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_SOL.CONCEPTO,V_FECHA,ROUND(V_VALOR,0),0,ROUND(V_VALOR,0),V_PORCENTAJE,'S',USER,SYSDATE,NULL,NULL);

              V_AÑO := V_AÑO + 1;
              V_FECHA := ADD_MONTHS(V_FECHA,12);

            END LOOP;

          END IF;
     end loop;
     close C_SOLICITUDES;

  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 13/03/2014
  --  METODO_AUMENTOS_CON
  -- Purpose : Crear la tabla de aumentos de cada contrato del seguro.
  -- cuando tiene los datos del contrato de arrendamiento.
  -- Para que queden los aumentos anuales que un riesgo debería tener.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE METODO_AUMENTOS_CONTRATO (P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                      P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE) IS

     CURSOR C_SOLICITUDES IS
        SELECT R.RVI_NMRO_ITEM SOLICITUD ,R.RVI_NMRO_PLZA POLIZA,R.RVI_CLSE_PLZA CLASE,
               R.RVI_RAM_CDGO RAMO, A.RVL_CNCPTO_VLOR CONCEPTO
          FROM RSGOS_VGNTES R, RSGOS_VGNTES_AVLOR A
         WHERE R.RVI_NMRO_ITEM = P_SOLICITUD
           AND R.RVI_NMRO_ITEM = A.RVL_NMRO_ITEM
           AND A.RVL_CDGO_AMPRO ='01'
           AND A.RVL_CNCPTO_VLOR = P_CONCEPTO
         ORDER BY R.RVI_NMRO_ITEM;

  CURSOR AUMENTO(AÑO_P NUMBER, TIPO VARCHAR2) IS
    SELECT PAR_VLOR2
      FROM PRMTROS
     WHERE PAR_CDGO = '1'
       AND PAR_MDLO = '3'
       AND PAR_VLOR1 = TIPO
       AND TO_NUMBER(TO_CHAR(PAR_FCHA_CREACION, 'YYYY')) = AÑO_P;


     R_SOL                      C_SOLICITUDES%ROWTYPE;
     V_PORCENTAJE               NUMBER;
     V_FECHA_INGRESO            DATE;
     V_VALOR                    NUMBER;
     V_FECHA                    DATE;
     V_AÑO                      NUMBER;
     V_SECUENCIA                NUMBER;
     V_VALOR_CANON              NUMBER;
     V_VALOR_CUOTA              NUMBER;
     V_SECUENCIA_CON            NUMBER;
     V_FECHA_INICIO             DATE;
     V_PER_INICIAL              NUMBER;
     V_PER_PRORROGA             NUMBER;
     V_CANON_I                  NUMBER;
     V_TIPO_CANON               NUMBER;
     V_PORC_CANON               NUMBER;
     V_CUOTA_I                  NUMBER;
     V_TIPO_CUOTA               NUMBER;
     V_PORC_CUOTA               NUMBER;
     V_INICIO_CUOTA             DATE;
     V_DESTINO                  SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE;
     V_IMPUESTO                 VARCHAR2(6);
     V_IVA                      NUMBER;
     V_TIPO                     NUMBER;
     V_INDICADOR                NUMBER;
     V_TASA                NUMBER;


  BEGIN


     BEGIN
       SELECT D.FECHA_INICIO_CONTRATO, D.PERIODO_INICIAL, D.PERIODO_PORROGA, D.CANON_INICIAL,
              D.TIPO_AUMENTO_CANON, D.MONTO_AUMENTO_CANON, D.CUOTA_INICIAL, D.TIPO_AUMENTO_CUOTA,
              D.MONTO_AUMENTO_CUOTA, D.FECHA_INICIO_CUOTA, D.SECUENCIA_CONTRATO,
              S.SES_DSTNO_INMBLE
         INTO V_FECHA_INICIO,V_PER_INICIAL,V_PER_PRORROGA,V_CANON_I,V_TIPO_CANON,V_PORC_CANON,
              V_CUOTA_I,V_TIPO_CUOTA,V_PORC_CUOTA,V_INICIO_CUOTA,V_SECUENCIA_CON,
              V_DESTINO
         FROM DATOS_CONTRATOS D, ARRNDTRIOS A, SLCTDES_ESTDIOS S
        WHERE D.SOLICITUD = P_SOLICITUD
          AND D.SOLICITUD = A.ARR_NMRO_SLCTUD
          AND A.ARR_SES_NMRO = S.SES_NMRO;

        open C_SOLICITUDES;
        loop
          fetch C_SOLICITUDES into R_SOL;
          exit when C_SOLICITUDES%notfound;

           IF V_DESTINO = 'C' THEN
              V_IMPUESTO := 'IVAC';
           ELSIF V_DESTINO = 'V' THEN
             V_IMPUESTO := 'IVAR';
           ELSE
            V_IMPUESTO := 'SD';
           END IF;

           IF R_SOL.CONCEPTO = '01' THEN

             IF V_CANON_I = 0 THEN
               V_VALOR := NVL(FUN_VALOR_INGRESO( R_SOL.SOLICITUD,'01',R_SOL.CONCEPTO),0);
             ELSE
               V_VALOR := V_CANON_I;
             END IF;

             IF V_FECHA_INICIO IS NOT NULL THEN
               V_FECHA_INGRESO :=  V_FECHA_INICIO;  --mantis # 31037 GGM. V_INICIO_CUOTA;
             ELSE
               V_FECHA_INGRESO := FECHA_INGRESO_SEG(R_SOL.SOLICITUD,R_SOL.POLIZA, R_SOL.CLASE, R_SOL.RAMO,'01');
             END IF;

           ELSE
             IF V_CUOTA_I = 0 THEN
               V_VALOR := NVL(FUN_VALOR_INGRESO( R_SOL.SOLICITUD,'01',R_SOL.CONCEPTO),0);
             ELSE
               V_VALOR := V_CUOTA_I;

             END IF;

             IF V_FECHA_INICIO IS NOT NULL THEN
               V_FECHA_INGRESO :=  V_FECHA_INICIO;  -- Mantis # 31037 GGM. 31/10/2014 --V_INICIO_CUOTA;
             ELSE
               V_FECHA_INGRESO := FECHA_INGRESO_SEG(R_SOL.SOLICITUD,R_SOL.POLIZA, R_SOL.CLASE, R_SOL.RAMO,'01');
             END IF;

           END IF;


          IF V_VALOR > 0 THEN
            SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;
            BEGIN
              INSERT INTO AUMENTOS_CONTRATOS
                VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_SOL.CONCEPTO,V_FECHA_INGRESO,V_VALOR,0,V_VALOR,0,'S',USER,SYSDATE,NULL,NULL);
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20522,SQLERRM);
            END;
            -- DEBE CREAR LA TABLA DE AUMENTOS PARA CADA RIESGO ASEGURADO.
            V_FECHA := ADD_MONTHS(V_FECHA_INGRESO,V_PER_PRORROGA);
            V_AÑO := TO_NUMBER(TO_CHAR(V_FECHA,'YYYY'));
            WHILE V_AÑO <= TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) LOOP



-- Modificar F. Rey R.  Cuando se incluye reingreso y no tiene definido aumento de cuota.
-- Mantis 37698

              IF R_SOL.CONCEPTO = '01' THEN
                V_TIPO       := V_TIPO_CANON;
                V_PORCENTAJE := V_PORC_CANON;
              ELSE
                V_TIPO       := NVL(V_TIPO_CUOTA, V_TIPO_CANON);
                V_PORCENTAJE := NVL(V_PORC_CUOTA, V_PORC_CANON);
              END IF;



              OPEN AUMENTO(V_AÑO, V_TIPO);
                FETCH AUMENTO
                  INTO V_INDICADOR;
                IF AUMENTO%NOTFOUND THEN
                  RAISE_APPLICATION_ERROR(-20502,'error al calcular la proyección de aumentos del canon, no existe el valor de aumento para un año estipulado.');
                  EXIT;
                ELSE
                  IF V_INDICADOR = 0 THEN
                    V_VALOR      := ROUND(V_VALOR + ((V_VALOR * V_PORCENTAJE) / 100),2);
                    V_TASA := V_PORCENTAJE;
                    IF V_FECHA >= TO_DATE('01/08/2004','DD/MM/YYYY') THEN
                      IF V_TIPO != '10' THEN
                        V_IVA         := ROUND(V_VALOR * (RETORNA_TASA_IMP(V_IMPUESTO, V_FECHA) / 100), 0);
                      ELSE
                        V_IVA := 0;
                      END IF;

                    ELSE
                      V_IVA := 0;
                    END IF;
                  ELSE
                    V_VALOR      := ROUND(V_VALOR + ((V_VALOR * ROUND(((V_INDICADOR * V_PORCENTAJE) / 100),2)) / 100),4);
                    V_TASA  := ((V_INDICADOR * V_PORCENTAJE) / 100);
                    IF V_FECHA >= TO_DATE('01/08/2004','DD/MM/YYYY') THEN
                      IF V_TIPO != '10' THEN
                       V_IVA         := ROUND(V_VALOR * (RETORNA_TASA_IMP(V_IMPUESTO, V_FECHA) / 100), 0);
                      ELSE
                        V_IVA := 0;
                      END IF;

                    ELSE
                      V_IVA := 0;
                    END IF;
                  END IF;

                END IF;
             CLOSE AUMENTO;

             SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;

             INSERT INTO AUMENTOS_CONTRATOS
             VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_SOL.CONCEPTO,V_FECHA,
             ROUND(V_VALOR,0),ROUND(V_IVA,0),ROUND(V_VALOR+V_IVA,0),V_TASA,'S',USER,SYSDATE,NULL,NULL);

              V_AÑO := V_AÑO + 1;
              V_FECHA := ADD_MONTHS(V_FECHA,V_PER_PRORROGA);

            END LOOP;

          END IF;
     end loop;
     close C_SOLICITUDES;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        METODO_AUMENTOS_SIN (P_SOLICITUD);
     WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20501,SQLERRM);
   END;

  END;



  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/03/2014
  --  CREAR_DATOS_CONTRATO
  -- Purpose : Crear la tabla de aumentos de cada contrato del seguro.
  -- cuando tiene los datos del contrato de arrendamiento.
  -- Para que queden los aumentos anuales que un riesgo debería tener.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE CREAR_DATOS_CONTRATO (P_SOLICITUD     RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                  P_POLIZA        RSGOS_VGNTES.RVI_NMRO_PLZA%TYPE,
                                  P_CLASE         RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE,
                                  P_RAMO          RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
                                  P_CONCEPTO      RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE,
                                  P_DESTINO       SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                                  P_FECHA_INICIO  DATE,
                                  P_TIPO_AUMENTO  VARCHAR2,
                                  P_PORCENTAJE    NUMBER,
                                  P_IVA_COMERCIAL VARCHAR2) IS

     V_AUMENTO                    NUMBER;
     V_VALOR_CANON                NUMBER;
     V_VALOR_CUOTA                NUMBER;
     V_SECUENCIA_CON              NUMBER;
     V_PORCENTAJE                 NUMBER;
     V_FECHA_INICIO               DATE;

    BEGIN


      IF P_DESTINO = 'C' THEN

         IF NVL(P_PORCENTAJE,0) = 0 THEN
           V_PORCENTAJE := 100;
         ELSE
           V_PORCENTAJE := P_PORCENTAJE;
         END IF;

        IF P_CONCEPTO = '01' THEN

          V_FECHA_INICIO := FECHA_INGRESO_SEG(P_SOLICITUD,P_POLIZA,P_CLASE,P_RAMO,'01');
          V_VALOR_CANON := NVL(FUN_VALOR_INGRESO( P_SOLICITUD,'01','01'),0);
          SELECT SEQ_CONTRATOS.NEXTVAL INTO V_SECUENCIA_CON FROM DUAL;

          INSERT INTO DATOS_CONTRATOS
          (secuencia_contrato,solicitud,poliza,clase,ramo,fecha_inicio_contrato,
           periodo_inicial,periodo_porroga,canon_inicial,tipo_aumento_canon,
           monto_aumento_canon,usuario_creacion,fecha_creacion,cuota_inicial,
           tipo_aumento_cuota,monto_aumento_cuota,fecha_inicio_cuota,
           usuario_modificacion,fecha_modificacion,INCLUYE_IVA_COMERCIAL,DATOS_REALES)
          VALUES(V_SECUENCIA_CON,P_SOLICITUD,P_POLIZA,P_CLASE,P_RAMO,V_FECHA_INICIO,
          12,12,V_VALOR_CANON,P_TIPO_AUMENTO,V_PORCENTAJE,USER,SYSDATE,0,
          P_TIPO_AUMENTO, V_PORCENTAJE,V_FECHA_INICIO,NULL,NULL,P_IVA_COMERCIAL,'S');


           METODO_AUMENTOS_CONTRATO(P_SOLICITUD,P_CONCEPTO);
        ELSE

          V_VALOR_CUOTA := NVL(FUN_VALOR_INGRESO( P_SOLICITUD,'01','02'),0);
          UPDATE DATOS_CONTRATOS D
             SET CUOTA_INICIAL = V_VALOR_CUOTA
           WHERE D.SOLICITUD = P_SOLICITUD;
           METODO_AUMENTOS_CONTRATO(P_SOLICITUD,P_CONCEPTO);

        END IF;

      ELSE

        IF P_CONCEPTO = '01' THEN

          SELECT SEQ_CONTRATOS.NEXTVAL INTO V_SECUENCIA_CON FROM DUAL;

           V_FECHA_INICIO := FECHA_INGRESO_SEG(P_SOLICITUD,P_POLIZA,P_CLASE,P_RAMO,'01');
           V_VALOR_CANON := NVL(FUN_VALOR_INGRESO( P_SOLICITUD,'01','01'),0);
           V_VALOR_CUOTA := NVL(FUN_VALOR_INGRESO( P_SOLICITUD,'01','02'),0);

          INSERT INTO DATOS_CONTRATOS
          (secuencia_contrato,solicitud,poliza,clase,ramo,fecha_inicio_contrato,
           periodo_inicial,periodo_porroga,canon_inicial,tipo_aumento_canon,
           monto_aumento_canon,usuario_creacion,fecha_creacion,cuota_inicial,
           tipo_aumento_cuota,monto_aumento_cuota,fecha_inicio_cuota,
           usuario_modificacion,fecha_modificacion,INCLUYE_IVA_COMERCIAL,DATOS_REALES)
          VALUES(V_SECUENCIA_CON,P_SOLICITUD,P_POLIZA,P_CLASE,P_RAMO,V_FECHA_INICIO,
          12,12,V_VALOR_CANON,1,100,USER,SYSDATE,0,
          1, 100,V_FECHA_INICIO,NULL,NULL,'N','S');

           METODO_AUMENTOS_CONTRATO(P_SOLICITUD,P_CONCEPTO);

        ELSE

          V_VALOR_CUOTA := NVL(FUN_VALOR_INGRESO( P_SOLICITUD,'01','02'),0);
          UPDATE DATOS_CONTRATOS D
             SET CUOTA_INICIAL = V_VALOR_CUOTA
           WHERE D.SOLICITUD = P_SOLICITUD;

           METODO_AUMENTOS_CONTRATO(P_SOLICITUD,P_CONCEPTO);

        END IF;


      END IF;
  EXCEPTION
     WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20501,'Error en el ingreso de datos del contrato '||SQLERRM);
  END;



  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/03/2014
  --  CREAR_DATOS_CONTRATO
  -- Purpose : Crear la tabla de aumentos de cada contrato del seguro.
  -- cuando tiene los datos del contrato de arrendamiento.
  -- Para que queden los aumentos anuales que un riesgo debería tener.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE SIN_DATOS_CONTRATO (P_SOLICITUD     RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                                  P_POLIZA        RSGOS_VGNTES.RVI_NMRO_PLZA%TYPE,
                                  P_CLASE         RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE,
                                  P_RAMO          RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
                                  P_FECHA_INICIO  DATE,
                                  P_TIPO_AUMENTO  VARCHAR2,
                                  P_PORCENTAJE    NUMBER,
                                  P_IVA_COMERCIAL VARCHAR2) IS

     V_AUMENTO                    NUMBER;
     V_VALOR_CANON                NUMBER;
     V_VALOR_CUOTA                NUMBER;
     V_SECUENCIA_CON              NUMBER;

    BEGIN


      SELECT PAR_VLOR2
        INTO V_AUMENTO
        FROM PRMTROS
       WHERE PAR_CDGO = '2'
         AND PAR_MDLO = '2'
         AND PAR_VLOR1 = 9
         AND PAR_SUC_CDGO = '2501'
         AND PAR_SUC_CIA_CDGO = '40';

       SELECT SEQ_CONTRATOS.NEXTVAL INTO V_SECUENCIA_CON FROM DUAL;

       V_VALOR_CANON := NVL(FUN_VALOR_INGRESO( P_SOLICITUD,'01','01'),0);
       V_VALOR_CUOTA := NVL(FUN_VALOR_INGRESO( P_SOLICITUD,'01','02'),0);

        INSERT INTO DATOS_CONTRATOS
        (secuencia_contrato,solicitud,poliza,clase,ramo,fecha_inicio_contrato,
         periodo_inicial,periodo_porroga,canon_inicial,tipo_aumento_canon,
         monto_aumento_canon,usuario_creacion,fecha_creacion,cuota_inicial,
         tipo_aumento_cuota,monto_aumento_cuota,fecha_inicio_cuota,
         usuario_modificacion,fecha_modificacion,INCLUYE_IVA_COMERCIAL,DATOS_REALES)
        VALUES(V_SECUENCIA_CON,P_SOLICITUD,P_POLIZA,P_CLASE,P_RAMO,P_FECHA_INICIO,
        12,12,V_VALOR_CANON,2,P_PORCENTAJE,USER,SYSDATE,V_VALOR_CUOTA,
        2, V_AUMENTO,P_FECHA_INICIO,NULL,NULL,'N','N');


         METODO_AUMENTOS_CONTRATO(P_SOLICITUD,'01');
         METODO_AUMENTOS_CONTRATO(P_SOLICITUD,'02');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,SQLERRM);
    END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 31/03/2014
  --  INSERTAR_TABLA_AUMENTOS
  -- Purpose : Crear la tabla de aumentos a partir de la información de
  -- contratos que grabaron desde indemnizaciones. Para los casos con y sin
  -- destino de inmueble. Si la solicitud no tiene el destino de inmueble
  -- se actualiza del que se grabó en indemnizaciones.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE INSERTAR_TABLA_AUMENTOS IS

     CURSOR C_SOLICITUDES IS
     select C.RVC_FCHA_INCCION_CNTRTO, C.RVC_PRDO_INCIAL, C.RVC_PRDO_PRRGA,
            C.RVC_TPO_AMNTO, C.RVC_MNTO_AMNTO, C.RVC_DSTNO_INMBLE, C.RVC_CNON_INCIAL,
            C.RC_FCHA_INCIO_CTA, C.RVC_CTA_ADMON_INICIAL, C.RVC_TPO_AMNTO_CTA,
            C.RVC_PRCNTJE_AMNTO_CTA, C.RVC_NMRO_ITEM SOLICITUD, C.RVC_NMRO_PLZA,
            C.RVC_CLSE_PLZA, C.RVC_RAM_CDGO, S.SES_DSTNO_INMBLE
       from  rsgos_vgntes r, arrndtrios a, slctdes_estdios s, rsgos_vgntes_cntrtos c
      where r.rvi_nmro_item = a.arr_nmro_slctud
        and a.arr_ses_nmro = s.ses_nmro
        and s.ses_dstno_inmble in ('V','C','S')
        and r.rvi_nmro_item != 0
        and r.rvi_nmro_item = c.rvc_nmro_item
        and not exists (select d.solicitud
                          from datos_contratos d
                        where r.rvi_nmro_item = d.solicitud);

       CURSOR C_CONCEPTOS(P_SOLICITUD NUMBER) IS
        SELECT R.RVI_NMRO_ITEM SOLICITUD ,R.RVI_NMRO_PLZA POLIZA,R.RVI_CLSE_PLZA CLASE,
               R.RVI_RAM_CDGO RAMO, A.RVL_CNCPTO_VLOR CONCEPTO
          FROM RSGOS_VGNTES R, RSGOS_VGNTES_AVLOR A
         WHERE R.RVI_NMRO_ITEM = P_SOLICITUD
           AND R.RVI_NMRO_ITEM = A.RVL_NMRO_ITEM
           AND A.RVL_CDGO_AMPRO ='01'
         ORDER BY R.RVI_NMRO_ITEM;

  CURSOR AUMENTO(AÑO_P NUMBER, TIPO VARCHAR2) IS
    SELECT PAR_VLOR2
      FROM PRMTROS
     WHERE PAR_CDGO = '1'
       AND PAR_MDLO = '3'
       AND PAR_VLOR1 = TO_NUMBER(TIPO)
       AND TO_NUMBER(TO_CHAR(PAR_FCHA_CREACION, 'YYYY')) = AÑO_P;


  R_SOL                 C_SOLICITUDES%ROWTYPE;
  R_VIG                 C_CONCEPTOS%ROWTYPE;
  V_SECUENCIA_CON       NUMBER;
  V_IMPUESTO            VARCHAR2(6);
  V_SECUENCIA           NUMBER;
  V_FECHA               DATE;
  V_VALOR               NUMBER;
  V_AÑO                 NUMBER;
  V_TIPO                VARCHAR2(5);
  V_PORCENTAJE          NUMBER;
  V_INDICADOR           NUMBER;
  V_IVA                 NUMBER;
  V_TASA                NUMBER;
  V_IVA_COMERCIAL       VARCHAR2(1):= 'N';


  BEGIN

    open C_SOLICITUDES;
    loop
      fetch C_SOLICITUDES into R_SOL;
      exit when C_SOLICITUDES%notfound;

       BEGIN

        IF R_SOL.SES_DSTNO_INMBLE = 'S' THEN
          UPDATE SLCTDES_ESTDIOS S
             SET S.SES_DSTNO_INMBLE = R_SOL.RVC_DSTNO_INMBLE
           WHERE S.SES_NMRO = R_SOL.SOLICITUD;
        END IF;

          IF R_SOL.RVC_FCHA_INCCION_CNTRTO > TO_DATE('01/01/1990','DD/MM/YYYY') THEN


          SELECT SEQ_CONTRATOS.NEXTVAL
            INTO V_SECUENCIA_CON
            FROM DUAL;

          BEGIN
          INSERT INTO DATOS_CONTRATOS
          (secuencia_contrato,solicitud,poliza,clase,ramo,fecha_inicio_contrato,
           periodo_inicial,periodo_porroga,canon_inicial,tipo_aumento_canon,
           monto_aumento_canon,usuario_creacion,fecha_creacion,cuota_inicial,
           tipo_aumento_cuota,monto_aumento_cuota,fecha_inicio_cuota,
           usuario_modificacion,fecha_modificacion,INCLUYE_IVA_COMERCIAL,DATOS_REALES)
          VALUES(V_SECUENCIA_CON,R_SOL.SOLICITUD,R_SOL.RVC_NMRO_PLZA,R_SOL.RVC_CLSE_PLZA,
           R_SOL.RVC_RAM_CDGO,R_SOL.RVC_FCHA_INCCION_CNTRTO,R_SOL.RVC_PRDO_INCIAL, R_SOL.RVC_PRDO_PRRGA,
           R_SOL.RVC_CNON_INCIAL,DECODE(R_SOL.RVC_TPO_AMNTO,'I','1','P','2','N','10',R_SOL.RVC_TPO_AMNTO), R_SOL.RVC_MNTO_AMNTO,USER,SYSDATE,
           R_SOL.RVC_CTA_ADMON_INICIAL,DECODE(R_SOL.RVC_TPO_AMNTO_CTA,'I','1','P','2','N','10',R_SOL.RVC_TPO_AMNTO_CTA), R_SOL.RVC_PRCNTJE_AMNTO_CTA,
           R_SOL.RC_FCHA_INCIO_CTA,NULL,NULL,'S','S');

          open C_CONCEPTOS(R_SOL.SOLICITUD);
          loop
            fetch C_CONCEPTOS into R_VIG;
            exit when C_CONCEPTOS%notfound;

             IF R_SOL.RVC_DSTNO_INMBLE = 'C' THEN
                V_IMPUESTO := 'IVAC';
             ELSIF R_SOL.RVC_DSTNO_INMBLE = 'V' THEN
               V_IMPUESTO := 'IVAR';
             ELSE
               V_IMPUESTO := 'SD';
             END IF;

             IF R_VIG.CONCEPTO = '01' THEN
               IF  NVL(R_SOL.RVC_CNON_INCIAL,0)  > 0 AND R_SOL.RVC_FCHA_INCCION_CNTRTO IS NOT NULL THEN
                 SELECT SEQ_AUMENTOS.NEXTVAL
                 INTO V_SECUENCIA
                 FROM DUAL;

                 INSERT INTO AUMENTOS_CONTRATOS
                 VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,R_SOL.RVC_FCHA_INCCION_CNTRTO,
                 R_SOL.RVC_CNON_INCIAL,0,R_SOL.RVC_CNON_INCIAL,0,'S',USER,SYSDATE,NULL,NULL);

                 V_VALOR := R_SOL.RVC_CNON_INCIAL;
                 V_FECHA := R_SOL.RVC_FCHA_INCCION_CNTRTO;

               ELSE
                  V_VALOR := NVL(FUN_VALOR_INGRESO( R_SOL.SOLICITUD,'01',R_VIG.CONCEPTO),0);
                  V_FECHA := FECHA_INGRESO_SEG(R_SOL.SOLICITUD,R_SOL.RVC_NMRO_PLZA,
                             R_SOL.RVC_CLSE_PLZA, R_SOL.RVC_RAM_CDGO,'01');
               END IF;

             END IF;

             IF R_VIG.CONCEPTO = '02' THEN
               IF  NVL(R_SOL.RVC_CTA_ADMON_INICIAL,0)  > 0 AND  R_SOL.RC_FCHA_INCIO_CTA IS NOT NULL THEN
                 SELECT SEQ_AUMENTOS.NEXTVAL
                   INTO V_SECUENCIA
                   FROM DUAL;

                 INSERT INTO AUMENTOS_CONTRATOS
                 VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,R_SOL.RC_FCHA_INCIO_CTA,R_SOL.RVC_CTA_ADMON_INICIAL,0,R_SOL.RVC_CTA_ADMON_INICIAL,0,'S',USER,SYSDATE,NULL,NULL);

                 V_VALOR := R_SOL.RVC_CTA_ADMON_INICIAL;
                 V_FECHA := R_SOL.RC_FCHA_INCIO_CTA;

               ELSE
                  V_VALOR := NVL(FUN_VALOR_INGRESO( R_SOL.SOLICITUD,'01',R_VIG.CONCEPTO),0);
                  V_FECHA := FECHA_INGRESO_SEG(R_SOL.SOLICITUD,R_SOL.RVC_NMRO_PLZA,
                             R_SOL.RVC_CLSE_PLZA, R_SOL.RVC_RAM_CDGO,'01');
               END IF;

            END IF;

              -- DEBE CREAR LA TABLA DE AUMENTOS PARA CADA RIESGO ASEGURADO.
               V_FECHA := ADD_MONTHS(V_FECHA,R_SOL.RVC_PRDO_PRRGA);
               V_AÑO := TO_NUMBER(TO_CHAR(V_FECHA,'YYYY'));

               WHILE V_AÑO <= TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) LOOP

                 IF R_VIG.CONCEPTO = '01' THEN
                   V_TIPO       := R_SOL.RVC_TPO_AMNTO;
                   V_PORCENTAJE :=  NVL(R_SOL.RVC_MNTO_AMNTO,0);
                 ELSE
                   V_TIPO       := R_SOL.RVC_TPO_AMNTO_CTA;
                   V_PORCENTAJE := NVL(R_SOL.RVC_PRCNTJE_AMNTO_CTA,0);
                 END IF;


                 IF V_TIPO = 'I' THEN
                   V_TIPO := '1';
                 ELSIF V_TIPO = 'P' THEN
                   V_TIPO := '2';
                 ELSIF V_TIPO = 'M' THEN
                   V_TIPO := '3';
                 ELSIF V_TIPO = 'N' THEN
                   V_TIPO := '10';
                 END IF;

                 OPEN AUMENTO(V_AÑO, V_TIPO);
                 FETCH AUMENTO
                 INTO V_INDICADOR;
                  IF AUMENTO%NOTFOUND THEN
                     V_INDICADOR := 0;
                  END IF;

                    IF V_INDICADOR = 0 THEN
                      V_TASA := V_PORCENTAJE;
                      V_VALOR      := ROUND(V_VALOR + ((V_VALOR * V_PORCENTAJE) / 100),2);
                      IF V_FECHA >= TO_DATE('01/08/2004','DD/MM/YYYY') THEN
                        IF V_TIPO != '10' THEN
                           V_IVA         := ROUND(V_VALOR * (RETORNA_TASA_IMP(V_IMPUESTO, V_FECHA) / 100), 0);
                        ELSE
                          V_IVA := 0;
                        END IF;

                        V_IVA_COMERCIAL := 'S';
                      ELSE
                        V_IVA := 0;
                      END IF;
                    ELSE
                      V_VALOR      := ROUND(V_VALOR + ((V_VALOR * ROUND(((V_INDICADOR * V_PORCENTAJE) / 100),2)) / 100),4);
                      V_TASA  := ((V_INDICADOR * V_PORCENTAJE) / 100);
                      IF V_FECHA >= TO_DATE('01/08/2004','DD/MM/YYYY') THEN
                        IF V_TIPO != '10' THEN
                           V_IVA         := ROUND(V_VALOR * (RETORNA_TASA_IMP(V_IMPUESTO, V_FECHA) / 100), 0);
                        ELSE
                          V_IVA := 0;
                        END IF;

                         V_IVA_COMERCIAL := 'S';
                      ELSE
                        V_IVA := 0;
                      END IF;
                    END IF;


                 CLOSE AUMENTO;

                 SELECT SEQ_AUMENTOS.NEXTVAL
                   INTO V_SECUENCIA
                   FROM DUAL;

                INSERT INTO AUMENTOS_CONTRATOS
                VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,V_FECHA,ROUND(NVL(V_VALOR,0),0),
                ROUND(NVL(V_IVA,0),0),ROUND(V_VALOR+NVL(V_IVA,0),0),V_TASA,'S',USER,SYSDATE,NULL,NULL);

              V_AÑO := V_AÑO + 1;
              V_FECHA := ADD_MONTHS(V_FECHA,R_SOL.RVC_PRDO_PRRGA);

            END LOOP;

            COMMIT;


       end loop;
       close C_CONCEPTOS;

           COMMIT;
          EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;

        END IF;
       EXCEPTION
         WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR (-20501,SQLERRM||' '||R_SOL.SOLICITUD);
       END;


    end loop;
    close C_SOLICITUDES;

  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 31/03/2014
  --  INSERTAR_TABLA_VIVIENDA
  -- Purpose : Crear la tabla de aumentos de inmuebles de destino vivienda
  -- con la regla dad por el usuario. Antes de julio de 2013 90% del IPC y
  -- después de julio 100% del IPC.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE INSERTAR_TABLA_VIVIENDA IS

     CURSOR C_SOLICITUDES IS
     select R.RVI_NMRO_ITEM SOLICITUD,R.RVI_NMRO_PLZA POLIZA, R.RVI_CLSE_PLZA CLASE,
            R.RVI_RAM_CDGO RAMO
       from  rsgos_vgntes r, arrndtrios a, slctdes_estdios s
      where r.rvi_nmro_item = a.arr_nmro_slctud
        and a.arr_ses_nmro = s.ses_nmro
        and s.ses_dstno_inmble in ('V')
        and r.rvi_nmro_item != 0
        and not exists (select d.solicitud
                          from datos_contratos d
                        where r.rvi_nmro_item = d.solicitud);

       CURSOR C_CONCEPTOS(P_SOLICITUD NUMBER) IS
        SELECT R.RVI_NMRO_ITEM SOLICITUD ,R.RVI_NMRO_PLZA POLIZA,R.RVI_CLSE_PLZA CLASE,
               R.RVI_RAM_CDGO RAMO, A.RVL_CNCPTO_VLOR CONCEPTO
          FROM RSGOS_VGNTES R, RSGOS_VGNTES_AVLOR A
         WHERE R.RVI_NMRO_ITEM = P_SOLICITUD
           AND R.RVI_NMRO_ITEM = A.RVL_NMRO_ITEM
           AND A.RVL_CDGO_AMPRO ='01'
         ORDER BY R.RVI_NMRO_ITEM;

  CURSOR AUMENTO(AÑO_P NUMBER, TIPO VARCHAR2) IS
    SELECT PAR_VLOR2
      FROM PRMTROS
     WHERE PAR_CDGO = '1'
       AND PAR_MDLO = '3'
       AND PAR_VLOR1 = TO_NUMBER(TIPO)
       AND TO_NUMBER(TO_CHAR(PAR_FCHA_CREACION, 'YYYY')) = AÑO_P;


  R_SOL                 C_SOLICITUDES%ROWTYPE;
  R_VIG                 C_CONCEPTOS%ROWTYPE;
  V_SECUENCIA_CON       NUMBER;
  V_SECUENCIA           NUMBER;
  V_FECHA               DATE;
  V_VALOR               NUMBER;
  V_AÑO                 NUMBER;
  V_TIPO                VARCHAR2(5);
  V_PORCENTAJE          NUMBER;
  V_INDICADOR           NUMBER;
  V_FECHA_INGRESO            DATE;
  V_VALOR_CANON              NUMBER;
  V_VALOR_CUOTA              NUMBER;
  V_TASA                     NUMBER;


  BEGIN



     open C_SOLICITUDES;
     loop
       fetch C_SOLICITUDES into R_SOL;
       exit when C_SOLICITUDES%notfound;

       BEGIN
        open C_CONCEPTOS(R_SOL.SOLICITUD);
        loop
          fetch C_CONCEPTOS into R_VIG;
          exit when C_CONCEPTOS%notfound;

          V_FECHA_INGRESO := FECHA_INGRESO_SEG(R_SOL.SOLICITUD,R_SOL.POLIZA, R_SOL.CLASE, R_SOL.RAMO,'01');

          IF V_FECHA_INGRESO > TO_DATE('01/01/1990','DD/MM/YYYY') THEN
           -- BUSCA EL VALOR DEL CONCEPTO CON EL CUAL SE INGRESO EL RIESGO.
             SELECT SEQ_CONTRATOS.NEXTVAL INTO V_SECUENCIA_CON FROM DUAL;

           V_VALOR := NVL(FUN_VALOR_INGRESO( R_SOL.SOLICITUD,'01',R_VIG.CONCEPTO),0);
           IF R_VIG.CONCEPTO = '01' THEN
             V_VALOR_CANON := V_VALOR;
           ELSE
             V_VALOR_CUOTA := V_VALOR;
           END IF;

           IF R_VIG.CONCEPTO = '01' THEN

               INSERT INTO DATOS_CONTRATOS
               VALUES(V_SECUENCIA_CON,R_SOL.SOLICITUD,R_SOL.POLIZA,R_SOL.CLASE,R_SOL.RAMO,V_FECHA_INGRESO,12,12,
               V_VALOR_CANON,1,NVL(V_PORCENTAJE,100),USER,SYSDATE,V_VALOR_CUOTA,1,NVL(V_PORCENTAJE,100),V_FECHA_INGRESO,NULL,NULL,'N','N');
           ELSE
             UPDATE DATOS_CONTRATOS
                SET CUOTA_INICIAL = V_VALOR_CUOTA
              WHERE SECUENCIA_CONTRATO = V_SECUENCIA_CON;
           END IF;

          IF V_VALOR > 0 THEN
            SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;
            INSERT INTO AUMENTOS_CONTRATOS
            VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,V_FECHA_INGRESO,V_VALOR,0,V_VALOR,0,'S',USER,SYSDATE,NULL,NULL);

            -- DEBE CREAR LA TABLA DE AUMENTOS PARA CADA RIESGO ASEGURADO.
            V_FECHA := ADD_MONTHS(V_FECHA_INGRESO,12);
            V_AÑO := TO_NUMBER(TO_CHAR(V_FECHA,'YYYY'));
            V_TIPO := '1';

            WHILE V_AÑO <= TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) LOOP

              IF V_FECHA <= TO_DATE('30/06/2013','DD/MM/YYYY') THEN
                 V_PORCENTAJE := 90;
              ELSE
                 V_PORCENTAJE := 100;
              END IF;

              OPEN AUMENTO(V_AÑO, V_TIPO);
              FETCH AUMENTO
              INTO V_INDICADOR;
              IF AUMENTO%NOTFOUND THEN
                V_INDICADOR := 0;
              END IF;
              CLOSE AUMENTO;

              V_VALOR      := ROUND(V_VALOR + ((V_VALOR * ROUND(((V_INDICADOR * V_PORCENTAJE) / 100),2)) / 100),4);
              V_TASA  := ((V_INDICADOR * V_PORCENTAJE) / 100);

              SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;

              INSERT INTO AUMENTOS_CONTRATOS
              VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,V_FECHA,ROUND(V_VALOR,0),0,ROUND(V_VALOR,0),V_PORCENTAJE,'S',USER,SYSDATE,NULL,NULL);

              V_AÑO := V_AÑO + 1;
              V_FECHA := ADD_MONTHS(V_FECHA,12);

            END LOOP;

            COMMIT;
          END IF;


         END IF;
       end loop;
       close C_CONCEPTOS;

     EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        NULL;
     END;


     end loop;
     close C_SOLICITUDES;

  END;


  PROCEDURE INSERTAR_TABLA_VIVIENDA(P_SOLICITUD NUMBER) IS

     CURSOR C_SOLICITUDES IS
     select R.RVI_NMRO_ITEM SOLICITUD,R.RVI_NMRO_PLZA POLIZA, R.RVI_CLSE_PLZA CLASE,
            R.RVI_RAM_CDGO RAMO
       from  rsgos_vgntes r, arrndtrios a, slctdes_estdios s
      where r.rvi_nmro_item = p_solicitud
        AND r.rvi_nmro_item = a.arr_nmro_slctud
        and a.arr_ses_nmro = s.ses_nmro
        and s.ses_dstno_inmble in ('V')
        and r.rvi_nmro_item != 0
        and not exists (select d.solicitud
                          from datos_contratos d
                        where r.rvi_nmro_item = d.solicitud);

       CURSOR C_CONCEPTOS(P_SOLICITUD NUMBER) IS
        SELECT R.RVI_NMRO_ITEM SOLICITUD ,R.RVI_NMRO_PLZA POLIZA,R.RVI_CLSE_PLZA CLASE,
               R.RVI_RAM_CDGO RAMO, A.RVL_CNCPTO_VLOR CONCEPTO
          FROM RSGOS_VGNTES R, RSGOS_VGNTES_AVLOR A
         WHERE R.RVI_NMRO_ITEM = P_SOLICITUD
           AND R.RVI_NMRO_ITEM = A.RVL_NMRO_ITEM
           AND A.RVL_CDGO_AMPRO ='01'
         ORDER BY R.RVI_NMRO_ITEM;

  CURSOR AUMENTO(AÑO_P NUMBER, TIPO VARCHAR2) IS
    SELECT PAR_VLOR2
      FROM PRMTROS
     WHERE PAR_CDGO = '1'
       AND PAR_MDLO = '3'
       AND PAR_VLOR1 = TO_NUMBER(TIPO)
       AND TO_NUMBER(TO_CHAR(PAR_FCHA_CREACION, 'YYYY')) = AÑO_P;


  R_SOL                 C_SOLICITUDES%ROWTYPE;
  R_VIG                 C_CONCEPTOS%ROWTYPE;
  V_SECUENCIA_CON       NUMBER;
  V_SECUENCIA           NUMBER;
  V_FECHA               DATE;
  V_VALOR               NUMBER;
  V_AÑO                 NUMBER;
  V_TIPO                VARCHAR2(5);
  V_PORCENTAJE          NUMBER;
  V_INDICADOR           NUMBER;
  V_FECHA_INGRESO            DATE;
  V_VALOR_CANON              NUMBER;
  V_VALOR_CUOTA              NUMBER;
  V_TASA                     NUMBER;


  BEGIN



     open C_SOLICITUDES;
     loop
       fetch C_SOLICITUDES into R_SOL;
       exit when C_SOLICITUDES%notfound;

       BEGIN
        open C_CONCEPTOS(R_SOL.SOLICITUD);
        loop
          fetch C_CONCEPTOS into R_VIG;
          exit when C_CONCEPTOS%notfound;

          V_FECHA_INGRESO := FECHA_INGRESO_SEG(R_SOL.SOLICITUD,R_SOL.POLIZA, R_SOL.CLASE, R_SOL.RAMO,'01');

          IF V_FECHA_INGRESO > TO_DATE('01/01/1990','DD/MM/YYYY') THEN
           -- BUSCA EL VALOR DEL CONCEPTO CON EL CUAL SE INGRESO EL RIESGO.
             SELECT SEQ_CONTRATOS.NEXTVAL INTO V_SECUENCIA_CON FROM DUAL;

           V_VALOR := NVL(FUN_VALOR_INGRESO( R_SOL.SOLICITUD,'01',R_VIG.CONCEPTO),0);
           IF R_VIG.CONCEPTO = '01' THEN
             V_VALOR_CANON := V_VALOR;
           ELSE
             V_VALOR_CUOTA := V_VALOR;
           END IF;

           IF R_VIG.CONCEPTO = '01' THEN

               INSERT INTO DATOS_CONTRATOS
               VALUES(V_SECUENCIA_CON,R_SOL.SOLICITUD,R_SOL.POLIZA,R_SOL.CLASE,R_SOL.RAMO,V_FECHA_INGRESO,12,12,
               V_VALOR_CANON,1,NVL(V_PORCENTAJE,100),USER,SYSDATE,V_VALOR_CUOTA,1,NVL(V_PORCENTAJE,100),V_FECHA_INGRESO,NULL,NULL,'N','N');
           ELSE
             UPDATE DATOS_CONTRATOS
                SET CUOTA_INICIAL = V_VALOR_CUOTA
              WHERE SECUENCIA_CONTRATO = V_SECUENCIA_CON;
           END IF;

          IF V_VALOR > 0 THEN
            SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;
            INSERT INTO AUMENTOS_CONTRATOS
            VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,V_FECHA_INGRESO,V_VALOR,0,V_VALOR,0,'S',USER,SYSDATE,NULL,NULL);

            -- DEBE CREAR LA TABLA DE AUMENTOS PARA CADA RIESGO ASEGURADO.
            V_FECHA := ADD_MONTHS(V_FECHA_INGRESO,12);
            V_AÑO := TO_NUMBER(TO_CHAR(V_FECHA,'YYYY'));
            V_TIPO := '1';

            WHILE V_AÑO <= TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) LOOP

              IF V_FECHA <= TO_DATE('30/06/2013','DD/MM/YYYY') THEN
                 V_PORCENTAJE := 90;
              ELSE
                 V_PORCENTAJE := 100;
              END IF;

              OPEN AUMENTO(V_AÑO, V_TIPO);
              FETCH AUMENTO
              INTO V_INDICADOR;
              IF AUMENTO%NOTFOUND THEN
                V_INDICADOR := 0;
              END IF;
              CLOSE AUMENTO;

              V_VALOR      := ROUND(V_VALOR + ((V_VALOR * ROUND(((V_INDICADOR * V_PORCENTAJE) / 100),2)) / 100),4);
              V_TASA  := ((V_INDICADOR * V_PORCENTAJE) / 100);

              SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;

              INSERT INTO AUMENTOS_CONTRATOS
              VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,V_FECHA,ROUND(V_VALOR,0),0,ROUND(V_VALOR,0),V_PORCENTAJE,'S',USER,SYSDATE,NULL,NULL);

              V_AÑO := V_AÑO + 1;
              V_FECHA := ADD_MONTHS(V_FECHA,12);

            END LOOP;

            COMMIT;
          END IF;


         END IF;
       end loop;
       close C_CONCEPTOS;

     EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        NULL;
     END;


     end loop;
     close C_SOLICITUDES;

  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 31/03/2014
  --  INSERTAR_TABLA_VIVIENDA
  -- Purpose : Crear la tabla de aumentos de inmuebles de destino vivienda
  -- con la regla dad por el usuario. Antes de julio de 2013 90% del IPC y
  -- después de julio 100% del IPC.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE INSERTAR_TABLA_COMERCIAL IS

     CURSOR C_SOLICITUDES IS
     select R.RVI_NMRO_ITEM SOLICITUD,R.RVI_NMRO_PLZA POLIZA, R.RVI_CLSE_PLZA CLASE,
            R.RVI_RAM_CDGO RAMO
       from  rsgos_vgntes r, arrndtrios a, slctdes_estdios s
      where r.rvi_nmro_item = a.arr_nmro_slctud
        and a.arr_ses_nmro = s.ses_nmro
        and s.ses_dstno_inmble in ('C')
        and r.rvi_nmro_item != 0
        and not exists (select d.solicitud
                          from datos_contratos d
                        where r.rvi_nmro_item = d.solicitud);

       CURSOR C_CONCEPTOS(P_SOLICITUD NUMBER) IS
        SELECT R.RVI_NMRO_ITEM SOLICITUD ,R.RVI_NMRO_PLZA POLIZA,R.RVI_CLSE_PLZA CLASE,
               R.RVI_RAM_CDGO RAMO, A.RVL_CNCPTO_VLOR CONCEPTO
          FROM RSGOS_VGNTES R, RSGOS_VGNTES_AVLOR A
         WHERE R.RVI_NMRO_ITEM = P_SOLICITUD
           AND R.RVI_NMRO_ITEM = A.RVL_NMRO_ITEM
           AND A.RVL_CDGO_AMPRO ='01'
         ORDER BY R.RVI_NMRO_ITEM;

  CURSOR AUMENTO(AÑO_P NUMBER, TIPO VARCHAR2) IS
    SELECT PAR_VLOR2
      FROM PRMTROS
     WHERE PAR_CDGO = '1'
       AND PAR_MDLO = '3'
       AND PAR_VLOR1 = TO_NUMBER(TIPO)
       AND TO_NUMBER(TO_CHAR(PAR_FCHA_CREACION, 'YYYY')) = AÑO_P;


  R_SOL                 C_SOLICITUDES%ROWTYPE;
  R_VIG                 C_CONCEPTOS%ROWTYPE;
  V_SECUENCIA_CON       NUMBER;
  V_SECUENCIA           NUMBER;
  V_FECHA               DATE;
  V_VALOR               NUMBER;
  V_AÑO                 NUMBER;
  V_TIPO                VARCHAR2(5);
  V_PORCENTAJE          NUMBER:=20;
  V_INDICADOR           NUMBER;
  V_FECHA_INGRESO            DATE;
  V_VALOR_CANON              NUMBER;
  V_VALOR_CUOTA              NUMBER;
  V_TASA                     NUMBER;


  BEGIN



     open C_SOLICITUDES;
     loop
       fetch C_SOLICITUDES into R_SOL;
       exit when C_SOLICITUDES%notfound;

        open C_CONCEPTOS(R_SOL.SOLICITUD);
        loop
          fetch C_CONCEPTOS into R_VIG;
          exit when C_CONCEPTOS%notfound;

          V_FECHA_INGRESO := FECHA_INGRESO_SEG(R_SOL.SOLICITUD,R_SOL.POLIZA, R_SOL.CLASE, R_SOL.RAMO,'01');

          IF V_FECHA_INGRESO > TO_DATE('01/01/1990','DD/MM/YYYY') THEN
           -- BUSCA EL VALOR DEL CONCEPTO CON EL CUAL SE INGRESO EL RIESGO.
             SELECT SEQ_CONTRATOS.NEXTVAL INTO V_SECUENCIA_CON FROM DUAL;

           V_VALOR := NVL(FUN_VALOR_INGRESO( R_SOL.SOLICITUD,'01',R_VIG.CONCEPTO),0);
           IF R_VIG.CONCEPTO = '01' THEN
             V_VALOR_CANON := V_VALOR;
           ELSE
             V_VALOR_CUOTA := V_VALOR;
           END IF;

           IF R_VIG.CONCEPTO = '01' THEN
             INSERT INTO DATOS_CONTRATOS
             VALUES(V_SECUENCIA_CON,R_SOL.SOLICITUD,R_SOL.POLIZA,R_SOL.CLASE,R_SOL.RAMO,V_FECHA_INGRESO,12,12,
             V_VALOR_CANON,2,V_PORCENTAJE,USER,SYSDATE,V_VALOR_CUOTA,2,V_PORCENTAJE,V_FECHA_INGRESO,NULL,NULL,'N','N');
           ELSE
             UPDATE DATOS_CONTRATOS
                SET CUOTA_INICIAL = V_VALOR_CUOTA
              WHERE SECUENCIA_CONTRATO = V_SECUENCIA_CON;
           END IF;

          IF V_VALOR > 0 THEN
            SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;
            INSERT INTO AUMENTOS_CONTRATOS
            VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,V_FECHA_INGRESO,V_VALOR,0,V_VALOR,0,'S',USER,SYSDATE,NULL,NULL);

            -- DEBE CREAR LA TABLA DE AUMENTOS PARA CADA RIESGO ASEGURADO.
            V_FECHA := ADD_MONTHS(V_FECHA_INGRESO,12);
            V_AÑO := TO_NUMBER(TO_CHAR(V_FECHA,'YYYY'));
            V_TIPO := '2';

            WHILE V_AÑO <= TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) LOOP


              V_VALOR      := ROUND(V_VALOR + ROUND((V_VALOR * V_PORCENTAJE / 100),0),0);

              SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;

              INSERT INTO AUMENTOS_CONTRATOS
              VALUES(V_SECUENCIA,V_SECUENCIA_CON,R_SOL.SOLICITUD,R_VIG.CONCEPTO,V_FECHA,ROUND(V_VALOR,0),0,ROUND(V_VALOR,0),V_PORCENTAJE,'S',USER,SYSDATE,NULL,NULL);

              V_AÑO := V_AÑO + 1;
              V_FECHA := ADD_MONTHS(V_FECHA,12);

            END LOOP;

            COMMIT;
          END IF;


         END IF;
       end loop;
       close C_CONCEPTOS;


     end loop;
     close C_SOLICITUDES;

  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 13/03/2014
  --  ACTUALIZAR_TABLA_CONTRATOS
  -- Purpose : Actualizar la tabla de contratos por cambios en
  -- los datos. Para esto se vuleve a actualizar la tabla de datos de
  -- contratos, se borra la de aumentos y se vuelve a calcular.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE ACTUALIZAR_TABLA_CONTRATOS (P_DATOS IN T_DATOS_CONTRATO) IS

    CURSOR C_CONCEPTOS IS
      SELECT A.RVL_CNCPTO_VLOR CONCEPTO
        FROM RSGOS_VGNTES_AVLOR A
       WHERE A.RVL_NMRO_ITEM = P_DATOS.P_SOLICITUD
         AND A.RVL_CDGO_AMPRO = '01';

  R_CONC     C_CONCEPTOS%ROWTYPE;

  BEGIN

    UPDATE DATOS_CONTRATOS D
       SET D.FECHA_INICIO_CONTRATO = P_DATOS.P_FECHA_INICIO_C,
           D.TIPO_AUMENTO_CANON    = P_DATOS.P_TIPO_AUMENTO_C,
           D.MONTO_AUMENTO_CANON   = P_DATOS.P_PORCENTAJE_C,
           D.TIPO_AUMENTO_CUOTA    = P_DATOS.P_TIPO_AUMENTO_A,
           D.MONTO_AUMENTO_CUOTA   = P_DATOS.P_PORCENTAJE_A
     WHERE D.SOLICITUD = P_DATOS.P_SOLICITUD;

    DELETE AUMENTOS_CONTRATOS A
     WHERE A.SOLICITUD =  P_DATOS.P_SOLICITUD;

    open C_CONCEPTOS;
    loop
      fetch C_CONCEPTOS into R_CONC;
      exit when C_CONCEPTOS%notfound;

      METODO_AUMENTOS_CONTRATO(P_DATOS.P_SOLICITUD,R_CONC.CONCEPTO);

    end loop;
    close C_CONCEPTOS;


  EXCEPTION
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20501,SQLERRM);

  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 10/04/2014
  --  PRC_REINGRESA_CONTRATO
  -- Purpose : Vuelve a traer los datos del contrato de arrendamiento
  -- por un reingreso al seguro.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_REINGRESA_CONTRATO (P_SOLICITUD IN RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE) IS

    CURSOR C_CONCEPTOS IS
      SELECT A.RVL_CNCPTO_VLOR CONCEPTO
        FROM RSGOS_VGNTES_AVLOR A
       WHERE A.RVL_NMRO_ITEM = P_SOLICITUD
         AND A.RVL_CDGO_AMPRO = '01';

    R_CONC     C_CONCEPTOS%ROWTYPE;
    V_SECUENCIA                    NUMBER;

  BEGIN

     SELECT MAX(SECUENCIA_HISTORICO)
       INTO V_SECUENCIA
       FROM DATOS_CONTRATOS_HISTORICO D
      WHERE D.SOLICITUD = P_SOLICITUD;


       INSERT INTO DATOS_CONTRATOS
       SELECT D.SECUENCIA_CONTRATO, D.SOLICITUD, D.POLIZA, D.CLASE, D.RAMO, D.FECHA_INICIO_CONTRATO,
              D.PERIODO_INICIAL, D.PERIODO_PORROGA, D.CANON_INICIAL, D.TIPO_AUMENTO_CANON,
              D.MONTO_AUMENTO_CANON, D.USUARIO_CREACION, D.FECHA_CREACION, D.CUOTA_INICIAL,
              D.TIPO_AUMENTO_CUOTA, D.MONTO_AUMENTO_CUOTA, D.FECHA_INICIO_CUOTA, D.USUARIO_MODIFICACION,
              D.FECHA_MODIFICACION, D.INCLUYE_IVA_COMERCIAL, D.DATOS_REALES
         FROM DATOS_CONTRATOS_HISTORICO D
        WHERE D.SECUENCIA_HISTORICO = V_SECUENCIA
          AND D.SOLICITUD = P_SOLICITUD;

       IF NVL(V_SECUENCIA,0) > 0  THEN
          open C_CONCEPTOS;
          loop
            fetch C_CONCEPTOS into R_CONC;
            exit when C_CONCEPTOS%notfound;

            METODO_AUMENTOS_CONTRATO(P_SOLICITUD,R_CONC.CONCEPTO);

          end loop;
          close C_CONCEPTOS;
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501,SQLERRM);
  END;
  
  --
  --
  --
  PROCEDURE PRC_PROYECTA_AUMENTOS IS  

  V_YEAR    NUMBER;

  BEGIN
    V_YEAR := TO_CHAR(SYSDATE,'YYYY'); 
    PRC_AUMENTOS_NUEVOAÑO(V_YEAR);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20521, SQLERRM);
  
  END PRC_PROYECTA_AUMENTOS;
  
    /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 07/01/2016
  --  PRC_AUMENTOS_NUEVOAÑO
  -- Purpose : Ingresa la proyección de los aumentos del año dado por parametro
  -- Se debe generar el primer día de cada año
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_AUMENTOS_NUEVOAÑO(P_AÑO IN OUT NUMBER) IS
  
    CURSOR C_SOLICITUDES IS
      SELECT *
        FROM DATOS_CONTRATOS D
       WHERE EXISTS (SELECT * FROM AUMENTOS_CONTRATOS A
                      WHERE A.SOLICITUD = d.SOLICITUD
                        AND TO_NUMBER(TO_CHAR(A.FECHA_AUMENTO, 'YYYY')) = (P_AÑO - 1));
  
    CURSOR C_CONCEPTOS(P_SOLICITUD NUMBER) IS
      SELECT SOLICITUD, CONCEPTO, VALOR_SIN_IVA, PORCENTAJE_LIQ
        FROM AUMENTOS_CONTRATOS A
       WHERE A.SOLICITUD = P_SOLICITUD
         AND TO_NUMBER(TO_CHAR(A.FECHA_AUMENTO, 'YYYY')) = (P_AÑO - 1)
       ORDER BY SOLICITUD;
  
    CURSOR AUMENTO(AÑO_P NUMBER, TIPO VARCHAR2) IS
      SELECT PAR_VLOR2
        FROM PRMTROS
       WHERE PAR_CDGO = '1'
         AND PAR_MDLO = '3'
         AND PAR_VLOR1 = TO_NUMBER(TIPO)
         AND TO_NUMBER(TO_CHAR(PAR_FCHA_CREACION, 'YYYY')) = AÑO_P;
  
    R_SOL           C_SOLICITUDES%ROWTYPE;
    R_VIG           C_CONCEPTOS%ROWTYPE;
    V_IMPUESTO      VARCHAR2(6);
    V_SECUENCIA     NUMBER;
    V_FECHA         DATE;
    V_VALOR         NUMBER;
    V_TIPO          VARCHAR2(5);
    V_PORCENTAJE    NUMBER;
    V_INDICADOR     NUMBER;
    V_IVA           NUMBER;
    V_TASA          NUMBER;
    DESTINO         SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE;
  
  BEGIN
    OPEN C_SOLICITUDES;
    LOOP
      FETCH C_SOLICITUDES INTO R_SOL;
      EXIT WHEN C_SOLICITUDES%NOTFOUND;
    
      BEGIN
        SELECT RVC_DSTNO_INMBLE
          INTO DESTINO
          FROM RSGOS_VGNTES_CNTRTOS
         WHERE RVC_NMRO_ITEM = R_SOL.SOLICITUD;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            SELECT SES_DSTNO_INMBLE
              INTO DESTINO
              FROM SLCTDES_ESTDIOS
             WHERE SES_NMRO = (SELECT ARR_SES_NMRO FROM ARRNDTRIOS
                                WHERE ARR_NMRO_SLCTUD = R_SOL.SOLICITUD);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              DESTINO := NULL;
          END;
      END;
    
      BEGIN
        OPEN C_CONCEPTOS(R_SOL.SOLICITUD);
        LOOP
          FETCH C_CONCEPTOS INTO R_VIG;
          EXIT WHEN C_CONCEPTOS%NOTFOUND;
        
          IF DESTINO = 'C' THEN
            V_IMPUESTO := 'IVAC';
          ELSIF DESTINO = 'V' THEN
            V_IMPUESTO := 'IVAR';
          ELSE
            V_IMPUESTO := 'SD';
          END IF;
        
          V_VALOR := R_VIG.VALOR_SIN_IVA;
          V_FECHA := TO_DATE(TO_CHAR(R_SOL.FECHA_INICIO_CONTRATO, 'DDMM') ||TO_CHAR(SYSDATE, 'YYYY'),'DD/MM/YYYY');
        
          IF R_VIG.CONCEPTO = '01' THEN
            V_TIPO       := R_SOL.TIPO_AUMENTO_CANON;
            V_PORCENTAJE := NVL(R_SOL.MONTO_AUMENTO_CANON, 0);
          ELSE
            V_TIPO       := R_SOL.TIPO_AUMENTO_CUOTA;
            V_PORCENTAJE := NVL(R_VIG.PORCENTAJE_LIQ, 0);
          END IF;
        
          IF V_TIPO = 'I' THEN
            V_TIPO := '1';
          ELSIF V_TIPO = 'P' THEN
            V_TIPO := '2';
          ELSIF V_TIPO = 'M' THEN
            V_TIPO := '3';
          ELSIF V_TIPO = 'N' THEN
            V_TIPO := '10';
          END IF;
        
          OPEN AUMENTO(P_AÑO, V_TIPO);
          FETCH AUMENTO INTO V_INDICADOR;
          IF AUMENTO%NOTFOUND THEN
            V_INDICADOR := 0;
          END IF;
        
          IF V_INDICADOR = 0 THEN
            V_TASA  := V_PORCENTAJE;
            V_VALOR := ROUND(V_VALOR + ((V_VALOR * V_PORCENTAJE) / 100), 2);
            IF V_FECHA >= TO_DATE('01/08/2004', 'DD/MM/YYYY') THEN
              IF V_TIPO != '10' THEN
                V_IVA := ROUND(V_VALOR * (RETORNA_TASA_IMP(V_IMPUESTO, V_FECHA) / 100),0);
              ELSE
                V_IVA := 0;
              END IF;
            ELSE
              V_IVA := 0;
            END IF;
          ELSE
            V_VALOR := ROUND(V_VALOR + ((V_VALOR * ROUND(((V_INDICADOR * V_PORCENTAJE) / 100),2)) / 100),4);
            V_TASA  := ((V_INDICADOR * V_PORCENTAJE) / 100);
            IF V_FECHA >= TO_DATE('01/08/2004', 'DD/MM/YYYY') THEN
              IF V_TIPO != '10' THEN
                V_IVA := ROUND(V_VALOR * (RETORNA_TASA_IMP(V_IMPUESTO, V_FECHA) / 100),0);
              ELSE
                V_IVA := 0;
              END IF;
            ELSE
              V_IVA := 0;
            END IF;
          END IF;
        
          CLOSE AUMENTO;
        
          SELECT SEQ_AUMENTOS.NEXTVAL INTO V_SECUENCIA FROM DUAL;
        
          BEGIN
            INSERT INTO AUMENTOS_CONTRATOS
            VALUES
              (V_SECUENCIA,
               R_SOL.SECUENCIA_CONTRATO,
               R_SOL.SOLICITUD,
               R_VIG.CONCEPTO,
               V_FECHA,
               ROUND(NVL(V_VALOR, 0), 0),
               ROUND(NVL(V_IVA, 0), 0),
               ROUND(V_VALOR + NVL(V_IVA, 0), 0),
               V_TASA,
               'S',
               USER,
               SYSDATE,
               NULL,
               NULL);
          
            COMMIT;
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;
        END LOOP;
        CLOSE C_CONCEPTOS;
      
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20501, SQLERRM || ' ' || R_SOL.SOLICITUD);
      END;
    
    END LOOP;
    CLOSE C_SOLICITUDES;
  
  END PRC_AUMENTOS_NUEVOAÑO;



end PKG_DETALLE_OPERACION;
/
