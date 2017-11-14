--------------------------------------------------------
--  DDL for Type TY_RPRTE_SNSTRO
--------------------------------------------------------

  CREATE OR REPLACE TYPE "TY_RPRTE_SNSTRO" Force As Object (
    datos_b             ty_dtos_bscos_snstro,
    t_conceptos         tb_repte_cnceptos,
    t_servicios         tb_repte_cnceptos,
    t_doctos            tb_doctos_snstro
   );

/
