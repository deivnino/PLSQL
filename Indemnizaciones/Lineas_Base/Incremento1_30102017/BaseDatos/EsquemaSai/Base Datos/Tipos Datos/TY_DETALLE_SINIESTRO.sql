CREATE OR REPLACE TYPE admsisa.TY_DETALLE_SINIESTRO AS OBJECT 
( 
  DTOS_DTLLE_SNSTRO     TY_DTOS_DTLLE_SNSTRO,
  CONCEPTOS_SINIESTRO   TB_TY_CONCEPTOS_SINIESTRO,
  OBJECIONES            TB_TY_OBJECION_SUSPENSION,
  SUSPENSIONES          TB_TY_OBJECION_SUSPENSION,
  AUMENTOS              TB_TY_AUMENTOS_SINIESTRO,
  ESTADO_CUENTA         TB_TY_ESTADO_CUENTA
)
/