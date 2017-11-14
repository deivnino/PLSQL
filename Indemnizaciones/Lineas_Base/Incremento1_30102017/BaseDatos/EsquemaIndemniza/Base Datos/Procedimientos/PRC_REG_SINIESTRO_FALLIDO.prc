Create Or Replace Procedure INDEMNIZA.Prc_Reg_siniestro_fallido(pi_fec_rep In date, pi_solicitud In number, pi_siniestro In TY_RPRTE_SNSTRO, po_mensaje Out varchar2)
Is 
Begin 
    If pi_siniestro Is Null Then
        po_mensaje := ' El objeto siniestro no puede ser nulo';
    Else 
    Begin
        Insert Into Datos_reintentos
        Values (pi_fec_rep,pi_solicitud,pi_siniestro);
        po_mensaje := Null;
    Exception 
    When Others Then 
     po_mensaje := ' Error inesperado en el alacenamiento de la data: ' ||Sqlerrm;
    End;
    End If;

End; 