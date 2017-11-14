CREATE OR REPLACE TYPE admsisa.ty_conceptos FORCE AS OBJECT
(
cod_amparo         varchar2(2),
cod_concepto       varchar2(4),
nuevo_valor        NUMBER (18, 2),
valor_estudio          NUMBER (18, 2)
);
/