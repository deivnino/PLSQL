CREATE OR REPLACE TYPE admsisa.T_ASEGURADOS_MES FORCE AS OBJECT 
( /* TODO enter attribute and method declarations here */ 
    MES VARCHAR(20),
    CANON NUMBER(18, 2),
    ADMINISTRACION NUMBER(18, 2),
    NUMERO_MES VARCHAR2(2)
)
/