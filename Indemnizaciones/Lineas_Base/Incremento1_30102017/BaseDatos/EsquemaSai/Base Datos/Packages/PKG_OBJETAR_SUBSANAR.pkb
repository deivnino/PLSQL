CREATE OR REPLACE PACKAGE BODY admsisa.PKG_OBJETAR_SUBSANAR IS

  --
  --
  --
  FUNCTION FUN_CDGO_RECUP(CODIGO VARCHAR2) RETURN VARCHAR2 IS

    CncptoBase VARCHAR2(10);

  BEGIN
    SELECT VPR_VLOR_BSE
      INTO CncptoBase
      FROM VLRES_PRDCTO
     WHERE VPR_CDGO = CODIGO;
    RETURN(CncptoBase);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      CncptoBase := NULL;
      RETURN(CncptoBase);
    WHEN too_many_rows THEN
      RAISE_APPLICATION_ERROR(-20003,'Mas de un Concepto Base en VPR_VLOR_BSE para el concepto ' ||CODIGO);
  END FUN_CDGO_RECUP;
  
  FUNCTION FUN_EXISTE_PAGO(SOLICITUD NUMBER, SINIESTRO NUMBER)
    RETURN VARCHAR2 IS

    EXISTE NUMBER;

  BEGIN
    SELECT NVL(COUNT(8), 0)
      INTO EXISTE
      FROM LQDCNES, LQDCNES_DTLLE
     WHERE LQT_NMRO_SLCTUD = SOLICITUD
       AND LQT_NMRO_SNSTRO = SINIESTRO
       AND LQT_ESTDO_LQDCION = '03'
       AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
       AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
       AND LQD_PRDO = LQT_PRDO;

    IF NVL(EXISTE, 0) = 0 THEN
      RETURN('N');
    ELSE
      RETURN('S');
    END IF;

  END FUN_EXISTE_PAGO;

  --
  --
  --
  FUNCTION FUN_NUMERO_SINIESTRO(ACCION VARCHAR2) RETURN NUMBER IS

    SINIESTRO_NEW NUMBER;

  BEGIN
    -- SE CAMBIO POR LA FUNCION PORQUE EN LAS PRUEBAS DE PAGOS ANTICIPADOS SE QUEDABA PEGADO
    -- EL NUMERO DE SINIESTRO Y NO LO ACTUALIZABA GGM. 16/07/2012

    IF ACCION = 'S' THEN
      SINIESTRO_NEW := F_NMRCION_SNSTROS('12');
      RETURN SINIESTRO_NEW;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 1;
      RAISE_APPLICATION_ERROR(-20004,'Error tomando numracion siniestro en la tabla NMRCION_SNSTROS ' ||SQLERRM);
  END FUN_NUMERO_SINIESTRO;

  --
  --
  --
  FUNCTION FUN_CONSULTA_PERIODO(AMPARO         VARCHAR2,
                                POLIZA         NUMBER,
                                RAMO           VARCHAR2,
                                CLASE          VARCHAR2,
                                FECHA_OBJECION DATE,
                                F_SUBSANACION  DATE) RETURN VARCHAR IS

    Periodo    prmtros.par_rfrncia%TYPE;
    PeriodoSub prmtros.par_rfrncia%TYPE;
    LimPago    DATE;

  BEGIN
    BEGIN
      SELECT MIN(FPG_FCHA_PGO)
        INTO V_FECHA_PAGO
        FROM FCHAS_PGO
       WHERE FPG_ESTDO = 'V';
    EXCEPTION
             WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20005,'Error consultando mínima fecha de pago ' || SQLERRM);
    END;

    PERIODO      := TO_CHAR(V_FECHA_PAGO, 'MMYYYY');
    LIMPAGO      := PKG_SINIESTROS.FUN_FECHA_POLIZA(POLIZA, CLASE, RAMO);
    FECHA_POLIZA := LIMPAGO;
    PERIODOSUB   := TO_CHAR(FECHA_OBJECION, 'MMYYYY');

    IF AMPARO = '01' AND Periodo = PeriodoSub AND TO_CHAR(F_SUBSANACION,'MMYYYY') = TO_CHAR(LimPago,'MMYYYY') THEN
      RETURN 'PERIODO1';
    ELSIF AMPARO = '01' AND Periodo = PeriodoSub AND TO_CHAR(FECHA_OBJECION,'MMYYYY') = TO_CHAR(F_SUBSANACION, 'MMYYYY') THEN
       RETURN 'PERIODO1';
    ELSIF AMPARO = '01' AND TO_CHAR(F_SUBSANACION, 'MMYYYY')= TO_CHAR(V_FECHA_PAGO, 'MMYYYY') THEN
      IF To_char(Add_months(FECHA_OBJECION, 1), 'MMYYYY') = TO_CHAR(V_FECHA_PAGO, 'MMYYYY') THEN
        RETURN 'PERIODO2';
      ELSE
        Raise_application_error(-20006,'Se ha superado el limite de periodos para subsanar. <Verifique> ');
      END IF;
    ELSIF AMPARO = '01' THEN
      PeriodoSub := To_char(Add_months(FECHA_OBJECION, 1), 'MMYYYY');
      IF Periodo = PeriodoSub AND TO_CHAR(F_SUBSANACION, 'MMYYYY') = TO_CHAR(LIMPAGO, 'MMYYYY') THEN
        RETURN 'PERIODO2';
      ELSE
        Raise_application_error(-20006,'Se ha superado el limite de periodos para subsanar. <Verifique> ');
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20007,'Error al consultar ConsultaPeriodo. ' ||SQLERRM);

  END FUN_CONSULTA_PERIODO;

  --
  -- 5
  --
  FUNCTION FUN_NMRO_MESES(FECHA_MORA DATE) RETURN NUMBER IS

    L_FECHA DATE;
    L_MESES NUMBER;
    SUMA    NUMBER;

  BEGIN

    IF TO_CHAR(FECHA_MORA, 'DD') = '01' THEN
      L_FECHA      := LAST_DAY(V_FECHA_PAGO);
      N_FECHA_MORA := ADD_MONTHS(L_FECHA, -2) + 1;
    ELSE
      L_FECHA      := TO_DATE(TO_CHAR(FECHA_MORA, 'DD') ||TO_CHAR(V_FECHA_PAGO, 'MMYYYY'),'DD/MM/YYYY');
      N_FECHA_MORA := ADD_MONTHS(L_FECHA, -2);
    END IF;

    IF FECHA_MORA = N_FECHA_MORA THEN
      N_FECHA_MORA := ADD_MONTHS(N_FECHA_MORA, 1);
    END IF;

    L_MESES := ROUND(MONTHS_BETWEEN(L_FECHA, FECHA_MORA), 0);

    IF L_MESES >= 3 THEN
      SUMA := 2;
    ELSIF L_MESES = 2 THEN
      SUMA := 1;
    ELSE
      SUMA := 1;
    END IF;

    RETURN(SUMA);

  END FUN_NMRO_MESES;

  --
  -- 6
  --
  FUNCTION FUN_AMNTOS(SINIESTRO NUMBER, CONCEPTO VARCHAR2) RETURN VARCHAR2 IS

    VALOR NUMBER;

  BEGIN
    SELECT COUNT(8)
      INTO VALOR
      FROM AMNTOS_SNSTROS
     WHERE AMN_NMRO_SNSTRO = SINIESTRO
       AND AMN_CNCPTO = CONCEPTO
       AND AMN_FCHA_AMNTO != AMN_FCHA_MRA;

    IF NVL(VALOR, 0) = 0 THEN
      RETURN('N');
    ELSE
      RETURN('S');
    END IF;

  END FUN_AMNTOS;

  --
  --
  --
  FUNCTION FUN_BORRA_RCPRCNES(SOLICITUD  NUMBER,
                              SINIESTRO  NUMBER) RETURN VARCHAR2 IS


  VALOR_SIN   NUMBER;
  VALOR_REC   NUMBER;
  BORRAR      VARCHAR2(1);

  BEGIN
    SELECT SUM(VLD_VLOR_CNSTTDO)
      INTO VALOR_REC
      FROM VLRES_DDAS
     WHERE VLD_NMRO_SLCTUD = SOLICITUD
       AND VLD_NMRO_SNSTRO = SINIESTRO
       AND VLD_CNCPTO_VLOR LIKE 'RM%'
       AND VLD_VLOR_PGDO_AFNZDO = 0;

    SELECT SUM(VLD_VLOR_CNSTTDO) - SUM(VLD_VLOR_PGDO_AFNZDO)
      INTO VALOR_SIN
      FROM VLRES_DDAS, VLRES_PRDCTO
     WHERE VLD_NMRO_SLCTUD = SOLICITUD
       AND VLD_NMRO_SNSTRO = SINIESTRO
       AND VLD_CNCPTO_VLOR = VPR_CDGO
       AND VPR_ESTDO_CNTA = 'S';

    IF NVL(VALOR_SIN,0) = NVL(VALOR_REC,0) THEN
      BORRAR := 'S';
    ELSE
      BORRAR := 'N';
    END IF;
    RETURN(BORRAR);

  END FUN_BORRA_RCPRCNES;

  --
  --
  --
  FUNCTION FUN_FECHA_PROXIMA(P_SOLICITUD   NUMBER,
                             P_SINIESTRO   NUMBER,
                             P_FECHA_PAGO  DATE) RETURN VARCHAR2 IS
  EXISTE   NUMBER;

  BEGIN
    SELECT COUNT(8)
      INTO EXISTE
      FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, VLRES_PRDCTO
     WHERE LQT_NMRO_SLCTUD = P_SOLICITUD
       AND LQT_NMRO_SNSTRO = P_SINIESTRO
       AND LQD_FCHA_PGO > P_FECHA_PAGO
       AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
       AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
       AND LQD_PRDO = LQT_PRDO
       AND LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
       AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
       AND LQT_PRDO = VLQ_PRDO
       AND LQT_SERIE = VLQ_SERIE
       AND VLQ_CNCPTO_VLOR = VPR_CDGO
       AND VPR_ESTDO_CNTA = 'S';
    IF NVL(EXISTE,0) = 0 THEN
      RETURN('N');
    ELSE
      RETURN('S');
    END IF;

  END FUN_FECHA_PROXIMA;

  --
  -- 7
  --
  FUNCTION FUN_VALIDA_PAGO(SOLICITUD NUMBER, FECHA_MORA  DATE, CONCEPTO  VARCHAR2) RETURN VARCHAR2 IS

  VALOR      NUMBER;
  VALOR_SIN  NUMBER;
  CODIGO     VARCHAR2(6);

  BEGIN
    BEGIN
      SELECT VLD_VLOR_PGDO_AFNZDO
        INTO VALOR_SIN
        FROM VLRES_DDAS
       WHERE VLD_NMRO_SLCTUD = SOLICITUD
         AND VLD_FCHA_MRA = FECHA_MORA
         AND VLD_CNCPTO_VLOR = CONCEPTO;
    EXCEPTION
      WHEN OTHERS THEN
        VALOR_SIN := 0;
    END;

    CODIGO := FUN_CDGO_RECUP(CONCEPTO);

    BEGIN
      SELECT VLD_VLOR_PGDO_AFNZDO
        INTO VALOR
        FROM VLRES_DDAS
       WHERE VLD_NMRO_SLCTUD = SOLICITUD
         AND VLD_FCHA_MRA = FECHA_MORA
         AND VLD_CNCPTO_VLOR = CODIGO;
    EXCEPTION
      WHEN OTHERS THEN
        VALOR := 0;
    END;

    IF NVL(VALOR_SIN,0) > 0 AND NVL(VALOR,0) = 0 THEN
      RETURN('S');
    ELSE
      RETURN('N');
    END IF;

  END FUN_VALIDA_PAGO;

  --
  -- 7
  --
  FUNCTION FUN_VALIDA_PAGO_MAYOR(SOLICITUD NUMBER, FECHA_MORA  DATE,CONCEPTO  VARCHAR2) RETURN VARCHAR2 IS

  VALOR      NUMBER;
  VALOR_C    NUMBER;
  CODIGO     VARCHAR2(6);

  BEGIN
    CODIGO := FUN_CDGO_RECUP(CONCEPTO);

    BEGIN
      SELECT VLD_VLOR_PGDO_AFNZDO,VLD_VLOR_CNSTTDO
        INTO VALOR, VALOR_C
        FROM VLRES_DDAS
       WHERE VLD_NMRO_SLCTUD = SOLICITUD
         AND VLD_FCHA_MRA = FECHA_MORA
         AND VLD_CNCPTO_VLOR = CODIGO;
    EXCEPTION
      WHEN OTHERS THEN
        VALOR   := 0;
        VALOR_C := 0;
    END;

    IF NVL(VALOR,0) > NVL(VALOR_C,0) THEN
      RETURN('S');
    ELSE
      RETURN('N');
    END IF;

  END FUN_VALIDA_PAGO_MAYOR;

  --
  -- 8
  --
  PROCEDURE PRC_ESTADOS_SNSTRO(SINIESTRO     NUMBER,
                               ESTADO_SNSTRO OUT VARCHAR2,
                               ESTADO_PAGO   OUT VARCHAR2) IS

  BEGIN
    SELECT SNA_ESTDO_SNSTRO, SNA_ESTDO_PGO
      INTO ESTADO_SNSTRO, ESTADO_PAGO
      FROM AVSOS_SNSTROS
     WHERE SNA_NMRO_SNSTRO = SINIESTRO;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20008,'Error consultando el estado del siniestro' ||sqlerrm);

  END PRC_ESTADOS_SNSTRO;

  --
  -- 9
  --
  PROCEDURE PRC_CALCULA_VALOR(SINIESTRO NUMBER,
                              CONCEPTO  VARCHAR2,
                              VALOR     OUT NUMBER,
                              VALOR_ANT OUT NUMBER,
                              FECHA     OUT DATE) IS

    CURSOR C_AMNTOS IS
      SELECT TRUNC(AMN_FCHA_AMNTO) FECHA, TRUNC(AMN_FCHA_MRA) AMN_FCHA_MRA, SUM(AMN_VLOR) VALOR
        FROM AMNTOS_SNSTROS
       WHERE AMN_NMRO_SNSTRO = SINIESTRO
         AND AMN_CNCPTO = CONCEPTO
       GROUP BY TRUNC(AMN_FCHA_AMNTO) , TRUNC(AMN_FCHA_MRA)
       ORDER BY TRUNC(AMN_FCHA_AMNTO);

    R_AMNTOS C_AMNTOS%ROWTYPE;

  BEGIN
    OPEN C_AMNTOS;
    LOOP
      FETCH C_AMNTOS
        INTO R_AMNTOS;
      IF C_AMNTOS%NOTFOUND THEN
        EXIT;
      END IF;

      IF TRUNC(R_AMNTOS.FECHA) = TRUNC(R_AMNTOS.AMN_FCHA_MRA) THEN
        FECHA     := R_AMNTOS.AMN_FCHA_MRA;
        VALOR_ANT := R_AMNTOS.VALOR;
        VALOR     := R_AMNTOS.VALOR;
      ELSE
        FECHA     := R_AMNTOS.FECHA;
        VALOR_ANT := NVL(VALOR, 0);
        VALOR     := NVL(VALOR, 0) + R_AMNTOS.VALOR;
      END IF;

    END LOOP;
    CLOSE C_AMNTOS;

  END PRC_CALCULA_VALOR;

  --
  -- 10
  --
  PROCEDURE PRC_CAMBIA_ESTDO_SNSTRO(RAMO      VARCHAR2,
                                    SINIESTRO NUMBER,
                                    EST_PAGO  VARCHAR2) IS
  BEGIN
    UPDATE AVSOS_SNSTROS
       SET SNA_ESTDO_PGO  = EST_PAGO,
           SNA_FCHA_ESTDO = SYSDATE,
           SNA_USRIO      = LOWER(USER)
     WHERE SNA_RAM_CDGO = RAMO
       AND SNA_NMRO_SNSTRO = SINIESTRO;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20009,'Error actualizando el estado en AVSOS_SNSTROS ' || SQLERRM);

  END PRC_CAMBIA_ESTDO_SNSTRO;

  --
  -- 11
  --
  PROCEDURE PRC_CAMBIAR_OBJCION(RAMO      VARCHAR2,
                                SINIESTRO NUMBER,
                                AMPARO    VARCHAR2) IS
  BEGIN
    UPDATE OBJCNES_SNSTROS
       SET OBS_FCHA_SBSNCION = TRUNC(SYSDATE), OBS_SUBSANA = 'S'
     WHERE OBS_CDGO_AMPRO = AMPARO
       AND OBS_NMRO_SNSTRO = SINIESTRO
       AND OBS_RAM_CDGO = RAMO
       AND OBS_FCHA_SBSNCION IS NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20013,'Error actualizando el estado en OBJCNES_SNSTROS ' ||SQLERRM);
  END PRC_CAMBIAR_OBJCION;

  --
  -- 12
  --
  PROCEDURE PRC_INSERT_VLRES_DDAS_TMP(RAMO      VARCHAR2,
                                      SINIESTRO NUMBER,
                                      SOLICITUD NUMBER,
                                      OBJETA    VARCHAR2) IS
  EXISTE   NUMBER;
  
  BEGIN
    IF OBJETA = 'S' THEN
      BEGIN
        INSERT INTO VLRES_DDAS_TMP
          SELECT *
            FROM VLRES_DDAS
           WHERE VLD_RAM_CDGO = RAMO
             AND VLD_NMRO_SNSTRO = SINIESTRO
             AND VLD_NMRO_SLCTUD = SOLICITUD;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20014,'Error insertando en la tabla VLRES_DDAS_TMP - ' || SQLERRM);
      END;
    ELSE
      --MANTIS 56162 ACTUALIZAR LA LIQUIDACION
      SELECT COUNT(8)
        INTO EXISTE 
        FROM VLRES_DDAS_TMP
       WHERE VLD_RAM_CDGO = RAMO
         AND VLD_NMRO_SNSTRO = SINIESTRO
         AND VLD_NMRO_SLCTUD = SOLICITUD;
      IF NVL(EXISTE,0) > 0 THEN  
        DELETE VLRES_DDAS_TMP
         WHERE VLD_RAM_CDGO = RAMO
           AND VLD_NMRO_SNSTRO = SINIESTRO
           AND VLD_NMRO_SLCTUD = SOLICITUD;
        IF SQL%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(-20014,'Error eliminando en la tabla VLRES_DDAS_TMP - ' || SQLERRM);
        END IF;
      END IF;
    END IF;

  END PRC_INSERT_VLRES_DDAS_TMP;

  --
  -- 13
  --
  PROCEDURE PRC_CAMBIA_CONCEPTOS(RAMO       VARCHAR2,
                                 AMPARO     VARCHAR2,
                                 SINIESTRO  NUMBER,
                                 SOLICITUD  NUMBER,
                                 CONCEPTO   VARCHAR2,
                                 VR_CNSTTDO NUMBER,
                                 VR_AFNZDO  NUMBER,
                                 MENSAJE    OUT VARCHAR2) IS

    vCodgRecup VARCHAR2(10);

  BEGIN
    vCodgRecup := FUN_CDGO_RECUP(CONCEPTO); --,Objeta);
    IF vCodgRecup IS NOT NULL AND VR_AFNZDO = 0 THEN
      BEGIN
        UPDATE VLRES_DDAS
           SET VLD_CNCPTO_VLOR = vCodgRecup
         WHERE VLD_RAM_CDGO = RAMO
           AND VLD_CDGO_AMPRO = AMPARO
           AND VLD_NMRO_SNSTRO = SINIESTRO
           AND VLD_NMRO_SLCTUD = SOLICITUD
           AND VLD_CNCPTO_VLOR = CONCEPTO;
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -1 THEN
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO +
                                        (VR_CNSTTDO - VR_AFNZDO)
               WHERE VLD_RAM_CDGO = RAMO
                 AND VLD_CDGO_AMPRO = AMPARO
                 AND VLD_NMRO_SNSTRO = SINIESTRO
                 AND VLD_NMRO_SLCTUD = SOLICITUD
                 AND VLD_CNCPTO_VLOR = vCodgRecup;
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := SQLERRM || CONCEPTO;
                RETURN;
            END;
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VR_AFNZDO
               WHERE VLD_RAM_CDGO = RAMO
                 AND VLD_CDGO_AMPRO = AMPARO
                 AND VLD_NMRO_SNSTRO = SINIESTRO
                 AND VLD_NMRO_SLCTUD = SOLICITUD
                 AND VLD_CNCPTO_VLOR = CONCEPTO;
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := TO_CHAR(SQLCODE) || SQLERRM || CONCEPTO;
                RETURN;
            END;
          ELSE
            MENSAJE := TO_CHAR(SQLCODE) || SQLERRM || CONCEPTO;
            RETURN;
          END IF;
      END;
    ELSIF vCodgRecup IS NOT NULL AND VR_AFNZDO > 0 THEN
      BEGIN
        INSERT INTO VLRES_DDAS
          SELECT VLD_NMRO_SLCTUD,
                 VLD_FCHA_MRA,
                 VLD_RAM_CDGO,
                 vCodgRecup,
                 VLD_NMRO_SNSTRO,
                 VLD_CDGO_AMPRO,
                 VLD_VLOR_PGDO_CIA,
                 (VR_CNSTTDO - VR_AFNZDO),
                 0,
                 VLD_USRIO,
                 VLD_FCHA_MDFCCION,
                 VLD_ORGEN,
                 VLD_NMRO_PGOS
            FROM VLRES_DDAS
           WHERE VLD_RAM_CDGO = RAMO
             AND VLD_CDGO_AMPRO = AMPARO
             AND VLD_NMRO_SNSTRO = SINIESTRO
             AND VLD_NMRO_SLCTUD = SOLICITUD
             AND VLD_CNCPTO_VLOR = CONCEPTO;

        UPDATE VLRES_DDAS
           SET VLD_VLOR_CNSTTDO = VR_AFNZDO
         WHERE VLD_RAM_CDGO = RAMO
           AND VLD_CDGO_AMPRO = AMPARO
           AND VLD_NMRO_SNSTRO = SINIESTRO
           AND VLD_NMRO_SLCTUD = SOLICITUD
           AND VLD_CNCPTO_VLOR = CONCEPTO;
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -1 THEN
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO + (VR_CNSTTDO - VR_AFNZDO)
               WHERE VLD_RAM_CDGO = RAMO
                 AND VLD_CDGO_AMPRO = AMPARO
                 AND VLD_NMRO_SNSTRO = SINIESTRO
                 AND VLD_NMRO_SLCTUD = SOLICITUD
                 AND VLD_CNCPTO_VLOR = vCodgRecup;
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := SQLERRM || CONCEPTO;
                RETURN;
            END;
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VR_AFNZDO
               WHERE VLD_RAM_CDGO = RAMO
                 AND VLD_CDGO_AMPRO = AMPARO
                 AND VLD_NMRO_SNSTRO = SINIESTRO
                 AND VLD_NMRO_SLCTUD = SOLICITUD
                 AND VLD_CNCPTO_VLOR = CONCEPTO;
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := TO_CHAR(SQLCODE) || SQLERRM ||CONCEPTO;
                RETURN;
            END;
          ELSE
            MENSAJE := TO_CHAR(SQLCODE) || SQLERRM || CONCEPTO;
            RETURN;
          END IF;
      END;
    END IF;
  END PRC_CAMBIA_CONCEPTOS;

  --
  -- 14
  --
  PROCEDURE PRC_SUSPENDE_LQDCION(SINIESTRO NUMBER, RAMO VARCHAR2) IS

  EXISTE   NUMBER;
  
  BEGIN
    UPDATE LQDCNES_DTLLE
       SET LQT_ESTDO_LQDCION = '02'
     WHERE LQT_NMRO_SNSTRO = SINIESTRO
       AND LQT_RAM_CDGO = RAMO
       AND EXISTS (SELECT *
              FROM VLRES_LQDCION, VLRES_PRDCTO P
             WHERE LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
               AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
               AND LQT_PRDO = VLQ_PRDO
               AND LQT_SERIE = VLQ_SERIE
               AND VPR_CDGO = VLQ_CNCPTO_VLOR
               AND P.VPR_ESTDO_CNTA = 'S');
               
    -- MANTIS 56957 GGM. 24/08/2017           
    SELECT COUNT(8)
      INTO EXISTE
      FROM LQDCNES_DTLLE,VLRES_LQDCION, VLRES_PRDCTO P
     WHERE LQT_NMRO_SNSTRO = SINIESTRO
       AND LQT_RAM_CDGO = RAMO
       AND LQT_ESTDO_LQDCION = '02'
       AND LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
       AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
       AND LQT_PRDO = VLQ_PRDO
       AND LQT_SERIE = VLQ_SERIE
       AND VPR_CDGO = VLQ_CNCPTO_VLOR
       AND P.VPR_ESTDO_CNTA = 'S';
    IF NVL(EXISTE,0) = 0 THEN
      RAISE_APPLICATION_ERROR(-20021,'Error actualizando la liquidación en suspendido ' || SQLERRM);
    END IF;
               
    IF SQL%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(-20021,'Error actualizando la liquidación en suspendido ' || SQLERRM);
    END IF;

  END PRC_SUSPENDE_LQDCION;

  --
  -- 15
  --
  PROCEDURE PRC_BORRA_DDCCIONES(SOLICITUD NUMBER, FECHA_MORA DATE) IS

    CURSOR C_DDCCNES IS
      SELECT *
        FROM DDCCNES_AUTMTCAS
       WHERE DAU_NMRO_SLCTUD = SOLICITUD
         AND DAU_FCHA_MRA = FECHA_MORA;

    R_DDCCNES C_DDCCNES%ROWTYPE;
    CODIGO    VARCHAR2(10);

  BEGIN
    OPEN C_DDCCNES;
    LOOP
      FETCH C_DDCCNES
        INTO R_DDCCNES;
      IF C_DDCCNES%NOTFOUND THEN
        EXIT;
      END IF;

      CODIGO := FUN_CDGO_RECUP(R_DDCCNES.DAU_CNCPTO_VLOR);

      UPDATE VLRES_DDAS
         SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO - R_DDCCNES.DAU_VLOR
       WHERE VLD_NMRO_SLCTUD = SOLICITUD
         AND VLD_FCHA_MRA = FECHA_MORA
         AND VLD_CNCPTO_VLOR = CODIGO;

    END LOOP;
    CLOSE C_DDCCNES;

    BEGIN
      DELETE DDCCNES_AUTMTCAS
       WHERE DAU_NMRO_SLCTUD = SOLICITUD
         AND DAU_FCHA_MRA = FECHA_MORA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20022,'Error borrando las deducciones del siniestros ' ||SQLERRM);
    END;

    BEGIN
      DELETE VLRES_LQDCION
       WHERE VLQ_ORGEN = 'C'
         AND VLQ_NMRO_SLCTUD = SOLICITUD
         AND EXISTS (SELECT *
                FROM LQDCNES_DTLLE
               WHERE LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
                 AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
                 AND LQT_PRDO = VLQ_PRDO
                 AND LQT_SERIE = VLQ_SERIE
                 AND LQT_FCHA_MRA = FECHA_MORA);

      DELETE LQDCNES_DTLLE
       WHERE LQT_NMRO_SLCTUD = SOLICITUD
         AND LQT_FCHA_MRA = FECHA_MORA
         AND NOT EXISTS (SELECT *
                FROM VLRES_LQDCION
               WHERE LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
                 AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
                 AND LQT_PRDO = VLQ_PRDO
                 AND LQT_SERIE = VLQ_SERIE);
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20023,'Error borrando las liquidaciones de las deducciones ' || SQLERRM);
    END;
  END PRC_BORRA_DDCCIONES;

  --
  -- 16
  --
  PROCEDURE PRC_OBJETAR(SOLICITUD     NUMBER,
                        SINIESTRO     NUMBER,
                        FECHA_MORA    DATE,
                        AMPARO        VARCHAR2,
                        RAMO          VARCHAR2,
                        ESTADO_SNSTRO VARCHAR2,
                        DEDUCCION     NUMBER,
                        ESTDO_PGO     VARCHAR2,
                        OBJETA        VARCHAR2,
                        MENSAJE       OUT VARCHAR2) IS

    CURSOR C_VLRES_DDAS IS
      SELECT VLD_NMRO_SLCTUD,
             VLD_FCHA_MRA,
             VLD_RAM_CDGO,
             VLD_CNCPTO_VLOR,
             VLD_NMRO_SNSTRO,
             VLD_CDGO_AMPRO,
             VLD_VLOR_PGDO_CIA,
             VLD_VLOR_CNSTTDO,
             VLD_VLOR_PGDO_AFNZDO,
             VLD_USRIO,
             VLD_FCHA_MDFCCION,
             VLD_ORGEN,
             VLD_NMRO_PGOS
        FROM VLRES_DDAS
       WHERE VLD_RAM_CDGO = RAMO
         AND VLD_CDGO_AMPRO = AMPARO
         AND VLD_NMRO_SNSTRO = SINIESTRO
         AND VLD_NMRO_SLCTUD = SOLICITUD;

    R_VLRES_DDAS C_VLRES_DDAS%ROWTYPE;
    V_MENSAJE    VARCHAR2(1000);
    
  BEGIN
    BEGIN
      PRC_CAMBIA_ESTDO_SNSTRO(RAMO, SINIESTRO, ESTDO_PGO);
      BEGIN
        PRC_INSERT_VLRES_DDAS_TMP(RAMO, SINIESTRO, SOLICITUD, OBJETA);
        BEGIN
          PRC_SUSPENDE_LQDCION(SINIESTRO, RAMO);
          OPEN C_VLRES_DDAS;
          LOOP
            FETCH C_VLRES_DDAS
              INTO R_VLRES_DDAS;
            IF C_VLRES_DDAS%NOTFOUND THEN
              EXIT;
            END IF;
              
            PRC_CAMBIA_CONCEPTOS(RAMO,
                                 AMPARO,
                                 SINIESTRO,
                                 SOLICITUD,
                                 R_VLRES_DDAS.Vld_Cncpto_Vlor,
                                 R_VLRES_DDAS.VLD_VLOR_CNSTTDO,
                                 R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO,
                                 V_MENSAJE);
            IF V_MENSAJE IS NOT NULL THEN
              MENSAJE := 'Error en PRC_CAMBIA_CONCEPTOS..  '||V_MENSAJE;
              RETURN;
            END IF;

          END LOOP;
          CLOSE C_VLRES_DDAS;
          
          IF DEDUCCION > 0 THEN
            BEGIN
              PRC_BORRA_DDCCIONES(SOLICITUD, FECHA_MORA);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'Error en PRC_BORRA_DDCCIONES..'||SQLERRM;
                RETURN;
            END;  
          END IF;

          IF ESTADO_SNSTRO = '05' THEN
            BEGIN
              UPDATE ORDNES_PGO O
                 SET O.OPG_ESTDO_PGO = '03'
               WHERE O.OPG_NMRO_SLCTUD = SOLICITUD
                 AND O.OPG_NMRO_SNSTRO = SINIESTRO
                 AND O.opg_fcha_estdo =
                     (SELECT MAX(OD.OPG_FCHA_ESTDO)
                        FROM ordnes_pgo OD
                       WHERE OD.OPG_NMRO_SLCTUD = O.OPG_NMRO_SLCTUD
                         AND OD.OPG_NMRO_SNSTRO = O.OPG_NMRO_SNSTRO);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'Error actualizando en la tabla ORDNES_PGO..' ||SQLERRM;
                RETURN;
            END;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'Error en PRC_SUSPENDE_LQDCION..'||SQLERRM;
            RETURN;
        END; 
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE := 'Error en PRC_INSERT_VLRES_DDAS_TMP..'||SQLERRM;
          RETURN;
      END; 
    EXCEPTION
      WHEN OTHERS THEN
        MENSAJE := 'Error en PRC_CAMBIA_ESTDO_SNSTRO..'||SQLERRM;
        RETURN;
    END; 
    
  END PRC_OBJETAR;

  --
  -- 17
  --
  PROCEDURE PRC_CAMBIAR_ESTDO_LQDCION(SINIESTRO NUMBER,
                                      ESTADO    VARCHAR2,
                                      SOLICITUD NUMBER) IS
  V_FECHA   DATE;
  
  BEGIN
    -- MANTIS 56162 ACTUALIZAR LA LIQUIDACION
    BEGIN
      SELECT DISTINCT LQD_FCHA_PGO
        INTO V_FECHA
        FROM LQDCNES,LQDCNES_DTLLE,VLRES_LQDCION,VLRES_PRDCTO
       WHERE LQT_NMRO_SLCTUD = SOLICITUD
         AND LQT_NMRO_SNSTRO = SINIESTRO
         AND LQT_ESTDO_LQDCION = '02'
         AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
         AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
         AND LQD_PRDO = LQT_PRDO
         AND LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
         AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
         AND LQT_PRDO = VLQ_PRDO
         AND LQT_SERIE = VLQ_SERIE
         AND VLQ_CNCPTO_VLOR = VPR_CDGO
         AND VPR_ESTDO_CNTA = 'S';         

      UPDATE LQDCNES_DTLLE
         SET LQT_ESTDO_LQDCION = ESTADO
       WHERE LQT_NMRO_SLCTUD = SOLICITUD
         AND LQT_NMRO_SNSTRO = SINIESTRO
         AND LQT_ESTDO_LQDCION NOT IN ('01', '03')
         AND EXISTS (SELECT * FROM LQDCNES,VLRES_LQDCION,VLRES_PRDCTO
                      WHERE LQD_FCHA_PGO = V_FECHA
                        AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
                        AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
                        AND LQD_PRDO = LQT_PRDO
                        AND LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
                        AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
                        AND LQT_PRDO = VLQ_PRDO
                        AND LQT_SERIE = VLQ_SERIE
                        AND VLQ_CNCPTO_VLOR = VPR_CDGO
                        AND VPR_ESTDO_CNTA = 'S');
      IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20025,'Error actualizando el estado de la liquidación en la tabla LQDCNES_DTLLE ' ||SQLERRM);
      END IF;
      
      IF V_FECHA < V_FECHA_PAGO THEN
        UPDATE LQDCNES
           SET LQD_FCHA_PGO = V_FECHA_PAGO
         WHERE LQD_NMRO_SLCTUD = SOLICITUD
           AND EXISTS (SELECT * FROM LQDCNES_DTLLE,VLRES_LQDCION,VLRES_PRDCTO
                      WHERE LQT_NMRO_SNSTRO = SINIESTRO
                        AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
                        AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
                        AND LQD_PRDO = LQT_PRDO
                        AND LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
                        AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
                        AND LQT_PRDO = VLQ_PRDO
                        AND LQT_SERIE = VLQ_SERIE
                        AND VLQ_CNCPTO_VLOR = VPR_CDGO
                        AND VPR_ESTDO_CNTA = 'S');   
        IF SQL%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(-20025,'Error actualizando el estado de la liquidación en la tabla LQDCNES_DTLLE ' ||SQLERRM);
        END IF;   
      END IF;  
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20027,'No encontro liquidación para activar en tabla LQDCNES_DTLLE ' ||SQLERRM);
    END;  
        
  END PRC_CAMBIAR_ESTDO_LQDCION;

  --
  -- 18
  --
  PROCEDURE PRC_ACTUALIZA_FECHA(SOLICITUD  NUMBER,
                                FECHA_MORA DATE,
                                POLIZA     NUMBER,
                                CLASE      VARCHAR2,
                                RAMO       VARCHAR2,
                                SINIESTRO  NUMBER) IS

    V_FECHA DATE;
    S_FECHA DATE;
    PRDO    VARCHAR2(6);

  BEGIN
    V_FECHA := PKG_SINIESTROS.FUN_FECHA_PAGO(SOLICITUD,
                                             FECHA_MORA,
                                             POLIZA,
                                             CLASE,
                                             RAMO,
                                             PRDO);
    S_FECHA  := V_FECHA;
    IF TRUNC(V_FECHA) != TRUNC(V_FECHA_PAGO) THEN
      IF TO_CHAR(V_FECHA, 'MMYYYY') != TO_CHAR(V_FECHA_PAGO, 'MMYYYY') THEN
        V_FECHA := V_FECHA_PAGO;
      ELSE
        V_FECHA := V_FECHA;
      END IF;
    ELSE
      V_FECHA := V_FECHA;
    END IF;

    IF V_CAMBIA_FECHA = 'N' THEN
      BEGIN
        UPDATE LQDCNES
           SET LQD_FCHA_PGO = V_FECHA
         WHERE LQD_NMRO_SLCTUD = SOLICITUD
           AND EXISTS (SELECT *
                  FROM LQDCNES_DTLLE
                 WHERE LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
                   AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
                   AND LQD_PRDO = LQT_PRDO
                   AND LQT_NMRO_SNSTRO = SINIESTRO);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20027, 'Error actualizando la fecha de pago ' || SQLERRM);
      END;
    ELSE
      BEGIN
        UPDATE LQDCNES
           SET LQD_FCHA_PGO = V_FECHA
         WHERE LQD_NMRO_SLCTUD = SOLICITUD
           AND LQD_FCHA_PGO = S_FECHA
           AND EXISTS (SELECT *
                  FROM LQDCNES_DTLLE
                 WHERE LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
                   AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
                   AND LQD_PRDO = LQT_PRDO
                   AND LQT_NMRO_SNSTRO = SINIESTRO);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20028, 'Error actualizando la fecha de pago ' || SQLERRM);
      END;
    END IF;
  END PRC_ACTUALIZA_FECHA;

  --
  -- 19
  --
  PROCEDURE PRC_BORRA_LQDCNES_NGTVAS(SINIESTRO  NUMBER,
                                     RAMO       VARCHAR2,
                                     FECHA_PAGO DATE) IS

    CURSOR C_LQDCNES IS
      SELECT *
        FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION
       WHERE LQD_FCHA_PGO = FECHA_PAGO
         AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
         AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
         AND LQD_PRDO = LQT_PRDO
         AND LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
         AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
         AND LQT_PRDO = VLQ_PRDO
         AND LQT_SERIE = VLQ_SERIE
         AND LQT_NMRO_SNSTRO = SINIESTRO
         AND LQT_RAM_CDGO = RAMO
         AND VLQ_ORGEN IN ('G','A')
         AND VLQ_VLOR < 0;

    R_LQDCNES     C_LQDCNES%ROWTYPE;
    BORRAR        VARCHAR2(1);

  BEGIN
    OPEN C_LQDCNES;
    LOOP
      FETCH C_LQDCNES INTO R_LQDCNES;
      IF C_LQDCNES%NOTFOUND THEN
        EXIT;
      END IF;

      IF R_LQDCNES.VLQ_ORGEN = 'A' THEN
        IF FUN_VALIDA_PAGO(R_LQDCNES.LQD_NMRO_SLCTUD,R_LQDCNES.LQT_FCHA_MRA, R_LQDCNES.VLQ_CNCPTO_VLOR) = 'S' THEN
          BORRAR := 'S';
        ELSE
          IF BORRA = 'S' THEN
            BORRAR := 'S';
          ELSE
            BORRAR := 'N';
          END IF;
        END IF;
      ELSE
        BORRAR := 'S';
      END IF;

      IF BORRAR = 'S' THEN
        BEGIN
          DELETE VLRES_LQDCION
           WHERE VLQ_NMRO_SLCTUD = R_LQDCNES.VLQ_NMRO_SLCTUD
             AND VLQ_TPO_LQDCION = R_LQDCNES.VLQ_TPO_LQDCION
             AND VLQ_PRDO = R_LQDCNES.VLQ_PRDO
             AND VLQ_SERIE = R_LQDCNES.VLQ_SERIE
             AND VLQ_ORGEN = R_LQDCNES.VLQ_ORGEN
             AND VLQ_CNCPTO_VLOR = R_LQDCNES.VLQ_CNCPTO_VLOR
             AND (VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE) IN
                 (SELECT LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE
                    FROM LQDCNES, LQDCNES_DTLLE
                   WHERE LQT_NMRO_SNSTRO = SINIESTRO
                     AND LQT_RAM_CDGO = RAMO
                     AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
                     AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
                     AND LQD_PRDO = LQT_PRDO
                     AND LQD_FCHA_PGO = FECHA_PAGO);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20029,'Error al borrar en  VLRES_LQDCION  ' ||SQLERRM);
        END;

        BEGIN
          DELETE LQDCNES_DTLLE
           WHERE LQT_NMRO_SLCTUD = R_LQDCNES.LQT_NMRO_SLCTUD
             AND LQT_TPO_LQDCION = R_LQDCNES.LQT_TPO_LQDCION
             AND LQT_PRDO = R_LQDCNES.LQT_PRDO
             AND LQT_SERIE = R_LQDCNES.LQT_SERIE
             AND LQT_NMRO_SNSTRO = SINIESTRO
             AND LQT_RAM_CDGO = RAMO;
        EXCEPTION
          WHEN OTHERS THEN
            IF SQLCODE = -2292 THEN
              NULL;
            ELSE
              RAISE_APPLICATION_ERROR(-20030,SQLCODE||'  AQUI: Error al borrar en  LQDCNES_DTLLE ' ||SQLERRM);
            END IF;
        END;
      END IF;

    END LOOP;
    CLOSE C_LQDCNES;

    BEGIN
      UPDATE VLRES_DDAS
         SET VLD_VLOR_CNSTTDO = 0
       WHERE VLD_NMRO_SNSTRO = SINIESTRO
         AND VLD_RAM_CDGO = RAMO
         AND VLD_VLOR_CNSTTDO < 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20031,'Error al actualizar en VLRES_DDAS ' ||SQLERRM);
    END;

  END PRC_BORRA_LQDCNES_NGTVAS;

  --
  -- 20
  --
  PROCEDURE PRC_ACTUALIZA_VALOR_LQDCION(SINIESTRO  NUMBER,
                                        RAMO       VARCHAR2,
                                        SOLICITUD  NUMBER,
                                        FECHA_MORA DATE,
                                        CONCEPTO   VARCHAR2,
                                        PORCENTAJE NUMBER) IS
   V_PORCENTAJE     NUMBER;

  BEGIN
    V_PORCENTAJE := PORCENTAJE;
    -- Caso de prueba donde pagan todo por siniestro se obejta y desocupan con fecha menor a la hasta
    -- Debe pagar hasta la fecha de desocupación.
    IF V_PORCENTAJE = 0 THEN
      IF FUN_VALIDA_PAGO(SOLICITUD,FECHA_MORA,CONCEPTO) = 'S' THEN
        V_PORCENTAJE := 1;
      ELSE
        V_PORCENTAJE := PORCENTAJE;
      END IF;
    END IF;

    UPDATE VLRES_LQDCION
       SET VLQ_VLOR        = DECODE(RTRIM(VLQ_CNCPTO_VLOR),
                                    RTRIM(CONCEPTO),
                                    ROUND(VLQ_VLOR * V_PORCENTAJE, 2),
                                    VLQ_VLOR),
           VLQ_VLOR_ORGNAL = DECODE(VLQ_CNCPTO_VLOR,
                                    CONCEPTO,
                                    ROUND(VLQ_VLOR_ORGNAL * V_PORCENTAJE, 2),
                                    VLQ_VLOR_ORGNAL)
     WHERE VLQ_NMRO_SLCTUD = SOLICITUD
       AND VLQ_CNCPTO_VLOR = CONCEPTO
       AND (VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE) IN
           (SELECT LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE
              FROM LQDCNES_DTLLE
             WHERE LQT_NMRO_SNSTRO = SINIESTRO
               AND LQT_RAM_CDGO = RAMO);

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20032, 'Error al actualizar en  VLRES_LQDCION  ' || SQLERRM);

  END PRC_ACTUALIZA_VALOR_LQDCION;

  --
  -- 21
  --
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
                                N_FECHA_MRA    OUT DATE) IS

    CURSOR C_DDAS_TMP IS
      SELECT *
        FROM VLRES_DDAS_TMP
       WHERE VLD_NMRO_SLCTUD = SOLICITUD
         AND VLD_RAM_CDGO = RAMO
         AND VLD_CDGO_AMPRO = AMPARO
         AND VLD_NMRO_SNSTRO = SINIESTRO;


    R_DDAS_TMP       C_DDAS_TMP%ROWTYPE;
    NMRO_SNSTRO      NUMBER;
    ESTADO_PAGO      VARCHAR2(3);
    SUMA             NUMBER;
    EXISTE_RE01      NUMBER;
    EXISTE_RE02      NUMBER;
    VALOR_CUOTA_ACT  NUMBER;
    VALOR_CUOTA_ANT  NUMBER;
    VALOR_CANON_ACT  NUMBER;
    VALOR_CANON_ANT  NUMBER;
    FECHA            DATE;

  BEGIN
    SUMA        := FUN_NMRO_MESES(FECHA_MORA);
    N_FECHA_MRA := N_FECHA_MORA;
    NMRO_SNSTRO := FUN_NUMERO_SINIESTRO('S');
    N_SINIESTRO := NMRO_SNSTRO;

    BEGIN
      INSERT INTO DDAS_VGNTES_ARRNDMNTOS
        SELECT DVA_NMRO_SLCTUD,
               N_FECHA_MRA,
               DVA_DIAS_DSFSE + 30,
               DVA_VLOR_DSFSE,
               DVA_FCHA_DSCPCION,
               DVA_RPRTDO_CBRNZA,
               LOWER(USER),
               SYSDATE,
               DVA_FCHA_ULTMO_PGO,
               '01',
               NULL,
               NULL,
               NULL
          FROM DDAS_VGNTES_ARRNDMNTOS
         WHERE DVA_NMRO_SLCTUD = SOLICITUD
           AND DVA_FCHA_MRA = FECHA_MORA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20033,'Error insertando en la tabla  DDAS_VGNTES_ARRNDMNTOS ' ||SQLERRM);
    END;

    IF ESTADO_SNSTRO = '01' THEN
      ESTADO_PAGO := '00';
    ELSE
      ESTADO_PAGO := '04';
    END IF;

    BEGIN
      INSERT INTO AVSOS_SNSTROS
        SELECT SNA_NMRO_ITEM,
               NMRO_SNSTRO,
               SNA_CAUSA_SNSTRO,
               SNA_NMRO_PLZA,
               SNA_CLSE_PLZA,
               SNA_RAM_CDGO,
               SYSDATE,
               N_FECHA_MRA,
               SNA_VLOR_AVSDO,
               SNA_VLOR_CNSTTDO,
               SNA_VLOR_PGDO,
               SNA_ESTDO_SNSTRO,
               ESTADO_PAGO,
               SNA_VLOR_GSTOS,
               SNA_FCHA_ESTDO,
               SNA_VLOR_SLVMNTO_RCBRO,
               SNA_NMRO_CRTFCDO,
               LOWER(USER),
               SYSDATE,
               SNA_FCHA_ULTMO_PGO,
               SNA_DSCRPCION_ESTDO || ' NUEVO SINIESTRO POR SUBSANACION',
               SNA_TPO_CBRNZA,
               SNA_TPOID_CBRDOR,
               SNA_NMROID_CBRDOR,
               CLASIFICACION_CASO,
               FECHA_CLASIFICACION,
               SNA_SNSTRO_SIMON,
               SNA_ESTDO_ANTRIOR,
               SNA_NMRO_EXPDNTE,
               SNA_MCA_ESTDO,
               SNA_POLIZA_SIMON
          FROM AVSOS_SNSTROS
         WHERE SNA_NMRO_SNSTRO = SINIESTRO
           AND SNA_RAM_CDGO = RAMO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20034,'Error insertando en la tabla  AVSOS_SNSTROS ' ||SQLERRM);
    END;

    BEGIN
      INSERT INTO AMPROS_SNSTROS
        SELECT NMRO_SNSTRO,
               AMS_CDGO_AMPRO,
               AMS_RAM_CDGO,
               AMS_NMRO_ITEM,
               N_FECHA_MRA,
               AMS_NMRO_CRTFCDO,
               AMS_CDGO_CAUSA,
               AMS_VLOR_AVSDO,
               AMS_VLOR_CNSTTDO,
               AMS_VLOR_PGDO,
               AMS_ESTDO,
               LOWER(USER),
               SYSDATE
          FROM AMPROS_SNSTROS
         WHERE AMS_NMRO_SNSTRO = SINIESTRO
           AND AMS_RAM_CDGO = RAMO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20035,'Error insertando en la tabla  AMPROS_SNSTROS  ' ||SQLERRM);
    END;

    BEGIN
      INSERT INTO VLRES_SNSTROS
        SELECT VSN_CNCPTO_VLOR,
               NMRO_SNSTRO,
               VSN_CDGO_AMPRO,
               VSN_RAM_CDGO,
               VSN_LQDCION,
               VSN_VLOR_AVSDO,
               VSN_VLOR_CNSTTDO,
               VSN_FCHA_RPRTE,
               VSN_ESTDO,
               VSN_USRIO,
               VSN_FCHA_MDFCCION,
               VSN_PRDOS,
               VSN_FCHA_DSDE,
               VSN_FCHA_HSTA
          FROM VLRES_SNSTROS
         WHERE VSN_NMRO_SNSTRO = SINIESTRO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20036,'Error insertando en la tabla  VLRES_SNSTROS  ' ||SQLERRM);
    END;

  -- Inicio aumentos
  -- Se calcula el valor actual y anterior del canon y la cuota para insertar en aumentos
  -- con el último valor y el desface se deja el valor anterior.
  PRC_CALCULA_VALOR(SINIESTRO,'01',VALOR_CANON_ACT,VALOR_CANON_ANT,FECHA);
  PRC_CALCULA_VALOR(SINIESTRO,'02',VALOR_CUOTA_ACT,VALOR_CUOTA_ANT,FECHA);

  BEGIN
    INSERT INTO AMNTOS_SNSTROS
      VALUES(NMRO_SNSTRO,RAMO,AMPARO,N_FECHA_MRA,'01',VALOR_CANON_ACT,0,SOLICITUD,N_FECHA_MRA,
             USER,N_FECHA_MRA,NULL);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20037,'Error insertando en la tabla  AMNTOS_SNSTROS  ' || SQLERRM);
  END;

  BEGIN
    INSERT INTO AMNTOS_SNSTROS
      VALUES(NMRO_SNSTRO,RAMO,AMPARO,N_FECHA_MRA,'02',VALOR_CUOTA_ACT,0,SOLICITUD,N_FECHA_MRA,
             USER,N_FECHA_MRA,NULL);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20038,'Error insertando en la tabla  AMNTOS_SNSTROS  ' || SQLERRM);
  END;

  SELECT COUNT(8)
    INTO EXISTE_RE01
     FROM VLRES_DDAS
    WHERE VLD_RAM_CDGO = RAMO
      AND VLD_CDGO_AMPRO = AMPARO
      AND VLD_NMRO_SNSTRO = SINIESTRO
      AND VLD_NMRO_SLCTUD = SOLICITUD
      AND VLD_CNCPTO_VLOR = 'RE01';

    IF NVL(EXISTE_RE01,0) = 0 THEN
      IF NVL(VALOR_CANON_ANT,0) > 0 THEN
        BEGIN
          /*** Inserta o actualiza concepto de desface RE01 ***/
          INSERT INTO VLRES_DDAS
            SELECT VLD_NMRO_SLCTUD,
                   N_FECHA_MRA,
                   VLD_RAM_CDGO,
                   'RE01',
                   NMRO_SNSTRO,
                   VLD_CDGO_AMPRO,
                   0,
                   NVL(VALOR_CANON_ANT,0),  --NVL(VR_DESFACE,0),
                   0,
                   LOWER(USER),
                   SYSDATE,
                   VLD_ORGEN,
                   1
              FROM VLRES_DDAS
             WHERE VLD_RAM_CDGO = RAMO
               AND VLD_CDGO_AMPRO = AMPARO
               AND VLD_NMRO_SNSTRO = SINIESTRO
               AND VLD_NMRO_SLCTUD = SOLICITUD
               AND ROWNUM = 1;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20041,'Error Actualizando Concepto <<RE01>> en la tabla  VLRES_DDAS. ' ||SQLERRM);
        END;
      END IF;
    ELSE
      BEGIN
        UPDATE VLRES_DDAS
           SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO + NVL(VALOR_CANON_ANT,0),  --NVL(VR_DESFACE,0),
               VLD_FCHA_MRA     = N_FECHA_MRA,
               VLD_NMRO_SNSTRO  = NMRO_SNSTRO
         WHERE VLD_RAM_CDGO = RAMO
           AND VLD_CDGO_AMPRO = AMPARO
           AND VLD_NMRO_SNSTRO = SINIESTRO
           AND VLD_NMRO_SLCTUD = SOLICITUD
           AND VLD_CNCPTO_VLOR = 'RE01';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20042,'Error Actualizando Concepto <<RE01>> en la tabla  VLRES_DDAS. ' ||SQLERRM);
      END;
    END IF;

    IF NVL(VALOR_CUOTA_ANT,0) > 0 THEN  --NVL(VR_DESFACE_CUOTA, 0) > 0 THEN
      SELECT COUNT(8)
        INTO EXISTE_RE02
         FROM VLRES_DDAS
        WHERE VLD_RAM_CDGO = RAMO
          AND VLD_CDGO_AMPRO = AMPARO
          AND VLD_NMRO_SNSTRO = SINIESTRO
          AND VLD_NMRO_SLCTUD = SOLICITUD
          AND VLD_CNCPTO_VLOR = 'RE02';
      IF NVL(EXISTE_RE02,0) = 0 THEN
        BEGIN
          /*** Inserta o actualiza concepto de desface RE02 ***/
          INSERT INTO VLRES_DDAS
            SELECT VLD_NMRO_SLCTUD,
                   N_FECHA_MRA,
                   VLD_RAM_CDGO,
                   'RE02',
                   NMRO_SNSTRO,
                   VLD_CDGO_AMPRO,
                   0,
                   NVL(VALOR_CUOTA_ANT,0),  --NVL(VR_DESFACE_CUOTA,0),
                   0,
                   LOWER(USER),
                   SYSDATE,
                   VLD_ORGEN,
                   1
              FROM VLRES_DDAS
             WHERE VLD_RAM_CDGO = RAMO
               AND VLD_CDGO_AMPRO = AMPARO
               AND VLD_NMRO_SNSTRO = SINIESTRO
               AND VLD_NMRO_SLCTUD = SOLICITUD
               AND ROWNUM = 1;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20043,'Error Actualizando Concepto <<RE02>> en la tabla  VLRES_DDAS. ' ||SQLERRM);
        END;
      ELSE
        BEGIN
          UPDATE VLRES_DDAS
             SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO + NVL(VALOR_CUOTA_ANT,0), -- NVL(VR_DESFACE_CUOTA,0),
                 VLD_FCHA_MRA     = N_FECHA_MRA,
                 VLD_NMRO_SNSTRO  = NMRO_SNSTRO
           WHERE VLD_RAM_CDGO = RAMO
             AND VLD_CDGO_AMPRO = AMPARO
             AND VLD_NMRO_SNSTRO = SINIESTRO
             AND VLD_NMRO_SLCTUD = SOLICITUD
             AND VLD_CNCPTO_VLOR = 'RE02';
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20044,'Error Actualizando Concepto <<RE02>> en la tabla  VLRES_DDAS. ' ||SQLERRM);
        END;
      END IF;
    END IF;

    BEGIN
      UPDATE DDAS_VGNTES_ARRNDMNTOS
         SET DVA_VLOR_DSFSE = DVA_VLOR_DSFSE + (NVL(VALOR_CANON_ANT,0) + NVL(VALOR_CUOTA_ANT,0))  --(NVL(VR_DESFACE,0) + NVL(VR_DESFACE_CUOTA,0))
       WHERE DVA_NMRO_SLCTUD = SOLICITUD
         AND DVA_FCHA_MRA = N_FECHA_MRA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20045,'Error actualizando en la tabla  DDAS_VGNTES_ARRNDMNTOS ' || SQLERRM);
    END;

    BEGIN
      INSERT INTO DDAS_ARRNDTRIOS
        SELECT DAR_NMRO_SLCTUD,
               N_FECHA_MRA,
               DAR_TPO_ARRNDTRIO,
               DAR_TPO_IDNTFCCION,
               DAR_NMRO_IDNTFCCION,
               DAR_NMRO_PLZA,
               DAR_CLSE_PLZA,
               DAR_RAM_CDGO
          FROM DDAS_ARRNDTRIOS
         WHERE DAR_NMRO_SLCTUD = SOLICITUD
           AND DAR_FCHA_MRA = FECHA_MORA
           AND DAR_TPO_ARRNDTRIO <> 'arrendatario';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20046,'Error insertando en la tabla  DDAS_ARRNDTRIOS  ' ||SQLERRM);
    END;

    BEGIN
      INSERT INTO OBJCNES_SNSTROS
        SELECT O.OBS_CDGO_OBJCION,
               O.OBS_CDGO_AMPRO,
               NMRO_SNSTRO,
               O.OBS_RAM_CDGO,
               O.OBS_USRIO,
               O.OBS_FCHA_MDFCCION,
               O.OBS_FCHA_OBJCION,
               SYSDATE,
               'S',
               'SE SUBSANA GENERANDO UN NUEVO SINIESTRO',
               O.OBS_TPO
          FROM OBJCNES_SNSTROS O
         WHERE O.OBS_NMRO_SNSTRO = SINIESTRO
           AND O.OBS_RAM_CDGO = RAMO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20047,'Error insertando en la tabla  OBJCNES_SNSTROS  ' ||SQLERRM);
    END;

    BEGIN
      INSERT INTO CASOS_CBRNZA
        SELECT CSC_CDGO_CBRDOR,
               CSC_NMRO_SLCTUD,
               N_FECHA_MRA,
               CSC_FCHA_ASGNCION,
               CSC_FCHA_APRTRA,
               CSC_ESTDO_CBRANZA,
               CSC_TPO_CBRNZA,
               LOWER(USER),
               SYSDATE
          FROM CASOS_CBRNZA
         WHERE CSC_NMRO_SLCTUD = SOLICITUD
           AND CSC_FCHA_MRA = FECHA_MORA;
    EXCEPTION
      -- MANTIS #35264
       WHEN DUP_VAL_ON_INDEX THEN
         NULL;
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20048,'Error insertando en la tabla  CASOS_CBRNZA  ' ||SQLERRM);
    END;

    PRC_RFRNCIAS_RCBOS(SOLICITUD, POLIZA, FECHA_MORA);

    BEGIN
      UPDATE AVSOS_SNSTROS
         SET SNA_ESTDO_PGO    = '02',
             SNA_ESTDO_SNSTRO = '06',
             SNA_FCHA_ESTDO   = SYSDATE,
             SNA_USRIO        = LOWER(USER)
       WHERE SNA_RAM_CDGO = RAMO
         AND SNA_NMRO_SNSTRO = SINIESTRO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20049,'Error actualizando el estado en AVSOS_SNSTROS ' ||SQLERRM);
    END;

    BEGIN
      UPDATE DDAS_VGNTES_ARRNDMNTOS
         SET DVA_ESTDO = '02'
       WHERE DVA_NMRO_SLCTUD = SOLICITUD
         AND DVA_FCHA_MRA = FECHA_MORA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20050,'Error actualizando el estado en DDAS_VGNTES_ARRNDMNTOS ' ||SQLERRM);
    END;

    OPEN C_DDAS_TMP;
    LOOP
      FETCH C_DDAS_TMP
        INTO R_DDAS_TMP;
      IF C_DDAS_TMP%NOTFOUND THEN
        EXIT;
      END IF;

      BEGIN
        PRC_VLRES_DDAS(SOLICITUD,
                       FECHA_MORA,
                       N_FECHA_MRA,
                       POLIZA,
                       RAMO,
                       CLASE,
                       SINIESTRO,
                       NMRO_SNSTRO,
                       AMPARO,
                       R_DDAS_TMP.VLD_CNCPTO_VLOR,
                       ESTADO_SNSTRO,
                       FECHA_DESOCUPA,
                       R_DDAS_TMP.VLD_VLOR_PGDO_CIA,
                       R_DDAS_TMP.VLD_VLOR_PGDO_AFNZDO,
                       R_DDAS_TMP.VLD_VLOR_CNSTTDO);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20051,'Error en el proceso de prc_vlres_ddas  ' ||SQLERRM);
      END;

    END LOOP;
    CLOSE C_DDAS_TMP;
    BEGIN
      PRC_INSERT_VLRES_DDAS_TMP(RAMO, SINIESTRO, SOLICITUD, 'N');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20051,'Error en PRC_INSERT_VLRES_DDAS_TMP EN PRC_NUEVO_SNSTRO. ' ||SQLERRM);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20052,'Error en nuevo << Procedure NuevoSiniestro >> . ' ||SQLERRM);

  END PRC_NUEVO_SINIESTRO;

  --
  -- 22
  --
  PROCEDURE PRC_NUEVA_LIQUIDACION(SOLICITUD  NUMBER,
                                  SINIESTRO  NUMBER,
                                  FECHA_MORA DATE,
                                  AMPARO     VARCHAR2,
                                  POLIZA     NUMBER,
                                  CLASE      VARCHAR2,
                                  RAMO       VARCHAR2,
                                  CONCEPTO   VARCHAR2,
                                  PORCENTAJE VARCHAR2) IS

    CURSOR C_LQDCNES IS
      SELECT *
        FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, VLRES_PRDCTO
       WHERE LQT_NMRO_SLCTUD = SOLICITUD
         AND LQT_NMRO_SNSTRO = SINIESTRO
         AND LQT_ESTDO_LQDCION = '02'
         AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
         AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
         AND LQD_PRDO = LQT_PRDO
         AND LQT_NMRO_SLCTUD = VLQ_NMRO_SLCTUD
         AND LQT_TPO_LQDCION = VLQ_TPO_LQDCION
         AND LQT_PRDO = VLQ_PRDO
         AND LQT_SERIE = VLQ_SERIE
         AND VLQ_CNCPTO_VLOR = VPR_CDGO
         AND VPR_ESTDO_CNTA = 'S'
         AND VLQ_CNCPTO_VLOR = CONCEPTO;

    R_LQDCNES   C_LQDCNES%ROWTYPE;
    MENSAJE     VARCHAR2(100);
    FECHA_PAGO  DATE;
    V_FECHA     DATE;
    PRDO        VARCHAR2(6);
    V_VALOR     NUMBER;
    SUMA        NUMBER;

  BEGIN
    V_FECHA := PKG_SINIESTROS.FUN_FECHA_PAGO(SOLICITUD,
                                             FECHA_MORA,
                                             POLIZA,
                                             CLASE,
                                             RAMO,
                                             PRDO);

    IF TO_CHAR(V_FECHA, 'MMYYYY') != TO_CHAR(V_FECHA_PAGO, 'MMYYYY') THEN
      FECHA_PAGO := V_FECHA_PAGO;
    ELSE
      FECHA_PAGO := V_FECHA;
    END IF;

    OPEN C_LQDCNES;
    LOOP
      FETCH C_LQDCNES
        INTO R_LQDCNES;
      IF C_LQDCNES%NOTFOUND THEN
        EXIT;
      END IF;

      V_VALOR := ROUND(R_LQDCNES.VLQ_VLOR * PORCENTAJE, 2);
      IF R_LQDCNES.VLQ_VLOR != 0 AND R_LQDCNES.LQD_FCHA_PGO != V_FECHA THEN
        IF V_VALOR > 0 THEN
          BEGIN
            INSERTA_CONCEPTO_LIQUIDACION(SOLICITUD,
                                         TO_CHAR(FECHA_PAGO, 'MMYYYY'),
                                         SINIESTRO,
                                         R_LQDCNES.LQT_FCHA_DSDE,
                                         R_LQDCNES.LQT_FCHA_HSTA,
                                         R_LQDCNES.LQT_TPO_LQDCION,
                                         USER,
                                         R_LQDCNES.LQT_NMRO_DIAS,
                                         FECHA_MORA,
                                         RAMO,
                                         AMPARO,
                                         R_LQDCNES.VLQ_CNCPTO_VLOR,
                                         V_VALOR,
                                         V_VALOR,
                                         R_LQDCNES.VLQ_ORGEN,
                                         FECHA_PAGO,
                                         MENSAJE);
            IF MENSAJE IS NOT NULL THEN
              RAISE_APPLICATION_ERROR(-20053,'Error insertando la liquidación  ' || mensaje);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20054,'Error insertando la liquidación  ' ||sqlerrm);
          END;
        END IF;
      END IF;

    END LOOP;
    CLOSE C_LQDCNES;

  END PRC_NUEVA_LIQUIDACION;

  --
  -- 23
  --
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
                                       P_VALOR        NUMBER) IS

    V_VALOR    NUMBER;
    V_FECHA    DATE;
    FECHA_PAGO DATE;
    DESDE      DATE;
    HASTA      DATE;
    DIAS       NUMBER;
    TIPO       VARCHAR2(4);
    MENSAJE    VARCHAR2(500);
    PRDO       VARCHAR2(6);
    SUMA       NUMBER;

  BEGIN
    TIPO  := '04';
    DESDE := N_FECHA_MORA;
    IF ESTADO_SNSTRO = '01' THEN
      SUMA  := FUN_NMRO_MESES(FECHA_MORA);
      HASTA := ADD_MONTHS(DESDE, SUMA) - 1;
    ELSE
      HASTA := FECHA_DSCPCION;
    END IF;
    DIAS := FU_RESTA_MES30(HASTA, DESDE, MENSAJE);
    IF MENSAJE IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20055,'Error al consultar los días..' || mensaje);
    END IF;

    V_FECHA := PKG_SINIESTROS.FUN_FECHA_PAGO(SOLICITUD,
                                             N_FECHA_MORA,
                                             POLIZA,
                                             CLASE,
                                             RAMO,
                                             PRDO);

    IF TO_CHAR(V_FECHA, 'MMYYYY') != TO_CHAR(V_FECHA_PAGO, 'MMYYYY') THEN
      FECHA_PAGO := V_FECHA_PAGO;
    ELSE
      FECHA_PAGO := V_FECHA;
    END IF;

    V_VALOR := P_VALOR / DIAS;
    IF V_VALOR != 0 THEN

      BEGIN
        INSERTA_CONCEPTO_LIQUIDACION(SOLICITUD,
                                     TO_CHAR(FECHA_PAGO, 'MMYYYY'),
                                     SINIESTRO,
                                     DESDE,
                                     HASTA,
                                     TIPO,
                                     USER,
                                     DIAS,
                                     N_FECHA_MORA,
                                     RAMO,
                                     AMPARO,
                                     CONCEPTO,
                                     V_VALOR,
                                     V_VALOR,
                                     'G',
                                     FECHA_PAGO,
                                     MENSAJE);

        IF MENSAJE IS NOT NULL THEN
          RAISE_APPLICATION_ERROR(-20056,'Error insertando la liquidación  ' ||mensaje);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20057,'Error insertando la liquidación ' || sqlerrm);
      END;
    END IF;

  END PRC_INSERTA_LQDCION_NUEVOS;

  --
  -- 24
  --
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
                           VR_CNSTTDO       NUMBER) IS

    CURSOR C_VLRESDDAS(CONCEPTO VARCHAR2) IS
      SELECT *
        FROM VLRES_DDAS
       WHERE VLD_RAM_CDGO = P_RAMO
         AND VLD_CDGO_AMPRO = P_AMPARO
         AND VLD_NMRO_SNSTRO = P_SINIESTRO
         AND VLD_NMRO_SLCTUD = P_SOLICITUD
         AND VLD_CNCPTO_VLOR = CONCEPTO;

    R_VlresDdas    C_VLRESDDAS%ROWTYPE;
    R_VlresDdasExt C_VLRESDDAS%ROWTYPE;
    COD_RECUP      VARCHAR2(10);
    V_VR_CNSTTDO   NUMBER;
    MENSAJE        VARCHAR2(500);
    V_VALOR_MES    NUMBER;
    VALOR_CONST    NUMBER;
    N_AMNTOS       VARCHAR2(1);
    VALOR          NUMBER;
    VALOR_ANT      NUMBER;
    FECHA          DATE;
    DIAS           NUMBER;
    MESES          NUMBER;
    CODIGO_R       VARCHAR2(6);
    VALOR_RECUP    NUMBER;
    SUMA           NUMBER;

  BEGIN
    COD_RECUP := FUN_CDGO_RECUP(P_CONCEPTO);
    OPEN C_VLRESDDAS(COD_RECUP);
    FETCH C_VLRESDDAS
      INTO R_VlresDdas;
    IF C_VLRESDDAS%NOTFOUND THEN
      NULL;
    ELSIF COD_RECUP IS NOT NULL THEN
      CLOSE C_VLRESDDAS;
      OPEN C_VLRESDDAS(P_CONCEPTO);
      FETCH C_VLRESDDAS
        INTO R_VlresDdasExt;
      IF C_VLRESDDAS%NOTFOUND THEN
        --Para amparo básico. es normal.
        IF P_AMPARO = '01' THEN
          SELECT SUM(AMN_VLOR)
            INTO V_VALOR_MES
            FROM AMNTOS_SNSTROS
           WHERE AMN_NMRO_SNSTRO = R_VlresDdas.Vld_Nmro_Snstro
             AND AMN_CNCPTO = P_CONCEPTO;
          V_VR_CNSTTDO := (R_VlresDdas.VLD_VLOR_CNSTTDO -
                          R_VlresDdas.VLD_VLOR_PGDO_AFNZDO);

          BEGIN
            INSERT INTO VLRES_DDAS
              SELECT VLD_NMRO_SLCTUD,
                     N_FECHA_MORA,
                     VLD_RAM_CDGO,
                     P_CONCEPTO,
                     DECODE(N_SINIESTRO, NULL, VLD_NMRO_SNSTRO, N_SINIESTRO),
                     VLD_CDGO_AMPRO,
                     VR_PGDO_CIA,
                     V_VR_CNSTTDO,
                     0,
                     VLD_USRIO,
                     VLD_FCHA_MDFCCION,
                     VLD_ORGEN,
                     VLD_NMRO_PGOS
                FROM VLRES_DDAS
               WHERE VLD_RAM_CDGO = P_RAMO
                 AND VLD_CDGO_AMPRO = P_AMPARO
                 AND VLD_NMRO_SNSTRO = P_SINIESTRO
                 AND VLD_NMRO_SLCTUD = P_SOLICITUD
                 AND VLD_CNCPTO_VLOR = COD_RECUP;
            UPDATE VLRES_DDAS
               SET VLD_VLOR_CNSTTDO = R_VlresDdas.VLD_VLOR_PGDO_AFNZDO,
                   VLD_FCHA_MRA     = N_FECHA_MORA,
                   VLD_NMRO_SNSTRO  = DECODE(N_SINIESTRO,NULL,VLD_NMRO_SNSTRO,N_SINIESTRO)
             WHERE VLD_RAM_CDGO = P_RAMO
               AND VLD_CDGO_AMPRO = P_AMPARO
               AND VLD_NMRO_SNSTRO = P_SINIESTRO
               AND VLD_NMRO_SLCTUD = P_SOLICITUD
               AND VLD_CNCPTO_VLOR = COD_RECUP;
          EXCEPTION
            WHEN OTHERS THEN
              Raise_application_error(-20058,TO_CHAR(SQLCODE) || SQLERRM ||P_CONCEPTO);
          END;

        END IF;
      ELSE
        IF P_AMPARO = '01' THEN
          SELECT SUM(AMN_VLOR)
            INTO V_VALOR_MES
            FROM AMNTOS_SNSTROS
           WHERE AMN_NMRO_SNSTRO = R_VlresDdas.Vld_Nmro_Snstro
             AND AMN_CNCPTO = P_CONCEPTO;

          CODIGO_R := FUN_CDGO_RECUP(P_CONCEPTO);
          BEGIN
            SELECT SUM(V.EST_VLOR_AFNZDO)
              INTO VALOR_RECUP
              FROM V_ABRESTDCUENTASTT V
             WHERE V.EST_SLCTUD = P_SOLICITUD
               AND V.EST_FCHA_MRA >= R_VlresDdas.Vld_Fcha_Mra
               AND V.EST_CNCPTO_VLOR = CODIGO_R
               AND EST_ESTADO LIKE 'PAGADO%'
               AND EST_PRDO NOT LIKE 'LIQUIDAC%';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VALOR_RECUP := 0;
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20059,'Error consultando la deuda de la solicitud.');
          END;
          -- SE ACTUALIZA LA FECHA DE MORA Y NUMERO DE SINIESTRO DE LOS CONCEPTOS DE SINIESTRO
          BEGIN
            UPDATE VLRES_DDAS
               SET VLD_FCHA_MRA    = N_FECHA_MORA,
                   VLD_NMRO_SNSTRO = DECODE(N_SINIESTRO,NULL,VLD_NMRO_SNSTRO,N_SINIESTRO)
             WHERE VLD_RAM_CDGO = P_RAMO
               AND VLD_CDGO_AMPRO = P_AMPARO
               AND VLD_NMRO_SNSTRO = P_SINIESTRO
               AND VLD_NMRO_SLCTUD = P_SOLICITUD
               AND VLD_CNCPTO_VLOR = P_CONCEPTO;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20060, SQLERRM || P_CONCEPTO);
          END;

          N_AMNTOS := FUN_AMNTOS(N_SINIESTRO, P_CONCEPTO);
          SUMA     := FUN_NMRO_MESES(P_FECHA_MORA);
          IF P_ESTDO_SNSTRO = '01' THEN
            IF N_AMNTOS = 'N' THEN
              -- se debe dejar asi, si al pagar todo hay que pagar un mes más
              -- o sino solo se gira por recuperación preguntar??
              --VALOR_CONST := (V_VALOR_MES * (SUMA+1)) - NVL(VALOR_RECUP,0);
              VALOR_CONST := (V_VALOR_MES * (SUMA)) - NVL(VALOR_RECUP, 0);
              IF VALOR_CONST < 0 THEN
                VALOR_CONST := 0;
              END IF;

              BEGIN
                UPDATE VLRES_DDAS
                   SET VLD_VLOR_CNSTTDO = NVL(VALOR_CONST, 0)
                 WHERE VLD_RAM_CDGO = P_RAMO
                   AND VLD_CDGO_AMPRO = P_AMPARO
                   AND VLD_NMRO_SNSTRO = N_SINIESTRO
                   AND VLD_NMRO_SLCTUD = P_SOLICITUD
                   AND VLD_CNCPTO_VLOR = P_CONCEPTO;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20061, SQLERRM || P_CONCEPTO);
              END;
            ELSE
              PRC_CALCULA_VALOR(N_SINIESTRO,
                                P_CONCEPTO,
                                VALOR,
                                VALOR_ANT,
                                FECHA);
              IF N_FECHA_MORA != FECHA THEN
                VALOR_CONST := (VALOR_ANT + VALOR);
              END IF;
              VALOR_CONST := VALOR_CONST - NVL(VALOR_RECUP, 0);
              IF VALOR_CONST < 0 THEN
                VALOR_CONST := 0;
              END IF;

              BEGIN
                UPDATE VLRES_DDAS
                   SET VLD_VLOR_CNSTTDO = NVL(VALOR_CONST, 0)
                 WHERE VLD_RAM_CDGO = P_RAMO
                   AND VLD_CDGO_AMPRO = P_AMPARO
                   AND VLD_NMRO_SNSTRO = N_SINIESTRO
                   AND VLD_NMRO_SLCTUD = P_SOLICITUD
                   AND VLD_CNCPTO_VLOR = P_CONCEPTO;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20062, SQLERRM || P_CONCEPTO);
              END;
            END IF;
          ELSE
            DIAS := FU_RESTA_MES30(P_FECHA_DESOCUPA, N_FECHA_MORA, MENSAJE);
            IF MENSAJE IS NOT NULL THEN
              RAISE_APPLICATION_ERROR(-20063,'Error al consultar los días..' || mensaje);
            END IF;
            IF N_AMNTOS = 'N' THEN

              VALOR_CONST := ((V_VALOR_MES / 30) * DIAS) - NVL(VALOR_RECUP, 0);
              IF VALOR_CONST < 0 THEN
                VALOR_CONST := 0;
              END IF;

              BEGIN
                UPDATE VLRES_DDAS
                   SET VLD_VLOR_CNSTTDO = NVL(VALOR_CONST, 0)
                 WHERE VLD_RAM_CDGO = P_RAMO
                   AND VLD_CDGO_AMPRO = P_AMPARO
                   AND VLD_NMRO_SNSTRO = N_SINIESTRO
                   AND VLD_NMRO_SLCTUD = P_SOLICITUD
                   AND VLD_CNCPTO_VLOR = P_CONCEPTO;
              EXCEPTION
                WHEN OTHERS THEN
                  Raise_application_error(-20064, SQLERRM || P_CONCEPTO);
              END;
            ELSE
              PRC_CALCULA_VALOR(N_SINIESTRO,P_CONCEPTO,VALOR,VALOR_ANT,FECHA);
              IF N_FECHA_MORA != FECHA THEN
                MESES := MONTHS_BETWEEN(FECHA, N_FECHA_MORA);
                IF MESES = 1 THEN
                  DIAS        := DIAS - 30;
                  VALOR_CONST := (VALOR_ANT + ((VALOR / 30) * DIAS));
                ELSE
                  DIAS        := DIAS - 60;
                  VALOR_CONST := ((VALOR_ANT * 2) + (VALOR / 30) * DIAS);
                END IF;
              END IF;

              VALOR_CONST := VALOR_CONST - NVL(VALOR_RECUP, 0);
              IF VALOR_CONST < 0 THEN
                VALOR_CONST := 0;
              END IF;

              BEGIN
                UPDATE VLRES_DDAS
                   SET VLD_VLOR_CNSTTDO = NVL(VALOR_CONST, 0)
                 WHERE VLD_RAM_CDGO = P_RAMO
                   AND VLD_CDGO_AMPRO = P_AMPARO
                   AND VLD_NMRO_SNSTRO = N_SINIESTRO
                   AND VLD_NMRO_SLCTUD = P_SOLICITUD
                   AND VLD_CNCPTO_VLOR = P_CONCEPTO;
              EXCEPTION
                WHEN OTHERS THEN
                  Raise_application_error(-20065, SQLERRM || P_CONCEPTO);
              END;
            END IF;
          END IF;
          -- SE ACTUALIZA LA FECHA DE MORA Y NUMERO DE SINIESTRO DE LOS CONCEPTOS DE RECUPERACION
          BEGIN
            UPDATE VLRES_DDAS
               SET VLD_FCHA_MRA    = N_FECHA_MORA,
                   VLD_NMRO_SNSTRO = DECODE(N_SINIESTRO,NULL,VLD_NMRO_SNSTRO,N_SINIESTRO)
             WHERE VLD_RAM_CDGO = P_RAMO
               AND VLD_CDGO_AMPRO = P_AMPARO
               AND VLD_NMRO_SNSTRO = P_SINIESTRO
               AND VLD_NMRO_SLCTUD = P_SOLICITUD
               AND VLD_CNCPTO_VLOR = COD_RECUP;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20066, SQLERRM || P_CONCEPTO);
          END;

          -- SE ACTUALIZA LA FECHA DE MORA Y NUMERO DE SINIESTRO DE LOS CONCEPTOS DE RECUPERACION
          -- EN LAS LQDCNES
          BEGIN
            UPDATE LQDCNES_DTLLE
               SET LQT_FCHA_MRA    = N_FECHA_MORA,
                   LQT_NMRO_SNSTRO = N_SINIESTRO
             WHERE LQT_NMRO_SNSTRO = P_SINIESTRO
               AND EXISTS (SELECT *
                      FROM VLRES_LQDCION, VLRES_PRDCTO
                     WHERE VLQ_NMRO_SLCTUD = LQT_NMRO_SLCTUD
                       AND VLQ_TPO_LQDCION = LQT_TPO_LQDCION
                       AND VLQ_PRDO = LQT_PRDO
                       AND VLQ_SERIE = LQT_SERIE
                       AND VLQ_CNCPTO_VLOR = VPR_CDGO
                       AND VPR_ESTDO_CNTA = 'R');
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20067,'Error al actualizar en lqdcnes_dtlle..' ||SQLERRM);
          END;

          BEGIN
            UPDATE VLRES_DDAS
               SET VLD_VLOR_CNSTTDO = DECODE(SIGN(R_VlresDdas.VLD_VLOR_CNSTTDO -
                                                  R_VlresDdas.VLD_VLOR_PGDO_AFNZDO -
                                                  (VR_CNSTTDO - VR_AFNZDO)),-1,
                                                  R_VlresDdas.VLD_VLOR_PGDO_AFNZDO,
                                                  R_VlresDdas.VLD_VLOR_CNSTTDO -
                                                  (VR_CNSTTDO - VR_AFNZDO))
             WHERE VLD_RAM_CDGO = P_RAMO
               AND VLD_CDGO_AMPRO = P_AMPARO
               AND VLD_NMRO_SNSTRO = N_SINIESTRO
               AND VLD_NMRO_SLCTUD = P_SOLICITUD
               AND VLD_CNCPTO_VLOR = COD_RECUP;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20068, TO_CHAR(SQLCODE) || SQLERRM || COD_RECUP);
          END;

          BEGIN
            SELECT VLD_VLOR_CNSTTDO
              INTO VALOR_CONST
              FROM VLRES_DDAS, VLRES_PRDCTO
             WHERE VLD_NMRO_SNSTRO = N_SINIESTRO
               AND VLD_CNCPTO_VLOR = P_CONCEPTO
               AND VLD_CNCPTO_VLOR = VPR_CDGO
               AND VPR_ESTDO_CNTA = 'S';
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20069,TO_CHAR(SQLCODE) || SQLERRM || COD_RECUP);
          END;

          IF NVL(VALOR_CONST, 0) > 0 THEN
            BEGIN
              PRC_INSERTA_LQDCION_NUEVOS(P_SOLICITUD,
                                         R_VlresDdas.Vld_Fcha_Mra,
                                         N_FECHA_MORA,
                                         N_SINIESTRO,
                                         P_ESTDO_SNSTRO,
                                         P_AMPARO,
                                         P_CONCEPTO,
                                         P_POLIZA,
                                         P_CLASE,
                                         P_RAMO,
                                         P_FECHA_DESOCUPA,
                                         VALOR_CONST);
            EXCEPTION
              WHEN OTHERS THEN
                Raise_application_error(-20070,'Error en prc_inserta_lqdcion_nuevos' ||SQLERRM);
            END;
          END IF;
        END IF;
      END IF;
    END IF;
    CLOSE C_VlresDdas;

  END PRC_VLRES_DDAS;

  --
  -- 25
  --
  PROCEDURE PRC_RFRNCIAS_RCBOS(SOLICITUD  NUMBER,
                               POLIZA     NUMBER,
                               FECHA_MORA DATE) IS

    REFERENCIA    VARCHAR2(50);
    REFERENCIANEW VARCHAR2(50);
    N_FECHA_MRA   DATE;

  BEGIN
    N_FECHA_MRA := N_FECHA_MORA;

    REFERENCIA    := RPAD(tO_CHAR(SOLICITUD), 10, ' ') ||
                     TO_CHAR(FECHA_MORA, 'DD/MM/YYYY') || TO_CHAR(POLIZA);
    REFERENCIANEW := RPAD(TO_CHAR(SOLICITUD), 10, ' ') ||
                     TO_CHAR(N_FECHA_MRA, 'DD/MM/YYYY') || TO_CHAR(POLIZA);
    INSERT INTO DTLLES_RCBOS_CJA

      SELECT REFERENCIANEW,
             DRC_NMRO_RCBO,
             DRC_CDGO_CIA,
             DRC_TPO_RCBO,
             DRC_ORGEN_RCDO,
             DRC_TPO_RFRNCIA,
             DRC_CDGO_RCDO,
             DRC_VLOR_PGDO,
             DRC_USRIO,
             DRC_FCHA_MDFCCION
        FROM DTLLES_RCBOS_CJA
       WHERE DRC_RFRNCIA = REFERENCIA;
    INSERT INTO CNCPTOS_DTLLE_RCBOS
      SELECT REFERENCIANEW,
             CDR_NMRO_RCBO,
             CDR_CDGO_CIA,
             CDR_TPO_RCBO,
             CDR_ORGEN_RCDO,
             CDR_CDGO_RCDO,
             CDR_CDGO_CNCPTO,
             CDR_TPO_RCDO,
             CDR_VLOR,
             CDR_USRIO,
             CDR_FCHA_MDFCCION,
             CDR_FCHA_DSDE,
             CDR_FCHA_HSTA
        FROM CNCPTOS_DTLLE_RCBOS
       WHERE CDR_RFRNCIA = REFERENCIA;
    DELETE CNCPTOS_DTLLE_RCBOS WHERE CDR_RFRNCIA = REFERENCIA;
    DELETE DTLLES_RCBOS_CJA WHERE DRC_RFRNCIA = REFERENCIA;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20071,'Error en Detalle y Conceptos Recibos de Caja ' ||SQLERRM);
  END PRC_RFRNCIAS_RCBOS;

  --
  -- 26
  --
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
                               P_MENSAJE    OUT VARCHAR2) IS

    CURSOR C_VLRES_DDAS(P_CONCEPTO VARCHAR2) IS
      SELECT VLD_NMRO_SLCTUD,
             VLD_FCHA_MRA,
             VLD_RAM_CDGO,
             VLD_CNCPTO_VLOR,
             VLD_NMRO_SNSTRO,
             VLD_CDGO_AMPRO,
             VLD_VLOR_PGDO_CIA,
             VLD_VLOR_CNSTTDO,
             VLD_VLOR_PGDO_AFNZDO,
             VLD_USRIO,
             VLD_FCHA_MDFCCION,
             VLD_ORGEN,
             VLD_NMRO_PGOS
        FROM VLRES_DDAS
       WHERE VLD_RAM_CDGO = RAMO
         AND VLD_CDGO_AMPRO = AMPARO
         AND VLD_NMRO_SNSTRO = SINIESTRO
         AND VLD_NMRO_SLCTUD = SOLICITUD
         AND VLD_CNCPTO_VLOR = P_CONCEPTO;

    R_VLRES_DDAS     C_VLRES_DDAS%ROWTYPE;
    R_VLRES_DDAS_EXT C_VLRES_DDAS%ROWTYPE;
    vCodgRecup       VARCHAR2(10);
    VALOR_CONCEPTO   NUMBER;
    V_VR_CNSTTDO     NUMBER;
    FECHA_PAGO       DATE;
    PRDO             VARCHAR2(6);
    PORCENTAJE       NUMBER := 0;

  BEGIN
    BEGIN
      FECHA_PAGO := PKG_SINIESTROS.FUN_FECHA_PAGO(SINIESTRO,
                                                  POLIZA,
                                                  CLASE,
                                                  RAMO,
                                                  PRDO);
    EXCEPTION
      WHEN OTHERS THEN
        P_MENSAJE := 'No se pudo Recuperar Fecha Pago.' ||sqlerrm;
        RETURN;
    END;

    BEGIN
      SELECT SUM(AMN_VLOR)
        INTO VALOR_CONCEPTO
        FROM AMNTOS_SNSTROS
       WHERE AMN_NMRO_SNSTRO = SINIESTRO
         AND AMN_CNCPTO = CONCEPTO;
    EXCEPTION
      WHEN OTHERS THEN
        P_MENSAJE := 'Error consultando el valor indemnizado..' ||SQLERRM;
        RETURN;
    END;
    
    vCodgRecup := FUN_CDGO_RECUP(CONCEPTO);
    OPEN C_VLRES_DDAS(vCodgRecup);
    FETCH C_VLRES_DDAS INTO R_VLRES_DDAS;
    IF C_VLRES_DDAS%NOTFOUND THEN
      NULL;
    ELSIF vCodgRecup IS NOT NULL THEN
      CLOSE C_VLRES_DDAS;
      OPEN C_VLRES_DDAS(CONCEPTO);
      FETCH C_VLRES_DDAS INTO R_VLRES_DDAS_EXT;
      IF C_VLRES_DDAS%NOTFOUND THEN
        IF AMPARO = '01' THEN
          IF VLOR_CNSTTDO != 0 THEN
            IF P_PERIODO IN ('PERIODO1') THEN
              IF R_VLRES_DDAS.VLD_VLOR_CNSTTDO != VLOR_CNSTTDO THEN
                PORCENTAJE := ((R_VLRES_DDAS.VLD_VLOR_CNSTTDO -
                              R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO) /
                              R_VLRES_DDAS.VLD_VLOR_CNSTTDO);
              ELSE
                PORCENTAJE := ((R_VLRES_DDAS.VLD_VLOR_CNSTTDO -
                              R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO) /
                              VLOR_CNSTTDO);
              END IF;
            END IF;
          ELSE
            PORCENTAJE := 0;
          END IF;
          IF P_PERIODO IN ('PERIODO1') THEN
            V_VR_CNSTTDO := (R_VLRES_DDAS.VLD_VLOR_CNSTTDO -
                            R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO);
          END IF;

          BEGIN
            INSERT INTO VLRES_DDAS
              SELECT VLD_NMRO_SLCTUD,
                     VLD_FCHA_MRA,
                     VLD_RAM_CDGO,
                     CONCEPTO,
                     VLD_NMRO_SNSTRO,
                     VLD_CDGO_AMPRO,
                     VR_PGDO_CIA,
                     V_VR_CNSTTDO,
                     0,
                     VLD_USRIO,
                     VLD_FCHA_MDFCCION,
                     VLD_ORGEN,
                     VLD_NMRO_PGOS
                FROM VLRES_DDAS
               WHERE VLD_RAM_CDGO = RAMO
                 AND VLD_CDGO_AMPRO = AMPARO
                 AND VLD_NMRO_SNSTRO = SINIESTRO
                 AND VLD_NMRO_SLCTUD = SOLICITUD
                 AND VLD_CNCPTO_VLOR = vCodgRecup;
          EXCEPTION
            WHEN others THEN
              P_MENSAJE := TO_CHAR(SQLCODE) || SQLERRM ||CONCEPTO;
              RETURN;
          END;

          BEGIN
            UPDATE VLRES_DDAS
               SET VLD_VLOR_CNSTTDO = R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO
             WHERE VLD_RAM_CDGO = RAMO
               AND VLD_CDGO_AMPRO = AMPARO
               AND VLD_NMRO_SNSTRO = SINIESTRO
               AND VLD_NMRO_SLCTUD = SOLICITUD
               AND VLD_CNCPTO_VLOR = vCodgRecup;
          EXCEPTION
            WHEN others THEN
              P_MENSAJE := TO_CHAR(SQLCODE) || SQLERRM ||CONCEPTO;
              RETURN;
          END;

          IF P_PERIODO IN ('PERIODO1') THEN           
            BEGIN
              PRC_CAMBIAR_OBJCION(RAMO, SINIESTRO, AMPARO);
              IF V_PAGOS = 'N' THEN
                BEGIN
                  PRC_ACTUALIZA_VALOR_LQDCION(SINIESTRO,
                                              RAMO,
                                              SOLICITUD,
                                              R_VLRES_DDAS.VLD_FCHA_MRA,
                                              CONCEPTO,
                                              PORCENTAJE);
                EXCEPTION
                  WHEN OTHERS THEN
                    P_MENSAJE := 'Error en PRC_ACTUALIZA_VALOR_LQDCION..'|| SQLERRM;
                    RETURN;
                END;
              ELSE
                V_ENTRO := 'S';
                BEGIN
                  PRC_NUEVA_LIQUIDACION(SOLICITUD,
                                        SINIESTRO,
                                        R_VLRES_DDAS.VLD_FCHA_MRA,
                                        AMPARO,
                                        POLIZA,
                                        CLASE,
                                        RAMO,
                                        CONCEPTO,
                                        PORCENTAJE);
                EXCEPTION
                  WHEN OTHERS THEN
                    P_MENSAJE := 'Error en PRC_NUEVA_LIQUIDACION..'|| SQLERRM;
                    RETURN;
                END;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error en PRC_CAMBIAR_OBJCION..'|| SQLERRM;
                RETURN;
            END;
            BEGIN 
              PRC_BORRA_LQDCNES_NGTVAS(SINIESTRO, RAMO, FECHA_PAGO);
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error en PRC_BORRA_LQDCNES_NGTVAS..'|| SQLERRM;
                RETURN;
            END;   
          END IF;
        END IF;
      ELSE
        IF AMPARO = '01' THEN
          IF P_PERIODO IN ('PERIODO1') THEN
            IF R_VLRES_DDAS.VLD_VLOR_CNSTTDO = 0 THEN
              IF VLOR_CNSTTDO = VLOR_AFNZDO THEN
                PORCENTAJE := 1;
              ELSE
                PORCENTAJE := (VLOR_CNSTTDO - VLOR_AFNZDO) / VLOR_CNSTTDO;
              END IF;
            ELSE
              PORCENTAJE := ((R_VLRES_DDAS.VLD_VLOR_CNSTTDO + VLOR_AFNZDO) -
                            R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO) /
                            (R_VLRES_DDAS.VLD_VLOR_CNSTTDO + VLOR_AFNZDO);
            END IF;
          END IF;

          IF P_PERIODO = 'PERIODO1' THEN
            V_VR_CNSTTDO := R_VLRES_DDAS.VLD_VLOR_CNSTTDO;
          END IF;

          IF P_PERIODO = 'PERIODO1' THEN
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO + (NVL(V_VR_CNSTTDO,0) - NVL(R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO,0))
               WHERE VLD_RAM_CDGO = RAMO
                 AND VLD_CDGO_AMPRO = AMPARO
                 AND VLD_NMRO_SNSTRO = SINIESTRO
                 AND VLD_NMRO_SLCTUD = SOLICITUD
                 AND VLD_CNCPTO_VLOR = CONCEPTO;
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := SQLERRM || CONCEPTO;
                RETURN;
            END;

            BEGIN
              UPDATE VLRES_DDAS
                SET VLD_VLOR_CNSTTDO = DECODE(SIGN(R_VLRES_DDAS.VLD_VLOR_CNSTTDO -
                                                  R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO -
                                                  (VLOR_CNSTTDO -
                                                  VLOR_AFNZDO)), -1,
                                                  R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO,
                                                  R_VLRES_DDAS.VLD_VLOR_CNSTTDO -
                                                  (VLOR_CNSTTDO - VLOR_AFNZDO))
               WHERE VLD_RAM_CDGO = RAMO
                 AND VLD_CDGO_AMPRO = AMPARO
                 AND VLD_NMRO_SNSTRO = SINIESTRO
                 AND VLD_NMRO_SLCTUD = SOLICITUD
                 AND VLD_CNCPTO_VLOR = FUN_CDGO_RECUP(CONCEPTO);
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error actualizando vlres_ddas '||SQLERRM || FUN_CDGO_RECUP(CONCEPTO);
                RETURN;
            END;

            BEGIN
              PRC_CAMBIAR_OBJCION(RAMO, SINIESTRO, AMPARO);

              IF V_PAGOS = 'N' THEN
                BEGIN
                  PRC_ACTUALIZA_VALOR_LQDCION(SINIESTRO,
                                              RAMO,
                                              SOLICITUD,
                                              R_VLRES_DDAS.VLD_FCHA_MRA,
                                              CONCEPTO,
                                              PORCENTAJE);
                EXCEPTION
                  WHEN OTHERS THEN
                    P_MENSAJE := 'Error en PRC_ACTUALIZA_VALOR_LQDCION..'|| SQLERRM;
                    RETURN;
                END;
              ELSE
                V_ENTRO := 'S';
                IF FUN_FECHA_PROXIMA(SOLICITUD,SINIESTRO,V_FECHA_PAGO) = 'S' THEN
                  V_CAMBIA_FECHA := 'S';
                  BEGIN
                    PRC_ACTUALIZA_VALOR_LQDCION(SINIESTRO,
                                                RAMO,
                                                SOLICITUD,
                                                R_VLRES_DDAS.VLD_FCHA_MRA,
                                                CONCEPTO,
                                                PORCENTAJE);
                    BEGIN
                      PRC_ACTUALIZA_FECHA(SOLICITUD,
                                          R_VLRES_DDAS.VLD_FCHA_MRA,
                                          POLIZA,
                                          CLASE,
                                          RAMO,
                                          SINIESTRO);
                    EXCEPTION
                      WHEN OTHERS THEN
                        P_MENSAJE := 'Error en PRC_ACTUALIZA_FECHA..'|| SQLERRM;
                        RETURN;
                    END;
                  EXCEPTION
                    WHEN OTHERS THEN
                      P_MENSAJE := 'Error en PRC_ACTUALIZA_VALOR_LQDCION..'|| SQLERRM;
                      RETURN;
                  END;  
                ELSE
                  IF V_CAMBIA_FECHA = 'N' THEN
                    BEGIN
                      PRC_NUEVA_LIQUIDACION(SOLICITUD,
                                            SINIESTRO,
                                            R_VLRES_DDAS.VLD_FCHA_MRA,
                                            AMPARO,
                                            POLIZA,
                                            CLASE,
                                            RAMO,
                                            CONCEPTO,
                                            PORCENTAJE);
                    EXCEPTION
                      WHEN OTHERS THEN
                        P_MENSAJE := 'Error en PRC_NUEVA_LIQUIDACION..'|| SQLERRM;
                        RETURN;
                    END; 
                  END IF;
                END IF;
              END IF;
                
              BEGIN         
                PRC_BORRA_LQDCNES_NGTVAS(SINIESTRO, RAMO, FECHA_PAGO);
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := 'Error en PRC_BORRA_LQDCNES_NGTVAS..'|| SQLERRM;
                  RETURN;
              END;
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error en PRC_CAMBIAR_OBJCION..'|| SQLERRM;
                RETURN;
            END; 
          END IF;
        END IF;
      END IF;
    END IF;
    CLOSE C_VLRES_DDAS;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20089, SQLERRM);

  END PRC_ACTUALIZA_DDAS;

  --
  -- 27
  --
  PROCEDURE PRC_ACTUALIZA_DDAS_NVO(RAMO         VARCHAR2,
                                   AMPARO       VARCHAR2,
                                   SINIESTRO    NUMBER,
                                   SOLICITUD    NUMBER,
                                   CONCEPTO     VARCHAR2,
                                   VR_PGDO_CIA  NUMBER,
                                   VLOR_CNSTTDO NUMBER,
                                   VLOR_AFNZDO  NUMBER) IS

    CURSOR C_VLRES_DDAS(P_CONCEPTO VARCHAR2) IS
      SELECT VLD_NMRO_SLCTUD,
             VLD_FCHA_MRA,
             VLD_RAM_CDGO,
             VLD_CNCPTO_VLOR,
             VLD_NMRO_SNSTRO,
             VLD_CDGO_AMPRO,
             VLD_VLOR_PGDO_CIA,
             VLD_VLOR_CNSTTDO,
             VLD_VLOR_PGDO_AFNZDO,
             VLD_USRIO,
             VLD_FCHA_MDFCCION,
             VLD_ORGEN,
             VLD_NMRO_PGOS
        FROM VLRES_DDAS
       WHERE VLD_RAM_CDGO = RAMO
         AND VLD_CDGO_AMPRO = AMPARO
         AND VLD_NMRO_SNSTRO = SINIESTRO
         AND VLD_NMRO_SLCTUD = SOLICITUD
         AND VLD_CNCPTO_VLOR = P_CONCEPTO;

    R_VLRES_DDAS     C_VLRES_DDAS%ROWTYPE;
    R_VLRES_DDAS_EXT C_VLRES_DDAS%ROWTYPE;
    vCodgRecup       VARCHAR2(10);
    VALOR_CONCEPTO   NUMBER;
    V_VR_CNSTTDO     NUMBER;

  BEGIN
    BEGIN
      SELECT SUM(AMN_VLOR)
        INTO VALOR_CONCEPTO
        FROM AMNTOS_SNSTROS
       WHERE AMN_NMRO_SNSTRO = SINIESTRO
         AND AMN_CNCPTO = CONCEPTO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20090,'Error consultando el valor indemnizado..' ||SQLERRM);
    END;
    vCodgRecup := FUN_CDGO_RECUP(CONCEPTO);
    OPEN C_VLRES_DDAS(vCodgRecup);
    FETCH C_VLRES_DDAS
      INTO R_VLRES_DDAS;
    IF C_VLRES_DDAS%NOTFOUND THEN
      null;
    ELSIF vCodgRecup IS NOT NULL THEN
      CLOSE C_VLRES_DDAS;
      OPEN C_VLRES_DDAS(CONCEPTO);
      FETCH C_VLRES_DDAS
        INTO R_VLRES_DDAS_EXT;
      IF C_VLRES_DDAS%NOTFOUND THEN
        IF AMPARO = '01' THEN
          V_VR_CNSTTDO := R_VLRES_DDAS.VLD_VLOR_CNSTTDO; -- + VALOR_CONCEPTO;

          -- SE INSERTA LOS CONCEPTOS DE RECUPERACION
          BEGIN
            INSERT INTO VLRES_DDAS
              SELECT VLD_NMRO_SLCTUD,
                     VLD_FCHA_MRA,
                     VLD_RAM_CDGO,
                     CONCEPTO,
                     VLD_NMRO_SNSTRO,
                     VLD_CDGO_AMPRO,
                     VR_PGDO_CIA,
                     V_VR_CNSTTDO,
                     0,
                     VLD_USRIO,
                     VLD_FCHA_MDFCCION,
                     VLD_ORGEN,
                     VLD_NMRO_PGOS
                FROM VLRES_DDAS
               WHERE VLD_RAM_CDGO = RAMO
                 AND VLD_CDGO_AMPRO = AMPARO
                 AND VLD_NMRO_SNSTRO = SINIESTRO
                 AND VLD_NMRO_SLCTUD = SOLICITUD
                 AND VLD_CNCPTO_VLOR = vCodgRecup;
          EXCEPTION
            WHEN others THEN
              RAISE_APPLICATION_ERROR(-20091,TO_CHAR(SQLCODE) || SQLERRM ||CONCEPTO);
          END;

          -- SE ACTUALIZA EL VALOR CONSTITUIDO POR EL VALOR QUE SE HA RECAUDADO

          BEGIN
            UPDATE VLRES_DDAS
               SET VLD_VLOR_CNSTTDO = NVL(R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO,0)
             WHERE VLD_RAM_CDGO = RAMO
               AND VLD_CDGO_AMPRO = AMPARO
               AND VLD_NMRO_SNSTRO = SINIESTRO
               AND VLD_NMRO_SLCTUD = SOLICITUD
               AND VLD_CNCPTO_VLOR = vCodgRecup;
          EXCEPTION
            WHEN others THEN
              RAISE_APPLICATION_ERROR(-20092,TO_CHAR(SQLCODE) || SQLERRM ||CONCEPTO);
          END;

        END IF;
      ELSE
        IF AMPARO = '01' THEN

          V_VR_CNSTTDO := (R_VLRES_DDAS.VLD_VLOR_CNSTTDO + VLOR_AFNZDO) +
                          ((R_VLRES_DDAS.VLD_VLOR_CNSTTDO + VLOR_AFNZDO) / 2);
          BEGIN
            UPDATE VLRES_DDAS
               SET VLD_VLOR_CNSTTDO =
                   (NVL(V_VR_CNSTTDO, 0) -
                   NVL(R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO, 0))
             WHERE VLD_RAM_CDGO = RAMO
               AND VLD_CDGO_AMPRO = AMPARO
               AND VLD_NMRO_SNSTRO = SINIESTRO
               AND VLD_NMRO_SLCTUD = SOLICITUD
               AND VLD_CNCPTO_VLOR = CONCEPTO;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20093, SQLERRM || CONCEPTO);
          END;

          BEGIN
            UPDATE VLRES_DDAS
               SET VLD_VLOR_CNSTTDO = DECODE(SIGN(R_VLRES_DDAS.VLD_VLOR_CNSTTDO -
                                                  R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO -
                                                  (VLOR_CNSTTDO -
                                                  VLOR_AFNZDO)), -1,
                                                  R_VLRES_DDAS.VLD_VLOR_PGDO_AFNZDO,
                                                  R_VLRES_DDAS.VLD_VLOR_CNSTTDO -
                                                  (VLOR_CNSTTDO - VLOR_AFNZDO))
             WHERE VLD_RAM_CDGO = RAMO
               AND VLD_CDGO_AMPRO = AMPARO
               AND VLD_NMRO_SNSTRO = SINIESTRO
               AND VLD_NMRO_SLCTUD = SOLICITUD
               AND VLD_CNCPTO_VLOR = vCodgRecup;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20094,TO_CHAR(SQLCODE) || SQLERRM ||CONCEPTO);
          END;

        END IF;
      END IF;
    END IF;
    CLOSE C_VLRES_DDAS;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20095, SQLERRM);

  END PRC_ACTUALIZA_DDAS_NVO;

  --
  --
  --
  PROCEDURE PRC_BORRA_RCPRCNES(P_SOLICITUD   NUMBER,
                               P_FECHA_MORA  DATE) IS

  EXISTE   NUMBER;

  BEGIN
    SELECT COUNT(8)
      INTO EXISTE
      FROM VLRES_DDAS
     WHERE VLD_NMRO_SLCTUD = P_SOLICITUD
       AND VLD_FCHA_MRA = P_FECHA_MORA
       AND VLD_CNCPTO_VLOR LIKE 'RM%'
       AND VLD_VLOR_CNSTTDO = 0
       AND VLD_VLOR_PGDO_AFNZDO = 0;

    IF NVL(EXISTE,0) > 0 THEN
      BEGIN
        DELETE VLRES_DDAS
         WHERE VLD_NMRO_SLCTUD = P_SOLICITUD
           AND VLD_FCHA_MRA = P_FECHA_MORA
           AND VLD_CNCPTO_VLOR LIKE 'RM%'
           AND VLD_VLOR_CNSTTDO = 0
           AND VLD_VLOR_PGDO_AFNZDO = 0;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20099,'Error borrando las recuperaciones en cero '|| SQLERRM);
      END;

    END IF;

    SELECT COUNT(8)
      INTO EXISTE
      FROM VLRES_DDAS
     WHERE VLD_NMRO_SLCTUD = P_SOLICITUD
       AND VLD_FCHA_MRA = P_FECHA_MORA
       AND VLD_CNCPTO_VLOR LIKE 'RM%'
       AND VLD_VLOR_PGDO_AFNZDO = 0;

    -- Solo se borran las recuperaciones mensuales sin pago cuando no tienen RM desde el siniestro
    IF NVL(EXISTE,0) > 0 AND NVL(EXISTE_RM,0) = 0 THEN
      BEGIN
        DELETE VLRES_DDAS
         WHERE VLD_NMRO_SLCTUD = P_SOLICITUD
           AND VLD_FCHA_MRA = P_FECHA_MORA
           AND VLD_CNCPTO_VLOR LIKE 'RM%'
           AND VLD_VLOR_PGDO_AFNZDO = 0;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20100,'Error borrando las recuperaciones en cero '|| SQLERRM);
      END;

    END IF;

  END PRC_BORRA_RCPRCNES;

  --
  -- BORRA LQDCNES DESPUES DE SUBSANAR QUE QUEDAN EN CERO
  --
  PROCEDURE PRC_BORRA_LQDCNES(P_SOLICITUD   NUMBER,
                              P_FECHA_MORA  DATE) IS

  CURSOR C_LQDCNES IS
    SELECT *
      FROM LQDCNES,LQDCNES_DTLLE, VLRES_LQDCION, VLRES_PRDCTO
     WHERE LQT_NMRO_SLCTUD = P_SOLICITUD
       AND LQT_FCHA_MRA = P_FECHA_MORA
       AND LQD_FCHA_PGO = V_FECHA_PAGO
       AND LQT_ESTDO_LQDCION = '01'
       AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
       AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
       AND LQD_PRDO = LQT_PRDO
       AND VLQ_NMRO_SLCTUD = LQT_NMRO_SLCTUD
       AND VLQ_TPO_LQDCION = LQT_TPO_LQDCION
       AND VLQ_PRDO = LQT_PRDO
       AND VLQ_SERIE = LQT_SERIE
       AND VLQ_RAM_CDGO = LQT_RAM_CDGO
       AND VLQ_VLOR = 0
       AND VLQ_CNCPTO_VLOR = VPR_CDGO
       AND VPR_ESTDO_CNTA = 'S';

  R_LQDCNES   C_LQDCNES%ROWTYPE;

  BEGIN
    OPEN C_LQDCNES;
    LOOP
      FETCH C_LQDCNES INTO R_LQDCNES;
      IF C_LQDCNES%NOTFOUND THEN
        EXIT;
      END IF;

      BEGIN
        DELETE VLRES_LQDCION
         WHERE VLQ_NMRO_SLCTUD = R_LQDCNES.LQT_NMRO_SLCTUD
           AND VLQ_TPO_LQDCION = R_LQDCNES.LQT_TPO_LQDCION
           AND VLQ_PRDO = R_LQDCNES.LQT_PRDO
           AND VLQ_SERIE = R_LQDCNES.LQT_SERIE
           AND VLQ_VLOR = 0;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20101,'Error borrando vlres_lqdcion en cero..'||sqlerrm);
      END;

      BEGIN
        DELETE LQDCNES_DTLLE
         WHERE LQT_NMRO_SLCTUD = R_LQDCNES.LQT_NMRO_SLCTUD
           AND LQT_TPO_LQDCION = R_LQDCNES.LQT_TPO_LQDCION
           AND LQT_PRDO = R_LQDCNES.LQT_PRDO
           AND LQT_SERIE = R_LQDCNES.LQT_SERIE;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20102,'Error borrando lqdcnes_dtlle en cero..'||sqlerrm);
      END;

    END LOOP;
    CLOSE C_LQDCNES;

  END PRC_BORRA_LQDCNES;


  --
  -- 28
  --
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
                         P_MENSAJE      OUT VARCHAR2) IS

    CURSOR C_VLRES_DDAS_TMP IS
      SELECT VLD_NMRO_SLCTUD,
             VLD_FCHA_MRA,
             VLD_RAM_CDGO,
             VLD_CNCPTO_VLOR,
             VLD_NMRO_SNSTRO,
             VLD_CDGO_AMPRO,
             VLD_VLOR_PGDO_CIA,
             VLD_VLOR_CNSTTDO,
             VLD_VLOR_PGDO_AFNZDO,
             VLD_USRIO,
             VLD_FCHA_MDFCCION,
             VLD_ORGEN,
             VLD_NMRO_PGOS
        FROM VLRES_DDAS_TMP
       WHERE VLD_RAM_CDGO = RAMO
         AND VLD_CDGO_AMPRO = AMPARO
         AND VLD_NMRO_SNSTRO = SINIESTRO
         AND VLD_NMRO_SLCTUD = SOLICITUD
         AND VLD_VLOR_CNSTTDO != 0;

    R_VLRES_DDAS_TMP C_VLRES_DDAS_TMP%ROWTYPE;
    V_PERIODO        VARCHAR2(9);
    V_ESTADO         VARCHAR2(2);
    ESTADO_SNSTRO    VARCHAR2(2);
    ESTADO_PAGO      VARCHAR2(2);
    N_SINIESTRO      NUMBER;
    N_FECHA_MRA      DATE;
    V_ORIGEN         VARCHAR2(2);
    EXISTE           NUMBER;
    FCHA_MRA         DATE;
    SUMA             NUMBER;
    PRDO             VARCHAR2(6);
    FECHA_PAGO       DATE;
    V_FECHA          DATE;
    V_MENSAJE        VARCHAR2(500);

  BEGIN
    BEGIN
      V_PAGOS   := FUN_EXISTE_PAGO(SOLICITUD, SINIESTRO);
      BEGIN
        V_PERIODO := FUN_CONSULTA_PERIODO(AMPARO,
                                          POLIZA,
                                          RAMO,
                                          CLASE,
                                          F_OBJECION,
                                          SYSDATE);


        IF V_PERIODO IN ('PERIODO1') THEN
          BEGIN
            SELECT NVL(COUNT(8),0)
              INTO EXISTE_RM
              FROM VLRES_DDAS_TMP
             WHERE VLD_RAM_CDGO = RAMO
               AND VLD_CDGO_AMPRO = AMPARO
               AND VLD_NMRO_SNSTRO = SINIESTRO
               AND VLD_NMRO_SLCTUD = SOLICITUD
               AND VLD_VLOR_CNSTTDO != 0
               AND VLD_CNCPTO_VLOR LIKE 'RM%';
          EXCEPTION
            WHEN OTHERS THEN
              EXISTE_RM := 0;
          END;
          
          --MANTIS 56162 ACTUALIZAR LA LIQUIDACION
          IF V_PAGOS = 'N' THEN
            BEGIN
              PRC_CAMBIAR_ESTDO_LQDCION(SINIESTRO, '01', SOLICITUD);
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error en PRC_CAMBIAR_ESTDO_LQDCION..'|| SQLERRM;
                RETURN;
            END;
          ELSE
            IF FUN_FECHA_PROXIMA(SOLICITUD,SINIESTRO,V_FECHA_PAGO) = 'S' THEN
              BEGIN
                PRC_CAMBIAR_ESTDO_LQDCION(SINIESTRO, '01', SOLICITUD);
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := 'Error en PRC_CAMBIAR_ESTDO_LQDCION..'|| SQLERRM;
                  RETURN;
              END;
            END IF;
          END IF;
          
          OPEN C_VLRES_DDAS_TMP;
          LOOP
            FETCH C_VLRES_DDAS_TMP
              INTO R_VLRES_DDAS_TMP;
            IF C_VLRES_DDAS_TMP%NOTFOUND THEN
              EXIT;
            END IF;

            BORRA := FUN_VALIDA_PAGO_MAYOR(SOLICITUD,FECHA_MORA,R_VLRES_DDAS_TMP.VLD_CNCPTO_VLOR);
            PRC_ACTUALIZA_DDAS(RAMO,
                               CLASE,
                               AMPARO,
                               SINIESTRO,
                               SOLICITUD,
                               R_VLRES_DDAS_TMP.VLD_CNCPTO_VLOR,
                               R_VLRES_DDAS_TMP.VLD_VLOR_PGDO_CIA,
                               R_VLRES_DDAS_TMP.VLD_VLOR_CNSTTDO,
                               R_VLRES_DDAS_TMP.VLD_VLOR_PGDO_AFNZDO,
                               POLIZA,
                               V_PERIODO,
                               V_MENSAJE);
            IF V_MENSAJE IS NOT NULL THEN
              P_MENSAJE := 'Error en PRC_ACTUALIZA_DDAS  '||V_MENSAJE;
              RETURN;
            END IF;
          END LOOP;
          CLOSE C_VLRES_DDAS_TMP;
          
          IF V_PAGOS = 'N' THEN
            BEGIN
              PRC_INSERT_VLRES_DDAS_TMP(RAMO,
                                        SINIESTRO,
                                        SOLICITUD,
                                        'N');
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error en PRC_INSERT_VLRES_DDAS_TMP..'|| SQLERRM;
                RETURN;
            END;
          
            BEGIN
              PRC_ACTUALIZA_FECHA(SOLICITUD,
                                  FECHA_MORA,
                                  POLIZA,
                                  CLASE,
                                  RAMO,
                                  SINIESTRO);
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error en PRC_ACTUALIZA_FECHA  '||SQLERRM;
                RETURN;
            END;    
          END IF;

          BEGIN
            PRC_ESTADOS_SNSTRO(SINIESTRO, ESTADO_SNSTRO, ESTADO_PAGO);
            IF ESTADO_SNSTRO = '01' THEN
              V_ESTADO := '00';
            ELSE
              V_ESTADO := '04';
            END IF;
            
            BEGIN
              PRC_CAMBIA_ESTDO_SNSTRO(RAMO, SINIESTRO, V_ESTADO);

              IF FUN_BORRA_RCPRCNES(SOLICITUD,SINIESTRO) = 'S' THEN 
                BEGIN
                  DELETE  VLRES_DDAS
                   WHERE VLD_NMRO_SLCTUD = SOLICITUD
                     AND VLD_NMRO_SNSTRO = SINIESTRO
                     AND VLD_CNCPTO_VLOR LIKE 'RM%'
                     AND VLD_VLOR_PGDO_AFNZDO = 0;
                EXCEPTION
                  WHEN OTHERS THEN
                    P_MENSAJE := 'Error al borrar las recuperaciones  '||sqlerrm;
                    RETURN;
                END;
              END IF;
            
              BEGIN
                PRC_BORRA_RCPRCNES(SOLICITUD,FECHA_MORA);
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := 'Error EN PRC_BORRA_RCPRCNES..  '||sqlerrm;
                  RETURN;
              END;  
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error EN PRC_CAMBIA_ESTDO_SNSTRO..  '||sqlerrm;
                RETURN;
            END; 
          EXCEPTION
            WHEN OTHERS THEN
              P_MENSAJE := 'Error EN PRC_ESTADOS_SNSTRO..  '||sqlerrm;
              RETURN;
          END;
        ELSE
          -- PERIODO 2 NUEVO SINIESTRO
          -- MANTIS 54492 
          SUMA   := FUN_NMRO_MESES(FECHA_MORA); -- trae la nueva fecha de mora
          IF FECHA_DSCPCION IS NOT NULL AND FECHA_DSCPCION < N_FECHA_MORA THEN
            P_MENSAJE := 'Error no se puede generar un siniestro nuevo, la fecha de desocupacion es menor a la nueva fecha de mora..';
            RETURN;
          ELSE
            OPEN C_VLRES_DDAS_TMP;
            LOOP
              FETCH C_VLRES_DDAS_TMP
                INTO R_VLRES_DDAS_TMP;
              IF C_VLRES_DDAS_TMP%NOTFOUND THEN
                EXIT;
              END IF;

              BEGIN
                PRC_ACTUALIZA_DDAS_NVO(RAMO,
                                       AMPARO,
                                       SINIESTRO,
                                       SOLICITUD,
                                       R_VLRES_DDAS_TMP.VLD_CNCPTO_VLOR,
                                       R_VLRES_DDAS_TMP.VLD_VLOR_PGDO_CIA,
                                       R_VLRES_DDAS_TMP.VLD_VLOR_CNSTTDO,
                                       R_VLRES_DDAS_TMP.VLD_VLOR_PGDO_AFNZDO);
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := 'Error en PRC_ACTUALIZA_DDAS_NVO .. '||SQLERRM;
                  RETURN;
              END;
            END LOOP;
            CLOSE C_VLRES_DDAS_TMP;
            BEGIN
              PRC_NUEVO_SINIESTRO(SOLICITUD,
                                  FECHA_MORA,
                                  SINIESTRO,
                                  EST_SNSTRO,
                                  FECHA_DSCPCION,
                                  AMPARO,
                                  POLIZA,
                                  CLASE,
                                  RAMO,
                                  N_SINIESTRO,
                                  N_FECHA_MRA);
              BEGIN
                PRC_BORRA_RCPRCNES(SOLICITUD,N_FECHA_MORA);
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := 'Error en PRC_BORRA_RCPRCNES .. '||SQLERRM;
                  RETURN;
              END; 
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error en PRC_NUEVO_SINIESTRO .. '||SQLERRM;
                RETURN;
            END;
          END IF;
        END IF;
        
        BEGIN
          PRC_INSERT_VLRES_DDAS_TMP(RAMO,
                                    SINIESTRO,
                                    SOLICITUD,
                                    'N'); 
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'Error en PRC_INSERT_VLRES_DDAS_TMP .. '||SQLERRM;
            RETURN;       
        END;
        
        BEGIN
          PRC_BORRA_LQDCNES(SOLICITUD,FECHA_MORA);
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'Error en PRC_BORRA_LQDCNES .. '||SQLERRM;
            RETURN;
        END;
        
        IF EST_SNSTRO = '05' THEN
          BEGIN
            UPDATE ORDNES_PGO O
               SET O.OPG_ESTDO_PGO = '00'
             WHERE O.OPG_NMRO_SLCTUD = SOLICITUD
               AND O.OPG_NMRO_SNSTRO = SINIESTRO
               AND O.opg_fcha_estdo =
                   (SELECT MAX(OD.OPG_FCHA_ESTDO)
                      FROM ordnes_pgo OD
                     WHERE OD.OPG_NMRO_SLCTUD = O.OPG_NMRO_SLCTUD
                       AND OD.OPG_NMRO_SNSTRO = O.OPG_NMRO_SNSTRO);
          EXCEPTION
            WHEN OTHERS THEN
              P_MENSAJE := 'Error actualizando en la tabla ORDNES_PGO..' ||SQLERRM;
              RETURN;
          END;
        END IF;
        
        -- Verifica si se generó la liquidción MANTIS 52464 GGM 16/03/2017
        -- MANTIS 56162 ACTUALIZAR LA LIQUIDACION 
        V_ORIGEN := 'G';
      
        IF N_FECHA_MRA IS NOT NULL THEN
          FCHA_MRA := N_FECHA_MRA;
        ELSE
          FCHA_MRA := FECHA_MORA;
        END IF;
        -- MANTIS 54492 
        BEGIN
          V_FECHA := PKG_SINIESTROS.FUN_FECHA_PAGO(SOLICITUD,
                                                   FCHA_MRA,
                                                   POLIZA,
                                                   CLASE,
                                                   RAMO,
                                                   PRDO);

          IF TO_CHAR(V_FECHA, 'MMYYYY') != TO_CHAR(V_FECHA_PAGO, 'MMYYYY') THEN
            FECHA_PAGO := V_FECHA_PAGO;
          ELSE
            FECHA_PAGO := V_FECHA;
          END IF;
      
          SELECT COUNT(8)
            INTO EXISTE
            FROM LQDCNES,LQDCNES_DTLLE, VLRES_LQDCION, VLRES_PRDCTO
           WHERE LQT_NMRO_SLCTUD = SOLICITUD
             AND LQT_FCHA_MRA = FCHA_MRA
             AND LQD_FCHA_PGO = FECHA_PAGO
             AND LQT_ESTDO_LQDCION = '01'
             AND LQD_NMRO_SLCTUD = LQT_NMRO_SLCTUD
             AND LQD_TPO_LQDCION = LQT_TPO_LQDCION
             AND LQD_PRDO = LQT_PRDO
             AND VLQ_NMRO_SLCTUD = LQT_NMRO_SLCTUD
             AND VLQ_TPO_LQDCION = LQT_TPO_LQDCION
             AND VLQ_PRDO = LQT_PRDO
             AND VLQ_SERIE = LQT_SERIE
             AND VLQ_RAM_CDGO = LQT_RAM_CDGO
             AND VLQ_VLOR != 0
             AND VLQ_ORGEN = V_ORIGEN
             AND VLQ_CNCPTO_VLOR = VPR_CDGO
             AND VPR_ESTDO_CNTA = 'S';
          IF NVL(EXISTE,0) = 0 THEN
            P_MENSAJE := 'No generó la liquidación de pago para el periodo..'||SOLICITUD||' / '||FECHA_PAGO||' / '||FCHA_MRA||' / '||V_ORIGEN;
            RETURN;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
          P_MENSAJE := 'Error en PKG_SINIESTROS.FUN_FECHA_PAGO..'||SQLERRM;
          RETURN;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := 'Error consultando el periodo de Subsanar...FUN_CONSULTA_PERIODO..'||SQLERRM;
          RETURN;
      END;
    EXCEPTION
      WHEN OTHERS THEN
        P_MENSAJE := 'Error consultando si existe pago..FUN_EXISTE_PAGO..'||SQLERRM;
        RETURN;
    END;
    
  END PRC_SUBSANAR;

END PKG_OBJETAR_SUBSANAR;
/
