CREATE OR REPLACE TYPE admsisa.T_CONSULTA_POLIZA FORCE AS OBJECT 
( /* TODO enter attribute and method declarations here */ 
NUMERO_POLIZA NUMBER(10),
    NUMERO_SOLICITUD NUMBER(10),
    INICIO_VIGENCIA_POLIZA DATE,
    FIN_VIGENCIA_POLIZA DATE,
    DIRECCION VARCHAR2(100)
)
/