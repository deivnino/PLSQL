CREATE OR REPLACE TYPE admsisa.ty_amparo FORCE AS OBJECT (
    tipo_amparo     Varchar2(1),
    cod_amparo      Varchar2(2),
    cod_concept     varchar2(4),
    desc_concep     varchar2(50),
    vlr_solicitud   number(18,2),
    vlr_aseg        number(18,2)
    );
	/