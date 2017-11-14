create or replace package admsisa.PKG_NOVEDADES_WEB_JAVA is

  -- Author  : Jorge Barrera
  -- Created : 09/10/2010 04:28:23 p.m.
  -- Purpose :

  -- Procedimientos
  FUNCTION FUN_RET_MENSAJE_ERROR(P_MENSAJE    IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION FUN_FECHA_NOV_DATE(P_LOGIN   NUMBER) RETURN DATE;
  FUNCTION FUN_FECHA_NOV(P_LOGIN   NUMBER) RETURN VARCHAR2;
  FUNCTION FNC_ASEGURADO_AMPARO(P_NSOLICITUD VARCHAR2, P_AMPARO VARCHAR2) RETURN NUMBER ;
  FUNCTION FNC_ASEGURADO(P_NSOLICITUD VARCHAR2) RETURN NUMBER;
  PROCEDURE PRC_GUARDAR_NOVEDAD_SEG_ARREN(NOVEDADES         VARCHAR2,
                                          ESTADO_POLIZA     VARCHAR2,
                                          SOLICITUD         IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                                          TIPO_IDEN         IN ARRNDTRIOS.ARR_TPO_IDNTFCCION%TYPE,
                                          NMRO_IDEN         IN ARRNDTRIOS.ARR_NMRO_IDNTFCCION%TYPE,
                                          APR_CDGO_AMPRO    AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                                          FECHA_NVDAD       DATE,
                                          NUEVO_VALOR       NUMBER,
                                          RVL_VLOR          NUMBER,
                                          APR_LMTCION_TPO   VARCHAR2,
                                          SES_NMRO_PLZA     IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                                          APR_TPO_AMPRO     IN AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE,
                                          RVL_CNCPTO_VLOR   IN V_CONCEPTOS.RVL_CNCPTO_VLOR%TYPE,
                                          DIR_DIRECCION     IN DIRECCIONES.DI_DIRECCION%TYPE,
                                          DIR_DIVPOL_CODIGO IN DIRECCIONES.DI_DIVPOL_CODIGO%TYPE,
                                          DIR_ESTRTO        IN DIRECCIONES.DI_ESTRTO%TYPE,
                                          SES_TPO_INMBLE    SLCTDES_ESTDIOS.SES_TPO_INMBLE%TYPE,
                                          SES_DSTNO_INMBLE  SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                                          ASISTENCIA        VARCHAR2,
                                          TTAL_ASGRDO       NUMBER,
                                          RVL_VLOR_ANT      NUMBER,
                                          FECHA_INGRESO     DATE,
                                          CODIGO_USUARIO    VARCHAR2,
                                          ENTRO             IN OUT NUMBER,
                                          FECHA_CONTRATO    IN OUT DATE,
                                          TIPO_AUMENTO      IN OUT VARCHAR2,
                                          MONTO_AUMENTO     IN OUT NUMBER,
                                          IVA_COMERCIAL     IN OUT VARCHAR2,
                                          METRAJE_HOGAR     IN OUT NUMBER,
                                          PI_TA_EXCEPCIONES IN TA_EXCEPCIONES);

  PROCEDURE INGRESO_SEGURO(DIR_ESTRTO         IN DIRECCIONES.DI_ESTRTO%TYPE,
                           NOVEDADES           VARCHAR2,
                           P_SES_TPO_INMBLE    IN SLCTDES_ESTDIOS.SES_TPO_INMBLE%TYPE,
                           P_SES_DSTNO_INMBLE  IN SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                           DIR_DIRECCION       IN DIRECCIONES.DI_DIRECCION%TYPE,
                           RVL_CNCPTO_VLOR     IN V_CONCEPTOS.RVL_CNCPTO_VLOR%TYPE,
                           APR_CDGO_AMPRO      AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                           SOLICITUD           IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                           FECHA_NVDAD         DATE,
                           APR_LMTCION_TPO     VARCHAR2,
                           SES_NMRO_PLZA       IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                           NUEVO_VALOR         NUMBER,
                           RVL_VLOR            NUMBER,
                           ASISTENCIA          VARCHAR2,
                           APR_TPO_AMPRO       IN AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE,
                           TTAL_ASGRDO         NUMBER,
                           DIR_DIVPOL_CODIGO   IN DIRECCIONES.DI_DIVPOL_CODIGO%TYPE,
                           CODIGO_USUARIO      VARCHAR2,
                           ENTRO               IN OUT NUMBER,
                           FECHA_CONTRATO      IN OUT DATE,
                           TIPO_AUMENTO        IN OUT VARCHAR2,
                           MONTO_AUMENTO       IN OUT NUMBER,
                           IVA_COMERCIAL      IN OUT VARCHAR2,
                           METRAJE_HOGAR      IN OUT NUMBER,
                           PI_TA_EXCEPCIONES IN TA_EXCEPCIONES);

  PROCEDURE RETIRO_SEGURO(SOLICITUD           IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                          SES_NMRO_PLZA       IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                          CDGO_AMPRO          IN AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                          FECHA_NVDAD         DATE,
                          NOVEDADES           VARCHAR2,
                          NUEVO_VALOR         NUMBER,
                          RVL_VLOR            NUMBER,
                          TTAL_ASGRDO         NUMBER,
                          CODIGO_USUARIO      VARCHAR2,
                          P_SES_DSTNO_INMBLE  IN SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE,
                          P_DVSION_POLITICA   IN NUMBER);

  PROCEDURE PRC_AUMENTO_SEGURO(SOLICITUD          IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                               SES_NMRO_PLZA      IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                               APR_CDGO_AMPRO     AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                               APR_TPO_AMPRO      IN AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE,
                               FECHA_NVDAD         DATE,
                               NOVEDADES           VARCHAR2,
                               NUEVO_VALOR         NUMBER,
                               RVL_VLOR            NUMBER,
                               RVL_VLOR_ANT        NUMBER,
                               RVL_CNCPTO_VLOR     IN V_CONCEPTOS.RVL_CNCPTO_VLOR%TYPE,
                               TTAL_ASGRDO         NUMBER,
                               FECHA_INGRESO       DATE,
                               CODIGO_USUARIO      VARCHAR2,
                               ENTRO               IN OUT NUMBER,
                               P_SES_DSTNO_INMBLE  VARCHAR2,
                               P_DVSION_POLITICA   NUMBER,
                               IVA_COMERCIAL       IN VARCHAR2,
                               PI_TA_EXCEPCIONES   IN TA_EXCEPCIONES);
                             
PROCEDURE PRC_VALIDA_ACCESO_USER(P_NID_LOGIN      IN VARCHAR2,
                                 P_TID_LOGIN      OUT VARCHAR2,
                                 P_URL_SERVICE    OUT VARCHAR2,
                                 P_NOM_LOGIN      OUT VARCHAR2,
                                 P_COD_MODULO     OUT VARCHAR2,
                                 P_COD_PAIS       OUT VARCHAR2,
                                 P_ERROR          OUT VARCHAR2);

end PKG_NOVEDADES_WEB_JAVA;
/
