CREATE OR REPLACE TYPE admsisa.TY_RGSTRO_SNSTROS FORCE AS OBJECT 
( 
    NUMERO_SOLICITUD      NUMBER (10),
    NUMERO_SINIESTRO     NUMBER,
    CODIGO               VARCHAR2(10),
    MENSAJE              VARCHAR2(1000)
)
/