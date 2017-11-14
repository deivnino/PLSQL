CREATE OR REPLACE PACKAGE admsisa.PKG_OPERACION AS

-- VARIABLES
-- VARIABLES


  V_RVL_CDGO_AMPRO      VARCHAR2(2);
  V_RVL_RAM_CDGO        VARCHAR2(2);
  V_RVL_NMRO_ITEM       NUMBER(10);
  V_RVL_NMRO_PLZA       NUMBER(10);
  V_RVL_CLSE_PLZA       VARCHAR2(2);
  V_RVL_CNCPTO_VLOR     VARCHAR2(4);
  V_RVL_VLOR            NUMBER(18,2);
  V_RVL_USRIO           VARCHAR2(30);
  V_RVL_FCHA_MDFCCION   DATE;
  V_RVL_PRIMA_NETA      NUMBER;
  V_RVL_PRIMA_NETA_ANT  NUMBER;
  V_RVL_VALOR_IVA       NUMBER;
  V_RVL_VALOR_IVA_ANT   NUMBER;
  V_RVL_TASA            NUMBER;

  N_RVL_CDGO_AMPRO      VARCHAR2(2);
  N_RVL_RAM_CDGO        VARCHAR2(2);
  N_RVL_NMRO_ITEM       NUMBER(10);
  N_RVL_NMRO_PLZA       NUMBER(10);
  N_RVL_CLSE_PLZA       VARCHAR2(2);
  N_RVL_CNCPTO_VLOR     VARCHAR2(4);
  N_RVL_VLOR            NUMBER(18,2);
  N_RVL_USRIO           VARCHAR2(30);
  N_RVL_FCHA_MDFCCION   DATE;
  N_RVL_PRIMA_NETA      NUMBER;
  N_RVL_PRIMA_NETA_ANT  NUMBER;
  N_RVL_VALOR_IVA       NUMBER;
  N_RVL_VALOR_IVA_ANT   NUMBER;
  N_RVL_TASA            NUMBER;

  FUNCTION FUN_VALOR_IVA RETURN NUMBER;

  FUNCTION FUN_ANEXO_HOGAR(P_POLIZA PLZAS.POL_NMRO_PLZA%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_DESTINO_HOGAR(DESTINO_INMUEBLE SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_DESTINO_SOLICITUD(P_SOLICITUD SLCTDES_ESTDIOS.SES_NMRO%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_DIVISION_DIRECCION(P_SOLICITUD SLCTDES_ESTDIOS.SES_NMRO%TYPE) RETURN NUMBER;

  FUNCTION FUN_SERVICIO_ASISTENCIA(DIVISION_POLITICA  NUMBER) RETURN VARCHAR2;

   FUNCTION FUN_VALIDA_HOGAR(POLIZA PLZAS.POL_NMRO_PLZA%TYPE,
                           CIUDAD  NUMBER,
                           DESTINO SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE) RETURN VARCHAR2;
  FUNCTION FUN_FACTURADO_AMPARO(P_SOLICITUD SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                              P_POLIZA PLZAS.POL_NMRO_PLZA%TYPE,
                              P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE) RETURN NUMBER;


  FUNCTION FUN_VALIDA_VALOR(P_AMPARO   AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                            P_RAMO     AMPROS_PRDCTO.APR_RAM_CDGO%TYPE,
                            P_SUCURSAL SCRSL.SUC_CDGO%TYPE,
                            P_COMPANIA SCRSL.SUC_CIA_CDGO%TYPE,
                            P_VALOR    NUMBER) RETURN VARCHAR2;

  FUNCTION FUN_VALIDA_SEGURO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                             P_AMPARO    RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                             P_RAMO      RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
                             P_CLASE     RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE,
                             P_POLIZA    PLZAS.POL_NMRO_PLZA%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_VALIDA_SEGURO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                             P_AMPARO    RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                             P_RAMO      RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
                             P_CLASE     RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_REQUIERE_BASICO(P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_REQUIERE_AMPARO(P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_VALOR_CONCEPTO(P_RAMO     VLRES_PRDCTO.VPR_RAM_CDGO%TYPE,
                              P_CONCEPTO VLRES_PRDCTO.VPR_CDGO%TYPE) RETURN NUMBER;

  FUNCTION FUN_PERMITE_SNSTRO(P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_TRFCION_EXTERNA(P_AMPARO RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                               P_RAMO   RSGOS_VGNTES.RVI_RAM_CDGO%TYPE) RETURN VARCHAR2;
  FUNCTION FUN_TIENE_RETIRO (P_SOLICITUD        IN NUMBER,
                             P_TIPO_NOVEDAD     IN VARCHAR2,
                             P_AMPARO           IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION FUN_TIPO_AMPARO(P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                           P_RAMO   AMPROS_PRDCTO.APR_RAM_CDGO%TYPE) RETURN VARCHAR2;

  FUNCTION FUN_MESES_HOGAR(P_MODULO      IN MODULOS.MDL_CDGO%TYPE,
                           P_SUCURSAL    IN SCRSL.SUC_CDGO%TYPE,
                           P_COMPANIA    IN SCRSL.SUC_CIA_CDGO%TYPE,
                           P_VALOR       IN PRMTROS.PAR_VLOR1%TYPE) RETURN NUMBER;

  FUNCTION FUN_VALOR_ASGRDO_HOGAR(P_SOLICITUD NUMBER,
                                  P_AMPARO    VARCHAR2,
                                  P_RAMO      VARCHAR2,
                                  P_CLASE     VARCHAR2,
                                  P_CONCEPTO  OUT VARCHAR) RETURN NUMBER;
                                  
  FUNCTION FUN_SUMA_CONCEPTOS(P_RECIBO   NUMBER,
                              P_TIPO     VARCHAR2,
                              P_CIA      VARCHAR2,
                              P_CONCEPTO VARCHAR2,
                              EXISTE     OUT NUMBER) RETURN NUMBER;
                              
  FUNCTION FUN_PAGOS_CRTFCDOS(P_RECIBO   NUMBER,
                              P_TIPO     VARCHAR2,
                              P_CIA      VARCHAR2) RETURN VARCHAR2;  
                                  
  
  FUNCTION FUN_VALIDA_PAGO_PLZA(P_POLIZA_SIMON   NUMBER) RETURN VARCHAR2;                                                     
                              
  PROCEDURE PRC_VALIDA_MANUAL(AUTOMATICO         VARCHAR2,
                              TIPO_NOVEDAD       VARCHAR2,
                              NMRO_SLCTUD        NUMBER,
                              NMRO_POLIZA        NUMBER,
                              CLASE_POLIZA       VARCHAR2,
                              RAMO               VARCHAR2,
                              AMPARO             VARCHAR2,
                              FECHA_NOVEDAD      DATE,
                              CERTIFICADO        IN OUT NUMBER,
                              CONCEPTO           VARCHAR2,
                              VALOR              NUMBER,
                              COMPANIA           VARCHAR2,
                              SUCURSAL           VARCHAR2,
                              TIPO_AMPARO        VARCHAR2,
                              RESULTADO          OUT NUMBER,
                              MENSAJE            IN OUT VARCHAR2,
                              MODULO             IN VARCHAR2,
                              USUARIO            IN VARCHAR2,
                              MENSAJE_INF        IN OUT VARCHAR2,
                              TTAL_ASGRADO       NUMBER,
                              P_NOVEDAD_WEB      VARCHAR2,
                              P_DESTINO_INMUEBLE VARCHAR2,
                              P_DVSION_POLITICA  NUMBER,
                              P_SINPRIMA         VARCHAR2,
                              P_IVA              VARCHAR2,
                              P_TA_EXCEPCIONES IN TA_EXCEPCIONES);

  PROCEDURE PRC_VALIDAR_ANULADO(SOLICITUD   ARRNDTRIOS.ARR_NMRO_SLCTUD%TYPE,
                                TIPO_AMPARO VARCHAR2,
                                AMPARO      RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                                APROBACION  IN OUT NUMBER,
                                RESULTADO   IN OUT NUMBER);

  PROCEDURE PRC_AUMENTO_SEGURO(SOLICITUD       IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                               SES_NMRO_PLZA   IN SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                               APR_CDGO_AMPRO  AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                               APR_TPO_AMPRO   IN AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE,
                               CLASE           VARCHAR2,
                               RAMO            VARCHAR2,
                               COMPANIA        VARCHAR2,
                               SUCURSAL        VARCHAR2,
                               FECHA_NVDAD     DATE,
                               NOVEDADES       VARCHAR2,
                               NUEVO_VALOR     NUMBER,
                               RVL_VLOR        NUMBER,
                               RVL_CNCPTO_VLOR IN V_CONCEPTOS.RVL_CNCPTO_VLOR%TYPE,
                               TTAL_ASGRDO     NUMBER,
                               FECHA_INGRESO   DATE,
                               CODIGO_USUARIO  VARCHAR2,
                               ENTRO           IN OUT NUMBER,
                               P_NOVEDAD_WEB   VARCHAR2,
                               MENSAJE         OUT VARCHAR2,
                               P_DESTINO_INMUEBLE VARCHAR2,
                               P_DVSION_POLITICA  NUMBER,
                               P_IVA              VARCHAR2);


   Procedure PRC_DEV_PRIMAS(SOLICITUD     NUMBER,
                                       POLIZA        NUMBER,
                                       SUCURSAL      VARCHAR2,
                                       COMPANIA      VARCHAR2,
                                       FECHA_NOVEDAD DATE,
                                       CLASE_POLIZA  VARCHAR2,
                                       RAMO          VARCHAR2,
                                       DEVOLUCION    NUMBER,
                                       MENSAJE       IN OUT VARCHAR2,
                                       USUARIO       VARCHAR2,
                                       NOVEDAD       VARCHAR2,
                                       AMPARO        VARCHAR2,
                                       MODULO        VARCHAR2,
                                       RAZON         VARCHAR2,
                                       TARIFACION    IN AMPROS_PRDCTO.APR_TRFCION_EXTRNA%TYPE);


    Procedure PRC_DEV_PRIMAS_POLIZA(POLIZA        NUMBER,
                                    SUCURSAL      VARCHAR2,
                                    COMPANIA      VARCHAR2,
                                    FECHA_NOVEDAD DATE,
                                    CLASE_POLIZA  VARCHAR2,
                                    RAMO          VARCHAR2,
                                    DEVOLUCION    NUMBER,
                                    MENSAJE       IN OUT VARCHAR2,
                                    USUARIO       VARCHAR2,
                                    NOVEDAD       VARCHAR2,
                                    AMPARO        VARCHAR2,
                                    MODULO        VARCHAR2,
                                    RAZON         VARCHAR2);




  PROCEDURE PRC_DEVOLUCION(SOLICITUD     NUMBER,
                           POLIZA        NUMBER,
                           RAMO          VARCHAR2,
                           CLASE         VARCHAR2,
                           AMPARO        VARCHAR2,
                           PERIODO       VARCHAR2,
                           CERTIFICADO   NUMBER,
                           MENSAJE       OUT VARCHAR2);


  PROCEDURE PRC_SUSPENSION(P_RAMO      IN PLZAS.POL_RAM_CDGO%TYPE,
                           P_SOLICITUD IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                           P_AMPARO    IN RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                           P_MODULO    IN MODULOS.MDL_CDGO%TYPE,
                           P_USUARIO   IN USRIOS.USR_CDGO_USRIO%TYPE,
                           P_CADENA    OUT VARCHAR2,
                           MENSAJE_S   OUT VARCHAR2);


  PROCEDURE PRC_LIQUIDACION(SOLICITUD         NUMBER,
                            RAMO              IN VARCHAR2,
                            POLIZA            NUMBER,
                            FECHA_LIQUIDACION DATE,
                            CLASE             IN VARCHAR2,
                            AMPARO            IN VARCHAR2,
                            CONCEPTO          IN VARCHAR,
                            VALOR_ANT         IN NUMBER,
                            VALOR             IN NUMBER,
                            IVA               IN NUMBER,
                            PERIODO           IN VARCHAR2,
                            USUARIO           IN VARCHAR2,
                            PRIMA_NETA_ANT    IN OUT NUMBER,
                            PRIMA_NETA        IN OUT NUMBER,
                            PRIMA_TOTAL_ANT   IN OUT NUMBER,
                            PRIMA_TOTAL       IN OUT NUMBER,
                            PRIMA_ANUAL_ANT   IN OUT NUMBER,
                            PRIMA_ANUAL       IN OUT NUMBER,
                            IVA_PRIMA_ANT     IN OUT NUMBER,
                            IVA_PRIMA         IN OUT NUMBER,
                            PORC_DESCUENTO    IN OUT NUMBER,
                            CUOTAS            OUT NUMBER,
                            MENSAJE           IN OUT VARCHAR2,
                            TASA              IN OUT NUMBER,
                            TIPO_TASA         IN OUT VARCHAR2,
                            TIPO_TASA_P       IN VARCHAR2,
                            TASA_P            IN NUMBER,
                            SUCURSAL          IN VARCHAR2,
                            COMPANIA          IN VARCHAR2,
                            NOVEDAD           IN VARCHAR2);

   PROCEDURE PRC_LIQUIDACION_T(SOLICITUD         NUMBER,
                                            NOVEDAD           IN VARCHAR2,
                                            RAMO              IN VARCHAR2,
                                            POLIZA            NUMBER,
                                            FECHA_LIQUIDACION DATE,
                                            CLASE             IN VARCHAR2,
                                            AMPARO            IN VARCHAR2,
                                            CONCEPTO          IN VARCHAR,
                                            VALOR_ANT         IN NUMBER,
                                            VALOR             IN NUMBER,
                                            IVA               IN NUMBER,
                                            PERIODO           IN VARCHAR2,
                                            USUARIO           IN VARCHAR2,
                                            PRIMA_NETA_ANT    IN OUT NUMBER,
                                            PRIMA_NETA        IN OUT NUMBER,
                                            PRIMA_TOTAL_ANT   IN OUT NUMBER,
                                            PRIMA_TOTAL       IN OUT NUMBER,
                                            PRIMA_ANUAL_ANT   IN OUT NUMBER,
                                            PRIMA_ANUAL       IN OUT NUMBER,
                                            IVA_PRIMA_ANT     IN OUT NUMBER,
                                            IVA_PRIMA         IN OUT NUMBER,
                                            PORC_DESCUENTO    IN OUT NUMBER,
                                            CUOTAS            OUT NUMBER,
                                            MENSAJE           IN OUT VARCHAR2,
                                            TASA              IN OUT NUMBER,
                                            TIPO_TASA         IN OUT VARCHAR2,
                                            TIPO_TASA_P       IN VARCHAR2,
                                            TASA_P            IN NUMBER,
                                            SUCURSAL          IN VARCHAR2,
                                            COMPANIA          IN VARCHAR2);

  PROCEDURE PRC_DEVOLUCION_PRIMAS(P_SOLICITUD    IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                              P_POLIZA       IN PLZAS.POL_NMRO_PLZA%TYPE,
                              P_CLASE        IN PLZAS.POL_CDGO_CLSE%TYPE,
                              P_RAMO         IN PLZAS.POL_RAM_CDGO%TYPE,
                              P_DVLCION      IN NUMBER,
                              P_SUCURSAL     IN SCRSL.SUC_CDGO%TYPE,
                              P_COMPANIA     PLZAS.POL_SUC_CIA_CDGO%TYPE,
                              P_FECHA_NVDAD  RSGOS_VGNTES_NVDDES.RIVN_FCHA_NVDAD%TYPE,
                              P_USUARIO      USRIOS.USR_CDGO_USRIO%TYPE,
                              P_AMPARO       RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                              P_MODULO       MODULOS.MDL_CDGO%TYPE,
                              P_RAZON        VARCHAR2,
                              P_NOVEDAD_DEV  VARCHAR2,
                              MENSAJE_D      OUT VARCHAR2,
                              TARIFACION     AMPROS_PRDCTO.APR_TRFCION_EXTRNA%TYPE);

  PROCEDURE PRC_DEVOLUCION_PRIMAS_POLIZA(P_POLIZA       IN PLZAS.POL_NMRO_PLZA%TYPE,
                                     P_CLASE        IN PLZAS.POL_CDGO_CLSE%TYPE,
                                     P_RAMO         IN PLZAS.POL_RAM_CDGO%TYPE,
                                     P_COMPANIA     IN PLZAS.POL_SUC_CIA_CDGO%TYPE,
                                     P_DVLCION_POL  IN NUMBER,
                                     P_NOVEDADES    VARCHAR2,
                                     P_SUCURSAL     SCRSL.SUC_CDGO%TYPE,
                                     P_USUARIO      USRIOS.USR_CDGO_USRIO%TYPE,
                                     P_NVDAD_DEV    VARCHAR2,
                                     P_MODULO       MODULOS.MDL_CDGO%TYPE,
                                     P_RAZON        VARCHAR2,
                                     MENSAJE_D      OUT VARCHAR2);


  PROCEDURE PRC_CALCULAR_RETROACTIVIDAD(FECHA_LIQUIDACION     IN OUT DATE,
                                                      PERIODO               IN VARCHAR2,
                                                      PRIMA_NETA            IN NUMBER,
                                                      PRIMA_ANUAL           IN NUMBER,
                                                      PRIMA_TOTAL           IN NUMBER,
                                                      IVA_PRIMA             IN NUMBER,
                                                      PRIMA_NETA_ANT        IN NUMBER,
                                                      PRIMA_ANUAL_ANT       IN NUMBER,
                                                      PRIMA_TOTAL_ANT       IN NUMBER,
                                                      IVA_PRIMA_ANT         IN NUMBER,
                                                      DESCUENTO             IN NUMBER,
                                                      DESCUENTO_ANT         IN NUMBER,
                                                      PRIMA_RETRO_NETA      IN OUT NUMBER,
                                                      PRIMA_RETRO_ANUAL     IN OUT NUMBER,
                                                      PRIMA_RETRO_TOTAL     IN OUT NUMBER,
                                                      IVA_RETRO             IN OUT NUMBER,
                                                      PRIMA_RETRO_NETA_ANT  IN OUT NUMBER,
                                                      PRIMA_RETRO_ANUAL_ANT IN OUT NUMBER,
                                                      PRIMA_RETRO_TOTAL_ANT IN OUT NUMBER,
                                                      IVA_RETRO_ANT         IN OUT NUMBER,
                                                      MODULO                IN VARCHAR2,
                                                      CESION                IN VARCHAR2,
                                                      TIPO_TASA             IN VARCHAR2,
                                                      MENSAJE               IN OUT VARCHAR2);

  PROCEDURE PRC_INGRESOS(NOVEDAD         VARCHAR2,
                                         SOLICITUD       NUMBER,
                                         POLIZA          NUMBER,
                                         CLASE_POLIZA    VARCHAR2,
                                         RAMO            VARCHAR2,
                                         FECHA_NOVEDAD   DATE,
                                         CERTIFICADO     NUMBER,
                                         NMRO_IDEN       NUMBER,
                                         TPO_IDEN        VARCHAR2,
                                         VALOR_ASEGURADO NUMBER,
                                         VALOR_ANT       NUMBER,
                                         VALOR           NUMBER,
                                         PRIMA_NETA_ANT  NUMBER,
                                         PRIMA_NETA      NUMBER,
                                         PRIMA_ANUAL_ANT NUMBER,
                                         PRIMA_ANUAL     NUMBER,
                                         ENTRO           NUMBER,
                                         USUARIO         VARCHAR2,
                                         MENSAJE         IN OUT VARCHAR2);

  PROCEDURE PRC_ACTUALIZA_VALOR(NOVEDAD      VARCHAR2,
                                SOLICITUD    NUMBER,
                                POLIZA       NUMBER,
                                CLASE_POLIZA VARCHAR2,
                                RAMO         VARCHAR2,
                                CERTIFICADO  NUMBER,
                                CONCEPTO     VARCHAR2,
                                AMPARO       VARCHAR2,
                                VALOR_ANT    NUMBER,
                                VALOR        NUMBER,
                                USUARIO      VARCHAR2,
                                MENSAJE      IN OUT VARCHAR2);


 PROCEDURE PRC_ACTUALIZA_VALORES(NOVEDAD      VARCHAR2,
                                                SOLICITUD    NUMBER,
                                                POLIZA       NUMBER,
                                                CLASE_POLIZA VARCHAR2,
                                                RAMO         VARCHAR2,
                                                CERTIFICADO  NUMBER,
                                                CONCEPTO     VARCHAR2,
                                                AMPARO       VARCHAR2,
                                                VALOR_ANT    NUMBER,
                                                VALOR        NUMBER,
                                                ENTRO        NUMBER,
                                                USUARIO      VARCHAR2,
                                                MENSAJE      IN OUT VARCHAR2);

  PROCEDURE PRC_ARRENDATARIOS(NOVEDAD      VARCHAR2,
                                            SOLICITUD    NUMBER,
                                            POLIZA       NUMBER,
                                            CLASE_POLIZA VARCHAR2,
                                            RAMO         VARCHAR2,
                                            AMPARO       VARCHAR2,
                                            CONCEPTO     VARCHAR2,
                                            CERTIFICADO  NUMBER,
                                            ENTRO        IN OUT NUMBER,
                                            USUARIO      VARCHAR2,
                                            MENSAJE      IN OUT VARCHAR2);

 PROCEDURE PRC_AMPAROS(NOVEDAD             VARCHAR2,
                                      SOLICITUD           NUMBER,
                                      POLIZA              NUMBER,
                                      CLASE_POLIZA        VARCHAR2,
                                      RAMO                VARCHAR2,
                                      AMPARO              VARCHAR2,
                                      CONCEPTO            VARCHAR2,
                                      CERTIFICADO         NUMBER,
                                      VALOR_ASEGURADO_ANT NUMBER,
                                      VALOR_ASEGURADO     NUMBER,
                                      PRIMA_NETA_ANT      NUMBER,
                                      PRIMA_NETA          NUMBER,
                                      PRIMA_NETA_ANUAL    NUMBER,
                                      PRIMA_ANUAL_ANT     NUMBER,
                                      PRIMA_ANUAL         NUMBER,
                                      TIPO_TASA           VARCHAR2,
                                      TASA                NUMBER,
                                      TPO_DEDUCIBLE       VARCHAR2,
                                      PORC_DEDUCIBLE      NUMBER,
                                      MNMO_DEDUCIBLE      NUMBER,
                                      TPO_IDEN            VARCHAR2,
                                      NMRO_IDEN           NUMBER,
                                      PORC_DESCUENTO      NUMBER,
                                      IVA                 NUMBER,
                                      ENTRO               IN OUT NUMBER,
                                      USUARIO             VARCHAR2,
                                      FECHA_NOVEDAD       DATE,
                                      MENSAJE             IN OUT VARCHAR2);

PROCEDURE PRC_ACTUALIZA_AMPAROS(NOVEDAD      VARCHAR2,
                                                SOLICITUD    NUMBER,
                                                POLIZA       NUMBER,
                                                CLASE_POLIZA VARCHAR2,
                                                RAMO         VARCHAR2,
                                                CONCEPTO     VARCHAR2,
                                                CERTIFICADO  NUMBER,
                                                AMPARO       VARCHAR2,
                                                VALOR_ANT    NUMBER,
                                                VALOR        NUMBER,
                                                PRIMA        NUMBER,
                                                PRIMA_ANT    NUMBER,
                                                IVA          NUMBER,
                                                IVA_ANT      NUMBER,
                                                TASA         NUMBER,
                                                USUARIO      VARCHAR2,
                                                MENSAJE      IN OUT VARCHAR2);

PROCEDURE PRC_INSERTA_NOVEDAD(NOVEDAD             VARCHAR2,
                                              SOLICITUD           NUMBER,
                                              POLIZA              NUMBER,
                                              CLASE_POLIZA        VARCHAR2,
                                              RAMO                VARCHAR2,
                                              FECHA_NOVEDAD       DATE,
                                              CONCEPTO            VARCHAR2,
                                              AMPARO              VARCHAR2,
                                              CERTIFICADO         NUMBER,
                                              VALOR_ANT           NUMBER,
                                              VALOR               NUMBER,
                                              VALOR_ASEGURADO_ANT NUMBER,
                                              VALOR_ASEGURADO     NUMBER,
                                              ENTRO               NUMBER,
                                              USUARIO             VARCHAR2,
                                              FECHA_PERIODO       DATE,
                                              REGISTRAR           VARCHAR2,
                                              MENSAJE             IN OUT VARCHAR2);


PROCEDURE PRC_VALORES_PRIMAS(NOVEDAD             VARCHAR2,
                                               FECHA_NOVEDAD       DATE,
                                               POLIZA              NUMBER,
                                               CLASE_POLIZA        VARCHAR2,
                                               RAMO                VARCHAR2,
                                               AMPARO              VARCHAR2,
                                               CERTIFICADO         NUMBER,
                                               SOLICITUD           NUMBER,
                                               PRIMA_NETA_ANT      IN OUT NUMBER,
                                               PRIMA_NETA          IN OUT NUMBER,
                                               PRIMA_TOTAL_ANT     IN OUT NUMBER,
                                               PRIMA_TOTAL         IN OUT NUMBER,
                                               PRIMA_ANUAL_ANT     IN OUT NUMBER,
                                               PRIMA_ANUAL         IN OUT NUMBER,
                                               VALOR_ASEGURADO_ANT NUMBER,
                                               VALOR_ASEGURADO     NUMBER,
                                               IVA                 NUMBER,
                                               IVA_PRIMA_ANT       IN OUT NUMBER,
                                               IVA_PRIMA           IN OUT NUMBER,
                                               RETRO_NETA          NUMBER,
                                               RETRO_ANUAL         NUMBER,
                                               RETRO_TOTAL         NUMBER,
                                               IVA_RETRO           NUMBER,
                                               RETRO_NETA_ANT      NUMBER,
                                               RETRO_ANUAL_ANT     NUMBER,
                                               RETRO_TOTAL_ANT     NUMBER,
                                               IVA_RETRO_ANT       NUMBER,
                                               PERIODO             VARCHAR2,
                                               CUOTAS              NUMBER,
                                               ENTRO               IN OUT NUMBER,
                                               USUARIO             VARCHAR2,
                                               MENSAJE             IN OUT VARCHAR2,
                                               CESION              IN VARCHAR2,
                                               COBRAR              IN VARCHAR2,
                                               TIPO_TASA           IN VARCHAR2);

  PROCEDURE PRC_BORRAR_REGISTROS(NOVEDAD      VARCHAR2,
                                               P_SOLICITUD    NUMBER,
                                               POLIZA       NUMBER,
                                               CLASE_POLIZA VARCHAR2,
                                               RAMO         VARCHAR2,
                                               CONCEPTO     VARCHAR2,
                                               AMPARO       VARCHAR2);

  PROCEDURE PRC_NOVEDADES(SOLICITUD     IN NUMBER,
                          POLIZA        IN NUMBER,
                          CLASE_POLIZA  IN VARCHAR2,
                          RAMO          IN VARCHAR2,
                          SUCURSAL      IN VARCHAR2,
                          COMPANIA      IN VARCHAR2,
                          FECHA_NOVEDAD IN OUT DATE,
                          AMPARO        IN VARCHAR2,
                          CONCEPTO      IN VARCHAR2,
                          VALOR_ANT     IN NUMBER,
                          CERTIFICADO   IN NUMBER,
                          VALOR         IN NUMBER,
                          NOVEDAD       IN VARCHAR2,
                          ENTRO         IN OUT NUMBER,
                          MODULO        IN VARCHAR2,
                          MENSAJE       IN OUT VARCHAR2,
                          USUARIO       IN VARCHAR2,
                          CESION        IN VARCHAR2,
                          COBRAR        IN VARCHAR2,
                          PERIODO       IN VARCHAR2,
                          TIPO_TASA_P   IN VARCHAR2,
                          TASA_P        IN NUMBER,
                          P_NOVEDAD_WEB IN VARCHAR2);
  
  PROCEDURE PRC_VALOR_BASE(P_SOLICITUD  NUMBER,
                           P_CONCEPTO   VARCHAR2,
                           P_POLIZA     NUMBER,
                           P_CLASE      VARCHAR2,
                           P_RAMO       VARCHAR2,
                           P_AMPARO     VARCHAR2,
                           P_USUARIO    VARCHAR2,
                           P_MENSAJE    OUT VARCHAR2);                          

  PROCEDURE PRC_AUMENTO_HOGAR(P_AMPARO          AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                              P_RAMO            AMPROS_PRDCTO.APR_RAM_CDGO%TYPE,
                              P_CLASE           RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE,
                              P_COMPANIA        SCRSL.SUC_CIA_CDGO%TYPE,
                              P_SUCURSAL        SCRSL.SUC_CDGO%TYPE,
                              FECHA_NOVEDAD     DATE,
                              FECHA_INGRESO     DATE,
                              P_SOLICITUD       RSGOS_VGNTES_AMPRO.RVA_NMRO_ITEM%TYPE,
                              P_POLIZA          RSGOS_VGNTES.RVI_NMRO_PLZA%TYPE,
                              P_CONCEPTO        VLRES_PRDCTO.VPR_CDGO%TYPE,
                              P_VALOR_ANT       NUMBER,
                              P_NUEVO_VALOR     NUMBER,
                              P_CODIGO_USUARIO  VARCHAR2,
                              P_NOVEDAD_WEB     VARCHAR2,
                              P_MENSAJE         OUT VARCHAR2,
                              P_DESTINO_INMUEBLE VARCHAR2,
                              P_DVSION_POLITICA  NUMBER);

  PROCEDURE PRC_RETIRO_SEGURO(P_SOLICITUD      SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                              P_POLIZA         SLCTDES_ESTDIOS.SES_NMRO_PLZA%TYPE,
                              P_AMPARO         AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                              P_RAMO           VARCHAR2,
                              P_CLASE          VARCHAR2,
                              P_COMPANIA       VARCHAR2,
                              P_SUCURSAL       SCRSL.SUC_CDGO%TYPE,
                              P_FECHA_NOVEDAD  DATE,
                              TTAL_ASGRDO      NUMBER,
                              P_CODIGO_USUARIO VARCHAR2,
                              P_MENSAJE        OUT VARCHAR2,
                              P_MENSAJE_INF    OUT VARCHAR2,
                              P_NOVEDAD_WEB    VARCHAR2,
                              P_DESTINO_INMUEBLE VARCHAR2,
                              P_DVSION_POLITICA  NUMBER);

  PROCEDURE PRC_DIFERENCIAS(P_RECIBO     IN NUMBER,
                            P_COMPANIA   IN VARCHAR2,
                            P_DIFERENCIA IN NUMBER,
                            P_VALOR      OUT NUMBER);

  PROCEDURE PRC_TESORERIA(P_NORECIBO          NUMBER,
                          P_CIA               VARCHAR2,
                          P_TEXTO             VARCHAR2,
                          P_VALORR            NUMBER,
                          P_POLIZA            NUMBER,
                          P_CODIGO_SUCURSAL   SCRSL.SUC_CDGO%TYPE,
                          P_NMRO_IDEN         NUMBER,
                          P_TIPO_IDEN         VARCHAR2,
                          P_TIPO_ACTIVIDAD    NUMBER,
                          P_FECHA_RECIBO      DATE);


  PROCEDURE PRC_PAGO_PRIMAS(P_POLIZA          PLZAS.POL_NMRO_PLZA%TYPE,
                            P_NMRO_IDNTFCCION PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE,
                            P_TPO_IDNTFCCION  PLZAS.POL_PRS_TPO_IDNTFCCION%TYPE,
                            P_VALOR_PAGAR     NUMBER,
                            P_ORIGEN          VARCHAR2,
                            P_CODIGO_LIQ      IN OUT NUMBER,
                            P_ESTADO          IN OUT VARCHAR2,
                            P_MENSAJE         IN OUT VARCHAR2);


  PROCEDURE PRC_LIQUIDACION_PRIMAS(P_POLIZA          PLZAS.POL_NMRO_PLZA%TYPE,
                                   P_NMRO_IDNTFCCION PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE,
                                   P_TPO_IDNTFCCION  PLZAS.POL_PRS_TPO_IDNTFCCION%TYPE,
                                   P_VALOR_PAGAR     NUMBER,
                                   P_USUARIO         VARCHAR2,
                                   P_NUMERO_RECIBO   IN OUT NUMBER,
                                   P_SECUENCIA       IN OUT NUMBER,
                                   P_TEXTO           IN OUT VARCHAR2,
                                   P_REGISTRO        NUMBER);


  PROCEDURE PRC_INSERTA_PSE(P_TIPO_ID     IN VARCHAR2,
                          P_NMRO_ID     IN NUMBER,
                          P_LIQUIDACION IN NUMBER,
                          P_VALOR_PAGO  IN NUMBER,
                          P_TEXTO       IN VARCHAR2,
                          P_CODIGO      IN OUT NUMBER);


  PROCEDURE PRC_GENERA_ORDEN_PAGO(P_POLIZA            NUMBER,
                                P_CLASE             VARCHAR2,
                                P_RAMO              VARCHAR2,
                                P_COMPANIA          VARCHAR2,
                                P_SUCURSAL          VARCHAR2,
                                P_TIPO_BENEFICIARIO VARCHAR2,
                                P_NIT_BENEFICIARIO  NUMBER,
                                P_SUCURSAL_PAGO     NUMBER,
                                P_FECHA_PAGO        DATE,
                                P_USUARIO           VARCHAR2,
                                P_VALOR             IN OUT NUMBER,
                                P_ORIGEN            VARCHAR2,
                                P_RECIBO_CJA        NUMBER);

  PROCEDURE PRC_ACTUALIZA_LIQUIDACION(P_LIQUIDACION  NUMBER,
                                      P_COMPANIA     VARCHAR2,
                                      P_TIPO_RECIBO  VARCHAR2,
                                      P_VALOR_RECIBO NUMBER);


  PROCEDURE PRC_ANULAR_LIQUIDACION(P_TIPO_ID     IN VARCHAR2,
                                   P_NUMERO_ID   IN NUMBER,
                                   P_POLIZA      IN NUMBER,
                                   P_MENSAJE     OUT VARCHAR2);

  PROCEDURE PRC_INSERTA_TIPO_CARTA(P_OPERACION        IN VARCHAR2,
                                   P_DESCRIPCION      IN VARCHAR2,
                                   P_SECUENCIA_MORA    IN VARCHAR2,
                                   P_SECUENCIA_FIRMA  IN NUMBER,
                                   P_REFERENCIA        IN VARCHAR2,
                                   P_TEXTO_INICIAL    IN VARCHAR2,
                                   P_TEXTO_FINAL      IN VARCHAR2,
                                   P_CARTA_AUTOMATICA IN VARCHAR2,
                                   P_USUARIO           IN VARCHAR2,
                                   P_SECUENCIA_CARTA   IN NUMBER,
                                   P_RESULTADO        OUT VARCHAR2,
                                   P_MENSAJE           OUT VARCHAR2);

  PROCEDURE PRC_INSERTA_BITACORA_PRIMAS(P_NUMERO_POLIZA   NUMBER,
                                        P_CLASE_POLIZA    VARCHAR2,
                                        P_RAMO            VARCHAR2,
                                        P_TEXTO_BITACORA  VARCHAR,
                                        P_USUARIO         VARCHAR2,
                                        P_RESULTADO       OUT VARCHAR2,
                                        P_MENSAJE         OUT VARCHAR2);


  PROCEDURE PRC_INSERTA_FECHAS_ACUERDO(P_NUMERO_POLIZA   NUMBER,
                                       P_CLASE_POLIZA    VARCHAR2,
                                       P_RAMO            VARCHAR2,
                                       P_FECHA_ACUERDO   DATE,
                                       P_VALOR_ACUERDO   NUMBER,
                                       P_OBSERVACION     VARCHAR2,
                                       P_MARCA_PAGADO    VARCHAR2,
                                       P_USUARIO         VARCHAR2,
                                       P_OPERACION       VARCHAR2,
                                       P_SECUENCIA       NUMBER,
                                       P_RESULTADO       OUT VARCHAR2,
                                       P_MENSAJE         OUT VARCHAR2);


  PROCEDURE PRC_ENVIAR_CORREO(P_NUMERO_POLIZA      IN NUMBER,
                              P_USUARIO           IN VARCHAR2,
                              P_CORREO_DESTINO    IN VARCHAR2,
                              P_RESULTADO         OUT VARCHAR2,
                              P_MENSAJE           OUT VARCHAR2);

  PROCEDURE PRC_ACTUALIZA_PLZAS(P_POLIZA    NUMBER,
                                P_ENVIO     VARCHAR2,
                                P_USUARIO   VARCHAR2,
                                P_RESULTADO OUT VARCHAR2,
                                P_MENSAJE   OUT VARCHAR2);

  PROCEDURE PRC_ANULA_PLZAS(P_USUARIO  VARCHAR2,
                            P_MENSAJE  OUT VARCHAR2);

  PROCEDURE PRC_LIQUIDACIONES_PENDIENTES;
  
    
  PROCEDURE PRC_VERIFICA_NOTA_NEGATIVA(P_RECIBO       NUMBER,
                                       P_TIPO         VARCHAR2,
                                       P_CIA          VARCHAR2,
                                       P_POLIZA       NUMBER);
                                       
  PROCEDURE PRC_CERT_PENDIENTES(P_RECIBO       NUMBER,
                                P_TIPO         VARCHAR2,
                                P_CIA          VARCHAR2,
                                P_SUCURSAL     VARCHAR2, 
                                P_TIPO_ID      VARCHAR2,
                                P_NMRO_ID      NUMBER,
                                P_POLIZA       NUMBER,
                                P_USUARIO      VARCHAR2,
                                P_VALOR_RECIBO IN OUT NUMBER,
                                P_DIV_CODIGO   NUMBER,
                                P_DEUDA        NUMBER,
                                P_DIFERENCIA   IN OUT NUMBER,
                                P_VR_INTERFAZ  OUT NUMBER,
                                P_MENSAJE      OUT VARCHAR2);   
                                
END PKG_OPERACION;
/