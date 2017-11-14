--------------------------------------------------------
--  DDL for Type TY_REPTE_CNCEPTOS
--------------------------------------------------------

  CREATE OR REPLACE TYPE "TY_REPTE_CNCEPTOS" Force As Object  ( 
        Nro_solicitud       number(10),
        fecha_ini_reporte   date,
        fecha_fin_reporte   date,
        cod_concepto        varchar2(4),
        valor_reportado     number(18,2) 
    );

/
