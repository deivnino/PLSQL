CREATE OR REPLACE PACKAGE admsisa.PKG_OBJETAR_SUBSANAR IS

  -- Author  : GLORIA GANTIVA 
  -- Purpose : Paquete que objeta y subsana un siniestro según politicas definidas
  --           Solo para el amparo básico
  -- Created : Febrero del 2014

  GPERIODO     VARCHAR2(7);
  GPERIODONEW  VARCHAR2(7);
  PERIODO      PRMTROS.PAR_RFRNCIA%TYPE;
  V_FECHA_PAGO DATE;
  FECHA_POLIZA DATE;
  V_PAGOS      VARCHAR2(1);
  N_FECHA_MORA DATE;
  GINSERTO     VARCHAR2(7) := 'N';
  S_ENTRO      VARCHAR2(1) := 'N';
  V_ENTRO      VARCHAR2(1) := 'N';
  BORRA        VARCHAR2(1):='N';
  EXISTE_RM    NUMBER:=0;
  V_CAMBIA_FECHA VARCHAR2(1):='N';


  FUNCTION FUN_CDGO_RECUP(CODIGO VARCHAR2) RETURN VARCHAR2;

  FUNCTION FUN_EXISTE_PAGO(SOLICITUD NUMBER, SINIESTRO NUMBER) RETURN VARCHAR2;

  FUNCTION FUN_NUMERO_SINIESTRO(ACCION VARCHAR2) RETURN NUMBER;

  FUNCTION FUN_CONSULTA_PERIODO(AMPARO         VARCHAR2,
                                POLIZA         NUMBER,
                                RAMO           VARCHAR2,
                                CLASE          VARCHAR2,
                                FECHA_OBJECION DATE,
                                F_SUBSANACION  DATE) RETURN VARCHAR;

  FUNCTION FUN_NMRO_MESES(FECHA_MORA DATE) RETURN NUMBER;

  FUNCTION FUN_AMNTOS(SINIESTRO NUMBER, CONCEPTO VARCHAR2) RETURN VARCHAR2;
  
  FUNCTION FUN_VALIDA_PAGO(SOLICITUD NUMBER, FECHA_MORA  DATE, CONCEPTO  VARCHAR2) RETURN VARCHAR2;

  FUNCTION FUN_BORRA_RCPRCNES(SOLICITUD  NUMBER,
                              SINIESTRO  NUMBER) RETURN VARCHAR2;
                              
  FUNCTION FUN_FECHA_PROXIMA(P_SOLICITUD   NUMBER,
                             P_SINIESTRO   NUMBER,
                             P_FECHA_PAGO  DATE) RETURN VARCHAR2;                              
                              
  FUNCTION FUN_VALIDA_PAGO_MAYOR(SOLICITUD NUMBER, FECHA_MORA  DATE,CONCEPTO  VARCHAR2) RETURN VARCHAR2;                              
  
  PROCEDURE PRC_ESTADOS_SNSTRO(SINIESTRO     NUMBER,
                               ESTADO_SNSTRO OUT VARCHAR2,
                               ESTADO_PAGO   OUT VARCHAR2);

  PROCEDURE PRC_CALCULA_VALOR(SINIESTRO NUMBER,
                              CONCEPTO  VARCHAR2,
                              VALOR     OUT NUMBER,
                              VALOR_ANT OUT NUMBER,
                              FECHA     OUT DATE);

  PROCEDURE PRC_CAMBIA_ESTDO_SNSTRO(RAMO      VARCHAR2,
                                    SINIESTRO NUMBER,
                                    EST_PAGO  VARCHAR2);

  PROCEDURE PRC_ACTUALIZA_FECHA(SOLICITUD  NUMBER,
                                FECHA_MORA DATE,
                                POLIZA     NUMBER,
                                CLASE      VARCHAR2,
                                RAMO       VARCHAR2,
                                SINIESTRO  NUMBER);

  PROCEDURE PRC_BORRA_LQDCNES_NGTVAS(SINIESTRO  NUMBER,
                                     RAMO       VARCHAR2,
                                     FECHA_PAGO DATE);

  PROCEDURE PRC_CAMBIAR_OBJCION(RAMO      VARCHAR2,
                                SINIESTRO NUMBER,
                                AMPARO    VARCHAR2);

  PROCEDURE PRC_INSERT_VLRES_DDAS_TMP(RAMO      VARCHAR2,
                                      SINIESTRO NUMBER,
                                      SOLICITUD NUMBER,
                                      OBJETA    VARCHAR2);

  PROCEDURE PRC_CAMBIA_CONCEPTOS(RAMO       VARCHAR2,
                                 AMPARO     VARCHAR2,
                                 SINIESTRO  NUMBER,
                                 SOLICITUD  NUMBER,
                                 CONCEPTO   VARCHAR2,
                                 VR_CNSTTDO NUMBER,
                                 VR_AFNZDO  NUMBER,
                                 MENSAJE    OUT VARCHAR2);

  PROCEDURE PRC_SUSPENDE_LQDCION(SINIESTRO NUMBER, RAMO VARCHAR2);

  PROCEDURE PRC_BORRA_DDCCIONES(SOLICITUD NUMBER, FECHA_MORA DATE);

  PROCEDURE PRC_OBJETAR(SOLICITUD     NUMBER,
                        SINIESTRO     NUMBER,
                        FECHA_MORA    DATE,
                        AMPARO        VARCHAR2,
                        RAMO          VARCHAR2,
                        ESTADO_SNSTRO VARCHAR2,
                        DEDUCCION     NUMBER,
                        ESTDO_PGO     VARCHAR2,
                        OBJETA        VARCHAR2,
                        MENSAJE       OUT VARCHAR2);

  PROCEDURE PRC_CAMBIAR_ESTDO_LQDCION(SINIESTRO NUMBER,
                                      ESTADO    VARCHAR2,
                                      SOLICITUD NUMBER);

  PROCEDURE PRC_ACTUALIZA_VALOR_LQDCION(SINIESTRO  NUMBER,
                                        RAMO       VARCHAR2,
                                        SOLICITUD  NUMBER,
                                        FECHA_MORA DATE,
                                        CONCEPTO   VARCHAR2,
                                        PORCENTAJE NUMBER);


  PROCEDURE PRC_NUEVO_SINIESTRO(SOLICITUD      NUMBER,
                                FECHA_MORA     DATE,
                                SINIESTRO      NUMBER,
                                ESTADO_SNSTRO  VARCHAR2,
                                FECHA_DESOCUPA DATE,
                                AMPARO         VARCHAR2,
                                POLIZA         NUMBER,
                                CLASE          VARCHAR2,
                                RAMO           VARCHAR2,
                                N_SINIESTRO    OUT NUMBER,
                                N_FECHA_MRA    OUT DATE);

  PROCEDURE PRC_NUEVA_LIQUIDACION(SOLICITUD  NUMBER,
                                  SINIESTRO  NUMBER,
                                  FECHA_MORA DATE,
                                  AMPARO     VARCHAR2,
                                  POLIZA     NUMBER,
                                  CLASE      VARCHAR2,
                                  RAMO       VARCHAR2,
                                  CONCEPTO   VARCHAR2,
                                  PORCENTAJE VARCHAR2);

  PROCEDURE PRC_INSERTA_LQDCION_NUEVOS(SOLICITUD      NUMBER,
                                       FECHA_MORA     DATE,
                                       N_FECHA_MORA   DATE,
                                       SINIESTRO      NUMBER,
                                       ESTADO_SNSTRO  VARCHAR2,
                                       AMPARO         VARCHAR2,
                                       CONCEPTO       VARCHAR2,
                                       POLIZA         NUMBER,
                                       CLASE          VARCHAR2,
                                       RAMO           VARCHAR2,
                                       FECHA_DSCPCION DATE,
                                       P_VALOR        NUMBER);

  PROCEDURE PRC_VLRES_DDAS(P_SOLICITUD      NUMBER,
                           P_FECHA_MORA     DATE,
                           N_FECHA_MORA     DATE,
                           P_POLIZA         NUMBER,
                           P_RAMO           VARCHAR2,
                           P_CLASE          VARCHAR2,
                           P_SINIESTRO      NUMBER,
                           N_SINIESTRO      NUMBER,
                           P_AMPARO         VARCHAR2,
                           P_CONCEPTO       VARCHAR2,
                           P_ESTDO_SNSTRO   VARCHAR2,
                           P_FECHA_DESOCUPA DATE,
                           VR_PGDO_CIA      NUMBER,
                           VR_AFNZDO        NUMBER,
                           VR_CNSTTDO       NUMBER);

  PROCEDURE PRC_RFRNCIAS_RCBOS(SOLICITUD  NUMBER,
                               POLIZA     NUMBER,
                               FECHA_MORA DATE);


  PROCEDURE PRC_ACTUALIZA_DDAS(RAMO         VARCHAR2,
                               CLASE        VARCHAR2,
                               AMPARO       VARCHAR2,
                               SINIESTRO    NUMBER,
                               SOLICITUD    NUMBER,
                               CONCEPTO     VARCHAR2,
                               VR_PGDO_CIA  NUMBER,
                               VLOR_CNSTTDO NUMBER,
                               VLOR_AFNZDO  NUMBER,
                               POLIZA       NUMBER,
                               P_PERIODO    VARCHAR2,
                               P_MENSAJE    OUT VARCHAR2);

  PROCEDURE PRC_ACTUALIZA_DDAS_NVO(RAMO         VARCHAR2,
                                   AMPARO       VARCHAR2,
                                   SINIESTRO    NUMBER,
                                   SOLICITUD    NUMBER,
                                   CONCEPTO     VARCHAR2,
                                   VR_PGDO_CIA  NUMBER,
                                   VLOR_CNSTTDO NUMBER,
                                   VLOR_AFNZDO  NUMBER);
                                   
  PROCEDURE PRC_BORRA_RCPRCNES(P_SOLICITUD   NUMBER,
                               P_FECHA_MORA  DATE);
                               
  PROCEDURE PRC_BORRA_LQDCNES(P_SOLICITUD   NUMBER,
                              P_FECHA_MORA  DATE);                               

  PROCEDURE PRC_SUBSANAR(SOLICITUD      NUMBER,
                         FECHA_MORA     DATE,
                         SINIESTRO      NUMBER,
                         EST_SNSTRO     VARCHAR2,
                         POLIZA         NUMBER,
                         AMPARO         VARCHAR2,
                         RAMO           VARCHAR2,
                         CLASE          VARCHAR2,
                         F_OBJECION     DATE,
                         FECHA_DSCPCION DATE,
                         P_MENSAJE      OUT VARCHAR2);

END PKG_OBJETAR_SUBSANAR;
/