Declare

Nro_siniestro       number(10);
codigo              number;
mensaje             varchar2(500);
v_siniestro         ADMSISA.ty_rprte_snstro;

Begin 
    -- proces od ecarga de siniestros por amparo basico

For r In (Select s.*  
          From Datos_Reintentos s)
Loop
    Begin
        --v_siniestro :=Cast(r.obj_Siniestro As ADMSISA.ty_rprte_snstro);
        
        pkg_interfaces_siniestros.prc_registra_siniestro(pi_siniestro  => r.obj_Siniestro ,
                                                        po_nmro_snstro => Nro_siniestro,
                                                        po_codigo      => codigo, 
                                                        po_mensaje     => mensaje);
        
        If codigo = 0 Then
            Update Siniestro w
            set w.COD_SINI_SAI = Nro_siniestro
            Where W.FEC_REP = r.FEC_REP
            And SOLICITUD_SAI_SOLICITUD =  r.Solicitud;
            
            --Delete From Datos_reintentos d
            --Where d.rowid = r.rowid;
            
            
            Update Transaccion
             set ESTADO = 22
            Where  SINIESTRO_FEC_REP =r.FEC_REP
            And SINIESTRO_SOL_SAI_SOLICITUD =r.Solicitud;
            Commit;
        Else 
            Rollback;
            Grabar_Log('error al procesar siniestro de la solicitud '|| r.Solicitud || ' mensaje devuelto: ' ||mensaje);  
            Update Transaccion
            set NUM_INTENTOS = NUM_INTENTOS +1
            Where  SINIESTRO_FEC_REP =r.FEC_REP
            And SINIESTRO_SOL_SAI_SOLICITUD =r.Solicitud;
            Commit;
        End If;
    
    Exception
    When Others Then
     Rollback;
     Grabar_Log('Error inesperado en el proceso de reintentos: '||Sqlerrm);
    Update Transaccion
       set NUM_INTENTOS = NUM_INTENTOS +1
    Where  SINIESTRO_FEC_REP =r.FEC_REP
      And SINIESTRO_SOL_SAI_SOLICITUD =r.Solicitud;
    Commit;  
    
    End;
                                               
End Loop;        

End;
