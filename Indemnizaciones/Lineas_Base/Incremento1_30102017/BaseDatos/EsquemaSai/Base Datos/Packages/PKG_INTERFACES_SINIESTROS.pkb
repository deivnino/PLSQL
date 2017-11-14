Create Or Replace Package Body ADMSISA.Pkg_Interfaces_Siniestros 
Is
-- variables globales
   vg_datos     ty_dtos_bscos_snstro ;
   vg_conceptos tb_repte_cnceptos;
   vg_servicios tb_repte_cnceptos;
   vg_doctos    tb_doctos_snstro;
   
   Vg_vigencia_inicial      date;
   vg_vigencia_final date;
   Vg_desocupacion date;
   vg_tipo_pol   varchar2(1);
   vg_estado_pol varchar2(1);
   vg_tipo_amparo varchar2(1);
   
   --conceptos
   
   --tipo para calcular liquidaciones de meses con aumentos
   Type reg_liq Is Record(
   cod_conc varchar2(2),
   f_ini    date,
   f_fin    date, 
   valor    number(18,2));   
   Type montos_liq Is Table Of reg_liq;
   
   --error para manejo de mensajes de error en el proceso.
   Error_negocio Exception;
 
   
   
    /*
      Nombre:           f_valor_const
      Autor:            jpmoreno(asw)
      Fecha_creacion:   22-08-2017
      fecha_mod:        22-08-2017
      proposito:        funcion para calcular el valor avisado(VA) y el valor constituido (VC)
                        
    */   
   Function f_valor_const(pi_tipo In varchar2) Return number
   Is
    v_valor number(18,2):= 0;
    v_existe varchar2(1);   
   Begin
    For R In 1..vg_conceptos.Count
    Loop
        If pi_tipo = 'VA' Then
        --    DBMS_OUTPUT.PUT_LINE(' valor '|| v_valor|| ' vlr_concepto ' ||vg_conceptos(r).valor_reportado||' cod_concp ' || Vg_conceptos(r).Cod_concepto);
            
            v_valor := v_valor + vg_conceptos(R).Valor_Reportado;
        
        Else --VC
            Begin
                -- se valida si el concepto que se envia corresponde a siniestro o a recuperacion.
                Select Distinct'X'
                Into v_existe
                From Vlres_Prdcto 
                Inner Join Vlres_Ampro_Prdcto  On
                     VPR_CDGO = VAR_CNCPTO_VLOR
                 And VPR_RAM_CDGO  = VAR_RAM_CDGO
                Where Vpr_ram_cdgo = '12'
                And Vpr_cdgo = Vg_conceptos(R).Cod_concepto
                And VAR_CDGO_AMPRO = vg_datos.cod_amparo
                And Vpr_estdo_cnta ='S';
                
                v_valor := Nvl(v_valor,0) + vg_conceptos(R).Valor_Reportado;
                --v_valor := v_valor + vg_conceptos(r).valor_reportado;
            Exception
             When No_Data_Found Then
               Null;
             End;

        End If;
        
    End Loop;
    
    If v_valor =0 Then        
         v_valor := Null;
     End If; 
     
     Return  v_valor;

   End f_valor_const;
  
    /*
      Nombre:           f_valida_cncep_siniestro
      Autor:            jpmoreno(asw)
      Fecha_creacion:   29-08-2017
      fecha_mod:        29-08-2017
      proposito:        Funcion que recorre los coneptos para validar si existen concesptos de siniestro y si la fecha de inicio es maximo de dos meses atras.                       
    */    
   Function f_valida_cncep_siniestro (pi_concep In varchar2 Default Null, 
                                      pi_estado In varchar2 Default 'S', 
                                      po_ind_fecha Out Boolean) Return Boolean
   Is 
   v_cont   number:=0;
   v_var    varchar2(2);
   v_meses  number(2); 
   Begin
    po_ind_fecha := True;
    If vg_tipo_pol = 'C' Then
        v_meses := 2;
    Else
        v_meses := 5;
    End If;
    For R In 1..Vg_conceptos.Count
    Loop
           -- DBMS_OUTPUT.PUT_LINE('Ciclo concepto, cod: '||Vg_conceptos(r).Cod_concepto || pi_concep);
            If pi_concep Is Null Then
               --DBMS_OUTPUT.PUT_LINE('entre por sin concepto, cod: '||Vg_conceptos(r).Cod_concepto);
                Begin    
                    Select Count(1),Vpr_estdo_cnta
                    Into v_cont,v_var
                    From Vlres_Prdcto
                    Where Vpr_ram_cdgo = '12'
                    And Vpr_cdgo = Vg_conceptos(R).Cod_concepto
                    And Vpr_estdo_cnta =pi_estado
                    Group By Vpr_estdo_cnta;
                   -- DBMS_OUTPUT.PUT_LINE('encontre: '||Vg_conceptos(r).Cod_concepto);
                Exception
                When No_Data_Found Then 
                    v_cont:= 0;
                    v_var := Null;
                End;
             Else
               --DBMS_OUTPUT.PUT_LINE('entre por CON concepto, cod: '||Vg_conceptos(r).Cod_concepto || ' - '||pi_concep|| ' - '|| pi_estado);
               Begin
                    Select Count(1),Vpr_estdo_cnta
                    Into v_cont,v_var
                    From Vlres_Prdcto
                    Where Vpr_ram_cdgo = '12'
                    And Vpr_cdgo = Vg_conceptos(R).Cod_concepto
                    And Vpr_cdgo = pi_concep
                    And Vpr_estdo_cnta =pi_estado
                    Group By Vpr_estdo_cnta;
                Exception
                When No_Data_Found Then 
                    v_cont:= 0;
                    v_var := Null;
                End;                   
             End If;
        If v_var = 'S' And v_cont > 0 Then -- si se esta buscando concepto de siniestro
                -- DBMS_OUTPUT.PUT_LINE('Conté : '||v_cont || ' fecha ini '|| Vg_conceptos(r).fecha_ini_reporte ||v_meses );
                If Round(Months_Between(Trunc(Sysdate),Vg_conceptos(R).fecha_ini_reporte )) > v_meses  Then --- se valida que la fecja inicio no sea menor a 60 dias antes del reporte
                    po_ind_fecha := False;    
                End If;
                -- DBMS_OUTPUT.PUT_LINE('Voy a salir ');
                exit;
        Else        -- si se busca concepto de recuperacion 
           --DBMS_OUTPUT.PUT_LINE('entre por el else encontre '||v_cont || ' - '||Vg_conceptos(r).fecha_ini_reporte || ' - '||Round(Months_Between(Trunc(Sysdate),Vg_conceptos(r).fecha_ini_reporte )));
            If v_cont > 0 Then
                If  Round(Months_Between(Trunc(Sysdate),Vg_conceptos(R).fecha_ini_reporte ))> 5 Then  -- si se encontró algun concepto de siniestro sale del ciclo
                    --DBMS_OUTPUT.PUT_LINE('error de fecha: '||Vg_conceptos(r).Cod_concepto);
                    po_ind_fecha := False; 
                Else 
                    po_ind_fecha := True; 
                End If;  
                If pi_concep Is Not Null Or Not po_ind_fecha Then     
                    exit;
                End If;
            End If;
        End If;
        -- DBMS_OUTPUT.PUT_LINE('valores: '||v_cont);
    
    End Loop;
   -- DBMS_OUTPUT.PUT_LINE('Fuera del ciclo');
    If v_cont > 0  Or pi_concep Is Null Then
   -- DBMS_OUTPUT.PUT_LINE('retorno');
        Return True;
    Else
       Return False;              
    End If;
    
    

   End f_valida_cncep_siniestro;
   
   
   /*
      Nombre:           f_calc_diff_conceptos
      Autor:            jpmoreno(asw)
      Fecha_creacion:   11-09-2017
      fecha_mod:        11-09-2017
      proposito:        Funcion que calcula y retorna la diferencia de valores entre 2 meses de siniestro                        
    */  
    Function f_calc_diff_conceptos (pi_montos In  montos_liq) Return number
    Is
    v_first     Boolean:=True;
    v_inicial   number(18,2):=0;
    v_diferencia number(18,2):=0;
    Begin
        For i In 1.. pi_montos.Count
        Loop
            If v_first Then
                v_inicial := pi_montos(i).valor;
                v_first:= False;
            Else 
                v_diferencia := Abs(v_inicial - pi_montos(i).valor);
            End If;
        End Loop;
    Return v_diferencia;
    
    End f_calc_diff_conceptos;
    
    /*
      Nombre:           f_valida_fechas_ab
      Autor:            jpmoreno(asw)
      Fecha_creacion:   05-10-2017
      fecha_mod:        05-10-2017
      proposito:        Funcion valida que las fechas de los conceptos del amparo basico sean iguales                        
    */ 
   Function f_valida_fechas_ab Return Boolean
   Is
      v_fisrt Boolean:= True;
      v_fini    date;
      v_ffin    date;
      v_ind_fecha Boolean ;
   Begin
     For s In 1.. Vg_conceptos.Count
     Loop
     If v_fisrt Then
        v_fini := Vg_conceptos(s).fecha_ini_reporte;
        v_ffin := Vg_conceptos(s).fecha_fin_reporte;
        v_fisrt := False;
     Else
    -- DBMS_OUTPUT.PUT_LINE(' fecha2 '||Vg_conceptos(s).fecha_ini_reporte  || ' fecha1 ' ||v_fini);
    -- DBMS_OUTPUT.PUT_LINE(' fecha4 '||Vg_conceptos(s).fecha_fin_reporte  || ' fecha3 ' ||v_ffin);
        If (Vg_conceptos(s).fecha_ini_reporte <> v_fini Or Vg_conceptos(s).fecha_fin_reporte <> v_ffin) And f_valida_cncep_siniestro(Vg_conceptos(s).cod_concepto,'S',v_ind_fecha)  Then
             Return False;
        End If;  
     End If;
     End Loop;
     Return True;
   
   End f_valida_fechas_ab;
   
   
       /*
      Nombre:           f_valida_periodo_aseg
      Autor:            jpmoreno(asw)
      Fecha_creacion:   06-10-2017
      fecha_mod:        06-10-2017
      proposito:        Funcion valida si el mes que se está evaluando está asegurado                        
    */ 
   Function f_valida_periodo_aseg(pi_t_asegurados In T_TABLE_ASEGURADOS_MES,pi_mes In number )
    Return Boolean
   Is
   Begin
     For c In 1.. pi_t_asegurados.Count
     Loop
         If To_Number(pi_t_asegurados(c).numero_mes)  = pi_mes Then
            Return True;
         End If;
     End Loop;
     Return False;
   End f_valida_periodo_aseg;
   
    /*
      Nombre:           f_calc_valor_reportado
      Autor:            jpmoreno(asw)
      Fecha_creacion:   27-09-2017
      fecha_mod:        27-09-2017
      proposito:        Funcion que calcula y retorna el valor total reportado para servicios publicos                        
    */   
   Function f_calc_valor_reportado  Return number
   Is 
   total number(18,2):= 0;
   Begin 
   For s In 1..vg_servicios.Count
   Loop
        total := total + vg_servicios(s).Valor_Reportado;
   End Loop;
   Return  total; 
   
   
   End f_calc_valor_reportado;
   /*
      Nombre:           f_tipo_amparo
      Autor:            jpmoreno(asw)
      Fecha_creacion:   26-09-2017
      fecha_mod:        26-09-2017
      proposito:        Funcion que retorna el tipo de amparo (B - Basico A - Adicional)                         
    */
    Function f_tipo_amparo ( pi_cod_ampro In varchar2) Return varchar2
    Is 
    v_t_ampro varchar2(2);
    Begin
        --vg_pos := '-20';
        Select APR_TPO_AMPRO
        Into v_t_ampro
        From Ampros_Prdcto
        Where APR_CDGO_AMPRO = pi_cod_ampro
        And APR_RAM_CDGO = '12';
        Return v_t_ampro;
    Exception When Others Then
          Return Null;
    End f_tipo_amparo;

    /*
      Nombre:           prc_calc_rango_serv
      Autor:            jpmoreno(asw)
      Fecha_creacion:   05-10-2017
      fecha_mod:        05-10-2017
      proposito:        procedimiento que calcula y retorna la el rengo de fechas maximo entre los servicios reportados                        
    */  
     Procedure prc_calc_rango_serv (po_fini Out date, po_ffin Out date)
     Is
      v_fisrt Boolean:= True;
     Begin
     For s In 1.. vg_servicios.Count
     Loop
     If v_fisrt Then
        po_fini := vg_servicios(s).fecha_ini_reporte;
        po_ffin := vg_servicios(s).fecha_fin_reporte;
        v_fisrt := False;
     Else
        If vg_servicios(s).fecha_ini_reporte < po_fini Then
            po_fini := vg_servicios(s).fecha_ini_reporte;
        End If; 
        If vg_servicios(s).fecha_fin_reporte > po_ffin Then
            po_ffin := vg_servicios(s).fecha_fin_reporte;
        End If; 
     End If;
     End Loop;
     
     End prc_calc_rango_serv;


    /*
      Nombre:           prc_vlores_desfase
      Autor:            jpmoreno(asw)
      Fecha_creacion:   22-08-2017
      fecha_mod:        22-08-2017
      proposito:        procedimiento para calcular los dias y el valor total de desfase  de los conceptos reportados                        
    */     
    Procedure prc_vlores_desfase (po_dias Out number,po_valor Out number,p_ind_re Out number) 
    Is 
    v_fecha_ini date;
    v_fecha_fin date;
    v_vlr_desfase number(18,2);
    v_msg       varchar2(200);
    v_first         Boolean := False;
    Begin 
     p_ind_re := 0;
     --DBMS_OUTPUT.PUT_LINE(' registros '||vg_conceptos.Count );
     For R In 1..vg_conceptos.Count
     Loop
         If vg_conceptos(R).cod_concepto Like '%RE%' Then
          p_ind_re := 1;
            If Not v_first Then
                v_first := True;
                v_fecha_ini := vg_conceptos(R).fecha_ini_reporte;
                v_fecha_fin := vg_conceptos(R).fecha_fin_reporte;
            Else    
              If v_fecha_ini < vg_conceptos(R).fecha_ini_reporte  Then
                v_fecha_ini := vg_conceptos(R).fecha_ini_reporte;
              End If;
              If v_fecha_fin > vg_conceptos(R).fecha_fin_reporte  Then
                v_fecha_fin := vg_conceptos(R).fecha_fin_reporte;
              End If;
            End If; 
            
         po_valor := Nvl(po_valor,0) +  vg_conceptos(R).Valor_Reportado;
         --DBMS_OUTPUT.PUT_LINE(' total '||po_valor  || ' valor '||vg_conceptos(r).valor_reportado );
        End If;   
     End Loop;
     
     
    po_dias :=  Fu_Resta_Mes30 ( v_fecha_fin ,v_fecha_ini , v_msg );
    
    End prc_vlores_desfase;
 

    /*
      Nombre:           prc_rgstro_gral_siniestro
      Autor:            jpmoreno(asw)
      Fecha_creacion:   22-08-2017
      fecha_mod:        22-08-2017
      proposito:        procedimiento interno que registra datos generales de un siniestro.                         
    */
   Procedure prc_rgstro_gral_siniestro(po_codigo Out number, po_mensaje Out varchar2 )
   Is
   v_dias_desfse number(4);
   v_vlr_desfase number(18,2);
   v_nmro_crtfcdo number(10);
   v_existe      number(4);
   v_liq_separd  varchar2(1);
   v_fecha_ret    date;
   v_valor       number(18,2);
   v_msg        varchar2(200);
   Begin
    vg_pos := '030';
    --se calcula el numero para asignarle al siniestro
    vg_nmro_siniestro := F_Nmrcion_Snstros(12);--ramo 12

   --llenado de la tabla    Ddas_Vgntes_Arrndmntos
       Begin
         vg_pos := '031';
         
         prc_vlores_desfase(v_dias_desfse, v_vlr_desfase,v_existe);
       --  DBMS_OUTPUT.PUT_LINE('Valores devueltos: '||v_dias_desfse ||' --'||v_vlr_desfase);
         If (v_vlr_desfase Is Null And v_dias_desfse  Is Null And v_existe =0) Or -- caso en que no viene recuperaciones permite inserar ceros
            (v_vlr_desfase Is Not Null And v_dias_desfse  Is Not Null And v_existe =1)  Then --caso en que si hay recuperaciones debe venir valores de desfase
             Insert Into Ddas_Vgntes_Arrndmntos
             Values(vg_datos.Nro_solicitud ,vg_datos.fecha_mora ,Nvl(v_dias_desfse,0),Nvl(v_vlr_desfase,0),Null,'S',vg_datos.nit_tercero,Sysdate,Null,         
                    '01',Null,Null,Null);

         Elsif v_existe =1 Then
          po_codigo := -96;
          po_mensaje := vg_pos || ' - '|| 'error al calcular los dias de desfase:'||po_mensaje ;
          Raise Error_negocio;                
        End If;
       Exception
       When Error_negocio Then
          Raise Error_negocio;
       When Others Then 
          po_codigo := Sqlcode;
          po_mensaje := vg_pos || ' - '|| 'Error al insertar en la tabla Ddas_Vgntes_Arrndmntos:'||Sqlerrm ;
          Raise Error_negocio;
       End;   
        -- validaciones para amparos adicionales.
      If vg_tipo_amparo = 'A' Then 
         v_valor := F_Valor_Asegurado(vg_datos.Nro_solicitud, vg_datos.Nro_poliza, vg_datos.cod_amparo , '12',v_msg);
          --doc
          If v_valor Is Null Then
              po_codigo := -77;
              po_mensaje := vg_pos || ' - '|| 'error,no se encontro valor asegurado para el amparo reportado.';
              Raise Error_negocio;
          End If;
            --doc
          If f_valor_const('VA') > v_valor Then
              po_codigo := -78;
              po_mensaje := vg_pos || ' - '|| 'error, el valor avisado es mayor al valor asegurado para los conceptos reportados';
              Raise Error_negocio;
          End If;
           --doc
          If Vg_desocupacion Is Null Then
              po_codigo := '-78';
              po_mensaje := vg_pos || ' - '|| 'error,no se encontro fecha de desocupacion para el riesgo asociado a la solicitud';
              Raise Error_negocio;
          End If;
           --doc
           v_fecha_ret := Fecha_Retiro_Seg(vg_datos.Nro_solicitud,vg_datos.Nro_poliza, '00', '12',vg_datos.cod_amparo);
          If  v_fecha_ret Is Null Then
              If vg_tipo_pol = 'I' Then
               Select Count(1)
               Into  v_existe
               From Rsgos_Rcbos
               Where rir_nmro_item = vg_datos.Nro_solicitud
               And Not Exists (Select 1 From Rsgos_Vgntes
                               Where rvi_nmro_item = rir_nmro_item)
               And RIR_NMRO_CRTFCDO = (Select Max(RIR_NMRO_CRTFCDO)
                                      From Rsgos_Rcbos
                                      Where rir_nmro_item =vg_datos.Nro_solicitud);
                If v_existe >= 1 Then
                   v_fecha_ret := Vg_vigencia_inicial;
                End If;
              End If;
              If v_fecha_ret Is Null Then
                  po_codigo := '-79';
                  po_mensaje := vg_pos || ' - '|| 'error,no se encontro fecha de retiro para el riesgo asociado a la solicitud';
                  Raise Error_negocio;
              End If;
          End If;
          -- validaciones para amparo integral.
          If vg_datos.cod_amparo = '08' Then
           --doc
              If vg_servicios.Count = 0 Then 
                po_codigo := -79;
                po_mensaje := vg_pos || ' - '|| 'para el siniestro de amparo integral se debe enviar el detalle de los servicios sinesitrados:' ;
                Raise Error_negocio; 
              Else
                  --doc
                  If f_valor_const('VA') <> f_calc_valor_reportado Then
                      po_codigo := -77;
                      po_mensaje := vg_pos || ' - '|| 'error,hay inconsistencias entre el valor reportado en el concepto y el detalle de servicios.';
                      Raise Error_negocio;
                  End If;                            
                   --doc
                  If f_calc_valor_reportado > v_valor Then
                         po_codigo := -80;
                      po_mensaje := vg_pos || ' - '|| 'error, el valor avisado es mayor al valor asegurado para los servicios reportados';
                      Raise Error_negocio;
                  End If;
              End If;
          End If;
      End If;

 -- llenado de tabla de avisos siniestros
        Begin
         vg_pos := '032';
         If vg_tipo_pol = 'C' Then
             Select Max(cer_nmro_crtfcdo)
             Into v_nmro_crtfcdo
             From Crtfcdos
             Where  cer_nmro_plza = vg_datos.Nro_poliza
             And To_Char(cer_fcha_prdccion,'MMYYYY') = To_Char(Sysdate,'MMYYYY');
         Else
            Select Max(cer_nmro_crtfcdo)
             Into v_nmro_crtfcdo
             From Crtfcdos
             Where  cer_nmro_plza = vg_datos.Nro_poliza;
         End If;
         
         vg_pos := '033';
        -- DBMS_OUTPUT.PUT_LINE(' avisado '||f_valor_const('VA') || 'const ' ||f_valor_const('VC') );
         --doc
         If f_valor_const('VC') Is Null Then 
              po_codigo := -85;
              po_mensaje := vg_pos || ' - '|| 'error, no se encontró valor constituido debido a que el concepto reportado no corresponde al amparo reportado.';
              Raise Error_negocio;
         End If;
         vg_pos := '234';
         Insert Into Avsos_Snstros
         Values(vg_datos.Nro_solicitud ,vg_nmro_siniestro,'01',vg_datos.Nro_poliza ,'00','12',
                Sysdate,vg_datos.fecha_mora,f_valor_const('VA'), f_valor_const('VC'),0,
                '01','00',0,Sysdate,0,
                v_nmro_crtfcdo, 
                vg_datos.nit_tercero,
                Sysdate,Null,Null,'C',Null,Null,Null,Null,Null,Null,Null,Null,Null
                --,Null,Null
                );

       Exception
       When Error_negocio Then
            Raise Error_negocio;
       When Others Then 
          po_codigo := Sqlcode;
          po_mensaje := vg_pos || ' - '|| 'Error al insertar en la tabla Avsos_Snstros:'||Sqlerrm ;
          Raise Error_negocio;
       End;


   --llenado de la tabla    Ampros_Snstros
       Begin
         vg_pos := '035';

         Insert Into Ampros_Snstros
         Values(vg_nmro_siniestro, vg_datos.cod_amparo,'12',vg_datos.Nro_solicitud,vg_datos.fecha_mora ,
         v_nmro_crtfcdo, '01',f_valor_const('VA'), f_valor_const('VC'),0,'02',vg_datos.nit_tercero,Sysdate);


       Exception
       When Error_negocio Then
          Raise Error_negocio;
       When Others Then 
          po_codigo := Sqlcode;
          po_mensaje := vg_pos || ' - '|| 'Error al insertar en la tabla Ampros_Snstros:'||Sqlerrm ;
           Raise Error_negocio;
       End;
   
      --llenado de la tabla    Ddas_Arrndtrios
       Begin
         vg_pos := '040';
         
         Select Count(1)
         Into v_existe
         From Rsgos_Vgntes_Nits
         Where Rvn_nmro_item = Vg_datos.Nro_solicitud
         And RVN_NMRO_PLZA = vg_datos.Nro_poliza
         And RVN_RAM_CDGO = '12'
         And RVN_CLSE_PLZA = '00'; 
         
        If v_existe > 0 Then
             Insert Into Ddas_Arrndtrios
             Select Vg_datos.Nro_solicitud,Vg_datos.Fecha_mora,Rvn_tpo_nit,Rvn_prs_tpo_idntfccion,Rvn_prs_nmro_idntfccion,vg_datos.Nro_poliza,'00','12'        
             From Rsgos_Vgntes_Nits
             Where Rvn_nmro_item = Vg_datos.Nro_solicitud
             And RVN_NMRO_PLZA = vg_datos.Nro_poliza
             And RVN_RAM_CDGO = '12'
             And RVN_CLSE_PLZA = '00';
        Else      
            vg_pos := '041';
             Select Count(1)
             Into v_existe
             From Rsgos_Rcbos_Nits r
             Where Rrn_nmro_item = Vg_datos.Nro_solicitud
             And Rrn_nmro_plza = vg_datos.Nro_poliza
             And Rrn_ram_cdgo = '12'
             And Rrn_clse_plza = '00'
             And RRN_NMRO_CRTFCDO = (Select Max(R1.RRN_NMRO_CRTFCDO)
                                      From Rsgos_Rcbos_Nits R1
                                     Where R1.Rrn_nmro_item = R.Rrn_nmro_item
                                       And R1.Rrn_nmro_plza = R.Rrn_nmro_plza);    

            If v_existe > 0 Then
                 Insert Into Ddas_Arrndtrios
                 Select Vg_datos.Nro_solicitud,Vg_datos.Fecha_mora,Rrn_tpo_nit,Rrn_tpo_idntfccion,Rrn_nmro_idntfccion,vg_datos.Nro_poliza,'00','12'        
                 From Rsgos_Rcbos_Nits r
                 Where Rrn_nmro_item = Vg_datos.Nro_solicitud
                 And Rrn_nmro_plza = vg_datos.Nro_poliza
                 And Rrn_ram_cdgo = '12'
                 And Rrn_clse_plza = '00'
                 And RRN_NMRO_CRTFCDO = (Select Max(R1.RRN_NMRO_CRTFCDO)
                                      From Rsgos_Rcbos_Nits R1
                                     Where R1.Rrn_nmro_item = R.Rrn_nmro_item
                                       And R1.Rrn_nmro_plza = R.Rrn_nmro_plza);
            Else
                po_codigo := '3321';
                po_mensaje := vg_pos || ' - '|| 'no se encontraron los terceros involucrados en la solicitud :'||Vg_datos.Nro_solicitud ;
                Raise Error_negocio;    
            End If;            
         End If;
       End; 
   
       Begin
         vg_pos := '046';

         Insert Into Rsgos_Vgntes_Cntrtos
         Values(vg_datos.Nro_solicitud,vg_datos.Nro_poliza,'00','12', vg_datos.fecha_ini_contr,
            Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,vg_datos.fecha_fin_contr);

       Exception
       When Dup_Val_On_Index Then
           Update  Rsgos_Vgntes_Cntrtos
           set RVC_FCHA_INCCION_CNTRTO = Case When vg_datos.fecha_ini_contr Is Null Then 
                                            RVC_FCHA_INCCION_CNTRTO Else 
                                            vg_datos.fecha_ini_contr End
                ,RVC_FCHA_FINAL_CNTRTO = Case When vg_datos.fecha_fin_contr Is Null Then 
                                            RVC_FCHA_FINAL_CNTRTO Else 
                                            vg_datos.fecha_fin_contr End
           Where RVC_NMRO_ITEM = vg_datos.Nro_solicitud
           And RVC_NMRO_PLZA = vg_datos.Nro_poliza
           And RVC_CLSE_PLZA = '00'
           And RVC_RAM_CDGO  = '12';
       When Others Then 
          po_codigo := Sqlcode;
          po_mensaje := vg_pos || ' - '|| 'Error al insertar en la tabla Rsgos_Vgntes_Cntrtos:'||Sqlerrm ;
           Raise Error_negocio;
       End;


   -----------------------------------------    
   --fin del proceso resultado exitoso
   po_codigo := 0;
   po_mensaje := 'proceso Exitoso'; 
      
   Exception
    When Error_negocio Then 
      po_mensaje := vg_pos || ' - '||po_mensaje;
      Rollback;
    When Others Then 
    Rollback;
      po_codigo := Sqlcode;
      po_mensaje := vg_pos || ' - '|| 'Error inesperado en el registro de datos generales del siniestro Error:'||Sqlerrm ;    
   End prc_rgstro_gral_siniestro;
   
   
   /*
      Nombre:           prc_rgstro_cnceptos_siniestro
      Autor:            jpmoreno(asw)
      Fecha_creacion:   23-08-2017
      fecha_mod:        23-08-2017
      proposito:        procedimiento para registrar las tablas donde se relacionan conceptos de amparos.
                        
    */
   Procedure prc_rgstro_cnceptos_siniestro (po_codigo Out number, po_mensaje Out varchar2 )
   Is
   v_msg            varchar2(200);
   v_variable       number(4);
   v_variable2      number(4);
   v_valor          number(18,2);
   v_periodo        varchar2(8);
   fcha_pgo         date;
   tpo_lqdcion      varchar2(3);
   v_liq_separd     varchar2(2);
   v_periodos_r     number(2); 
   v_mes_ini        number(2);
   v_mes_fin        number(2);      
   vt_concep        T_TABLE_ASEGURADOS_MES;
   montos           montos_liq;
   v_fini  date; 
   v_ffin  date;
   v_ind_fecha Boolean; 
   Begin
                
        For R In 1..vg_conceptos.Count
        Loop
        vg_pos := '050';
        v_variable := Null;
        v_valor    := Null;
        v_liq_separd := Null;
        --doc
        If vg_conceptos(R).fecha_ini_reporte < vg_datos.fecha_mora And f_valida_cncep_siniestro(Vg_conceptos(R).Cod_concepto,'S',v_ind_fecha) And vg_tipo_amparo = 'B' Then
            po_codigo := -234;
            po_mensaje := vg_pos || ' - '|| 'la fecha del concepto reportado ' ||vg_conceptos(R).cod_concepto||' es anterior a la fecha de mora.';     
            Raise Error_negocio; 
        End If;
         --doc
        prc_calc_rango_serv (v_fini, v_ffin);
        --DBMS_OUTPUT.PUT_LINE(' ini '|| v_fini || 'fin ' ||v_ffin);
        If v_fini <> vg_conceptos(R).fecha_ini_reporte Or v_ffin <> vg_conceptos(R).fecha_fin_reporte Then
            po_codigo := -96;
            po_mensaje := vg_pos || ' - '|| 'Los rangos de fechas de los servicios no corresponden a los reportados en el rango de fechas del concepto' ;
            Raise Error_negocio;
        End If;        
      -- si el siniestro es por servicios publicos se validan que vengas servicios
       --doc
      If vg_datos.cod_amparo = '08' Then 
          vg_pos := '501';
          If  vg_servicios.Count = 0 Then
            po_codigo := -97;
            po_mensaje := vg_pos || ' - '|| 'para el siniestro de amparo integral se debe enviar el detalle de los servicios sinesitrados:'||po_mensaje ;
            Raise Error_negocio;  
          Else
              For s In 1.. vg_servicios.Count
              Loop
                  --doc
                 If vg_servicios(s).fecha_ini_reporte Is Null Or  vg_servicios(s).fecha_fin_reporte Is Null Then 
                    po_codigo := -98;
                    po_mensaje := vg_pos || ' - '|| 'Para el reporte de servicios publicos las fechas desde y hasta no pueden ser nulas' ;
                    Raise Error_negocio;
                 End If;
                  --doc
                 If vg_tipo_pol = 'C' Then -- para polizas colectivas
                  --doc
                     If vg_servicios(s).fecha_ini_reporte < Fecha_Ingreso_Seg(vg_datos.Nro_solicitud, vg_datos.Nro_poliza, '00','12', vg_datos.cod_amparo )   Then
                        po_codigo := -99;
                        po_mensaje := vg_pos || ' - '|| 'la fecha desde de un servicio no puede ser anterior a la fecha de ingreso al seguro' ;
                        Raise Error_negocio;
                      End If; 
                 Else -- para polizas individuales 
                  --doc
                     If vg_servicios(s).fecha_ini_reporte < Vg_vigencia_inicial   Then
                        po_codigo := -100;
                        po_mensaje := vg_pos || ' - '|| 'la fecha desde de un servicio no puede ser anterior  a la fecha de ingreso al seguro' ;
                        Raise Error_negocio;
                      End If; 
                 End If;
                     
                 If vg_servicios(s).fecha_ini_reporte > Vg_desocupacion Or Vg_desocupacion Is Null    Then
                        po_codigo := -101;
                        po_mensaje := vg_pos || ' - '|| 'la fecha desde de un servicio es posterior a la fecha de desocupacion y la fecha desocupacion debe existir' ;
                        Raise Error_negocio;
                 End If; 
                 If vg_servicios(s).fecha_ini_reporte > vg_servicios(s).fecha_fin_reporte  Then
                        po_codigo := -102;
                        po_mensaje := vg_pos || ' - '|| 'la fecha desde no puede ser mayor que la fecha hasta para el reporte de servicios.' ;
                        Raise Error_negocio;
                 End If;
                 If  vg_servicios(s).fecha_fin_reporte > Trunc(Sysdate)  Then
                        po_codigo := -103;
                        po_mensaje := vg_pos || ' - '|| 'la fecha hasta no puede ser mayor que la fecha actual.' ;
                        Raise Error_negocio;
                 End If;
                 
                 --DBMS_OUTPUT.PUT_LINE(' -'||vg_servicios(s).fecha_fin_reporte || '- ' || Vg_desocupacion );
                  If vg_servicios(s).fecha_fin_reporte > Vg_desocupacion Or Vg_desocupacion Is Null    Then
                        po_codigo := -104;
                        po_mensaje := vg_pos || ' - '|| 'la fecha hasta de un servicio posterior a la fecha de desocupacion y la fecha desocupacion debe existir' ;
                        Raise Error_negocio;
                 End If;
                 If vg_tipo_pol = 'C' Then -- para polizas colectivas
                     If Buscar_Si_Existe(vg_datos.Nro_solicitud, 0, '12', vg_conceptos(R).cod_concepto,vg_servicios(s).cod_concepto, 
                                       vg_servicios(s).fecha_ini_reporte, vg_servicios(s).fecha_ini_reporte) Then
                            po_codigo := -105;
                            po_mensaje := vg_pos || ' - '|| 'se detecto que para el servicio '|| vg_servicios(s).cod_concepto || '  ya se tiene un siniestro que involucra las fechas del rango ingrsado'   ;
                            Raise Error_negocio;
                     End If;
                 Else
                     If vg_servicios(s).fecha_fin_reporte > vg_vigencia_final   Then
                        po_codigo := -106;
                        po_mensaje := vg_pos || ' - '|| 'la fecha hasta de un servicio no puede posterior a la fecha de vigencia de poliza' ;
                        Raise Error_negocio;
                      End If;
                 
                 End If;
                     
                Insert Into Fctras_Afctdas_Snstro
                Values (SEQ_FCTRAS_SNSTROS.Nextval,vg_nmro_siniestro,'12',vg_conceptos(R).cod_concepto,vg_servicios(s).cod_concepto,
                       vg_servicios(s).fecha_ini_reporte,vg_servicios(s).fecha_fin_reporte,vg_datos.Nro_solicitud,vg_datos.fecha_mora,vg_datos.nit_tercero,Sysdate);
              End Loop;
          End If;
      End If;
        
        v_periodos_r := Trunc(Fu_Resta_Mes30(vg_conceptos(R).fecha_fin_reporte ,
                                                vg_conceptos(R).fecha_ini_reporte,v_msg )/30);
                                                
         
       -- DBMS_OUTPUT.PUT_LINE('concepto evaluado ' || vg_conceptos(r).cod_concepto);                                                                            
        If v_msg  Is Not Null Or Nvl(v_periodos_r,0) <=0 Then
              If vg_datos.cod_amparo <> '05' Then
                po_codigo := -236;
                po_mensaje := vg_pos || ' - '|| 'Error inesperado en el calculo de periodos de recuperacion.:'||Nvl(v_msg,'El calculo de periodos reportados es = 0') ;     
                Raise Error_negocio; 
              Else 
                v_periodos_r := 1;
              End If;
        End If;
        vg_pos := '051'; 
        If (vg_conceptos(R).fecha_fin_reporte > vg_vigencia_final And vg_tipo_pol = 'I') Or  
            (vg_conceptos(R).fecha_fin_reporte > vg_vigencia_final And vg_estado_pol <> 'V') Then
                po_codigo := -237;
                po_mensaje := vg_pos || ' - '|| 'La fecha hasta es mayor a la fecha de terminación de la vigencia de la póliza';     
                Raise Error_negocio; 
        End If;                                     
                                                
        If vg_conceptos(R).cod_concepto Like 'RE%' Then
            Begin
                Insert Into Vlres_Snstros
                Values(vg_conceptos(R).cod_concepto,
                       vg_nmro_siniestro,
                       vg_datos.cod_amparo,
                       '12',
                       '02',
                        vg_conceptos(R).Valor_Reportado,
                        0,
                        Sysdate,
                       '02',
                       vg_datos.nit_tercero,
                       Sysdate,
                       v_periodos_r,
                       vg_conceptos(R).fecha_ini_reporte,
                       vg_conceptos(R).fecha_fin_reporte
                       );
                        
                        
             End;           
        Elsif vg_conceptos(R).cod_concepto Like 'RM%' Then -- caso cuando los conceptos son recuperacion RM
            vg_pos := '052';     
            If v_periodos_r >1 Then
                v_valor := vg_conceptos(R).Valor_Reportado / v_periodos_r;
            Else     
               v_valor := vg_conceptos(R).Valor_Reportado;
            End If;
            Insert Into Vlres_Snstros
            Values(vg_conceptos(R).cod_concepto,
                   vg_nmro_siniestro,
                   vg_datos.cod_amparo,
                   '12',
                   '02',
                    v_valor,
                    v_valor,
                    Sysdate,
                   '02',
                   vg_datos.nit_tercero,
                   Sysdate,
                   v_periodos_r,--periodos reportados
                   vg_conceptos(R).fecha_ini_reporte,
                   vg_conceptos(R).fecha_fin_reporte
                   );              

        Else -- caso cuando los conceptos son de siniestro 
            vg_pos := '054';                               
                Insert Into Vlres_Snstros
                Values(vg_conceptos(R).cod_concepto,
                       vg_nmro_siniestro,
                       vg_datos.cod_amparo,
                       '12',
                       '02',
                        vg_conceptos(R).Valor_Reportado,
                        vg_conceptos(R).Valor_Reportado,
                        Sysdate,
                       '02',
                       vg_datos.nit_tercero,
                       Sysdate,
                       v_periodos_r,
                       vg_conceptos(R).fecha_ini_reporte,
                       vg_conceptos(R).fecha_fin_reporte
                       );
        
        End If;
        vg_pos := '057';
        Insert Into Vlres_Ddas
        Values( vg_datos.Nro_solicitud,
                vg_datos.fecha_mora,
               '12', 
               vg_conceptos(R).cod_concepto,
               vg_nmro_siniestro,
               vg_datos.cod_amparo,
                0,
                vg_conceptos(R).Valor_Reportado,
                0,
               vg_datos.nit_tercero,
                Sysdate,
               'G',
                0
               );

        vg_pos := '059';
        
       -- DBMS_OUTPUT.PUT_LINE('resultado de evaluacion '|| sys.diutil.bool_to_int(f_valida_cncep_siniestro(Vg_conceptos(r).Cod_concepto,'S',v_ind_fecha)));
        If f_valida_cncep_siniestro(Vg_conceptos(R).Cod_concepto,'S',v_ind_fecha) Then
              Begin  
             -- DBMS_OUTPUT.PUT_LINE('Sali IF');
              vg_pos := '591';
              fcha_pgo := Pkg_Siniestros.FUN_FECHA_PAGO(vg_datos.Nro_solicitud, 
                                                        vg_datos.fecha_mora,
                                                        vg_datos.Nro_poliza,
                                                        '00',
                                                        '12',
                                                        v_periodo);
              Exception
                When Others Then
                po_codigo := -240;
                po_mensaje := vg_pos || ' - '|| 'Error en la consulta de la fecha de pago.' ;     
                Raise Error_negocio;
              End;
              If fcha_pgo Is Null Then
                po_codigo := -241;
                po_mensaje := vg_pos || ' - '|| 'No existe fecha de pago para próximo período.' ;     
                Raise Error_negocio;
              End If;
             vg_pos := '061';
             tpo_lqdcion := '04';
           --  DBMS_OUTPUT.PUT_LINE('Periodos ' || v_periodos_r);
              montos :=  montos_liq();        
             If v_periodos_r = 1 Then
                If vg_tipo_amparo = 'B' Then
                     Inserta_Concepto_Liquidacion(vg_datos.Nro_solicitud,
                                                  v_periodo,
                                                  vg_nmro_siniestro,
                                                  vg_conceptos(R).fecha_ini_reporte,
                                                  vg_conceptos(R).fecha_fin_reporte,
                                                  tpo_lqdcion,--'04', 
                                                  vg_datos.nit_tercero,
                                                  Fu_Resta_Mes30(vg_conceptos(R).fecha_fin_reporte ,
                                                  vg_conceptos(R).fecha_ini_reporte,v_msg ),
                                                  vg_datos.fecha_mora,
                                                  '12',
                                                 vg_datos.cod_amparo,
                                                 vg_conceptos(R).cod_concepto,
                                                 vg_conceptos(R).Valor_Reportado/30,
                                                 vg_conceptos(R).Valor_Reportado/30,
                                                 'G',
                                                 fcha_pgo,
                                                 po_mensaje);
                Else 
                    Inserta_Concepto_Liquidacion(vg_datos.Nro_solicitud,
                                                  v_periodo,
                                                  vg_nmro_siniestro,
                                                  Sysdate,
                                                  Sysdate,
                                                  tpo_lqdcion,--'04', 
                                                  vg_datos.nit_tercero,
                                                  1,
                                                  vg_datos.fecha_mora,
                                                  '12',
                                                 vg_datos.cod_amparo,
                                                 vg_conceptos(R).cod_concepto,
                                                 vg_conceptos(R).Valor_Reportado,
                                                 vg_conceptos(R).Valor_Reportado,
                                                 'G',
                                                 fcha_pgo,
                                                 po_mensaje);
                
                End If;
                montos.Extend;
                montos(1).valor:=  vg_conceptos(R).Valor_Reportado;
                montos(1).cod_conc :=vg_conceptos(R).cod_concepto;
                montos(1).f_ini := vg_conceptos(R).fecha_ini_reporte;
                montos(1).f_fin := vg_conceptos(R).fecha_fin_reporte;                              
             
             Elsif v_periodos_r >= 2 Then -- si vienen  2 periodos en un registro de concepto de siniestro
                --DBMS_OUTPUT.PUT_LINE('Sali elsif 2');
               If vg_tipo_pol = 'C' And v_periodos_r > 2 And vg_tipo_amparo = 'B' Then
                    po_codigo := -234;
                    po_mensaje := vg_pos || ' - '|| 'Error, para conceptos de siniestro solo se aceptan 2 periodos como maximo' ;     
                    Raise Error_negocio;  
               End If;
                vg_pos := '062';
              If vg_tipo_amparo = 'B' Then
                    Pkg_Interfaces_Consultas.PRC_CONSULTAR_ASEGURADOS_MES(vg_datos.Nro_solicitud,vg_datos.fecha_mora,vt_concep,
                                              po_codigo,
                                              po_mensaje );
                    If po_codigo  <> 0 Then
                        po_mensaje := vg_pos || ' - '|| 'Error inesperado en la consulta de valores para liquidacion de conceptos. Error:'||po_mensaje ;     
                        Raise Error_negocio;
                    End If;
                    
                    v_mes_ini := Extract(Month From  vg_conceptos(R).fecha_ini_reporte);
                    v_mes_fin := Extract(Month From  vg_conceptos(R).fecha_fin_reporte); 
                    
                    If v_mes_ini = v_mes_fin Then
                        po_codigo := -234;
                        po_mensaje := vg_pos || ' - '|| 'Error, en el rango de fechas del concepto de siniestro '||vg_conceptos(R).cod_concepto  ;
                        Raise Error_negocio;
                    End If; 
                    
                    If Not f_valida_periodo_aseg(vt_concep,v_mes_ini) Or Not f_valida_periodo_aseg(vt_concep,v_mes_fin) Then
                        po_codigo := -236;
                        po_mensaje := vg_pos || ' - '|| 'Error, el periodo reportado no se encuentra asegurado '  ;
                        Raise Error_negocio;
                    End If;
                   v_variable :=0;
                   v_variable2 :=0;
                     montos :=  montos_liq();
                     vg_pos := '063';                                
                    For c In 1..vt_concep.Count
                    Loop
                        If vg_conceptos(R).cod_concepto  = '01' Then 
                        --DBMS_OUTPUT.PUT_LINE(' entro al if 01 mes ......'|| Lpad(To_Char(v_mes_ini),2,'0'));
                            If To_Number(vt_concep(c).numero_mes) = v_mes_ini  Then
                               If vg_conceptos(R).Valor_Reportado/v_periodos_r <> vt_concep(c).CANON Then
                                -- DBMS_OUTPUT.PUT_LINE(' entro al if dif valores fecha ini '||'01'||Lpad(v_mes_ini,2,'0')||Extract(Year From vg_conceptos(r).fecha_ini_reporte));
                                v_variable := v_variable +1;
                                 montos.Extend;
                                 montos(v_variable).valor:=  vt_concep(c).CANON;
                                 montos(v_variable).cod_conc :='01';
                                 montos(v_variable).f_ini :=To_Date('01'||Lpad(v_mes_ini,2,'0')||Extract(Year From vg_conceptos(R).fecha_ini_reporte),'DDMMYYYY');
                                 montos(v_variable).f_fin :=Last_Day(To_Date('01'||Lpad(v_mes_ini,2,'0')||Extract(Year From vg_conceptos(R).fecha_ini_reporte),'DDMMYYYY'));
                                -- DBMS_OUTPUT.PUT_LINE('2 sali del al if dif valores  '|| '01'||Lpad(v_mes_ini,2,'0')||Extract(Year From vg_conceptos(r).fecha_ini_reporte));
                               End If;
                            Elsif To_Number(vt_concep(c).numero_mes) = v_mes_fin  Then
                               If vg_conceptos(R).Valor_Reportado/v_periodos_r <> vt_concep(c).CANON Then
                                v_variable := v_variable +1;
                                montos.Extend;
                                montos(v_variable).valor:= vt_concep(c).CANON;
                                montos(v_variable).cod_conc :='01';
                                montos(v_variable).f_ini :=To_Date('01'||Lpad(v_mes_fin,2,'0')||Extract(Year From vg_conceptos(R).fecha_fin_reporte),'DDMMYYYY');
                                montos(v_variable).f_fin :=Last_Day(To_Date('01'||Lpad(v_mes_fin,2,'0')||Extract(Year From vg_conceptos(R).fecha_fin_reporte),'DDMMYYYY'));                            
                               End If; 
                            End If;
                        Elsif vg_conceptos(R).cod_concepto  = '02' Then
                         -- DBMS_OUTPUT.PUT_LINE(' entro al elsif 02');
                            If To_Number(vt_concep(c).numero_mes) = v_mes_ini  Then
                               If vg_conceptos(R).Valor_Reportado/v_periodos_r <> vt_concep(c).ADMINISTRACION Then
                                v_variable := v_variable +1;
                                montos.Extend;
                                montos(v_variable).valor:= vt_concep(c).ADMINISTRACION;
                                montos(v_variable).cod_conc :='02';
                                montos(v_variable).f_ini :=To_Date('01'||Lpad(v_mes_ini,2,'0')||Extract(Year From vg_conceptos(R).fecha_ini_reporte),'DDMMYYYY');
                                montos(v_variable).f_fin :=Last_Day(To_Date('01'||Lpad(v_mes_ini,2,'0')||Extract(Year From vg_conceptos(R).fecha_ini_reporte),'DDMMYYYY'));
                               End If;
                            Elsif To_Number(vt_concep(c).numero_mes) = v_mes_fin  Then
                               If vg_conceptos(R).Valor_Reportado/v_periodos_r <> vt_concep(c).ADMINISTRACION Then
                                v_variable := v_variable +1;
                                montos.Extend;
                                montos(v_variable).valor:= vt_concep(c).ADMINISTRACION;
                                montos(v_variable).cod_conc :='02';
                                montos(v_variable).f_ini :=To_Date('01'||Lpad(v_mes_fin,2,'0')||Extract(Year From vg_conceptos(R).fecha_fin_reporte),'DDMMYYYY');
                                montos(v_variable).f_fin :=Last_Day(To_Date('01'||Lpad(v_mes_fin,2,'0')||Extract(Year From vg_conceptos(R).fecha_fin_reporte),'DDMMYYYY')); 
                               End If; 
                            End If;
                        End If;
                          
                    End Loop; 
                 
                
                    vg_pos := '064'; 
                    If montos.Count > 1 Then
                        For i In 1..montos.Count 
                        Loop
                            Inserta_Concepto_Liquidacion(vg_datos.Nro_solicitud,
                                                          v_periodo,
                                                          vg_nmro_siniestro,
                                                          montos(i).f_ini,
                                                          montos(i).f_fin,
                                                          tpo_lqdcion,--'04', 
                                                          vg_datos.nit_tercero,
                                                          
                                                          30,
                                                          vg_datos.fecha_mora,
                                                          '12',
                                                         vg_datos.cod_amparo,
                                                         montos(i).cod_conc,
                                                         montos(i).valor/30,
                                                         montos(i).valor/30,
                                                         'G',
                                                         fcha_pgo,
                                                         po_mensaje);
                        End Loop;
                    Else
                        Inserta_Concepto_Liquidacion(vg_datos.Nro_solicitud,
                                                      v_periodo,
                                                      vg_nmro_siniestro,
                                                      vg_conceptos(R).fecha_ini_reporte,
                                                      vg_conceptos(R).fecha_fin_reporte,
                                                      tpo_lqdcion,--'04', 
                                                      vg_datos.nit_tercero,
                                                      Fu_Resta_Mes30(vg_conceptos(R).fecha_fin_reporte ,
                                                      vg_conceptos(R).fecha_ini_reporte,v_msg ),
                                                      vg_datos.fecha_mora,
                                                      '12',
                                                     vg_datos.cod_amparo,
                                                     vg_conceptos(R).cod_concepto,
                                                     vg_conceptos(R).Valor_Reportado/(v_periodos_r*30),
                                                     vg_conceptos(R).Valor_Reportado/(v_periodos_r*30),
                                                     'G',
                                                     fcha_pgo,
                                                     po_mensaje);
                    
                    End If;
              Else -- amparos adicionales
                                  Inserta_Concepto_Liquidacion(vg_datos.Nro_solicitud,
                                                  v_periodo,
                                                  vg_nmro_siniestro,
                                                  Sysdate,
                                                  Sysdate,
                                                  tpo_lqdcion,--'04', 
                                                  vg_datos.nit_tercero,
                                                  1,
                                                  vg_datos.fecha_mora,
                                                  '12',
                                                 vg_datos.cod_amparo,
                                                 vg_conceptos(R).cod_concepto,
                                                 vg_conceptos(R).Valor_Reportado,
                                                 vg_conceptos(R).Valor_Reportado,
                                                 'G',
                                                 fcha_pgo,
                                                 po_mensaje);
              
              
              End If;
            
             End If;                              
                                                                 
                    
           If po_mensaje  Is Not Null Then
                po_codigo := -236;
                po_mensaje := vg_pos || ' - '|| 'Error inesperado en la liquidacion de conceptos. Error:'||po_mensaje ;     
                Raise Error_negocio;
           End If; 
        End If;
         -- DBMS_OUTPUT.PUT_LINE('Sali validacion');     
               vg_pos := '066';
              -- DBMS_OUTPUT.PUT_LINE(' concepto evaluado '||vg_datos.cod_amparo);
               If vg_tipo_amparo = 'B' And f_valida_cncep_siniestro(Vg_conceptos(R).Cod_concepto,'S',v_ind_fecha) Then -- amparo basico
                -- DBMS_OUTPUT.PUT_LINE('  conteo '||montos.Count); 
                  If montos.Count > 1 Then
                  vg_pos := '661';
                    v_valor := f_calc_diff_conceptos (montos);
                   vg_pos := '662'; 
                    If v_valor = 0 Then 
                        po_codigo := -237;
                        po_mensaje := vg_pos || ' - '|| 'Error inesperado calculando valores de  Amntos_Snstros. Valor =0:';     
                        Raise Error_negocio;
                    End If;
                    For i In 1.. montos.Count
                    Loop
                    Begin
                    --DBMS_OUTPUT.PUT_LINE('fecha ini ' ||montos(i).f_ini||' count '||montos.Count  );
                      Insert Into  Amntos_Snstros
                       Values(vg_nmro_siniestro,
                              '12',
                              vg_datos.cod_amparo,
                              montos(i).f_ini,
                              vg_conceptos(R).cod_concepto,
                              Case When i =1 Then montos(i).valor Else v_valor End,
                              0,
                              vg_datos.Nro_solicitud,
                              vg_datos.fecha_mora,
                              vg_datos.nit_tercero,
                              montos(i).f_ini,
                              Null); 
                         --DBMS_OUTPUT.PUT_LINE('pase insercion ' ||v_valor);
                         If vg_conceptos(R).cod_concepto = '01' Then
                            Insert Into  Amntos_Snstros
                                   Values(vg_nmro_siniestro,
                                          '12',
                                          vg_datos.cod_amparo,
                                          montos(i).f_ini,
                                          '02',
                                          0,
                                          0,
                                          vg_datos.Nro_solicitud,
                                          vg_datos.fecha_mora,
                                          vg_datos.nit_tercero,
                                          montos(i).f_ini,
                                          Null);
                         
                         End If;
                       Exception When Dup_Val_On_Index Then
                           Update Amntos_Snstros
                           set Amn_vlor = Case When I =1 Then Montos(I).Valor Else V_valor End
                           Where Amn_nmro_snstro = Vg_nmro_siniestro
                            And Amn_ram_cdgo = '12'
                            And Amn_cdgo_ampro = '01'
                            And Amn_cncpto = vg_conceptos(R).cod_concepto
                            And AMN_FCHA_ACTLZCION = montos(i).f_ini; 
                     End;
                     End Loop; 
                  
                  Else
                  Begin
                  vg_pos := '069';
                     Insert Into  Amntos_Snstros
                       Values(vg_nmro_siniestro,
                              '12',
                              vg_datos.cod_amparo,
                              vg_datos.fecha_mora,
                              vg_conceptos(R).cod_concepto,
                              vg_conceptos(R).Valor_Reportado/v_periodos_r,
                              0,
                              vg_datos.Nro_solicitud,
                              vg_datos.fecha_mora,
                              vg_datos.nit_tercero,
                              vg_datos.fecha_mora,
                              Null);
                      vg_pos := '070';
                      If vg_conceptos(R).cod_concepto = '01' Then
                                Insert Into  Amntos_Snstros
                                       Values(vg_nmro_siniestro,
                                              '12',
                                              vg_datos.cod_amparo,
                                              vg_datos.fecha_mora,
                                              '02',
                                              0,
                                              0,
                                              vg_datos.Nro_solicitud,
                                              vg_datos.fecha_mora,
                                              vg_datos.nit_tercero,
                                              vg_datos.fecha_mora,
                                              Null);
                         
                       End If;
                       Exception When Dup_Val_On_Index Then
                           Update Amntos_Snstros
                           set Amn_vlor = vg_conceptos(R).Valor_Reportado/v_periodos_r
                           Where Amn_nmro_snstro = Vg_nmro_siniestro
                            And Amn_ram_cdgo = '12'
                            And Amn_cdgo_ampro = '01'
                            And Amn_cncpto = vg_conceptos(R).cod_concepto
                            And AMN_FCHA_ACTLZCION =  vg_datos.fecha_mora; 
                     End;
                  
                  
                   End If ;
               End If; 
        
        End Loop;     
        vg_pos := '071';
        Insert Into Snstros_Nuevos
                    Values(fcha_pgo,
                    vg_datos.Nro_poliza,
                    vg_datos.Nro_solicitud,
                    vg_datos.fecha_mora,
                    Vg_nmro_siniestro,
                    '12',
                    '01',
                    'S',
                    vg_datos.nit_tercero,
                    Sysdate);

    


   -----------------------------------------    
   --fin del proceso resultado exitoso
   po_codigo := 0;
   po_mensaje := 'proceso Exitoso'; 
      
   Exception
    When Error_negocio Then 
      po_mensaje := vg_pos || ' - '||po_mensaje;
      Rollback;
    When Others Then 
    Rollback;
      po_codigo := Sqlcode;
      po_mensaje := vg_pos || ' - '|| 'Error inesperado en el registro del siniestro Error:'||Sqlerrm ;   
   End prc_rgstro_cnceptos_siniestro;  



  Procedure prc_rgstro_doctos_siniestro(po_codigo Out number, po_mensaje Out varchar2)
  Is 
  Begin
  vg_pos := '068';
  --DBMS_OUTPUT.PUT_LINE('conte registros de doctos '||vg_doctos.Count);
  For R In 1..vg_doctos.Count
  Loop
  Begin
   Insert Into Dtlle_Dcmntos_Snstro
   Values(vg_datos.Nro_solicitud,
          vg_doctos(R).cod_docto,
          vg_datos.Nro_poliza,
          vg_datos.nit_tercero,
          Sysdate);
  Exception 
  When Dup_Val_On_Index Then
  Null;
  End;
  End Loop; 
   
  -----------------------------------------    
   --fin del proceso resultado exitoso 
   po_codigo := 0;
   po_mensaje := 'proceso Exitoso';
  
  Exception
    When Others Then 
    Rollback;
      po_codigo := Sqlcode;
      po_mensaje := vg_pos || ' - '|| 'Error inesperado en el registro de documentos del siniestro Error:'||Sqlerrm ;    

  End prc_rgstro_doctos_siniestro; 


   
    
   
   Procedure prc_registra_siniestro( pi_siniestro In ty_rprte_snstro,po_nmro_snstro Out number, po_codigo Out number, po_mensaje Out varchar2)
   Is
   v_poliza_simon number;
   V_TERMOK     varchar2(2);
   V_ANUPOL     varchar2(2);
   V_PROVISORIA varchar2(2);

   v_var        varchar2(2);
   
   v_ind_fecha Boolean;
   Begin
        vg_pos := '000'; 
        vg_datos     := pi_siniestro.datos_b;
        vg_conceptos := pi_siniestro.T_Conceptos;
        vg_servicios := pi_siniestro.T_Servicios;
        vg_doctos    := pi_siniestro.T_Doctos;
        
        If vg_servicios Is Null Then
        vg_servicios := tb_repte_cnceptos();
        End If;
        
        If vg_doctos Is Null Then
        vg_doctos := tb_doctos_snstro();
        End If;
        
       -- DBMS_OUTPUT.PUT_LINE('voy a validar canon');
        --Se valida, que entre los conceptos reportados al menos venga un registro por canon
        
       

        --se valida la consulta de la poliza por identificacion del tercero
        --doc
        Begin
            vg_pos := '001';
            Select Pol_poliza_simon,Pol_tpoplza,Pol_fcha_dsde_incial,Pol_estado_plza,Pol_fcha_hsta_incial
            Into v_poliza_simon,vg_tipo_pol,Vg_vigencia_inicial,vg_estado_pol,vg_vigencia_final  
            From Plzas P
            Where P.POL_NMRO_PLZA = vg_datos.Nro_poliza
            And P.POL_PRS_NMRO_IDNTFCCION = vg_datos.nit_tercero;
        Exception
        When No_Data_Found Then 
              po_codigo := Sqlcode;
              po_mensaje := vg_pos || ' - '|| 'no se encontraron datos de la poliza ' ;
              Raise Error_negocio;  
        When Too_Many_Rows Then 
              po_codigo := Sqlcode;
              po_mensaje := vg_pos || ' - '|| 'Error inesperado en la consulta de la poliza Error:' ; 
              Raise Error_negocio;
        End;
        --doc
         If vg_conceptos Is Null Then
            po_codigo := -02;
            po_mensaje:= vg_pos || ' - '||'Error.no se estan enviando conceptos para el siniestro';
            Raise Error_negocio;
         
         End If;
         
         
         
         
        
        Vg_desocupacion :=  Pkg_Consulta_Indemnizacion.Fun_fecha_desocupacion(vg_datos.Nro_solicitud, vg_datos.Nro_poliza);
        vg_tipo_amparo := f_tipo_amparo (vg_datos.cod_amparo);
        --doc
        If vg_tipo_amparo Is Null Then
            po_codigo := -35;
            po_mensaje:= vg_pos || ' - '||'no se pudo recuperar el tipo de amparo de la solicitud';
            Raise Error_negocio;
        End If;
        --doc
        If  vg_tipo_amparo ='A' Then
            If Abs(Trunc(Months_Between(vg_datos.fecha_mora,Vg_desocupacion))) > 3  Then
                   po_codigo := 49;
                  po_mensaje := vg_pos || ' - '|| 'Error.el tiempo maximo entre la fecha mora y la fecha desocupacion, debe ser de 3 meses' ;
                  Raise Error_negocio;
            End If;
        Else
             --doc  
            If To_Char(vg_datos.fecha_mora,'DD') <> '01' Then
                po_codigo := -35;
                po_mensaje:= vg_pos || ' - '||'Error.la fecha mora para amparo basico solo puede ser el primer dia del periodo reportado';
                Raise Error_negocio;
            End If;
             --doc
            If Not f_valida_cncep_siniestro('01','S',v_ind_fecha)  Then
                  po_codigo := 50;
                  po_mensaje := vg_pos || ' - '|| 'Error. no se existe registro de canon en los conceptos reportados' ;
                  Raise Error_negocio;
            End If;
             --doc
            If Not f_valida_fechas_ab  Then
                  po_codigo := 10;
                  po_mensaje := vg_pos || ' - '|| 'Error. las fechas de los conceptos del amparo basico deben ser iguales para todos.' ;
                  Raise Error_negocio;
            End If;
        End If;
        vg_pos := '101';        
        
      --DBMS_OUTPUT.PUT_LINE('voy a validar AB');
              
         --doc
        If Not v_ind_fecha 
        --And vg_tipo_pol = 'C' 
        Then
              po_codigo := 51;
              po_mensaje := vg_pos || ' - '|| 'Error. solo se generan siniestros para maximo 2 meses anteriores para polzias colectivas, y 5 meses anteriores para polizas individuales.' ;
              Raise Error_negocio;
        End If;
        vg_pos := '102'; 
        --DBMS_OUTPUT.PUT_LINE('voy a validar recuperaciones');
        -- se valida que si alguno de los conceptos de recupe
         --doc
       If  f_valida_cncep_siniestro(Null,'R',v_ind_fecha)   Then
            If Not v_ind_fecha Then
              po_codigo := 52;
              po_mensaje := vg_pos || ' - '|| 'Error. la fecha inicial de uno de los conceptos de recuperacion es anterior a  los 5 meses permitidos en el reporte.' ;
              Raise Error_negocio;
             End If;
        End If;
        
        
        vg_pos := '002';
        If V_POLIZA_SIMON Is Not Null Then 
          If vg_tipo_pol = 'I' Then
            V_PROVISORIA := Pkg_Consulta_Operacion.FUN_POLIZA_PROVISORIA(3,37,486,V_POLIZA_SIMON ,V_TERMOK,V_ANUPOL);
             --doc
              If V_PROVISORIA = 'S' Then
                 po_codigo := -32;
                 po_mensaje:=vg_pos || ' - '||'La Póliza esta provisoria no puede ingresar el siniestro. Verifique con Emisión ';
                 Raise Error_negocio;
              End If;
              --doc
            If V_ANUPOL = 'S' Then
                po_codigo := -33;
                po_mensaje:= vg_pos || ' - '||'La Póliza esta Anulada no puede ingresar el siniestro. Verifique con Emisión ';
                Raise Error_negocio;
            End If;
             --doc           
            If f_valida_cncep_siniestro(Null,'R',v_ind_fecha) Then
                po_codigo := -34;
                po_mensaje:= vg_pos || ' - '||'La póliza fue expedida en SIMON, no puede tener  conceptos de recuperación';
                Raise Error_negocio;
            End If;            
            
          End If; 
            
        End If;
        
        
        -- se valida que la solicitud no tenga ningun siniestro vigente por amparo basico.
        vg_pos := '003';
         --doc
        Begin
            Select Distinct'X'-- DVA_FCHA_DSCPCION, DVA_FCHA_MRA
            Into v_var
            From Ddas_Vgntes_Arrndmntos, Ampros_Snstros
            Where DVA_NMRO_SLCTUD = vg_datos.Nro_solicitud
            And DVA_ESTDO = '01' 
            And DVA_NMRO_SLCTUD = AMS_NMRO_ITEM 
            And DVA_FCHA_MRA = AMS_FCHA_MRA
            And AMS_CDGO_AMPRO = '01';
            
            If v_var Is Not Null And vg_tipo_amparo ='B' Then
                po_codigo := -35;
                po_mensaje:= 'Existe un siniestro vigente para la Solicitud:'||vg_datos.Nro_solicitud;
                Raise Error_negocio; 
            End If;      
        Exception
            When No_Data_Found Then
            Null;
        End;
        
        
        --se valida que la fecha mora no supere los 5 meses anteriores a la fecha del reporte del siniestro o posterior a la actual
        vg_pos := '004';
         --doc
        If Round(Months_Between(Trunc(Sysdate),vg_datos.fecha_mora ))>5 Then
           po_codigo := -36;
           po_mensaje:=vg_pos || ' - '||'La Fecha de Mora no Puede ser menor a 5 meses';
           Raise Error_negocio;
        End If;
         --doc
        If  vg_datos.fecha_mora > Sysdate Then 
            po_codigo := -37;
            po_mensaje:=vg_pos || ' - '||'La Fecha de Mora no Puede ser  Mayor a la Fecha actual';
            Raise Error_negocio;
        End If;

        
        
        
         -- se valida, para las poliza colectivas, que la fecha de mora no sea anterior a la fecha de inicio de la poliza.
         vg_pos := '005';
         If vg_tipo_pol = 'C' Then
             Vg_vigencia_inicial := Fecha_Ingreso_Seg(vg_datos.Nro_solicitud ,
                                          vg_datos.Nro_poliza    ,
                                         '00',
                                         '12',
                                         '01');
            
         End If ;
          --doc                       
         If Vg_vigencia_inicial > vg_datos.fecha_mora Then
              po_codigo := -38;
               po_mensaje := vg_pos || ' - '||'Error. La fecha mora es anterior A la vigencia de la poliza.' ; 
              Raise Error_negocio;
            End If;
                        
        
        -- se valida que el siniestro no esté doblemente reportado.
        vg_pos := '007';
         --doc
        Begin
           Select  Distinct'X'
           Into v_var
           From Lqdcnes_Dtlle,Vlres_Lqdcion,Vlres_Prdcto,Ampros_Snstros
                 Where LQT_NMRO_SLCTUD = vg_datos.Nro_solicitud
                   And LQT_FCHA_MRA != vg_datos.fecha_mora
                   And LQT_ESTDO_LQDCION = '03'
                   And VLQ_NMRO_SLCTUD = LQT_NMRO_SLCTUD
                   And VLQ_TPO_LQDCION = LQT_TPO_LQDCION
                   And VLQ_PRDO = LQT_PRDO
                   And VLQ_SERIE = LQT_SERIE
                   And VLQ_CNCPTO_VLOR = VPR_CDGO
                    And VPR_TPO_VLOR = 'S'
                    And VLQ_ORGEN Not In ('N','E')
                    And LQT_NMRO_SNSTRO = AMS_NMRO_SNSTRO
                    And AMS_CDGO_AMPRO = '01'
                     And AMS_RAM_CDGO = LQT_RAM_CDGO           
                   And vg_datos.fecha_mora Between LQT_FCHA_DSDE And LQT_FCHA_HSTA;
         If v_var Is Not Null Then
             po_codigo := -42;
             po_mensaje := vg_pos || ' - '|| 'El siniestro está siendo doblemente reportado.';
             Raise Error_negocio;
          End If;
        Exception
            When No_Data_Found Then
            Null;
        End; 
        
        vg_pos := '008';
         --doc
        Begin
           Select  Distinct'X'
           Into v_var
           From Avsos_Snstros
           Where SNA_NMRO_ITEM = vg_datos.Nro_solicitud
           And Trunc(SNA_FCHA_SNSTRO) = Trunc(vg_datos.fecha_mora);

         If v_var Is Not Null Then
             po_codigo := -44;
             po_mensaje := vg_pos || ' - '|| 'Existe un siniestro con la misma fecha de mora.';
             Raise Error_negocio;
          End If;
        Exception
            When No_Data_Found Then
            Null;
        End;        
        
        -- se valida el estado de la poliza
         --doc
        vg_pos := '009';
       -- vg_tipo_pol = 'I' And
        If  vg_tipo_amparo ='B' Then
           If vg_estado_pol Not In ('V','P') Then
               po_codigo := -48;
               po_mensaje := vg_pos || ' - '||'La póliza Individual No se encuentra vigente. No se pueden registrar siniestros.';
               Raise Error_negocio;
            End If;
        End If;
        
        
        vg_pos := '010';
         --doc
        If v_poliza_simon Is Not Null And  vg_tipo_pol = 'I' Then
            v_var := Pkg_Operacion.FUN_VALIDA_PAGO_PLZA(v_poliza_simon);
            If v_var = 'N' Then
                 po_codigo := -46;
                 po_mensaje := vg_pos || ' - '|| 'No se puede registrar el siniestro, pertenece A una póliza individual que No ha cancelado la totalidad de las Primas.';
                 Raise Error_negocio;
            End If;
        End If;
        --DBMS_OUTPUT.PUT_LINE('llegue a la pos '||777);
        
   
        --primera parte del proceso 
          prc_rgstro_gral_siniestro(po_codigo, po_mensaje );
          If Nvl(po_codigo,99) <> 0  Then
                Raise Error_negocio;
          End If;
          
          
          -- registro de conceptos del siniestros
          prc_rgstro_cnceptos_siniestro (po_codigo , po_mensaje );
          If Nvl(po_codigo,99) <> 0  Then
                Raise Error_negocio;
          End If;
          --DBMS_OUTPUT.PUT_LINE('llegue a la pos '||888);
          --
          If vg_tipo_amparo = 'B' Then
              prc_rgstro_doctos_siniestro(po_codigo , po_mensaje );
              If Nvl(po_codigo,99) <> 0  Then
                    Raise Error_negocio;
              End If;
          End If;              
          
   
   po_nmro_snstro := vg_nmro_siniestro;
   -----------------------------------------    
   --fin del proceso resultado exitoso
   po_codigo := 0;
   po_mensaje := 'Proceso Exitoso'; 
      
   Exception
    When Error_negocio Then 
      Rollback;
    When Others Then 
    Rollback;
      po_codigo := Sqlcode;
      po_mensaje := vg_pos || ' - '|| 'Error inesperado en el registro del siniestro Error:'||Sqlerrm ;   
   End;

      /*
       Nombre:           prc_registra_daños
       Autor:            jgallo(asw)
       Fecha_creacion:   27-09-2017
       fecha_mod:        27-09-2017
       proposito:        Procedimiento que registra siniestros de forma masiva
     */     
   Procedure Prc_registra_siniestros_masivo(Pi_tb_ty_rprte_snstro In Tb_ty_rprte_snstro, Po_tb_ty_rgstro_snstros Out Tb_ty_rgstro_snstros, Po_codigo Out Varchar2,
  Po_mensaje Out Varchar2) As
  
  V_CODIGO_PROCESO NUMBER;
  V_MENSAJE_PROCESO VARCHAR(1000);
  V_NUMERO_SINIESTRO NUMBER;
  v_pos varchar2(3);
  Begin
    v_pos:='001';
    PO_TB_TY_RGSTRO_SNSTROS := TB_TY_RGSTRO_SNSTROS(); 
    v_pos:='002';
    For i In 1..PI_TB_TY_RPRTE_SNSTRO.Last Loop
    v_pos:='003';
      Pkg_Interfaces_Siniestros.PRC_REGISTRA_SINIESTRO(PI_TB_TY_RPRTE_SNSTRO(i),
                                       V_NUMERO_SINIESTRO,
                                       V_CODIGO_PROCESO,
                                       V_MENSAJE_PROCESO);
                                       v_pos:='004';
     PO_TB_TY_RGSTRO_SNSTROS.Extend(); 
     PO_TB_TY_RGSTRO_SNSTROS(i) := TY_RGSTRO_SNSTROS(PI_TB_TY_RPRTE_SNSTRO(i).datos_b.nro_solicitud, V_NUMERO_SINIESTRO, V_CODIGO_PROCESO, V_MENSAJE_PROCESO); 
     v_pos:='005';
    End Loop;
    PO_CODIGO := 0;
    PO_MENSAJE := 'Transacción exitosa';
    Exception
      When Others Then
        PO_CODIGO := Sqlcode;
        PO_MENSAJE := 'Error inesperado en el proceso masivo: '||v_pos||' '||Sqlerrm;
  End;

    /*Nombre:         PRC_CALCULA_CUPO_AMP_INT
  Autor:            jgallo(asw)
  Fecha_creacion:   20-10-2017
  fecha_mod:        20-10-2017
  proposito:        Devuelve el cupo de amparo integral utilizado y los conceptos de con sus respectivas fechas
  */
 Procedure PRC_CALCULA_CUPO_AMP_INT(P_NUMERO_SOLICITUD In NUMBER, PO_VALOR_GIRADO Out NUMBER, PO_TB_TY_CUPO_SINIESTRO Out TB_TY_CUPO_SINIESTRO,
                                    PO_CODIGO Out VARCHAR2, PO_MENSAJE Out VARCHAR2)
  As
    V_VALOR_GIRADO NUMBER(30,5);
    V_VALOR_ASEGURADO NUMBER(30,5);
    V_CONCEPTO_AMP_INT VARCHAR2(2) := '16'; --CONCEPTO DE AMPARO INTEGRAL
    V_ESTADO_PAGADO VARCHAR2(20) := 'PAGADO'; --ESTADO PAGADO
    V_RAMO VARCHAR2(2) := '12'; --RAMO 12
    V_COD_AMPARO_INT VARCHAR2(2) := '08';--CODIGO DE AMPARO INTEGRAL
    Cursor FECHAS_SINIESTRO_CURSOR Is
    Select ff.fas_tpo_srvcio servicio,Tt.EST_FCHA_MRA fecha_mora,ff.fas_fcha_dsde fecha_inicio,ff.fas_fcha_hsta fecha_fin, Tt.EST_VLOR_CIA valor
    From v_abrestdcuentastt Tt,Fctras_Afctdas_Snstro ff
    Where Tt.EST_SLCTUD = P_NUMERO_SOLICITUD
    And Tt.EST_CNCPTO_VLOR = V_CONCEPTO_AMP_INT
    And Tt.EST_VLOR_CIA != 0   
    And Tt.EST_ESTADO =  V_ESTADO_PAGADO 
    And ff.fas_nmro_slctud = Tt.EST_SLCTUD
    And ff.fas_fcha_mra = Tt.EST_FCHA_MRA
    Order By Tt.EST_FCHA_MRA,ff.fas_fcha_dsde;
    cont number(5) := 1;
  Begin 
      Begin --VALOR TOTAL QUE YA SE HA SINIESTRADO
          Select Nvl(Sum(Tt.EST_VLOR_CIA),0)
          Into PO_VALOR_GIRADO
          From v_abrestdcuentastt Tt
          Where Tt.EST_SLCTUD = P_NUMERO_SOLICITUD
          And Tt.EST_CNCPTO_VLOR = V_CONCEPTO_AMP_INT
          And Tt.EST_VLOR_CIA != 0  
          And Tt.EST_ESTADO = V_ESTADO_PAGADO ;
      End;
     -- CONCEPTOS QUE SE HAN SINIESTRADO
      PO_TB_TY_CUPO_SINIESTRO := TB_TY_CUPO_SINIESTRO();
      For FECHAS_RECORD In FECHAS_SINIESTRO_CURSOR Loop
        PO_TB_TY_CUPO_SINIESTRO.Extend();
        PO_TB_TY_CUPO_SINIESTRO(cont) := TY_CUPO_SINIESTRO(FECHAS_RECORD.servicio,
                                                            FECHAS_RECORD.fecha_mora,
                                                            FECHAS_RECORD.fecha_inicio,
                                                            FECHAS_RECORD.fecha_fin,
                                                            FECHAS_RECORD.valor);
        cont:= cont+1;
      End Loop;
      PO_CODIGO := 0;
      PO_MENSAJE := 'Consulta exitosa';
      Exception 
        When Others Then
          PO_CODIGO := Sqlcode;
          PO_MENSAJE := Sqlerrm;
  End PRC_CALCULA_CUPO_AMP_INT;
  


End Pkg_Interfaces_Siniestros;
/
