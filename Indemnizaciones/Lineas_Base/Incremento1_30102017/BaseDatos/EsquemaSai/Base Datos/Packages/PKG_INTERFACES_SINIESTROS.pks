Create Or Replace Package ADMSISA.Pkg_Interfaces_Siniestros
Is
   --variable para manejar el numero del siniestro entre los procesos internos
   vg_nmro_siniestro   NUMBER (10);

   -- variable para hacer seguimiento a los errores
   vg_pos        VARCHAR2 (3);


   Function f_valor_const (pi_tipo In VARCHAR2) Return NUMBER;

  
   /*
     Nombre:           prc_registra_siniestro
     Autor:            jpmoreno(asw)
     Fecha_creacion:   22-08-2017
     fecha_mod:        22-08-2017
     proposito:        procedimiento macro para manejar el siniestro

   */
   Procedure prc_registra_siniestro (pi_siniestro     In     ty_rprte_snstro,
                                       po_nmro_snstro      Out NUMBER,
                                       po_codigo           Out NUMBER,
                                       po_mensaje           Out VARCHAR2);



--   /*
--    Nombre:           prc_registra_amp_integral
--    Autor:            jpmoreno(asw)
--    Fecha_creacion:   15-09-2017
--    fecha_mod:        15-09-2017
--    proposito:        procedimiento  para registrar un siniestro de amparo integral.
--  */
--   Procedure prc_registra_amp_integral (pi_nro_solicitud   In     NUMBER,
--                                        pi_cod_amparo      In     VARCHAR2,
--                                        pi_tb_servicios    In     Tb_repte_cnceptos,
--                                        po_nmro_snstro      Out NUMBER,
--                                        po_codigo       Out NUMBER,
--                                        po_mensaje      Out VARCHAR2);
--
--   /*
--       Nombre:           prc_registra_daños
--       Autor:            jpmoreno(asw)
--       Fecha_creacion:   15-09-2017
--       fecha_mod:        15-09-2017
--       proposito:        procedimiento  para registrar daños y faltantes.
--     */
--   Procedure prc_registra_daños (pi_nro_solicitud   In    NUMBER,
--                                pi_cod_amparo       In    VARCHAR2,
--                                pi_vlr_reclamar    In    NUMBER,
--                                Pi_observacion       In    VARCHAR2,
--                                pi_tipo_registro   In    NUMBER,
--                                po_codigo          Out NUMBER,
--                                po_mensaje          Out VARCHAR2);

   /*
       Nombre:           prc_registra_daños
       Autor:            jgallo(asw)
       Fecha_creacion:   27-09-2017
       fecha_mod:        27-09-2017
       proposito:        Procedimiento que registra siniestros de forma masiva
     */                                
       PROCEDURE PRC_REGISTRA_SINIESTROS_MASIVO(PI_TB_TY_RPRTE_SNSTRO IN TB_TY_RPRTE_SNSTRO, PO_TB_TY_RGSTRO_SNSTROS OUT TB_TY_RGSTRO_SNSTROS, PO_CODIGO OUT VARCHAR2,
  PO_MENSAJE OUT VARCHAR2);
                              
                              
 /*Nombre:         PRC_CALCULA_CUPO_AMP_INT
  Autor:            jgallo(asw)
  Fecha_creacion:   20-10-2017
  fecha_mod:        20-10-2017
  proposito:        Devuelve el cupo de amparo integral utilizado y los conceptos de con sus respectivas fechas
  */
 PROCEDURE PRC_CALCULA_CUPO_AMP_INT(P_NUMERO_SOLICITUD IN NUMBER, PO_VALOR_GIRADO OUT NUMBER, PO_TB_TY_CUPO_SINIESTRO OUT TB_TY_CUPO_SINIESTRO,
                                    PO_CODIGO OUT VARCHAR2, PO_MENSAJE OUT VARCHAR2);
End Pkg_Interfaces_Siniestros;
/
