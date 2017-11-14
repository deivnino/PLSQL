CREATE OR REPLACE TYPE admsisa.ty_reg_sini_basico FORCE AS OBJECT
(
Nro_Solicitud         NUMBER (10),
Fecha_Mora            DATE,
Nro_siniestro         NUMBER (10),
Poliza                NUMBER (10),
Id_inquilino          number(12),
Inquilino             VARCHAR2(200),
Direccion             VARCHAR2 (100),
Estado_Siniestro      VARCHAR2(20),
Amparo                VARCHAR2(50)
)
/