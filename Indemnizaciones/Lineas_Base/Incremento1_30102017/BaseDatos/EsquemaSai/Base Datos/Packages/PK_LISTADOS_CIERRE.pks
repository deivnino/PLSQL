CREATE OR REPLACE PACKAGE admsisa.PK_LISTADOS_CIERRE is

  -- Author  : INNOVACION ---DAP.
  -- Created : 04/09/2009 02:26:37 p.m.
  -- Purpose :


  FUNCTION F_LISTADOS(P_LISTADO NUMBER, P_POLIZA NUMBER, P_FECHA_PAGO DATE)
    RETURN NUMBER;

  function F_NOVEDAD_CIERRE(P_SOLICITUD NUMBER,
                            P_POLIZA    NUMBER,
                            P_CLASE     VARCHAR2,
                            P_RAMO      VARCHAR2,
                            P_PERIODO   VARCHAR2) RETURN VARCHAR2;
  function F_NOTA_CIERRE(P_SOLICITUD NUMBER,
                         P_POLIZA    NUMBER,
                         P_CLASE     VARCHAR2,
                         P_RAMO      VARCHAR2,
                         P_PERIODO   VARCHAR2) RETURN VARCHAR2;

  function f_comas(p_cadena varchar2) return varchar2;

  FUNCTION FUN_PRIMA_CONCEPTO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                              P_AMPARO    RSGOS_VGNTES_AVLOR.RVL_CDGO_AMPRO%TYPE,
                              P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE)
    RETURN NUMBER;

  procedure PR_CERTIFICADOS_CIERRE(P_POLIZA   NUMBER,
                                   P_CLASE    VARCHAR2,
                                   P_RAMO     VARCHAR2,
                                   P_COMPANIA VARCHAR2,
                                   P_SUCURSAL VARCHAR2,
                                   P_PERIODO  VARCHAR2,
                                   P_FCHA_PGO DATE);

  procedure PR_CERTIFICADOS_CIERRE_TODOS(P_SUCURSAL VARCHAR2,
                                         P_PERIODO  VARCHAR2,
                                         P_POLIZA   NUMBER,
                                         P_FCHA_PGO DATE);

  procedure PR_RNOVEDADES(P_POLIZA          NUMBER,
                          P_CLASE           VARCHAR2,
                          P_RAMO            VARCHAR2,
                          P_CODIGO_SUCURSAL VARCHAR2,
                          P_CODIGO_COMPANIA VARCHAR2,
                          P_PERIODO         VARCHAR2,
                          P_FECHA_PAGO      DATE);

  procedure PR_RNOVEDADES_TODOS(P_CODIGO_SUCURSAL VARCHAR2,
                                P_PERIODO         VARCHAR2,
                                P_POLIZA          NUMBER,
                                P_FCHA_PGO        DATE);

  procedure PR_CARTAS_RECHAZO(P_POLIZA   NUMBER,
                              P_RAMO     VARCHAR2,
                              P_CLASE    VARCHAR2,
                              P_SUCURSAL VARCHAR2,
                              P_COMPANIA VARCHAR2,
                              P_FCHA_PGO DATE);
  function f_centrar(p_cadena varchar2, tamano number) return varchar2;

  procedure PR_CREAR_ARCHIVOSOLD(P_FCHA_PGO DATE);

  procedure PR_CREAR_ARCHIVOS(P_FCHA_PGO DATE);

  PROCEDURE PRC_RELACION_ASEGURADOS(P_Codigo_CLASE    PLZAS.POL_CDGO_CLSE%TYPE,
                                    P_Codigo_RAMO     PLZAS.POL_RAM_CDGO%TYPE,
                                    P_CODIGO_SUCURSAL PLZAS.POL_SUC_CDGO%TYPE,
                                    P_CODIGO_COMPANIA PLZAS.POL_SUC_CIA_CDGO%TYPE,
                                    P_POLIZA          PLZAS.POL_NMRO_PLZA%TYPE,
                                    P_POL_HASTA       PLZAS.POl_NMRO_PLZA%TYPE,
                                    P_PERIODO         VARCHAR2,
                                    p_Codigo_Usuario  VARCHAR2,
                                    P_FECHA_PAGO      DATE);

  PROCEDURE PRC_EXTRACTOS(P_POLIZA   NUMBER,
                          P_RAMO     VARCHAR2,
                          P_CLASE    VARCHAR2,
                          P_PERIODO  DATE,
                          P_SUCURSAL VARCHAR2);

  PROCEDURE PRC_LISTADO_SINIESTROS(P_CLASE           IN VARCHAR2,
                                   P_RAMO            IN AVSOS_SNSTROS.SNA_RAM_CDGO%TYPE,
                                   P_POLIZA          IN AVSOS_SNSTROS.SNA_NMRO_PLZA%TYPE,
                                   P_CODIGO_SUCURSAL PLZAS.POL_SUC_CDGO%TYPE,
                                   P_CODIGO_COMPANIA PLZAS.POL_SUC_CIA_CDGO%TYPE,
                                   P_FECHA_PAGO      DATE);
  PROCEDURE PRC_ESTADOS_POLIZAS(P_POLIZA   NUMBER,
                                P_CLASE    VARCHAR2,
                                P_RAMO     VARCHAR2,
                                P_SUCURSAL VARCHAR2,
                                P_COMPANIA VARCHAR2);


  FUNCTION FUN_VALORES_IGUALES(P_SOLICITUD   NUMBER,
                               P_FECHA_MORA  DATE,
                               P_FECHA_PAGO  DATE,
                               P_ORIGEN      VARCHAR2) RETURN NUMBER;

  PROCEDURE PRC_CRUCES_REINTEGROS(P_POLIZA     PLZAS.POL_NMRO_PLZA%TYPE,
                                  P_CLASE      PLZAS.POL_CDGO_CLSE%TYPE,
                                  P_RAMO       PLZAS.POL_RAM_CDGO%TYPE,
                                  P_SUCURSAL   PLZAS.POL_SUC_CDGO%TYPE,
                                  P_FECHA_PAGO DATE);

/**** funciones para los listados y la consulta de resultados ****/
FUNCTION FUN_RELACION_DE_FACTURAS(P_POLIZA   IN   VARCHAR2,
                                  P_FECHA    IN   VARCHAR2) RETURN NUMBER;
PROCEDURE PRC_VALIDA_ACCESO_USER(P_NID_LOGIN      IN VARCHAR2,
                                 P_TID_LOGIN      OUT VARCHAR2,
                                 P_URL_SERVICE    OUT VARCHAR2,
                                 P_NOM_LOGIN      OUT VARCHAR2,
                                 P_COD_MODULO     OUT VARCHAR2,
                                 P_COD_PAIS       OUT VARCHAR2,
                                 P_ERROR          OUT VARCHAR2);
FUNCTION FUN_RET_URL_LISTADO(P_COD_LISTADO   IN NUMBER
                             ,P_POLIZA        IN NUMBER,
                             P_PERIODO       IN VARCHAR2) RETURN VARCHAR2;
FUNCTION FUN_RET_SERVICIOS(P_LSERVPUB   IN VARCHAR2,
                           P_LAMPINT    IN VARCHAR2,
                           P_LAMPINTS   IN VARCHAR2) RETURN VARCHAR2;
PROCEDURE PRC_VALORES_EXCEL(P_POLIZA        IN  VARCHAR2,
                            P_PERIODO       IN  VARCHAR2,
                            P_VLR_IVA       OUT NUMBER,
                            P_NETA_ASIS     OUT NUMBER,
                            P_NETA_HOGAR    OUT NUMBER,
                            P_IVA_ASIS      OUT NUMBER,
                            P_IVA_HOGAR     OUT NUMBER,
                            P_TOTAL_ASIS    OUT NUMBER,
                            P_TOTAL_HOGAR   OUT NUMBER,
                            P_DEV_HOGAR     OUT NUMBER,
                            P_VALOR_IVA     OUT NUMBER);
PROCEDURE PRC_GENERAR_RESULTADO(P_SOLICITUD       IN  VARCHAR2,
                                P_PASSWORD        IN  VARCHAR2,
                                P_DEVUELVE_DATOS  OUT CLOB,
                                P_COD_ERROR       OUT VARCHAR2,
                                P_DESC_ERROR      OUT VARCHAR2);
FUNCTION FUN_RETORNA_FECHA (P_FECHA     IN DATE) RETURN VARCHAR2;

end PK_LISTADOS_CIERRE;
/