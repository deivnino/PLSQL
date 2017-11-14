CREATE OR REPLACE PACKAGE BODY admsisa.PKG_NOVEDADES_WEB_JAVA is

--------------------------------------------------------------------------
-- QUITA LOS ORA-###### DEL MENSAJE QUE SE LE MUESTRA A LA INMOBILIARIA --
-- MODIFICADO POR: GONZALO CHAPARRO.                   FEBRERO - 2015 ----
--------------------------------------------------------------------------
FUNCTION FUN_RET_MENSAJE_ERROR(P_MENSAJE    IN VARCHAR2) RETURN VARCHAR2 IS

V_MENSAJE_AUX       VARCHAR2(4000) := NULL;
V_MENSAJE_FINAL     VARCHAR2(4000) := NULL;
V_INICIO_ORA        NUMBER(4) := 0;

BEGIN
  BEGIN
    V_MENSAJE_AUX := P_MENSAJE;
    FOR ITERA IN 1..5 LOOP
       V_INICIO_ORA := INSTR(V_MENSAJE_AUX,'ORA-');
       IF V_INICIO_ORA = 0 THEN -- no encuentra más cadena....
         V_MENSAJE_FINAL := V_MENSAJE_FINAL||V_MENSAJE_AUX;
         EXIT;
       ELSE
         V_MENSAJE_FINAL := V_MENSAJE_FINAL||SUBSTR(V_MENSAJE_AUX, 0, V_INICIO_ORA-1);
         V_MENSAJE_AUX := SUBSTR(V_MENSAJE_AUX, V_INICIO_ORA + 10);
       END IF;
    END LOOP;

    IF V_MENSAJE_FINAL IS NULL THEN
      V_MENSAJE_FINAL := P_MENSAJE;
    END IF;

    EXCEPTION WHEN OTHERS THEN -- se deja el que trae....
                V_MENSAJE_FINAL := P_MENSAJE;
  END;

  RETURN V_MENSAJE_FINAL;
END FUN_RET_MENSAJE_ERROR;

-----------------------------------------------------------------------
-- DEVUELVE EL PERIODO DE INGRESO DE LAS NOVEDADES POR LA PAGINA WEB --
-- MODIFICADO POR: GONZALO CHAPARRO.                   FEBRERO - 2015--
-----------------------------------------------------------------------
FUNCTION FUN_FECHA_NOV(P_LOGIN NUMBER) RETURN VARCHAR2 IS

FECHA       DATE := NULL;
MES         VARCHAR2(30):= NULL;

BEGIN
  BEGIN
    FECHA := PKG_NOVEDADES_WEB_JAVA.FUN_FECHA_NOV_DATE(P_LOGIN);

    EXCEPTION WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20501,'NO SE PUEDE CONSULTAR LA FECHA DE NOVEDAD. ' ||FUN_RET_MENSAJE_ERROR(SQLERRM));
  END;

  IF FECHA IS NOT NULL THEN
    IF TO_CHAR(FECHA, 'MM') = '01' THEN
      MES := 'ENERO';
    ELSIF TO_CHAR(FECHA, 'MM') = '02' THEN
      MES := 'FEBRERO';
    ELSIF TO_CHAR(FECHA, 'MM') = '03' THEN
      MES := 'MARZO';
    ELSIF TO_CHAR(FECHA, 'MM') = '04' THEN
      MES := 'ABRIL';
    ELSIF TO_CHAR(FECHA, 'MM') = '05' THEN
      MES := 'MAYO';
    ELSIF TO_CHAR(FECHA, 'MM') = '06' THEN
      MES := 'JUNIO';
    ELSIF TO_CHAR(FECHA, 'MM') = '07' THEN
      MES := 'JULIO';
    ELSIF TO_CHAR(FECHA, 'MM') = '08' THEN
      MES := 'AGOSTO';
    ELSIF TO_CHAR(FECHA, 'MM') = '09' THEN
      MES := 'SEPTIEMBRE';
    ELSIF TO_CHAR(FECHA, 'MM') = '10' THEN
      MES := 'OCTUBRE';
    ELSIF TO_CHAR(FECHA, 'MM') = '11' THEN
      MES := 'NOVIEMBRE';
    ELSIF TO_CHAR(FECHA, 'MM') = '12' THEN
      MES := 'DICIEMBRE';
    ELSE
      RAISE_APPLICATION_ERROR(-20502,'NO SE PUEDE CONSULTAR LA FECHA DE NOVEDAD. ' ||FUN_RET_MENSAJE_ERROR(SQLERRM));
    END IF;
  END IF;

  RETURN(MES);
END FUN_FECHA_NOV;

-----------------------------------------------------------------------
-- DEVUELVE EL PERIODO DE INGRESO DE LAS NOVEDADES POR LA PAGINA WEB --
-- MODIFICADO POR: GONZALO CHAPARRO.                   FEBRERO - 2015--
-----------------------------------------------------------------------
FUNCTION FUN_FECHA_NOV_DATE(P_LOGIN NUMBER) RETURN DATE IS

POLIZA      NUMBER := NULL;
CERT        NUMBER := NULL;
FECHA       DATE := NULL;

BEGIN
  BEGIN
    SELECT MIN(POL_NMRO_PLZA)
      INTO POLIZA
      FROM PLZAS
     WHERE POL_PRS_NMRO_IDNTFCCION      = P_LOGIN
       AND POL_ESTADO_PLZA              = 'V';

    EXCEPTION WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20550, 'NO SE PUEDE CONSULTAR LA POLIZA DEL LOGIN ' ||P_LOGIN||'. '||FUN_RET_MENSAJE_ERROR(SQLERRM));
  END;

  IF POLIZA IS NOT NULL OR POLIZA > 0 THEN
    BEGIN
      SELECT POL_NMRO_CRTFCDO
        INTO CERT
        FROM PLZAS
       WHERE POL_NMRO_PLZA        = POLIZA;

      EXCEPTION WHEN NO_DATA_FOUND THEN
                  CERT := 0;
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20551, 'NO SE PUEDE CONSULTAR EL CERIFICADO DE LA POLIZA '||POLIZA||'. '||FUN_RET_MENSAJE_ERROR(SQLERRM));
    END;

    IF CERT != 0 THEN
      BEGIN
        SELECT CER_FCHA_DSDE_ACTUAL
          INTO FECHA
          FROM CRTFCDOS
         WHERE CER_NMRO_CRTFCDO = CERT
           AND CER_NMRO_PLZA = POLIZA;

        EXCEPTION WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20552, 'NO SE PUEDE CONSULTAR EL CERIFICADO Y FECHA DE LA POLIZA ' ||POLIZA||' - '||CERT||'. '||FUN_RET_MENSAJE_ERROR(SQLERRM));
      END;
    ELSE
      BEGIN
        SELECT MAX(CER_FCHA_DSDE_ACTUAL)
          INTO FECHA
          FROM CRTFCDOS
         WHERE CER_ESTDO_PRDCCION = '00';

        EXCEPTION WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20553, 'NO SE PUEDE CONSULTAR EL CERIFICADO Y FECHA DE LA POLIZA ' ||FUN_RET_MENSAJE_ERROR(SQLERRM));
      END;
    END IF;

  ELSE
    RAISE_APPLICATION_ERROR(-20554, 'NO EXISTE POLIZA VIGENTE PARA EL LOGIN '||P_LOGIN);
  END IF;

  RETURN FECHA;
END FUN_FECHA_NOV_DATE;

-------------------------------------------------------------------------
-- FUNCION QUE DEVUELVE LOS CONCEPTOS ASEGURADOS POR SOLCITUD Y AMPARO --
-- MODIFICADO POR: GONZALO CHAPARRO.                     FEBRERO - 2015--
-------------------------------------------------------------------------
FUNCTION FNC_ASEGURADO_AMPARO(P_NSOLICITUD VARCHAR2,
                              P_AMPARO VARCHAR2) RETURN NUMBER AS

V_CANT_ASEGURADOS       NUMBER := 0;

BEGIN
  BEGIN
    SELECT COUNT(8)
      INTO V_CANT_ASEGURADOS
      FROM RSGOS_VGNTES_AVLOR
     WHERE RVL_NMRO_ITEM        = P_NSOLICITUD
       AND RVL_CDGO_AMPRO       = P_AMPARO;

    EXCEPTION WHEN OTHERS THEN
                V_CANT_ASEGURADOS := 0;
  END;

  RETURN V_CANT_ASEGURADOS;
END FNC_ASEGURADO_AMPARO;

-----------------------------------------------------------------
-- FUNCION QUE DEVUELVE SI LA SOLICITUD SE ENCUENTRA ASEGURADA --
-- MODIFICADO POR: GONZALO CHAPARRO.             FEBRERO - 2015--
-----------------------------------------------------------------
FUNCTION FNC_ASEGURADO(P_NSOLICITUD VARCHAR2) RETURN NUMBER AS

V_CANT_ASEGURADOS       NUMBER := 0;

BEGIN
  BEGIN
    SELECT COUNT(8)
      INTO V_CANT_ASEGURADOS
      FROM RSGOS_VGNTES
     WHERE RVI_NMRO_ITEM        = P_NSOLICITUD;

    EXCEPTION WHEN OTHERS THEN
                V_CANT_ASEGURADOS := 0;
  END;

  RETURN V_CANT_ASEGURADOS;
END FNC_ASEGURADO;

---------------------------------------------------------------------------------------------
-- PROCEDIMIENTO DISPARADO DESDE LA APLICACION WEB QUE ME REALIZA EL MOVIMIENTO SOLICITADO --
-- MODIFICADO POR: GONZALO CHAPARRO.                                         FEBRERO - 2015--
-- Modificado por: Asesoftware - Jorge Gallo          
-- Fecha: 21/09/2017
-- Propósito de modificación: se aumenta campo TA_EXCEPCIONES para indicar excepciones a omitir
---------------------------------------------------------------------------------------------
PROCEDURE PRC_GUARDAR_NOVEDAD_SEG_ARREN(NOVEDADES         IN VARCHAR2,
                                        ESTADO_POLIZA     IN VARCHAR2,
                                        SOLICITUD         IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                                        TIPO_IDEN         IN ARRNDTRIOS.ARR_TPO_IDNTFCCION%TYPE,
                                        NMRO_IDEN         IN ARRNDTRIOS.ARR_NMRO_IDNTFCCION%TYPE,
                                        APR_CDGO_AMPRO    IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                                        FECHA_NVDAD       IN DATE,
                                        NUEVO_VALOR       IN NUMBER,
                                        RVL_VLOR          IN NUMBER,
                                        APR_LMTCION_TPO   IN VARCHAR2,
                                        SES_NMRO_PLZA     IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                                        APR_TPO_AMPRO     IN AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE,
                                        RVL_CNCPTO_VLOR   IN V_CONCEPTOS.RVL_CNCPTO_VLOR%TYPE,
                                        DIR_DIRECCION     IN DIRECCIONES.DI_DIRECCION%TYPE,
                                        DIR_DIVPOL_CODIGO IN DIRECCIONES.DI_DIVPOL_CODIGO%TYPE,
                                        DIR_ESTRTO        IN DIRECCIONES.DI_ESTRTO%TYPE,
                                        SES_TPO_INMBLE    IN SLCTDES_ESTDIOS.SES_TPO_INMBLE%TYPE,
                                        SES_DSTNO_INMBLE  IN SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                                        ASISTENCIA        IN VARCHAR2,
                                        TTAL_ASGRDO       IN NUMBER,
                                        RVL_VLOR_ANT      IN NUMBER,
                                        FECHA_INGRESO     IN DATE,
                                        CODIGO_USUARIO    IN VARCHAR2,
                                        ENTRO             IN OUT NUMBER,
                                        FECHA_CONTRATO    IN OUT DATE,
                                        TIPO_AUMENTO      IN OUT VARCHAR2,
                                        MONTO_AUMENTO     IN OUT NUMBER,
                                        IVA_COMERCIAL     IN OUT VARCHAR2,
                                        METRAJE_HOGAR     IN OUT NUMBER,
                                        PI_TA_EXCEPCIONES IN TA_EXCEPCIONES) IS

POLIZA_RETIRO           RSGOS_RCBOS_NVDAD.REN_NMRO_PLZA%TYPE;
PERIODO_RETIRO          RSGOS_RCBOS_NVDAD.REN_FCHA_MDFCCION%TYPE;
EXISTE                  NUMBER;
EXISTE1                 NUMBER;
FECHA_RETIRO            DATE;
ESTA                    VARCHAR2(6);
MENSAJE                 VARCHAR2(4000) := NULL;
TIPO_RES                NUMBER;
AMPARO                  AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE;
V_TARIFA_EXTERNA        VARCHAR2(10) := NULL;
V_VALIDA_SEGURO         VARCHAR2(10) := NULL;

--variables costantes...
PARAM_CODIGO_RAMO       VARCHAR2(2) := '12';
PARAM_CODIGO_CLASE      VARCHAR2(2) := '00';
PARAM_CODIGO_MODULO     VARCHAR2(2) := '2';
GLOBAL_PERIODO          VARCHAR2(6) := NULL;

V_COD_ERROR             VARCHAR2(6) := '0';
V_DESC_ERROR            VARCHAR2(4000) := NULL;
V_EXCEPCION             EXCEPTION;

BEGIN

  IF FECHA_NVDAD IS NOT NULL THEN
    BEGIN
      GLOBAL_PERIODO := TO_CHAR(FECHA_NVDAD, 'MMYYYY');

      EXCEPTION WHEN OTHERS THEN
                  V_COD_ERROR  := '20500';
                  V_DESC_ERROR := SUBSTR('NO SE PUEDE CONSULTAR EL PERIODO FECHA DE LA NOVEDAD '||FECHA_NVDAD||'. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
                  RAISE V_EXCEPCION;
    END;

  ELSE
    V_COD_ERROR  := '20501';
    V_DESC_ERROR := 'LA FECHA DE LA NOVEDAD NO SE ENCUENTRA, POR FAVOR COMUNICARSE CON EL LIBERTADOR';
    RAISE V_EXCEPCION;

  END IF;

  IF NOVEDADES IS NOT NULL THEN

    IF ESTADO_POLIZA = 'V' THEN
      BEGIN
        SELECT COUNT(8)
          INTO EXISTE
          FROM RSGOS_VGNTES
         WHERE RVI_NMRO_ITEM    = SOLICITUD;

        EXCEPTION WHEN OTHERS THEN
                    EXISTE := 0;
      END;

      BEGIN
        SELECT COUNT(8)
          INTO EXISTE1
          FROM RSGOS_RCBOS
         WHERE RIR_NMRO_ITEM    = SOLICITUD;

        EXCEPTION WHEN OTHERS THEN
                    EXISTE := 0;
      END;

      BEGIN
        ESTA := '0';
        IF NOVEDADES != '02' THEN

          BEGIN -- verifica si es clientes rstringido...
            PK_TERCEROS.CLIENTE_RESTRINGIDO(TIPO_IDEN,
                                            NMRO_IDEN,
                                            ESTA,
                                            TIPO_RES,
                                            MENSAJE,
                                            PARAM_CODIGO_MODULO,
                                            NOVEDADES,
                                            'S');

            EXCEPTION WHEN OTHERS THEN
              BEGIN
                PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                           APR_CDGO_AMPRO,
                                                           SOLICITUD,
                                                           SES_NMRO_PLZA,
                                                           NOVEDADES,
                                                           'LA NOVEDAD DEBE SER ENVIADA A EL LIBERTADOR. (CR)',
                                                           NUEVO_VALOR,
                                                           RVL_VLOR,
                                                           CODIGO_USUARIO);

                EXCEPTION WHEN OTHERS THEN
                            V_COD_ERROR  := '20505';
                            V_DESC_ERROR := '* LA NOVEDAD DEBE SER ENVIADA A EL LIBERTADOR.';
                            RAISE V_EXCEPCION;
              END;

              V_COD_ERROR  := '20506';
              V_DESC_ERROR := 'LA NOVEDAD DEBE SER ENVIADA A EL LIBERTADOR. (CR)';
              RAISE V_EXCEPCION; -- sigue siendo parte del exception when others de arriba.
          END;
        END IF;

        IF ESTA = '1' THEN
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       APR_CDGO_AMPRO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       'LA NOVEDAD DEBE SER ENVIADA A EL LIBERTADOR.',
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        V_COD_ERROR  := '20510';
                        V_DESC_ERROR := '* LA NOVEDAD DEBE SER ENVIADA A EL LIBERTADOR.';
                        RAISE V_EXCEPCION;
          END;

          V_COD_ERROR  := '20511';
          V_DESC_ERROR := 'LA NOVEDAD DEBE SER ENVIADA A EL LIBERTADOR.';
          RAISE V_EXCEPCION;
        END IF;
      END;

      BEGIN
        SELECT MAX(REN_FCHA_NVDAD), REN_NMRO_PLZA, REN_FCHA_MDFCCION
          INTO FECHA_RETIRO, POLIZA_RETIRO, PERIODO_RETIRO
          FROM RSGOS_RCBOS_NVDAD
         WHERE REN_CDGO_AMPRO       = '01'
           AND REN_NMRO_ITEM        = SOLICITUD
           AND REN_NMRO_PLZA        = SES_NMRO_PLZA
           AND REN_CLSE_PLZA        = PARAM_CODIGO_RAMO
           AND REN_RAM_CDGO         = PARAM_CODIGO_RAMO
           AND REN_TPO_NVDAD        = '02'
        GROUP BY REN_NMRO_PLZA, REN_FCHA_MDFCCION;

        EXCEPTION WHEN NO_DATA_FOUND THEN
                    FECHA_RETIRO := NULL;
                  WHEN OTHERS THEN -- no tenia el others y se metio.
                    FECHA_RETIRO := NULL;
      END;

      IF NOVEDADES = '01' THEN -- ingreso....

        IF FECHA_RETIRO IS NOT NULL AND POLIZA_RETIRO = SES_NMRO_PLZA AND TO_CHAR(PERIODO_RETIRO, 'MMYYYY') = GLOBAL_PERIODO THEN
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       APR_CDGO_AMPRO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       'ESTA INGRESANDO DE NUEVO UNA SOLICITUD YA RETIRADA. BORRE LA NOVEDAD DE RETIRO Y PROCEDA A INGRESARLA AL SEGURO',
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        V_COD_ERROR  := '20515';
                        V_DESC_ERROR := '* ESTA INGRESANDO DE NUEVO UNA SOLICITUD YA RETIRADA. BORRE LA NOVEDAD DE RETIRO Y PROCEDA A INGRESARLA AL SEGURO.';
                        RAISE V_EXCEPCION;
          END;

          V_COD_ERROR  := '20516';
          V_DESC_ERROR := 'ESTA INGRESANDO DE NUEVO UNA SOLICITUD YA RETIRADA. BORRE LA NOVEDAD DE RETIRO Y PROCEDA A INGRESARLA AL SEGURO.';
          RAISE V_EXCEPCION;

        ELSE
          IF EXISTE > 0 AND APR_CDGO_AMPRO = '01' AND RVL_CNCPTO_VLOR = '01' THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'LA SOLICITUD ESTA ASEGURADA. LA NOVEDAD DE INGRESO YA FUE REALIZADA.',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          V_COD_ERROR  := '20520';
                          V_DESC_ERROR := '* LA SOLICITUD ESTA ASEGURADA. LA NOVEDAD DE INGRESO YA FUE REALIZADA. ';
                          RAISE V_EXCEPCION;
            END;

            V_COD_ERROR  := '20521';
            V_DESC_ERROR := 'LA SOLICITUD ESTA ASEGURADA. LA NOVEDAD DE INGRESO YA FUE REALIZADA.';
            RAISE V_EXCEPCION;

          ELSE
            BEGIN
              PKG_NOVEDADES_WEB_JAVA.INGRESO_SEGURO(DIR_ESTRTO,
                                                    NOVEDADES,
                                                    SES_TPO_INMBLE,
                                                    SES_DSTNO_INMBLE,
                                                    DIR_DIRECCION,
                                                    RVL_CNCPTO_VLOR,
                                                    APR_CDGO_AMPRO,
                                                    SOLICITUD,
                                                    FECHA_NVDAD,
                                                    APR_LMTCION_TPO,
                                                    SES_NMRO_PLZA,
                                                    NUEVO_VALOR,
                                                    RVL_VLOR,
                                                    ASISTENCIA,
                                                    APR_TPO_AMPRO,
                                                    TTAL_ASGRDO,
                                                    DIR_DIVPOL_CODIGO,
                                                    CODIGO_USUARIO,
                                                    ENTRO,
                                                    FECHA_CONTRATO,
                                                    TIPO_AUMENTO,
                                                    MONTO_AUMENTO,
                                                    IVA_COMERCIAL,
                                                    METRAJE_HOGAR,
                                                    PI_TA_EXCEPCIONES);

              EXCEPTION WHEN OTHERS THEN
                          V_COD_ERROR  := '20523';
                          V_DESC_ERROR := SUBSTR('RESULTADO DEL INGRESO: '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
                          RAISE V_EXCEPCION;
            END;
          END IF;
        END IF;

      ELSIF NOVEDADES = '02' THEN -- novedad de retiro...

        IF APR_TPO_AMPRO = 'B' THEN
          IF EXISTE = 0 THEN
            IF EXISTE1 = 0 THEN
              BEGIN
                PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                           APR_CDGO_AMPRO,
                                                           SOLICITUD,
                                                           SES_NMRO_PLZA,
                                                           NOVEDADES,
                                                           'LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO',
                                                           NUEVO_VALOR,
                                                           RVL_VLOR,
                                                           CODIGO_USUARIO);

                EXCEPTION WHEN OTHERS THEN
                            V_COD_ERROR  := '20525';
                            V_DESC_ERROR := '* LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO.';
                            RAISE V_EXCEPCION;
              END;

              V_COD_ERROR  := '20526';
              V_DESC_ERROR := 'LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO.';
              RAISE V_EXCEPCION;

            ELSE
              BEGIN
                PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                           APR_CDGO_AMPRO,
                                                           SOLICITUD,
                                                           SES_NMRO_PLZA,
                                                           NOVEDADES,
                                                           'LA SOLICITUD NO ESTA ASEGURADA. LA NOVEDAD DE RETIRO YA FUE REALIZADA.',
                                                           NUEVO_VALOR,
                                                           RVL_VLOR,
                                                           CODIGO_USUARIO);

                EXCEPTION WHEN OTHERS THEN
                            V_COD_ERROR  := '20530';
                            V_DESC_ERROR := '* LA SOLICITUD NO ESTA ASEGURADA. LA NOVEDAD DE RETIRO YA FUE REALIZADA.';
                            RAISE V_EXCEPCION;
              END;

              V_COD_ERROR  := '20531';
              V_DESC_ERROR := 'LA SOLICITUD NO ESTA ASEGURADA. LA NOVEDAD DE RETIRO YA FUE REALIZADA.';
              RAISE V_EXCEPCION;
            END IF;

          ELSE
            BEGIN
              AMPARO := NULL;
              PKG_NOVEDADES_WEB_JAVA.RETIRO_SEGURO(SOLICITUD,
                                                   SES_NMRO_PLZA,
                                                   AMPARO,
                                                   FECHA_NVDAD,
                                                   NOVEDADES,
                                                   NUEVO_VALOR,
                                                   RVL_VLOR,
                                                   TTAL_ASGRDO,
                                                   CODIGO_USUARIO,
                                                   SES_DSTNO_INMBLE,
                                                   DIR_DIVPOL_CODIGO);

              EXCEPTION WHEN OTHERS THEN
                          V_COD_ERROR  := '20535';
                          V_DESC_ERROR := SUBSTR('RESULTADO DEL RETIRO: '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
                          RAISE V_EXCEPCION;
            END;
          END IF;

        ELSE
          BEGIN
            V_TARIFA_EXTERNA := PKG_OPERACION.FUN_TRFCION_EXTERNA(APR_CDGO_AMPRO, PARAM_CODIGO_RAMO);

            EXCEPTION WHEN OTHERS THEN -- revisar si la funcion falla, se manda la excepcion?....
                        V_TARIFA_EXTERNA := 'N';
          END;

          IF V_TARIFA_EXTERNA = 'S' THEN
            IF EXISTE = 0 THEN
              IF EXISTE1 = 0 THEN
                BEGIN
                  PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                             APR_CDGO_AMPRO,
                                                             SOLICITUD,
                                                             SES_NMRO_PLZA,
                                                             NOVEDADES,
                                                             'LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO',
                                                             NUEVO_VALOR,
                                                             RVL_VLOR,
                                                             CODIGO_USUARIO);

                  EXCEPTION WHEN OTHERS THEN
                              V_COD_ERROR  := '20540';
                              V_DESC_ERROR := '* LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO.';
                              RAISE V_EXCEPCION;
                END;

                V_COD_ERROR  := '20541';
                V_DESC_ERROR := 'LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO.';
                RAISE V_EXCEPCION;

              ELSE
                BEGIN
                  PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                             APR_CDGO_AMPRO,
                                                             SOLICITUD,
                                                             SES_NMRO_PLZA,
                                                             NOVEDADES,
                                                             'LA SOLICITUD NO ESTA ASEGURADA. LA NOVEDAD DE RETIRO YA FUE REALIZADA.',
                                                             NUEVO_VALOR,
                                                             RVL_VLOR,
                                                             CODIGO_USUARIO);

                  EXCEPTION WHEN OTHERS THEN
                              V_COD_ERROR  := '20545';
                              V_DESC_ERROR := '* LA SOLICITUD NO ESTA ASEGURADA. LA NOVEDAD DE RETIRO YA FUE REALIZADA.';
                              RAISE V_EXCEPCION;
                END;

                V_COD_ERROR  := '20546';
                V_DESC_ERROR := 'LA SOLICITUD NO ESTA ASEGURADA. LA NOVEDAD DE RETIRO YA FUE REALIZADA.';
                RAISE V_EXCEPCION;
              END IF;

            ELSE
              BEGIN
               V_VALIDA_SEGURO := PKG_OPERACION.FUN_VALIDA_SEGURO(SOLICITUD, APR_CDGO_AMPRO, PARAM_CODIGO_RAMO, PARAM_CODIGO_CLASE);

                EXCEPTION WHEN OTHERS THEN -- revisar si la funcion falla, se manda la excepcion?....
                            V_VALIDA_SEGURO := 'N';
              END;

              IF V_VALIDA_SEGURO = 'S' THEN
                BEGIN
                  PKG_NOVEDADES_WEB_JAVA.RETIRO_SEGURO(SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       APR_CDGO_AMPRO,
                                                       FECHA_NVDAD,
                                                       NOVEDADES,
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       TTAL_ASGRDO,
                                                       CODIGO_USUARIO,
                                                       SES_DSTNO_INMBLE,
                                                       DIR_DIVPOL_CODIGO);

                  EXCEPTION WHEN OTHERS THEN
                              V_COD_ERROR  := '20548';
                              V_DESC_ERROR := SUBSTR('RESULTADO DEL RETIRO: '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
                              RAISE V_EXCEPCION;
                END;

              ELSE
                BEGIN
                  PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                             APR_CDGO_AMPRO,
                                                             SOLICITUD,
                                                             SES_NMRO_PLZA,
                                                             NOVEDADES,
                                                             'LA SOLICITUD NO ESTA ASEGURADA POR ESTE AMPARO. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO',
                                                             NUEVO_VALOR,
                                                             RVL_VLOR,
                                                             CODIGO_USUARIO);

                  EXCEPTION WHEN OTHERS THEN
                              V_COD_ERROR  := '20550';
                              V_DESC_ERROR := '* LA SOLICITUD NO ESTA ASEGURADA POR ESTE AMPARO. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO.';
                              RAISE V_EXCEPCION;
                END;

                V_COD_ERROR  := '20551';
                V_DESC_ERROR := 'LA SOLICITUD NO ESTA ASEGURADA POR ESTE AMPARO. NO PUEDE REALIZAR LA NOVEDAD DE RETIRO';
                RAISE V_EXCEPCION;
              END IF;
            END IF;

          ELSE
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'NO PUEDE REALIZAR RETIROS DE AMPAROS ADICIONALES. POR FAVOR ENVIE LA NOVEDAD A EL LIBERTADOR.',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          V_COD_ERROR  := '20555';
                          V_DESC_ERROR := '* NO PUEDE REALIZAR RETIROS DE AMPAROS ADICIONALES. POR FAVOR ENVIE LA NOVEDAD A EL LIBERTADOR.';
                          RAISE V_EXCEPCION;
            END;

            V_COD_ERROR  := '20556';
            V_DESC_ERROR := 'NO PUEDE REALIZAR RETIROS DE AMPAROS ADICIONALES. POR FAVOR ENVIE LA NOVEDAD A EL LIBERTADOR.';
            RAISE V_EXCEPCION;
          END IF;
        END IF;

      ELSIF NOVEDADES = '03' THEN -- novedad de modificacion....

        IF EXISTE = 0 THEN
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       APR_CDGO_AMPRO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       'LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE MODIFICACION',
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        V_COD_ERROR  := '20560';
                        V_DESC_ERROR := '* LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE MODIFICACION.';
                        RAISE V_EXCEPCION;
          END;

          V_COD_ERROR  := '20561';
          V_DESC_ERROR := 'LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE MODIFICACION.';
          RAISE V_EXCEPCION;
        END IF;

        IF DIR_DIRECCION IS NOT NULL AND DIR_DIVPOL_CODIGO IS NOT NULL THEN

          BEGIN
            INSERT INTO RSGOS_VGNTES_NVDDES(RIVN_FCHA_NVDAD, RIVN_CDGO_AMPRO, RIVN_RAM_CDGO, RIVN_NMRO_ITEM,
                                            RIVN_NMRO_PLZA, RIVN_CLSE_PLZA, RIVN_TPO_NVDAD, RIVN_VLOR_DFRNCIA,
                                            RIVN_FCHA_MDFCCION, RIVN_USRIO)
                                    VALUES (FECHA_NVDAD, APR_CDGO_AMPRO, PARAM_CODIGO_RAMO, SOLICITUD,
                                            SES_NMRO_PLZA, PARAM_CODIGO_CLASE, NOVEDADES, 0,
                                            FECHA_NVDAD, CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        V_COD_ERROR  := '20563';
                        V_DESC_ERROR := SUBSTR('NO SE PUDO INGRESAR EL RIESGO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
                        RAISE V_EXCEPCION;
          END;

          IF SQL%NOTFOUND THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'NO SE PUDO INGRESAR LA NOVEDAD DE MODIFICACION',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          V_COD_ERROR  := '20565';
                          V_DESC_ERROR := '* NO SE PUDO INGRESAR LA NOVEDAD DE MODIFICACION.';
                          RAISE V_EXCEPCION;
            END;

            V_COD_ERROR  := '20566';
            V_DESC_ERROR := 'NO SE PUDO INGRESAR LA NOVEDAD DE MODIFICACION.';
            RAISE V_EXCEPCION;
          END IF;

          BEGIN
            UPDATE DIRECCIONES
               SET DI_DIVPOL_CODIGO     = DIR_DIVPOL_CODIGO,
                   DI_DIRECCION         = DIR_DIRECCION,
                   DI_ESTRTO            = DIR_ESTRTO
             WHERE DI_SOLICITUD             = SOLICITUD
               AND DI_TPO_DRCCION           = 'R';


            EXCEPTION WHEN OTHERS THEN
                        V_COD_ERROR  := '20568';
                        V_DESC_ERROR := SUBSTR('NO SE PUDO ACTUALIZAR LA DIRECCION DE LA SOLICITUD. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
                        RAISE V_EXCEPCION;
          END;

          IF SQL%NOTFOUND THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'NO SE PUDO ACTUALIZAR LA DIRECCION DE LA SOLICITUD ',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          V_COD_ERROR  := '20565';
                          V_DESC_ERROR := '* NO SE PUDO ACTUALIZAR LA DIRECCION DE LA SOLICITUD.';
                          RAISE V_EXCEPCION;
            END;

            V_COD_ERROR  := '20566';
            V_DESC_ERROR := 'NO SE PUDO ACTUALIZAR LA DIRECCION DE LA SOLICITUD. ';
            RAISE V_EXCEPCION;
          END IF;

          ROLLBACK; -- este pedazo para que será????? GCHL 06022015.
          V_COD_ERROR  := '20568';
          V_DESC_ERROR := 'LA MODIFICACION DE LA DIRECCION FUE REALIZADA.';
          RAISE V_EXCEPCION;

        END IF;

      ELSIF NOVEDADES = '04' THEN -- novedad de aumento.

        IF APR_LMTCION_TPO = 'S' THEN
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       APR_CDGO_AMPRO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       'ESTE TIPO DE NOVEDAD NO ESTÁ PERMITIDO PARA EL AMPARO.',
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        V_COD_ERROR  := '20570';
                        V_DESC_ERROR := '* ESTE TIPO DE NOVEDAD NO ESTÁ PERMITIDO PARA EL AMPARO.';
                        RAISE V_EXCEPCION;
          END;

          V_COD_ERROR  := '20571';
          V_DESC_ERROR := 'ESTE TIPO DE NOVEDAD NO ESTÁ PERMITIDO PARA EL AMPARO. ';
          RAISE V_EXCEPCION;
        END IF;

        IF APR_TPO_AMPRO = 'B' THEN
          IF NUEVO_VALOR != 0 or (NUEVO_VALOR = 0 and rvl_cncpto_vlor = '02') THEN
            IF EXISTE = 0 THEN
              BEGIN
                PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                           APR_CDGO_AMPRO,
                                                           SOLICITUD,
                                                           SES_NMRO_PLZA,
                                                           NOVEDADES,
                                                           'LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE AUMENTO',
                                                           NUEVO_VALOR,
                                                           RVL_VLOR,
                                                           CODIGO_USUARIO);

                EXCEPTION WHEN OTHERS THEN
                            V_COD_ERROR  := '20575';
                            V_DESC_ERROR := '* LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE AUMENTO.';
                            RAISE V_EXCEPCION;
              END;

              V_COD_ERROR  := '20576';
              V_DESC_ERROR := 'LA SOLICITUD NO ESTA ASEGURADA. NO PUEDE REALIZAR LA NOVEDAD DE AUMENTO. ';
              RAISE V_EXCEPCION;

            ELSE
              BEGIN
                PKG_NOVEDADES_WEB_JAVA.PRC_AUMENTO_SEGURO(SOLICITUD,
                                                          SES_NMRO_PLZA,
                                                          APR_CDGO_AMPRO,
                                                          APR_TPO_AMPRO,
                                                          FECHA_NVDAD,
                                                          NOVEDADES,
                                                          NUEVO_VALOR,
                                                          RVL_VLOR,
                                                          RVL_VLOR_ANT,
                                                          RVL_CNCPTO_VLOR,
                                                          TTAL_ASGRDO,
                                                          FECHA_INGRESO,
                                                          CODIGO_USUARIO,
                                                          ENTRO,
                                                          SES_DSTNO_INMBLE,
                                                          DIR_DIVPOL_CODIGO,
                                                          IVA_COMERCIAL,
                                                          PI_TA_EXCEPCIONES);

                EXCEPTION WHEN OTHERS THEN
                            V_COD_ERROR  := '20578';
                            V_DESC_ERROR := SUBSTR('RESULTADO DEL AUMENTO: '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
                            RAISE V_EXCEPCION;
              END;

            END IF;

          ELSE
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'LA SOLICITUD NO SE ENCUENTRA ASEGURADA. NO PUEDE HACER AUMENTO DE VALOR ASEGURADO.',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          V_COD_ERROR  := '20580';
                          V_DESC_ERROR := '* LA SOLICITUD NO SE ENCUENTRA ASEGURADA. NO PUEDE HACER AUMENTO DE VALOR ASEGURADO.';
                          RAISE V_EXCEPCION;
            END;

            V_COD_ERROR  := '20581';
            V_DESC_ERROR := 'LA SOLICITUD NO SE ENCUENTRA ASEGURADA. NO PUEDE HACER AUMENTO DE VALOR ASEGURADO. ';
            RAISE V_EXCEPCION;
          END IF;

        ELSE
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       APR_CDGO_AMPRO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       'NO PUEDE REALIZAR AUMENTOS DE AMPAROS ADICIONALES. ENVIE LA NOVEDAD A EL LIBERTADOR.',
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        V_COD_ERROR  := '20585';
                        V_DESC_ERROR := '* NO PUEDE REALIZAR AUMENTOS DE AMPAROS ADICIONALES. ENVIE LA NOVEDAD A EL LIBERTADOR.';
                        RAISE V_EXCEPCION;
          END;

          V_COD_ERROR  := '20586';
          V_DESC_ERROR := 'NO PUEDE REALIZAR AUMENTOS DE AMPAROS ADICIONALES. ENVIE LA NOVEDAD A EL LIBERTADOR. ';
          RAISE V_EXCEPCION;
        END IF;

      ELSE
        BEGIN
          PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                     APR_CDGO_AMPRO,
                                                     SOLICITUD,
                                                     SES_NMRO_PLZA,
                                                     NOVEDADES,
                                                     'OPCION NO HABILITADA. CONTACTESE CON EL LIBERTADOR.',
                                                     NUEVO_VALOR,
                                                     RVL_VLOR,
                                                     CODIGO_USUARIO);

          EXCEPTION WHEN OTHERS THEN
                      V_COD_ERROR  := '20590';
                      V_DESC_ERROR := '* OPCION NO HABILITADA. CONTACTESE CON EL LIBERTADOR.';
                      RAISE V_EXCEPCION;
        END;

        V_COD_ERROR  := '20591';
        V_DESC_ERROR := 'OPCION NO HABILITADA. CONTACTESE CON EL LIBERTADOR.';
        RAISE V_EXCEPCION;
      END IF;

    ELSE -- si la poliza no esta vigente...
      BEGIN
        PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                   APR_CDGO_AMPRO,
                                                   SOLICITUD,
                                                   SES_NMRO_PLZA,
                                                   NOVEDADES,
                                                   'LA POLIZA DE LA SOLICITUD NO ESTA VIGENTE, NO SE PERMITE HACER NINGUNA NOVEDAD',
                                                   NUEVO_VALOR,
                                                   RVL_VLOR,
                                                   CODIGO_USUARIO);

        EXCEPTION WHEN OTHERS THEN
                    V_COD_ERROR  := '20595';
                    V_DESC_ERROR := '* LA POLIZA DE LA SOLICITUD NO ESTA VIGENTE, NO SE PERMITE HACER NINGUNA NOVEDAD.';
                    RAISE V_EXCEPCION;
      END;

      V_COD_ERROR  := '20596';
      V_DESC_ERROR := 'LA POLIZA DE LA SOLICITUD NO ESTA VIGENTE, NO SE PERMITE HACER NINGUNA NOVEDAD';
      RAISE V_EXCEPCION;

    END IF; -- final de pliza 'v'.

  ELSE
    V_COD_ERROR  := '20503';
    V_DESC_ERROR := 'POR FAVOR INGRESE LA NOVEDAD QUE DESEA REALIZAR';
    RAISE V_EXCEPCION;

  END IF;

  EXCEPTION WHEN V_EXCEPCION THEN
              --ROLLBACK;
              RAISE_APPLICATION_ERROR(-20022, V_COD_ERROR||': '|| V_DESC_ERROR);
            WHEN OTHERS THEN
              ROLLBACK;
              RAISE_APPLICATION_ERROR(-20022, SUBSTR('MENSAJE: ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
END PRC_GUARDAR_NOVEDAD_SEG_ARREN;

----------------------------------------------------------------------
-- PROCEDIMIENTO QUE EJECUTA EL INGRESO DE UNA NOVEDAD DESDE LA WEB --
-- MODIFICADO POR: GONZALO CHAPARRO.                 FEBRERO - 2015 --
-- Modificado por: Asesoftware - Jorge Gallo          
-- Fecha: 21/09/2017
-- Propósito de modificación: se aumenta campo TA_EXCEPCIONES para indicar excepciones a omitir
----------------------------------------------------------------------
PROCEDURE INGRESO_SEGURO(DIR_ESTRTO         IN DIRECCIONES.DI_ESTRTO%TYPE,
                         NOVEDADES          IN VARCHAR2,
                         P_SES_TPO_INMBLE   IN SLCTDES_ESTDIOS.SES_TPO_INMBLE%TYPE,
                         P_SES_DSTNO_INMBLE IN SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                         DIR_DIRECCION      IN DIRECCIONES.DI_DIRECCION%TYPE,
                         RVL_CNCPTO_VLOR    IN V_CONCEPTOS.RVL_CNCPTO_VLOR%TYPE,
                         APR_CDGO_AMPRO     IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                         SOLICITUD          IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                         FECHA_NVDAD        IN DATE,
                         APR_LMTCION_TPO    IN VARCHAR2,
                         SES_NMRO_PLZA      IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                         NUEVO_VALOR        IN NUMBER,
                         RVL_VLOR           IN NUMBER,
                         ASISTENCIA         IN VARCHAR2,
                         APR_TPO_AMPRO      IN AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE,
                         TTAL_ASGRDO        IN NUMBER,
                         DIR_DIVPOL_CODIGO  IN DIRECCIONES.DI_DIVPOL_CODIGO%TYPE,
                         CODIGO_USUARIO     IN VARCHAR2,
                         ENTRO              IN OUT NUMBER,
                         FECHA_CONTRATO     IN OUT DATE,
                         TIPO_AUMENTO       IN OUT VARCHAR2,
                         MONTO_AUMENTO      IN OUT NUMBER,
                         IVA_COMERCIAL      IN OUT VARCHAR2,
                         METRAJE_HOGAR      IN OUT NUMBER,
                         PI_TA_EXCEPCIONES IN TA_EXCEPCIONES) IS

RECHAZO                 VARCHAR2(3);
DESCRIPCION             VARCHAR2(1000);
MENSAJE                 VARCHAR2(4000) := NULL;
CERTIFICADO             NUMBER(10);
MENSAJE_INF             VARCHAR2(4000) := NULL;
TIPO                    VARCHAR2(1);
FCHA_NVDAD              DATE;
FECHA_NVDAD_SALIDA      DATE := FECHA_NVDAD;
V_DIRECCION             DIRECCIONES.DI_DIRECCION%TYPE;
V_TIPO                  DIRECCIONES.DI_TPO_DRCCION%TYPE;

------ costantes.
PARAM_CODIGO_RAMO       VARCHAR2(2) := '12';
PARAM_CODIGO_CLASE      VARCHAR2(2) := '00';
PARAM_CODIGO_MODULO     VARCHAR2(2) := '2';
PARAM_CODIGO_COMPANIA   VARCHAR2(2) := '40';
PARAM_CODIGO_SUCURSAL   VARCHAR2(5);
PARAM_CODIGO_COMPAÑIA   VARCHAR2(2) := '40';
GLOBAL_PERIODO          VARCHAR2(6) := NULL;
EXISTE                  NUMBER;
FECHA_ACTUAL            DATE;

BEGIN

  BEGIN --dap. mantis 11747 se debe traer la sucursal de la póliza. 26/11/2012.
    SELECT POL_SUC_CDGO
      INTO PARAM_CODIGO_SUCURSAL
      FROM PLZAS
     WHERE POL_NMRO_PLZA    = SES_NMRO_PLZA
       AND POL_RAM_CDGO     = '12'
       AND POL_CDGO_CLSE    = '00';

    EXCEPTION WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20023, 'NO SE ENCONTRO LA SUCURSAL DE LA POLIZA '||SES_NMRO_PLZA);
  END;

  BEGIN
    FECHA_ACTUAL := PKG_NOVEDADES_WEB.TRAER_FECHA(SES_NMRO_PLZA,
                                                  PARAM_CODIGO_RAMO,
                                                  PARAM_CODIGO_CLASE,
                                                  NOVEDADES,
                                                  MENSAJE);

    EXCEPTION WHEN OTHERS THEN
                FECHA_ACTUAL := NULL;
                MENSAJE := MENSAJE;
  END;

  IF MENSAJE IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20024, 'NO SE ENCONTRO LA FECHA DE LA NOVEDAD, '||MENSAJE);
  END IF;

  BEGIN
    GLOBAL_PERIODO := TO_CHAR(FECHA_ACTUAL, 'MMYYYY');

    EXCEPTION WHEN OTHERS THEN
                GLOBAL_PERIODO := NULL;
  END;

  IF DIR_ESTRTO IS NULL THEN
    RAISE_APPLICATION_ERROR(-20025, 'NO HA DILIGENCIADO EL CAMPO DE ESTRATO DEL INMUEBLE A ASEGURAR.');
  END IF;

  IF P_SES_TPO_INMBLE IN ('S', 'X') OR P_SES_TPO_INMBLE IS NULL THEN
    RAISE_APPLICATION_ERROR(-20026, 'DEBE DILIGENCIAR EL TIPO DE INMUEBLE A ASEGURAR.');
  END IF;

  IF P_SES_DSTNO_INMBLE IN ('S') OR P_SES_DSTNO_INMBLE IS NULL THEN
    RAISE_APPLICATION_ERROR(-20027, 'DEBE DILIGENCIAR EL DESTINO DEL INMUEBLE A ASEGURAR.');
  END IF;
  
  IF P_SES_DSTNO_INMBLE = 'C' AND P_SES_TPO_INMBLE IN ('L','O')  THEN -- comercio, local y oficina...
    IF METRAJE_HOGAR IS NULL THEN -- si el metraje es nulo ... 
      RAISE_APPLICATION_ERROR(-20028, 'EL CAMPO METRAJE NO PUEDE SER VACIO');
    ELSIF METRAJE_HOGAR < 0 THEN -- si el metraje es menor a cero ... 
      RAISE_APPLICATION_ERROR(-20028, 'EL CAMPO METRAJE NO PUEDE SER MENOR QUE CERO');      
    ELSE
      IF APR_CDGO_AMPRO = '11' THEN -- amparo hogar ...
        IF METRAJE_HOGAR < 1 THEN 
          RAISE_APPLICATION_ERROR(-20025, 'PARA EL AMPARO HOGAR EL METRAJE DEBE ESTAR ENTRE 1 Y 400 MTS'); 
        ELSIF METRAJE_HOGAR > 400 THEN   
          RAISE_APPLICATION_ERROR(-20026, 'PARA EL AMPARO HOGAR EL METRAJE DEBE ESTAR ENTRE 1 Y 400 MTS'); 
        END IF;
      ELSE -- demas amparos ...
        IF METRAJE_HOGAR < 0 THEN 
          RAISE_APPLICATION_ERROR(-20025, 'PARA ESTE AMPARO EL METRAJE DEBE ESTAR ENTRE 0 Y 400 MTS'); 
        ELSIF METRAJE_HOGAR > 400 THEN   
          RAISE_APPLICATION_ERROR(-20026, 'PARA ESTE AMPARO HOGAR EL METRAJE DEBE ESTAR ENTRE 0 Y 400 MTS'); 
        END IF;
      END IF;
    END IF;    
  END IF;

  IF DIR_DIRECCION LIKE 'PENDIENT%' THEN
    RAISE_APPLICATION_ERROr(-20028, 'DEBE DILIGENCIAR CORRECTAMENTE LA DIRECCIÓN DEL INMUEBLE.');
  END IF;

  IF RVL_CNCPTO_VLOR NOT IN ('02', '31') THEN
    BEGIN
      PKG_NOVEDADES_WEB.VALIDAR_SEGURO(SOLICITUD, APR_CDGO_AMPRO, MENSAJE);

      EXCEPTION WHEN OTHERS THEN
                  MENSAJE := SUBSTR('NO SE HA PODIDO VALIDAR EL ESTADO DE LA SOLICITUD.. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
    END;

  ELSE
    BEGIN
      SELECT COUNT(8)
        INTO EXISTE
        FROM RSGOS_VGNTES_NVDDES N
       WHERE N.RIVN_NMRO_ITEM               = SOLICITUD
         AND N.RIVN_CDGO_AMPRO              = '01'
         AND TRUNC(N.RIVN_FCHA_MDFCCION)    < TRUNC(FECHA_NVDAD);

      EXCEPTION WHEN OTHERS THEN
                EXISTE := 0;
    END;

    IF EXISTE > 0 THEN
      IF RVL_CNCPTO_VLOR <> '31' THEN
        BEGIN
          PKG_NOVEDADES_WEB.VALIDAR_SEGURO(SOLICITUD, APR_CDGO_AMPRO, MENSAJE);

          EXCEPTION WHEN OTHERS THEN
                      MENSAJE := SUBSTR('NO SE HA PODIDO VALIDAR EL ESTADO DE LA SOLICITUD. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900);
        END;
      END IF;
    END IF;
  END IF;

  IF MENSAJE IS NOT NULL THEN
    BEGIN
      PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                 APR_CDGO_AMPRO,
                                                 SOLICITUD,
                                                 SES_NMRO_PLZA,
                                                 NOVEDADES,
                                                 'NO SE HA PODIDO VALIDAR EL ESTADO DE LA SOLICITUD. '||MENSAJE,
                                                 NUEVO_VALOR,
                                                 RVL_VLOR,
                                                 CODIGO_USUARIO);

      EXCEPTION WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20029, '* NO SE HA PODIDO VALIDAR EL ESTADO DE LA SOLICITUD, '||MENSAJE);
    END;

    RAISE_APPLICATION_ERROR(-20030, 'NO SE HA PODIDO VALIDAR EL ESTADO DE LA SOLICITUD. '||MENSAJE);
  END IF;

  RECHAZO := NULL;
  IF RVL_CNCPTO_VLOR = '01' THEN
    FCHA_NVDAD := FECHA_NVDAD;
  END IF;

  IF RVL_CNCPTO_VLOR = '02' THEN
    BEGIN
      BUSCAR_CERTIFICADO(SES_NMRO_PLZA, PARAM_CODIGO_CLASE, PARAM_CODIGO_RAMO, CERTIFICADO);

      EXCEPTION WHEN OTHERS THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'NO SE HA PODIDO ENCONTRAR EL NUMERO DE CERTIFICADO DE LA POLIZA.',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          RAISE_APPLICATION_ERROR(-20031, '* NO SE HA PODIDO ENCONTRAR EL NUMERO DE CERTIFICADO DE LA POLIZA.');
            END;

            RAISE_APPLICATION_ERROR(-20032, 'NO SE HA PODIDO ENCONTRAR EL NUMERO DE CERTIFICADO DE LA POLIZA. '); -- hace parte del exception..
    END;

    BEGIN
      INSERT INTO NVDDES_CTA
          (NVC_CDGO_AMPRO,
           NVC_NMRO_ITEM,
           NVC_NMRO_PLZA,
           NVC_CLSE_PLZA,
           NVC_RAM_CDGO,
           NVC_TPO_NVDAD,
           NVC_FCHA_NVDAD,
           NVC_NMRO_CRTFCDO,
           NVC_USRIO,
           NVC_FCHA_ACTLZCION)
      VALUES
          (APR_CDGO_AMPRO,
           SOLICITUD,
           SES_NMRO_PLZA,
           PARAM_CODIGO_CLASE,
           PARAM_CODIGO_RAMO,
           NOVEDADES,
           FECHA_NVDAD,
           CERTIFICADO,
           CODIGO_USUARIO,
           SYSDATE);

      EXCEPTION WHEN OTHERS THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'NO SE HA PODIDO ACTUALIZAR LA NOVEDAD DE INGRESO DE CUOTA.',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          RAISE_APPLICATION_ERROR(-20033, '* NO SE HA PODIDO ACTUALIZAR LA NOVEDAD DE INGRESO DE CUOTA.');
            END;

            RAISE_APPLICATION_ERROR(-20034, 'NO SE HA PODIDO ACTUALIZAR LA NOVEDAD DE INGRESO DE CUOTA.'); -- hace parte del exception...
    END;
  END IF;

  IF RVL_CNCPTO_VLOR = '02' AND RVL_VLOR > 0 THEN
    IF FCHA_NVDAD != FECHA_NVDAD THEN
      BEGIN
        PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                   APR_CDGO_AMPRO,
                                                   SOLICITUD,
                                                   SES_NMRO_PLZA,
                                                   NOVEDADES,
                                                   'LA FECHA DE INGRESO DE LA CUOTA DE ADMINISTRACIÓN ES DIFERENTE A LA DEL CANÓN DE ARRENDAMIENTO. POR FAVOR VERIFIQUE',
                                                   NUEVO_VALOR,
                                                   RVL_VLOR,
                                                   CODIGO_USUARIO);

        EXCEPTION WHEN OTHERS THEN
                   RAISE_APPLICATION_ERROR(-20035, '* LA FECHA DE INGRESO DE LA CUOTA DE ADMINISTRACIÓN ES DIFERENTE A LA DEL CANÓN DE ARRENDAMIENTO. POR FAVOR VERIFIQUE.');
      END;

      RAISE_APPLICATION_ERROR(-20036, 'LA FECHA DE INGRESO DE LA CUOTA DE ADMINISTRACIÓN ES DIFERENTE A LA DEL CANÓN DE ARRENDAMIENTO. POR FAVOR VERIFIQUE.');
    END IF;
  END IF;

  IF RVL_CNCPTO_VLOR = '02' AND RVL_VLOR = 0 THEN
      NULL;

  ELSE
    IF APR_CDGO_AMPRO != '01' and NUEVO_VALOR != 0 THEN
      --DBMS_OUTPUT.PUT_LINE('ENTRO POR AQUI 1');
      rechazo := 21;
    END IF;

    IF APR_LMTCION_TPO = 'S' THEN
      IF P_SES_TPO_INMBLE NOT IN ('A', 'C', 'O', 'L') THEN  -- adiciona local y oficina por web GCHL 20092017..
        BEGIN
          PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                     APR_CDGO_AMPRO,
                                                     SOLICITUD,
                                                     SES_NMRO_PLZA,
                                                     NOVEDADES,
                                                     'NO SE PUEDE REGISTRAR EL INGRESO AL SEGURO. EL TIPO DE INMUEBLE NO ESTÁ PERMITIDO DENTRO DEL CONTRATO.',
                                                     NUEVO_VALOR,
                                                     RVL_VLOR,
                                                     CODIGO_USUARIO);

          EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20040, '* NO SE PUEDE REGISTRAR EL INGRESO AL SEGURO. EL TIPO DE INMUEBLE NO ESTÁ PERMITIDO DENTRO DEL CONTRATO.');
        END;

        RAISE_APPLICATION_ERROR(-20041, 'NO SE PUEDE REGISTRAR EL INGRESO AL SEGURO. EL TIPO DE INMUEBLE NO ESTÁ PERMITIDO DENTRO DEL CONTRATO.');
      END IF;

      IF NVL(ASISTENCIA, 'N') = 'N' THEN
        BEGIN
          PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                     APR_CDGO_AMPRO,
                                                     SOLICITUD,
                                                     SES_NMRO_PLZA,
                                                     NOVEDADES,
                                                     'NO SE PUEDE REGISTRAR EL INGRESO AL SEGURO. LA PÓLIZA NO TIENE CONSTITUIDO CONVENIO DE ASISTENCIA.',
                                                     NUEVO_VALOR,
                                                     RVL_VLOR,
                                                     CODIGO_USUARIO);

          EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20045, '* NO SE PUEDE REGISTRAR EL INGRESO AL SEGURO. LA PÓLIZA NO TIENE CONSTITUIDO CONVENIO DE ASISTENCIA.');
        END;

        RAISE_APPLICATION_ERROR(-20046, 'NO SE PUEDE REGISTRAR EL INGRESO AL SEGURO. LA PÓLIZA NO TIENE CONSTITUIDO CONVENIO DE ASISTENCIA.');
      END IF;
    END IF;

    BEGIN
      PKG_OPERACION.PRC_VALIDA_MANUAL('N',
                                      NOVEDADES,
                                      SOLICITUD,
                                      SES_NMRO_PLZA,
                                      PARAM_CODIGO_CLASE,
                                      PARAM_CODIGO_RAMO,
                                      APR_CDGO_AMPRO,
                                      FECHA_NVDAD,
                                      CERTIFICADO,
                                      RVL_CNCPTO_VLOR,
                                      RVL_VLOR,
                                      PARAM_CODIGO_COMPANIA,
                                      PARAM_CODIGO_SUCURSAL,
                                      APR_TPO_AMPRO,
                                      RECHAZO,
                                      MENSAJE,
                                      PARAM_CODIGO_MODULO,
                                      CODIGO_USUARIO,
                                      MENSAJE_INF,
                                      TTAL_ASGRDO,
                                      'S',
                                      P_SES_DSTNO_INMBLE,
                                      DIR_DIVPOL_CODIGO,
                                      'S',
                                      IVA_COMERCIAL,
                                      PI_TA_EXCEPCIONES);

      EXCEPTION WHEN others THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         SUBSTR('NO SE PUEDE VALIDAR EL INGRESO AL SEGURO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          RAISE_APPLICATION_ERROR(-20047, SUBSTR('* NO SE PUEDE VALIDAR EL INGRESO AL SEGURO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
            END;

            RAISE_APPLICATION_ERROR(-20048, SUBSTR('NO SE PUEDE VALIDAR EL INGRESO AL SEGURO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
    END;

    IF RECHAZO IS NOT NULL THEN
      BEGIN
        SELECT RCN_TPO_CDGO, RCN_DSCRPCION_WEB
          INTO TIPO, DESCRIPCION
          FROM RCHZOS_NVDDES
         WHERE RCN_CDGO         = RECHAZO
           AND RCN_RAM_CDGO     = PARAM_CODIGO_RAMO;

        EXCEPTION WHEN others THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR.',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          RAISE_APPLICATION_ERROR(-20049, '* EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR.');
            END;

            RAISE_APPLICATION_ERROR(-20050, 'EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR.'); -- hace parte del exception...
      END;

      BEGIN
        PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                   APR_CDGO_AMPRO,
                                                   SOLICITUD,
                                                   SES_NMRO_PLZA,
                                                   NOVEDADES,
                                                   DESCRIPCION,
                                                   NUEVO_VALOR,
                                                   RVL_VLOR,
                                                   CODIGO_USUARIO);

        EXCEPTION WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20053, '* NO SE PUEDE REALIZAR EL INGRESO AL SEGURO. ' ||DESCRIPCION);
      END;

      RAISE_APPLICATION_ERROR(-20054, 'NO SE PUEDE REALIZAR EL INGRESO AL SEGURO. ' ||DESCRIPCION);

    ELSE
      IF APR_CDGO_AMPRO = '01' THEN
        rechazo := '01';
      END IF;

      BEGIN
        PKG_OPERACION.PRC_NOVEDADES(SOLICITUD,
                                    SES_NMRO_PLZA,
                                    PARAM_CODIGO_CLASE,
                                    PARAM_CODIGO_RAMO,
                                    PARAM_CODIGO_SUCURSAL,
                                    PARAM_CODIGO_COMPAÑIA,
                                    FECHA_NVDAD_SALIDA,
                                    APR_CDGO_AMPRO,
                                    RVL_CNCPTO_VLOR,
                                    0,
                                    CERTIFICADO,
                                    RVL_VLOR,
                                    NOVEDADES,
                                    ENTRO,
                                    PARAM_CODIGO_MODULO,
                                    MENSAJE,
                                    CODIGO_USUARIO,
                                    'NO',
                                    'SI',
                                    GLOBAL_PERIODO,
                                    NULL,
                                    NULL,
                                    'S');

        EXCEPTION WHEN others THEN
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       APR_CDGO_AMPRO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       SUBSTR('NO SE PUEDE REALIZAR EL INGRESO AL SEGURO. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20055, SUBSTR('* NO SE PUEDE REALIZAR EL INGRESO AL SEGURO. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
          END;

          RAISE_APPLICATION_ERROR(-20056, SUBSTR('NO SE PUEDE REALIZAR EL INGRESO AL SEGURO. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
      END;

      IF MENSAJE IS NOT NULL THEN
        BEGIN
          PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                     APR_CDGO_AMPRO,
                                                     SOLICITUD,
                                                     SES_NMRO_PLZA,
                                                     NOVEDADES,
                                                     MENSAJE,
                                                     NUEVO_VALOR,
                                                     RVL_VLOR,
                                                     CODIGO_USUARIO);

          EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20057, '* NO SE PUEDE REALIZAR EL INGRESO AL SEGURO. '||MENSAJE);
        END;

        RAISE_APPLICATION_ERROR(-20058, 'NO SE PUEDE REALIZAR EL INGRESO AL SEGURO. '||MENSAJE);
      END IF;
    END IF;
  END IF;

  BEGIN
    INSERT INTO DIRECCIONES
         VALUES (SOLICITUD,
                 'R',
                 DIR_DIRECCION,
                 DIR_DIVPOL_CODIGO,
                 CODIGO_USUARIO,
                 SYSDATE,
                 NULL,
                 NULL,
                 DIR_ESTRTO,
                 METRAJE_HOGAR);

    EXCEPTION  WHEN dup_val_on_index THEN
                 UPDATE DIRECCIONES
                    SET DI_DIVPOL_CODIGO = DIR_DIVPOL_CODIGO,
                        DI_DIRECCION     = DIR_DIRECCION,
                        DI_ESTRTO        = DIR_ESTRTO,
                        DI_AREA          = METRAJE_HOGAR
                  WHERE DI_SOLICITUD            = SOLICITUD
                    AND DI_TPO_DRCCION          = 'R';

                 IF SQL%NOTFOUND THEN
                   BEGIN
                     PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                                APR_CDGO_AMPRO,
                                                                SOLICITUD,
                                                                SES_NMRO_PLZA,
                                                                NOVEDADES,
                                                                'NO SE PUEDE ACTUALIZAR LA DIRECCION DEL RIESGO.',
                                                                NUEVO_VALOR,
                                                                RVL_VLOR,
                                                                CODIGO_USUARIO);

                     EXCEPTION WHEN OTHERS THEN
                               RAISE_APPLICATION_ERROR(-20059, '* NO SE PUEDE ACTUALIZAR LA DIRECCION DEL RIESGO. ');
                   END;

                   RAISE_APPLICATION_ERROR(-20060, 'NO SE PUEDE ACTUALIZAR LA DIRECCION DEL RIESGO. '); -- hace parte del exception...
                 END IF;

               WHEN others THEN
                 BEGIN
                   PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                              APR_CDGO_AMPRO,
                                                              SOLICITUD,
                                                              SES_NMRO_PLZA,
                                                              NOVEDADES,
                                                              SUBSTR('NO SE PUEDE ACTUALIZAR LA DIRECCION DEL RIESGO. ' ||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                              NUEVO_VALOR,
                                                              RVL_VLOR,
                                                              CODIGO_USUARIO);

                   EXCEPTION WHEN OTHERS THEN
                               RAISE_APPLICATION_ERROR(-20065, SUBSTR('* NO SE PUEDE ACTUALIZAR LA DIRECCION DEL RIESGO. ' ||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
                 END;

                RAISE_APPLICATION_ERROR(-20066, SUBSTR('NO SE PUEDE ACTUALIZAR LA DIRECCION DEL RIESGO. ' ||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
  END;

  BEGIN
    UPDATE SLCTDES_ESTDIOS
       SET SES_TPO_INMBLE       = P_SES_TPO_INMBLE,
           SES_DSTNO_INMBLE     = P_SES_DSTNO_INMBLE
     WHERE SES_NMRO                 = SOLICITUD;

    EXCEPTION  WHEN others THEN
       BEGIN
        PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                   APR_CDGO_AMPRO,
                                                   SOLICITUD,
                                                   SES_NMRO_PLZA,
                                                   NOVEDADES,
                                                   SUBSTR('NO SE PUEDE ACTUALIZAR EL TIPO Y DESTINO DEL INMUEBLE '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                   NUEVO_VALOR,
                                                   RVL_VLOR,
                                                   CODIGO_USUARIO);

         EXCEPTION WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20067, SUBSTR('* NO SE PUEDE ACTUALIZAR EL TIPO Y DESTINO DEL INMUEBLE. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
       END;

      RAISE_APPLICATION_ERROR(-20068, SUBSTR('NO SE PUEDE ACTUALIZAR EL TIPO Y DESTINO DEL INMUEBLE. ' ||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
  END;

  -- INGRESA LOS DATOS DEL CONTRATO DE ARRENDAMIENTO. NOVEDADES WEB FASE II. MANTIS #22568
  -- SPPC. 01/04/2014
  IF APR_CDGO_AMPRO = '01' THEN
    BEGIN
      PKG_DETALLE_OPERACION.CREAR_DATOS_CONTRATO(SOLICITUD,
                                                 SES_NMRO_PLZA,
                                                 PARAM_CODIGO_CLASE,
                                                 PARAM_CODIGO_RAMO,
                                                 RVL_CNCPTO_VLOR,
                                                 P_SES_DSTNO_INMBLE,
                                                 FECHA_CONTRATO,
                                                 TIPO_AUMENTO,
                                                 MONTO_AUMENTO,
                                                 IVA_COMERCIAL);

      EXCEPTION WHEN others THEN
        BEGIN
          PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                     APR_CDGO_AMPRO,
                                                     SOLICITUD,
                                                     SES_NMRO_PLZA,
                                                     NOVEDADES,
                                                     SUBSTR('NO SE PUEDEN CREAR LOS DATOS DEL CONTRATO DE ARRENDAMIENTO ' ||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                     NUEVO_VALOR,
                                                     RVL_VLOR,
                                                     CODIGO_USUARIO);

          EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20069, SUBSTR('* NO SE PUEDEN CREAR LOS DATOS DEL CONTRATO DE ARRENDAMIENTO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
        END;

        RAISE_APPLICATION_ERROR(-20070, SUBSTR('NO SE PUEDEN CREAR LOS DATOS DEL CONTRATO DE ARRENDAMIENTO. ' ||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
    END;
  END IF;

  --EXCEPTION WHEN OTHERS THEN
    --          RAISE_APPLICATION_ERROR(-20042, SQLERRM);
END INGRESO_SEGURO;

------
------
------
PROCEDURE VALIDAR_RANGO_ESTUDIO(RVL_CNCPTO_VLOR IN V_CONCEPTOS.RVL_CNCPTO_VLOR%TYPE,
                                RVL_VLOR        NUMBER,
                                TTAL_ASGRDO     NUMBER,
                                NUEVO_VALOR     NUMBER,
                                FECHA_NVDAD     DATE,
                                APR_CDGO_AMPRO  NUMBER,
                                SOLICITUD       IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                                SES_NMRO_PLZA   IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                                NOVEDADES       VARCHAR2) IS

RANGO_HASTA1 VLRES_ESTDIO_INVSA.VEI_RNGO_HSTA%TYPE;
RANGO_HASTA2 VLRES_ESTDIO_INVSA.VEI_RNGO_HSTA%TYPE;
V_CANON      SLCTDES_ESTDIOS.SES_CNON_ARRNDMNTO%TYPE;
V_CUOTA      SLCTDES_ESTDIOS.SES_CNON_ARRNDMNTO%TYPE;
BASE         SLCTDES_ESTDIOS.SES_CNON_ARRNDMNTO%TYPE;

PARAM_CODIGO_SUCURSAL VARCHAR2(2) := '';
PARAM_CODIGO_USUARIO  VARCHAR2(2) := '';

BEGIN
  IF RVL_CNCPTO_VLOR = '01' THEN
    V_CANON := RVL_VLOR;
    V_CUOTA := TTAL_ASGRDO - V_CANON;

    IF NVL(V_CUOTA, 0) / NVL(V_CANON, 0) >= (50 / 100) THEN
      BASE := NVL(V_CUOTA, 0) + NVL(V_CANON, 0);
    ELSE
      BASE := RVL_VLOR;
    END IF;

    IF RVL_VLOR > NUEVO_VALOR THEN
      IF RVL_VLOR > 0 THEN
        BEGIN
            SELECT VEI_RNGO_HSTA
              INTO RANGO_HASTA1
              FROM VLRES_ESTDIO_INVSA
             WHERE NUEVO_VALOR BETWEEN VEI_RNGO_DSDE AND VEI_RNGO_HSTA
               AND VEI_SUC_CDGO = PARAM_CODIGO_SUCURSAL;

          EXCEPTION  WHEN no_data_found THEN
                       RANGO_HASTA1 := 0;
        END;

        BEGIN
          SELECT VEI_RNGO_HSTA
            INTO RANGO_HASTA2
            FROM VLRES_ESTDIO_INVSA
           WHERE BASE BETWEEN VEI_RNGO_DSDE AND VEI_RNGO_HSTA
             AND VEI_SUC_CDGO = PARAM_CODIGO_SUCURSAL;

          EXCEPTION WHEN no_data_found THEN
              RANGO_HASTA2 := 0;
        END;
      END IF;

      IF RANGO_HASTA1 != RANGO_HASTA2 THEN
        BEGIN
          PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                     APR_CDGO_AMPRO,
                                                     SOLICITUD,
                                                     SES_NMRO_PLZA,
                                                     NOVEDADES,
                                                     'DEBE ENVIAR LA AMPLIACIÓN DEL CANON A EL LIBERTADOR PARA SU RESPECTIVO REESTUDIO.',
                                                     NUEVO_VALOR,
                                                     RVL_VLOR,
                                                     PARAM_CODIGO_USUARIO);

          EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20069, '* DEBE ENVIAR LA AMPLIACIÓN DEL CANON A EL LIBERTADOR PARA SU RESPECTIVO REESTUDIO. ');
        END;

        RAISE_APPLICATION_ERROR(-20070, 'DEBE ENVIAR LA AMPLIACIÓN DEL CANON A EL LIBERTADOR PARA SU RESPECTIVO REESTUDIO.'); -- hace parte del exception...
      END IF;

    ELSE
      NULL;
    END IF;
  END IF;
END VALIDAR_RANGO_ESTUDIO;

---------------------------------------------------------------------
-- PROCEDIMIENTO QUE EJECUTA EL RETIRO DE UNA NOVEDAD DESDE LA WEB --
-- MODIFICADO POR: GONZALO CHAPARRO.                 FEBRERO - 2015--
---------------------------------------------------------------------
PROCEDURE RETIRO_SEGURO(SOLICITUD           IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                        SES_NMRO_PLZA       IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                        CDGO_AMPRO          IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                        FECHA_NVDAD         IN DATE,
                        NOVEDADES           IN VARCHAR2,
                        NUEVO_VALOR         IN NUMBER,
                        RVL_VLOR            IN NUMBER,
                        TTAL_ASGRDO         IN NUMBER,
                        CODIGO_USUARIO      IN VARCHAR2,
                        P_SES_DSTNO_INMBLE  IN SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                        P_DVSION_POLITICA   IN NUMBER) IS

NOVEDAD_RETIRO          VARCHAR2(6) := '02';
RECHAZO                 VARCHAR2(3);
DESCRIPCION             VARCHAR2(1000);
MENSAJE                 VARCHAR2(2000) := NULL;
MENSAJE_SUS             VARCHAR2(2000) := NULL;
CADENA                  VARCHAR2(30) := NULL;
MENSAJE_INF             VARCHAR2(2000) := NULL;
FECHA                   DATE;
CERTIFICADO             NUMBER(10);
ENTRO                   NUMBER;
TIPO                    VARCHAR2(1);
AMPARO                  VARCHAR2(2);
CONCEPTO                VARCHAR2(4);
VALOR                   NUMBER(18, 2);
JURIDICO                NUMBER(2);
TIPO_A                  VARCHAR2(2);
PARAM_CODIGO_RAMO       VARCHAR2(2) := '12';
PARAM_CODIGO_CLASE      VARCHAR2(2) := '00';
PARAM_CODIGO_MODULO     VARCHAR2(2) := '2';
PARAM_CODIGO_SUCURSAL   VARCHAR2(4);
PARAM_CODIGO_COMPAÑIA   VARCHAR2(2) := '40';
GLOBAL_PERIODO          VARCHAR2(6) := TO_CHAR(FECHA_NVDAD, 'MMYYYY');

CURSOR AMPAROS IS
  SELECT APR_CDGO_AMPRO, APR_TPO_AMPRO
    FROM AMPROS_PRDCTO
   WHERE APR_RAM_CDGO = PARAM_CODIGO_RAMO
     AND APR_CDGO_AMPRO LIKE DECODE(CDGO_AMPRO, NULL, '%', CDGO_AMPRO);

CURSOR VALORES(AMPARO VARCHAR2) IS
  SELECT RVL_CNCPTO_VLOR, RVL_VLOR
    FROM RSGOS_VGNTES_AVLOR, VLRES_PRDCTO
   WHERE RVL_CDGO_AMPRO = AMPARO
     AND RVL_NMRO_ITEM = SOLICITUD
     AND RVL_NMRO_PLZA = SES_NMRO_PLZA
     AND RVL_CLSE_PLZA = PARAM_CODIGO_CLASE
     AND RVL_RAM_CDGO = PARAM_CODIGO_RAMO
     AND VPR_RAM_CDGO = PARAM_CODIGO_RAMO
     AND RVL_CNCPTO_VLOR = VPR_CDGO
  ORDER BY RVL_CNCPTO_VLOR;

BEGIN
  BEGIN
    SELECT POL_SUC_CDGO
      INTO PARAM_CODIGO_SUCURSAL
      FROM PLZAS
     WHERE POL_NMRO_PLZA        = SES_NMRO_PLZA;

    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20044, 'ERROR AL CONSULTAR LA SUCURSAL DE LA POLIZA ' ||SES_NMRO_PLZA||'. '||FUN_RET_MENSAJE_ERROR(SQLERRM));
  END;

  OPEN AMPAROS;
    LOOP
      FETCH AMPAROS INTO AMPARO, TIPO_A;
      IF AMPAROS%NOTFOUND THEN
        EXIT;

      ELSE
        BEGIN
          JURIDICO := NOVEDAD_JURIDICO_AMPARO(SOLICITUD, PARAM_CODIGO_RAMO, AMPARO);

          EXCEPTION WHEN OTHERS THEN
                      JURIDICO := 1;
        END;

        IF JURIDICO = 1 THEN
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       AMPARO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       'LA SOLICITUD SE ENCUENTRA SINIESTRADA. DEBE ENVIAR LA NOVEDAD DE RETIRO A EL LIBERTADOR. ',
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        RAISE_APPLICATION_ERROR(-20045, '* LA SOLICITUD SE ENCUENTRA SINIESTRADA. DEBE ENVIAR LA NOVEDAD DE RETIRO A EL LIBERTADOR.');
          END;

          RAISE_APPLICATION_ERROR(-20046, 'LA SOLICITUD SE ENCUENTRA SINIESTRADA. DEBE ENVIAR LA NOVEDAD DE RETIRO A EL LIBERTADOR. ');
        END IF;

        OPEN VALORES(AMPARO);
        ENTRO := 0;
        LOOP
          FETCH VALORES INTO CONCEPTO, VALOR;
          IF VALORES%NOTFOUND THEN
            EXIT;

          ELSE
            IF ENTRO = 0 THEN
              BEGIN
                PKG_OPERACION.PRC_VALIDA_MANUAL('N',
                                                NOVEDAD_RETIRO,
                                                SOLICITUD,
                                                SES_NMRO_PLZA,
                                                PARAM_CODIGO_CLASE,
                                                PARAM_CODIGO_RAMO,
                                                AMPARO,
                                                FECHA_NVDAD,
                                                CERTIFICADO,
                                                CONCEPTO,
                                                VALOR,
                                                PARAM_CODIGO_COMPAÑIA,
                                                PARAM_CODIGO_SUCURSAL,
                                                TIPO_A,
                                                RECHAZO,
                                                MENSAJE,
                                                PARAM_CODIGO_MODULO,
                                                CODIGO_USUARIO,
                                                MENSAJE_INF,
                                                TTAL_ASGRDO,
                                                'S',
                                                P_SES_DSTNO_INMBLE,
                                                P_DVSION_POLITICA,
                                                'S',
                                                NULL,
                                                NULL);

                EXCEPTION WHEN OTHERS THEN
                  BEGIN
                    PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                               AMPARO,
                                                               SOLICITUD,
                                                               SES_NMRO_PLZA,
                                                               NOVEDADES,
                                                               SUBSTR('NO SE HA PODIDO VALIDA LA NOVEDAD DE RETIRO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                               NUEVO_VALOR,
                                                               RVL_VLOR,
                                                               CODIGO_USUARIO);

                    EXCEPTION WHEN OTHERS THEN
                                RAISE_APPLICATION_ERROR(-20047, SUBSTR('* NO SE HA PODIDO VALIDA LA NOVEDAD DE RETIRO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
                  END;

                  RAISE_APPLICATION_ERROR(-20048, SUBSTR('NO SE HA PODIDO VALIDA LA NOVEDAD DE RETIRO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
              END;
            END IF;

            IF RECHAZO IS NOT NULL THEN
              BEGIN
                SELECT RCN_TPO_CDGO, RCN_DSCRPCION_WEB
                  INTO TIPO, DESCRIPCION
                  FROM RCHZOS_NVDDES
                 WHERE RCN_CDGO = RECHAZO
                   AND RCN_RAM_CDGO = PARAM_CODIGO_RAMO;

                EXCEPTION WHEN OTHERS THEN
                  BEGIN
                    PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                               AMPARO,
                                                               SOLICITUD,
                                                               SES_NMRO_PLZA,
                                                               NOVEDADES,
                                                               'EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR ',
                                                               NUEVO_VALOR,
                                                               RVL_VLOR,
                                                               CODIGO_USUARIO);

                    EXCEPTION WHEN OTHERS THEN
                                RAISE_APPLICATION_ERROR(-20049, '* EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR.');
                  END;

                  RAISE_APPLICATION_ERROR(-20050, 'EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR.'); -- hace parte del when othrers..
              END;

              BEGIN
                PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                           AMPARO,
                                                           SOLICITUD,
                                                           SES_NMRO_PLZA,
                                                           NOVEDADES,
                                                           DESCRIPCION,
                                                           NUEVO_VALOR,
                                                           RVL_VLOR,
                                                           CODIGO_USUARIO);

                EXCEPTION WHEN OTHERS THEN
                            RAISE_APPLICATION_ERROR(-20052, '* NO SE PUEDE REALIZAR EL RETIRO DEL SEGURO. '||DESCRIPCION);
              END;

              RAISE_APPLICATION_ERROR(-20053, ' NO SE PUEDE REALIZAR EL RETIRO DEL SEGURO. '||DESCRIPCION);

            ELSE

              BEGIN
                FECHA := TRUNC(FECHA_NVDAD) + (SYSDATE - TRUNC(SYSDATE));
                PKG_OPERACION.PRC_NOVEDADES(SOLICITUD,
                                            SES_NMRO_PLZA,
                                            PARAM_CODIGO_CLASE,
                                            PARAM_CODIGO_RAMO,
                                            PARAM_CODIGO_SUCURSAL,
                                            PARAM_CODIGO_COMPAÑIA,
                                            FECHA,
                                            AMPARO,
                                            CONCEPTO,
                                            VALOR,
                                            CERTIFICADO,
                                            0,
                                            NOVEDAD_RETIRO,
                                            ENTRO,
                                            PARAM_CODIGO_MODULO,
                                            MENSAJE,
                                            CODIGO_USUARIO,
                                            'NO',
                                            'SI',
                                            GLOBAL_PERIODO,
                                            NULL,
                                            NULL,
                                            'S');

              EXCEPTION WHEN OTHERS THEN
                BEGIN
                  PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                             AMPARO,
                                                             SOLICITUD,
                                                             SES_NMRO_PLZA,
                                                             NOVEDADES,
                                                             SUBSTR('NO SE PODIDO REALIZAR EL RETIRO DE LA SOLICITUD. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                             NUEVO_VALOR,
                                                             RVL_VLOR,
                                                             CODIGO_USUARIO);

                  EXCEPTION WHEN OTHERS THEN
                            RAISE_APPLICATION_ERROR(-20054, SUBSTR('* NO SE PODIDO REALIZAR EL RETIRO DE LA SOLICITUD. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
                END;

                RAISE_APPLICATION_ERROR(-20055, SUBSTR('NO SE PODIDO REALIZAR EL RETIRO DE LA SOLICITUD. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
              END;

              IF MENSAJE IS NOT NULL THEN
                BEGIN
                  PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                             AMPARO,
                                                             SOLICITUD,
                                                             SES_NMRO_PLZA,
                                                             NOVEDADES,
                                                             MENSAJE,
                                                             NUEVO_VALOR,
                                                             RVL_VLOR,
                                                             CODIGO_USUARIO);

                  EXCEPTION WHEN OTHERS THEN
                              RAISE_APPLICATION_ERROR(-20056, '* NO SE PODIDO REALIZAR EL RETIRO DE LA SOLICITUD. '||MENSAJE);
                END;

                RAISE_APPLICATION_ERROR(-20057, 'NO SE PODIDO REALIZAR EL RETIRO DE LA SOLICITUD. '||MENSAJE); -- hace parte del when others ...
                EXIT;
              END IF;
            END IF;
          END IF;
        END LOOP;
        CLOSE VALORES;

        BEGIN
          PKG_OPERACION.PRC_DEVOLUCION(SOLICITUD,
                                       SES_NMRO_PLZA,
                                       PARAM_CODIGO_RAMO,
                                       PARAM_CODIGO_CLASE,
                                       AMPARO,
                                       GLOBAL_PERIODO,
                                       CERTIFICADO,
                                       MENSAJE);


          EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20058, 'NO SE HAN ENCONTRADO LAS NOVEDADES DE DEVOLUCION. '||FUN_RET_MENSAJE_ERROR(SQLERRM));
        END;

        IF MENSAJE IS NOT NULL THEN
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       AMPARO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       MENSAJE,
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        RAISE_APPLICATION_ERROR(-20059, '* NO SE HAN ENCONTRADO LAS NOVEDADES DE DEVOLUCION. '||MENSAJE);
          END;

          RAISE_APPLICATION_ERROR(-20060, 'NO SE HAN ENCONTRADO LAS NOVEDADES DE DEVOLUCION. '||MENSAJE);
        END IF;
      END IF;

      IF MENSAJE IS NULL THEN
        BEGIN
          PKG_OPERACION.PRC_SUSPENSION(PARAM_CODIGO_RAMO,
                                       SOLICITUD,
                                       AMPARO,
                                       PARAM_CODIGO_MODULO,
                                       CODIGO_USUARIO,
                                       CADENA,
                                       MENSAJE_SUS);

          EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20061, 'NO SE HAN ENCONTRADO LAS NOVEDADES DE SUSPENSION. '||FUN_RET_MENSAJE_ERROR(SQLERRM));
        END;

        IF MENSAJE_SUS IS NOT NULL THEN
          IF CADENA = ' Ad' THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         AMPARO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         MENSAJE_SUS,
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          RAISE_APPLICATION_ERROR(-20062, '* NO SE HAN ENCONTRADO LAS NOVEDADES DE SUSPENSION. '||MENSAJE_SUS);
            END;

            RAISE_APPLICATION_ERROR(-20063, 'NO SE HAN ENCONTRADO LAS NOVEDADES DE SUSPENSION. '||MENSAJE_SUS);

          ELSE
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         AMPARO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         MENSAJE_SUS,
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);


              EXCEPTION WHEN OTHERS THEN
                          RAISE_APPLICATION_ERROR(-20064, '* NO SE HAN ENCONTRADO LAS NOVEDADES DE SUSPENSION. '||MENSAJE_SUS);
            END;

            RAISE_APPLICATION_ERROR(-20065, 'NO SE HAN ENCONTRADO LAS NOVEDADES DE SUSPENSION. '||MENSAJE_SUS);
          END IF;
        END IF;
      END IF;
    END LOOP;
  CLOSE AMPAROS;

  COMMIT;
  --EXCEPTION WHEN OTHERS THEN
      --raise_application_error(-20054, SQLERRM);
END RETIRO_SEGURO;

----------------------------------------------------------------------
-- PROCEDIMIENTO QUE EJECUTA EL AUMENTO DE UNA NOVEDAD DESDE LA WEB --
-- MODIFICADO POR: GONZALO CHAPARRO.                  FEBRERO - 2015--
-- Modificado por: Asesoftware - Jorge Gallo          
-- Fecha: 21/09/2017
-- Propósito de modificación: se aumenta campo TA_EXCEPCIONES para indicar excepciones a omitir
----------------------------------------------------------------------
PROCEDURE PRC_AUMENTO_SEGURO(SOLICITUD          IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                             SES_NMRO_PLZA      IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                             APR_CDGO_AMPRO     IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                             APR_TPO_AMPRO      IN AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE,
                             FECHA_NVDAD        IN DATE,
                             NOVEDADES          IN VARCHAR2,
                             NUEVO_VALOR        IN NUMBER,
                             RVL_VLOR           IN NUMBER,
                             RVL_VLOR_ANT       IN NUMBER,
                             RVL_CNCPTO_VLOR    IN V_CONCEPTOS.RVL_CNCPTO_VLOR%TYPE,
                             TTAL_ASGRDO        IN NUMBER,
                             FECHA_INGRESO      IN DATE,
                             CODIGO_USUARIO     IN VARCHAR2,
                             ENTRO              IN OUT NUMBER,
                             P_SES_DSTNO_INMBLE IN VARCHAR2,
                             P_DVSION_POLITICA  IN NUMBER,
                             IVA_COMERCIAL      IN VARCHAR2,
                             PI_TA_EXCEPCIONES IN TA_EXCEPCIONES) IS

RECHAZO                 VARCHAR2(3);
TIPO                    VARCHAR2(2);
DESCRIPCION             VARCHAR2(1000);
MENSAJE                 VARCHAR2(2000) := NULL;
CERTIFICADO             NUMBER(10);
SINIESTRO               NUMBER(10);
FECHA                   DATE;
FCHA_NVDAD              DATE;
ESTADO                  VARCHAR2(2);
ESTADO_SINIESTRO        VARCHAR2(2);
FECHA_NOVEDAD           DATE;
MENSAJE_INF             VARCHAR2(2000) := NULL;
NOVEDAD_AUMENTO         VARCHAR(6) := '04';
PARAM_CODIGO_RAMO       VARCHAR2(2) := '12';
PARAM_CODIGO_CLASE      VARCHAR2(2) := '00';
PARAM_CODIGO_MODULO     VARCHAR2(2) := '2';
PARAM_CODIGO_SUCURSAL   VARCHAR2(5); -- := '2502';  DAP. 26/11/2012 MANTIS 11747
PARAM_CODIGO_COMPAÑIA   VARCHAR2(2) := '40';
CAMBIO_VALOR            VARCHAR2(1):= 'S';
VR_VLOR_ANT             NUMBER;
GLOBAL_PERIODO          VARCHAR2(6) := TO_CHAR(FECHA_NVDAD, 'MMYYYY');

  BEGIN
    FECHA_NOVEDAD := TRUNC(FECHA_NVDAD);
    --DAP. MANTIS 11747 Se debe traer la sucursal de la póliza. 26/11/2012.
    BEGIN
      SELECT POL_SUC_CDGO
        INTO PARAM_CODIGO_SUCURSAL
        FROM PLZAS
       WHERE POL_NMRO_PLZA = SES_NMRO_PLZA
         AND POL_RAM_CDGO = '12'
         AND POL_CDGO_CLSE = '00';

      EXCEPTION WHEN OTHERS THEN
                   RAISE_APPLICATION_ERROR(-20055,'NO SE HA ENCONTRADO LA SUCURSAL DE LA PÓLIZA.');
    END;

    -- Mantis # 28409 17/09/2014 GGM.
    IF RVL_CNCPTO_VLOR = '01' AND RVL_VLOR = NUEVO_VALOR THEN
      CAMBIO_VALOR := 'N';
    ELSE
      CAMBIO_VALOR := 'S';
    END IF;

    IF RVL_CNCPTO_VLOR = '02' AND CAMBIO_VALOR = 'N' THEN
      BEGIN
        SELECT RVL_VLOR
          INTO VR_VLOR_ANT
          FROM RSGOS_VGNTES_AVLOR
         WHERE RVL_NMRO_ITEM = SOLICITUD;

        EXCEPTION WHEN OTHERS THEN
                    VR_VLOR_ANT :=0;
      END;

      IF RVL_VLOR = VR_VLOR_ANT THEN
        RAISE_APPLICATION_ERROR(-20056, 'NO HA CAMBIADO EL VALOR ASEGURADO PARA LA NOVEDAD DE AUMENTO.');
      END IF;
    END IF;

    IF RVL_VLOR = 0 AND RVL_CNCPTO_VLOR != '02' THEN
      RAISE_APPLICATION_ERROR(-20057,'EL VALOR ASEGURADO NO PUEDE SER CERO.');

    ELSE

      IF RVL_CNCPTO_VLOR = '01' THEN
        FCHA_NVDAD := FECHA_NVDAD;
      END IF;

      IF RVL_CNCPTO_VLOR = '02' THEN
        IF FCHA_NVDAD != FECHA_NVDAD THEN
          RAISE_APPLICATION_ERROR(-20058, 'LA FECHA DE INGRESO DE LA CUOTA DE ADMINISTRACIÓN ES DIFERENTE A LA DEL CANÓN DE ARRENDAMIENTO. VERIFIQUE');
        END IF;
      END IF;

      BEGIN
        PKG_OPERACION.PRC_VALIDA_MANUAL('N',
                                        NOVEDAD_AUMENTO,
                                        SOLICITUD,
                                        SES_NMRO_PLZA,
                                        PARAM_CODIGO_CLASE,
                                        PARAM_CODIGO_RAMO,
                                        APR_CDGO_AMPRO,
                                        FECHA_NOVEDAD,
                                        CERTIFICADO,
                                        RVL_CNCPTO_VLOR,
                                        RVL_VLOR,
                                        PARAM_CODIGO_COMPAÑIA,
                                        PARAM_CODIGO_SUCURSAL,
                                        APR_TPO_AMPRO,
                                        RECHAZO,
                                        MENSAJE,
                                        PARAM_CODIGO_MODULO,
                                        CODIGO_USUARIO,
                                        MENSAJE_INF,
                                        TTAL_ASGRDO,
                                        'S',
                                        P_SES_DSTNO_INMBLE,
                                        P_DVSION_POLITICA,
                                        'S',
                                        IVA_COMERCIAL,
                                        PI_TA_EXCEPCIONES);

        EXCEPTION WHEN others THEN
          BEGIN
            PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                       APR_CDGO_AMPRO,
                                                       SOLICITUD,
                                                       SES_NMRO_PLZA,
                                                       NOVEDADES,
                                                       SUBSTR('NO SE HA PODIDO VALIDAR LA NOVEDAD DE AUMENTO '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                       NUEVO_VALOR,
                                                       RVL_VLOR,
                                                       CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        RAISE_APPLICATION_ERROR(-20059, SUBSTR('* NO SE HA PODIDO VALIDAR LA NOVEDAD DE AUMENTO. '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
          END;

          RAISE_APPLICATION_ERROR(-20060, SUBSTR('NO SE HA PODIDO VALIDAR LA NOVEDAD DE AUMENTO '||FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
      END;

      IF MENSAJE IS NOT NULL THEN
        BEGIN
          PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                     APR_CDGO_AMPRO,
                                                     SOLICITUD,
                                                     SES_NMRO_PLZA,
                                                     NOVEDADES,
                                                     MENSAJE,
                                                     NUEVO_VALOR,
                                                     RVL_VLOR,
                                                     CODIGO_USUARIO);

            EXCEPTION WHEN OTHERS THEN
                        RAISE_APPLICATION_ERROR(-20061, '* NO SE PUEDE REALIZAR LA NOVEDAD DE AUMENTO. '||MENSAJE);
        END;

        RAISE_APPLICATION_ERROR(-20062, 'NO SE PUEDE REALIZAR LA NOVEDAD DE AUMENTO. '||MENSAJE);
      --ROLLBACK;
      END IF;

      -- EL AUMENTO NO PUEDE SER MENOR A LA FECHA DE INGRESO DEL AMPARO.
      IF FECHA_NVDAD < FECHA_INGRESO THEN
        RECHAZO := 25;
      END IF;

      -- EN NOVEDADES WEB NO SE PERMITE AUMENTOS RETROACTIVOS.
      IF FECHA_NOVEDAD < TO_DATE('01' || GLOBAL_PERIODO, 'DD/MM/YYYY') THEN
        RECHAZO := 66;
      END IF;

      IF RECHAZO IS NOT NULL THEN
        BEGIN
          SELECT RCN_TPO_CDGO, RCN_DSCRPCION_WEB
            INTO TIPO, DESCRIPCION
            FROM RCHZOS_NVDDES
           WHERE RCN_RAM_CDGO = PARAM_CODIGO_RAMO
             AND RCN_CDGO = RECHAZO;

          EXCEPTION WHEN OTHERS THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         'EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR ',
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

                    EXCEPTION WHEN OTHERS THEN
                                RAISE_APPLICATION_ERROR(-20065, '* EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR.');
            END;

            RAISE_APPLICATION_ERROR(-20066, 'EL CÓDIGO DE RECHAZO DE LA NOVEDAD NO EXISTE. CONSULTE CON EL LIBERTADOR.'); -- hace parte del when othrers..
        END;

        BEGIN
          PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                     APR_CDGO_AMPRO,
                                                     SOLICITUD,
                                                     SES_NMRO_PLZA,
                                                     NOVEDADES,
                                                     DESCRIPCION,
                                                     NUEVO_VALOR,
                                                     RVL_VLOR,
                                                     CODIGO_USUARIO);

          EXCEPTION WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20068, '* NO SE PUEDE REALIZAR EL AUMENTO DE VALOR ASEGURADO. '||DESCRIPCION);
        END;

        RAISE_APPLICATION_ERROR(-20069, 'NO SE PUEDE REALIZAR EL AUMENTO DE VALOR ASEGURADO. ' ||DESCRIPCION);

      ELSE
        -- Se elimina esta validación siempre entraba por este proceso y no dejaba hacer aumentos.
        --VALIDAR_RANGO_ESTUDIO;

        IF RVL_VLOR_ANT != 0 THEN
          BEGIN
            PKG_OPERACION.PRC_NOVEDADES(SOLICITUD,
                                        SES_NMRO_PLZA,
                                        PARAM_CODIGO_CLASE,
                                        PARAM_CODIGO_RAMO,
                                        PARAM_CODIGO_SUCURSAL,
                                        PARAM_CODIGO_COMPAÑIA,
                                        FECHA_NOVEDAD,
                                        APR_CDGO_AMPRO,
                                        RVL_CNCPTO_VLOR,
                                        NUEVO_VALOR,
                                        CERTIFICADO,
                                        RVL_VLOR,
                                        NOVEDAD_AUMENTO,
                                        ENTRO,
                                        PARAM_CODIGO_MODULO,
                                        MENSAJE,
                                        CODIGO_USUARIO,
                                        'NO',
                                        'SI',
                                        GLOBAL_PERIODO,
                                        NULL,
                                        NULL,
                                        'S');

            EXCEPTION WHEN OTHERS THEN
              BEGIN
                PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                           APR_CDGO_AMPRO,
                                                           SOLICITUD,
                                                           SES_NMRO_PLZA,
                                                           NOVEDADES,
                                                           SUBSTR('NO SE PUEDE REALIZAR LA NOVEDAD DE AUMENTO. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900),
                                                           NUEVO_VALOR,
                                                           RVL_VLOR,
                                                           CODIGO_USUARIO);

                EXCEPTION WHEN OTHERS THEN
                          RAISE_APPLICATION_ERROR(-20070, SUBSTR('* NO SE PUEDE REALIZAR LA NOVEDAD DE AUMENTO. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
              END;

              RAISE_APPLICATION_ERROR(-20071, SUBSTR('NO SE PUEDE REALIZAR LA NOVEDAD DE AUMENTO. ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900)); -- hace parte del exception...
          END;

          IF MENSAJE IS NOT NULL THEN
            BEGIN
              PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                         APR_CDGO_AMPRO,
                                                         SOLICITUD,
                                                         SES_NMRO_PLZA,
                                                         NOVEDADES,
                                                         MENSAJE,
                                                         NUEVO_VALOR,
                                                         RVL_VLOR,
                                                         CODIGO_USUARIO);

              EXCEPTION WHEN OTHERS THEN
                          RAISE_APPLICATION_ERROR(-20072, '* NO SE PUEDE REALIZAR LA NOVEDAD DE AUMENTO. ' || MENSAJE);
            END;

            RAISE_APPLICATION_ERROR(-20073, 'NO SE PUEDE REALIZAR LA NOVEDAD DE AUMENTO. '||MENSAJE);

          ELSE

            IF PARAM_CODIGO_MODULO = '3' THEN
              /* INDEMNIZACION */
              BEGIN
                PR_CORREGIR_LIQUIDACION(SOLICITUD,
                                        PARAM_CODIGO_RAMO,
                                        SES_NMRO_PLZA,
                                        PARAM_CODIGO_CLASE,
                                        APR_CDGO_AMPRO,
                                        RVL_CNCPTO_VLOR,
                                        RVL_VLOR,
                                        FECHA_NOVEDAD,
                                        CODIGO_USUARIO,
                                        MENSAJE);

                EXCEPTION WHEN OTHERS THEN
                            RAISE_APPLICATION_ERROR(-20075, SUBSTR('NO SE HA PODIDO REAJUSTAR LA LIQUIDACION DE LA SOLICITUD ' || FUN_RET_MENSAJE_ERROR(SQLERRM),0,3900));
              END;

              IF MENSAJE IS NOT NULL THEN
                BEGIN
                  PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                             APR_CDGO_AMPRO,
                                                             SOLICITUD,
                                                             SES_NMRO_PLZA,
                                                             NOVEDADES,
                                                             MENSAJE,
                                                             NUEVO_VALOR,
                                                             RVL_VLOR,
                                                             CODIGO_USUARIO);

                  EXCEPTION WHEN OTHERS THEN
                              RAISE_APPLICATION_ERROR(-20076, '* NO SE HA PODIDO REAJUSTAR LA LIQUIDACION DE LA SOLICITUD. ' || MENSAJE);
                END;

                RAISE_APPLICATION_ERROR(-20077, 'NO SE HA PODIDO REAJUSTAR LA LIQUIDACION DE LA SOLICITUD . '||MENSAJE);

              ELSE

                BEGIN
                  SELECT MAX(SNA_NMRO_SNSTRO), SNA_ESTDO_PGO, SNA_ESTDO_SNSTRO
                    INTO SINIESTRO, ESTADO, ESTADO_SINIESTRO
                    FROM AVSOS_SNSTROS
                   WHERE SNA_NMRO_ITEM      = SOLICITUD
                     AND SNA_NMRO_PLZA      = SES_NMRO_PLZA
                     AND SNA_CLSE_PLZA      = PARAM_CODIGO_CLASE
                     AND SNA_RAM_CDGO       = PARAM_CODIGO_RAMO
                   GROUP BY SNA_NMRO_SNSTRO, SNA_ESTDO_PGO;

                  EXCEPTION WHEN no_data_found THEN
                                BEGIN
                                  PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                                             APR_CDGO_AMPRO,
                                                                             SOLICITUD,
                                                                             SES_NMRO_PLZA,
                                                                             NOVEDADES,
                                                                             'NO ENCONTRO EL SINIESTRO ASOCIADO A LA SOLICITUD',
                                                                             NUEVO_VALOR,
                                                                             RVL_VLOR,
                                                                             CODIGO_USUARIO);

                                  EXCEPTION WHEN OTHERS THEN
                                              RAISE_APPLICATION_ERROR(-20080, '* NO ENCONTRO EL SINIESTRO ASOCIADO A LA SOLICITUD. ');
                                END;

                                RAISE_APPLICATION_ERROR(-20081, 'NO ENCONTRO EL SINIESTRO ASOCIADO A LA SOLICITUD. '); -- hace parte del no_data_found...

                            WHEN OTHERS THEN
                                BEGIN
                                  PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                                             APR_CDGO_AMPRO,
                                                                             SOLICITUD,
                                                                             SES_NMRO_PLZA,
                                                                             NOVEDADES,
                                                                             'NO SE HA PODIDO CONSULTAR LA INFORMACION DEL SINIESTRO',
                                                                             NUEVO_VALOR,
                                                                             RVL_VLOR,
                                                                             CODIGO_USUARIO);

                                  EXCEPTION WHEN OTHERS THEN
                                              RAISE_APPLICATION_ERROR(-20082, '* NO SE HA PODIDO CONSULTAR LA INFORMACION DEL SINIESTRO.');
                                END;

                                RAISE_APPLICATION_ERROR(-20083, 'NO SE HA PODIDO CONSULTAR LA INFORMACION DEL SINIESTRO.'); -- hace parte del others ..
                END;

                IF SINIESTRO IS NULL THEN
                  BEGIN
                    PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                               APR_CDGO_AMPRO,
                                                               SOLICITUD,
                                                               SES_NMRO_PLZA,
                                                               NOVEDADES,
                                                               'NO ENCONTRO EL SINIESTRO ASOCIADO A LA SOLICITUD',
                                                               NUEVO_VALOR,
                                                               RVL_VLOR,
                                                               CODIGO_USUARIO);

                    EXCEPTION WHEN OTHERS THEN
                                RAISE_APPLICATION_ERROR(-20085, '* NO ENCONTRO EL SINIESTRO ASOCIADO A LA SOLICITUD. ');
                  END;

                  RAISE_APPLICATION_ERROR(-20086, 'NO ENCONTRO EL SINIESTRO ASOCIADO A LA SOLICITUD');

                ELSE
                  IF ESTADO IN ('02', '03') AND ESTADO_SINIESTRO != '03' THEN
                    BEGIN
                      PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                                 APR_CDGO_AMPRO,
                                                                 SOLICITUD,
                                                                 SES_NMRO_PLZA,
                                                                 NOVEDADES,
                                                                 'EL SINIESTRO SE ENCUENTRA OBJETADO O SUSPENDIDO POR LO TANTO NO SE PUEDEN REALIZAR AUMENTOS',
                                                                 NUEVO_VALOR,
                                                                 RVL_VLOR,
                                                                 CODIGO_USUARIO);

                      EXCEPTION WHEN OTHERS THEN
                                  RAISE_APPLICATION_ERROR(-20087, '* EL SINIESTRO SE ENCUENTRA OBJETADO O SUSPENDIDO POR LO TANTO NO SE PUEDEN REALIZAR AUMENTOS. ');
                    END;

                    RAISE_APPLICATION_ERROR(-20088, 'EL SINIESTRO SE ENCUENTRA OBJETADO O SUSPENDIDO POR LO TANTO NO SE PUEDEN REALIZAR AUMENTOS');

                  END IF;
                END IF;

                BEGIN
                  FECHA := TO_DATE('01' || GLOBAL_PERIODO, 'DDMMYYYY');

                  EXCEPTION WHEN OTHERS THEN
                              RAISE_APPLICATION_ERROR(-20089, 'NO SE HA PODIDO CALCULAR LA FECHA DE AUMENTO. '||FUN_RET_MENSAJE_ERROR(SQLERRM));
                END;

                BEGIN
                  UPDATE AJSTES_SNSTROS
                     SET AJS_VLOR_AJSTE     = AJS_VLOR_AJSTE - NUEVO_VALOR + RVL_VLOR
                   WHERE AJS_FCHA_AJSTE         = FECHA
                     AND AJS_RAM_CDGO           = PARAM_CODIGO_RAMO
                     AND AJS_NMRO_SNSTRO        = SINIESTRO;

                  EXCEPTION WHEN OTHERS THEN
                    BEGIN
                      PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                                 APR_CDGO_AMPRO,
                                                                 SOLICITUD,
                                                                 SES_NMRO_PLZA,
                                                                 NOVEDADES,
                                                                 'EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES.',
                                                                 NUEVO_VALOR,
                                                                 RVL_VLOR,
                                                                 CODIGO_USUARIO);

                      EXCEPTION WHEN OTHERS THEN
                                  RAISE_APPLICATION_ERROR(-20092, '* EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES. ');
                    END;

                    RAISE_APPLICATION_ERROR(-20093, 'EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES'); -- hace parte del others..
                END;

                IF SQL%NOTFOUND THEN
                  BEGIN
                    INSERT INTO AJSTES_SNSTROS
                      (AJS_FCHA_AJSTE,
                       AJS_CDGO_AJSTDOR,
                       AJS_RAM_CDGO,
                       AJS_NMRO_SNSTRO,
                       AJS_VLOR_AJSTE,
                       AJS_VLOR_HNRRIOS,
                       AJS_USRIO,
                       AJS_FCHA_MDFCCION)
                    VALUES
                      (FECHA,
                       CODIGO_USUARIO,
                       PARAM_CODIGO_RAMO,
                       SINIESTRO,
                       RVL_VLOR - NUEVO_VALOR,
                       0,
                       CODIGO_USUARIO,
                       SYSDATE);

                    EXCEPTION WHEN OTHERS THEN
                      BEGIN
                        PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                                   APR_CDGO_AMPRO,
                                                                   SOLICITUD,
                                                                   SES_NMRO_PLZA,
                                                                   NOVEDADES,
                                                                   'EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES.',
                                                                   NUEVO_VALOR,
                                                                   RVL_VLOR,
                                                                   CODIGO_USUARIO);

                        EXCEPTION WHEN OTHERS THEN
                                    RAISE_APPLICATION_ERROR(-20094, '* EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES. ');
                      END;

                      RAISE_APPLICATION_ERROR(-20095, 'EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES.'); -- hace parte del others..
                  END;

                  IF SQL%NOTFOUND THEN
                    BEGIN
                      PKG_NOVEDADES_WEB.PRC_NOVEDADES_RECHAZADAS(FECHA_NVDAD,
                                                                 APR_CDGO_AMPRO,
                                                                 SOLICITUD,
                                                                 SES_NMRO_PLZA,
                                                                 NOVEDADES,
                                                                 'EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES.',
                                                                 NUEVO_VALOR,
                                                                 RVL_VLOR,
                                                                 CODIGO_USUARIO);

                      EXCEPTION WHEN OTHERS THEN
                                  RAISE_APPLICATION_ERROR(-20098, '* EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES. ');
                    END;

                    RAISE_APPLICATION_ERROR(-20099, 'EL USUARIO NO TIENE PERMISO PARA REALIZAR AUMENTOS DESDE INDEMNIZACIONES.'); -- hace parte del others..
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;

  --EXCEPTION WHEN others THEN
              --raise_application_error(-20073, sqlerrm);
END PRC_AUMENTO_SEGURO;

---------------------------------------------------------------------------------------
-- PROCEDIMIENTOS LLAMADO DESDE LA APLIACION DE NOVEDADES WEB PARA VALIDAR EL ACCESO --
-- DEL USUARIO LOGUEADO EN EL MAP CON EL WEB SERVICE                                 --
-- CREADO POR: GONZALO CHAPARRO.                                   SEPTIEMBRE - 2014 --
---------------------------------------------------------------------------------------
PROCEDURE PRC_VALIDA_ACCESO_USER(P_NID_LOGIN      IN VARCHAR2,
                                 P_TID_LOGIN      OUT VARCHAR2,
                                 P_URL_SERVICE    OUT VARCHAR2,
                                 P_NOM_LOGIN      OUT VARCHAR2,
                                 P_COD_MODULO     OUT VARCHAR2,
                                 P_COD_PAIS       OUT VARCHAR2,
                                 P_ERROR          OUT VARCHAR2) IS

V_ERROR         VARCHAR2(1000) := NULL;

BEGIN
  V_ERROR       := '0';

  BEGIN -- saca el pais del map.
    SELECT PS.VALOR
      INTO P_COD_PAIS
      FROM PARAMETRO_SAI PS
     WHERE PS.ID        = 'PAIS';

    EXCEPTION WHEN OTHERS THEN
                P_COD_PAIS    := 'CO';
  END;

  BEGIN -- saca el pais del map.
    SELECT PS.VALOR
      INTO P_COD_MODULO
      FROM PARAMETRO_SAI PS
     WHERE PS.ID        = 'IDMP';

    EXCEPTION WHEN OTHERS THEN
                P_COD_MODULO  := '283';
  END;


  BEGIN -- saca la direccion del service del map...
    SELECT PS.VALOR
      INTO P_URL_SERVICE
      FROM PARAMETRO_SAI PS
     WHERE PS.ID        = 'SDLN';

    EXCEPTION WHEN OTHERS THEN
                V_ERROR := 'NO SE PUEDE AUTENTICAR EL LOGIN '||P_NID_LOGIN||'. '||FUN_RET_MENSAJE_ERROR(SQLERRM);
  END;

  IF V_ERROR = '0' THEN
    BEGIN
      SELECT DISTINCT POL.POL_PRS_TPO_IDNTFCCION
        INTO P_TID_LOGIN
        FROM PLZAS POL
       WHERE POL.POL_PRS_NMRO_IDNTFCCION      = TO_NUMBER(P_NID_LOGIN);

      EXCEPTION WHEN NO_DATA_FOUND THEN
                  P_TID_LOGIN := NULL;
                  V_ERROR := 'EL USUARIO '||P_NID_LOGIN||' NO EXISTE EN LA TABLA DE POLIZAS';
                WHEN TOO_MANY_ROWS THEN
                  P_TID_LOGIN := 'NT';
                  V_ERROR := '0';
                WHEN OTHERS THEN
                  V_ERROR := 'ERROR AL CAPTURAR LA INFORMACION DEL USUARIO LOGEADO '||FUN_RET_MENSAJE_ERROR(SQLERRM);
    END;
  END IF;

  IF V_ERROR = '0' THEN
    BEGIN
      P_NOM_LOGIN := PK_TERCEROS.F_NOMBRES(TO_NUMBER(P_NID_LOGIN), P_TID_LOGIN);

      EXCEPTION WHEN OTHERS THEN
                  P_NOM_LOGIN := '';
    END;
  END IF;

  P_ERROR := V_ERROR;
END PRC_VALIDA_ACCESO_USER;

  /* -- para capturar los valores que vienen de la aplicacion web...
  RAISE_APPLICATION_ERROR(-20500,'PRC_GUARDAR_NOVEDAD_SEG_ARREN '||NOVEDADES
  ||' - '||DIR_ESTRTO||' - '||FECHA_INGRESO||' - '||CODIGO_USUARIO||' - '||ENTRO
  ||' - '||FECHA_CONTRATO||' - '||TIPO_AUMENTO||' - '||MONTO_AUMENTO||' - '||IVA_COMERCIAL
  ||' - '||TTAL_ASGRDO||' - '||RVL_CNCPTO_VLOR||' - '||NUEVO_VALOR||' - '||RVL_VLOR
  ||' - '||RVL_VLOR_ANT||' - '||APR_TPO_AMPRO||' - '||SES_DSTNO_INMBLE);
  */

end PKG_NOVEDADES_WEB_JAVA;
/
