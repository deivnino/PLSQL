Create Or Replace Package Body ADMSISA.Pkg_Interfaces_Operaciones As
  --funciones
  
  /*Nombre:           F_VALIDA_DESISTIDOS
  Autor:            jgallo(asw)
  Fecha_creacion:   20-10-2017
  fecha_mod:        20-10-2017
  proposito:        Valido si el siniestro ya fue reportado para la fecha ingresada
  */
  Function F_VALIDA_DESISTIDOS(P_NUMERO_SOLICITUD NUMBER, P_FECHA_MORA DATE) Return VARCHAR2
  As 
  v_estado_desistido varchar2(2) := '04'; --estado desistido
  V_RESPUESTA VARCHAR2(1) := 'S';
  E_VALIDA    Exception;
  v_periodo varchar2(8);
  V_FECHA_MORA DATE;
  V_FECHA_PAGO DATE;
  V_POLIZA NUMBER(10);
  V_CLASE VARCHAR2(2) := '00';
  V_RAMO VARCHAR(2) := '12';
  V_PERIODO_FUN VARCHAR2(10);
  Cursor DESISTIDOS_CURSOR Is --Cursor que almacena las fechas de siniestro desistidas de la solicitud
    Select Distinct(sna_fcha_snstro) fecha
    From Avsos_Snstros A, Lqdcnes_Dtlle_Img l
    Where A.sna_nmro_item = p_numero_solicitud
    And sna_estdo_snstro = v_estado_desistido
    And lqt_nmro_snstro = sna_nmro_snstro;
  
  Begin    
    V_FECHA_MORA := P_FECHA_MORA;
    Begin
      Select Distinct(SES_NMRO_PLZA)
      Into V_POLIZA
      From Slctdes_Estdios
      Where SES_NMRO = P_NUMERO_SOLICITUD;
    End;
    V_FECHA_PAGO := Pkg_Siniestros.FUN_FCHA_PAGO(V_POLIZA,
                         V_CLASE,
                         V_RAMO,
                         V_PERIODO_FUN);
      While(To_Date(To_Char(V_FECHA_MORA,'MM/YY'),'MM/YY') <= To_Date(To_Char(V_FECHA_PAGO,'MM/YY'),'MM/YY')) Loop
      For DESISTIDOS_RECORD In DESISTIDOS_CURSOR Loop -- Recorre todos los siniestros desistidos de la solicitud
            DBMS_OUTPUT.PUT_LINE(V_FECHA_MORA);
      v_periodo := Extract(Month From V_FECHA_MORA)||Extract(Year From V_FECHA_MORA);
          If(Extract(Month From DESISTIDOS_RECORD.FECHA)||Extract(Year From DESISTIDOS_RECORD.FECHA)=V_PERIODO) Then
            V_RESPUESTA := 'N';
            Raise E_VALIDA;
          End If;
        End Loop;
        V_FECHA_MORA := Add_Months(V_FECHA_MORA,1);
      End Loop;  
      Return V_RESPUESTA;
      Exception 
        When E_VALIDA Then
          Return V_RESPUESTA;
        When Others Then
           Raise_Application_Error(-20102, 'Error validando desistidos: '||Sqlerrm);
      
  End F_VALIDA_DESISTIDOS;

    /*
      Nombre:           prc_registra_ingreso_sai
      Autor:            jgallo(asw)
      Fecha_creacion:   14-09-2017
      fecha_mod:        14-09-2017
      proposito:        procedimiento que registra ingreso de sai.                         
    */
      Procedure prc_registra_ingreso_sai ( pi_ty_datos_ingreso In ty_datos_ingreso, pi_tb_conceptos In ty_tb_conceptos, PI_TA_EXCEPCIONES In TA_EXCEPCIONES,  po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 ) As
    SES_NMRO_PLZA       Slctdes_Estdios.SES_NMRO_PLZA%Type;
        COD_DSTNO_INMBLE    Slctdes_Estdios.SES_DSTNO_INMBLE%Type;
        DSTNO_INMBLE        Cg_Ref_Codes.RV_MEANING%Type;
        COD_TPO_INMBLE      Slctdes_Estdios.SES_TPO_INMBLE%Type;
        TPO_INMBLE          Cg_Ref_Codes.RV_MEANING%Type;
        NMRO_IDENINQUILINO  Arrndtrios.ARR_NMRO_IDNTFCCION%Type;
        TIPO_IDENINQUILINO  Arrndtrios.ARR_TPO_IDNTFCCION%Type;
        DIR_DIRECCION       Direcciones.DI_DIRECCION%Type;
        DIR_ESTRTO          Direcciones.DI_ESTRTO%Type;
        DI_DIVPOL_CODIGO    Direcciones.DI_DIVPOL_CODIGO%Type;
        DSP_CIU_NMBRE       V_DIVISION_POLITICAS.NOM_CIU%Type;
        V_NOMBRE_POLIZA     VARCHAR2(200);
        V_ESTADO_POLIZA     Plzas.POL_ESTADO_PLZA%Type;
        V_ASISTENCIA        Plzas.POL_ASSTNCIA%Type;
        V_TIPO_POLIZA       Plzas.POL_TPOPLZA%Type;
        V_TIPO_RIESGO       Plzas.POL_TPORSGO%Type;
        V_SUCURSAL          Plzas.POL_SUC_CDGO%Type;
        SUCURSAL            Plzas.POL_SUC_CDGO%Type;
        INQUILINO           VARCHAR2(200);
        MENSAJE             VARCHAR2(200);
        FECHA_CONTRATO      DATE;
        TIPO_AUMENTO        VARCHAR2(10);
        MONTO_AUMENTO       NUMBER;
        IVA_COMERCIAL       VARCHAR2(50);  
    V_NOVEDADES         VARCHAR2(2);
    V_APR_TPO_AMPRO     Ampros_Prdcto.APR_TPO_AMPRO%Type;
    V_APR_LMTCION_TPO   Ampros_Prdcto.APR_LMTCION_TPO%Type;--
    V_ENTRO             NUMBER(2);
    
    V_TIPO_AUMENTO      Datos_Contratos.TIPO_AUMENTO_CANON%Type:=Null;
    V_MONTO_AUMENTO     Datos_Contratos.MONTO_AUMENTO_CANON%Type:=Null;
    V_FECHA_CONTRATO    date:= pi_ty_datos_ingreso.FECHA_CONTRATO;
    V_PORCENTAJE_IVA    NUMBER(4,2):= pi_ty_datos_ingreso.AMPAROB_PORCENTAJE_IVA;
    V_METRAJE_HOGAR     Direcciones.DI_AREA%Type;
    V_MENSAJE             VARCHAR2(200);
    V_TTAL_ASGRDO         NUMBER:=0;
    V_EXISTE_IVA            VARCHAR2(2);
    Po_ty_solicitud ty_datos_solicitud;
    V_TA_EXCEPCIONES TA_EXCEPCIONES := PI_TA_EXCEPCIONES;
    
    v_amparo_valido number(1):=0;
    e_NEGOCIO            Exception;
Begin
  V_NOVEDADES := '01'; --01 para ingresos
  V_TIPO_AUMENTO := pi_ty_datos_ingreso.TIPO_AUMENTO;
  V_MONTO_AUMENTO := pi_ty_datos_ingreso.MONTO_AUMENTO;
  V_FECHA_CONTRATO := pi_ty_datos_ingreso.FECHA_CONTRATO;
  V_EXISTE_IVA := pi_ty_datos_ingreso.AMPAROB_EXISTE_IVA;
  V_METRAJE_HOGAR := pi_ty_datos_ingreso.AMPAROS_HOGAR_METRAJE;
  
   If(V_TA_EXCEPCIONES Is Null) Then
      V_TA_EXCEPCIONES := TA_EXCEPCIONES();
    End If;
    
  --CONSULTA DE DATOS BÁSICOS
  Begin
    Pkg_Interfaces_Consultas.Prc_cons_datos_basicos_sai (pi_ty_datos_ingreso.NUMERO_SOLICITUD, 
                                         pi_ty_datos_ingreso.NIT_INMOBILIARIA, 
                                         Po_ty_solicitud,
                                         po_Codigo,
                                         po_Mensaje);
      If(PO_CODIGO != 0) Then
        Raise E_NEGOCIO;
      End If;
    End;
 --CONSULTA DE DATOS DE SOLICITUD                            
        PRC_DATOS_SOLICITUD( pi_ty_datos_ingreso.NUMERO_SOLICITUD,
                            pi_ty_datos_ingreso.NIT_INMOBILIARIA  ,
                            SES_NMRO_PLZA     ,
                            COD_DSTNO_INMBLE  ,
                            DSTNO_INMBLE      ,
                            COD_TPO_INMBLE    ,
                            TPO_INMBLE        ,
                            NMRO_IDENINQUILINO,
                            TIPO_IDENINQUILINO,
                            DIR_DIRECCION     ,
                            DIR_ESTRTO        ,
                            DI_DIVPOL_CODIGO  ,
                            DSP_CIU_NMBRE     ,
                            V_NOMBRE_POLIZA   ,
                            V_ESTADO_POLIZA   ,
                            V_ASISTENCIA      ,
                            V_TIPO_POLIZA     ,
                            V_TIPO_RIESGO     ,
                            V_SUCURSAL        ,
                            SUCURSAL          ,
                            INQUILINO         ,
                            MENSAJE           ,
                            FECHA_CONTRATO    ,
                            TIPO_AUMENTO      ,
                            MONTO_AUMENTO     ,
                            IVA_COMERCIAL     );
 
   
  For i In 1..pi_tb_conceptos.Last Loop
  --VALIDACIÓN DE AMPARO (Valida si el amparo está en los criterios de ingreso)
    Select Count(AP.APR_CDGO_AMPRO) 
    Into v_amparo_valido
    From Ampros_Prdcto ap
    Where Exists (Select * From Trfa_Ampros_Prdcto tr
                  Where AP.apr_Cdgo_Ampro = TR.tap_Cdgo_Ampro
                  And AP.apr_Ram_Cdgo = TR.tap_Ram_Cdgo
                  And TR.tap_Ingrso_Web = 'S'
                  And TR.tap_Tpo_Plza = 'C') 
    And apr_cdgo_ampro = pi_tb_conceptos(i).cod_amparo;
    
    If(v_amparo_valido = 0) Then
      PO_CODIGO:=-90;
      PO_MENSAJE:='El código de amparo ingresado es incorrecto'; 
      Raise e_negocio;
    End If;
  
  -- CONSULTA DE VALOR ASEGURADO O ESTUDIO
   For r In 1..Po_ty_solicitud.amparos.Count
    Loop   
      If(Po_ty_solicitud.amparos(r).cod_concept = pi_tb_conceptos(i).cod_concepto) Then
        V_TTAL_ASGRDO := Po_ty_solicitud.amparos(r).vlr_aseg; 
      End If;
    End Loop;
  -- CONSULTA DE TIPO DE AMPARO Y LIMITACIÓN

    Select apr_lmtcion_tpo, apr_tpo_ampro, 
      Case 
        When APR_CDGO_AMPRO = '01' And pi_tb_conceptos(i).cod_concepto = '01' Then 0 
        When APR_CDGO_AMPRO = '01' And pi_tb_conceptos(i).cod_concepto = '02' Then 1
        Else Null End
    Into V_APR_LMTCION_TPO ,V_APR_TPO_AMPRO, V_ENTRO
    From Ampros_Prdcto 
    Where apr_cdgo_ampro = pi_tb_conceptos(i).cod_amparo;
  --Ejecución de procedimiento de almacenamiento de novedades
    Pkg_Novedades_Web_Java.PRC_GUARDAR_NOVEDAD_SEG_ARREN(V_NOVEDADES,
                                                       V_ESTADO_POLIZA,
                                                       pi_ty_datos_ingreso.NUMERO_SOLICITUD,
                                                       TIPO_IDENINQUILINO,
                                                       NMRO_IDENINQUILINO,
                                                       pi_tb_conceptos(i).cod_amparo,
                                                       pi_ty_datos_ingreso.fecha_ingreso,
                                                       --pi_tb_conceptos(i).NUEVO_VALOR,
                                                       pi_tb_conceptos(i).VALOR_ESTUDIO,
                                                       pi_tb_conceptos(i).NUEVO_VALOR,
                                                       V_APR_LMTCION_TPO,
                                                       SES_NMRO_PLZA,
                                                       V_APR_TPO_AMPRO,
                                                       pi_tb_conceptos(i).cod_concepto,
                                                       DIR_DIRECCION,
                                                       DI_DIVPOL_CODIGO,
                                                       pi_ty_datos_ingreso.ESTRATO,
                                                       COD_TPO_INMBLE ,
                                                       COD_DSTNO_INMBLE,
                                                       V_ASISTENCIA,
                                                       V_TTAL_ASGRDO, 
                                                       V_TTAL_ASGRDO, 
                                                       pi_ty_datos_ingreso.FECHA_INGRESO, 
                                                       pi_ty_datos_ingreso.NIT_INMOBILIARIA,
                                                       V_ENTRO,
                                                       V_FECHA_CONTRATO, 
                                                       V_TIPO_AUMENTO,
                                                       V_MONTO_AUMENTO,
                                                       V_EXISTE_IVA,
                                                       V_METRAJE_HOGAR,
                                                       V_TA_EXCEPCIONES);
  End Loop;      
  
  PO_CODIGO:=0;
  PO_MENSAJE :='Registro exitoso';
  Exception
     When E_negocio Then
         PO_MENSAJE :='ERROR DE NEGOCIO: '||PO_MENSAJE;
         pO_codigo:=PO_CODIGO;
     When Others Then
         PO_MENSAJE :=Sqlerrm;
         pO_codigo:=Sqlcode;
    
  End prc_registra_ingreso_sai;

  /*
      Nombre:           prc_registra_aumento
      Autor:            jgallo(asw)
      Fecha_creacion:   03-10-2017
      fecha_mod:        03-10-2017
      proposito:        procedimiento  que registra aumento de los valores asegurados.                         
    */
 Procedure prc_registra_aumento ( pi_datos_aumento In ty_datos_aumento, pi_tb_conceptos In ty_tb_conceptos, PI_TA_EXCEPCIONES In TA_EXCEPCIONES,  po_Codigo    Out     VARCHAR2 ,
                                  po_Mensaje   Out     VARCHAR2 ) As  
   SES_NMRO_PLZA       Slctdes_Estdios.SES_NMRO_PLZA%Type;
        COD_DSTNO_INMBLE    Slctdes_Estdios.SES_DSTNO_INMBLE%Type;
        DSTNO_INMBLE        Cg_Ref_Codes.RV_MEANING%Type;
        COD_TPO_INMBLE      Slctdes_Estdios.SES_TPO_INMBLE%Type;
        TPO_INMBLE          Cg_Ref_Codes.RV_MEANING%Type;
        NMRO_IDENINQUILINO  Arrndtrios.ARR_NMRO_IDNTFCCION%Type;
        TIPO_IDENINQUILINO  Arrndtrios.ARR_TPO_IDNTFCCION%Type;
        DIR_DIRECCION       Direcciones.DI_DIRECCION%Type;
        DIR_ESTRTO          Direcciones.DI_ESTRTO%Type;
        DI_DIVPOL_CODIGO    Direcciones.DI_DIVPOL_CODIGO%Type;
        DSP_CIU_NMBRE       V_DIVISION_POLITICAS.NOM_CIU%Type;
        V_NOMBRE_POLIZA     VARCHAR2(200);
        V_ESTADO_POLIZA     Plzas.POL_ESTADO_PLZA%Type;
        V_ASISTENCIA        Plzas.POL_ASSTNCIA%Type;
        V_TIPO_POLIZA       Plzas.POL_TPOPLZA%Type;
        V_TIPO_RIESGO       Plzas.POL_TPORSGO%Type;
        V_SUCURSAL          Plzas.POL_SUC_CDGO%Type;
        SUCURSAL            Plzas.POL_SUC_CDGO%Type;
        INQUILINO           VARCHAR2(200);
        MENSAJE             VARCHAR2(200);
        FECHA_CONTRATO      DATE;
        TIPO_AUMENTO        VARCHAR2(10);
        MONTO_AUMENTO       NUMBER;
        IVA_COMERCIAL       VARCHAR2(50);  
        
    V_NOVEDADES         VARCHAR2(2);
    V_APR_TPO_AMPRO     Ampros_Prdcto.APR_TPO_AMPRO%Type;
    V_APR_LMTCION_TPO   Ampros_Prdcto.APR_LMTCION_TPO%Type;--
    V_ENTRO             NUMBER(2);
    
    V_TIPO_AUMENTO      Datos_Contratos.TIPO_AUMENTO_CANON%Type:=Null;
    V_MONTO_AUMENTO     Datos_Contratos.MONTO_AUMENTO_CANON%Type:=Null;
    V_FECHA_CONTRATO    date;
    V_PORCENTAJE_IVA    NUMBER(4,2);
    V_METRAJE_HOGAR     Direcciones.DI_AREA%Type;
       V_EXISTE_IVA            VARCHAR2(2);
     
     V_TA_EXCEPCIONES TA_EXCEPCIONES := PI_TA_EXCEPCIONES;
       Po_ty_solicitud ty_datos_solicitud;
     
         V_MENSAJE             VARCHAR2(200);
     V_TTAL_ASGRDO         NUMBER:=0;
     
      v_amparo_valido number(1):=0;
    e_NEGOCIO            Exception;
  Begin
    V_NOVEDADES := '04'; --04 para AUMENTOS
    
    If(V_TA_EXCEPCIONES Is Null) Then
      V_TA_EXCEPCIONES := TA_EXCEPCIONES();
    End If;
  
        PRC_DATOS_SOLICITUD(PI_DATOS_AUMENTO.NUMERO_SOLICITUD,
                            PI_DATOS_AUMENTO.NIT_INMOBILIARIA  ,
                            SES_NMRO_PLZA     ,
                            COD_DSTNO_INMBLE  ,
                            DSTNO_INMBLE      ,
                            COD_TPO_INMBLE    ,
                            TPO_INMBLE        ,
                            NMRO_IDENINQUILINO,
                            TIPO_IDENINQUILINO,
                            DIR_DIRECCION     ,
                            DIR_ESTRTO        ,
                            DI_DIVPOL_CODIGO  ,
                            DSP_CIU_NMBRE     ,
                            V_NOMBRE_POLIZA   ,
                            V_ESTADO_POLIZA   ,
                            V_ASISTENCIA      ,
                            V_TIPO_POLIZA     ,
                            V_TIPO_RIESGO     ,
                            V_SUCURSAL        ,
                            SUCURSAL          ,
                            INQUILINO         ,
                            MENSAJE           ,
                            FECHA_CONTRATO    ,
                            TIPO_AUMENTO      ,
                            MONTO_AUMENTO     ,
                            IVA_COMERCIAL     );
  V_FECHA_CONTRATO := FECHA_CONTRATO;
   
     --CONSULTA DE DATOS BÁSICOS
  Begin
      Pkg_Interfaces_Consultas.Prc_cons_datos_basicos_sai (pi_datos_aumento.NUMERO_SOLICITUD, 
                                         pi_datos_aumento.NIT_INMOBILIARIA, 
                                         Po_ty_solicitud,
                                         po_Codigo,
                                         po_Mensaje);
      If(PO_CODIGO != 0) Then
          Raise E_NEGOCIO;
          End If;
      End;
   
  For i In 1..pi_tb_conceptos.Last Loop
    --VALIDACIÓN DE AMPARO (Valida si el amparo está en los criterios de ingreso)
    Select Count(AP.APR_CDGO_AMPRO) 
    Into v_amparo_valido
    From Ampros_Prdcto ap
    Where Exists (Select * From Trfa_Ampros_Prdcto tr
                  Where AP.apr_Cdgo_Ampro = TR.tap_Cdgo_Ampro
                  And AP.apr_Ram_Cdgo = TR.tap_Ram_Cdgo
                  And TR.tap_Ingrso_Web = 'S'
                  And TR.tap_Tpo_Plza = 'C') 
    And apr_cdgo_ampro = pi_tb_conceptos(i).cod_amparo;
    
    If(v_amparo_valido = 0) Then
      PO_CODIGO:=-90;
      PO_MENSAJE:='El código de amparo ingresado es incorrecto'; 
      Raise e_negocio;
    End If;
  
  -- CONSULTA DE VALOR ASEGURADO O ESTUDIO
  If(pi_tb_conceptos(i).cod_amparo = '01') Then -- si es amparo básico suma los conceptos de canon y arrendamiento
    V_TTAL_ASGRDO := 0;
    
     For r In 1..Po_ty_solicitud.amparos.Count
    Loop   
      If(Po_ty_solicitud.amparos(r).cod_concept = '01' Or Po_ty_solicitud.amparos(r).cod_concept='02') Then
        V_TTAL_ASGRDO := V_TTAL_ASGRDO + Po_ty_solicitud.amparos(r).vlr_aseg; 
      End If;
    End Loop; 
  Else
   For r In 1..Po_ty_solicitud.amparos.Count
    Loop   
      If(Po_ty_solicitud.amparos(r).cod_concept = pi_tb_conceptos(i).cod_concepto) Then
        V_TTAL_ASGRDO := Po_ty_solicitud.amparos(r).vlr_aseg; 
      End If;
    End Loop;
  End If;
    
    
    Select apr_lmtcion_tpo, apr_tpo_ampro,
          Case 
        When APR_CDGO_AMPRO = '01' And pi_tb_conceptos(i).cod_concepto = '01' Then 1 
        When APR_CDGO_AMPRO = '01' And pi_tb_conceptos(i).cod_concepto = '02' Then 0
        Else Null End
    Into V_APR_LMTCION_TPO ,V_APR_TPO_AMPRO, V_ENTRO
    From Ampros_Prdcto 
    Where apr_cdgo_ampro = pi_tb_conceptos(i).cod_amparo;

        Pkg_Novedades_Web_Java.PRC_GUARDAR_NOVEDAD_SEG_ARREN(V_NOVEDADES,
                                                       V_ESTADO_POLIZA,
                                                       pi_datos_aumento.NUMERO_SOLICITUD,
                                                       TIPO_IDENINQUILINO,
                                                       NMRO_IDENINQUILINO,
                                                       pi_tb_conceptos(i).cod_amparo,
                                                      pi_datos_aumento.FECHA_AUMENTO,
                                                       --pi_tb_conceptos(i).nuevo_valor,
                                                       pi_tb_conceptos(i).VALOR_ESTUDIO,
                                                       pi_tb_conceptos(i).nuevo_valor,
                                                       V_APR_LMTCION_TPO,
                                                       SES_NMRO_PLZA,
                                                       V_APR_TPO_AMPRO,
                                                       pi_tb_conceptos(i).cod_concepto,
                                                       DIR_DIRECCION,
                                                       DI_DIVPOL_CODIGO,
                                                       DIR_ESTRTO,
                                                       COD_TPO_INMBLE ,
                                                       COD_DSTNO_INMBLE,
                                                       V_ASISTENCIA,
                                                       -- 581000, --   
                                                        V_TTAL_ASGRDO,
                                                       V_TTAL_ASGRDO, 
                                                      FECHA_INGRESO_SEG(pi_datos_aumento.NUMERO_SOLICITUD,
                                                                        ses_nmro_plza,
                                                                        '00',
                                                                        '12',
                                                                         pi_tb_conceptos(i).cod_amparo),
                                                       pi_datos_aumento.NIT_INMOBILIARIA,
                                                       V_ENTRO,
                                                       V_FECHA_CONTRATO, 
                                                       V_TIPO_AUMENTO,
                                                       V_MONTO_AUMENTO,
                                                       V_EXISTE_IVA,
                                                       V_METRAJE_HOGAR,
                                                       V_TA_EXCEPCIONES);
  End Loop;      
  
  Po_CODIGO:=0;
  po_Mensaje :='Registro exitoso';
  Exception
       When E_negocio Then
         PO_MENSAJE :='ERROR DE NEGOCIO: '||PO_MENSAJE;
         pO_codigo:=PO_CODIGO;
     When Others Then
         po_Mensaje :=Sqlerrm;
         po_codigo :=Sqlcode;
  End prc_registra_aumento;
  
                                         
  Procedure prc_registra_alerta ( pi_nro_solicitud In number,  pi_fecha_mora In date, pi_tipo_operacion  In   varchar2,pi_tipo_observacion  In   varchar2,  po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 ) As
    Begin
      Null;
    End prc_registra_alerta;


  /*
      Nombre:           prc_registra_aumento
      Autor:            jgallo(asw)
      Fecha_creacion:   06-10-2017
      fecha_mod:        06-10-2017
      proposito:        procedimiento  que registra retiro en SAI
    */
  Procedure prc_registra_retiro (  pi_solicitud In number, pi_fecha_retiro In DATE, pi_nit_inmobiliaria In varchar2, po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 ) Is
    SES_NMRO_PLZA       Slctdes_Estdios.SES_NMRO_PLZA%Type;
        COD_DSTNO_INMBLE    Slctdes_Estdios.SES_DSTNO_INMBLE%Type;
        DSTNO_INMBLE        Cg_Ref_Codes.RV_MEANING%Type;
        COD_TPO_INMBLE      Slctdes_Estdios.SES_TPO_INMBLE%Type;
        TPO_INMBLE          Cg_Ref_Codes.RV_MEANING%Type;
        NMRO_IDENINQUILINO  Arrndtrios.ARR_NMRO_IDNTFCCION%Type;
        TIPO_IDENINQUILINO  Arrndtrios.ARR_TPO_IDNTFCCION%Type;
        DIR_DIRECCION       Direcciones.DI_DIRECCION%Type;
        DIR_ESTRTO          Direcciones.DI_ESTRTO%Type;
        DI_DIVPOL_CODIGO    Direcciones.DI_DIVPOL_CODIGO%Type;
        DSP_CIU_NMBRE       V_DIVISION_POLITICAS.NOM_CIU%Type;
        V_NOMBRE_POLIZA     VARCHAR2(200);
        V_ESTADO_POLIZA     Plzas.POL_ESTADO_PLZA%Type;
        V_ASISTENCIA        Plzas.POL_ASSTNCIA%Type;
        V_TIPO_POLIZA       Plzas.POL_TPOPLZA%Type;
        V_TIPO_RIESGO       Plzas.POL_TPORSGO%Type;
        V_SUCURSAL          Plzas.POL_SUC_CDGO%Type;
        SUCURSAL            Plzas.POL_SUC_CDGO%Type;
        INQUILINO           VARCHAR2(200);
        MENSAJE             VARCHAR2(200);
        FECHA_CONTRATO      DATE;
        TIPO_AUMENTO        VARCHAR2(10);
        MONTO_AUMENTO       NUMBER;
        IVA_COMERCIAL       VARCHAR2(50);  
        
    V_NOVEDADES         VARCHAR2(2);
    V_APR_TPO_AMPRO     Ampros_Prdcto.APR_TPO_AMPRO%Type;
    V_APR_LMTCION_TPO   Ampros_Prdcto.APR_LMTCION_TPO%Type;--
    V_ENTRO             NUMBER(2);
    
    V_TIPO_AUMENTO      Datos_Contratos.TIPO_AUMENTO_CANON%Type:=Null;
    V_MONTO_AUMENTO     Datos_Contratos.MONTO_AUMENTO_CANON%Type:=Null;
    V_FECHA_CONTRATO    date;
    V_PORCENTAJE_IVA    NUMBER(4,2);
    V_METRAJE_HOGAR     Direcciones.DI_AREA%Type;
    V_EXISTE_IVA            VARCHAR2(2);
     
    Po_ty_solicitud ty_datos_solicitud;    
    V_MENSAJE             VARCHAR2(200);
    V_TTAL_ASGRDO         NUMBER:=0;
    
    e_NEGOCIO            Exception;  
    
    Type T_AMP_RETIRADOS Is Table Of VARCHAR2(2); 
    V_AMP_RETIRADOS T_AMP_RETIRADOS;
    cont_amp_retirados int := 1;
    V_EXISTE_AMP       NUMBER(1):=0;
    V_AMP_BASICO       varchar2(2) := '01'; --código del amparo básico
    
  Begin
    V_NOVEDADES := '02'; --02 para RETIROS
    V_AMP_RETIRADOS := T_AMP_RETIRADOS();
        PRC_DATOS_SOLICITUD(pi_solicitud,
                            pi_nit_inmobiliaria  ,
                            SES_NMRO_PLZA     ,
                            COD_DSTNO_INMBLE  ,
                            DSTNO_INMBLE      ,
                            COD_TPO_INMBLE    ,
                            TPO_INMBLE        ,
                            NMRO_IDENINQUILINO,
                            TIPO_IDENINQUILINO,
                            DIR_DIRECCION     ,
                            DIR_ESTRTO        ,
                            DI_DIVPOL_CODIGO  ,
                            DSP_CIU_NMBRE     ,
                            V_NOMBRE_POLIZA   ,
                            V_ESTADO_POLIZA   ,
                            V_ASISTENCIA      ,
                            V_TIPO_POLIZA     ,
                            V_TIPO_RIESGO     ,
                            V_SUCURSAL        ,
                            SUCURSAL          ,
                            INQUILINO         ,
                            MENSAJE           ,
                            FECHA_CONTRATO    ,
                            TIPO_AUMENTO      ,
                            MONTO_AUMENTO     ,
                            IVA_COMERCIAL     );
  V_FECHA_CONTRATO := FECHA_CONTRATO;
       --CONSULTA DE DATOS BÁSICOS
  Begin
      Pkg_Interfaces_Consultas.Prc_cons_datos_basicos_sai (pi_solicitud, 
                                        pi_nit_inmobiliaria, 
                                         Po_ty_solicitud,
                                         po_Codigo,
                                         po_Mensaje);
  --revisa si la solicitud fue encontrada en el procedimiento de datos básicos
      If(PO_CODIGO != 0) Then
          Raise E_NEGOCIO;
          End If;
       End;
    --Revisa si se encuentra asegurada
       If PO_TY_SOLICITUD.ESTADO_SOLICITUD != 'AS' Then
          PO_CODIGO:= '-10';
          PO_MENSAJE := 'La solicitud ' ||pi_solicitud || ' no se encuentra asegurada o ya fue retirada';
          Raise e_negocio;
        End If;
   -- CONSULTA DE VALOR ASEGURADO
    For j In 1..po_ty_solicitud.amparos.Count Loop--recorre los amparos para determinar la suma del valor asegurado por cada amparo
      If(V_AMP_BASICO = po_ty_solicitud.amparos(j).cod_amparo) Then
          V_TTAL_ASGRDO := V_TTAL_ASGRDO  + po_ty_solicitud.amparos(j).vlr_aseg;      
      End If;
    End Loop;
    -- consulta de limitación y tipo de amparo
    Select apr_lmtcion_tpo, apr_tpo_ampro
    Into V_APR_LMTCION_TPO ,V_APR_TPO_AMPRO
    From Ampros_Prdcto 
    Where apr_cdgo_ampro = V_AMP_BASICO;
        
    --Ejecución de procedimiento de retiro    
    Pkg_Novedades_Web_Java.PRC_GUARDAR_NOVEDAD_SEG_ARREN(V_NOVEDADES,
                                                       V_ESTADO_POLIZA,
                                                       pi_SOLICITUD,
                                                       TIPO_IDENINQUILINO,
                                                       NMRO_IDENINQUILINO,
                                                        V_AMP_BASICO,
                                                      pi_fecha_retiro,
                                                       V_TTAL_ASGRDO,
                                                        V_TTAL_ASGRDO,
                                                       V_APR_LMTCION_TPO,
                                                       SES_NMRO_PLZA,
                                                       V_APR_TPO_AMPRO,
                                                       Null,
                                                       DIR_DIRECCION,
                                                       DI_DIVPOL_CODIGO,
                                                       DIR_ESTRTO,
                                                       COD_TPO_INMBLE ,
                                                       COD_DSTNO_INMBLE,
                                                       V_ASISTENCIA,
                                                       --581000,
                                                       V_TTAL_ASGRDO, 
                                                       V_TTAL_ASGRDO, 
                                                      FECHA_INGRESO_SEG(pi_SOLICITUD,
                                                                        ses_nmro_plza,
                                                                        '00',
                                                                        '12',
                                                                              V_AMP_BASICO),
                                                       pi_NIT_INMOBILIARIA,
                                                       V_ENTRO,
                                                       V_FECHA_CONTRATO, 
                                                       V_TIPO_AUMENTO,
                                                       V_MONTO_AUMENTO,
                                                       V_EXISTE_IVA,
                                                       V_METRAJE_HOGAR,
                                                       Null);
                                                    
  
  Po_CODIGO:=0;
  po_Mensaje :='Registro exitoso';
  Exception
       When E_negocio Then
         PO_MENSAJE :='ERROR DE NEGOCIO: '||PO_MENSAJE;
         pO_codigo:=PO_CODIGO;
     When Others Then
         po_Mensaje :=Sqlerrm;
         po_codigo :=Sqlcode;
    
  End prc_registra_retiro;
  
End Pkg_Interfaces_Operaciones;
/
