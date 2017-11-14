Create Or Replace Package Body ADMSISA.Pkg_Interfaces_Consultas Is
   

/*********************** Funciones ***************************/

    /*Nombre:           f_solicitud_aseg
      Autor:            jpmoreno(asw)
      Fecha_creacion:   16-08-2017
      fecha_mod:        16-08-2017
      proposito:        retorna el numero de solicitud realmente asegurada
                        cuando ocurre cambio de inquilino 
    */
    Function f_solicitud_aseg (pi_solicitud In number) Return number
    Is
    v_sol number;
    Begin       
     Select Distinct R.RVI_NMRO_ITEM
        Into v_sol
        From Rsgos_Vgntes r
        Where RVI_NMRO_ITEM In (Select ARR_NMRO_SLCTUD
                                 From Arrndtrios 
                                 Where   ARR_SES_NMRO = pi_solicitud);                         
    Return v_sol;
    Exception
    When No_Data_Found Then
        Begin       
             Select Distinct R.RIR_NMRO_ITEM
                Into v_sol
                From Rsgos_Rcbos r
                Where RIR_NMRO_ITEM In (Select ARR_NMRO_SLCTUD
                                         From Arrndtrios 
                                         Where   ARR_SES_NMRO = pi_solicitud);                         
            Return v_sol;
        Exception
            When No_Data_Found Then
                v_sol := pi_solicitud;
                Return v_sol;
         End;
    End f_solicitud_aseg;  
    
    /*Nombre:           F_CONSULTAR_ESTADO_SOLICITUD
  Autor:            jgallo(asw)
  Fecha_creacion:   17-10-2017
  fecha_mod:        17-10-2017
  proposito:        Determina el estado en que se encuentra una solicitud
  */
  Function F_CONSULTAR_ESTADO_SOLICITUD(P_NUMERO_SOLICITUD NUMBER) Return VARCHAR2 
  Is
    V_ESTADO_SOLICITUD VARCHAR2(2);
    Begin
          Select Distinct 'AS'
          Into  V_Estado_Solicitud
          From Rsgos_Vgntes 
          Where rvi_nmro_item  = P_NUMERO_SOLICITUD;
           Return v_estado_solicitud;
          Exception When No_Data_Found Then
              Begin
                  Select Distinct'RT'
                  Into  v_Estado_Solicitud
                  From Rsgos_Rcbos
                  Where rir_nmro_item In(P_NUMERO_SOLICITUD)
                  And Not Exists (Select 1 From Rsgos_Vgntes
                  Where rvi_nmro_item = rir_nmro_item);
                   Return v_estado_solicitud;
                  Exception When No_Data_Found Then    
                      Begin
                        Select Distinct 'ES'
                        Into V_ESTADO_SOLICITUD
                        From Slctdes_Estdios
                        Where SES_NMRO = P_NUMERO_SOLICITUD;
                         Return v_estado_solicitud;
                        Exception When No_Data_Found Then
                           Raise_Application_Error(-20101, 'No existe la solicitud: '||p_numero_solicitud);
                                When Others Then
                                  Raise_Application_Error(-20102, Sqlerrm);
                End;
        End;  
       Return v_estado_solicitud;
  End F_CONSULTAR_ESTADO_SOLICITUD;
  
  /*Nombre:           F_CONSULTAR_VALOR_ASEGURADO
  Autor:            jgallo(asw)
  Fecha_creacion:   18-10-2017
  fecha_mod:        18-10-2017
  proposito:        Determina el valor asegurado de un concepto de una solicitud
  */
  Function F_VALOR_ASEGURADO_CONCEPTO(P_NUMERO_SOLICITUD NUMBER, P_ESTADO_SOLICITUD varchar2, P_CONCEPTO varchar2) Return NUMBER
  As
    po_canon number(30,5) := 0;
  Begin
     If(p_estado_solicitud = 'AS') Then --Si la solicitud está asegurada
        Select rvl_vlor
        Into po_canon
        From Rsgos_Vgntes_Avlor
        Where rvl_nmro_item = P_NUMERO_SOLICITUD
        And rvl_cncpto_vlor = '01';
      End If;
     If(p_estado_solicitud = 'RT') Then --Si la solicitud ya fue retirada
        Select rav_vlor
        Into po_canon
        From Rsgos_Rcbos_Avlor
        Where rav_nmro_item = P_NUMERO_SOLICITUD
        And rav_cncpto_vlor = '01';
      End If;
     If(p_ESTADO_SOLICITUD = 'ES') Then
          Select SES_CNON_ARRNDMNTO
          Into po_canon
          From Slctdes_Estdios
          Where ses_nmro = P_NUMERO_SOLICITUD;
        End If;  
      Return po_canon;
  End f_valor_asegurado_CONCEPTO;
    /*********************** Procedimientos ***************************/
    
    /*Nombre:           Prc_cons_datos_basicos_sai
      Autor:            jpmoreno(asw)
      Fecha_creacion:   09-08-2017
      fecha_mod:        09-08-2017
      proposito:        Devolver los datos basicos de una solicitud 
                        tanto para polizas colectivas como individuales
      Fecha_mod:        27-09-2017
      Modificado por:   jgallo(asw)
      Proposito:        Agregar campos de homologación de: Destinacion, Ciudad, Tipo Inmueble, Estado Solicitud
    */
   Procedure Prc_cons_datos_basicos_sai (pi_nro_solicitud In NUMBER, 
                                         pi_nit_inmobiliaria In NUMBER Default Null, 
                                         po_ty_solicitud Out ty_datos_solicitud,
                                         po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 )
   Is
   
   v_pos    varchar2(3);
   v_aseg   varchar2(2);
   v_cur    number(4);
   v_existe varchar2(1);
   
   --variables de resupuesta 
  Nro_Solicitud         NUMBER (10);
  Nombre_Inquilino      VARCHAR2 (120);
  Destinacion           VARCHAR2 (1);
  Poliza                NUMBER (10);
  Tipo_Inmueble         VARCHAR2 (1);
  Direccion             VARCHAR2 (100);
  Ciudad                NUMBER (10);
  Nuevo_vlr_aseg        NUMBER (18, 2);
  Fecha_Novedad         DATE;
  Estado_Solicitud      VARCHAR2 (2);         --(En estudio/Asegurada/Retirada)
  Estado_Siniestro      VARCHAR2 (2);
  Estado_Pago           VARCHAR2 (2);        --(Objetado/Vigente/Suspendido)
  Fecha_Mora            DATE;                 --(Fecha de mora del siniestro)
  Fecha_Ingreso         DATE;                 -- (aseguramiento)
  Fecha_Estudio         DATE;
  Fecha_desocupacion    DATE;
  Fecha_retiro          DATE;
  Fecha_Ini_Contr       DATE;
  Fecha_fin_Contr       DATE;
  Estrato_Econ          NUMBER (1);
  Fecha_mora_Amp_basico DATE;    
  vt_conceptos          tb_amparos;
  destinacion_desc     varchar2(240);
  estado_solicitud_desc varchar2(100);
  tipo_inmueble_desc   varchar2(240);
  nombre_ciudad         VARCHAR2(60);
  nro_identificacion_inq NUMBER(12);
  tipo_identificacion_inq VARCHAR2(2);
  Correo_e               varchar2(150);
  V_SCNCIA_TERCERO      number;
  V_TIPO_ID             VARCHAR2 (2); 
  V_NMRO_ID             NUMBER;
  V_TIPO                varchar2(2);
  
  v_vlr_canon number(18,2);
  v_vlr_admon number(18,2);
    

   Error_negocio Exception;
   Error_negocio2 Exception;
   
   Begin  
   
     Begin
        Select Ses_nmro, 
              Pk_Terceros.F_NOMBRES(ARR_NMRO_IDNTFCCION, ARR_TPO_IDNTFCCION),
              Ses_dstno_inmble,              
              Ses_tpo_inmble,
              Ses_fcha_ingrso,
              Ses_cnon_arrndmnto,
              Ses_cta_admnstrcion,
              Ses_nmro_plza,
              A.ARR_NMRO_IDNTFCCION,
              A.ARR_TPO_IDNTFCCION 
       Into  Nro_solicitud,
             Nombre_Inquilino,
             Destinacion,
             Tipo_Inmueble,
             Fecha_Estudio,
             v_vlr_canon,
             v_vlr_admon,
             Poliza,
             nro_identificacion_inq,
             tipo_identificacion_inq
       From Slctdes_Estdios Se
       Inner Join Arrndtrios A On (A.ARR_NMRO_SLCTUD = pi_nro_solicitud And Se.Ses_nmro = A.ARR_SES_NMRO);

      Exception When No_Data_Found Then
           v_pos  := '010';
           po_Codigo := Sqlcode;
           po_Mensaje := 'No se encontro ninguna solicitud con el existente';
           Raise Error_negocio;
      End;
      -- Descripción de tipo de destino
      Begin
        Select RV_MEANING 
        Into destinacion_desc
        From Cg_Ref_Codes CG
        Where CG.RV_DOMAIN = 'DESTINO_INMUEBLE'
        And CG.RV_LOW_VALUE = Destinacion;
           
        Exception When No_Data_Found Then
        po_Codigo := Sqlcode;
        po_Mensaje := 'No se encontro traducción para el tipo de destino';
        Raise Error_negocio;
      End;
      Nro_solicitud := f_solicitud_aseg( Pi_nro_solicitud);
      
      --descripcion de tipo de inmueble
      Begin
        Select rv_meaning 
        Into tipo_inmueble_desc
        From Cg_Ref_Codes CG
        Where CG.RV_DOMAIN = 'TIPO_INMUEBLE'
        And CG.RV_LOW_VALUE = tipo_inmueble;
        
        Exception When No_Data_Found Then
        po_Codigo := Sqlcode;
        po_Mensaje := 'No se encontro traducción para el tipo de destino';
        Raise Error_negocio;
          
      End;
     --Estado solicitud
     Begin
            v_pos  := '012' ;
            Select Distinct 'AS', 'ASEGURADO',RVI_NMRO_PLZA
                Into  Estado_Solicitud, estado_solicitud_desc,Poliza
                From Rsgos_Vgntes 
                Where rvi_nmro_item  In(Nro_solicitud);

     Exception When No_Data_Found Then
             Begin
                   v_pos  := '014' ;
                   Select Distinct'RT', 'RETIRADO',rir_NMRO_PLZA
                   Into  Estado_Solicitud, estado_solicitud_desc,Poliza
                   From Rsgos_Rcbos
                   Where rir_nmro_item In(Nro_solicitud)
                   And Not Exists (Select 1 From Rsgos_Vgntes
                                   Where rvi_nmro_item = rir_nmro_item)
                   And RIR_NMRO_CRTFCDO = (Select Max(RIR_NMRO_CRTFCDO)
                                          From Rsgos_Rcbos
                                            Where rir_nmro_item =Nro_solicitud);
                Exception When No_Data_Found Then    
                       Estado_Solicitud := 'ES';
                       estado_solicitud_desc := 'ESTUDIO';
              End;  
     End;
     
    -- DBMS_OUTPUT.PUT_LINE('Estado solicitud  '||Estado_Solicitud  || ' - ');
     
     
     -- validacion de la poliza y la inmobiliara
    Begin
       v_pos := '015';
       Select POL_PRS_NMRO_IDNTFCCION,POL_PRS_TPO_IDNTFCCION
       Into   V_NMRO_ID, V_TIPO_ID
       From  Plzas P  
       Where P.POL_NMRO_PLZA =Poliza   
       And P.Pol_prs_nmro_idntfccion = Pi_nit_inmobiliaria; 

        V_SCNCIA_TERCERO := Pk_Terceros.Fun_Retorna_Secuencia(V_TIPO_ID,V_NMRO_ID,V_TIPO);
    Exception
       When No_Data_Found Then
         v_pos := '016';
          If Estado_Solicitud <> 'ES'Then
              po_Codigo := Sqlcode;
              po_Mensaje := 'no se encontraron datos validos para la solicitud '||Nro_solicitud  ;
              Raise Error_negocio;
          End If;
    End;     
     
     
     
     -- condulta de direcciones
     If    Estado_Solicitud In ('AS','RT') Then    
        Begin
        
           v_pos := '017';
           Select Di_direccion, Di_divpol_codigo, Di_estrto
           Into    Direccion, Ciudad, Estrato_Econ
           From     Direcciones 
           Where Di_solicitud= Nro_solicitud 
           And DI_TPO_DRCCION = 'R';
        Exception
            When No_Data_Found Then
                Begin
                   v_pos := '018';
                   Select Di_direccion, Di_divpol_codigo, Di_estrto
                   Into    Direccion, Ciudad, Estrato_Econ
                   From     Direcciones 
                   Where Di_solicitud= Nro_solicitud 
                   And DI_TPO_DRCCION = 'E';
                Exception
                   When No_Data_Found
                   Then
                      po_Codigo := Sqlcode;
                      po_Mensaje := 'No se encontro direccion del riesgo para la solicitud '||Nro_solicitud  ;
                      Raise Error_negocio;
                End;
        End;
    Else
        Begin
           v_pos := '019';
           Select Di_direccion, Di_divpol_codigo, Di_estrto
           Into    Direccion, Ciudad, Estrato_Econ
           From     Direcciones 
           Where Di_solicitud= Nro_solicitud 
           And DI_TPO_DRCCION = 'E';
        Exception
           When No_Data_Found
           Then
              po_Codigo := Sqlcode;
              po_Mensaje := 'No se encontro direccion del riesgo para la solicitud '||Nro_solicitud  ;
              Raise Error_negocio;
        End;
   End If;     
     
    
      vt_conceptos :=tb_amparos();
     -- valores por concepto para polizas aseguradas
     
      If    Estado_Solicitud = 'AS' Then
            v_pos  := '020' ;
            v_cur := 1;
         --   DBMS_OUTPUT.PUT_LINE(' antes de ciclo  '||v_cur  || '- ');
            For c_conc In (Select A.Apr_tpo_ampro tipo_amparo,A.Apr_cdgo_ampro cod_amparo,R.Rvl_cncpto_vlor cod_concept,V.Vpr_dscrpcion desc_concep,Rvl_vlor vlr_aseg
                              From Rsgos_Vgntes_Avlor R
                             Inner Join Ampros_Prdcto A On R.Rvl_cdgo_ampro = A.Apr_cdgo_ampro
                             Inner Join Vlres_Prdcto V On V.Vpr_cdgo = R.Rvl_cncpto_vlor
                             Where RVL_NMRO_ITEM = Nro_solicitud
                             And Rvl_vlor <> 0 )
            Loop
          --      DBMS_OUTPUT.PUT_LINE(' entre al ciclo  '||v_cur  || '- ');
                 
                
                 vt_conceptos.Extend;
                 vt_conceptos(v_cur) := ty_amparo(c_conc.tipo_amparo,
                                                  c_conc.cod_amparo,
                                                  c_conc.cod_concept,
                                                  c_conc.desc_concep,
                                                  Case When c_conc.desc_concep = '01' Then
                                                            v_vlr_canon
                                                       When c_conc.desc_concep = '02' Then
                                                            v_vlr_admon
                                                       Else  c_conc.vlr_aseg End,
                                                  c_conc.vlr_aseg);            
                
                 v_cur := v_cur + 1;               
            End Loop;
           -- DBMS_OUTPUT.PUT_LINE(' sali al ciclo  '||v_cur  || '- ');
--            If v_cur = 1 Then
--                 po_Codigo := -85;
--                 po_Mensaje := 'No se encontraron los valores asegurados  para la solicitud: '||Nro_solicitud ;
--                 Raise Error_negocio;
--            End If;                        

        -- valores por concepto para polizas retiradas
       Elsif  Estado_Solicitud = 'RT' Then
             v_pos  := '021' ;
            v_cur := 1;
            
            For c_conc In (Select A.Apr_tpo_ampro tipo_amparo,A.Apr_cdgo_ampro cod_amparo,R.rav_CNCPTO_VLOR cod_concept,V.Vpr_dscrpcion desc_concep,rav_VLOR vlr_aseg
                              From Rsgos_Rcbos_Avlor R
                             Inner Join Ampros_Prdcto A On R.rav_cdgo_ampro = A.Apr_cdgo_ampro
                             Inner Join Vlres_Prdcto V On V.Vpr_cdgo = R.rav_CNCPTO_VLOR
                             Where rav_NMRO_ITEM = Nro_solicitud
                             And rav_VLOR <> 0 
                             And R.rav_NMRO_CRTFCDO = ( Select Max(x.rav_NMRO_CRTFCDO)
                                                        From Rsgos_Rcbos_Avlor x
                                                        Where x.rav_nmro_item =Nro_solicitud))
            Loop
                
                 vt_conceptos.Extend;
                 vt_conceptos(v_cur) := ty_amparo(c_conc.tipo_amparo,
                                                  c_conc.cod_amparo,
                                                  c_conc.cod_concept,
                                                  c_conc.desc_concep,
                                                  Case When c_conc.desc_concep = '01' Then
                                                            v_vlr_canon
                                                       When c_conc.desc_concep = '02' Then
                                                            v_vlr_admon
                                                       Else  c_conc.vlr_aseg End,
                                                  c_conc.vlr_aseg);              
                
                 v_cur := v_cur + 1;               
            End Loop;
            
            If v_cur = 1 Then
                 po_Codigo := Sqlcode;
                 po_Mensaje := 'No se los valores asegurados  para la solicitud: '||Nro_solicitud ;
                 Raise Error_negocio;
            End If;
      
      Else  -- valores por concepto para polizas en estudio
           v_pos  := '022' ;
          Declare
            tipo_amparo     Varchar2(1);
            cod_amparo      Varchar2(2);
            cod_concept     varchar2(4);
            desc_concep     varchar2(50);
            vlr_solicitud        number(18,2);
          Begin 
             vt_conceptos.Extend;    
             Select 'B','01',vpr_cdgo,vpr_dscrpcion,v_vlr_canon
             Into tipo_amparo, 
                  cod_amparo,  
                  cod_concept, 
                  desc_concep, 
                  vlr_solicitud    
             From Vlres_Prdcto
             Where vpr_cdgo  = '01'; -- canon
          
            vt_conceptos(1) := ty_amparo( tipo_amparo,
                                              cod_amparo,
                                              cod_concept,
                                              desc_concep,
                                              vlr_solicitud,
                                              Null);
          
          
          If  Nvl(v_vlr_admon,0) <> 0 Then
              v_pos  := '023' ;
              vt_conceptos.Extend; 
             Select 'B','01',vpr_cdgo,vpr_dscrpcion,v_vlr_admon
             Into tipo_amparo, 
                  cod_amparo,  
                  cod_concept, 
                  desc_concep, 
                  vlr_solicitud
             From Vlres_Prdcto
             Where vpr_cdgo  = '02'; -- admon
            vt_conceptos(2) := ty_amparo( tipo_amparo,
                                                          cod_amparo,
                                                          cod_concept,
                                                          desc_concep,
                                                          vlr_solicitud,
                                                          Null);

           End If;
          
          Exception When No_Data_Found Then
                po_Codigo := Sqlcode;
                po_Mensaje := 'No se encontraron los conceptos y las descripciones';
                Raise Error_negocio;
          End;
      End If ;
     
       
     
     --nuevo valor asegurado
      Nuevo_vlr_aseg := F_Valor_Asegurado(Nro_solicitud,--P_SOLICITUD NUMBER,
                                                          Poliza,        --P_POLIZA NUMBER,
                                                          '01',                         --P_AMPARO VARCHAR2,
                                                          '12',                         --P_RAMO VARCHAR2,
                                                          v_aseg                        --P_ASEG  Out VARCHAR2
                                                          ); 
     
                                                 
     
     --fecha_novedad para amparo basico
     Begin
         v_pos  := '024' ;
        Select Max(rivn_fcha_nvdad)
        Into  Fecha_Novedad
        From Rsgos_Vgntes_Nvddes
        Where rivn_nmro_item = Nro_solicitud
        And rivn_cdgo_ampro = '01'; 
        
     Exception When No_Data_Found Then
           /*po_Codigo := Sqlcode;
           po_Mensaje := 'No se encontraron  valores asegurados adicionales  para la solicitud: '||Nro_solicitud ;
           Raise Error_negocio;*/
            Fecha_Novedad := Null;
     End;
     

     
     --  fecha mora
     Begin
        v_pos  := '025' ;
  Select Max(ams_fcha_mra), Max(ams_fcha_mra)
        Into Fecha_Mora,Fecha_mora_Amp_basico
        From  Ampros_Snstros
        Where AMS_NMRO_ITEM = Nro_solicitud
        And ams_cdgo_ampro = '01'
        And Exists (Select 'x' From Vlres_Snstros
                    Where VSN_NMRO_SNSTRO = ams_nmro_snstro
                      And vsn_cncpto_vlor = '01');
     Exception When No_Data_Found Then
        Fecha_Mora := Null;    

     End;
     
               
     -- estado siniestro y estado pago
     If Fecha_Mora Is Not Null Then
        Begin
            v_pos  := '026';
           Select sna_estdo_snstro, sna_estdo_pgo
           Into Estado_Siniestro, Estado_Pago
           From Avsos_Snstros
          Where sna_nmro_item = Nro_solicitud
            And sna_fcha_snstro = Fecha_Mora;

        Exception When No_Data_Found Then
                       po_Codigo := Sqlcode;
                       po_Mensaje := 'No se encontraron  el estado siniestro ni  estado pago para la solicitud: '||Nro_solicitud ;
                       Raise Error_negocio; 
        End;     
     End If; 
   
     --fecha ingreso
     Fecha_Ingreso := Fecha_Ingreso_Seg(Nro_solicitud,   --P_SOLICITUD NUMBER,
                                                        Poliza,            --P_POLIZA    NUMBER,
                                                        '00',-- P_CLASE     VARCHAR2,=
                                                        '12',-- P_RAMO      VARCHAR2,=
                                                        '01' --P_AMPARO    VARCHAR2
                                                         ); 
     
     --fecha desocupacion
     Begin
            v_pos  := '027' ;
               Select dse_fcha_dscpcion
                 Into Fecha_desocupacion
                 From Dscpcnes_Efctdas, Avsos_Snstros
                Where dse_nmro_snstro  = sna_nmro_snstro
                  And sna_nmro_item =Nro_solicitud
                  And sna_fcha_snstro =  Fecha_Mora;
        Exception When No_Data_Found Then
         Fecha_desocupacion := Null;
        End; 
     
     
     --fecha retiro
     Fecha_retiro := Fecha_Retiro_Seg(Nro_solicitud,--  P_SOLICITUD NUMBER, 
                                                        Poliza, --  P_POLIZA    NUMBER
                                                        '00', -- P_CLASE     VARCHAR2, 
                                                        '12', -- P_RAMO      VARCHAR2, 
                                                        '01' --  P_AMPARO    VARCHAR2
                                                        );                                  

     -- fecha inicio contrato
        Begin
        v_pos  := '028' ;
           Select rvc_fcha_inccion_cntrto,rvc_fcha_final_cntrto 
           Into Fecha_Ini_Contr,Fecha_fin_Contr
              From Rsgos_Vgntes_Cntrtos
          Where rvc_nmro_item  = Nro_solicitud;

        Exception When No_Data_Found Then
         Fecha_Ini_Contr := Null;
         Fecha_fin_Contr := Null;
        End;     
     
     -- nombre de ciudad
     Begin
        Select NOM_CIU
        Into nombre_ciudad
        From V_DIVISION_POLITICAS DP
        Where DP.codazzi_ciu = ciudad;
     End;
     
         Begin
             If V_TIPO = 'J' Then
                Select EMAIL
                  Into Correo_e
                  From CONTACTOS
                 Where JUR_SECUENCIA = V_SCNCIA_TERCERO
                   And CODIGO_CARGO = 2;
              Else
                Select EMAIL
                  Into Correo_e
                  From CONTACTOS
                 Where NAT_SECUENCIA = V_SCNCIA_TERCERO
                   And CODIGO_CARGO = 2;
              End If;
          Exception When Others Then
            Correo_e := Null;
          End;



   Po_ty_solicitud := ty_datos_solicitud(Nro_Solicitud         ,
                                        Null,
                                        Nombre_Inquilino      ,
                                        Destinacion           ,
                                        Poliza                ,
                                        Tipo_Inmueble         ,
                                        Direccion             ,
                                        Ciudad                ,
                                        Nuevo_vlr_aseg        ,
                                        Fecha_Novedad         ,
                                        Estado_Solicitud      ,
                                        Estado_Siniestro      ,
                                        Estado_Pago           ,
                                        Fecha_Mora            ,
                                        Fecha_Ingreso         ,
                                        Fecha_Estudio         ,
                                        Fecha_desocupacion    ,
                                        Fecha_retiro          ,
                                        Fecha_Ini_Contr       ,
                                        Fecha_fin_Contr       ,
                                        Estrato_Econ          ,
                                        Fecha_mora_Amp_basico ,
                                        vt_conceptos,
                                        destinacion_desc      ,
                                        tipo_inmueble_desc    ,
                                        estado_solicitud_desc ,
                                        nombre_ciudad,
                                        nro_identificacion_inq,
                                        tipo_identificacion_inq,
                                        Correo_e
                                        );
   
   --fin del proceso resultado exitoso
   po_Codigo := 0;
   po_Mensaje := 'Consulta Exitosa'; 
      
   Exception
    When Error_negocio Then 
      po_Mensaje := v_pos || ' - '||po_Mensaje;
      Rollback;
    When Others Then 
      po_Codigo := Sqlcode;
      po_Mensaje := v_pos || ' - '|| 'Error inesperado en la consulta de solicitud. Error:'||Sqlerrm ;    

   End Prc_cons_datos_basicos_sai;                                     

  -- Author  : Asesoftware - Jorge Gallo.
  -- Created : 09/08/2017.
  -- Purpose :  Procedimiento que permite consultar las polizas asociadas al numero de identificacion de un usuario
  -- Modificado por:
  --
    Procedure PRC_CONSULTAR_PLZAS_ASCDAS
    (
        P_NUMERO_IDENTIFICACION In VARCHAR2,
        P_TABLE_PLZAS Out T_TABLE_PLZAS,
        P_CODIGO_RESPUESTA Out VARCHAR2,
        P_MENSAJE_RESPUESTA Out VARCHAR2
    ) 
     As 
        i Binary_Integer := 0; 
        j Binary_Integer := 1; 
        Cursor plzas_cursor Is 
          Select pl.POL_NMRO_PLZA, s.SES_NMRO, pl.POL_FCHA_DSDE_ACTUAL, pl.POL_FCHA_HSTA_ACTUAL, d.DI_DIRECCION, d.DI_TPO_DRCCION, r.RVI_NMRO_PLZA 
          From Slctdes_Estdios s       
                 Inner Join Direcciones d
                 On s.SES_NMRO = d.DI_SOLICITUD
                 Inner Join Plzas pl
                 On s.SES_NMRO_PLZA = pl.POL_NMRO_PLZA
                 Left Join Rsgos_Vgntes r
                 On r.RVI_NMRO_PLZA  = pl.POL_NMRO_PLZA
                 Left Join Rsgos_Rcbos rr
                 On rr.RIR_NMRO_PLZA = pl.POL_NMRO_PLZA
          Where pl.POL_PRS_NMRO_IDNTFCCION = To_Number(P_NUMERO_IDENTIFICACION) 
          And pl.POl_ESTADO_PLZA Not In ('A')
          And POL_TPOPLZA = 'I'
          Group By pl.POL_NMRO_PLZA, s.SES_NMRO, pl.POL_FCHA_DSDE_ACTUAL, pl.POL_FCHA_HSTA_ACTUAL, d.DI_DIRECCION, d.DI_TPO_DRCCION, r.RVI_NMRO_PLZA 
          Order By 2;        
        plzas_temp T_TABLE_PLZAS_AUX;
        cont int:=0;
      Begin
        plzas_temp := T_TABLE_PLZAS_AUX();
        P_TABLE_PLZAS := T_TABLE_PLZAS();
        For plzas_record In plzas_cursor Loop --Revisa la dirección que corresponde, si es 'E' o 'R'
          cont:=cont+1;
          plzas_temp.Extend();
          plzas_temp(cont) := T_CONSULTA_POLIZA_AUX(plzas_record.POL_NMRO_PLZA, plzas_Record.SES_NMRO, plzas_Record.POL_FCHA_DSDE_ACTUAL, plzas_Record.POL_FCHA_HSTA_ACTUAL,plzas_Record.DI_DIRECCION, plzas_Record.DI_TPO_DRCCION, plzas_Record.RVI_NMRO_PLZA);
        End Loop;
        If (plzas_temp.Last<=1) Then
          p_table_plzas.Extend();
          p_table_plzas(j):=T_CONSULTA_POLIZA(plzas_temp(j).NUMERO_POLIZA, plzas_temp(j).NUMERO_SOLICITUD, plzas_temp(j).INICIO_VIGENCIA_POLIZA, plzas_temp(j).FIN_VIGENCIA_POLIZA, plzas_temp(j).DIRECCION);
          Else
            If (plzas_temp(j).POLIZA_RIESGOS Is Null And plzas_temp(j).TIPO_DIRECCION = 'E') Or (plzas_temp(j).POLIZA_RIESGOS Is Not Null And plzas_temp(j).TIPO_DIRECCION = 'R') Or (plzas_temp(j).NUMERO_SOLICITUD != plzas_temp(j+1).NUMERO_SOLICITUD)
            Then
                  p_table_plzas.Extend();
                  p_table_plzas(j):=T_CONSULTA_POLIZA(plzas_temp(j).NUMERO_POLIZA, plzas_temp(j).NUMERO_SOLICITUD, plzas_temp(j).INICIO_VIGENCIA_POLIZA, plzas_temp(j).FIN_VIGENCIA_POLIZA, plzas_temp(j).DIRECCION);
                j:=j+1;
            End If;
          For i In 2..plzas_temp.Last-1 Loop
            If (plzas_temp(i).POLIZA_RIESGOS Is Null And plzas_temp(i).TIPO_DIRECCION = 'E') Or (plzas_temp(i).POLIZA_RIESGOS Is Not Null And plzas_temp(i).TIPO_DIRECCION = 'R') Or (plzas_temp(i).NUMERO_SOLICITUD != plzas_temp(i+1).NUMERO_SOLICITUD And plzas_temp(i).NUMERO_SOLICITUD != plzas_temp(i-1).NUMERO_SOLICITUD)
            Then
            p_table_plzas.Extend();
            p_table_plzas(j):=T_CONSULTA_POLIZA(plzas_temp(i).NUMERO_POLIZA, plzas_temp(i).NUMERO_SOLICITUD, plzas_temp(i).INICIO_VIGENCIA_POLIZA, plzas_temp(i).FIN_VIGENCIA_POLIZA, plzas_temp(i).DIRECCION);
                j:=j+1;
            End If;
          End Loop;
          If ((plzas_temp(plzas_temp.Last).POLIZA_RIESGOS Is Null And plzas_temp(plzas_temp.Last).TIPO_DIRECCION = 'E') Or (plzas_temp(plzas_temp.Last).POLIZA_RIESGOS Is Not Null And plzas_temp(plzas_temp.Last).TIPO_DIRECCION = 'R') Or (plzas_temp(plzas_temp.Last).NUMERO_SOLICITUD != plzas_temp(plzas_temp.Last-1).NUMERO_SOLICITUD)) And plzas_temp.Last >1
              Then
              p_table_plzas.Extend();
              p_table_plzas(j):=T_CONSULTA_POLIZA(plzas_temp(plzas_temp.Last).NUMERO_POLIZA, plzas_temp(plzas_temp.Last).NUMERO_SOLICITUD, plzas_temp(plzas_temp.Last).INICIO_VIGENCIA_POLIZA, plzas_temp(plzas_temp.Last).FIN_VIGENCIA_POLIZA, plzas_temp(plzas_temp.Last).DIRECCION);
          End If;
        End If;
                p_codigo_respuesta:=Sqlcode;
                P_MENSAJE_RESPUESTA :='Consulta exitosa';
       Exception 
        When No_Data_Found Or Subscript_Beyond_Count Then
           P_MENSAJE_RESPUESTA :='No se encontraron polizas asociadas al documento: '||p_numero_identificacion;
           p_codigo_respuesta:=Sqlcode;
        When Others Then
          P_MENSAJE_RESPUESTA :=Sqlerrm;
          p_codigo_respuesta:=Sqlcode; 
           
  End PRC_CONSULTAR_PLZAS_ASCDAS;



   -- Author  : Asesoftware - Jorge Gallo.
  -- Created : 24/08/2017.
  -- Purpose :  Procedimiento que permite consultar los valores asegurados por mes de una solicitud en especifico
  -- Modificado por:
  --
  --
Procedure PRC_CONSULTAR_ASEGURADOS_MES(
      P_NUMERO_SOLICITUD In NUMBER,
      P_FECHA_MORA       In DATE,
      P_TABLE_ASEGURADOS_MES Out T_TABLE_ASEGURADOS_MES,
      P_CODIGO_RESPUESTA Out VARCHAR2,
      P_MENSAJE_RESPUESTA Out VARCHAR2 )
  As
    Cursor riesgos_cursor (p_concepto VARCHAR2)
    Is
      Select Valor_Aseg, --obtiene los valores asegurados de los meses anteriores para concepto 1
        concepto,
        Decode ( Substr(periodo,1,2),'01','Enero','02','Febrero','03','Marzo','04','Abril', '05','Mayo','06','Junio','07','Julio','08','Agosto','09','Septiembre','10','Octubre', '11','Noviembre','12','Diciembre','mes') Mes,
        To_Date(periodo,'MM-YYYY'),
        Substr(periodo,1,2) NUMERO_MES
      From Riesgos_Asegurados
      Where Solicitud = p_numero_solicitud
      And concepto    = p_concepto
      And To_Date(periodo,'MM-YYYY') Between P_FECHA_MORA And Add_Months(Sysdate, -1)
    Union
    Select rvl_vlor, --obtiene los valores asegurados del último mes para concepto 1
      rvl_cncpto_vlor,
      Decode(To_Char(Sysdate,'MM'),'01','Enero','02','Febrero','03','Marzo','04','Abril', '05','Mayo','06','Junio','07','Julio','08','Agosto','09','Septiembre','10','Octubre', '11','Noviembre','12','Diciembre','mes') Mes,
      To_Date(Null),
      To_Char(Sysdate,'MM') NUMERO_MES
    From Rsgos_Vgntes_Avlor
    Where rvl_nmro_item = p_numero_solicitud
    And rvl_cncpto_vlor = p_concepto
    Order By 4;
    Cursor riesgos_cursor2 (p_concepto VARCHAR2)
    Is
      Select Valor_Aseg,--obtiene los valores asegurados de los meses anteriores para concepto 2
        concepto,
        Decode ( Substr(periodo,1,2),'01','Enero','02','Febrero','03','Marzo','04','Abril', '05','Mayo','06','Junio','07','Julio','08','Agosto','09','Septiembre','10','Octubre', '11','Noviembre','12','Diciembre','mes') Mes,
        To_Date(periodo,'MM-YYYY')
      From Riesgos_Asegurados
      Where Solicitud = p_numero_solicitud
      And concepto    = p_concepto
      And To_Date(periodo,'MM-YYYY') Between P_FECHA_MORA And Add_Months(Sysdate, -1)
    Union
    Select rvl_vlor,--obtiene los valores asegurados del último mes para concepto 2
      rvl_cncpto_vlor,
      Decode(To_Char(Sysdate,'MM'),'01','Enero','02','Febrero','03','Marzo','04','Abril', '05','Mayo','06','Junio','07','Julio','08','Agosto','09','Septiembre','10','Octubre', '11','Noviembre','12','Diciembre','mes') Mes,
      To_Date(Null)
    From Rsgos_Vgntes_Avlor
    Where rvl_nmro_item = p_numero_solicitud
    And rvl_cncpto_vlor = p_concepto
    Order By 4;
    i Binary_Integer :=0;
    E_SIN_DATOS Exception;
  Begin
  P_TABLE_ASEGURADOS_MES:= T_TABLE_ASEGURADOS_MES();
  -- recorre los riesgos correspondientes al concepto 1
    For riesgos_record In riesgos_cursor('01') 
    Loop
                  i                               :=i+1;
      P_TABLE_ASEGURADOS_MES.Extend();
      P_TABLE_ASEGURADOS_MES(i) := T_ASEGURADOS_MES(riesgos_record.mes,riesgos_record.Valor_Aseg,0,riesgos_record.numero_mes);
      For riesgos_record2 In riesgos_cursor2('02') --recorre los riesgos correspondientes al concepto 2
      Loop
        If(riesgos_record2.mes                      = riesgos_record.mes) Then
          p_table_asegurados_mes(i).administracion := riesgos_record2.Valor_Aseg;
        End If;
      End Loop;
    End Loop;
    If (i<=0) Then
    Raise E_SIN_DATOS;
    End If;
     p_codigo_respuesta:=Sqlcode;
    P_MENSAJE_RESPUESTA :='Consulta exitosa';    
    Exception 
        When E_SIN_DATOS Then
              P_MENSAJE_RESPUESTA :='No se encontraron riesgos asegurados relacionados a la solicitud: '||p_numero_solicitud;
           p_codigo_respuesta:=Sqlcode;
        When Others Then
         P_MENSAJE_RESPUESTA :=Sqlerrm;
          p_codigo_respuesta:=Sqlcode;
   End PRC_CONSULTAR_ASEGURADOS_MES;

/*
      Nombre:           PRC_CONSULTAR_FECHAS_SINIESTRO
      Autor:            jgallo(asw)
      Fecha_creacion:   21-09-2017
      fecha_mod:        21-09-2017
      proposito:        Obtiene una lista con las fechas de mora e información de los siniestros asociados a una solicitud
    */
    Procedure PRC_CONSULTAR_FECHAS_SINIESTRO(P_NUMERO_SOLICITUD In VARCHAR2, PO_TB_TY_DATOS_SINIESTRO Out TB_TY_DATOS_SINIESTRO, po_Codigo    Out     VARCHAR2 , 
    po_Mensaje   Out     VARCHAR2 ) As
       Cursor SINIESTROS_CURSOR Is
          Select  sna_fcha_snstro, sna_nmro_snstro,
            (Select apr_dscrpcion
            From Ampros_Snstros, Ampros_Prdcto
            Where ams_nmro_snstro = sna_nmro_snstro
            And apr_cdgo_ampro = ams_cdgo_ampro) amparo,
          Decode(sna_estdo_snstro,'01','N','V') estado_snstro
          From Avsos_Snstros
          Where sna_nmro_item = P_NUMERO_SOLICITUD
          And sna_estdo_snstro In ('01','02');
          i int := 0;
        E_SIN_DATOS Exception;
    Begin
      PO_TB_TY_DATOS_SINIESTRO := TB_TY_DATOS_SINIESTRO();
      For SINIESTROS_RECORD In SINIESTROS_CURSOR Loop
        i := i+1;
        PO_TB_TY_DATOS_SINIESTRO.Extend();
        PO_TB_TY_DATOS_SINIESTRO(i) := TY_DATOS_SINIESTRO(SINIESTROS_RECORD.sna_fcha_snstro,
                                                      SINIESTROS_RECORD.sna_nmro_snstro,
                                                      SINIESTROS_RECORD.amparo,
                                                      SINIESTROS_RECORD.estado_snstro);
      End Loop;
      If(i<=0) Then
        Raise E_SIN_DATOS;
      End If;
      PO_CODIGO := Sqlcode;
      PO_MENSAJE :='Consulta exitosa';  
    Exception 
        When E_SIN_DATOS Then
          PO_CODIGO := Sqlcode;
          PO_MENSAJE := 'No se encontraron siniestros relacionados a la solicitud '||P_NUMERO_SOLICITUD;
        When Others Then
          PO_CODIGO := Sqlcode;
          PO_MENSAJE := Sqlerrm;
    End PRC_CONSULTAR_FECHAS_SINIESTRO;
    
   /*Nombre:           PRC_CONSULTA_ESTADO_SINIESTRO
  Autor:            jgallo(asw)
  Fecha_creacion:   12-10-2017
  fecha_mod:        12-10-2017
  proposito:        Obtiene información de estado de siniestro y estado de pago relacionadas a una solicitud
  */
  Procedure PRC_CONSULTAR_ESTADO_SINIESTRO(
      PI_NUMERO_SOLICITUD In NUMBER,
      PI_FECHA_MORA       In DATE,
      PO_ESTADO_SINIESTRO Out VARCHAR2,
      PO_ESTADO_PAGO Out VARCHAR2,
      PO_CODIGO Out VARCHAR2,
      PO_MENSAJE Out VARCHAR2)
  As
  Begin
    Select sna_estdo_snstro,
      sna_estdo_pgo
    Into po_Estado_Siniestro,
      po_Estado_Pago
    From Avsos_Snstros
    Where sna_nmro_item = PI_NUMERO_SOLICITUD
    And sna_fcha_snstro = PI_Fecha_Mora;
    PO_CODIGO := Sqlcode;
    PO_MENSAJE := 'Consulta exitosa';
  Exception
  When No_Data_Found Then
    po_Codigo  := Sqlcode;
    po_Mensaje := 'No se encontraron  el estado siniestro ni  estado pago para la solicitud: '||PI_NUMERO_SOLICITUD ;
  When Others Then
    PO_CODIGO := Sqlcode;
    PO_MENSAJE := Sqlerrm;
  End PRC_CONSULTAR_ESTADO_SINIESTRO;
    
    /*Nombre:           PRC_CONSULTA_INFORMACION_DOCUMENTOS
  Autor:            jgallo(asw)
  Fecha_creacion:   17-10-2017
  fecha_mod:        17-10-2017
  proposito:        Obtiene información relacionada al arrendatario y al inmueble
  */
    Procedure PRC_CONSULTA_INFO_DOCUMENTO(PI_NUMERO_SOLICITUD In NUMBER,PO_NOMBRE_INQUILINO Out VARCHAR2,
                                              PO_DOCUMENTO Out VARCHAR2, PO_DIRECCION Out VARCHAR2,PO_CANON Out NUMBER
                                              ,PO_CODIGO_RESPUESTA Out VARCHAR, PO_MENSAJE_RESPUESTA Out VARCHAR2) As
      V_ESTADO_SOLICITUD VARCHAR2(2);
      e_negocio         Exception;
      v_Existe          number(1);
      v_concepto        varchar2(2) := '01';--canon
    Begin
    /*
      LA INFORMACIÓN DE INQUILINO ES DIFERENTES PARA TODOS Y LA DE RT SE REVISA EN RSGOS_RCBOS_AVLOR, SELECCIONANDO EL MÁXIMO CERTIFICADO
    */
    --estado solicitud
      v_estado_solicitud := F_CONSULTAR_ESTADO_SOLICITUD(PI_NUMERO_SOLICITUD);
      --canon
      PO_CANON := F_VALOR_ASEGURADO_CONCEPTO(PI_NUMERO_SOLICITUD, V_ESTADO_SOLICITUD, v_concepto);
      Begin -- información del inquilino
        If V_ESTADO_SOLICITUD = 'ES' Then
          Select arr_nmro_idntfccion,Pk_Terceros.f_nombres(arr_nmro_idntfccion, arr_tpo_idntfccion)
          Into PO_DOCUMENTO, PO_NOMBRE_INQUILINO
          From Arrndtrios
          Where arr_nmro_slctud = PI_NUMERO_SOLICITUD;
        End If;
        If V_ESTADO_SOLICITUD = 'AS' Then
          Select rva_prs_nmro_idntfccion,Pk_Terceros.f_nombres(rva_prs_nmro_idntfccion, rva_prs_tpo_idntfccion)
          Into PO_DOCUMENTO, PO_NOMBRE_INQUILINO
          From Rsgos_Vgntes_Ampro
          Where rva_nmro_item = PI_NUMERO_SOLICITUD 
          And rva_cdgo_ampro = '01';
        End If;
        If V_ESTADO_SOLICITUD = 'RT' Then
          Select rra_nmro_idntfccion,Pk_Terceros.f_nombres(rra_nmro_idntfccion, rra_tpo_idntfccion)
          Into PO_DOCUMENTO, PO_NOMBRE_INQUILINO
          From Rsgos_Rcbos_Ampro
          Where rra_nmro_item = PI_NUMERO_SOLICITUD
          And rra_cdgo_ampro = '01';
        End If;
        Exception 
          When No_Data_Found Then
            PO_MENSAJE_RESPUESTA := 'Error obteniendo el inquilino';
            Raise e_negocio;
       End;     
          
      Begin --dirección
          Select DI_DIRECCION
          Into po_direccion
          From Direcciones
          Where di_solicitud = PI_NUMERO_SOLICITUD
          And di_tpo_drccion = Decode(V_ESTADO_SOLICITUD,'ES', 'E','R');
          Exception When Others Then
            po_mensaje_respuesta:= 'Error obteniendo la dirección: '||Sqlerrm;
            Raise e_negocio;
      End;    
          po_codigo_respuesta := Sqlcode;
          po_mensaje_respuesta := 'Consulta exitosa';
      Exception 
        When E_NEGOCIO Then
              po_codigo_respuesta := Sqlcode;
              PO_MENSAJE_RESPUESTA := PO_MENSAJE_RESPUESTA;
        When Others Then
              po_codigo_respuesta := Sqlcode;
              PO_MENSAJE_RESPUESTA := Sqlerrm;          
    End PRC_CONSULTA_INFO_DOCUMENTO;
    
    
    /*
      Nombre:           prc_cons_datos_inquilino
      Autor:            jpmoreno(asw)
      Fecha_creacion:   20-10-2017
      fecha_mod:        20-10-2017
      proposito:        procedimiento  consultar el listado de siniestros de una solicitud                   
    */
Procedure prc_cons_datos_inquilino (Solicitud NUMBER, POLIZA NUMBER, CLASE VARCHAR2, RAMO VARCHAR2,po_tipo_id Out VARCHAR2,po_id Out number,po_nombre Out varchar2 )
Is

Begin
  Begin
    Select RVI_PRS_TPO_IDNTFCCION,RVI_PRS_NMRO_IDNTFCCION,Pk_Terceros.F_NOMBRES(RVI_PRS_NMRO_IDNTFCCION,RVI_PRS_TPO_IDNTFCCION) PRS_NMBRE 
      Into po_tipo_id,po_id,po_nombre
      From Rsgos_Vgntes
     Where RVI_NMRO_ITEM = Solicitud
       And RVI_NMRO_PLZA = POLIZA
       And RVI_CLSE_PLZA = CLASE
       And RVI_RAM_CDGO  = RAMO
       And Rownum        = 1;
  Exception
    When No_Data_Found Then
      Begin
        Select RIR_TPO_IDNTFCCION,RIR_NMRO_IDNTFCCION,Pk_Terceros.F_NOMBRES(RIR_NMRO_IDNTFCCION,RIR_TPO_IDNTFCCION) PRS_NMBRE
          Into po_tipo_id,po_id,po_nombre
          From Rsgos_Rcbos
         Where RIR_NMRO_ITEM = Solicitud
           And rir_nmro_crtfcdo > 0
           And RIR_NMRO_PLZA = POLIZA
           And RIR_CLSE_PLZA = CLASE
           And RIR_RAM_CDGO  = RAMO
           And RIR_FCHA_MDFCCION = (Select Max(RIR_FCHA_MDFCCION)
                                      From Rsgos_Rcbos
                                               Where RIR_NMRO_ITEM = Solicitud
                                       And rir_nmro_crtfcdo  > 0
                                               And RIR_NMRO_PLZA = POLIZA
                                             And RIR_CLSE_PLZA = CLASE
                                       And RIR_RAM_CDGO  = RAMO
                                   );

      Exception
        When No_Data_Found  Then
             po_id  :=  Null;
        When Too_Many_Rows  Then
             po_id  :=  Null;
      End;
    When Too_Many_Rows Then
        po_id  :=  Null;

  End;
End;
    
      /*
      Nombre:           prc_consulta_siniestro
      Autor:            jpmoreno(asw)
      Fecha_creacion:   20-10-2017
      fecha_mod:        20-10-2017
      proposito:        procedimiento  consultar el listado de siniestros de una solicitud                   
    */
    Procedure prc_consulta_siniestros ( pi_nro_solicitud In number, pi_nit_inmobiliaria In NUMBER, po_siniestros  Out  ty_tb_sini_basico ,  po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 )
    Is 
   v_direccion     varchar2(40);
    v_clase         varchar2(2) := '00';
    v_ramo          varchar2(2) := '12';
    v_tipo_id       varchar2(2);
    v_id            number(12);
    v_nombre        varchar2(500);
    v_pos           varchar2(3);
    v_cont          number(6) := 0;    
    e_sin_datos     Exception;
    Begin
        po_siniestros := ty_tb_sini_basico();
        v_pos := '001';
        For r In ( Select sna_nmro_item,
             sna_nmro_plza,
             sna_nmro_snstro, 
             sna_fcha_snstro, 
              (Select RV_MEANING 
              From Cg_Ref_Codes f
              Where f.rv_domain = 'ESTADO_SINIESTRO'
              And RV_LOW_VALUE  = SNA_ESTDO_SNSTRO) Estado,
              (Select APR_DSCRPCION 
              From Ampros_Snstros , Ampros_Prdcto 
              Where AMS_NMRO_SNSTRO = SNA_NMRO_SNSTRO
              And AMS_CDGO_AMPRO = APR_CDGO_AMPRO) AMPARO
             From Avsos_Snstros
             Where sna_nmro_item = pi_nro_solicitud)
        Loop
            v_cont := v_cont+1;
            v_pos := '005';
        --datos del inquilino
            prc_cons_datos_inquilino (pi_nro_solicitud, 
                                      r.sna_nmro_plza,  
                                      v_clase, 
                                      v_ramo,
                                      v_tipo_id,
                                      v_id,
                                      v_nombre);
         v_pos := '010';
          -- dirección del inquilino
          Begin
            Select DI_DIRECCION
            Into v_direccion
            From Direcciones
            Where di_solicitud = pi_nro_solicitud
            And di_tpo_drccion = 'R';
            Exception 
              When No_Data_Found Then
                PO_CODIGO:= Sqlerrm;
                PO_MENSAJE := 'Error en consulta de dirección. No existe para la solicitud: '||pi_nro_solicitud;
                Raise;
          End;
          v_pos := '015';
            po_siniestros.Extend();
            po_siniestros(v_cont) := TY_REG_SINI_BASICO(r.sna_nmro_item,
                                                        r.sna_fcha_snstro,
                                                        r.sna_nmro_snstro,
                                                        r.sna_nmro_plza,
                                                        v_id,
                                                        v_nombre,
                                                        v_direccion,
                                                        r.Estado,
                                                        r.AMPARO);    
        v_pos := '020';
        
        End Loop;        
         v_pos := '025';  
        If(v_cont <= 0) Then
            Raise E_SIN_DATOS;
          End If;
        PO_CODIGO := 0;
        po_mensaje:= 'Consulta exitosa';
        Exception 
          When E_SIN_DATOS Then
            PO_CODIGO := -90;
            PO_MENSAJE := 'No existen siniestros asociados a la solicitud '||pi_nro_solicitud;
          When Others Then
            PO_CODIGO := Sqlcode;
            PO_MENSAJE := '- '||v_pos||'- Error inesperado en consulta de siniestros: '||po_mensaje||' - ' ||Sqlerrm;   
    End prc_consulta_siniestros ; 
                                                                                      
      /*
      Nombre:           PRC_CONSULTA_DETALLE_SINIESTRO
      Autor:            jgallo(asw)
      Fecha_creacion:   30-10-2017
      fecha_mod:        30-10-2017
      proposito:        Procedimiento que retorna el detalle de un siniestro
    */
    Procedure PRC_CONSULTA_DETALLE_SINIESTRO ( pi_nro_solicitud In number, pi_fcha_mora In date, po_ty_detalle_siniestro  Out  ty_detalle_siniestro ,  po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 ) As
    vg_pos number(3);
    v_ramo varchar2(2) := '12';
    v_clase varchar2(2) := '00';
    E_NEGOCIO Exception;
    V_CONT NUMBER := 1;
    --DATOS GENERALES
    V_DTOS_DTLLE_SNSTRO       TY_DTOS_DTLLE_SNSTRO;
    V_NMRO_SOLICITUD NUMBER(10);
    V_FECHA_MORA     DATE;
    V_ESTADO_PAGO    VARCHAR2(50);
    V_ESTADO_SINIESTRO VARCHAR2(50);
    V_UBICACION_CASO  VARCHAR2(20);
    V_SUCURSAL       VARCHAR2(100);
    V_MESES_DESFASE  NUMBER(10);
    V_DIAS_DESFASE   NUMBER(10);
    V_FECHA_DESOCUPA DATE;
    V_FECHA_CONTRATO DATE;
    V_FECHA_RETIRO_SINI DATE;
    V_DIRECCION      VARCHAR2(200);
    V_CIUDAD         VARCHAR2(100);
    v_poliza         NUMBER(10);
    V_NMRO_SNSTRO     NUMBER(10);
    V_AMPARO          VARCHAR2(200);
    
    --CONCEPTOS
    V_CONCEPTOS_SINIESTRO   TB_TY_CONCEPTOS_SINIESTRO;
    Cursor CONCEPTOS_CURSOR(P_NMRO_SNSTRO NUMBER) Is
      Select VSN_CNCPTO_VLOR,
      (Select rvl_vlor
          From Rsgos_Vgntes_Avlor
          Where rvl_nmro_item = pi_nro_solicitud
          And rvl_cncpto_vlor = VSN_CNCPTO_VLOR)  VALOR_ASEG,
          Decode(VSN_CDGO_AMPRO,'01',(Select rvl_vlor
          From Rsgos_Vgntes_Avlor
          Where rvl_nmro_item = pi_nro_solicitud
          And rvl_cncpto_vlor = VSN_CNCPTO_VLOR),VSN_VLOR_CNSTTDO) VALOR_SINIESTRADO
      From Vlres_Snstros, Vlres_Prdcto V
      Where VSN_NMRO_SNSTRO =  P_NMRO_SNSTRO
      And VSN_CNCPTO_VLOR = V.VPR_CDGO        
      And V.VPR_ESTDO_CNTA = 'S'
      Order By 1;
      
    --OBJECIONES
    V_OBJECIONES            TB_TY_OBJECION_SUSPENSION;
    Cursor OBJECIONES_CURSOR(P_NMRO_NSTRO NUMBER) Is
          Select OS.OBS_CDGO_OBJCION CODIGO, O.OBP_DSCRPCION DESCRIPCION
          From Objcnes_Snstros OS, Objcnes_Prdctos O
          Where OS.OBS_NMRO_SNSTRO = P_NMRO_NSTRO
          And OS.OBS_CDGO_OBJCION = O.OBP_CDGO
          Order By 1;
    
    --SUSPENSIONES
    V_SUSPENSIONES          TB_TY_OBJECION_SUSPENSION;
    Cursor SUSPENSIONES_CURSOR(P_NMRO_NSTRO NUMBER) Is
        Select OS.SSN_CDGO_SSPNSION CODIGO, O.SPR_DSCRPCION DESCRIPCION
        From Sspnsnes_Snstros OS, Sspnsnes_Prdcto O
        Where OS.SSN_NMRO_SNSTRO = P_NMRO_NSTRO
        And OS.SSN_CDGO_AMPRO = O.SPR_CDGO_AMPRO
        And OS.SSN_CDGO_SSPNSION = O.SPR_CDGO
        Order By 1;
 
    --AUMENTOS
    V_AUMENTOS              TB_TY_AUMENTOS_SINIESTRO;
    Cursor AUMENTOS_CURSOR(P_NMRO_NSTRO NUMBER) Is
          Select M.AMN_CNCPTO concepto,M.AMN_FCHA_AMNTO fecha , Sum(M.AMN_VLOR) valor
          From Amntos_Snstros M      
          Where AMN_NMRO_SNSTRO = P_NMRO_NSTRO
          Group By M.AMN_CNCPTO,M.AMN_FCHA_AMNTO
          Order By 1;
          
    --ESTADO DE CUENTA
    V_ESTADO_CUENTA         TB_TY_ESTADO_CUENTA;  
    V_SALDO_DEUDA           NUMBER(30,5);
    --estado de cuenta de conceptos de amparo básico
    Cursor ESTADO_CUENTA_CURSOR_SINI Is
        Select CONCEPTO,FECHA,DEUDA,PAGADO_AGENCIA,PAGO_INQUILINO
          From (
              Select VV.EST_CNCPTO_VLOR CONCEPTO, 
                VV.EST_FCHA_MVTO FECHA,
                Sum(VV.EST_VLOR_CIA) DEUDA,
                Sum(VV.EST_VLOR_CIA) PAGADO_AGENCIA,
                Sum(VV.EST_VLOR_AFNZDO) PAGO_INQUILINO
              From V_ABRESTDCUENTASTT VV
              Where VV.EST_SLCTUD = pi_nro_solicitud
              And VV.EST_FCHA_MRA = pi_fcha_mora
              And EST_CRTRIO_CNSLTA = 'S'
              And EST_ESTADO Like 'PAGADO%'
              And EST_PRDO Not Like 'LIQUIDAC%'  -- linea nueva
              Group By VV.EST_CNCPTO_VLOR,VV.EST_FCHA_MVTO)
          Order By FECHA;
    -- estado de cuenta de conceptos diferentes a amparo básico
    Cursor EST_CUENTA_CURSOR_RECU Is
        Select CONCEPTO,FECHA,DEUDA,PAGADO_AGENCIA,PAGO_INQUILINO
            From (
              Select VV.EST_CNCPTO_VLOR CONCEPTO, VV.EST_FCHA_MVTO FECHA,0 DEUDA, VV.EST_VLOR_CIA PAGADO_AGENCIA,VV.EST_VLOR_AFNZDO PAGO_INQUILINO
              From V_ABRESTDCUENTASTT VV
              Where VV.EST_SLCTUD = pi_nro_solicitud
              And VV.EST_FCHA_MRA = pi_fcha_mora
              And EST_CRTRIO_CNSLTA = 'R'
              And EST_ESTADO Like 'PAGADO%'
            And EST_PRDO Not Like 'LIQUIDAC%')
          Order By FECHA;
    Cursor ESTC_CURSOR_RECU_DEUDA Is
           Select CONCEPTO,FECHA,DEUDA,PAGADO_AGENCIA,PAGO_INQUILINO
            From (
              Select VLD_CNCPTO_VLOR CONCEPTO, Null FECHA,VLD_VLOR_CNSTTDO DEUDA,Null PAGADO_AGENCIA,Null PAGO_INQUILINO
              From Vlres_Ddas, Vlres_Prdcto V
              Where VLD_NMRO_SLCTUD = pi_nro_solicitud
              And VLD_FCHA_MRA = pi_fcha_mora
              And V.VPR_CDGO = VLD_CNCPTO_VLOR
              And V.VPR_ESTDO_CNTA = 'R')
            Order By FECHA;
    Begin
    vg_pos := '005';
    --INICIALIZACIÓN DE TIPOS
    --V_DTOS_DTLLE_SNSTRO :=   TY_DTOS_DTLLE_SNSTRO();
    V_CONCEPTOS_SINIESTRO :=  TB_TY_CONCEPTOS_SINIESTRO();
    V_OBJECIONES          :=  TB_TY_OBJECION_SUSPENSION();
    V_SUSPENSIONES        :=  TB_TY_OBJECION_SUSPENSION();
    V_AUMENTOS            :=  TB_TY_AUMENTOS_SINIESTRO();
    V_ESTADO_CUENTA       :=  TB_TY_ESTADO_CUENTA();  
    
    vg_pos := '010';
      -- DATOS GENERALES DEL SINIESTRO
      Begin
        Select 
        SNA_NMRO_ITEM,
        SNA_NMRO_SNSTRO,
        sna_fcha_snstro, 
        (Select rv_meaning From Cg_Ref_Codes Where rv_domain = 'ESTADO_SINIESTRO' And rv_low_value = SNA_ESTDO_SNSTRO) estado_siniestro,
        (Select rv_meaning From Cg_Ref_Codes Where rv_domain = 'ESTADO_SINIESPAGO' And rv_low_value = SNA_ESTDO_PGO)estado_pago,
        SNA_NMRO_PLZA,
        (Select APR_DSCRPCION
          From Ampros_Snstros , Ampros_Prdcto
          Where AMS_NMRO_SNSTRO = SNA_NMRO_SNSTRO
          And AMS_CDGO_AMPRO = APR_CDGO_AMPRO) AMPARO,
        PKG_REPORTES_JURIDICO.FUN_RET_AREA_CASO(Null,sna_nmro_item,sna_fcha_snstro)UBICACION,
        S.SUC_NMBRE SUCURSAL
        Into
        V_NMRO_SOLICITUD,
        V_NMRO_SNSTRO,
        V_FECHA_MORA,
        V_ESTADO_SINIESTRO,
        V_ESTADO_PAGO,
        v_poliza,
        V_AMPARO,
        V_UBICACION_CASO,
        V_SUCURSAL
        From Avsos_Snstros, Plzas, Scrsl S
        Where sna_nmro_item = pi_nro_solicitud
        And SNA_NMRO_PLZA = POL_NMRO_PLZA
        And POL_SUC_CDGO = S.SUC_CDGO
        And sna_fcha_snstro = pi_fcha_mora
        And S.SUC_CIA_CDGO = '40';
        vg_pos := '020';
        Exception  
          When Others Then
            po_codigo := Sqlcode;
            po_mensaje := vg_pos || ' - Error inesperado consultado datos generales de siniestro:' ||Sqlerrm;
            Raise E_NEGOCIO;
      End;
      vg_pos := '025';
      -- consulta de dirección y ciudad
      Begin
        Select DI_DIRECCION, 
        (Select NOM_CIU
        From V_DIVISION_POLITICAS DP
        Where DP.codazzi_ciu = Di_divpol_codigo)
        Into V_DIRECCION, V_CIUDAD
        From Direcciones
        Where di_solicitud = pi_nro_solicitud
        And di_tpo_drccion = 'R';
        Exception  
          When Others Then
            po_codigo := Sqlcode;
            po_mensaje := vg_pos || ' - Error inesperado consultado dirección:' ||Sqlerrm;
            Raise E_NEGOCIO;
      End;
        vg_pos := '025';
      Begin
       V_FECHA_DESOCUPA := Pkg_Consulta_Indemnizacion.FUN_FECHA_DESOCUPACION(v_nmro_snstro,
                                 v_ramo,
                                 pi_nro_solicitud,
                                 v_fecha_mora);
       V_FECHA_CONTRATO := Pkg_Consulta_Indemnizacion.FUN_FECHA_CONTRATO(pi_nro_solicitud,
                             V_RAMO,
                             V_CLASE,
                             V_POLIZA);
        V_FECHA_RETIRO_SINI := FECHA_RETIRO_SEG(pi_nro_solicitud,
                                  V_POLIZA,
                                  V_CLASE,
                                  V_RAMO,
                                  '01');
         Exception  
          When Others Then
            po_codigo := Sqlcode;
            po_mensaje := vg_pos || ' - Error inesperado:' ||Sqlerrm;
            Raise E_NEGOCIO;
      End;
              vg_pos := '025';
        Begin
          Select Round(DVA_DIAS_DSFSE/30), DVA_DIAS_DSFSE
          Into V_MESES_DESFASE, V_DIAS_DESFASE
          From Ddas_Vgntes_Arrndmntos
          Where DVA_NMRO_SLCTUD = pi_nro_solicitud
          And DVA_FCHA_MRA = V_FECHA_MORA;
          Exception  
          When Others Then
            po_codigo := Sqlcode;
            po_mensaje := vg_pos || ' - Error inesperado consultando meses de desfase:' ||Sqlerrm;
            Raise E_NEGOCIO;
        End;
        vg_pos := '030';
        V_DTOS_DTLLE_SNSTRO := TY_DTOS_DTLLE_SNSTRO(V_NMRO_SOLICITUD,
                                                    V_FECHA_MORA,
                                                    V_ESTADO_PAGO,
                                                    V_ESTADO_SINIESTRO,
                                                    V_UBICACION_CASO,
                                                    V_SUCURSAL,
                                                    V_MESES_DESFASE,
                                                    V_DIAS_DESFASE,
                                                    V_FECHA_DESOCUPA,
                                                    V_FECHA_CONTRATO,
                                                    V_FECHA_RETIRO_SINI,
                                                    V_DIRECCION,
                                                    V_CIUDAD);
        -- CONCEPTOS
             vg_pos := '035';
        Begin
          For CONCEPTOS_RECORD In CONCEPTOS_CURSOR(V_NMRO_SNSTRO) Loop
            V_CONCEPTOS_SINIESTRO.Extend;
            V_CONCEPTOS_SINIESTRO(v_cont) := TY_CONCEPTOS_SINIESTRO(CONCEPTOS_RECORD.VSN_CNCPTO_VLOR,
                                                                    CONCEPTOS_RECORD.VALOR_ASEG);
            V_CONT := V_CONT + 1;
          End Loop;
            Exception
              When Others Then
            po_codigo := Sqlcode;
            po_mensaje := vg_pos || ' - Error inesperado consultando conceptos:' ||Sqlerrm;
            Raise E_NEGOCIO;
        End;
        V_CONT := 1;
        -- OBJECIONES
        vg_pos := '040';
        Begin 
          For OBJ_RECORD In OBJECIONES_CURSOR(V_NMRO_SNSTRO) Loop
              V_OBJECIONES.Extend;
              V_OBJECIONES(V_CONT) := TY_OBJECION_SUSPENSION(OBJ_RECORD.CODIGO,
                                                              OBJ_RECORD.DESCRIPCION);
              V_CONT := V_CONT + 1;
          End Loop;
            Exception
              When Others Then
            po_codigo := Sqlcode;
            po_mensaje := vg_pos || ' - Error inesperado consultando objeciones:' ||Sqlerrm;
            Raise E_NEGOCIO;
        End;
          V_CONT := 1;
          
        -- SUSPENSIONES
          vg_pos := '045';
        Begin 
          For SUSP_RECORD In SUSPENSIONES_CURSOR(V_NMRO_SNSTRO) Loop
              V_SUSPENSIONES.Extend;
              V_SUSPENSIONES(V_CONT) := TY_OBJECION_SUSPENSION(SUSP_RECORD.CODIGO,
                                                              SUSP_RECORD.DESCRIPCION);
              V_CONT := V_CONT + 1;
          End Loop;
            Exception
              When Others Then
            po_codigo := Sqlcode;
            po_mensaje := vg_pos || ' - Error inesperado consultando suspensiones:' ||Sqlerrm;
            Raise E_NEGOCIO;
        End;
        V_CONT := 1;
        
        -- AUMENTOS
        vg_pos := '050';
        Begin
          For AUM_RECORD In AUMENTOS_CURSOR(V_NMRO_SNSTRO) Loop
            V_AUMENTOS.Extend;
            V_AUMENTOS(V_CONT) := TY_AUMENTOS_SINIESTRO(AUM_RECORD.CONCEPTO,
                                                        AUM_RECORD.FECHA,
                                                        AUM_RECORD.VALOR);
            V_CONT := V_CONT + 1;
          End Loop;
          Exception
              When Others Then
            po_codigo := Sqlcode;
            po_mensaje := vg_pos || ' - Error inesperado consultando aumentos:' ||Sqlerrm;
            Raise E_NEGOCIO;
        End;
          v_cont := 1;
          
          --ESTADO DE CUENTA
           vg_pos := '055';
           --SINIESTROS
        Begin
        v_saldo_deuda := 0;
          For EST_RECORD In ESTADO_CUENTA_CURSOR_SINI Loop
             V_ESTADO_CUENTA.Extend;
            V_SALDO_DEUDA := V_SALDO_DEUDA + EST_RECORD.PAGADO_AGENCIA - EST_RECORD.PAGO_INQUILINO;
            V_ESTADO_CUENTA(V_CONT) := TY_ESTADO_CUENTA(EST_RECORD.CONCEPTO,
                                                        EST_RECORD.FECHA,
                                                        EST_RECORD.DEUDA,
                                                        EST_RECORD.PAGADO_AGENCIA,
                                                        EST_RECORD.PAGO_INQUILINO,
                                                        V_SALDO_DEUDA);
            V_CONT := V_CONT + 1;
          End Loop;
        End;
                 vg_pos := '060';  
        -- RECUPERACIONES DEUDA
                
        Begin
                v_saldo_deuda := 0;
          For EST_RECORD In ESTC_CURSOR_RECU_DEUDA Loop
            V_ESTADO_CUENTA.Extend;
            V_SALDO_DEUDA := V_SALDO_DEUDA + EST_RECORD.PAGADO_AGENCIA - EST_RECORD.PAGO_INQUILINO;
            V_ESTADO_CUENTA(V_CONT) := TY_ESTADO_CUENTA(EST_RECORD.CONCEPTO,
                                                        EST_RECORD.FECHA,
                                                        EST_RECORD.DEUDA,
                                                        EST_RECORD.PAGADO_AGENCIA,
                                                        EST_RECORD.PAGO_INQUILINO,
                                                        V_SALDO_DEUDA);
            V_CONT := V_CONT + 1;
          End Loop;
        End;
        
        --RECUPERACIONES
        Begin
        v_saldo_deuda := 0;
          For EST_RECORD In EST_CUENTA_CURSOR_RECU Loop
            V_ESTADO_CUENTA.Extend;
            V_SALDO_DEUDA := V_SALDO_DEUDA + EST_RECORD.PAGADO_AGENCIA - EST_RECORD.PAGO_INQUILINO;
            V_ESTADO_CUENTA(V_CONT) := TY_ESTADO_CUENTA(EST_RECORD.CONCEPTO,
                                                        EST_RECORD.FECHA,
                                                        EST_RECORD.DEUDA,
                                                        EST_RECORD.PAGADO_AGENCIA,
                                                        EST_RECORD.PAGO_INQUILINO,
                                                        V_SALDO_DEUDA);
            V_CONT := V_CONT + 1;
          End Loop;
        End;
        -- LLENADO DE TYPE DE SALIDA
        po_ty_detalle_siniestro := TY_DETALLE_SINIESTRO(V_DTOS_DTLLE_SNSTRO,
                                                        V_CONCEPTOS_SINIESTRO,
                                                        V_OBJECIONES,
                                                        V_SUSPENSIONES,
                                                        V_AUMENTOS,
                                                        V_ESTADO_CUENTA);
        
        po_codigo := Sqlcode;
        po_mensaje := 'Consulta exitosa';
        dbms_output.put_line(v_nmro_snstro);
        Exception
          When E_negocio Then 
            po_Mensaje := po_Mensaje;
          When Others Then
            PO_CODIGO := Sqlcode;
            PO_MENSAJE := vg_pos || ' - Error inesperado: '||Sqlerrm;
          
    End PRC_CONSULTA_DETALLE_SINIESTRO;
    
End Pkg_Interfaces_Consultas;
/
