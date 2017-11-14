CREATE OR REPLACE PACKAGE BODY admsisa.ObjetarSubsanar IS
  FUNCTION BuscarFechaPago(Snstro    NUMBER,
                           NmroPlza  NUMBER,
                           ClsePlza  VARCHAR2,
                           RamCdgo   VARCHAR2) RETURN DATE IS
    newFchaPgo DATE;
    prdo       VARCHAR2(6);
    -- GGM. 13/03/2012 PAGOS ANTICIPADOS
  BEGIN
    newFchaPgo := PKG_SINIESTROS.FUN_FECHA_PAGO(Snstro,NmroPlza,ClsePlza,RamCdgo,Prdo);
    RETURN(newFchaPgo);
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20001,'No se pudo Recuperar Fecha Pago.'||sqlerrm);

  END BuscarFechaPago;


  procedure ForeignKeys(p_table      in varchar2,
                        p_accion     in varchar2,
                        p_constraint in varchar2) is
    ds  number;
    str varchar2(200);
  begin
    ds  := dbms_sql.open_cursor;
    str := 'alter table ' || p_table || ' ' || p_accion || ' constraint ' ||
           p_constraint;
    dbms_sql.parse(ds, str, dbms_sql.native);
    dbms_sql.close_cursor(ds);
  end;
  FUNCTION CodgRecup(CdgoProduc VARCHAR2) RETURN VARCHAR2 IS
    CncptoBase VARCHAR2(10);
  BEGIN
    SELECT VPR_VLOR_BSE
      INTO CncptoBase
      FROM VLRES_PRDCTO
     WHERE VPR_CDGO = CdgoProduc;
    RETURN(CncptoBase);
  EXCEPTION
    WHEN no_data_found THEN
      CncptoBase := NULL;
      RETURN(CncptoBase);
      --Raise_application_error( -20002, 'No exite Concepto Base en VPR_VLOR_BSE para el concepto ' || CdgoProduc);
    WHEN too_many_rows THEN
      Raise_application_error(-20002,
                              'Mas de un Concepto Base en VPR_VLOR_BSE para el concepto ' ||
                              CdgoProduc);
  END CodgRecup;
  FUNCTION ConsultaPeriodo(CodgoAmpro   VARCHAR2,
                           Poliza       NUMBER,
                           Ramo         VARCHAR2,
                           Clase        VARCHAR2,
                           FchaObjecion DATE,
                           FchaSubsn    DATE) RETURN VARCHAR IS
    Periodo    prmtros.par_rfrncia%TYPE;
    PeriodoSub prmtros.par_rfrncia%TYPE;
    LimPago    DATE;
    vContar    NUMBER := 0;
  BEGIN
    SELECT par_rfrncia
      INTO Periodo
      FROM prmtros
     WHERE par_cdgo = '1' AND par_vlor1 = '1' AND par_mdlo = '6';
    gPeriodoNew := Periodo;
    /* Se compara la fecha Objecion para validar si hay 1,2 o mas periodos*/
    -- GGM. 13/03/2012  PAGOS ANTICIPADOS
    /*SELECT MIN(FPP_FCHA_PGO)
      INTO LimPago
      FROM fchas_pgo_plzas
     WHERE FPP_ESTDO = 'V' AND FPP_NMRO_PLZA = Poliza AND
           FPP_FCHA_PGO > To_date('01/02/1990', 'DD/MM/YYYY');*/
    LimPago := PKG_SINIESTROS.FUN_FECHA_POLIZA(Poliza,Clase,Ramo);
    PeriodoSub := To_char(FchaObjecion, 'MMYYYY');
    gPeriodo   := PeriodoSub;
    IF CodgoAmpro = '01' AND Periodo = PeriodoSub AND FchaSubsn < LimPago THEN
      RETURN 'PERIODO1';
    ELSIF CodgoAmpro = '01' AND Periodo = PeriodoSub AND
          FchaSubsn > LimPago THEN
      RETURN 'PERIODO2';
    ELSIF CodgoAmpro = '01' THEN
      PeriodoSub := To_char(Add_months(FchaObjecion, 1), 'MMYYYY');
      IF Periodo = PeriodoSub AND FchaSubsn < LimPago THEN
        RETURN 'PERIODO2';
      ELSE
        Raise_application_error(-20003,
                                Periodo || '/' ||
                                To_char(FchaObjecion, 'DDMMYYYY') ||
                                '/Se ha superado el limite de periodos para subsanar. <ConsultaPeriodo> ');
      END IF;
    ELSIF CodgoAmpro <> '01' THEN
      /*Si el codigo del amparo es diferente a 01 se debe generar error superando 6 periodos */
      LOOP
        vContar := vContar + 1;

--        IF vContar < 13 AND Periodo = PeriodoSub AND FchaSubsn < LimPago THEN
        IF vContar < 13 AND Periodo = PeriodoSub THEN
          RETURN 'SERVICIOS';
          EXIT;
        ELSIF vContar = 13 THEN
          Raise_application_error(-20053,
                                  Periodo || '/' || PeriodoSub || '/' ||
                                  To_char(FchaObjecion, 'DDMMYYYY') ||
                                  To_char(FchaSubsn, 'DDMMYYYY') ||
                                  To_char(LimPago, 'DDMMYYYY') ||
                                  '/Se ha superado el limite de periodos para subsanar servicios. <ConsultaPeriodo> ');
          EXIT;
        END IF;
        -- Se quita el comentario de la linea donde maneja el vContar porque es la que va sumando
        -- Queda pendiente el caso del porque lo cambiaron a 1 GGM. 16032011
        --PeriodoSub := To_char(Add_months(FchaObjecion, 1), 'MMYYYY');
        PeriodoSub := To_char(Add_months(FchaObjecion, vContar), 'MMYYYY');
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20003,
                              'Error al consultar ConsultaPeriodo. ' ||
                              SQLERRM);
  END ConsultaPeriodo;
  PROCEDURE CambiarEstadoSiniest(Ramo       VARCHAR2,
                                 Siniestro  NUMBER,
                                 EstdPgo    VARCHAR2,
                                 EstdSnstro VARCHAR2) IS
  BEGIN
    UPDATE AVSOS_SNSTROS
       SET SNA_ESTDO_PGO    = EstdPgo,
           SNA_ESTDO_SNSTRO = DECODE(EstdSnstro,
                                     NULL,
                                     SNA_ESTDO_SNSTRO,
                                     EstdSnstro),
           SNA_FCHA_ESTDO   = SYSDATE,
           SNA_USRIO        = LOWER(USER)
     WHERE SNA_RAM_CDGO = Ramo AND SNA_NMRO_SNSTRO = Siniestro;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20004,
                              'Error actualizando el estado en AVSOS_SNSTROS ' ||
                              SQLERRM);
  END CambiarEstadoSiniest;
  PROCEDURE InsertarNvoPgoSnstros(RamCdgo       VARCHAR2,
                                  NmroSnstro    NUMBER,
                                  FchaPgo       DATE,
                                  NmroSnstroNew NUMBER) IS
  BEGIN
    INSERT INTO PGOS_EFCTDOS_SNSTROS
      SELECT PES_FCHA_PGO,
             PES_NMRO_PLZA,
             PES_CLSE_PLZA,
             PES_RAM_CDGO,
             NmroSnstroNew,
             PES_VLOR_PGDO,
             PES_VLOR_SNSTRO,
             PES_VLOR_RCPRCNES,
             PES_FCHA_DSDE,
             PES_FCHA_HSTA,
             PES_NMRO_DIAS,
             PES_TPO_PAGO,
             PES_USRIO,
             PES_FCHA_MDFCCION
        FROM PGOS_EFCTDOS_SNSTROS
       WHERE PES_FCHA_PGO < FchaPgo AND PES_RAM_CDGO = RamCdgo AND
             PES_NMRO_SNSTRO = NmroSnstro;
    UPDATE VLRES_PGO_EFCTDOS
       SET VPE_NMRO_SNSTRO = NmroSnstroNew
     WHERE VPE_RAM_CDGO = RamCdgo AND VPE_NMRO_SNSTRO = NmroSnstro AND
           VPE_FCHA_PGO < FchaPgo;
    DELETE PGOS_EFCTDOS_SNSTROS
     WHERE PES_FCHA_PGO < FchaPgo AND PES_RAM_CDGO = RamCdgo AND
           PES_NMRO_SNSTRO = NmroSnstro;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20006,
                              'Error en procedimiento InsertarNvoPgoSnstros' ||
                              SQLERRM);
  END InsertarNvoPgoSnstros;

  PROCEDURE CambiarEstadoLiquid(Ramo          VARCHAR2,
                                Siniestro     NUMBER,
                                Estado        VARCHAR2,
                                SumMes        NUMBER,
                                NmroSnstroNew NUMBER,
                                Periodo       VARCHAR2,
                                PeriodoNew    VARCHAR2,
                                NmroSlctud    NUMBER) IS
    PeriodoN  varchar2(6);
  BEGIN
    dbms_output.put_line('ENTRO UPDATE');
    IF gInserto = 'N' THEN
      dbms_output.put_line('ENTRO IF UPDATE ' ||Ramo||' - '||Siniestro||' - '||SumMes||' - '||NmroSnstroNew||' - '||Periodo||' - '||PeriodoNew||' - '||NmroSlctud);
      UPDATE LQDCNES_DTLLE
         SET LQT_ESTDO_LQDCION = DECODE(LQT_ESTDO_LQDCION,
                                        '03',
                                        '03',
                                        Estado),
             LQT_FCHA_MRA      = Add_months(LQT_FCHA_MRA, SumMes),
             LQT_NMRO_SNSTRO   = Nvl(NmroSnstroNew, LQT_NMRO_SNSTRO),
             LQT_PRDO          = DECODE(LQT_ESTDO_LQDCION,
                                        '03',
                                        Periodo,
                                        NVL(PeriodoNew, LQT_PRDO)),
             LQT_TPO_LQDCION   = DECODE(Siniestro,
                                        NmroSnstroNew,
                                        '01',
                                        LQT_TPO_LQDCION)
       WHERE LQT_NMRO_SNSTRO = Siniestro /*DECODE(gInserto,'I',NmroSnstroNew,Siniestro)*/
             AND LQT_RAM_CDGO = Ramo AND
             LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
             (LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE) IN
             (SELECT VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE
                FROM VLRES_LQDCION, VLRES_PRDCTO
               WHERE VPR_CDGO = VLQ_CNCPTO_VLOR AND
                     VLQ_NMRO_SLCTUD = NmroSlctud AND
                     NVL(VPR_VLOR_BSE, '=') <> DECODE(SumMes, 0, '=', '*'));
      IF SQL%NOTFOUND THEN
        Raise_application_error(-20007,'Error actualizando la liquidación en suspendido - CambiarEstadoLiquid' ||SQLERRM);
      END IF;
      gInserto := 'A';
    ELSE
      dbms_output.put_line('SEGUNDO INSERT  ' || Estado);
      UPDATE LQDCNES_DTLLE
         SET LQT_ESTDO_LQDCION = DECODE(LQT_ESTDO_LQDCION,
                                        '03',
                                        '03',
                                        Estado),
             LQT_FCHA_MRA      = Add_months(LQT_FCHA_MRA, SumMes),
             LQT_NMRO_SNSTRO   = Nvl(NmroSnstroNew, LQT_NMRO_SNSTRO),
             LQT_PRDO          = DECODE(LQT_ESTDO_LQDCION,
                                        '03',
                                        Periodo,
                                        NVL(PeriodoNew, LQT_PRDO)),
             LQT_TPO_LQDCION   = DECODE(Siniestro,
                                        NmroSnstroNew,
                                        '01',
                                        LQT_TPO_LQDCION)
       WHERE LQT_NMRO_SNSTRO = Siniestro /*DECODE(gInserto,'I',NmroSnstroNew,Siniestro)*/
             AND LQT_RAM_CDGO = Ramo AND LQT_ESTDO_LQDCION = '03' AND
             (LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE) IN
             (SELECT VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, periodo, VLQ_SERIE
                FROM VLRES_LQDCION, VLRES_PRDCTO
               WHERE VPR_CDGO = VLQ_CNCPTO_VLOR AND
                     VLQ_NMRO_SLCTUD = NmroSlctud AND
                     NVL(VPR_VLOR_BSE, '=') <> DECODE(SumMes, 0, '*', '*'));
--      IF SQL%NOTFOUND THEN
--        Raise_application_error(-20008,'Error actualizando la liquidación en suspendido - CambiarEstadoLiquid' ||SQLERRM);
--      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -2292 THEN
        BEGIN
          INSERT INTO LQDCNES_DTLLE
            SELECT LQT_NMRO_SLCTUD,
                   DECODE(Siniestro, NmroSnstroNew, '01', LQT_TPO_LQDCION),
                   NVL(PeriodoNew, LQT_PRDO),
                   LQT_SERIE,
                   DECODE(LQT_FCHA_DSDE,
                          LQT_FCHA_HSTA,
                          LQT_FCHA_DSDE,
                          Add_months(LQT_FCHA_DSDE, SumMes)),
                   DECODE(LQT_FCHA_HSTA,
                          LQT_FCHA_DSDE,
                          LQT_FCHA_HSTA,
                          Add_months(LQT_FCHA_HSTA, SumMes)),
                   LQT_NMRO_DIAS,
                   DECODE(LQT_ESTDO_LQDCION, '03', '03', Estado),
                   LQT_USER,
                   LQT_FCHA_MDFCCION,
                   Add_months(LQT_FCHA_MRA, SumMes),
                   Nvl(NmroSnstroNew, LQT_NMRO_SNSTRO),
                   LQT_RAM_CDGO
              FROM LQDCNES_DTLLE
             WHERE LQT_NMRO_SNSTRO = Siniestro AND LQT_RAM_CDGO = Ramo AND
                   LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
                   LQT_PRDO LIKE DECODE(SumMes, 0, PeriodoNew, '%');
          gInserto := 'A';
          dbms_output.put_line('TTTTTTTTTTTTTTTTTTTTTTTT' ||
                               To_char(NmroSnstroNew));
        EXCEPTION
          WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
              NULL;
            ELSE
              Raise_application_error(-20005,
                                      'Error al insertar el estado en LQDCNES_DTLLE ' ||
                                      SQLERRM);
            END IF;
        END;
      ELSIF SQLCODE = -2291 THEN
         begin
           --SELECT MAX(LQD_PRDO) INTO PeriodoN DAP. No se puede comparar char mmyyyy directamente.
            select substr(to_char(max(to_number(substr(lqd_prdo,3,4)||substr(lqd_prdo,1,2)))),5,2)||
                  substr(to_char(max(to_number(substr(lqd_prdo,3,4)||substr(lqd_prdo,1,2)))),1,4)
              INTO PeriodoN
             FROM LQDCNES
            WHERE LQD_NMRO_SLCTUD = NmroSlctud;
            exception when others then
                          Raise_application_error(-20005,
                                      'Error al consultar periodo  en LQDCNES ' ||
                                      SQLERRM);
         end;
         if PeriodoN <> PeriodoNew then
            null;
         else
            PeriodoN := PeriodoNew;
         end if;

        BEGIN
          UPDATE LQDCNES_DTLLE
             SET LQT_ESTDO_LQDCION = DECODE(LQT_ESTDO_LQDCION,
                                            '03',
                                            '03',
                                            Estado),
                 LQT_FCHA_MRA      = Add_months(LQT_FCHA_MRA, SumMes),
                 LQT_NMRO_SNSTRO   = Nvl(NmroSnstroNew, LQT_NMRO_SNSTRO),
                 LQT_PRDO          = DECODE(LQT_ESTDO_LQDCION,
                                            '03',
                                            Periodo,
                                            NVL(PeriodoN, LQT_PRDO))
           WHERE LQT_NMRO_SNSTRO = Siniestro AND LQT_RAM_CDGO = Ramo AND
                 LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
                 (LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE) IN
                 (SELECT VLQ_NMRO_SLCTUD,
                         VLQ_TPO_LQDCION,
                         VLQ_PRDO,
                         VLQ_SERIE
                    FROM VLRES_LQDCION, VLRES_PRDCTO
                   WHERE VPR_CDGO = VLQ_CNCPTO_VLOR AND
                         VLQ_NMRO_SLCTUD = NmroSlctud AND
                         NVL(VPR_VLOR_BSE, '=') <>
                         DECODE(Estado, 0, '*', '*'));
          gInserto := 'A';
          dbms_output.put_line('XXXXXXXXXXXXXXXXXXXX' ||To_char(NmroSnstroNew));
        EXCEPTION
          WHEN OTHERS THEN
            BEGIN
            UPDATE LQDCNES_DTLLE
             SET LQT_ESTDO_LQDCION = DECODE(LQT_ESTDO_LQDCION,
                                            '03',
                                            '03',
                                            Estado),
                 LQT_FCHA_MRA      = Add_months(LQT_FCHA_MRA, SumMes),
                 LQT_NMRO_SNSTRO   = Nvl(NmroSnstroNew, LQT_NMRO_SNSTRO),
                 LQT_PRDO          = DECODE(LQT_ESTDO_LQDCION,
                                            '03',
                                            Periodo,
                                            NVL(PeriodoNew, LQT_PRDO))
           WHERE LQT_NMRO_SNSTRO = Siniestro AND LQT_RAM_CDGO = Ramo AND
                 LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
                 (LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE) IN
                 (SELECT VLQ_NMRO_SLCTUD,
                         VLQ_TPO_LQDCION,
                         VLQ_PRDO,
                         VLQ_SERIE
                    FROM VLRES_LQDCION, VLRES_PRDCTO
                   WHERE VPR_CDGO = VLQ_CNCPTO_VLOR AND
                         VLQ_NMRO_SLCTUD = NmroSlctud AND
                         NVL(VPR_VLOR_BSE, '=') <>
                         DECODE(Estado, 0, '*', '*'));
          gInserto := 'A';
          dbms_output.put_line('XXXXXXXXXXXXXXXXXXXX' ||To_char(NmroSnstroNew));

            EXCEPTION
              WHEN OTHERS THEN
                Raise_application_error(-20005,'Error en paso2 actualizando el estado en LQDCNES_DTLLE ' ||PeriodoNew ||SQLERRM);
            END;
        END;
      ELSIF SQLCODE = -1 THEN
        NULL;
      ELSIF SQLCODE = -20502 THEN
       BEGIN
                 INSERT INTO LQDCNES_DTLLE
            SELECT LQT_NMRO_SLCTUD,
                   DECODE(Siniestro, NmroSnstroNew, '01', LQT_TPO_LQDCION),
                   NVL(PeriodoNew, LQT_PRDO),
                   LQT_SERIE,
                   DECODE(LQT_FCHA_DSDE,
                          LQT_FCHA_HSTA,
                          LQT_FCHA_DSDE,
                          Add_months(LQT_FCHA_DSDE, SumMes)),
                   DECODE(LQT_FCHA_HSTA,
                          LQT_FCHA_DSDE,
                          LQT_FCHA_HSTA,
                          Add_months(LQT_FCHA_HSTA, SumMes)),
                   LQT_NMRO_DIAS,
                   DECODE(LQT_ESTDO_LQDCION, '03', '03', Estado),
                   LQT_USER,
                   LQT_FCHA_MDFCCION,
                   Add_months(LQT_FCHA_MRA, SumMes),
                   Nvl(NmroSnstroNew, LQT_NMRO_SNSTRO),
                   LQT_RAM_CDGO
              FROM LQDCNES_DTLLE
             WHERE LQT_NMRO_SNSTRO = Siniestro AND LQT_RAM_CDGO = Ramo AND
                   LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
                   LQT_PRDO LIKE DECODE(SumMes, 0, PeriodoNew, '%');
          gInserto := 'A';
          dbms_output.put_line('TTTTTTTTTTTTTTTTTTTTTTTT' ||
                               To_char(NmroSnstroNew));
       EXCEPTION
         WHEN OTHERS THEN
          Raise_application_error(-20005,
                                'Error actualizando el estado en LQDCNES_DTLLE ' ||
                                SQLERRM);
       END;
      ELSE
        Raise_application_error(-20009,
                                'Error actualizando en LQDCNES_DTLLE ' ||Ramo||' - '||Siniestro||' - '||SumMes||' - '||NmroSnstroNew||' - '||Periodo||' - '||PeriodoNew||' - '||NmroSlctud||' - '||
                                SQLERRM);

      END IF;
  END CambiarEstadoLiquid;
  PROCEDURE CambiarSnstro(Ramo       VARCHAR2,
                          Siniestro  NUMBER,
                          CodgoAmpro VARCHAR2) IS
  BEGIN
    UPDATE OBJCNES_SNSTROS
       SET OBS_FCHA_SBSNCION = TRUNC(SYSDATE), OBS_SUBSANA = 'S'
     WHERE OBS_CDGO_AMPRO = CodgoAmpro AND OBS_NMRO_SNSTRO = Siniestro AND
           OBS_RAM_CDGO = Ramo and OBS_FCHA_SBSNCION IS NULL;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20006,
                              'Error actualizando el estado en OBJCNES_SNSTROS ' ||
                              SQLERRM);
  END CambiarSnstro;
  PROCEDURE BorrarDetLiquid(Ramo VARCHAR2, NmroSlctud NUMBER) IS
  BEGIN
    DELETE LQDCNES_DTLLE
     WHERE LQT_NMRO_SLCTUD = NmroSlctud AND LQT_RAM_CDGO = Ramo AND
           (LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE) NOT IN
           (SELECT VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE
              FROM VLRES_LQDCION
             WHERE VLQ_NMRO_SLCTUD = NmroSlctud);
    DELETE LQDCNES
     WHERE LQD_NMRO_SLCTUD = NmroSlctud AND
           (LQD_NMRO_SLCTUD, LQD_TPO_LQDCION, LQD_PRDO) NOT IN
           (SELECT LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO
              FROM LQDCNES_DTLLE
             WHERE LQT_NMRO_SLCTUD = NmroSlctud AND LQT_RAM_CDGO = Ramo);
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20006,
                              'Error Borrando <<LQDCNES_DTLLE>> ' ||
                              SQLERRM);
  END BorrarDetLiquid;
  PROCEDURE CambiarEstadoDdasVigt(FchaMora  DATE,
                                  Solicitud NUMBER,
                                  Estado    VARCHAR2) IS
  BEGIN
    UPDATE DDAS_VGNTES_ARRNDMNTOS
       SET DVA_ESTDO = Estado
     WHERE DVA_NMRO_SLCTUD = Solicitud AND DVA_FCHA_MRA = FchaMora;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20007,
                              'Error actualizando el estado en DDAS_VGNTES_ARRNDMNTOS ' ||
                              SQLERRM);
  END CambiarEstadoDdasVigt;
  PROCEDURE CambiarEstadoCasosCbrza(FchaMora  DATE,
                                    Solicitud NUMBER,
                                    Estado    VARCHAR2) IS
  BEGIN
    UPDATE CASOS_CBRNZA
       SET CSC_ESTDO_CBRANZA = Estado
     WHERE CSC_NMRO_SLCTUD = Solicitud AND CSC_FCHA_MRA = FchaMora;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20008,
                              'Error actualizando el estado en  CASOS_CBRNZA ' ||
                              SQLERRM);
  END CambiarEstadoCasosCbrza;
  /*** Crear el nuevo siniestro ***/
  PROCEDURE InsertDdasVgtes(NmroSlctud   NUMBER,
                            FchaMora     DATE,
                            ValorDesface NUMBER) IS
  BEGIN
    INSERT INTO DDAS_VGNTES_ARRNDMNTOS
      SELECT DVA_NMRO_SLCTUD,
             Add_months(DVA_FCHA_MRA, 1),
             DVA_DIAS_DSFSE + 30,
             DVA_VLOR_DSFSE + ValorDesface,
             NULL,
             DVA_RPRTDO_CBRNZA,
             Lower(USER),
             SYSDATE,
             DVA_FCHA_ULTMO_PGO,
             '01',
             NULL,NULL,NULL
        FROM DDAS_VGNTES_ARRNDMNTOS
       WHERE DVA_NMRO_SLCTUD = NmroSlctud AND DVA_FCHA_MRA = FchaMora;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20009,
                              'Error insertando en la tabla  DDAS_VGNTES_ARRNDMNTOS ' ||
                              SQLERRM);
  END InsertDdasVgtes;
  PROCEDURE InsertAvsosSnstros(RamCdgo       VARCHAR2,
                               NmroSnstro    NUMBER,
                               NmroSnstroNew NUMBER) IS
  BEGIN
    INSERT INTO AVSOS_SNSTROS
      SELECT SNA_NMRO_ITEM,
             NmroSnstroNew,
             SNA_CAUSA_SNSTRO,
             SNA_NMRO_PLZA,
             SNA_CLSE_PLZA,
             SNA_RAM_CDGO,
             SYSDATE,
             Add_months(SNA_FCHA_SNSTRO, 1),
             SNA_VLOR_AVSDO,
             SNA_VLOR_CNSTTDO,
             SNA_VLOR_PGDO,
             '01',
             '02',
             SNA_VLOR_GSTOS,
             SNA_FCHA_ESTDO,
             SNA_VLOR_SLVMNTO_RCBRO,
             SNA_NMRO_CRTFCDO,
             Lower(USER),
             SYSDATE,
             SNA_FCHA_ULTMO_PGO,
             SNA_DSCRPCION_ESTDO,
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
       WHERE SNA_NMRO_SNSTRO = NmroSnstro AND SNA_RAM_CDGO = RamCdgo;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20010,
                              'Error insertando en la tabla  DDAS_VGNTES_ARRNDMNTOS ' ||
                              SQLERRM);
  END InsertAvsosSnstros;
  PROCEDURE InsertVlresSnstros(NmroSnstro    NUMBER,
                               NmroSnstroNew NUMBER) IS
  BEGIN
    INSERT INTO VLRES_SNSTROS
      SELECT VSN_CNCPTO_VLOR,
             NmroSnstroNew,
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
       WHERE VSN_NMRO_SNSTRO = NmroSnstro;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20011,
                              'Error insertando en la tabla  VLRES_SNSTROS  ' ||
                              SQLERRM);
  END InsertVlresSnstros;
  PROCEDURE InsertAmprosSnstros(RamCdgo       VARCHAR2,
                                NmroSnstro    NUMBER,
                                NmroSnstroNew NUMBER) IS
  BEGIN
    INSERT INTO AMPROS_SNSTROS
      SELECT NmroSnstroNew,
             AMS_CDGO_AMPRO,
             AMS_RAM_CDGO,
             AMS_NMRO_ITEM,
             Add_months(AMS_FCHA_MRA, 1),
             AMS_NMRO_CRTFCDO,
             AMS_CDGO_CAUSA,
             AMS_VLOR_AVSDO,
             AMS_VLOR_CNSTTDO,
             AMS_VLOR_PGDO,
             AMS_ESTDO,
             Lower(USER),
             SYSDATE
        FROM AMPROS_SNSTROS
       WHERE AMS_NMRO_SNSTRO = NmroSnstro AND AMS_RAM_CDGO = RamCdgo;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20012,
                              'Error insertando en la tabla  AMPROS_SNSTROS  ' ||
                              SQLERRM);
  END InsertAmprosSnstros;
  PROCEDURE InsertVlresDdas(RamCdgo       VARCHAR2,
                            CodgoAmpro    VARCHAR2,
                            NmroSnstro    NUMBER,
                            NmroSlctud    NUMBER,
                            ValorDesface  NUMBER,
                            NmroSnstroNew NUMBER) IS
  BEGIN
    /*** Inserta o actualiza concepto de desface RE01 ***/
    INSERT INTO VLRES_DDAS
      SELECT VLD_NMRO_SLCTUD,
             Add_months(VLD_FCHA_MRA, 1),
             VLD_RAM_CDGO,
             'RE01',
             NmroSnstroNew,
             VLD_CDGO_AMPRO,
             0,
             ValorDesface,
             0,
             Lower(USER),
             SYSDATE,
             VLD_ORGEN,
             1
        FROM VLRES_DDAS
       WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
             VLD_NMRO_SNSTRO = NmroSnstro AND VLD_NMRO_SLCTUD = NmroSlctud AND
             ROWNUM = 1;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -1 THEN
        BEGIN
          UPDATE VLRES_DDAS
             SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO + ValorDesface,
                 VLD_FCHA_MRA     = Add_months(VLD_FCHA_MRA, 1),
                 VLD_NMRO_SNSTRO  = NmroSnstroNew
           WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                 VLD_NMRO_SNSTRO = NmroSnstro AND
                 VLD_NMRO_SLCTUD = NmroSlctud AND VLD_CNCPTO_VLOR = 'RE01';
        EXCEPTION
          WHEN OTHERS THEN
            Raise_application_error(-20013,
                                    'Error Actualizando Concepto <<RE01>> en la tabla  VLRES_DDAS. ' ||
                                    SQLERRM);
        END;
      ELSE
        Raise_application_error(-20013,
                                'Error insertando Concepto <<RE01>> en la tabla  VLRES_DDAS  ' ||
                                SQLERRM);
      END IF;
  END InsertVlresDdas;
  PROCEDURE InsertAmntosSnstros(RamCdgo       VARCHAR2,
                                CodgoAmpro    VARCHAR2,
                                NmroSnstro    NUMBER,
                                NmroSnstroNew NUMBER) IS
  BEGIN
    INSERT INTO AMNTOS_SNSTROS
      SELECT NmroSnstroNew,
             AMN_RAM_CDGO,
             AMN_CDGO_AMPRO,
             Add_months(AMN_FCHA_AMNTO, 1),
             AMN_CNCPTO,
             AMN_VLOR,
             AMN_VLOR_FRA,
             AMN_SLCTUD,
             Add_months(AMN_FCHA_MRA, 1),
             Lower(USER),
             DECODE(TO_CHAR(AMN_FCHA_ACTLZCION,'DD'),'01',Add_months(AMN_FCHA_AMNTO, 1),AMN_FCHA_ACTLZCION),
             AMN_OBSRVCION
        FROM AMNTOS_SNSTROS
       WHERE AMN_CDGO_AMPRO = CodgoAmpro AND AMN_NMRO_SNSTRO = NmroSnstro AND
             AMN_RAM_CDGO = RamCdgo;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20014,
                              'Error insertando en la tabla  AMNTOS_SNSTROS  ' ||
                              SQLERRM);
  END InsertAmntosSnstros;
  PROCEDURE InsertDdasArrndtrios(FchaMora DATE, NmroSlctud NUMBER) IS
  BEGIN
    INSERT INTO DDAS_ARRNDTRIOS
      SELECT DAR_NMRO_SLCTUD,
             Add_months(DAR_FCHA_MRA, 1),
             DAR_TPO_ARRNDTRIO,
             DAR_TPO_IDNTFCCION,
             DAR_NMRO_IDNTFCCION,
             DAR_NMRO_PLZA,
             DAR_CLSE_PLZA,
             DAR_RAM_CDGO
        FROM DDAS_ARRNDTRIOS
       WHERE DAR_NMRO_SLCTUD = NmroSlctud AND DAR_FCHA_MRA = FchaMora AND
             DAR_TPO_ARRNDTRIO <> 'arrendatario';
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20015,
                              'Error insertando en la tabla  DDAS_ARRNDTRIOS  ' ||
                              SQLERRM);
  END InsertDdasArrndtrios;
  PROCEDURE InsertCasosCbrnza(FchaMora DATE, NmroSlctud NUMBER) IS
  BEGIN
    INSERT INTO CASOS_CBRNZA
      SELECT CSC_CDGO_CBRDOR,
             CSC_NMRO_SLCTUD,
             Add_months(CSC_FCHA_MRA, 1),
             CSC_FCHA_ASGNCION,
             CSC_FCHA_APRTRA,
             CSC_ESTDO_CBRANZA,
             CSC_TPO_CBRNZA,
             Lower(USER),
             SYSDATE
        FROM CASOS_CBRNZA
       WHERE CSC_NMRO_SLCTUD = NmroSlctud and CSC_FCHA_MRA = FchaMora;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20016,
                              'Error insertando en la tabla  CASOS_CBRNZA  ' ||
                              SQLERRM);
  END InsertCasosCbrnza;
  FUNCTION GenerarNumeroSiniestro(Accion VARCHAR2) RETURN NUMBER IS
    NumSnstroNew NUMBER;
  BEGIN
    -- SE CAMBIO POR LA FUNCION PORQUE EN LAS PRUEBAS DE PAGOS ANTICIPADOS SE QUEDABA PEGADO
    -- EL NUMERO DE SINIESTRO Y NO LO ACTUALIZABA GGM. 16/07/2012

    /*IF Accion = 'S' THEN
      SELECT NMS_ULTMO_SNSTRO_ASGNDO + 1
        INTO NumSnstroNew
        FROM NMRCION_SNSTROS;
      RETURN NumSnstroNew;
    ELSE
      UPDATE NMRCION_SNSTROS
         SET NMS_ULTMO_SNSTRO_ASGNDO = NMS_ULTMO_SNSTRO_ASGNDO + 1;
      RETURN 0;
    END IF;*/
    IF Accion = 'S' THEN
      NumSnstroNew := f_nmrcion_snstros('12');
      RETURN NumSnstroNew;
    ELSE
      RETURN 0;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 1;
      Raise_application_error(-20017,
                              'Error tomando numracion siniestro en la tabla NMRCION_SNSTROS ' ||
                              SQLERRM);
  END GenerarNumeroSiniestro;
  /*** Fin del los procedimiento del nuevo siniestro ***/
  PROCEDURE CambiaReferenciaRecibos(NmroSlctud NUMBER,
                                    NmroPlza   NUMBER,
                                    FchaMora   DATE) IS
    Referencia    VARCHAR2(50);
    ReferenciaNew VARCHAR2(50);
  BEGIN
    Referencia    := rpad(to_char(NmroSlctud), 10, ' ') ||
                     to_char(FchaMora, 'DD/MM/YYYY') || to_char(NmroPlza);
    ReferenciaNew := rpad(to_char(NmroSlctud), 10, ' ') ||
                     to_char(Add_months(FchaMora, 1), 'DD/MM/YYYY') ||
                     to_char(NmroPlza);
    INSERT INTO DTLLES_RCBOS_CJA
      SELECT ReferenciaNew,
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
       WHERE DRC_RFRNCIA = Referencia;
    INSERT INTO CNCPTOS_DTLLE_RCBOS
      SELECT ReferenciaNew,
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
       WHERE CDR_RFRNCIA = Referencia;
    DELETE CNCPTOS_DTLLE_RCBOS WHERE CDR_RFRNCIA = Referencia;
    DELETE DTLLES_RCBOS_CJA WHERE DRC_RFRNCIA = Referencia;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20040,
                              'Error en Detalle y Conceptos Recibos de Caja ' ||
                              SQLERRM);
  END CambiaReferenciaRecibos;
  PROCEDURE DevolcionContrato(NmroSnstro NUMBER, Ramo VARCHAR2) IS
  BEGIN
    INSERT INTO CNTRTOS_DVLVER
    VALUES
      ('01',
       SYSDATE,
       NmroSnstro,
       Ramo,
       LOWER(USER),
       SYSDATE,
       'Devolucion de contrato por SUBSANACION',
       '3');
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20018,
                              'Error al insertar en  CNTRTOS_DVLVER ' ||
                              SQLERRM);
  END DevolcionContrato;
  PROCEDURE InsetLqdacion(NmroSlctud NUMBER,
                          Periodo    VARCHAR2,
                          PeriodoNew VARCHAR2,
                          FechaPago  DATE) IS
  BEGIN
    IF FechaPago IS NOT NULL THEN
      INSERT INTO LQDCNES
        SELECT LQD_NMRO_SLCTUD,
               DECODE(Periodo,
                      PeriodoNew,
                      DECODE(FechaPago, LQD_FCHA_PGO, LQD_TPO_LQDCION, '01'),
                      LQD_TPO_LQDCION),
               PeriodoNew,
               FechaPago,
               Lower(USER),
               TRUNC(SYSDATE)
          FROM LQDCNES
         WHERE LQD_NMRO_SLCTUD = NmroSlctud AND LQD_PRDO = Periodo AND
               ROWNUM < DECODE(Periodo, PeriodoNew, 2, 100);
    ELSE
      Raise_application_error(-20019,
                              'Error insertando tabla LQDCNES FechaPago NULA' ||
                              SQLERRM);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -1 THEN
        NULL;
      ELSE
        Raise_application_error(-20019,
                                'Error insertando o actualizando en la tabla LQDCNES ' ||
                                SQLERRM);
      END IF;
  END InsetLqdacion;
  PROCEDURE ActualizarLqdacion(NmroSlctud NUMBER,
                               Periodo    VARCHAR2,
                               FechaPago  DATE) IS
  BEGIN
    UPDATE LQDCNES
       SET LQD_FCHA_PGO      = FechaPago,
           LQD_USER          = Lower(USER),
           LQD_FCHA_MDFCCION = SYSDATE
     WHERE LQD_NMRO_SLCTUD = NmroSlctud AND LQD_PRDO = Periodo;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20039,
                              'Actualiza la tabla LQDCNES ' || SQLERRM);
  END ActualizarLqdacion;
  PROCEDURE ActlzaVloresLqdcion(ConcptVlor    VARCHAR2,
                                RamCdgo       VARCHAR2,
                                NmroSnstro    NUMBER,
                                Porcent       NUMBER, /*Estado VARCHAR2,*/
                                Periodo       VARCHAR2,
                                PeriodoNew    VARCHAR2,
                                NmroSnstroNew NUMBER,
                                NmroPlza      NUMBER,
                                ClsePlza      VARCHAR2,
                                NmroSlctud    NUMBER,
                                EstLiquid     VARCHAR2,
                                SumMes        NUMBER) IS
    /**** "Estado" <<03>> valida si se pago o esta en otro ****/
    FechaPago DATE;
  BEGIN
    /*** Si el estado es '03' es por estar en siguiente periodo ***/
    dbms_output.put_line(' periodo de detalle ' || PeriodoNew);
    FechaPago := BuscarFechaPago(NmroSnstroNew,
                                 NmroPlza,
                                 ClsePlza,
                                 RamCdgo);
    InsetLqdacion(NmroSlctud,
                  Periodo,
                  PeriodoNew,
                  FechaPago);
    CambiarEstadoLiquid(RamCdgo,
                        NmroSnstro,
                        EstLiquid,
                        SumMes,
                        NmroSnstroNew,
                        Periodo,
                        PeriodoNew,
                        NmroSlctud);
    IF gInserto IN ('B', 'A') THEN
      UPDATE VLRES_LQDCION
         SET VLQ_VLOR        = DECODE(RTRIM(VLQ_CNCPTO_VLOR),
                                      RTRIM(ConcptVlor),
                                      ROUND(VLQ_VLOR * Porcent, 2),
                                      VLQ_VLOR),
             VLQ_VLOR_ORGNAL = DECODE(VLQ_CNCPTO_VLOR,
                                      ConcptVlor,
                                      ROUND(VLQ_VLOR_ORGNAL * Porcent, 2),
                                      VLQ_VLOR_ORGNAL),
             VLQ_PRDO        = PeriodoNew,
             VLQ_TPO_LQDCION = DECODE(NmroSnstro,
                                      NmroSnstroNew,
                                      '01',
                                      VLQ_TPO_LQDCION)
       WHERE (VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE) IN
             (SELECT LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE
                FROM LQDCNES_DTLLE
               WHERE LQT_NMRO_SNSTRO IN (NmroSnstro, NmroSnstroNew) AND
                     LQT_RAM_CDGO = RamCdgo AND
                     LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
                     LQT_PRDO LIKE DECODE(SumMes, 0, PeriodoNew, '%'));
      IF gInserto = 'B' THEN
        UPDATE VLRES_LQDCION
           SET VLQ_VLOR        = DECODE(RTRIM(VLQ_CNCPTO_VLOR),
                                        RTRIM(ConcptVlor),
                                        ROUND(VLQ_VLOR * Porcent, 2),
                                        VLQ_VLOR),
               VLQ_VLOR_ORGNAL = DECODE(VLQ_CNCPTO_VLOR,
                                        ConcptVlor,
                                        ROUND(VLQ_VLOR_ORGNAL * Porcent, 2),
                                        VLQ_VLOR_ORGNAL),
               VLQ_PRDO        = Periodo
        --HOYVLQ_TPO_LQDCION = DECODE(NmroSnstro,NmroSnstroNew,'01',VLQ_TPO_LQDCION)
         WHERE (VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE) IN
               (SELECT LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE
                  FROM LQDCNES_DTLLE
                 WHERE LQT_NMRO_SNSTRO = NmroSnstroNew AND
                       LQT_RAM_CDGO = RamCdgo AND LQT_ESTDO_LQDCION = '03' AND
                       LQT_PRDO LIKE DECODE(SumMes, 0, PeriodoNew, '%'));
        IF SumMes = 1 THEN
          BorrarDetLiquid(RamCdgo, NmroSlctud);
          InsertarNvoPgoSnstros(RamCdgo,
                                NmroSnstro,
                                FechaPago,
                                NmroSnstroNew);
        END IF;
        gInserto := 'N';
      END IF;
      gInserto := 'B';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -2291 THEN
        BEGIN
          UPDATE VLRES_LQDCION
             SET VLQ_VLOR        = DECODE(VLQ_CNCPTO_VLOR,
                                          ConcptVlor,
                                          ROUND(VLQ_VLOR * Porcent, 2),
                                          VLQ_VLOR),
                 VLQ_VLOR_ORGNAL = DECODE(VLQ_CNCPTO_VLOR,
                                          ConcptVlor,
                                          ROUND(VLQ_VLOR_ORGNAL * Porcent, 2),
                                          VLQ_VLOR_ORGNAL),
                 VLQ_PRDO        = PeriodoNew
           WHERE (VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE) IN
                 (SELECT LQT_NMRO_SLCTUD,
                         LQT_TPO_LQDCION,
                         LQT_PRDO,
                         LQT_SERIE
                    FROM LQDCNES_DTLLE
                   WHERE LQT_NMRO_SNSTRO IN (NmroSnstro, NmroSnstroNew) AND
                         LQT_RAM_CDGO = RamCdgo AND
                         LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
                         LQT_PRDO LIKE DECODE(SumMes, 0, PeriodoNew, '%'));
        EXCEPTION
          WHEN OTHERS THEN
            Raise_application_error(-20020,
                                    '1Error al actualizar en  VLRES_LQDCION ' ||
                                    SQLERRM);
        END;
      ELSE
        Raise_application_error(-20020,
                                'Error al actualizar en  VLRES_LQDCION LQT_ESTDO_LQDCION <> 03 ' || EstLiquid ||
                                SQLERRM);
      END IF;
  END ActlzaVloresLqdcion;
  PROCEDURE ActlzaVloresLqdcion1(ConcptVlor    VARCHAR2,
                                RamCdgo       VARCHAR2,
                                NmroSnstro    NUMBER,
                                Porcent       NUMBER, /*Estado VARCHAR2,*/
                                Periodo       VARCHAR2,
                                PeriodoNew    VARCHAR2,
                                NmroSnstroNew NUMBER,
                                NmroPlza      NUMBER,
                                ClsePlza      VARCHAR2,
                                NmroSlctud    NUMBER,
                                EstLiquid     VARCHAR2,
                                SumMes        NUMBER,
                                valor_permitido NUMBER) IS
    /**** "Estado" <<03>> valida si se pago o esta en otro ****/
    FechaPago DATE;
  BEGIN
    /*** Si el estado es '03' es por estar en siguiente periodo ***/
    dbms_output.put_line(' periodo de detalle ' || PeriodoNew);
    FechaPago := BuscarFechaPago(NmroSnstroNew,
                                 NmroPlza,
                                 ClsePlza,
                                 RamCdgo);
    InsetLqdacion(NmroSlctud,
                  Periodo,
                  PeriodoNew,
                  FechaPago);
    CambiarEstadoLiquid(RamCdgo,
                        NmroSnstro,
                        EstLiquid,
                        SumMes,
                        NmroSnstroNew,
                        Periodo,
                        PeriodoNew,
                        NmroSlctud);
    IF gInserto IN ('B', 'A') THEN
      UPDATE VLRES_LQDCION
         SET VLQ_VLOR        = DECODE(RTRIM(VLQ_CNCPTO_VLOR),
                                      RTRIM(ConcptVlor),
                                      ROUND(valor_permitido * Porcent, 2),
                                      valor_permitido),
             VLQ_VLOR_ORGNAL = DECODE(VLQ_CNCPTO_VLOR,
                                      ConcptVlor,
                                      ROUND(valor_permitido * Porcent, 2),
                                      valor_permitido),
             VLQ_PRDO        = PeriodoNew,
             VLQ_TPO_LQDCION = DECODE(NmroSnstro,
                                      NmroSnstroNew,
                                      '01',
                                      VLQ_TPO_LQDCION)
       WHERE (VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE) IN
             (SELECT LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE
                FROM LQDCNES_DTLLE
               WHERE LQT_NMRO_SNSTRO IN (NmroSnstro, NmroSnstroNew) AND
                     LQT_RAM_CDGO = RamCdgo AND
                     LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
                     LQT_PRDO LIKE DECODE(SumMes, 0, PeriodoNew, '%'));
      IF gInserto = 'B' THEN
        UPDATE VLRES_LQDCION
           SET VLQ_VLOR        = DECODE(RTRIM(VLQ_CNCPTO_VLOR),
                                        RTRIM(ConcptVlor),
                                        ROUND(valor_permitido * Porcent, 2),
                                        valor_permitido),
               VLQ_VLOR_ORGNAL = DECODE(VLQ_CNCPTO_VLOR,
                                        ConcptVlor,
                                        ROUND(valor_permitido * Porcent, 2),
                                        valor_permitido),
               VLQ_PRDO        = Periodo
        --HOYVLQ_TPO_LQDCION = DECODE(NmroSnstro,NmroSnstroNew,'01',VLQ_TPO_LQDCION)
         WHERE (VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE) IN
               (SELECT LQT_NMRO_SLCTUD, LQT_TPO_LQDCION, LQT_PRDO, LQT_SERIE
                  FROM LQDCNES_DTLLE
                 WHERE LQT_NMRO_SNSTRO = NmroSnstroNew AND
                       LQT_RAM_CDGO = RamCdgo AND LQT_ESTDO_LQDCION = '03' AND
                       LQT_PRDO LIKE DECODE(SumMes, 0, PeriodoNew, '%'));
        IF SumMes = 1 THEN
          BorrarDetLiquid(RamCdgo, NmroSlctud);
          InsertarNvoPgoSnstros(RamCdgo,
                                NmroSnstro,
                                FechaPago,
                                NmroSnstroNew);
        END IF;
        gInserto := 'N';
      END IF;
      gInserto := 'B';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -2291 THEN
        BEGIN
          UPDATE VLRES_LQDCION
             SET VLQ_VLOR        = DECODE(VLQ_CNCPTO_VLOR,
                                          ConcptVlor,
                                          ROUND(valor_permitido * Porcent, 2),
                                          VLQ_VLOR),
                 VLQ_VLOR_ORGNAL = DECODE(VLQ_CNCPTO_VLOR,
                                          ConcptVlor,
                                          ROUND(valor_permitido * Porcent, 2),
                                          valor_permitido),
                 VLQ_PRDO        = PeriodoNew
           WHERE (VLQ_NMRO_SLCTUD, VLQ_TPO_LQDCION, VLQ_PRDO, VLQ_SERIE) IN
                 (SELECT LQT_NMRO_SLCTUD,
                         LQT_TPO_LQDCION,
                         LQT_PRDO,
                         LQT_SERIE
                    FROM LQDCNES_DTLLE
                   WHERE LQT_NMRO_SNSTRO IN (NmroSnstro, NmroSnstroNew) AND
                         LQT_RAM_CDGO = RamCdgo AND
                         LQT_ESTDO_LQDCION <> DECODE(SumMes, 0, '03', '=') AND
                         LQT_PRDO LIKE DECODE(SumMes, 0, PeriodoNew, '%'));
        EXCEPTION
          WHEN OTHERS THEN
            Raise_application_error(-20020,
                                    '1Error al actualizar en  VLRES_LQDCION ' ||
                                    SQLERRM);
        END;
      ELSE
        Raise_application_error(-20020,
                                'Error al actualizar en  VLRES_LQDCION LQT_ESTDO_LQDCION <> 03 ' || EstLiquid ||
                                SQLERRM);
      END IF;
  END ActlzaVloresLqdcion1;

  PROCEDURE TerminaContr(RamCdgo    VARCHAR2,
                         CodgoAmpro VARCHAR2,
                         NmroSnstro NUMBER,
                         NmroSlctud NUMBER,
                         FchaMora   DATE,
                         EstSinst   VARCHAR2) IS
    Valor NUMBER;
  BEGIN
    SELECT NVL(SUM(VLD_VLOR_CNSTTDO) - SUM(VLD_VLOR_PGDO_AFNZDO), 0)
      INTO Valor
      FROM VLRES_DDAS, VLRES_PRDCTO
     WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
           VLD_NMRO_SNSTRO = NmroSnstro AND VLD_NMRO_SLCTUD = NmroSlctud AND
           VPR_TPO_VLOR = 'S' AND VLD_CNCPTO_VLOR = VPR_CDGO AND
           VPR_RAM_CDGO = VLD_RAM_CDGO AND
           VLD_VLOR_CNSTTDO > 0; -- se ingresa validacion según mantis #53102 GGM 16/03/2017
    IF Valor = 0 THEN
      /******* Se actualiza el estado de pago del siniestro a objetado = '03' */
      CambiarEstadoSiniest(RamCdgo, NmroSnstro, EstSinst, '03');
      CambiarEstadoDdasVigt(FchaMora, NmroSlctud, '02');
      CambiarEstadoCasosCbrza(FchaMora, NmroSlctud, '03');
      DevolcionContrato(NmroSnstro, RamCdgo);
    ELSE
      CambiarEstadoSiniest(RamCdgo, NmroSnstro, EstSinst, NULL);
    END IF;
  END TerminaContr;

  PROCEDURE ValidaVlorConsttdo(Ramo         VARCHAR2,
                          Ampro        VARCHAR2,
                          NroSnstro    NUMBER,
                          NroSlctud    NUMBER,
                          FchaMora     DATE) IS

  CURSOR C_CNCPTOS IS
    SELECT VSN_CNCPTO_VLOR,VSN_VLOR_CNSTTDO
      FROM VLRES_SNSTROS,VLRES_PRDCTO
     WHERE VSN_NMRO_SNSTRO = NroSnstro
       AND VSN_CDGO_AMPRO = Ampro
       AND VSN_RAM_CDGO   = Ramo
       AND VSN_CNCPTO_VLOR = VPR_CDGO
       AND VPR_TPO_VLOR = 'S';


  V_VALOR   NUMBER;
  CONCEPTO  VLRES_DDAS.VLD_CNCPTO_VLOR%TYPE;
  VALOR     VLRES_SNSTROS.VSN_VLOR_CNSTTDO%TYPE;

  BEGIN
    SELECT SUM(VLD_VLOR_CNSTTDO)
      INTO V_VALOR
      FROM VLRES_DDAS, VLRES_PRDCTO
     WHERE VLD_RAM_CDGO = Ramo AND VLD_CDGO_AMPRO = Ampro AND
           VLD_NMRO_SNSTRO = NroSnstro AND VLD_NMRO_SLCTUD = NroSlctud AND
           VPR_TPO_VLOR = 'S' AND VLD_CNCPTO_VLOR = VPR_CDGO AND
           VPR_RAM_CDGO = VLD_RAM_CDGO;

    IF V_VALOR = 0 THEN
      OPEN C_CNCPTOS;
        LOOP
          FETCH C_CNCPTOS INTO CONCEPTO,VALOR;
          IF C_CNCPTOS%NOTFOUND THEN
            EXIT;
          END IF;

          BEGIN
            UPDATE VLRES_DDAS
               SET VLD_VLOR_CNSTTDO = VALOR
             WHERE VLD_NMRO_SLCTUD = NroSlctud
               AND VLD_FCHA_MRA = FchaMora
               AND VLD_CNCPTO_VLOR = CONCEPTO;
          EXCEPTION
            WHEN OTHERS THEN
              Raise_application_error(-20023,'Error actualizando en VLD el valor constituido '||TO_CHAR(SQLCODE) || SQLERRM);
            END;
          END LOOP;
       CLOSE C_CNCPTOS;
    END IF;


  END ValidaVlorConsttdo;

  PROCEDURE InsDelDdaVlres(RamCdgo    VARCHAR2,
                           CodgoAmpro VARCHAR2,
                           NmroSnstro NUMBER,
                           NmroSlctud NUMBER,
                           Objeta     Varchar2) IS
  BEGIN
    IF Objeta = 'S' THEN
      INSERT INTO VLRES_DDAS_TMP
        SELECT *
          FROM VLRES_DDAS
         WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
               VLD_NMRO_SNSTRO = NmroSnstro AND
               VLD_NMRO_SLCTUD = NmroSlctud;
    ELSE
      DELETE VLRES_DDAS_TMP
       WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
             VLD_NMRO_SNSTRO = NmroSnstro AND VLD_NMRO_SLCTUD = NmroSlctud;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20022,
                              'Error insertando en la tabla VLRES_DDAS_TMP - ' ||
                              SQLERRM);
  END InsDelDdaVlres;
  PROCEDURE Objetar(RamCdgo      VARCHAR2,
                    CodgoAmpro   VARCHAR2,
                    NmroSnstro   NUMBER,
                    NmroSlctud   NUMBER,
                    ConcpVlorAnt VARCHAR2,
                    VlorCnstdo   NUMBER,
                    VlorAfnzdo   NUMBER) IS
    -- ConcpVlorAnt  rowVlresDdas.VLD_CNCPTO_VLOR;
    -- VlorCnstdo    rowVlresDdas.VLD_VLOR_CNSTTDO
    -- VlorAfnzdo    rowVlresDdas.VLD_VLOR_PGDO_AFNZDO
    vCodgRecup VARCHAR2(10);
  BEGIN
    vCodgRecup := CodgRecup(ConcpVlorAnt); --,Objeta);
    IF vCodgRecup IS NOT NULL AND VlorAfnzdo = 0 THEN
      BEGIN
        UPDATE VLRES_DDAS
           SET VLD_CNCPTO_VLOR = vCodgRecup
         WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
               VLD_NMRO_SNSTRO = NmroSnstro AND
               VLD_NMRO_SLCTUD = NmroSlctud AND
               VLD_CNCPTO_VLOR = ConcpVlorAnt;
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -1 THEN
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO +
                                        (VlorCnstdo - VlorAfnzdo)
               WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                     VLD_NMRO_SNSTRO = NmroSnstro AND
                     VLD_NMRO_SLCTUD = NmroSlctud AND
                     VLD_CNCPTO_VLOR = vCodgRecup;
            EXCEPTION
              WHEN OTHERS THEN
                Raise_application_error(-20023, SQLERRM || ConcpVlorAnt);
            END;
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VlorAfnzdo
               WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                     VLD_NMRO_SNSTRO = NmroSnstro AND
                     VLD_NMRO_SLCTUD = NmroSlctud AND
                     VLD_CNCPTO_VLOR = ConcpVlorAnt;
            EXCEPTION
              WHEN OTHERS THEN
                Raise_application_error(-20023,
                                        TO_CHAR(SQLCODE) || SQLERRM ||
                                        ConcpVlorAnt);
            END;
          ELSE
            Raise_application_error(-20023,
                                    TO_CHAR(SQLCODE) || SQLERRM ||
                                    ConcpVlorAnt);
          END IF;
      END;
    ELSIF vCodgRecup IS NOT NULL AND VlorAfnzdo > 0 THEN
      BEGIN
        INSERT INTO VLRES_DDAS
          SELECT VLD_NMRO_SLCTUD,
                 VLD_FCHA_MRA,
                 VLD_RAM_CDGO,
                 vCodgRecup,
                 VLD_NMRO_SNSTRO,
                 VLD_CDGO_AMPRO,
                 VLD_VLOR_PGDO_CIA,
                 (VlorCnstdo - VlorAfnzdo),
                 0,
                 VLD_USRIO,
                 VLD_FCHA_MDFCCION,
                 VLD_ORGEN,
                 VLD_NMRO_PGOS
            FROM VLRES_DDAS
           WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                 VLD_NMRO_SNSTRO = NmroSnstro AND
                 VLD_NMRO_SLCTUD = NmroSlctud AND
                 VLD_CNCPTO_VLOR = ConcpVlorAnt;
        UPDATE VLRES_DDAS
           SET VLD_VLOR_CNSTTDO = VlorAfnzdo
         WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
               VLD_NMRO_SNSTRO = NmroSnstro AND
               VLD_NMRO_SLCTUD = NmroSlctud AND
               VLD_CNCPTO_VLOR = ConcpVlorAnt;
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -1 THEN
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO +
                                        (VlorCnstdo - VlorAfnzdo)
               WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                     VLD_NMRO_SNSTRO = NmroSnstro AND
                     VLD_NMRO_SLCTUD = NmroSlctud AND
                     VLD_CNCPTO_VLOR = vCodgRecup;
            EXCEPTION
              WHEN OTHERS THEN
                Raise_application_error(-20024, SQLERRM || ConcpVlorAnt);
            END;
            BEGIN
              UPDATE VLRES_DDAS
                 SET VLD_VLOR_CNSTTDO = VlorAfnzdo
               WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                     VLD_NMRO_SNSTRO = NmroSnstro AND
                     VLD_NMRO_SLCTUD = NmroSlctud AND
                     VLD_CNCPTO_VLOR = ConcpVlorAnt;
            EXCEPTION
              WHEN OTHERS THEN
                Raise_application_error(-20025,
                                        TO_CHAR(SQLCODE) || SQLERRM ||
                                        ConcpVlorAnt);
            END;
          ELSE
            Raise_application_error(-20026,
                                    TO_CHAR(SQLCODE) || SQLERRM ||
                                    ConcpVlorAnt);
          END IF;
      END;
    END IF;
  END Objetar;
  PROCEDURE Subsanar(RamCdgo       VARCHAR2,
                     CodgoAmpro    VARCHAR2,
                     NmroSnstro    NUMBER,
                     NmroSlctud    NUMBER,
                     EstLiquid     VARCHAR2,
                     ConcpVlorAnt  VARCHAR2,
                     VlorPgoCia    NUMBER,
                     VlorCnstdo    NUMBER,
                     VlorAfnzdo    NUMBER,
                     SumMes        NUMBER,
                     NmroSnstroNew NUMBER,
                     Periodo       VARCHAR2,
                     PeriodoNew    VARCHAR2, /* NumReg NUMBER, */
                     NmroPlza      NUMBER,
                     ClsePlza      VARCHAR2) IS
    -- ConcpVlorAnt rowVlresDdas.VLD_CNCPTO_VLOR;
    -- VlorCnstdo   rowVlresDdas.VLD_VLOR_CNSTTDO
    -- VlorAfnzdo    rowVlresDdas.VLD_VLOR_PGDO_AFNZDO
    vCodgRecup VARCHAR2(10);
    CURSOR curVlresDdas(Concepto VARCHAR2) IS
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
       WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
             VLD_NMRO_SNSTRO = NmroSnstro AND VLD_NMRO_SLCTUD = NmroSlctud AND
             VLD_CNCPTO_VLOR = Concepto;
    rowVlresDdas    curVlresDdas%ROWTYPE;
    rowVlresDdasExt curVlresDdas%ROWTYPE;
    Porcent         NUMBER := 0;
    vr_aseg         number(18,2);
    vr_deuda        number(18,2);
    vr_constituido  number(18,2);
    valor_disponible number(18,2);
    valor_consti  number(18,2);
  BEGIN
    vCodgRecup := CodgRecup(ConcpVlorAnt); --,Objeta);
    --Se debe revisar si es de amparo adicional. Para calcular el cumulo
    if CodgoAmpro <> '01' then
      begin
       vr_aseg :=  Valor_asegurado(NmroSlctud,ConcpVlorAnt,
                   CodgoAmpro,NmroPlza);
       vr_deuda := Deuda_Siniestro_Concepto(NmroSlctud,'C','12',CodgoAmpro,
                   ConcpVlorAnt);
       exception when others then
         Raise_application_error(-20700,TO_CHAR(SQLCODE) || SQLERRM ||'En el Calculo del cúmulo');
         return;
      end;
      if vr_deuda is null then
         vr_deuda := 0;
      end if;
      if vr_aseg is null then
         vr_aseg := 0;
      end if;
      valor_disponible := vr_aseg - vr_deuda;
    end if;     --Para amaparos adicionales únicamente.

    OPEN curVlresDdas(vCodgRecup);
    FETCH curVlresDdas
      INTO rowVlresDdas;
    IF curVlresDdas%NOTFOUND THEN
      null;
    ELSIF vCodgRecup IS NOT NULL THEN
      CLOSE curVlresDdas;
      OPEN curVlresDdas(ConcpVlorAnt);
      FETCH curVlresDdas
        INTO rowVlresDdasExt;
      IF curVlresDdas%NOTFOUND THEN
         --Para amparo básico. es normal.
         if CodgoAmpro =  '01'  then
            BEGIN
              INSERT INTO VLRES_DDAS
                SELECT VLD_NMRO_SLCTUD,
                       Add_months(VLD_FCHA_MRA, SumMes),
                       VLD_RAM_CDGO,
                       ConcpVlorAnt,
                       Decode(NmroSnstroNew,
                              NULL,
                              VLD_NMRO_SNSTRO,
                              NmroSnstroNew),
                              VLD_CDGO_AMPRO,
                              VlorPgoCia,
                       (rowVlresDdas.VLD_VLOR_CNSTTDO -
                        rowVlresDdas.VLD_VLOR_PGDO_AFNZDO),
                       0,
                       VLD_USRIO,
                       VLD_FCHA_MDFCCION,
                       VLD_ORGEN,
                       VLD_NMRO_PGOS
                  FROM VLRES_DDAS
                 WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                       VLD_NMRO_SNSTRO = NmroSnstro AND
                       VLD_NMRO_SLCTUD = NmroSlctud AND
                       VLD_CNCPTO_VLOR = vCodgRecup;
               UPDATE VLRES_DDAS
                  SET VLD_VLOR_CNSTTDO = rowVlresDdas.VLD_VLOR_PGDO_AFNZDO,
                      VLD_FCHA_MRA     = Add_months(VLD_FCHA_MRA, SumMes),
                      VLD_NMRO_SNSTRO  = Decode(NmroSnstroNew,
                                             NULL,
                                             VLD_NMRO_SNSTRO,
                                             NmroSnstroNew)
               WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                     VLD_NMRO_SNSTRO = NmroSnstro AND
                     VLD_NMRO_SLCTUD = NmroSlctud AND
                     VLD_CNCPTO_VLOR = vCodgRecup;
              if vlorCnstdo != 0 then
                Porcent := (rowVlresDdas.VLD_VLOR_CNSTTDO -
                           rowVlresDdas.VLD_VLOR_PGDO_AFNZDO) / VlorCnstdo;
              else
                Porcent := 0;
              end if;
              ActlzaVloresLqdcion(ConcpVlorAnt,
                                  RamCdgo,
                                  NmroSnstro,
                                  Porcent,
                                  Periodo,
                                  PeriodoNew,
                                  NmroSnstroNew,
                                  NmroPlza,
                                  ClsePlza,
                                  NmroSlctud,
                                  EstLiquid,
                                  SumMes);
            EXCEPTION
              WHEN others THEN
                Raise_application_error(-20030,
                                        TO_CHAR(SQLCODE) || SQLERRM ||
                                        ConcpVlorAnt);
            END;
          else   --de amparo 01.
            --Para los adicionales.  DAP.
            if rowVlresDdas.VLD_VLOR_CNSTTDO = 0 then
               return;
            end if;
            if valor_disponible = 0 then
                Raise_application_error(-20701,
                   'No hay valor disponible en el cúmulo para el amparo '||CodgoAmpro);
                RETURN;
            end if;
            if  (rowVlresDdas.VLD_VLOR_CNSTTDO - rowVlresDdas.VLD_VLOR_PGDO_AFNZDO) <= valor_disponible then
                vr_constituido := (rowVlresDdas.VLD_VLOR_CNSTTDO - rowVlresDdas.VLD_VLOR_PGDO_AFNZDO);
            else
                vr_constituido := valor_disponible;
            end if;
            BEGIN
              INSERT INTO VLRES_DDAS
                SELECT VLD_NMRO_SLCTUD,
                       Add_months(VLD_FCHA_MRA, SumMes),
                       VLD_RAM_CDGO,
                       ConcpVlorAnt,
                       Decode(NmroSnstroNew,
                              NULL,
                              VLD_NMRO_SNSTRO,
                              NmroSnstroNew),
                              VLD_CDGO_AMPRO,
                              VlorPgoCia,
                        vr_constituido,
                       0,
                       VLD_USRIO,
                       VLD_FCHA_MDFCCION,
                       VLD_ORGEN,
                       VLD_NMRO_PGOS
                  FROM VLRES_DDAS
                 WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                       VLD_NMRO_SNSTRO = NmroSnstro AND
                       VLD_NMRO_SLCTUD = NmroSlctud AND
                       VLD_CNCPTO_VLOR = vCodgRecup;
               UPDATE VLRES_DDAS
                  SET VLD_VLOR_CNSTTDO = rowVlresDdas.VLD_VLOR_PGDO_AFNZDO,
                      VLD_FCHA_MRA     = Add_months(VLD_FCHA_MRA, SumMes),
                      VLD_NMRO_SNSTRO  = Decode(NmroSnstroNew,
                                             NULL,
                                             VLD_NMRO_SNSTRO,
                                             NmroSnstroNew)
               WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                     VLD_NMRO_SNSTRO = NmroSnstro AND
                     VLD_NMRO_SLCTUD = NmroSlctud AND
                     VLD_CNCPTO_VLOR = vCodgRecup;
              --Porcent := vr_constituido / VlorCnstdo;
              if vr_constituido != 0 then
                Porcent := vr_constituido / vr_constituido;
              else
                Porcent := 0;
              end if;
              ActlzaVloresLqdcion1(ConcpVlorAnt,
                                  RamCdgo,
                                  NmroSnstro,
                                  Porcent,
                                  Periodo,
                                  PeriodoNew,
                                  NmroSnstroNew,
                                  NmroPlza,
                                  ClsePlza,
                                  NmroSlctud,
                                  EstLiquid,
                                  SumMes,vr_constituido);
            EXCEPTION
              WHEN others THEN
                Raise_application_error(-20030,
                                        TO_CHAR(SQLCODE) || SQLERRM ||
                                        ConcpVlorAnt);
            END;

          end if;
      ELSE
       if CodgoAmpro = '01' THEN
          BEGIN
             UPDATE VLRES_DDAS
                SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO +
                                       DECODE(SIGN(rowVlresDdas.VLD_VLOR_CNSTTDO -
                                                   rowVlresDdas.VLD_VLOR_PGDO_AFNZDO -
                                                   (VlorCnstdo - VlorAfnzdo)),
                                              -1,
                                              rowVlresDdas.VLD_VLOR_CNSTTDO -
                                              rowVlresDdas.VLD_VLOR_PGDO_AFNZDO,
                                              (VlorCnstdo - VlorAfnzdo)),
                    VLD_FCHA_MRA     = Add_months(VLD_FCHA_MRA, SumMes),
                    VLD_NMRO_SNSTRO  = Decode(NmroSnstroNew,
                                              NULL,
                                              VLD_NMRO_SNSTRO,
                                              NmroSnstroNew)
              WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                    VLD_NMRO_SNSTRO = NmroSnstro AND
                    VLD_NMRO_SLCTUD = NmroSlctud AND
                    VLD_CNCPTO_VLOR = ConcpVlorAnt;
             SELECT (DECODE(SIGN(rowVlresDdas.VLD_VLOR_CNSTTDO -
                                 rowVlresDdas.VLD_VLOR_PGDO_AFNZDO -
                                 (VlorCnstdo - VlorAfnzdo)),
                            -1,
                            VlorAfnzdo + (rowVlresDdas.VLD_VLOR_CNSTTDO -
                            rowVlresDdas.VLD_VLOR_PGDO_AFNZDO),
                            (VlorCnstdo))) / VlorCnstdo
               INTO Porcent
               FROM DUAL;
             ActlzaVloresLqdcion(ConcpVlorAnt,
                                 RamCdgo,
                                 NmroSnstro,
                                 Porcent,
                                 Periodo,
                                 PeriodoNew,
                                 NmroSnstroNew,
                                 NmroPlza,
                                 ClsePlza,
                                 NmroSlctud,
                                 EstLiquid,
                                 SumMes);
           EXCEPTION
             WHEN OTHERS THEN
               Raise_application_error(-20028, SQLERRM || ConcpVlorAnt);
           END;
           BEGIN
             UPDATE VLRES_DDAS
                SET VLD_VLOR_CNSTTDO = DECODE(SIGN(rowVlresDdas.VLD_VLOR_CNSTTDO -
                                                   rowVlresDdas.VLD_VLOR_PGDO_AFNZDO -
                                                   (VlorCnstdo - VlorAfnzdo)),
                                              -1,
                                              rowVlresDdas.VLD_VLOR_PGDO_AFNZDO,
                                              rowVlresDdas.VLD_VLOR_CNSTTDO -
                                              (VlorCnstdo - VlorAfnzdo)),
                    VLD_FCHA_MRA     = Add_months(VLD_FCHA_MRA, SumMes),
                    VLD_NMRO_SNSTRO  = Decode(NmroSnstroNew,
                                              NULL,
                                              VLD_NMRO_SNSTRO,
                                              NmroSnstroNew)
              WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                    VLD_NMRO_SNSTRO = NmroSnstro AND
                    VLD_NMRO_SLCTUD = NmroSlctud AND
                    VLD_CNCPTO_VLOR = vCodgRecup;
           EXCEPTION
             WHEN OTHERS THEN
               Raise_application_error(-20029,
                                     TO_CHAR(SQLCODE) || SQLERRM ||
                                    ConcpVlorAnt);
           END;
         else  --de amparo 01
            if valor_disponible = 0 then
                Raise_application_error(-20701,
                   'No hay valor disponible en el cúmulo para el amparo '||CodgoAmpro);
                RETURN;
            end if;
            select ( DECODE(SIGN(rowVlresDdas.VLD_VLOR_CNSTTDO -
                     rowVlresDdas.VLD_VLOR_PGDO_AFNZDO -
                           (VlorCnstdo - VlorAfnzdo)),
                            -1,
                       rowVlresDdas.VLD_VLOR_CNSTTDO -
                       rowVlresDdas.VLD_VLOR_PGDO_AFNZDO,
                       (VlorCnstdo - VlorAfnzdo)) )  into valor_consti from dual;
            if  valor_consti   <= valor_disponible then
                vr_constituido := valor_consti;
            else
                vr_constituido := valor_disponible;
            end if;


          BEGIN
             UPDATE VLRES_DDAS
                SET VLD_VLOR_CNSTTDO = VLD_VLOR_CNSTTDO +
                                       vr_constituido,
                    VLD_FCHA_MRA     = Add_months(VLD_FCHA_MRA, SumMes),
                    VLD_NMRO_SNSTRO  = Decode(NmroSnstroNew,
                                              NULL,
                                              VLD_NMRO_SNSTRO,
                                              NmroSnstroNew)
              WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                    VLD_NMRO_SNSTRO = NmroSnstro AND
                    VLD_NMRO_SLCTUD = NmroSlctud AND
                    VLD_CNCPTO_VLOR = ConcpVlorAnt;
             SELECT vr_constituido / VlorCnstdo
               INTO Porcent
               FROM DUAL;
             ActlzaVloresLqdcion1(ConcpVlorAnt,
                                 RamCdgo,
                                 NmroSnstro,
                                 Porcent,
                                 Periodo,
                                 PeriodoNew,
                                 NmroSnstroNew,
                                 NmroPlza,
                                 ClsePlza,
                                 NmroSlctud,
                                 EstLiquid,
                                 SumMes,vr_constituido);
           EXCEPTION
             WHEN OTHERS THEN
               Raise_application_error(-20028, SQLERRM || ConcpVlorAnt);
           END;
           BEGIN
             UPDATE VLRES_DDAS
                SET VLD_VLOR_CNSTTDO = DECODE(SIGN(rowVlresDdas.VLD_VLOR_CNSTTDO -
                                                   rowVlresDdas.VLD_VLOR_PGDO_AFNZDO -
                                                   (VlorCnstdo - VlorAfnzdo)),
                                              -1,
                                              rowVlresDdas.VLD_VLOR_PGDO_AFNZDO,
                                              rowVlresDdas.VLD_VLOR_CNSTTDO -
                                              (VlorCnstdo - VlorAfnzdo)),
                    VLD_FCHA_MRA     = Add_months(VLD_FCHA_MRA, SumMes),
                    VLD_NMRO_SNSTRO  = Decode(NmroSnstroNew,
                                              NULL,
                                              VLD_NMRO_SNSTRO,
                                              NmroSnstroNew)
              WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
                    VLD_NMRO_SNSTRO = NmroSnstro AND
                    VLD_NMRO_SLCTUD = NmroSlctud AND
                    VLD_CNCPTO_VLOR = vCodgRecup;
           EXCEPTION
             WHEN OTHERS THEN
               Raise_application_error(-20029,
                                     TO_CHAR(SQLCODE) || SQLERRM ||
                                    ConcpVlorAnt);
           END;
        end if;  --de codigo amparo 01.
      END IF;
    END IF;
    CLOSE curVlresDdas;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20033, SQLERRM);
  END Subsanar;
  PROCEDURE NuevoSiniestro(RamCdgo    VARCHAR2,
                           NmroSlctud NUMBER,
                           NmroSnstro NUMBER,
                           CodgoAmpro VARCHAR2,
                           Objeta     VARCHAR2,
                           EstSinst   VARCHAR2,
                           EstLiquid  VARCHAR2,
                           Periodo    VARCHAR2,
                           PeriodoNew VARCHAR2,
                           NmroPlza   NUMBER,
                           ClsePlza   VARCHAR2) IS
    /*, NumReg NUMBER*/
    CURSOR curVlresDdasTmp IS
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
       WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
             VLD_NMRO_SNSTRO = NmroSnstro AND VLD_NMRO_SLCTUD = NmroSlctud;
    rowVlresDdas  curVlresDdasTmp%ROWTYPE;
    ValorDesface  NUMBER;
    NmroSnstroNew NUMBER;
    FchaMora      DATE;
    Ejecutar      VARCHAR2(2) := 'S';
  BEGIN
    NmroSnstroNew := GenerarNumeroSiniestro('S');
    SELECT SUM(AMN_VLOR)
      INTO ValorDesface
      FROM AMNTOS_SNSTROS
     WHERE AMN_NMRO_SNSTRO = NmroSnstro AND AMN_RAM_CDGO = RamCdgo AND
           AMN_CDGO_AMPRO = '01' AND AMN_CNCPTO = '01';
    OPEN curVlresDdasTmp;
    LOOP
      FETCH curVlresDdasTmp
        INTO rowVlresDdas;
      IF curVlresDdasTmp%NOTFOUND THEN
        EXIT;
      END IF;
      IF Ejecutar = 'S' THEN
        FchaMora := rowVlresDdas.VLD_FCHA_MRA;
        InsertDdasVgtes(NmroSlctud, FchaMora, ValorDesface);
        InsertAvsosSnstros(RamCdgo, NmroSnstro, NmroSnstroNew);
        InsertAmprosSnstros(RamCdgo, NmroSnstro, NmroSnstroNew);
        InsertVlresSnstros(NmroSnstro, NmroSnstroNew);
        InsertVlresDdas(RamCdgo,
                        CodgoAmpro,
                        NmroSnstro,
                        NmroSlctud,
                        ValorDesface,
                        NmroSnstroNew);
        InsertAmntosSnstros(RamCdgo,
                            CodgoAmpro,
                            NmroSnstro,
                            NmroSnstroNew);
        InsertDdasArrndtrios(FchaMora, NmroSlctud);
        InsertCasosCbrnza(FchaMora, NmroSlctud);
        Ejecutar := 'N';
      END IF;
      Subsanar(RamCdgo,
               CodgoAmpro,
               NmroSnstro,
               NmroSlctud,
               EstLiquid,
               rowVlresDdas.VLD_CNCPTO_VLOR,
               rowVlresDdas.VLD_VLOR_PGDO_CIA,
               rowVlresDdas.VLD_VLOR_CNSTTDO,
               rowVlresDdas.VLD_VLOR_PGDO_AFNZDO,
               1,
               NmroSnstroNew,
               Periodo,
               PeriodoNew,
               NmroPlza,
               ClsePlza);
      CambiarSnstro(RamCdgo, NmroSnstro, CodgoAmpro);
    END LOOP;
    CLOSE curVlresDdasTmp;
    FchaMora := rowVlresDdas.VLD_FCHA_MRA;
    CambiaReferenciaRecibos(NmroSlctud, NmroPlza, FchaMora);
    ValidaVlorConsttdo(RamCdgo,CodgoAmpro,NmroSnstro,NmroSlctud,FchaMora);
    TerminaContr(RamCdgo,
                 CodgoAmpro,
                 NmroSnstroNew,
                 NmroSlctud,
                 Add_months(rowVlresDdas.VLD_FCHA_MRA, 1),
                 EstSinst);
    InsDelDdaVlres(RamCdgo, CodgoAmpro, NmroSnstro, NmroSlctud, Objeta);
    CambiarEstadoSiniest(RamCdgo, NmroSnstro, '02', '06');
    CambiarEstadoDdasVigt(FchaMora, NmroSlctud, '02');
    --NmroSnstroNew := GenerarNumeroSiniestro('U');
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20032,
                              'Error en nuevo << Procedure NuevoSiniestro >> . ' ||
                              SQLERRM);
  END NuevoSiniestro;


FUNCTION Tipo_Poliza(P_SOLICITUD NUMBER,P_POLIZA NUMBER,
                      P_CLASE VARCHAR2, P_RAMO VARCHAR2) return VARCHAR2 is

  V_TIPO                         PLZAS.POL_TPOPLZA%TYPE;
  V_RIESGO                       PLZAS.POL_TPORSGO%TYPE;
begin
 BEGIN
  SELECT POL_TPORSGO,POL_TPOPLZA
    INTO V_RIESGO,V_TIPO
    FROM RLCION_ARRNDTRIOS,PLZAS
   WHERE RLA_NMRO_SLCTUD = P_SOLICITUD
     AND RLA_NMRO_PLZA = POL_NMRO_PLZA
     AND POL_CDGO_CLSE  = P_CLASE
     AND POL_RAM_CDGO = P_RAMO;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
     BEGIN
      SELECT POL_TPORSGO,POL_TPOPLZA
        INTO V_RIESGO,V_TIPO
        FROM PLZAS
       WHERE POL_NMRO_PLZA = P_POLIZA
         AND POL_CDGO_CLSE = P_CLASE
         AND POL_RAM_CDGO  = P_RAMO;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            Raise_application_error(-20033, 'No existe el tipo de poliza '||SQLERRM);
       WHEN OTHERS THEN
         Raise_application_error(-20033, 'Error buscando el tipo de poliza '||SQLERRM);
     END;
  WHEN OTHERS THEN
       Raise_application_error(-20033, 'Error buscando el tipo de poliza '||SQLERRM);
 END;
 IF V_RIESGO ='CUM' THEN
    V_TIPO := 'I';
 END IF;
 RETURN(V_TIPO);

end;




PROCEDURE Principal(RamCdgo      VARCHAR2,
                      CodgoAmpro   VARCHAR2,
                      NmroSnstro   NUMBER,
                      NmroSlctud   NUMBER,
                      Objeta       VARCHAR2,
                      EstSinst     VARCHAR2,
                      EstLiquid    VARCHAR2,
                      NmroPlza     NUMBER,
                      ClsePlza     VARCHAR2,
                      FchaObjecion DATE,
                      FchaSubsn    DATE) IS

    CURSOR curVlresDdas IS
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
       WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
             VLD_NMRO_SNSTRO = NmroSnstro AND VLD_NMRO_SLCTUD = NmroSlctud;
    CURSOR curVlresDdasTmp IS
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
       WHERE VLD_RAM_CDGO = RamCdgo AND VLD_CDGO_AMPRO = CodgoAmpro AND
             VLD_NMRO_SNSTRO = NmroSnstro AND VLD_NMRO_SLCTUD = NmroSlctud;
    rowVlresDdas curVlresDdas%ROWTYPE;
    --AND VLD_CNCPTO_VLOR = CncptoVlor;
    Opcion VARCHAR2(10);
  BEGIN
    /******* Se actualiza el estado de liquidacion a suspendido = '02' */
    gInserto := 'N';
    IF Objeta = 'S' THEN
      /******* Se actualiza el estado de pago del siniestro a objetado = '03' */
      CambiarEstadoSiniest(RamCdgo, NmroSnstro, EstSinst, NULL);
      InsDelDdaVlres(RamCdgo, CodgoAmpro, NmroSnstro, NmroSlctud, Objeta);
      OPEN curVlresDdas;
      LOOP
        FETCH curVlresDdas
          INTO rowVlresDdas;
        IF curVlresDdas%NOTFOUND THEN
          EXIT;
        END IF;
        CambiarEstadoLiquid(RamCdgo,
                            NmroSnstro,
                            EstLiquid,
                            0,
                            NULL,
                            gPeriodo,
                            NULL,
                            NmroSlctud);
        Objetar(RamCdgo,
                CodgoAmpro,
                NmroSnstro,
                NmroSlctud,
                rowVlresDdas.VLD_CNCPTO_VLOR,
                rowVlresDdas.VLD_VLOR_CNSTTDO,
                rowVlresDdas.VLD_VLOR_PGDO_AFNZDO);
      END LOOP;
      CLOSE curVlresDdas;
    ELSE
      Opcion := ConsultaPeriodo(CodgoAmpro,
                                NmroPlza,
                                RamCdgo,
                                ClsePlza,
                                FchaObjecion,
                                FchaSubsn);
      IF Opcion IN ('PERIODO1', 'SERVICIOS') THEN
        OPEN curVlresDdasTmp;
        LOOP
          FETCH curVlresDdasTmp
            INTO rowVlresDdas;
          IF curVlresDdasTmp%NOTFOUND THEN
            EXIT;
          END IF;
          --CambiarEstadoLiquid(RamCdgo,NmroSnstro,EstLiquid,0,NULL,NULL,NmroSlctud);
          Subsanar(RamCdgo,
                   CodgoAmpro,
                   NmroSnstro,
                   NmroSlctud,
                   EstLiquid,
                   rowVlresDdas.VLD_CNCPTO_VLOR,
                   rowVlresDdas.VLD_VLOR_PGDO_CIA,
                   rowVlresDdas.VLD_VLOR_CNSTTDO,
                   rowVlresDdas.VLD_VLOR_PGDO_AFNZDO,
                   0,
                   NmroSnstro,
                   gPeriodo,
                   gPeriodo,
                   NmroPlza,
                   ClsePlza);
          CambiarSnstro(RamCdgo, NmroSnstro, CodgoAmpro);
        END LOOP;
        CLOSE curVlresDdasTmp;
        TerminaContr(RamCdgo,
                     CodgoAmpro,
                     NmroSnstro,
                     NmroSlctud,
                     rowVlresDdas.VLD_FCHA_MRA,
                     EstSinst);
        InsDelDdaVlres(RamCdgo, CodgoAmpro, NmroSnstro, NmroSlctud, Objeta);
        -- ANTES ActualizarLqdacion(NmroPlza, ClsePlza, RamCdgo, NmroSlctud, gPeriodo);
      ELSIF Opcion = 'PERIODO2' THEN
        NuevoSiniestro(RamCdgo,
                       NmroSlctud,
                       NmroSnstro,
                       CodgoAmpro,
                       Objeta,
                       EstSinst,
                       EstLiquid,
                       gPeriodo,
                       gPeriodoNew,
                       NmroPlza,
                       ClsePlza);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_application_error(-20033, SQLERRM);
  END Principal;
END ObjetarSubsanar;
/
