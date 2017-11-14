CREATE OR REPLACE TYPE admsisa.ty_cupo_siniestro FORCE AS OBJECT
( /* TODO enter attribute and method declarations here */ 
cod_servicio VARCHAR2(2),
fecha_mora DATE,
fecha_inicio DATE,
fecha_fin DATE,
valor NUMBER(30,5)
)
/
