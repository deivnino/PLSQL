CREATE OR REPLACE TYPE admsisa.TY_DATOS_AUMENTO AS OBJECT 
( 
  NUMERO_SOLICITUD NUMBER(10),
  FECHA_AUMENTO DATE,
  NIT_INMOBILIARIA VARCHAR2(20)
)
/