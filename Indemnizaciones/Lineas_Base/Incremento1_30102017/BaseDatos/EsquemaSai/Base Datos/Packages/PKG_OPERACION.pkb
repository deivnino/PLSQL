CREATE OR REPLACE PACKAGE BODY admsisa.PKG_OPERACION AS

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 24/09/2012 03:36:52 p.m.
  -- FUN_ANEXO_HOGAR
  -- Purpose : Función que confirme si la póliza tiene habilitado el manejo
  -- del anexo de hogar.
  -- Modificado por:
  --
  --

  /***********************************************************************/
  FUNCTION FUN_VALOR_IVA RETURN NUMBER IS

  IVA  PRMTROS.PAR_VLOR2%TYPE;
  BEGIN
     BEGIN
      SELECT PAR_VLOR2
        INTO IVA
        FROM PRMTROS
       WHERE PAR_MDLO = '6'
         and PAR_CDGO = '4'
         AND PAR_VLOR1= '01'
         AND PAR_FCHA_CREACION = (SELECT MAX(PAR_FCHA_CREACION)
                                    FROM PRMTROS
                                   WHERE PAR_MDLO = '6'
                                     and par_cdgo = '4'
                                     and PAR_VLOR1= '01');
      RETURN(IVA);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20501,'No Se Encontro el Valor del I.V.A.');
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,'No Se Encontro el Valor del I.V.A.');
    END;

  END FUN_VALOR_IVA;

  --
  --
  --
  FUNCTION FUN_ANEXO_HOGAR(P_POLIZA PLZAS.POL_NMRO_PLZA%TYPE) RETURN VARCHAR2 IS

    V_MARCA PLZAS.POL_ASSTNCIA%TYPE;

  BEGIN
    BEGIN
      SELECT P.POL_ASSTNCIA
        INTO V_MARCA
        FROM PLZAS P
       WHERE POL_NMRO_PLZA = P_POLIZA;
      IF NVL(V_MARCA, 'X') = 'S' THEN
        RETURN('S');
      ELSE
        RETURN('N');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,
                                'Error en la consulta de la póliza..' ||
                                SQLERRM);
    END;

  END FUN_ANEXO_HOGAR;

  /**********************************************************************/
  -- Author  : Sandra Patricia Posada
  -- Created : 04/10/2012 03:36:52 p.m.
  --  FUN_DESTINO_HOGAR
  -- Purpose : Función que valida si el destino del inmueble esta permitido
  -- para hogar
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_DESTINO_HOGAR(DESTINO_INMUEBLE SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE) RETURN VARCHAR2 IS

  BEGIN

    IF DESTINO_INMUEBLE = 'V' THEN
      RETURN('S');
    ELSE
      RETURN('N');
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,
                                'Error en la validación del destino..' ||
                                SQLERRM);

  END FUN_DESTINO_HOGAR;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 05/10/2012 11:12:17 a.m.
  --  FUN_DESTINO_SOLICITUD
  -- Purpose : Función que retorna el destino de inmueble de una Solicitud
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_DESTINO_SOLICITUD(P_SOLICITUD SLCTDES_ESTDIOS.SES_NMRO%TYPE) RETURN VARCHAR2 IS

  V_DESTINO   SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE;

  BEGIN

    SELECT SES_DSTNO_INMBLE
      INTO V_DESTINO
      FROM SLCTDES_ESTDIOS,ARRNDTRIOS -- MANTIS #37877 GGM. 10/08/2015
     WHERE ARR_NMRO_SLCTUD = P_SOLICITUD
       AND ARR_SES_NMRO = SES_NMRO;
    RETURN(V_DESTINO);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501,'Error consultando el destino de la solicitud..' ||SQLERRM);

  END FUN_DESTINO_SOLICITUD;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 05/10/2012 11:12:17 a.m.
  --  FUN_DIVISION_DIRECCION
  -- Purpose : Función que retorna la división politica de la dirección de una Solicitud
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_DIVISION_DIRECCION(P_SOLICITUD SLCTDES_ESTDIOS.SES_NMRO%TYPE) RETURN NUMBER IS

  V_DIVISION   DIRECCIONES.DI_DIVPOL_CODIGO%TYPE;

  BEGIN
    SELECT D.DI_DIVPOL_CODIGO
      INTO V_DIVISION
      FROM DIRECCIONES D
     WHERE D.DI_SOLICITUD = P_SOLICITUD
       AND D.DI_TPO_DRCCION = 'R';
      RETURN(V_DIVISION);
  EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,'Error consultando la división politica de la direción del inmueble de la Solicitud..' ||SQLERRM);

  END FUN_DIVISION_DIRECCION;


  /**********************************************************************/
  -- Author  : Sandra Patricia Posada
  -- Created : 04/10/2012 03:36:52 p.m.
  --  FUN_SERVICIO_ASISTENCIA
  -- Purpose : Función que valida si la ciudad dada tiene servicio de asistencia
  -- Modificado por:
  --
  --
  /***********************************************************************/
 FUNCTION FUN_SERVICIO_ASISTENCIA(DIVISION_POLITICA  NUMBER) RETURN VARCHAR2 IS

     v_prima number;
     v_asistencia  varchar2(1):= 'N';
     V_CODIGO      DIVISION_POLITICAS.CODIGO_TRONADOR%TYPE;
     V_PRODUCTO    AMPROS_PRDCTO.APR_SUBPRODUCTO%TYPE;
     V_RAMO        AMPROS_PRDCTO.APR_RAMO%TYPE;
     V_COBERTURA   NUMBER;
     V_RAMO_SAI    AMPROS_PRDCTO.APR_RAM_CDGO%TYPE;

  BEGIN

     --CONVIERTE EL CODIGO CODAZZI A CODIGO TRONADOR.
     BEGIN
        SELECT CODIGO_TRONADOR
          INTO V_CODIGO
          FROM DIVISION_POLITICAS
         WHERE CODIGO_CODAZZI = DIVISION_POLITICA;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20501,'La ciudad no existe.');
     END;

     BEGIN
       SELECT A.APR_SUBPRODUCTO, A.APR_RAMO, A.APR_RAM_CDGO
         INTO V_PRODUCTO, V_RAMO,V_RAMO_SAI
         FROM AMPROS_PRDCTO A
        WHERE A.APR_TRFCION_EXTRNA = 'S';
     EXCEPTION
        WHEN OTHERS  THEN
          RAISE_APPLICATION_ERROR(-20501,'Error al consultar el amparo. '||' '||SQLERRM);
     END;

     BEGIN
       SELECT V.VPR_CODIGO_COBERTURA
         INTO V_COBERTURA
         FROM VLRES_PRDCTO V
        WHERE V.VPR_RAM_CDGO = V_RAMO_SAI
          AND V.VPR_CDGO     = '31';
     EXCEPTION
        WHEN OTHERS  THEN
          RAISE_APPLICATION_ERROR(-20501,'Error al consultar el amparo. '||' '||SQLERRM);
     END;

     BEGIN
        v_prima:= F223_PCC127(3,V_RAMO,V_CODIGO,V_COBERTURA,V_PRODUCTO,TO_CHAR(SYSDATE,'DD-MON-YYYY'));
        IF nvl(v_prima,0) = 0 then
          v_asistencia:= 'N';
        ELSE
          v_asistencia:= 'S';
        END IF;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v_asistencia:= 'N';
        WHEN OTHERS  THEN
          RAISE_APPLICATION_ERROR(-20501,'Error al consultar si tiene servicio de asistencia. '||' '||SQLERRM);
     END;

    RETURN(V_ASISTENCIA);

  END FUN_SERVICIO_ASISTENCIA;

  /**********************************************************************/
  -- Author  : Sandra Patricia Posada
  -- Created : 04/10/2012 03:36:52 p.m.
  --  FUN_VALIDA_HOGAR
  -- Purpose : Función que valida las tres reglas básicas de hogar.
  -- servicio de asistencia, marca de hogar y destino del inmueble.
  -- Modificado por:
  --
  --
  /***********************************************************************/
 FUNCTION FUN_VALIDA_HOGAR(POLIZA PLZAS.POL_NMRO_PLZA%TYPE,
                           CIUDAD  NUMBER,
                           DESTINO SLCTDES_ESTDIOS.SES_DSTNO_INMBLE%TYPE) RETURN VARCHAR2 IS

     V_ASISTENCIA  varchar2(1):= 'N';
     V_DESTINO     VARCHAR2(1):= 'N';
     V_HOGAR       VARCHAR2(1):= 'N';

  BEGIN

     --VERIFICA SI LA POLIZA TIENE HABILITADO EL CONVENIO DE HOGAR
     BEGIN
        V_HOGAR := FUN_ANEXO_HOGAR(POLIZA);
     EXCEPTION
        WHEN OTHERS  THEN
          RAISE_APPLICATION_ERROR(-20501,SQLERRM);
     END;

     --VERIFICA SI EL DESTINO ESTA HABILITADO PARA HOGAR
     BEGIN
        V_DESTINO := FUN_DESTINO_HOGAR(DESTINO);
     EXCEPTION
        WHEN OTHERS  THEN
          RAISE_APPLICATION_ERROR(-20501,SQLERRM);
     END;

     --VERIFICA SI LA CIUDAD TIENE SERVICIO DE ASISTENCIA
     BEGIN
        V_ASISTENCIA := FUN_SERVICIO_ASISTENCIA(CIUDAD);
     EXCEPTION
        WHEN OTHERS  THEN
          RAISE_APPLICATION_ERROR(-20501,SQLERRM);
     END;

     IF V_HOGAR = 'S' AND V_DESTINO = 'S' AND V_ASISTENCIA = 'S' THEN
       RETURN('S');
     ELSE
       RETURN('N');
     END IF;


  END FUN_VALIDA_HOGAR;

  /**********************************************************************/
  -- Author  : Sandra Patricia Posada
  -- Created : 04/10/2012 03:36:52 p.m.
  --  FUN_FACTURADO_AMPARO
  -- Purpose : Función que retorna lo que se ha cobrado por el amparo dado.
  -- Modificado por:
  --
  --
  /***********************************************************************/
 FUNCTION FUN_FACTURADO_AMPARO(P_SOLICITUD SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                              P_POLIZA PLZAS.POL_NMRO_PLZA%TYPE,
                              P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE) RETURN NUMBER IS
   V_FACTURADO                NUMBER;
  BEGIN

     --VERIFICA SI LA POLIZA TIENE HABILITADO EL CONVENIO DE HOGAR
     BEGIN
         SELECT SUM(NVL(R.AMPHOGAR,0)+ NVL(R.AMPASIS,0))
           INTO V_FACTURADO
           FROM RASEGURADOS R
          WHERE R.POLIZA    = P_POLIZA
            AND R.SOLICITUD = P_SOLICITUD;
     EXCEPTION
        WHEN OTHERS  THEN
          RAISE_APPLICATION_ERROR(-20501,SQLERRM);
     END;

     RETURN(V_FACTURADO);


  END FUN_FACTURADO_AMPARO;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:36:52 p.m.
  -- FUN_VALIDA_VALOR
  -- Purpose : Función que valida si el valor ingresado esta entre el valor mínimo y máximo de la parametrica
  -- Modificado por:
  --
  --
  /***********************************************************************/

  FUNCTION FUN_VALIDA_VALOR(P_AMPARO   AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                            P_RAMO     AMPROS_PRDCTO.APR_RAM_CDGO%TYPE,
                            P_SUCURSAL SCRSL.SUC_CDGO%TYPE,
                            P_COMPANIA SCRSL.SUC_CIA_CDGO%TYPE,
                            P_VALOR    NUMBER) RETURN VARCHAR2 IS

    EXISTE NUMBER;

  BEGIN
    BEGIN
      Select 1
        into EXISTE
        from Trfa_Ampros_Prdcto
       where tap_cdgo_ampro = P_AMPARO
         and tap_ram_cdgo = P_RAMO
         and tap_suc_cdgo = P_SUCURSAL
         and tap_cia_cdgo = P_COMPANIA
         and tap_tpo_plza = 'C'
         and P_VALOR between tap_vlor_asgrdo_mnmo and tap_vlor_asgrdo_mxmo;
      RETURN('S');
    Exception
      when no_data_found Then
        RETURN('N');
    End;

  END FUN_VALIDA_VALOR;


  /**********************************************************************/
  -- Author  :Sandra Patricia Posada C.
  -- Created : 12/03/2014
  -- FUN_VALIDA_VALOR_WEB
  -- Purpose : Función que valida si el valor ingresado esta entre el valor
  --            mínimo y máximo de la parametrica para ingresos de la web.
  -- Modificado por:
  --
  --
  /***********************************************************************/

  FUNCTION FUN_VALIDA_VALOR_WEB(P_AMPARO   AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                                P_RAMO     AMPROS_PRDCTO.APR_RAM_CDGO%TYPE,
                                P_SUCURSAL SCRSL.SUC_CDGO%TYPE,
                                P_COMPANIA SCRSL.SUC_CIA_CDGO%TYPE,
                                P_VALOR    NUMBER) RETURN VARCHAR2 IS

    EXISTE NUMBER;

  BEGIN
    BEGIN
      Select 1
        into EXISTE
        from Trfa_Ampros_Prdcto
       where tap_cdgo_ampro = P_AMPARO
         and tap_ram_cdgo = P_RAMO
         and tap_suc_cdgo = P_SUCURSAL
         and tap_cia_cdgo = P_COMPANIA
         and tap_tpo_plza = 'C'
         and P_VALOR between tap_asegurado_desdeweb and tap_asegurado_hastaweb;

      RETURN('S');
    Exception
      when no_data_found Then
        RETURN('N');
    End;

  END FUN_VALIDA_VALOR_WEB;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:36:52 p.m.
  -- FUN_VALIDA_SEGURO
  -- Purpose : Función que valida si el amparo de una solicitud esta asegurado
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_VALIDA_SEGURO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                             P_AMPARO    RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                             P_RAMO      RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
                             P_CLASE     RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE,
                             P_POLIZA    PLZAS.POL_NMRO_PLZA%TYPE)
    RETURN VARCHAR2 IS

    EXISTE NUMBER;

  BEGIN
    SELECT COUNT(8)
      INTO EXISTE
      FROM Rsgos_Vgntes_Ampro
     WHERE rva_nmro_item = P_SOLICITUD
       AND rva_cdgo_ampro = P_AMPARO
       AND rva_ram_cdgo = P_RAMO
       AND rva_nmro_plza = P_POLIZA
       AND rva_clse_plza = P_CLASE;
    IF NVL(EXISTE, 0) = 0 THEN
      RETURN('N');
    ELSE
      RETURN('S');
    END IF;

  END FUN_VALIDA_SEGURO;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:36:52 p.m.
  -- FUN_VALIDA_SEGURO
  -- Purpose : Función que valida si el amparo de una solicitud esta asegurado
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_VALIDA_SEGURO(P_SOLICITUD RSGOS_VGNTES.RVI_NMRO_ITEM%TYPE,
                             P_AMPARO    RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                             P_RAMO      RSGOS_VGNTES.RVI_RAM_CDGO%TYPE,
                             P_CLASE     RSGOS_VGNTES.RVI_CLSE_PLZA%TYPE)
    RETURN VARCHAR2 IS

    EXISTE NUMBER;

  BEGIN
    SELECT COUNT(8)
      INTO EXISTE
      FROM Rsgos_Vgntes_Ampro
     WHERE rva_nmro_item = P_SOLICITUD
       AND rva_cdgo_ampro = P_AMPARO
       AND rva_ram_cdgo = P_RAMO
       AND rva_clse_plza = P_CLASE;
    IF NVL(EXISTE, 0) = 0 THEN
      RETURN('N');
    ELSE
      RETURN('S');
    END IF;

  END FUN_VALIDA_SEGURO;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:36:52 p.m.
  -- FUN_REQUIERE_BASICO
  -- Purpose : Función que valida si un amparo requiere que el amparo básico este asegurado
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_REQUIERE_BASICO(P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE)
    RETURN VARCHAR2 IS

    BASICO AMPROS_PRDCTO.APR_REQUIERE_BASICO%TYPE;

  BEGIN
    BEGIN
      SELECT APR_REQUIERE_BASICO
        INTO BASICO
        FROM AMPROS_PRDCTO
       WHERE APR_CDGO_AMPRO = P_AMPARO;
      IF NVL(BASICO, 'X') = 'S' THEN
        RETURN('S');
      ELSE
        RETURN('N');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20010,
                                'Error al consultar el Amparo  ' || SQLERRM);
    END;

  END FUN_REQUIERE_BASICO;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:36:52 p.m.
  -- FUN_REQUIERE_AMPARO
  -- Purpose : Función que valida si un amparo requiere de otro amparo para su ingreso
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_REQUIERE_AMPARO(P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE)
    RETURN VARCHAR2 IS

    BASICO AMPROS_PRDCTO.APR_REQUIERE_AMPARO%TYPE;

  BEGIN
    BEGIN
      SELECT APR_REQUIERE_AMPARO
        INTO BASICO
        FROM AMPROS_PRDCTO
       WHERE APR_CDGO_AMPRO = P_AMPARO;
      RETURN(BASICO);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20010,
                                'Error al consultar el Amparo  ' || SQLERRM);
    END;

  END FUN_REQUIERE_AMPARO;

  /**********************************************************************/

  -- Author  : Gloria Gantiva M.
  -- Created : 27/09/2012 03:36:52 p.m.
  -- FUN_VALOR_ASEGURADO
  -- Purpose : Función que valida el mínimo valor asegurado de un concepto
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_VALOR_ASGRDO_HOGAR(P_SOLICITUD NUMBER,
                                  P_AMPARO    VARCHAR2,
                                  P_RAMO      VARCHAR2,
                                  P_CLASE     VARCHAR2,
                                  P_CONCEPTO  OUT VARCHAR)  RETURN NUMBER IS

  V_ASEGURADO  NUMBER;

BEGIN
  BEGIN
    SELECT RVL_VLOR,RVL_CNCPTO_VLOR
      INTO V_ASEGURADO,P_CONCEPTO
      FROM RSGOS_VGNTES_AVLOR
     WHERE RVL_CDGO_AMPRO  = P_AMPARO
       AND RVL_RAM_CDGO    = P_RAMO
       AND RVL_NMRO_ITEM   = P_SOLICITUD
       AND RVL_CLSE_PLZA   = P_CLASE
       AND RVL_VLOR > 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_ASEGURADO := 0;
      P_CONCEPTO  := NULL;
    WHEN OTHERS THEN
      raise_application_error(-20010,'Error al consultar el Valor Asegurado  ' ||SQLERRM);
  END;
  RETURN(V_ASEGURADO);

END FUN_VALOR_ASGRDO_HOGAR;


  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 27/09/2012 03:36:52 p.m.
  -- FUN_VALOR_CONCEPTO
  -- Purpose : Función que valida el mínimo valor asegurado de un concepto
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_VALOR_CONCEPTO(P_RAMO     VLRES_PRDCTO.VPR_RAM_CDGO%TYPE,
                              P_CONCEPTO VLRES_PRDCTO.VPR_CDGO%TYPE)
    RETURN NUMBER IS

    VALOR VLRES_PRDCTO.VPR_MINMO_VALOR%TYPE;

  BEGIN
    BEGIN
      SELECT V.VPR_MINMO_VALOR
        INTO VALOR
        FROM VLRES_PRDCTO V
       WHERE V.VPR_RAM_CDGO = P_RAMO
         AND V.VPR_CDGO = P_CONCEPTO;
      RETURN(VALOR);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20010,
                                'Error al consultar el Concepto  ' ||
                                SQLERRM);
    END;

  END FUN_VALOR_CONCEPTO;

   /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 05/10/2012 11:40:52 a.m.
  -- FUN_PERMITE_SNSTRO
  -- Purpose : Función que retorna si un amparo permite ingreso de siniestros
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_PERMITE_SNSTRO(P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE)
    RETURN VARCHAR2 IS

  PRMTE_SNSTRO AMPROS_PRDCTO.APR_PRMTE_SNSTROS%TYPE;

  BEGIN
    BEGIN
      SELECT APR_PRMTE_SNSTROS
        INTO PRMTE_SNSTRO
        FROM AMPROS_PRDCTO
       WHERE APR_CDGO_AMPRO = P_AMPARO;
      IF NVL(PRMTE_SNSTRO, 'X') = 'S' THEN
        RETURN('S');
      ELSE
        RETURN('N');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20010,'Error al consultar el Amparo  ' || SQLERRM);
    END;

  END FUN_PERMITE_SNSTRO;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 28/09/2012 03:36:52 p.m.
  -- FUN_TIPO_AMPARO
  -- Purpose : Función que devuelve el tipo de amparo
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_TIPO_AMPARO(P_AMPARO AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE,
                           P_RAMO   AMPROS_PRDCTO.APR_RAM_CDGO%TYPE) RETURN VARCHAR2 IS

  TIPO_AMPARO   AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE;

  BEGIN
    SELECT AP.APR_TPO_AMPRO
      INTO TIPO_AMPARO
      FROM AMPROS_PRDCTO AP
     WHERE AP.APR_CDGO_AMPRO = P_AMPARO
       AND AP.APR_RAM_CDGO = P_RAMO;
    RETURN(TIPO_AMPARO);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20525,'Error en la consulta del Tipo de Amparo.' ||SQLERRM);

  END FUN_TIPO_AMPARO;


  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:36:52 p.m.
  -- FUN_VALIDA_SEGURO
  -- Purpose : Función que valida si el amparo es por tarifación interna o externa
  -- Modificado por:
  --
  --
  /***********************************************************************/
  FUNCTION FUN_TRFCION_EXTERNA(P_AMPARO RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                               P_RAMO   RSGOS_VGNTES.RVI_RAM_CDGO%TYPE)
    RETURN VARCHAR2 IS

    EXISTE VARCHAR2(1);

  BEGIN
    BEGIN
      SELECT APR_TRFCION_EXTRNA
        INTO EXISTE
        FROM AMPROS_PRDCTO
       WHERE APR_CDGO_AMPRO = P_AMPARO
         AND APR_RAM_CDGO = P_RAMO;
      IF NVL(EXISTE, 'N') = 'S' THEN
        RETURN('S');
      ELSE
        RETURN('N');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,
                                'Error en la consulta del Amparo.' ||
                                SQLERRM);
    END;

  END FUN_TRFCION_EXTERNA;

  /**********************************************************************/
  -- Author  : Gonzalo Chaparro López.
  -- Created : 24/09/2013 02:13:52 p.m.
  -- FUN_TIENE_RETIRO
  -- Purpose : Función que devuelve si para una solicitud/amparo ya
  --          existe una novedad de retiro
  -- Modificado por:
  /***********************************************************************/
  FUNCTION FUN_TIENE_RETIRO (P_SOLICITUD        IN NUMBER,
                             P_TIPO_NOVEDAD     IN VARCHAR2,
                             P_AMPARO           IN VARCHAR2) RETURN VARCHAR2 IS

  V_TIENE_RETIRO        VARCHAR2(1) := NULL;
  V_EXISTE_RETIRO       NUMBER(15) := NULL;

  BEGIN
    V_EXISTE_RETIRO := 0;
    BEGIN
      SELECT COUNT(8)
        INTO V_EXISTE_RETIRO
        FROM RSGOS_RCBOS_NVDAD
       WHERE REN_NMRO_ITEM      = P_SOLICITUD
         AND REN_TPO_NVDAD      = P_TIPO_NOVEDAD
         AND REN_CDGO_AMPRO     = P_AMPARO
         AND NOT EXISTS         (SELECT *
                                   FROM RSGOS_VGNTES
                                  WHERE RVI_NMRO_ITEM = REN_NMRO_ITEM);
         --AND TO_CHAR(REN_FCHA_MDFCCION,'MMYYYY') = PERIODO Mantis 19369 no se tiene en cuenta el período.

      EXCEPTION WHEN OTHERS THEN
                  V_TIENE_RETIRO := 'S'; -- po seguridad no deje hacer la novedad.
    END;

    IF NVL(V_EXISTE_RETIRO,0) > 0 THEN -- si tiene retiro la solicitud/amparo.
      V_TIENE_RETIRO := 'S';
    ELSE
      V_TIENE_RETIRO := 'N';
    END IF;

    RETURN V_TIENE_RETIRO;
  END FUN_TIENE_RETIRO;



  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 02/10/2012 03:36:52 p.m.
  -- PRC_MESES_HOGAR
  -- Purpose : procedimiento que consulta el número de meses maximos para el anexo de hogar
  -- despúes de ingresado el amparo básico.
  --
  --
  /***********************************************************************/
  FUNCTION FUN_MESES_HOGAR(P_MODULO      IN MODULOS.MDL_CDGO%TYPE,
                           P_SUCURSAL    IN SCRSL.SUC_CDGO%TYPE,
                           P_COMPANIA    IN SCRSL.SUC_CIA_CDGO%TYPE,
                           P_VALOR       IN PRMTROS.PAR_VLOR1%TYPE) RETURN NUMBER IS

  MESES   PRMTROS.PAR_VLOR2%TYPE;

  BEGIN
    BEGIN
      SELECT PAR_VLOR2
        INTO MESES
        FROM PRMTROS
       WHERE PAR_CDGO = '2'
         AND PAR_MDLO = P_MODULO
         AND PAR_VLOR1 = P_VALOR
         AND PAR_SUC_CDGO = P_SUCURSAL
         AND PAR_SUC_CIA_CDGO = P_COMPANIA;
      RETURN(MESES);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20502,'Error consultando el parametro de # de meses hogar.'||p_modulo||' '||p_sucursal||' '||p_compania);
    END;

  END FUN_MESES_HOGAR;
  
  --
  --
  --
  FUNCTION FUN_SUMA_CONCEPTOS(P_RECIBO   NUMBER,
                              P_TIPO     VARCHAR2,
                              P_CIA      VARCHAR2,
                              P_CONCEPTO VARCHAR2,
                              EXISTE     OUT NUMBER) RETURN NUMBER IS
  
  VALOR_CONCEPTO    NUMBER;
                                
  BEGIN 
    SELECT SUM(CDR_VLOR), COUNT(9)
      INTO VALOR_CONCEPTO, EXISTE
      FROM CNCPTOS_DTLLE_RCBOS
     WHERE CDR_NMRO_RCBO = P_RECIBO
       AND CDR_TPO_RCBO = P_TIPO
       AND CDR_CDGO_CIA = P_CIA
       AND CDR_CDGO_CNCPTO LIKE '%'||P_CONCEPTO||'%';
    RETURN (VALOR_CONCEPTO);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      VALOR_CONCEPTO := 0;
      RETURN (VALOR_CONCEPTO);
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20502,'Error consultando el valor de la prima para la contabilidad '||SQLERRM);
      
  END FUN_SUMA_CONCEPTOS; 
  
  --
  --
  --
  FUNCTION FUN_PAGOS_CRTFCDOS(P_RECIBO   NUMBER,
                              P_TIPO     VARCHAR2,
                              P_CIA      VARCHAR2) RETURN VARCHAR2 IS
                              
  CURSOR C_RCBOS IS
    SELECT *
      FROM ESTADO_CTA_RCBOS
     WHERE EST_NMRO_RCBO =  P_RECIBO
       AND EST_TPO_RCBO = P_TIPO
       AND EST_CIA_CDGO = P_CIA;    
       
  R_RCBOS        C_RCBOS%ROWTYPE;                           
  VALOR_CRTFCDO  NUMBER;
  VALOR_PAGOS    NUMBER;  
  VR_RCBO_ACTUAL NUMBER;  
  V_EXISTE       VARCHAR2(1);
                          
  BEGIN
    OPEN C_RCBOS;
    LOOP
      FETCH C_RCBOS INTO R_RCBOS;
      IF C_RCBOS%NOTFOUND THEN
        EXIT;
      END IF;
      
      BEGIN
        SELECT CER_VLOR_TTAL_CRTFCDO
          INTO VALOR_CRTFCDO
          FROM CRTFCDOS
         WHERE CER_NMRO_CRTFCDO = R_RCBOS.EST_SLCTUD
           AND CER_NMRO_PLZA = R_RCBOS.EST_PLZA;  -- MANTIS # 52232 GGM 26/01/2017 
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          VALOR_CRTFCDO := 0;
      END;
      
      SELECT NVL(SUM(EST_VLOR_AFNZDO),0)
        INTO VALOR_PAGOS
        FROM ESTADO_CTA_RCBOS
       WHERE EST_SLCTUD = R_RCBOS.EST_SLCTUD
         AND EST_ESTDO_RCBO = 'I';
         
      SELECT NVL(SUM(EST_VLOR_AFNZDO),0)
        INTO VR_RCBO_ACTUAL
        FROM ESTADO_CTA_RCBOS
       WHERE EST_SLCTUD = R_RCBOS.EST_SLCTUD
         AND EST_NMRO_RCBO =  P_RECIBO
         AND EST_TPO_RCBO = P_TIPO
         AND EST_CIA_CDGO = P_CIA;
         
      IF (NVL(VALOR_PAGOS,0) + NVL(VR_RCBO_ACTUAL,0)) > VALOR_CRTFCDO THEN
        V_EXISTE := 'S';
        EXIT;
      ELSE 
        V_EXISTE := 'N';
      END IF;
         
    END LOOP;
    CLOSE C_RCBOS;
    RETURN(V_EXISTE);
  
  END FUN_PAGOS_CRTFCDOS;   
  
  --
  --
  --
  FUNCTION FUN_VALIDA_PAGO_PLZA(P_POLIZA_SIMON   NUMBER) RETURN VARCHAR2 IS
   
  V_NUM_SECU_POL   POLIZAS_SIMON.NUM_SECU_POL%TYPE;
  V_PAGO           NUMBER;
   
  BEGIN
    BEGIN
      SELECT DISTINCT NUM_SECU_POL
        INTO V_NUM_SECU_POL
        FROM POLIZAS_SIMON
       WHERE POLIZA_SIMON = P_POLIZA_SIMON;
    EXCEPTION
      WHEN OTHERS THEN  
        RAISE_APPLICATION_ERROR(-20502,'Error en la consulta del Número de la secuencia de la póliza'||SQLERRM);
    END;
        
    BEGIN
      SELECT SIM_PCK_NOVEDADES_LIBERTADOR.FUN_POLIZA_RECAUDADA(V_NUM_SECU_POL) 
        INTO V_PAGO
        FROM DUAL;
      IF V_PAGO = 0 THEN
        RETURN('S');
      ELSE
        RETURN('N');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN  
        RAISE_APPLICATION_ERROR(-20502,'Error en la consulta del Número de la secuencia de la póliza'||SQLERRM);
    END;
    
  END FUN_VALIDA_PAGO_PLZA;
  
  
  /**********************************************************************/
  -- Author  : Sandra Patricia Posada.
  -- Created : 28/09/2012 09:30 a.m.
  -- PRC__LIQUIDACION
  -- Purpose : Procedimiento que realiza la liquidación de primas del concepto
  -- y el amparo que ingresa como parámetro.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                            NOVEDAD           IN VARCHAR2) IS
    PRORRATA              NUMBER;
    DESCUENTO             NUMBER(18, 2) := 0;
    DESCUENTO_ANT         NUMBER(18, 2) := 0;
    PORC_DESCUENTO_POLIZA NUMBER := -1;

    CURSOR TASAS(AMPARO VARCHAR2) IS
      SELECT TAP_TSA_BSCA,
             TAP_TPO_TSA,
             TAP_DSCNTO_TMDOR,
             TAP_NMRO_CUOTAS,
             TAP_INCLYE_IVA
        FROM TRFA_AMPROS_PRDCTO
       WHERE TAP_CDGO_AMPRO = AMPARO
         AND TAP_RAM_CDGO = RAMO
         AND TAP_SUC_CDGO = SUCURSAL
         AND TAP_CIA_CDGO = COMPANIA
         AND TAP_TPO_PLZA = 'C';
    CURSOR TASAS_POLIZAS(AMPARO VARCHAR2) IS
      SELECT RVA_TSA_AMPRO, RVA_TPO_TSA, RVA_PRCNTJE_DSCNTO
        FROM RSGOS_VGNTES_AMPRO
       WHERE RVA_CDGO_AMPRO = AMPARO
         AND RVA_RAM_CDGO = RAMO
         AND RVA_NMRO_ITEM = 0
         AND RVA_NMRO_PLZA = POLIZA
         AND RVA_CLSE_PLZA = CLASE;

    CURSOR TASAS_RIESGO(AMPARO VARCHAR2) IS
      SELECT RVA_TSA_AMPRO, RVA_PRCNTJE_DDCBLE, RVA_TPO_TSA
        FROM RSGOS_VGNTES_AMPRO
       WHERE RVA_CDGO_AMPRO = AMPARO
         AND RVA_RAM_CDGO = RAMO
         AND RVA_NMRO_ITEM = SOLICITUD
         AND RVA_NMRO_PLZA = POLIZA
         AND RVA_CLSE_PLZA = CLASE;

    DIAS_VIGENCIA        NUMBER := 1;
    DIAS_PERIODO         NUMBER := 1;
    DEDUCIBLE            NUMBER(4, 2) := 0;
    TASA_POLIZA          NUMBER(8, 5) := 0;
    TASA_RIESGO          NUMBER(8, 5) := 0;
    TIPO_POLIZA          VARCHAR2(1);
    TIPO_RIESGO          VARCHAR2(1);
    IVA_ANT              NUMBER(4, 2) := 0;
    PRIMA                NUMBER;
    PRIMA_ANT            NUMBER;
    INCLUYE_IVA          VARCHAR2(1);
    V_TARIFACION_EXTERNA AMPROS_PRDCTO.APR_TRFCION_EXTRNA%TYPE;
    V_VALOR_ASEGURADO    NUMBER;
    V_IDENTIFICACION     PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;

  BEGIN

    -- OBTIENE SI LA TARIFCACION USA TABLAS DE SAI O LA TARIFACION LA DEVULEVE OTRO
    --- APLICATIVO. SPPC. 27/09/2012
    BEGIN
      SELECT NVL(A.APR_TRFCION_EXTRNA, 'N')
        INTO V_TARIFACION_EXTERNA
        FROM AMPROS_PRDCTO A
       WHERE A.APR_CDGO_AMPRO = AMPARO
         AND A.APR_RAM_CDGO = RAMO;
    END;

    /*******************************************************************************
    **************/
    /* ASIGNAR LA PRORRATA SEGUN LOS DIAS DEL PERIODO                    */

    /*******************************************************************************
    **************/
    PRORRATA := TRUNC(DIAS_VIGENCIA / DIAS_PERIODO, 5);
    /*******************************************************************************
    **************/
    /* HACER LIQUIDACION POR CADA UNO DE LOS AMPAROS                */
    /*******************************************************************************
    **************/
    /*******************************************************************************
    **************/
    /* BUSQUEDA DE LAS TASAS PARA CADA UNO DE LOS AMPAROS          */
    /*******************************************************************************
    **************/
    OPEN TASAS(AMPARO);
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
    OPEN TASAS_POLIZAS(AMPARO);
    FETCH TASAS_POLIZAS
      INTO TASA_POLIZA, TIPO_POLIZA, PORC_DESCUENTO_POLIZA;
    IF TASAS_POLIZAS%NOTFOUND THEN
      TASA_POLIZA := -1;
    END IF;
    CLOSE TASAS_POLIZAS;


    -- Se elimina para que funcione dejar una tasa de póliza en cero. SPPC. 27/09/2012.
   IF TASA_POLIZA != -1 THEN
     IF TASA_POLIZA != TASA THEN
       TASA := TASA_POLIZA;
     END IF;
   END IF;

    IF TIPO_POLIZA IS NOT NULL THEN
      IF TIPO_POLIZA != TIPO_TASA THEN
        TIPO_TASA := TIPO_POLIZA;
      END IF;
    END IF;

    IF PORC_DESCUENTO_POLIZA != -1 THEN
      IF PORC_DESCUENTO != PORC_DESCUENTO_POLIZA THEN
        PORC_DESCUENTO := PORC_DESCUENTO_POLIZA;
      END IF;
    END IF;

    /*******************************************************************************
    **************/
    /* BUSCAR SI LA TASA DEL RIESGO ES LA MISMA QUE LA TASA RESULTANTE DE LA
    COMPARACION CON LA  */
    /* POLIZA PARA CADA UNO DE LOS AMPAROS            */
    /*******************************************************************************
    **************/
    OPEN TASAS_RIESGO(AMPARO);
    FETCH TASAS_RIESGO
      INTO TASA_RIESGO, DEDUCIBLE, TIPO_RIESGO;
    IF TASAS_RIESGO%NOTFOUND THEN
      TASA_RIESGO := -1;
    END IF;
    CLOSE TASAS_RIESGO;

    -- Se elimina para que funcione dejar un riesgo en cero. SPPC. 27/09/2012
   IF TASA_RIESGO != -1 THEN
    IF TASA_RIESGO != TASA THEN
      IF NOVEDAD = '06' THEN
        TASA := TASA;
      ELSE
        TASA := TASA_RIESGO;
      END IF;
    END IF;
 END IF;

    IF TIPO_RIESGO IS NOT NULL THEN
      IF TIPO_RIESGO != TIPO_TASA THEN
        TIPO_TASA := TIPO_RIESGO;
      END IF;
    END IF;

    IF TIPO_TASA_P IS NOT NULL AND TASA_P IS NOT NULL THEN
      IF NOVEDAD = '06' THEN
        NULL;
      ELSE
        TIPO_TASA := TIPO_TASA_P;
        TASA      := TASA_P;
      END IF;
    END IF;

    IF IVA_ANT = 0 THEN
      IVA_ANT := IVA;
    END IF;

    /*******************************************************************************
    **************/
    /* CALCULO DE LAS PRIMAS PARA CADA UNO DE LOS AMPAROS BASICOS        */
    /*******************************************************************************
    **************/

        BEGIN
          SELECT P.POL_PRS_NMRO_IDNTFCCION
            INTO V_IDENTIFICACION
            FROM PLZAS P
           WHERE P.POL_NMRO_PLZA = POLIZA
             AND P.POL_CDGO_CLSE = CLASE
             AND P.POL_RAM_CDGO  = RAMO;
        EXCEPTION
          WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20501, SQLERRM);
        END;

    IF TIPO_TASA = 'U' THEN
      IF V_TARIFACION_EXTERNA = 'N' THEN
        PRIMA     := ((VALOR - NVL(VALOR_ANT,0)) * TASA) / 100;
        PRIMA_ANT := (NVL(VALOR_ANT,0) * TASA) / 100;
      ELSE
        IF NOVEDAD IN ('01', '05') THEN
          PRIMA_ANT := 0;
        ELSIF NOVEDAD IN ('06', '04') THEN
          BEGIN
            SELECT NVL(R.RVL_PRIMA_NETA_ANT, 0)
              INTO PRIMA_ANT
              FROM RSGOS_VGNTES_AVLOR R
             WHERE R.RVL_NMRO_ITEM = SOLICITUD
               AND R.RVL_CDGO_AMPRO = AMPARO
               AND R.RVL_CNCPTO_VLOR = CONCEPTO;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20501, SQLERRM);
          END;
        END IF;
        BEGIN
           PKG_INTERFACE_TRONADOR.PRC_VALOR_PRIMA(RAMO,
                                                 AMPARO,
                                                 V_IDENTIFICACION,
                                                 SOLICITUD,
                                                 CONCEPTO,
                                                 V_VALOR_ASEGURADO,
                                                 PRIMA);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20501, SQLERRM);
        END;
      END IF;
    ELSE
      IF V_TARIFACION_EXTERNA = 'N' THEN
        PRIMA     := ((VALOR * TASA) / 100) * PRORRATA;
        PRIMA_ANT := ((NVL(VALOR_ANT,0) * TASA) / 100) * PRORRATA;
      ELSE
        IF NOVEDAD IN ('01', '05') THEN
          PRIMA_ANT := 0;
        ELSIF NOVEDAD IN ('06', '04') THEN
          BEGIN
            SELECT NVL(R.RVL_PRIMA_NETA_ANT, 0)
              INTO PRIMA_ANT
              FROM RSGOS_VGNTES_AVLOR R
             WHERE R.RVL_NMRO_ITEM = SOLICITUD
               AND R.RVL_CDGO_AMPRO = AMPARO
               AND R.RVL_CNCPTO_VLOR = CONCEPTO;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20501, SQLERRM);
          END;
        END IF;
        BEGIN
          PKG_INTERFACE_TRONADOR.PRC_VALOR_PRIMA(RAMO,
                                                 AMPARO,
                                                 V_IDENTIFICACION,
                                                 SOLICITUD,
                                                 CONCEPTO,
                                                 V_VALOR_ASEGURADO,
                                                 PRIMA);
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20501, SQLERRM);
        END;
      END IF;
    END IF;

    DESCUENTO     := (NVL(PRIMA,0) * PORC_DESCUENTO) / 100;
    DESCUENTO_ANT := (NVL(PRIMA_ANT,0) * PORC_DESCUENTO) / 100;
    /* VERIFICAR SI LA TARIFA DEL AMPARO INCLUYE IVA O NO */

    IF INCLUYE_IVA = 'N' THEN
      PRIMA           := NVL(PRIMA,0) - NVL(DESCUENTO,0);
      PRIMA_NETA      := NVL(PRIMA,0);
      IVA_PRIMA       := (NVL(PRIMA,0) * IVA) / 100;
      PRIMA_TOTAL     := NVL(PRIMA,0) + IVA_PRIMA;
      PRIMA_ANUAL     := NVL(PRIMA,0) * 12 * PRORRATA;
      PRIMA_ANT       := NVL(PRIMA_ANT,0) - NVL(DESCUENTO_ANT,0);
      PRIMA_NETA_ANT  := NVL(PRIMA_ANT,0);
      IVA_PRIMA_ANT   := (NVL(PRIMA_ANT,0) * IVA_ANT) / 100;
      PRIMA_TOTAL_ANT := NVL(PRIMA_ANT,0) + IVA_PRIMA_ANT;
      PRIMA_ANUAL_ANT := NVL(PRIMA_ANT,0) * 12 * PRORRATA;
    ELSE
      PRIMA           := NVL(PRIMA,0) - DESCUENTO;
      PRIMA_NETA      := NVL(PRIMA,0) * (100 / (IVA + 100));
      IVA_PRIMA       := (NVL(PRIMA_NETA,0) * (IVA / 100));
      PRIMA_TOTAL     := NVL(PRIMA,0);
      PRIMA_ANUAL     := NVL(PRIMA,0) * 12 * PRORRATA;
      PRIMA_ANT       := NVL(PRIMA_ANT,0) - NVL(DESCUENTO_ANT,0);
      PRIMA_NETA_ANT  := NVL(PRIMA_ANT,0) * (100 / (IVA_ANT + 100));
      IVA_PRIMA_ANT   := (NVL(PRIMA_NETA_ANT,0) * (IVA_ANT / 100));
      PRIMA_TOTAL_ANT := NVL(PRIMA_ANT,0);
      PRIMA_ANUAL_ANT := NVL(PRIMA_ANT,0) * 12 * PRORRATA;
    END IF;

    IF TIPO_TASA = 'U' THEN
      PRIMA_ANUAL     := 0;
      PRIMA_ANUAL_ANT := 0;
    ELSIF TIPO_TASA = 'A' THEN
      PRIMA_ANUAL     := PRIMA;
      PRIMA_ANUAL_ANT := PRIMA_ANT;
    ELSIF TIPO_TASA = 'S' THEN
      PRIMA_ANUAL     := PRIMA * 2;
      PRIMA_ANUAL_ANT := PRIMA_ANT * 2;
    ELSIF TIPO_TASA = 'T' THEN
      PRIMA_ANUAL     := PRIMA * 4;
      PRIMA_ANUAL_ANT := PRIMA_ANT * 4;
    ELSIF TIPO_TASA = 'B' THEN
      PRIMA_ANUAL     := PRIMA * 6;
      PRIMA_ANUAL_ANT := PRIMA_ANT * 6;
    END IF;
  END PRC_LIQUIDACION;




  /**********************************************************************/
  -- Author  : Sandra Patricia Posada.
  -- Created : 28/09/2012 09:30 a.m.
  -- PRC__LIQUIDACION_T
  -- Purpose : Procedimiento que realiza la liquidación de primas del concepto
  -- y el amparo que ingresa como parámetro. Para tipos que no sean mensuales.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                               COMPANIA          IN VARCHAR2) IS

    PRORRATA              NUMBER;
    DESCUENTO             NUMBER(18, 2) := 0;
    DESCUENTO_ANT         NUMBER(18, 2) := 0;
    PORC_DESCUENTO_POLIZA NUMBER := -1;

    CURSOR TASAS(AMPARO VARCHAR2) IS
      SELECT TAP_TSA_BSCA,
             TAP_TPO_TSA,
             TAP_DSCNTO_TMDOR,
             TAP_NMRO_CUOTAS,
             TAP_INCLYE_IVA
        FROM TRFA_AMPROS_PRDCTO
       WHERE TAP_CDGO_AMPRO = AMPARO
         AND TAP_RAM_CDGO = RAMO
         AND TAP_SUC_CDGO = SUCURSAL
         AND TAP_CIA_CDGO = COMPANIA
         AND TAP_TPO_PLZA = 'C';
    CURSOR TASAS_POLIZAS(AMPARO VARCHAR2) IS
      SELECT RVA_TSA_AMPRO, RVA_TPO_TSA, RVA_PRCNTJE_DSCNTO
        FROM RSGOS_VGNTES_AMPRO
       WHERE RVA_NMRO_PLZA = POLIZA
         AND RVA_RAM_CDGO = RAMO
         AND RVA_CLSE_PLZA = CLASE
         AND RVA_NMRO_ITEM = 0
         AND RVA_CDGO_AMPRO = AMPARO;
    CURSOR TASAS_RIESGO(AMPARO VARCHAR2) IS
      SELECT RVA_TSA_AMPRO, RVA_PRCNTJE_DDCBLE, RVA_TPO_TSA
        FROM RSGOS_VGNTES_AMPRO
       WHERE RVA_NMRO_PLZA = POLIZA
         AND RVA_NMRO_ITEM = SOLICITUD
         AND RVA_CDGO_AMPRO = AMPARO;

    PERIODO_TASA  NUMBER(4);
    MESES         NUMBER(4);
    DIAS_VIGENCIA NUMBER := 1;
    DIAS_PERIODO  NUMBER := 1;
    DEDUCIBLE     NUMBER(4, 2) := 0;
    TASA_POLIZA   NUMBER(8, 5) := 0;
    TASA_RIESGO   NUMBER(8, 5) := 0;
    TIPO_POLIZA   VARCHAR2(1);
    TIPO_RIESGO   VARCHAR2(1);
    IVA_ANT       NUMBER(4, 2) := 0;
    FECHA         DATE;
    PRIMA         NUMBER;
    PRIMA_ANT     NUMBER;
    INCLUYE_IVA   VARCHAR2(1);
  BEGIN
    /*******************************************************************************
    **************/
    /* ASIGNAR LA PRORRATA SEGUN LOS DIAS DEL PERIODO                    */

    /*******************************************************************************
    **************/
    PRORRATA := TRUNC(DIAS_VIGENCIA / DIAS_PERIODO, 5);
    /*******************************************************************************
    **************/
    /* HACER LIQUIDACION POR CADA UNO DE LOS AMPAROS                */
    /*******************************************************************************
    **************/
    /*******************************************************************************
    **************/
    /* BUSQUEDA DE LAS TASAS PARA CADA UNO DE LOS AMPAROS          */
    /*******************************************************************************
    **************/
    OPEN TASAS(AMPARO);
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
    OPEN TASAS_POLIZAS(AMPARO);
    FETCH TASAS_POLIZAS
      INTO TASA_POLIZA, TIPO_POLIZA, PORC_DESCUENTO_POLIZA;
    IF TASAS_POLIZAS%NOTFOUND THEN
      TASA_POLIZA := -1;
    END IF;
    CLOSE TASAS_POLIZAS;

    IF TASA_POLIZA != -1 THEN
      IF TASA_POLIZA != TASA THEN
        TASA := TASA_POLIZA;
      END IF;
    END IF;
    IF TIPO_POLIZA IS NOT NULL THEN
      IF TIPO_POLIZA != TIPO_TASA THEN
        TIPO_TASA := TIPO_POLIZA;
      END IF;
    END IF;

    IF PORC_DESCUENTO_POLIZA != -1 THEN
      IF PORC_DESCUENTO != PORC_DESCUENTO_POLIZA THEN
        PORC_DESCUENTO := PORC_DESCUENTO_POLIZA;
      END IF;
    END IF;

    /*******************************************************************************
    **************/
    /* BUSCAR SI LA TASA DEL RIESGO ES LA MISMA QUE LA TASA RESULTANTE DE LA
    COMPARACION CON LA  */
    /* POLIZA PARA CADA UNO DE LOS AMPAROS            */
    /*******************************************************************************
    **************/
    OPEN TASAS_RIESGO(AMPARO);
    FETCH TASAS_RIESGO
      INTO TASA_RIESGO, DEDUCIBLE, TIPO_RIESGO;
    IF TASAS_RIESGO%NOTFOUND THEN
      TASA_RIESGO := -1;
    END IF;
    CLOSE TASAS_RIESGO;

    IF TASA_RIESGO != -1 THEN
      IF TASA_RIESGO != TASA THEN
        TASA := TASA_RIESGO;
      END IF;
    END IF;

    IF TIPO_RIESGO IS NOT NULL THEN
      IF TIPO_RIESGO != TIPO_TASA THEN
        TIPO_TASA := TIPO_RIESGO;
      END IF;
    END IF;

    IF TIPO_TASA_P IS NOT NULL AND TASA_P IS NOT NULL THEN
      TIPO_TASA := TIPO_TASA_P;
      TASA      := TASA_P;
    END IF;

    IF IVA_ANT = 0 THEN
      IVA_ANT := IVA;
    END IF;

    /*******************************************************************************
    **************/
    /* CALCULO DE LAS PRIMAS PARA CADA UNO DE LOS AMPAROS BASICOS        */
    /*******************************************************************************
    **************/
    IF TIPO_TASA = 'U' THEN
      PRIMA     := (VALOR * TASA) / 100;
      PRIMA_ANT := (VALOR_ANT * TASA) / 100;
    ELSE
      PRIMA     := ((VALOR * TASA) / 100) * PRORRATA;
      PRIMA_ANT := ((VALOR_ANT * TASA) / 100) * PRORRATA;
    END IF;
    DESCUENTO     := (PRIMA * PORC_DESCUENTO) / 100;
    DESCUENTO_ANT := (PRIMA_ANT * PORC_DESCUENTO) / 100;
    /* VERIFICAR SI LA TARIFA DEL AMPARO INCLUYE IVA O NO */

    IF INCLUYE_IVA = 'N' THEN
      PRIMA           := PRIMA - DESCUENTO;
      PRIMA_NETA      := PRIMA;
      IVA_PRIMA       := (PRIMA * IVA) / 100;
      PRIMA_TOTAL     := PRIMA + IVA_PRIMA;
      PRIMA_ANUAL     := PRIMA * 12 * PRORRATA;
      PRIMA_ANT       := PRIMA_ANT - DESCUENTO_ANT;
      PRIMA_NETA_ANT  := PRIMA_ANT;
      IVA_PRIMA_ANT   := (PRIMA_ANT * IVA_ANT) / 100;
      PRIMA_TOTAL_ANT := PRIMA_ANT + IVA_PRIMA_ANT;
      PRIMA_ANUAL_ANT := PRIMA_ANT * 12 * PRORRATA;
    ELSE
      PRIMA           := PRIMA - DESCUENTO;
      PRIMA_NETA      := PRIMA * (100 / (IVA + 100));
      IVA_PRIMA       := (PRIMA_NETA * (IVA / 100));
      PRIMA_TOTAL     := PRIMA;
      PRIMA_ANUAL     := PRIMA * 12 * PRORRATA;
      PRIMA_ANT       := PRIMA_ANT - DESCUENTO_ANT;
      PRIMA_NETA_ANT  := PRIMA_ANT * (100 / (IVA_ANT + 100));
      IVA_PRIMA_ANT   := (PRIMA_NETA_ANT * (IVA_ANT / 100));
      PRIMA_TOTAL_ANT := PRIMA_ANT;
      PRIMA_ANUAL_ANT := PRIMA_ANT * 12 * PRORRATA;
    END IF;

    IF TIPO_TASA = 'U' THEN
      PRIMA_ANUAL     := 0;
      PRIMA_ANUAL_ANT := 0;
      PERIODO_TASA    := 1;
    ELSIF TIPO_TASA = 'A' THEN
      PRIMA_ANUAL     := PRIMA;
      PRIMA_ANUAL_ANT := PRIMA_ANT;
      PERIODO_TASA    := 12;
    ELSIF TIPO_TASA = 'S' THEN
      PRIMA_ANUAL     := PRIMA * 2;
      PRIMA_ANUAL_ANT := PRIMA_ANT * 2;
      PERIODO_TASA    := 6;
    ELSIF TIPO_TASA = 'T' THEN
      PRIMA_ANUAL     := PRIMA * 4;
      PRIMA_ANUAL_ANT := PRIMA_ANT * 4;
      PERIODO_TASA    := 3;
    ELSIF TIPO_TASA = 'B' THEN
      PRIMA_ANUAL     := PRIMA * 6;
      PRIMA_ANUAL_ANT := PRIMA_ANT * 6;
      PERIODO_TASA    := 2;
    END IF;

    IF NOVEDAD = '02' THEN
      BEGIN
        SELECT MAX(RIVN_FCHA_NVDAD)
          INTO FECHA
          FROM RSGOS_VGNTES_NVDDES
         WHERE RIVN_NMRO_ITEM = SOLICITUD
           AND RIVN_NMRO_PLZA = POLIZA
           AND RIVN_CLSE_PLZA = CLASE
           AND RIVN_RAM_CDGO = RAMO
           AND RIVN_CDGO_AMPRO = '01'
           AND RIVN_TPO_NVDAD = '14'; 
        MESES           := MONTHS_BETWEEN(FECHA, FECHA_LIQUIDACION);
        PRIMA_NETA_ANT  := NVL(PRIMA_NETA_ANT,0) * MESES / PERIODO_TASA;
        PRIMA_NETA      := NVL(PRIMA_NETA,0) * MESES / PERIODO_TASA;
        IVA_PRIMA_ANT   := NVL(IVA_PRIMA_ANT,0) * MESES / PERIODO_TASA;
        PRIMA_TOTAL_ANT := NVL(PRIMA_ANT,0);
        PRIMA_TOTAL     := NVL(PRIMA,0);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          MENSAJE := 'No se encontro el cobro anticipado de la prima.';
          ROLLBACK;
          RETURN;
      END;
    END IF;

  END PRC_LIQUIDACION_T;


  /**********************************************************************/
  -- Author  : Sandra Patricia Posada.
  -- Created : 28/09/2012 09:30 a.m.
  -- PRC_DEV_PRIMAS
  -- Purpose : Procedimiento que realiza la devolución de primas de
  -- de un amparo dado.
  -- Modificado por:
  --
  --
  /***********************************************************************/

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
                                       TARIFACION    IN AMPROS_PRDCTO.APR_TRFCION_EXTRNA%TYPE) Is

  CERTIFICADO NUMBER;
  incluye     varchar2(1);
  PRIMA_NETA  NUMBER(18, 2);
  PRIMA_TOTAL NUMBER(18, 2);
  IVA_PRIMA   NUMBER(18, 2);
  IVA         NUMBER;
  --FECHA       DATE;
  MENSAJE2    VARCHAR2(100);
  V_AMPARO    AMPROS_PRDCTO.APR_CDGO_AMPRO%TYPE;
  V_ASEGURADO VARCHAR2(1);
  V_FACTURADO NUMBER;

Begin

  -- VALIDA SI VAN A DEVOLVER PRIMAS DEL AMPARO DE HOGAR. SPPC. 04/10/2012.
    IF TARIFACION = 'S' THEN

      BEGIN
        SELECT 'S', A.APR_CDGO_AMPRO
          INTO V_ASEGURADO, V_AMPARO
          FROM RSGOS_VGNTES_AMPRO R, AMPROS_PRDCTO A
         WHERE R.RVA_NMRO_ITEM = SOLICITUD
           AND R.RVA_CDGO_AMPRO = A.APR_CDGO_AMPRO
           AND A.APR_TRFCION_EXTRNA = 'S';
       mensaje:= 'El amparo de Hogar no se encuentra retirado. No se pueden devolver primas.';
       return;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          V_ASEGURADO := 'N';
        WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20501,SQLERRM);
      END;

    END IF;

  -- LIQUIDAR LA DEVOLUCION SEGUN SI INCLUYE IVA O NO LA TARIFA DEL AMPARO

  Begin
    Select TAP_INCLYE_IVA
      into incluye
      from TRFA_AMPROS_PRDCTO
     where TAP_CDGO_AMPRO = AMPARO
       and TAP_RAM_CDGO = RAMO
       and TAP_SUC_CDGO = SUCURSAL
       and TAP_CIA_CDGO = COMPANIA
       and TAP_TPO_PLZA = 'C';
  Exception
    When no_data_found then
      mensaje := 'No se puede conocer si la tarifa del amparo incluye iva o no.';
      return;
  End;

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
      MENSAJE := 'ERROR EN LA BUSQUEDA DEL IVA';
      ROLLBACK;
      RETURN;
    WHEN OTHERS THEN
      MENSAJE := 'ERROR EN LA BUSQUEDA DEL IVA';
      ROLLBACK;
      RETURN;
  END;

  IF INCLUYE = 'N' THEN
    PRIMA_NETA  := DEVOLUCION;
    IVA_PRIMA   := (DEVOLUCION * IVA) / 100;
    PRIMA_TOTAL := DEVOLUCION + IVA_PRIMA;
  ELSE
    PRIMA_NETA  := DEVOLUCION * (100 / (100 + IVA));
    IVA_PRIMA   := PRIMA_NETA * (IVA / 100);
    PRIMA_TOTAL := DEVOLUCION;
  END IF;

  -- COMPARA SI LO DEVUELTO NO SEA MAYOR A LO FACTURADO. SPPC. 04/10/2012.
  IF TARIFACION = 'S' THEN
    IF V_ASEGURADO = 'N' THEN
      V_FACTURADO := PKG_OPERACION.FUN_FACTURADO_AMPARO(SOLICITUD,
                                                        POLIZA,
                                                        V_AMPARO);
      V_FACTURADO :=  V_FACTURADO * (100 / (100 + IVA));
      IF PRIMA_NETA > V_FACTURADO THEN
        mensaje:= 'El valor a devolver es mayor al valor facturado por el anexo.';
        return;
      END IF;
    END IF;
  END IF;

  BUSCAR_CERTIFICADO(POLIZA, CLASE_POLIZA, RAMO, CERTIFICADO);

  Update Crtfcdos
     set cer_vlor_prma_nta  = cer_vlor_prma_nta - PRIMA_NETA,
         cer_vlor_prma_ttal = cer_vlor_prma_ttal - PRIMA_TOTAL,
         cer_vlor_iva       = cer_vlor_iva - IVA_PRIMA
   where cer_nmro_crtfcdo = CERTIFICADO
     and cer_nmro_plza = POLIZA
     and cer_clse_plza = CLASE_POLIZA
     and cer_ram_cdgo = RAMO;
  If sql%notfound Then
    MENSAJE := 'ERROR ACTUALIZACION DE LA DEVOLUCION';
    return;
  End If;

  /* INSERTA LA NOVEDAD DE DEVOLUCION DE PRIMAS*/
  Begin
    insert into Rsgos_Vgntes_Nvddes
      (rivn_fcha_nvdad,
       rivn_cdgo_ampro,
       rivn_ram_cdgo,
       rivn_nmro_item,
       rivn_nmro_plza,
       rivn_clse_plza,
       rivn_tpo_nvdad,
       rivn_vlor_dfrncia,
       rivn_fcha_mdfccion,
       rivn_usrio)
    values
      (FECHA_NOVEDAD,
       amparo,
       ramo,
       solicitud,
       poliza,
       clase_poliza,
       NOVEDAD,
       PRIMA_NETA,
       FECHA_NOVEDAD,
       usuario);
    If sql%notfound Then
      mensaje := 'ERROR INSERTANDO NOVEDADES';
      return;
    End If;
  EXCEPTION
    WHEN OTHERS THEN
      insert into Nvddes
        (rivn_fcha_nvdad,
         rivn_cdgo_ampro,
         rivn_ram_cdgo,
         rivn_nmro_item,
         rivn_nmro_plza,
         rivn_clse_plza,
         rivn_tpo_nvdad,
         rivn_vlor_dfrncia,
         rivn_fcha_mdfccion,
         rivn_usrio,
         rivn_nmro_crtfcdo)
      values
        (FECHA_NOVEDAD,
         amparo,
         ramo,
         solicitud,
         poliza,
         clase_poliza,
         NOVEDAD,
         PRIMA_NETA,
         FECHA_NOVEDAD,
         usuario,
         CERTIFICADO);
      If sql%notfound Then
        mensaje := 'ERROR INSERTANDO NOVEDADES';
        return;
      End If;
  End;
  BEGIN
    INSERTAR_AUDITORIA('CRTFCDOS',
                       TO_CHAR(CERTIFICADO),
                       TO_CHAR(POLIZA),
                       CLASE_POLIZA,
                       RAMO,
                       TO_CHAR(SOLICITUD),
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       'VLOR_PRMA_NTA',
                       TO_CHAR(0),
                       TO_CHAR(DEVOLUCION),
                       MODULO,
                       USUARIO,
                       SYSDATE,
                       'POR SOLICITUD: ' || TO_CHAR(SOLICITUD) || ' ' ||
                       RAZON,
                       MENSAJE2);
    if mensaje2 is not null then
      mensaje := mensaje2;
      return;
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      mensaje := 'Error insertando en la tabla de auditoria.';
      return;
  END;
End;


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
                                    RAZON         VARCHAR2) Is
      CERTIFICADO NUMBER;
      incluye     varchar2(1);
      PRIMA_NETA  NUMBER(18, 2);
      PRIMA_TOTAL NUMBER(18, 2);
      IVA_PRIMA   NUMBER(18, 2);
      IVA         NUMBER;
      --FECHA       DATE;
      MENSAJE2    VARCHAR2(100);
    Begin

      -- LIQUIDAR LA DEVOLUCION SEGUN SI INCLUYE IVA O NO LA TARIFA DEL AMPARO

      Begin
        Select TAP_INCLYE_IVA
          into incluye
          from TRFA_AMPROS_PRDCTO
         where TAP_CDGO_AMPRO = AMPARO
           and TAP_RAM_CDGO = RAMO
           and TAP_SUC_CDGO = SUCURSAL
           and TAP_CIA_CDGO = COMPANIA
           and TAP_TPO_PLZA = 'C';
      Exception
        When no_data_found then
          mensaje := 'No se puede conocer si la tarifa del amparo incluye iva o no.';
      End;

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
          MENSAJE := 'ERROR EN LA BUSQUEDA DEL IVA';
          ROLLBACK;
          RETURN;
        WHEN OTHERS THEN
          MENSAJE := 'ERROR EN LA BUSQUEDA DEL IVA';
          ROLLBACK;
          RETURN;
      END;

      IF INCLUYE = 'N' THEN
        PRIMA_NETA  := DEVOLUCION;
        IVA_PRIMA   := (DEVOLUCION * IVA) / 100;
        PRIMA_TOTAL := DEVOLUCION + IVA_PRIMA;
      ELSE
        PRIMA_NETA  := DEVOLUCION * (100 / (100 + IVA));
        IVA_PRIMA   := PRIMA_NETA * (IVA / 100);
        PRIMA_TOTAL := DEVOLUCION;
      END IF;

      BUSCAR_CERTIFICADO(POLIZA, CLASE_POLIZA, RAMO, CERTIFICADO);

      Update Crtfcdos
         set cer_vlor_prma_nta  = cer_vlor_prma_nta - PRIMA_NETA,
             cer_vlor_prma_ttal = cer_vlor_prma_ttal - PRIMA_TOTAL,
             cer_vlor_iva       = cer_vlor_iva - IVA_PRIMA
       where cer_nmro_crtfcdo = CERTIFICADO
         and cer_nmro_plza = POLIZA
         and cer_clse_plza = CLASE_POLIZA
         and cer_ram_cdgo = RAMO;
      If sql%notfound Then
        MENSAJE := 'ERROR ACTUALIZACION DE LA DEVOLUCION';
        return;
      End If;

      /* INSERTA LA NOVEDAD DE DEVOLUCION DE PRIMAS*/
      Begin
        insert into Nvddes
          (rivn_fcha_nvdad,
           rivn_cdgo_ampro,
           rivn_ram_cdgo,
           rivn_nmro_item,
           rivn_nmro_plza,
           rivn_clse_plza,
           rivn_tpo_nvdad,
           rivn_vlor_dfrncia,
           rivn_fcha_mdfccion,
           rivn_usrio,
           rivn_nmro_crtfcdo)
        values
          (FECHA_NOVEDAD,
           amparo,
           ramo,
           1,
           poliza,
           clase_poliza,
           NOVEDAD,
           PRIMA_NETA,
           FECHA_NOVEDAD,
           usuario,
           CERTIFICADO);
        If sql%notfound Then
          mensaje := 'ERROR INSERTANDO NOVEDADES';
          return;
        End If;
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE := 'ERROR NO INSERTO NOVEDADES';
          return;
      End;
      BEGIN
        INSERTAR_AUDITORIA('CRTFCDOS',
                           TO_CHAR(CERTIFICADO),
                           TO_CHAR(POLIZA),
                           CLASE_POLIZA,
                           RAMO,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           'VLOR_PRMA_NTA',
                           TO_CHAR(0),
                           TO_CHAR(DEVOLUCION),
                           MODULO,
                           USUARIO,
                           SYSDATE,
                           'POR SOLICITUD: ' || TO_CHAR(1) || ' ' || RAZON,
                           MENSAJE2);
        if mensaje2 is not null then
          mensaje := mensaje2;
          return;
        end if;
      EXCEPTION
        WHEN OTHERS THEN
          mensaje := 'Error insertando en la tabla de auditoria.';
          return;
      END;
    End;

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
                              TARIFACION     AMPROS_PRDCTO.APR_TRFCION_EXTRNA%TYPE) IS
  MENSAJE     VARCHAR2(2000);
  BEGIN
    PRC_DEV_PRIMAS(P_SOLICITUD,P_POLIZA,P_SUCURSAL,P_COMPANIA,P_FECHA_NVDAD,P_CLASE,
               P_RAMO,P_DVLCION,MENSAJE,P_USUARIO,P_NOVEDAD_DEV,P_AMPARO,P_MODULO,
               P_RAZON,TARIFACION);
    IF MENSAJE IS NOT NULL THEN
      MENSAJE_D := MENSAJE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      MENSAJE_D := 'NO SE PUDO REALIZAR LA DEVOLUCIÓN DE PRIMAS. CONSULTE AL ADMINISTRADOR DEL SISTEMA.  '|| SQLERRM;
  END PRC_DEVOLUCION_PRIMAS;


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
                                     MENSAJE_D      OUT VARCHAR2) IS
  MENSAJE     VARCHAR2(2000);
  FECHA       DATE;
  BEGIN
    FECHA := PKG_NOVEDADES_WEB.TRAER_FECHA(P_POLIZA,P_RAMO,P_CLASE,P_NOVEDADES,MENSAJE);
    PRC_DEV_PRIMAS_POLIZA(P_POLIZA,P_SUCURSAL,P_COMPANIA,FECHA,P_CLASE,P_RAMO,P_DVLCION_POL,MENSAJE,
                      P_USUARIO,P_NVDAD_DEV,'01',P_MODULO,P_RAZON);
    IF MENSAJE IS NOT NULL THEN
      MENSAJE_D  := MENSAJE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      MENSAJE_D  := 'NO SE PUDO REALIZAR LA DEVOLUCIÓN DE PRIMAS. CONSULTE AL ADMINISTRADOR DEL SISTEMA. '||SQLERRM;
  END PRC_DEVOLUCION_PRIMAS_POLIZA;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 24/09/2012 03:33:30 p.m.
  -- PRC_RETIRO
  -- Purpose : Procedimiento que realice el retiro de un o los amparos.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                              P_DVSION_POLITICA  NUMBER) IS

    NOVEDAD_RETIRO VARCHAR2(6) := '02';
    RECHAZO        VARCHAR2(3);
    DESCRIPCION    VARCHAR2(1000);
    V_MENSAJE      VARCHAR2(2000) := NULL;
    MENSAJE_SUS    VARCHAR2(2000) := NULL;
    FECHA          DATE;
    CERTIFICADO    NUMBER(10);
    CADENA         VARCHAR2(30) := NULL;
    ENTRO          NUMBER;
    TIPO           VARCHAR2(1);
    V_CONCEPTO     VARCHAR2(4);
    V_VALOR        NUMBER(18, 2);
    JURIDICO       NUMBER(2);
    SOL            NUMBER;
    AMPARO         VARCHAR2(2);
    TIPO_A         VARCHAR2(2);
    MENSAJE_INF    VARCHAR2(2000) := NULL;
    MENSAJE_D      VARCHAR2(1000) := NULL;
    CODIGO_MODULO  VARCHAR2(2) := '2';
    GLOBAL_PERIODO VARCHAR2(6) := TO_CHAR(P_FECHA_NOVEDAD, 'MMYYYY');

    CURSOR AMPAROS IS
      SELECT APR_CDGO_AMPRO, APR_TPO_AMPRO
        FROM AMPROS_PRDCTO, RSGOS_VGNTES_AMPRO
       WHERE APR_RAM_CDGO = P_RAMO
         AND APR_CDGO_AMPRO = RVA_CDGO_AMPRO
         AND APR_RAM_CDGO = RVA_RAM_CDGO
         AND RVA_NMRO_ITEM = P_SOLICITUD;

    CURSOR VALORES(V_AMPARO VARCHAR2) IS
      SELECT RVL_CNCPTO_VLOR, RVL_VLOR
        FROM RSGOS_VGNTES_AVLOR, VLRES_PRDCTO
       WHERE RVL_CDGO_AMPRO = V_AMPARO
         AND RVL_NMRO_ITEM = P_SOLICITUD
         AND RVL_NMRO_PLZA = P_POLIZA
         AND RVL_CLSE_PLZA = P_CLASE
         AND RVL_RAM_CDGO = P_RAMO
         AND VPR_RAM_CDGO = RVL_RAM_CDGO
         AND RVL_CNCPTO_VLOR = VPR_CDGO
       ORDER BY RVL_CNCPTO_VLOR;

  BEGIN
    Juridico := NOVEDAD_JURIDICO_AMPARO(P_SOLICITUD, P_RAMO, P_AMPARO);
    IF Juridico = 1 Then
      IF FUN_TRFCION_EXTERNA(P_AMPARO, P_RAMO) = 'S' THEN
        P_MENSAJE := 'La solicitud se encuentra siniestrada.';
      ELSE
        P_MENSAJE_INF := 'La solicitud se encuentra siniestrada.';
      END IF;
    END IF;

    IF P_AMPARO = '01' THEN
      OPEN AMPAROS;
      LOOP
        FETCH AMPAROS
          INTO AMPARO, TIPO_A;
        IF AMPAROS%NOTFOUND THEN
          EXIT;
        END IF;
        
        OPEN VALORES(AMPARO);
        ENTRO := 0;
        LOOP
          FETCH VALORES
            INTO V_CONCEPTO, V_VALOR;
          IF VALORES%NOTFOUND THEN
            EXIT;
          ELSE
            IF ENTRO = 0 THEN
              BEGIN
                PRC_VALIDA_MANUAL('N',
                                  NOVEDAD_RETIRO,
                                  P_SOLICITUD,
                                  P_POLIZA,
                                  P_CLASE,
                                  P_RAMO,
                                  AMPARO,
                                  P_FECHA_NOVEDAD,
                                  CERTIFICADO,
                                  V_CONCEPTO,
                                  V_VALOR,
                                  P_COMPANIA,
                                  P_SUCURSAL,
                                  TIPO_A,
                                  RECHAZO,
                                  V_MENSAJE,
                                  CODIGO_MODULO,
                                  P_CODIGO_USUARIO,
                                  MENSAJE_INF,
                                  TTAL_ASGRDO,
                                  P_NOVEDAD_WEB,
                                  P_DESTINO_INMUEBLE,
                                  P_DVSION_POLITICA,'S',NULL,NULL);
                IF V_MENSAJE IS NOT NULL THEN
                  P_MENSAJE := V_MENSAJE;
                END IF;
              EXCEPTION
                WHEN others THEN
                  P_MENSAJE := 'ERROR EN VALIDA_MANUAL...' || SQLERRM;
              END;
            END IF;
            IF RECHAZO IS NOT NULL THEN
              BEGIN
                SELECT RCN_TPO_CDGO, RCN_DSCRPCION
                  INTO TIPO, DESCRIPCION
                  FROM RCHZOS_NVDDES
                 WHERE RCN_CDGO = RECHAZO
                   AND RCN_RAM_CDGO = P_RAMO;
              EXCEPTION
                WHEN no_data_found THEN
                  P_MENSAJE := 'El código de rechazo de la novedad no existe. Consulte con El Libertador ';
              END;
              IF TIPO = 'E' THEN
                P_MENSAJE := 'No se puede realizar el retiro al seguro. ' ||
                             DESCRIPCION;
              END IF;
              IF MENSAJE_INF IS NOT NULL THEN
                P_MENSAJE_INF := MENSAJE_INF;
              END IF;
              BUSCAR_CERTIFICADO(P_POLIZA, P_CLASE, P_RAMO, CERTIFICADO);
              IF CERTIFICADO IS NULL THEN
                P_MENSAJE := 'Error: No se pudo encontrar el certificado respectivo de la póliza. Consulte al administrador del sistema.';
                EXIT;
              END IF;
              INSERTA_RECHAZO(CERTIFICADO,
                              P_POLIZA,
                              P_CLASE,
                              P_RAMO,
                              RECHAZO,
                              0,
                              '0',
                              P_SOLICITUD,
                              P_CODIGO_USUARIO,
                              V_MENSAJE);
              IF V_MENSAJE IS NOT NULL THEN
                P_MENSAJE := 'Error: No se pudo registrar el rechazo de la Novedad. Consulte al Administrador del Sistema.';
                EXIT;
              END IF;

              IF TIPO != 'E' THEN
                V_MENSAJE := NULL;
                FECHA     := TRUNC(P_FECHA_NOVEDAD) +
                             (SYSDATE - TRUNC(SYSDATE));
                PRC_NOVEDADES(P_SOLICITUD,
                              P_POLIZA,
                              P_CLASE,
                              P_RAMO,
                              P_SUCURSAL,
                              P_COMPANIA,
                              FECHA,
                              AMPARO,
                              V_CONCEPTO,
                              V_VALOR,
                              CERTIFICADO,
                              0,
                              NOVEDAD_RETIRO,
                              ENTRO,
                              CODIGO_MODULO,
                              V_MENSAJE,
                              P_CODIGO_USUARIO,
                              'NO',
                              'SI',
                              GLOBAL_PERIODO,
                              NULL,
                              NULL,
                              P_NOVEDAD_WEB);
                IF ENTRO = 0 THEN
                  insertar_auditoria('RSGOS_VGNTES_NVDDES',
                                     to_char(sysdate),
                                     AMPARO,
                                     P_RAMO,
                                     TO_CHAR(P_SOLICITUD),
                                     TO_CHAR(P_POLIZA),
                                     '02',
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     'RIVN_VLOR_DFRNCIA',
                                     TO_CHAR(V_VALOR),
                                     TO_CHAR(0),
                                     CODIGO_MODULO,
                                     P_CODIGO_USUARIO,
                                     SYSDATE,
                                     'Pasa el límite permitido',
                                     V_MENSAJE);
                END IF;
                ENTRO   := 1;
                RECHAZO := NULL;
              ELSE
                EXIT;
              END IF;
            ELSE
              BEGIN
                FECHA := TRUNC(P_FECHA_NOVEDAD) +
                         (SYSDATE - TRUNC(SYSDATE));
                PRC_NOVEDADES(P_SOLICITUD,
                              P_POLIZA,
                              P_CLASE,
                              P_RAMO,
                              P_SUCURSAL,
                              P_COMPANIA,
                              FECHA,
                              AMPARO,
                              V_CONCEPTO,
                              V_VALOR,
                              CERTIFICADO,
                              0,
                              NOVEDAD_RETIRO,
                              ENTRO,
                              CODIGO_MODULO,
                              V_MENSAJE,
                              P_CODIGO_USUARIO,
                              'NO',
                              'SI',
                              GLOBAL_PERIODO,
                              NULL,
                              NULL,
                              P_NOVEDAD_WEB);
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := V_MENSAJE || SQLERRM;
              END;
              IF V_MENSAJE IS NOT NULL THEN
                P_MENSAJE := V_MENSAJE;
                EXIT;
              END IF;
            END IF;
          END IF;
        END LOOP;
        CLOSE VALORES;

        PRC_DEVOLUCION(P_SOLICITUD,
                       P_POLIZA,
                       P_RAMO,
                       P_CLASE,
                       AMPARO,
                       GLOBAL_PERIODO,
                       CERTIFICADO,
                       MENSAJE_D);
        IF MENSAJE_D IS NOT NULL THEN
          P_MENSAJE := MENSAJE_D;
        END IF;
      END LOOP;
      CLOSE AMPAROS;
      IF V_MENSAJE IS NULL THEN
        BEGIN
          PRC_SUSPENSION(P_RAMO,
                         P_SOLICITUD,
                         P_AMPARO,
                         CODIGO_MODULO,
                         P_CODIGO_USUARIO,
                         CADENA,
                         MENSAJE_SUS);
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := MENSAJE_SUS;
        END;
      END IF;
    ELSE
      /* HACE EL RETIRO PARA EL AMPARO DIFERENTE AL BASICO Y SERVICIOS PUBLICOS*/
      SOL := 0;
      BUSCAR_CERTIFICADO(P_POLIZA, P_CLASE, P_RAMO, CERTIFICADO);
      IF CERTIFICADO IS NULL THEN
        P_MENSAJE := 'Error: No se pudo encontrar el certificado respectivo de la póliza. Consulte al administrador del sistema.';
      END IF;
      IF P_AMPARO IN ('02', '03', '04') THEN
        BEGIN
          SELECT RVA_NMRO_ITEM
            INTO SOL
            FROM RSGOS_VGNTES_AMPRO
           WHERE RVA_CDGO_AMPRO = '05'
             AND RVA_RAM_CDGO = P_RAMO
             AND RVA_NMRO_ITEM = P_SOLICITUD
             AND RVA_NMRO_PLZA = P_POLIZA
             AND RVA_CLSE_PLZA = P_CLASE;
          P_MENSAJE := 'No se puede retirar el amparo porque tiene amparo de Daños y Faltantes. Debe ser retirado primero Daños.';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            SOL := 0;
          WHEN OTHERS THEN
            P_MENSAJE := 'Error consultando el amparo de Daños y Faltantes.';
        END;
      END IF;
      IF SOL = 0 THEN
        ENTRO := 0;
        IF FUN_VALIDA_SEGURO(P_SOLICITUD,
                             P_AMPARO,
                             P_RAMO,
                             P_CLASE,
                             P_POLIZA) = 'N' THEN
          P_MENSAJE := 'El amparo no se encuentra asegurado.';
        END IF;
        OPEN VALORES(P_AMPARO);
        LOOP
          FETCH VALORES
            INTO V_CONCEPTO, V_VALOR;
          IF VALORES%NOTFOUND THEN
            EXIT;
          END IF;

          IF ENTRO = 0 THEN
            PRC_VALIDA_MANUAL('N',
                              NOVEDAD_RETIRO,
                              P_SOLICITUD,
                              P_POLIZA,
                              P_CLASE,
                              P_RAMO,
                              P_AMPARO,
                              P_FECHA_NOVEDAD,
                              CERTIFICADO,
                              V_CONCEPTO,
                              V_VALOR,
                              P_COMPANIA,
                              P_SUCURSAL,
                              TIPO_A,
                              RECHAZO,
                              V_MENSAJE,
                              CODIGO_MODULO,
                              P_CODIGO_USUARIO,
                              MENSAJE_INF,
                              TTAL_ASGRDO,
                              P_NOVEDAD_WEB,
                              P_DESTINO_INMUEBLE,
                              P_DVSION_POLITICA,'S',NULL,NULL);
            IF V_MENSAJE IS NOT NULL THEN
              P_MENSAJE := V_MENSAJE;
            END IF;
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
                P_MENSAJE := 'El código arrojado como error no existe. Consulte al administrador del sistema.';
            END;
            IF TIPO = 'E' THEN
              P_MENSAJE := 'No se puede realizar el retiro al seguro. ' ||
                           DESCRIPCION;
            ELSE
              V_MENSAJE := NULL;
              FECHA     := TRUNC(P_FECHA_NOVEDAD) +
                           (SYSDATE - TRUNC(SYSDATE));
              PRC_NOVEDADES(P_SOLICITUD,
                            P_POLIZA,
                            P_CLASE,
                            P_RAMO,
                            P_SUCURSAL,
                            P_COMPANIA,
                            FECHA,
                            P_AMPARO,
                            V_CONCEPTO,
                            V_VALOR,
                            CERTIFICADO,
                            0,
                            NOVEDAD_RETIRO,
                            ENTRO,
                            CODIGO_MODULO,
                            V_MENSAJE,
                            P_CODIGO_USUARIO,
                            'NO',
                            'SI',
                            GLOBAL_PERIODO,
                            NULL,
                            NULL,
                            P_NOVEDAD_WEB);
              IF ENTRO = 0 THEN
                insertar_auditoria('RSGOS_VGNTES_NVDDES',
                                   to_char(sysdate),
                                   P_AMPARO,
                                   P_RAMO,
                                   TO_CHAR(P_SOLICITUD),
                                   TO_CHAR(P_POLIZA),
                                   NOVEDAD_RETIRO,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   'RIVN_VLOR_DFRNCIA',
                                   TO_CHAR(V_VALOR),
                                   TO_CHAR(V_VALOR),
                                   CODIGO_MODULO,
                                   P_CODIGO_USUARIO,
                                   SYSDATE,
                                   'Pasa el límite permitido',
                                   V_MENSAJE);
              END IF;
              ENTRO   := 1;
              RECHAZO := NULL;
              EXIT;
            END IF;
          ELSE
            BEGIN
              FECHA := TRUNC(P_FECHA_NOVEDAD) + (SYSDATE - TRUNC(SYSDATE));
              PRC_NOVEDADES(P_SOLICITUD,
                            P_POLIZA,
                            P_CLASE,
                            P_RAMO,
                            P_SUCURSAL,
                            P_COMPANIA,
                            FECHA,
                            P_AMPARO,
                            V_CONCEPTO,
                            V_VALOR,
                            CERTIFICADO,
                            0,
                            NOVEDAD_RETIRO,
                            ENTRO,
                            CODIGO_MODULO,
                            V_MENSAJE,
                            P_CODIGO_USUARIO,
                            'NO',
                            'SI',
                            GLOBAL_PERIODO,
                            NULL,
                            NULL,
                            P_NOVEDAD_WEB);
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := V_MENSAJE || SQLERRM;
            END;
            IF V_MENSAJE IS NOT NULL THEN
              P_MENSAJE := V_MENSAJE;
              EXIT;
            END IF;
          END IF;

          ENTRO   := 1;
          RECHAZO := NULL;
        END LOOP;
        CLOSE VALORES;

        PRC_DEVOLUCION(P_SOLICITUD,
                       P_POLIZA,
                       P_RAMO,
                       P_CLASE,
                       AMPARO,
                       GLOBAL_PERIODO,
                       CERTIFICADO,
                       MENSAJE_D);
        IF MENSAJE_D IS NOT NULL THEN
          P_MENSAJE := MENSAJE_D;
        END IF;
        IF V_MENSAJE IS NULL THEN
          BEGIN
            PRC_SUSPENSION(P_RAMO,
                           P_SOLICITUD,
                           P_AMPARO,
                           CODIGO_MODULO,
                           P_CODIGO_USUARIO,
                           CADENA,
                           MENSAJE_SUS);
          EXCEPTION
            WHEN OTHERS THEN
              P_MENSAJE := MENSAJE_SUS;
          END;
        END IF;
      END IF;
    END IF;

  END PRC_RETIRO_SEGURO;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_SUSPENSION
  -- Purpose : Procedimiento que hace la suspensión del siniestro.
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_SUSPENSION(P_RAMO      IN PLZAS.POL_RAM_CDGO%TYPE,
                           P_SOLICITUD IN SLCTDES_ESTDIOS.SES_NMRO%TYPE,
                           P_AMPARO    IN RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                           P_MODULO    IN MODULOS.MDL_CDGO%TYPE,
                           P_USUARIO   IN USRIOS.USR_CDGO_USRIO%TYPE,
                           P_CADENA    OUT VARCHAR2,
                           MENSAJE_S   OUT VARCHAR2) IS

  MENSAJE     VARCHAR2(1000):=NULL;
  SUBCADENA   VARCHAR2(30);
  BEGIN
    P_CADENA := NULL;
    SUSPENSION_PAGOS_RETIRO(P_RAMO,P_SOLICITUD,P_AMPARO,MENSAJE,P_MODULO,P_USUARIO);
    IF MENSAJE IS NOT NULL THEN
      SUBCADENA := SUBSTR(MENSAJE,1,3);
      IF  SUBCADENA = ' AD' THEN
        P_CADENA := SUBCADENA;
        MENSAJE_S := MENSAJE;
      ELSE
        MENSAJE_S := MENSAJE;
      END IF;
    END IF;

  END PRC_SUSPENSION;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_DEVOLUCION
  -- Purpose : Procedimiento de la devolución en el retiro
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_DEVOLUCION(SOLICITUD     NUMBER,
                           POLIZA        NUMBER,
                           RAMO          VARCHAR2,
                           CLASE         VARCHAR2,
                           AMPARO        VARCHAR2,
                           PERIODO       VARCHAR2,
                           CERTIFICADO   NUMBER,
                           MENSAJE       OUT VARCHAR2) IS

  DEVOLUCION   NUMBER;

  BEGIN
    SELECT COUNT(REN_NMRO_ITEM)
      INTO DEVOLUCION
       FROM RSGOS_RCBOS_NVDAD
      WHERE REN_CDGO_AMPRO = AMPARO
        AND REN_NMRO_ITEM  = SOLICITUD
        AND REN_NMRO_PLZA  = POLIZA
        AND REN_CLSE_PLZA  = CLASE
        AND REN_RAM_CDGO   = RAMO
        AND REN_TPO_NVDAD  = '09'
        AND TRUNC(REN_FCHA_NVDAD) = TO_DATE('01'||PERIODO,'DDMMYYYY');
    IF NVL(DEVOLUCION,0) > 0 THEN
      BEGIN
        INSERT INTO NVDDES
          SELECT RIVN_FCHA_NVDAD,RIVN_CDGO_AMPRO,RIVN_RAM_CDGO,RIVN_NMRO_ITEM,
                 RIVN_NMRO_PLZA,RIVN_CLSE_PLZA,RIVN_TPO_NVDAD,RIVN_VLOR_DFRNCIA,
                 RIVN_FCHA_MDFCCION,RIVN_USRIO,CERTIFICADO
            FROM RSGOS_VGNTES_NVDDES
           WHERE RIVN_NMRO_ITEM  = SOLICITUD
             AND RIVN_NMRO_PLZA  = POLIZA
             AND RIVN_CLSE_PLZA  = CLASE
             AND RIVN_TPO_NVDAD  = '09'
             AND RIVN_CDGO_AMPRO = AMPARO
             AND TRUNC(RIVN_FCHA_NVDAD) = TO_DATE('01'||PERIODO,'DDMMYYYY');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          MENSAJE := 'ERROR PASANDO LAS NOVEDADES DE DEVOLUCIÓN. '||SQLERRM;
      END;
      BEGIN
        DELETE RSGOS_RCBOS_NVDAD
         WHERE REN_CDGO_AMPRO = AMPARO
           AND REN_NMRO_ITEM = SOLICITUD
           AND REN_NMRO_PLZA = POLIZA
           AND REN_CLSE_PLZA = CLASE
           AND REN_RAM_CDGO  = RAMO
           AND REN_TPO_NVDAD = '09'
           AND TRUNC(REN_FCHA_NVDAD) = TO_DATE('01'||PERIODO,'DDMMYYYY');
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE := 'ERROR TRASLADANDO LA DEVOLUCIÓN. '||SQLERRM;
      END;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      MENSAJE := 'ERROR CONSULTANDO LAS NOVEDADES DE DEVOLUCIÓN. '||SQLERRM;

  END PRC_DEVOLUCION;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_VALIDA_MANUAL
  -- Purpose : Procedimiento con las validaciones generales para el ingreso de novedades
  -- Modificado por: Asesoftware - Jorge Gallo
  -- Fecha: 21/09/2017
  -- Propósito: Se agregó el campo ta_excepciones para identificar
  --excepciones a omitir
  --
  /***********************************************************************/
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
                              P_TA_EXCEPCIONES IN TA_EXCEPCIONES) IS



    Solicitud         slctdes_estdios.ses_nmro%type;
    Aprobacion        Number(6) := 0;
    Fechnvdad         date;
    fecha             date;
    FECHA_INGRESO     DATE;
    canon_mnmo        Number(18, 2);
    minimo            Number(18, 2);
    Juridico          Number(1);
    Retiro            Number(1);
    dias_maximo       NUMBER(6);
    Aumento           Number(18, 2) := 0;
    Parametro         Number(18, 2);
    Porcentaje        Number(18, 2);
    Varia_Canon       Number(6, 2);
    Varia_Cuota       Number(6, 2);
    Canon             rsgos_vgntes_avlor.rvl_vlor%type;
    Cuota             rsgos_vgntes_avlor.rvl_vlor%type;
    Canon_Anterior    rsgos_vgntes_avlor.rvl_vlor%type;
    Ingreso           Number(6);
    Meses             Number(6);
    Retirado          Number(10);
    Dias              Number(6);
    mensajes          VARCHAR2(1000);
    nov               VARCHAR2(2);
    NIT               NUMBER;
    fecha_nov         DATE;
    cod_amparo        varchar2(2);
    FECHA_ACTUAL      DATE;
    vlor              number(18, 2);
    PERIODO           VARCHAR2(6);
    FECHA_VIGENCIA    DATE;
    TIPO_SOLICITUD    SLCTDES_ESTDIOS.SES_TPO_SLCTUD%TYPE;
    N_SOLICITUD       NUMBER;
    PRIMER            VARCHAR2(10);
    FECHA_RES         DATE;
    PRIMER_DIA        DATE;
    V_FECHA_TEMP      DATE;
    ULTIMO_DIA        DATE;
--    DIAS_MES          NUMBER;
    fech              DATE;
    reg               NUMBER(1);
    permiso           varchar2(1);
    FECHA_BASICO      DATE;
    V_VALOR           PRMTROS.PAR_VLOR1%TYPE;
    V_AMPARO          AMPROS_PRDCTO.APR_REQUIERE_AMPARO%TYPE;
    PERIODO_CERTIFICADO VARCHAR2(6);
    MAX_RESULTADO       NUMBER;
    EXTRACTO            NUMBER;
    V_EXISTE_RETIRO     VARCHAR2(2) := NULL;
    V_TOTAL_ANTERIOR    NUMBER;
    IVA_COMERCIAL       NUMBER;
    v_max_asegurado     NUMBER;
    V_VALOR_HASTA       NUMBER;
    TEMP                NUMBER;
    VALOR_MAXIMO_INGRESO NUMBER;
    valor_max_cambios    NUMBER;
    cuota_ingreso        NUMBER;
    V_MAX_CUOTA          NUMBER;
    V_FECHA_INGRESO      DATE;
    Estado_Cierre        varchar2(1);
    CONTADOR_CERTIFICADOS NUMBER;
    V_TPO_INM            VARCHAR2(2);
    flag_omitir_excepcion NUMBER(1) :=0;
    PI_TA_EXCEPCIONES TA_EXCEPCIONES;

  BEGIN
    V_EXISTE_RETIRO := 'N'; -- para validar solicitud de ingreso si retiro ya hecho. GCHL 24/09/2013.
     
    -- Revisa si existen excepciones a saltar
    IF(P_TA_EXCEPCIONES IS NULL) THEN
    PI_TA_EXCEPCIONES := TA_EXCEPCIONES();
    ELSE
      PI_TA_EXCEPCIONES := P_TA_EXCEPCIONES;
    END IF;

    BEGIN

      SELECT POL_FCHA_DSDE_ACTUAL
        INTO FECHA_VIGENCIA
        FROM PLZAS
       WHERE POL_NMRO_PLZA = NMRO_POLIZA
         AND POL_CDGO_CLSE = CLASE_POLIZA
         AND POL_RAM_CDGO = RAMO;
      IF FECHA_NOVEDAD < FECHA_VIGENCIA THEN
        RESULTADO := 60;
        RETURN;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        MENSAJE :=  'NO ENCONTRO POLIZA PARA VIGENCIA INICIAL';
        RETURN;
    END;

    PERIODO := BUSCAR_PERIODO(MENSAJES);
    IF MENSAJES IS NOT NULL THEN
      MENSAJE := MENSAJES;
      RETURN;
    END IF;
    PRIMER     := '01' || PERIODO;
    PRIMER_DIA := TO_DATE(PRIMER, 'DDMMYYYY');
    ULTIMO_DIA := LAST_DAY(PRIMER_DIA);
    --DIAS_MES   := TO_NUMBER(TO_CHAR(ULTIMO_DIA, 'DD'));

    BEGIN
      BUSCAR_CERTIFICADO(NMRO_POLIZA,CLASE_POLIZA,RAMO,CERTIFICADO);

      IF CERTIFICADO IS NULL OR CERTIFICADO = 0 THEN

         BEGIN
           SELECT CER_SEQ.NEXTVAL INTO CERTIFICADO
             FROM DUAL;
           /*TRAE EL NUMERO QUE DEBE SALIR EN EL EXTRACTO DE CUENTA*/
           BEGIN
             SELECT CSE_NMRO_EXTRCTO INTO EXTRACTO
              FROM CNSCTVOS_EXTRCTOS;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                MENSAJE := 'NO EXISTE NUMERACION PARA LOS EXTRACTOS';
                RETURN;
             WHEN OTHERS THEN
                MENSAJE := 'ERROR AL EXTRAER LA NUMERACION PARA LOS EXTRACTOS';
                RETURN;
            END;
          END;
          BEGIN
--  BICC - 27/11/2015 -- MAN-39134 -- Para tener en cta que si ya se cerro el mes del sysdate, genere el certif. en el siguiente mes
             begin
               Select t.fpg_estdo
                 Into Estado_Cierre
                 From fchas_pgo t
                Where t.fpg_fcha_pgo between to_date('01'||to_char(sysdate, 'mmyyyy'), 'ddmmyyyy')
                                         and last_day(sysdate)
                  And t.marca_cierre_oprcion = 'S';
             exception
           when others then
                 estado_cierre := 'X';
             end;
       If Estado_Cierre = 'V' Then
          periodo := to_char(sysdate, 'mmyyyy');
             Else
          periodo := TO_CHAR(add_months(to_date('01'||to_char(sysdate, 'mmyyyy'), 'ddmmyyyy'), 1),'MMYYYY');
             End If;
--  BICC
  --  Mantis 44368.  Evitar generar doble certificado en casos en que la póiza es nueva
--  FERR.
--  Junio 2/2016

           SELECT COUNT (1)
             INTO CONTADOR_CERTIFICADOS
             FROM CRTFCDOS C
            WHERE C.CER_NMRO_PLZA         = NMRO_POLIZA
              AND C.CER_CLSE_PLZA         = CLASE_POLIZA
              AND C.CER_RAM_CDGO          = RAMO
              AND C.CER_FCHA_DSDE_ACTUAL  = TO_DATE('01'||PERIODO,'DDMMYYYY');

--  Mantis 44368.  Evitar generar doble certificado en casos en que la póiza es nueva.
--  FERR.
--  Junio 2/2016
              IF CONTADOR_CERTIFICADOS = 0  THEN 

                 INSERT INTO CRTFCDOS
                 SELECT CERTIFICADO, POL_NMRO_PLZA,POL_CDGO_CLSE,POL_RAM_CDGO,POL_CLSE_CRTFCDO,
                        POL_CDGO_CIASGRO,POL_CDGO_MNDA,'1',POL_PRS_NMRO_IDNTFCCION,
                        POL_PRS_TPO_IDNTFCCION,30,LAST_DAY(TO_DATE('01'||PERIODO,'DDMMYYYY')),
                        SYSDATE,TO_DATE('01'||PERIODO,'DDMMYYYY'),POL_TPO_PRDCCION,'00',
                        POL_CMBIO,100,100,POL_PRCNTJE_IVA,POL_PRCNTJE_CMSION,'I',
                        POL_GSTOS_EXPDCION,POL_VLOR_CMSION,POL_VLOR_PRMA_NTA,
                        POL_VLOR_PRMA_TTAL,0,POL_VLO_ASEGRBLE,POL_VLOR_IVA,USUARIO,
                        0,0,SYSDATE,0,0,NULL,TO_DATE('01'||PERIODO,'DDMMYYYY'),POL_VLOR_PRMA_TTAL
                        FROM PLZAS
                  WHERE POL_NMRO_PLZA = NMRO_POLIZA
                    AND POL_CDGO_CLSE =  CLASE_POLIZA
                    AND POL_RAM_CDGO  = RAMO;
              END IF;
           EXCEPTION
             WHEN DUP_VAL_ON_INDEX THEN
               null;
             WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20501,'Error al insertar el certificado de la póliza '||sqlerrm);
            END;

       END IF;
    EXCEPTION
      WHEN OTHERS THEN
        MENSAJE := 'ERROR BUSCANDO EL CERTIFICADO';
    END;

    IF CERTIFICADO IS NULL THEN
      RAISE_APPLICATION_ERROR(-20501,'ERROR BUSCANDO EL CERTIFICADO');

    END IF;

    BEGIN
        SELECT TO_CHAR(C.CER_FCHA_DSDE_ACTUAL,'MMYYYY')
          INTO PERIODO_CERTIFICADO
          FROM CRTFCDOS C
         WHERE C.CER_NMRO_CRTFCDO= CERTIFICADO;
   EXCEPTION
      WHEN OTHERS THEN
       PERIODO_CERTIFICADO := PERIODO;
--        RAISE_APPLICATION_ERROR(-20501,'ERROR BUSCANDO EL CERTIFICADO');
    END;

    Begin
      Select par_vlor2
        into ingreso
        from Prmtros
       where par_cdgo = '2'
         and par_mdlo = '2'
         and par_vlor1 = 2
         and par_suc_cdgo = SUCURSAL
         and par_suc_cia_cdgo = COMPANIA;
    Exception
      when no_data_found Then
        IF P_NOVEDAD_WEB = 'N' THEN
          RESULTADO := 87;
          RETURN;
        ELSE
          RESULTADO := 79;
          RETURN;
        END IF;
        return;
    End;

   -- se inlcuye para cumplir con las validaciones que se hablaron en la reunión
   -- con el libertador del 01/03/2013. sppc.
    Begin
      Select par_vlor2
        into MAX_RESULTADO
        from Prmtros
       where par_cdgo = '2'
         and par_mdlo = '2'
         and par_vlor1 = 12
         and par_suc_cdgo = SUCURSAL
         and par_suc_cia_cdgo = COMPANIA;
    Exception
      when no_data_found Then
        IF P_NOVEDAD_WEB = 'N' THEN
          RESULTADO := 87;
          RETURN;
        ELSE
          RESULTADO := 79;
          RETURN;
        END IF;
        return;
    End;


    -- Ingreso

    If TIPO_NOVEDAD = '01' Then
      -- GGM. 10/09/2013 - Mantis # 19369 validación opara que no se puede ingresar un riesgo cuando ya no han retirado
      IF P_NOVEDAD_WEB = 'S' THEN
        BEGIN -- GCHL. 24/09/2013. se pasa la funcionalidad de Gloria a una función para ser llamada tambien en la web.
          V_EXISTE_RETIRO := PKG_OPERACION.FUN_TIENE_RETIRO(NMRO_SLCTUD, '02', AMPARO);

          EXCEPTION WHEN OTHERS THEN
                           V_EXISTE_RETIRO := 'S'; -- si falla, es mejor que detenga al usuario.
        END;

        --raise_application_error(-20520,'V_EXISTE_RETIRO: '||V_EXISTE_RETIRO||' - '||NMRO_SLCTUD||' - '||AMPARO);
        IF UPPER(V_EXISTE_RETIRO) = UPPER('S') THEN -- si tiene retiro la solictud/amparo a ingresar.
          RESULTADO := 41;
          RETURN; -- sale del procedimiento y no deja hacer nada.
        END IF;

        /*SELECT COUNT(8)
          INTO EXISTE_RETIRO
          FROM RSGOS_RCBOS_NVDAD
         WHERE REN_NMRO_ITEM = NMRO_SLCTUD
         -- Mantis 19369 no se tiene en cuenta el período
         -- AND TO_CHAR(REN_FCHA_MDFCCION,'MMYYYY') = PERIODO
           AND REN_TPO_NVDAD = '02'
           AND REN_CDGO_AMPRO = AMPARO
           AND NOT EXISTS (SELECT * FROM RSGOS_VGNTES
                            WHERE RVI_NMRO_ITEM = REN_NMRO_ITEM);
        IF NVL(EXISTE_RETIRO,0) > 0 THEN
          RESULTADO := 45;
          RETURN;
        END IF;*/
      END IF;

      IF CONCEPTO IN ( '01') THEN
        IF FUN_VALIDA_VALOR(AMPARO, RAMO, SUCURSAL, COMPANIA, VALOR) = 'N' THEN
          Resultado := 29;
          Return;
        END IF;
      END IF;

      Juridico := NOVEDAD_JURIDICO(NMRO_SLCTUD, RAMO);
      If Juridico = 1 Then
        IF P_NOVEDAD_WEB = 'N' THEN
          RESULTADO := 6;
          RETURN;
        ELSE
          RESULTADO := 74;
          RETURN;
        END IF;
      END IF;

      -- Debe validar primero si las reglas de hogar para que no permita seguir la novedad
      IF TIPO_AMPARO = 'A' Then
        IF FUN_TRFCION_EXTERNA(AMPARO,RAMO) = 'S' THEN
          IF FUN_ANEXO_HOGAR(NMRO_POLIZA) = 'N'THEN
            RESULTADO := 70;
            RETURN;
          END IF;

          IF FUN_SERVICIO_ASISTENCIA(P_DVSION_POLITICA) = 'N'THEN
            RESULTADO := 71;
            RETURN;
          END IF;

          -- VALIDACION TIPO INMUEBLE JRIO
          BEGIN
              SELECT SE.SES_TPO_INMBLE
                INTO V_TPO_INM
              FROM SLCTDES_ESTDIOS SE
              WHERE SES_NMRO = NMRO_SLCTUD;
          EXCEPTION WHEN OTHERS THEN
            V_TPO_INM := 'X';
          END;
          
          IF P_DESTINO_INMUEBLE != 'V' THEN
             IF P_DESTINO_INMUEBLE = 'C' AND V_TPO_INM IN ('L','O')  THEN
                RESULTADO := NULL;
             ELSE
                RESULTADO := 69;
                RETURN;
             END IF;
          END IF;

          IF TO_CHAR(FECHA_NOVEDAD,'MMYYYY') != PERIODO_CERTIFICADO THEN
            RESULTADO := 73;
            RETURN;
          END IF;


          --
          BEGIN
            SELECT SES_TPO_SLCTUD
              INTO TIPO_SOLICITUD
              FROM SLCTDES_ESTDIOS
             WHERE SES_NMRO = NMRO_SLCTUD;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                SELECT ARR_SES_NMRO
                  INTO N_SOLICITUD
                  FROM ARRNDTRIOS
                 WHERE ARR_NMRO_SLCTUD = NMRO_SLCTUD;

                BEGIN
                  SELECT SES_TPO_SLCTUD
                    INTO TIPO_SOLICITUD
                    FROM SLCTDES_ESTDIOS
                   WHERE SES_NMRO = N_SOLICITUD;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    RESULTADO := 75;
                    RETURN;
                END;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  RESULTADO := 75;
                  RETURN;
              END;
          END;

          IF TIPO_SOLICITUD IN ('IN','IP') THEN
            V_VALOR := 11;
          ELSE
            V_VALOR := 10;
          END IF;

          IF FUN_MESES_HOGAR(MODULO,SUCURSAL,COMPANIA,V_VALOR) IS NOT NULL THEN
            FECHA_INGRESO := FECHA_INGRESO_SEG(NMRO_SLCTUD,NMRO_POLIZA,CLASE_POLIZA,RAMO,'01');
            IF FECHA_INGRESO IS NOT NULL THEN
              V_FECHA_TEMP := ADD_MONTHS(FECHA_INGRESO,FUN_MESES_HOGAR(MODULO,SUCURSAL,COMPANIA,V_VALOR));
              IF TRUNC(FECHA_NOVEDAD) < TRUNC(V_FECHA_TEMP) THEN
                RESULTADO := 72;
                RETURN;
              END IF;
            ELSE
              RESULTADO := 76;
              RETURN;
            END IF;
          ELSE
            IF P_NOVEDAD_WEB = 'N' THEN
              RESULTADO := 77;
              RETURN;
            ELSE
              RESULTADO := 88;
              RETURN;
            END IF;
          END IF;
        END IF;
      END IF;

      -- VERIFICA SI LA SOLICITUD SE ENCUENTRA APROBADA
      Begin
        select max(rea_fcha_rsltdo)
          into fech
          from rsltdos_arrndtrios
         where rea_nmro_slctud = NMRO_SLCTUD;
        If fech is not null then
          begin
            select 1
              into aprobacion
              from rsltdos_arrndtrios, rsltdo_estdio
             where rea_nmro_slctud = nmro_slctud
               and rea_fcha_rsltdo = fech
               and rea_tpo_rsltdo = 'D'
               and ret_nmro_slctud = nmro_slctud
               and ret_fcha_rsltdo = fech
               and ret_cdgo_rsltdo IN ('01', '70', '71');
          exception
            when no_data_found then
              prc_validar_anulado(nmro_slctud,
                                  tipo_amparo,
                                  amparo,
                                  aprobacion,
                                  resultado);
              if aprobacion = 1 or resultado > 0 then
                return;
              End if;
            when too_many_rows then
              if tipo_amparo = 'B' then
                aprobacion := 1;
              else
                IF P_NOVEDAD_WEB = 'S' THEN
                  IF AMPARO = '04' THEN
                    RESULTADO := 48;
                    RETURN;
                  ELSE
                    APROBACION := 1;
                  END IF;
                ELSE
                  APROBACION := 1;
                END IF;
              end if;
          end;
        else
          resultado := 8;
          return;
        End if;
      Exception
        when no_data_found then
          aprobacion := 0;
          resultado  := 8;
          return;
      End;

      IF TIPO_AMPARO = 'B' THEN
        -- Verifica si sobrepasa el tiempo para el ingreso
        IF CONCEPTO = '01' THEN
          BEGIN
            SELECT MAX(RET_FCHA_RSLTDO)
              INTO FECHA_RES
              FROM RSLTDO_ESTDIO
             WHERE RET_NMRO_SLCTUD = NMRO_SLCTUD;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RAISE_APPLICATION_ERROR(-20505,'ERROR CONSULTANDO EL RESULTADO DE LA SOLICITUD ');
          END;

          -- GCHL 15102014. Mantis 30279,
          -- se quita el round para que tome exactamente los días entre el dia de ingreso y la fecha de resultado.
          /*IF ROUND(MONTHS_BETWEEN(SYSDATE, FECHA_RES), 0) > INGRESO / 30 THEN
            RESULTADO := 68;
            RETURN;
          END IF;*/
          --IF MONTHS_BETWEEN(SYSDATE, FECHA_RES) > (INGRESO / 30) THEN -- meses exacto del 17/07 al 17/09...
          IF(PI_TA_EXCEPCIONES.COUNT > 0) THEN
              FOR i IN 1..PI_TA_EXCEPCIONES.COUNT LOOP
                IF(PI_TA_EXCEPCIONES(i) = '68') THEN
                  flag_omitir_excepcion := 1;
                END IF;
              END LOOP;
          END IF;
          IF (TRUNC(FECHA_RES + INGRESO) < TRUNC(SYSDATE)) AND flag_omitir_excepcion = 0 THEN 
            RESULTADO := 68;
            RETURN;
          END IF;
          flag_omitir_excepcion := 0;
        END IF;

       -- se habilita nuevamente pues se había tomado una validación
       -- incorrecta 04/03/2013. sppc.
        IF P_NOVEDAD_WEB != 'S' THEN  ---DAP. Mantis 14838
          IF FECHA_NOVEDAD < FECHA_RES THEN
            RESULTADO := 92;
            RETURN;
          END IF;
        ELSE  --DAP. Validación Mantis 14838 basado en los datos del sistema.
           IF TO_NUMBER(TO_CHAR(FECHA_NOVEDAD,'YYYYMM')) <
              TO_NUMBER(TO_CHAR(FECHA_RES,'YYYYMM')) THEN
              RESULTADO := 92;
              RETURN;
           END IF;
        END IF;

      -- se inlcuye para cumplir con las validaciones que se hablaron en la reunión
       -- con el libertador del 01/03/2013. sppc.
        IF ADD_MONTHS(SYSDATE,MAX_RESULTADO*-1) > FECHA_RES  THEN
          RESULTADO := 93;
          RETURN;
        END IF;

        IF CONCEPTO = '02' THEN
          Begin
            Select RVL_CDGO_AMPRO, RVL_VLOR
              into cod_amparo, vlor
              from rsgos_vgntes_avlor
             where RVL_CDGO_AMPRO = amparo
               and RVL_NMRO_ITEM = nmro_slctud
               and RVL_NMRO_PLZA = nmro_poliza
               and RVL_CLSE_PLZA = clase_poliza
               and RVL_RAM_CDGO = ramo
               and RVL_CNCPTO_VLOR = '01';
          Exception
            When no_data_found then
              resultado := 27;
              return;
            when too_many_rows then
             RAISE_APPLICATION_ERROR(-20507,SQLERRM);
            when others then
              RAISE_APPLICATION_ERROR(-20508,SQLERRM);
          end;
        ELSE
          IF CONCEPTO != '31' THEN
            Begin
              Select rivn_tpo_nvdad, rivn_fcha_nvdad
                into nov, fecha_nov
                from rsgos_vgntes_nvddes
               where rivn_nmro_item = NMRO_SLCTUD
                 and rivn_clse_plza = CLASE_POLIZA
                 and rivn_ram_cdgo = RAMO
                 and rivn_cdgo_ampro = AMPARO
                 and rivn_tpo_nvdad = TIPO_NOVEDAD;
              If nov = TIPO_NOVEDAD then
                resultado := 21;
                return;
              End if;
            Exception
              When no_data_found then
                begin
                 select 1
                    into reg
                    from rsgos_vgntes_ampro
                   where rva_cdgo_ampro = amparo
                     and rva_ram_cdgo = ramo
                     and rva_nmro_item = NMRO_SLCTUD
                     and rva_clse_plza = clase_POLIZA;
                  if reg = 1 then
                    resultado := 21;
                    return;
                  end if;
                exception
                  when no_data_found then
                    null;
                end;
            End;
          END IF;
        END IF;
        If aprobacion = 0 Then
          Resultado := 8;
          Return;
        Else
          BEGIN
            SELECT ARR_SES_NMRO
              INTO solicitud
              FROM ARRNDTRIOS
             WHERE ARR_NMRO_SLCTUD = NMRO_SLCTUD;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RESULTADO := 75;
              RETURN;
          END;

          Begin
            Select ses_cnon_arrndmnto, ses_cta_admnstrcion
              into canon, cuota
              from Slctdes_Estdios
             where ses_nmro = SOLICITUD
               and ses_clse_plza = CLASE_POLIZA
               and ses_ram_cdgo = RAMO;
          Exception
            when no_data_found Then
                RESULTADO := 75;
              return;
          End;


          Begin
            Select par_vlor2
              into varia_canon
              from Prmtros
             where par_cdgo = '2'
               and par_mdlo = '2'
               and par_vlor1 = 8
               and par_suc_cdgo = SUCURSAL
               and par_suc_cia_cdgo = COMPANIA;
          Exception
            when no_data_found Then
              IF P_NOVEDAD_WEB = 'N' THEN
                RESULTADO := 95;
                RETURN;
              ELSE
                RESULTADO := 95;
                RETURN;
              END IF;
              return;
          End;

          -- SPPC. MANTIS 22568
          IF P_NOVEDAD_WEB = 'S' THEN

            Begin
              Select par_vlor2
                into valor_max_cambios
                from Prmtros
               where par_cdgo = '2'
                 and par_mdlo = '2'
                 and par_vlor1 = 16
                 and par_suc_cdgo = SUCURSAL
                 and par_suc_cia_cdgo = COMPANIA;
            Exception
              when no_data_found Then
                RESULTADO := 95;
                RETURN;
            End;

            -- VERIFICA QUE EL VALOR ASEGURADO ES MAYOR AL PARAMETRO DADO
            -- CON EL FIN DE NO DEJAR HACER CAMBIOS AL VALOR APROBADO.
            IF TTAL_ASGRADO >  valor_max_cambios THEN
              IF(PI_TA_EXCEPCIONES.COUNT > 0) THEN
                FOR i IN 1..PI_TA_EXCEPCIONES.COUNT LOOP
                  IF(PI_TA_EXCEPCIONES(i) = '19') THEN
                    flag_omitir_excepcion := 1;
                  END IF;
                END LOOP;
              END IF;
              IF CANON + NVL(CUOTA,0) > TTAL_ASGRADO AND flag_omitir_excepcion = 0 THEN
                 Resultado := 19;
                 Return;
              END IF;
              flag_omitir_excepcion :=0;
            END IF;



          END IF;

          -- se incluye parámetro del iva comercial. SPPC. 12/03/2014. MANTIS 22568.
          IF P_DESTINO_INMUEBLE = 'C' AND CONCEPTO = '01' THEN

            Begin
              Select par_vlor2
                into iva_comercial
                from Prmtros
               where par_cdgo = '2'
                 and par_mdlo = '2'
                 and par_vlor1 = 15
                 and par_suc_cdgo = SUCURSAL
                 and par_suc_cia_cdgo = COMPANIA;
            Exception
              when no_data_found Then
                IF P_NOVEDAD_WEB = 'N' THEN
                  RESULTADO := 97;
                  RETURN;
                ELSE
                  RESULTADO := 97;
                  RETURN;
                END IF;
                return;
            End;


        /*    if nvl(P_IVA,'N') = 'S' then
               varia_canon := varia_canon + NVL(iva_comercial,0);
            end if;*/


          END IF;

          -- se incluye nuevo parámetro para validar el incremento de la cuota.
          -- SPPC. MANTIS 22568. 03/03/2014
          Begin
            Select par_vlor2
              into varia_cuota
              from Prmtros
             where par_cdgo = '2'
               and par_mdlo = '2'
               and par_vlor1 = 13
               and par_suc_cdgo = SUCURSAL
               and par_suc_cia_cdgo = COMPANIA;
          Exception
            when no_data_found Then
              IF P_NOVEDAD_WEB = 'N' THEN
                RESULTADO := 96;
                RETURN;
              ELSE
                RESULTADO := 96;
                RETURN;
              END IF;
              return;
          End;

          Begin
            Select trunc(ses_fcha_ultmo_rsltdo)
              into fechnvdad
              from Slctdes_Estdios
             where ses_nmro = solicitud
               and ses_clse_plza = CLASE_POLIZA
               and ses_ram_cdgo = RAMO;
          Exception
            when no_data_found Then
             RAISE_APPLICATION_ERROR(-20506, 'Error en fecha de resultado solicitud');
          End;

          Begin
            Select par_vlor2
              into dias_maximo
              from Prmtros
             where par_cdgo = '2'
               and par_mdlo = '2'
               and par_vlor1 = 2
               and par_suc_cdgo = SUCURSAL
               and par_suc_cia_cdgo = COMPANIA;
          Exception
            when no_data_found Then
              IF P_NOVEDAD_WEB = 'N' THEN
                RESULTADO := 90;
                RETURN;
              ELSE
                RESULTADO := 79;
                RETURN;
              END IF;
              return;
          End;

          IF P_NOVEDAD_WEB = 'N' THEN
            If (primer_dia - fechnvdad) > dias_maximo Then
              Resultado := 7;
              Return;
            End If;
          ELSE
            IF ((ULTIMO_DIA - 1) - FECHA_NOVEDAD) > DIAS_MAXIMO THEN
              RESULTADO := 7;
              RETURN;
            END IF;
          END IF;
        End If;

        -- SPPC. MANTIS 22568
        -- GCHL. MANTIS 33420, se suprime porque se valida arriba en la linea 2034, esto esta duplicado....
       /* IF P_NOVEDAD_WEB = 'S' THEN

          SELECT T.TAP_ASEGURADO_HASTAWEB
            INTO V_VALOR_MAX
            FROM TRFA_AMPROS_PRDCTO T
          WHERE T.TAP_CDGO_AMPRO =  AMPARO
            AND T.TAP_RAM_CDGO   = RAMO
            AND T.TAP_SUC_CDGO   = SUCURSAL
            AND T.TAP_CIA_CDGO   = COMPANIA
            AND T.TAP_TPO_PLZA   = 'C';

          IF TTAL_ASGRADO > V_VALOR_MAX THEN
             Resultado := 19;
             Return;
          END IF;

        END IF;*/

        IF VALOR < FUN_VALOR_CONCEPTO(RAMO, CONCEPTO) THEN
          Resultado := 11;
          Return;
        END IF;
        
        IF(PI_TA_EXCEPCIONES.COUNT > 0) THEN
          FOR i IN 1..PI_TA_EXCEPCIONES.COUNT LOOP
            IF(PI_TA_EXCEPCIONES(i) = '19') THEN
              flag_omitir_excepcion := 1;
            END IF;
          END LOOP;
        END IF;

        IF CONCEPTO = '01' and VALOR != 0 Then
          IF VALOR > CANON THEN
            porcentaje := (ABS(VALOR - CANON) * 100) / CANON;
            if nvl(P_IVA,'N') = 'S' then
               TEMP := (CANON + ((CANON * VARIA_CANON)/100));
               VALOR_MAXIMO_INGRESO := TEMP + ((TEMP * IVA_COMERCIAL)/100);
               IF (VALOR > VALOR_MAXIMO_INGRESO) AND flag_omitir_excepcion = 0 THEN
                Resultado := 19;
                Return;
               End If;
            else
              If (porcentaje > varia_canon) AND flag_omitir_excepcion = 0  Then
                Resultado := 19;
                Return;
              End If;
            End if;
          END IF;
        End If;
        flag_omitir_excepcion := 0;
        IF CONCEPTO = '02' and VALOR != 0 Then
          IF CUOTA != 0 THEN
            IF VALOR > CUOTA THEN
              porcentaje := (ABS(VALOR - CUOTA) * 100) / CUOTA;
              If porcentaje > varia_canon Then
                Resultado := 94;
                Return;
              End If;
            END IF;
          ELSE

            IF P_NOVEDAD_WEB = 'N' THEN
              IF VALOR > CUOTA THEN
                If VALOR > (varia_cuota * 1000) Then
                  Resultado := 94;
                  Return;
                End If;
              END IF;
            ELSE

             Begin
               Select par_vlor2
                 into cuota_ingreso
                 from Prmtros
                where par_cdgo = '2'
                  and par_mdlo = '2'
                  and par_vlor1 = 17
                  and par_suc_cdgo = SUCURSAL
                  and par_suc_cia_cdgo = COMPANIA;
              Exception
                 when no_data_found Then
                   RESULTADO := 95;
                   RETURN;
              End;
                 V_MAX_CUOTA :=  ((CANON * CUOTA_INGRESO)/100);

                 IF VALOR > V_MAX_CUOTA THEN
                   Resultado := 94;
                   Return;
                 END IF;

            END IF;
          END IF;
        End If;
        
        IF(PI_TA_EXCEPCIONES.COUNT > 0) THEN
          FOR i IN 1..PI_TA_EXCEPCIONES.COUNT LOOP
            IF(PI_TA_EXCEPCIONES(i) = '19') THEN
              flag_omitir_excepcion := 1;
            END IF;
          END LOOP;
        END IF;

        IF P_NOVEDAD_WEB ='S' THEN
          -- se DEBE VALIDAR QUE EL TOTAL ASEGURADO
          -- NO SUPERE TAMPOCO EL PORCENTAJE. SPPC. 03/03/2014

         IF NVL(P_IVA,'N') = 'N' THEN

          IF TTAL_ASGRADO != 0 THEN
            IF  TTAL_ASGRADO > (CANON+CUOTA)   THEN
               porcentaje := (ABS(TTAL_ASGRADO - (CANON+CUOTA)) * 100) / (CANON+CUOTA);
               If (porcentaje > varia_canon) AND flag_omitir_excepcion = 0  Then
                 Resultado := 19;
                 Return;
               End If;
            END IF;
          END IF;

         END IF;

        END IF;

      END IF;
      flag_omitir_excepcion := 0;
      Juridico := NOVEDAD_JURIDICO(NMRO_SLCTUD, RAMO);
      If Juridico = 1 Then
        BEGIN
          SELECT 'S'
            INTO PERMISO
            FROM ROLES_USRIOS
           WHERE RUS_CDGO_ROL = '111'
             AND RUS_CDGO_USRIO = USUARIO;
          IF P_NOVEDAD_WEB = 'S' THEN
            RESULTADO := 74;
            RETURN;
          ELSE
            RESULTADO := 74;
            RETURN;
          END IF;
          RETURN;
          BEGIN
            INSERT INTO RSGOS_CON_SNSTROS
            VALUES
              (NMRO_SLCTUD,
               NMRO_POLIZA,
               CLASE_POLIZA,
               RAMO,
               AMPARO,
               USER,
               SYSDATE);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RESULTADO := 6;
            RETURN;
        END;
      End if;

      IF TIPO_AMPARO = 'A' Then
        V_AMPARO := NULL;
        -- se incluye pues solo validaba para novedades web. sppc. 05/03/2013.
        FECHA_INGRESO := FECHA_INGRESO_SEG(NMRO_SLCTUD,NMRO_POLIZA,CLASE_POLIZA,RAMO,'01');
        IF FECHA_INGRESO IS NOT NULL THEN
           IF TRUNC(FECHA_INGRESO) > TRUNC(FECHA_NOVEDAD) THEN
             RESULTADO := 65;
             RETURN;
            END IF;
         ELSE
             RESULTADO := 76;
             RETURN;
         END IF;

        IF FUN_REQUIERE_BASICO(AMPARO) = 'S' THEN
          IF FUN_VALIDA_SEGURO(NMRO_SLCTUD,
                               '01',
                               RAMO,
                               CLASE_POLIZA,
                               NMRO_POLIZA) = 'N' THEN
            Resultado := 17;
            Return;
          END IF;
        END IF;
        V_AMPARO := FUN_REQUIERE_AMPARO(AMPARO);
        IF V_AMPARO IS NOT NULL THEN
          IF FUN_VALIDA_SEGURO(NMRO_SLCTUD,
                               V_AMPARO,
                               RAMO,
                               CLASE_POLIZA,
                               NMRO_POLIZA) = 'N' THEN
            Resultado := 26;
            Return;
          END IF;
        END IF;

        Begin
          Select rvl_vlor
            into canon_mnmo
            from Rsgos_Vgntes_Avlor
           where rvl_cdgo_ampro = '01'
             and rvl_nmro_item = NMRO_SLCTUD
             and rvl_nmro_plza = NMRO_POLIZA
             and rvl_clse_plza = CLASE_POLIZA
             and rvl_ram_cdgo = RAMO
             and rvl_cncpto_vlor = '01';
        Exception
          when no_data_found Then
            Resultado := 17;
            Return;
        End;

        -- verifica que el amparo ya ha sido ingresado
        -- El parametro P_SINPRIMA se utiliza porque en la forma Ingreso de Adicionales sin cobro de prima
        -- no debe validar si ya ha sido ingresado el amparo
        IF P_SINPRIMA = 'S' THEN
          IF CONCEPTO != '31' THEN
            IF FUN_VALIDA_SEGURO(NMRO_SLCTUD,
                                 AMPARO,
                                 RAMO,
                                 CLASE_POLIZA,
                                 NMRO_POLIZA) = 'S' THEN
              Resultado := 21;
              Return;
            END IF;
          END IF;
        END IF;

        BEGIN
          select vaa_vlor_mnmo
            into minimo
            from asgrdos_ampros
           where vaa_ram_cdgo = RAMO
             and vaa_cdgo_ampro = AMPARO
             and vaa_cncpto = '01'
             and vaa_rngo_dsde >= canon
             and vaa_rngo_hsta <= canon;
          If VALOR < minimo then
            Resultado := 10;
            Return;
          End if;
        Exception
          when no_data_found then
            null;
        End;

        If CONCEPTO = '03' AND VALOR != 0 Then
          IF FUN_VALIDA_VALOR(AMPARO, RAMO, SUCURSAL, COMPANIA, VALOR) = 'N' THEN
            Resultado := 9;
            Return;
          END IF;
        End If;

        If CONCEPTO = '05' AND VALOR != 0 Then
          IF FUN_VALIDA_VALOR(AMPARO, RAMO, SUCURSAL, COMPANIA, VALOR) = 'N' THEN
            Resultado := 10;
            Return;
          END IF;
        End If;

        If CONCEPTO = '14' AND VALOR != 0 Then
          IF FUN_VALIDA_VALOR(AMPARO, RAMO, SUCURSAL, COMPANIA, VALOR) = 'N' THEN
            Resultado := 28;
            Return;
          END IF;
        END IF;


       -- se incluye esta validación por mantis #23440.SPPC.13/02/2014.
       -- No validaba amparo integral.

        IF P_NOVEDAD_WEB = 'S' THEN
          If CONCEPTO = '16' AND VALOR != 0 Then
            IF FUN_VALIDA_VALOR(AMPARO, RAMO, SUCURSAL, COMPANIA, VALOR) = 'N' THEN
              Resultado := 28;
              Return;
            END IF;
          END IF;
        END IF;


        -- SPPC. 13/03/2014. MANTIS 22568.
        IF P_NOVEDAD_WEB = 'S' THEN
            BEGIN
              SELECT T.TAP_ASEGURADO_HASTAWEB
                INTO V_VALOR_HASTA
                FROM TRFA_AMPROS_PRDCTO T
               WHERE T.TAP_CDGO_AMPRO = AMPARO
                 AND T.TAP_RAM_CDGO   = RAMO
                 AND T.TAP_SUC_CDGO   = SUCURSAL
                 AND T.TAP_CIA_CDGO   = COMPANIA
                 AND T.TAP_TPO_PLZA   = 'C';

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                Resultado := 28;
                Return;
            END;
          -- VERIFICA QUE NO SUPERE EL MAXIMO PERMITIDO A INGRESAR SIEMPRES Y CUANDO
          -- NO SEA EL VALOR APROBADO. SPPC. 13/03/2014. MANTIS 22568.
          IF(PI_TA_EXCEPCIONES.COUNT > 0) THEN
            FOR i IN 1..PI_TA_EXCEPCIONES.COUNT LOOP
              IF(PI_TA_EXCEPCIONES(i) = '19') THEN
                flag_omitir_excepcion := 1;
              END IF;
            END LOOP;
          END IF;
          
          IF CONCEPTO = '01' THEN

              IF VALOR > V_VALOR_HASTA THEN
                IF VALOR != CANON AND flag_omitir_excepcion = 0 THEN
                  Resultado := 19;
                  Return;
                END IF;
              END IF;
          ELSIF CONCEPTO = '02' THEN
              IF VALOR > V_VALOR_HASTA THEN
                IF VALOR != CUOTA THEN
                  Resultado := 94;
                  Return;
                END IF;
              END IF;

          END IF;

          -- VALIDA SI EL VALOR TOTAL ASEGURADO SUPERA EL LIMITE PERMITIDO. SPPC. 13/03/2014. MANTIS 22568.
          IF CONCEPTO IN ('01','02') THEN

             IF (CANON+ NVL(CUOTA,0)) != TTAL_ASGRADO AND flag_omitir_excepcion = 0 THEN
                Resultado := 19;
                Return;
              END IF;
            END IF;

        END IF;
        flag_omitir_excepcion := 0;
        
        IF VALOR < FUN_VALOR_CONCEPTO(RAMO, CONCEPTO) THEN
          Resultado := 11;
          Return;
        END IF;

        IF FUN_TRFCION_EXTERNA(AMPARO,RAMO) = 'S' THEN
          IF FUN_ANEXO_HOGAR(NMRO_POLIZA) = 'N'THEN
            RESULTADO := 70;
            RETURN;
          END IF;

          IF FUN_SERVICIO_ASISTENCIA(P_DVSION_POLITICA) = 'N'THEN
            RESULTADO := 71;
            RETURN;
          END IF;

          -- VALIDACION TIPO INMUEBLE JRIO
          BEGIN
              SELECT SE.SES_TPO_INMBLE
                INTO V_TPO_INM
              FROM SLCTDES_ESTDIOS SE
              WHERE SES_NMRO = NMRO_SLCTUD;
          EXCEPTION WHEN OTHERS THEN
            V_TPO_INM := 'X';
          END;
          
          IF P_DESTINO_INMUEBLE != 'V' THEN
             IF P_DESTINO_INMUEBLE = 'C' AND V_TPO_INM IN ('L','O')  THEN
                RESULTADO := NULL;
             ELSE
                RESULTADO := 69;
                RETURN;
             END IF;
          END IF;

          IF TO_CHAR(FECHA_NOVEDAD,'MMYYYY') != PERIODO_CERTIFICADO THEN
            RESULTADO := 73;
            RETURN;
          END IF;
          -- NO SE DEBE TENER EN CUENTA ESTA REGLA PARA CONTRATOS POR INDUCCION SEGUN MANTIS # 11812
          BEGIN
            SELECT SES_TPO_SLCTUD
              INTO TIPO_SOLICITUD
              FROM SLCTDES_ESTDIOS
             WHERE SES_NMRO = NMRO_SLCTUD;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                SELECT ARR_SES_NMRO
                  INTO N_SOLICITUD
                  FROM ARRNDTRIOS
                 WHERE ARR_NMRO_SLCTUD = NMRO_SLCTUD;

                BEGIN
                  SELECT SES_TPO_SLCTUD
                    INTO TIPO_SOLICITUD
                    FROM SLCTDES_ESTDIOS
                   WHERE SES_NMRO = N_SOLICITUD;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    RESULTADO := 75;
                    RETURN;
                END;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  RESULTADO := 75;
                  RETURN;
              END;
          END;
           -- NO SE DEBE TENER EN CUENTA ESTA REGLA PARA CONTRATOS POR INDUCCION SEGUN MANTIS # 11812
          BEGIN
            SELECT SES_TPO_SLCTUD
              INTO TIPO_SOLICITUD
              FROM SLCTDES_ESTDIOS
             WHERE SES_NMRO = NMRO_SLCTUD;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
                SELECT ARR_SES_NMRO
                  INTO N_SOLICITUD
                  FROM ARRNDTRIOS
                 WHERE ARR_NMRO_SLCTUD = NMRO_SLCTUD;

                BEGIN
                  SELECT SES_TPO_SLCTUD
                    INTO TIPO_SOLICITUD
                    FROM SLCTDES_ESTDIOS
                   WHERE SES_NMRO = N_SOLICITUD;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    RESULTADO := 75;
                    RETURN;
                END;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  RESULTADO := 75;
                  RETURN;
              END;
          END;

          IF TIPO_SOLICITUD IN ('IN','IP') THEN
            V_VALOR := 11;
          ELSE
            V_VALOR := 10;
          END IF;
          IF TIPO_SOLICITUD NOT IN ('IN','IP') THEN
            IF FUN_MESES_HOGAR(MODULO,SUCURSAL,COMPANIA,V_VALOR) IS NOT NULL THEN
              FECHA_INGRESO := FECHA_INGRESO_SEG(NMRO_SLCTUD,NMRO_POLIZA,CLASE_POLIZA,RAMO,'01');
              IF FECHA_INGRESO IS NOT NULL THEN
                V_FECHA_TEMP := ADD_MONTHS(FECHA_INGRESO,FUN_MESES_HOGAR(MODULO,SUCURSAL,COMPANIA,V_VALOR));
                IF TRUNC(FECHA_NOVEDAD) < TRUNC(V_FECHA_TEMP) THEN
                  RESULTADO := 72;
                  RETURN;
                END IF;
              ELSE
                RESULTADO := 76;
                RETURN;
              END IF;
            ELSE
              IF P_NOVEDAD_WEB = 'N' THEN
                RESULTADO := 91;
                RETURN;
              ELSE
                RESULTADO := 77;
                RETURN;
              END IF;
            END IF;
          END IF;
          --
        ELSE
          IF P_NOVEDAD_WEB = 'S' THEN
            Select MIN(rivn_fcha_nvdad)
              into fecha_basico
              from rsgos_vgntes_nvddes
             where rivn_nmro_item = NMRO_SLCTUD
               and rivn_clse_plza = CLASE_POLIZA
               and rivn_ram_cdgo = RAMO
               and rivn_cdgo_ampro = '01'
               and rivn_tpo_nvdad = '01';

            Select MIN(rivn_fcha_mdfccion)
              into fecha_nov
              from rsgos_vgntes_nvddes
             where rivn_nmro_item = NMRO_SLCTUD
               and rivn_clse_plza = CLASE_POLIZA
               and rivn_ram_cdgo = RAMO
               and rivn_cdgo_ampro = '01'
               and rivn_tpo_nvdad = '01';
            if fecha_nov is null then
              Select MIN(ren_fcha_nvdad)
                into fecha_nov
                from rsgos_rcbos_nvdad
               where ren_nmro_item = NMRO_SLCTUD
                 and ren_clse_plza = CLASE_POLIZA
                 and ren_ram_cdgo = RAMO
                 and ren_cdgo_ampro = '01'
                 and ren_tpo_nvdad = '01';
            end if;
            -- Verifica que el amparo adicional no se grabe antes de la fecha de ingreso del
            -- amparo básico.
            BEGIN
              SELECT POL_PRS_NMRO_IDNTFCCION
                INTO NIT
                FROM PLZAS
               WHERE POL_NMRO_PLZA = NMRO_POLIZA
                 AND POL_CDGO_CLSE = CLASE_POLIZA
                 AND POL_RAM_CDGO = RAMO;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20515,'ERROR EN LA CONSULTA DE LA IDENTIFICACION DE LA POLIZA');
            END;
            -- Según pruebas con los usuarios el 28/09/2011 se definio que:
            -- Si es el mismo periodo en que se ingresa el amparo básico el amparo adicional
            -- debe ingresarse con la misma fecha del básico
            -- Se dá el siguiente periodo para ingresar el amparo adicional pero solo con fecha
            -- del periodo actual  G.G.M.
            fecha_actual := pkg_novedades_web_java.FUN_FECHA_NOV_DATE(NIT);
            -- En la reunión del 16/07/2007 se definió que para las novedades por web se
            -- va a permitir el ingreso de los amparos adicionales sólo al momento del ingreso
            -- del amparo básico. sppc

            IF fecha_nov is not null then
              IF TRUNC(fecha_nov) = trunc(fecha_actual) then
                IF trunc(fecha_novedad) != trunc(fecha_basico) then
                  RESULTADO := 65;
                  RETURN;
                END IF;

                IF trunc(fecha_novedad) != trunc(fecha_basico) then
                  RESULTADO := 64;
                  return;
                END IF;
              ELSIF trunc(fecha_actual) = trunc(add_months(fecha_nov, 1)) then
                IF trunc(fecha_novedad) != trunc(fecha_actual) then
                  RESULTADO := 65;
                  RETURN;
                END IF;
                IF trunc(fecha_novedad) != trunc(fecha_actual) then
                  RESULTADO := 64;
                  RETURN;
                END IF;
              ELSE
                RESULTADO := 65;
                RETURN;
              END IF;
            END IF;
          END IF;
        END IF;

        -- El parametro P_SINPRIMA se utiliza porque en la forma Ingreso de Adicionales sin cobro de prima
        -- no debe validar si ya ha sido ingresado el amparo
        IF P_SINPRIMA = 'S' THEN
          IF CONCEPTO != '31' THEN
            IF FUN_VALIDA_SEGURO(NMRO_SLCTUD, AMPARO, RAMO, CLASE_POLIZA) = 'S' THEN
              Resultado := 21;
              Return;
            END IF;
          END IF;
        END IF;

      End if;

      -- Retiro
    Elsif TIPO_NOVEDAD = '02' Then

      IF TIPO_AMPARO = 'B' THEN

        Juridico := NOVEDAD_JURIDICO(NMRO_SLCTUD, RAMO);
        If Juridico = 1 Then
          IF P_NOVEDAD_WEB = 'N' THEN
            RESULTADO := 74;
            RETURN;
          ELSE
            RESULTADO := 6;
            RETURN;
          END IF;
        End if;

        IF CONCEPTO = '02' THEN
          Begin
            Select 1
              into retiro
              from Rsgos_Rcbos_Nvdad, rsgos_vgntes_avlor
             where ren_cdgo_ampro = AMPARO
               and ren_nmro_item = NMRO_SLCTUD
               and ren_nmro_plza = NMRO_POLIZA
               and ren_clse_plza = CLASE_POLIZA
               and ren_ram_cdgo = RAMO
               and ren_nmro_crtfcdo = CERTIFICADO
               and ren_tpo_nvdad = TIPO_NOVEDAD
               and ren_cdgo_ampro = rvl_cdgo_ampro
               and ren_nmro_item = rvl_nmro_item
               and ren_nmro_plza = rvl_nmro_plza
               and ren_clse_plza = rvl_clse_plza
               and ren_ram_cdgo = rvl_ram_cdgo
               and rvl_cncpto_vlor = CONCEPTO;

            resultado := 12;
            return;
          Exception
            When no_data_found then
              null;
          End;

        else
          Begin
            select 1
              into retiro
              from Rsgos_Vgntes
             where rvi_nmro_item = NMRO_SLCTUD
               and rvi_nmro_plza = NMRO_POLIZA
               and rvi_clse_plza = CLASE_POLIZA
               and rvi_ram_cdgo = RAMO;
          Exception
            when no_data_found then
              resultado := 12;
              return;
          End;
        End if;

        If AUTOMATICO = 'S' Then
          Begin
            Select 1
              into canon_anterior
              from Rsgos_Vgntes_Avlor
             where rvl_cdgo_ampro = AMPARO
               and rvl_nmro_item = NMRO_SLCTUD
               and rvl_nmro_plza = NMRO_POLIZA
               and rvl_clse_plza = CLASE_POLIZA
               and rvl_ram_cdgo = RAMO
               and rvl_cncpto_vlor = CONCEPTO
               and rvl_vlor = VALOR;
          Exception
            when no_data_found Then
              Resultado := 5;
              return;
          End;
        END IF;

      else

        begin
          Select 1
            into retiro
            from Rsgos_Rcbos_Nvdad
           where ren_cdgo_ampro = AMPARO
             and ren_nmro_item = NMRO_SLCTUD
             and ren_nmro_plza = NMRO_POLIZA
             and ren_clse_plza = CLASE_POLIZA
             and ren_ram_cdgo = RAMO
             and ren_nmro_crtfcdo = CERTIFICADO
             and ren_tpo_nvdad = TIPO_NOVEDAD;

          resultado := 12;
          return;
        Exception
          When no_data_found then
            null;
        End;

      end if;

      --  Aumento Valor Asegurado
    Elsif TIPO_NOVEDAD = '04' Then

      --OBTIENE EL VALOR ASEGURADO ANTERIOR.
      Begin
        Select rvl_vlor
          into aumento
          from rsgos_vgntes_avlor
         where rvl_cdgo_ampro = AMPARO
           and rvl_nmro_item = NMRO_SLCTUD
           and rvl_nmro_plza = NMRO_POLIZA
           and rvl_clse_plza = CLASE_POLIZA
           and rvl_ram_cdgo = RAMO
           and rvl_cncpto_vlor = CONCEPTO;
      Exception
        when no_data_found Then
          aumento := 0;
      End;


      IF P_NOVEDAD_WEB = 'S' THEN
         V_FECHA_INGRESO := FECHA_INGRESO_SEG(NMRO_SLCTUD, NMRO_POLIZA,CLASE_POLIZA, RAMO,AMPARO);
         -- GCHL 27102014. Mantis 31013, se trunca la fecha de ingreso para que quede bien..
         IF TRUNC(FECHA_NOVEDAD) < ADD_MONTHS(TRUNC(V_FECHA_INGRESO),12)   THEN
            Resultado := 99;
            Return;
         END IF;

         IF CONCEPTO = '02' THEN
           IF VALOR = 0  AND AUMENTO != 0 THEN
             Resultado := 100;
            Return;
           END IF;
         END IF;
      END IF;


      IF CONCEPTO IN ( '01') THEN
          IF FUN_VALIDA_VALOR(AMPARO, RAMO, SUCURSAL, COMPANIA, VALOR) = 'N' THEN
            Resultado := 29;
            Return;
          END IF;
      END IF;


      IF MODULO = '2' THEN
        Juridico := NOVEDAD_JURIDICO_AMPARO(NMRO_SLCTUD, RAMO, AMPARO);
        If Juridico = 1 Then
          IF P_NOVEDAD_WEB = 'N' THEN
            RESULTADO := 6;
            RETURN;
          ELSE
            RESULTADO := 6;
            RETURN;
          END IF;
        End if;
      END IF;
      If AUTOMATICO = 'S' Then
        Begin
          Select 1
            into canon_anterior
            from Rsgos_Vgntes_Avlor
           where rvl_cdgo_ampro = AMPARO
             and rvl_nmro_item = NMRO_SLCTUD
             and rvl_nmro_plza = NMRO_POLIZA
             and rvl_clse_plza = CLASE_POLIZA
             and rvl_ram_cdgo = RAMO
             and rvl_cncpto_vlor = CONCEPTO
             and rvl_vlor = VALOR;
        Exception
          when no_data_found Then
            Resultado := 5;
            return;
        End;
      End If;
      
      IF(PI_TA_EXCEPCIONES.COUNT > 0) THEN
        IF(PI_TA_EXCEPCIONES(1) = '14') THEN
          flag_omitir_excepcion := 1;
        END IF;
      END IF;

      IF P_NOVEDAD_WEB = 'N' THEN
        Begin
          Select par_vlor2
            into parametro
            from Prmtros
           where par_cdgo = '2'
             and par_mdlo = '2'
             and par_vlor1 = 3
             and par_suc_cdgo = SUCURSAL
             and par_suc_cia_cdgo = COMPANIA;
          aumento := aumento + (aumento * parametro / 100);
          If (VALOR > aumento) AND flag_omitir_excepcion = 0 Then
            resultado := 14;
            return;
          End If;
          flag_omitir_excepcion := 0;
        Exception
          when no_data_found Then
            RESULTADO := '81';
            return;
        End;
      ELSE

        -- SE MODIFICO EL PAR_VLOR1 DE 3 POR 9 POR EL PORCENTAJE ES DIFERENTE EN LAS NOVEDADES WEB
        -- ESTO VERIFICA QUE NO SUPERE EL PORCENTAJE PERMITIDO PARA AUMENTOS.SPPC.24/07/2007.
        BEGIN
          SELECT PAR_VLOR2
            INTO PARAMETRO
            FROM PRMTROS
           WHERE PAR_CDGO = '2'
             AND PAR_MDLO = '2'
             AND PAR_VLOR1 = 9
             AND PAR_SUC_CDGO = SUCURSAL
             AND PAR_SUC_CIA_CDGO = COMPANIA;

          SELECT PAR_VLOR2
            INTO v_max_asegurado
            FROM PRMTROS
           WHERE PAR_CDGO = '2'
             AND PAR_MDLO = '2'
             AND PAR_VLOR1 = 14
             AND PAR_SUC_CDGO = SUCURSAL
             AND PAR_SUC_CIA_CDGO = COMPANIA;


      -- SE DEBE VALIDAR EL VALOR CONTRA LA TABLA DE AUMENTOS DE CADA RIESGO. SSPC. MANTIS 22658. 02/04/2014.
        BEGIN
          IF(PI_TA_EXCEPCIONES.COUNT > 0) THEN
            IF(PI_TA_EXCEPCIONES(1) = '14') THEN
              flag_omitir_excepcion := 1;
            END IF;
          END IF;
          IF  NVL(P_DESTINO_INMUEBLE,'S') = 'V' THEN
             V_VALOR := PKG_DETALLE_OPERACION.FUN_OBTENER_AUMENTO(NMRO_SLCTUD,CONCEPTO,FECHA_NOVEDAD);

             IF VALOR > V_VALOR THEN
               --SE DEBE PERMITIR AUMENTAR HASTA 100.000 MÁS DEL VALOR DE LA TABLA. SPPC. 03/09/2014
               IF VALOR > (V_VALOR + 100000) AND flag_omitir_excepcion = 0 THEN
                 Resultado := 14;
                 Return;
               END IF;
             END IF;
           END IF;


           /* aumento := aumento + (aumento * parametro / 100);
           If VALOR > aumento Then
              resultado := 14;
              return;
            End If;*/

            If VALOR > v_max_asegurado AND flag_omitir_excepcion = 0 Then
              resultado := 14;
              return;
            End If;

            -- Verifica que no haya pasado el porcentaje de parámetro en un año.   SSPC. MANTIS 22658. 02/04/2014.
            V_VALOR := PKG_DETALLE_OPERACION.FUN_AUMENTO_ANUAL(NMRO_SLCTUD,AMPARO,FECHA_NOVEDAD);

             Begin
               Select SUM(rvl_vlor)
                 into aumento
                 from rsgos_vgntes_avlor
                where rvl_cdgo_ampro = AMPARO
                  and rvl_nmro_item = NMRO_SLCTUD
                  and rvl_nmro_plza = NMRO_POLIZA
                  and rvl_clse_plza = CLASE_POLIZA
                  and rvl_ram_cdgo = RAMO;
             Exception
              when no_data_found Then
                aumento := 0;
             End;

            aumento := NVL(aumento,0) -  V_VALOR;
            aumento := aumento + (aumento * parametro / 100);

            IF TTAL_ASGRADO > AUMENTO AND flag_omitir_excepcion = 0 THEN
              IF V_VALOR > 0 THEN
                Resultado := 14;
              ELSE
                Resultado := 14;
              END IF;
              Return;
            END IF;
        --  END IF;
           flag_omitir_excepcion := 0;
         EXCEPTION
           WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20501,SQLERRM);
         END;



        Exception
          when no_data_found Then
            RESULTADO := '81';
            return;
        End;


        -- se DEBE VALIDAR QUE EL TOTAL ASEGURADO
        -- NO SUPERE TAMPOCO EL PORCENTAJE. SPPC. 03/03/2014
        IF TTAL_ASGRADO != 0 THEN
          BEGIN
            SELECT (R.CANON+ NVL(R.ADMON,0))
              INTO V_TOTAL_ANTERIOR
              FROM RASEGURADOS R
             WHERE R.PERIODO = TO_CHAR(ADD_MONTHS(FECHA_NOVEDAD,-1),'MMYYYY')
               AND R.SOLICITUD = NMRO_SLCTUD
               AND R.POLIZA    =  NMRO_POLIZA;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_TOTAL_ANTERIOR := 1;
          END;
          
          IF(PI_TA_EXCEPCIONES.COUNT > 0) THEN
            IF(PI_TA_EXCEPCIONES(1) = '14') THEN
              flag_omitir_excepcion := 1;
            END IF;
          END IF;
          porcentaje := round((ABS(TTAL_ASGRADO - (V_TOTAL_ANTERIOR)) * 100) / (V_TOTAL_ANTERIOR),0);
          If porcentaje > PARAMETRO AND flag_omitir_excepcion = 0  Then
            Resultado := 14;
            Return;
          END IF;

         If TTAL_ASGRADO > v_max_asegurado AND flag_omitir_excepcion = 0 Then
            resultado := 14;
            return;
          End If;
          flag_omitir_excepcion := 0;
        END IF;
      END IF;

      IF P_NOVEDAD_WEB = 'N' THEN
        Begin
          Select abs(trunc(months_between(FECHA_NOVEDAD, SYSDATE)))
            into meses
            from Dual;
        End;
        Begin
          Select par_vlor2
            into parametro
            from Prmtros
           where par_cdgo = '2'
             and par_mdlo = '2'
             and par_vlor1 = 5
             and par_suc_cdgo = SUCURSAL
             and par_suc_cia_cdgo = COMPANIA;
          If meses > parametro Then
            resultado := 20;
            return;
          End If;
        Exception
          when no_data_found Then
           RESULTADO := 82;
            return;
        End;

-- ESTO SE REEMPLZA POR LA DEFINICIÓN DE NOVEDADES WEB. MANTIS # 22658. SPPC.

--      ELSE
        -- SEGUN REUNION DEL 16/07/2007. SOLO SE DEBE PERMITIR UN AUMENTO POR AÑO.
        -- SPPC. 24/07/2007.
        -- Según las últimas pruebas de novedades se definio que el aumento se permita anual
        -- y sea validado desde la fecha de ingreso y durante 3 meses después. G.G. 29/09/2011.

        -- SE PONE EN CONMENTARIO PORQUE SEGUN MANTIS # 22568, SE PUEDE PERMITIR MAS DE UN AUMENTO
        -- POR AÑO. SPPC. 03/03/2014

       /*IF TIPO_AMPARO = 'B' THEN
          FECHA_ING := FECHA_INGRESO_SEG(NMRO_SLCTUD,
                                         NMRO_POLIZA,
                                         CLASE_POLIZA,
                                         RAMO,
                                         '01');
          IF FECHA_ING IS NULL THEN
            RESULTADO := 76;
            RETURN;
          END IF;

          IF TO_CHAR(FECHA_ING, 'YYYY') = TO_CHAR(FECHA_NOVEDAD, 'YYYY') THEN
            RESULTADO := 67;
            RETURN;
          ELSE
            FECHA := TO_DATE(TO_CHAR(FECHA_ING, 'DD/MM/') ||
                             TO_CHAR(SYSDATE, 'YYYY  '),
                             'DD/MM/YYYY');
            IF TRUNC(FECHA) > TRUNC(FECHA_NOVEDAD) THEN
              RESULTADO := 67;
              RETURN;
            ELSE
              FECHA_TEMP := ADD_MONTHS(FECHA, 3);
              IF TRUNC(FECHA_NOVEDAD) != TRUNC(FECHA) THEN
                IF TRUNC(FECHA_NOVEDAD) > FECHA_TEMP THEN
                  RESULTADO := 67;
                  RETURN;
                ELSE
                  SELECT COUNT(9)
                    INTO CANTIDAD_AUMENTOS
                    FROM RSGOS_VGNTES_NVDDES
                   WHERE RIVN_NMRO_ITEM = NMRO_SLCTUD
                     AND RIVN_NMRO_PLZA = NMRO_POLIZA
                     AND RIVN_CLSE_PLZA = CLASE_POLIZA
                     AND RIVN_RAM_CDGO = RAMO
                     AND RIVN_CDGO_AMPRO = AMPARO
                     AND RIVN_TPO_NVDAD = '04'
                     AND TRUNC(RIVN_FCHA_NVDAD) >= TRUNC(FECHA)
                     AND TRUNC(RIVN_FCHA_NVDAD) <= TRUNC(FECHA_TEMP)
                     AND RIVN_USRIO = USUARIO;
                  IF NVL(CANTIDAD_AUMENTOS, 0) > 0 THEN
                    RESULTADO := 67;
                    RETURN;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;*/

      END IF;

      -- NO PUEDEN ASEGURAR MENOS DEL MINIMO Y MAS DEL MAXIMO. SPPC. 24/07/2007.
      IF CONCEPTO = '01' THEN
        IF FUN_VALIDA_VALOR(AMPARO, RAMO, SUCURSAL, COMPANIA, VALOR) = 'N' THEN
          Resultado := 29;
          Return;
        END IF;
      END IF;
      -- Cambio de Inmbueble
    Elsif TIPO_NOVEDAD = '07' Then
      Begin
        Select min(rivn_fcha_nvdad)
          into fecha
          from rsgos_vgntes_nvddes
         where rivn_nmro_item = NMRO_SLCTUD
           and rivn_nmro_plza = NMRO_POLIZA
           and rivn_clse_plza = CLASE_POLIZA
           and rivn_ram_cdgo = RAMO
           and rivn_cdgo_ampro = AMPARO
           and rivn_tpo_nvdad = '01';
      Exception
        when no_data_found Then
          begin
            Select ren_fcha_nvdad
              into fecha
              from rsgos_rcbos_nvdad
             where ren_cdgo_ampro = AMPARO
               and ren_nmro_item = NMRO_SLCTUD
               and ren_nmro_plza = NMRO_POLIZA
               and ren_clse_plza = CLASE_POLIZA
               and ren_ram_cdgo = RAMO
               and ren_tpo_nvdad = '01';
          Exception
            When no_data_found then
              BEGIN
                SELECT rvi_fcha_dsde_actual
                  into fecha
                  from rsgos_vgntes
                 where rvi_nmro_item = NMRO_SLCTUD
                   and rvi_nmro_plza = NMRO_POLIZA
                   and rvi_clse_plza = CLASE_POLIZA
                   and rvi_ram_cdgo = RAMO;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  RAISE_APPLICATION_ERROR(-20505, 'No ha sido reportado el ingreso de la solicitud');
                  return;
              END;
          End;
      End;
      Begin
        Select par_vlor2
          into parametro
          from Prmtros
         where par_cdgo = '2'
           and par_mdlo = '2'
           and par_vlor1 = 6
           and par_suc_cdgo = SUCURSAL
           and par_suc_cia_cdgo = COMPANIA;
      Exception
        when no_data_found Then
          RESULTADO := 83;
          return;
      End;
      dias := fu_resta_mes30(fecha_novedad, fecha, mensaje);
      If mensaje is not null then
        return;
      else
        If dias > parametro Then
          resultado := 15;
          return;
        End If;
      End if;

      -- Cesion
    Elsif TIPO_NOVEDAD = '06' Then
      Juridico := NOVEDAD_JURIDICO(NMRO_SLCTUD, RAMO);
      If Juridico = 1 Then
        resultado := 74;
        return;
      End if;
      Begin
        Select 1
          into retirado
          from Rsgos_Rcbos
         where rir_nmro_item = NMRO_SLCTUD
           AND rir_nmro_plza = NMRO_POLIZA
           and rir_clse_plza = CLASE_POLIZA
           and rir_ram_cdgo = RAMO;
      Exception
        when no_data_found Then
          resultado := 13;
          return;
      End;
      Begin
        Select abs(trunc(months_between(FECHA_NOVEDAD, SYSDATE)))
          into meses
          from Dual;
      End;
      Begin
        Select par_vlor2
          into parametro
          from Prmtros
         where par_cdgo = '2'
           and par_mdlo = '2'
           and par_vlor1 = 7
           and par_suc_cdgo = SUCURSAL
           and par_suc_cia_cdgo = COMPANIA;
        If meses > parametro Then
          RESULTADO := 84;
          return;
        End If;
      Exception
        when no_data_found Then
          RESULTADO := 85;
          return;
      End;
      -- Reingreso
    Elsif TIPO_NOVEDAD = '05' Then
      Juridico := NOVEDAD_JURIDICO(NMRO_SLCTUD, RAMO);
      If Juridico = 1 Then
        BEGIN
          SELECT 'S'
            INTO PERMISO
            FROM ROLES_USRIOS
           WHERE RUS_CDGO_ROL = '111'
             AND RUS_CDGO_USRIO = USUARIO;
          IF P_NOVEDAD_WEB = 'N' THEN
            RESULTADO := 74;
            RETURN;
          ELSE
            RESULTADO := 74;
            RETURN;
          END IF;

          BEGIN
            INSERT INTO RSGOS_CON_SNSTROS
            VALUES
              (NMRO_SLCTUD,
               NMRO_POLIZA,
               CLASE_POLIZA,
               RAMO,
               AMPARO,
               USER,
               SYSDATE);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
          END;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            resultado := 6;
            return;
          WHEN OTHERS THEN
            MENSAJE := 'ERROR VALIDANDO JURIDICO ' || SQLERRM;
            RETURN;
        END;
      End if;

      Begin
        Select rvl_nmro_item
          into retirado
          from Rsgos_vgntes_avlor
         where rvl_cdgo_ampro = AMPARO
           and rvl_nmro_item = NMRO_SLCTUD
           AND rvl_nmro_plza = NMRO_POLIZA
           and rvl_clse_plza = CLASE_POLIZA
           and rvl_ram_cdgo = RAMO;
        resultado := 13;
        return;
      Exception
        when no_data_found Then
          null;
      End;
      Begin
        Select par_vlor2
          into parametro
          from Prmtros
         where par_cdgo = '2'
           and par_mdlo = '2'
           and par_vlor1 = 4
           and par_suc_cdgo = SUCURSAL
           and par_suc_cia_cdgo = COMPANIA;
      Exception
        when no_data_found Then
          RESULTADO := 86;
          return;
      End;
      Begin
        Select max(ren_fcha_nvdad)
          into fecha
          from Rsgos_Rcbos_Nvdad
         where ren_cdgo_ampro = AMPARO
           and ren_nmro_item = NMRO_SLCTUD
           and ren_nmro_plza = NMRO_POLIZA
           and ren_clse_plza = CLASE_POLIZA
           and ren_ram_cdgo = RAMO
           and ren_tpo_nvdad = '02';
        dias := abs(trunc(fecha - fecha_novedad));
      Exception
        when no_data_found Then
          resultado := 13;
          return;
      End;
      If dias > parametro Then
        resultado := 18;
        return;
      End If;
      -- SE ELIMINA PORQUE NO DEJA HACER LOS REINGRESOS DE AMPAROS. SPPC. 19/03/2014.
      /*If fecha = FECHA_NOVEDAD then
        resultado := 23;
        return;
      End if;*/

      -- SE INCLUYE PARA QUE VALIDE QUE CUANDO REINGRESEN NO INCLUYA HOGAR
      -- SI LA POLIZA NO ESTA MARCADA CON EL CONVENIO DE HOGAR O QUE
      -- EL DESTINO DEL INMUEBLE HAYA CAMBIADO. SPPC. 31/10/2012
      IF TIPO_AMPARO = 'A' Then
         V_AMPARO := NULL;
         IF FUN_TRFCION_EXTERNA(AMPARO,RAMO) = 'S' THEN
           IF FUN_ANEXO_HOGAR(NMRO_POLIZA) = 'N'THEN
             RESULTADO := 70;
             RETURN;
           END IF;

          -- VALIDACION TIPO INMUEBLE JRIO
          BEGIN
              SELECT SE.SES_TPO_INMBLE
                INTO V_TPO_INM
              FROM SLCTDES_ESTDIOS SE
              WHERE SES_NMRO = NMRO_SLCTUD;
          EXCEPTION WHEN OTHERS THEN
            V_TPO_INM := 'X';
          END;
          
           IF P_DESTINO_INMUEBLE != 'V' THEN
              IF P_DESTINO_INMUEBLE = 'C' AND V_TPO_INM IN ('L','O')  THEN
                 RESULTADO := NULL;
              ELSE
                 RESULTADO := 69;
                 RETURN;
              END IF;
           END IF;
        END IF;
      END IF;
    End If;

  END PRC_VALIDA_MANUAL;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_VALIDAR_ANULADO
  -- Purpose : Procedimiento que valida si existe arrndtrios anulados
  -- Modificado por:
  --
  --
  /***********************************************************************/
  PROCEDURE PRC_VALIDAR_ANULADO(SOLICITUD   ARRNDTRIOS.ARR_NMRO_SLCTUD%TYPE,
                                TIPO_AMPARO VARCHAR2,
                                AMPARO      RSGOS_VGNTES_AMPRO.RVA_CDGO_AMPRO%TYPE,
                                APROBACION  IN OUT NUMBER,
                                RESULTADO   IN OUT NUMBER) IS

    SOL_CAMBIO SLCTDES_ESTDIOS.SES_NMRO%TYPE;
    FECH       DATE;

  BEGIN
    BEGIN
      SELECT ARR_SES_NMRO
        INTO SOL_CAMBIO
        FROM ARRNDTRIOS
       WHERE ARR_NMRO_SLCTUD = SOLICITUD
         AND ARR_ESTDO = 'A';
      BEGIN
        SELECT MAX(REA_FCHA_RSLTDO)
          INTO FECH
          FROM RSLTDOS_ARRNDTRIOS
         WHERE REA_NMRO_SLCTUD = SOL_CAMBIO;
        IF FECH IS NOT NULL THEN
          BEGIN
            SELECT 1
              INTO APROBACION
              FROM RSLTDOS_ARRNDTRIOS, RSLTDO_ESTDIO
             WHERE REA_NMRO_SLCTUD = SOL_CAMBIO
               AND REA_FCHA_RSLTDO = FECH
               AND REA_TPO_RSLTDO = 'D'
               AND RET_NMRO_SLCTUD = SOL_CAMBIO
               AND RET_FCHA_RSLTDO = FECH
               AND RET_CDGO_RSLTDO IN ('01', '70', '71');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              APROBACION := 0;
              RESULTADO  := 8;
              RETURN;
            WHEN TOO_MANY_ROWS THEN
              IF TIPO_AMPARO = 'B' THEN
                APROBACION := 1;
              ELSE
                IF AMPARO = '04' THEN
                  RESULTADO := 48;
                  RETURN;
                ELSE
                  APROBACION := 1;
                END IF;
              END IF;
          END;
        ELSE
          RESULTADO := 8;
          RETURN;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          APROBACION := 0;
          RESULTADO  := 8;
          RETURN;
      END;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        APROBACION := 0;
        RESULTADO  := 8;
        RETURN;
    END;

  END PRC_VALIDAR_ANULADO;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_CALCULAR_RETROACTIVIDAD
  -- Purpose : Procedimiento que calcula las primas retoractivas de un riesgo
  -- cuando la fecha de ingreso es anterior al período vigente.
  -- Modificado por:
  --
  --
  /***********************************************************************/

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
                                                      MENSAJE               IN OUT VARCHAR2) IS

    MESES        NUMBER;
    FECHA_ACTUAL DATE;
    DIA          VARCHAR2(2);
    MES          VARCHAR2(2);
    ANO          VARCHAR2(4);

  BEGIN
    /*********************************************************************************************/
    /* CALCULAR SI EXISTE RETROACTIVIDAD PARA LA LIQUIDACION DE LAS PRIMAS*/
    /*********************************************************************************************/

    IF TIPO_TASA IN ('M', 'U') THEN
      MESES := 0;
      IF PRIMA_ANUAL != 0 or PRIMA_ANUAL_ANT != 0 THEN
        IF TO_DATE(TO_CHAR(FECHA_LIQUIDACION, 'MMYYYY'), 'MMYYYY') <
           TO_DATE(PERIODO, 'MMYYYY') THEN
          FECHA_ACTUAL          := TO_DATE('01' || '/' ||
                                           SUBSTR(PERIODO, 1, 2) || '/' ||
                                           SUBSTR(PERIODO, 3, 4),
                                           'DD/MM/YYYY');
          FECHA_ACTUAL          := LAST_DAY(FECHA_ACTUAL);
          meses                 := FU_RESTA_MES30(FECHA_ACTUAL,
                                                  FECHA_LIQUIDACION,
                                                  MENSAJE) / 30;
          PRIMA_RETRO_NETA      := PRIMA_NETA * (MESES - 1);
          PRIMA_RETRO_ANUAL     := PRIMA_ANUAL * (MESES - 1);
          PRIMA_RETRO_TOTAL     := PRIMA_TOTAL * (MESES - 1);
          IVA_RETRO             := IVA_PRIMA * (MESES - 1);
          PRIMA_RETRO_NETA_ANT  := PRIMA_NETA_ANT * (MESES - 1);
          PRIMA_RETRO_ANUAL_ANT := PRIMA_ANUAL_ANT * (MESES - 1);
          PRIMA_RETRO_TOTAL_ANT := PRIMA_TOTAL_ANT * (MESES - 1);
          IVA_RETRO_ANT         := IVA_PRIMA_ANT * (MESES - 1);
          DIA                   := TO_CHAR(FECHA_LIQUIDACION, 'DD');
          MES                   := TO_CHAR(FECHA_LIQUIDACION, 'MM');
          ANO                   := TO_CHAR(FECHA_LIQUIDACION, 'YYYY');
          FECHA_LIQUIDACION     := TO_DATE(DIA || '/' || MES || '/' || ANO || ' ' ||
                                           '01:01:00',
                                           'DD/MM/YYYY HH:MI:SS');
          IF MODULO = '3' THEN
            IF PRIMA_NETA < PRIMA_NETA_ANT THEN
              PRIMA_RETRO_NETA      := 0;
              PRIMA_RETRO_ANUAL     := 0;
              PRIMA_RETRO_TOTAL     := 0;
              IVA_RETRO             := 0;
              PRIMA_RETRO_NETA_ANT  := 0;
              PRIMA_RETRO_ANUAL_ANT := 0;
              PRIMA_RETRO_TOTAL_ANT := 0;
              IVA_RETRO_ANT         := 0;
              FECHA_LIQUIDACION     := FECHA_LIQUIDACION;
            END IF;
          END IF;
          IF CESION = 'SI' THEN
            PRIMA_RETRO_NETA      := 0;
            PRIMA_RETRO_ANUAL     := 0;
            PRIMA_RETRO_TOTAL     := 0;
            IVA_RETRO             := 0;
            PRIMA_RETRO_NETA_ANT  := 0;
            PRIMA_RETRO_ANUAL_ANT := 0;
            PRIMA_RETRO_TOTAL_ANT := 0;
            IVA_RETRO_ANT         := 0;
          END IF;
        ELSIF TO_DATE(TO_CHAR(FECHA_LIQUIDACION, 'MMYYYY'), 'MMYYYY') >
              TO_DATE(PERIODO, 'MMYYYY') THEN
          MENSAJE := 'La fecha de la Novedad no puede ser mayor al periodo actual.';
        END IF;
      END IF;
    END IF;
  END;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_INGRESOS
  -- Purpose : Procedimiento que realiza la inserción en las tablas de
  -- riesgos y copia a los históricos de riesgos en caso de novedades
  -- de modificación.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                                         MENSAJE         IN OUT VARCHAR2) IS

      NOVEDAD_RETIRO     VARCHAR2(2) := '02';
      NOVEDAD_AUMENTO    VARCHAR2(2) := '04';
      NOVEDAD_INGRESO    VARCHAR2(2) := '01';
      IDEN               NUMBER(12);
      TIPO               VARCHAR2(2);
      REFERENCIA         VARCHAR2(20);
      NMRO_BNES          NUMBER(5);
      VLOR_ASGRDO        NUMBER(18, 2);
      VLOR_ASGRDO_FLTNTE NUMBER(18, 2);
      VLOR_ASGRDO_TTAL   NUMBER(18, 2);
      COA                NUMBER(7, 5) := 0;
      PRMA_NTA           NUMBER(18, 2);
      PRMA_ANUAL         NUMBER(18, 2);
      DESDE              DATE;
      HASTA              DATE;
      DIAS               NUMBER(8);
      DSCNTO             NUMBER(4, 2);
      RCRGO              NUMBER(4, 2);
      VLOR_ASGRBLE       NUMBER(18, 2);
      DESCUENTO_ANT      NUMBER(4, 2);
      DESCUENTO          NUMBER(4, 2);
      RECARGO_ANT        NUMBER(4, 2);
      RECARGO            NUMBER(4, 2);
      ZONA_RIESGO        NUMBER(3) := 1;
    BEGIN
      IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) THEN
        BEGIN
          SELECT RVI_PRS_NMRO_IDNTFCCION,
                 RVI_PRS_TPO_IDNTFCCION,
                 RVI_CDGO_RFRNCIA,
                 RVI_NMRO_BNES,
                 RVI_VLOR_ASGRDO_BIEN,
                 RVI_VLOR_ASGRDO_TTAL,
                 RVI_VLOR_ASGRDO_FLTNTE,
                 RVI_PRCNTJE_CSGRO,
                 RVI_VLOR_PRMA_NTA,
                 RVI_VLOR_PRMA_ANUAL,
                 RVI_FCHA_DSDE_ACTUAL,
                 RVI_FCHA_HSTA_ACTUAL,
                 RVI_DIAS_VGNCIA_ACTUAL,
                 RVI_PRCNTJE_DSCNTO,
                 RVI_PRCNTJE_RCRGO,
                 RVI_VLOR_ASGRBLE
            INTO IDEN,
                 TIPO,
                 REFERENCIA,
                 NMRO_BNES,
                 VLOR_ASGRDO,
                 VLOR_ASGRDO_TTAL,
                 VLOR_ASGRDO_FLTNTE,
                 COA,
                 PRMA_NTA,
                 PRMA_ANUAL,
                 DESDE,
                 HASTA,
                 DIAS,
                 DSCNTO,
                 RCRGO,
                 VLOR_ASGRBLE
            FROM RSGOS_VGNTES
           WHERE RVI_NMRO_ITEM = SOLICITUD
             AND RVI_NMRO_PLZA = POLIZA
             AND RVI_CLSE_PLZA = CLASE_POLIZA
             AND RVI_RAM_CDGO = RAMO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            MENSAJE := 'LA SOLICITUD NO SE ENCUENTRA INGRESADA AL SEGURO.....2' || ' ' ||
                       SQLERRM;
            ROLLBACK;
            RETURN;
        END;
        UPDATE RSGOS_RCBOS
           SET RIR_NMRO_IDNTFCCION    = IDEN,
               RIR_TPO_IDNTFCCION     = TIPO,
               RIR_CDGO_RFRNCIA       = REFERENCIA,
               RIR_NMRO_BNES          = NMRO_BNES,
               RIR_VLOR_ASGRDO_BIEN   = VLOR_ASGRDO,
               RIR_VLOR_ASGRDO_TTAL   = VLOR_ASGRDO_TTAL,
               RIR_VLOR_ASGRDO_FLTNTE = VLOR_ASGRDO_FLTNTE,
               RIR_PRCNTJE_CSGRO      = COA,
               RIR_VLOR_PRMA_NTA      = PRMA_NTA,
               RIR_VLOR_PRMA_ANUAL    = PRMA_ANUAL,
               RIR_FCHA_DSDE_ACTUAL   = DESDE,
               RIR_FCHA_HSTA_ACTUAL   = HASTA,
               RIR_DIAS_VGNCIA_ACTUAL = DIAS,
               RIR_USRIO              = USUARIO,
               RIR_FCHA_MDFCCION      = SYSDATE,
               RIR_PRCNTJE_DSCNTO     = DSCNTO,
               RIR_PRCNTJE_RCRGO      = RCRGO,
               RIR_VLOR_ASGRBLE       = VLOR_ASGRBLE
         WHERE RIR_NMRO_ITEM = SOLICITUD
           AND RIR_NMRO_CRTFCDO = CERTIFICADO
           AND RIR_NMRO_PLZA = POLIZA
           AND RIR_CLSE_PLZA = CLASE_POLIZA
           AND RIR_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO RSGOS_RCBOS
              (RIR_NMRO_CRTFCDO,
               RIR_NMRO_PLZA,
               RIR_NMRO_ITEM,
               RIR_CLSE_PLZA,
               RIR_RAM_CDGO,
               RIR_NMRO_IDNTFCCION,
               RIR_TPO_IDNTFCCION,
               RIR_CDGO_RFRNCIA,
               RIR_NMRO_BNES,
               RIR_VLOR_ASGRDO_BIEN,
               RIR_VLOR_ASGRDO_TTAL,
               RIR_VLOR_ASGRDO_FLTNTE,
               RIR_PRCNTJE_CSGRO,
               RIR_VLOR_PRMA_NTA,
               RIR_VLOR_PRMA_ANUAL,
               RIR_FCHA_DSDE_ACTUAL,
               RIR_FCHA_HSTA_ACTUAL,
               RIR_DIAS_VGNCIA_ACTUAL,
               RIR_USRIO,
               RIR_FCHA_MDFCCION,
               RIR_PRCNTJE_DSCNTO,
               RIR_PRCNTJE_RCRGO,
               RIR_VLOR_ASGRBLE)
            VALUES
              (CERTIFICADO,
               POLIZA,
               SOLICITUD,
               CLASE_POLIZA,
               RAMO,
               IDEN,
               TIPO,
               REFERENCIA,
               NMRO_BNES,
               VLOR_ASGRDO,
               VLOR_ASGRDO_TTAL,
               VLOR_ASGRDO_FLTNTE,
               COA,
               PRMA_NTA,
               PRMA_ANUAL,
               DESDE,
               HASTA,
               DIAS,
               USUARIO,
               SYSDATE,
               DSCNTO,
               RCRGO,
               VLOR_ASGRBLE);
            IF SQL%NOTFOUND THEN
              MENSAJE := 'ERROR INSERTANDO EN RSGOS_RCBOS. ' || SQLERRM;
              ROLLBACK;
              RETURN;
            END IF;
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              MENSAJE := 'YA SE ENCUENTRA REGISTRADO EL RETIRO AL SEGURO DE LA SOLICITUD MENCIONADA.';
              ROLLBACK;
              RETURN;
            WHEN OTHERS THEN
              MENSAJE := 'ERROR INSERCION HISTORICO RSGOS_RCBOS' || ' ' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
      END IF;
      IF NOVEDAD = NOVEDAD_INGRESO THEN
        UPDATE RSGOS_VGNTES
           SET RVI_VLOR_ASGRDO_BIEN   = RVI_VLOR_ASGRDO_BIEN - VALOR_ANT + VALOR,
               RVI_VLOR_ASGRDO_TTAL   = RVI_VLOR_ASGRDO_TTAL - VALOR_ANT + VALOR,
               RVI_VLOR_ASGRDO_FLTNTE = RVI_VLOR_ASGRDO_FLTNTE - VALOR_ANT +
                                        VALOR,
               RVI_VLOR_ASGRBLE       = RVI_VLOR_ASGRBLE - VALOR_ANT + VALOR,
               RVI_VLOR_PRMA_NTA      = RVI_VLOR_PRMA_NTA - PRIMA_NETA_ANT +
                                        PRIMA_NETA,
               RVI_VLOR_PRMA_ANUAL    = RVI_VLOR_PRMA_ANUAL - PRIMA_ANUAL_ANT +
                                        PRIMA_ANUAL,
               --     RVI_FCHA_DSDE_ACTUAL   = FECHA_NOVEDAD,
               --             RVI_FCHA_HSTA_ACTUAL   = FECHA_NOVEDAD,
               RVI_USRIO          = USUARIO,
               RVI_FCHA_MDFCCION  = SYSDATE,
               RVI_PRCNTJE_DSCNTO = RVI_PRCNTJE_DSCNTO - DESCUENTO_ANT +
                                    DESCUENTO,
               RVI_PRCNTJE_RCRGO  = RVI_PRCNTJE_RCRGO - RECARGO_ANT + RECARGO
         WHERE RVI_NMRO_ITEM = SOLICITUD
           AND RVI_NMRO_PLZA = POLIZA
           AND RVI_CLSE_PLZA = CLASE_POLIZA
           AND RVI_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO RSGOS_VGNTES
              (RVI_NMRO_ITEM,
               RVI_NMRO_PLZA,
               RVI_CLSE_PLZA,
               RVI_RAM_CDGO,
               RVI_ZNA_RSGO,
               RVI_PRS_NMRO_IDNTFCCION,
               RVI_PRS_TPO_IDNTFCCION,
               RVI_NMRO_CRTFCDO,
               RVI_CDGO_RFRNCIA,
               RVI_NMRO_BNES,
               RVI_VLOR_ASGRDO_BIEN,
               RVI_VLOR_ASGRDO_TTAL,
               RVI_VLOR_ASGRDO_FLTNTE,
               RVI_PRCNTJE_CSGRO,
               RVI_VLOR_ASGRBLE,
               RVI_VLOR_PRMA_NTA,
               RVI_VLOR_PRMA_ANUAL,
               RVI_FCHA_DSDE_ACTUAL,
               RVI_FCHA_HSTA_ACTUAL,
               RVI_DIAS_VGNCIA_ACTUAL,
               RVI_USRIO,
               RVI_FCHA_MDFCCION,
               RVI_PRCNTJE_DSCNTO,
               RVI_PRCNTJE_RCRGO)
            VALUES
              (SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               RAMO,
               ZONA_RIESGO,
               NMRO_IDEN,
               TPO_IDEN,
               CERTIFICADO,
               0,
               1,
               VALOR_ASEGURADO,
               VALOR_ASEGURADO,
               VALOR_ASEGURADO,
               0,
               VALOR_ASEGURADO,
               PRIMA_NETA,
               PRIMA_ANUAL,
               FECHA_NOVEDAD,
               FECHA_NOVEDAD,
               0,
               USUARIO,
               SYSDATE,
               DESCUENTO,
               RECARGO);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              MENSAJE := 'YA SE ENCUENTRA REGISTRADO EL INGRESO AL SEGURO DE LA SOLICITUD MENCIONADA';
              ROLLBACK;
              RETURN;
            WHEN OTHERS THEN
              MENSAJE := 'NO SE PUDO REALIZAR LA NOVEDAD' || ' ' || SQLERRM;
              ROLLBACK;
              RETURN;
          END;
          BEGIN
            INSERT INTO SLCTDES_VGNTES
              (SVI_RAM_CDGO,
               SVI_NMRO_IDNTFCCION,
               SVI_TPO_IDNTFCCION,
               SVI_NMRO_PLZA,
               SVI_NMRO_ITEM,
               SVI_USRIO,
               SVI_FCHA_MDFCCION,
               SVI_CLSE_PLZA)
            VALUES
              (RAMO,
               NMRO_IDEN,
               TPO_IDEN,
               POLIZA,
               SOLICITUD,
               USUARIO,
               SYSDATE,
               CLASE_POLIZA);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR INSERCION SLCTDES_VGNTES' || ' ' || SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
      ELSE
        UPDATE RSGOS_VGNTES
           SET RVI_VLOR_ASGRDO_BIEN   = RVI_VLOR_ASGRDO_BIEN - VALOR_ANT + VALOR,
               RVI_VLOR_ASGRDO_TTAL   = RVI_VLOR_ASGRDO_TTAL - VALOR_ANT + VALOR,
               RVI_VLOR_ASGRDO_FLTNTE = RVI_VLOR_ASGRDO_FLTNTE - VALOR_ANT +
                                        VALOR,
               RVI_VLOR_ASGRBLE       = RVI_VLOR_ASGRBLE - VALOR_ANT + VALOR,
               RVI_VLOR_PRMA_NTA      = NVL(RVI_VLOR_PRMA_NTA,0) - NVL(PRIMA_NETA_ANT,0) +
                                        NVL(PRIMA_NETA,0),
               RVI_VLOR_PRMA_ANUAL    = NVL(RVI_VLOR_PRMA_ANUAL,0) - NVL(PRIMA_ANUAL_ANT,0) +
                                        NVL(PRIMA_ANUAL,0),
               --     RVI_FCHA_DSDE_ACTUAL   = FECHA_NOVEDAD,
               --             RVI_FCHA_HSTA_ACTUAL   = FECHA_NOVEDAD,
               RVI_USRIO          = USUARIO,
               RVI_FCHA_MDFCCION  = SYSDATE,
               RVI_PRCNTJE_DSCNTO = RVI_PRCNTJE_DSCNTO - DESCUENTO_ANT +
                                    DESCUENTO,
               RVI_PRCNTJE_RCRGO  = RVI_PRCNTJE_RCRGO - RECARGO_ANT + RECARGO
         WHERE RVI_NMRO_ITEM = SOLICITUD
           AND RVI_NMRO_PLZA = POLIZA
           AND RVI_CLSE_PLZA = CLASE_POLIZA
           AND RVI_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO RSGOS_VGNTES
              (RVI_NMRO_ITEM,
               RVI_NMRO_PLZA,
               RVI_CLSE_PLZA,
               RVI_RAM_CDGO,
               RVI_ZNA_RSGO,
               RVI_PRS_NMRO_IDNTFCCION,
               RVI_PRS_TPO_IDNTFCCION,
               RVI_NMRO_CRTFCDO,
               RVI_CDGO_RFRNCIA,
               RVI_NMRO_BNES,
               RVI_VLOR_ASGRDO_BIEN,
               RVI_VLOR_ASGRDO_TTAL,
               RVI_VLOR_ASGRDO_FLTNTE,
               RVI_PRCNTJE_CSGRO,
               RVI_VLOR_ASGRBLE,
               RVI_VLOR_PRMA_NTA,
               RVI_VLOR_PRMA_ANUAL,
               RVI_FCHA_DSDE_ACTUAL,
               RVI_FCHA_HSTA_ACTUAL,
               RVI_DIAS_VGNCIA_ACTUAL,
               RVI_USRIO,
               RVI_FCHA_MDFCCION,
               RVI_PRCNTJE_DSCNTO,
               RVI_PRCNTJE_RCRGO)
            VALUES
              (SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               RAMO,
               ZONA_RIESGO,
               NMRO_IDEN,
               TPO_IDEN,
               CERTIFICADO,
               0,
               1,
               VALOR_ASEGURADO,
               VALOR_ASEGURADO,
               VALOR_ASEGURADO,
               0,
               VALOR_ASEGURADO,
               PRIMA_NETA,
               PRIMA_ANUAL,
               FECHA_NOVEDAD,
               FECHA_NOVEDAD,
               0,
               USUARIO,
               SYSDATE,
               DESCUENTO,
               RECARGO);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              MENSAJE := 'YA SE ENCUENTRA REGISTRADO EL INGRESO AL SEGURO DE LA SOLICITUD MENCIONADA';
              ROLLBACK;
              RETURN;
            WHEN OTHERS THEN
              MENSAJE := 'NO SE PUDO REALIZAR LA NOVEDAD' || ' ' || SQLERRM;
              ROLLBACK;
              RETURN;
          END;
          BEGIN
            INSERT INTO SLCTDES_VGNTES
              (SVI_RAM_CDGO,
               SVI_NMRO_IDNTFCCION,
               SVI_TPO_IDNTFCCION,
               SVI_NMRO_PLZA,
               SVI_NMRO_ITEM,
               SVI_USRIO,
               SVI_FCHA_MDFCCION,
               SVI_CLSE_PLZA)
            VALUES
              (RAMO,
               NMRO_IDEN,
               TPO_IDEN,
               POLIZA,
               SOLICITUD,
               USUARIO,
               SYSDATE,
               CLASE_POLIZA);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR INSERCION SLCTDES_VGNTES' || ' ' || SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;

      END IF;
    END;



  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_ACTUALIZA_VALOR
  -- Purpose : Procedimiento que ingresa o actualiza los valores de los riesgos
  -- que se ingresan o modifican en el seguro. Hace una copia al historico de
  -- valores de riesgos por las modificaciones realizadas.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                                MENSAJE      IN OUT VARCHAR2) IS
    NOVEDAD_RETIRO    VARCHAR2(2) := '02';
    NOVEDAD_AUMENTO   VARCHAR2(2) := '04';
    CNCPTO_VLOR       VARCHAR2(4);
    VLOR              NUMBER;
    NOVEDAD_REINGRESO VARCHAR2(2) := '05';
  BEGIN
    IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) THEN
      BEGIN
        SELECT /*+ index(rvv  rvv_pk)   */
         rvv.RVV_CNCPTO_VLOR, rvv.RVV_VLOR
          INTO CNCPTO_VLOR, VLOR
          FROM RSGOS_VGNTES_VLRES rvv
         WHERE RVV.RVV_NMRO_ITEM = SOLICITUD
           AND rvv.RVV_NMRO_PLZA = POLIZA
           AND rvv.RVV_CLSE_PLZA = CLASE_POLIZA
           AND rvv.RVV_RAM_CDGO = RAMO
           AND rvv.RVV_CNCPTO_VLOR = CONCEPTO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          MENSAJE := 'LA SOLICITUD NO HA SIDO INGRESADA EN EL SEGURO ' ||
                     concepto || ' ' || SQLERRM;
          ROLLBACK;
          RETURN;
      END;
      UPDATE /*+  index(rhv  rhv_pk)   */ RSGOS_RCBO_VLOR rhv
         SET rhv.RHV_VLOR          = VALOR_ANT,
             rhv.RHV_FCHA_MDFCCION = SYSDATE,
             rhv.RHV_USRIO         = USUARIO
       WHERE rhv.RHV_NMRO_ITEM = SOLICITUD
         aND rhv.RHV_NMRO_PLZA = POLIZA
         AND rhv.RHV_CLSE_PLZA = CLASE_POLIZA
         AND rhv.RHV_RAM_CDGO = RAMO
         AND rhv.RHV_CDGO_AMPRO = AMPARO
         AND rhv.RHV_CNCPTO_VLOR = CONCEPTO
         aND rhv.RHV_NMRO_CRTFCDO = CERTIFICADO;
      IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO RSGOS_RCBO_VLOR
            (RHV_NMRO_CRTFCDO,
             RHV_NMRO_ITEM,
             RHV_CNCPTO_VLOR,
             RHV_RAM_CDGO,
             RHV_CDGO_AMPRO,
             RHV_NMRO_PLZA,
             RHV_CLSE_PLZA,
             RHV_VLOR,
             RHV_FCHA_MDFCCION,
             RHV_USRIO)
          VALUES
            (CERTIFICADO,
             SOLICITUD,
             CONCEPTO,
             RAMO,
             AMPARO,
             POLIZA,
             CLASE_POLIZA,
             VALOR_ANT,
             SYSDATE,
             USUARIO);
          IF SQL%NOTFOUND THEN
            MENSAJE := 'ERROR INSERCION HISTORICO RSGOS_RCBO_VLOR' || ' ' ||
                       SQLERRM;
            ROLLBACK;
            RETURN;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            --             MENSAJE:='ERROR INSERCION HISTORICO1 RSGOS_RCBO_VLOR'||' '||SQLERRM;
            --             ROLLBACK;
            --             RETURN;
            NULL;
        END;
      END IF;
    END IF;
    IF NOVEDAD != NOVEDAD_RETIRO THEN
      UPDATE /*+  index(rvv_pk)   */ RSGOS_VGNTES_VLRES rvv
         SET rvv.RVV_VLOR          = rvv.RVV_VLOR - VALOR_ANT + VALOR,
             rvv.RVV_USRIO         = USUARIO,
             rvv.RVV_FCHA_MDFCCION = SYSDATE
       WHERE rvv.RVV_NMRO_ITEM = SOLICITUD
         aND rvv.RVV_NMRO_PLZA = POLIZA
         AND rvv.RVV_CLSE_PLZA = CLASE_POLIZA
         AND rvv.RVV_RAM_CDGO = RAMO
         AND rvv.RVV_CNCPTO_VLOR = CONCEPTO;
      IF SQL%NOTFOUND THEN
        IF NOVEDAD = NOVEDAD_REINGRESO THEN
          BEGIN
            INSERT INTO RSGOS_VGNTES_VLRES
              (RVV_NMRO_ITEM,
               rVV_CNCPTO_VLOR,
               RVV_RAM_CDGO,
               RVV_NMRO_PLZA,
               RVV_CLSE_PLZA,
               RVV_VLOR,
               RVV_FCHA_MDFCCION,
               RVV_USRIO)
              SELECT /*+ index(rhv   rhv_pk)   */
               SOLICITUD,
               rhv.RHV_CNCPTO_VLOR,
               RAMO,
               POLIZA,
               CLASE_POLIZA,
               rhv.RHV_VLOR,
               SYSDATE,
               USUARIO
                FROM RSGOS_RCBO_VLOR rhv, CRTFCDOS
               WHERE rhv.RHV_NMRO_ITEM = SOLICITUD
                 AND rhv.RHV_NMRO_PLZA = POLIZA
                 AND rhv.RHV_CLSE_PLZA = CLASE_POLIZA
                 AND rhv.RHV_RAM_CDGO = RAMO
                 AND rhv.RHV_CDGO_AMPRO = AMPARO
                 AND rhv.RHV_CNCPTO_VLOR = CONCEPTO
                 AND CER_NMRO_CRTFCDO = rhv.RHV_NMRO_CRTFCDO
                 AND CER_NMRO_PLZA = rhv.RHV_NMRO_PLZA
                 AND CER_CLSE_PLZA = rhv.RHV_CLSE_PLZA
                 AND CER_FCHA_DSDE_ACTUAL =
                     (SELECT MAX(CER_FCHA_DSDE_ACTUAL)
                        FROM RSGOS_RCBO_VLOR, CRTFCDOS
                       WHERE RHV_NMRO_ITEM = SOLICITUD
                         AND RHV_NMRO_PLZA = POLIZA
                         AND RHV_CLSE_PLZA = CLASE_POLIZA
                         AND RHV_RAM_CDGO = RAMO
                         AND RHV_CDGO_AMPRO = AMPARO
                         AND RHV_CNCPTO_VLOR = CONCEPTO
                         AND CER_NMRO_CRTFCDO = RHV_NMRO_CRTFCDO
                         AND CER_NMRO_PLZA = RHV_NMRO_PLZA
                         AND CER_CLSE_PLZA = RHV_CLSE_PLZA);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR REINGRESO RSGOS_RCBO_VLOR' || ' ' || SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        ELSE
          BEGIN
            INSERT INTO RSGOS_VGNTES_VLRES
              (RVV_NMRO_ITEM,
               RVV_NMRO_PLZA,
               RVV_CLSE_PLZA,
               RVV_RAM_CDGO,
               RVV_CNCPTO_VLOR,
               RVV_VLOR,
               RVV_USRIO,
               RVV_FCHA_MDFCCION)
            VALUES
              (SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               RAMO,
               CONCEPTO,
               VALOR,
               USUARIO,
               SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR EN RIESGOS VIGENTES VALORES' || ' ' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
      END IF;
    END IF;
  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_ACTUALIZA_VALOR
  -- Purpose : Procedimiento que ingresa o actualiza los valores base de los riesgos
  -- que se ingresan o modifican en el seguro. Hace una copia al historico de
  -- valores de riesgos por las modificaciones realizadas.
  -- Modificado por:
  --
  --
  /***********************************************************************/

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
                                                MENSAJE      IN OUT VARCHAR2) IS
    NOVEDAD_RETIRO    VARCHAR2(2) := '02';
    NOVEDAD_REINGRESO VARCHAR2(2) := '05';
    VALOR_BASE        VARCHAR2(4);
    CNCPTO_VLOR       VARCHAR2(4);
    VLOR              NUMBER;
    FECHA             DATE;
  BEGIN
    IF AMPARO != '01' THEN
      BEGIN
        SELECT VPR_VLOR_BASE
          INTO VALOR_BASE
          FROM VLRES_PRDCTO
         WHERE VPR_RAM_CDGO = RAMO
           AND VPR_CDGO = CONCEPTO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          MENSAJE := 'NO SE ENCUENTRAN DEFINIDOS LOS VALORES PARA EL AMPARO.';
          ROLLBACK;
          RETURN;
      END;

      -- dbms_output.put_line('valor base  '||valor_base);
      IF NOVEDAD = NOVEDAD_REINGRESO AND ENTRO = 0 THEN
        BEGIN
          SELECT RHV_CNCPTO_VLOR, RHV_VLOR, MAX(CER_FCHA_DSDE_ACTUAL)
            INTO CNCPTO_VLOR, VLOR, FECHA
            FROM RSGOS_RCBO_VLOR, CRTFCDOS
           WHERE --RHV_NMRO_CRTFCDO = CERTIFICADO AND --DAP. Se encontro que el certificado no era el mismo para el reingreso 12/04/2007.
           RHV_NMRO_CRTFCDO =
           (SELECT MAX(RHV_NMRO_CRTFCDO)
              FROM RSGOS_RCBO_VLOR
             WHERE RHV_NMRO_ITEM = SOLICITUD
               AND RHV_NMRO_PLZA = POLIZA
               AND RHV_CLSE_PLZA = CLASE_POLIZA
               AND RHV_RAM_CDGO = RAMO
               AND RHV_CDGO_AMPRO = AMPARO
               AND RHV_CNCPTO_VLOR = VALOR_BASE)
           AND RHV_NMRO_ITEM = SOLICITUD
           AND RHV_NMRO_PLZA = POLIZA
           AND RHV_CLSE_PLZA = CLASE_POLIZA
           AND RHV_RAM_CDGO = RAMO
           AND RHV_CDGO_AMPRO = AMPARO
           AND RHV_CNCPTO_VLOR = VALOR_BASE
           AND CER_NMRO_CRTFCDO = RHV_NMRO_CRTFCDO
           AND CER_NMRO_PLZA = RHV_NMRO_PLZA
           AND CER_CLSE_PLZA = RHV_CLSE_PLZA
           GROUP BY RHV_CNCPTO_VLOR, RHV_VLOR;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            MENSAJE := 'ERROR EN ACTUALIZAR_VALORES.LA SOLICITUD NO HA SIDO INGRESADA EN EL SEGURO. ' ||
                       AMPARO || ' ' || SQLERRM;
            /*MENSAJE := 'Error. '||to_char(solicitud)||'/'||to_char(poliza)||'/'||clase_poliza||'/'||
            ramo||'/'||amparo||'/'||valor_base||sqlerrm;*/
            RETURN;
          WHEN OTHERS THEN
            MENSAJE := 'ERROR. << En Actualiza Valor >> ' || SQLERRM;
            RETURN;
        END;
        BEGIN
          INSERT INTO RSGOS_VGNTES_VLRES
            (RVV_NMRO_ITEM,
             RVV_CNCPTO_VLOR,
             RVV_RAM_CDGO,
             RVV_NMRO_PLZA,
             RVV_CLSE_PLZA,
             RVV_VLOR,
             RVV_FCHA_MDFCCION,
             RVV_USRIO)
          VALUES
            (SOLICITUD,
             VALOR_BASE,
             RAMO,
             POLIZA,
             CLASE_POLIZA,
             VLOR,
             SYSDATE,
             USUARIO);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR INSERCION HISTORICO RSGOS_RCBO_VLOR ' ||
                       SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;
      IF NOVEDAD = NOVEDAD_RETIRO AND ENTRO = 0 THEN

        IF CONCEPTO != '04' THEN
          BEGIN
            SELECT RVV_CNCPTO_VLOR, RVV_VLOR
              INTO CNCPTO_VLOR, VLOR
              FROM RSGOS_VGNTES_VLRES
             WHERE RVV_NMRO_ITEM = SOLICITUD
               AND RVV_NMRO_PLZA = POLIZA
               AND RVV_CLSE_PLZA = CLASE_POLIZA
               AND RVV_RAM_CDGO = RAMO
               AND RVV_CNCPTO_VLOR = VALOR_BASE;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              MENSAJE := 'LA SOLICITUD NO HA SIDO INGRESADA EN EL SEGU0RO4 ' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
          UPDATE RSGOS_RCBO_VLOR
             SET RHV_VLOR          = VLOR,
                 RHV_FCHA_MDFCCION = SYSDATE,
                 RHV_USRIO         = USUARIO
           WHERE RHV_NMRO_ITEM = SOLICITUD
             AND RHV_NMRO_PLZA = POLIZA
             AND RHV_CLSE_PLZA = CLASE_POLIZA
             AND RHV_RAM_CDGO = RAMO
             AND RHV_CDGO_AMPRO = AMPARO
             AND RHV_CNCPTO_VLOR = VALOR_BASE
             AND RHV_NMRO_CRTFCDO = CERTIFICADO;
          IF SQL%NOTFOUND THEN
            BEGIN
              INSERT INTO RSGOS_RCBO_VLOR
                (RHV_NMRO_CRTFCDO,
                 RHV_NMRO_ITEM,
                 RHV_CNCPTO_VLOR,
                 RHV_RAM_CDGO,
                 RHV_CDGO_AMPRO,
                 RHV_NMRO_PLZA,
                 RHV_CLSE_PLZA,
                 RHV_VLOR,
                 RHV_FCHA_MDFCCION,
                 RHV_USRIO)
              VALUES
                (CERTIFICADO,
                 SOLICITUD,
                 VALOR_BASE,
                 RAMO,
                 AMPARO,
                 POLIZA,
                 CLASE_POLIZA,
                 VLOR,
                 SYSDATE,
                 USUARIO);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR INSERCION RSGOS_RCBO_VLOR. VERIFIQUE VALOR BASE CONCEPTO ' || ' ' ||
                           CONCEPTO || 'AMPARO ' || AMPARO || sqlerrm;
                ROLLBACK;
                RETURN;
            END;
          END IF;
          DELETE RSGOS_VGNTES_VLRES
           WHERE RVV_NMRO_ITEM = SOLICITUD
             AND RVV_NMRO_PLZA = POLIZA
             AND RVV_CLSE_PLZA = CLASE_POLIZA
             AND RVV_RAM_CDGO = RAMO
             AND RVV_CNCPTO_VLOR = VALOR_BASE;
        END IF;
      END IF;
    END IF;
    IF NOVEDAD != NOVEDAD_RETIRO AND NOVEDAD != NOVEDAD_REINGRESO THEN
      IF VALOR_BASE != CONCEPTO THEN
        UPDATE RSGOS_VGNTES_VLRES
           SET RVV_VLOR          = RVV_VLOR - VALOR_ANT + VALOR,
               RVV_USRIO         = USUARIO,
               RVV_FCHA_MDFCCION = SYSDATE
         WHERE RVV_NMRO_ITEM = SOLICITUD
           AND RVV_NMRO_PLZA = POLIZA
           AND RVV_CLSE_PLZA = CLASE_POLIZA
           AND RVV_RAM_CDGO = RAMO
           AND RVV_CNCPTO_VLOR = VALOR_BASE;
        IF SQL%NOTFOUND THEN
          IF NOVEDAD = NOVEDAD_REINGRESO THEN
            BEGIN
              INSERT INTO RSGOS_VGNTES_VLRES
                (RVV_NMRO_ITEM,
                 RVV_CNCPTO_VLOR,
                 RVV_RAM_CDGO,
                 RVV_NMRO_PLZA,
                 RVV_CLSE_PLZA,
                 RVV_VLOR,
                 RVV_FCHA_MDFCCION,
                 RVV_USRIO)
                SELECT SOLICITUD,
                       RHV_CNCPTO_VLOR,
                       RAMO,
                       POLIZA,
                       CLASE_POLIZA,
                       RHV_VLOR,
                       SYSDATE,
                       USUARIO
                  FROM RSGOS_RCBO_VLOR
                 WHERE RHV_NMRO_ITEM = SOLICITUD
                   AND RHV_NMRO_PLZA = POLIZA
                   AND RHV_CLSE_PLZA = CLASE_POLIZA
                   AND RHV_RAM_CDGO = RAMO
                   AND RHV_CDGO_AMPRO = AMPARO
                   AND RHV_CNCPTO_VLOR = VALOR_BASE;
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR REINGRESO RSGOS_RCBO_VLOR' || ' ' ||
                           SQLERRM;
                ROLLBACK;
                RETURN;
            END;
          ELSE
            BEGIN
              INSERT INTO RSGOS_VGNTES_VLRES
                (RVV_NMRO_ITEM,
                 RVV_NMRO_PLZA,
                 RVV_CLSE_PLZA,
                 RVV_RAM_CDGO,
                 RVV_CNCPTO_VLOR,
                 RVV_VLOR,
                 RVV_USRIO,
                 RVV_FCHA_MDFCCION)
              VALUES
                (SOLICITUD,
                 POLIZA,
                 CLASE_POLIZA,
                 RAMO,
                 VALOR_BASE,
                 VALOR,
                 USUARIO,
                 SYSDATE);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR INSERCION RSGOS_VGNTES_VLRES';
                ROLLBACK;
                RETURN;
            END;
          END IF;
        END IF;
      END IF;
    END IF;
  END;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_ARRENDATARIOS
  -- Purpose : Procedimiento que ingresa o actualiza los asegurados de los riesgos
  -- que se ingresan o modifican en el seguro. Hace una copia al historico de
  -- asegurados de riesgos por las modificaciones realizadas.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                                            MENSAJE      IN OUT VARCHAR2) IS
    NOVEDAD_INGRESO   VARCHAR2(2) := '01';
    NOVEDAD_RETIRO    VARCHAR2(2) := '02';
    NOVEDAD_REINGRESO VARCHAR2(2) := '05';
    ARRENDAMIENTOS    VARCHAR2(2) := '01';
    TPO_IDEN          VARCHAR2(2);
    NMRO_IDEN         PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
    TPO_NIT           VARCHAR2(1);
    ESTA              VARCHAR2(1);
    CURSOR ARRENDATARIOS(SOLICITUD NUMBER) IS
      SELECT arr.ARR_NMRO_IDNTFCCION,
             arr.ARR_TPO_IDNTFCCION,
             arr.ARR_TPO_ARRNDTRIO
        FROM ARRNDTRIOS arr
       WHERE arr.ARR_SES_NMRO = SOLICITUD
         AND arr.ARR_ESTDO = 'V';
    CURSOR NITS_VIGENTES IS
      SELECT /*+  index(rvn  rvn_rvi_fk_i)   */
       rvn.RVN_PRS_NMRO_IDNTFCCION,
       rvn.RVN_PRS_TPO_IDNTFCCION,
       rvn.RVN_TPO_NIT
        FROM RSGOS_VGNTES_NITS rvn
       WHERE rvn.RVN_NMRO_ITEM = SOLICITUD
         and rvn.RVN_NMRO_PLZA = POLIZA
         AND rvn.RVN_CLSE_PLZA = CLASE_POLIZA
         AND rvn.RVN_RAM_CDGO = RAMO;
    CURSOR NITS_RETIRADOS IS
      SELECT /*+   index(rrn   rrn_rir_fk_i )  */
       rrn.RRN_NMRO_IDNTFCCION,
       rrn.RRN_TPO_IDNTFCCION,
       rrn.RRN_NMRO_ITEM,
       rrn.RRN_NMRO_PLZA,
       rrn.RRN_CLSE_PLZA,
       rrn.RRN_RAM_CDGO,
       rrn.RRN_TPO_NIT
        FROM RSGOS_RCBOS_NITS rrn
       WHERE rrn.RRN_NMRO_PLZA = POLIZA
         AND rrn.RRN_NMRO_ITEM = SOLICITUD
         AND rrn.RRN_CLSE_PLZA = CLASE_POLIZA
         AND rrn.RRN_RAM_CDGO = RAMO;

    V_SOLICITUD NUMBER;

  BEGIN
    IF NOVEDAD = NOVEDAD_INGRESO AND AMPARO = ARRENDAMIENTOS THEN
      IF ENTRO = 0 THEN
        BEGIN
          SELECT ARR_SES_NMRO
            INTO V_SOLICITUD
            FROM ARRNDTRIOS
           WHERE ARR_NMRO_SLCTUD = SOLICITUD;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            MENSAJE := 'LA SOLICITUD DE ESTUDIO NO SE ENCUENTRA ' || sqlerrm;
            ROLLBACK;
            RETURN;
        END;

        OPEN ARRENDATARIOS(V_SOLICITUD);
        LOOP
          FETCH ARRENDATARIOS
            INTO NMRO_IDEN, TPO_IDEN, TPO_NIT;
          IF ARRENDATARIOS%NOTFOUND THEN
            EXIT;
          ELSE
            --MOSTRAR_MENSAJE('INSERTANDO '||TO_CHAR(NMRO_IDEN)||' '||TPO_IDEN||' '||TPO_NIT,'E',FALSE);
            IF CONCEPTO = '01' THEN
              BEGIN
                BEGIN
                  ESTA := '0';
                  CLIENTE_RESTRINGIDO(TPO_IDEN, NMRO_IDEN, ESTA);
                  IF ESTA = '1' THEN
                    MENSAJE := 'El Arrendatario identificado como ' ||
                               NMRO_IDEN || ' es cliente restringido. ';
--                    ROLLBACK;
--                    RETURN;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    MENSAJE := 'ERROR EN CLIENTE RESTRINGIDO' ||
                               TO_CHAR(NMRO_IDEN) || ' ' || TPO_IDEN ||
                               SUBSTR(SQLERRM, 1, 50);
                    --MENSAJE:='Error consultando si el cliente es restringido. '||NMRO_IDEN;
                END;

                INSERT INTO RSGOS_VGNTES_NITS
                  (RVN_PRS_NMRO_IDNTFCCION,
                   RVN_PRS_TPO_IDNTFCCION,
                   RVN_NMRO_ITEM,
                   RVN_NMRO_PLZA,
                   RVN_CLSE_PLZA,
                   RVN_RAM_CDGO,
                   RVN_TPO_NIT,
                   RVN_USRIO,
                   RVN_FCHA_MDFCCION)
                VALUES
                  (NMRO_IDEN,
                   TPO_IDEN,
                   SOLICITUD,
                   POLIZA,
                   CLASE_POLIZA,
                   RAMO,
                   TPO_NIT,
                   USUARIO,
                   SYSDATE);
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
                WHEN OTHERS THEN
                  MENSAJE := 'LA SOLICITUD YA SE ENCUENTRA INGRESADA' ||
                             sqlerrm;
                  ROLLBACK;
                  RETURN;
              END;
            ELSE
              EXIT;
            END IF;
          END IF;
        END LOOP;
        CLOSE ARRENDATARIOS;
      END IF;
    END IF;

    IF NOVEDAD = NOVEDAD_RETIRO THEN
      IF ENTRO = 0 THEN
        OPEN NITS_VIGENTES;
        LOOP
          FETCH NITS_VIGENTES
            INTO NMRO_IDEN, TPO_IDEN, TPO_NIT;
          IF NITS_VIGENTES%NOTFOUND THEN
            EXIT;
          ELSE
            BEGIN
              INSERT INTO RSGOS_RCBOS_NITS
                (RRN_NMRO_IDNTFCCION,
                 RRN_TPO_IDNTFCCION,
                 RRN_NMRO_ITEM,
                 RRN_NMRO_PLZA,
                 RRN_CLSE_PLZA,
                 RRN_RAM_CDGO,
                 RRN_TPO_NIT,
                 RRN_USRIO,
                 RRN_FCHA_MDFCCION,
                 RRN_NMRO_CRTFCDO)
              VALUES
                (NMRO_IDEN,
                 TPO_IDEN,
                 SOLICITUD,
                 POLIZA,
                 CLASE_POLIZA,
                 RAMO,
                 TPO_NIT,
                 USUARIO,
                 SYSDATE,
                 CERTIFICADO);
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                NULL;
              WHEN OTHERS THEN
                MENSAJE := 'NO SE PUEDE RETIRAR EL NIT ' || sqlerrm;
                ROLLBACK;
                RETURN;
            END;
          END IF;
        END LOOP;
        CLOSE NITS_VIGENTES;
      END IF;
    END IF;
    IF NOVEDAD = NOVEDAD_REINGRESO THEN
      FOR REG_RETIRADOS IN NITS_RETIRADOS LOOP
        BEGIN
          INSERT INTO RSGOS_VGNTES_NITS
            (RVN_PRS_NMRO_IDNTFCCION,
             RVN_PRS_TPO_IDNTFCCION,
             RVN_NMRO_ITEM,
             RVN_NMRO_PLZA,
             RVN_CLSE_PLZA,
             RVN_RAM_CDGO,
             RVN_TPO_NIT,
             RVN_USRIO,
             RVN_FCHA_MDFCCION)
          VALUES
            (REG_RETIRADOS.RRN_NMRO_IDNTFCCION,
             REG_RETIRADOS.RRN_TPO_IDNTFCCION,
             REG_RETIRADOS.RRN_NMRO_ITEM,
             REG_RETIRADOS.RRN_NMRO_PLZA,
             REG_RETIRADOS.RRN_CLSE_PLZA,
             REG_RETIRADOS.RRN_RAM_CDGO,
             REG_RETIRADOS.RRN_TPO_NIT,
             USUARIO,
             SYSDATE);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            MENSAJE := 'NO SE PUEDE REINGRESAR LOS NIT';
            ROLLBACK;
            RETURN;
        END;
      END LOOP;
    END IF;
  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_AMPAROS
  -- Purpose : Procedimiento que ingresa o actualiza los amparos de los riesgos
  -- que se ingresan o modifican en el seguro. Hace una copia al historico de los
  -- amparos de riesgos por las modificaciones realizadas.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                                      MENSAJE             IN OUT VARCHAR2) IS
    NOVEDAD_RETIRO     VARCHAR2(2) := '02';
    NOVEDAD_AUMENTO    VARCHAR2(2) := '04';
    TIPO               VARCHAR2(2);
    IDEN               PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
    VLOR_ASGRDO_FLTNTE NUMBER(18, 2);
    VLOR_ASGRDO_TTAL   NUMBER(18, 2);
    PRMA_NTA           NUMBER(18, 2);
    PRMA_ANUAL         NUMBER(18, 2);
    DESDE              DATE;
    HASTA              DATE;
    DIAS               NUMBER(8);
    TPO_DDCBLE         VARCHAR2(5);
    TSA                NUMBER;
    TPO_TSA            VARCHAR2(1);
    DDCBLE             NUMBER;
    INDCE              NUMBER;
    MNMO_DDCBLE        NUMBER;
    BSE_INDCE          NUMBER;
    DSCNTO             NUMBER(4, 2);
    RCRGO              NUMBER(4, 2);
    BASE_INDICE        NUMBER := 0;
    PORC_INDICE        NUMBER := 0;
    PORCENTAJE_RECARGO NUMBER(4, 2);
  BEGIN
    IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) THEN
  --    IF ENTRO = 0 THEN
        BEGIN
          SELECT RVA_PRS_NMRO_IDNTFCCION,
                 RVA_PRS_TPO_IDNTFCCION,
                 RVA_VLOR_ASGRDO_TTAL,
                 RVA_VLOR_ASGRDO_FLTNTE,
                 NVL(RVA_VLOR_PRMA_NTA,0),
                 NVL(RVA_VLOR_PRMA_ANUAL,0),
                 RVA_FCHA_DSDE_ACTUAL,
                 RVA_FCHA_HSTA_ACTUAL,
                 RVA_DIAS_VGNCIA_ACTUAL,
                 RVA_TPO_TSA,
                 RVA_TSA_AMPRO,
                 RVA_PRCNTJE_DDCBLE,
                 RVA_TPO_DDCBLE,
                 RVA_MNMO_DDCBLE,
                 RVA_PRCNTJE_INDCE,
                 RVA_VLOR_BSE_INDCE,
                 RVA_PRCNTJE_DSCNTO,
                 RVA_PRCNTJE_RCRGO
            INTO IDEN,
                 TIPO,
                 VLOR_ASGRDO_TTAL,
                 VLOR_ASGRDO_FLTNTE,
                 PRMA_NTA,
                 PRMA_ANUAL,
                 DESDE,
                 HASTA,
                 DIAS,
                 TPO_TSA,
                 TSA,
                 DDCBLE,
                 TPO_DDCBLE,
                 MNMO_DDCBLE,
                 INDCE,
                 BSE_INDCE,
                 DSCNTO,
                 RCRGO
            FROM RSGOS_VGNTES_AMPRO
           WHERE RVA_NMRO_ITEM = SOLICITUD
             AND RVA_NMRO_PLZA = POLIZA
             AND RVA_CLSE_PLZA = CLASE_POLIZA
             AND RVA_RAM_CDGO = RAMO
             AND RVA_CDGO_AMPRO = AMPARO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            MENSAJE := 'LA SOLICITUD NO HA SIDO INGRESADA AL SEGURO';
            ROLLBACK;
            RETURN;
        END;
        UPDATE RSGOS_RCBOS_AMPRO
           SET RRA_NMRO_IDNTFCCION    = IDEN,
               RRA_TPO_IDNTFCCION     = TIPO,
               RRA_VLOR_ASGRDO_TTAL   = VLOR_ASGRDO_TTAL,
               RRA_VLOR_ASGRDO_FLTNTE = VLOR_ASGRDO_FLTNTE,
               RRA_VLOR_PRMA_NTA      = PRMA_NTA,
               RRA_VLOR_PRMA_ANUAL    = PRMA_ANUAL,
               RRA_FCHA_DSDE_ACTUAL   = DESDE,
               RRA_FCHA_HSTA_ACTUAL   = HASTA,
               RRA_DIAS_VGNCIA_ACTUAL = DIAS,
               RRA_TPO_TSA            = TPO_TSA,
               RRA_TSA_AMPRO          = TSA,
               RRA_PRCNTJE_DDCBLE     = DDCBLE,
               RRA_TPO_DDCBLE         = TPO_DDCBLE,
               RRA_MNMO_DDCBLE        = MNMO_DDCBLE,
               RRA_PRCNTJE_INDCE      = INDCE,
               RRA_VLOR_BSE_INDCE     = BSE_INDCE,
               RRA_USRIO              = USUARIO,
               RRA_FCHA_MDFCCION      = SYSDATE,
               RRA_PRCNTJE_DSCNTO     = DSCNTO,
               RRA_PRCNTJE_RCRGO      = RCRGO
         WHERE RRA_NMRO_ITEM = SOLICITUD
           AND RRA_NMRO_PLZA = POLIZA
           AND RRA_CLSE_PLZA = CLASE_POLIZA
           AND RRA_RAM_CDGO = RAMO
           AND RRA_CDGO_AMPRO = AMPARO
           AND RRA_NMRO_CRTFCDO = CERTIFICADO;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO RSGOS_RCBOS_AMPRO
              (RRA_CDGO_AMPRO,
               RRA_RAM_CDGO,
               RRA_NMRO_ITEM,
               RRA_NMRO_PLZA,
               RRA_CLSE_PLZA,
               RRA_NMRO_IDNTFCCION,
               RRA_TPO_IDNTFCCION,
               RRA_NMRO_CRTFCDO,
               RRA_VLOR_ASGRDO_TTAL,
               RRA_VLOR_ASGRDO_FLTNTE,
               RRA_VLOR_PRMA_NTA,
               RRA_VLOR_PRMA_ANUAL,
               RRA_FCHA_DSDE_ACTUAL,
               RRA_FCHA_HSTA_ACTUAL,
               RRA_DIAS_VGNCIA_ACTUAL,
               RRA_TPO_TSA,
               RRA_TSA_AMPRO,
               RRA_PRCNTJE_DDCBLE,
               RRA_TPO_DDCBLE,
               RRA_MNMO_DDCBLE,
               RRA_PRCNTJE_INDCE,
               RRA_VLOR_BSE_INDCE,
               RRA_USRIO,
               RRA_FCHA_MDFCCION,
               RRA_PRCNTJE_DSCNTO,
               RRA_PRCNTJE_RCRGO)
            VALUES
              (AMPARO,
               RAMO,
               SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               IDEN,
               TIPO,
               CERTIFICADO,
               VLOR_ASGRDO_TTAL,
               VLOR_ASGRDO_FLTNTE,
               PRMA_NTA,
               PRMA_ANUAL,
               DESDE,
               HASTA,
               DIAS,
               TPO_TSA,
               TSA,
               DDCBLE,
               TPO_DDCBLE,
               MNMO_DDCBLE,
               INDCE,
               BSE_INDCE,
               USUARIO,
               SYSDATE,
               DSCNTO,
               RCRGO);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR INSERCION HISTORICO RSGOS_RCBOS_AMPRO' || ' ' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
--      END IF;
    END IF;
    IF NOVEDAD = NOVEDAD_AUMENTO THEN
      IF CONCEPTO != '02' THEN
        UPDATE RSGOS_VGNTES_AMPRO
           SET RVA_NMRO_CRTFCDO       = CERTIFICADO,
               RVA_VLOR_ASGRDO_TTAL   = RVA_VLOR_ASGRDO_TTAL -
                                        VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               RVA_VLOR_ASGRDO_FLTNTE = RVA_VLOR_ASGRDO_FLTNTE -
                                        VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               RVA_VLOR_PRMA_NTA      = NVL(RVA_VLOR_PRMA_NTA,0) - NVL(PRIMA_NETA_ANT,0) +
                                        NVL(PRIMA_NETA,0),
               RVA_VLOR_PRMA_ANUAL    = NVL(RVA_VLOR_PRMA_ANUAL,0) - NVL(PRIMA_ANUAL_ANT,0) +
                                        NVL(PRIMA_ANUAL,0),
               RVA_FCHA_DSDE_ACTUAL   = FECHA_NOVEDAD,
               RVA_FCHA_HSTA_ACTUAL   = FECHA_NOVEDAD,
               RVA_TSA_AMPRO          = TASA,
               RVA_TPO_DDCBLE         = TPO_DEDUCIBLE,
               RVA_MNMO_DDCBLE        = MNMO_DEDUCIBLE,
               RVA_PRCNTJE_INDCE      = PORC_INDICE,
               RVA_VLOR_BSE_INDCE     = BASE_INDICE,
               RVA_USRIO              = USUARIO,
               RVA_FCHA_MDFCCION      = SYSDATE,
               RVA_PRCNTJE_DSCNTO     = PORC_DESCUENTO,
               RVA_PRCNTJE_RCRGO      = PORCENTAJE_RECARGO,
               RVA_PRCNTJE_DDCBLE     = IVA
         WHERE RVA_NMRO_ITEM = SOLICITUD
           AND RVA_NMRO_PLZA = POLIZA
           AND RVA_CLSE_PLZA = CLASE_POLIZA
           AND RVA_RAM_CDGO = RAMO
           AND RVA_CDGO_AMPRO = AMPARO;
      ELSE
        UPDATE RSGOS_VGNTES_AMPRO
           SET RVA_NMRO_CRTFCDO       = CERTIFICADO,
               RVA_VLOR_ASGRDO_TTAL   = RVA_VLOR_ASGRDO_TTAL -
                                        VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               RVA_VLOR_ASGRDO_FLTNTE = RVA_VLOR_ASGRDO_FLTNTE -
                                        VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               RVA_VLOR_PRMA_NTA      = NVL(RVA_VLOR_PRMA_NTA,0) - NVL(PRIMA_NETA_ANT,0) +
                                        NVL(PRIMA_NETA,0),
               RVA_VLOR_PRMA_ANUAL    = NVL(RVA_VLOR_PRMA_ANUAL,0) - NVL(PRIMA_ANUAL_ANT,0) +
                                        NVL(PRIMA_ANUAL,0),
               --   RVA_FCHA_DSDE_ACTUAL = FECHA_NOVEDAD,
               --   RVA_FCHA_HSTA_ACTUAL   = FECHA_NOVEDAD,
               --   RVA_TSA_AMPRO    = TASA,
               RVA_TPO_DDCBLE     = TPO_DEDUCIBLE,
               RVA_MNMO_DDCBLE    = MNMO_DEDUCIBLE,
               RVA_PRCNTJE_INDCE  = PORC_INDICE,
               RVA_VLOR_BSE_INDCE = BASE_INDICE,
               RVA_USRIO          = USUARIO,
               RVA_FCHA_MDFCCION  = SYSDATE,
               --   RVA_PRCNTJE_DSCNTO = PORC_DESCUENTO,
               RVA_PRCNTJE_RCRGO  = PORCENTAJE_RECARGO,
               RVA_PRCNTJE_DDCBLE = IVA
         WHERE RVA_NMRO_ITEM = SOLICITUD
           AND RVA_NMRO_PLZA = POLIZA
           AND RVA_CLSE_PLZA = CLASE_POLIZA
           AND RVA_RAM_CDGO = RAMO
           AND RVA_CDGO_AMPRO = AMPARO;
      END IF;
      IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO RSGOS_VGNTES_AMPRO
            (RVA_CDGO_AMPRO,
             RVA_RAM_CDGO,
             RVA_NMRO_ITEM,
             RVA_NMRO_PLZA,
             RVA_CLSE_PLZA,
             RVA_PRS_NMRO_IDNTFCCION,
             RVA_PRS_TPO_IDNTFCCION,
             RVA_NMRO_CRTFCDO,
             RVA_VLOR_ASGRDO_TTAL,
             RVA_VLOR_ASGRDO_FLTNTE,
             RVA_VLOR_PRMA_NTA,
             RVA_VLOR_PRMA_ANUAL,
             RVA_FCHA_DSDE_ACTUAL,
             RVA_FCHA_HSTA_ACTUAL,
             RVA_DIAS_VGNCIA_ACTUAL,
             RVA_TPO_TSA,
             RVA_TSA_AMPRO,
             RVA_PRCNTJE_DDCBLE,
             RVA_TPO_DDCBLE,
             RVA_MNMO_DDCBLE,
             RVA_PRCNTJE_INDCE,
             RVA_VLOR_BSE_INDCE,
             RVA_USRIO,
             RVA_FCHA_MDFCCION,
             RVA_PRCNTJE_DSCNTO,
             RVA_PRCNTJE_RCRGO)
          VALUES
            (AMPARO,
             RAMO,
             SOLICITUD,
             POLIZA,
             CLASE_POLIZA,
             NMRO_IDEN,
             TPO_IDEN,
             CERTIFICADO,
             VALOR_ASEGURADO,
             VALOR_ASEGURADO,
             PRIMA_NETA - PRIMA_NETA_ANT,
             PRIMA_ANUAL - PRIMA_ANUAL_ANT,
             FECHA_NOVEDAD,
             FECHA_NOVEDAD,
             0,
             TIPO_TASA,
             TASA,
             IVA,
             TPO_DEDUCIBLE,
             MNMO_DEDUCIBLE,
             PORC_INDICE,
             BASE_INDICE,
             USUARIO,
             SYSDATE,
             PORC_DESCUENTO,
             PORCENTAJE_RECARGO);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR INSERCION RSGOS_VGNTES_AMPRO ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;
    ELSE
      UPDATE RSGOS_VGNTES_AMPRO
         SET RVA_NMRO_CRTFCDO       = CERTIFICADO,
             RVA_VLOR_ASGRDO_TTAL   = RVA_VLOR_ASGRDO_TTAL -
                                      VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             RVA_VLOR_ASGRDO_FLTNTE = RVA_VLOR_ASGRDO_FLTNTE -
                                      VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
             RVA_VLOR_PRMA_NTA      = NVL(RVA_VLOR_PRMA_NTA,0) - NVL(PRIMA_NETA_ANT,0) +
                                      NVL(PRIMA_NETA,0),
             RVA_VLOR_PRMA_ANUAL    = NVL(RVA_VLOR_PRMA_ANUAL,0) - NVL(PRIMA_ANUAL_ANT,0) +
                                      NVL(PRIMA_ANUAL,0),
             RVA_TSA_AMPRO          = TASA,
             RVA_TPO_DDCBLE         = TPO_DEDUCIBLE,
             RVA_MNMO_DDCBLE        = MNMO_DEDUCIBLE,
             RVA_PRCNTJE_INDCE      = PORC_INDICE,
             RVA_VLOR_BSE_INDCE     = BASE_INDICE,
             RVA_USRIO              = USUARIO,
             RVA_FCHA_MDFCCION      = SYSDATE,
             RVA_PRCNTJE_DSCNTO     = PORC_DESCUENTO,
             RVA_PRCNTJE_RCRGO      = PORCENTAJE_RECARGO,
             RVA_PRCNTJE_DDCBLE     = IVA
       WHERE RVA_NMRO_ITEM = SOLICITUD
         AND RVA_NMRO_PLZA = POLIZA
         AND RVA_CLSE_PLZA = CLASE_POLIZA
         AND RVA_RAM_CDGO = RAMO
         AND RVA_CDGO_AMPRO = AMPARO;
      IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO RSGOS_VGNTES_AMPRO
            (RVA_CDGO_AMPRO,
             RVA_RAM_CDGO,
             RVA_NMRO_ITEM,
             RVA_NMRO_PLZA,
             RVA_CLSE_PLZA,
             RVA_PRS_NMRO_IDNTFCCION,
             RVA_PRS_TPO_IDNTFCCION,
             RVA_NMRO_CRTFCDO,
             RVA_VLOR_ASGRDO_TTAL,
             RVA_VLOR_ASGRDO_FLTNTE,
             RVA_VLOR_PRMA_NTA,
             RVA_VLOR_PRMA_ANUAL,
             RVA_FCHA_DSDE_ACTUAL,
             RVA_FCHA_HSTA_ACTUAL,
             RVA_DIAS_VGNCIA_ACTUAL,
             RVA_TPO_TSA,
             RVA_TSA_AMPRO,
             RVA_PRCNTJE_DDCBLE,
             RVA_TPO_DDCBLE,
             RVA_MNMO_DDCBLE,
             RVA_PRCNTJE_INDCE,
             RVA_VLOR_BSE_INDCE,
             RVA_USRIO,
             RVA_FCHA_MDFCCION,
             RVA_PRCNTJE_DSCNTO,
             RVA_PRCNTJE_RCRGO)
          VALUES
            (AMPARO,
             RAMO,
             SOLICITUD,
             POLIZA,
             CLASE_POLIZA,
             NMRO_IDEN,
             TPO_IDEN,
             CERTIFICADO,
             VALOR_ASEGURADO,
             VALOR_ASEGURADO,
             PRIMA_NETA - PRIMA_NETA_ANT,
             PRIMA_ANUAL - PRIMA_ANUAL_ANT,
             FECHA_NOVEDAD,
             FECHA_NOVEDAD,
             0,
             TIPO_TASA,
             TASA,
             IVA,
             TPO_DEDUCIBLE,
             MNMO_DEDUCIBLE,
             PORC_INDICE,
             BASE_INDICE,
             USUARIO,
             SYSDATE,
             PORC_DESCUENTO,
             PORCENTAJE_RECARGO);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR INSERCION RSGOS_VGNTES_AMPRO ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;

    END IF;
  END;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_ACTUALIZA_AMPAROS
  -- Purpose : Procedimiento que ingresa o actualiza los valores de los amparos
  -- de los riesgos que se ingresan o modifican en el seguro. Hace una copia
  -- al historico de los valores de los amparos de riesgos por las
  -- modificaciones realizadas.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                                  MENSAJE      IN OUT VARCHAR2) IS


    NOVEDAD_RETIRO    VARCHAR2(2) := '02';
    NOVEDAD_AUMENTO   VARCHAR2(2) := '04';
    NOVEDAD_REINGRESO VARCHAR2(2) := '05';
    CNCPTO_VLOR       VARCHAR2(4);
    VLOR              NUMBER;
    V_PRIMA           NUMBER;
    V_PRIMA_ANT       NUMBER;
    V_IVA             NUMBER;
    V_IVA_ANT         NUMBER;
    V_TASA            NUMBER;
  BEGIN

    IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) THEN
      BEGIN
        SELECT RVL_CNCPTO_VLOR,
               RVL_VLOR,
               A.RVL_PRIMA_NETA,
               A.RVL_PRIMA_NETA_ANT,
               A.RVL_VALOR_IVA,
               A.RVL_VALOR_IVA_ANT,
               A.RVL_TASA
          INTO CNCPTO_VLOR,
               VLOR,
               V_PRIMA,
               V_PRIMA_ANT,
               V_IVA,
               V_IVA_ANT,
               V_TASA
          FROM RSGOS_VGNTES_AVLOR A
         WHERE RVL_CDGO_AMPRO = AMPARO
           AND RVL_NMRO_ITEM = SOLICITUD
           AND RVL_NMRO_PLZA = POLIZA
           AND RVL_CLSE_PLZA = CLASE_POLIZA
           AND RVL_RAM_CDGO = RAMO
           AND RVL_CNCPTO_VLOR = CONCEPTO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          MENSAJE := 'LA SOLICITUD NO HA SIDO INGRESADA EN EL SEGURO1' || ' ' ||
                     SQLERRM;
          ROLLBACK;
          RETURN;
      END;
      UPDATE RSGOS_RCBOS_AVLOR V
         SET RAV_VLOR             = VLOR,
             V.RAV_PRIMA_NETA     = V_PRIMA,
             V.RAV_PRIMA_NETA_ANT = V_PRIMA_ANT,
             V.RAV_VALOR_IVA      = V_IVA,
             V.RAV_VALOR_IVA_ANT  = V_IVA_ANT,
             V.RAV_TASA           = V_TASA,
             RAV_USRIO            = USUARIO,
             RAV_FCHA_MDFCCION    = SYSDATE
       WHERE RAV_CDGO_AMPRO = AMPARO
         AND RAV_NMRO_ITEM = SOLICITUD
         AND RAV_NMRO_PLZA = POLIZA
         AND RAV_CLSE_PLZA = CLASE_POLIZA
         AND RAV_RAM_CDGO = RAMO
         AND RAV_CNCPTO_VLOR = CONCEPTO
         AND RAV_NMRO_CRTFCDO = CERTIFICADO;
      IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO RSGOS_RCBOS_AVLOR
            (RAV_NMRO_CRTFCDO,
             RAV_CDGO_AMPRO,
             RAV_RAM_CDGO,
             RAV_NMRO_ITEM,
             RAV_NMRO_PLZA,
             RAV_CLSE_PLZA,
             RAV_CNCPTO_VLOR,
             RAV_VLOR,
             RAV_USRIO,
             RAV_FCHA_MDFCCION,
             RAV_PRIMA_NETA,
             RAV_PRIMA_NETA_ANT,
             RAV_VALOR_IVA,
             RAV_VALOR_IVA_ANT,
             RAV_TASA)
          VALUES
            (CERTIFICADO,
             AMPARO,
             RAMO,
             SOLICITUD,
             POLIZA,
             CLASE_POLIZA,
             CNCPTO_VLOR,
             VLOR,
             USUARIO,
             SYSDATE,
             V_PRIMA,
             V_PRIMA_ANT,
             V_IVA,
             V_IVA_ANT,
             V_TASA);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR INSERCION HISTORICO RSGOS_RCBOS_AVLOR CUOTA' || ' ' ||
                       POLIZA || ' ' || CNCPTO_VLOR || ' ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;
    END IF;
    IF NOVEDAD != NOVEDAD_RETIRO THEN
   
      UPDATE RSGOS_VGNTES_AVLOR
         SET RVL_VLOR          = RVL_VLOR - VALOR_ANT + VALOR,
             RVL_PRIMA_NETA    = ROUND(PRIMA,2),
             RVL_PRIMA_NETA_ANT = ROUND(PRIMA_ANT,2),
             RVL_VALOR_IVA = ROUND(IVA,2),
             RVL_VALOR_IVA_ANT = ROUND(IVA_ANT,2),
             RVL_TASA = TASA,
             RVL_USRIO = USUARIO,
             RVL_FCHA_MDFCCION = SYSDATE
       WHERE RVL_CDGO_AMPRO = AMPARO
         AND RVL_NMRO_ITEM = SOLICITUD
         AND RVL_NMRO_PLZA = POLIZA
         AND RVL_CLSE_PLZA = CLASE_POLIZA
         AND RVL_RAM_CDGO = RAMO
         AND RVL_CNCPTO_VLOR = CONCEPTO;
      IF SQL%NOTFOUND THEN
        IF NOVEDAD = NOVEDAD_REINGRESO THEN
          BEGIN
            INSERT INTO RSGOS_VGNTES_AVLOR
              (RVL_CDGO_AMPRO,
               RVL_RAM_CDGO,
               RVL_NMRO_ITEM,
               RVL_NMRO_PLZA,
               RVL_CLSE_PLZA,
               RVL_CNCPTO_VLOR,
               RVL_VLOR,
               RVL_USRIO,
               RVL_FCHA_MDFCCION,
               RVL_PRIMA_NETA,
               RVL_PRIMA_NETA_ANT,
               RVL_VALOR_IVA,
               RVL_VALOR_IVA_ANT,
               RVL_TASA)
              SELECT AMPARO,
                     RAMO,
                     SOLICITUD,
                     POLIZA,
                     CLASE_POLIZA,
                     RAV_CNCPTO_VLOR,
                     RAV_VLOR,
                     USUARIO,
                     SYSDATE,
                     RAV_PRIMA_NETA,
                     RAV_PRIMA_NETA_ANT,
                     RAV_VALOR_IVA,
                     RAV_VALOR_IVA_ANT,
                     RAV_TASA
                FROM RSGOS_RCBOS_AVLOR, CRTFCDOS
               WHERE RAV_CDGO_AMPRO = AMPARO
                 AND RAV_NMRO_ITEM = SOLICITUD
                 AND RAV_NMRO_PLZA = POLIZA
                 AND RAV_CLSE_PLZA = CLASE_POLIZA
                 AND RAV_RAM_CDGO = RAMO
                 AND RAV_CNCPTO_VLOR = CONCEPTO
                 AND RAV_NMRO_CRTFCDO = CER_NMRO_CRTFCDO
                 AND CER_NMRO_PLZA = RAV_NMRO_PLZA
                 AND CER_CLSE_PLZA = RAV_CLSE_PLZA
                 AND CER_RAM_CDGO = RAV_RAM_CDGO
                 AND CER_FCHA_DSDE_ACTUAL =
                     (SELECT MAX(CER_FCHA_DSDE_ACTUAL)
                        FROM RSGOS_RCBOS_AVLOR, CRTFCDOS
                       WHERE RAV_CDGO_AMPRO = AMPARO
                         AND RAV_NMRO_ITEM = SOLICITUD
                         AND RAV_NMRO_PLZA = POLIZA
                         AND RAV_CLSE_PLZA = CLASE_POLIZA
                         AND RAV_RAM_CDGO = RAMO
                         AND RAV_CNCPTO_VLOR = CONCEPTO
                         AND CER_NMRO_CRTFCDO = RAV_NMRO_CRTFCDO
                         AND CER_NMRO_PLZA = RAV_NMRO_PLZA
                         AND CER_CLSE_PLZA = RAV_CLSE_PLZA);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR REINGRESO RSGOS_VGNTES_AVLOR CANON' || ' ' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        ELSE
          BEGIN
            INSERT INTO RSGOS_VGNTES_AVLOR
              (RVL_CDGO_AMPRO,
               RVL_RAM_CDGO,
               RVL_NMRO_ITEM,
               RVL_NMRO_PLZA,
               RVL_CLSE_PLZA,
               RVL_CNCPTO_VLOR,
               RVL_VLOR,
               RVL_USRIO,
               RVL_FCHA_MDFCCION,
               RVL_PRIMA_NETA,
               RVL_PRIMA_NETA_ANT,
               RVL_VALOR_IVA,
               RVL_VALOR_IVA_ANT,
               RVL_TASA)
            VALUES
              (AMPARO,
               RAMO,
               SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               CONCEPTO,
               VALOR,
               USUARIO,
               SYSDATE,
               ROUND(PRIMA,2),
               ROUND(PRIMA_ANT,2),
               ROUND(IVA,2),
               ROUND(IVA_ANT,2),
               TASA);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR INSERCION RSGOS_VGNTES_AVLOR AMPARO....' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
      END IF;
    END IF;
  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_INSERTA_NOVEDAD
  -- Purpose : Procedimiento que ingresa o actualiza la novedad del seguro
  -- que se realiza al riesgo. Hace una copia al historico de la novedade
  -- del riesgo por las modificaciones realizadas.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                                              MENSAJE             IN OUT VARCHAR2) IS

    NOVEDAD_RETIRO    VARCHAR2(2) := '02';
    NOVEDAD_AUMENTO   VARCHAR2(2) := '04';
    NOVEDAD_REINGRESO VARCHAR2(2) := '05';
    NOVEDAD_INGRESO   VARCHAR2(2) := '01';
    FCHA_NVDAD        DATE;
    TPO_NVDAD         VARCHAR2(2);
    VLOR              NUMBER := 0;
    USUA              VARCHAR2(30);
    FCHA              DATE;

    CURSOR NOVEDADES(SOLICITUD NUMBER) IS
      SELECT RIVN_FCHA_NVDAD,
             RIVN_TPO_NVDAD,
             RIVN_VLOR_DFRNCIA,
             RIVN_USRIO,
             RIVN_FCHA_MDFCCION
        FROM RSGOS_VGNTES_NVDDES
       WHERE RIVN_NMRO_ITEM = SOLICITUD
         AND RIVN_NMRO_PLZA = POLIZA
         AND RIVN_CLSE_PLZA = CLASE_POLIZA
         AND RIVN_RAM_CDGO = RAMO
         AND RIVN_CDGO_AMPRO = AMPARO;

  BEGIN
    IF (NOVEDAD = NOVEDAD_RETIRO) AND ENTRO = 0 THEN
      OPEN NOVEDADES(SOLICITUD);
      LOOP
        FETCH NOVEDADES
          INTO FCHA_NVDAD, TPO_NVDAD, VLOR, USUA, FCHA;
        IF NOVEDADES%NOTFOUND THEN
          EXIT;
        ELSE
          IF TPO_NVDAD = '02' THEN
            BEGIN
              INSERT INTO RSGOS_RCBOS_NVDAD
                (REN_NMRO_CRTFCDO,
                 REN_FCHA_NVDAD,
                 REN_CDGO_AMPRO,
                 REN_RAM_CDGO,
                 REN_NMRO_ITEM,
                 REN_NMRO_PLZA,
                 REN_CLSE_PLZA,
                 REN_TPO_NVDAD,
                 REN_VLOR_DFRNCIA,
                 REN_FCHA_MDFCCION,
                 REN_USRIO)
              VALUES
                (CERTIFICADO,
                 FCHA_NVDAD,
                 AMPARO,
                 RAMO,
                 SOLICITUD,
                 POLIZA,
                 CLASE_POLIZA,
                 TPO_NVDAD,
                 VLOR,
                 FCHA,
                 USUARIO);
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
          ELSE
            BEGIN
              INSERT INTO RSGOS_RCBOS_NVDAD
                (REN_NMRO_CRTFCDO,
                 REN_FCHA_NVDAD,
                 REN_CDGO_AMPRO,
                 REN_RAM_CDGO,
                 REN_NMRO_ITEM,
                 REN_NMRO_PLZA,
                 REN_CLSE_PLZA,
                 REN_TPO_NVDAD,
                 REN_VLOR_DFRNCIA,
                 REN_FCHA_MDFCCION,
                 REN_USRIO)
              VALUES
                (CERTIFICADO,
                 FCHA_NVDAD,
                 AMPARO,
                 RAMO,
                 SOLICITUD,
                 POLIZA,
                 CLASE_POLIZA,
                 TPO_NVDAD,
                 VLOR,
                 FCHA,
                 USUA);
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
          END IF;
        END IF;
      END LOOP;
      CLOSE NOVEDADES;
    END IF;
    IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) THEN
      UPDATE RSGOS_RCBOS_NVDAD
         SET REN_VLOR_DFRNCIA  = REN_VLOR_DFRNCIA + VALOR - VALOR_ANT,
             REN_FCHA_MDFCCION = FECHA_PERIODO,
             REN_USRIO         = USUARIO
       WHERE REN_CDGO_AMPRO = AMPARO
         AND REN_NMRO_ITEM = SOLICITUD
         AND REN_NMRO_PLZA = POLIZA
         AND REN_CLSE_PLZA = CLASE_POLIZA
         AND REN_RAM_CDGO = RAMO
         AND TRUNC(REN_FCHA_NVDAD) = TRUNC(FECHA_NOVEDAD)
         AND REN_NMRO_CRTFCDO = CERTIFICADO
         AND REN_TPO_NVDAD = NOVEDAD;
      IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO RSGOS_RCBOS_NVDAD
            (REN_NMRO_CRTFCDO,
             REN_FCHA_NVDAD,
             REN_CDGO_AMPRO,
             REN_RAM_CDGO,
             REN_NMRO_ITEM,
             REN_NMRO_PLZA,
             REN_CLSE_PLZA,
             REN_TPO_NVDAD,
             REN_VLOR_DFRNCIA,
             REN_FCHA_MDFCCION,
             REN_USRIO)
          VALUES
            (CERTIFICADO,
             FECHA_NOVEDAD,
             AMPARO,
             RAMO,
             SOLICITUD,
             POLIZA,
             CLASE_POLIZA,
             NOVEDAD,
             VALOR - VALOR_ANT,
             FECHA_PERIODO,
             USUARIO);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'Solo puede registrar una novedad por periodo33333.' ||
                       sqlerrm;
            ROLLBACK;
            RETURN;
        END;
      END IF;
    END IF;
    IF NOVEDAD != NOVEDAD_RETIRO THEN
      IF NOVEDAD = NOVEDAD_AUMENTO THEN
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + VALOR - VALOR_ANT,
                 RIVN_USRIO        = USUARIO
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = AMPARO
             AND RIVN_TPO_NVDAD = NOVEDAD
             AND RIVN_FCHA_NVDAD = FECHA_NOVEDAD;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR ACTUALIZANDO RSGOS VGNTES NVDDES ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      ELSE
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + VALOR - VALOR_ANT,
                 RIVN_USRIO        = USUARIO
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = AMPARO
             AND RIVN_TPO_NVDAD = NOVEDAD
             AND TRUNC(RIVN_FCHA_NVDAD) = TRUNC(FECHA_NOVEDAD);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR ACTUALIZANDO RSGOS VGNTES NVDDES ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;
      IF SQL%NOTFOUND THEN
        BEGIN
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
            (FECHA_NOVEDAD,
             AMPARO,
             RAMO,
             SOLICITUD,
             POLIZA,
             CLASE_POLIZA,
             NOVEDAD,
             VALOR - VALOR_ANT,
             FECHA_PERIODO,
             USUARIO);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            MENSAJE := 'Solamente se puede ingresar una novedad por periodo';
            ROLLBACK;
            RETURN;
          WHEN OTHERS THEN
            MENSAJE := sqlerrm;
            ROLLBACK;
            RETURN;
        END;
      END IF;
    END IF;
    IF (NOVEDAD = NOVEDAD_AUMENTO OR NOVEDAD = NOVEDAD_RETIRO) THEN
      UPDATE RSGOS_RCBOS_NVLOR
         SET RNV_VLOR          = VALOR_ANT,
             RNV_USRIO         = USUARIO,
             RNV_FCHA_MDFCCION = FECHA_PERIODO
       WHERE RNV_CDGO_AMPRO = AMPARO
         AND RNV_NMRO_ITEM = SOLICITUD
         AND RNV_NMRO_PLZA = POLIZA
         AND RNV_CLSE_PLZA = CLASE_POLIZA
         AND RNV_RAM_CDGO = RAMO
         AND RNV_CNCPTO_VLOR = CONCEPTO
         AND TRUNC(RNV_FCHA_NVDAD) = TRUNC(FECHA_NOVEDAD)
         AND RNV_NMRO_CRTFCDO = CERTIFICADO;
      IF SQL%NOTFOUND THEN
        /*    IF NOVEDAD = NOVEDAD_AUMENTO THEN
          BEGIN
           SELECT  RVNV_CNCPTO_VLOR, RVNV_VLOR INTO CNCPTO_VLOR, VLOR
             FROM  RSGOS_VGNTES_NVLOR
            WHERE  RVNV_NMRO_ITEM = SOLICITUD
        AND RVNV_NMRO_PLZA  = POLIZA
        AND RVNV_CLSE_PLZA  = CLASE_POLIZA
              AND RVNV_RAM_CDGO = RAMO
              AND RVNV_CDGO_AMPRO = AMPARO
          AND RVNV_CNCPTO_VLOR  = CONCEPTO;
          EXCEPTION  WHEN OTHERS THEN
            MENSAJE:='ERROR HISTORICO RSGOS_RCBOS_NVLOR '||' '||SQLERRM;
            ROLLBACK;
            RETURN;
          END;
          END IF;*/
        INSERT INTO RSGOS_RCBOS_NVLOR
          (RNV_NMRO_CRTFCDO,
           RNV_FCHA_NVDAD,
           RNV_CDGO_AMPRO,
           RNV_RAM_CDGO,
           RNV_NMRO_ITEM,
           RNV_NMRO_PLZA,
           RNV_CLSE_PLZA,
           RNV_CNCPTO_VLOR,
           RNV_VLOR,
           RNV_USRIO,
           RNV_FCHA_MDFCCION)
        VALUES
          (CERTIFICADO,
           FECHA_NOVEDAD,
           AMPARO,
           RAMO,
           SOLICITUD,
           POLIZA,
           CLASE_POLIZA,
           CONCEPTO,
           VALOR_ANT,
           USUARIO,
           FECHA_PERIODO);
        IF SQL%NOTFOUND THEN
          MENSAJE := 'ERROR INSERTANDO LOS VALORES DEL HISTORICO' || ' ' ||
                     SQLERRM;
          ROLLBACK;
          RETURN;
        END IF;
      END IF;
    END IF;
    IF NOVEDAD != NOVEDAD_RETIRO THEN
      IF NOVEDAD = NOVEDAD_INGRESO AND REGISTRAR = 'NO' THEN
        BEGIN
          UPDATE /*+ INDEX (RSGOS_VGNTES_NVLOR RVNV_PK) */ RSGOS_VGNTES_NVLOR
             SET RVNV_VLOR         = VALOR,
                 RVNV_USRIO        = USUARIO,
                 RVNV_FCH_MDFCCION = FECHA_NOVEDAD
           WHERE RVNV_NMRO_ITEM = SOLICITUD
             AND RVNV_NMRO_PLZA = POLIZA
             AND RVNV_CLSE_PLZA = CLASE_POLIZA
             AND RVNV_RAM_CDGO = RAMO
             AND RVNV_CDGO_AMPRO = AMPARO
             AND RVNV_CNCPTO_VLOR = CONCEPTO
             AND TRUNC(RVNV_FCHA_NVDAD) = TRUNC(FECHA_NOVEDAD);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR ACTUALIZANDO RSGOS VGNTES NVLOR1 ' || ' ' ||
                       SQLERRM;
            ROLLBACK;
            RETURN;
        END;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO RSGOS_VGNTES_NVLOR
              (RVNV_FCHA_NVDAD,
               RVNV_CDGO_AMPRO,
               RVNV_RAM_CDGO,
               RVNV_NMRO_ITEM,
               RVNV_NMRO_PLZA,
               RVNV_CLSE_PLZA,
               RVNV_CNCPTO_VLOR,
               RVNV_VLOR,
               RVNV_USRIO,
               RVNV_FCH_MDFCCION)
            VALUES
              (FECHA_NOVEDAD,
               AMPARO,
               RAMO,
               SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               CONCEPTO,
               VALOR,
               USUARIO,
               FECHA_NOVEDAD);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR INGRESO RSGOS_VGNTES_NVLOR1' || ' ' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
      ELSE
        BEGIN
          UPDATE /*+ INDEX (RSGOS_VGNTES_NVLOR,RVNV_PK)*/ RSGOS_VGNTES_NVLOR
             SET RVNV_VLOR         = VALOR,
                 RVNV_USRIO        = USUARIO,
                 RVNV_FCH_MDFCCION = FECHA_PERIODO
           WHERE RVNV_NMRO_ITEM = SOLICITUD
             AND RVNV_NMRO_PLZA = POLIZA
             AND RVNV_CLSE_PLZA = CLASE_POLIZA
             AND RVNV_RAM_CDGO = RAMO
             AND RVNV_CDGO_AMPRO = AMPARO
             AND RVNV_CNCPTO_VLOR = CONCEPTO
             AND TRUNC(RVNV_FCHA_NVDAD) = TRUNC(FECHA_NOVEDAD);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR ACTUALIZANDO RSGOS VGNTES NVLOR1 ' || ' ' ||
                       SQLERRM;
            ROLLBACK;
            RETURN;
        END;
        IF SQL%NOTFOUND THEN
          IF NOVEDAD = NOVEDAD_REINGRESO THEN
            BEGIN
              SELECT RNV_VLOR
                INTO VLOR
                FROM RSGOS_RCBOS_NVLOR
               WHERE RNV_CDGO_AMPRO = AMPARO
                 AND RNV_NMRO_ITEM = SOLICITUD
                 AND RNV_NMRO_PLZA = POLIZA
                 AND RNV_CLSE_PLZA = CLASE_POLIZA
                 AND RNV_RAM_CDGO = RAMO
                 AND RNV_CNCPTO_VLOR = CONCEPTO
                 AND TRUNC(RNV_FCHA_NVDAD) =
                     (SELECT MAX(TRUNC(RNV_FCHA_NVDAD))
                        FROM RSGOS_RCBOS_NVLOR
                       WHERE RNV_CDGO_AMPRO = AMPARO
                         AND RNV_NMRO_ITEM = SOLICITUD
                         AND RNV_NMRO_PLZA = POLIZA
                         AND RNV_CLSE_PLZA = CLASE_POLIZA
                         AND RNV_RAM_CDGO = RAMO
                         AND RNV_CNCPTO_VLOR = CONCEPTO);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                MENSAJE := 'NO ENCONTRO';
                ROLLBACK;
                RETURN;
              WHEN OTHERS THEN
                MENSAJE := 'ERROR REINGRESO RSGOS_VGNTES_NVLOR' || ' ' ||
                           SQLERRM;
                ROLLBACK;
                RETURN;
            END;
            BEGIN
              INSERT INTO RSGOS_VGNTES_NVLOR
                (RVNV_FCHA_NVDAD,
                 RVNV_CDGO_AMPRO,
                 RVNV_RAM_CDGO,
                 RVNV_NMRO_ITEM,
                 RVNV_NMRO_PLZA,
                 RVNV_CLSE_PLZA,
                 RVNV_CNCPTO_VLOR,
                 RVNV_VLOR,
                 RVNV_USRIO,
                 RVNV_FCH_MDFCCION)
              VALUES
                (FECHA_NOVEDAD,
                 AMPARO,
                 RAMO,
                 SOLICITUD,
                 POLIZA,
                 CLASE_POLIZA,
                 CONCEPTO,
                 VLOR,
                 USUARIO,
                 FECHA_PERIODO);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR INGRESO RSGOS_VGNTES_NVLOR1' || ' ' ||
                           SQLERRM;
                ROLLBACK;
                RETURN;
            END;
          ELSE
            BEGIN
              INSERT INTO RSGOS_VGNTES_NVLOR
                (RVNV_FCHA_NVDAD,
                 RVNV_CDGO_AMPRO,
                 RVNV_RAM_CDGO,
                 RVNV_NMRO_ITEM,
                 RVNV_NMRO_PLZA,
                 RVNV_CLSE_PLZA,
                 RVNV_CNCPTO_VLOR,
                 RVNV_VLOR,
                 RVNV_USRIO,
                 RVNV_FCH_MDFCCION)
              VALUES
                (FECHA_NOVEDAD,
                 AMPARO,
                 RAMO,
                 SOLICITUD,
                 POLIZA,
                 CLASE_POLIZA,
                 CONCEPTO,
                 VALOR,
                 USUARIO,
                 FECHA_PERIODO);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR INSERCION RSGOS_VGNTES_NVLOR ' || SQLERRM;
                ROLLBACK;
                RETURN;
            END;
          END IF;
        END IF;
      END IF;
    END IF;
  END;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_VALORES_PRIMAS
  -- Purpose : Procedimiento que actualiza las primas en las pólizas,
  -- certificados y tablas de acumulados por amparo.
  -- También calcula las cuotas de amparos adicionales que se deben
  -- cobrar a futuro.
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                                               TIPO_TASA           IN VARCHAR2) IS

   CURSOR C_CUOTAS IS
    SELECT TRUNC(R.REN_FCHA_NVDAD) FECHA_NOVEDAD, R.REN_VLOR_DFRNCIA VALOR,
           TRUNC(R.REN_FCHA_MDFCCION) FECHA_MODIFICACION
      FROM RSGOS_RCBOS_NVDAD R
     WHERE R.REN_NMRO_ITEM  = SOLICITUD
       AND R.REN_CDGO_AMPRO = AMPARO
       AND R.REN_TPO_NVDAD  = '11'
      ORDER BY R.REN_FCHA_NVDAD;


    NOVEDAD_RETIRO    VARCHAR2(2) := '02';
    NOVEDAD_INGRESO   VARCHAR2(2) := '01';
    NOVEDAD_REINGRESO VARCHAR2(2) := '05';
    NOVEDAD_AUMENTO   VARCHAR2(2) := '04';
    NUMERO_NOVEDADES  NUMBER := 0;
    NUMERO_RIESGOS    NUMBER := 0;
    CONTADOR          NUMBER(4);
    FECHA             DATE;
    FECHA_N           DATE;
    FECHA_S           DATE;
    --CUOTA             NUMBER(4);
    PERIODO_TASA      NUMBER(4);
    COBRO             NUMBER(18, 2);
    COBRO_IVA         NUMBER(18, 2);
    COBRO_TOTAL       NUMBER(18, 2);
    MESES             NUMBER(4);
    FECHA_A           DATE;
    R_CUOTAS          C_CUOTAS%ROWTYPE;
    --V_FECHA_RETIRO    DATE;
    V_MESES           NUMBER;
    V_FECHA_PERIODO   DATE;

  BEGIN

    IF ENTRO = 0 THEN
      NUMERO_NOVEDADES := 1;
    END IF;
    IF NOVEDAD = NOVEDAD_RETIRO THEN
      UPDATE RSMEN_NVDDES_CRTFCDO
         SET RNC_VLOR_PRMA    = NVL(RNC_VLOR_PRMA,0) + NVL(PRIMA_NETA_ANT,0) - NVL(PRIMA_NETA,0),
             RNC_VLOR_ASGRDO  = RNC_VLOR_ASGRDO + VALOR_ASEGURADO_ANT -
                                VALOR_ASEGURADO,
             RNC_NMERO_NVDDES = RNC_NMERO_NVDDES + NUMERO_NOVEDADES
       WHERE RNC_NMRO_CRTFCDO = CERTIFICADO
         AND RNC_NMRO_PLZA = POLIZA
         AND RNC_CLSE_PLZA = CLASE_POLIZA
         AND RNC_RAM_CDGO = RAMO
         AND RNC_CDGO_AMPRO = AMPARO
         AND RNC_TPO_NVDAD = NOVEDAD;
      IF SQL%NOTFOUND THEN
        BEGIN
          INSERT INTO RSMEN_NVDDES_CRTFCDO
            (RNC_NMRO_PLZA,
             RNC_CLSE_PLZA,
             RNC_RAM_CDGO,
             RNC_CDGO_AMPRO,
             RNC_TPO_NVDAD,
             RNC_NMRO_CRTFCDO,
             RNC_VLOR_PRMA,
             RNC_VLOR_ASGRDO,
             RNC_NMERO_NVDDES,
             RNC_USRIO,
             RNC_FCH_MDFCCION)
          VALUES
            (POLIZA,
             CLASE_POLIZA,
             RAMO,
             AMPARO,
             NOVEDAD,
             CERTIFICADO,
             NVL(PRIMA_NETA_ANT,0),
             VALOR_ASEGURADO_ANT,
             NUMERO_NOVEDADES,
             USUARIO,
             SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR EN INSERCION NOVEDADES CERTIFICADO' || ' ' ||
                       SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;
    ELSE
      IF COBRAR = 'SI' THEN
        --AND TIPO_TASA IN ('M','U') THEN
        UPDATE RSMEN_NVDDES_CRTFCDO
           SET RNC_VLOR_PRMA    = NVL(RNC_VLOR_PRMA,0) - NVL(PRIMA_NETA_ANT,0) + NVL(PRIMA_NETA,0),
               RNC_VLOR_ASGRDO  = RNC_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                  VALOR_ASEGURADO,
               RNC_NMERO_NVDDES = RNC_NMERO_NVDDES + NUMERO_NOVEDADES
         WHERE RNC_NMRO_CRTFCDO = CERTIFICADO
           AND RNC_NMRO_PLZA = POLIZA
           AND RNC_CLSE_PLZA = CLASE_POLIZA
           AND RNC_RAM_CDGO = RAMO
           AND RNC_CDGO_AMPRO = AMPARO
           AND RNC_TPO_NVDAD = NOVEDAD;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO RSMEN_NVDDES_CRTFCDO
              (RNC_NMRO_PLZA,
               RNC_CLSE_PLZA,
               RNC_RAM_CDGO,
               RNC_CDGO_AMPRO,
               RNC_TPO_NVDAD,
               RNC_NMRO_CRTFCDO,
               RNC_VLOR_PRMA,
               RNC_VLOR_ASGRDO,
               RNC_NMERO_NVDDES,
               RNC_USRIO,
               RNC_FCH_MDFCCION)
            VALUES
              (POLIZA,
               CLASE_POLIZA,
               RAMO,
               AMPARO,
               NOVEDAD,
               CERTIFICADO,
               NVL(PRIMA_NETA,0) - NVL(PRIMA_NETA_ANT,0),
               VALOR_ASEGURADO - VALOR_ASEGURADO_ANT,
               NUMERO_NOVEDADES,
               USUARIO,
               SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR EN INSERCION NOVEDADES CERTIFICADO' || ' ' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
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

    IF TIPO_TASA IN ('M', 'U') THEN
      IF AMPARO != '01' AND NOVEDAD = NOVEDAD_RETIRO THEN
        UPDATE ACMLDOS_AMPRO
           SET ACA_NMRO_RSGOS  = ACA_NMRO_RSGOS + NUMERO_RIESGOS,
               ACA_VLOR_ASGRDO = ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                 VALOR_ASEGURADO
         WHERE ACA_NMRO_PLZA = POLIZA
           AND ACA_RAM_CDGO = RAMO
           AND ACA_CLSE_PLZA = CLASE_POLIZA
           AND ACA_CDGO_AMPRO = AMPARO
           AND ACA_NMRO_CRTFCDO = CERTIFICADO;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO ACMLDOS_AMPRO
              (ACA_NMRO_CRTFCDO,
               ACA_NMRO_PLZA,
               ACA_CLSE_PLZA,
               ACA_RAM_CDGO,
               ACA_CDGO_AMPRO,
               ACA_NMRO_RSGOS,
               ACA_VLOR_ASGRDO,
               ACA_PRMA_NTA,
               ACA_USRIO,
               ACA_FCHA_ACTLZCION)
            VALUES
              (CERTIFICADO,
               POLIZA,
               CLASE_POLIZA,
               RAMO,
               AMPARO,
               1,
               VALOR_ASEGURADO,
               0,
               USUARIO,
               SYSDATE);
            if sql%notfound then
              MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
              ROLLBACK;
              RETURN;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
              ROLLBACK;
              RETURN;
          END;
        END IF;
      ELSIF AMPARO != '01' AND NOVEDAD = NOVEDAD_REINGRESO THEN
        UPDATE ACMLDOS_AMPRO
           SET ACA_NMRO_RSGOS  = ACA_NMRO_RSGOS + NUMERO_RIESGOS,
               ACA_VLOR_ASGRDO = ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                 VALOR_ASEGURADO
         WHERE ACA_NMRO_PLZA = POLIZA
           AND ACA_RAM_CDGO = RAMO
           AND ACA_CLSE_PLZA = CLASE_POLIZA
           AND ACA_CDGO_AMPRO = AMPARO
           AND ACA_NMRO_CRTFCDO = CERTIFICADO;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO ACMLDOS_AMPRO
              (ACA_NMRO_CRTFCDO,
               ACA_NMRO_PLZA,
               ACA_CLSE_PLZA,
               ACA_RAM_CDGO,
               ACA_CDGO_AMPRO,
               ACA_NMRO_RSGOS,
               ACA_VLOR_ASGRDO,
               ACA_PRMA_NTA,
               ACA_USRIO,
               ACA_FCHA_ACTLZCION)
            VALUES
              (CERTIFICADO,
               POLIZA,
               CLASE_POLIZA,
               RAMO,
               AMPARO,
               1,
               VALOR_ASEGURADO,
               0,
               USUARIO,
               SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
              ROLLBACK;
              RETURN;
          END;
        END IF;
      ELSIF AMPARO != '01' AND NOVEDAD = NOVEDAD_AUMENTO THEN
        BEGIN
          UPDATE ACMLDOS_AMPRO
             SET ACA_NMRO_RSGOS  = ACA_NMRO_RSGOS + NUMERO_RIESGOS,
                 ACA_VLOR_ASGRDO = ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                   VALOR_ASEGURADO,
                 ACA_PRMA_NTA    = ACA_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA
           WHERE ACA_NMRO_PLZA = POLIZA
             AND ACA_RAM_CDGO = RAMO
             AND ACA_CLSE_PLZA = CLASE_POLIZA
             AND ACA_CDGO_AMPRO = AMPARO
             AND ACA_NMRO_CRTFCDO = CERTIFICADO;
          IF SQL%NOTFOUND THEN
            BEGIN
              INSERT INTO ACMLDOS_AMPRO
                (ACA_NMRO_CRTFCDO,
                 ACA_NMRO_PLZA,
                 ACA_CLSE_PLZA,
                 ACA_RAM_CDGO,
                 ACA_CDGO_AMPRO,
                 ACA_NMRO_RSGOS,
                 ACA_VLOR_ASGRDO,
                 ACA_PRMA_NTA,
                 ACA_USRIO,
                 ACA_FCHA_ACTLZCION)
              VALUES
                (CERTIFICADO,
                 POLIZA,
                 CLASE_POLIZA,
                 RAMO,
                 AMPARO,
                 1,
                 VALOR_ASEGURADO,
                 PRIMA_NETA - PRIMA_NETA_ANT,
                 USUARIO,
                 SYSDATE);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
                ROLLBACK;
                RETURN;
            END;
          END IF;
        END;
      ELSIF CESION = 'SI' THEN
        IF AMPARO = '01' THEN
          BEGIN
            UPDATE ACMLDOS_AMPRO
               SET ACA_NMRO_RSGOS  = ACA_NMRO_RSGOS + NUMERO_RIESGOS,
                   ACA_VLOR_ASGRDO = ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                     VALOR_ASEGURADO,
                   ACA_PRMA_NTA    = ACA_PRMA_NTA - PRIMA_NETA_ANT +
                                     PRIMA_NETA
             WHERE ACA_NMRO_PLZA = POLIZA
               AND ACA_RAM_CDGO = RAMO
               AND ACA_CLSE_PLZA = CLASE_POLIZA
               AND ACA_CDGO_AMPRO = AMPARO
               AND ACA_NMRO_CRTFCDO = CERTIFICADO;
            IF SQL%NOTFOUND THEN
              BEGIN
                INSERT INTO ACMLDOS_AMPRO
                  (ACA_NMRO_CRTFCDO,
                   ACA_NMRO_PLZA,
                   ACA_CLSE_PLZA,
                   ACA_RAM_CDGO,
                   ACA_CDGO_AMPRO,
                   ACA_NMRO_RSGOS,
                   ACA_VLOR_ASGRDO,
                   ACA_PRMA_NTA,
                   ACA_USRIO,
                   ACA_FCHA_ACTLZCION)
                VALUES
                  (CERTIFICADO,
                   POLIZA,
                   CLASE_POLIZA,
                   RAMO,
                   AMPARO,
                   1,
                   VALOR_ASEGURADO,
                   PRIMA_NETA - PRIMA_NETA_ANT,
                   USUARIO,
                   SYSDATE);
              EXCEPTION
                WHEN OTHERS THEN
                  MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
                  ROLLBACK;
                  RETURN;
              END;
            END IF;
          END;
        ELSE
          BEGIN
            UPDATE ACMLDOS_AMPRO
               SET ACA_NMRO_RSGOS  = ACA_NMRO_RSGOS + NUMERO_RIESGOS,
                   ACA_VLOR_ASGRDO = ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                     VALOR_ASEGURADO
             WHERE ACA_NMRO_PLZA = POLIZA
               AND ACA_RAM_CDGO = RAMO
               AND ACA_CLSE_PLZA = CLASE_POLIZA
               AND ACA_CDGO_AMPRO = AMPARO
               AND ACA_NMRO_CRTFCDO = CERTIFICADO;
            IF SQL%NOTFOUND THEN
              BEGIN
                INSERT INTO ACMLDOS_AMPRO
                  (ACA_NMRO_CRTFCDO,
                   ACA_NMRO_PLZA,
                   ACA_CLSE_PLZA,
                   ACA_RAM_CDGO,
                   ACA_CDGO_AMPRO,
                   ACA_NMRO_RSGOS,
                   ACA_VLOR_ASGRDO,
                   ACA_PRMA_NTA,
                   ACA_USRIO,
                   ACA_FCHA_ACTLZCION)
                VALUES
                  (CERTIFICADO,
                   POLIZA,
                   CLASE_POLIZA,
                   RAMO,
                   AMPARO,
                   1,
                   VALOR_ASEGURADO,
                   0,
                   USUARIO,
                   SYSDATE);
              EXCEPTION
                WHEN OTHERS THEN
                  MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
                  ROLLBACK;
                  RETURN;
              END;
            END IF;
          END;
        END IF;
      ELSIF CUOTAS = 1 THEN
        BEGIN
          UPDATE ACMLDOS_AMPRO
             SET ACA_NMRO_RSGOS  = ACA_NMRO_RSGOS + NUMERO_RIESGOS,
                 ACA_VLOR_ASGRDO = ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                   VALOR_ASEGURADO,
                 ACA_PRMA_NTA    = ACA_PRMA_NTA - PRIMA_NETA_ANT + PRIMA_NETA
           WHERE ACA_NMRO_PLZA = POLIZA
             AND ACA_RAM_CDGO = RAMO
             AND ACA_CLSE_PLZA = CLASE_POLIZA
             AND ACA_CDGO_AMPRO = AMPARO
             AND ACA_NMRO_CRTFCDO = CERTIFICADO;
          IF SQL%NOTFOUND THEN
            BEGIN
              INSERT INTO ACMLDOS_AMPRO
                (ACA_NMRO_CRTFCDO,
                 ACA_NMRO_PLZA,
                 ACA_CLSE_PLZA,
                 ACA_RAM_CDGO,
                 ACA_CDGO_AMPRO,
                 ACA_NMRO_RSGOS,
                 ACA_VLOR_ASGRDO,
                 ACA_PRMA_NTA,
                 ACA_USRIO,
                 ACA_FCHA_ACTLZCION)
              VALUES
                (CERTIFICADO,
                 POLIZA,
                 CLASE_POLIZA,
                 RAMO,
                 AMPARO,
                 1,
                 VALOR_ASEGURADO,
                 PRIMA_NETA - PRIMA_NETA_ANT,
                 USUARIO,
                 SYSDATE);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
                ROLLBACK;
                RETURN;
            END;
          END IF;
        END;
      END IF;
    ELSE
      BEGIN
        UPDATE ACMLDOS_AMPRO
           SET ACA_NMRO_RSGOS  = ACA_NMRO_RSGOS + NUMERO_RIESGOS,
               ACA_VLOR_ASGRDO = ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                 VALOR_ASEGURADO
         WHERE ACA_NMRO_PLZA = POLIZA
           AND ACA_RAM_CDGO = RAMO
           AND ACA_CLSE_PLZA = CLASE_POLIZA
           AND ACA_CDGO_AMPRO = AMPARO
           AND ACA_NMRO_CRTFCDO = CERTIFICADO;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO ACMLDOS_AMPRO
              (ACA_NMRO_CRTFCDO,
               ACA_NMRO_PLZA,
               ACA_CLSE_PLZA,
               ACA_RAM_CDGO,
               ACA_CDGO_AMPRO,
               ACA_NMRO_RSGOS,
               ACA_VLOR_ASGRDO,
               ACA_PRMA_NTA,
               ACA_USRIO,
               ACA_FCHA_ACTLZCION)
            VALUES
              (CERTIFICADO,
               POLIZA,
               CLASE_POLIZA,
               RAMO,
               AMPARO,
               1,
               VALOR_ASEGURADO,
               0,
               USUARIO,
               SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
              ROLLBACK;
              RETURN;
          END;
        END IF;
      END;

    END IF;
    /***************************************************************************************/
    /* ACTUALIZAR POLIZAS CON EL VALOR ASEGURADO Y LA PRIMA RESULTANTE.              */
    /* PERO PARA RIESGOS CUYO TIPO DE TASA SEA DIFERENTE A LA MENSUAL SE DEBE ACTUALIZAR   */
    /* SOLAMENTE EL VALOR ASEGURADO Y EL NUMERO DE RIESGOS.              */
    /***************************************************************************************/
    IF AMPARO = '01' AND TIPO_TASA IN ('M') THEN
      BEGIN
        UPDATE PLZAS
           SET POL_NMRO_RSGOS_VGNTES  = POL_NMRO_RSGOS_VGNTES + NUMERO_RIESGOS,
               POL_NMRO_RSGOS         = POL_NMRO_RSGOS + NUMERO_RIESGOS,
               POL_VLOR_ASGRDO_FLTNTE = POL_VLOR_ASGRDO_FLTNTE -
                                        VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               POL_VLOR_ASGRDO_TTAL   = POL_VLOR_ASGRDO_TTAL -
                                        VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               POL_VLO_ASEGRBLE       = POL_VLO_ASEGRBLE - VALOR_ASEGURADO_ANT +
                                        VALOR_ASEGURADO,
               POL_VLOR_PRMA_TTAL     = POL_VLOR_PRMA_TTAL - PRIMA_TOTAL_ANT +
                                        PRIMA_TOTAL,
               POL_VLOR_PRMA_ANUAL    = POL_VLOR_PRMA_ANUAL - PRIMA_ANUAL_ANT +
                                        PRIMA_ANUAL,
               POL_VLOR_PRMA_NTA      = POL_VLOR_PRMA_NTA - PRIMA_NETA_ANT +
                                        PRIMA_NETA,
               POL_NMRO_CRTFCDO       = CERTIFICADO,
               POL_PRCNTJE_IVA        = IVA,
               POL_VLOR_IVA           = POL_VLOR_IVA - IVA_PRIMA_ANT +
                                        IVA_PRIMA
         WHERE POL_NMRO_PLZA = POLIZA
           AND POL_CDGO_CLSE = CLASE_POLIZA
           AND POL_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          MENSAJE := 'ERROR EN LA ACTUALIZACION DE POLIZAS';
          ROLLBACK;
          RETURN;
        END IF;
      END;
    ELSIF AMPARO = '01' AND TIPO_TASA != 'M' THEN
      BEGIN
        UPDATE PLZAS
           SET POL_NMRO_RSGOS_VGNTES  = POL_NMRO_RSGOS_VGNTES + NUMERO_RIESGOS,
               POL_NMRO_RSGOS         = POL_NMRO_RSGOS + NUMERO_RIESGOS,
               POL_VLOR_ASGRDO_FLTNTE = POL_VLOR_ASGRDO_FLTNTE -
                                        VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               POL_VLOR_ASGRDO_TTAL   = POL_VLOR_ASGRDO_TTAL -
                                        VALOR_ASEGURADO_ANT + VALOR_ASEGURADO,
               POL_VLO_ASEGRBLE       = POL_VLO_ASEGRBLE - VALOR_ASEGURADO_ANT +
                                        VALOR_ASEGURADO,
               POL_NMRO_CRTFCDO       = CERTIFICADO,
               POL_PRCNTJE_IVA        = IVA
         WHERE POL_NMRO_PLZA = POLIZA
           AND POL_CDGO_CLSE = CLASE_POLIZA
           AND POL_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          MENSAJE := 'ERROR EN LA ACTUALIZACION DE POLIZAS';
          ROLLBACK;
          RETURN;
        END IF;
      END;
    END IF;

    /***************************************************************************************/
    /* GUARDA LA PRIMA RETROACTIVA PARA MOSTRARLA EN LA RELACION DE ASEGURADOS.            */
    /* SOLO EXISTE PRIMA RETROACTIVA PARA EL AMPARO BASICO               */
    /***************************************************************************************/

    IF AMPARO = '01' AND
       (NOVEDAD = NOVEDAD_INGRESO OR NOVEDAD = NOVEDAD_AUMENTO OR
       NOVEDAD = NOVEDAD_REINGRESO) THEN
      IF RETRO_NETA_ANT != 0 OR RETRO_NETA != 0 THEN
        BEGIN
          FECHA := TO_DATE('01' || '/' || SUBSTR(PERIODO, 1, 2) || '/' ||
                           SUBSTR(PERIODO, 3, 4) || ' ' || '01:03:00',
                           'DD/MM/YYYY HH:MI:SS');
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA - RETRO_NETA_ANT +
                                     RETRO_NETA
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = AMPARO
             AND RIVN_TPO_NVDAD = '12';
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
               AMPARO,
               RAMO,
               SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               '12',
               RETRO_NETA - RETRO_NETA_ANT,
               SYSDATE,
               USUARIO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR INSERTANDO RETROACTIVIDAD DEL AMPARO.' || ' ' ||
                       SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;
    ELSIF AMPARO = '01' AND NOVEDAD = NOVEDAD_RETIRO THEN
      IF RETRO_NETA_ANT != 0 OR RETRO_NETA != 0 THEN
        BEGIN
          FECHA := TO_DATE('01' || '/' || SUBSTR(PERIODO, 1, 2) || '/' ||
                           SUBSTR(PERIODO, 3, 4) || ' ' || '01:03:00',
                           'DD/MM/YYYY HH:MI:SS');
          UPDATE NVDDES
             SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + RETRO_NETA_ANT
           WHERE RIVN_CDGO_AMPRO = AMPARO
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_TPO_NVDAD = '09';
          IF SQL%NOTFOUND THEN
            INSERT INTO NVDDES
              (RIVN_FCHA_NVDAD,
               RIVN_CDGO_AMPRO,
               RIVN_RAM_CDGO,
               RIVN_NMRO_ITEM,
               RIVN_NMRO_PLZA,
               RIVN_CLSE_PLZA,
               RIVN_TPO_NVDAD,
               RIVN_VLOR_DFRNCIA,
               RIVN_FCHA_MDFCCION,
               RIVN_USRIO,
               RIVN_NMRO_CRTFCDO)
            VALUES
              (FECHA,
               AMPARO,
               RAMO,
               SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               '09',
               RETRO_NETA_ANT,
               SYSDATE,
               USUARIO,
               CERTIFICADO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR INSERTANDO RETROACTIVIDAD DEL AMPARO.' || ' ' ||
                       SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      END IF;
    END IF;

    /***************************************************************************************/
    /* GENERA LAS CUOTAS QUE FALTAN POR COBRAR PARA LOS AMPAROS ADICIONALES.               */
    /* SE REGISTRAR COMO NOVEDAD
    . CONTABILIZA LA PRIMERA CUOTA EN ACUMULADOS AMPARO     */
    /***************************************************************************************/

    IF NOVEDAD = NOVEDAD_INGRESO OR NOVEDAD = NOVEDAD_AUMENTO THEN
      IF CESION = 'NO' THEN
        IF CUOTAS > 1 THEN
          --mostrar_mensaje('cuotas es mayor que 1','e',false);
          PRIMA_NETA      := PRIMA_NETA / CUOTAS;
          IVA_PRIMA       := IVA_PRIMA / CUOTAS;
          PRIMA_TOTAL     := PRIMA_TOTAL / CUOTAS;
          PRIMA_ANUAL     := PRIMA_ANUAL / CUOTAS;
          PRIMA_NETA_ANT  := PRIMA_NETA_ANT / CUOTAS;
          IVA_PRIMA_ANT   := IVA_PRIMA_ANT / CUOTAS;
          PRIMA_TOTAL_ANT := PRIMA_TOTAL_ANT / CUOTAS;
          PRIMA_ANUAL_ANT := PRIMA_ANUAL_ANT / CUOTAS;
          BEGIN
            UPDATE ACMLDOS_AMPRO
               SET ACA_NMRO_RSGOS  = ACA_NMRO_RSGOS + NUMERO_RIESGOS,
                   ACA_VLOR_ASGRDO = ACA_VLOR_ASGRDO - VALOR_ASEGURADO_ANT +
                                     VALOR_ASEGURADO,
                   ACA_PRMA_NTA    = ACA_PRMA_NTA - PRIMA_NETA_ANT +
                                     PRIMA_NETA
             WHERE ACA_NMRO_PLZA = POLIZA
               AND ACA_RAM_CDGO = RAMO
               AND ACA_CLSE_PLZA = CLASE_POLIZA
               AND ACA_CDGO_AMPRO = AMPARO
               AND ACA_NMRO_CRTFCDO = CERTIFICADO;
            IF SQL%NOTFOUND THEN
              BEGIN
                INSERT INTO ACMLDOS_AMPRO
                  (ACA_NMRO_CRTFCDO,
                   ACA_NMRO_PLZA,
                   ACA_CLSE_PLZA,
                   ACA_RAM_CDGO,
                   ACA_CDGO_AMPRO,
                   ACA_NMRO_RSGOS,
                   ACA_VLOR_ASGRDO,
                   ACA_PRMA_NTA,
                   ACA_USRIO,
                   ACA_FCHA_ACTLZCION)
                VALUES
                  (CERTIFICADO,
                   POLIZA,
                   CLASE_POLIZA,
                   RAMO,
                   AMPARO,
                   1,
                   VALOR_ASEGURADO,
                   PRIMA_NETA - PRIMA_NETA_ANT,
                   USUARIO,
                   SYSDATE);
              EXCEPTION
                WHEN OTHERS THEN
                  MENSAJE := 'ERROR EN INSERCION ACUMULADOS AMPARO';
                  ROLLBACK;
                  RETURN;
              END;
            END IF;
          END;

          IF NOVEDAD = NOVEDAD_AUMENTO THEN
            BEGIN
              UPDATE RSGOS_VGNTES_AMPRO
                 SET RVA_VLOR_PRMA_NTA = NVL(RVA_VLOR_PRMA_NTA,0) +
                                         (NVL(PRIMA_NETA,0) * CUOTAS)
               WHERE RVA_CDGO_AMPRO = AMPARO
                 AND RVA_RAM_CDGO = RAMO
                 AND RVA_NMRO_ITEM = SOLICITUD
                 AND RVA_NMRO_PLZA = POLIZA
                 AND RVA_CLSE_PLZA = CLASE_POLIZA;
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR INSERTANDO CUOTAS DEL AMPARO.' || ' ' ||
                           SQLERRM;
                ROLLBACK;
                RETURN;
            END;
          END IF;

          CONTADOR := 1;
          FECHA    := TO_DATE('01' || '/' || SUBSTR(PERIODO, 1, 2) || '/' ||
                              SUBSTR(PERIODO, 3, 4) || ' ' || '01:02:00',
                              'DD/MM/YYYY HH:MI:SS');
          WHILE CONTADOR <= CUOTAS / 2 LOOP
            BEGIN
              UPDATE RSGOS_VGNTES_NVDDES
                 SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + PRIMA_NETA
               WHERE RIVN_NMRO_ITEM = SOLICITUD
                 AND RIVN_NMRO_PLZA = POLIZA
                 AND RIVN_CLSE_PLZA = CLASE_POLIZA
                 AND RIVN_RAM_CDGO = RAMO
                 AND RIVN_CDGO_AMPRO = AMPARO
                 AND RIVN_TPO_NVDAD = '11'
                 and rivn_fcha_nvdad = fecha;
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
                   AMPARO,
                   RAMO,
                   SOLICITUD,
                   POLIZA,
                   CLASE_POLIZA,
                   '11',
                   PRIMA_NETA,
                   ADD_MONTHS(FECHA, 1),
                   USUARIO);
                IF SQL%NOTFOUND THEN
                  MENSAJE := 'NO INSERTO LA CUOTA DEL AMPARO';
                  ROLLBACK;
                  RETURN;
                END IF;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := 'ERROR INSERTANDO CUOTAS DEL AMPARO.' || ' ' ||
                           SQLERRM;
                ROLLBACK;
                RETURN;
            END;
            CONTADOR := CONTADOR + 1;
            FECHA    := ADD_MONTHS(FECHA, 2);
          END LOOP;
        END IF;
      END IF;
    END IF;

      -- Se incluye para que los reingresos de amparos adicionales cobren las cuotas
    -- pendientes por cobrar. SPPC. 27/09/2013. Mantis # 20111.
    BEGIN
     IF NOVEDAD = NOVEDAD_REINGRESO THEN



        V_FECHA_PERIODO := TO_DATE('01'||PERIODO,'DDMMYYYY');
        V_MESES := ROUND(MONTHS_BETWEEN(V_FECHA_PERIODO,FECHA_NOVEDAD),0);


         open C_CUOTAS;
         loop
           fetch C_CUOTAS into R_CUOTAS;
           exit when C_CUOTAS%notfound;


             IF R_CUOTAS.FECHA_NOVEDAD < TRUNC(FECHA_NOVEDAD) THEN
               IF R_CUOTAS.FECHA_MODIFICACION = TRUNC(FECHA_NOVEDAD) THEN
                 IF R_CUOTAS.FECHA_MODIFICACION <= V_FECHA_PERIODO AND  ---Mantis 40315
                    TRUNC(FECHA_NOVEDAD) <>  V_FECHA_PERIODO  THEN ---Mantis 40315
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
                     (ADD_MONTHS(R_CUOTAS.FECHA_MODIFICACION,V_MESES),
                      AMPARO,
                      RAMO,
                      SOLICITUD,
                      POLIZA,
                      CLASE_POLIZA,
                      '11',
                      R_CUOTAS.VALOR,
                      ADD_MONTHS(R_CUOTAS.FECHA_MODIFICACION,V_MESES),
                      USUARIO);
                 END IF;
               END IF;
             ELSIF R_CUOTAS.FECHA_NOVEDAD >= TRUNC(FECHA_NOVEDAD) THEN

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
                  (ADD_MONTHS(R_CUOTAS.FECHA_NOVEDAD,V_MESES),
                   AMPARO,
                   RAMO,
                   SOLICITUD,
                   POLIZA,
                   CLASE_POLIZA,
                   '11',
                   R_CUOTAS.VALOR,
                   ADD_MONTHS(R_CUOTAS.FECHA_MODIFICACION,V_MESES),
                   USUARIO);

             END IF;

         end loop;
         close C_CUOTAS;


     END IF;

    END;


    /***************************************************************************************/
    /* Crea un registro en la tabla de novedades para realizar el cobro            */
    /* de las primas en los riesgos cuya tasa es diferente a la mensual o unica.           */
    /* la novedad 13 significa el primer cobro que se va a realizar.                       */
    /* la novedad 14 los pagos periodicos que debe realizar. Se diferencian porque la      */
    /* novedad 13 suma directamente al certificado en el ingreso de las novedades mientras */
    /* que la novedad 14 la debe tomar solamente el cierre de operacion.           */
    /***************************************************************************************/

    IF TIPO_TASA NOT IN ('M', 'U') AND AMPARO = '01' THEN
      FECHA   := TO_DATE('01' || '/' || SUBSTR(PERIODO, 1, 2) || '/' ||
                         SUBSTR(PERIODO, 3, 4) || ' ' || '01:02:00',
                         'DD/MM/YYYY HH:MI:SS');
      FECHA_N := TO_DATE(TO_CHAR(FECHA_NOVEDAD, 'DD/MM/YYYY') || ' ' ||
                         '02:18:00',
                         'DD/MM/YYYY HH:MI:SS');
      IF TIPO_TASA = 'B' THEN
        FECHA_S      := ADD_MONTHS(FECHA_N, 2);
        PERIODO_TASA := 2;
      ELSIF TIPO_TASA = 'T' THEN
        FECHA_S      := ADD_MONTHS(FECHA_N, 3);
        PERIODO_TASA := 3;
      ELSIF TIPO_TASA = 'S' THEN
        FECHA_S      := ADD_MONTHS(FECHA_N, 6);
        PERIODO_TASA := 6;
      ELSIF TIPO_TASA = 'A' THEN
        FECHA_S      := ADD_MONTHS(FECHA_N, 12);
        PERIODO_TASA := 12;
      END IF;
      IF NOVEDAD = NOVEDAD_INGRESO AND CESION = 'NO' THEN
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + PRIMA_NETA
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = AMPARO
             AND RIVN_TPO_NVDAD = '13'
             AND TRUNC(RIVN_FCHA_NVDAD) = TRUNC(FECHA_N);
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
              (FECHA_N,
               AMPARO,
               RAMO,
               SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               '13',
               PRIMA_NETA,
               FECHA,
               USUARIO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR INSERTANDO COBRO PARA EL TIPO DE TASA.' ||
                       TIPO_TASA || ' ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = RIVN_VLOR_DFRNCIA + PRIMA_NETA
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = AMPARO
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
               AMPARO,
               RAMO,
               SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               '14',
               PRIMA_NETA,
               FECHA_S,
               USUARIO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'ERROR INSERTANDO COBRO SIGUIENTE PARA EL TIPO DE TASA.' ||
                       TIPO_TASA || ' ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      ELSIF NOVEDAD = NOVEDAD_RETIRO THEN
        BEGIN
          UPDATE NVDDES
             SET RIVN_VLOR_DFRNCIA = NVL(RIVN_VLOR_DFRNCIA,0) + NVL(PRIMA_NETA_ANT,0)
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = AMPARO
             AND RIVN_TPO_NVDAD = '09'
             AND TRUNC(RIVN_FCHA_NVDAD) = TRUNC(FECHA);
          IF SQL%NOTFOUND THEN
            BEGIN
              INSERT INTO NVDDES
                (RIVN_FCHA_NVDAD,
                 RIVN_CDGO_AMPRO,
                 RIVN_RAM_CDGO,
                 RIVN_NMRO_ITEM,
                 RIVN_NMRO_PLZA,
                 RIVN_CLSE_PLZA,
                 RIVN_TPO_NVDAD,
                 RIVN_VLOR_DFRNCIA,
                 RIVN_FCHA_MDFCCION,
                 RIVN_USRIO,
                 RIVN_NMRO_CRTFCDO)
              VALUES
                (FECHA,
                 AMPARO,
                 RAMO,
                 SOLICITUD,
                 POLIZA,
                 CLASE_POLIZA,
                 '09',
                 NVL(PRIMA_NETA_ANT,0), -- PARA SIMON 
                 FECHA,
                 USUARIO,
                 CERTIFICADO);
            EXCEPTION
              WHEN OTHERS THEN
                MENSAJE := '1.ERROR INSERTANDO DESCUENTO POR RETIRO PARA TIPOS DE TASAS DIFERENTES A MENSUAL.' ||
                           TIPO_TASA || ' ' || SQLERRM;
                ROLLBACK;
                RETURN;
            END;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := '2.ERROR INSERTANDO DESCUENTO POR RETIRO PARA TIPOS DE TASAS DIFERENTES A MENSUAL.' ||
                       TIPO_TASA || ' ' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      ELSIF NOVEDAD = NOVEDAD_AUMENTO THEN
        /* BUSCAR LA FECHA EN QUE SE DEBE COBRAR LA PROXIMA PRIMA*/
        BEGIN
          SELECT MAX(RIVN_FCHA_NVDAD)
            INTO FECHA_A
            FROM RSGOS_VGNTES_NVDDES
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = '01'
             AND RIVN_TPO_NVDAD = '14';
          MESES       := MONTHS_BETWEEN(FECHA_A, FECHA_NOVEDAD);
          COBRO       := (PRIMA_NETA - PRIMA_NETA_ANT) * MESES / PERIODO_TASA;
          COBRO_IVA   := (IVA_PRIMA - IVA_PRIMA_ANT) * MESES / PERIODO_TASA;
          COBRO_TOTAL := COBRO + COBRO_IVA;
          BEGIN
            /* COBRAR ANTICIPADAMENTE LA DIFERENCIA POR EL AUMENTO DE VALOR ASEGURADO DEL PERIODO COMPLETO SEGUN EL TIPO DE TASA*/
            INSERT INTO RSGOS_VGNTES_NVDDES
            VALUES
              (FECHA,
               AMPARO,
               RAMO,
               SOLICITUD,
               POLIZA,
               CLASE_POLIZA,
               '13',
               COBRO,
               FECHA,
               USUARIO);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'error insertando el cobro por la diferencia del aumento.';
              ROLLBACK;
              RETURN;
          END;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            MENSAJE := 'No se encontro el cobro anticipado de la prima.';
            ROLLBACK;
            RETURN;
        END;
        /* ACTUALIZAR EL COBRO ANTICIPADO DEL SIGUIENTE PERIODO CON EL AUMENTO DEL VALOR ASEGURADO*/
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = PRIMA_NETA
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = '01'
             AND RIVN_TPO_NVDAD = '14'
             AND RIVN_FCHA_NVDAD = FECHA_A;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'No se encontro el cobro anticipado de la prima.';
            ROLLBACK;
            RETURN;
        END;
        /* ACTUALIZAR EL COBRO ANTICIPADO DEL AUMENTO EN LA NOVEDAD DE AUMENTO REPORTADA*/
        BEGIN
          UPDATE RSGOS_VGNTES_NVDDES
             SET RIVN_VLOR_DFRNCIA = COBRO
           WHERE RIVN_NMRO_ITEM = SOLICITUD
             AND RIVN_NMRO_PLZA = POLIZA
             AND RIVN_CLSE_PLZA = CLASE_POLIZA
             AND RIVN_RAM_CDGO = RAMO
             AND RIVN_CDGO_AMPRO = '01'
             AND RIVN_TPO_NVDAD = NOVEDAD_AUMENTO
             AND TRUNC(RIVN_FCHA_NVDAD) = FECHA_NOVEDAD;
        EXCEPTION
          WHEN OTHERS THEN
            MENSAJE := 'Error al actualizar la novedad de aumento.';
            ROLLBACK;
            RETURN;
        END;
        /* ACTUALIZAR LA TABLA DE RESUMEN NOVEDADES CERTIFICADO CON EL COBRO ANTICIPADO DE LA DIFERENCIA*/
        UPDATE RSMEN_NVDDES_CRTFCDO
           SET RNC_VLOR_PRMA = RNC_VLOR_PRMA + PRIMA_NETA_ANT - PRIMA_NETA +
                               COBRO
         WHERE RNC_NMRO_CRTFCDO = CERTIFICADO
           AND RNC_NMRO_PLZA = POLIZA
           AND RNC_CLSE_PLZA = CLASE_POLIZA
           AND RNC_RAM_CDGO = RAMO
           AND RNC_CDGO_AMPRO = AMPARO
           AND RNC_TPO_NVDAD = NOVEDAD;
        IF SQL%NOTFOUND THEN
          BEGIN
            INSERT INTO RSMEN_NVDDES_CRTFCDO
              (RNC_NMRO_PLZA,
               RNC_CLSE_PLZA,
               RNC_RAM_CDGO,
               RNC_CDGO_AMPRO,
               RNC_TPO_NVDAD,
               RNC_NMRO_CRTFCDO,
               RNC_VLOR_PRMA,
               RNC_VLOR_ASGRDO,
               RNC_NMERO_NVDDES,
               RNC_USRIO,
               RNC_FCH_MDFCCION)
            VALUES
              (POLIZA,
               CLASE_POLIZA,
               RAMO,
               AMPARO,
               NOVEDAD,
               CERTIFICADO,
               COBRO,
               VALOR_ASEGURADO - VALOR_ASEGURADO_ANT,
               NUMERO_NOVEDADES,
               USUARIO,
               SYSDATE);
          EXCEPTION
            WHEN OTHERS THEN
              MENSAJE := 'ERROR EN INSERCION NOVEDADES CERTIFICADO' || ' ' ||
                         SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
        --  ELSIF NOVEDAD = NOVEDAD_INGRESO AND CESION = 'SI'THEN
      END IF;
    END IF;

    /***************************************************************************************/
    /* Actualiza el certificado para el periodo actual.              */
    /* No puede actualizar el certificado si se retira un amparo adicional.                */
    /***************************************************************************************/

    IF (NOVEDAD = NOVEDAD_RETIRO OR NOVEDAD = NOVEDAD_REINGRESO) AND
       AMPARO IN ('02', '03', '04', '05') THEN
      BEGIN
        UPDATE CRTFCDOS
           SET CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA - VALOR_ASEGURADO_ANT +
                                     VALOR_ASEGURADO
         WHERE CER_NMRO_CRTFCDO = CERTIFICADO
           AND CER_NMRO_PLZA = POLIZA
           AND CER_CLSE_PLZA = CLASE_POLIZA
           AND CER_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          MENSAJE := 'ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
          ROLLBACK;
          RETURN;
        END IF;
      END;
    ELSIF (NOVEDAD = NOVEDAD_INGRESO AND CESION = 'SI') AND
          AMPARO IN ('02', '03', '04', '05') THEN
      BEGIN
        UPDATE CRTFCDOS
           SET CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA - VALOR_ASEGURADO_ANT +
                                     VALOR_ASEGURADO
         WHERE CER_NMRO_CRTFCDO = CERTIFICADO
           AND CER_NMRO_PLZA = POLIZA
           AND CER_CLSE_PLZA = CLASE_POLIZA
           AND CER_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          MENSAJE := 'ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
          ROLLBACK;
          RETURN;
        END IF;
      END;
    ELSIF NOVEDAD = NOVEDAD_AUMENTO AND TIPO_TASA NOT IN ('M', 'U') THEN
      BEGIN
        UPDATE CRTFCDOS
           SET CER_VLOR_PRMA_NTA   = NVL(CER_VLOR_PRMA_NTA,0) + NVL(COBRO,0),
               CER_VLOR_PRMA_TTAL  = NVL(CER_VLOR_PRMA_TTAL,0) + NVL(COBRO_TOTAL,0),
               CER_VLOR_SMA_ASGRDA = NVL(CER_VLOR_SMA_ASGRDA,0) - NVL(VALOR_ASEGURADO_ANT,0) +
                                     NVL(VALOR_ASEGURADO,0),
               CER_VLOR_IVA        = NVL(CER_VLOR_IVA,0) + NVL(COBRO_IVA,0)
         WHERE CER_NMRO_CRTFCDO = CERTIFICADO
           AND CER_NMRO_PLZA = POLIZA
           AND CER_CLSE_PLZA = CLASE_POLIZA
           AND CER_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          MENSAJE := 'ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
          ROLLBACK;
          RETURN;
        END IF;
      END;
    ELSIF (NOVEDAD = NOVEDAD_INGRESO AND CESION = 'SI' AND AMPARO = '01' AND
          TIPO_TASA NOT IN ('M', 'U')) THEN
      NULL;
    ELSE
      BEGIN
        UPDATE CRTFCDOS
           SET CER_VLOR_PRMA_NTA   = NVL(CER_VLOR_PRMA_NTA,0) - NVL(PRIMA_NETA_ANT,0) +
                                     NVL(PRIMA_NETA,0) - NVL(RETRO_NETA_ANT,0) + NVL(RETRO_NETA,0),
               CER_VLOR_PRMA_TTAL  = NVL(CER_VLOR_PRMA_TTAL,0) - NVL(PRIMA_TOTAL_ANT,0) +
                                     NVL(PRIMA_TOTAL,0) - NVL(RETRO_TOTAL_ANT,0) +
                                     NVL(RETRO_TOTAL,0),
               CER_VLOR_SMA_ASGRDA = CER_VLOR_SMA_ASGRDA - VALOR_ASEGURADO_ANT +
                                     VALOR_ASEGURADO,
               CER_VLOR_IVA        = NVL(CER_VLOR_IVA,0) - NVL(IVA_PRIMA_ANT,0) + NVL(IVA_PRIMA,0) -
                                     NVL(IVA_RETRO_ANT,0) + NVL(IVA_RETRO,0)
         WHERE CER_NMRO_CRTFCDO = CERTIFICADO
           AND CER_NMRO_PLZA = POLIZA
           AND CER_CLSE_PLZA = CLASE_POLIZA
           AND CER_RAM_CDGO = RAMO;
        IF SQL%NOTFOUND THEN
          MENSAJE := 'ERROR EN LA ACTUALIZACION DE CERTIFICADOS';
          ROLLBACK;
          RETURN;
        END IF;
      END;
    END IF;
    ENTRO := 1;
  END;


  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_BORRAR_REGISTROS
  -- Purpose : Procedimiento que borrar la estructura de riesgos
  --  cuando hay un retiro del seguro.
  -- Modificado por:
  --
  --
  /***********************************************************************/
 PROCEDURE PRC_BORRAR_REGISTROS(NOVEDAD      VARCHAR2,
                                               P_SOLICITUD    NUMBER,
                                               POLIZA       NUMBER,
                                               CLASE_POLIZA VARCHAR2,
                                               RAMO         VARCHAR2,
                                               CONCEPTO     VARCHAR2,
                                               AMPARO       VARCHAR2) IS
    NOVEDAD_RETIRO    VARCHAR2(2) := '02';
    --NOVEDAD_REINGRESO VARCHAR2(2) := '05';
    CONTADOR          NUMBER := 0;
  BEGIN

    IF NOVEDAD = NOVEDAD_RETIRO THEN
      DELETE FROM RSGOS_VGNTES_NVLOR
       WHERE RVNV_NMRO_ITEM = P_SOLICITUD
         AND RVNV_NMRO_PLZA = POLIZA
         AND RVNV_CLSE_PLZA = CLASE_POLIZA
         AND RVNV_RAM_CDGO = RAMO
         AND RVNV_CDGO_AMPRO = AMPARO
         AND RVNV_CNCPTO_VLOR = CONCEPTO;
      DELETE FROM RSGOS_VGNTES_VLRES
       WHERE RVV_NMRO_ITEM = P_SOLICITUD
         AND RVV_NMRO_PLZA = POLIZA
         AND RVV_CLSE_PLZA = CLASE_POLIZA
         AND RVV_RAM_CDGO = RAMO
         AND RVV_CNCPTO_VLOR = CONCEPTO;
      DELETE FROM RSGOS_VGNTES_AVLOR
       WHERE RVL_CDGO_AMPRO = AMPARO
         AND RVL_NMRO_ITEM = P_SOLICITUD
         AND RVL_NMRO_PLZA = POLIZA
         AND RVL_CLSE_PLZA = CLASE_POLIZA
         AND RVL_RAM_CDGO = RAMO
         AND RVL_CNCPTO_VLOR = CONCEPTO;
      BEGIN
        SELECT COUNT(8)
          INTO CONTADOR
          FROM RSGOS_VGNTES_NVLOR
         WHERE RVNV_NMRO_ITEM = P_SOLICITUD
           AND RVNV_NMRO_PLZA = POLIZA
           AND RVNV_CLSE_PLZA = CLASE_POLIZA
           AND RVNV_RAM_CDGO = RAMO
           AND RVNV_CDGO_AMPRO = AMPARO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          CONTADOR := 0;
      END;
      IF CONTADOR = 0 THEN
        DELETE FROM RSGOS_VGNTES_NVDDES
         WHERE RIVN_NMRO_ITEM = P_SOLICITUD
           AND RIVN_NMRO_PLZA = POLIZA
           AND RIVN_CLSE_PLZA = CLASE_POLIZA
           AND RIVN_RAM_CDGO = RAMO
           AND RIVN_CDGO_AMPRO = AMPARO;
        DELETE FROM RSGOS_VGNTES_AVLOR
         WHERE RVL_CDGO_AMPRO = AMPARO
           AND RVL_NMRO_ITEM = P_SOLICITUD
           AND RVL_NMRO_PLZA = POLIZA
           AND RVL_CLSE_PLZA = CLASE_POLIZA
           AND RVL_RAM_CDGO = RAMO
           AND RVL_CNCPTO_VLOR = CONCEPTO;
        BEGIN
          SELECT COUNT(8)
            INTO CONTADOR
            FROM RSGOS_VGNTES_AVLOR
           WHERE RVL_CDGO_AMPRO = AMPARO
             AND RVL_NMRO_ITEM = P_SOLICITUD
             AND RVL_NMRO_PLZA = POLIZA
             AND RVL_CLSE_PLZA = CLASE_POLIZA
             AND RVL_RAM_CDGO = RAMO;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            CONTADOR := 0;
        END;
        IF CONTADOR = 0 THEN
          DELETE FROM RSGOS_VGNTES_AMPRO
           WHERE RVA_CDGO_AMPRO = AMPARO
             AND RVA_RAM_CDGO = RAMO
             AND RVA_NMRO_ITEM = P_SOLICITUD
             AND RVA_NMRO_PLZA = POLIZA
             AND RVA_CLSE_PLZA = CLASE_POLIZA;
        END IF;
        DELETE FROM RSGOS_VGNTES_VLRES
         WHERE RVV_NMRO_ITEM = P_SOLICITUD
           AND RVV_NMRO_PLZA = POLIZA
           AND RVV_CLSE_PLZA = CLASE_POLIZA
           AND RVV_RAM_CDGO = RAMO
           AND RVV_CNCPTO_VLOR = CONCEPTO;
      END IF;
      BEGIN
        SELECT COUNT(8)
          INTO CONTADOR
          FROM RSGOS_VGNTES_AMPRO
         WHERE RVA_NMRO_ITEM = P_SOLICITUD
           AND RVA_NMRO_PLZA = POLIZA
           AND RVA_CLSE_PLZA = CLASE_POLIZA
           AND RVA_RAM_CDGO = RAMO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          CONTADOR := 0;
      END;
      IF CONTADOR = 0 THEN
       -- SE INCLUYE PARA LAS NUEVAS TABLAS QUE EXISTEN EN OPERACION. SPPC. 10/04/2014
       DELETE AUMENTOS_CONTRATOS A
        WHERE A.SOLICITUD = P_SOLICITUD;

       DELETE DATOS_CONTRATOS D
        WHERE D.SOLICITUD = P_SOLICITUD;

        DELETE FROM RSGOS_VGNTES_VLRES
         WHERE RVV_NMRO_ITEM = P_SOLICITUD
           AND RVV_NMRO_PLZA = POLIZA
           AND RVV_CLSE_PLZA = CLASE_POLIZA
           AND RVV_RAM_CDGO = RAMO;
        DELETE FROM RSGOS_VGNTES_NITS
         WHERE RVN_NMRO_ITEM = P_SOLICITUD
           AND RVN_NMRO_PLZA = POLIZA
           AND RVN_CLSE_PLZA = CLASE_POLIZA
           AND RVN_RAM_CDGO = RAMO;
        DELETE SLCTDES_VGNTES WHERE SVI_NMRO_ITEM = P_SOLICITUD;
        DELETE FROM RSGOS_VGNTES
         WHERE RVI_NMRO_ITEM = P_SOLICITUD
           AND RVI_NMRO_PLZA = POLIZA
           AND RVI_CLSE_PLZA = CLASE_POLIZA
           AND RVI_RAM_CDGO = RAMO;
      END IF;
    END IF;
  END;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 26/09/2012 03:33:30 p.m.
  -- PRC_NOVEDADES
  -- Purpose : Procedimiento que ingresa las novedades del modulo de operación
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                          P_NOVEDAD_WEB IN VARCHAR2) IS

    TIPO_RIESGO         VARCHAR2(1);
    FECHA_PERIODO       DATE;
    MENSAJE2            VARCHAR2(1000);
    TPO_IDEN            VARCHAR2(2);
    IVA                 PLZAS.POL_PRCNTJE_IVA%TYPE;
    NMRO_IDEN           PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;
    TASA_GENERAL        RSGOS_VGNTES_AMPRO.RVA_TSA_AMPRO%TYPE;
    TASA                RSGOS_VGNTES_AMPRO.RVA_TSA_AMPRO%TYPE;
    VALOR_ASEGURADO     NUMBER(16, 2);
    TIPO_TASA           VARCHAR2(1);
    DESCUENTO           NUMBER(4, 2);
    TIPO_VALOR          VARCHAR2(1);
    VALOR_BASE          VARCHAR2(4);
    SUMA                VARCHAR2(1) := 'S';
    SMTRIA_RSGO         VARCHAR2(1) := 'N';
    SMTRIA_PLZA         VARCHAR2(1) := 'N';
    TIENE_DEDUCIBLE     VARCHAR2(1) := 'N';
    PORC_DEDUCIBLE      NUMBER := 0;
    TPO_DEDUCIBLE       VARCHAR2(5);
    MENSAJEVB           VARCHAR2(500);
    --FECHA               DATE;
    EXISTE              NUMBER;
    CUOTAS              NUMBER := 0;
    PRIMA_NETA          NUMBER := 0;
    MNMO_DEDUCIBLE      NUMBER := 0;
    PRIMA_NETA_ANUAL    NUMBER := 0;
    PRIMA_ANUAL         NUMBER := 0;
    PRIMA_ANUAL_ANT     NUMBER := 0;
    PRIMA_NETA_ANT      NUMBER := 0;
    PRIMA_TOTAL         NUMBER := 0;
    PRIMA_TOTAL_ANT     NUMBER := 0;
    IVA_PRIMA           NUMBER := 0;
    IVA_PRIMA_ANT       NUMBER := 0;
    RETRO_NETA          NUMBER := 0;
    RETRO_ANUAL         NUMBER := 0;
    RETRO_TOTAL         NUMBER := 0;
    IVA_RETRO           NUMBER := 0;
    RETRO_NETA_ANT      NUMBER := 0;
    RETRO_ANUAL_ANT     NUMBER := 0;
    RETRO_TOTAL_ANT     NUMBER := 0;
    IVA_RETRO_ANT       NUMBER := 0;
    VALOR_ASEGURADO_ANT NUMBER := 0;
    VALOR_DESCUENTO     NUMBER := 0;
    VALOR_DESCUENTO_ANT NUMBER := 0;
    SOL_INQ             NUMBER;
    PORC_DESCUENTO      NUMBER := 0;
    TARIFA_EXTERNA      AMPROS_PRDCTO.APR_TRFCION_EXTRNA%TYPE;
    --IVA_ANT             NUMBER;

    CURSOR TASAS(AMPARO VARCHAR2) IS
      SELECT TAP_TSA_BSCA, TAP_TPO_TSA, TAP_DSCNTO_TMDOR, TAP_NMRO_CUOTAS
        FROM TRFA_AMPROS_PRDCTO
       WHERE TAP_CDGO_AMPRO = AMPARO
         AND TAP_RAM_CDGO = RAMO
         AND TAP_SUC_CDGO = SUCURSAL
         AND TAP_CIA_CDGO = COMPANIA
         AND TAP_TPO_PLZA = 'C';
    CURSOR VALORES(VALOR VARCHAR2) IS
      SELECT VPR_TPO_VLOR,
             VPR_SMTORIA_RSGO_SN,
             VPR_SMTORIA_PLZA_SN,
             VPR_VLOR_BASE
        FROM VLRES_PRDCTO
       WHERE VPR_RAM_CDGO = RAMO
         AND VPR_CDGO = VALOR;

    CURSOR TASAS_RIESGO(AMPARO VARCHAR2) IS
      SELECT RVA_TPO_TSA
        FROM RSGOS_VGNTES_AMPRO
       WHERE RVA_CDGO_AMPRO = AMPARO
         AND RVA_RAM_CDGO = RAMO
         AND RVA_NMRO_ITEM = SOLICITUD
         AND RVA_NMRO_PLZA = POLIZA
         AND RVA_CLSE_PLZA = CLASE_POLIZA;

  BEGIN

    -- Trae numero identificacion inquilino principal
    BEGIN
      SELECT ARR_SES_NMRO
        INTO SOL_INQ
        FROM ARRNDTRIOS
       WHERE ARR_NMRO_SLCTUD = SOLICITUD;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        MENSAJE := 'ERROR.NO SE PUEDE ENCONTRAR EL ARRENDATARIO DE LA SOLICITUD';
    END;

    BEGIN
      SELECT ARR_TPO_IDNTFCCION, ARR_NMRO_IDNTFCCION
        INTO TPO_IDEN, NMRO_IDEN
        FROM ARRNDTRIOS
       WHERE ARR_NMRO_SLCTUD = SOL_INQ
         AND ARR_SES_NMRO = ARR_NMRO_SLCTUD;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        MENSAJE := 'NO SE PUEDE ENCONTRAR EL ARRENDATARIO DE LA SOLICITUD';
        RETURN;
    END;
    FECHA_PERIODO := TO_DATE('01' || PERIODO, 'DDMMYYYY');
    -- Trae el ultimo certificado abierto para la poliza de la solicitud
    -- Busqueda tasas para cada amparo

    OPEN TASAS(AMPARO);
    FETCH TASAS
      INTO TASA_GENERAL, TIPO_TASA, DESCUENTO, CUOTAS;
    IF TASAS%NOTFOUND THEN
      MENSAJE := 'ERROR EN LA TASA DEL AMPARO ' || AMPARO || sqlerrm;
      ROLLBACK;
      RETURN;
    END IF;
    CLOSE TASAS;

    -- Determinar que valores suman al riesgo y a la poliza
    OPEN VALORES(CONCEPTO);
    FETCH VALORES
      INTO TIPO_VALOR, SMTRIA_RSGO, SMTRIA_PLZA, VALOR_BASE;
    IF VALORES%NOTFOUND THEN
      MENSAJE := 'ERROR EN DATOS DEL VALOR ' || CONCEPTO;
      ROLLBACK;
      RETURN;
    END IF;
    CLOSE VALORES;
    VALOR_ASEGURADO     := VALOR;
    VALOR_ASEGURADO_ANT := VALOR_ANT;

    -- Trae deducibles del amparo y si se suman para el valor asegurado
    BEGIN
      SELECT APR_SMA_VLOR_ASGRDO_SN,
             APR_TNE_DDCBLE_SN,
             APR_PRCNTJE_DDCBLE,
             APR_TPO_DDCBLE,
             APR_VLOR_DDCBLE_MNMO,
             APR_TRFCION_EXTRNA
        INTO SUMA,
             TIENE_DEDUCIBLE,
             PORC_DEDUCIBLE,
             TPO_DEDUCIBLE,
             MNMO_DEDUCIBLE,
             TARIFA_EXTERNA
        FROM AMPROS_PRDCTO
       WHERE APR_CDGO_AMPRO = AMPARO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        MENSAJE := 'ERROR EN AMPARO ' || AMPARO;
        ROLLBACK;
        RETURN;
    END;

    OPEN TASAS_RIESGO(AMPARO);
    FETCH TASAS_RIESGO
      INTO TIPO_RIESGO;
    IF TASAS_RIESGO%NOTFOUND THEN
      NULL;
    END IF;
    CLOSE TASAS_RIESGO;

    -- Trae el porcentaje de IVA definido
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
        MENSAJE := 'ERROR EN LA BUSQUEDA DEL IVA';
        ROLLBACK;
        RETURN;
      WHEN OTHERS THEN
        MENSAJE := 'ERROR EN LA BUSQUEDA DEL IVA';
        ROLLBACK;
        RETURN;
    END;

    /* VERIFICAR SI YA TIENE UNA NOVEDAD PARA EL PERIODO */
    IF ENTRO = 0 THEN
       -- SE ELIMINA PORQUE CON LA NUEVA CONDICION DE HACER VARIOS AUMENTOS EN UN MES
       -- SPPC. 03/03/2014
     /* Begin
        select rivn_fcha_nvdad
          into fecha
          from rsgos_vgntes_nvddes
         where rivn_nmro_item = SOLICITUD
           and rivn_nmro_plza = POLIZA
           and rivn_clse_plza = CLASE_POLIZA
           and rivn_ram_cdgo = RAMO
           and rivn_cdgo_ampro = AMPARO
           and TO_CHAR(rivn_fcha_nvdad, 'MM/YYYY') =
               TO_CHAR(FECHA_PERIODO, 'MM/YYYY');
        if fecha = FECHA_NOVEDAD then
          MENSAJE := 'SOLO SE PUEDE REGISTRAR UNA NOVEDAD POR PERIODO.';
          ROLLBACK;
          RETURN;
        End if;*/
        IF P_NOVEDAD_WEB = 'S' THEN
          -- G.G.M. 26/09/2011 Para validar que no se pueda realizar el ingreso y retiro o aumento en
          -- el mismo periodo
          SELECT COUNT(8)
            INTO EXISTE
            FROM RSGOS_VGNTES_NVDDES B
           WHERE B.RIVN_NMRO_ITEM = SOLICITUD
             AND TO_CHAR(B.RIVN_FCHA_MDFCCION, 'MMYYYY') =
                 TO_CHAR(FECHA_PERIODO, 'MMYYYY')
             AND B.RIVN_TPO_NVDAD = '01';
          IF EXISTE > 0 AND NOVEDAD IN ('04', '02') THEN
            MENSAJE := ' SOLO SE PUEDE REGISTRAR UNA NOVEDAD POR PERIODO.';
            RETURN;
          END IF;
        END IF;
      /*Exception
        When no_data_found then
          null;
        WHEN too_many_rows THEN
          NULL;
      End;*/
    END IF;

    -- Calculo de las primas para el amparo
    IF NOVEDAD = '02' AND TIPO_RIESGO NOT IN ('M', 'U') THEN
      PRC_LIQUIDACION_T(SOLICITUD,
                    NOVEDAD,
                    RAMO,
                    POLIZA,
                    FECHA_NOVEDAD,
                    CLASE_POLIZA,
                    AMPARO,
                    CONCEPTO,
                    VALOR_ANT,
                    VALOR,
                    IVA,
                    PERIODO,
                    USUARIO,
                    PRIMA_NETA_ANT,
                    PRIMA_NETA,
                    PRIMA_TOTAL_ANT,
                    PRIMA_TOTAL,
                    PRIMA_ANUAL_ANT,
                    PRIMA_ANUAL,
                    IVA_PRIMA_ANT,
                    IVA_PRIMA,
                    PORC_DESCUENTO,
                    CUOTAS,
                    MENSAJE2,
                    TASA,
                    TIPO_TASA,
                    TIPO_TASA_P,
                    TASA_P,
                    SUCURSAL,
                    COMPANIA);
    ELSE
      PRC_LIQUIDACION(SOLICITUD,
                  RAMO,
                  POLIZA,
                  FECHA_NOVEDAD,
                  CLASE_POLIZA,
                  AMPARO,
                  CONCEPTO,
                  VALOR_ANT,
                  VALOR,
                  IVA,
                  PERIODO,
                  USUARIO,
                  PRIMA_NETA_ANT,
                  PRIMA_NETA,
                  PRIMA_TOTAL_ANT,
                  PRIMA_TOTAL,
                  PRIMA_ANUAL_ANT,
                  PRIMA_ANUAL,
                  IVA_PRIMA_ANT,
                  IVA_PRIMA,
                  PORC_DESCUENTO,
                  CUOTAS,
                  MENSAJE2,
                  TASA,
                  TIPO_TASA,
                  TIPO_TASA_P,
                  TASA_P,
                  SUCURSAL,
                  COMPANIA,
                  NOVEDAD);
      IF MENSAJE2 IS NOT NULL THEN
        MENSAJE := MENSAJE2;
        ROLLBACK;
        RETURN;
      END IF;
    END IF;

    -- traer la fecha de retiro de la solicitud.
    TRAER_FECHA_RETIRO(FECHA_NOVEDAD,
                       PERIODO,
                       SOLICITUD,
                       RAMO,
                       POLIZA,
                       CLASE_POLIZA,
                       AMPARO,
                       NOVEDAD,
                       MENSAJE);

    -- verificar si la fecha de la novedad es anterior  a la del periodo actual, para calcular
    -- la prima retroactiva.
    PRC_CALCULAR_RETROACTIVIDAD(FECHA_NOVEDAD,
                            PERIODO,
                            PRIMA_NETA,
                            PRIMA_ANUAL,
                            PRIMA_TOTAL,
                            IVA_PRIMA,
                            PRIMA_NETA_ANT,
                            PRIMA_ANUAL_ANT,
                            PRIMA_TOTAL_ANT,
                            IVA_PRIMA_ANT,
                            VALOR_DESCUENTO,
                            VALOR_DESCUENTO_ANT,
                            RETRO_NETA,
                            RETRO_ANUAL,
                            RETRO_TOTAL,
                            IVA_RETRO,
                            RETRO_NETA_ANT,
                            RETRO_ANUAL_ANT,
                            RETRO_TOTAL_ANT,
                            IVA_RETRO_ANT,
                            MODULO,
                            CESION,
                            TIPO_TASA,
                            MENSAJE2);
    IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
    END IF;

    -- Ingreso novedades segun el tipo
    PRC_INGRESOS(NOVEDAD,
             SOLICITUD,
             POLIZA,
             CLASE_POLIZA,
             RAMO,
             FECHA_NOVEDAD,
             CERTIFICADO,
             NMRO_IDEN,
             TPO_IDEN,
             VALOR_ASEGURADO,
             VALOR_ANT,
             VALOR,
             PRIMA_NETA_ANT,
             PRIMA_NETA,
             PRIMA_ANUAL_ANT,
             PRIMA_ANUAL,
             ENTRO,
             USUARIO,
             MENSAJE2);

    IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
    END IF;

    -- Actualiza valores del riesgo
    PRC_ACTUALIZA_VALOR(NOVEDAD,
                    SOLICITUD,
                    POLIZA,
                    CLASE_POLIZA,
                    RAMO,
                    CERTIFICADO,
                    CONCEPTO,
                    AMPARO,
                    VALOR_ANT,
                    VALOR,
                    USUARIO,
                    MENSAJE2);
    IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
    END IF;

    --   Actualiza el concepto que agrupa el valor
    PRC_ACTUALIZA_VALORES(NOVEDAD,
                      SOLICITUD,
                      POLIZA,
                      CLASE_POLIZA,
                      RAMO,
                      CERTIFICADO,
                      CONCEPTO,
                      AMPARO,
                      VALOR_ANT,
                      VALOR,
                      ENTRO,
                      USUARIO,
                      MENSAJE2);

    IF MENSAJE2 IS NOT NULL THEN
      MENSAJE := MENSAJE2;
      ROLLBACK;
      RETURN;
    END IF;

    -- Ingresa arrendatarios en el riesgo
    PRC_ARRENDATARIOS(NOVEDAD,
                  SOLICITUD,
                  POLIZA,
                  CLASE_POLIZA,
                  RAMO,
                  AMPARO,
                  CONCEPTO,
                  CERTIFICADO,
                  ENTRO,
                  USUARIO,
                  MENSAJE2);

    IF MENSAJE2 IS NOT NULL THEN
      IF MENSAJE2 LIKE '%restringido%' THEN
        NULL;
      ELSE
         MENSAJE := MENSAJE2;
        ROLLBACK;
        RETURN;
      END IF;
    END IF;

    -- Crea el valor para el amparo
    PRC_AMPAROS(NOVEDAD,
            SOLICITUD,
            POLIZA,
            CLASE_POLIZA,
            RAMO,
            AMPARO,
            CONCEPTO,
            CERTIFICADO,
            VALOR_ASEGURADO_ANT,
            VALOR_ASEGURADO,
            PRIMA_NETA_ANT,
            PRIMA_NETA,
            PRIMA_NETA_ANUAL,
            PRIMA_ANUAL_ANT,
            PRIMA_ANUAL,
            TIPO_TASA,
            TASA,
            TPO_DEDUCIBLE,
            PORC_DEDUCIBLE,
            MNMO_DEDUCIBLE,
            TPO_IDEN,
            NMRO_IDEN,
            PORC_DESCUENTO,
            IVA,
            ENTRO,
            USUARIO,
            FECHA_NOVEDAD,
            MENSAJE2);

    IF MENSAJE2 IS NOT NULL THEN
      IF MENSAJE2 LIKE '%restringido%' THEN
        NULL;
      ELSE
         MENSAJE := MENSAJE2;
        ROLLBACK;
        RETURN;
      END IF;
    END IF;

    -- Actualiza los valores para el amparo
 
    PRC_ACTUALIZA_AMPAROS(NOVEDAD,
                          SOLICITUD,
                          POLIZA,
                          CLASE_POLIZA,
                          RAMO,
                          CONCEPTO,
                          CERTIFICADO,
                          AMPARO,
                          VALOR_ANT,
                          VALOR,
                          PRIMA_NETA,
                          PRIMA_NETA_ANT,
                          IVA_PRIMA,
                          IVA_PRIMA_ANT,
                          TASA,
                          USUARIO,
                          MENSAJE2);
    IF MENSAJE2 IS NOT NULL THEN
      IF MENSAJE2 LIKE '%restringido%' THEN
        NULL;
      ELSE
         MENSAJE := MENSAJE2;
        ROLLBACK;
        RETURN;
      END IF;
    END IF;

    -- Inserta en la tabla de novedades
    PRC_INSERTA_NOVEDAD(NOVEDAD,
                    SOLICITUD,
                    POLIZA,
                    CLASE_POLIZA,
                    RAMO,
                    FECHA_NOVEDAD,
                    CONCEPTO,
                    AMPARO,
                    CERTIFICADO,
                    VALOR_ANT,
                    VALOR,
                    VALOR_ASEGURADO_ANT,
                    VALOR_ASEGURADO,
                    ENTRO,
                    USUARIO,
                    FECHA_PERIODO,
                    CESION,
                    MENSAJE2);
    IF MENSAJE2 IS NOT NULL THEN
      IF MENSAJE2 LIKE '%restringido%' THEN
        NULL;
      ELSE
         MENSAJE := MENSAJE2;
        ROLLBACK;
        RETURN;
      END IF;
    END IF;

    -- Actualizar valores asegurados y de primas para los ingresos al seguro
    PRC_VALORES_PRIMAS(NOVEDAD,
                   FECHA_NOVEDAD,
                   POLIZA,
                   CLASE_POLIZA,
                   RAMO,
                   AMPARO,
                   CERTIFICADO,
                   SOLICITUD,
                   PRIMA_NETA_ANT,
                   PRIMA_NETA,
                   PRIMA_TOTAL_ANT,
                   PRIMA_TOTAL,
                   PRIMA_ANUAL_ANT,
                   PRIMA_ANUAL,
                   VALOR_ASEGURADO_ANT,
                   VALOR_ASEGURADO,
                   IVA,
                   IVA_PRIMA_ANT,
                   IVA_PRIMA,
                   RETRO_NETA,
                   RETRO_ANUAL,
                   RETRO_TOTAL,
                   IVA_RETRO,
                   RETRO_NETA_ANT,
                   RETRO_ANUAL_ANT,
                   RETRO_TOTAL_ANT,
                   IVA_RETRO_ANT,
                   PERIODO,
                   CUOTAS,
                   ENTRO,
                   USUARIO,
                   MENSAJE2,
                   CESION,
                   COBRAR,
                   TIPO_TASA);
    IF MENSAJE2 IS NOT NULL THEN
      IF MENSAJE2 LIKE '%restringido%' THEN
        NULL;
      ELSE
         MENSAJE := MENSAJE2;
        ROLLBACK;
        RETURN;
      END IF;
    END IF;

    --  Borra los valores de la solicitud a retirar o las tablas de historicos si ha
    --   sido un reingreso
    PRC_BORRAR_REGISTROS(NOVEDAD,
                     SOLICITUD,
                     POLIZA,
                     CLASE_POLIZA,
                     RAMO,
                     CONCEPTO,
                     AMPARO);

    -- INCLUIR DATOS EN LA AUDITORIA
    IF ENTRO = 0 THEN
      insertar_auditoria('RSGOS_VGNTES_NVDDES',
                         to_char(sysdate),
                         AMPARO,
                         RAMO,
                         TO_CHAR(SOLICITUD),
                         TO_CHAR(POLIZA),
                         NOVEDAD,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         'RIVN_VLOR_DFRNCIA',
                         TO_CHAR(VALOR_ANT),
                         TO_CHAR(VALOR),
                         MODULO,
                         USUARIO,
                         SYSDATE,
                         'control de datos de novedades.',
                         MENSAJE);

    END IF;
    
    -- VERIFICA QUE LOS CONCEPTOS TENGAN VALOR BASE
    -- MANTIS 58109 03/10/2017 GGM.
    IF NOVEDAD IN ('01','05') THEN
      MENSAJEVB  := NULL;
      PRC_VALOR_BASE(SOLICITUD,
                     CONCEPTO,
                     POLIZA,
                     CLASE_POLIZA,
                     RAMO,
                     AMPARO,
                     USUARIO,
                     MENSAJEVB);
      IF MENSAJEVB IS NOT NULL THEN
        MENSAJE := MENSAJEVB;
        ROLLBACK;
        RETURN;
      END IF;  
    END IF;

  END PRC_NOVEDADES;
  
  --
  -- MANTIS 58109 03/10/2017 GGM.
  --
  PROCEDURE PRC_VALOR_BASE(P_SOLICITUD  NUMBER,
                           P_CONCEPTO   VARCHAR2,
                           P_POLIZA     NUMBER,
                           P_CLASE      VARCHAR2,
                           P_RAMO       VARCHAR2,
                           P_AMPARO     VARCHAR2,
                           P_USUARIO    VARCHAR2,
                           P_MENSAJE    OUT VARCHAR2) IS
                           
                                  
  V_VALOR_BASE   VLRES_PRDCTO.VPR_VLOR_BASE%TYPE;
  EXISTE         NUMBER;
  V_VALOR        NUMBER;
  
  BEGIN
    BEGIN
      SELECT VPR_VLOR_BASE
        INTO V_VALOR_BASE
        FROM VLRES_PRDCTO
       WHERE VPR_RAM_CDGO = P_RAMO
         AND VPR_CDGO = P_CONCEPTO;
    
      SELECT COUNT(8)
        INTO EXISTE
        FROM RSGOS_VGNTES_VLRES
       WHERE RVV_NMRO_ITEM = P_SOLICITUD
         AND RVV_NMRO_PLZA = P_POLIZA
         AND RVV_CNCPTO_VLOR = V_VALOR_BASE;
         
      SELECT NVL(SUM(RVL_VLOR),0)
        INTO V_VALOR
        FROM RSGOS_VGNTES_AVLOR
       WHERE RVL_NMRO_ITEM = P_SOLICITUD
         AND RVL_CDGO_AMPRO = P_AMPARO;
           
      IF NVL(EXISTE,0) = 0 THEN
        BEGIN
          INSERT INTO RSGOS_VGNTES_VLRES
            (RVV_NMRO_ITEM,    
             RVV_NMRO_PLZA,    
             RVV_CLSE_PLZA,    
             RVV_RAM_CDGO,     
             RVV_CNCPTO_VLOR,  
             RVV_VLOR,         
             RVV_USRIO,        
             RVV_FCHA_MDFCCION)
          VALUES
            (P_SOLICITUD,
             P_POLIZA,
             P_CLASE,
             P_RAMO,
             V_VALOR_BASE,
             V_VALOR,
             P_USUARIO,
             SYSDATE);
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'ERROR INSERCION RSGOS_VGNTTES_VLRES PRC_VALOR_BASE. ' || sqlerrm;
            ROLLBACK;
            RETURN;
        END; 
      ELSE
        BEGIN
          UPDATE RSGOS_VGNTES_VLRES
             SET RVV_VLOR = V_VALOR
           WHERE RVV_NMRO_ITEM = P_SOLICITUD   
             AND RVV_NMRO_PLZA = P_POLIZA   
             AND RVV_CLSE_PLZA = P_CLASE
             AND RVV_RAM_CDGO = P_RAMO     
             AND RVV_CNCPTO_VLOR = V_VALOR_BASE;  
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'ERROR ACTUALIZANDO RSGOS_VGNTTES_VLRES RN PRC_VALOR_BASE. ' || sqlerrm;
            ROLLBACK;
            RETURN;
        END; 
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_MENSAJE := 'ERROR CONSULTANDO EL VALOR BASE DL CONCEPTO . ' ||P_CONCEPTO||' '||sqlerrm;
        ROLLBACK;
        RETURN;
    END;    
   
  END PRC_VALOR_BASE; 

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 28/09/2012 03:33:30 p.m.
  -- PRC_AUMENTO_HOGAR
  -- Purpose : Procedimiento que valida si el valor del amparo de Hogar cambia
  -- entonces realiza el aumento
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                              P_DVSION_POLITICA  NUMBER) IS

  VALOR_ASEGURADO    NUMBER;
  VALOR_PRIMA        NUMBER;
  NOVEDADES          VARCHAR2(2):= '04';
  TIPO_AMPARO        AMPROS_PRDCTO.APR_TPO_AMPRO%TYPE;
  ENTRO              NUMBER:=0;
  MENSAJE            VARCHAR2(1000):=NULL;
  V_IDENTIFICACION     PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE;


  BEGIN

        BEGIN
          SELECT P.POL_PRS_NMRO_IDNTFCCION
            INTO V_IDENTIFICACION
            FROM PLZAS P
           WHERE P.POL_NMRO_PLZA = P_POLIZA
             AND P.POL_CDGO_CLSE = P_CLASE
             AND P.POL_RAM_CDGO  = P_RAMO;
        EXCEPTION
          WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20501, SQLERRM);
        END;


    BEGIN
      PKG_INTERFACE_TRONADOR.PRC_VALOR_PRIMA(P_RAMO,
                                             P_AMPARO,
                                             V_IDENTIFICACION,
                                             P_SOLICITUD,
                                             P_CONCEPTO,
                                             VALOR_ASEGURADO,
                                             VALOR_PRIMA);
    EXCEPTION
      WHEN OTHERS THEN
        P_MENSAJE := 'Error en PKG_INTERFACE_TRONADOR.PRC_VALOR_PRIMA..'||sqlerrm;
    END;
 
    IF VALOR_ASEGURADO !=  P_NUEVO_VALOR THEN
      BEGIN
        TIPO_AMPARO := FUN_TIPO_AMPARO(P_AMPARO,P_RAMO);
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := 'Error consultandoel tipo de Amparo..'||sqlerrm;
      END;
      PRC_AUMENTO_SEGURO(P_SOLICITUD,
                         P_POLIZA,
                         P_AMPARO,
                         TIPO_AMPARO,
                         P_CLASE,
                         P_RAMO,
                         P_COMPANIA,
                         P_SUCURSAL,
                         FECHA_NOVEDAD,
                         NOVEDADES,
                         VALOR_ASEGURADO,
                         P_VALOR_ANT,
                         P_CONCEPTO,
                         VALOR_ASEGURADO,
                         FECHA_INGRESO,
                         P_CODIGO_USUARIO,
                         ENTRO,
                         P_NOVEDAD_WEB,
                         MENSAJE,
                         P_DESTINO_INMUEBLE,
                         P_DVSION_POLITICA,NULL);
      IF MENSAJE IS NOT NULL THEN
        P_MENSAJE := MENSAJE;
      END IF;
    END IF;

  END PRC_AUMENTO_HOGAR;

  /**********************************************************************/
  -- Author  : Gloria Gantiva M.
  -- Created : 28/09/2012
  -- PRC_AUMENTO_SEGURO
  -- Purpose : Procedimiento para que realice el aumento de un amparo
  -- Modificado por:
  --
  --
  /***********************************************************************/
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
                               P_IVA              VARCHAR2) IS

    RECHAZO          VARCHAR2(3);
    TIPO             VARCHAR2(2);
    DESCRIPCION      VARCHAR2(1000);
    CERTIFICADO      NUMBER(10);
    SINIESTRO        NUMBER(10);
    FECHA            DATE;
    ESTADO           VARCHAR2(2);
    ESTADO_SINIESTRO VARCHAR2(2);
    FECHA_NOVEDAD    DATE;
    V_AUMENTO          VARCHAR2(1):= 'N';
    V_MENSAJE        VARCHAR2(2000) := NULL;
    MENSAJE_INF      VARCHAR2(2000) := NULL;
    CODIGO_MODULO    VARCHAR2(2) := '2';
    GLOBAL_PERIODO   VARCHAR2(6) := TO_CHAR(FECHA_NVDAD, 'MMYYYY');

  BEGIN
    FECHA_NOVEDAD := TRUNC(FECHA_NVDAD) + (SYSDATE - TRUNC(SYSDATE));

    IF FUN_VALOR_CONCEPTO(RAMO,RVL_CNCPTO_VLOR) < NUEVO_VALOR THEN
      MENSAJE := 'El Valor Asegurado no puede ser menor al mínimo parametrizado.';
    END IF;
    ENTRO := 0;
    -- LLEVA EL CONTROL SI SE REALIZO CAMBIOS DE VALOR ASEGURADO PARA PERMITIR GRABAR LA NOVEDAD. SPPC. 28/05/2012.
    IF RVL_VLOR != NUEVO_VALOR THEN
      V_AUMENTO := 'S';
    END IF;

    PRC_VALIDA_MANUAL('N',
                      NOVEDADES,
                      SOLICITUD,
                      SES_NMRO_PLZA,
                      CLASE,
                      RAMO,
                      APR_CDGO_AMPRO,
                      FECHA_NOVEDAD,
                      CERTIFICADO,
                      RVL_CNCPTO_VLOR,
                      RVL_VLOR,
                      COMPANIA,
                      SUCURSAL,
                      APR_TPO_AMPRO,
                      RECHAZO,
                      V_MENSAJE,
                      CODIGO_MODULO,
                      CODIGO_USUARIO,
                      MENSAJE_INF,
                      TTAL_ASGRDO,
                      P_NOVEDAD_WEB,
                      P_DESTINO_INMUEBLE,
                      P_DVSION_POLITICA,'S',P_IVA,NULL);
    IF MENSAJE IS NOT NULL THEN
      MENSAJE := V_MENSAJE;
    END IF;

    -- EL AUMENTO NO PUEDE SER MENOR A LA FECHA DE INGRESO DEL AMPARO.
    IF FECHA_NVDAD < FECHA_INGRESO THEN
      RECHAZO := 5;
    END IF;

    IF RECHAZO IS NOT NULL THEN
      BEGIN
        SELECT RCN_TPO_CDGO, RCN_DSCRPCION
          INTO TIPO, DESCRIPCION
          FROM RCHZOS_NVDDES
         WHERE RCN_RAM_CDGO = RAMO
           AND RCN_CDGO = RECHAZO;
      EXCEPTION
        WHEN no_data_found THEN
          MENSAJE := 'El código de rechazo de la novedad no existe. Consulte al administrador del sistema.';
          return;
      END;
      IF TIPO = 'E' THEN
        MENSAJE := 'No se puede realizar el Aumento de Valor Asegurado. ' ||RECHAZO||'- '||DESCRIPCION;
        return;
      END IF;
    ELSE
      BEGIN
        PRC_NOVEDADES(SOLICITUD,
                      SES_NMRO_PLZA,
                      CLASE,
                      RAMO,
                      SUCURSAL,
                      COMPANIA,
                      FECHA_NOVEDAD,
                      APR_CDGO_AMPRO,
                      RVL_CNCPTO_VLOR,
                      RVL_VLOR,
                      CERTIFICADO,
                      NUEVO_VALOR,
                      NOVEDADES,
                      ENTRO,
                      CODIGO_MODULO,
                      V_MENSAJE,
                      CODIGO_USUARIO,
                      'NO',
                      'SI',
                      GLOBAL_PERIODO,
                      NULL,
                      NULL,
                      P_NOVEDAD_WEB);
      EXCEPTION
        WHEN OTHERS THEN
          MENSAJE := V_MENSAJE;
          RETURN;
      END;
      IF V_MENSAJE IS NOT NULL THEN
        MENSAJE := V_MENSAJE;
        RETURN;
      ELSE
        IF CODIGO_MODULO = '3' THEN
          /* INDEMNIZACION */
          PR_CORREGIR_LIQUIDACION(SOLICITUD,
                                  RAMO,
                                  SES_NMRO_PLZA,
                                  CLASE,
                                  APR_CDGO_AMPRO,
                                  RVL_CNCPTO_VLOR,
                                  RVL_VLOR,
                                  FECHA_NOVEDAD,
                                  CODIGO_USUARIO,
                                  V_MENSAJE);
          IF V_MENSAJE IS NOT NULL THEN
            MENSAJE := V_MENSAJE;
            RETURN;
          ELSE
            BEGIN
              SELECT MAX(SNA_NMRO_SNSTRO),
                     SNA_ESTDO_PGO,
                     SNA_ESTDO_SNSTRO
                INTO SINIESTRO, ESTADO, ESTADO_SINIESTRO
                FROM AVSOS_SNSTROS
               WHERE SNA_NMRO_ITEM = SOLICITUD
                 AND SNA_NMRO_PLZA = SES_NMRO_PLZA
                 AND SNA_CLSE_PLZA = CLASE
                 AND SNA_RAM_CDGO = RAMO
              GROUP BY SNA_NMRO_SNSTRO, SNA_ESTDO_PGO;
              IF SINIESTRO IS NULL THEN
                MENSAJE := 'No encontro el siniestro asociado a la solicitud';
                RETURN;
              ELSE
                IF ESTADO IN ('02', '03') AND ESTADO_SINIESTRO != '03' THEN
                  MENSAJE := 'El siniestro se encuentra objetado o suspendido por lo tanto no se pueden realizar aumentos';
                END IF;
              END IF;
            EXCEPTION
              WHEN no_data_found THEN
                MENSAJE := 'No encontro el siniestro asociado a la solicitud';
                RETURN;
              WHEN OTHERS THEN
                MENSAJE := 'Error en la consulta del siniestro '||SQLERRM;
                RETURN;
            END;
            FECHA := TO_DATE('01' || GLOBAL_PERIODO, 'DDMMYYYY');
            BEGIN
              UPDATE AJSTES_SNSTROS
                 SET AJS_VLOR_AJSTE = AJS_VLOR_AJSTE - NUEVO_VALOR + RVL_VLOR
               WHERE AJS_FCHA_AJSTE = FECHA
                 AND AJS_RAM_CDGO = RAMO
                 AND AJS_NMRO_SNSTRO = SINIESTRO;
            EXCEPTION
              WHEN others THEN
                MENSAJE := 'El usuario no tiene permiso para realizar aumentos desde indemnizaciones.';
                RETURN;
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
                       RAMO,
                       SINIESTRO,
                       RVL_VLOR - NUEVO_VALOR,
                       0,
                       CODIGO_USUARIO,
                       SYSDATE);
                IF SQL%NOTFOUND THEN
                  MENSAJE := 'El usuario no tiene permiso para realizar aumentos desde indemnizaciones.';
                  RETURN;
                END IF;
              EXCEPTION
                WHEN others THEN
                  MENSAJE := 'El usuario no tiene permiso para realizar aumentos desde indemnizaciones.';
                  RETURN;
              END;
            END IF;
          END IF;
        END IF;
      END IF;
      IF MENSAJE IS NULL THEN
        -- SE INCLUYE ESTA VALIDACION PARA QUE NO PERMITA HACER AUMENTOS DE VALOR ASEGURADO SINO HAN REALIZADO
        -- CAMBIOS EN LOS VALORES ASEGURADOS. SPPC. 28/05/2012.
        IF V_AUMENTO != 'S' THEN
          ROLLBACK;
          MENSAJE := 'No se realiza la novedad de Aumento de Valor Asegurado. Porque no se registraron cambios en los valores de los conceptos.';
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      MENSAJE := 'Error en procedimiento de aumento al seguro '||sqlerrm;

  END PRC_AUMENTO_SEGURO;

  -- DESDE AQUI ES NUEVO PARA RECAUDO DE PRIMAS

  --
  -- mantis 37979  22/07/2015 GGM.
  --
  PROCEDURE PRC_DIFERENCIAS(P_RECIBO     IN NUMBER,
                            P_COMPANIA   IN VARCHAR2,
                            P_DIFERENCIA IN NUMBER,
                            P_VALOR      OUT NUMBER) IS

  BEGIN
    UPDATE CNCPTOS_DTLLE_RCBOS
       SET CDR_VLOR = CDR_VLOR - P_DIFERENCIA
     WHERE CDR_NMRO_RCBO = P_RECIBO
       AND CDR_TPO_RCBO = 'R'
       AND CDR_CDGO_CIA = P_COMPANIA
       AND CDR_CDGO_CNCPTO = 'IVA'
       AND ROWNUM = 1;
    BEGIN
      SELECT SUM(EST_VLOR_AFNZDO)
        INTO P_VALOR
        FROM ESTADO_CTA_RCBOS
       WHERE EST_NMRO_RCBO = P_RECIBO
         AND EST_CIA_CDGO = P_COMPANIA
         AND EST_TPO_RCBO = 'R';
     EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20531,sqlerrm);
     END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20523,'Error en actualizar diferencia '||sqlerrm);

  END PRC_DIFERENCIAS;


    /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 18/03/2012 11:33:30 a.m.
  -- PRC_TESORERIA
  -- Purpose : Procedimiento que realiza la inserción en las tablas de la
  -- interface de Tesorería de Tronador. Para que el cajero pueda recaudar
  -- el dinero por el sistema Tronador.
  -- Modificado por:
  -- FUNCION PARA PAGO DE PRIMAS DE ARRENDAMIENTO NUEVO
  --
  /***********************************************************************/
  PROCEDURE PRC_TESORERIA(P_NORECIBO          NUMBER,
                          P_CIA               VARCHAR2,
                          P_TEXTO             VARCHAR2,
                          P_VALORR            NUMBER,
                          P_POLIZA            NUMBER,
                          P_CODIGO_SUCURSAL   SCRSL.SUC_CDGO%TYPE,
                          P_NMRO_IDEN         NUMBER,
                          P_TIPO_IDEN         VARCHAR2,
                          P_TIPO_ACTIVIDAD    NUMBER,
                          P_FECHA_RECIBO      DATE) IS

   CURSOR  C_CONCEPTOS IS
     SELECT C.CDR_CDGO_CNCPTO, C.CDR_VLOR
       FROM CNCPTOS_DTLLE_RCBOS C
       WHERE C.CDR_NMRO_RCBO = P_NoRecibo
         AND C.CDR_CDGO_CIA = P_CIA;

   TipoOrd                  VARCHAR2(1) := 'E';
   ConcepT                  VARCHAR2(10);
   Concepto                 VARCHAR2(10);
   DescrpT                  VARCHAR2(160);
   Descripcion              VARCHAR2(500);
   vSuma                    NUMBER;
   RECIBIDO_DE              VARCHAR2(300);
   V_CIA_TRO40              CNVRSION_TRNDOR.CNT_CMPNIA_TRNDOR%TYPE;
   V_AGCIA_TRON40           CNVRSION_TRNDOR.CNT_AGNCIA_TRNDOR%TYPE;
   V_TESORERIA_40           CG_REF_CODES.RV_MEANING%TYPE;
   V_TESORERIA_42           CG_REF_CODES.RV_MEANING%TYPE;
   V_VALOR                  NUMBER;
   V_DIFERENCIA             NUMBER;
   R_CONC                   C_CONCEPTOS%ROWTYPE;

  BEGIN
   BEGIN
    SELECT SUM(EST_VLOR_AFNZDO)
      INTO vSuma
      FROM ESTADO_CTA_RCBOS
     WHERE EST_NMRO_RCBO = P_NoRecibo
       AND EST_CIA_CDGO =P_Cia
       AND EST_TPO_RCBO = 'R';
   EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20531,sqlerrm);
   END;

   V_DIFERENCIA := NVL(vSuma,0) - NVL(P_Valorr,0);
   IF ROUND(V_DIFERENCIA,0) BETWEEN -5 AND 5 THEN
     PRC_DIFERENCIAS(P_NoRecibo,P_Cia,V_DIFERENCIA,V_VALOR);
   END IF;
   vSuma := V_VALOR;

   IF NVL(vSuma,0) <>  P_Valorr THEN
     RAISE_APPLICATION_ERROR(-20501,'Errores en Totales' || to_char(P_Valorr) || ' - ' || to_char(vSuma));
   END IF;

    BEGIN
     SELECT RV_MEANING
       INTO V_TESORERIA_40
       FROM CG_REF_CODES C
      WHERE C.RV_DOMAIN  ='CONCEP_TESORERIA_PRM'
        AND RV_LOW_VALUE = '40';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,'Error buscando concepto de la tesorería 40');
    END;


    BEGIN
      SELECT RV_MEANING
       INTO V_TESORERIA_42
       FROM CG_REF_CODES C
      WHERE C.RV_DOMAIN  ='CONCEP_TESORERIA'
        AND RV_LOW_VALUE = '42';

    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,'Error buscando concepto de la tesorería 42');
    END;

    BEGIN
       SELECT CNT_CMPNIA_TRNDOR, CNT_AGNCIA_TRNDOR
         INTO V_CIA_TRO40, V_AGCIA_TRON40
         FROM CNVRSION_TRNDOR
        WHERE CNT_CMPNIA     = '40'
          AND CNT_SCRSAL     = P_CODIGO_SUCURSAL
          AND CNT_CLSE_ASNTO = 'RAR';
    EXCEPTION
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20506,'Error al Recuperar el Parametro Agencia en la tabla<<CNVRSION_TRNDOR>> para la compañia LIBERTADOR.');
    END ;


    BEGIN
        SELECT PK_TERCEROS.f_Nombres(P_NMRO_IDEN,P_TIPO_IDEN )
          INTO Descripcion
          FROM DUAL;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20501,SQLERRM);
    END;


    Descripcion := 'RECIBIDO DE : ' || RECIBIDO_DE|| CHR(10) || CHR(10)
                  || Descripcion;

    Descripcion := SUBSTR(Descripcion,1,199);


    BEGIN
      pk_inter_teso_sai_int.nuevo_docu(TO_CHAR(P_NoRecibo),V_CIA_TRO40, TipoOrd,
             P_NMRO_IDEN, P_TIPO_IDEN,P_TIPO_ACTIVIDAD,P_Valorr, V_TESORERIA_40,V_AGCIA_TRON40,
            Descripcion, SUBSTR(P_Texto,1,300), TO_CHAR(P_POLIZA), Lower(user));

   EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20506,SQLERRM);
   END;


  open C_CONCEPTOS;
  loop
    fetch C_CONCEPTOS into R_CONC;
    exit when C_CONCEPTOS%notfound;

         Select CNR_CDGO_TNT
           INTO ConcepT
           FROM CNCPTOS_RCDOS
          WHERE CNR_CDGO =  R_CONC.CDR_CDGO_CNCPTO;

          Select CNR_DSCRPCION
             INTO DescrpT
             FROM CNCPTOS_RCDOS
           WHERE CNR_CDGO = ConcepT;


     IF R_CONC.CDR_CDGO_CNCPTO = 'IVA' THEN

        Select CNR_CDGO_TNT
          INTO CONCEPTO
          FROM CNCPTOS_RCDOS
         WHERE CNR_CDGO = 'PRM';

        IF R_CONC.CDR_VLOR <> 0 THEN


          BEGIN
            pk_inter_teso_sai_int.det_concepto(P_NoRecibo, Concepto,ConcepT, DescrpT, R_CONC.CDR_VLOR);
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20501,SQLERRM);
          END;



      END IF;
    ELSIF   R_CONC.CDR_CDGO_CNCPTO = 'IASI' THEN
      BEGIN
        pk_inter_teso_sai_int.det_concepto(p_NoRecibo, 'ASIS','IASI', 'IVA DE HOGAR', round(R_CONC.CDR_VLOR,0));
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20504,'en IVA HOGAR teso sai');
      END;


    ELSE
      BEGIN
         pk_inter_teso_sai_int.total_concepto(P_NoRecibo, ConcepT, DescrpT, R_CONC.CDR_VLOR);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20501,SQLERRM);
      END;

    END IF;

  end loop;
  close C_CONCEPTOS;


   BEGIN
      pk_inter_teso_sai_int.cerrar_liquidacion(P_NoRecibo, V_CIA_TRO40,'E',
           TO_CHAR(P_FECHA_RECIBO,'YYYYMMDD HH24:MI:SS'));
   EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20508,SQLERRM);
   END;

  END PRC_TESORERIA;

  --
  --
  --
  PROCEDURE PRC_PAGO_PRIMAS(P_POLIZA          PLZAS.POL_NMRO_PLZA%TYPE,
                            P_NMRO_IDNTFCCION PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE,
                            P_TPO_IDNTFCCION  PLZAS.POL_PRS_TPO_IDNTFCCION%TYPE,
                            P_VALOR_PAGAR     NUMBER,
                            P_ORIGEN          VARCHAR2,
                            P_CODIGO_LIQ      IN OUT NUMBER,
                            P_ESTADO          IN OUT VARCHAR2,
                            P_MENSAJE         IN OUT VARCHAR2) IS

  CURSOR C_PLZAS IS
    SELECT *
      FROM V_POLIZAS_DEUDAS PD
     WHERE PD.NUMERO_ID_POLIZA = P_NMRO_IDNTFCCION
       AND PD.TIPO_ID_POLIZA = P_TPO_IDNTFCCION;

  V_NUMERO_RECIBO   NUMBER;
  V_RECIBO          NUMBER;
  V_MENSAJE         VARCHAR2(1000);
  VALOR             NUMBER;
  R_PLZAS           C_PLZAS%ROWTYPE;
  --MARCA             VARCHAR2(1);
  EXISTE            NUMBER;
  V_SECUENCIA       NUMBER;
  SECUENCIA         NUMBER;
  TEXTO             VARCHAR2(1000);
  V_TEXTO           VARCHAR2(1000);

  BEGIN
    P_ESTADO      := 'OK';
    P_CODIGO_LIQ  := NULL;
    P_MENSAJE     := NULL;

    IF P_POLIZA IS NULL THEN
      SELECT SUM(VALOR_DEUDA)
        INTO VALOR
        FROM V_POLIZAS_DEUDAS
       WHERE NUMERO_ID_POLIZA = P_NMRO_IDNTFCCION
         AND TIPO_ID_POLIZA = P_TPO_IDNTFCCION;
      IF VALOR != P_VALOR_PAGAR THEN
        P_MENSAJE := 'El valor a pagar debe ser igual al valor de la Deuda';
        RETURN;
      END IF;
    END IF;

    PRC_ANULAR_LIQUIDACION(P_TPO_IDNTFCCION,P_NMRO_IDNTFCCION,P_POLIZA,V_MENSAJE);
    IF V_MENSAJE IS NOT NULL THEN
      P_ESTADO      := 'ER';
      P_MENSAJE := V_MENSAJE;
      ROLLBACK;
      RETURN;
    END IF;

    IF P_POLIZA IS NULL THEN
      OPEN C_PLZAS;
      LOOP
        FETCH C_PLZAS INTO R_PLZAS;
        IF C_PLZAS%NOTFOUND THEN
          EXIT;
        END IF;

        V_SECUENCIA := SECUENCIA;

        BEGIN
          PRC_LIQUIDACION_PRIMAS(R_PLZAS.NUMERO_POLIZA,
                                 P_NMRO_IDNTFCCION,
                                 P_TPO_IDNTFCCION,
                                 P_VALOR_PAGAR,
                                 P_NMRO_IDNTFCCION,
                                 V_NUMERO_RECIBO,
                                 V_SECUENCIA,
                                 V_TEXTO,
                                 C_PLZAS%ROWCOUNT);
          SECUENCIA := V_SECUENCIA;
          IF C_PLZAS%ROWCOUNT = 1 THEN
            V_RECIBO  := V_NUMERO_RECIBO;
          END IF;
          TEXTO := TEXTO || V_TEXTO;

        EXCEPTION
          WHEN OTHERS THEN
            P_ESTADO      := 'ER';
            P_MENSAJE := 'ERROR EN PRC_LIQUIDACION_PRIMAS..'|| SQLERRM;
            ROLLBACK;
            RETURN;
        END;

      END LOOP;
      CLOSE C_PLZAS;
    ELSE
      BEGIN
        PRC_LIQUIDACION_PRIMAS(P_POLIZA,
                               P_NMRO_IDNTFCCION,
                               P_TPO_IDNTFCCION,
                               P_VALOR_PAGAR,
                               P_NMRO_IDNTFCCION,
                               V_NUMERO_RECIBO,
                               V_SECUENCIA,
                               V_TEXTO,
                               1);
         V_RECIBO  := V_NUMERO_RECIBO;
         TEXTO := V_TEXTO;
      EXCEPTION
        WHEN OTHERS THEN
          P_ESTADO  := 'ER';
          P_MENSAJE := 'ERROR EN PRC_LIQUIDACION_PRIMAS..'|| SQLERRM;
          ROLLBACK;
          RETURN;
      END;
    END IF;
    P_CODIGO_LIQ := V_NUMERO_RECIBO;
    -- SE VERIFICA SI GRABO LA LIQUIDACION
    SELECT COUNT(8)
      INTO EXISTE
      FROM RCBOS_CJA
     WHERE RCC_NMRO_RCBO = V_NUMERO_RECIBO;
    IF NVL(EXISTE,0) = 0 THEN
      P_ESTADO  := 'ER';
      P_MENSAJE := 'ERROR AL GRABR LA LIQUIDACION..'|| SQLERRM;
      ROLLBACK;
      RETURN;
    END IF;
    IF P_ORIGEN = 'P' THEN
      BEGIN
        PRC_INSERTA_PSE(P_TPO_IDNTFCCION,
                        P_NMRO_IDNTFCCION,
                        V_RECIBO,
                        P_VALOR_PAGAR,
                        TEXTO,
                        P_CODIGO_LIQ);
        BEGIN
          UPDATE OBLIGACIONES_PAGAR
             SET COBRADOR = P_CODIGO_LIQ
           WHERE SOLICITUD = V_RECIBO
             AND NUMERO_IDENTIFICACION = P_NMRO_IDNTFCCION
             AND TIPO_IDENTIFICACION = P_TPO_IDNTFCCION;
        EXCEPTION
          WHEN OTHERS THEN
            P_ESTADO  := 'ER';
            P_MENSAJE := 'ERROR EN ACTUALIZANDO EL CODIGO DE PSE EN OBLIGACIONES_PAGAR.. '||SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          P_ESTADO  := 'ER';
          P_MENSAJE := 'ERROR EN PRC_INSERTA_PSE.. '||SQLERRM;
          ROLLBACK;
          RETURN;
      END;
    END IF;
  IF P_ESTADO = 'OK' THEN
    COMMIT;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      P_ESTADO      := 'ER';
      P_MENSAJE := 'ERROR EN PAGO PRIMAS.. '||SQLERRM;
      ROLLBACK;
      RETURN;

  END PRC_PAGO_PRIMAS;

  /**********************************************************************/
  -- Author  : Sandra Posada C.
  -- Created : 12/02/2012 11:33:30 a.m.
  -- PRC_LIQUIDADOR_PRIMAS
  -- Purpose : Procedimiento que realiza la liquidación de primas de una
  -- póliza con el valor dado por el usuario.
  -- Este proceduimiento toma todos los certificados que están pendientes
  -- de pago y los va cancelando desde el más antiguo al más reciente y
  -- si el certificado tiene valores de hogar. Debe aplicar los abonos o
  -- cancelaciones de la siguiente manera:
  -- 1.  Tomar el 50% del valor de la deuda de hogar, si el valor a abonar o pagar es menor.
  -- 2.  La diferencia del abono o valor a pagar se llevará al concepto de arrendamientos.
  -- 3.  Si el valor de la deuda de arrendamientos es menor al valor a pagar, se abonará la diferencia hasta el tope de la deuda de hogar.
  -- 4.  Si queda una diferencia se llevará al concepto de arrendamientos hasta completar el valor total a pagar.
  -- Modificado por: Gloria Gantvia
  -- Se incluye la insersion de recaudo empresarial Febrero 2015
  -- PROCESO PARA PAGO DE PRIMAS DE ARRENDAMIENTO NUEVO
  /***********************************************************************/
  PROCEDURE PRC_LIQUIDACION_PRIMAS(P_POLIZA          PLZAS.POL_NMRO_PLZA%TYPE,
                                   P_NMRO_IDNTFCCION PLZAS.POL_PRS_NMRO_IDNTFCCION%TYPE,
                                   P_TPO_IDNTFCCION  PLZAS.POL_PRS_TPO_IDNTFCCION%TYPE,
                                   P_VALOR_PAGAR     NUMBER,
                                   P_USUARIO         VARCHAR2,
                                   P_NUMERO_RECIBO   IN OUT NUMBER,
                                   P_SECUENCIA       IN OUT NUMBER,
                                   P_TEXTO           IN OUT VARCHAR2,
                                   P_REGISTRO        NUMBER) IS

   CURSOR C_CRTFCDOS IS
     SELECT CER_NMRO_CRTFCDO,
           PKG_CONSULTA_OPERACION.FUN_DEUDA_POLIZA(CER_NMRO_PLZA,CER_NMRO_CRTFCDO)CER_VLOR_SLDO,
           CER_VLOR_PRMA_TTAL,
           CER_VLOR_PPLRIA,
           CER_VLOR_CTA_PRMA,
           CER_VLOR_CTA_FAX,
           CER_VLOR_PRMA_NTA,
           CER_VLOR_IVA,
           CER_PRCNTJE_IVA,
           CER_FCHA_DSDE_ACTUAL,
           CER_NMRO_PLZA,
           CER_RAM_CDGO,
           CER_CLSE_PLZA
      FROM CRTFCDOS, PLZAS
     WHERE CER_NMRO_PLZA = P_POLIZA
       AND CER_NMRO_PLZA = POL_NMRO_PLZA
       AND PKG_CONSULTA_OPERACION.FUN_DEUDA_POLIZA(CER_NMRO_PLZA,CER_NMRO_CRTFCDO) > 0
       AND CER_VLOR_SLDO > 0
       AND CER_NMRO_IDNTFCCION = P_NMRO_IDNTFCCION
       AND CER_TPO_IDNTFCCION = P_TPO_IDNTFCCION
       AND CER_ESTDO_PRDCCION IN ('20','30')
      ORDER BY CER_FCHA_DSDE_ACTUAL;


  VALOR_SIN_IVA          NUMBER;
  VALOR_IVA_RECIBO       NUMBER;
  VALOR_RECAUDADO_ASIS   NUMBER;
  SALDO_ASISTENCIA       NUMBER;
  VALOR_RECAUDADO_PRM    NUMBER;
  SALDO_ARR              NUMBER;
  VLOR_PGDO_PLZA         NUMBER(18, 2) := 0;
  VLOR_DSCTOS_PRMAS      NUMBER(18, 2) := 0;
  VLOR_DSCNTOS_FNNCCNES  NUMBER(18, 2) := 0;
  P_CRTFCDOS             C_CRTFCDOS%ROWTYPE;
  VLOR_PRIMAS            NUMBER(18, 2);
  VLOR_IVA_PRM           NUMBER(18, 2);
  VLOR_IVA_ASIS          NUMBER(18, 2);
  VLOR_ASISTENCIA        NUMBER;
  VLOR_RCBO              NUMBER(18, 2) := 0;
  vlor_pp                number;
  VLOR_FIN               NUMBER(18, 2);
  SEQ_ASEG               VARCHAR2(100);
  v_sql_string           VARCHAR2(2000);
  v_cursor               INTEGER;
  v_feedback             INTEGER;
  v_retorna_nbr          NUMBER;
  NMRO_RCBO              NUMBER(10);
  V_OFICINA              VARCHAR2(2);
  V_CODIGO_BARRAS1       LIQUIDACIONES_OBLIGACION.CODIGO_BARRAS%TYPE;
  V_CODIGO_RECAUDO       CDGOS_RCDO.CGR_CDGO_RCDO%TYPE;
  V_TEMP                 VARCHAR2(10);
  V_ASIENTO              VARCHAR2(10);
  V_ASIENTO_C            VARCHAR2(10);
  V_CONCEPTO_IVA         VARCHAR2(10);
  V_CONCEPTO_FIN         VARCHAR2(10);
  V_CIUDAD               VARCHAR2(15);
  C_CONCEPTO             CNCPTOS_DTLLE_RCBOS.CDR_CDGO_CNCPTO%TYPE;
  S_CIUDAD               DIVISION_POLITICAS.NOMBRE%TYPE;
  V_IVA                  NUMBER(4, 2);
  V_COMPANIA_TRONADOR    NUMBER;
  V_AGENCIA_TRONADOR     NUMBER;
  V_ENTRO                NUMBER;
  V_CONCEPTO             VARCHAR2(10);
  V_TEXTO                VARCHAR2(1000); --DAP. MANTIS 20787 SE AMPLIA PARA EVITAR FALLA.
  VALOR_PAGO_CERTIFICADO NUMBER;
  VALOR_DETALLE          NUMBER;
  FECHA_LIMITE           DATE;
  V_SECUENCIA            NUMBER;
  V_BOLIVAR_GS1          NUMBER;
  V_IDENTIFICACION1      NUMBER;
  V_ORDEN                NUMBER := 1;
  V_SUCURSAL             SCRSL.SUC_CDGO%TYPE;
  V_DIV_CODIGO           PLZAS.POL_DIV_CDGO%TYPE;
  V_COMPANIA             SCRSL.SUC_CIA_CDGO%TYPE;
  V_CLASE                PLZAS.POL_CDGO_CLSE%TYPE;
  V_RAMO                 PLZAS.POL_RAM_CDGO%TYPE;
  V_VALOR_AJUSTE         NUMBER := 0;



BEGIN
  IF P_REGISTRO = 1 THEN
    BEGIN
      SELECT SEQ_OBLIGACIONES.NEXTVAL
        INTO V_SECUENCIA
        FROM DUAL;
      P_SECUENCIA := V_SECUENCIA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20504, SQLERRM);
    END;
  ELSE
    V_SECUENCIA := P_SECUENCIA;
  END IF;

  BEGIN
    SELECT POL_SUC_CDGO,
           POL_DIV_CDGO,
           POL_SUC_CIA_CDGO,
           POL_CDGO_CLSE,
           POL_RAM_CDGO
      INTO V_SUCURSAL, V_DIV_CODIGO, V_COMPANIA, V_CLASE, V_RAMO
      FROM PLZAS
     WHERE POL_NMRO_PLZA = P_POLIZA;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20500, SQLERRM);
  END;

  -- TOMA LOS PARAMETROS PARA LA ELABORACIÓN DE LA LIQUIDACION.
  BEGIN
    PARAMETROS_LIQUIDACION(V_COMPANIA,
                           V_SUCURSAL,
                           SYSDATE,
                           P_POLIZA,
                           V_CLASE,
                           V_RAMO,
                           V_TEMP,
                           V_ASIENTO,
                           V_ASIENTO_C,
                           V_OFICINA,
                           V_IVA,
                           V_CODIGO_RECAUDO,
                           V_CONCEPTO_IVA,
                           V_CONCEPTO_FIN,
                           V_CIUDAD,
                           V_COMPANIA_TRONADOR,
                           V_AGENCIA_TRONADOR);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501, SQLERRM);
  END;

  VLOR_PGDO_PLZA        := P_VALOR_PAGAR;
  VLOR_DSCTOS_PRMAS     := 0;
  VLOR_DSCNTOS_FNNCCNES := 0;
  V_ENTRO               := 0;

  -- RECORRE CADA UNO DE LOS CERTIFICADOS ADEUDADOS POR LA INMOBILIARIA.
  OPEN C_CRTFCDOS;
  LOOP
    FETCH C_CRTFCDOS INTO P_CRTFCDOS;
    IF C_CRTFCDOS%NOTFOUND THEN
      EXIT;
    ELSE
      VALOR_RECAUDADO_ASIS := 0;
      VALOR_RECAUDADO_PRM  := 0;
      SALDO_ASISTENCIA     := 0;
      SALDO_ARR            := 0;
      VLOR_ASISTENCIA      := 0;
      VLOR_PRIMAS          := 0;
      VLOR_IVA_PRM         := 0;
      VLOR_IVA_ASIS        := 0;

      -- VERIFICA LOS PAGOS QUE SE HAN REALIZADO POR ASISTENCIA
      BEGIN
        SELECT nvl(SUM(E.EST_VLOR_AFNZDO), 0)
          INTO VALOR_RECAUDADO_ASIS
          FROM ESTADO_CTA_RCBOS E
         WHERE E.EST_SLCTUD = P_CRTFCDOS.CER_NMRO_CRTFCDO
           AND E.EST_PLZA = P_POLIZA
           AND E.EST_ESTDO_RCBO = 'I'
           AND E.EST_CDGO_CNCPTO = 'ASIS';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20501,
                                  'Consultar recaudo de asistencia ');
      END;

      -- VERIFICA LOS PAGOS QUE HAYAN REALIZADO POR ARRENDAMIENTOS.
      BEGIN
        SELECT nvl(SUM(E.EST_VLOR_AFNZDO), 0)
          INTO VALOR_RECAUDADO_PRM
          FROM ESTADO_CTA_RCBOS E
         WHERE E.EST_SLCTUD = P_CRTFCDOS.CER_NMRO_CRTFCDO
           AND E.EST_PLZA = P_POLIZA
           AND E.EST_ESTDO_RCBO = 'I'
           AND E.EST_CDGO_CNCPTO = 'PRM';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20501, 'Consultar recaudo de primas ');
      END;

      SALDO_ASISTENCIA := ROUND((P_CRTFCDOS.CER_VLOR_CTA_FAX +
                                P_CRTFCDOS.CER_VLOR_CTA_PRMA) -
                                VALOR_RECAUDADO_ASIS,
                                0);
      SALDO_ARR        := ROUND((P_CRTFCDOS.CER_VLOR_PRMA_NTA -
                                VALOR_RECAUDADO_PRM),
                                0);
      -- VALOR PAGADO MAYOR A CERO.
      IF VLOR_PGDO_PLZA > 0 THEN
        -- EL VALOR DEL SALDO DEL CERTIFICADO ES MENOR O IGUAL AL VALOR QUE VAN A CANCELAR.
        IF P_CRTFCDOS.CER_VLOR_SLDO <= VLOR_PGDO_PLZA THEN
          IF V_TEXTO IS NULL THEN
            V_TEXTO                := P_CRTFCDOS.CER_NMRO_PLZA ||' - '||P_CRTFCDOS.CER_NMRO_CRTFCDO|| ' - ';
          ELSE
            V_TEXTO                := V_TEXTO || ' - ' ||
                                      P_CRTFCDOS.CER_NMRO_CRTFCDO;
          END IF;
          VLOR_RCBO              := VLOR_RCBO + P_CRTFCDOS.CER_VLOR_SLDO;
          VALOR_PAGO_CERTIFICADO := P_CRTFCDOS.CER_VLOR_SLDO;
          VALOR_SIN_IVA          := ROUND(P_CRTFCDOS.CER_VLOR_SLDO / (1 +
                                          (P_CRTFCDOS.CER_PRCNTJE_IVA / 100)),
                                          0);
          VALOR_IVA_RECIBO       := ROUND(P_CRTFCDOS.CER_VLOR_SLDO -
                                          NVL(VALOR_SIN_IVA, 0),
                                          0);
          IF SALDO_ASISTENCIA > 0 THEN
            VLOR_ASISTENCIA := ROUND(SALDO_ASISTENCIA / 2, 0);
          ELSE
            VLOR_ASISTENCIA := 0;
          END IF;
          IF ROUND(VALOR_SIN_IVA - VLOR_ASISTENCIA, 0) > SALDO_ARR THEN
            VLOR_PRIMAS := SALDO_ARR;
            IF SALDO_ASISTENCIA > 0 THEN
              VLOR_ASISTENCIA := SALDO_ASISTENCIA;
            END IF;
          ELSE
            VLOR_PRIMAS := ROUND(VALOR_SIN_IVA - VLOR_ASISTENCIA, 0);
          END IF;
          VLOR_IVA_PRM          := ROUND(NVL(ROUND(((VLOR_PRIMAS * (1 +
                                                   (P_CRTFCDOS.CER_PRCNTJE_IVA / 100))) -
                                                   VLOR_PRIMAS),
                                                   0),
                                             0),
                                         0);
          VLOR_IVA_ASIS         := ROUND(NVL(ROUND(((VLOR_ASISTENCIA * (1 +
                                                   (P_CRTFCDOS.CER_PRCNTJE_IVA / 100))) -
                                                   VLOR_ASISTENCIA),
                                                   0),
                                             0),
                                         0);
          VLOR_PGDO_PLZA        := VLOR_PGDO_PLZA -
                                   P_CRTFCDOS.CER_VLOR_SLDO;
          VLOR_DSCTOS_PRMAS     := VLOR_DSCTOS_PRMAS +
                                   P_CRTFCDOS.CER_VLOR_SLDO;
          VLOR_DSCNTOS_FNNCCNES := VLOR_DSCNTOS_FNNCCNES +
                                   P_CRTFCDOS.CER_VLOR_PPLRIA;
          VLOR_PP               := P_CRTFCDOS.CER_VLOR_PPLRIA;

          VLOR_FIN                 := P_CRTFCDOS.CER_VLOR_PPLRIA;
          P_CRTFCDOS.CER_VLOR_SLDO := 0;
          V_ENTRO                  := V_ENTRO + 1;
          IF SQL%NOTFOUND THEN
            CLOSE C_CRTFCDOS;
            RAISE_APPLICATION_ERROR(-20501,
                                    'No se Pudo Actualizar el Certificado ');
          END IF;
        ELSE
          -- EL VALOR DEL SALDO DEL CERTIFICADO ES MAYOR AL VALOR QUE VAN A CANCELAR.
          IF V_TEXTO IS NULL THEN
            V_TEXTO              := P_CRTFCDOS.CER_NMRO_PLZA ||' - '||P_CRTFCDOS.CER_NMRO_CRTFCDO|| ' - ';
          ELSE
            V_TEXTO              := V_TEXTO || ' - ' ||
                                    P_CRTFCDOS.CER_NMRO_CRTFCDO;
          END IF;
          VLOR_RCBO              := VLOR_RCBO + VLOR_PGDO_PLZA;
          VALOR_PAGO_CERTIFICADO := VLOR_PGDO_PLZA;
          VALOR_SIN_IVA          := ROUND(VLOR_PGDO_PLZA / (1 +
                                          (P_CRTFCDOS.CER_PRCNTJE_IVA / 100)),
                                          0);
          VALOR_IVA_RECIBO       := ROUND(VLOR_PGDO_PLZA -
                                          NVL(VALOR_SIN_IVA, 0),
                                          0);
          IF SALDO_ASISTENCIA > 0 THEN
            IF SALDO_ASISTENCIA >= VALOR_SIN_IVA THEN
              VLOR_ASISTENCIA := ROUND(VALOR_SIN_IVA / 2, 0);
            ELSE
              VLOR_ASISTENCIA := ROUND(SALDO_ASISTENCIA / 2, 0);
            END IF;
          ELSE
            VLOR_ASISTENCIA := 0;
          END IF;
          IF ROUND(VALOR_SIN_IVA - VLOR_ASISTENCIA, 0) > SALDO_ARR THEN
            VLOR_PRIMAS := SALDO_ARR;
            IF SALDO_ASISTENCIA > 0 THEN
              VLOR_ASISTENCIA := SALDO_ASISTENCIA;
            END IF;
          ELSE
            VLOR_PRIMAS := ROUND(VALOR_SIN_IVA - VLOR_ASISTENCIA, 0);
          END IF;
          VLOR_IVA_PRM  := ROUND(NVL(ROUND(((VLOR_PRIMAS * (1 +
                                           (P_CRTFCDOS.CER_PRCNTJE_IVA / 100))) -
                                           VLOR_PRIMAS),
                                           0),
                                     0),
                                 0);
          VLOR_IVA_ASIS := ROUND(NVL(ROUND(((VLOR_ASISTENCIA * (1 +
                                           (P_CRTFCDOS.CER_PRCNTJE_IVA / 100))) -
                                           VLOR_ASISTENCIA),
                                           0),
                                     0),
                                 0);

          VLOR_DSCTOS_PRMAS        := VLOR_DSCTOS_PRMAS + VLOR_PGDO_PLZA;
          P_CRTFCDOS.CER_VLOR_SLDO := P_CRTFCDOS.CER_VLOR_SLDO -
                                      VLOR_PGDO_PLZA;
          VLOR_DSCNTOS_FNNCCNES    := 0;
          VLOR_FIN                 := 0;
          vlor_pp                  := 0;
          VLOR_PGDO_PLZA           := 0;

          V_ENTRO := V_ENTRO + 1;
          IF SQL%NOTFOUND THEN
            CLOSE C_CRTFCDOS;
            RAISE_APPLICATION_ERROR(-20501,
                                    'No se Pudo Actualizar el Certificado ');
          END IF;
        END IF;

        IF V_VALOR_AJUSTE != 0 THEN
          VLOR_RCBO := P_VALOR_PAGAR + NVL(V_VALOR_AJUSTE, 0);
        END IF;

        IF NVL(VLOR_PRIMAS, 0) + NVL(VLOR_IVA_PRM, 0) +
           NVL(VLOR_IVA_ASIS, 0) + NVL(VLOR_ASISTENCIA, 0) !=
           VALOR_PAGO_CERTIFICADO THEN

          IF NVL(VLOR_PRIMAS, 0) + NVL(VLOR_IVA_PRM, 0) +
             NVL(VLOR_IVA_ASIS, 0) + NVL(VLOR_ASISTENCIA, 0) =
             VALOR_PAGO_CERTIFICADO + 1 THEN
            VLOR_PRIMAS := VLOR_PRIMAS - 1;
          ELSE
            VLOR_PRIMAS := VLOR_PRIMAS + 1;
          END IF;

        END IF;

        IF NVL(VLOR_PRIMAS, 0) + NVL(VLOR_IVA_PRM, 0) +
           NVL(VLOR_IVA_ASIS, 0) + NVL(VLOR_ASISTENCIA, 0) !=
           VALOR_PAGO_CERTIFICADO THEN

          VLOR_PRIMAS := ROUND(VLOR_PRIMAS +
                               (VALOR_PAGO_CERTIFICADO -
                               (NVL(VLOR_PRIMAS, 0) + NVL(VLOR_IVA_PRM, 0) +
                               NVL(VLOR_IVA_ASIS, 0) +
                               NVL(VLOR_ASISTENCIA, 0))),
                               0);

        END IF;

        IF V_ENTRO = 1 THEN

          -- TOMAR LA SECUENCIA QUE SE DEBE UTILIZAR PARA LA NUMERACION DE LA
          -- LIQUIDACION DE ACUERDO A LA SUCURSAL DE LA POLIZA.
          BEGIN
            SELECT RTRIM(SUBSTR(RV_MEANING, 1, 50), ' ')
              INTO SEQ_ASEG
              FROM CG_REF_CODES
             WHERE RV_HIGH_VALUE IS NULL
               AND SUBSTR(RV_LOW_VALUE, 1, 4) = V_SUCURSAL
               AND SUBSTR(RV_LOW_VALUE, 5, 2) = '40'
               AND RV_DOMAIN = 'SECUENCIA';
          EXCEPTION
            WHEN OTHERS THEN
              CLOSE C_CRTFCDOS;
              RAISE_APPLICATION_ERROR(-20534,
                                      'Error obtendiendo la secuencia de las notas ');
          END;

          -- TOMAR EL NÚMERO QUE DEBE TENER LA LIQUIDACION.
          BEGIN
            v_sql_string := 'SELECT ' || UPPER(SEQ_ASEG) ||
                            '.NEXTVAL FROM DUAL';
            v_cursor     := dbms_sql.open_cursor;
            dbms_sql.parse(v_cursor, v_sql_string, DBMS_SQL.V7);
            dbms_sql.define_column(v_cursor, 1, v_retorna_nbr);
            v_feedback := dbms_sql.execute(v_cursor);
            v_feedback := dbms_sql.fetch_rows(v_cursor);
            dbms_sql.column_value(v_cursor, 1, v_retorna_nbr);
            dbms_sql.close_cursor(v_cursor);
            NMRO_RCBO := v_retorna_nbr;
          EXCEPTION
            WHEN OTHERS THEN
              CLOSE C_CRTFCDOS;
              RAISE_APPLICATION_ERROR(-20535,
                                      'Error obteniendo el numero del recibo');
          END;
          IF NMRO_RCBO IS NULL THEN
            CLOSE C_CRTFCDOS;
            RAISE_APPLICATION_ERROR(-20501,
                                    'No se encontro el numero del recibo de la nota de cartera. ' ||
                                    TO_CHAR(P_POLIZA));
          ELSE

            BEGIN
              INSERT INTO RLCION_RCBOS_CJA
                (rlr_cdgo_cia,
                 rlr_nmro_rcbo_invesa,
                 rlr_nmro_rcbo,
                 rlr_fcha_rcbos,
                 rlr_vlor_rcbo,
                 rlr_vlor_rcbo_invesa,
                 rlr_prctje_hnrrios,
                 rlr_nmro_fctra,
                 Rlr_usrio,
                 rlr_fcha_actlzcion,
                 rlr_dda_hon,
                 rlr_nmro_idntfccion,
                 rlr_tpo_idntfccion)
              VALUES
                (V_COMPANIA,
                 0,
                 NMRO_RCBO,
                 SYSDATE,
                 VALOR_PAGO_CERTIFICADO, --P_VALOR_PAGAR + NVL(V_VALOR_AJUSTE, 0),
                 0,
                 0,
                 0,
                 P_USUARIO,
                 SYSDATE,
                 0,
                 P_NMRO_IDNTFCCION,
                 P_TPO_IDNTFCCION);

            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20501,
                                        'No Se Pudo Insertar rlcion_rcbos_cja ' ||
                                        sqlerrm || ' ' || TO_CHAR(P_POLIZA));
            END;


            FECHA_LIMITE := PKG_CONSULTA_OPERACION.FUN_FECHA_LIMITE_EXTRACTO(P_POLIZA);

            --
            -- REALIZA LA LIQUIDACION DEL CERTIFICADO
            BEGIN
              INSERT INTO RCBOS_CJA
              VALUES
                (NMRO_RCBO,
                 V_COMPANIA,
                 'R',
                 V_OFICINA,
                 P_NMRO_IDNTFCCION,
                 P_TPO_IDNTFCCION,
                 'T',
                 SYSDATE,
                 P_VALOR_PAGAR,
                 P_USUARIO,
                 SYSDATE,
                 'PAGO DE CERTIFICADOS ' || V_TEXTO,
                 V_SUCURSAL,
                 -2,
                 V_COMPANIA,
                 NULL,
                 V_DIV_CODIGO,
                 FECHA_LIMITE,
                 NULL,
                 NULL);
            EXCEPTION
              WHEN OTHERS THEN
                CLOSE C_CRTFCDOS;
                RAISE_APPLICATION_ERROR(-20501,
                                        'No Se Pudo Insertar el Recibo de Caja ' ||
                                        sqlerrm || ' ' || TO_CHAR(P_POLIZA));
            END;
            IF SQL%NOTFOUND THEN
              CLOSE C_CRTFCDOS;
              RAISE_APPLICATION_ERROR(-20501,
                                      'No Se Pudo Insertar el Recibo de Caja ');
            END IF;
          END IF;

          -- SE INSERTA EN OBLIGACIONES
          IF P_REGISTRO = 1 THEN
            BEGIN
              SELECT D.NOMBRE
                INTO S_CIUDAD
                FROM DIVISION_POLITICAS D
               WHERE D.CODIGO_CODAZZI = V_DIV_CODIGO;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20503, SQLERRM);
            END;

            BEGIN
              INSERT INTO OBLIGACIONES_PAGAR
               (SECUENCIA,
                SOLICITUD,
                VALOR,
                NUMERO_IDENTIFICACION,
                TIPO_IDENTIFICACION,
                FECHA_LIMITE_PAGO,
                NOMBRE_OBLIGADO,
                DIRECCION,
                ARRENDADOR,
                CIUDAD,
                FECHA_GENERACION,
                ESTADO_SOLICITUD,
                ESTADO_PAGO,
                PAGADO_POR,
                TEXTO_CESION,
                MARCA_PROCESO,
                POLIZA,
                COBRADOR,
                ORIGEN_RECAUDO)
              VALUES
                (V_SECUENCIA,
                 NMRO_RCBO,  -- por ahora
                 P_VALOR_PAGAR,
                 P_NMRO_IDNTFCCION,
                 P_TPO_IDNTFCCION,
                 FECHA_LIMITE,
                 PK_TERCEROS.F_NOMBRES(P_NMRO_IDNTFCCION,P_TPO_IDNTFCCION),
                 NVL(PK_TERCEROS.F_DIRECCION(P_NMRO_IDNTFCCION,P_TPO_IDNTFCCION),'NULA'),
                 PK_TERCEROS.F_NOMBRES(P_NMRO_IDNTFCCION,P_TPO_IDNTFCCION),
                 S_CIUDAD,
                 SYSDATE,
                 'V',
                 'PE',
                 PK_TERCEROS.F_NOMBRES(P_NMRO_IDNTFCCION,P_TPO_IDNTFCCION),
                 NULL,
                 'N',
                 P_POLIZA,
                 RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
                 SUBSTR(V_CODIGO_RECAUDO, 1, 1));
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20505, SQLERRM);
            END;
          END IF;

          -- INSERTA EN CODIGO DE BARRAS

          V_BOLIVAR_GS1    := 7709998416031;

          BEGIN
            INSERT INTO CODIGO_BARRAS
               (SECUENCIA, NUMERO_LIQUIDACION, IDENTIFICADOR, VALOR, ORDEN)
            VALUES
              (V_SECUENCIA, NMRO_RCBO, 415, V_BOLIVAR_GS1, 1);
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20514, SQLERRM);
          END;

          BEGIN
            INSERT INTO CODIGO_BARRAS
               (SECUENCIA, NUMERO_LIQUIDACION, IDENTIFICADOR, VALOR, ORDEN)
            VALUES
              (V_SECUENCIA,NMRO_RCBO, 8020,LPAD(NMRO_RCBO,12, '0'),2);

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20514, SQLERRM);
          END;

          BEGIN
            INSERT INTO CODIGO_BARRAS
              (SECUENCIA, NUMERO_LIQUIDACION, IDENTIFICADOR, VALOR, ORDEN)
            VALUES
              (V_SECUENCIA,NMRO_RCBO,3900,LPAD(VALOR_PAGO_CERTIFICADO, 10, '0'),3);
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20514, SQLERRM);
          END;

          BEGIN
            INSERT INTO CODIGO_BARRAS
              (SECUENCIA, NUMERO_LIQUIDACION, IDENTIFICADOR, VALOR, ORDEN)
            VALUES
              (V_SECUENCIA,NMRO_RCBO,96,TO_CHAR(FECHA_LIMITE, 'YYYYMMDD'),4);
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20514, SQLERRM);
          END;

          BEGIN
            SELECT C.CIA_NMRO_IDNTFCCION
              INTO V_IDENTIFICACION1
              FROM CMPNIAS C
             WHERE C.CIA_CDGO = V_COMPANIA;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20501, SQLERRM);
          END;

        END IF;

        IF V_ENTRO = 1 THEN
          VALOR_DETALLE := VALOR_PAGO_CERTIFICADO + NVL(V_VALOR_AJUSTE, 0);
        ELSE
          VALOR_DETALLE := VALOR_PAGO_CERTIFICADO;
        END IF;

        BEGIN
          INSERT INTO DTLLES_RCBOS_CJA
          VALUES
            (RTRIM(V_RAMO || V_CLASE ||
                   RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||
                   RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_CRTFCDO), 10, ' '),
                   ' '),
             NMRO_RCBO,
             V_COMPANIA,
             'R',
             SUBSTR(V_CODIGO_RECAUDO, 1, 1),
             '03',
             RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
             VALOR_DETALLE,
             P_USUARIO,
             SYSDATE);

          --INSERTA EN LIQUIDACIONES_OBLIGACION
            BEGIN
              INSERT INTO LIQUIDACIONES_OBLIGACION
                (SECUENCIA,
                 NUMERO_LIQUIDACION,
                 VALOR_LIQUIDACION,
                 CODIGO_BARRAS,
                 COMPANIA,
                 IDENTIFICACION)
               VALUES
                (V_SECUENCIA,
                 NMRO_RCBO,
                 VALOR_DETALLE,
                 V_CODIGO_BARRAS1,
                 V_COMPANIA,
                 V_IDENTIFICACION1);
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                 BEGIN
                   UPDATE LIQUIDACIONES_OBLIGACION
                      SET VALOR_LIQUIDACION = VALOR_LIQUIDACION + VALOR_DETALLE
                    WHERE SECUENCIA = V_SECUENCIA
                      AND NUMERO_LIQUIDACION = NMRO_RCBO;
                 EXCEPTION
                   WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20514, V_SECUENCIA||' '||P_SECUENCIA||' '||SQLERRM);
                 END;
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20514, V_SECUENCIA||' '||P_SECUENCIA||' '||SQLERRM);
            END;
        EXCEPTION
          WHEN OTHERS THEN
            CLOSE C_CRTFCDOS;
            RAISE_APPLICATION_ERROR(-20501,'No Se Pudo Insertar el detalle del Recibo de Caja ' ||
                                    sqlerrm);
        END;

        IF SQL%NOTFOUND THEN
          CLOSE C_CRTFCDOS;
          RAISE_APPLICATION_ERROR(-20501,'No Se Pudo Insertar el detalle del Recibo de Caja ' ||
                                  sqlerrm);
        ELSE
          BEGIN
            INSERT INTO CNCPTOS_DTLLE_RCBOS
            VALUES
              (RTRIM(V_RAMO || V_CLASE ||
                     RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||
                     RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_CRTFCDO), 10, ' '),
                     ' '),
               NMRO_RCBO,
               V_COMPANIA,
               'R',
               SUBSTR(V_CODIGO_RECAUDO, 1, 1),
               RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
               RTRIM(SUBSTR(V_CODIGO_RECAUDO, 6, 4)),
               'D',
               VLOR_PRIMAS,
               P_USUARIO,
               SYSDATE,
               null,
               null);

               -- INSERTA EN CONCEPTOS_LIQUIDACION
               C_CONCEPTO := RTRIM(SUBSTR(V_CODIGO_RECAUDO, 6, 4));
               BEGIN
                 INSERT INTO CONCEPTOS_LIQUIDACION
                   (SECUENCIA,
                    NUMERO_LIQUIDACION,
                    CODIGO_CONCEPTO,
                    DESCRIPCION_CONCEPTO,
                    VALOR_CONCEPTO,
                    FECHA_DESDE_CONCEPTO,
                    FECHA_HASTA_CONCEPTO,
                    ORDEN)
                  VALUES
                   (V_SECUENCIA,
                    NMRO_RCBO,
                    C_CONCEPTO,
                    PKG_CONSULTA_OPERACION.FUN_NOMBRE_CONCEPTO(C_CONCEPTO),
                    VLOR_PRIMAS,
                    NULL,
                    NULL,
                    V_ORDEN);
                 V_ORDEN := V_ORDEN + 1;
               EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                   BEGIN
                     UPDATE CONCEPTOS_LIQUIDACION C
                        SET C.VALOR_CONCEPTO = C.VALOR_CONCEPTO + VLOR_PRIMAS
                      WHERE C.SECUENCIA = V_SECUENCIA
                        AND C.NUMERO_LIQUIDACION = NMRO_RCBO
                        AND C.CODIGO_CONCEPTO = C_CONCEPTO;
                   EXCEPTION
                     WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR(-20515, SQLERRM);
                   END;
               WHEN OTHERS THEN
                 RAISE_APPLICATION_ERROR(-20516, SQLERRM);
               END;

          EXCEPTION
            WHEN OTHERS THEN
              CLOSE C_CRTFCDOS;
              RAISE_APPLICATION_ERROR(-20501,'No Se Pudo Insertar el concepto de primas del Recibo de Caja ');
          END;
          IF SQL%NOTFOUND THEN
            CLOSE C_CRTFCDOS;
            RAISE_APPLICATION_ERROR(-20501,'No Se Pudo Insertar el Concepto del  detalle del Recibo de Caja ');
          END IF;

          BEGIN
            INSERT INTO CNCPTOS_DTLLE_RCBOS
            VALUES
              (RTRIM(V_RAMO || V_CLASE ||
                     RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||
                     RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_CRTFCDO), 10, ' '),
                     ' '),
               NMRO_RCBO,
               V_COMPANIA,
               'R',
               SUBSTR(V_CODIGO_RECAUDO, 1, 1),
               RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
               RTRIM(V_CONCEPTO_IVA),
               'D',
               VLOR_IVA_PRM,
               P_USUARIO,
               SYSDATE,
               null,
               null);

               -- INSERTA EN CONCEPTOS_LIQUIDACION
               C_CONCEPTO := RTRIM(V_CONCEPTO_IVA);
               BEGIN
                 INSERT INTO CONCEPTOS_LIQUIDACION
                   (SECUENCIA,
                    NUMERO_LIQUIDACION,
                    CODIGO_CONCEPTO,
                    DESCRIPCION_CONCEPTO,
                    VALOR_CONCEPTO,
                    FECHA_DESDE_CONCEPTO,
                    FECHA_HASTA_CONCEPTO,
                    ORDEN)
                  VALUES
                   (V_SECUENCIA,
                    NMRO_RCBO,
                    C_CONCEPTO,
                    PKG_CONSULTA_OPERACION.FUN_NOMBRE_CONCEPTO(C_CONCEPTO),
                    VLOR_IVA_PRM,
                    NULL,
                    NULL,
                    V_ORDEN);
                 V_ORDEN := V_ORDEN + 1;
               EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                   BEGIN
                     UPDATE CONCEPTOS_LIQUIDACION C
                        SET C.VALOR_CONCEPTO = C.VALOR_CONCEPTO + VLOR_IVA_PRM
                      WHERE C.SECUENCIA = V_SECUENCIA
                        AND C.NUMERO_LIQUIDACION = NMRO_RCBO
                        AND C.CODIGO_CONCEPTO = C_CONCEPTO;
                   EXCEPTION
                     WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR(-20515, SQLERRM);
                   END;
               WHEN OTHERS THEN
                 RAISE_APPLICATION_ERROR(-20516, SQLERRM);
               END;

          EXCEPTION
            WHEN OTHERS THEN
              CLOSE C_CRTFCDOS;
              RAISE_APPLICATION_ERROR(-20501,'No Se Pudo Insertar el concepto de iva del Recibo de Caja ' ||
                                      sqlerrm);
          END;
          IF SQL%NOTFOUND THEN
            CLOSE C_CRTFCDOS;
            RAISE_APPLICATION_ERROR(-20501,'No Se Pudo Insertar el Concepto del  detalle del Recibo de Caja ');
          END IF;

          IF VLOR_ASISTENCIA > 0 THEN
            BEGIN
              INSERT INTO CNCPTOS_DTLLE_RCBOS
              VALUES
                (RTRIM(V_RAMO || V_CLASE ||
                       RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||
                       RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_CRTFCDO), 10, ' '),
                       ' '),
                 NMRO_RCBO,
                 V_COMPANIA,
                 'R',
                 SUBSTR(V_CODIGO_RECAUDO, 1, 1),
                 RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
                 'ASIS',
                 'D',
                 VLOR_ASISTENCIA,
                 P_USUARIO,
                 SYSDATE,
                 null,
                 null);

               -- INSERTA EN CONCEPTOS_LIQUIDACION
               C_CONCEPTO := 'ASIS';
               BEGIN
                 INSERT INTO CONCEPTOS_LIQUIDACION
                   (SECUENCIA,
                    NUMERO_LIQUIDACION,
                    CODIGO_CONCEPTO,
                    DESCRIPCION_CONCEPTO,
                    VALOR_CONCEPTO,
                    FECHA_DESDE_CONCEPTO,
                    FECHA_HASTA_CONCEPTO,
                    ORDEN)
                  VALUES
                   (V_SECUENCIA,
                    NMRO_RCBO,
                    C_CONCEPTO,
                    PKG_CONSULTA_OPERACION.FUN_NOMBRE_CONCEPTO(C_CONCEPTO),
                    VLOR_ASISTENCIA,
                    NULL,
                    NULL,
                    V_ORDEN);
                 V_ORDEN := V_ORDEN + 1;
               EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                   BEGIN
                     UPDATE CONCEPTOS_LIQUIDACION C
                        SET C.VALOR_CONCEPTO = C.VALOR_CONCEPTO + VLOR_ASISTENCIA
                      WHERE C.SECUENCIA = V_SECUENCIA
                        AND C.NUMERO_LIQUIDACION = NMRO_RCBO
                        AND C.CODIGO_CONCEPTO = C_CONCEPTO;
                   EXCEPTION
                     WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR(-20515, SQLERRM);
                   END;
               WHEN OTHERS THEN
                 RAISE_APPLICATION_ERROR(-20516, SQLERRM);
               END;

            EXCEPTION
              WHEN OTHERS THEN
                CLOSE C_CRTFCDOS;
                RAISE_APPLICATION_ERROR(-20501,'No Se Pudo Insertar el concepto de asistencia del Recibo de Caja ' || ' ' ||
                                        V_CONCEPTO_FIN || ' ' || sqlerrm);
            END;

            BEGIN
              INSERT INTO CNCPTOS_DTLLE_RCBOS
              VALUES
                (RTRIM(V_RAMO || V_CLASE ||
                       RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||
                       RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_CRTFCDO), 10, ' '),
                       ' '),
                 NMRO_RCBO,
                 V_COMPANIA,
                 'R',
                 SUBSTR(V_CODIGO_RECAUDO, 1, 1),
                 RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
                 'IASI',
                 'D',
                 VLOR_IVA_ASIS,
                 P_USUARIO,
                 SYSDATE,
                 null,
                 null);

               -- INSERTA EN CONCEPTOS_LIQUIDACION
               C_CONCEPTO := 'IASI';
               BEGIN
                 INSERT INTO CONCEPTOS_LIQUIDACION
                   (SECUENCIA,
                    NUMERO_LIQUIDACION,
                    CODIGO_CONCEPTO,
                    DESCRIPCION_CONCEPTO,
                    VALOR_CONCEPTO,
                    FECHA_DESDE_CONCEPTO,
                    FECHA_HASTA_CONCEPTO,
                    ORDEN)
                  VALUES
                   (V_SECUENCIA,
                    NMRO_RCBO,
                    C_CONCEPTO,
                    PKG_CONSULTA_OPERACION.FUN_NOMBRE_CONCEPTO(C_CONCEPTO),
                    VLOR_IVA_ASIS,
                    NULL,
                    NULL,
                    V_ORDEN);
                 V_ORDEN := V_ORDEN + 1;
               EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                   BEGIN
                     UPDATE CONCEPTOS_LIQUIDACION C
                        SET C.VALOR_CONCEPTO = C.VALOR_CONCEPTO + VLOR_IVA_ASIS
                      WHERE C.SECUENCIA = V_SECUENCIA
                        AND C.NUMERO_LIQUIDACION = NMRO_RCBO
                        AND C.CODIGO_CONCEPTO = C_CONCEPTO;
                   EXCEPTION
                     WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR(-20515, SQLERRM);
                   END;
               WHEN OTHERS THEN
                 RAISE_APPLICATION_ERROR(-20516, SQLERRM);
               END;

            EXCEPTION
              WHEN OTHERS THEN
                CLOSE C_CRTFCDOS;
                RAISE_APPLICATION_ERROR(-20501,
                                        'No Se Pudo Insertar el concepto de iva del Recibo de Caja ' ||
                                        sqlerrm);
            END;
            IF SQL%NOTFOUND THEN
              CLOSE C_CRTFCDOS;
              RAISE_APPLICATION_ERROR(-20501,
                                      'No Se Pudo Insertar el Concepto del  detalle del Recibo de Caja ');
            END IF;
          END IF;

          IF VLOR_PP > 0 THEN
            BEGIN
              INSERT INTO CNCPTOS_DTLLE_RCBOS
              VALUES
                (RTRIM(V_RAMO || V_CLASE ||
                       RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||
                       RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_CRTFCDO), 10, ' '),
                       ' '),
                 NMRO_RCBO,
                 V_COMPANIA,
                 'R',
                 SUBSTR(V_CODIGO_RECAUDO, 1, 1),
                 RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
                 'CPL',
                 'D',
                 VLOR_PP,
                 P_USUARIO,
                 SYSDATE,
                 null,
                 null);

               -- INSERTA EN CONCEPTOS_LIQUIDACION
               C_CONCEPTO := 'CPL';
               BEGIN
                 INSERT INTO CONCEPTOS_LIQUIDACION
                   (SECUENCIA,
                    NUMERO_LIQUIDACION,
                    CODIGO_CONCEPTO,
                    DESCRIPCION_CONCEPTO,
                    VALOR_CONCEPTO,
                    FECHA_DESDE_CONCEPTO,
                    FECHA_HASTA_CONCEPTO,
                    ORDEN)
                  VALUES
                   (V_SECUENCIA,
                    NMRO_RCBO,
                    C_CONCEPTO,
                    PKG_CONSULTA_OPERACION.FUN_NOMBRE_CONCEPTO(C_CONCEPTO),
                    VLOR_PP,
                    NULL,
                    NULL,
                    V_ORDEN);
                 V_ORDEN := V_ORDEN + 1;
               EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                   BEGIN
                     UPDATE CONCEPTOS_LIQUIDACION C
                        SET C.VALOR_CONCEPTO = C.VALOR_CONCEPTO + VLOR_PP
                      WHERE C.SECUENCIA = V_SECUENCIA
                        AND C.NUMERO_LIQUIDACION = NMRO_RCBO
                        AND C.CODIGO_CONCEPTO = C_CONCEPTO;
                   EXCEPTION
                     WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR(-20515, SQLERRM);
                   END;
               WHEN OTHERS THEN
                 RAISE_APPLICATION_ERROR(-20516, SQLERRM);
               END;

            EXCEPTION
              WHEN OTHERS THEN
                CLOSE C_CRTFCDOS;
                RAISE_APPLICATION_ERROR(-20501,
                                        'No Se Pudo Insertar el concepto de Finan. del Recibo de Caja ' || ' ' ||
                                        V_CONCEPTO_FIN || ' ' || sqlerrm);
            END;
          END IF;

          IF VLOR_PP > 0 THEN
            VLOR_FIN := VLOR_FIN - VLOR_PP;
          END IF;

          IF VLOR_FIN > 0 THEN
            BEGIN
              INSERT INTO CNCPTOS_DTLLE_RCBOS
              VALUES
                (RTRIM(V_RAMO || V_CLASE ||
                       RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||
                       RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_CRTFCDO), 10, ' '),
                       ' '),
                 NMRO_RCBO,
                 V_COMPANIA,
                 'R',
                 SUBSTR(V_CODIGO_RECAUDO, 1, 1),
                 RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
                 'CFI',
                 'D',
                 VLOR_FIN,
                 P_USUARIO,
                 SYSDATE,
                 null,
                 null);

               -- INSERTA EN CONCEPTOS_LIQUIDACION
               C_CONCEPTO := 'CFI';
               BEGIN
                 INSERT INTO CONCEPTOS_LIQUIDACION
                   (SECUENCIA,
                    NUMERO_LIQUIDACION,
                    CODIGO_CONCEPTO,
                    DESCRIPCION_CONCEPTO,
                    VALOR_CONCEPTO,
                    FECHA_DESDE_CONCEPTO,
                    FECHA_HASTA_CONCEPTO,
                    ORDEN)
                  VALUES
                   (V_SECUENCIA,
                    NMRO_RCBO,
                    C_CONCEPTO,
                    PKG_CONSULTA_OPERACION.FUN_NOMBRE_CONCEPTO(C_CONCEPTO),
                    VLOR_FIN,
                    NULL,
                    NULL,
                    V_ORDEN);
                 V_ORDEN := V_ORDEN + 1;
               EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                   BEGIN
                     UPDATE CONCEPTOS_LIQUIDACION C
                        SET C.VALOR_CONCEPTO = C.VALOR_CONCEPTO + VLOR_FIN
                      WHERE C.SECUENCIA = V_SECUENCIA
                        AND C.NUMERO_LIQUIDACION = NMRO_RCBO
                        AND C.CODIGO_CONCEPTO = C_CONCEPTO;
                   EXCEPTION
                     WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR(-20515, SQLERRM);
                   END;
               WHEN OTHERS THEN
                 RAISE_APPLICATION_ERROR(-20516, SQLERRM);
               END;

            EXCEPTION
              WHEN OTHERS THEN
                CLOSE C_CRTFCDOS;
                RAISE_APPLICATION_ERROR(-20501,
                                        'No Se Pudo Insertar el concepto de Finan. del Recibo de Caja ' || ' ' ||
                                        V_CONCEPTO_FIN || ' ' || sqlerrm);
            END;
          END IF;

          IF V_ENTRO = 1 THEN
            IF V_VALOR_AJUSTE != 0 THEN
              IF V_VALOR_AJUSTE > 0 THEN
                V_CONCEPTO := 'MVP';
              ELSE
                V_CONCEPTO := 'YVP';
              END IF;

              BEGIN
                INSERT INTO CNCPTOS_DTLLE_RCBOS
                VALUES
                  (RTRIM(V_RAMO || V_CLASE ||
                         RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||
                         RPAD(TO_CHAR(P_CRTFCDOS.CER_NMRO_CRTFCDO),
                              10,
                              ' '),
                         ' '),
                   NMRO_RCBO,
                   V_COMPANIA,
                   'R',
                   SUBSTR(V_CODIGO_RECAUDO, 1, 1),
                   RTRIM(SUBSTR(V_CODIGO_RECAUDO, 2, 4)),
                   V_CONCEPTO,
                   'D',
                   V_VALOR_AJUSTE,
                   P_USUARIO,
                   SYSDATE,
                   null,
                   null);

               -- INSERTA EN CONCEPTOS_LIQUIDACION
               C_CONCEPTO := V_CONCEPTO;
               BEGIN
                 INSERT INTO CONCEPTOS_LIQUIDACION
                   (SECUENCIA,
                    NUMERO_LIQUIDACION,
                    CODIGO_CONCEPTO,
                    DESCRIPCION_CONCEPTO,
                    VALOR_CONCEPTO,
                    FECHA_DESDE_CONCEPTO,
                    FECHA_HASTA_CONCEPTO,
                    ORDEN)
                  VALUES
                   (V_SECUENCIA,
                    NMRO_RCBO,
                    C_CONCEPTO,
                    PKG_CONSULTA_OPERACION.FUN_NOMBRE_CONCEPTO(C_CONCEPTO),
                    V_VALOR_AJUSTE,
                    NULL,
                    NULL,
                    V_ORDEN);
                 V_ORDEN := V_ORDEN + 1;
               EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                   BEGIN
                     UPDATE CONCEPTOS_LIQUIDACION C
                        SET C.VALOR_CONCEPTO = C.VALOR_CONCEPTO + V_VALOR_AJUSTE
                      WHERE C.SECUENCIA = V_SECUENCIA
                        AND C.NUMERO_LIQUIDACION = NMRO_RCBO
                        AND C.CODIGO_CONCEPTO = C_CONCEPTO;
                   EXCEPTION
                     WHEN OTHERS THEN
                       RAISE_APPLICATION_ERROR(-20515, SQLERRM);
                   END;
               WHEN OTHERS THEN
                 RAISE_APPLICATION_ERROR(-20516, SQLERRM);
               END;

              EXCEPTION
                WHEN OTHERS THEN
                  CLOSE C_CRTFCDOS;
                  RAISE_APPLICATION_ERROR(-20501,
                                          'No Se Pudo Insertar el concepto de Finan. del Recibo de Caja ' || ' ' ||
                                          V_CONCEPTO_FIN || ' ' || sqlerrm);
              END;

            END IF;
          END IF;

          IF V_ENTRO = 1 THEN
            BEGIN
              INSERT INTO FRMAS_PGO_RCBOS
              VALUES
                (NMRO_RCBO,
                 V_COMPANIA,
                 'R',
                 'S',
                 '0',
                 '0',
                 0,
                 null,
                 null,
                 VLOR_RCBO,
                 null,
                 P_USUARIO,
                 SYSDATE,
                 NULL,
                 NULL);
              IF SQL%NOTFOUND THEN
                CLOSE C_CRTFCDOS;
                RAISE_APPLICATION_ERROR(-20501,
                                        'No Se Pudo Insertar la forma de pago ' ||
                                        sqlerrm);
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                CLOSE C_CRTFCDOS;
                RAISE_APPLICATION_ERROR(-20501,
                                        'No Se Pudo Insertar la forma de pago de la nota de Cartera. ' ||
                                        sqlerrm);
            END;
          END IF;
        END IF;

        P_NUMERO_RECIBO := NMRO_RCBO;
      ELSE
        EXIT;
      END IF;

    END IF;
  END LOOP;
  CLOSE C_CRTFCDOS;
  P_TEXTO := V_TEXTO;

  -- INSERTA EN LA INTERFAZ DE TESORERIA DE TRONADOR.

  BEGIN
    PRC_TESORERIA(P_NUMERO_RECIBO,
                  V_COMPANIA,
                  'PAGO DE CERTIFICADOS DE COBRO DE PRIMAS ' || V_TEXTO,
                  P_VALOR_PAGAR, --VLOR_RCBO,
                  P_POLIZA,
                  V_SUCURSAL,
                  P_NMRO_IDNTFCCION,
                  P_TPO_IDNTFCCION,
                  1,
                  SYSDATE);

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20501, SQLERRM);
  END;


  END PRC_LIQUIDACION_PRIMAS;


  --
  --
  --
  PROCEDURE PRC_INSERTA_PSE(P_TIPO_ID     IN VARCHAR2,
                            P_NMRO_ID     IN NUMBER,
                            P_LIQUIDACION IN NUMBER,
                            P_VALOR_PAGO  IN NUMBER,
                            P_TEXTO       IN VARCHAR2,
                            P_CODIGO      IN OUT NUMBER) IS


  EXISTE         NUMBER;
  V_CONSECUTIVO  NUMBER;
  V_DESC_PROD    VARCHAR2(50) := 'RECAUDO EMPRESARIAL PAGO DE PRIMAS';
  VALOR_IVA      NUMBER;
  NOMBRE_CIA     VARCHAR2(200);
  NIT_CIA        VARCHAR2(60);
  SERVICIO_ACH   VARCHAR2(10);

  BEGIN
    SELECT COUNT(8)
      INTO EXISTE
      FROM OBLIGACIONES_PAGAR A
     WHERE A.NUMERO_IDENTIFICACION = P_NMRO_ID
       AND A.TIPO_IDENTIFICACION = P_TIPO_ID
       AND A.SOLICITUD = P_LIQUIDACION
       AND A.ESTADO_PAGO = 'PE'
       AND TRUNC(A.FECHA_LIMITE_PAGO) >= TRUNC(SYSDATE)
       AND A.ESTADO_SOLICITUD = 'V'
       AND ORIGEN_RECAUDO = 'P';

    IF NVL(EXISTE,0) > 0 THEN
      BEGIN
        SELECT CIA_NMRO_IDNTFCCION||DIGITO_CHEQUEO||' - '||CIA_NMBRE
          INTO NOMBRE_CIA
          FROM CMPNIAS, JURIDICOS
         WHERE CIA_CDGO = '40'
           AND NUMERO_DOCUMENTO = CIA_NMRO_IDNTFCCION;

        SELECT VALOR
          INTO NIT_CIA
          FROM PARAMETRO_SAI
         WHERE ID = 'NACH';

        SELECT VALOR
          INTO SERVICIO_ACH
          FROM PARAMETRO_SAI
         WHERE ID = 'ACH';

        SELECT SEQ_VALIDA_CAPI_TRONADOR.NEXTVAL
          INTO V_CONSECUTIVO
          FROM DUAL;

        P_CODIGO := V_CONSECUTIVO;

        --  Mantis 38629.  Se debe modificar el cálculo del IVA.
        --  VALOR_IVA := ROUND((P_VALOR_PAGO * (FUN_VALOR_IVA/100)),0);
        VALOR_IVA := P_VALOR_PAGO  -  ROUND((P_VALOR_PAGO / ((1 + pkg_operacion.FUN_VALOR_IVA/100))),0);


        INSERT INTO PARAMETROS_PSE
          (COD_TRANSACCION_SB,
           ESTADO_TRANSACCION_SB,
           F_TRANSACCION_SB,
           COD_TRANSACCION_PSE,
           ESTADO_TRANSACCION_PSE,
           F_TRANSACCION_PSE,
           TIPO_ID,
           IDENTIFICACION,
           REFERENCIA,
           VALOR_A_PAGAR,
           VALOR_IVA,
           NIT_CIA,
           DESC_CIA,
           COD_PROD,
           DESC_PROD,
           IDORIGEN)
        VALUES
          (V_CONSECUTIVO,
           'PENDING',
           SYSDATE,
           NULL,
           NULL,
           NULL,
           P_TIPO_ID,
           P_NMRO_ID,
           'CERT. # '||P_TEXTO,
           P_VALOR_PAGO,
           VALOR_IVA,
           NIT_CIA,
           NOMBRE_CIA,
           SERVICIO_ACH,
           V_DESC_PROD,
           'URL_PRIMAS');
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20501,'Error al insertar en parametros_pse '||SQLERRM);
      END;
    ELSE
      RAISE_APPLICATION_ERROR(-20502,'Error en obligaciones pagar del proceso insertar_pse'||SQLERRM);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20503,'Error en proceso insertar_pse '||SQLERRM);

  END PRC_INSERTA_PSE;


  --
  --
  --
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
                                  P_RECIBO_CJA        NUMBER) IS

  COMPANIA_TRONADOR   CNVRSION_TRNDOR.CNT_CMPNIA_TRNDOR%TYPE;
  AGENCIA_TRONADOR    CNVRSION_TRNDOR.CNT_AGNCIA_TRNDOR%TYPE;
  V_CERTIFICADO       CRTFCDOS.CER_NMRO_CRTFCDO%TYPE;
  RIESGOS             VARCHAR2(100);
  SUB_TIPO_ORDEN      VARCHAR2(1);
  V_NUMERO_ORDEN_PAGO NUMBER(14) := 0;
  V_PERIODO           VARCHAR2(6);
  ASIENTO             VARCHAR2(4);
  MENSAJE             VARCHAR2(100);
  CONCEPTO_PAGO       VARCHAR2(4);
  VALOR               NUMBER;

  BEGIN

      ASIENTO  := 'EMA';
      -- TRAER LA COMPA?IA Y OFICINA TRONADOR SEGUN LA CLASE DE ASIENTO Y LA SUCURSAL DE LA POLIZA.
      BEGIN
        SELECT CNT_CMPNIA_TRNDOR,CNT_AGNCIA_TRNDOR
          INTO COMPANIA_TRONADOR, AGENCIA_TRONADOR
          FROM CNVRSION_TRNDOR
         WHERE CNT_CMPNIA = P_COMPANIA
           AND CNT_SCRSAL = P_SUCURSAL
           AND CNT_CLSE_ASNTO = ASIENTO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20500,'La compa?ia y oficina tronador no se encuentran definidas.');
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20501,'Error al consultar la compa?ia y oficina tronador.'||sqlerrm);
      END;

      BEGIN
        SELECT NUM_ORD_PAGO
          INTO V_NUMERO_ORDEN_PAGO
          FROM a5010060
         WHERE COD_CIA = COMPANIA_TRONADOR AND COD_AGENCIA = AGENCIA_TRONADOR;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20502,'No existe registro para obtener el numero de la orden de pago' ||sqlerrm);
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20503,'Error al obtener el numero de la orden de pago1.' ||sqlerrm);
      END;
      V_PERIODO := TO_CHAR(P_FECHA_PAGO,'MMYYYY');
      V_NUMERO_ORDEN_PAGO := TO_NUMBER(TO_CHAR(AGENCIA_TRONADOR) ||SUBSTR(V_PERIODO, 3, 4) ||
                             LPAD(TO_CHAR(V_NUMERO_ORDEN_PAGO), 6, '0'));

      IF COMPANIA_TRONADOR = '7' THEN
        SUB_TIPO_ORDEN := 'J';
      ELSE
        SUB_TIPO_ORDEN := NULL;
      END IF;

      -- ORIGEN C = SE GENERA EN EL CIERRE DEL LIBERTADOR Y D - CIERRE DIARIO DE TESORERIA
      IF P_ORIGEN = 'C' THEN
        BEGIN
          SELECT CER_NMRO_CRTFCDO
            INTO V_CERTIFICADO
            FROM CRTFCDOS
           WHERE CER_NMRO_PLZA = P_POLIZA
             AND TO_CHAR(CER_FCHA_DSDE_ACTUAL,'MMYYYY') = TO_CHAR(P_FECHA_PAGO,'MMYYYY');
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20504,'Error consultando el certificado.' ||SQLERRM);
        END;
        VALOR  := P_VALOR * (-1);

        BEGIN
          SELECT PAR_RFRNCIA
            INTO CONCEPTO_PAGO
            FROM PRMTROS
           WHERE PAR_MDLO  = '6'
             AND PAR_CDGO   = '5'
             AND PAR_VLOR1 = '3'
             AND PAR_SUC_CDGO   = P_SUCURSAL
             AND PAR_SUC_CIA_CDGO = P_COMPANIA;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20505,'ERROR CONSULTANDO EL CONCEPTO DE LA ORDEN'||SQLERRM);
        END;
      ELSE
        V_CERTIFICADO := P_RECIBO_CJA;
        VALOR  := P_VALOR;

        BEGIN
          SELECT PAR_RFRNCIA
            INTO CONCEPTO_PAGO
            FROM PRMTROS
           WHERE PAR_MDLO  = '6'
             AND PAR_CDGO   = '5'
             AND PAR_VLOR1 = '4'
             AND PAR_SUC_CDGO   = P_SUCURSAL
             AND PAR_SUC_CIA_CDGO = P_COMPANIA;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RAISE_APPLICATION_ERROR(-20514,'ERROR CONSULTANDO EL CONCEPTO DE LA ORDEN'||SQLERRM);
        END;
      END IF;
      
      BEGIN
        INTERFAZ_TESORERIA_VARIOS(P_COMPANIA,
                                  P_SUCURSAL,
                                  P_FECHA_PAGO,
                                  COMPANIA_TRONADOR,
                                  AGENCIA_TRONADOR,
                                  P_TIPO_BENEFICIARIO,
                                  P_NIT_BENEFICIARIO,
                                  VALOR,
                                  ASIENTO,
                                  P_USUARIO,
                                  NULL,
                                  P_SUCURSAL_PAGO,
                                  V_NUMERO_ORDEN_PAGO,
                                  'D',
                                  SUB_TIPO_ORDEN,
                                  CONCEPTO_PAGO,
                                  AGENCIA_TRONADOR,
                                  MENSAJE);
        IF MENSAJE IS NOT NULL THEN
          RAISE_APPLICATION_ERROR(-20507,MENSAJE);
        END IF;

        MENSAJE := NULL;

        IF P_ORIGEN = 'C' THEN
          BEGIN
            INTERFAZ_CONTABLE(P_COMPANIA,
                              P_SUCURSAL,
                              TO_DATE('01' ||TO_CHAR(SYSDATE,'MMYYYY'),'DDMMYYYY'),
                              ASIENTO,
                              'E',
                              VALOR,
                              TO_CHAR(V_CERTIFICADO),
                              P_TIPO_BENEFICIARIO,
                              P_NIT_BENEFICIARIO,
                              'P',
                              MENSAJE,
                              'DEBITO',
                              'DEBITO',
                              NULL,
                              NULL,
                              'C');
            IF MENSAJE IS NOT NULL THEN
              RAISE_APPLICATION_ERROR(-20515,MENSAJE);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20508,'Error en contabilidad de la orden..' ||SQLERRM);
          END;

          BEGIN
            INTERFAZ_CONTABLE(P_COMPANIA,
                              P_SUCURSAL,
                              TO_DATE('01' ||TO_CHAR(SYSDATE,'MMYYYY'),'DDMMYYYY'),
                              ASIENTO,
                              'E',
                              VALOR,
                              TO_CHAR(V_CERTIFICADO),
                              P_TIPO_BENEFICIARIO,
                              P_NIT_BENEFICIARIO,
                              'P',
                              MENSAJE,
                              'CREDITO',
                              'CREDITO',
                              NULL,
                              NULL,
                              'C');
            IF MENSAJE IS NOT NULL THEN
              RAISE_APPLICATION_ERROR(-20515,MENSAJE);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20508,'Error en contabilidad de la orden..' ||SQLERRM);
          END;
        ELSE
          BEGIN
            INTERFAZ_CONTABLE(P_COMPANIA,
                              P_SUCURSAL,
                              SYSDATE,
                              ASIENTO,
                              'E',
                              VALOR,
                              TO_CHAR(P_RECIBO_CJA),
                              P_TIPO_BENEFICIARIO,
                              P_NIT_BENEFICIARIO,
                              'R',
                              MENSAJE,
                              'DEBITO',
                              'DEBITO',
                              NULL,
                              NULL,
                              'C');
            IF MENSAJE IS NOT NULL THEN
              RAISE_APPLICATION_ERROR(-20516,MENSAJE);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20509,'Error en contabilidad de la orden..' ||SQLERRM);
          END;

          BEGIN
            INTERFAZ_CONTABLE(P_COMPANIA,
                              P_SUCURSAL,
                              SYSDATE,
                              ASIENTO,
                              'E',
                              VALOR,
                              TO_CHAR(P_RECIBO_CJA),
                              P_TIPO_BENEFICIARIO,
                              P_NIT_BENEFICIARIO,
                              'R',
                              MENSAJE,
                              'CREDITO',
                              'CREDITO',
                              NULL,
                              NULL,
                              'C');
            IF MENSAJE IS NOT NULL THEN
              RAISE_APPLICATION_ERROR(-20515,MENSAJE);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20506,'Error en contabilidad de la orden..' ||SQLERRM);
          END;

        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20508,'Error al generar la orden de pago..' ||SQLERRM);
      END;

      BEGIN
        UPDATE a5010060
           SET NUM_ORD_PAGO = NUM_ORD_PAGO + 1
         WHERE COD_CIA = COMPANIA_TRONADOR
           AND COD_AGENCIA = AGENCIA_TRONADOR;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          RAISE_APPLICATION_ERROR(-20507,'Error actualizando el numero de la orden de pago.' ||SQLERRM);
      END;

      IF P_ORIGEN = 'C' THEN
        BEGIN
          UPDATE CRTFCDOS
             SET CER_VLOR_SLDO = 0,
                 CER_ESTDO_PRDCCION = '50'
           WHERE CER_NMRO_PLZA = P_POLIZA
             AND  TO_CHAR(CER_FCHA_DSDE_ACTUAL,'MMYYYY') = TO_CHAR(P_FECHA_PAGO,'MMYYYY');
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20508,'Error actualizando el saldo y estado del certificado.' ||SQLERRM);
        END;

        RIESGOS := PKG_CONSULTA_OPERACION.FUN_RIESGOS_DEVOLUCION(P_POLIZA,P_FECHA_PAGO);
      ELSE
        RIESGOS := '0';
      END IF;

      BEGIN
        INSERT INTO DEVOLUCION_PRIMAS
          VALUES(SEQ_DEVOLUCIONES.NEXTVAL,P_POLIZA,P_CLASE,P_RAMO,V_CERTIFICADO,
                 VALOR,RIESGOS,P_FECHA_PAGO,V_NUMERO_ORDEN_PAGO,P_ORIGEN,P_USUARIO,SYSDATE,NULL,NULL);
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          RAISE_APPLICATION_ERROR(-20509,'Error al insertar en devolucion_primas .' ||SQLERRM);
      END;

  END PRC_GENERA_ORDEN_PAGO;

  --
  --
  --
  PROCEDURE PRC_ACTUALIZA_LIQUIDACION(P_LIQUIDACION  NUMBER,
                                      P_COMPANIA     VARCHAR2,
                                      P_TIPO_RECIBO  VARCHAR2,
                                      P_VALOR_RECIBO NUMBER) IS

  CURSOR C_DATOS IS
    SELECT DISTINCT EST_SLCTUD,EST_PLZA
      FROM ESTADO_CTA_RCBOS
     WHERE EST_NMRO_RCBO = P_LIQUIDACION
       AND EST_CDGO_CNCPTO = 'PRM';

  R_DATOS    C_DATOS%ROWTYPE;
  VR_CRTFCDO NUMBER;
  VALOR      NUMBER;

  BEGIN
    BEGIN
      UPDATE RCBOS_CJA
         SET RCC_VLOR_RCBO = P_VALOR_RECIBO
       WHERE RCC_NMRO_RCBO = P_LIQUIDACION
         AND RCC_CIA_CDGO = P_COMPANIA
         AND RCC_TPO_RCBO = P_TIPO_RECIBO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20511,'Error al actualizar dtlles_rcbos_cja..'||SQLERRM);
    END;

    OPEN C_DATOS;
    LOOP
      FETCH C_DATOS INTO R_DATOS;
      IF C_DATOS%NOTFOUND THEN
        EXIT;
      END IF;

      VR_CRTFCDO := PKG_CONSULTA_OPERACION.FUN_DEUDA_POLIZA(R_DATOS.EST_PLZA,R_DATOS.EST_SLCTUD);

      BEGIN
          UPDATE DTLLES_RCBOS_CJA
             SET DRC_VLOR_PGDO = VR_CRTFCDO
           WHERE DRC_NMRO_RCBO = P_LIQUIDACION
             AND DRC_CDGO_CIA = P_COMPANIA
             AND DRC_TPO_RCBO = P_TIPO_RECIBO
             AND SUBSTR(DRC_RFRNCIA,15,10) = TO_CHAR(R_DATOS.EST_SLCTUD);

          VALOR := ROUND(VR_CRTFCDO /(1 + (PKG_CONSULTA_OPERACION.FUN_PORCENTAJE_IVA/100)),0);

          BEGIN
            UPDATE CNCPTOS_DTLLE_RCBOS
               SET CDR_VLOR = VALOR
             WHERE CDR_NMRO_RCBO = P_LIQUIDACION
               AND CDR_CDGO_CIA = P_COMPANIA
               AND CDR_TPO_RCBO = P_TIPO_RECIBO
               AND CDR_CDGO_CNCPTO = 'PRM'
               AND SUBSTR(CDR_RFRNCIA,15,10) = TO_CHAR(R_DATOS.EST_SLCTUD);

            UPDATE CNCPTOS_DTLLE_RCBOS
               SET CDR_VLOR = VR_CRTFCDO - VALOR
             WHERE CDR_NMRO_RCBO = P_LIQUIDACION
               AND CDR_CDGO_CIA = P_COMPANIA
               AND CDR_TPO_RCBO = P_TIPO_RECIBO
               AND CDR_CDGO_CNCPTO = 'IVA'
               AND SUBSTR(CDR_RFRNCIA,15,10) = TO_CHAR(R_DATOS.EST_SLCTUD);
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20510,'Error al actualizar cncptos_dtlles_rcbos..'||SQLERRM);
          END;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20510,'Error al actualizar dtlles_rcbos_cja..'||SQLERRM);
        END;
    END LOOP;
    CLOSE C_DATOS;


  END PRC_ACTUALIZA_LIQUIDACION;


  --
  --
  --
  PROCEDURE PRC_ANULAR_LIQUIDACION(P_TIPO_ID     IN VARCHAR2,
                                   P_NUMERO_ID   IN NUMBER,
                                   P_POLIZA      IN NUMBER,
                                   P_MENSAJE     OUT VARCHAR2) IS

  CURSOR C_RECIBOS IS
     SELECT *
      FROM RCBOS_CJA RCC, ESTADO_CTA_RCBOS
     WHERE RCC.RCC_NMRO_IDNTFCCION = P_NUMERO_ID
       AND RCC.RCC_TPO_IDNTFCCION  = P_TIPO_ID
       AND EST_PLZA = P_POLIZA -- Mantis 37947  GGM. 21/07/2015
       AND RCC.RCC_ESTDO_RCBO NOT IN ('I','A')
       AND RCC.RCC_FCHA_RCBO > TO_DATE('01/01/2015','DD/MM/YYYY') -- inicia construccion
       AND RCC.RCC_NMRO_RCBO = EST_NMRO_RCBO
       AND RCC.RCC_TPO_RCBO = EST_TPO_RCBO
       AND RCC.RCC_CIA_CDGO = EST_CIA_CDGO
       AND EST_ORGEN_RCDO = 'P';

  EXISTE        NUMBER;
  R_RECIBOS     C_RECIBOS%ROWTYPE;
  V_SALIDA      VARCHAR2(2);
  V_MENSAJE     VARCHAR2(1000);
  V_CODIGO      PARAMETROS_PSE.COD_TRANSACCION_PSE%TYPE;
  V_LIQUIDACION PARAMETROS_PSE.COD_TRANSACCION_SB%TYPE;


  BEGIN
    OPEN C_RECIBOS;
    LOOP
      FETCH C_RECIBOS INTO R_RECIBOS;
      IF C_RECIBOS%NOTFOUND THEN
        EXIT;
      END IF;

      SELECT COUNT(8)
        INTO EXISTE
        FROM A5021113
       WHERE NUM_LIQUIDACION = R_RECIBOS.RCC_NMRO_RCBO
         AND DOCUMENTO > 0;

      IF NVL(EXISTE,0) > 0 THEN
        P_MENSAJE := 'Existe una liquidación ya recaudada pendiente por procesar ';
        RETURN;
      ELSE
        IF P_POLIZA IS NOT NULL THEN
          BEGIN
            SELECT COUNT(*)
              INTO EXISTE
              FROM PARAMETROS_PSE pp
             INNER JOIN OBLIGACIONES_PAGAR op ON (pp.IDENTIFICACION = op.numero_identificacion
               AND op.COBRADOR = TO_CHAR(COD_TRANSACCION_SB))
             WHERE pp.IDENTIFICACION = P_NUMERO_ID
               AND pp.ESTADO_TRANSACCION_PSE IN ('PROCESSING','PENDING')
               AND op.poliza = P_POLIZA;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              EXISTE := 0;
          END;
          IF NVL(EXISTE,0) > 0 THEN
            BEGIN
              SELECT pp.COD_TRANSACCION_SB, pp.COD_TRANSACCION_PSE
                INTO V_LIQUIDACION,V_CODIGO
                FROM PARAMETROS_PSE pp
               INNER JOIN OBLIGACIONES_PAGAR op ON (pp.IDENTIFICACION = op.numero_identificacion
                 AND op.COBRADOR = TO_CHAR(COD_TRANSACCION_SB))
               WHERE pp.IDENTIFICACION = P_NUMERO_ID
                 AND pp.ESTADO_TRANSACCION_PSE IN ('PROCESSING','PENDING')
                 AND op.poliza = P_POLIZA
                 AND pp.F_TRANSACCION_SB = (SELECT MAX(p1.F_TRANSACCION_SB) -- MANTIS 42588 03/02/2015 GGM.
                                              FROM PARAMETROS_PSE p1
                                             INNER JOIN OBLIGACIONES_PAGAR op1 ON (p1.IDENTIFICACION = op1.NUMERO_IDENTIFICACION
                                                            AND op1.COBRADOR = TO_CHAR(p1.COD_TRANSACCION_SB))
                                             WHERE p1.IDENTIFICACION = pp.IDENTIFICACION
                                               AND p1.ESTADO_TRANSACCION_PSE IN ('PROCESSING','PENDING')
                                               AND op1.poliza = op.poliza);
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'Error al consultar la transación pendiente..'||sqlerrm;
                RETURN;
            END;
          END IF;
        ELSE
          BEGIN
            SELECT COUNT(*)
              INTO EXISTE
              FROM PARAMETROS_PSE
             WHERE IDENTIFICACION = P_NUMERO_ID
               AND ESTADO_TRANSACCION_PSE IN ('PROCESSING','PENDING');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              EXISTE := 0;
          END;
          IF NVL(EXISTE,0) > 0 THEN
            BEGIN
              SELECT P.COD_TRANSACCION_SB, P.COD_TRANSACCION_PSE
                INTO V_LIQUIDACION,V_CODIGO
                FROM PARAMETROS_PSE P
               WHERE P.IDENTIFICACION = P_NUMERO_ID
                 AND P.ESTADO_TRANSACCION_PSE IN ('PROCESSING','PENDING')
                 AND P.F_TRANSACCION_SB = (SELECT MAX(P1.F_TRANSACCION_SB)   -- MANTIS 42588 03/02/2015 GGM.
                                             FROM PARAMETROS_PSE P1
                                            WHERE P1.IDENTIFICACION = P.IDENTIFICACION
                                              AND P1.ESTADO_TRANSACCION_PSE IN ('PROCESSING','PENDING'));
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                P_MENSAJE := 'Error al consultar la transación pendiente..'||sqlerrm;
                RETURN;
            END;
          END IF;
        END IF;

        IF NVL(EXISTE,0) > 0 THEN
          P_MENSAJE := 'En este momento su factura Nro. '||V_LIQUIDACION||' presenta un proceso de pago cuya transacción se encuentra PENDIENTE de recibir confirmación por parte de su entidad financiera, por favor espere unos minutos y vuelva a consultar más tarde para verificar si su pago fue confirmado de forma exitosa. Si desea mayor información sobre el estado actual de su operación puede comunicarse a nuestra línea en Bogotá 3527070 y pregunte por el estado de la transacción Nro. : '||V_CODIGO;
          RETURN;
        ELSE
          PKG_CARTERA.PRC_ANULAR_RECIBO_BOLIVAR (R_RECIBOS.EST_CIA_CDGO,
                                                 R_RECIBOS.EST_TPO_RCBO,
                                                 R_RECIBOS.RCC_NMRO_RCBO,
                                                 R_RECIBOS.EST_CIA_CDGO,
                                                 R_RECIBOS.RCC_SUC_CDGO,
                                                 V_SALIDA,
                                                 V_MENSAJE);
          IF V_SALIDA != 'OK' THEN
            P_MENSAJE := V_MENSAJE;
            ROLLBACK;
          END IF;
        END IF;
      END IF;

    END LOOP;
    CLOSE C_RECIBOS;

  EXCEPTION
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20509,SQLERRM);

  END PRC_ANULAR_LIQUIDACION;

  --
  --
  --
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
                                   P_MENSAJE           OUT VARCHAR2) IS
  V_SECUENCIA NUMBER;
  BEGIN
    P_RESULTADO := 'OK';
    P_MENSAJE   := NULL;

    IF P_OPERACION = 'I' THEN
      BEGIN
        V_SECUENCIA := SEQ_TIPOS_CARTAS_PRIMAS.NEXTVAL;

        INSERT INTO TIPOS_CARTAS_PRIMAS
             (SECUENCIA_CARTA,
              DESCRIPTION_CARTA,
              REFERENCIA,
              ALTURA_MORA,
              TEXTO_INICIAL,
              TEXTO_FINAL,
              SECUENCIA_FIRMA,
              CARTA_AUTOMATICA,
              USUARIO_CREACION,
              FECHA_CREACION,
              USUARIO_MODIFICACION,
              FECHA_MODIFICACION)
          VALUES(
              V_SECUENCIA,
              P_DESCRIPCION,
              P_REFERENCIA,
              P_SECUENCIA_MORA,
              P_TEXTO_INICIAL,
              P_TEXTO_FINAL,
              P_SECUENCIA_FIRMA,
              P_CARTA_AUTOMATICA,
              P_USUARIO,
              SYSDATE,
              NULL,
              NULL);
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          P_RESULTADO := 'ER';
          P_MENSAJE   := 'ERROR INSERTANDO EL TIPO DE CARTA  ..'||SQLERRM;
          ROLLBACK;
          RETURN;
      END;
    ELSE
      IF P_SECUENCIA_CARTA IS NULL THEN
        P_RESULTADO := 'ER';
        P_MENSAJE   := 'LA SECUENCIA DEL TIPO DE CARTA ES NULA';
        RETURN;
      ELSE
        BEGIN
          UPDATE TIPOS_CARTAS_PRIMAS
             SET DESCRIPTION_CARTA = P_DESCRIPCION,
                 REFERENCIA = P_REFERENCIA,
                 ALTURA_MORA = P_SECUENCIA_MORA,
                 TEXTO_INICIAL = P_TEXTO_INICIAL,
                 TEXTO_FINAL = P_TEXTO_FINAL,
                 SECUENCIA_FIRMA = P_SECUENCIA_FIRMA,
                 CARTA_AUTOMATICA = P_CARTA_AUTOMATICA,
                 USUARIO_MODIFICACION = P_USUARIO,
                 FECHA_MODIFICACION = SYSDATE
           WHERE SECUENCIA_CARTA = P_SECUENCIA_CARTA;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            P_RESULTADO := 'ER';
            P_MENSAJE   := 'ERROR ACTUALIZANDO EL TIPO DE CARTA  ..'||SQLERRM;
            ROLLBACK;
            RETURN;
       END;
      END IF;
    END IF;

  END PRC_INSERTA_TIPO_CARTA;

  --
  --
  --
  PROCEDURE PRC_INSERTA_BITACORA_PRIMAS(P_NUMERO_POLIZA   NUMBER,
                                        P_CLASE_POLIZA    VARCHAR2,
                                        P_RAMO            VARCHAR2,
                                        P_TEXTO_BITACORA  VARCHAR,
                                        P_USUARIO         VARCHAR2,
                                        P_RESULTADO       OUT VARCHAR2,
                                        P_MENSAJE         OUT VARCHAR2) IS

  BEGIN
    P_RESULTADO := 'OK';
    P_MENSAJE   := NULL;

    BEGIN
      INSERT INTO BITACORA_COBRO_PRIMAS
         (SECUENCIA,
          NUMERO_POLIZA,
          CLASE_POLIZA,
          RAMO,
          TEXTO_BITACORA,
          USUARIO_CREACION,
          FECHA_CREACION,
          USUARIO_MODIFICACION,
          FECHA_MODIFICACION)
        VALUES(
          SEQ_BITACORA_PRIMAS.NEXTVAL,
          P_NUMERO_POLIZA,
          P_CLASE_POLIZA,
          P_RAMO,
          P_TEXTO_BITACORA,
          P_USUARIO,
          SYSDATE,
          NULL,
          NULL);
        COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        P_RESULTADO  := 'ER';
        P_MENSAJE    := 'Error Insertando en la bitacora ..'||SQLERRM;
        ROLLBACK;
        RETURN;
    END;

  END PRC_INSERTA_BITACORA_PRIMAS;

  --
  --
  --
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
                                       P_MENSAJE         OUT VARCHAR2) IS

  BEGIN
    P_RESULTADO := 'OK';
    P_MENSAJE   := NULL;

    IF P_OPERACION = 'I' THEN
      BEGIN
        INSERT INTO FECHAS_COBRO_PRIMAS
          (SECUENCIA,
           NUMERO_POLIZA,
           CLASE_POLIZA,
           RAMO,
           FECHA_ACUERDO,
           VALOR_ACUERDO,
           OBSERVACION,
           MARCA_PAGADO,
           USUARIO_CREACION,
           FECHA_CREACION,
           USUARIO_MODIFICACION,
           FECHA_MODIFICACION)
        VALUES
          (SEQ_FECHAS_ACUERDO.NEXTVAL,
           P_NUMERO_POLIZA,
           P_CLASE_POLIZA,
           P_RAMO,
           P_FECHA_ACUERDO,
           P_VALOR_ACUERDO,
           P_OBSERVACION,
           P_MARCA_PAGADO,
           P_USUARIO,
           SYSDATE,
           NULL,
           NULL);
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          P_RESULTADO   := 'ER';
          P_MENSAJE     := 'Error insertando las fechas de Acuerdo ..'||SQLERRM;
          ROLLBACK;
          RETURN;
      END;
    ELSIF P_OPERACION = 'A' THEN
      IF P_SECUENCIA IS NOT NULL THEN
        BEGIN
          UPDATE FECHAS_COBRO_PRIMAS
             SET FECHA_ACUERDO = P_FECHA_ACUERDO,
                 VALOR_ACUERDO = P_VALOR_ACUERDO,
                 OBSERVACION = P_OBSERVACION,
                 MARCA_PAGADO = P_MARCA_PAGADO,
                 USUARIO_MODIFICACION = P_USUARIO,
                 FECHA_MODIFICACION = SYSDATE
           WHERE NUMERO_POLIZA =P_NUMERO_POLIZA
             AND SECUENCIA =  P_SECUENCIA;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            P_RESULTADO  := 'ER';
            P_MENSAJE    := 'Error actualizando la fechas de Acuerdo ..'||SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      ELSE
        P_RESULTADO   := 'ER';
        P_MENSAJE     := 'El número de la secuencia es nulo para actualizar el registro ..';
      END IF;
    ELSE
      IF P_SECUENCIA IS NOT NULL THEN
        BEGIN
          DELETE FECHAS_COBRO_PRIMAS
           WHERE NUMERO_POLIZA = P_NUMERO_POLIZA
             AND SECUENCIA =  P_SECUENCIA;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            P_RESULTADO    := 'ER';
            P_MENSAJE      := 'Error actualizando la fechas de Acuerdo ..'||SQLERRM;
            ROLLBACK;
            RETURN;
        END;
      ELSE
        P_RESULTADO   := 'ER';
        P_MENSAJE     := 'El número de la secuencia es nulo para borrar el registro ..';
      END IF;
    END IF;

  END PRC_INSERTA_FECHAS_ACUERDO;

  --
  --
  --
  PROCEDURE PRC_ENVIAR_CORREO(P_NUMERO_POLIZA      IN NUMBER,
                              P_USUARIO           IN VARCHAR2,
                              P_CORREO_DESTINO    IN VARCHAR2,
                              P_RESULTADO         OUT VARCHAR2,
                              P_MENSAJE           OUT VARCHAR2) IS

  V_CORREO           VARCHAR2(1000);
  V_ASUNTO           VARCHAR2(1000);
  V_TEXTO            VARCHAR2(1000);
  V_LINK             VARCHAR2(1000);
  LINK               VARCHAR2(1000);
  V_NOMBRE           USRIOS.USR_NMBRE%TYPE;

 BEGIN
     P_RESULTADO  := 'OK';
     P_MENSAJE := NULL;
   BEGIN
     SELECT PK_TERCEROS.F_NOMBRES(POL_PRS_NMRO_IDNTFCCION,POL_PRS_TPO_IDNTFCCION)
       INTO V_NOMBRE
       FROM PLZAS
      WHERE POL_NMRO_PLZA = P_NUMERO_POLIZA;
   EXCEPTION
     WHEN OTHERS THEN
       P_RESULTADO  := 'ER';
       P_MENSAJE := 'Error consultando el nombre de la póliza ..'||SQLERRM;
       ROLLBACK;
       RETURN;
   END;

   IF P_CORREO_DESTINO IS NULL THEN
     P_RESULTADO  := 'ER';
     P_MENSAJE := 'No ha ingresado el correo al cual le desea enviar la carta.'||SQLERRM;
     RETURN;
   ELSE
     BEGIN
       SELECT VALOR
         INTO LINK
         FROM PARAMETRO_SAI
        WHERE ID = 'EXCA';

       BEGIN
         SELECT T.PAR_RFRNCIA
           INTO V_CORREO
           FROM PRMTROS T
          WHERE T.PAR_CDGO = 'CACR'
            AND T.PAR_MDLO = '2';

         V_ASUNTO := 'Link para carta de Acuerdo de pago de Primas de Arrendamiento : '||P_NUMERO_POLIZA||'- '|| V_NOMBRE;
         V_LINK   := LINK||'poliza='||P_NUMERO_POLIZA;
         V_TEXTO  := 'Buen día: ' ||chr(10)||chr(10)||chr(10)||chr(10)||'Adjuntamos carta de acuerdo de pago, por favor acceda al link adjunto para imprimirla.  Cancele en Oficinas Banco Davivienda ó vía pago electrónico a través de botón PSE. '||chr(10)||v_link||chr(10)||chr(10)||chr(10)||chr(10)||'Señor Arrendatario: Recuerde que sus pagos se deben efectuar unicamente a través  de los medios autorizados por El Libertador, para mayor información comuniquese con el PBX 3527070 Area comercial.'||chr(10)||chr(10)||'El Libertador ';

         PRC_SEND_MAIL(P_CORREO_DESTINO,
                       NULL,
                       V_CORREO,
                       V_ASUNTO,
                       V_TEXTO);
         BEGIN
           INSERT INTO CORREOS_ACUERDOS_PAGO
               (SECUENCIA,
                NUMERO_POLIZA,
                CLASE_POLIZA,
                RAMO,
                CORREO_DESTINO,
                USUARIO_CREACION,
                FECHA_CREACION,
                USUARIO_MODIFICACION,
                FECHA_MODIFICACION)
             VALUES
               (SEQ_ENVIO_CORREOS_PRIMAS.NEXTVAL,
                P_NUMERO_POLIZA,
                '00',
                '12',
                P_CORREO_DESTINO,
                P_USUARIO,
                SYSDATE,
                NULL,
                NULL);
            COMMIT;
         EXCEPTION
           WHEN OTHERS THEN
             P_RESULTADO  := 'ER';
             P_MENSAJE := 'Error insertando el correo enviado ..'||SQLERRM;
             ROLLBACK;
             RETURN;
         END;
       EXCEPTION
         WHEN OTHERS THEN
           P_RESULTADO  := 'ER';
           P_MENSAJE := 'Error consultando el correo de envio de la carta ..'||SQLERRM;
           ROLLBACK;
           RETURN;
       END;
     EXCEPTION
       WHEN OTHERS THEN
       P_RESULTADO  := 'ER';
       P_MENSAJE := 'Error consultando el link de la carta ..'||SQLERRM;
       ROLLBACK;
       RETURN;
     END;

   END IF;

  END PRC_ENVIAR_CORREO;

  --
  --
  --
  PROCEDURE PRC_ACTUALIZA_PLZAS(P_POLIZA    NUMBER,
                                P_ENVIO     VARCHAR2,
                                P_USUARIO   VARCHAR2,
                                P_RESULTADO OUT VARCHAR2,
                                P_MENSAJE   OUT VARCHAR2) IS


  BEGIN
     P_RESULTADO := 'OK';
     P_MENSAJE   := NULL;

    BEGIN
      UPDATE PLZAS
         SET POL_ENVIA_CARTA = P_ENVIO,
             POL_USRIO = P_USUARIO,
             POL_FCHA_MDFCCION = SYSDATE
       WHERE POL_NMRO_PLZA = P_POLIZA;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        P_RESULTADO  := 'ER';
        P_MENSAJE    := 'Error actualizando en plzas ..'||SQLERRM;
        ROLLBACK;
        RETURN;
    END;

  END PRC_ACTUALIZA_PLZAS;

  --
  --
  --
  PROCEDURE PRC_ANULA_PLZAS(P_USUARIO  VARCHAR2,
                            P_MENSAJE  OUT VARCHAR2) IS

  CURSOR C_PLZAS IS
    SELECT *
      FROM PLZAS
     WHERE POL_TPOPLZA = 'I'
       AND POL_ESTADO_PLZA = 'V'
       AND TRUNC(ADD_MONTHS(POL_FCHA_EXPDCION,1)+1) <= TRUNC(SYSDATE) -- MANTIS 37891
       AND PKG_CONSULTA_OPERACION.FUN_VALIDA_PAGO(POL_NMRO_PLZA) = 'N';
       
  CURSOR C_INTRFAZ_C(ASIE VARCHAR2, CERTI NUMBER) IS
    SELECT *  
      FROM INTRFAZ_CNTBLE
     WHERE INC_CMPNIA = 3
       and INC_ASNTO IN (ASIE,'EMA')
       and INC_DCMNTO = TO_CHAR(CERTI);
       

  R_PLZAS            C_PLZAS%ROWTYPE;
  R_INTERFAZ         C_INTRFAZ_C%ROWTYPE;
  V_MENSAJE          VARCHAR2(500);
  CRTFCDO            NUMBER;
  V_ASIENTO          VARCHAR2(10);
  V_CONCEPTO_PRIMA   VARCHAR2(10);
  V_CONCEPTO_IVA     VARCHAR2(10);


  BEGIN
    OPEN C_PLZAS;
    LOOP
      FETCH C_PLZAS INTO R_PLZAS;
      IF C_PLZAS%NOTFOUND THEN
        EXIT;
      END IF;

      BEGIN
        PK_CANCELA_INDIVIDUAL.BORRA_RIESGOS_INDIVIDUAL(R_PLZAS.POL_NMRO_PLZA,
                                                       R_PLZAS.POL_CDGO_CLSE,
                                                       R_PLZAS.POL_RAM_CDGO,
                                                       V_MENSAJE );
      

        BEGIN
          SELECT CER_SEQ.NEXTVAL
            INTO CRTFCDO
            FROM DUAL;
        
          BEGIN
            UPDATE CRTFCDOS
               SET CER_ESTDO_PRDCCION = '70'
             WHERE CER_NMRO_PLZA = R_PLZAS.POL_NMRO_PLZA;

            BEGIN
              INSERT INTO CRTFCDOS
                SELECT CRTFCDO,
                       CER_NMRO_PLZA,
                       CER_CLSE_PLZA,
                       CER_RAM_CDGO,
                       CER_CLSE_CRTFCDO,
                       CER_CDGO_CIASGRO,
                       CER_CDGO_MNDA,
                       CER_CDGO_CRTFCDO,
                       CER_NMRO_IDNTFCCION,
                       CER_TPO_IDNTFCCION,
                       CER_DIAS_VGNCIA_ACTUAL,
                       CER_FCHA_HSTA_ACTUAL,
                       SYSDATE,
                       CER_FCHA_DSDE_ACTUAL,
                       CER_TPO_PRDCCION,
                       '70',
                       CER_CMBIO,
                       CER_PRTCPCION_CMPNIA,
                       CER_PRTCPCION_AGNTE,
                       CER_PRCNTJE_IVA,
                       CER_PRCNTJE_CMSION,
                       'A',
                       CER_GSTOS_EXPDCION,
                       CER_VLOR_CMSION * (-1),
                       CER_VLOR_PRMA_NTA * (-1),
                       CER_VLOR_PRMA_TTAL * (-1),
                       CER_VLOR_SLDO * (-1),
                       CER_VLOR_SMA_ASGRDA * (-1),
                       CER_VLOR_IVA * (-1),
                       P_USUARIO,
                       CER_VLOR_CTA_PRMA,
                       CER_VLOR_PPLRIA,
                       SYSDATE,
                       CER_NMRO_APLCCION,
                       CER_VLOR_CTA_FAX,
                       CER_FCHA_PGO,
                       SYSDATE,
                       CER_VLOR_TTAL_CRTFCDO * (-1)
               FROM CRTFCDOS
              WHERE CER_NMRO_PLZA = R_PLZAS.POL_NMRO_PLZA;
            

              BEGIN
                UPDATE PLZAS
                   SET POL_ESTADO_PLZA = 'A',
                       POL_FCHA_ESTDO = SYSDATE,
                       POL_USRIO = P_USUARIO
                 WHERE POL_NMRO_PLZA = R_PLZAS.POL_NMRO_PLZA;
              
                -- Interfaz Contable
                BEGIN
                  SELECT PAR_RFRNCIA
                    INTO V_ASIENTO
                    FROM PRMTROS
                   WHERE PAR_MDLO = '6'
                     AND PAR_CDGO = '9'
                     AND PAR_VLOR1 = '1'
                     AND PAR_SUC_CDGO	 = R_PLZAS.POL_SUC_CDGO
                     AND PAR_SUC_CIA_CDGO = R_PLZAS.POL_SUC_CIA_CDGO;
                
             
                  OPEN C_INTRFAZ_C(V_ASIENTO,R_PLZAS.POL_NMRO_CRTFCDO);
                  LOOP
                    FETCH C_INTRFAZ_C INTO R_INTERFAZ;
                    IF C_INTRFAZ_C%NOTFOUND THEN
                      EXIT;
                    END IF;
                   
                    BEGIN
                      INSERT INTO INTRFAZ_CNTBLE 
                        VALUES (R_INTERFAZ.INC_CMPNIA,R_INTERFAZ.INC_AGNCIA,R_INTERFAZ.INC_ASNTO,SYSDATE, 
                                R_INTERFAZ.INC_CNTA_CNTBLE,TO_CHAR(CRTFCDO),R_INTERFAZ.INC_RMO,
                                R_INTERFAZ.INC_BNFCRIO,R_INTERFAZ.INC_CMPRBNTE,R_INTERFAZ.INC_CNSCTVO,
                                R_INTERFAZ.INC_INFLCION,R_INTERFAZ.INC_BNCOS,R_INTERFAZ.INC_AGRPCION,
                                R_INTERFAZ.INC_CRDTO,R_INTERFAZ.INC_DBTO,R_INTERFAZ.INC_ORGEN,
                                R_INTERFAZ.INC_NIT_BNFCRIO,R_INTERFAZ.INC_ACTVDAD_BNFCRIO,R_INTERFAZ.INC_PRDCTOR,
                                SYSDATE,SYSDATE,R_INTERFAZ.INC_NMRO_CPON,R_INTERFAZ.INC_TPO_BNFCRIO);
                   
                    EXCEPTION
                      WHEN OTHERS THEN
                        P_MENSAJE := 'Error insertando en interfaz contable..'||R_INTERFAZ.INC_CNTA_CNTBLE||' '||SQLERRM;
                        RETURN;
                    END;
                  
                  END LOOP;
                  CLOSE C_INTRFAZ_C;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    P_MENSAJE := 'ERROR CONSULTANDO EL ASIENTO DE PRIMAS '||SQLERRM;
                    RETURN;
                END;
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := 'ERROR ACTUALIZANDO EL ESTADO DE LA POLIZA..'||SQLERRM;
                  RETURN;
              END;
            EXCEPTION
              WHEN OTHERS THEN
                P_MENSAJE := 'ERROR INSERTANDO EL CERTIFICADO DE ANULACION ..'||SQLERRM;
                RETURN;
            END;
          EXCEPTION
            WHEN OTHERS THEN
              P_MENSAJE := 'ERROR ACTUALIZANDO EL ESTADO DEL CERTIFICADO..'||SQLERRM;
              RETURN;
          END;
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := 'ERROR PRESENTADO EN SECUENCIA DE CERTIFICADOS  '||SQLERRM;
            RETURN;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := 'ERROR EN BORRAR RIESGOS..'||SQLERRM;
          RETURN;
      END;

    END LOOP;
    CLOSE C_PLZAS;

  END PRC_ANULA_PLZAS;


  --
  --
  --
  PROCEDURE PRC_LIQUIDACIONES_PENDIENTES IS

  CURSOR C_DATOS IS
    SELECT DISTINCT EST_PLZA,EST_NMRO_RCBO,EST_TPO_RCBO,EST_CIA_CDGO
      FROM ESTADO_CTA_RCBOS
     WHERE EST_NMRO_RCBO > 0
       AND EST_ESTDO_RCBO = 'T'
       AND EST_ORGEN_RCDO = 'P'
       AND EST_FCHA_MRA IS NULL
       AND TRUNC(EST_FCHA_MVTO) >= to_date('01/06/2015','dd/mm/yyyy')
       AND EXISTS (SELECT * FROM A5021113
                    WHERE NUM_LIQUIDACION = EST_NMRO_RCBO
                      AND DOCUMENTO IS NULL);


  R_DATOS      C_DATOS%ROWTYPE;
  VALOR        NUMBER;
  V_DEUDA      NUMBER;

  BEGIN
    OPEN C_DATOS;
    LOOP
      FETCH C_DATOS INTO R_DATOS;
      IF C_DATOS%NOTFOUND THEN
        EXIT;
      END IF;

      V_DEUDA := PKG_CONSULTA_OPERACION.FUN_DEUDA_POLIZA(R_DATOS.EST_PLZA);

      IF NVL(V_DEUDA,0) = 0 THEN
        BEGIN
          UPDATE RCBOS_CJA
             SET RCC_ESTDO_RCBO = 'A'
           WHERE RCC_NMRO_RCBO = R_DATOS.EST_NMRO_RCBO
             AND RCC_TPO_RCBO = R_DATOS.EST_TPO_RCBO
             AND RCC_CIA_CDGO = R_DATOS.EST_CIA_CDGO;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      ELSE
        BEGIN
          SELECT RCC_VLOR_RCBO
            INTO VALOR
            FROM RCBOS_CJA
           WHERE RCC_NMRO_RCBO = R_DATOS.EST_NMRO_RCBO
             AND RCC_TPO_RCBO = R_DATOS.EST_TPO_RCBO
             AND RCC_CIA_CDGO = R_DATOS.EST_CIA_CDGO;
        EXCEPTION
          WHEN OTHERS THEN
            VALOR := 0;
        END;

        IF NVL(VALOR,0) > 0 THEN
          IF NVL(V_DEUDA,0) < NVL(VALOR,0) THEN
            BEGIN
              UPDATE RCBOS_CJA
                 SET RCC_ESTDO_RCBO = 'A'
               WHERE RCC_NMRO_RCBO = R_DATOS.EST_NMRO_RCBO
                 AND RCC_TPO_RCBO = R_DATOS.EST_TPO_RCBO
                 AND RCC_CIA_CDGO = R_DATOS.EST_CIA_CDGO;
              COMMIT;
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
          END IF;
        END IF;
      END IF;

    END LOOP;
    CLOSE C_DATOS;

  END PRC_LIQUIDACIONES_PENDIENTES;
  
  --
  --
  --
  PROCEDURE PRC_VERIFICA_NOTA_NEGATIVA(P_RECIBO       NUMBER,
                                       P_TIPO         VARCHAR2,
                                       P_CIA          VARCHAR2,
                                       P_POLIZA       NUMBER) IS

                               
    CURSOR C_CRTFCDOS IS
      SELECT CER_NMRO_PLZA,CER_RAM_CDGO,CER_CLSE_PLZA,CER_NMRO_CRTFCDO,CER_FCHA_PRDCCION,
            (CER_VLOR_TTAL_CRTFCDO - 
             NVL((SELECT SUM(EST_VLOR_AFNZDO)
                    FROM ESTADO_CTA_RCBOS
                   WHERE EST_SLCTUD = CER_NMRO_CRTFCDO
                     AND EST_ESTDO_RCBO = 'I'
                     AND EST_NMRO_RCBO != P_RECIBO
                     AND EST_VLOR_AFNZDO > 0),0)) CER_VLOR_SLDO,
             CER_VLOR_TTAL_CRTFCDO
        FROM CRTFCDOS
       WHERE CER_NMRO_PLZA = P_POLIZA
         AND CER_VLOR_TTAL_CRTFCDO > 0
         AND EXISTS (SELECT * FROM ESTADO_CTA_RCBOS
                      WHERE EST_NMRO_RCBO = P_RECIBO
                        AND EST_TPO_RCBO = P_TIPO
                        AND EST_CIA_CDGO = P_CIA
                        AND CER_NMRO_CRTFCDO = EST_SLCTUD
                        AND CER_NMRO_PLZA = EST_PLZA)
    UNION
      SELECT CER_NMRO_PLZA,CER_RAM_CDGO,CER_CLSE_PLZA,CER_NMRO_CRTFCDO,CER_FCHA_PRDCCION,CER_VLOR_SLDO,CER_VLOR_TTAL_CRTFCDO
        FROM CRTFCDOS
       WHERE CER_NMRO_PLZA = P_POLIZA
         AND CER_ESTDO_PRDCCION IN ('20','30') 
         AND CER_VLOR_SLDO > 0
         AND CER_VLOR_TTAL_CRTFCDO > 0  
         AND NOT EXISTS (SELECT * FROM ESTADO_CTA_RCBOS
                          WHERE EST_NMRO_RCBO = P_RECIBO
                            AND EST_TPO_RCBO = P_TIPO
                            AND EST_CIA_CDGO = P_CIA
                            AND CER_NMRO_CRTFCDO = EST_SLCTUD
                            AND CER_NMRO_PLZA = EST_PLZA)     
     ORDER BY CER_FCHA_PRDCCION;

         
  R_CRTFCDOS   C_CRTFCDOS%ROWTYPE;
  N_RECIBO     NUMBER;
  --VALOR_NOTA   NUMBER;
  SALDO        NUMBER:=0;
  VR_DEUDA     NUMBER;
  VALOR        NUMBER;
  VR_SALDO_CERT NUMBER;
  V_VALOR      NUMBER;
  VALOR_RECIBO NUMBER;
  V_ESTADO     CRTFCDOS.CER_ESTDO_PRDCCION%TYPE;
  REFERENCIA   DTLLES_RCBOS_CJA.DRC_RFRNCIA%TYPE;

  BEGIN 
    BEGIN
      SELECT RCC_VLOR_RCBO
        INTO VALOR_RECIBO 
        FROM RCBOS_CJA
       WHERE RCC_NMRO_RCBO = P_RECIBO
         AND RCC_TPO_RCBO = P_TIPO
         AND RCC_CIA_CDGO = P_CIA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20504,'Error CONSULTANDO EL VALOR DEL RECIBO '||SQLERRM);
    END; 
    
    BEGIN
      UPDATE DTLLES_RCBOS_CJA
         SET DRC_VLOR_PGDO = 0
       WHERE DRC_NMRO_RCBO = P_RECIBO
         AND DRC_TPO_RCBO = P_TIPO
         AND DRC_CDGO_CIA = P_CIA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20504,'Error actualizando los valores de dtlles_rcbos_cja '||SQLERRM);
    END;  
    
    BEGIN
      UPDATE CNCPTOS_DTLLE_RCBOS
         SET CDR_VLOR = 0
       WHERE CDR_NMRO_RCBO = P_RECIBO
         AND CDR_TPO_RCBO = P_TIPO
         AND CDR_CDGO_CIA = P_CIA;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20504,'Error actualizando los valores de CNCPTOS_DTLLE_RCBOS '||SQLERRM);
    END;  
         
    SALDO := VALOR_RECIBO;
     
    OPEN C_CRTFCDOS;
      LOOP
        FETCH C_CRTFCDOS INTO R_CRTFCDOS;
        IF C_CRTFCDOS%NOTFOUND THEN
          EXIT;
        END IF;

        IF SALDO > 0 THEN          
          VR_DEUDA := R_CRTFCDOS.CER_VLOR_SLDO;  
          IF VR_DEUDA > 0 THEN
            REFERENCIA := RTRIM(R_CRTFCDOS.CER_RAM_CDGO || R_CRTFCDOS.CER_CLSE_PLZA ||RPAD(TO_CHAR(R_CRTFCDOS.CER_NMRO_PLZA), 10, ' ') ||RPAD(TO_CHAR(R_CRTFCDOS.CER_NMRO_CRTFCDO), 10, ' '),' ');
        
            IF SALDO >= VR_DEUDA THEN
              V_VALOR := VR_DEUDA;
            ELSE
              V_VALOR := SALDO;
            END IF;
          
            VALOR := ROUND(V_VALOR /(1 + (PKG_CONSULTA_OPERACION.FUN_PORCENTAJE_IVA/100)),0);  
            BEGIN
              INSERT INTO DTLLES_RCBOS_CJA
                VALUES(REFERENCIA,P_RECIBO,P_CIA,P_TIPO,'P','03','99',V_VALOR,USER,SYSDATE);
                      
              BEGIN  
                INSERT INTO CNCPTOS_DTLLE_RCBOS
                   VALUES(REFERENCIA,P_RECIBO,P_CIA,P_TIPO,'P','99','PRM','D',VALOR,USER,SYSDATE,NULL,NULL);   
                    
                BEGIN 
                  INSERT INTO CNCPTOS_DTLLE_RCBOS
                     VALUES(REFERENCIA,P_RECIBO,P_CIA,P_TIPO,'P','99','IVA','D',(V_VALOR - VALOR),USER,SYSDATE,NULL,NULL);  
                                     
                  IF VR_DEUDA <= SALDO THEN
                    V_ESTADO := '50';
                  ELSE
                    V_ESTADO := '30';
                  END IF; 
                    
                  BEGIN 
                    UPDATE CRTFCDOS
                       SET CER_ESTDO_PRDCCION = V_ESTADO,
                           CER_VLOR_SLDO = CER_VLOR_SLDO - V_VALOR
                     WHERE CER_NMRO_CRTFCDO = R_CRTFCDOS.CER_NMRO_CRTFCDO
                       AND CER_NMRO_PLZA = R_CRTFCDOS.CER_NMRO_PLZA;                                                           
                  EXCEPTION
                    WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20503,'Error actualizando el nuevo certificado '||SQLERRM);                    
                  END;
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN   
                    BEGIN
                      UPDATE CNCPTOS_DTLLE_RCBOS 
                         SET CDR_VLOR = CDR_VLOR + (V_VALOR - VALOR)
                       WHERE CDR_NMRO_RCBO = P_RECIBO
                         AND CDR_TPO_RCBO = P_TIPO
                         AND CDR_CDGO_CIA = P_CIA
                         AND CDR_RFRNCIA = REFERENCIA
                         AND CDR_CDGO_CNCPTO = 'IVA';
                    EXCEPTION
                      WHEN OTHERS THEN
                        RAISE_APPLICATION_ERROR(-20503,'Error actualizando el nuevo certificado '||SQLERRM);                    
                    END;
                  WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20503,'Error actualizando CNCPTOS_DTLLE_RCBOS - IVA '||SQLERRM);                    
                END;   
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN   
                  BEGIN   
                    UPDATE CNCPTOS_DTLLE_RCBOS 
                       SET CDR_VLOR = CDR_VLOR + VALOR
                     WHERE CDR_NMRO_RCBO = P_RECIBO
                       AND CDR_TPO_RCBO = P_TIPO
                       AND CDR_CDGO_CIA = P_CIA
                       AND CDR_RFRNCIA = REFERENCIA
                       AND CDR_CDGO_CNCPTO = 'PRM';
                  EXCEPTION
                    WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20504,'Error actualizando CNCPTOS_DTLLE_RCBOS - PRM '||SQLERRM);                    
                  END; 
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20504,'Error insertando CNCPTOS_DTLLE_RCBOS - PRM '||SQLERRM);                    
              END;  
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                BEGIN
                  UPDATE DTLLES_RCBOS_CJA
                     SET DRC_VLOR_PGDO = DRC_VLOR_PGDO + V_VALOR
                   WHERE DRC_NMRO_RCBO = P_RECIBO
                     AND DRC_TPO_RCBO = P_TIPO
                     AND DRC_CDGO_CIA = P_CIA
                     AND DRC_RFRNCIA = REFERENCIA;
                       
                  BEGIN
                    UPDATE CNCPTOS_DTLLE_RCBOS 
                       SET CDR_VLOR = CDR_VLOR + VALOR 
                     WHERE CDR_NMRO_RCBO = P_RECIBO
                       AND CDR_TPO_RCBO = P_TIPO
                       AND CDR_CDGO_CIA = P_CIA
                       AND CDR_RFRNCIA = REFERENCIA
                       AND CDR_CDGO_CNCPTO = 'PRM';
                  EXCEPTION
                    WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20503,'Error actualizando CNCPTOS_DTLLE_RCBOS - PRM '||SQLERRM);                    
                  END;
                      
                  BEGIN
                    UPDATE CNCPTOS_DTLLE_RCBOS 
                       SET CDR_VLOR = CDR_VLOR + (V_VALOR - VALOR)
                     WHERE CDR_NMRO_RCBO = P_RECIBO
                       AND CDR_TPO_RCBO = P_TIPO
                       AND CDR_CDGO_CIA = P_CIA
                       AND CDR_RFRNCIA = REFERENCIA
                       AND CDR_CDGO_CNCPTO = 'IVA';
                  EXCEPTION
                    WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20503,'Error actualizando CNCPTOS_DTLLE_RCBOS - IVA'||SQLERRM);                    
                  END;
                                      
                  IF VR_DEUDA <= SALDO THEN
                    V_ESTADO := '50';
                  ELSE
                    V_ESTADO := '30';
                  END IF; 
                    
                  BEGIN 
                    UPDATE CRTFCDOS
                       SET CER_ESTDO_PRDCCION = V_ESTADO,
                           CER_VLOR_SLDO = CER_VLOR_SLDO - V_VALOR
                     WHERE CER_NMRO_CRTFCDO = R_CRTFCDOS.CER_NMRO_CRTFCDO
                       AND CER_NMRO_PLZA = R_CRTFCDOS.CER_NMRO_PLZA;
                  EXCEPTION
                    WHEN OTHERS THEN
                      RAISE_APPLICATION_ERROR(-20517,'Error actualizando  el saldo del certificado '||SQLERRM);      
                  END;
                EXCEPTION
                  WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20518,'Error actualizando  el detalle del recibo '||SQLERRM);      
                END;
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20505,'Error insertanto el detalle del recibo '||SQLERRM);                    
            END;        
      
            BEGIN 
              SELECT CER_VLOR_SLDO
                INTO VR_SALDO_CERT
                FROM CRTFCDOS
               WHERE CER_NMRO_CRTFCDO = R_CRTFCDOS.CER_NMRO_CRTFCDO
                 AND CER_NMRO_PLZA = R_CRTFCDOS.CER_NMRO_PLZA;                                                           
        
              IF NVL(VR_SALDO_CERT,0) < 0 THEN
                BEGIN 
                  UPDATE CRTFCDOS
                     SET CER_ESTDO_PRDCCION = '50',
                         CER_VLOR_SLDO = 0
                   WHERE CER_NMRO_CRTFCDO = R_CRTFCDOS.CER_NMRO_CRTFCDO
                     AND CER_NMRO_PLZA = R_CRTFCDOS.CER_NMRO_PLZA;
                EXCEPTION
                  WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20517,'Error actualizando  el saldo del certificado '||SQLERRM);      
                END;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20503,'Error actualizando el nuevo certificado '||SQLERRM);                    
            END;       
        
            BEGIN 
              SELECT EST_NMRO_RCBO
                INTO N_RECIBO
                FROM ESTADO_CTA_RCBOS
               WHERE EST_SLCTUD = R_CRTFCDOS.CER_NMRO_CRTFCDO
                 AND EST_VLOR_AFNZDO NOT BETWEEN -1000 AND 1000
                 AND EST_ESTDO_RCBO = 'I'
                 AND EST_TPO_RCBO = 'N'
                 AND EST_ORGEN_RCDO = 'P'
                 AND EST_VLOR_AFNZDO < 0
              GROUP BY EST_NMRO_RCBO;
            EXCEPTION
              WHEN  OTHERS THEN
                 N_RECIBO  := 0;
            END;
      
            IF N_RECIBO != 0 THEN
              BEGIN     
                UPDATE RCBOS_CJA
                   SET RCC_ESTDO_RCBO = 'V'
                 WHERE RCC_NMRO_RCBO = N_RECIBO;
         
                BEGIN
                  DELETE INTRFAZ_CNTBLE 
                   WHERE INC_DCMNTO = TO_CHAR(N_RECIBO);
                EXCEPTION
                  WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20516,'Error borrando contabilidad de la nota '||SQLERRM);                    
                END;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20515,'Error actualizando el estado de la nota '||SQLERRM);                    
              END;  
            END IF;
          
            SALDO := SALDO - VR_DEUDA;
          ELSE
            BEGIN 
              SELECT EST_NMRO_RCBO
                INTO N_RECIBO
                FROM ESTADO_CTA_RCBOS
               WHERE EST_SLCTUD = R_CRTFCDOS.CER_NMRO_CRTFCDO
                 AND EST_VLOR_AFNZDO NOT BETWEEN -1000 AND 1000
                 AND EST_ESTDO_RCBO = 'I'
                 AND EST_TPO_RCBO = 'N'
                 AND EST_ORGEN_RCDO = 'P'
                 AND EST_VLOR_AFNZDO < 0
              GROUP BY EST_NMRO_RCBO;
            EXCEPTION
              WHEN  OTHERS THEN
                 N_RECIBO  := 0;
            END;
      
            IF N_RECIBO != 0 THEN
              BEGIN     
                UPDATE RCBOS_CJA
                   SET RCC_ESTDO_RCBO = 'V'
                 WHERE RCC_NMRO_RCBO = N_RECIBO;
         
                BEGIN
                  DELETE INTRFAZ_CNTBLE 
                   WHERE INC_DCMNTO = TO_CHAR(N_RECIBO);
                EXCEPTION
                  WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20516,'Error borrando contabilidad de la nota '||SQLERRM);                    
                END;
              EXCEPTION
                WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20515,'Error actualizando el estado de la nota '||SQLERRM);                    
              END;  
            END IF;
          END IF;
        ELSE
          EXIT;
        END IF;  

      END LOOP;
      CLOSE C_CRTFCDOS;
          
  END PRC_VERIFICA_NOTA_NEGATIVA;

  --
  --
  --
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
                                P_MENSAJE      OUT VARCHAR2) IS
                                
  CURSOR C_CRTFCDOS IS
    SELECT EST_SLCTUD, SUM(EST_VLOR_AFNZDO) VALOR
      FROM ESTADO_CTA_RCBOS
     WHERE EST_NMRO_RCBO = P_RECIBO
       AND EST_TPO_RCBO = P_TIPO
       AND EST_CIA_CDGO = P_CIA
    GROUP BY EST_SLCTUD;                                

  R_CRTFCDOS       C_CRTFCDOS%ROWTYPE; 
  VR_SALDO_CERT    NUMBER;                            
  V_NUMERO_RECIBO  NUMBER;
  VALOR_AJUSTE     NUMBER;
  P_SUCURSAL_PAGO  NUMBER;
  VALOR_PAGOS      NUMBER;
  VALOR_PROCESAR   NUMBER;


  BEGIN 
    IF NVL(P_DEUDA,0) < P_VALOR_RECIBO THEN
      VALOR_PROCESAR := P_DEUDA;
    ELSE
      VALOR_PROCESAR := P_VALOR_RECIBO;
    END IF;
    P_VR_INTERFAZ    := VALOR_PROCESAR;
    -- SE ANULA EL RECIBO PARA QUE NO TOME EL VALOR DEL RECIBO ACTUAL
    BEGIN
      UPDATE RCBOS_CJA
         SET RCC_ESTDO_RCBO = 'A'
       WHERE RCC_NMRO_RCBO = P_RECIBO
         AND RCC_TPO_RCBO = P_TIPO
         AND RCC_CIA_CDGO = P_CIA;
    EXCEPTION
      WHEN OTHERS THEN
        P_MENSAJE := 'Error actualizando el estado en RCBOS_CJA '||SQLERRM;
        RETURN;
    END; 
      
    -- SE GENERA UNA LIQUIDACION NUEVA CON EL PROCESO AUTOMATICO CON EL VALOR DE LA DEUDA
    -- PARA PODER ACTUALIZAR EL OTRO RECIBO Y LA CONTABILIDAD CON LOS VALORES CORRECTOS    
    PKG_LIQUIDACIONES_RECAUDOS.PRC_LIQUIDADOR_PRIMAS(P_POLIZA,'12','00',
                                                     VALOR_PROCESAR,
                                                     USER,
                                                     P_SUCURSAL,
                                                     P_DIV_CODIGO,
                                                     P_CIA,
                                                     P_NMRO_ID,
                                                     P_TIPO_ID,
                                                     VALOR_AJUSTE,
                                                     V_NUMERO_RECIBO);
     
    IF V_NUMERO_RECIBO != 0 THEN
      BEGIN
        DELETE CNCPTOS_DTLLE_RCBOS
         WHERE CDR_NMRO_RCBO = P_RECIBO
           AND CDR_TPO_RCBO = P_TIPO
           AND CDR_CDGO_CIA = P_CIA;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := 'Error actualizando los valores de CNCPTOS_DTLLE_RCBOS '||SQLERRM;
          RETURN;
      END;     
        
      BEGIN
        DELETE DTLLES_RCBOS_CJA
         WHERE DRC_NMRO_RCBO = P_RECIBO
           AND DRC_TPO_RCBO = P_TIPO
           AND DRC_CDGO_CIA = P_CIA;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := 'Error actualizando en dtlles_rcbos_cja '||SQLERRM;
          RETURN;
      END; 
        
      BEGIN
        INSERT INTO DTLLES_RCBOS_CJA
          SELECT DRC_RFRNCIA,
                 P_RECIBO,
                 DRC_CDGO_CIA,
                 DRC_TPO_RCBO,
                 DRC_ORGEN_RCDO,
                 DRC_TPO_RFRNCIA,
                 DRC_CDGO_RCDO,
                 DRC_VLOR_PGDO,
                 DRC_USRIO,
                 DRC_FCHA_MDFCCION
            FROM DTLLES_RCBOS_CJA
           WHERE DRC_NMRO_RCBO = V_NUMERO_RECIBO;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := 'Error insertando en dtlles_rcbos_cja '||SQLERRM;
          RETURN;
      END;    
        
      BEGIN  
        INSERT INTO CNCPTOS_DTLLE_RCBOS 
          SELECT CDR_RFRNCIA,
                 P_RECIBO,
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
           WHERE CDR_NMRO_RCBO = V_NUMERO_RECIBO;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := 'Error insertando en dtlles_rcbos_cja '||SQLERRM;
          RETURN;
      END; 
            
      -- SE ACTUALIZA EL ESTADO DEL CERTIFICADO
      OPEN C_CRTFCDOS;
      LOOP
        FETCH C_CRTFCDOS INTO R_CRTFCDOS;
        IF C_CRTFCDOS%NOTFOUND THEN
          EXIT;
        END IF;
          
        SELECT NVL(SUM(EST_VLOR_AFNZDO),0) 
          INTO VALOR_PAGOS
          FROM ESTADO_CTA_RCBOS
         WHERE EST_SLCTUD = R_CRTFCDOS.EST_SLCTUD
           AND EST_ESTDO_RCBO = 'I';
            
        UPDATE CRTFCDOS
           SET CER_VLOR_SLDO = CER_VLOR_TTAL_CRTFCDO - NVL(VALOR_PAGOS,0)
         WHERE CER_NMRO_CRTFCDO = R_CRTFCDOS.EST_SLCTUD
           AND CER_NMRO_PLZA = P_POLIZA;
             
         BEGIN 
           SELECT CER_VLOR_SLDO
             INTO VR_SALDO_CERT
             FROM CRTFCDOS
            WHERE CER_NMRO_CRTFCDO = R_CRTFCDOS.EST_SLCTUD
              AND CER_NMRO_PLZA = P_POLIZA;                                                           
        
            IF NVL(VR_SALDO_CERT,0) <= 0 THEN
              BEGIN 
                UPDATE CRTFCDOS
                   SET CER_ESTDO_PRDCCION = '50',
                       CER_VLOR_SLDO = 0
                 WHERE CER_NMRO_CRTFCDO = R_CRTFCDOS.EST_SLCTUD
                   AND CER_NMRO_PLZA = P_POLIZA;
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := 'Error actualizando  el saldo del certificado '||SQLERRM;  
                  RETURN;    
              END;
            ELSE
              BEGIN 
                UPDATE CRTFCDOS
                   SET CER_ESTDO_PRDCCION = '30'
                 WHERE CER_NMRO_CRTFCDO = R_CRTFCDOS.EST_SLCTUD
                   AND CER_NMRO_PLZA = P_POLIZA;
              EXCEPTION
                WHEN OTHERS THEN
                  P_MENSAJE := 'Error actualizando  el saldo del certificado '||SQLERRM;  
                  RETURN;    
              END;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              P_MENSAJE := 'Error actualizando el nuevo certificado '||SQLERRM;   
              RETURN;                 
          END;        
                              
      END LOOP;            
      CLOSE C_CRTFCDOS; 
        
      -- SE DEJA NUEVAMENTE EL RECIBO DEL PARAMETRO EN 'I'
      BEGIN
        UPDATE RCBOS_CJA
           SET RCC_ESTDO_RCBO = 'I',
               RCC_VLOR_RCBO = VALOR_PROCESAR
         WHERE RCC_NMRO_RCBO = P_RECIBO
           AND RCC_TPO_RCBO = P_TIPO
           AND RCC_CIA_CDGO = P_CIA;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := '2.Error actualizando RCBOS_CJA '||SQLERRM;
          RETURN;
      END; 
      -- SE ANULA EL RECIBO TEMPORAL 
      BEGIN
        UPDATE RCBOS_CJA
           SET RCC_ESTDO_RCBO = 'A'
         WHERE RCC_NMRO_RCBO = V_NUMERO_RECIBO;
      EXCEPTION
        WHEN OTHERS THEN
          P_MENSAJE := '3.Error actualizando RCBOS_CJA '||SQLERRM;
          RETURN;
      END;
                       
      IF P_DIFERENCIA > 0 THEN
        --SE GENERA ORDEN DE PAGO POR LA DIFERENCIA
        BEGIN
          PKG_OPERACION.PRC_GENERA_ORDEN_PAGO(P_POLIZA,'00','12',
                                              P_CIA,
                                              P_SUCURSAL,
                                              P_TIPO_ID,
                                              P_NMRO_ID,
                                              P_SUCURSAL_PAGO,
                                              SYSDATE,
                                              P_USUARIO,
                                              P_DIFERENCIA,
                                              'D',
                                              P_RECIBO);                                              
        EXCEPTION
          WHEN OTHERS THEN
            P_MENSAJE := '1.Error en PRC_GENERA_ORDEN_PAGO..'||SQLERRM;
            RETURN;
        END;
      END IF;
    END IF;             
    
  END PRC_CERT_PENDIENTES;
  
  
END PKG_OPERACION;
/
