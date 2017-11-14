   --tipo para almacenar los datos basicos de la solicitud del siniestro
 CREATE OR REPLACE TYPE admsisa.ty_dtos_bscos_snstro FORCE AS OBJECT (
        Nro_solicitud       number(10),
        Nro_poliza          number(10),
        nit_tercero         number(12),
        fecha_mora          date,
        fecha_ini_contr     date,
        fecha_fin_contr     date,
        cod_amparo          varchar2(2),
        Observaciones       varchar2(800),
        tipo_poliza         varchar2(1),
        tipo_registro       number(1)
   ); 
   /