CREATE OR REPLACE PACKAGE BODY admsisa.PK_LISTADOS_CIERRE is

  -- Private type declarations


  FUNCTION F_LISTADOS(P_LISTADO NUMBER, P_POLIZA NUMBER, P_FECHA_PAGO DATE)
    RETURN NUMBER IS

    V_LISTADO RARCHIVOS.NOMBRE%TYPE;
    V_SALIDA  NUMBER;
    V_EXISTE  VARCHAR2(1);


  BEGIN

    IF P_LISTADO = 1 THEN
      V_LISTADO := 'Extracto de Cuenta';
    ELSIF P_LISTADO = 2 THEN
      V_LISTADO := 'Relación Asegurados';
    ELSIF P_LISTADO = 3 THEN
      V_LISTADO := 'Certificado de Seguro';
    ELSIF P_LISTADO = 4 THEN
      V_LISTADO := 'Relación de Siniestros';
    ELSIF P_LISTADO = 5 THEN
      V_LISTADO := 'Carta Rechazo';
    ELSIF P_LISTADO = 6 THEN
      V_LISTADO := 'Listado Novedades';
    ELSIF P_LISTADO = 7 THEN
      V_LISTADO := 'Clausulado de Hogar';
    END IF;

    BEGIN
      SELECT 'S'
        INTO V_EXISTE
        FROM RARCHIVOS R
       WHERE R.POLIZA = P_POLIZA
         AND R.FECHA_PGO = P_FECHA_PAGO
         AND R.NOMBRE = V_LISTADO;

      V_SALIDA := 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_SALIDA := 0;
      WHEN TOO_MANY_ROWS THEN
        V_SALIDA := 1;
    END;

    RETURN(V_SALIDA);

  END;

  FUNCTION F_NOVEDAD_CIERRE(P_SOLICITUD NUMBER,
                            P_POLIZA    NUMBER,
                            P_CLASE     VARCHAR2,
                            P_RAMO      VARCHAR2,
                            P_PERIODO   VARCHAR2) RETURN VARCHAR2 IS

    CURSOR NVDAD IS
      select rivn_tpo_nvdad, RIVN_CDGO_AMPRO
        from Rsgos_Vgntes_Nvddes
       where RIVN_RAM_CDGO = P_RAMO
         and RIVN_NMRO_ITEM = P_SOLICITUD
         and RIVN_NMRO_PLZA = P_POLIZA
         and RIVN_CLSE_PLZA = P_CLASE
         and rivn_tpo_nvdad != '02'
         and rivn_tpo_nvdad != '09'
         and rivn_tpo_nvdad != '11'
         and rivn_tpo_nvdad != '13'
         and to_char(rivn_fcha_mdfccion, 'MMYYYY') = P_PERIODO
       order by rivn_tpo_nvdad, RIVN_CDGO_AMPRO;

    TPO_NVDAD  VARCHAR2(2);
    CDGO_AMPRO VARCHAR2(2);

  BEGIN

    OPEN NVDAD;
    FETCH NVDAD
      INTO TPO_NVDAD, CDGO_AMPRO;
    IF (CDGO_AMPRO = '01' AND TPO_NVDAD = '01') THEN
      RETURN('CERTIFICADO DE SEGURO');
    ELSIF (CDGO_AMPRO = '01' AND TPO_NVDAD = '12') THEN
      RETURN('CERTIFICADO DE SEGURO');
    ELSE
      RETURN('CERTIFICADO DE MODIFICACION');
    END IF;
    CLOSE NVDAD;
  end;

  function F_NOTA_CIERRE(P_SOLICITUD NUMBER,
                         P_POLIZA    NUMBER,
                         P_CLASE     VARCHAR2,
                         P_RAMO      VARCHAR2,
                         P_PERIODO   VARCHAR2) RETURN VARCHAR2 IS

    CURSOR NVDAD IS
      select rivn_tpo_nvdad, RIVN_CDGO_AMPRO
        from Rsgos_Vgntes_Nvddes
       where RIVN_RAM_CDGO = P_Ramo
         and RIVN_NMRO_ITEM = P_SOLICITUD
         and RIVN_NMRO_PLZA = P_POLIZA
         and RIVN_CLSE_PLZA = P_CLASE
         and rivn_tpo_nvdad != '02'
         and rivn_tpo_nvdad != '11'
         and to_char(rivn_fcha_mdfccion, 'MMYYYY') = P_PERIODO;

    TPO_NVDAD  VARCHAR2(2);
    CDGO_AMPRO VARCHAR2(2);

  BEGIN

    OPEN NVDAD;
    FETCH NVDAD
      INTO TPO_NVDAD, CDGO_AMPRO;
    IF CDGO_AMPRO = '01' AND TPO_NVDAD = '01' THEN
      RETURN('N O T A:  EL PRESENTE CERTIFICADO DE SEGUROS SE EXPIDE CON BASE EN LAS DECLARACIONES HECHAS POR EL ASEGURADO EN
LA SOLICITUD DE INGRESO AL SEGURO.');
    ELSIF (CDGO_AMPRO = '01' AND TPO_NVDAD = '12') THEN
      RETURN('N O T A:  EL PRESENTE CERTIFICADO DE SEGUROS SE EXPIDE CON BASE EN LAS DECLARACIONES HECHAS POR EL ASEGURADO EN
LA SOLICITUD DE INGRESO AL SEGURO.');
    ELSE
      RETURN('N O T A:  EL PRESENTE CERTIFICADO DE MODIFICACION SE EXPIDE CON BASE EN LAS DECLARACIONES HECHAS POR EL ASEGURADO,  Y
REEMPLAZA CUALQUIER OTRO CERTIFICADO EXPEDIDO CON ANTERIORIDAD A LA FECHA DE LA PRESENTE MODIFICACION.');
    END IF;
    CLOSE NVDAD;
  end;

  function f_comas(p_cadena varchar2) return varchar2 is

    Result    varchar2(100);
    p_cadena1 varchar2(100);
    parte2    varchar2(10);
    v_cadena  VARCHAR2(100);
    v_lon     NUMBER;
    v_i       number;
    v_n       number;

  begin
    if nvl(instr(p_cadena, '.'), 0) > 0 then
      p_cadena1 := substr(p_cadena, 1, instr(p_cadena, '.') - 1);
      parte2    := substr(p_cadena, instr(p_cadena, '.'), 3);
    else
      p_cadena1 := p_cadena;
      parte2    := '';
    end if;
    v_cadena := null;
    v_lon    := length(p_cadena1);
    v_n      := 1;
    v_i      := MOD(v_lon, 3);
    if v_i = 0 then
      while v_n <= v_lon loop
        v_cadena := SUBSTR(p_cadena1, v_n, 3) || ',';
        Result   := Result || v_cadena;
        v_n      := v_n + 3;
      end loop;
    else
      if v_lon = 1 then
        Result := p_cadena1;
      else
        while v_n < v_lon loop
          v_cadena := SUBSTR(p_cadena1, v_n, v_i) || ',';
          v_n      := v_n + v_i;
          v_i      := 3;
          Result   := Result || v_cadena;
        end loop;
      end if;
    end if;
    v_lon := length(Result);
    if SUBSTR(Result, v_lon, v_lon) = ',' then
      Result := SUBSTR(Result, 1, v_lon - 1);
    end if;
    Result := Result || parte2;
    return(Result);
  end f_comas;

  --
  --
  --
  FUNCTION FUN_PRIMA_CONCEPTO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                              P_AMPARO    RSGOS_VGNTES_AVLOR.RVL_CDGO_AMPRO%TYPE,
                              P_CONCEPTO  RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE)
    RETURN NUMBER IS

    V_PRIMA NUMBER;

  BEGIN
    BEGIN
      SELECT ROUND((NVL(RVL.RVL_PRIMA_NETA, 0) + NVL(RVL.RVL_VALOR_IVA, 0)),
                   0)
        INTO V_PRIMA
        FROM RSGOS_VGNTES_AVLOR RVL
       WHERE RVL.RVL_NMRO_ITEM = P_SOLICITUD
         AND RVL.RVL_CDGO_AMPRO = P_AMPARO
         AND RVL.RVL_CNCPTO_VLOR = P_CONCEPTO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        V_PRIMA := 0;
    END;
    RETURN(V_PRIMA);

  END FUN_PRIMA_CONCEPTO;

  procedure PR_CERTIFICADOS_CIERRE(P_POLIZA   NUMBER,
                                   P_CLASE    VARCHAR2,
                                   P_RAMO     VARCHAR2,
                                   P_COMPANIA VARCHAR2,
                                   P_SUCURSAL VARCHAR2,
                                   P_PERIODO  VARCHAR2,
                                   P_FCHA_PGO DATE) is

    cursor C_CERTIF is
      select unique(rva_nmro_item),
             pol_prs_nmro_idntfccion nit_poliza,
             pk_terceros.f_nombres(pol_prs_nmro_idntfccion,
                                   pol_prs_tpo_idntfccion) poliza,
             rva_nmro_plza polizz,
             pol_suc_cdgo sucurr,
             rva_clse_plza,
             rva_ram_cdgo,
             RVI_FCHA_DSDE_ACTUAL,
             DECODE(DI_DIRECCION,
                    NULL,
                    'NO EXISTE DIRECCION DE RIESGO',
                    DI_DIRECCION) direcccion,
             max(rva_fcha_mdfccion) f_reporte,
             trunc(rivn_fcha_mdfccion) rivn_fcha_mdfccion,
             S.SUC_NMBRE
        from Rsgos_Vgntes_Ampro,
             Rsgos_Vgntes_Nvddes,
             plzas,
             scrsl s,
             direcciones,
             rsgos_vgntes
       where rivn_nmro_plza = P_POLIZA
         and rivn_clse_plza = P_CLASE
         and rivn_ram_cdgo = P_RAMO
         and rivn_tpo_nvdad != '02'
         and rivn_tpo_nvdad != '06'
         and rivn_tpo_nvdad != '09'
         and rivn_tpo_nvdad != '11'
         and rivn_tpo_nvdad != '12'
         and to_char(rivn_fcha_mdfccion, 'MMYYYY') = P_PERIODO
         and RVI_NMRO_ITEM = RVA_NMRO_ITEM
         and RVI_NMRO_PLZA = RVA_NMRO_PLZA
         and RVI_CLSE_PLZA = rva_clse_plza
         and RVI_RAM_CDGO = rva_ram_cdgo
         and pol_nmro_plza = rivn_nmro_plza
         and pol_cdgo_clse = rivn_clse_plza
         and pol_ram_cdgo = rivn_ram_cdgo
         and pol_tpoplza = 'C'
         and pol_suc_cdgo = p_sucursal
         and pol_suc_cia_cdgo = p_compania
         and rva_nmro_plza = rivn_nmro_plza
         and rva_clse_plza = rivn_clse_plza
         and rva_ram_cdgo = rivn_ram_cdgo
         and rva_nmro_item = rivn_nmro_item
         and di_solicitud(+) = to_char(rva_nmro_item)
         and di_tpo_drccion(+) = 'R'
         AND (PLZAS.POL_SUC_CDGO = S.SUC_CDGO)
         AND (PLZAS.POL_SUC_CIA_CDGO = S.SUC_CIA_CDGO)
         AND NOT EXISTS (select cer_nmro_plza
                from crtfcdos, plzas
               where cer_nmro_crtfcdo = rvi_nmro_crtfcdo
                 and cer_nmro_plza = pol_nmro_plza
                 and POL_TPORSGO = 'CUM')
       group by pol_prs_nmro_idntfccion,
                pk_terceros.f_nombres(pol_prs_nmro_idntfccion,
                                      pol_prs_tpo_idntfccion),
                rva_nmro_item,
                rva_nmro_plza,
                rva_clse_plza,
                rva_ram_cdgo,
                di_direccion,
                trunc(rivn_fcha_mdfccion),
                pol_suc_cdgo,
                S.SUC_NMBRE,
                RVI_FCHA_DSDE_ACTUAL
       order by pol_suc_cdgo, rva_nmro_plza, rva_nmro_item;

    CURSOR C_ASEGURADOS(V_SOL NUMBER, V_CLSE VARCHAR2, V_RMO VARCHAR2) IS
      select rvi_nmro_item,
             rvi_nmro_plza,
             rvn_prs_tpo_idntfccion,
             rvn_prs_nmro_idntfccion,
             nvl(prs_nmbre, 'P.N'),
             rvn_tpo_nit,
             tipo_tercero,
             rownum
        from riesgos_arrendatarios, tipos_documento
       where RVI_NMRO_ITEM = V_SOL
         AND POL_CDGO_CLSE = V_CLSE
         AND POL_RAM_CDGO = V_RMO
         AND rvn_prs_tpo_idntfccion = codigo
       order by rvn_tpo_nit desc;

    V_SOLICITUD    RSGOS_VGNTES_AMPRO.RVA_NMRO_ITEM%TYPE;
    V_NIT_POLIZA   PLZAS.pol_prs_nmro_idntfccion%TYPE;
    V_NOM_POLIZA   varchar2(120); --PRSNAS.PRS_NMBRE_ANT%TYPE;
    V_POLIZA       PLZAS.POL_NMRO_PLZA%TYPE;
    V_SUCURSAL     PLZAS.POL_SUC_CDGO%TYPE;
    V_CLASE        PLZAS.POL_CDGO_CLSE%TYPE;
    V_RAMO         PLZAS.POL_RAM_CDGO%TYPE;
    V_FECHAD       RSGOS_VGNTES.RVI_FCHA_DSDE_ACTUAL%TYPE;
    V_DIRECCION    VARCHAR2(300);
    V_FECHAR       DATE;
    V_FECHAM       DATE;
    V_NSUCURSAL    SCRSL.SUC_NMBRE%TYPE;
    V_CANON        NUMBER;
    V_ADMON        NUMBER;
    V_SERVICIO     NUMBER;
    V_RECONEC      NUMBER;
    V_DANOS        NUMBER;
    V_ESPEN        NUMBER;
    V_AMPINTST     NUMBER;
    V_AMPINT       NUMBER;
    V_MODIFICACION VARCHAR2(60);
    V_NOTA         VARCHAR2(600);
    PRIMA_SER      RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    PRIMA_DANOS    RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    PRIMA_EXP      RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    PRIMA_AIS      RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    PRIMA_AI       RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    V_IVA          NUMBER;
    PRIMA_NETA     NUMBER;
    PRIMA_ARR      NUMBER;
    C_ITEM         RSGOS_VGNTES_AMPRO.RVA_NMRO_ITEM%TYPE;
    C_POLIZA       RSGOS_VGNTES_AMPRO.RVA_NMRO_PLZA%TYPE;
    C_TIPO         PLZAS.POL_PRS_TPO_IDNTFCCION%TYPE;
    C_NUMERO       PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
    C_NOMBRE       PRSNAS.PRS_NMBRE_ANT%TYPE;
    C_TPO_NIT      RSGOS_VGNTES_NITS.RVN_TPO_NIT%TYPE;
    C_TPO_TRCRO    VARCHAR2(1);
    rep            varchar2(300);
    nitt           number;
    n_linea        number;
    entro          varchar2(1);

  begin
    SELECT PAR_VLOR2
      INTO V_IVA
      FROM PRMTROS
     WHERE PAR_CDGO = '4'
       AND PAR_MDLO = '6'
       AND PAR_VLOR1 = '01'
       AND PAR_FCHA_CREACION = (SELECT MAX(PAR_FCHA_CREACION)
                                  FROM PRMTROS
                                 WHERE PAR_VLOR1 = '01'
                                   AND PAR_MDLO = '6'
                                   AND PAR_CDGO = '4');
    open C_CERTIF;
    loop
      fetch C_CERTIF
        into V_SOLICITUD,
             V_NIT_POLIZA,
             V_NOM_POLIZA,
             V_POLIZA,
             V_SUCURSAL,
             V_CLASE,
             V_RAMO,
             V_FECHAD,
             V_DIRECCION,
             V_FECHAR,
             V_FECHAM,
             V_NSUCURSAL;
      if C_CERTIF%notfound then
        exit;
      end if;

      SELECT MIN(decode(rvl_cncpto_vlor,
                        '01',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '02',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '03',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '04',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '05',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '06',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '15',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '16',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor)))
        INTO V_CANON,
             V_ADMON,
             V_SERVICIO,
             V_RECONEC,
             V_DANOS,
             V_ESPEN,
             V_AMPINTST,
             V_AMPINT
        from Rsgos_Vgntes_avlor
       where rvl_nmro_item = V_SOLICITUD
         and rvl_nmro_plza = V_POLIZA
         and rvl_clse_plza = V_CLASE
         and rvl_ram_cdgo = V_RAMO;

      V_CANON    := NVL(V_CANON, 0);
      V_ADMON    := NVL(V_ADMON, 0);
      V_SERVICIO := NVL(V_SERVICIO, 0);
      V_RECONEC  := NVL(V_RECONEC, 0);
      V_DANOS    := NVL(V_DANOS, 0);
      V_ESPEN    := NVL(V_ESPEN, 0);
      V_AMPINTST := NVL(V_AMPINTST, 0);
      V_AMPINT   := NVL(V_AMPINT, 0);

      -- DESCRIPCION DE LA NOTA

      V_MODIFICACION := F_NOVEDAD_CIERRE(V_SOLICITUD,
                                         V_POLIZA,
                                         V_CLASE,
                                         V_RAMO,
                                         P_PERIODO);
      V_NOTA         := F_NOTA_CIERRE(V_SOLICITUD,
                                      V_POLIZA,
                                      V_CLASE,
                                      V_RAMO,
                                      P_PERIODO);

      SELECT decode(nvl(rva_vlor_prma_nta, 0),
                    0,
                    999999999999999999,
                    rva_vlor_prma_nta) rva_vlor_prma_nta
        INTO PRIMA_NETA
        FROM RSGOS_VGNTES_AMPRO, RSGOS_VGNTES_AVLOR
       WHERE RVA_CDGO_AMPRO = '01' --ARRENDAMIENTOS
         AND RVA_RAM_CDGO = V_RAMO
         AND RVA_NMRO_ITEM = V_SOLICITUD
         AND RVA_NMRO_PLZA = V_POLIZA
         AND RVA_CLSE_PLZA = V_CLASE
         AND RVL_CDGO_AMPRO = RVA_CDGO_AMPRO
         AND RVL_RAM_CDGO = RVA_RAM_CDGO
         AND RVL_NMRO_ITEM = RVA_NMRO_ITEM
         AND RVL_NMRO_PLZA = RVA_NMRO_PLZA
         AND RVL_CLSE_PLZA = RVA_CLSE_PLZA
         AND RVL_CNCPTO_VLOR = '01';

      PRIMA_ARR := round(((PRIMA_NETA * (100 + V_IVA)) / 100), 1);

      SELECT MIN(DECODE(RVL_CNCPTO_VLOR,
                        '03',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0) * 2))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '05',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0)))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '06',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0)))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '15',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0)))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '16',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0))))
        INTO PRIMA_SER, PRIMA_DANOS, PRIMA_EXP, PRIMA_AIS, PRIMA_AI
        FROM RSGOS_VGNTES_AMPRO, RSGOS_VGNTES_AVLOR
       WHERE RVA_CDGO_AMPRO IN ('02', '03', '04', '05', '06', '07', '08')
         AND RVA_RAM_CDGO = V_RAMO
         AND RVA_NMRO_ITEM = V_SOLICITUD
         AND RVA_NMRO_PLZA = V_POLIZA
         AND RVA_CLSE_PLZA = V_CLASE
         AND RVL_CDGO_AMPRO = RVA_CDGO_AMPRO
         AND RVL_RAM_CDGO = RVA_RAM_CDGO
         AND RVL_NMRO_ITEM = RVA_NMRO_ITEM
         AND RVL_NMRO_PLZA = RVA_NMRO_PLZA
         AND RVL_CLSE_PLZA = RVA_CLSE_PLZA
         AND RVL_CNCPTO_VLOR in ('05', '06', '03', '15', '16');

      PRIMA_SER   := NVL(PRIMA_SER, 0);
      PRIMA_DANOS := NVL(PRIMA_DANOS, 0);
      PRIMA_EXP   := NVL(PRIMA_EXP, 0);
      PRIMA_AIS   := NVL(PRIMA_AIS, 0);
      PRIMA_AI    := NVL(PRIMA_AI, 0);

      BEGIN
        INSERT INTO RCERTIFICADOS
        VALUES
          (f_comas(V_CANON),
           V_SOLICITUD,
           V_DIRECCION,
           V_MODIFICACION,
           P_FCHA_PGO,
           V_POLIZA,
           f_comas(V_NIT_POLIZA),
           V_NOM_POLIZA,
           V_ADMON,
           to_char(V_FECHAM, 'YYYY/MM/DD'),
           to_char(V_FECHAD, 'YYYY/MM/DD'),
           '$' || f_comas(V_CANON),
           '$' || f_comas(PRIMA_ARR),
           '$' || f_comas(V_SERVICIO),
           '$' || f_comas(PRIMA_SER),
           '$' || f_comas(V_RECONEC),
           '$0',
           '$' || f_comas(V_DANOS),
           '$' || f_comas(PRIMA_DANOS),
           '$' || f_comas(V_ESPEN),
           '$' || f_comas(PRIMA_EXP),
           '$' || f_comas(V_AMPINTST),
           '$' || f_comas(PRIMA_AIS),
           '$' || f_comas(V_AMPINT),
           '$' || f_comas(PRIMA_AI),
           V_NOTA,
           '$0',
           '$0');
        COMMIT;
        entro := 'S';
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20501,
                                  '1. Error insertando en la tabla R_CERTIFICADO ' ||
                                  v_solicitud || ' ' || SQLERRM);
      END;
      open C_ASEGURADOS(V_SOLICITUD, V_CLASE, V_RAMO);
      loop
        fetch C_ASEGURADOS
          into C_ITEM,
               C_POLIZA,
               C_TIPO,
               C_NUMERO,
               C_NOMBRE,
               C_TPO_NIT,
               C_TPO_TRCRO,
               N_LINEA;
        if C_ASEGURADOS%notfound then
          exit;
        end if;
        if substr(C_NOMBRE, 1, 2) = '  ' then
          C_NOMBRE := 'P.D';
        end if;
        N_LINEA := N_LINEA + 2;
        BEGIN
          INSERT INTO RDETALLECERTIFICADOS
          VALUES
            (f_comas(C_NUMERO),
             C_NOMBRE,
             N_LINEA,
             C_POLIZA,
             P_FCHA_PGO,
             C_ITEM);
          commit;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20501,
                                    '1. Error insertando en la tabla RDETALLECER ' ||
                                    C_ITEM || ' ' || SQLERRM);
        END;
        if C_TPO_TRCRO = 'J' then
          begin
            select 'R.Legal: ' || substr(Representante_legal, 1, 50),
                   numero_documento_representante
              into rep, nitt
              from juridicos
             where numero_documento = c_numero
               and tipdoc_codigo = c_tipo;
          exception
            when others then
              rep  := ' ';
              nitt := NULL;
          end;
          if (nitt is not null) and (nitt > 0) then
            N_LINEA := N_LINEA + 1;
            BEGIN
              INSERT INTO RDETALLECERTIFICADOS
              VALUES
                (f_comas(NITT), REP, N_LINEA, C_POLIZA, P_FCHA_PGO, C_ITEM);
              commit;
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '1. Error insertando el representante en la tabla RDETALLECER' ||
                                        C_ITEM || ' ' || SQLERRM);
            END;
          end if;
        end if;
        COMMIT;
      END LOOP;
      CLOSE C_ASEGURADOS;
    end loop;
    close C_CERTIF;
  END;

  procedure PR_CERTIFICADOS_CIERRE_TODOS(P_SUCURSAL VARCHAR2,
                                         P_PERIODO  VARCHAR2,
                                         P_POLIZA   NUMBER,
                                         P_FCHA_PGO DATE) is

    cursor C_CERTIF IS
      select unique(rva_nmro_item) SOLICITUD,
             rva_nmro_plza,
             pol_prs_nmro_idntfccion nit_poliza,
             pk_terceros.f_nombres(pol_prs_nmro_idntfccion,
                                   pol_prs_tpo_idntfccion) NOM_POLIZA,
             pol_suc_cdgo SUCURSAL,
             rva_clse_plza CLASE,
             rva_ram_cdgo RAMO,
             RVI_FCHA_DSDE_ACTUAL FECHAD,
             DECODE(DI_DIRECCION,
                    NULL,
                    'NO EXISTE DIRECCION DE RIESGO',
                    DI_DIRECCION) direccion,
             max(rva_fcha_mdfccion) f_reporte,
             trunc(rivn_fcha_mdfccion) FECHAM,
             S.SUC_NMBRE
        from Rsgos_Vgntes_Ampro,
             Rsgos_Vgntes_Nvddes,
             plzas,
             scrsl s,
             direcciones,
             rsgos_vgntes
       where rivn_nmro_plza = P_POLIZA
         and rivn_clse_plza = '00'
         and rivn_ram_cdgo = '12'
         and rivn_tpo_nvdad != '02'
         and rivn_tpo_nvdad != '06'
         and rivn_tpo_nvdad != '09'
         and rivn_tpo_nvdad != '11'
         and rivn_tpo_nvdad != '12'
         and to_char(rivn_fcha_mdfccion, 'MMYYYY') = P_PERIODO
         and RVI_NMRO_ITEM = RVA_NMRO_ITEM
         and RVI_NMRO_PLZA = RVA_NMRO_PLZA
         and RVI_CLSE_PLZA = rva_clse_plza
         and RVI_RAM_CDGO = rva_ram_cdgo
         and pol_nmro_plza = rivn_nmro_plza
         and pol_cdgo_clse = rivn_clse_plza
         and pol_ram_cdgo = rivn_ram_cdgo
         and pol_tpoplza = 'C'
         and pol_suc_cdgo like p_sucursal
         and pol_suc_cia_cdgo = '40'
         and rva_nmro_plza = rivn_nmro_plza
         and rva_clse_plza = rivn_clse_plza
         and rva_ram_cdgo = rivn_ram_cdgo
         and rva_nmro_item = rivn_nmro_item
         and di_solicitud(+) = to_char(rva_nmro_item)
         and di_tpo_drccion(+) = 'R'
         AND (PLZAS.POL_SUC_CDGO = S.SUC_CDGO)
         AND (PLZAS.POL_SUC_CIA_CDGO = S.SUC_CIA_CDGO)
         AND NOT EXISTS (select cer_nmro_plza
                from crtfcdos, plzas
               where cer_nmro_crtfcdo = rvi_nmro_crtfcdo
                 and cer_nmro_plza = pol_nmro_plza
                 and POL_TPORSGO = 'CUM')
       group by pol_prs_nmro_idntfccion,
                pk_terceros.f_nombres(pol_prs_nmro_idntfccion,
                                      pol_prs_tpo_idntfccion),
                rva_nmro_item,
                rva_nmro_plza,
                rva_clse_plza,
                rva_ram_cdgo,
                di_direccion,
                trunc(rivn_fcha_mdfccion),
                pol_suc_cdgo,
                S.SUC_NMBRE,
                RVI_FCHA_DSDE_ACTUAL
       order by pol_suc_cdgo, rva_nmro_plza, rva_nmro_item;

    CURSOR C_ASEGURADOS(V_SOL NUMBER, V_CLSE VARCHAR2, V_RMO VARCHAR2) IS
      select rvi_nmro_item ITEM,
             rvi_nmro_plza POLIZA,
             rvn_prs_tpo_idntfccion TIPO,
             rvn_prs_nmro_idntfccion NUMERO,
             nvl(prs_nmbre, 'P.N') NOMBRE,
             rvn_tpo_nit TPO_NIT,
             tipo_tercero TPO_TRCRO,
             rownum LINEA_ANT
        from riesgos_arrendatarios, tipos_documento
       where RVI_NMRO_PLZA = P_POLIZA
         AND RVI_NMRO_ITEM = V_SOL
         AND POL_CDGO_CLSE = V_CLSE
         AND POL_RAM_CDGO = V_RMO
         AND rvn_prs_tpo_idntfccion = codigo
       order by rvn_tpo_nit desc;

    R_REGISTRO     C_CERTIF%ROWTYPE;
    R_ASGRDOS      C_ASEGURADOS%ROWTYPE;
    V_CANON        NUMBER;
    V_CANON_TOT    NUMBER;
    V_ADMON        NUMBER;
    V_SERVICIO     NUMBER;
    V_RECONEC      NUMBER;
    V_DANOS        NUMBER;
    V_ESPEN        NUMBER;
    V_AMPINTST     NUMBER;
    V_AMPINT       NUMBER;
    V_HOGAR        NUMBER;
    V_MODIFICACION VARCHAR2(60);
    V_NOTA         VARCHAR2(600);
    PRIMA_SER      RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    PRIMA_DANOS    RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    PRIMA_EXP      RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    PRIMA_AIS      RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    PRIMA_AI       RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE;
    V_IVA          NUMBER;
    PRIMA_NETA     NUMBER;
    PRIMA_ARR      NUMBER;
    PRIMA_HOGAR    NUMBER;
    rep            varchar2(300);
    nitt           number;
    n_linea        number;
    entro          varchar2(1);
    CANON_C        VARCHAR2(20);
    ADMON_C        VARCHAR2(20);
    CANON_TOT_C    VARCHAR2(20);
    NIT_C          VARCHAR2(20);
    PRIMA_ARR_C    VARCHAR2(20);
    V_SERVICIO_C   VARCHAR2(20);
    PRIMA_SER_C    VARCHAR2(20);
    V_RECONEC_C    VARCHAR2(20);
    V_DANOS_C      VARCHAR2(20);
    PRIMA_DANOS_C  VARCHAR2(20);
    V_ESPEN_C      VARCHAR2(20);
    PRIMA_EXP_C    VARCHAR2(20);
    V_AMPINTST_C   VARCHAR2(20);
    PRIMA_AIS_C    VARCHAR2(20);
    V_AMPINT_C     VARCHAR2(20);
    PRIMA_AI_C     VARCHAR2(20);
    PRIMA_HOGAR_C  VARCHAR2(20);
    V_HOGAR_C      VARCHAR2(20);

  begin
    SELECT PAR_VLOR2
      INTO V_IVA
      FROM PRMTROS
     WHERE PAR_CDGO = '4'
       AND PAR_MDLO = '6'
       AND PAR_VLOR1 = '01'
       AND PAR_FCHA_CREACION = (SELECT MAX(PAR_FCHA_CREACION)
                                  FROM PRMTROS
                                 WHERE PAR_VLOR1 = '01'
                                   AND PAR_MDLO = '6'
                                   AND PAR_CDGO = '4');
    --entro := 'N';

    open C_CERTIF;
    loop
      fetch C_CERTIF
        INTO R_REGISTRO;
      if C_CERTIF%notfound then
        exit;
      end if;

      SELECT MIN(decode(rvl_cncpto_vlor,
                        '01',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '02',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '03',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '04',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '05',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '06',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '15',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '16',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor))),
             MIN(decode(rvl_cncpto_vlor,
                        '26',
                        decode(nvl(rvl_vlor, 0), 0, 0, rvl_vlor)))
        INTO V_CANON,
             V_ADMON,
             V_SERVICIO,
             V_RECONEC,
             V_DANOS,
             V_ESPEN,
             V_AMPINTST,
             V_AMPINT,
             V_HOGAR
        from Rsgos_Vgntes_avlor
       where rvl_nmro_item = R_REGISTRO.SOLICITUD
         and rvl_nmro_plza = P_POLIZA
         and rvl_clse_plza = R_REGISTRO.CLASE
         and rvl_ram_cdgo = R_REGISTRO.RAMO;

      V_CANON     := NVL(V_CANON, 0);
      V_ADMON     := NVL(V_ADMON, 0);
      V_SERVICIO  := NVL(V_SERVICIO, 0);
      V_RECONEC   := NVL(V_RECONEC, 0);
      V_DANOS     := NVL(V_DANOS, 0);
      V_ESPEN     := NVL(V_ESPEN, 0);
      V_AMPINTST  := NVL(V_AMPINTST, 0);
      V_AMPINT    := NVL(V_AMPINT, 0);
      V_HOGAR     := NVL(V_HOGAR, 0);
      V_CANON_TOT := V_CANON + V_ADMON;

      -- DESCRIPCION DE LA NOTA

      V_MODIFICACION := F_NOVEDAD_CIERRE(R_REGISTRO.SOLICITUD,
                                         P_POLIZA,
                                         R_REGISTRO.CLASE,
                                         R_REGISTRO.RAMO,
                                         P_PERIODO);
      V_NOTA         := F_NOTA_CIERRE(R_REGISTRO.SOLICITUD,
                                      P_POLIZA,
                                      R_REGISTRO.CLASE,
                                      R_REGISTRO.RAMO,
                                      P_PERIODO);

      BEGIN
        SELECT nvl(rva_vlor_prma_nta, 0) rva_vlor_prma_nta
          INTO PRIMA_NETA
          FROM RSGOS_VGNTES_AMPRO, RSGOS_VGNTES_AVLOR
         WHERE RVA_CDGO_AMPRO = '01' --ARRENDAMIENTOS
           AND RVA_RAM_CDGO = R_REGISTRO.RAMO
           AND RVA_NMRO_ITEM = R_REGISTRO.SOLICITUD
           AND RVA_NMRO_PLZA = P_POLIZA
           AND RVA_CLSE_PLZA = R_REGISTRO.CLASE
           AND RVL_CDGO_AMPRO = RVA_CDGO_AMPRO
           AND RVL_RAM_CDGO = RVA_RAM_CDGO
           AND RVL_NMRO_ITEM = RVA_NMRO_ITEM
           AND RVL_NMRO_PLZA = RVA_NMRO_PLZA
           AND RVL_CLSE_PLZA = RVA_CLSE_PLZA
           AND RVL_CNCPTO_VLOR = '01';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          PRIMA_NETA := 0;
      END;

      PRIMA_ARR := round(((PRIMA_NETA * (100 + V_IVA)) / 100), 1);

      SELECT MIN(DECODE(RVL_CNCPTO_VLOR,
                        '03',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0) * 2))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '05',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0)))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '06',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0)))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '15',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0)))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '16',
                        (ROUND(RVL_VLOR * (rva_tsa_ampro / 100), 0)))),
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '26',
                        (NVL(RVL_PRIMA_NETA, 0) + RVL_VALOR_IVA))) +
             MIN(DECODE(RVL_CNCPTO_VLOR,
                        '31',
                        (NVL(RVL_PRIMA_NETA, 0) + RVL_VALOR_IVA)))
        INTO PRIMA_SER,
             PRIMA_DANOS,
             PRIMA_EXP,
             PRIMA_AIS,
             PRIMA_AI,
             PRIMA_HOGAR
        FROM RSGOS_VGNTES_AMPRO, RSGOS_VGNTES_AVLOR
       WHERE RVA_CDGO_AMPRO IN
             ('02', '03', '04', '05', '06', '07', '08', '11')
         AND RVA_RAM_CDGO = R_REGISTRO.RAMO
         AND RVA_NMRO_ITEM = R_REGISTRO.SOLICITUD
         AND RVA_NMRO_PLZA = P_POLIZA
         AND RVA_CLSE_PLZA = R_REGISTRO.CLASE
         AND RVL_CDGO_AMPRO = RVA_CDGO_AMPRO
         AND RVL_RAM_CDGO = RVA_RAM_CDGO
         AND RVL_NMRO_ITEM = RVA_NMRO_ITEM
         AND RVL_NMRO_PLZA = RVA_NMRO_PLZA
         AND RVL_CLSE_PLZA = RVA_CLSE_PLZA
         AND RVL_CNCPTO_VLOR in ('05', '06', '03', '15', '16', '26', '31');

      PRIMA_SER     := NVL(PRIMA_SER, 0);
      PRIMA_DANOS   := NVL(PRIMA_DANOS, 0);
      PRIMA_EXP     := NVL(PRIMA_EXP, 0);
      PRIMA_AIS     := NVL(PRIMA_AIS, 0);
      PRIMA_AI      := NVL(PRIMA_AI, 0);
      PRIMA_HOGAR   := NVL(PRIMA_HOGAR, 0);
      CANON_C       := f_comas(V_CANON);
      ADMON_C       := f_comas(V_ADMON);
      CANON_TOT_C   := f_comas(V_CANON_TOT);
      NIT_C         := f_comas(R_REGISTRO.NIT_POLIZA);
      PRIMA_ARR_C   := f_comas(PRIMA_ARR);
      V_SERVICIO_C  := f_comas(V_SERVICIO);
      PRIMA_SER_C   := f_comas(PRIMA_SER);
      V_RECONEC_C   := f_comas(V_RECONEC);
      V_DANOS_C     := f_comas(V_DANOS);
      PRIMA_DANOS_C := f_comas(PRIMA_DANOS);
      V_ESPEN_C     := f_comas(V_ESPEN);
      PRIMA_EXP_C   := f_comas(PRIMA_EXP);
      V_AMPINTST_C  := f_comas(V_AMPINTST);
      PRIMA_AIS_C   := f_comas(PRIMA_AIS);
      V_AMPINT_C    := f_comas(V_AMPINT);
      PRIMA_AI_C    := f_comas(PRIMA_AI);
      V_HOGAR_C     := F_COMAS(V_HOGAR);
      PRIMA_HOGAR_C := F_COMAS(PRIMA_HOGAR);
      BEGIN
        INSERT INTO RCERTIFICADOS
        VALUES
          (CANON_C,
           R_REGISTRO.SOLICITUD,
           R_REGISTRO.DIRECCION,
           V_MODIFICACION,
           P_FCHA_PGO,
           P_POLIZA,
           NIT_C,
           R_REGISTRO.NOM_POLIZA,
           ADMON_C,
           to_char(R_REGISTRO.FECHAM, 'YYYY/MM/DD'),
           to_char(R_REGISTRO.FECHAD, 'YYYY/MM/DD'),
           '$' || CANON_TOT_C,
           '$' || PRIMA_ARR_C,
           '$' || V_SERVICIO_C,
           '$' || PRIMA_SER_C,
           '$' || V_RECONEC_C,
           '$0',
           '$' || V_DANOS_C,
           '$' || PRIMA_DANOS_C,
           '$' || V_ESPEN_C,
           '$' || PRIMA_EXP_C,
           '$' || V_AMPINTST_C,
           '$' || PRIMA_AIS_C,
           '$' || V_AMPINT_C,
           '$' || PRIMA_AI_C,
           V_NOTA,
           '$' || V_HOGAR_C,
           '$' || PRIMA_HOGAR_C);
        COMMIT;
        entro := 'S';
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20501,
                                  '1. Error insertando en la tabla R_CERTIFICADO ' ||
                                  R_REGISTRO.solicitud || ' ' || SQLERRM);
      END;
      open C_ASEGURADOS(R_REGISTRO.SOLICITUD,
                        R_REGISTRO.CLASE,
                        R_REGISTRO.RAMO);
      N_LINEA := 1;
      loop
        fetch C_ASEGURADOS
          into R_ASGRDOS;
        if C_ASEGURADOS%notfound then
          exit;
        end if;

        if substr(R_ASGRDOS.NOMBRE, 1, 2) = '  ' then
          R_ASGRDOS.NOMBRE := 'P.D';
        end if;
        N_LINEA := N_LINEA + 2;
        BEGIN
          INSERT INTO RDETALLECERTIFICADOS
          VALUES
            (f_comas(R_ASGRDOS.NUMERO),
             R_ASGRDOS.NOMBRE,
             N_LINEA,
             R_ASGRDOS.POLIZA,
             P_FCHA_PGO,
             R_ASGRDOS.ITEM);
          commit;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20501,
                                    '1. Error insertando en la tabla RDETALLECER ' ||
                                    R_ASGRDOS.ITEM || ' ' || SQLERRM);
        END;
        if R_ASGRDOS.TPO_TRCRO = 'J' then
          begin
            select 'R.Legal: ' || substr(Representante_legal, 1, 50),
                   numero_documento_representante
              into rep, nitt
              from juridicos
             where numero_documento = R_ASGRDOS.numero
               and tipdoc_codigo = R_ASGRDOS.tipo;
          exception
            when others then
              rep  := ' ';
              nitt := NULL;
          end;
          if (nitt is not null) and (nitt > 0) then
            N_LINEA := N_LINEA + 1;
            BEGIN
              INSERT INTO RDETALLECERTIFICADOS
              VALUES
                (f_comas(NITT),
                 REP,
                 N_LINEA,
                 R_ASGRDOS.POLIZA,
                 P_FCHA_PGO,
                 R_ASGRDOS.ITEM);
              commit;
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '1. Error insertando el representante en la tabla RDETALLECER' ||
                                        R_ASGRDOS.ITEM || ' ' || SQLERRM);
            END;
          end if;
        end if;
      END LOOP;
      CLOSE C_ASEGURADOS;
    end loop;
    close C_CERTIF;
  exception
    when others then
      raise_application_error(-20510,
                              'Error en proceso de certificados ' || ' ' ||
                              SQLERRM);
  end;

  ---PROCEDIMIENTO DE NOVEDADES.
  procedure PR_RNOVEDADES(P_POLIZA          NUMBER,
                          P_CLASE           VARCHAR2,
                          P_RAMO            VARCHAR2,
                          P_CODIGO_SUCURSAL VARCHAR2,
                          P_CODIGO_COMPANIA VARCHAR2,
                          P_PERIODO         VARCHAR2,
                          P_FECHA_PAGO      DATE) is

    cursor C_NOVEDADES is
      SELECT ALL POL.POL_NMRO_PLZA POLIZA,
                 PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,
                                       POL_PRS_TPO_IDNTFCCION) N_POLIZA,
                 POL.POL_SUC_CDGO SUCURSAL,
                 POL.POL_PRS_NMRO_IDNTFCCION NIT,
                 SUC_NMBRE NOMBRE_SUC,
                 RIVN.RIVN_NMRO_ITEM ITEM,
                 PK_TERCEROS.F_NOMBRES(RVA_PRS_NMRO_IDNTFCCION,
                                       RVA_PRS_TPO_IDNTFCCION) NOMBER_INQ,
                 RVA_PRS_NMRO_IDNTFCCION NMRO_ID,
                 RVA_PRS_TPO_IDNTFCCION TPO_ID,
                 RIVN.RIVN_FCHA_NVDAD FCHA_NOVEDAD,
                 RIVN.RIVN_TPO_NVDAD NOVEDAD,
                 TNP.TNP_DSCRPCION TIPO_NOV,
                 RIVN.RIVN_CDGO_AMPRO C_AMPARO,
                 APR.APR_ALIAS AMPARO,
                 RIVN.RIVN_VLOR_DFRNCIA VALOR,
                 RVA.RVA_VLOR_ASGRDO_TTAL VALOR_A
        FROM PLZAS               POL,
             SCRSL,
             RSGOS_VGNTES_NVDDES RIVN,
             TPOS_NVDAD_PRDCTO   TNP,
             RSGOS_VGNTES_AMPRO  RVA,
             AMPROS_PRDCTO       APR
       WHERE POL.POL_NMRO_PLZA = P_POLIZA
         AND POL.POL_CDGO_CLSE = P_CLASE
         AND POL.POL_RAM_CDGO = P_RAMO
         AND POL.POL_SUC_CDGO = P_CODIGO_SUCURSAL
         AND POL.POL_SUC_CIA_CDGO = P_CODIGO_COMPANIA
         AND POL.POL_TPOPLZA = 'C'
         AND SUC_CDGO = POL.POL_SUC_CDGO
         AND SUC_CIA_CDGO = P_CODIGO_COMPANIA
         AND POL.POL_NMRO_PLZA = RIVN.RIVN_NMRO_PLZA
         AND POL.POL_CDGO_CLSE = RIVN.RIVN_CLSE_PLZA
         AND POL.POL_RAM_CDGO = RIVN.RIVN_RAM_CDGO
         AND RIVN.RIVN_TPO_NVDAD IN
             ('01', '04', '03', '05', '06', '07', '09')
         AND TO_CHAR(RIVN.RIVN_FCHA_MDFCCION, 'MMYYYY') = P_PERIODO
         AND RIVN.RIVN_TPO_NVDAD = TNP.TNP_CDGO
         AND RIVN.RIVN_RAM_CDGO = TNP.TNP_RAM_CDGO
         AND RVA.RVA_NMRO_ITEM = RIVN.RIVN_NMRO_ITEM
         AND RVA.RVA_NMRO_PLZA = RIVN.RIVN_NMRO_PLZA
         AND RVA.RVA_CLSE_PLZA = RIVN.RIVN_CLSE_PLZA
         AND RVA.RVA_RAM_CDGO = RIVN.RIVN_RAM_CDGO
         AND RVA.RVA_CDGO_AMPRO = RIVN.RIVN_CDGO_AMPRO
         AND RVA.RVA_CDGO_AMPRO = APR.APR_CDGO_AMPRO
      UNION
      SELECT ALL POL.POL_NMRO_PLZA POLIZA,
                 PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,
                                       POL_PRS_TPO_IDNTFCCION) N_POLIZA,
                 POL.POL_SUC_CDGO SUCUSAL,
                 POL.POL_PRS_NMRO_IDNTFCCION NIT,
                 SUC_NMBRE NOMBRE_SUC,
                 REN.REN_NMRO_ITEM ITEM,
                 PK_TERCEROS.F_NOMBRES(RIR_NMRO_IDNTFCCION,
                                       RIR_TPO_IDNTFCCION) NOMBRE_INQ,
                 RIR_NMRO_IDNTFCCION NMRO_ID,
                 RIR_TPO_IDNTFCCION TPO_ID,
                 REN.REN_FCHA_NVDAD FCHA_NOVEDAD,
                 REN.REN_TPO_NVDAD NOVEDAD,
                 TNP.TNP_DSCRPCION TIPO_NOV,
                 REN.REN_CDGO_AMPRO C_AMPARO,
                 APR.APR_ALIAS AMPARO,
                 REN.REN_VLOR_DFRNCIA VALOR,
                 REN.REN_VLOR_DFRNCIA VALOR_A
        FROM PLZAS             POL,
             SCRSL,
             RSGOS_RCBOS_NVDAD REN,
             TPOS_NVDAD_PRDCTO TNP,
             CRTFCDOS          CER,
             RSGOS_RCBOS       RIR,
             AMPROS_PRDCTO     APR
       WHERE POL.POL_NMRO_PLZA = P_POLIZA
         AND POL.POL_CDGO_CLSE = P_CLASE
         AND POL.POL_RAM_CDGO = P_RAMO
         AND POL.POL_SUC_CDGO = P_CODIGO_SUCURSAL
         AND POL.POL_SUC_CIA_CDGO = P_CODIGO_COMPANIA
         AND SUC_CDGO = POL.POL_SUC_CDGO
         AND SUC_CIA_CDGO = P_CODIGO_COMPANIA
         AND POL.POL_NMRO_PLZA = REN.REN_NMRO_PLZA
         AND POL.POL_CDGO_CLSE = REN.REN_CLSE_PLZA
         AND POL.POL_RAM_CDGO = REN.REN_RAM_CDGO
         AND REN.REN_TPO_NVDAD = '02'
         AND CER.CER_NMRO_CRTFCDO = REN.REN_NMRO_CRTFCDO
         AND CER.CER_NMRO_PLZA = REN.REN_NMRO_PLZA
         AND CER.CER_RAM_CDGO = REN.REN_RAM_CDGO
         AND CER.CER_CLSE_PLZA = REN.REN_CLSE_PLZA
         AND TO_CHAR(CER.CER_FCHA_DSDE_ACTUAL, 'MMYYYY') = P_PERIODO
         AND REN.REN_RAM_CDGO = TNP.TNP_RAM_CDGO
         AND REN.REN_TPO_NVDAD = TNP.TNP_CDGO
         AND REN.REN_NMRO_ITEM = RIR.RIR_NMRO_ITEM
         AND REN.REN_NMRO_CRTFCDO = RIR.RIR_NMRO_CRTFCDO
         AND REN.REN_NMRO_PLZA = RIR.RIR_NMRO_PLZA
         AND REN.REN_CDGO_AMPRO = APR.APR_CDGO_AMPRO
       ORDER BY sucursal, poliza;

    V_POLIZA       PLZAS.POL_NMRO_PLZA%TYPE;
    V_NOM_POLIZA   varchar2(120); ---PRSNAS.PRS_NMBRE_ANT%TYPE;
    V_SUCURSAL     PLZAS.POL_SUC_CDGO%TYPE;
    V_NIT          PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
    V_SUC_NMBRE    SCRSL.SUC_NMBRE%TYPE;
    V_ITEM         RSGOS_RCBOS_NVDAD.REN_NMRO_ITEM%TYPE;
    V_NOMBRE_INQ   PRSNAS.PRS_NMBRE_ANT%TYPE;
    V_NMRO_ID      PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
    V_TPO_ID       PLZAS.POL_PRS_TPO_IDNTFCCION%TYPE;
    V_FCHA_NOVEDAD RSGOS_RCBOS_NVDAD.REN_FCHA_NVDAD%TYPE;
    V_NOVEDAD      RSGOS_RCBOS_NVDAD.REN_TPO_NVDAD%TYPE;
    V_TIPO_NOV     varchar2(300); --RSGOS_RCBOS_NVDAD.REN_TPO_NVDAD%TYPE;
    V_COD_AMPARO   RSGOS_RCBOS_NVDAD.REN_CDGO_AMPRO%TYPE;
    V_AMPARO       AMPROS_PRDCTO.APR_ALIAS%TYPE;
    V_VALOR        RSGOS_RCBOS_NVDAD.REN_VLOR_DFRNCIA%TYPE;
    V_VALOR_A      RSGOS_RCBOS_NVDAD.REN_VLOR_DFRNCIA%TYPE;
    CONSECUTIVO    NUMBER(10) := 0;

  begin

    open C_NOVEDADES;
    loop
      fetch C_NOVEDADES
        into V_POLIZA,
             V_NOM_POLIZA,
             V_SUCURSAL,
             V_NIT,
             V_SUC_NMBRE,
             V_ITEM,
             V_NOMBRE_INQ,
             V_NMRO_ID,
             V_TPO_ID,
             V_FCHA_NOVEDAD,
             V_NOVEDAD,
             V_TIPO_NOV,
             V_COD_AMPARO,
             V_AMPARO,
             V_VALOR,
             V_VALOR_A;

      if C_NOVEDADES%notfound then
        exit;
      end if;
      CONSECUTIVO := CONSECUTIVO + 1;
      if substr(V_NOMBRE_INQ, 1, 2) = '  ' then
        V_NOMBRE_INQ := 'P.D';
      end if;
      BEGIN
        INSERT INTO RNOVEDADES
        VALUES
          (V_VALOR,
           CONSECUTIVO,
           V_NOMBRE_INQ,
           V_AMPARO,
           V_ITEM,
           V_FCHA_NOVEDAD,
           V_TIPO_NOV,
           V_POLIZA,
           P_FECHA_PAGO,
           V_NMRO_ID,
           V_TPO_ID);
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20501,
                                  '1. Error insertando en la tabla rnovedad ' ||
                                  v_item || ' ' || SQLERRM);
      END;
    end loop;
    close C_NOVEDADES;
  end;

  procedure PR_RNOVEDADES_TODOS(P_CODIGO_SUCURSAL VARCHAR2,
                                P_PERIODO         VARCHAR2,
                                P_POLIZA          NUMBER,
                                P_FCHA_PGO        DATE) IS

    cursor C_NOVEDADES IS
      SELECT ALL POL.POL_NMRO_PLZA POLIZA,
                 PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,
                                       POL_PRS_TPO_IDNTFCCION) N_POLIZA,
                 POL.POL_SUC_CDGO SUCURSAL,
                 POL.POL_PRS_NMRO_IDNTFCCION NIT,
                 SUC_NMBRE NOMBRE_SUC,
                 RIVN.RIVN_NMRO_ITEM ITEM,
                 PK_TERCEROS.F_NOMBRES(RVA_PRS_NMRO_IDNTFCCION,
                                       RVA_PRS_TPO_IDNTFCCION) NOMBRE_INQ,
                 RVA_PRS_NMRO_IDNTFCCION NMRO_ID,
                 RVA_PRS_TPO_IDNTFCCION TPO_ID,
                 RIVN.RIVN_FCHA_NVDAD FCHA_NOVEDAD,
                 RIVN.RIVN_TPO_NVDAD NOVEDAD,
                 TNP.TNP_DSCRPCION TIPO_NOV,
                 RIVN.RIVN_CDGO_AMPRO C_AMPARO,
                 APR.APR_ALIAS AMPARO,
                 RIVN.RIVN_VLOR_DFRNCIA VALOR,
                 RVA.RVA_VLOR_ASGRDO_TTAL VALOR_A
        FROM PLZAS               POL,
             SCRSL,
             RSGOS_VGNTES_NVDDES RIVN,
             TPOS_NVDAD_PRDCTO   TNP,
             RSGOS_VGNTES_AMPRO  RVA,
             AMPROS_PRDCTO       APR
       WHERE POL.POL_NMRO_PLZA = P_POLIZA
         AND POL.POL_CDGO_CLSE = '00'
         AND POL.POL_RAM_CDGO = '12'
         AND POL.POL_SUC_CDGO LIKE P_CODIGO_SUCURSAL
         AND POL.POL_SUC_CIA_CDGO = '40'
         AND POL.POL_TPOPLZA = 'C'
         AND SUC_CDGO = POL.POL_SUC_CDGO
         AND SUC_CIA_CDGO = '40'
         AND POL.POL_NMRO_PLZA = RIVN.RIVN_NMRO_PLZA
         AND POL.POL_CDGO_CLSE = RIVN.RIVN_CLSE_PLZA
         AND POL.POL_RAM_CDGO = RIVN.RIVN_RAM_CDGO
         AND RIVN.RIVN_TPO_NVDAD IN
             ('01', '04', '03', '05', '06', '07', '09')
         AND TO_CHAR(RIVN.RIVN_FCHA_MDFCCION, 'MMYYYY') = P_PERIODO
         AND RIVN.RIVN_TPO_NVDAD = TNP.TNP_CDGO
         AND RIVN.RIVN_RAM_CDGO = TNP.TNP_RAM_CDGO
         AND RVA.RVA_NMRO_ITEM = RIVN.RIVN_NMRO_ITEM
         AND RVA.RVA_NMRO_PLZA = RIVN.RIVN_NMRO_PLZA
         AND RVA.RVA_CLSE_PLZA = RIVN.RIVN_CLSE_PLZA
         AND RVA.RVA_RAM_CDGO = RIVN.RIVN_RAM_CDGO
         AND RVA.RVA_CDGO_AMPRO = RIVN.RIVN_CDGO_AMPRO
         AND RVA.RVA_CDGO_AMPRO = APR.APR_CDGO_AMPRO
      UNION
      SELECT ALL POL.POL_NMRO_PLZA POLIZA,
                 PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,
                                       POL_PRS_TPO_IDNTFCCION) N_POLIZA,
                 POL.POL_SUC_CDGO SUCURSAL,
                 POL.POL_PRS_NMRO_IDNTFCCION NIT,
                 SUC_NMBRE NOMBRE_SUC,
                 REN.REN_NMRO_ITEM ITEM,
                 PK_TERCEROS.F_NOMBRES(RIR_NMRO_IDNTFCCION,
                                       RIR_TPO_IDNTFCCION) NOMBRE_INQ,
                 RIR_NMRO_IDNTFCCION NMRO_ID,
                 RIR_TPO_IDNTFCCION TPO_ID,
                 REN.REN_FCHA_NVDAD FCHA_NOVEDAD,
                 REN.REN_TPO_NVDAD NOVEDAD,
                 TNP.TNP_DSCRPCION TIPO_NOV,
                 REN.REN_CDGO_AMPRO C_AMPARO,
                 APR.APR_ALIAS AMPARO,
                 REN.REN_VLOR_DFRNCIA VALOR,
                 REN.REN_VLOR_DFRNCIA VALOR_A
        FROM PLZAS             POL,
             SCRSL,
             RSGOS_RCBOS_NVDAD REN,
             TPOS_NVDAD_PRDCTO TNP,
             CRTFCDOS          CER,
             RSGOS_RCBOS       RIR,
             AMPROS_PRDCTO     APR
       WHERE POL.POL_NMRO_PLZA = P_POLIZA
         AND POL.POL_CDGO_CLSE = '00'
         AND POL.POL_RAM_CDGO = '12'
         AND POL.POL_SUC_CDGO LIKE P_CODIGO_SUCURSAL
         AND POL.POL_SUC_CIA_CDGO = '40'
         AND SUC_CDGO = POL.POL_SUC_CDGO
         AND SUC_CIA_CDGO = '40'
         AND POL.POL_NMRO_PLZA = REN.REN_NMRO_PLZA
         AND POL.POL_CDGO_CLSE = REN.REN_CLSE_PLZA
         AND POL.POL_RAM_CDGO = REN.REN_RAM_CDGO
         AND REN.REN_TPO_NVDAD = '02'
         AND CER.CER_NMRO_CRTFCDO = REN.REN_NMRO_CRTFCDO
         AND CER.CER_NMRO_PLZA = REN.REN_NMRO_PLZA
         AND CER.CER_RAM_CDGO = REN.REN_RAM_CDGO
         AND CER.CER_CLSE_PLZA = REN.REN_CLSE_PLZA
         AND TO_CHAR(CER.CER_FCHA_DSDE_ACTUAL, 'MMYYYY') = P_PERIODO
         AND REN.REN_RAM_CDGO = TNP.TNP_RAM_CDGO
         AND REN.REN_TPO_NVDAD = TNP.TNP_CDGO
         AND REN.REN_NMRO_ITEM = RIR.RIR_NMRO_ITEM
         AND REN.REN_NMRO_CRTFCDO = RIR.RIR_NMRO_CRTFCDO
         AND REN.REN_NMRO_PLZA = RIR.RIR_NMRO_PLZA
         AND REN.REN_CDGO_AMPRO = APR.APR_CDGO_AMPRO
       ORDER BY sucursal, poliza;

    R_NVDDES    C_NOVEDADES%ROWTYPE;
    CONSECUTIVO NUMBER(10) := 0;
    entro       VARCHAR2(1);
    V_VALOR_C   VARCHAR2(25);
    V_VALOR_CEN VARCHAR2(25);

  begin

    open C_NOVEDADES;
    loop
      fetch C_NOVEDADES
        into R_NVDDES;
      if C_NOVEDADES%notfound then
        exit;
      end if;
      CONSECUTIVO := CONSECUTIVO + 1;
      if substr(R_NVDDES.NOMBRE_INQ, 1, 2) = '  ' then
        R_NVDDES.NOMBRE_INQ := 'P.D';
      end if;
      V_VALOR_C   := f_comas(R_NVDDES.VALOR);
      V_VALOR_CEN := f_centrar(V_VALOR_C, 25);
      BEGIN
        INSERT INTO RNOVEDADES
        VALUES
          (V_VALOR_CEN,
           CONSECUTIVO,
           R_NVDDES.NOMBRE_INQ,
           ' ' || R_NVDDES.AMPARO,
           ' ' || R_NVDDES.ITEM,
           R_NVDDES.FCHA_NOVEDAD,
           R_NVDDES.TIPO_NOV,
           R_NVDDES.POLIZA,
           P_FCHA_PGO,
           R_NVDDES.NMRO_ID,
           R_NVDDES.TPO_ID);
        COMMIT;
        entro := 'S';
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20501,
                                  '1. Error insertando en la tabla rnovedad ' ||
                                  R_NVDDES.item || ' ' || SQLERRM);
      END;

    end loop;
    close C_NOVEDADES;
  end;

  procedure PR_CARTAS_RECHAZO(P_POLIZA   NUMBER,
                              P_RAMO     VARCHAR2,
                              P_CLASE    VARCHAR2,
                              P_SUCURSAL VARCHAR2,
                              P_COMPANIA VARCHAR2,
                              P_FCHA_PGO DATE) is

    cursor C_CARTAS is
      SELECT NRZ.NRZ_NMRO_RGSTRO REGISTRO,
             NRZ.NRZ_NMRO_CRTFCDO CERTIFICADO,
             NRZ.NRZ_NMRO_SLCTUD SOLICITUD,
             NRZ.NRZ_CDGO_RCHZO CODIGO_NOVEDAD,
             NRZ.NRZ_NMRO_PLZA POLIZA,
             POL.POL_PRS_NMRO_IDNTFCCION NUMERO,
             POL.POL_PRS_TPO_IDNTFCCION TIPO,
             POL.POL_SUC_CDGO,
             DIV.NOM_CIU CIUDAD,
             PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,
                                   POL_PRS_TPO_IDNTFCCION) NOM_POLIZA,
             POL.POL_SUC_TRCRO SEC_DIR
        FROM NVDDES_RCHZDAS NRZ, PLZAS POL, V_DIVISION_POLITICAS DIV
       WHERE NRZ.NRZ_RAM_CDGO = P_RAMO
         AND NRZ.NRZ_CLSE_PLZA = P_CLASE
         AND POL.POL_NMRO_PLZA = NRZ.NRZ_NMRO_PLZA
         AND POL.POL_SUC_CDGO = P_SUCURSAL
         AND POL.POL_SUC_CIA_CDGO = P_COMPANIA
         AND POL.POL_TPOPLZA = 'C'
         AND POL.POL_NMRO_PLZA = P_POLIZA
         AND POL.POL_DIV_CDGO = DIV.CODAZZI_CIU
       ORDER BY POL.POL_SUC_CDGO, NRZ.NRZ_NMRO_PLZA;

    V_REGISTRO    NVDDES_RCHZDAS.NRZ_NMRO_RGSTRO%TYPE;
    V_CERTIFICADO NVDDES_RCHZDAS.NRZ_NMRO_CRTFCDO%TYPE;
    V_SOLICITUD   NVDDES_RCHZDAS.NRZ_NMRO_SLCTUD%TYPE;
    V_COD_NOVEDAD NVDDES_RCHZDAS.NRZ_CDGO_RCHZO%TYPE;
    V_POLIZA      NVDDES_RCHZDAS.NRZ_NMRO_PLZA%TYPE;
    V_NUMERO      PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
    V_TIPO        PLZAS.POL_PRS_TPO_IDNTFCCION%TYPE;
    V_SUCURSAL    PLZAS.POL_SUC_CDGO%TYPE;
    V_CIUDAD      V_DIVISION_POLITICAS.NOM_CIU%TYPE;
    V_NOM_POLIZA  varchar2(120); 
    V_SECDIR      PLZAS.POL_SUC_TRCRO%TYPE;
    V_DESCRIPCION VARCHAR2(300);

  begin
    open C_CARTAS;
    loop
      fetch C_CARTAS
        into V_REGISTRO,
             V_CERTIFICADO,
             V_SOLICITUD,
             V_COD_NOVEDAD,
             V_POLIZA,
             V_NUMERO,
             V_TIPO,
             V_SUCURSAL,
             V_CIUDAD,
             V_NOM_POLIZA,
             V_SECDIR;
      if C_CARTAS%notfound then
        exit;
      end if;
      BEGIN
        SELECT RCN.RCN_DSCRPCION
          INTO V_DESCRIPCION
          FROM RCHZOS_NVDDES RCN
         WHERE RCN.RCN_RAM_CDGO = P_RAMO
           AND RCN.RCN_CDGO = V_COD_NOVEDAD;
        BEGIN
          INSERT INTO RCARTAS
          VALUES
            (1, V_SOLICITUD, V_DESCRIPCION, V_POLIZA, P_FCHA_PGO);
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20501,
                                    '1. Error insertando en la tabla R_CARTAS ' ||
                                    v_solicitud || ' ' || SQLERRM);
        END;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    end loop;
    close C_CARTAS;
  end;

  function f_centrar(p_cadena varchar2, tamano number) return varchar2 is
    --Funcion que dada una variable char centra su contenido distribuido en
    --en el valor de la variable tamano. En estos momentos se usa para una
    --variable max de 100.   AUTOR : DAP. 21/09/2009.
    Result varchar2(100);
    i      varchar2(100);
    y      number;

  begin
    if tamano > 100 then
      raise_application_error(-20501,
                              '1. Error centrando variable tamano excedido.');
      return('Error');
    end if;
    if tamano = LENGTH(p_cadena) then
      Result := p_cadena;
    else
      y := 1;
      while y <= (tamano - LENGTH(p_cadena) - 1) / 2 loop
        i := i || ' ';
        y := y + 1;
      end loop;
      i      := i || p_cadena;
      Result := i;
    end if;
    return(Result);
  end f_centrar;

  --
  --
  --
  procedure PR_CREAR_ARCHIVOSOLD(P_FCHA_PGO DATE) IS

    CURSOR C_EXTRACTO IS
      SELECT POLIZA, COUNT(9)
        FROM REXTRACTOS
       WHERE FECHA_PAGO = P_FCHA_PGO
       GROUP BY POLIZA;

    CURSOR C_SINIESTROS IS
      SELECT SNA_NMRO_PLZA, COUNT(9)
        FROM RSINIESTROS
       WHERE PES_FCHA_PGO = P_FCHA_PGO
       GROUP BY SNA_NMRO_PLZA;

    CURSOR C_CARTAS IS
      SELECT REXT_POLIZA, COUNT(9)
        FROM RCARTAS
       WHERE REXT_FECHA_PAGO = P_FCHA_PGO
       GROUP BY REXT_POLIZA;

    CURSOR C_NOVEDADES IS
      SELECT REXT_POLIZA, COUNT(9)
        FROM RNOVEDADES
       WHERE REXT_FECHA_PAGO = P_FCHA_PGO
       GROUP BY REXT_POLIZA;

    CURSOR C_ASEGURADOS IS
      SELECT POLIZA, COUNT(9)
        FROM RASEGURADOS
       WHERE PERIODO = TO_CHAR(P_FCHA_PGO, 'MMYYYY')
         AND FECHA_PAGO = P_FCHA_PGO
       GROUP BY POLIZA;

    CURSOR C_CERTIFICADOS IS
      SELECT POLIZA, COUNT(9)
        FROM RCERTIFICADOS
       WHERE POLIZA > 0
         AND FECHA_PAGO = P_FCHA_PGO
       GROUP BY POLIZA;

    CURSOR C_POLIZAS(NUMERO_P NUMBER) IS
      SELECT POL_PRS_NMRO_IDNTFCCION,
             PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,
                                   POL_PRS_TPO_IDNTFCCION)
        FROM PLZAS
       WHERE POL_NMRO_PLZA = NUMERO_P
         AND POL_CDGO_CLSE = '00'
         AND POL_RAM_CDGO = '12';
    POLI     NUMBER(10);
    CUANTOS  NUMBER(10);
    NIT_P    NUMBER(13);
    EXISTE   VARCHAR2(1);
    NOMBRE_P VARCHAR2(120);

  BEGIN
    OPEN C_EXTRACTO;
    LOOP
      FETCH C_EXTRACTO
        INTO POLI, CUANTOS;
      IF C_EXTRACTO%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Extracto de Cuenta'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Extracto de Cuenta',
                 'EX4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '2. Error insertando Tabla RARCHIVOS REXTRACTOS ' || POLI || ' ' ||
                                        SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '2. Error insertando Tabla REPORTES' || POLI || ' ' ||
                                        SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_EXTRACTO;

    OPEN C_SINIESTROS;
    LOOP
      FETCH C_SINIESTROS
        INTO POLI, CUANTOS;
      IF C_SINIESTROS%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Relación de Siniestros'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Relación de Siniestros',
                 'SI4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '2. Error insertando Tabla RARCHIVOS RSINIESTROS ' || POLI || ' ' ||
                                        SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '2. Error insertando Tabla REPORTES' || POLI || ' ' ||
                                        SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_SINIESTROS;

    OPEN C_CARTAS;
    LOOP
      FETCH C_CARTAS
        INTO POLI, CUANTOS;
      IF C_CARTAS%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Carta Rechazo'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Carta Rechazo',
                 'CA4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '2. Error insertando Tabla RARCHIVOS RCARTAS ' || POLI || ' ' ||
                                        SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '2. Error insertando Tabla REPORTES' || POLI || ' ' ||
                                        SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_CARTAS;

    OPEN C_NOVEDADES;
    LOOP
      FETCH C_NOVEDADES
        INTO POLI, CUANTOS;
      IF C_NOVEDADES%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Listado Novedades'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Listado Novedades',
                 'NO4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,
                                        '2. Error insertando Tabla RARCHIVOS RNOVEDADES ' || POLI || ' ' ||
                                        SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' ||SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_NOVEDADES;

    OPEN C_ASEGURADOS;
    LOOP
      FETCH C_ASEGURADOS
        INTO POLI, CUANTOS;
      IF C_ASEGURADOS%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Relación Asegurados'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Relación Asegurados',
                 'RA4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla RARCHIVOS RASEGURADOS ' || POLI || ' ' ||SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' ||SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_ASEGURADOS;

    OPEN C_CERTIFICADOS;
    LOOP
      FETCH C_CERTIFICADOS
        INTO POLI, CUANTOS;
      IF C_CERTIFICADOS%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Certificado de Seguro'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Certificado de Seguro',
                 'CS4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla RARCHIVOS RCERTIFICADOS ' || POLI || ' ' || SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' ||SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_CERTIFICADOS;

  END PR_CREAR_ARCHIVOSOLD;

  --
  --
  --
  procedure PR_CREAR_ARCHIVOS(P_FCHA_PGO DATE) IS

    CURSOR C_EXTRACTO IS
      SELECT EXT_NMRO_PLZA, COUNT(9)
        FROM EXTRACTOS
       WHERE EXT_FECHA_PAGO = P_FCHA_PGO
       GROUP BY EXT_NMRO_PLZA;

    CURSOR C_SINIESTROS IS
      SELECT SNA_NMRO_PLZA, COUNT(9)
        FROM RSINIESTROS
       WHERE PES_FCHA_PGO = P_FCHA_PGO
       GROUP BY SNA_NMRO_PLZA;

    CURSOR C_CARTAS IS
      SELECT REXT_POLIZA, COUNT(9)
        FROM RCARTAS
       WHERE REXT_FECHA_PAGO = P_FCHA_PGO
       GROUP BY REXT_POLIZA;

    CURSOR C_NOVEDADES IS
      SELECT REXT_POLIZA, COUNT(9)
        FROM RNOVEDADES
       WHERE REXT_FECHA_PAGO = P_FCHA_PGO
       GROUP BY REXT_POLIZA;

    CURSOR C_ASEGURADOS IS
      SELECT POLIZA, COUNT(9)
        FROM RASEGURADOSRES
       WHERE PERIODO = TO_CHAR(P_FCHA_PGO, 'MMYYYY')
         AND FECHA_PAGO = P_FCHA_PGO
       GROUP BY POLIZA;

    CURSOR C_CERTIFICADOS IS
      SELECT POLIZA, COUNT(9)
        FROM RCERTIFICADOS
       WHERE POLIZA > 0
         AND FECHA_PAGO = P_FCHA_PGO
       GROUP BY POLIZA;

    CURSOR C_POLIZAS(NUMERO_P NUMBER) IS
      SELECT POL_PRS_NMRO_IDNTFCCION,
             PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,
                                   POL_PRS_TPO_IDNTFCCION)
        FROM PLZAS
       WHERE POL_NMRO_PLZA = NUMERO_P
         AND POL_CDGO_CLSE = '00'
         AND POL_RAM_CDGO = '12';

    CURSOR C_POLIZAS_HOGAR IS
      SELECT POL_NMRO_PLZA,
             POL_PRS_NMRO_IDNTFCCION,
             PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,
                                   POL_PRS_TPO_IDNTFCCION)
        FROM PLZAS P
       WHERE P.POL_TPOPLZA = 'C'
         AND NVL(P.POL_ASSTNCIA, 'N') = 'S'
         AND POL_CDGO_CLSE = '00'
         AND POL_RAM_CDGO = '12';

    POLI     NUMBER(10);
    CUANTOS  NUMBER(10);
    NIT_P    NUMBER(13);
    EXISTE   VARCHAR2(1);
    NOMBRE_P VARCHAR2(120);

  BEGIN
    OPEN C_EXTRACTO;
    LOOP
      FETCH C_EXTRACTO
        INTO POLI, CUANTOS;
      IF C_EXTRACTO%NOTFOUND THEN
        EXIT;
      END IF;

      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Extracto de Cuenta'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Extracto de Cuenta',
                 'EX4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla RARCHIVOS REXTRACTOS ' || POLI || ' ' ||SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' || SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_EXTRACTO;

    OPEN C_SINIESTROS;
    LOOP
      FETCH C_SINIESTROS
        INTO POLI, CUANTOS;
      IF C_SINIESTROS%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Relación de Siniestros'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Relación de Siniestros',
                 'SI4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla RARCHIVOS RSINIESTROS ' || POLI || ' ' ||SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' ||SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_SINIESTROS;

    OPEN C_CARTAS;
    LOOP
      FETCH C_CARTAS
        INTO POLI, CUANTOS;
      IF C_CARTAS%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Carta Rechazo'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Carta Rechazo',
                 'CA4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla RARCHIVOS RCARTAS ' || POLI || ' ' ||SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' ||SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_CARTAS;

    OPEN C_NOVEDADES;
    LOOP
      FETCH C_NOVEDADES
        INTO POLI, CUANTOS;
      IF C_NOVEDADES%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Listado Novedades'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Listado Novedades',
                 'NO4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla RARCHIVOS RNOVEDADES ' || POLI || ' ' ||SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' ||SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_NOVEDADES;

    OPEN C_ASEGURADOS;
    LOOP
      FETCH C_ASEGURADOS
        INTO POLI, CUANTOS;
      IF C_ASEGURADOS%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Relación Asegurados'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Relación Asegurados',
                 'RA4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla RARCHIVOS RASEGURADOS ' || POLI || ' ' ||SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' || SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_ASEGURADOS;

    OPEN C_CERTIFICADOS;
    LOOP
      FETCH C_CERTIFICADOS
        INTO POLI, CUANTOS;
      IF C_CERTIFICADOS%NOTFOUND THEN
        EXIT;
      END IF;
      BEGIN
        OPEN C_POLIZAS(POLI);
        FETCH C_POLIZAS
          INTO NIT_P, NOMBRE_P;
        CLOSE C_POLIZAS;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RARCHIVOS
           WHERE NOMBRE = 'Certificado de Seguro'
             AND POLIZA = POLI
             AND FECHA_PGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RARCHIVOS
              VALUES
                ('Certificado de Seguro',
                 'CS4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
                 POLI,
                 P_FCHA_PGO,
                 NIT_P);
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla RARCHIVOS RCERTIFICADOS ' || POLI || ' ' || SQLERRM);
            END;
        END;
        BEGIN
          SELECT '1'
            INTO EXISTE
            FROM RREPORTES
           WHERE REP_POLIZA = POLI
             AND REP_FECHA_PAGO = P_FCHA_PGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              INSERT INTO RREPORTES
              VALUES
                (POLI, P_FCHA_PGO, NOMBRE_P, '0');
            EXCEPTION
              WHEN OTHERS THEN
                raise_application_error(-20501,'2. Error insertando Tabla REPORTES' || POLI || ' ' || SQLERRM);
            END;
        END;
        COMMIT;

      END;
    END LOOP;
    CLOSE C_CERTIFICADOS;

    -- Se incluye para que a las pólizas que tengan marca de convenio de asistencia
    -- se les genere el clausulado de las pólizas de hogar. SPPC. 17/10/2012.
    OPEN C_POLIZAS_HOGAR;
    LOOP
      FETCH C_POLIZAS_HOGAR
        INTO POLI, NIT_P, NOMBRE_P;
      IF C_POLIZAS_HOGAR%NOTFOUND THEN
        EXIT;
      END IF;

      BEGIN
        SELECT '1'
          INTO EXISTE
          FROM RARCHIVOS
         WHERE NOMBRE = 'Clausulado de Hogar'
           AND POLIZA = POLI
           AND FECHA_PGO = P_FCHA_PGO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            INSERT INTO RARCHIVOS
            VALUES
              ('Clausulado de Hogar',
               'CH4O' || TO_CHAR(P_FCHA_PGO, 'MMYYYY') || POLI || '.PDF',
               POLI,
               P_FCHA_PGO,
               NIT_P);
          EXCEPTION
            WHEN OTHERS THEN
              raise_application_error(-20501, '2. Error insertando Tabla RARCHIVOS RSINIESTROS ' || POLI || ' ' || SQLERRM);
          END;
      END;
      COMMIT;

    END LOOP;
    CLOSE C_POLIZAS_HOGAR;
  END PR_CREAR_ARCHIVOS;

  --
  -- Procedimiento que alimenta las tablas que genera el reporte de relación de asegurados
  --
  PROCEDURE PRC_RELACION_ASEGURADOS(P_Codigo_CLASE    PLZAS.POL_CDGO_CLSE%TYPE,
                                    P_Codigo_RAMO     PLZAS.POL_RAM_CDGO%TYPE,
                                    P_CODIGO_SUCURSAL PLZAS.POL_SUC_CDGO%TYPE,
                                    P_CODIGO_COMPANIA PLZAS.POL_SUC_CIA_CDGO%TYPE,
                                    P_POLIZA          PLZAS.POL_NMRO_PLZA%TYPE,
                                    P_POL_HASTA       PLZAS.POl_NMRO_PLZA%TYPE,
                                    P_PERIODO         VARCHAR2,
                                    p_Codigo_Usuario  VARCHAR2,
                                    P_FECHA_PAGO      DATE) IS
    CURSOR C_CERTIFICADOS IS
      SELECT /*+  index (pol3   pol_pk)
                        index (cer    cer_pol_fk_i)*/
       Cer.CER_FCHA_DSDE_ACTUAL,
       Cer.CER_NMRO_CRTFCDO,
       Cer.CER_NMRO_PLZA,
       POL_DIV_CDGO
        FROM PLZAS POL3, CRTFCDOS Cer
       WHERE POL3.POL_NMRO_PLZA >= p_POLIZA
         AND POL3.POL_NMRO_PLZA <= p_POL_HASTA
         AND POL3.POL_CDGO_CLSE = P_CODIGO_CLASE
         AND POL3.POL_RAM_CDGO = P_CODIGO_RAMO
         AND POL3.POL_SUC_CDGO = P_CODIGO_SUCURSAL
         AND POL3.POL_SUC_CIA_CDGO = P_CODIGO_COMPANIA
         AND POL3.POL_TPOPLZA = 'C'
         AND CER.CER_NMRO_CRTFCDO > 0
         AND Cer.CER_NMRO_PLZA = POL3.POL_NMRO_PLZA
         AND Cer.CER_CLSE_PLZA = POL3.POL_CDGO_CLSE
         AND Cer.CER_RAM_CDGO = POL3.POL_RAM_CDGO
         AND TO_CHAR(Cer.CER_FCHA_DSDE_ACTUAL, 'MMYYYY') = p_Periodo;

    CURSOR C_SOLICITUDES(PLZA NUMBER, IVA CRTFCDOS.CER_VLOR_IVA%TYPE) IS
      SELECT /*+  index(rvi     rvi_pol_fk_i)
                                                       index(prs     prs_pk   )
                                                       index(dir     dir_pk   )
                                                       index(rvl     rvl_pk   )
                                                       index(rva     rva_rvi_fk_i   ) */
       RVI.RVI_NMRO_ITEM SOLICITUD,
       PK_TERCEROS.F_NOMBRES(RVI_PRS_NMRO_IDNTFCCION,
                             RVI_PRS_TPO_IDNTFCCION) NOMBRE,
       DIR.DI_DIRECCION DIRECCION,
       FECHA_INGRESO_SEG(RVI_NMRO_ITEM,RVI_NMRO_PLZA,RVI_CLSE_PLZA,RVI_RAM_CDGO,'01') FECHA,
       RVA.RVA_CDGO_AMPRO AMPARO,
       RVA.RVA_TPO_TSA TIPO_TASA,
       ((RVA.RVA_VLOR_ASGRDO_TTAL * RVA.RVA_TSA_AMPRO / 100) /
       (1 + (IVA / 100))) PRIMA_NETA,
       RVA.RVA_VLOR_ASGRDO_TTAL ASEGURADO,
       RVA.RVA_PRCNTJE_DSCNTO DESCUENTO,
       RVL.RVL_CNCPTO_VLOR CONCEPTO,
       RVL.RVL_VLOR VALOR,
       RVL.RVL_PRIMA_NETA PRMA_NTA,
       RIVN.RIVN_TPO_NVDAD NOVEDAD,
       RIVN.RIVN_VLOR_DFRNCIA VALOR_NOVEDAD,
       RIVN2.RIVN_VLOR_DFRNCIA RETRO,
       RIVN3.RIVN_VLOR_DFRNCIA CUOTAS,
       RVI.RVI_PRS_NMRO_IDNTFCCION NIT,
       RVI.RVI_PRS_TPO_IDNTFCCION TIPO,
       RVA.RVA_VLOR_BSE_INDCE ASISTENCIA
        FROM RSGOS_VGNTES        RVI,
             DIRECCIONES         DIR,
             RSGOS_VGNTES_AMPRO  RVA,
             RSGOS_VGNTES_AVLOR  RVL,
             RSGOS_VGNTES_NVDDES RIVN,
             RSGOS_VGNTES_NVDDES RIVN2,
             RSGOS_VGNTES_NVDDES RIVN3
       WHERE RVI.RVI_NMRO_PLZA = PLZA
         AND RVI.RVI_CLSE_PLZA = P_CODIGO_CLASE
         AND RVI.RVI_RAM_CDGO = P_CODIGO_RAMO
         AND RVI.RVI_NMRO_ITEM != 0
         AND DIR.DI_SOLICITUD(+) = Rvi.RVI_NMRO_ITEM
         AND DIR.DI_TPO_DRCCION(+) = 'R'
         AND RVA.RVA_NMRO_ITEM = RVI.RVI_NMRO_ITEM
         AND RVA.RVA_NMRO_PLZA = RVI.RVI_NMRO_PLZA
         AND RVA.RVA_CLSE_PLZA = RVI.RVI_CLSE_PLZA
         AND RVA.RVA_RAM_CDGO = RVI.RVI_RAM_CDGO
         AND RVL.RVL_CDGO_AMPRO = RVA.RVA_CDGO_AMPRO
         AND RVL.RVL_NMRO_ITEM = RVI.RVI_NMRO_ITEM
         AND RVL.RVL_NMRO_PLZA = RVI.RVI_NMRO_PLZA
         AND RVL.RVL_CLSE_PLZA = RVI.RVI_CLSE_PLZA
         AND RVL.RVL_RAM_CDGO = RVI.RVI_RAM_CDGO
         AND RIVN.RIVN_NMRO_ITEM(+) = RVA.RVA_NMRO_ITEM
         AND RIVN.RIVN_NMRO_PLZA(+) = RVA.RVA_NMRO_PLZA
         AND RIVN.RIVN_CLSE_PLZA(+) = RVA.RVA_CLSE_PLZA
         AND RIVN.RIVN_RAM_CDGO(+) = RVA.RVA_RAM_CDGO
         AND RIVN.RIVN_CDGO_AMPRO(+) = RVA.RVA_CDGO_AMPRO
         AND RIVN.RIVN_FCHA_MDFCCION(+) BETWEEN
             To_Date('01' || P_PERIODO, 'DDMMYYYY') AND
             TO_DATE('01' || P_PERIODO || ' 23:59:59',
                     'DDMMYYYY HH24:MI:SS')
         AND RIVN2.RIVN_NMRO_ITEM(+) = RVA.RVA_NMRO_ITEM
         AND RIVN2.RIVN_NMRO_PLZA(+) = RVA.RVA_NMRO_PLZA
         AND RIVN2.RIVN_CLSE_PLZA(+) = RVA.RVA_CLSE_PLZA
         AND RIVN2.RIVN_RAM_CDGO(+) = RVA.RVA_RAM_CDGO
         AND RIVN2.RIVN_CDGO_AMPRO(+) = RVA.RVA_CDGO_AMPRO
         AND RIVN2.RIVN_TPO_NVDAD(+) = '12'
         AND RIVN2.RIVN_FCHA_NVDAD(+) BETWEEN
             To_Date('01' || P_PERIODO, 'DDMMYYYY') AND
             TO_DATE('01' || P_PERIODO || ' 23:59:59',
                     'DDMMYYYY HH24:MI:SS')
         AND RIVN3.RIVN_NMRO_ITEM(+) = RVA.RVA_NMRO_ITEM
         AND RIVN3.RIVN_NMRO_PLZA(+) = RVA.RVA_NMRO_PLZA
         AND RIVN3.RIVN_CLSE_PLZA(+) = RVA.RVA_CLSE_PLZA
         AND RIVN3.RIVN_RAM_CDGO(+) = RVA.RVA_RAM_CDGO
         AND RIVN3.RIVN_CDGO_AMPRO(+) = RVA.RVA_CDGO_AMPRO
         AND RIVN3.RIVN_TPO_NVDAD(+) = '11'
         AND RIVN3.RIVN_FCHA_NVDAD(+) BETWEEN
             To_Date('01' || P_PERIODO, 'DDMMYYYY') AND
             TO_DATE('01' || P_PERIODO || ' 23:59:59',
                     'DDMMYYYY HH24:MI:SS')
       ORDER BY RVI.RVI_NMRO_ITEM;

    CURSOR C_AMPAROS IS
      SELECT APR_CDGO_AMPRO, APR_DSCRPCION
        FROM AMPROS_PRDCTO
       WHERE APR_RAM_CDGO = P_CODIGO_RAMO
         AND APR_CDGO_AMPRO NOT IN ('09', '10')
       ORDER BY 1;
    CURSOR C_ACUMULADOS(P_AMPARO VARCHAR2, P_CER NUMBER, P_PLZA NUMBER) IS
      SELECT /*+ index (aca   aca_pk)
                                                     index (rnc   rnc_pk)*/
       Aca.ACA_NMRO_RSGOS,
       Aca.ACA_PRMA_NTA,
       Aca.ACA_VLOR_ASGRDO,
       Rnc.Rnc_Nmero_Nvddes,
       Rnc2.Rnc_Nmero_Nvddes,
       Rnc3.Rnc_Nmero_Nvddes
        FROM Acmldos_Ampro        Aca,
             Rsmen_Nvddes_Crtfcdo Rnc,
             Rsmen_Nvddes_Crtfcdo Rnc2,
             Rsmen_Nvddes_Crtfcdo Rnc3
       WHERE Aca.ACA_NMRO_PLZA(+) = P_PLZA
         AND Aca.ACA_RAM_CDGO(+) = P_CODIGO_RAMO
         AND Aca.ACA_CLSE_PLZA(+) = P_CODIGO_CLASE
         AND Aca.ACA_CDGO_AMPRO(+) = P_AMPARO
         AND Aca.ACA_NMRO_CRTFCDO(+) = P_CER
         AND Rnc.RNC_NMRO_CRTFCDO(+) = ACA.ACA_NMRO_CRTFCDO
         AND Rnc.RNC_NMRO_PLZA(+) = ACA.ACA_NMRO_PLZA
         AND Rnc.RNC_CLSE_PLZA(+) = ACA.ACA_CLSE_PLZA
         AND Rnc.RNC_RAM_CDGO(+) = ACA.ACA_RAM_CDGO
         AND Rnc.RNC_CDGO_AMPRO(+) = ACA.ACA_CDGO_AMPRO
         AND Rnc.RNC_TPO_NVDAD(+) = '01'
         AND Rnc2.RNC_NMRO_CRTFCDO(+) = ACA.ACA_NMRO_CRTFCDO
         AND Rnc2.RNC_NMRO_PLZA(+) = ACA.ACA_NMRO_PLZA
         AND Rnc2.RNC_CLSE_PLZA(+) = ACA.ACA_CLSE_PLZA
         AND Rnc2.RNC_RAM_CDGO(+) = ACA.ACA_RAM_CDGO
         AND Rnc2.RNC_CDGO_AMPRO(+) = ACA.ACA_CDGO_AMPRO
         AND Rnc2.RNC_TPO_NVDAD(+) = '02'
         AND Rnc3.RNC_NMRO_CRTFCDO(+) = ACA.ACA_NMRO_CRTFCDO
         AND Rnc3.RNC_NMRO_PLZA(+) = ACA.ACA_NMRO_PLZA
         AND Rnc3.RNC_CLSE_PLZA(+) = ACA.ACA_CLSE_PLZA
         AND Rnc3.RNC_RAM_CDGO(+) = ACA.ACA_RAM_CDGO
         AND Rnc3.RNC_CDGO_AMPRO(+) = ACA.ACA_CDGO_AMPRO
         AND Rnc3.RNC_TPO_NVDAD(+) = '04'
       GROUP BY Aca.ACA_NMRO_RSGOS,
                Aca.ACA_PRMA_NTA,
                Aca.ACA_VLOR_ASGRDO,
                Rnc.Rnc_Nmero_Nvddes,
                Rnc2.Rnc_Nmero_Nvddes,
                Rnc3.Rnc_Nmero_Nvddes;

    CURSOR C_NVDDES(CLASE   VARCHAR2,
                    RAMO    VARCHAR2,
                    PERIODO VARCHAR2,
                    POLIZA  NUMBER,
                    AMPARO  VARCHAR2) IS
      SELECT SUM(DEVO)
        FROM (SELECT NVL(SUM(RIVN.RIVN_VLOR_DFRNCIA), 0) DEVO
                FROM RSGOS_VGNTES_NVDDES RIVN
               WHERE RIVN.RIVN_NMRO_PLZA = POLIZA
                 AND RIVN.RIVN_RAM_CDGO = RAMO
                 AND RIVN.RIVN_CLSE_PLZA = CLASE
                 AND RIVN.RIVN_TPO_NVDAD = '09'
                 AND RIVN.RIVN_CDGO_AMPRO = AMPARO
                 AND RIVN.RIVN_FCHA_NVDAD(+) BETWEEN
                     To_Date('01' || PERIODO, 'DDMMYYYY') AND
                     TO_DATE('01' || PERIODO || ' 23:59:59',
                             'DDMMYYYY HH24:MI:SS')
              UNION
              SELECT NVL(SUM(NVD.RIVN_VLOR_DFRNCIA), 0) DEVO
                FROM NVDDES NVD
               WHERE NVD.RIVN_NMRO_PLZA(+) = POLIZA
                 AND NVD.RIVN_CLSE_PLZA(+) = CLASE
                 AND NVD.RIVN_RAM_CDGO(+) = RAMO
                 AND NVD.RIVN_CDGO_AMPRO = AMPARO
                 AND NVD.RIVN_TPO_NVDAD(+) = '09'
                 AND NVD.RIVN_FCHA_NVDAD(+) BETWEEN
                     To_Date('01' || PERIODO, 'DDMMYYYY') AND
                     TO_DATE('01' || PERIODO || ' 23:59:59',
                             'DDMMYYYY HH24:MI:SS'));

    C_CANON           RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE := 0;
    AMPARO            RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE;
    C_AMPARO          RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE;
    NOMBRE_A          AMPROS_PRDCTO.APR_DSCRPCION%TYPE;
    NOVEDAD           RSGOS_VGNTES_NVDDES.RIVN_TPO_NVDAD%TYPE;
    CUOTA             RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE := 0;
    DIRECCION         VARCHAR2(200);
    CDYF              RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE := 0;
    CEXPENSAS         RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE := 0;
    INGRESOS          RSMEN_NVDDES_CRTFCDO.RNC_NMERO_NVDDES%TYPE;
    AUMENTOS          RSMEN_NVDDES_CRTFCDO.RNC_NMERO_NVDDES%TYPE;
    VALOR_NOVEDAD     RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE;
    N_RETRO           RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE;
    TOTAL_RETRO       RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE;
    CUOTAS            RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE;
    DEVO1             RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    INQUILINO         VARCHAR2(200);
    IVA               CRTFCDOS.CER_VLOR_IVA%TYPE;
    IVA_PRIMA         CRTFCDOS.CER_VLOR_IVA%TYPE;
    L_DYF             RASEGURADOS.LDYF%TYPE;
    LS_P              RASEGURADOS.LSERV_PUB%TYPE;
    L_EXPENSAS        RASEGURADOS.LEXPENSAS%TYPE;
    L_AIS             RASEGURADOS.LSERV_PUB%TYPE;
    L_AI              RASEGURADOS.LSERV_PUB%TYPE;
    PRIMA             CRTFCDOS.CER_VLOR_PRMA_NTA%TYPE := 0;
    PRIMA_NETA        CRTFCDOS.CER_VLOR_PRMA_NTA%TYPE;
    PRIMA_RETRO       CRTFCDOS.CER_VLOR_PRMA_NTA%TYPE;
    PRIMA_TOTAL       CRTFCDOS.CER_VLOR_PRMA_TTAL%TYPE;
    RETIROS           RSMEN_NVDDES_CRTFCDO.RNC_NMERO_NVDDES%TYPE;
    RETRO             CRTFCDOS.CER_VLOR_PRMA_TTAL%TYPE;
    RIESGOS           RSMEN_NVDDES_CRTFCDO.RNC_NMERO_NVDDES%TYPE;
    N_SOLICITUD       SLCTDES_ESTDIOS.SES_NMRO%TYPE;
    T_SOLICITUD       SLCTDES_ESTDIOS.SES_NMRO%TYPE;
    S_P               RASEGURADOS.SERV_PUB%TYPE;
    A_E               RASEGURADOS.SERV_PUB%TYPE;
    VALOR_A_E         RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    LA_E              RASEGURADOS.LSERV_PUB%TYPE;
    AIS               RASEGURADOS.SERV_PUB%TYPE;
    AI                RASEGURADOS.SERV_PUB%TYPE;
    ASEGURADO         RASEGURADOS.CANON%TYPE;
    DESCUENTO         TRFA_AMPROS_PRDCTO.TAP_GSTS_EXPDCION%TYPE;
    CON_DESCUENTO     RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE;
    VALOR_S_P         RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VALOR_CDYF        RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VALOR_EXP         RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VALOR_AIS         RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VALOR_AI          RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VLOR_BNFCCION     RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VLOR_BNFCCION_SP  RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VLOR_BNFCCION_AE  RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VLOR_BNFCCION_DYF RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VLOR_BNFCCION_EXP RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VLOR_BNFCCION_AIS RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VLOR_BNFCCION_AI  RSGOS_VGNTES_NVDDES.RIVN_VLOR_DFRNCIA%TYPE := 0;
    VNIT              NUMBER(18);
    VTIPO             VARCHAR2(2);
    C_CERTIFICADO     CRTFCDOS.CER_NMRO_CRTFCDO%TYPE;
    CONCEPTO          RSGOS_VGNTES_AVLOR.RVL_CNCPTO_VLOR%TYPE;
    FECHA             DATE;
    FECHA_INGRESO     DATE;
    N_POLIZA          PLZAS.POL_NMRO_PLZA%TYPE;
    TIPO_TASA         VARCHAR2(1);
    VALOR             RSGOS_VGNTES_AVLOR.RVL_VLOR%TYPE := 0;
    CESION            VARCHAR2(1);
    TOTAL             NUMBER(18, 2);
    V_CODAZZI         PLZAS.POL_DIV_CDGO%TYPE;
    VASISTENCIA       NUMBER;
    V_ENTRO           VARCHAR2(1);
    A_HOGAR           NUMBER;
    ASEG_HOGAR        NUMBER;
    PRMA_NTA          NUMBER;


  BEGIN

    BEGIN
      SELECT PAR_VLOR2
        INTO IVA
        FROM PRMTROS
       WHERE PAR_CDGO = '4'
         AND PAR_MDLO = '6'
         AND PAR_VLOR1 = '01'
         AND PAR_FCHA_CREACION =
             (SELECT MAX(PAR_FCHA_CREACION)
                FROM PRMTROS
               WHERE PAR_VLOR1 = '01'
                 AND PAR_MDLO = '6'
                 AND PAR_CDGO = '4');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20501,'Error al capturar el valor del I.V.A.. No se encuentra definido');
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,'Error al capturar el valor del I.V.A..');
    END;
    OPEN C_CERTIFICADOS;
    LOOP
      FETCH C_CERTIFICADOS
        INTO FECHA, C_CERTIFICADO, N_POLIZA, V_CODAZZI;
      IF C_CERTIFICADOS%NOTFOUND THEN
        EXIT;
      ELSE
        T_SOLICITUD       := NULL;
        TOTAL_RETRO       := 0;
        DEVO1             := 0;
        VLOR_BNFCCION     := 0;
        VLOR_BNFCCION_SP  := 0;
        VLOR_BNFCCION_DYF := 0;
        VLOR_BNFCCION_EXP := 0;
        VLOR_BNFCCION_AIS := 0;
        VLOR_BNFCCION_AI  := 0;
        VLOR_BNFCCION_AE  := 0;

        OPEN C_SOLICITUDES(N_POLIZA, IVA);
        LOOP
          FETCH C_SOLICITUDES
            INTO N_SOLICITUD,
                 INQUILINO,
                 DIRECCION,
                 FECHA_INGRESO,
                 AMPARO,
                 TIPO_TASA,
                 PRIMA_NETA,
                 ASEGURADO,
                 DESCUENTO,
                 CONCEPTO,
                 VALOR,
                 PRMA_NTA,
                 NOVEDAD,
                 VALOR_NOVEDAD,
                 N_RETRO,
                 CUOTAS,
                 VNIT,
                 VTIPO,
                 VASISTENCIA;
          IF C_SOLICITUDES%NOTFOUND THEN
            EXIT;
          ELSE
            BEGIN
              IF T_SOLICITUD != N_SOLICITUD OR T_SOLICITUD IS NULL THEN
                V_ENTRO    := 'N';
                C_CANON    := NULL;
                CUOTA      := NULL;
                PRIMA      := NULL;
                RETRO      := NULL;
                S_P        := NULL;
                AIS        := NULL;
                AI         := NULL;
                LS_P       := NULL;
                CDYF       := NULL;
                L_AIS      := NULL;
                L_AI       := NULL;
                L_DYF      := NULL;
                CEXPENSAS  := NULL;
                L_EXPENSAS := NULL;
                VALOR_S_P  := NULL;
                VALOR_CDYF := NULL;
                VALOR_EXP  := NULL;
                VALOR_AIS  := NULL;
                VALOR_AI   := NULL;
                TOTAL      := 0;
                CESION     := 'N';
                A_E        := NULL;
                VALOR_A_E  := NULL;
                LA_E       := NULL;
                A_HOGAR    := NULL;
                ASEG_HOGAR := NULL;

              END IF;

              -- LAS POLIZAS DE MANIZALES NO TIENEN DESCUENTO POR
              -- EL AMPARO DE SERVICIOS PUBLICOS.

              IF V_CODAZZI = 17001 AND AMPARO = '04' THEN
                DESCUENTO := 0;
              END IF;
              IF AMPARO = '01' THEN
                IF CONCEPTO = '01' THEN
                  C_CANON := NVL(ROUND(VALOR, 0), 0);
                ELSIF CONCEPTO = '02' THEN
                  CUOTA := NVL(ROUND(VALOR, 0), 0);
                END IF;
                IF N_RETRO IS NOT NULL AND RETRO IS NULL THEN
                  RETRO       := Round(N_RETRO + (N_RETRO * IVA / 100), 0);
                  TOTAL_RETRO := TOTAL_RETRO + RETRO;
                END IF;
                PRIMA := Round(PRIMA_NETA + (PRIMA_NETA * IVA / 100),2); -- MANTIS 52276 AJUSTE PARA EL IVA DEL 19 Y DEN LOS VALORES COORECTOS
                IF NOVEDAD = '06' THEN
                  CESION := 'S';
                END IF;
              ELSIF AMPARO = '04' THEN
                IF NOVEDAD = '11' THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD + Nvl(CUOTAS, 0)) *
                                   (1 + (IVA / 100));
                  S_P           := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_S_P     := (S_P - (S_P * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  LS_P          := TO_CHAR(S_P, '999,999,999,999');
                ELSIF NOVEDAD IS NULL THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD * (1 + (IVA / 100)));
                  S_P           := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_S_P     := (S_P - (S_P * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  LS_P          := 'S.P.R.R';
                ELSIF CUOTAS IS NOT NULL THEN
                  CON_DESCUENTO := CUOTAS * (1 + (IVA / 100));
                  S_P           := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_S_P     := (S_P - (S_P * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  LS_P          := TO_CHAR(S_P, '999,999,999,999');
                ELSIF NOVEDAD = '01' THEN
                  LS_P := 'S.P.R.R';
                ELSIF NOVEDAD = '05' THEN
                  LS_P := 'S.P.R.R';
                ELSIF CESION = 'S' THEN
                  LS_P := 'S.P.R.R';
                END IF;
                IF CONCEPTO = '03' THEN
                  VLOR_BNFCCION_SP := NVL(VLOR_BNFCCION_SP, 0) +
                                      NVL(VALOR_S_P, 0);
                END IF;
              ELSIF AMPARO = '05' THEN
                IF NOVEDAD = '11' THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD + Nvl(CUOTAS, 0)) *
                                   (1 + (IVA / 100));
                  CDYF          := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_CDYF    := (CDYF - (CDYF * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_DYF         := TO_CHAR(CDYF, '999,999,999,999');
                ELSIF NOVEDAD IS NULL THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD * (1 + (IVA / 100)));
                  CDYF          := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_CDYF    := (CDYF - (CDYF * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_DYF         := 'D.F.';
                ELSIF CUOTAS IS NOT NULL THEN
                  CON_DESCUENTO := CUOTAS * (1 + (IVA / 100));
                  CDYF          := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_CDYF    := (CDYF - (CDYF * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_DYF         := TO_CHAR(CDYF, '999,999,999,999');
                ELSIF NOVEDAD = '01' THEN
                  L_DYF := 'D.F.';
                ELSIF NOVEDAD = '05' THEN
                  L_DYF := 'D.F.';
                ELSIF CESION = 'S' THEN
                  L_DYF := 'D.F.';
                END IF;
                VLOR_BNFCCION_DYF := NVL(VLOR_BNFCCION_DYF, 0) +
                                     NVL(VALOR_CDYF, 0);
              ELSIF AMPARO = '06' THEN
                IF NOVEDAD = '11' THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD + Nvl(CUOTAS, 0)) *
                                   (1 + (IVA / 100));
                  CEXPENSAS     := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_EXP     := (CEXPENSAS -
                                   (CEXPENSAS * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_EXPENSAS    := TO_CHAR(CEXPENSAS, '999,999,999,999');
                ELSIF NOVEDAD IS NULL THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD * (1 + (IVA / 100)));
                  CEXPENSAS     := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_EXP     := (CEXPENSAS -
                                   (CEXPENSAS * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_EXPENSAS    := 'E.C.O.';
                ELSIF CUOTAS IS NOT NULL THEN
                  CON_DESCUENTO := CUOTAS * (1 + (IVA / 100));
                  CEXPENSAS     := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_EXP     := (CEXPENSAS -
                                   (CEXPENSAS * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_EXPENSAS    := TO_CHAR(CEXPENSAS, '999,999,999,999');
                ELSIF NOVEDAD = '01' THEN
                  L_EXPENSAS := 'E.C.O.';
                ELSIF NOVEDAD = '05' THEN
                  L_EXPENSAS := 'E.C.O.';
                ELSIF CESION = 'S' THEN
                  L_EXPENSAS := 'E.C.O.';
                END IF;
                VLOR_BNFCCION_EXP := NVL(VLOR_BNFCCION_EXP, 0) +
                                     NVL(VALOR_EXP, 0);
              ELSIF AMPARO IN ('07') THEN
                IF NOVEDAD = '11' THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD + Nvl(CUOTAS, 0)) *
                                   (1 + (IVA / 100));
                  AIS           := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_AIS     := (AIS - (AIS * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_AIS         := TO_CHAR(AIS, '999,999,999,999');
                ELSIF CUOTAS IS NOT NULL THEN
                  CON_DESCUENTO := CUOTAS * (1 + (IVA / 100));
                  AIS           := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_AIS     := (AIS - (AIS * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_AIS         := TO_CHAR(AIS, '999,999,999,999');
                ELSIF NOVEDAD IS NULL THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD * (1 + (IVA / 100)));
                  AIS           := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_AIS     := (AIS - (AIS * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_AIS         := 'A.I.S.';
                ELSIF NOVEDAD = '01' THEN
                  L_AIS := 'A.I.S.';
                ELSIF NOVEDAD = '05' THEN
                  L_AIS := 'A.I.S.';
                ELSIF CESION = 'S' THEN
                  L_AIS := 'A.I.S.';
                END IF;
                IF CONCEPTO IN ('15') THEN
                  VLOR_BNFCCION_AIS := NVL(VLOR_BNFCCION_AIS, 0) +
                                       NVL(VALOR_AIS, 0);
                END IF;
              ELSIF AMPARO IN ('08') THEN
                IF NOVEDAD = '11' THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD + Nvl(CUOTAS, 0)) *
                                   (1 + (IVA / 100));
                  AI            := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_AI      := (AI - (AI * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_AI          := TO_CHAR(AI, '999,999,999,999');
                ELSIF CUOTAS IS NOT NULL THEN
                  CON_DESCUENTO := CUOTAS * (1 + (IVA / 100));
                  AI            := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /
                                         (100 - DESCUENTO)),
                                         0);
                  VALOR_AI      := (AI - (AI * (100 - DESCUENTO)) / 100) /
                                   (1 + (IVA / 100));
                  L_AI          := TO_CHAR(AI, '999,999,999,999');
                ELSIF NOVEDAD IS NULL THEN
                  CON_DESCUENTO := (VALOR_NOVEDAD * (1 + (IVA / 100)));
                  AI            := Round(CON_DESCUENTO +
                                         ((CON_DESCUENTO * DESCUENTO) /(100 - DESCUENTO)),0);
                  VALOR_AI      := (AI - (AI * (100 - DESCUENTO)) / 100) /(1 + (IVA / 100));
                  L_AI          := 'A.I.';
                ELSIF NOVEDAD = '01' THEN
                  L_AI := 'A.I.';
                ELSIF NOVEDAD = '05' THEN
                  L_AI := 'A.I.';
                ELSIF NOVEDAD = '09' THEN
                  --DAP. 26/01/2012 SE INCLUYE PORQUE CUANDO HAY DEVOLUCONES NO LO MUESTRA
                  L_AI := 'A.I.'; --MANTIS 4346.
                ELSIF CESION = 'S' THEN
                  L_AI := 'A.I.';
                END IF;
                IF CONCEPTO IN ('16') THEN
                  VLOR_BNFCCION_AI := NVL(VLOR_BNFCCION_AI, 0) + NVL(VALOR_AI, 0);
                END IF;
              ELSIF AMPARO IN ('11') THEN
                IF CONCEPTO = '26' THEN
                  ASEG_HOGAR := NVL(ROUND(VALOR, 0), 0);
                  A_HOGAR    := NVL(FUN_PRIMA_CONCEPTO(N_SOLICITUD,AMPARO,CONCEPTO),0);
                END IF;

                IF CONCEPTO = '31' THEN
                  A_E  := NVL(FUN_PRIMA_CONCEPTO(N_SOLICITUD,AMPARO,CONCEPTO), 0);
                  LA_E := TO_CHAR(A_E, '999,999,999,999');
                END IF;
                V_ENTRO := 'S';
              END IF;
              TOTAL := NVL(S_P, 0) + NVL(AIS, 0) + NVL(AI, 0);
              IF TOTAL != 0 THEN
                LS_P := TO_CHAR(TOTAL, '999,999,999,999');
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20501,'Error actualizando variables');
            END;
            IF T_SOLICITUD != N_SOLICITUD OR T_SOLICITUD IS NULL THEN
              BEGIN
                INSERT INTO RASEGURADOS
                VALUES
                  (P_CODIGO_SUCURSAL,
                   P_CODIGO_COMPANIA,
                   P_PERIODO,
                   N_POLIZA,
                   N_SOLICITUD,
                   C_CERTIFICADO,
                   INQUILINO,
                   DIRECCION,
                   FECHA_INGRESO,
                   C_CANON,
                   CUOTA,
                   ROUND(PRIMA,2),  -- MANTIS 52276
                   RETRO,
                   TOTAL,
                   CDYF,
                   LS_P,
                   L_DYF,
                   P_CODIGO_USUARIO,
                   CEXPENSAS,
                   L_EXPENSAS,
                   TIPO_TASA,
                   AIS,
                   L_AIS,
                   AI,
                   L_AI,
                   P_FECHA_PAGO,
                   VNIT,
                   VTIPO,
                   A_E,
                   LA_E,
                   A_HOGAR,
                   ASEG_HOGAR);
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20501,'Error insertando en la tabla temporal ' ||SQLERRM);
                  ROLLBACK;
                  RETURN;
              END;
            ELSE
              BEGIN
                UPDATE RASEGURADOS
                   SET CANON           = C_CANON,
                       ADMON           = CUOTA,
                       PRIMA_MES       = ROUND(PRIMA,2),  -- MANTIS 52276
                       PRIMA_RETRO     = RETRO,
                       SERV_PUB        = TOTAL,
                       DYF             = CDYF,
                       LSERV_PUB       = LS_P,
                       LDYF            = L_DYF,
                       EXPENSAS        = CEXPENSAS,
                       LEXPENSAS       = L_EXPENSAS,
                       AMPINTS         = AIS,
                       LAMPINTS        = L_AIS,
                       AMPINT          = AI,
                       LAMPINT         = L_AI,
                       AMPASIS         = A_E,
                       LAMPASIS        = LA_E,
                       AMPHOGAR        = A_HOGAR,
                       VLOR_ASEG_HOGAR = ASEG_HOGAR
                 WHERE SUCURSAL = P_CODIGO_SUCURSAL
                   AND COMPANIA = P_CODIGO_COMPANIA
                   AND POLIZA = N_POLIZA
                   AND SOLICITUD = N_SOLICITUD
                   AND CERTIFICADO = C_CERTIFICADO
                   AND PERIODO = PERIODO;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20501,'Error actualizando la tabla temporal ' ||To_Char(n_Solicitud));
              END;
            END IF;
            
            DECLARE 
              CURSOR rsgos_vgntes_cursor IS
                SELECT * FROM RSGOS_VGNTES_NVDDES
                 WHERE RIVN_NMRO_PLZA = N_POLIZA
                   and RIVN_TPO_NVDAD='11'
                   and RIVN_NMRO_ITEM = N_SOLICITUD;
              
              rsgos_vgntes_record rsgos_vgntes_cursor%ROWTYPE;
              amprs_record ampros_prdcto%ROWTYPE;
              flag_prima number(1) :=0;
              v_count_temp number (4) :=0;
            
            BEGIN
              select count(*) 
                into v_count_temp 
                from(select * 
              from AMPROS_PRDCTO
              where APR_CDGO_AMPRO = AMPARO
              and APR_TPO_AMPRO = 'A');
                  IF (v_count_temp >0) THEN --Si corresponde a ampros_producto
                      select * INTO amprs_record 
                      from AMPROS_PRDCTO
                      where APR_CDGO_AMPRO = AMPARO
                      and APR_TPO_AMPRO = 'A';
                    IF(amprs_record.APR_TRFCION_EXTRNA = 'N') THEN
                      FOR rsgos_vgntes_record IN rsgos_vgntes_cursor LOOP
                        IF(TO_DATE(P_PERIODO,'MM-YYYY')<=rsgos_vgntes_record.rivn_fcha_nvdad or TO_DATE(P_PERIODO,'MM-YYYY')<=rsgos_vgntes_record.rivn_fcha_mdfccion) THEN --Si tiene prima para el periodo posterior
                             INSERT INTO RIESGOS_ASEGURADOS
                             (SOLICITUD,PERIODO, AMPARO,CONCEPTO,VALOR_ASEG,VALOR_PRIMA,PRIMA_RETRO,POLIZA)
                            VALUES(N_SOLICITUD, P_PERIODO, AMPARO, CONCEPTO, NVL(VALOR,0), NVL2(rsgos_vgntes_record.RIVN_VLOR_DFRNCIA,ROUND(rsgos_vgntes_record.RIVN_VLOR_DFRNCIA,2),0), NVL(N_RETRO,0), N_POLIZA);
                          flag_prima:=1;
                          exit when flag_prima = 1;
                        END IF;
                      END LOOP;
                      IF (flag_prima = 0) THEN -- si no tiene prima
                          INSERT INTO RIESGOS_ASEGURADOS
                          (SOLICITUD,PERIODO,AMPARO,CONCEPTO,VALOR_ASEG,VALOR_PRIMA,PRIMA_RETRO,POLIZA)
                          VALUES(N_SOLICITUD, P_PERIODO, AMPARO, CONCEPTO, NVL(VALOR,0), 0, NVL(N_RETRO,0), N_POLIZA);
                      END IF;
                      flag_prima :=0;
                    ELSE -- si es hogar
                       INSERT INTO RIESGOS_ASEGURADOS
                          (SOLICITUD,PERIODO,AMPARO,CONCEPTO,VALOR_ASEG,VALOR_PRIMA,PRIMA_RETRO,POLIZA)
                         VALUES(N_SOLICITUD, P_PERIODO, AMPARO, CONCEPTO, NVL(VALOR,0), NVL2(PRMA_NTA,ROUND(PRMA_NTA,2),0), NVL(N_RETRO,0), N_POLIZA);
                   END IF;
                  ELSIF (CONCEPTO IN ('01','02')) THEN -- Si no corresponde a amprs_producto
                    INSERT INTO RIESGOS_ASEGURADOS
                          (SOLICITUD,PERIODO,AMPARO,CONCEPTO,VALOR_ASEG,VALOR_PRIMA,PRIMA_RETRO,POLIZA)
                         VALUES(N_SOLICITUD, P_PERIODO, AMPARO, CONCEPTO, NVL(VALOR,0), NVL2(PRMA_NTA,ROUND(PRMA_NTA,2),0), NVL(N_RETRO,0), N_POLIZA);
                  ELSE
                        INSERT INTO RIESGOS_ASEGURADOS
                        (SOLICITUD,PERIODO,AMPARO,CONCEPTO,VALOR_ASEG,VALOR_PRIMA,PRIMA_RETRO,POLIZA)
                          VALUES(N_SOLICITUD, P_PERIODO, AMPARO, CONCEPTO, NVL(VALOR,0), NVL2(PRIMA_NETA,ROUND(PRIMA_NETA,2),0), NVL(N_RETRO,0), N_POLIZA);
                  END IF;
            EXCEPTION
              when dup_val_on_index then
              null;
              WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20501,'Error Insertando en la tabla RIESGOS_ASEGURADOS -'||sqlerrm||'-'||To_Char(n_Solicitud)||','||To_Char(n_poliza));
            END;
            T_SOLICITUD := N_SOLICITUD;
          END IF;
        END LOOP;
        CLOSE C_SOLICITUDES;

        OPEN C_AMPAROS;
        LOOP
          FETCH C_AMPAROS
            INTO C_AMPARO, NOMBRE_A;
          IF C_AMPAROS%NOTFOUND THEN
            EXIT;
          ELSE
            DEVO1 := 0;
            OPEN C_ACUMULADOS(C_AMPARO, C_CERTIFICADO, N_POLIZA);
            FETCH C_ACUMULADOS
              INTO RIESGOS,
                   PRIMA_NETA,
                   ASEGURADO,
                   INGRESOS,
                   RETIROS,
                   AUMENTOS;
            IF C_ACUMULADOS%FOUND THEN
              PRIMA       := 0;
              PRIMA_TOTAL := 0;
              PRIMA       := ROUND(PRIMA_NETA, 0);
              OPEN C_NVDDES(P_CODIGO_CLASE,
                            P_CODIGO_RAMO,
                            P_PERIODO,
                            N_POLIZA,
                            C_AMPARO);
              FETCH C_NVDDES
                INTO DEVO1;
              IF C_NVDDES%NOTFOUND THEN
                DEVO1 := 0;
              END IF;
              CLOSE C_NVDDES;

              IVA_PRIMA   := ROUND(PRIMA * IVA / 100, 0);
              PRIMA_TOTAL := ROUND(PRIMA + IVA_PRIMA, 0);

              IF C_AMPARO = '01' THEN
                VLOR_BNFCCION := 0;
              ELSIF C_AMPARO = '04' THEN
                VLOR_BNFCCION := ROUND(VLOR_BNFCCION_SP, 0);
              ELSIF C_AMPARO = '05' THEN
                VLOR_BNFCCION := ROUND(VLOR_BNFCCION_DYF, 0);
              ELSIF C_AMPARO = '06' THEN
                VLOR_BNFCCION := ROUND(VLOR_BNFCCION_EXP, 0);
              ELSIF C_AMPARO = '07' THEN
                VLOR_BNFCCION := ROUND(VLOR_BNFCCION_AIS, 0);
              ELSIF C_AMPARO = '08' THEN
                VLOR_BNFCCION := ROUND(VLOR_BNFCCION_AI, 0);
              ELSIF C_AMPARO = '11' THEN
                VLOR_BNFCCION := ROUND(VLOR_BNFCCION_AE, 0);
              ELSE
                VLOR_BNFCCION := 0;
              END IF;
              PRIMA       := ROUND(PRIMA + nvl(VLOR_BNFCCION, 0), 0);
              IVA_PRIMA   := ROUND(IVA_PRIMA + (VLOR_BNFCCION * (1 + (IVA / 100)) - VLOR_BNFCCION), 0);
              PRIMA_TOTAL := ROUND(PRIMA + IVA_PRIMA, 0);

              BEGIN
                INSERT INTO RASEGURADOSRES
                VALUES
                  (P_CODIGO_SUCURSAL,
                   P_CODIGO_COMPANIA,
                   P_PERIODO,
                   N_POLIZA,
                   NOMBRE_A,
                   RIESGOS,
                   ASEGURADO,
                   PRIMA,
                   IVA_PRIMA,
                   PRIMA_TOTAL,
                   NVL(INGRESOS, 0),
                   NVL(AUMENTOS, 0),
                   NVL(RETIROS, 0),
                   P_CODIGO_USUARIO,
                   VLOR_BNFCCION,
                   Round(NVL(DEVO1, 0), 0),
                   P_FECHA_PAGO,
                   IVA);
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20501,'Error insertando la tabla de acumulados ' || Amparo || ' ' || SQLERRM);
              END;
            END IF;
            CLOSE C_ACUMULADOS;
          END IF;
        END LOOP;
        CLOSE C_AMPAROS;
      END IF;
    END LOOP;
    CLOSE C_CERTIFICADOS;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501, SQLERRM);

  END PRC_RELACION_ASEGURADOS;

  --
  -- Procedimiento que alimenta las tablas que genera el reporte de Extractos
  --
  PROCEDURE PRC_EXTRACTOS(P_POLIZA   NUMBER,
                          P_RAMO     VARCHAR2,
                          P_CLASE    VARCHAR2,
                          P_PERIODO  DATE,
                          P_SUCURSAL VARCHAR2) IS

    CURSOR C_EXTRACTOS IS
      SELECT POLIZA, AMPARO, CRITERIO, SUM(VALOR) VALOR
        FROM (SELECT PES_NMRO_PLZA POLIZA,
                     VPE_CNCPTO_VLOR CONCEPTO,
                     VPE_CDGO_AMPRO AMPARO,
                     VP.VPR_TPO_VLOR CRITERIO,
                     SUM(VPE_VLOR) VALOR
                FROM PGOS_EFCTDOS_SNSTROS PE,
                     VLRES_PGO_EFCTDOS    VE,
                     VLRES_PRDCTO         VP
               WHERE PES_NMRO_PLZA = P_POLIZA
                 AND VPE_RAM_CDGO = P_RAMO
                 AND VPE_FCHA_PGO = P_PERIODO
                 AND VPE_RAM_CDGO = PES_RAM_CDGO
                 AND VPE_NMRO_SNSTRO = PES_NMRO_SNSTRO
                 AND VPE_FCHA_PGO = PES_FCHA_PGO
                 AND VP.VPR_CDGO = VE.VPE_CNCPTO_VLOR
               GROUP BY PES_NMRO_PLZA,
                        VPE_CNCPTO_VLOR,
                        VPE_CDGO_AMPRO,
                        VP.VPR_TPO_VLOR)
       GROUP BY POLIZA, AMPARO, CRITERIO;

    CURSOR C_PRMAS IS
      SELECT S.*,
             N.APR_DSCRPCION    CONCEPTO,
             C.CER_CDGO_CRTFCDO,
             C.CER_VLOR_IVA     IVA,
             C.CER_VLOR_CTA_FAX VR_FAX,
             C.CER_VLOR_PPLRIA  PPLRIA
        FROM ACMLDOS_AMPRO S, CRTFCDOS C, AMPROS_PRDCTO N
       WHERE TO_NUMBER(TO_CHAR(C.CER_FCHA_DSDE_ACTUAL, 'RRRRMM')) =
             TO_NUMBER(TO_CHAR(P_PERIODO, 'RRRRMM'))
         AND S.ACA_NMRO_CRTFCDO = C.CER_NMRO_CRTFCDO
         AND S.ACA_NMRO_PLZA = C.CER_NMRO_PLZA
         AND S.ACA_NMRO_PLZA = P_POLIZA
         AND C.CER_ESTDO_PRDCCION != 00
         AND PKG_OPERACION.FUN_TRFCION_EXTERNA(S.ACA_CDGO_AMPRO,
                                               S.ACA_RAM_CDGO) = 'N'
         AND S.ACA_CDGO_AMPRO = N.APR_CDGO_AMPRO;

    CURSOR C_CER_PNDNTES(P_CERTIFICADO NUMBER) IS
      SELECT ALL NVL(SLDOS_EXTRCTOS.SLE_DSCRPCION,
                     'PRIMAS DEL MES DE  ' ||
                     TO_CHAR(CER_FCHA_DSDE_ACTUAL,'MONTH','NLS_DATE_LANGUAGE = SPANISH') || '  DE  ' ||
                     TO_CHAR(CER_FCHA_DSDE_ACTUAL, 'YYYY') || '  ' ||
                     TO_CHAR(CER_NMRO_CRTFCDO)) DSCRPCION,
                 NVL(ROUND(SLDOS_EXTRCTOS.SLE_VLOR), CER_VLOR_SLDO) SLE_VALOR,
                 NVL(SLDOS_EXTRCTOS.SLE_PLZA, CER_NMRO_PLZA) SLE_PLZA,
             SLE_NMRO_CRTFCDO
        FROM SLDOS_EXTRCTOS, CRTFCDOS
       WHERE SLDOS_EXTRCTOS.SLE_PLZA(+) = P_POLIZA
         AND SLDOS_EXTRCTOS.SLE_PLZA = CER_NMRO_PLZA
         AND SLDOS_EXTRCTOS.SLE_FCHA_PGO(+) = P_PERIODO
         AND CER_NMRO_CRTFCDO = SLE_NMRO_CRTFCDO(+)
         AND CER_CLSE_PLZA = P_CLASE
         AND CER_RAM_CDGO = P_RAMO
         AND CER_ESTDO_PRDCCION NOT IN ('70')
         AND TO_NUMBER(TO_CHAR(CER_FCHA_DSDE_ACTUAL, 'YYYYMM')) <=
             TO_NUMBER(TO_CHAR(P_PERIODO, 'YYYYMM'))
         AND CER_VLOR_SLDO > 0
         AND CER_NMRO_PLZA = SLE_PLZA(+)
         AND CER_NMRO_CRTFCDO != P_CERTIFICADO
      UNION
      SELECT ALL NVL(SLDOS_EXTRCTOS.SLE_DSCRPCION,
                     'PRIMAS DEL MES DE  ' ||
                     TO_CHAR(CER_FCHA_DSDE_ACTUAL,'MONTH','NLS_DATE_LANGUAGE = SPANISH') || '  DE  ' ||
                     TO_CHAR(CER_FCHA_DSDE_ACTUAL, 'YYYY') || '  ' ||
                     TO_CHAR(CER_NMRO_CRTFCDO)) DSCRPCION,
                 NVL(ROUND(SLDOS_EXTRCTOS.SLE_VLOR), CER_VLOR_SLDO) SLE_VALOR,
                 NVL(SLDOS_EXTRCTOS.SLE_PLZA, CER_NMRO_PLZA) SLE_PLZA,
             SLE_NMRO_CRTFCDO
        FROM SLDOS_EXTRCTOS, CRTFCDOS
       WHERE SLDOS_EXTRCTOS.SLE_PLZA = P_POLIZA
         AND SLDOS_EXTRCTOS.SLE_PLZA = CER_NMRO_PLZA
         AND SLDOS_EXTRCTOS.SLE_FCHA_PGO = P_PERIODO
         AND CER_NMRO_CRTFCDO(+) = SLE_NMRO_CRTFCDO
         AND CER_CLSE_PLZA(+) = P_CLASE
         AND CER_RAM_CDGO(+) = P_RAMO
         AND CER_ESTDO_PRDCCION NOT IN ('70')
         AND TO_NUMBER(TO_CHAR(CER_FCHA_DSDE_ACTUAL(+), 'YYYYMM')) <=
             TO_NUMBER(TO_CHAR(P_PERIODO, 'YYYYMM'))
         AND CER_VLOR_SLDO <= 0
       ORDER BY SLE_NMRO_CRTFCDO;

    R_CASOS            C_EXTRACTOS%ROWTYPE;
    R_PRMAS            C_PRMAS%ROWTYPE;
    R_PNDNTES          C_CER_PNDNTES%ROWTYPE;
    VR_DEVOLUCION      NUMBER;
    VR_RETRO           NUMBER;
    V_SNTROS_ARR       NUMBER;
    V_RCPRCION_ARR     NUMBER;
    V_RCPRCION_SRVCIOS NUMBER;
    V_RCPRCION_DANOS   NUMBER;
    V_SNSTROS_ANXOS    NUMBER;
    V_TTAL_SNSTROS     NUMBER;
    NRO_ORDEN          NUMBER := 0;
    VLOR_GIRAGO        NUMBER := 0;
    FORMA_PAGO         VARCHAR2(30) := NULL;
    MORA_EXTRACTO      NUMBER;
    SUMA               NUMBER;
    V_MORA             VARCHAR2(50);
    V_EMBARGO          PLZAS.POL_EMBRGO%TYPE;
    V_FECHA_LIMITE     DATE;
    V_MENSAJE          VARCHAR2(100);
    N_ORDEN            NUMBER;
    VR_PRIMAS          NUMBER;
    NRO_EXTRACTO       NUMBER;
    V_NOMBRE           VARCHAR2(150);
    V_IVA              CRTFCDOS.CER_VLOR_IVA%TYPE;
    V_FAX              CRTFCDOS.CER_VLOR_CTA_FAX%TYPE;
    V_PPLRIA           CRTFCDOS.CER_VLOR_PPLRIA%TYPE;
    NRO_CRTFCDO        CRTFCDOS.CER_NMRO_CRTFCDO%TYPE;
    TIPO_ID            PLZAS.POL_PRS_TPO_IDNTFCCION%TYPE;
    NMRO_ID            PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
    MARCA_CIERRE       FCHAS_PGO.MARCA_CIERRE_OPRCION%TYPE;
    V_ORDEN            FCHAS_PGO.FPG_ORDEN_FCHA%TYPE;
    FECHA_PROCESO      DATE;
    VALOR_IVA          NUMBER;
    VALOR_HOGAR        NUMBER;
    VALOR_ASIS         NUMBER;
    IVA_HOGAR          NUMBER;
    IVA_ASIS           NUMBER;
    V_PAGO             NUMBER;
    PRIMA_ASIS         NUMBER;
    PRIMA_HOGAR        NUMBER;
    IVA                NUMBER;

  BEGIN
    BEGIN
      SELECT PAR_VLOR2
        INTO IVA
        FROM PRMTROS
       WHERE PAR_CDGO = '4'
         AND PAR_MDLO = '6'
         AND PAR_VLOR1 = '01'
         AND PAR_FCHA_CREACION =
             (SELECT MAX(PAR_FCHA_CREACION)
                FROM PRMTROS
               WHERE PAR_VLOR1 = '01'
                 AND PAR_MDLO = '6'
                 AND PAR_CDGO = '4');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20500,'Error en la consulta del valor del IVA .' || SQLERRM);
    END;

    BEGIN
      SELECT F.FPG_LMTE_EXTRCTO,MARCA_CIERRE_OPRCION,FPG_ORDEN_FCHA
        INTO V_FECHA_LIMITE,MARCA_CIERRE,V_ORDEN
        FROM FCHAS_PGO F
       WHERE F.FPG_FCHA_PGO = P_PERIODO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20500,'Error en la consulta de la fecha límite del extracto .' ||SQLERRM);
    END;

    BEGIN
      SELECT PG.PGS_NMRO_ORDEN_PGO,
             PG.PGS_VLOR_PGDO,
             POL_EMBRGO,
             DECODE(NUMERO_DOCUMENTO, null, 'CHEQUE', 'TRANSFERENCIA') FORMA,
             POL_PRS_TPO_IDNTFCCION,
             POL_PRS_NMRO_IDNTFCCION,
             PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,POL_PRS_TPO_IDNTFCCION) NOMBRE
        INTO NRO_ORDEN,
             VLOR_GIRAGO,
             V_EMBARGO,
             FORMA_PAGO,
             TIPO_ID,
             NMRO_ID,
             V_NOMBRE
        FROM PGOS_SNSTROS PG, PLZAS, A5021103
       WHERE PGS_NMRO_PLZA = P_POLIZA
         AND PGS_FCHA_PGO = P_PERIODO
         AND PG.PGS_NMRO_PLZA = POL_NMRO_PLZA
         AND POL_PRS_NMRO_IDNTFCCION = NUMERO_DOCUMENTO(+)
         AND ESTADO(+) = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NRO_ORDEN := 0;
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501, 'Error en la consulta de la orden de pago .' || SQLERRM);
    END;

    MORA_EXTRACTO := F_MORA_EXTRACTO(P_POLIZA, P_CLASE, P_RAMO);
    IF MORA_EXTRACTO = 0 THEN
      V_MORA := NULL;
    ELSIF MORA_EXTRACTO > 0 AND MORA_EXTRACTO <= 120 THEN
      V_MORA := 'PRESENTA MORA DE ' || MORA_EXTRACTO || ' ' || 'DIAS';
    ELSIF MORA_EXTRACTO > 120 THEN
      V_MORA := 'PRESENTA MORA DE MAS DE 120 DIAS';
    ELSE
      V_MORA := NULL;
    END IF;

    /*TRAE EL NUMERO QUE DEBE SALIR EN EL EXTRACTO DE CUENTA*/
    NRO_EXTRACTO := 0;
    BEGIN
      SELECT CSE_NMRO_EXTRCTO INTO NRO_EXTRACTO FROM CNSCTVOS_EXTRCTOS;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20502,'No existe numeracion para los extractos. ' || SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20503,'Error al extraer la numeracion para los extractos. ' || SQLERRM);
    END;
    NRO_EXTRACTO := P_POLIZA || NRO_EXTRACTO;

    V_SNTROS_ARR       := 0;
    V_RCPRCION_ARR     := 0;
    V_RCPRCION_SRVCIOS := 0;
    V_RCPRCION_DANOS   := 0;
    V_SNSTROS_ANXOS    := 0;
    V_TTAL_SNSTROS     := 0;

    OPEN C_EXTRACTOS;
    LOOP
      FETCH C_EXTRACTOS
        INTO R_CASOS;
      IF C_EXTRACTOS%NOTFOUND THEN
        EXIT;
      END IF;

      IF R_CASOS.AMPARO = '01' THEN
        IF R_CASOS.CRITERIO = 'S' THEN
          V_SNTROS_ARR := NVL(R_CASOS.VALOR, 0);
        ELSE
          V_RCPRCION_ARR := V_RCPRCION_ARR + NVL(R_CASOS.VALOR, 0);
        END IF;
      ELSIF R_CASOS.AMPARO = '05' THEN
        IF R_CASOS.CRITERIO = 'R' THEN
          V_RCPRCION_DANOS := V_RCPRCION_DANOS + NVL(R_CASOS.VALOR, 0);
        ELSE
          V_SNSTROS_ANXOS := NVL(V_SNSTROS_ANXOS, 0) +
                             NVL(R_CASOS.VALOR, 0);
        END IF;
      ELSE
        IF R_CASOS.CRITERIO = 'S' THEN
          V_SNSTROS_ANXOS := NVL(V_SNSTROS_ANXOS, 0) +
                             NVL(R_CASOS.VALOR, 0);
        ELSE
          V_RCPRCION_SRVCIOS := V_RCPRCION_SRVCIOS + NVL(R_CASOS.VALOR, 0);
        END IF;
      END IF;

      V_TTAL_SNSTROS := NVL(V_SNTROS_ARR, 0) + NVL(V_RCPRCION_ARR, 0) +
                        NVL(V_RCPRCION_SRVCIOS, 0) +
                        NVL(V_RCPRCION_DANOS, 0) + NVL(V_SNSTROS_ANXOS, 0);

    END LOOP;
    CLOSE C_EXTRACTOS;

    N_ORDEN     := 0;
    NRO_CRTFCDO := 0;
    OPEN C_PRMAS;
    LOOP
      FETCH C_PRMAS
        INTO R_PRMAS;
      IF C_PRMAS%NOTFOUND THEN
        EXIT;
      END IF;

      V_IVA    := R_PRMAS.IVA;
      V_FAX    := R_PRMAS.VR_FAX;
      V_PPLRIA := R_PRMAS.PPLRIA;

      IF R_PRMAS.ACA_PRMA_NTA != 0 THEN
        N_ORDEN := N_ORDEN + 1;
        BEGIN
          INSERT INTO DETALLE_EXTRACTOS
          VALUES
            (P_PERIODO,
             P_POLIZA,
             N_ORDEN,
             R_PRMAS.CONCEPTO,
             R_PRMAS.ACA_NMRO_CRTFCDO,
             R_PRMAS.ACA_PRMA_NTA,
             1);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20105,'Error al insertar el detalle primas del mes ' || P_POLIZA || ' ' || SQLERRM);
        END;
      END IF;

      NRO_CRTFCDO := R_PRMAS.ACA_NMRO_CRTFCDO;
    END LOOP;
    CLOSE C_PRMAS;

    -- Devoluciones
    -- MANTIS 48990  GGM. 27/09/2016 SOLO DEBE TOMAR LAS DEVOLUCIONES CUENDO SE HACER CIERRE DE OPERACION
    IF NVL(V_ORDEN,0) != 1 THEN
      SELECT SUM(VALOR) VALOR
        INTO VR_DEVOLUCION
        FROM (SELECT SUM(RIVN_VLOR_DFRNCIA) VALOR
                FROM NVDDES
               WHERE RIVN_NMRO_PLZA = P_POLIZA
                 AND NVDDES.RIVN_CLSE_PLZA = P_CLASE
                 AND NVDDES.RIVN_RAM_CDGO = P_RAMO
                 AND NVDDES.RIVN_TPO_NVDAD = '09'
                 AND TO_CHAR(NVDDES.RIVN_FCHA_NVDAD, 'MMYYYY') =
                     TO_CHAR(P_PERIODO, 'MMYYYY')
               GROUP BY NVDDES.RIVN_TPO_NVDAD
              UNION
              SELECT SUM(RIVN_VLOR_DFRNCIA) VALOR
                FROM RSGOS_VGNTES_NVDDES
               WHERE RIVN_NMRO_PLZA BETWEEN P_POLIZA AND P_POLIZA
                 AND RSGOS_VGNTES_NVDDES.RIVN_CLSE_PLZA = P_CLASE
                 AND RSGOS_VGNTES_NVDDES.RIVN_RAM_CDGO = P_RAMO
                 AND RSGOS_VGNTES_NVDDES.RIVN_TPO_NVDAD = '09'
                 AND (RIVN_FCHA_NVDAD BETWEEN
                     TO_DATE(TO_CHAR(P_PERIODO, 'MMYYYY'), 'MMYYYY') AND
                     LAST_DAY(P_PERIODO) OR
                     TO_CHAR(RIVN_FCHA_MDFCCION, 'MMYYYY') =
                     TO_CHAR(P_PERIODO, 'MMYYYY')));

      IF NVL(VR_DEVOLUCION, 0) != 0 THEN
        N_ORDEN := N_ORDEN + 1;
        BEGIN
          INSERT INTO DETALLE_EXTRACTOS
          VALUES
            (P_PERIODO,
             P_POLIZA,
             N_ORDEN,
             'DEVOLUCION PRIMAS',
             NRO_CRTFCDO,
             (VR_DEVOLUCION * -1),
             1);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20106,'Error al insrtar el detalle de devoluciones  ' ||  P_POLIZA || ' ' || SQLERRM);
        END;
      END IF;
    END IF;
    -- Prima retroactiva

    SELECT SUM(RIVN_VLOR_DFRNCIA) VALOR
      INTO VR_RETRO
      FROM RSGOS_VGNTES_NVDDES, CRTFCDOS C
     WHERE RIVN_NMRO_PLZA = P_POLIZA
       AND RSGOS_VGNTES_NVDDES.RIVN_CLSE_PLZA = P_CLASE
       AND RSGOS_VGNTES_NVDDES.RIVN_RAM_CDGO = P_RAMO
       AND RSGOS_VGNTES_NVDDES.RIVN_TPO_NVDAD = '12'
       AND TO_CHAR(RIVN_FCHA_NVDAD, 'YYYYMM') =
           TO_CHAR(P_PERIODO, 'YYYYMM')
       AND C.CER_NMRO_PLZA = RSGOS_VGNTES_NVDDES.RIVN_NMRO_PLZA
       AND C.CER_ESTDO_PRDCCION != 00
       AND TO_CHAR(C.CER_FCHA_DSDE_ACTUAL, 'YYYYMM') =
           TO_CHAR(P_PERIODO, 'YYYYMM');

    IF NVL(VR_RETRO, 0) != 0 THEN
      N_ORDEN := N_ORDEN + 1;
      BEGIN
        INSERT INTO DETALLE_EXTRACTOS
        VALUES
          (P_PERIODO,
           P_POLIZA,
           N_ORDEN,
           'PRIMAS RETROACTIVAS AMP. BASICO',
           NRO_CRTFCDO,
           VR_RETRO,
           1);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20107,'Error al insrtar el detalle de primas retro ' ||P_POLIZA || ' ' || SQLERRM);
      END;
    END IF;

    -- Primas Hogar

    SELECT NVL(SUM(RA.AMPASIS), 0), NVL(SUM(RA.AMPHOGAR), 0)
      INTO PRIMA_ASIS, PRIMA_HOGAR
      FROM RASEGURADOS RA
     WHERE RA.SUCURSAL = P_SUCURSAL
       AND RA.PERIODO = TO_CHAR(P_PERIODO, 'MMYYYY')
       AND RA.POLIZA = P_POLIZA;

    IF NVL(PRIMA_HOGAR, 0) != 0 THEN
      VALOR_HOGAR := ROUND(PRIMA_HOGAR / (1 + (IVA / 100)), 0);
      IVA_HOGAR   := PRIMA_HOGAR - VALOR_HOGAR;
    ELSE
      VALOR_HOGAR := 0;
      IVA_HOGAR   := 0;
    END IF;

    IF NVL(PRIMA_ASIS, 0) != 0 THEN
      VALOR_ASIS := ROUND(PRIMA_ASIS / (1 + (IVA / 100)), 0);
      IVA_ASIS   := PRIMA_ASIS - VALOR_ASIS;
    ELSE
      VALOR_ASIS := 0;
      IVA_ASIS   := 0;
    END IF;

    VALOR_IVA := NVL(V_IVA, 0); -- - NVL(IVA_HOGAR,0) - NVL(IVA_ASIS,0);

    IF NVL(VALOR_IVA, 0) != 0 THEN
      N_ORDEN := N_ORDEN + 1;
      BEGIN
        INSERT INTO DETALLE_EXTRACTOS
        VALUES
          (P_PERIODO,
           P_POLIZA,
           N_ORDEN,
           'I.V.A DE PRIMAS',
           NRO_CRTFCDO,
           VALOR_IVA,
           1);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20108,'Error al insrtar el detalle de IVA ' || P_POLIZA || ' ' || SQLERRM);
      END;
    END IF;

    IF NVL(V_PPLRIA, 0) != 0 THEN
      N_ORDEN := N_ORDEN + 1;
      BEGIN
        INSERT INTO DETALLE_EXTRACTOS
        VALUES
          (P_PERIODO,
           P_POLIZA,
           N_ORDEN,
           'PAPELERIA',
           NRO_CRTFCDO,
           V_PPLRIA,
           1);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20110,'Error al insrtar el detalle de papeleria ' ||P_POLIZA || ' ' || SQLERRM);
      END;
    END IF;

    -- Primas Hogar

    IF NVL(VALOR_HOGAR, 0) != 0 THEN
      N_ORDEN := N_ORDEN + 1;
      BEGIN
        INSERT INTO DETALLE_EXTRACTOS
        VALUES
          (P_PERIODO,
           P_POLIZA,
           N_ORDEN,
           'AMPARO HOGAR',
           NRO_CRTFCDO,
           VALOR_HOGAR,
           1);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20109,'Error al insrtar el detalle Valor Hogar ' ||P_POLIZA || ' ' || SQLERRM);
      END;

      N_ORDEN := N_ORDEN + 1;
      BEGIN
        INSERT INTO DETALLE_EXTRACTOS
        VALUES
          (P_PERIODO,
           P_POLIZA,
           N_ORDEN,
           'IVA HOGAR',
           NRO_CRTFCDO,
           IVA_HOGAR,
           1);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20109,'Error al insrtar el detalle IVA Hogar ' ||P_POLIZA || ' ' || SQLERRM);
      END;

    END IF;

    IF NVL(PRIMA_ASIS, 0) != 0 THEN
      N_ORDEN := N_ORDEN + 1;
      BEGIN
        INSERT INTO DETALLE_EXTRACTOS
        VALUES
          (P_PERIODO,
           P_POLIZA,
           N_ORDEN,
           'VALOR ASISTENCIA',
           NRO_CRTFCDO,
           VALOR_ASIS,
           1);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20106,'Error al insrtar el detalle Valor Asistencia ' ||P_POLIZA || ' ' || SQLERRM);
      END;

      N_ORDEN := N_ORDEN + 1;
      BEGIN
        INSERT INTO DETALLE_EXTRACTOS
        VALUES
          (P_PERIODO,
           P_POLIZA,
           N_ORDEN,
           'IVA ASISTENCIA',
           NRO_CRTFCDO,
           IVA_ASIS,
           1);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20107,'Error al insrtar el detalle IVA Asistencia ' ||P_POLIZA || ' ' || SQLERRM);
      END;
    END IF;

    -- Pagos Efectuados
    BEGIN
      SELECT PS.PGS_FCHA_MDFCCION
        INTO FECHA_PROCESO
        FROM PGOS_SNSTROS PS
       WHERE PS.PGS_FCHA_PGO = TRUNC(P_PERIODO)
         AND PS.PGS_NMRO_PLZA = P_POLIZA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20108,'Error al consultar la fecha de proceso' ||SQLERRM);
    END;

    IF NVL(MARCA_CIERRE, 'N') = 'S' THEN
      SELECT NVL(SUM(ESTADO_CTA_RCBOS.EST_VLOR_AFNZDO), 0) valor
        INTO V_PAGO
        FROM ESTADO_CTA_RCBOS, DTLLES_RCBOS_CJA DRC
       WHERE (ESTADO_CTA_RCBOS.EST_PLZA = P_POLIZA AND
             ESTADO_CTA_RCBOS.EST_FCHA_MRA IS NULL AND
             ESTADO_CTA_RCBOS.EST_ORGEN_RCDO = 'P' AND
             ESTADO_CTA_RCBOS.EST_ESTDO_RCBO = 'I' AND
             ESTADO_CTA_RCBOS.EST_NMRO_RCBO = DRC.DRC_NMRO_RCBO AND
             ESTADO_CTA_RCBOS.EST_TPO_RCBO in ('R') AND
             ESTADO_CTA_RCBOS.EST_CIA_CDGO = DRC.DRC_CDGO_CIA AND
             ESTADO_CTA_RCBOS.EST_TPO_RCBO = DRC.DRC_TPO_RCBO AND
             TO_CHAR(ESTADO_CTA_RCBOS.EST_SLCTUD) =
             SUBSTR(DRC.DRC_RFRNCIA, 15, 10) AND
             ESTADO_CTA_RCBOS.EST_SLCTUD = NRO_CRTFCDO AND
             TRUNC(ESTADO_CTA_RCBOS.EST_FCHA_MVTO) < TRUNC(FECHA_PROCESO));
    ELSE
      SELECT NVL(SUM(ESTADO_CTA_RCBOS.EST_VLOR_AFNZDO), 0) valor
        INTO V_PAGO
        FROM ESTADO_CTA_RCBOS, DTLLES_RCBOS_CJA DRC
       WHERE (ESTADO_CTA_RCBOS.EST_PLZA = P_POLIZA AND
             ESTADO_CTA_RCBOS.EST_FCHA_MRA IS NULL AND
             ESTADO_CTA_RCBOS.EST_ORGEN_RCDO = 'P' AND
             ESTADO_CTA_RCBOS.EST_ESTDO_RCBO = 'I' AND
             ESTADO_CTA_RCBOS.EST_NMRO_RCBO = DRC.DRC_NMRO_RCBO AND
             ESTADO_CTA_RCBOS.EST_TPO_RCBO in ('R', 'N') AND
             ESTADO_CTA_RCBOS.EST_CIA_CDGO = DRC.DRC_CDGO_CIA AND
             ESTADO_CTA_RCBOS.EST_TPO_RCBO = DRC.DRC_TPO_RCBO AND
             TO_CHAR(ESTADO_CTA_RCBOS.EST_SLCTUD) =
             SUBSTR(DRC.DRC_RFRNCIA, 15, 10) AND
             ESTADO_CTA_RCBOS.EST_SLCTUD = NRO_CRTFCDO AND
             TRUNC(ESTADO_CTA_RCBOS.EST_FCHA_MVTO) < TRUNC(FECHA_PROCESO));
    END IF;

    IF NVL(V_PAGO, 0) != 0 THEN
      N_ORDEN := N_ORDEN + 1;
      BEGIN
        INSERT INTO DETALLE_EXTRACTOS
        VALUES
          (P_PERIODO,
           P_POLIZA,
           N_ORDEN,
           'PAGOS EFECTUADOS',
           NRO_CRTFCDO,
           (V_PAGO * (-1)),
           1);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20110,'Error al insrtar el detalle de papeleria ' ||P_POLIZA || ' ' || SQLERRM);
      END;
    END IF;

    N_ORDEN := 0;
    OPEN C_CER_PNDNTES(NRO_CRTFCDO);
    LOOP
      FETCH C_CER_PNDNTES
        INTO R_PNDNTES;
      IF C_CER_PNDNTES%NOTFOUND THEN
        EXIT;
      END IF;

      IF NVL(R_PNDNTES.SLE_VALOR, 0) != 0 THEN
        N_ORDEN := N_ORDEN + 1;
        BEGIN
          INSERT INTO DETALLE_EXTRACTOS
          VALUES
            (P_PERIODO,
             P_POLIZA,
             N_ORDEN,
             R_PNDNTES.DSCRPCION,
             NRO_CRTFCDO,
             R_PNDNTES.SLE_VALOR,
             2);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20111,'Error al insrtar el detalle lado 2 ' ||P_POLIZA || ' ' || SQLERRM);
        END;
      END IF;

    END LOOP;
    CLOSE C_CER_PNDNTES;

    SELECT SUM(DE.DEX_VALOR)
      INTO VR_PRIMAS
      FROM DETALLE_EXTRACTOS DE
     WHERE DE.DEX_FCHA_PGO = P_PERIODO
       AND DE.DEX_NRO_PLZA = P_POLIZA;
    -- valor de las primas pendiente

    IF V_EMBARGO = 'S' THEN
      IF NVL(V_TTAL_SNSTROS, 0) > 0 THEN
        V_MENSAJE := 'TOTAL A CARGO POR PRIMAS ' ||TO_CHAR(VR_PRIMAS, '$999,999,999') || '  ' ||
                     'TOTAL A FAVOR POR SINIESTROS ' ||TO_CHAR(V_TTAL_SNSTROS, '$999,999,999');
      ELSE
        V_MENSAJE := 'TOTAL A CARGO POR PRIMAS ' ||TO_CHAR(VR_PRIMAS, '$999,999,999');
      END IF;
    ELSE
      Suma := NVL(V_TTAL_SNSTROS, 0) - NVL(VR_PRIMAS, 0);
      IF Suma > 0 THEN
        V_MENSAJE := 'VALOR TOTAL A FAVOR:  ' ||TO_CHAR(ABS(NVL(V_TTAL_SNSTROS, 0) - NVL(VR_PRIMAS, 0)),'$999,999,999');
      ELSIF Suma < 0 THEN
        V_MENSAJE := 'PAGUE ANTES DEL: ' ||TO_CHAR(V_FECHA_LIMITE, 'DD/MM/YYYY') || ' ' ||
                     TO_CHAR(ABS(NVL(V_TTAL_SNSTROS, 0) - NVL(VR_PRIMAS, 0)),'$999,999,999');
      ELSE
        V_MENSAJE := 'GRACIAS POR ESTAR AL DIA';
      END IF;
    END IF;

    IF NRO_EXTRACTO != 0 THEN
      BEGIN
        INSERT INTO EXTRACTOS
        VALUES
          (P_PERIODO,
           P_SUCURSAL,
           P_POLIZA,
           NRO_EXTRACTO,
           TIPO_ID,
           NMRO_ID,
           NVL(V_SNTROS_ARR, 0),
           NVL(V_RCPRCION_ARR, 0),
           0,
           NVL(V_RCPRCION_SRVCIOS, 0),
           NVL(V_RCPRCION_DANOS, 0),
           NVL(V_SNSTROS_ANXOS, 0),
           NVL(V_TTAL_SNSTROS, 0),
           VR_PRIMAS,
           NRO_ORDEN,
           FORMA_PAGO,
           V_MORA,
           V_MENSAJE,
           VLOR_GIRAGO,
           SYSDATE,
           V_NOMBRE);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20112,'Error al insertar en extractos  ' ||P_POLIZA || ' ' || SQLERRM);
      END;
    END IF;

  END PRC_EXTRACTOS;

  --
  --
  --
  PROCEDURE PRC_LISTADO_SINIESTROS(P_CLASE           IN VARCHAR2,
                                   P_RAMO            IN AVSOS_SNSTROS.SNA_RAM_CDGO%TYPE,
                                   P_POLIZA          IN AVSOS_SNSTROS.SNA_NMRO_PLZA%TYPE,
                                   P_CODIGO_SUCURSAL PLZAS.POL_SUC_CDGO%TYPE,
                                   P_CODIGO_COMPANIA PLZAS.POL_SUC_CIA_CDGO%TYPE,
                                   P_FECHA_PAGO      DATE) IS

    CURSOR C_PRINCIPAL IS
      SELECT DISTINCT SNA_NMRO_ITEM,
                      SNA_CLSE_PLZA,
                      SNA_NMRO_PLZA,
                      SNA_RAM_CDGO,
                      PES_FCHA_PGO,
                      TO_CHAR(PES_FCHA_PGO, 'MMYYYY') PERIODO,
                      pk_terceros.f_nombres(pol_prs_nmro_idntfccion,
                                            pol_prs_tpo_idntfccion) AGENCIA,
                      TO_CHAR(POL_PRS_NMRO_IDNTFCCION, '999,999,999,999') NIT,
                      POL_PRS_NMRO_IDNTFCCION NIT1
        FROM AVSOS_SNSTROS, PLZAS, PGOS_EFCTDOS_SNSTROS
       WHERE SNA_NMRO_PLZA LIKE DECODE(P_POLIZA, NULL, '%', P_POLIZA)
         AND SNA_CLSE_PLZA = P_CLASE
         AND SNA_RAM_CDGO = P_RAMO
         AND SNA_ESTDO_SNSTRO != '06'
         AND PES_FCHA_PGO = P_FECHA_PAGO
         AND PES_RAM_CDGO = P_RAMO
         AND SNA_NMRO_SNSTRO = PES_NMRO_SNSTRO
         AND SNA_NMRO_PLZA = POL_NMRO_PLZA
         AND SNA_CLSE_PLZA = POL_CDGO_CLSE
         AND SNA_RAM_CDGO = POL_RAM_CDGO
         AND POL_SUC_CDGO = P_CODIGO_SUCURSAL
         AND POL_SUC_CIA_CDGO = P_CODIGO_COMPANIA
         AND POL_ESTADO_PLZA IN ('V', 'S')
         AND POL_TPOPLZA = 'C'
       ORDER BY SNA_NMRO_PLZA,
                pk_terceros.f_nombres(pol_prs_nmro_idntfccion,
                                      pol_prs_tpo_idntfccion),
                PES_FCHA_PGO;

    INQUILINO     JURIDICOS.RAZON_SOCIAL%TYPE;
    DIRECCION     DIRECCIONES.Di_Direccion%TYPE;
    VNIT          NUMBER(18);
    VTIPO         VARCHAR2(2);
    FECHA_DESDE   DATE;
    FECHA_HASTA   DATE;
    VALOR_SIN_ARR NUMBER(18, 2) := 0;
    VALOR_SIN_CUO NUMBER(18, 2) := 0;
    VALOR_REC_ARR NUMBER(18, 2) := 0;
    VALOR_REC_CUO NUMBER(18, 2) := 0;
    VALOR_SIN_AD  NUMBER := 0;
    VALOR_REC_AD  NUMBER := 0;
    VALOR_OTRO    NUMBER := 0;
  BEGIN

    FOR REP IN C_PRINCIPAL LOOP
      -- Busca el nombre del inquilino
      BEGIN
        BEGIN
          SELECT pk_terceros.f_nombres(rvi_prs_nmro_idntfccion,
                                       rvi_prs_tpo_idntfccion),
                 RVI_PRS_NMRO_IDNTFCCION,
                 RVI_PRS_TPO_IDNTFCCION
            INTO INQUILINO, VNIT, VTIPO
            FROM RSGOS_VGNTES
           WHERE RVI_NMRO_ITEM = REP.SNA_NMRO_ITEM
             AND RVI_NMRO_PLZA = Rep.SNA_NMRO_PLZA
             AND RVI_CLSE_PLZA = Rep.SNA_CLSE_PLZA
             AND RVI_RAM_CDGO = Rep.SNA_RAM_CDGO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT pk_terceros.f_nombres(rir_nmro_idntfccion,
                                           rir_tpo_idntfccion),
                     RIR_NMRO_IDNTFCCION,
                     RIR_TPO_IDNTFCCION
                INTO INQUILINO, VNIT, VTIPO
                FROM RSGOS_RCBOS, CRTFCDOS
               WHERE RIR_NMRO_ITEM = Rep.SNA_NMRO_ITEM
                 AND RIR_NMRO_PLZA = Rep.SNA_NMRO_PLZA
                 AND RIR_CLSE_PLZA = Rep.SNA_CLSE_PLZA
                 AND RIR_RAM_CDGO = Rep.SNA_RAM_CDGO
                 AND RIR_NMRO_CRTFCDO = CER_NMRO_CRTFCDO
                 AND RIR_NMRO_PLZA = CER_NMRO_PLZA
                 AND RIR_CLSE_PLZA = CER_CLSE_PLZA
                 AND RIR_RAM_CDGO = CER_RAM_CDGO
                 AND CER_FCHA_DSDE_ACTUAL =
                     (SELECT MAX(CER_FCHA_DSDE_ACTUAL)
                        FROM RSGOS_RCBOS, CRTFCDOS
                       WHERE RIR_NMRO_ITEM = Rep.SNA_NMRO_ITEM
                         AND RIR_NMRO_PLZA = Rep.SNA_NMRO_PLZA
                         AND RIR_CLSE_PLZA = Rep.SNA_CLSE_PLZA
                         AND RIR_RAM_CDGO = Rep.SNA_RAM_CDGO
                         AND RIR_NMRO_CRTFCDO = CER_NMRO_CRTFCDO
                         AND RIR_NMRO_PLZA = CER_NMRO_PLZA
                         AND RIR_CLSE_PLZA = CER_CLSE_PLZA
                         AND RIR_RAM_CDGO = CER_RAM_CDGO);
            EXCEPTION
              WHEN No_Data_Found THEN
                INQUILINO := NULL;
                VNIT      := NULL;
                VTIPO     := NULL;
            END;
        END;
        -- Busca la direccion
        BEGIN
          SELECT Di_Direccion
            INTO Direccion
            FROM Direcciones
           WHERE Di_solicitud = Rep.SNA_Nmro_ITEM
             AND Di_Tpo_Drccion = 'R';
        EXCEPTION
          WHEN No_Data_Found THEN
            DIRECCION := NULL;
        END;
        -- Contabiliza el valor de siniestros de canon de arrendamientos
        BEGIN
          SELECT ROUND(SUM(VLRES_LQDCION.VLQ_VLOR * LQT_NMRO_DIAS), 0)
            INTO VALOR_SIN_ARR
            FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, AVSOS_SNSTROS
           WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
             AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
             AND LQT_NMRO_SNSTRO = SNA_NMRO_SNSTRO
             AND SNA_NMRO_PLZA = rep.SNA_NMRO_PLZA
             AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                 LQDCNES_DTLLE.LQT_TPO_LQDCION = LQDCNES.LQD_TPO_LQDCION AND
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD = LQDCNES.LQD_NMRO_SLCTUD) AND
                 (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                 VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                 VLRES_LQDCION.VLQ_TPO_LQDCION =
                 LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                 VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                 LQT_ESTDO_LQDCION = '03' AND
                 LQT_TPO_LQDCION IN ('01', '02', '03', '04') AND
                 LQD_FCHA_PGO = P_FECHA_PAGO) AND VLQ_CDGO_AMPRO = '01' AND
                 (VLQ_CNCPTO_VLOR = '01'));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            VALOR_SIN_ARR := 0;
        END;
        -- Contabiliza el valor de siniestros de cuota de administracion
        BEGIN
          SELECT ROUND(SUM(VLRES_LQDCION.VLQ_VLOR * LQT_NMRO_DIAS), 0)
            INTO VALOR_SIN_CUO
            FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, AVSOS_SNSTROS
           WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
             AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
             AND LQT_NMRO_SNSTRO = SNA_NMRO_SNSTRO
             AND SNA_NMRO_PLZA = rep.SNA_NMRO_PLZA
             AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                 LQDCNES_DTLLE.LQT_TPO_LQDCION = LQDCNES.LQD_TPO_LQDCION AND
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD = LQDCNES.LQD_NMRO_SLCTUD) AND
                 (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                 VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                 VLRES_LQDCION.VLQ_TPO_LQDCION =
                 LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                 VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                 LQT_ESTDO_LQDCION = '03' AND
                 LQT_TPO_LQDCION IN ('01', '02', '03', '04') AND
                 LQD_FCHA_PGO = P_FECHA_PAGO) AND VLQ_CDGO_AMPRO = '01' AND
                 (VLQ_CNCPTO_VLOR = '02'));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            VALOR_SIN_CUO := 0;
        END;
        -- Valor de Siniestro Adicionales
        BEGIN
          SELECT ROUND(SUM(VLRES_LQDCION.VLQ_VLOR * LQT_NMRO_DIAS), 0)
            INTO VALOR_SIN_AD
            FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, AVSOS_SNSTROS
           WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
             AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
             AND LQT_NMRO_SNSTRO = SNA_NMRO_SNSTRO
             AND SNA_NMRO_PLZA = rep.SNA_NMRO_PLZA
             AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                 LQDCNES_DTLLE.LQT_TPO_LQDCION = LQDCNES.LQD_TPO_LQDCION AND
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD = LQDCNES.LQD_NMRO_SLCTUD) AND
                 (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                 VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                 VLRES_LQDCION.VLQ_TPO_LQDCION =
                 LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                 VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                 LQD_FCHA_PGO = P_FECHA_PAGO))
             AND VLQ_CDGO_AMPRO <> '01'
             AND (VLQ_CNCPTO_VLOR IN ('03','04','05','06','14','15','16','17','18','19','20','21','22','23'));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            VALOR_SIN_AD := 0;
        END;
        -- Valida si existe alguna de los valores de siniestros para que traiga las fechas
        IF (NVL(VALOR_SIN_ARR, 0) + NVL(VALOR_SIN_CUO, 0)) = 0 AND
           NVL(VALOR_SIN_AD, 0) = 0 THEN
          FECHA_DESDE := NULL;
          FECHA_HASTA := NULL;
        ELSE
          -- Coloca la fecha desde
          BEGIN
            BEGIN
              SELECT MIN(LQDCNES_DTLLE.LQT_FCHA_DSDE)
                INTO FECHA_DESDE
                FROM LQDCNES,
                     LQDCNES_DTLLE,
                     VLRES_LQDCION,
                     VLRES_PRDCTO,
                     AVSOS_SNSTROS
               WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
                 AND VPR_CDGO = VLQ_CNCPTO_VLOR
                 AND VPR_DSCRPCION NOT LIKE '%RECUPERA%'
                 AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
                 AND LQT_NMRO_SNSTRO = SNA_NMRO_SNSTRO
                 AND SNA_NMRO_PLZA = rep.SNA_NMRO_PLZA
                 AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                     LQDCNES_DTLLE.LQT_TPO_LQDCION =
                     LQDCNES.LQD_TPO_LQDCION AND LQDCNES_DTLLE.LQT_NMRO_SLCTUD =
                     LQDCNES.LQD_NMRO_SLCTUD) AND
                     (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                     VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                     VLRES_LQDCION.VLQ_TPO_LQDCION =
                     LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                     VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                     LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                     LQT_ESTDO_LQDCION = '03' AND
                     LQT_TPO_LQDCION IN ('01', '02', '04', '03') AND
                     LQD_FCHA_PGO = P_FECHA_PAGO));
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                FECHA_DESDE := NULL;
            END;
            -- Coloca la Fecha Hasta
            BEGIN
              SELECT MAX(LQDCNES_DTLLE.LQT_FCHA_HSTA)
                INTO FECHA_HASTA
                FROM LQDCNES,
                     LQDCNES_DTLLE,
                     VLRES_LQDCION,
                     VLRES_PRDCTO,
                     AVSOS_SNSTROS
               WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
                 AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
                 AND LQT_NMRO_SNSTRO = SNA_NMRO_SNSTRO
                 AND SNA_NMRO_PLZA = rep.SNA_NMRO_PLZA
                 AND VPR_CDGO = VLQ_CNCPTO_VLOR
                 AND VPR_DSCRPCION NOT LIKE '%RECUPERA%'
                 AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                     LQDCNES_DTLLE.LQT_TPO_LQDCION =
                     LQDCNES.LQD_TPO_LQDCION AND LQDCNES_DTLLE.LQT_NMRO_SLCTUD =
                     LQDCNES.LQD_NMRO_SLCTUD) AND
                     (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                     VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                     VLRES_LQDCION.VLQ_TPO_LQDCION =
                     LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                     VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                     LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                     LQT_ESTDO_LQDCION = '03' AND
                     LQT_TPO_LQDCION IN ('01', '02', '03', '04') AND
                     LQD_FCHA_PGO = P_FECHA_PAGO));
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                FECHA_HASTA := NULL;
            END;
            --     END;
          END;
        END IF;
        -- Valor de Recuperacion de arrendamientos
        BEGIN
          SELECT ROUND(SUM(VLRES_LQDCION.VLQ_VLOR * LQT_NMRO_DIAS), 0)
            INTO VALOR_REC_ARR
            FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, AVSOS_SNSTROS
           WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
             AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
             AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                 LQDCNES_DTLLE.LQT_TPO_LQDCION = LQDCNES.LQD_TPO_LQDCION AND
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD = LQDCNES.LQD_NMRO_SLCTUD) AND
                 (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                 VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                 VLRES_LQDCION.VLQ_TPO_LQDCION =
                 LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                 VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                 LQDCNES_DTLLE.LQT_NMRO_SNSTRO =
                 AVSOS_SNSTROS.SNA_NMRO_SNSTRO AND
                 LQDCNES_DTLLE.LQT_RAM_CDGO = AVSOS_SNSTROS.SNA_RAM_CDGO AND
                 AVSOS_SNSTROS.SNA_ESTDO_SNSTRO != '06' AND
                 AVSOS_SNSTROS.SNA_NMRO_PLZA = REP.SNA_NMRO_PLZA AND
                 LQD_FCHA_PGO = P_FECHA_PAGO))
             AND (VLQ_CNCPTO_VLOR = 'RE01' OR VLQ_CNCPTO_VLOR = 'RM01');

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            VALOR_REC_ARR := 0;
        END;
        -- Valor de Recuperacion de cuota de administracion
        BEGIN
          SELECT ROUND(SUM(VLRES_LQDCION.VLQ_VLOR * LQT_NMRO_DIAS), 0)
            INTO VALOR_REC_CUO
            FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, AVSOS_SNSTROS
           WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
             AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
             AND LQT_NMRO_SNSTRO = SNA_NMRO_SNSTRO
             AND SNA_NMRO_PLZA = rep.SNA_NMRO_PLZA
             AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                 LQDCNES_DTLLE.LQT_TPO_LQDCION = LQDCNES.LQD_TPO_LQDCION AND
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD = LQDCNES.LQD_NMRO_SLCTUD) AND
                 (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                 VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                 VLRES_LQDCION.VLQ_TPO_LQDCION =
                 LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                 VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                 LQD_FCHA_PGO = P_FECHA_PAGO))
             AND (VLQ_CNCPTO_VLOR = 'RE02' OR VLQ_CNCPTO_VLOR = 'RM02');
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            VALOR_REC_CUO := 0;
        END;
        -- Valor de recuperaciones Adicionales
        BEGIN
          SELECT ROUND(SUM(VLRES_LQDCION.VLQ_VLOR * LQT_NMRO_DIAS), 0)
            INTO VALOR_REC_AD
            FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, AVSOS_SNSTROS
           WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
             AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
             AND LQT_NMRO_SNSTRO = SNA_NMRO_SNSTRO
             AND SNA_NMRO_PLZA = rep.SNA_NMRO_PLZA
             AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                 LQDCNES_DTLLE.LQT_TPO_LQDCION = LQDCNES.LQD_TPO_LQDCION AND
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD = LQDCNES.LQD_NMRO_SLCTUD) AND
                 (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                 VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                 VLRES_LQDCION.VLQ_TPO_LQDCION =
                 LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                 VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                 LQD_FCHA_PGO = P_FECHA_PAGO))
             AND (VLQ_CNCPTO_VLOR = 'RE03' OR VLQ_CNCPTO_VLOR = 'RE04' OR
                 VLQ_CNCPTO_VLOR = 'RE05');
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            VALOR_REC_AD := 0;
        END;
        -- Valor Otro
        BEGIN
          SELECT ROUND(SUM(VLRES_LQDCION.VLQ_VLOR * LQT_NMRO_DIAS), 0)
            INTO VALOR_OTRO
            FROM LQDCNES, LQDCNES_DTLLE, VLRES_LQDCION, AVSOS_SNSTROS
           WHERE LQD_NMRO_SLCTUD = Rep.SNA_NMRO_ITEM
             AND LQDCNES_DTLLE.LQT_ESTDO_LQDCION = '03'
             AND LQT_NMRO_SNSTRO = SNA_NMRO_SNSTRO
             AND SNA_NMRO_PLZA = rep.SNA_NMRO_PLZA
             AND ((LQDCNES_DTLLE.LQT_PRDO = LQDCNES.LQD_PRDO AND
                 LQDCNES_DTLLE.LQT_TPO_LQDCION = LQDCNES.LQD_TPO_LQDCION AND
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD = LQDCNES.LQD_NMRO_SLCTUD) AND
                 (VLRES_LQDCION.VLQ_SERIE = LQDCNES_DTLLE.LQT_SERIE AND
                 VLRES_LQDCION.VLQ_PRDO = LQDCNES_DTLLE.LQT_PRDO AND
                 VLRES_LQDCION.VLQ_TPO_LQDCION =
                 LQDCNES_DTLLE.LQT_TPO_LQDCION AND
                 VLRES_LQDCION.VLQ_NMRO_SLCTUD =
                 LQDCNES_DTLLE.LQT_NMRO_SLCTUD AND
                 LQD_FCHA_PGO = P_FECHA_PAGO))
             AND (VLQ_CNCPTO_VLOR <> '01' AND VLQ_CNCPTO_VLOR <> '02' AND
                 VLQ_CNCPTO_VLOR <> '03' AND VLQ_CNCPTO_VLOR <> '04' AND
                 VLQ_CNCPTO_VLOR <> '05' AND VLQ_CNCPTO_VLOR <> 'RE01' AND
                 VLQ_CNCPTO_VLOR <> 'RE02' AND VLQ_CNCPTO_VLOR <> 'RE03' AND
                 VLQ_CNCPTO_VLOR <> 'RE04' AND VLQ_CNCPTO_VLOR <> 'RE05' AND
                 VLQ_CNCPTO_VLOR <> 'RM01' AND VLQ_CNCPTO_VLOR <> 'RM02' AND
                 VLQ_CNCPTO_VLOR <> '06' AND VLQ_CNCPTO_VLOR <> '07' AND
                 VLQ_CNCPTO_VLOR <> '08' AND VLQ_CNCPTO_VLOR <> '09' AND
                 VLQ_CNCPTO_VLOR <> '13' AND VLQ_CNCPTO_VLOR <> '14' AND
                 VLQ_CNCPTO_VLOR <> '15' AND VLQ_CNCPTO_VLOR <> '16' AND
                 VLQ_CNCPTO_VLOR <> '17' AND VLQ_CNCPTO_VLOR <> '18' AND
                 VLQ_CNCPTO_VLOR <> '19' AND VLQ_CNCPTO_VLOR <> '20' AND
                 VLQ_CNCPTO_VLOR <> '21' AND VLQ_CNCPTO_VLOR <> '22' AND
                 VLQ_CNCPTO_VLOR <> '23' AND VLQ_CNCPTO_VLOR <> '27' AND
                 VLQ_CNCPTO_VLOR <> '28');
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            VALOR_OTRO := 0;
        END;
        -- Inserta los datos extraidos en la tabla temporal
        BEGIN
          IF NVL(VALOR_SIN_ARR, 0) + NVL(VALOR_SIN_CUO, 0) = 0 AND
             NVL(VALOR_SIN_AD, 0) = 0 THEN
            FECHA_DESDE := NULL;
            FECHA_HASTA := NULL;
          END IF;
          INSERT INTO RSINIESTROS
            (SNA_SUC_CDGO,
             SNA_CIA_CDGO,
             SNA_NMRO_PLZA,
             SNA_NMRO_ITEM,
             SNA_CLSE_PLZA,
             SNA_RAM_CDGO,
             PES_FCHA_PGO,
             PERIODO,
             AGENCIA,
             INQUILINO,
             DIRECCION,
             FECHA_DESDE,
             FECHA_HASTA,
             VALOR_SIN_ARR,
             VALOR_SIN_CUO,
             VALOR_REC_ARR,
             VALOR_REC_CUO,
             VALOR_SIN_AD,
             VALOR_REC_AD,
             VALOR_OTRO,
             DOCUMN_INQ,
             TIPODOC)
          VALUES
            (P_CODIGO_SUCURSAL,
             P_CODIGO_COMPANIA,
             Rep.SNA_NMRO_PLZA,
             Rep.SNA_NMRO_ITEM,
             Rep.SNA_CLSE_PLZA,
             Rep.SNA_RAM_CDGO,
             Rep.PES_FCHA_PGO,
             Rep.PERIODO,
             Rep.NIT || '  -  ' || Rep.AGENCIA,
             INQUILINO,
             DIRECCION,
             FECHA_DESDE,
             FECHA_HASTA,
             VALOR_SIN_ARR,
             VALOR_SIN_CUO,
             VALOR_REC_ARR,
             VALOR_REC_CUO,
             VALOR_SIN_AD,
             VALOR_REC_AD,
             VALOR_OTRO,
             VNIT,
             VTIPO);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20501,'Error insertando ' || To_Char(Rep.SNA_NMRO_PLZA) || ' ' ||To_Char(Rep.SNA_NMRO_ITEM) || ' ' || SQLERRM);
        END;
      END;
    END LOOP;

    -- LLENAR LA TABLA DE FACTURAS NEGATIVAS
    BEGIN
      INSERT INTO rsiniestros1
        SELECT FCN_PLZA, FCN_SLCTUD, FCN_VLOR, FCN_FCHA_PGO
          FROM FCTRAS_NGTVAS
         WHERE FCN_PLZA = P_POLIZA
           AND FCN_FCHA_PGO = P_FECHA_PAGO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,'Error creando la factura negativa para la póliza ' ||p_poliza || ' ' || sqlerrm);
    END;

  END PRC_LISTADO_SINIESTROS;

  --
  --
  --
  PROCEDURE PRC_ESTADOS_POLIZAS(P_POLIZA   NUMBER,
                                P_CLASE    VARCHAR2,
                                P_RAMO     VARCHAR2,
                                P_SUCURSAL VARCHAR2,
                                P_COMPANIA VARCHAR2) IS

  BEGIN
    UPDATE PLZAS
       SET POL_ESTADO_PLZA = 'R'
     WHERE POL_NMRO_PLZA = P_POLIZA
       AND POL_CDGO_CLSE = P_CLASE
       AND POL_RAM_CDGO = P_RAMO
       AND POL_SUC_CDGO = P_SUCURSAL
       AND POL_SUC_CIA_CDGO = P_COMPANIA
       AND POL_ESTADO_PLZA = 'P';

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501,'Error revocando la poliza ' ||to_char(p_poliza));

  END PRC_ESTADOS_POLIZAS;

  --
  -- SE INGRESA ORIGEN PARA QUE REALIZA LA SUMA SOLO POR EL ORIGEN QUE SE ENVIE 'V' Y 'N' UNICAMENTE
  --
  FUNCTION FUN_VALORES_IGUALES(P_SOLICITUD   NUMBER,
                               P_FECHA_MORA  DATE,
                               P_FECHA_PAGO  DATE,
                               P_ORIGEN      VARCHAR2) RETURN NUMBER IS

  VALOR    NUMBER;

  BEGIN
    SELECT SUM(V.VLQ_VLOR)
      INTO VALOR
      FROM LQDCNES D, LQDCNES_DTLLE L, VLRES_LQDCION V
     WHERE L.LQT_NMRO_SLCTUD = P_SOLICITUD
       AND L.LQT_FCHA_MRA = P_FECHA_MORA
       AND D.LQD_FCHA_PGO = P_FECHA_PAGO
       AND D.LQD_NMRO_SLCTUD = L.LQT_NMRO_SLCTUD
       AND D.LQD_TPO_LQDCION = L.LQT_TPO_LQDCION
       AND D.LQD_PRDO = L.LQT_PRDO
       AND L.LQT_NMRO_SLCTUD = V.VLQ_NMRO_SLCTUD
       AND L.LQT_TPO_LQDCION = V.VLQ_TPO_LQDCION
       AND L.LQT_PRDO = V.VLQ_PRDO
       AND L.LQT_SERIE = V.VLQ_SERIE
       AND V.VLQ_ORGEN = P_ORIGEN
       AND L.LQT_ESTDO_LQDCION = '03';

    RETURN(NVL(VALOR,0));

  END FUN_VALORES_IGUALES;


  --
  --
  --
  PROCEDURE PRC_CRUCES_REINTEGROS(P_POLIZA     PLZAS.POL_NMRO_PLZA%TYPE,
                                  P_CLASE      PLZAS.POL_CDGO_CLSE%TYPE,
                                  P_RAMO       PLZAS.POL_RAM_CDGO%TYPE,
                                  P_SUCURSAL   PLZAS.POL_SUC_CDGO%TYPE,
                                  P_FECHA_PAGO DATE) IS

    CURSOR C_LQDCNES IS
      -- Mantis #20487 GGM. 09/10/2013 se abre la consulta de solo liquidaciones con origen
      -- V - Devolución para validar que la suma de estas liquidaciones si es igual a cero
      -- no lo tome la consulta para que no genere la nota.
      -- Estos casos son cuando descuenta un valor por cuota y el mismo valor positivo por canon
      SELECT vlq_nmro_slctud,
             round(vlq_vlor * lqt_nmro_dias, 0),
             sna_fcha_snstro,
             pol_suc_cdgo,
             POL_DIV_CDGO,
             pol_prs_nmro_idntfccion,
             pol_prs_tpo_idntfccion,
             vlq_cncpto_vlor,
             vlq_orgen,
             sna_nmro_snstro
             -- SE QUITA LAS FECHAS DESDE HASTA PARA QUE TOME EL VALOR TOTAL POR CONCEPTO
             -- Y GENERE LA NOTA CORRECTA MANTIS # 31915 GGM. 01/12/2014
             -- lqt_fcha_dsde,
             -- lqt_fcha_hsta
        FROM vlres_lqdcion, lqdcnes_dtlle, lqdcnes, avsos_snstros, plzas
       WHERE sna_nmro_plza = P_POLIZA
         AND vlq_orgen = 'V'
         AND vlq_vlor < 0
         AND lqt_estdo_lqdcion = '03'
         AND vlq_nmro_slctud = lqt_nmro_slctud
         AND vlq_tpo_lqdcion = lqt_tpo_lqdcion
         AND vlq_prdo = lqt_prdo
         AND vlq_serie = lqt_serie
         AND vlq_nmro_slctud = lqd_nmro_slctud
         AND vlq_tpo_lqdcion = lqd_tpo_lqdcion
         AND vlq_prdo = lqd_prdo
         AND lqd_fcha_pgo = P_FECHA_PAGO
         AND lqt_nmro_slctud = sna_nmro_item
         AND lqt_fcha_mra = sna_fcha_snstro
         AND sna_nmro_plza = pol_nmro_plza
         AND pk_listados_cierre.fun_valores_iguales(sna_nmro_item,sna_fcha_snstro,p_fecha_pago,'V') != 0
    union
-- GGM. 02/02/2015 Mantis #32938 se ingresa consulta para que tome los cruces cuando esta solo una factura negativa origen 'N'
          SELECT vlq_nmro_slctud,
             round(vlq_vlor * lqt_nmro_dias, 0),
             sna_fcha_snstro,
             pol_suc_cdgo,
             POL_DIV_CDGO,
             pol_prs_nmro_idntfccion,
             pol_prs_tpo_idntfccion,
             vlq_cncpto_vlor,
             vlq_orgen,
             sna_nmro_snstro
             -- SE QUITA LAS FECHAS DESDE HASTA PARA QUE TOME EL VALOR TOTAL POR CONCEPTO
             -- Y GENERE LA NOTA CORRECTA MANTIS # 31915 GGM. 01/12/2014
             -- lqt_fcha_dsde,
             -- lqt_fcha_hsta
        FROM vlres_lqdcion, lqdcnes_dtlle, lqdcnes, avsos_snstros, plzas
       WHERE sna_nmro_plza = P_POLIZA
         AND vlq_orgen = 'N'
         AND vlq_vlor < 0
         AND lqt_estdo_lqdcion = '03'
         AND vlq_nmro_slctud = lqt_nmro_slctud
         AND vlq_tpo_lqdcion = lqt_tpo_lqdcion
         AND vlq_prdo = lqt_prdo
         AND vlq_serie = lqt_serie
         AND vlq_nmro_slctud = lqd_nmro_slctud
         AND vlq_tpo_lqdcion = lqd_tpo_lqdcion
         AND vlq_prdo = lqd_prdo
         AND lqd_fcha_pgo = P_FECHA_PAGO
         AND lqt_nmro_slctud = sna_nmro_item
         AND lqt_fcha_mra = sna_fcha_snstro
         AND sna_nmro_plza = pol_nmro_plza
         AND pk_listados_cierre.fun_valores_iguales(sna_nmro_item,sna_fcha_snstro,p_fecha_pago,'N') != 0
    union
      SELECT vlq_nmro_slctud,
             round(vlq_vlor * lqt_nmro_dias, 0),
             sna_fcha_snstro,
             pol_suc_cdgo,
             POL_DIV_CDGO,
             pol_prs_nmro_idntfccion,
             pol_prs_tpo_idntfccion,
             vlq_cncpto_vlor,
             vlq_orgen,
             sna_nmro_snstro
            -- lqt_fcha_dsde,
           --  lqt_fcha_hsta
        FROM vlres_lqdcion, lqdcnes_dtlle, lqdcnes, avsos_snstros, plzas, ddas_plzas
       WHERE sna_nmro_plza = P_POLIZA
         AND vlq_orgen not in ('A','V','N')
         AND vlq_vlor < 0
         AND lqt_estdo_lqdcion = '03'
         AND vlq_nmro_slctud = lqt_nmro_slctud
         AND vlq_tpo_lqdcion = lqt_tpo_lqdcion
         AND vlq_prdo = lqt_prdo
         AND vlq_serie = lqt_serie
         AND vlq_nmro_slctud = lqd_nmro_slctud
         AND vlq_tpo_lqdcion = lqd_tpo_lqdcion
         AND vlq_prdo = lqd_prdo
         AND lqd_fcha_pgo = P_FECHA_PAGO
         AND lqt_nmro_slctud = sna_nmro_item
         AND lqt_fcha_mra = sna_fcha_snstro
         AND sna_nmro_plza = pol_nmro_plza
         -- Se adiciona solo para que consulte las liquidaciones que se tiene que cruzar mantis # 25583 GGM 25/04/2014 porque las ya pagadas
         -- no tiene que salir ya que se genera doble cruce de siniestros. GGM 25/06/2014
         AND ddp_nmro_slctud = sna_nmro_item
         AND ddp_fcha_mra = sna_fcha_snstro
         AND trunc(lqt_fcha_dsde) between trunc(ddp_fcha_dsde) and trunc(ddp_fcha_hsta)
         AND trunc(lqt_fcha_hsta) between trunc(ddp_fcha_dsde) and trunc(ddp_fcha_hsta)
         AND ddp_vlor_dda - ddp_vlor_pgdo > 0
       ORDER BY VLQ_CNCPTO_VLOR;

    CURSOR C_DEUDAS(P_SOLICITUD NUMBER, P_FECHA_MORA DATE, P_CONCEPTO VARCHAR2) IS
      SELECT DDP_SERIE SERIE, DDP_VLOR_DDA DEUDA, DDP_VLOR_PGDO PAGADO
        FROM DDAS_PLZAS
       WHERE DDP_NMRO_SLCTUD = P_SOLICITUD
         AND DDP_FCHA_MRA = P_FECHA_MORA
         AND DDP_VLOR_DDA - DDP_VLOR_PGDO > 0
         AND DDP_CNCPTO = P_CONCEPTO
       ORDER BY DDP_FCHA_MDFCCION;

    solicitud        avsos_snstros.sna_nmro_item%type;
    siniestro        avsos_snstros.sna_nmro_snstro%type;
    valor            vlres_lqdcion.vlq_vlor%type;
    fecha_mora       avsos_snstros.sna_fcha_snstro%type;
    sucursal         plzas.pol_suc_cdgo%type;
    div_politica     plzas.pol_div_cdgo%type;
    nit              plzas.pol_prs_nmro_idntfccion%type;
    tpo_nit          plzas.pol_prs_tpo_idntfccion%type;
    concepto         vlres_lqdcion.vlq_cncpto_vlor%type;
    origen           vlres_lqdcion.vlq_orgen%type;
    oficina          ofcnas.ofi_cdgo%type;
    vlor_pgdo_plza   number;
    cadena           varchar2(500);
    seq_aseguradora  varchar2(500);
    v_solicitud      number;
    fecha_desde      date;
    --fecha_hasta      date;
    nota             varchar2(1);
    v_siniestro      number;
    v_fecha_dsde     date;
    valor_pagado     number;
    liq_negativas    number;
    pagos_reintegros number;
    saldo            number;
    v_actualizar     number;
    r_deudas         c_deudas%rowtype;
    v_concepto        vlres_lqdcion.vlq_cncpto_vlor%type;

  begin

    BEGIN
      SELECT PAR_RFRNCIA
        INTO OFICINA
        FROM PRMTROS
       WHERE PAR_MDLO = '6'
         AND PAR_CDGO = '2'
         AND PAR_SUC_CDGO = P_SUCURSAL
         AND PAR_SUC_CIA_CDGO = '40';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501, 'No Se Encontro el Parametro de Oficina Principal');
    END;

    BEGIN
      SELECT PGS_VLOR_PGDO
        INTO VLOR_PGDO_PLZA
        FROM PGOS_SNSTROS
       WHERE PGS_FCHA_PGO = P_FECHA_PAGO
         AND PGS_NMRO_PLZA = P_POLIZA
         AND PGS_CLSE_PLZA = P_CLASE
         AND PGS_RAM_CDGO = P_RAMO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        VLOR_PGDO_PLZA := 0;
    end;
dbms_output.put_line ('deuda poliza   '||VLOR_PGDO_PLZA);

    v_solicitud  := 0;
    v_siniestro  := 0;
    v_concepto   := null;
    --v_fecha_dsde := to_date('01/01/1890','dd/mm/yyyy');
    open c_lqdcnes;
    loop
      fetch c_lqdcnes
        into solicitud,
             valor,
             fecha_mora,
             sucursal,
             div_politica,
             nit,
             tpo_nit,
             concepto,
             origen,
             siniestro;
      if c_lqdcnes%notfound then
        exit;
      end if;

      if v_solicitud != solicitud then
         NOTA := 'N';
      else
        -- Mantis 20248 GGM. Se adiciona condición ya que cuando la solicitud tenia más de un valor negativo
        -- para el segundo registro no inicializaba la variable NOTA y no generaba la nota correspondiente.
        if v_siniestro != v_siniestro then
          NOTA := 'N';
        else
          if concepto != v_concepto then
            NOTA := 'N';
          else
            NOTA := 'S';
          end if;
        end if;
      end if;

      if vlor_pgdo_plza > 0 then
        -- Actualiza ddp
        update ddas_plzas
           set ddp_vlor_pgdo = ddp_vlor_dda
         where ddp_nmro_plza = p_poliza
           and ddp_nmro_slctud = solicitud
           and ddp_fcha_mra = fecha_mora
           and ddp_cncpto = concepto
           and ddp_orgen = origen
           /*and (trunc(ddp_fcha_dsde) between trunc(fecha_desde) and trunc(fecha_hasta)
            or trunc(ddp_fcha_hsta) between trunc(fecha_desde) and trunc(fecha_hasta))*/
           and ddp_vlor_dda - ddp_vlor_pgdo > 0;

        IF sql%notfound then
          IF origen = 'N' THEN
            update ddas_plzas
               set ddp_vlor_pgdo = ddp_vlor_dda
             where ddp_nmro_plza = p_poliza
               and ddp_nmro_slctud = solicitud
               and ddp_fcha_mra = fecha_mora
               and ddp_cncpto = concepto
               and ddp_vlor_dda - ddp_vlor_pgdo > 0
               and ddp_serie =
                   (select min(ddp_serie)
                      from ddas_plzas
                     where ddp_nmro_plza = p_poliza
                       and ddp_nmro_slctud = solicitud
                       and ddp_fcha_mra = fecha_mora
                       and ddp_cncpto = concepto
                       and ddp_vlor_dda - ddp_vlor_pgdo > 0);
          END IF;
        END IF;
        if sql%found then
          -- VERIFICA EL VALOR POR EL CUAL DEBE REALIZAR LA NOTA.
          IF NOTA = 'N' THEN
            Begin
              select pes_vlor_snstro
                into valor_pagado
                from pgos_efctdos_snstros
               where pes_fcha_pgo = p_fecha_pago
                 and pes_nmro_plza = p_poliza
                 and pes_nmro_snstro = siniestro;
            end;
            --             if valor_pagado < 0 then
            --              valor := valor_pagado * (-1);
            --             else
            -- Verificar la sumatoria de las liquidaciones negativas.
            SELECT SUM(round(vlq_vlor * lqt_nmro_dias, 0))
              INTO liq_negativas
              FROM vlres_lqdcion,
                   lqdcnes_dtlle,
                   lqdcnes,
                   avsos_snstros,
                   plzas
             WHERE sna_nmro_snstro = siniestro
               AND sna_nmro_plza = P_POLIZA
               AND vlq_orgen != 'A'
               AND vlq_vlor < 0
               AND lqt_estdo_lqdcion = '03'
               AND vlq_nmro_slctud = lqt_nmro_slctud
               AND vlq_tpo_lqdcion = lqt_tpo_lqdcion
               AND vlq_prdo = lqt_prdo
               AND vlq_serie = lqt_serie
               AND vlq_nmro_slctud = lqd_nmro_slctud
               AND vlq_tpo_lqdcion = lqd_tpo_lqdcion
               AND vlq_prdo = lqd_prdo
               AND lqd_fcha_pgo = P_FECHA_PAGO
               AND lqt_nmro_slctud = sna_nmro_item
               AND lqt_fcha_mra = sna_fcha_snstro
               AND sna_nmro_plza = pol_nmro_plza
               AND vlq_cncpto_vlor = concepto;

            -- Verificar los abonos o pagos a reintegros vía recibos de caja

            SELECT SUM(round(vlq_vlor * lqt_nmro_dias, 0))
              INTO pagos_reintegros
              FROM vlres_lqdcion,
                   lqdcnes_dtlle,
                   lqdcnes,
                   avsos_snstros,
                   plzas
             WHERE sna_nmro_snstro = siniestro
               AND sna_nmro_plza = P_POLIZA
               AND vlq_orgen IN ('E', 'N')
               AND vlq_vlor > 0
               AND lqt_estdo_lqdcion = '03'
               AND vlq_nmro_slctud = lqt_nmro_slctud
               AND vlq_tpo_lqdcion = lqt_tpo_lqdcion
               AND vlq_prdo = lqt_prdo
               AND vlq_serie = lqt_serie
               AND vlq_nmro_slctud = lqd_nmro_slctud
               AND vlq_tpo_lqdcion = lqd_tpo_lqdcion
               AND vlq_prdo = lqd_prdo
               AND lqd_fcha_pgo = P_FECHA_PAGO
               AND lqt_nmro_slctud = sna_nmro_item
               AND lqt_fcha_mra = sna_fcha_snstro
               AND sna_nmro_plza = pol_nmro_plza
               AND vlq_cncpto_vlor = concepto;

           valor := (NVL(liq_negativas, 0) + NVL(pagos_reintegros, 0)) * -1;
            --           end if;

dbms_output.put_line ('valor   '||NOTA||'  '||VALOR);
            IF VALOR > 0 THEN
dbms_output.put_line ('ENTRO');
              CADENA := sucursal || '40';
              REF_CODES(CADENA, SEQ_ASEGURADORA, 'SECUENCIA');
              INSERTAR_RECIBO_CRUCE(P_POLIZA,
                                    SOLICITUD,
                                    FECHA_MORA,
                                    '00',
                                    '12',
                                    concepto,
                                    valor * (-1),
                                    '40',
                                    OFICINA,
                                    NIT,
                                    TPO_NIT,
                                    SEQ_ASEGURADORA,
                                    P_SUCURSAL,
                                    DIV_POLITICA);
              NOTA := 'S';
            END IF;
          END IF;
        END IF;
      else
        if v_solicitud != solicitud then
          NOTA := 'N';
        else
          if v_siniestro != siniestro then
            NOTA := 'N';
          else
            if v_concepto != concepto then
              NOTA := 'N';
            else
              NOTA := 'S';
            end if;
          end if;
        end if;

        IF NOTA = 'N' THEN
          -- Verificar la sumatoria de las liquidaciones negativas.
          SELECT SUM(round(vlq_vlor * lqt_nmro_dias, 0))
            INTO liq_negativas
            FROM vlres_lqdcion,
                 lqdcnes_dtlle,
                 lqdcnes,
                 avsos_snstros,
                 plzas
           WHERE sna_nmro_snstro = siniestro
             AND sna_nmro_plza = P_POLIZA
             AND vlq_orgen != 'A'
             AND vlq_vlor < 0
             AND lqt_estdo_lqdcion = '03'
             AND vlq_nmro_slctud = lqt_nmro_slctud
             AND vlq_tpo_lqdcion = lqt_tpo_lqdcion
             AND vlq_prdo = lqt_prdo
             AND vlq_serie = lqt_serie
             AND vlq_nmro_slctud = lqd_nmro_slctud
             AND vlq_tpo_lqdcion = lqd_tpo_lqdcion
             AND vlq_prdo = lqd_prdo
             AND lqd_fcha_pgo = P_FECHA_PAGO
             AND lqt_nmro_slctud = sna_nmro_item
             AND lqt_fcha_mra = sna_fcha_snstro
             AND sna_nmro_plza = pol_nmro_plza
             AND vlq_cncpto_vlor = concepto;

          -- Verificar los abonos o pagos a reintegros vía recibos de caja

          SELECT SUM(round(vlq_vlor * lqt_nmro_dias, 0))
            INTO pagos_reintegros
            FROM vlres_lqdcion,
                 lqdcnes_dtlle,
                 lqdcnes,
                 avsos_snstros,
                 plzas
           WHERE sna_nmro_snstro = siniestro
             AND sna_nmro_plza = P_POLIZA
             AND vlq_orgen IN ('E', 'N')
             AND vlq_vlor > 0
             AND lqt_estdo_lqdcion = '03'
             AND vlq_nmro_slctud = lqt_nmro_slctud
             AND vlq_tpo_lqdcion = lqt_tpo_lqdcion
             AND vlq_prdo = lqt_prdo
             AND vlq_serie = lqt_serie
             AND vlq_nmro_slctud = lqd_nmro_slctud
             AND vlq_tpo_lqdcion = lqd_tpo_lqdcion
             AND vlq_prdo = lqd_prdo
             AND lqd_fcha_pgo = P_FECHA_PAGO
             AND lqt_nmro_slctud = sna_nmro_item
             AND lqt_fcha_mra = sna_fcha_snstro
             AND sna_nmro_plza = pol_nmro_plza
             AND vlq_cncpto_vlor = concepto;

          valor := (NVL(liq_negativas, 0) + NVL(pagos_reintegros, 0)) * -1;

        END IF;
dbms_output.put_line ('valor   '||NOTA||'  '||VALOR);
        IF NOTA = 'N' AND VALOR > 0 THEN
dbms_output.put_line ('ENTRO  11');
          CADENA := sucursal || '40';
          REF_CODES(CADENA, SEQ_ASEGURADORA, 'SECUENCIA');
          INSERTAR_RECIBO_CRUCE(P_POLIZA,
                                SOLICITUD,
                                FECHA_MORA,
                                '00',
                                '12',
                                concepto,
                                valor * (-1),
                                '40',
                                OFICINA,
                                NIT,
                                TPO_NIT,
                                SEQ_ASEGURADORA,
                                P_SUCURSAL,
                                DIV_POLITICA);
          NOTA := 'S';

          SALDO := VALOR;
          OPEN C_DEUDAS(solicitud, fecha_mora,concepto);
          LOOP
            FETCH C_DEUDAS
              INTO R_DEUDAS;
            IF C_DEUDAS%NOTFOUND THEN
              EXIT;
            END IF;
            IF R_DEUDAS.DEUDA - R_DEUDAS.PAGADO > SALDO THEN
              V_ACTUALIZAR := SALDO;
            ELSE
              V_ACTUALIZAR := R_DEUDAS.DEUDA - R_DEUDAS.PAGADO;
            END IF;
            SALDO := SALDO - V_ACTUALIZAR;

            -- Actualiza ddp
            update ddas_plzas
               set ddp_vlor_pgdo = ddp_vlor_pgdo + v_actualizar
             where ddp_nmro_plza = p_poliza
               and ddp_nmro_slctud = solicitud
               and ddp_fcha_mra = fecha_mora
               and ddp_serie = r_deudas.serie;

            IF SALDO = 0 THEN
              EXIT;
            END IF;

          END LOOP;
          CLOSE C_DEUDAS;

        END IF;
      end if;

      v_solicitud  := solicitud;
      v_siniestro  := siniestro;
      v_concepto   := concepto;
      v_fecha_dsde := fecha_desde;
    end loop;
    close c_lqdcnes;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501, SQLERRM);

  END PRC_CRUCES_REINTEGROS;

---------------------------------------------------------------------------------------------
-- FUNCION TRAIDA DESDE INTRANET QUE ME DEVUELVE SI SE MUESTRA O NO LA REALCION DE FACTURA --
-- CREADO POR: GONZALO CHAPARRO.                                         SEPTIEMBRE - 2014 --
---------------------------------------------------------------------------------------------
FUNCTION FUN_RELACION_DE_FACTURAS(P_POLIZA   IN   VARCHAR2,
                                  P_FECHA    IN   VARCHAR2) RETURN NUMBER IS

V_COUNT NUMBER;

BEGIN

  BEGIN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PLZAS,
           FCTRAS,
           V_DIVISION_POLITICAS,
           SCRSL
     WHERE POL_NMRO_PLZA         = P_POLIZA
       AND FAC_FCHA_PGO          = TO_DATE(P_FECHA,'DD-MM-RRRR')
       AND FAC_NMRO_IDNTFCCION   = POL_PRS_NMRO_IDNTFCCION
        AND FAC_TPO_IDNTFCCION    = POL_PRS_TPO_IDNTFCCION
         AND FAC_TPO_RCBO_ORGNA    = 'M'
       AND FAC_ESTDO_FCTRA       <> 'A'
       AND CODAZZI_CIU           = FAC_DIV_CDGO
       AND SUC_CDGO              = FAC_SUC_CDGO
       AND SUC_CIA_CDGO          = FAC_CDGO_CIA;

    EXCEPTION WHEN NO_DATA_FOUND THEN
                V_COUNT := 0;
              WHEN OTHERS THEN
                V_COUNT := 0;
  END;

  RETURN V_COUNT;
END FUN_RELACION_DE_FACTURAS;

---------------------------------------------------------------------------------------
-- PROCEDIMIENTOS LLAMADO DESDE LA APLIACION DE LISTADOS WEB PARA VALIDAR EL ACCESO  --
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
  V_ERROR       := '0';

  BEGIN -- saca el pais del map.
    SELECT PS.VALOR
      INTO P_COD_PAIS
      FROM PARAMETRO_SAI PS
     WHERE PS.ID        = 'PAIS';

    EXCEPTION WHEN OTHERS THEN
                P_COD_PAIS    := 'CO';
  END;

  BEGIN -- saca el codigo de SAI en el map..
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
                V_ERROR := 'NO SE PUEDE AUTENTICAR EL LOGIN '||P_NID_LOGIN||'. '||SQLERRM;
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
                  V_ERROR := 'ERROR AL CAPTURAR LA INFORMACION DEL USUARIO LOGEADO '||SQLERRM;
    END;
  END IF;

  IF V_ERROR = '0' THEN
    BEGIN
      P_NOM_LOGIN := PK_TERCEROS.F_NOMBRES(P_NID_LOGIN, P_TID_LOGIN);

      EXCEPTION WHEN OTHERS THEN
                  P_NOM_LOGIN := '';
    END;
  END IF;

  P_ERROR := V_ERROR;
END PRC_VALIDA_ACCESO_USER;

---------------------------------------------------------------------------------
-- DEVUELVE LA DIRECCION DEL LISTADO SELECCIONADA POR EL USUARIO EN LA PAGINA  --
-- CREADO POR: GONZALO CHAPARRO.                             SEPTIEMBRE - 2014 --
---------------------------------------------------------------------------------
FUNCTION FUN_RET_URL_LISTADO(P_COD_LISTADO   IN NUMBER,
                             P_POLIZA        IN NUMBER,
                             P_PERIODO       IN VARCHAR2) RETURN VARCHAR2 IS


V_REPORTE           VARCHAR2(100) := NULL;
V_DIRECCION         VARCHAR2(1000) := NULL;
V_PARAMETROS        VARCHAR2(100) := NULL;

BEGIN

  IF P_COD_LISTADO = 1 THEN -- estracto de cuenta.
    V_REPORTE    := 'EXCU';
    V_PARAMETROS := '&P_POLIZA='|| P_POLIZA ||'&'||'P_FECHA='|| P_PERIODO;
  ELSIF P_COD_LISTADO = 2 THEN
    V_REPORTE := 'REAS';
    V_PARAMETROS := '&P_POLIZA='|| P_POLIZA ||'&'||'P_FECHA='|| P_PERIODO;
  ELSIF P_COD_LISTADO = 3 THEN
    V_REPORTE := 'CESE';
    V_PARAMETROS := '&P_POLIZA='|| P_POLIZA ||'&'||'P_FECHA='|| P_PERIODO;
  ELSIF P_COD_LISTADO = 4 THEN
    V_REPORTE := 'RESI';
    V_PARAMETROS := '&P_POLIZA='|| P_POLIZA ||'&'||'P_FECHA='|| P_PERIODO;
  ELSIF P_COD_LISTADO = 5 THEN --
    V_REPORTE := 'CARE';
    V_PARAMETROS := '&P_POLIZA='|| P_POLIZA ||'&'||'P_FECHA='|| P_PERIODO;
  ELSIF P_COD_LISTADO = 6 THEN
    V_REPORTE := 'LINO';
    V_PARAMETROS := '&P_POLIZA='|| P_POLIZA ||'&'||'P_FECHA='|| P_PERIODO;
  ELSIF P_COD_LISTADO = 7 THEN
    V_REPORTE   := 'CLHO';
    V_PARAMETROS := '';
  ELSE
    V_REPORTE   := 'PWEB';
    V_PARAMETROS := '';
  END IF;

  BEGIN -- saca la direccion del service del map...
    SELECT PS.VALOR
      INTO V_DIRECCION
      FROM PARAMETRO_SAI PS
     WHERE PS.ID        = V_REPORTE;

    V_DIRECCION := V_DIRECCION||V_PARAMETROS;

    EXCEPTION WHEN OTHERS THEN
                V_DIRECCION := NULL;
  END;

  IF V_DIRECCION IS NULL THEN
    BEGIN -- saca el pais del map.
      SELECT PS.VALOR
        INTO V_DIRECCION
        FROM PARAMETRO_SAI PS
       WHERE PS.ID        = 'PWEB';

      EXCEPTION WHEN OTHERS THEN
                  V_DIRECCION := 'http://www.ellibertador.co';
    END;
  END IF;

  RETURN V_DIRECCION;
END FUN_RET_URL_LISTADO;

---------------------------------------------------------------------------------
-- RETORNA EL VALOR DE LOS SERVICIOS PUBLICOS POR CADA ASEGURADO PARA EL EXCEL --
-- CREADO POR: GONZALO CHAPARRO.                             SEPTIEMBRE - 2014 --
---------------------------------------------------------------------------------
FUNCTION FUN_RET_SERVICIOS(P_LSERVPUB   IN VARCHAR2,
                           P_LAMPINT    IN VARCHAR2,
                           P_LAMPINTS   IN VARCHAR2) RETURN VARCHAR2 IS

V_SERV_PUB      VARCHAR2(200) := NULL;

BEGIN
  BEGIN -- saca el valor de servicios públicos.
    IF P_LSERVPUB LIKE 'S.P.R%' OR P_LAMPINT LIKE 'A.I%' OR P_LAMPINTS IS NOT NULL THEN
      V_SERV_PUB := P_LSERVPUB||'  '||P_LAMPINT||'  '||P_LAMPINTS;
    ELSE
      V_SERV_PUB := P_LSERVPUB;
    END IF;

    EXCEPTION WHEN OTHERS THEN
                V_SERV_PUB := 'ERROR';
  END;

  RETURN V_SERV_PUB;
END FUN_RET_SERVICIOS;

----------------------------------------------------------------------
-- RETORNA INFORMACION REQUERIDA PARA LOS TOTALES DEL ARCHIVO EXCEL --
-- CREADO POR: GONZALO CHAPARRO.                  SEPTIEMBRE - 2014 --
----------------------------------------------------------------------
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
                            P_VALOR_IVA     OUT NUMBER) IS

BEGIN

--SUM_RETRO_TOTAL  := SUM_RETRO_TOTAL - (NVL((SUM_RETRO_TOTAL - ROUND((SUM_RETRO_TOTAL/(1 + (PKG_OPERACION.FUN_VALOR_IVA)/100)),0)),0));

  BEGIN -- saca el iva para la última parte.
    SELECT CER_VLOR_IVA
      INTO P_VLR_IVA
      FROM CRTFCDOS
     WHERE CER_NMRO_PLZA                            = TO_NUMBER(P_POLIZA)
       AND TO_CHAR(CER_FCHA_DSDE_ACTUAL,'MMYYYY')   = TO_CHAR(TO_DATE(P_PERIODO,'DD/MM/YYYY'),'MMYYYY');

    EXCEPTION WHEN OTHERS THEN
                P_VLR_IVA := 0;
  END;

  BEGIN -- saca la información de los subtotales del amparo de hogar.
    SELECT NVL(ROUND((SUM(AA.AMPASIS)/(1 + (PKG_OPERACION.FUN_VALOR_IVA)/100)),0),0)
           ,NVL(ROUND((SUM(AA.AMPHOGAR)/(1 + (PKG_OPERACION.FUN_VALOR_IVA)/100)),0),0)
           ,NVL((SUM(AA.AMPASIS) - ROUND((SUM(AA.AMPASIS)/(1 + (PKG_OPERACION.FUN_VALOR_IVA)/100)),0)),0)
           ,NVL((SUM(AA.AMPHOGAR)- ROUND((SUM(AA.AMPHOGAR)/(1 + (PKG_OPERACION.FUN_VALOR_IVA)/100)),0)),0)
           ,NVL(SUM(AA.AMPASIS),0)
           ,NVL(SUM(AA.AMPHOGAR),0)
      INTO P_NETA_ASIS, P_NETA_HOGAR, P_IVA_ASIS, P_IVA_HOGAR, P_TOTAL_ASIS, P_TOTAL_HOGAR
      FROM RASEGURADOS AA
     WHERE AA.FECHA_PAGO      = TO_DATE(P_PERIODO,'DD/MM/YYYY')
       AND AA.POLIZA          = TO_NUMBER(P_POLIZA)
    GROUP BY AA.SUCURSAL, AA.COMPANIA, AA.POLIZA;

    EXCEPTION WHEN OTHERS THEN
                P_NETA_ASIS := 0;
                P_NETA_HOGAR := 0;
                P_IVA_ASIS := 0;
                P_IVA_HOGAR := 0;
                P_TOTAL_ASIS := 0;
                P_TOTAL_HOGAR := 0;
  END;

  BEGIN -- saca las devoluciones de hogar.
    SELECT TRIM(TO_CHAR(NVL(ACU.DEVOLUCIONES,0),'999,999,999,999,999'))
      INTO P_DEV_HOGAR
      FROM RASEGURADOSRES ACU
     WHERE ACU.FECHA_PAGO   = TO_DATE(P_PERIODO,'DD/MM/YYYY')
       AND ACU.POLIZA       = TO_NUMBER(P_POLIZA)
       AND AMPARO           LIKE 'HOGAR';

    EXCEPTION WHEN NO_DATA_FOUND THEN
                    P_DEV_HOGAR := 0;
  END;

  BEGIN -- valor de iva para las funciones...
    P_VALOR_IVA := PKG_OPERACION.FUN_VALOR_IVA;

    EXCEPTION WHEN OTHERS THEN
                P_VALOR_IVA := 0;
  END;

END PRC_VALORES_EXCEL;

--------------------------------------------------------------------------------
-- DEVUELVE UN CLOB CON LA INFORMACION PARA LA GENERACION DE LA PLANTILLA PDF --
-- CREADO POR: GONZALO CHAPARRO.                            SEPTIEMBRE - 2014 --
--------------------------------------------------------------------------------
PROCEDURE PRC_GENERAR_RESULTADO(P_SOLICITUD       IN  VARCHAR2,
                                P_PASSWORD        IN  VARCHAR2,
                                P_DEVUELVE_DATOS  OUT CLOB,
                                P_COD_ERROR       OUT VARCHAR2,
                                P_DESC_ERROR      OUT VARCHAR2) IS

-- cursor que saca los arrendatarios de una solicitud.
CURSOR ARRENDATARIOS(V_SOLICITUD_UNO IN NUMBER) IS
  SELECT A.ARR_TPO_ARRNDTRIO AS TIPO,
         DECODE(A.ARR_TPO_ARRNDTRIO,'P','INQUILINO','I','INQUILINO','DEUDOR SOLIDARIO') AS DESC_TIPO_ARR,
         TRIM(TO_CHAR(NVL(A.ARR_NMRO_IDNTFCCION,0),'999,999,999,999')) AS CEDULA,
         PK_TERCEROS.F_NOMBRES(A.ARR_NMRO_IDNTFCCION,A.ARR_TPO_IDNTFCCION) AS NOMBRE,
         A.ARR_NMRO_SLCTUD AS SOLICITUD,
         A.ARR_SES_NMRO
    FROM ARRNDTRIOS A
   WHERE A.ARR_SES_NMRO     = V_SOLICITUD_UNO
     AND A.ARR_ESTDO        = 'V'
  ORDER BY A.ARR_TPO_ARRNDTRIO DESC, A.ARR_NMRO_SLCTUD;

-- saca los resultados por arrendatario.
CURSOR C_RESULTADOS (V_SOLI_ARR IN NUMBER, V_FECHA_RES_ARR IN DATE) IS
  SELECT DISTINCT(C.RET_CDGO_RSLTDO) AS CODIGO,
         C.RET_OBSRVCION AS DESCRIPCION,
         C.RET_FCHA_RSLTDO AS FECHA_RESUL
    FROM RSLTDO_ESTDIO C, RSLTDOS_ARRNDTRIOS D
   WHERE C.RET_NMRO_SLCTUD   = D.REA_NMRO_SLCTUD
     AND C.RET_NMRO_SLCTUD   = V_SOLI_ARR
     AND D.REA_TPO_RSLTDO    = 'D'
     AND C.RET_FCHA_RSLTDO   = V_FECHA_RES_ARR
     AND C.RET_FCHA_RSLTDO   = D.REA_FCHA_RSLTDO
     AND C.RET_CDGO_RSLTDO   NOT IN (SELECT E.CRE_CDGO
                                       FROM CDGOS_RSLTDS E
                                      WHERE E.CRE_CNSLTBLE = 'N')
  ORDER BY C.RET_CDGO_RSLTDO ASC;

V_FECHA                 VARCHAR2(80) := NULL;
--V_DERECHOS              VARCHAR2(80) := NULL;
V_SOLI_ARRENDATARIO     NUMBER;
V_FECHA_RES_DATE        DATE;
V_FECHA_RES_CHAR        VARCHAR2(10);
V_DIRECCION             VARCHAR2(100);
V_CUOTA                 VARCHAR2(30);
V_ADMON                 VARCHAR2(30);
V_NUM_POLIZA            NUMBER;
V_DESC_INMOBILIARIA     VARCHAR2(100);
V_RESULTADOS            VARCHAR2(4000);
V_ESPACIO               NUMBER(2) := 0;
V_COD_ERROR             VARCHAR2(6) := '0';
V_DESC_ERROR            VARCHAR2(4000) := NULL;
V_EXCEPCION             EXCEPTION;

BEGIN
  IF P_SOLICITUD IS NULL THEN
    V_COD_ERROR  := '20810';
    V_DESC_ERROR := 'EL NUMERO DE SOLICITUD NO PUEDE VENIR VACIO.';
    RAISE V_EXCEPCION;
  END IF;

  IF P_PASSWORD IS NULL THEN
    V_COD_ERROR  := '20811';
    V_DESC_ERROR := 'LA CONTRASEÑA NO PUEDE VENIR VACIA.';
    RAISE V_EXCEPCION;
  END IF;

  BEGIN
    V_FECHA    := FUN_RETORNA_FECHA(SYSDATE);

    EXCEPTION WHEN OTHERS THEN
                V_COD_ERROR  := '20812';
                V_DESC_ERROR := 'ERROR EN LA GENERACION DEL REPORTE, POR FAVOR COMUNIQUESE CON EL LIBERTADOR '||SUBSTR(SQLERRM,0,3700);
                RAISE V_EXCEPCION;
  END;

  -- ARR_SES_NMRO. es el número de solicitud por estudio
  -- ARR_NMRO_SLCTUD es el numero de solicitud por arrendatario.
  BEGIN -- saca la solicitud del arrendatario.
    SELECT A.ARR_NMRO_SLCTUD
      INTO V_SOLI_ARRENDATARIO
      FROM ARRNDTRIOS A
     WHERE A.ARR_SES_NMRO                     = P_SOLICITUD
       AND MOD(A.ARR_NMRO_IDNTFCCION,10000)   = P_PASSWORD
       AND A.ARR_TPO_ARRNDTRIO                IN ('P','I');

    EXCEPTION WHEN NO_DATA_FOUND THEN
                V_COD_ERROR  := '20512';
                V_DESC_ERROR := 'NO SE ENCONTRO INFORMACION PARA LA SOLICITUD '||P_SOLICITUD||' Y CONTRASENA '||P_PASSWORD;
                RAISE V_EXCEPCION;
              WHEN OTHERS THEN
                V_COD_ERROR  := '20514';
                V_DESC_ERROR := 'ERROR AL CONSULTAR INFORMACION PARA LA SOLICITUD '||P_SOLICITUD||' Y CONTRASENA '||P_PASSWORD||' - '||SUBSTR(SQLERRM,0,3700);
                RAISE V_EXCEPCION;
  END;

  BEGIN -- fecha de resultado por cada arrendatario.
    SELECT MAX(B.REA_FCHA_RSLTDO)
      INTO V_FECHA_RES_DATE
      FROM RSLTDOS_ARRNDTRIOS B
     WHERE B.REA_NMRO_SLCTUD      = V_SOLI_ARRENDATARIO;

    EXCEPTION WHEN NO_DATA_FOUND THEN
                V_COD_ERROR  := '20516';
                V_DESC_ERROR := 'NO SE ENCONTRO RESULTADO PARA LA SOLICITUD '||V_SOLI_ARRENDATARIO;
                RAISE V_EXCEPCION;
              WHEN OTHERS THEN
                V_COD_ERROR  := '20518';
                V_DESC_ERROR := 'ERROR AL CONSULTAR EL RESULTADO PARA LA SOLICITUD '||V_SOLI_ARRENDATARIO||' - '||SUBSTR(SQLERRM,0,3700);
                RAISE V_EXCEPCION;
  END;

  IF V_FECHA_RES_DATE IS NULL THEN -- se hace xq el max muchas veces no estra por no_data_found.
    V_COD_ERROR  := '20520';
    V_DESC_ERROR := 'NO SE ENCONTRO RESULTADO PARA LA SOLICITUD '||V_SOLI_ARRENDATARIO;
    RAISE V_EXCEPCION;

  ELSE
    BEGIN
      V_FECHA_RES_CHAR := TO_CHAR(V_FECHA_RES_DATE,'DD-MM-RRRR');

      EXCEPTION WHEN OTHERS THEN
                  V_COD_ERROR  := '20521';
                  V_DESC_ERROR := 'ERROR AL TRAER LA FECHA DE RESULTADO '||V_FECHA_RES_DATE||' - '||SUBSTR(SQLERRM,0,3700);
                  RAISE V_EXCEPCION;
    END;
  END IF;

  BEGIN -- saca la direccion de la solicitud.
    SELECT DI_DIRECCION
      INTO V_DIRECCION
      FROM DIRECCIONES
     WHERE DI_SOLICITUD     = P_SOLICITUD
       AND DI_TPO_DRCCION   = 'E';

    EXCEPTION WHEN NO_DATA_FOUND THEN
                V_COD_ERROR  := '20522';
                V_DESC_ERROR := 'NO SE ENCONTRO DIRECCION ALMACENADA PARA LA SOLICITUD '||P_SOLICITUD;
                RAISE V_EXCEPCION;
              WHEN TOO_MANY_ROWS THEN
                V_COD_ERROR  := '20524';
                V_DESC_ERROR := 'NO SE ENCONTRO MAS DE UNA DIRECCION ALMACENADA PARA LA SOLICITUD '||P_SOLICITUD;
                RAISE V_EXCEPCION;
              WHEN OTHERS THEN
                V_COD_ERROR  := '20526';
                V_DESC_ERROR := ' ERROR AL CONSULTAR LA DIRECCION DE LA SOLICITUD '||P_SOLICITUD||' - '||SUBSTR(SQLERRM,0,3700);
                RAISE V_EXCEPCION;
  END;

  BEGIN -- saca la informacion de la inmobiliaria y valores.
    SELECT TRIM(TO_CHAR(NVL(A.SES_CNON_ARRNDMNTO,0),'$999,999,999,999')),
           TRIM(TO_CHAR(NVL(A.SES_CTA_ADMNSTRCION,0),'$999,999,999,999')), B.POL_NMRO_PLZA,
           PK_TERCEROS.F_NOMBRES(B.POL_PRS_NMRO_IDNTFCCION,B.POL_PRS_TPO_IDNTFCCION) POL_PRS_NMBRE
      INTO V_CUOTA, V_ADMON, V_NUM_POLIZA, V_DESC_INMOBILIARIA
      FROM SLCTDES_ESTDIOS A, PLZAS B
     WHERE A.SES_NMRO_PLZA    = B.POL_NMRO_PLZA
       AND A.SES_CLSE_PLZA    = B.POL_CDGO_CLSE
       AND A.SES_RAM_CDGO     = B.POL_RAM_CDGO
       AND A.SES_NMRO         = P_SOLICITUD;

    EXCEPTION WHEN NO_DATA_FOUND THEN
                V_COD_ERROR  := '20528';
                V_DESC_ERROR := 'NO SE ENCONTRARON DATOS DEL CANON Y LA INMOBILIARIA PARA LA SOLICITUD '||P_SOLICITUD;
                RAISE V_EXCEPCION;
              WHEN OTHERS THEN
                V_COD_ERROR  := '20530';
                V_DESC_ERROR := 'ERROR CONSULTANDO LA INFORMACION DEL CANON Y LA INMOBILIARIA PARA LA SOLICITUD '||P_SOLICITUD||' - '||SUBSTR(SQLERRM,0,3700);
                RAISE V_EXCEPCION;
  END;

  /*BEGIN -- inserta en la tabla de auditoria.
    INSERT INTO AUDITORIA VALUES(P_SOLICITUD, V_NUM_POLIZA, SYSDATE);
    COMMIT;

    EXCEPTION WHEN OTHERS THEN
                NULL;
  END;*/

  DBMS_LOB.CREATETEMPORARY(P_DEVUELVE_DATOS, TRUE); -- inicializa el lob de los documentos.

  ---------- concatena el titulo de la certificacion ----------
  V_ESPACIO := 3;
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'<tit>'||V_ESPACIO||' := '||'RESULTADO DE LA SOLICITUD'||'</tit>');
  -------------------------------------------------------------

  ---------- concatena el encabezado de la carta ----------
  V_ESPACIO := 3;
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'<dai>'||V_ESPACIO||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'Inmobiliaria. :='||REPLACE(V_DESC_INMOBILIARIA,'Ñ','')||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'Agencia. :='||V_NUM_POLIZA||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'Dirección del inmueble. :='||V_DIRECCION||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'Fecha de resultado. :='||V_FECHA_RES_CHAR||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'Canon. :='||V_CUOTA||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'Administración. :='||V_ADMON||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'</dai>');
  ---------------------------------------------------------

  ---------- concatena el titulo de la certificacion ----------
  V_ESPACIO := 3;
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'<des>'||V_ESPACIO||':='||'Descripción del resultado'||'</des>');
  -------------------------------------------------------------

  V_ESPACIO := 1;
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'<deu>'||V_ESPACIO||':=');

  FOR A IN ARRENDATARIOS(V_SOLI_ARRENDATARIO) LOOP -- los deudores de la solicitud.
    FOR C IN C_RESULTADOS(A.SOLICITUD, V_FECHA_RES_DATE) LOOP -- resultados por deudor.
      BEGIN
        IF C.CODIGO = 70 OR C.CODIGO = 71 THEN -- no concatene resultados.
          NULL;
        ELSE
          V_RESULTADOS := V_RESULTADOS||C.DESCRIPCION||'.'||CHR(10);
        END IF;
      END;
    END LOOP;

    IF V_RESULTADOS IS NOT NULL THEN
      V_RESULTADOS := SUBSTR(V_RESULTADOS,0,LENGTH(V_RESULTADOS)-1);
    ELSE
      V_RESULTADOS := ' - ';
    END IF;

    DBMS_LOB.APPEND(P_DEVUELVE_DATOS,A.DESC_TIPO_ARR||':='||A.CEDULA||':='||REPLACE(trim(A.NOMBRE),'Ñ','')||':='||A.SOLICITUD||':='||V_RESULTADOS||':=');

    V_RESULTADOS := NULL;
  END LOOP;

  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'</deu>');
  --------------------------------------------------------------------

  ---------- concatena la alerta de la carta ----------
  V_ESPACIO := 2;
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'<alt>'||V_ESPACIO||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'ALERTA. '||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'La suplantación al firmar los contratos de arrendamiento se ha convertido en una diaria amenaza. Es de total responsabilidad del arrendador verificar nombres, cedulas y la capacidad de contratación de los futuros arrendatarios. '||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'ATREVASE A SOSPECHAR '||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'y tome las medidas necesarias para evitar la suplantación y falsedad al suscribir los contratos de arrendamiento, en caso de siniestro '||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'la Aseguradora se abstendrá de indemnizar.'||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'</alt>');
  ---------------------------------------------------------

  ---------- concatena la alerta de la carta ----------
  V_ESPACIO := 4;
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'<pie>'||V_ESPACIO||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'Fecha de Consulta. '||':='||V_FECHA||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'Todos los derechos reservados.'||':=');
  DBMS_LOB.APPEND(P_DEVUELVE_DATOS,'</pie>');
  ---------------------------------------------------------

  -- devolución de las variables de error sin que haya una excepcion --
  P_COD_ERROR  := '0';
  P_DESC_ERROR := 'Transacción Exitosa';

  -- al lanzar una excepcion, aquí la coje y actualiza p_cod_error y p_desc_error --
  EXCEPTION WHEN V_EXCEPCION THEN
              P_COD_ERROR  := V_COD_ERROR;
              P_DESC_ERROR := V_DESC_ERROR;
END PRC_GENERAR_RESULTADO;

-----------------------------------------------------
-- RETORNA EL NOMBRE DEL MES ENVIADO POR PARAMETRO --
-- CREADO POR: GONZALO CHAPARRO. SEPTIEMBRE - 2011 --
-----------------------------------------------------
FUNCTION FUN_RETORNA_FECHA (P_FECHA     IN DATE) RETURN VARCHAR2 IS

V_RETORNO   VARCHAR2(30) := NULL;
V_DIA       VARCHAR2(2)  := '00';
V_MES       VARCHAR2(2)  := '13';
V_ANIO      VARCHAR2(4)  := '1600';

BEGIN

  V_DIA  := TO_CHAR(P_FECHA,'DD');
  V_MES  := TO_CHAR(P_FECHA,'MM');
  V_ANIO := TO_CHAR(P_FECHA,'YYYY');

  IF V_MES = '01' THEN
    V_RETORNO := 'Enero';
  ELSIF V_MES = '02' THEN
    V_RETORNO := 'Febrero';
  ELSIF V_MES = '03' THEN
    V_RETORNO := 'Marzo';
  ELSIF V_MES = '04' THEN
    V_RETORNO := 'Abril';
  ELSIF V_MES = '05' THEN
    V_RETORNO := 'Mayo';
  ELSIF V_MES = '06' THEN
    V_RETORNO := 'Junio';
  ELSIF V_MES = '07' THEN
    V_RETORNO := 'Julio';
  ELSIF V_MES = '08' THEN
    V_RETORNO := 'Agosto';
  ELSIF V_MES = '09' THEN
    V_RETORNO := 'Septiembre';
  ELSIF V_MES = '10' THEN
    V_RETORNO := 'Octubre';
  ELSIF V_MES = '11' THEN
    V_RETORNO := 'Noviembre';
  ELSIF V_MES = '12' THEN
    V_RETORNO := 'Diciembre';
  ELSE
    V_RETORNO := 'Mes Desconocido';
  END IF;

  RETURN V_RETORNO||' '||V_DIA||'/'||V_ANIO;

  EXCEPTION WHEN OTHERS THEN
              RETURN NULL;
END FUN_RETORNA_FECHA;

end PK_LISTADOS_CIERRE;
/
