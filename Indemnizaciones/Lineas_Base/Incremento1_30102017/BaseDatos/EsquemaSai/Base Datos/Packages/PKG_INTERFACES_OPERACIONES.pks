Create Or Replace Package ADMSISA.Pkg_Interfaces_Operaciones
Is

--funciones
    /*Nombre:           F_VALIDA_DESISTIDOS
  Autor:            jgallo(asw)
  Fecha_creacion:   20-10-2017
  fecha_mod:        20-10-2017
  proposito:        Valido si el siniestro ya fue reportado para la fecha ingresada
  */
  Function F_VALIDA_DESISTIDOS(P_NUMERO_SOLICITUD NUMBER, P_FECHA_MORA DATE) Return VARCHAR2;
  
  --procedimientos
    /*
      Nombre:           prc_registra_ingreso_sai
      Autor:            jgallo(asw)
      Fecha_creacion:   14-09-2017
      fecha_mod:        14-09-2017
      proposito:        procedimiento que registra ingreso de sai.                         
    */
    Procedure prc_registra_ingreso_sai ( pi_ty_datos_ingreso In ty_datos_ingreso, pi_tb_conceptos In ty_tb_conceptos, PI_TA_EXCEPCIONES In TA_EXCEPCIONES,  po_Codigo    Out     VARCHAR2,
                                         po_Mensaje   Out     VARCHAR2 );
                                         

    /*
      Nombre:           prc_registra_aumento
      Autor:            jpmoreno(asw)
      Fecha_creacion:   14-09-2017
      fecha_mod:        14-09-2017
      proposito:        procedimiento  que registra aumento de los valores asegurados.                         
    */
     Procedure prc_registra_aumento ( pi_datos_aumento In ty_datos_aumento, pi_tb_conceptos In ty_tb_conceptos, PI_TA_EXCEPCIONES In TA_EXCEPCIONES, po_Codigo    Out     VARCHAR2 ,
                                  po_Mensaje   Out     VARCHAR2 );
    
    /*
      Nombre:           prc_registra_retiro
      Autor:            jpmoreno(asw)
      Fecha_creacion:   14-09-2017
      fecha_mod:        14-09-2017
      proposito:        procedimiento  que registra retiro de riesgos existentes en las polizas colectivas.                         
    */
   Procedure prc_registra_retiro ( pi_solicitud In number, pi_fecha_retiro In DATE, pi_nit_inmobiliaria In varchar2, po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 ); 
                                         
                                        


    /*
      Nombre:           prc_registra_alerta
      Autor:            jpmoreno(asw)
      Fecha_creacion:   15-09-2017
      fecha_mod:        15-09-2017
      proposito:        procedimiento  que registra alertas del aplicativo.                         
    */
    Procedure prc_registra_alerta ( pi_nro_solicitud In number,  pi_fecha_mora In date, pi_tipo_operacion  In   varchar2,pi_tipo_observacion  In   varchar2,  po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 );
                                         

End Pkg_Interfaces_Operaciones;
/
