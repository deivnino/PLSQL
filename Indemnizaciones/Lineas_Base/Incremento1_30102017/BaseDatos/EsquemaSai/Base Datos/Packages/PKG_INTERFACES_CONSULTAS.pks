Create Or Replace Package ADMSISA.Pkg_Interfaces_Consultas
Is



/*********************** Funciones ***************************/

Function f_solicitud_aseg (pi_solicitud In number) Return number;

/*Nombre:           F_CONSULTAR_ESTADO_SOLICITUD
  Autor:            jgallo(asw)
  Fecha_creacion:   17-10-2017
  fecha_mod:        17-10-2017
  proposito:        Determina el estado en que se encuentra una solicitud
  */
  Function F_CONSULTAR_ESTADO_SOLICITUD(P_NUMERO_SOLICITUD NUMBER) Return VARCHAR2;
  
  /*Nombre:           F_CONSULTAR_VALOR_ASEGURADO
  Autor:            jgallo(asw)
  Fecha_creacion:   18-10-2017
  fecha_mod:        18-10-2017
  proposito:        Determina el valor asegurado de un concepto de una solicitud
  */
  Function F_VALOR_ASEGURADO_CONCEPTO(P_NUMERO_SOLICITUD NUMBER, P_ESTADO_SOLICITUD varchar2, P_CONCEPTO varchar2) Return NUMBER;

   Procedure Prc_cons_datos_basicos_sai (pi_nro_solicitud In NUMBER, 
                                         pi_nit_inmobiliaria In NUMBER Default Null, 
                                         po_ty_solicitud Out ty_datos_solicitud,
                                         po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 );
   
   
/*********************** Procedimientos ***************************/   

  -- Author  : Asesoftware - Jorge Gallo.
  -- Created : 09/08/2017.
  -- Purpose :  Procedimiento que permite consultar las polizas asociadas al numero de identificacion de un usuario
  -- Modificado por:
  --
  --
    Procedure PRC_CONSULTAR_PLZAS_ASCDAS
    (
        P_NUMERO_IDENTIFICACION In VARCHAR2,
        P_TABLE_PLZAS Out T_TABLE_PLZAS,
        P_CODIGO_RESPUESTA Out VARCHAR2,
        P_MENSAJE_RESPUESTA Out VARCHAR2
    );  
   
       -- Author  : Asesoftware - Jorge Gallo.
  -- Created : 24/08/2017.
  -- Purpose :  Procedimiento que permite consultar los valores asegurados por mes de una solicitud en especifico
  -- Modificado por:
  --
  --
    Procedure PRC_CONSULTAR_ASEGURADOS_MES
    (
        P_NUMERO_SOLICITUD In NUMBER,
        P_FECHA_MORA In DATE,
        P_TABLE_ASEGURADOS_MES Out T_TABLE_ASEGURADOS_MES,
        P_CODIGO_RESPUESTA Out VARCHAR2,
        P_MENSAJE_RESPUESTA Out VARCHAR2
    ); 

    
    /*
      Nombre:           prc_consulta_ubicacion_j
      Autor:            jpmoreno(asw)
      Fecha_creacion:   15-09-2017
      fecha_mod:        15-09-2017
      proposito:        procedimiento  consultar la ubicacion juridica de un siniestro                    
    */
--    Procedure prc_consulta_ubicacion_j ( pi_nro_solicitud In number, pi_fecha_mora In date, po_ubicacion  Out   varchar2,  po_Codigo    Out     VARCHAR2 ,
--                                         po_Mensaje   Out     VARCHAR2 ); 
                                         
  

  
  
    /*
      Nombre:           PRC_CONSULTAR_FECHAS_SINIESTRO
      Autor:            jgallo(asw)
      Fecha_creacion:   21-09-2017
      fecha_mod:        21-09-2017
      proposito:        Obtiene una lista con las fechas de mora e información de los siniestros asociados a una solicitud
    */
    Procedure PRC_CONSULTAR_FECHAS_SINIESTRO(P_NUMERO_SOLICITUD In VARCHAR2, PO_TB_TY_DATOS_SINIESTRO Out TB_TY_DATOS_SINIESTRO, po_Codigo    Out     VARCHAR2 , 
    po_Mensaje   Out     VARCHAR2 );
    
      /*Nombre:           PRC_CONSULTA_ESTADO_SINIESTRO
  Autor:            jgallo(asw)
  Fecha_creacion:   12-10-2017
  fecha_mod:        12-10-2017
  proposito:        Obtiene información de estado de siniestro y estado de pago relacionadas a una solicitud
  */
    Procedure PRC_CONSULTAR_ESTADO_SINIESTRO(PI_NUMERO_SOLICITUD In NUMBER, PI_FECHA_MORA In DATE, 
    PO_ESTADO_SINIESTRO Out VARCHAR2, PO_ESTADO_PAGO Out VARCHAR2, PO_CODIGO Out VARCHAR2,  PO_MENSAJE Out VARCHAR2);

  /*Nombre:           PRC_CONSULTA_INFORMACION_DOCUMENTOS
  Autor:            jgallo(asw)
  Fecha_creacion:   17-10-2017
  fecha_mod:        17-10-2017
  proposito:        Obtiene información relacionada al arrendatario y al inmueble
  */
    Procedure PRC_CONSULTA_INFO_DOCUMENTO(PI_NUMERO_SOLICITUD In NUMBER,PO_NOMBRE_INQUILINO Out VARCHAR2,
                                              PO_DOCUMENTO Out VARCHAR2, PO_DIRECCION Out VARCHAR2,PO_CANON Out NUMBER
                                              ,PO_CODIGO_RESPUESTA Out VARCHAR, PO_MENSAJE_RESPUESTA Out VARCHAR2);
      /*
      Nombre:           prc_consulta_siniestro
      Autor:            jpmoreno(asw)
      Fecha_creacion:   15-10-2017
      fecha_mod:        15-10-2017
      proposito:        procedimiento  consultar el listado de siniestros de una solicitud                   
    */
    Procedure prc_consulta_siniestros ( pi_nro_solicitud In number, pi_nit_inmobiliaria In NUMBER, po_siniestros  Out  ty_tb_sini_basico ,  po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 );   
                                         
                                         
    /*
      Nombre:           PRC_CONSULTA_DETALLE_SINIESTRO
      Autor:            jgallo(asw)
      Fecha_creacion:   30-10-2017
      fecha_mod:        30-10-2017
      proposito:        Procedimiento que retorna el detalle de un siniestro
    */
    Procedure PRC_CONSULTA_DETALLE_SINIESTRO ( pi_nro_solicitud In number, pi_fcha_mora In date, po_ty_detalle_siniestro  Out  ty_detalle_siniestro ,  po_Codigo    Out     VARCHAR2 ,
                                         po_Mensaje   Out     VARCHAR2 );   
                                              
End Pkg_Interfaces_Consultas;
/
