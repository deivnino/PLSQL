
CREATE OR REPLACE TYPE admsisa.ty_datos_solicitud FORCE AS OBJECT
   (
      Nro_Solicitud         NUMBER (10),
      Nro_Siniestro         NUMBER (10),
      Nombre_Inquilino        VARCHAR2 (120),
      Destinacion            VARCHAR2 (1),
      Poliza                NUMBER (10),
      Tipo_Inmueble         VARCHAR2 (1),
      Direccion                VARCHAR2 (100),
      Ciudad                NUMBER (10),
      Nuevo_vlr_aseg        NUMBER (18, 2),
      Fecha_Novedad         DATE,
      Estado_Solicitud        VARCHAR2 (2),         --(En estudio/Asegurada/Retirada)
      Estado_Siniestro        VARCHAR2 (2),
      Estado_Pago            VARCHAR2 (2),         --(Objetado/Vigente/Suspendido)
      Fecha_Mora            DATE,                 --(Fecha de mora del siniestro)
      Fecha_Ingreso         DATE,                 -- (aseguramiento)
      Fecha_Estudio         DATE,
      Fecha_desocupacion    DATE,
      Fecha_retiro            DATE,
      Fecha_Ini_Contr        DATE,
      Fecha_fin_Contr        DATE,
      Estrato_Econ            NUMBER (1),
      Fecha_mora_Amp_basico    DATE,
      amparos               tb_amparos,
      destinacion_desc      varchar2(240),
      tipo_inmueble_desc   varchar2(240),
      estado_solicitud_desc varchar2(100),
      nombre_ciudad         VARCHAR2(60),
      nro_identificacion_inq NUMBER(12),
      tipo_identificacion_inq VARCHAR2(2),
      Correo_e               varchar2(150)
   );
/
