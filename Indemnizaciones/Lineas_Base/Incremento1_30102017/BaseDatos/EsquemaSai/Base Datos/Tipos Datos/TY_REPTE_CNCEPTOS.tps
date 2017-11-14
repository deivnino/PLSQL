-- definicion de registro de coceptos de siniestro
CREATE OR REPLACE TYPE admsisa.ty_repte_cnceptos FORCE AS OBJECT  ( 
        Nro_solicitud       number(10),
        fecha_ini_reporte   date,
        fecha_fin_reporte   date,
        cod_concepto        varchar2(4),
        valor_reportado     number(18,2) 
    );
     /