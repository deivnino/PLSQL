
  -- tipo para encapsular toda la informacion de un siniestro. 
  CREATE OR REPLACE TYPE admsisa.ty_rprte_snstro FORCE AS OBJECT (
    datos_b             ty_dtos_bscos_snstro,
    t_conceptos         tb_repte_cnceptos,
    t_servicios         tb_repte_cnceptos,
    t_doctos            tb_doctos_snstro
   );
   /