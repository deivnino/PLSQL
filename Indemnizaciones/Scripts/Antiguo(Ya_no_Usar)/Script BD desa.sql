--------------------------------------------------------
--  DDL for Sequence AUTORIZACION_INDEMNIZACION_COD
--------------------------------------------------------

   CREATE SEQUENCE  "AUTORIZACION_INDEMNIZACION_COD"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_ALERTA
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_ALERTA"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_AUTO_DESOCU
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_AUTO_DESOCU"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 7 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_AUTO_INDEN
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_AUTO_INDEN"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_DOC_NOTIFICACION
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_DOC_NOTIFICACION"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_DOC_SOPORTE
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_DOC_SOPORTE"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_DOMINIO
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_DOMINIO"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_LIS_DOCUMENTO
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_LIS_DOCUMENTO"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_NOT_CORREO
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_NOT_CORREO"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_PARAMETRO
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_PARAMETRO"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_PERFIL
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_PERFIL"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_SERV_PUBLICO
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_SERV_PUBLICO"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_TRANSACCION
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_TRANSACCION"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_VAL_DOMINIO
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_VAL_DOMINIO"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEC_VAL_REPORTADO
--------------------------------------------------------

   CREATE SEQUENCE  "SEC_VAL_REPORTADO"  MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE  ORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Sequence SEQ_LOGERROR
--------------------------------------------------------

   CREATE SEQUENCE  "SEQ_LOGERROR"  MINVALUE 1 MAXVALUE 999999999 INCREMENT BY 1 START WITH 81 CACHE 20 NOORDER  NOCYCLE ;
--------------------------------------------------------
--  DDL for Table ALERTA
--------------------------------------------------------

  CREATE TABLE "ALERTA" 
   (	"COD_ALE" NUMBER(15,0), 
	"FEC_ALE" DATE DEFAULT SYSDATE, 
	"OBSERVACION" VARCHAR2(400 BYTE), 
	"ESTADO" NUMBER(20,0), 
	"TRANSACCION_COD_TRAN" NUMBER(5,0)
   ) ;

   COMMENT ON COLUMN "ALERTA"."COD_ALE" IS 'codigo alerta - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "ALERTA"."FEC_ALE" IS 'fecha alerta - Campo donde se almacena la fecha del sistema en la que se esta realizando la alerta.';
   COMMENT ON COLUMN "ALERTA"."OBSERVACION" IS 'Campo que indica la observacion de la alerta,la razon por la que se esta generando la alerta.';
   COMMENT ON COLUMN "ALERTA"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';
   COMMENT ON COLUMN "ALERTA"."TRANSACCION_COD_TRAN" IS 'Codigo autoincremental de la tabla';
   COMMENT ON TABLE "ALERTA"  IS 'Tabla donde se registran las Alertas que se requieran hacer sobre una transaccion,generalmente anulaciones.';
--------------------------------------------------------
--  DDL for Table AUMENTO
--------------------------------------------------------

  CREATE TABLE "AUMENTO" 
   (	"FEC_AUMENTO" DATE, 
	"CANO_ARRENDA_AUME" NUMBER(20,2), 
	"VAL_ADMIN_AUM" NUMBER(20,2), 
	"PERIODO" VARCHAR2(10 BYTE), 
	"ESTADO" NUMBER(20,0), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "AUMENTO"."FEC_AUMENTO" IS 'fecha aumento - Fecha en la cual se esta realizando el aumento.';
   COMMENT ON COLUMN "AUMENTO"."CANO_ARRENDA_AUME" IS 'canon arrendamiento aumento - Valor del canon de arrendamiento que esta siendo aumentado';
   COMMENT ON COLUMN "AUMENTO"."VAL_ADMIN_AUM" IS 'valor administracion aumento - Valor de administracion que esta siendo aumentado';
   COMMENT ON COLUMN "AUMENTO"."PERIODO" IS 'Indica el periodo calculado en SAI en el cual se hace el aumento.';
   COMMENT ON COLUMN "AUMENTO"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';
   COMMENT ON TABLE "AUMENTO"  IS 'Tabla donde se registran los aumentos que se le van a realizar a una solicitud.';
--------------------------------------------------------
--  DDL for Table AUMENTO_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "AUMENTO_PENDIENTE" 
   (	"TIPO_OBS_AUM" NUMBER(20,0), 
	"FEC_PEND" DATE DEFAULT SYSDATE, 
	"ESTADO" NUMBER(20,0), 
	"AUMENTO_FEC_AUMENTO" DATE DEFAULT SYSDATE, 
	"AUMENTO_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "AUMENTO_PENDIENTE"."TIPO_OBS_AUM" IS 'Tabla Dominio - tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes';
   COMMENT ON COLUMN "AUMENTO_PENDIENTE"."FEC_PEND" IS 'fecha pendiente- Fecha por la cual el aumento quedo en aumentos pendietes.';
   COMMENT ON COLUMN "AUMENTO_PENDIENTE"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';
   COMMENT ON COLUMN "AUMENTO_PENDIENTE"."AUMENTO_FEC_AUMENTO" IS 'fecha aumento - Fecha en la cual se esta realizando el aumento.';
   COMMENT ON TABLE "AUMENTO_PENDIENTE"  IS 'Aumento Pendiente - Tabla donde se registran los aumentos pendientes,los que no cumplieron con las reglas de negocio definidas.';
--------------------------------------------------------
--  DDL for Table AUTORIZACION_DESOCUPACIOON
--------------------------------------------------------

  CREATE TABLE "AUTORIZACION_DESOCUPACIOON" 
   (	"CODIGO_AUT_DES" NUMBER(15,0), 
	"AREA_AUTO" VARCHAR2(10 BYTE), 
	"FEC_AUTO" DATE DEFAULT SYSDATE, 
	"RESPONSABLE" NUMBER(10,0), 
	"ESTADO" NUMBER(20,0), 
	"OBSERVACION" VARCHAR2(400 BYTE), 
	"TIPO_MOT" NUMBER(20,0), 
	"DESO_PEND_TIPO_OBS" NUMBER(20,0), 
	"DESO_PEND_DESOC_FEC_REGI" DATE, 
	"DESO_PEND_DESOC_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."CODIGO_AUT_DES" IS 'Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."AREA_AUTO" IS 'Area Autorizacion - Dominio que establece qe area va a realizar la autorización.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."FEC_AUTO" IS 'fecha autorizacion - Campo donde se almacena la fecha y la hora en el que se proceso la autorizacion.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."RESPONSABLE" IS 'Campo donde se almacena el codigo del reponsable de la autorizacion/rechazo del pendiente.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."ESTADO" IS 'Campo que indica el estado de la autorizacion,si fue aprobada o rechazada.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."OBSERVACION" IS 'Campo donde se registra la observacion realizada en la aprobacion o en el rechazo.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."TIPO_MOT" IS 'tipo motivo - Dominio que indica el motivo por el cual esta siendo rechazada la novedad pendiente.';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."DESO_PEND_TIPO_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   COMMENT ON COLUMN "AUTORIZACION_DESOCUPACIOON"."DESO_PEND_DESOC_FEC_REGI" IS 'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';
   COMMENT ON TABLE "AUTORIZACION_DESOCUPACIOON"  IS 'Autorizacion Desocupacion - Tabla donde se registran las autorizaciones de desocupaciones realizadas,aprobar o rechazar segun sea el caso.';
--------------------------------------------------------
--  DDL for Table AUTORIZACION_INDEMNIZACION
--------------------------------------------------------

  CREATE TABLE "AUTORIZACION_INDEMNIZACION" 
   (	"COD_AUT_IND" NUMBER(15,0), 
	"AREA_AUTO" VARCHAR2(10 BYTE), 
	"FEC_AUTOR" DATE DEFAULT SYSDATE, 
	"RESPONSABLE" NUMBER(10,0), 
	"ESTADO" NUMBER(20,0), 
	"TIPO_MOT" NUMBER(20,0), 
	"OBSERVACION" VARCHAR2(400 BYTE), 
	"DAN_FALT_PEND_TIPO_OBS" NUMBER(20,0), 
	"DAN_FALT_PEND_FEC_REP" DATE, 
	"DAN_FALT_PEND_SOLICITUD" NUMBER(10,0), 
	"SINI_PEND_TIP_OBS" NUMBER(20,0), 
	"SINI_PEND_SINIE_FEC_REP" DATE, 
	"SINI_PEND_SINIE_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."COD_AUT_IND" IS 'codigo autorizacion indenmnizacion - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."AREA_AUTO" IS 'area autorizar - Dominio que establece quien va a realizar la autorización';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."FEC_AUTOR" IS 'feccha auto - Campo donde se almacena la fecha y la hora en el que se proceso la autorizacion.';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."RESPONSABLE" IS 'Campo donde se almacena el codigo del reponsable de la autorizacion/rechazo del pendiente.';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."ESTADO" IS 'Campo que indica el estado de la autorizacion,si fue aprobada o rechazada.';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."TIPO_MOT" IS 'tipo motivo - Dominio que indica el motivo por el cual esta siendo rechazada la novedad pendiente.';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."OBSERVACION" IS 'Campo donde se almacena la observacion del rechazo o aprobacion del pendinte.';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."DAN_FALT_PEND_TIPO_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."DAN_FALT_PEND_FEC_REP" IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."SINI_PEND_TIP_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   COMMENT ON COLUMN "AUTORIZACION_INDEMNIZACION"."SINI_PEND_SINIE_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   COMMENT ON TABLE "AUTORIZACION_INDEMNIZACION"  IS 'Autorizacion Idenmnizacion - Tabla donde se registraran las autorizaciones realizadas para el reporte de siniestros,ya sea aprobar o rechazar la solicitud segun sea el caso.';
--------------------------------------------------------
--  DDL for Table AUTORIZACION_OPERACION
--------------------------------------------------------

  CREATE TABLE "AUTORIZACION_OPERACION" 
   (	"COD_AUTO_OPER" NUMBER(15,0), 
	"OBSERVACION" VARCHAR2(200 BYTE), 
	"AREA_AUTO" VARCHAR2(10 BYTE), 
	"FEC_AUTO" DATE DEFAULT SYSDATE, 
	"RESPONSABLE" NUMBER(10,0), 
	"ESTADO" NUMBER(20,0), 
	"TIPO_MOT" NUMBER(20,0), 
	"ING_PEND_INGR_FEC_REGISTRO_ING" DATE, 
	"ING_PEND_INGR_SOLICITUD" NUMBER(10,0), 
	"ING_PEND_TIPO_OBS_ING" NUMBER(20,0), 
	"AUM_PEND_AUME_SOLICITUD" NUMBER(10,0), 
	"AUM_PEND_AUM_FEC_AUMENTO" DATE DEFAULT SYSDATE, 
	"AUM_PEND_TIPO_OBS_AUM" NUMBER(20,0)
   ) ;

   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."COD_AUTO_OPER" IS 'codigo autorizacion operacion - Codigo autoincremental de la tabla';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."AREA_AUTO" IS 'area autorizar - Dominio que establece quien va a realizar la autorización';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."FEC_AUTO" IS 'fecha autorizacion - Campo donde se almacena la fecha y la hora en el que se proceso la autorizacion.';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."RESPONSABLE" IS 'Campo donde se almacena el codigo del reponsable de la autorizacion/rechazo del pendiente.';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."ESTADO" IS 'Tabla Dominio - Campo que indica el estado de la autorizacion,si fue aprobada o rechazada.';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."TIPO_MOT" IS 'Tabla Dominio - tipo motivo - Dominio que indica el motivo por el cual esta siendo rechazada la novedad pendiente.';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."ING_PEND_INGR_FEC_REGISTRO_ING" IS 'Fecha del sistema donde de cuado se esta realizando el registro.';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."ING_PEND_TIPO_OBS_ING" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."AUM_PEND_AUM_FEC_AUMENTO" IS 'fecha aumento - Fecha en la cual se esta realizando el aumento.';
   COMMENT ON COLUMN "AUTORIZACION_OPERACION"."AUM_PEND_TIPO_OBS_AUM" IS 'Tabla Dominio - tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes';
   COMMENT ON TABLE "AUTORIZACION_OPERACION"  IS 'Autorizacion Desocupacion - Tabla donde se registran las autorizaciones de las operaciones de Ingresos y Aumentos,segun sea el caso,ya sea rechazar o aprobar la solicitud.';
--------------------------------------------------------
--  DDL for Table DANIO_FALTANTE_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "DANIO_FALTANTE_PENDIENTE" 
   (	"TIPO_OBS" NUMBER(20,0), 
	"FEC_PEND" DATE DEFAULT SYSDATE, 
	"ESTADO" NUMBER(20,0), 
	"REG_DAN_FALT_FEC_REP" DATE DEFAULT SYSDATE, 
	"REG_DAN_FALT_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "DANIO_FALTANTE_PENDIENTE"."TIPO_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   COMMENT ON COLUMN "DANIO_FALTANTE_PENDIENTE"."FEC_PEND" IS 'fecha pendiente - Campor donde se almacena la fecha del sistema donde la solicitud quedo como pendiente.';
   COMMENT ON COLUMN "DANIO_FALTANTE_PENDIENTE"."ESTADO" IS 'Campo que por medio de un dominio indica el estado de registro.';
   COMMENT ON COLUMN "DANIO_FALTANTE_PENDIENTE"."REG_DAN_FALT_FEC_REP" IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   COMMENT ON TABLE "DANIO_FALTANTE_PENDIENTE"  IS 'Danios Faltantes Pendientes - Tabla donde se registran las solicitudes de reporte de daños y faltantes que quedan pendientes,que no cumplieron las reglas de negocio definidas';
--------------------------------------------------------
--  DDL for Table DESISTIMIENTO
--------------------------------------------------------

  CREATE TABLE "DESISTIMIENTO" 
   (	"FEC_REG" DATE, 
	"COD_SINI" NUMBER(10,0), 
	"FEC_DESI" DATE, 
	"PERIODO" VARCHAR2(10 BYTE), 
	"TIPO_POLI" VARCHAR2(200 BYTE), 
	"EST_SINI" NUMBER(20,0), 
	"EST_PAGO" NUMBER(20,0), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "DESISTIMIENTO"."FEC_REG" IS 'fecha registro - fecha del sistema en el que se esta haciendo el desistimiento.';
   COMMENT ON COLUMN "DESISTIMIENTO"."COD_SINI" IS 'codigo siniestro - Codigo del siniestro generado en SAI.';
   COMMENT ON COLUMN "DESISTIMIENTO"."FEC_DESI" IS 'fecha desistimiento - Campor donde se registra la fecha del desistimiento.';
   COMMENT ON COLUMN "DESISTIMIENTO"."PERIODO" IS 'Indica el periodo efectivo calculado en SAI.';
   COMMENT ON COLUMN "DESISTIMIENTO"."TIPO_POLI" IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';
   COMMENT ON COLUMN "DESISTIMIENTO"."EST_SINI" IS 'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';
   COMMENT ON COLUMN "DESISTIMIENTO"."EST_PAGO" IS 'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';
   COMMENT ON TABLE "DESISTIMIENTO"  IS 'Tabla donde se registran los desistimientos que se realizen sobre una solicitud que se encuetre siniestrada.';
--------------------------------------------------------
--  DDL for Table DESOCUPACION
--------------------------------------------------------

  CREATE TABLE "DESOCUPACION" 
   (	"FEC_REGI" DATE, 
	"FEC_DESO" DATE, 
	"TIP_POL" VARCHAR2(200 BYTE), 
	"PERIODO" VARCHAR2(10 BYTE), 
	"EST_SINI" NUMBER(20,0), 
	"EST_PAG" NUMBER(20,0), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"FEC_MOR" DATE, 
	"NUM_SINI" NUMBER(20,0)
   ) ;

   COMMENT ON COLUMN "DESOCUPACION"."FEC_REGI" IS 'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';
   COMMENT ON COLUMN "DESOCUPACION"."FEC_DESO" IS 'fecha desocupacion - Fecha en la cual se va a realizar la desocupacion.';
   COMMENT ON COLUMN "DESOCUPACION"."TIP_POL" IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';
   COMMENT ON COLUMN "DESOCUPACION"."PERIODO" IS 'Indica el periodo efectivo calculado en SAI.';
   COMMENT ON COLUMN "DESOCUPACION"."EST_SINI" IS 'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';
   COMMENT ON COLUMN "DESOCUPACION"."EST_PAG" IS 'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';
   COMMENT ON COLUMN "DESOCUPACION"."FEC_MOR" IS 'Fecha de mora del siniestro';
   COMMENT ON COLUMN "DESOCUPACION"."NUM_SINI" IS 'Numero del siniestro.';
   COMMENT ON TABLE "DESOCUPACION"  IS 'Tabla donde se registran las desocupaciones que se van a realizar de manera colectiva e individual segun sea el caso.';
--------------------------------------------------------
--  DDL for Table DESOCUPACION_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "DESOCUPACION_PENDIENTE" 
   (	"TIPO_OBS" NUMBER(20,0), 
	"FEC_PEN" DATE DEFAULT SYSDATE, 
	"DESOCUPACION_FEC_REGI" DATE DEFAULT SYSDATE, 
	"DESOCUPACION_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "DESOCUPACION_PENDIENTE"."TIPO_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   COMMENT ON COLUMN "DESOCUPACION_PENDIENTE"."FEC_PEN" IS 'fecha pendiente - Fecha del sistema en la que el registro quedo en pendiente.';
   COMMENT ON COLUMN "DESOCUPACION_PENDIENTE"."DESOCUPACION_FEC_REGI" IS 'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';
   COMMENT ON TABLE "DESOCUPACION_PENDIENTE"  IS 'Desocupacion Pendiente - Tabla donde se registran las desocupaciones que no cumplieron con las reglas de negocio definidas y quedan pendietes a una auotorizacion.';
--------------------------------------------------------
--  DDL for Table DOCUMENTO_NOTIFICACION
--------------------------------------------------------

  CREATE TABLE "DOCUMENTO_NOTIFICACION" 
   (	"COD_DOC_NOTIFICACION" NUMBER(15,0), 
	"COD_DOC" NUMBER(5,0), 
	"COD_REPO" NUMBER(10,0), 
	"RUTA_REPO" VARCHAR2(400 BYTE), 
	"ESTADO" NUMBER(20,0), 
	"NOTIFICACION_SOLICITUD" NUMBER(10,0), 
	"NOTIFICACION_FEC_NOTI" DATE
   ) ;

   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."COD_DOC_NOTIFICACION" IS 'Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."COD_DOC" IS 'codigo documento - Codigo SAI del documento que se esta solicitando.';
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."COD_REPO" IS 'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."RUTA_REPO" IS 'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."ESTADO" IS 'Tabla Dominio - Indicaria si ya fue cargado el archivo solicitado';
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."NOTIFICACION_SOLICITUD" IS 'Numero de solicitud que a la que se le esta haciendo la novedad.';
   COMMENT ON COLUMN "DOCUMENTO_NOTIFICACION"."NOTIFICACION_FEC_NOTI" IS 'fecha notificacion - Fecha del sistema de cuando se esta generando la notificacion.';
   COMMENT ON TABLE "DOCUMENTO_NOTIFICACION"  IS 'Documento Notificacion - Tabla donde se registran los documentos que han sido solicitados en la notificacion para las inmobiliarias.';
--------------------------------------------------------
--  DDL for Table DOCUMENTO_SOPORTE
--------------------------------------------------------

  CREATE TABLE "DOCUMENTO_SOPORTE" 
   (	"COD_DOC_SOP" NUMBER(15,0), 
	"NOMBRE" VARCHAR2(200 BYTE), 
	"COD_REPO" NUMBER(10,0), 
	"RUTA_REPO" VARCHAR2(400 BYTE), 
	"REG_DAN_FALT_FEC_REP" DATE, 
	"REG_DAN_FALT_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "DOCUMENTO_SOPORTE"."COD_DOC_SOP" IS 'codigo documento soporte - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "DOCUMENTO_SOPORTE"."NOMBRE" IS 'Campo donde se almacena el nombre del documento.';
   COMMENT ON COLUMN "DOCUMENTO_SOPORTE"."COD_REPO" IS 'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';
   COMMENT ON COLUMN "DOCUMENTO_SOPORTE"."RUTA_REPO" IS 'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';
   COMMENT ON COLUMN "DOCUMENTO_SOPORTE"."REG_DAN_FALT_FEC_REP" IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   COMMENT ON TABLE "DOCUMENTO_SOPORTE"  IS 'DOCUMENTO SOPORTE - Tabla donde se almacenan los documentos soportes que se adjuntan en el reporte de daño y faltantes.';
--------------------------------------------------------
--  DDL for Table DOMINIO
--------------------------------------------------------

  CREATE TABLE "DOMINIO" 
   (	"COD_DOMINIO" NUMBER(15,0), 
	"NOMBRE" VARCHAR2(200 BYTE), 
	"ESTADO" VARCHAR2(20 BYTE)
   ) ;

   COMMENT ON COLUMN "DOMINIO"."COD_DOMINIO" IS 'Codigo autoincremental de la tabla';
   COMMENT ON COLUMN "DOMINIO"."NOMBRE" IS 'Campo que indica el nombre que va a tener el dominio.';
   COMMENT ON COLUMN "DOMINIO"."ESTADO" IS 'Dominio que indica el estado del dominio,si este esta activo o esta inactivo.';
   COMMENT ON TABLE "DOMINIO"  IS 'Tabla donde se crearan los dominios que se haran uso en el sistema.';
--------------------------------------------------------
--  DDL for Table INGRESO
--------------------------------------------------------

  CREATE TABLE "INGRESO" 
   (	"FEC_REGISTRO_ING" DATE, 
	"FEC_INGRESO" DATE, 
	"CAN_ARRENDAMIENTO" NUMBER(20,2), 
	"VAL_ADMINISTRACION" NUMBER(20,2), 
	"PERIODO" VARCHAR2(10 BYTE), 
	"ESTADO" NUMBER, 
	"TIPO_IVA" NUMBER(20,0), 
	"VAL_AMP_INTEGRAL" NUMBER(20,0), 
	"METRAJE_AMP_HOGAR" NUMBER(20,2), 
	"VAL_AMP_HOGAR" NUMBER(20,2), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "INGRESO"."FEC_REGISTRO_ING" IS 'Fecha del sistema donde de cuado se esta realizando el registro.';
   COMMENT ON COLUMN "INGRESO"."FEC_INGRESO" IS 'fecha ingreso  - Fecha en la que se realizó el ingreso.';
   COMMENT ON COLUMN "INGRESO"."CAN_ARRENDAMIENTO" IS 'canon arrendamiento - Valor del canon de arrendamiento asegurado.';
   COMMENT ON COLUMN "INGRESO"."VAL_ADMINISTRACION" IS 'valor administracion - Valor del cuota de administración asegurado.';
   COMMENT ON COLUMN "INGRESO"."PERIODO" IS 'Indica el periodo efectivo calculado en SAI.';
   COMMENT ON COLUMN "INGRESO"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';
   COMMENT ON COLUMN "INGRESO"."TIPO_IVA" IS 'Tabla Dominio - Dominio que indica el tipo de iva que va a tener como ingreso,si aplica o no.';
   COMMENT ON COLUMN "INGRESO"."VAL_AMP_INTEGRAL" IS 'Tabla Dominio - valor amparo integral - Valor del amapro integral,el cual se va a asegurar';
   COMMENT ON COLUMN "INGRESO"."METRAJE_AMP_HOGAR" IS 'Valor del mentraje del inmueble que se va a asegurar por amparo hogar.';
   COMMENT ON COLUMN "INGRESO"."VAL_AMP_HOGAR" IS 'Valor que se va a asegurar como amaparo hogar.';
   COMMENT ON TABLE "INGRESO"  IS 'Tabla donde se registran los ingresos de las solicitudes.';
--------------------------------------------------------
--  DDL for Table INGRESO_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "INGRESO_PENDIENTE" 
   (	"TIPO_OBS_ING" NUMBER(20,0), 
	"FEC_PEND" DATE DEFAULT SYSDATE, 
	"ESTADO" NUMBER(20,0), 
	"INGRESO_FEC_REGISTRO_ING" DATE DEFAULT SYSDATE, 
	"INGRESO_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "INGRESO_PENDIENTE"."TIPO_OBS_ING" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo en los pendietes';
   COMMENT ON COLUMN "INGRESO_PENDIENTE"."FEC_PEND" IS 'fecha pendiente - Fecha en la cual el ingreso quedo pendiente.';
   COMMENT ON COLUMN "INGRESO_PENDIENTE"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';
   COMMENT ON COLUMN "INGRESO_PENDIENTE"."INGRESO_FEC_REGISTRO_ING" IS 'Fecha del sistema donde de cuado se esta realizando el registro.';
   COMMENT ON TABLE "INGRESO_PENDIENTE"  IS 'Tabla donde se registran los ingresos pendientes,los que no cumplieron con las reglas de negocio definidas.';
--------------------------------------------------------
--  DDL for Table LISTA_DOCUMENTO
--------------------------------------------------------

  CREATE TABLE "LISTA_DOCUMENTO" 
   (	"COD_LIST_DOC" NUMBER(15,0), 
	"COD_DOC" NUMBER(5,0), 
	"NOMBRE" VARCHAR2(200 BYTE), 
	"APLICA" CHAR(1 BYTE), 
	"COD_REPO" NUMBER(10,0), 
	"RUTA_REPO" VARCHAR2(400 BYTE), 
	"SINIESTRO_FEC_REP" DATE, 
	"SINI_SOL_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "LISTA_DOCUMENTO"."COD_LIST_DOC" IS 'codigo lista documento - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."COD_DOC" IS 'codigo documento - En este atribuo se almacena el codigo que tiene el documeno en SAI.';
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."NOMBRE" IS 'Nombre que tiene el documento en SAI.';
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."APLICA" IS 'Campo que indica si el documento aplica o no para el reporte de siniestro.';
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."COD_REPO" IS 'codigo repositorio - Campo donde se almancena el codigo que se genera en el repositorio.';
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."RUTA_REPO" IS 'ruta repositorio - Campo donde se almacena la ruta fisica de los archivos cargados en el repositorio.';
   COMMENT ON COLUMN "LISTA_DOCUMENTO"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   COMMENT ON TABLE "LISTA_DOCUMENTO"  IS 'Lista Documento - Tabla donde se almacena la lista de documentos que se ingresa en el reporte de siniestros.';
--------------------------------------------------------
--  DDL for Table LOG_ERROR
--------------------------------------------------------

  CREATE TABLE "LOG_ERROR" 
   (	"ID_LOG" NUMBER(10,0), 
	"ENTIDAD" VARCHAR2(30 BYTE), 
	"FECHA_REGISTRO" DATE DEFAULT SYSDATE, 
	"OBSERVACION" VARCHAR2(2000 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Table LOG_SERVICIO_SIMI
--------------------------------------------------------

  CREATE TABLE "LOG_SERVICIO_SIMI" 
   (	"COD_LOG_SERV" NUMBER(5,0), 
	"FECHA_REGISTRO" DATE DEFAULT SYSDATE, 
	"REQUEST" VARCHAR2(400 BYTE), 
	"RESPONSE" VARCHAR2(400 BYTE), 
	"ESTADO" NUMBER(20,0)
   ) ;

   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."COD_LOG_SERV" IS 'codigo log servicio SIMI - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."FECHA_REGISTRO" IS 'Fecha del sistema de cuando se hizo el registro';
   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."REQUEST" IS 'Campo donde se almacena la peticion generada al servicio de SIMI.';
   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."RESPONSE" IS 'Campo donde se almacena lar respuesta generada por el servicio de SIMI.';
   COMMENT ON COLUMN "LOG_SERVICIO_SIMI"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de registro.';
   COMMENT ON TABLE "LOG_SERVICIO_SIMI"  IS 'Tabla donde se almacena la informacion que procesa el servicio web de SIMI.';
--------------------------------------------------------
--  DDL for Table MES_REGISTRADO
--------------------------------------------------------

  CREATE TABLE "MES_REGISTRADO" 
   (	"MES" DATE, 
	"CAN_ASEG" NUMBER(20,2), 
	"RECU_CAN" NUMBER(20,2), 
	"TOT_CAN" NUMBER(20,2), 
	"ADM_ASEG" NUMBER(20,2), 
	"RECU_ADMI" NUMBER(20,2), 
	"TOT_ADMI" NUMBER(20,2), 
	"TOTAL_MES" NUMBER(20,2), 
	"SINIESTRO_FEC_REP" DATE DEFAULT SYSDATE, 
	"SINI_SOL_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "MES_REGISTRADO"."MES" IS 'Mes que se va a reportar.';
   COMMENT ON COLUMN "MES_REGISTRADO"."CAN_ASEG" IS 'canon asegurado - Valor de canon asegurado para el mes que se va a reportar.';
   COMMENT ON COLUMN "MES_REGISTRADO"."RECU_CAN" IS 'recuperacion canon - Valor de recuperacion para le canon de arrendamiento para el mes reportado.';
   COMMENT ON COLUMN "MES_REGISTRADO"."TOT_CAN" IS 'total canon - Valor total de la suma de canon de arredamiento asegurado mas el valor de la recuperacion por mes.';
   COMMENT ON COLUMN "MES_REGISTRADO"."ADM_ASEG" IS 'administracion asegurado - Valor de la cuota de administracion asegurada para el mes que se va a reportar.';
   COMMENT ON COLUMN "MES_REGISTRADO"."RECU_ADMI" IS 'recuperacion administracion - Valor de recuperacion para la cuota de administracion  para el mes reportado.';
   COMMENT ON COLUMN "MES_REGISTRADO"."TOT_ADMI" IS 'total administracion - Valor total de la suma de la cuota de administracion asegurado mas el valor de la recuperacion por mes.';
   COMMENT ON COLUMN "MES_REGISTRADO"."TOTAL_MES" IS 'Valor total por mes reportado, que es compuesto por la suma del total canon y el total administracion.';
   COMMENT ON COLUMN "MES_REGISTRADO"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   COMMENT ON TABLE "MES_REGISTRADO"  IS 'MES REGISTRADO - Tabla donde se almacenan los meses que se van a reportar,segun la fecha de mora ingresada.';
--------------------------------------------------------
--  DDL for Table MODULO
--------------------------------------------------------

  CREATE TABLE "MODULO" 
   (	"COD_MOD" NUMBER(5,0), 
	"NOMBRE" VARCHAR2(200 BYTE)
   ) ;

   COMMENT ON COLUMN "MODULO"."COD_MOD" IS 'codigo modulo - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "MODULO"."NOMBRE" IS 'aCampo donde se almacena el nombre del modulo.';
   COMMENT ON TABLE "MODULO"  IS 'Tabla donde se almacenan las opciones/modulos que tendra la aplicacion';
--------------------------------------------------------
--  DDL for Table MODULO_PERFIL
--------------------------------------------------------

  CREATE TABLE "MODULO_PERFIL" 
   (	"MODULO_COD_MOD" NUMBER(5,0), 
	"PERFIL_COD_PERF" NUMBER(5,0)
   ) ;

   COMMENT ON TABLE "MODULO_PERFIL"  IS 'MODULO PERFIL - Tabla donde se asignan los modulos que va a tener un perfil determinado.';
--------------------------------------------------------
--  DDL for Table NOTIFICACION
--------------------------------------------------------

  CREATE TABLE "NOTIFICACION" 
   (	"SOLICITUD" NUMBER(10,0), 
	"FEC_NOTI" DATE
   ) ;

   COMMENT ON COLUMN "NOTIFICACION"."SOLICITUD" IS 'Numero de solicitud que a la que se le esta haciendo la novedad.';
   COMMENT ON COLUMN "NOTIFICACION"."FEC_NOTI" IS 'fecha notificacion - Fecha del sistema de cuando se esta generando la notificacion.';
   COMMENT ON TABLE "NOTIFICACION"  IS 'Tabla donde se registran las solicitudes de notificaciones que se requieren por parte de la inmobiliaria.';
--------------------------------------------------------
--  DDL for Table NOTIFICACION_CORREO
--------------------------------------------------------

  CREATE TABLE "NOTIFICACION_CORREO" 
   (	"COD_NOTI_CORR" NUMBER(15,0), 
	"DESTINATARIO" VARCHAR2(200 BYTE), 
	"ASUNTO" VARCHAR2(200 BYTE), 
	"CUERPO" VARCHAR2(400 BYTE)
   ) ;

   COMMENT ON COLUMN "NOTIFICACION_CORREO"."COD_NOTI_CORR" IS 'codigo notificacion correo';
   COMMENT ON TABLE "NOTIFICACION_CORREO"  IS 'NOTIFICACION CORREO - Tabla donde se guardaran la informacion correspondiente al envio de correos electronicos.';
--------------------------------------------------------
--  DDL for Table PARAMETRO
--------------------------------------------------------

  CREATE TABLE "PARAMETRO" 
   (	"COD_PARA" NUMBER(15,0), 
	"DESCRIPCION" VARCHAR2(200 BYTE), 
	"VALOR" NVARCHAR2(200), 
	"ESTADO" VARCHAR2(20 BYTE)
   ) ;

   COMMENT ON COLUMN "PARAMETRO"."COD_PARA" IS 'codigo parametro';
   COMMENT ON TABLE "PARAMETRO"  IS 'Tabla encargada de guardar los parametros que se van a usar en el sistema.';
--------------------------------------------------------
--  DDL for Table PERFIL
--------------------------------------------------------

  CREATE TABLE "PERFIL" 
   (	"COD_PERF" NUMBER(15,0), 
	"NOMBRE" VARCHAR2(200 BYTE)
   ) ;

   COMMENT ON COLUMN "PERFIL"."COD_PERF" IS 'codigo perfil - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "PERFIL"."NOMBRE" IS 'Campor donde se guarda el nombre del perfil.';
   COMMENT ON TABLE "PERFIL"  IS 'Tabla donde se registran los perfiles que se van a manejar en la aplicacion.';
--------------------------------------------------------
--  DDL for Table REGISTRO_AMPARO_INTEGRAL
--------------------------------------------------------

  CREATE TABLE "REGISTRO_AMPARO_INTEGRAL" 
   (	"FEC_REP" DATE, 
	"TIPO_POLI" VARCHAR2(200 BYTE), 
	"FECHA_MORA" DATE, 
	"TOT_RECL" NUMBER(20,2), 
	"EST_SINI" NUMBER(20,0), 
	"EST_PAGO" NUMBER(20,0), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "REGISTRO_AMPARO_INTEGRAL"."FEC_REP" IS 'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';
   COMMENT ON COLUMN "REGISTRO_AMPARO_INTEGRAL"."TIPO_POLI" IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrando la desocupacion,colectiva/individual';
   COMMENT ON COLUMN "REGISTRO_AMPARO_INTEGRAL"."FECHA_MORA" IS 'fec mora - Campo donde se registra la fecha de mora que se va a ingresar.';
   COMMENT ON COLUMN "REGISTRO_AMPARO_INTEGRAL"."TOT_RECL" IS 'total reclamar - Campo donde se registra el valor total que se va a reclamar.';
   COMMENT ON COLUMN "REGISTRO_AMPARO_INTEGRAL"."EST_SINI" IS 'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';
   COMMENT ON COLUMN "REGISTRO_AMPARO_INTEGRAL"."EST_PAGO" IS 'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro';
   COMMENT ON TABLE "REGISTRO_AMPARO_INTEGRAL"  IS 'REGI AMPA INTE - Tabla donde se registra los reportes de amparo integral.';
--------------------------------------------------------
--  DDL for Table REGISTRO_DANIO_FALTANTE
--------------------------------------------------------

  CREATE TABLE "REGISTRO_DANIO_FALTANTE" 
   (	"FEC_REP" DATE, 
	"FEC_MOR" DATE, 
	"VAL_ASEG" NUMBER(20,2), 
	"VAL_RECL" NUMBER(20,2), 
	"TIP_POL" VARCHAR2(200 BYTE), 
	"PERIODO" VARCHAR2(10 BYTE), 
	"ESTA_SINI" NUMBER(20,0), 
	"EST_PAG" NUMBER, 
	"OBSERVACION" VARCHAR2(200 BYTE), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."FEC_REP" IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."FEC_MOR" IS 'fecha mora - Campo donde se registra la fecha de mora de el reporte de danios y faltantes.';
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."VAL_ASEG" IS 'val aseg - valor del amparo hogar asegurado';
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."VAL_RECL" IS 'valor reclamar - Campo donde se almacena el valor que va a ser reclamado.';
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."TIP_POL" IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrand,colectiva/individual';
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."PERIODO" IS 'Indica el periodo efectivo calculado en SAI.';
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."ESTA_SINI" IS 'Tabla Dominio - estado siniestro - Campo que indica el estado del siniestro.';
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."EST_PAG" IS 'Tabla Dominio - estado pago - Campo que indica el estado del pago del siniestro.';
   COMMENT ON COLUMN "REGISTRO_DANIO_FALTANTE"."OBSERVACION" IS 'Campo donde se guarda la observacion de registro si se tiene.';
   COMMENT ON TABLE "REGISTRO_DANIO_FALTANTE"  IS 'Tabla donde se registran el reporte de daños y faltantes.';
--------------------------------------------------------
--  DDL for Table RETIRO
--------------------------------------------------------

  CREATE TABLE "RETIRO" 
   (	"FECHA_RETIRO" DATE, 
	"PERIODO" DATE, 
	"ESTADO" NUMBER(20,0), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "RETIRO"."FECHA_RETIRO" IS 'fecha retiro - fecha el cual se hizo el retiro.';
   COMMENT ON COLUMN "RETIRO"."PERIODO" IS 'Indica el periodo calculado en SAI en al cual se hace el retiro.';
   COMMENT ON COLUMN "RETIRO"."ESTADO" IS 'Tabla Dominio - Campo que por medio de un dominio indica el estado de la solicitud.';
   COMMENT ON TABLE "RETIRO"  IS 'Tabla donde se registraran los retiros del seguro a uno solicitud.';
--------------------------------------------------------
--  DDL for Table SERVICIO_PUBLICO
--------------------------------------------------------

  CREATE TABLE "SERVICIO_PUBLICO" 
   (	"COD_SERV_PUB" NUMBER(15,0), 
	"COD_SERV" NUMBER(5,0), 
	"NOMBRE" VARCHAR2(200 BYTE), 
	"VAL_RECL" NUMBER(20,2), 
	"FEC_INI" DATE, 
	"FEC_FIN" DATE, 
	"REG_AMP_INTE_FEC_REP" DATE DEFAULT SYSDATE, 
	"REG_AMP_INT_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "SERVICIO_PUBLICO"."COD_SERV_PUB" IS 'codigo servicio publico - Codigo autoincremental de la tabla';
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."COD_SERV" IS 'codigo servicio - Campo donde se almacena el codigo del servicio publico que esta registrado en SAI.';
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."NOMBRE" IS 'Campo donde se registra el nombre del servicio publico.';
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."VAL_RECL" IS 'valor reclamar - Campo donde se almacena el valor que se va a reclamar por cada servicio publico.';
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."FEC_INI" IS 'fecha inicial - Campo donde se registra el iinicio del periodo de facturacion de los servicios publicos.';
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."FEC_FIN" IS 'fecha final - Campo donde se registra el fin del periodo de facturacion de los servicios publicos.';
   COMMENT ON COLUMN "SERVICIO_PUBLICO"."REG_AMP_INTE_FEC_REP" IS 'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';
   COMMENT ON TABLE "SERVICIO_PUBLICO"  IS 'SERVICIO PUBLICO - Tabla donde se almacenan los valores ingresados de los servicios publicos,en el reporte del amparo integral.';
--------------------------------------------------------
--  DDL for Table SINIESTRO
--------------------------------------------------------

  CREATE TABLE "SINIESTRO" 
   (	"FEC_REP" DATE, 
	"COD_SINI_SAI" NUMBER(10,0), 
	"FEC_MORA" DATE, 
	"FEC_INI_CONT" DATE, 
	"FEC_FIN_CONT" DATE, 
	"PERIODO" VARCHAR2(10 BYTE), 
	"TIP_POL" VARCHAR2(200 BYTE), 
	"TIPO_REP_SINI" VARCHAR2(30 BYTE), 
	"CUOT_ADM" CHAR(1 BYTE), 
	"EST_PAGO" NUMBER(20,0), 
	"EST_SINI" NUMBER(20,0), 
	"CANO_ARRE_REPO" NUMBER(20,2), 
	"VAL_ADMI_REPO" NUMBER(20,2), 
	"OBSERVACION" VARCHAR2(400 BYTE), 
	"SOLICITUD_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "SINIESTRO"."FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   COMMENT ON COLUMN "SINIESTRO"."COD_SINI_SAI" IS 'codigo siniestro SAI - Campo donde se almancena el numero del reporte de siniestro generado en SAI.';
   COMMENT ON COLUMN "SINIESTRO"."FEC_MORA" IS 'fecha mora - Fehca de mora que se esta reportando en el siniestro';
   COMMENT ON COLUMN "SINIESTRO"."FEC_INI_CONT" IS 'fecha inicio contrato - Fecha de inicio de cuando se inicia el contrato';
   COMMENT ON COLUMN "SINIESTRO"."FEC_FIN_CONT" IS 'fecha fin contrato - Fecha de fin de cuando se inicia el contrato';
   COMMENT ON COLUMN "SINIESTRO"."PERIODO" IS 'Indica el periodo efectivo calculado en SAI.';
   COMMENT ON COLUMN "SINIESTRO"."TIP_POL" IS 'tipo poliza - Dominio que identifica el tipo de poliza que esta registrando la desocupacion,colectiva/individual';
   COMMENT ON COLUMN "SINIESTRO"."TIPO_REP_SINI" IS 'tipo reporte siniestro - Dominio donde se indica el tipo de reporte de siniestro (Personalizado,Masivo)';
   COMMENT ON COLUMN "SINIESTRO"."CUOT_ADM" IS 'cuota administracion - campo que indica si se va a reportar o no la cuota de administracion.';
   COMMENT ON COLUMN "SINIESTRO"."EST_PAGO" IS 'Tabla dominio que indica el estado del pago del siniestro.';
   COMMENT ON COLUMN "SINIESTRO"."EST_SINI" IS 'Tabla dominio que indica el estado del siniestro';
   COMMENT ON COLUMN "SINIESTRO"."CANO_ARRE_REPO" IS 'canon arrendamiento reportado - Valor usado para el reporte individual.';
   COMMENT ON COLUMN "SINIESTRO"."VAL_ADMI_REPO" IS 'valor administracion reportado - Valor usado para el reporte individual';
   COMMENT ON TABLE "SINIESTRO"  IS 'Tabla donde se registran el reporte de siniestros personalizado y masivo segun sea el caso.';
--------------------------------------------------------
--  DDL for Table SINIESTRO_PENDIENTE
--------------------------------------------------------

  CREATE TABLE "SINIESTRO_PENDIENTE" 
   (	"TIP_OBS" NUMBER(20,0), 
	"FEC_PEND" DATE DEFAULT SYSDATE, 
	"SINIESTRO_FEC_REP" DATE DEFAULT SYSDATE, 
	"SINIESTRO_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "SINIESTRO_PENDIENTE"."TIP_OBS" IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   COMMENT ON COLUMN "SINIESTRO_PENDIENTE"."FEC_PEND" IS 'fecha pendiente -  Fecha del sistema en la que el registro quedo en pendiente.';
   COMMENT ON COLUMN "SINIESTRO_PENDIENTE"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   COMMENT ON TABLE "SINIESTRO_PENDIENTE"  IS 'SINIESTRO PENDIENTE - Tabla donde se almacenan los siniestros pendients,los que no cumplieron con las reglas de negocio definidas,y quedan pendietes a ser verificadas.';
--------------------------------------------------------
--  DDL for Table SOLICITUD_SAI
--------------------------------------------------------

  CREATE TABLE "SOLICITUD_SAI" 
   (	"SOLICITUD" NUMBER(22,0), 
	"INQUILINO" VARCHAR2(100 BYTE), 
	"DESTINACION" VARCHAR2(100 BYTE), 
	"TIPO_INMU" VARCHAR2(100 BYTE), 
	"POLIZA" NUMBER(22,0), 
	"DIRECCION" VARCHAR2(100 BYTE), 
	"CIUDAD" VARCHAR2(100 BYTE), 
	"CANON" NUMBER(20,2), 
	"ADMINISTRACION" NUMBER(20,2), 
	"CANO_ASEG" NUMBER(20,2), 
	"ADMI_ASEG" NUMBER(20,2), 
	"AMP_HOG_ASEG" NUMBER(20,2), 
	"AMP_INT_ASEG" NUMBER(20,2), 
	"NUEV_VAL_ASEG" NUMBER(20,2), 
	"FEC_NOVE" DATE, 
	"EST_SOLI" VARCHAR2(2 BYTE), 
	"EST_SINI" VARCHAR2(2 BYTE), 
	"EST_PAGO" VARCHAR2(2 BYTE), 
	"FEC_MORA" DATE, 
	"FEC_INGR" DATE, 
	"FEC_ESTU" DATE, 
	"FEC_DESO" DATE, 
	"FEC_RETI" DATE, 
	"FEC_INI_CONT" DATE, 
	"TIP_IDENTIFICA" VARCHAR2(2 BYTE), 
	"NUM_IDENTIFICA" NUMBER(12,0)
   ) ;

   COMMENT ON COLUMN "SOLICITUD_SAI"."SOLICITUD" IS 'Numero de la solicitud de SAI';
   COMMENT ON COLUMN "SOLICITUD_SAI"."DESTINACION" IS 'Comercial-Vivienda';
   COMMENT ON COLUMN "SOLICITUD_SAI"."TIPO_INMU" IS 'Apartamento-Local-Casa-Oficina';
   COMMENT ON COLUMN "SOLICITUD_SAI"."CANON" IS 'Validar';
   COMMENT ON TABLE "SOLICITUD_SAI"  IS 'Datos Basicos Sai Conexion - Tabla usada para consultar los datos basicos de SAI,cuan SAI este caido,esta tabla se ira actualizando a medida que se consulte la informacion en SAI.
Actualiza constantemente la tabla con los datos de consulta de SAI,solo se usaria para consultas';
--------------------------------------------------------
--  DDL for Table TRANSACCION
--------------------------------------------------------

  CREATE TABLE "TRANSACCION" 
   (	"COD_TRAN" NUMBER(15,0), 
	"USUARIO" NUMBER(20,0), 
	"IDENTIFICACION" NUMBER(20,0), 
	"FEC_TRAN" DATE DEFAULT SYSDATE, 
	"EQUIPO" VARCHAR2(300 BYTE), 
	"ESTADO" NUMBER(20,0), 
	"LOG_SERV_SIMI_COD_LOG_SERV" NUMBER(5,0), 
	"DESOCUPACION_FEC_REGI" DATE DEFAULT SYSDATE, 
	"DESO_SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"DESISTIMIENTO_FEC_REG" DATE DEFAULT SYSDATE, 
	"DESIS_SOL_SAI_SOLICITUD" NUMBER(10,0), 
	"REG_DANIO_FALT_FEC_REP" DATE DEFAULT SYSDATE, 
	"REG_DAN_FAL_SOL_SAI_SOLICITUD" NUMBER(10,0), 
	"REG_AMPARO_INTEGRAL_FEC_REP" DATE DEFAULT SYSDATE, 
	"REG_AMP_INTE_SOL_SAI_SOLICITUD" NUMBER(10,0), 
	"AUMENTO_FEC_AUMENTO" DATE DEFAULT SYSDATE, 
	"AUM_SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"INGRESO_FEC_REGISTRO_ING" DATE DEFAULT SYSDATE, 
	"ING_SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"RETIRO_FECHA_RETIRO" DATE DEFAULT SYSDATE, 
	"RETI_SOLICITUD_SAI_SOLICITUD" NUMBER(10,0), 
	"SINIESTRO_FEC_REP" DATE DEFAULT SYSDATE, 
	"SINIESTRO_SOL_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "TRANSACCION"."COD_TRAN" IS 'codigo transaccion - Codigo autoincremental de la tabla';
   COMMENT ON COLUMN "TRANSACCION"."USUARIO" IS 'LLave o codigo del usuario que realizó la transacción.';
   COMMENT ON COLUMN "TRANSACCION"."IDENTIFICACION" IS 'Campo establecido para las polizas individuales';
   COMMENT ON COLUMN "TRANSACCION"."FEC_TRAN" IS 'fecha transaccion - Campo que indica la fecha del sistema en la que se realizo la transaccion.';
   COMMENT ON COLUMN "TRANSACCION"."EQUIPO" IS 'Atributo donde se almacena el equipo/ip del usuario que esta haciendo uso de la aplicacion.';
   COMMENT ON COLUMN "TRANSACCION"."ESTADO" IS 'Campo que por medio de un dominio indica el estado de registro.';
   COMMENT ON COLUMN "TRANSACCION"."LOG_SERV_SIMI_COD_LOG_SERV" IS 'Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "TRANSACCION"."DESOCUPACION_FEC_REGI" IS 'fecha registro - Fecha del sistema de cuando se esta realizando la desocupacion.';
   COMMENT ON COLUMN "TRANSACCION"."DESISTIMIENTO_FEC_REG" IS 'fecha registro - fecha del sistema en el que se esta haciendo el desistimiento.';
   COMMENT ON COLUMN "TRANSACCION"."REG_DANIO_FALT_FEC_REP" IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   COMMENT ON COLUMN "TRANSACCION"."REG_AMPARO_INTEGRAL_FEC_REP" IS 'fec rep - campo donde se guarda la fecha del sistema de cuando se esta realizando el reporte de la novedad.';
   COMMENT ON COLUMN "TRANSACCION"."AUMENTO_FEC_AUMENTO" IS 'fecha aumento - Fecha en la cual se esta realizando el aumento.';
   COMMENT ON COLUMN "TRANSACCION"."INGRESO_FEC_REGISTRO_ING" IS 'Fecha del sistema donde de cuado se esta realizando el registro.';
   COMMENT ON COLUMN "TRANSACCION"."RETIRO_FECHA_RETIRO" IS 'fecha retiro - fecha el cual se hizo el retiro.';
   COMMENT ON COLUMN "TRANSACCION"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   COMMENT ON TABLE "TRANSACCION"  IS 'Tabla donde se van a almacenar las transacciones que se realizen sobre el sistema.';
--------------------------------------------------------
--  DDL for Table USUARIO_PERFIL
--------------------------------------------------------

  CREATE TABLE "USUARIO_PERFIL" 
   (	"COD_USU" NUMBER(5,0), 
	"PERFIL_COD_PERF" NUMBER(5,0)
   ) ;

   COMMENT ON COLUMN "USUARIO_PERFIL"."COD_USU" IS 'codigo usuario - Campo donde se alamcena el codigo del usuario que se le va asignar el perfil.';
   COMMENT ON TABLE "USUARIO_PERFIL"  IS 'USUARIO PERFIL - Tabla donde se asignaran los perfiles por usuario de la  aplicacion.';
--------------------------------------------------------
--  DDL for Table VAL_DOMINIO
--------------------------------------------------------

  CREATE TABLE "VAL_DOMINIO" 
   (	"COD_VAL_DOMINIO" NUMBER(15,0), 
	"VALOR" VARCHAR2(400 BYTE), 
	"ESTADO" VARCHAR2(20 BYTE), 
	"DOMINIO_COD_DOMINIO" NUMBER(15,0)
   ) ;

   COMMENT ON COLUMN "VAL_DOMINIO"."COD_VAL_DOMINIO" IS 'Codigo Autoincremental de la tabla.';
   COMMENT ON COLUMN "VAL_DOMINIO"."VALOR" IS 'Posible valor que puede tomar el dominio.';
   COMMENT ON COLUMN "VAL_DOMINIO"."ESTADO" IS 'Dominio que indica el estado del dominio,si este esta activo o esta inactivo.';
   COMMENT ON COLUMN "VAL_DOMINIO"."DOMINIO_COD_DOMINIO" IS 'Codigo autoincremental de la tabla';
   COMMENT ON TABLE "VAL_DOMINIO"  IS 'Tabla donde se almacenaran los posibles valores que puede tomar un dominio.';
--------------------------------------------------------
--  DDL for Table VALOR_REPORTADO
--------------------------------------------------------

  CREATE TABLE "VALOR_REPORTADO" 
   (	"COD_VAL_REPOR" NUMBER(15,0), 
	"TIP_CON" NUMBER(20,0), 
	"PER_INI" DATE, 
	"PER_FIN" DATE, 
	"VAL_REPO" NUMBER(20,2), 
	"SINIESTRO_FEC_REP" DATE, 
	"SINI_SOL_SAI_SOLICITUD" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "VALOR_REPORTADO"."COD_VAL_REPOR" IS 'codigo valor reportado - Codigo autoincremental de la tabla.';
   COMMENT ON COLUMN "VALOR_REPORTADO"."TIP_CON" IS 'tipo concepto - Dominio que indica el tipo de concepto del pago: REM01,RM,01,02';
   COMMENT ON COLUMN "VALOR_REPORTADO"."PER_INI" IS 'periodo inicio - Fecha de inicio del valor reportado del siniestro.';
   COMMENT ON COLUMN "VALOR_REPORTADO"."PER_FIN" IS 'periodo fin - Fecha fin del valor reportado del siniestro.';
   COMMENT ON COLUMN "VALOR_REPORTADO"."VAL_REPO" IS 'valor reportado';
   COMMENT ON COLUMN "VALOR_REPORTADO"."SINIESTRO_FEC_REP" IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   COMMENT ON TABLE "VALOR_REPORTADO"  IS 'VALOR REPORTADO - Tabla donde se ingresan los valores que se van a reportar en SAI (valores de desfase,valores de reporte de siniestro,Valores por Recueracion).';
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV8
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV8" ON "TRANSACCION" ("INGRESO_FEC_REGISTRO_ING", "ING_SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index USUARIO_PERFIL_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "USUARIO_PERFIL_PK" ON "USUARIO_PERFIL" ("PERFIL_COD_PERF") 
  ;
--------------------------------------------------------
--  DDL for Index DOCUMENTO_SOPORTE__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "DOCUMENTO_SOPORTE__IDX" ON "DOCUMENTO_SOPORTE" ("COD_DOC_SOP") 
  ;
--------------------------------------------------------
--  DDL for Index AUTORIZACION_OPERACION_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTORIZACION_OPERACION_PK" ON "AUTORIZACION_OPERACION" ("COD_AUTO_OPER") 
  ;
--------------------------------------------------------
--  DDL for Index REGISTRO_AMPARO_INTEGRAL__IDX
--------------------------------------------------------

  CREATE INDEX "REGISTRO_AMPARO_INTEGRAL__IDX" ON "REGISTRO_AMPARO_INTEGRAL" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index PARAMETRO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "PARAMETRO__IDX" ON "PARAMETRO" ("COD_PARA") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV9
--------------------------------------------------------

  CREATE INDEX "TRANSACCION__IDXV9" ON "TRANSACCION" ("COD_TRAN") 
  ;
--------------------------------------------------------
--  DDL for Index DESOCUPACION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "DESOCUPACION__IDX" ON "DESOCUPACION" ("FEC_REGI", "SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index ALERTA__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "ALERTA__IDX" ON "ALERTA" ("COD_ALE", "ESTADO") 
  ;
--------------------------------------------------------
--  DDL for Index DANIO_FALTANTE_PENDIENTE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "DANIO_FALTANTE_PENDIENTE_PK" ON "DANIO_FALTANTE_PENDIENTE" ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD", "TIPO_OBS") 
  ;
--------------------------------------------------------
--  DDL for Index ALERTA_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "ALERTA_PK" ON "ALERTA" ("COD_ALE") 
  ;
--------------------------------------------------------
--  DDL for Index VALOR_REPORTADO__IDX
--------------------------------------------------------

  CREATE INDEX "VALOR_REPORTADO__IDX" ON "VALOR_REPORTADO" ("COD_VAL_REPOR") 
  ;
--------------------------------------------------------
--  DDL for Index DOCUMENTO_NOTIFICACION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "DOCUMENTO_NOTIFICACION__IDX" ON "DOCUMENTO_NOTIFICACION" ("COD_DOC_NOTIFICACION", "ESTADO") 
  ;
--------------------------------------------------------
--  DDL for Index AUMENTO_PENDIENTE__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUMENTO_PENDIENTE__IDX" ON "AUMENTO_PENDIENTE" ("TIPO_OBS_AUM", "ESTADO") 
  ;
--------------------------------------------------------
--  DDL for Index MODULO_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "MODULO_PK" ON "MODULO" ("COD_MOD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV3
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV3" ON "TRANSACCION" ("SINIESTRO_FEC_REP", "SINIESTRO_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV2
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV2" ON "TRANSACCION" ("AUMENTO_FEC_AUMENTO", "AUM_SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index AUMENTO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUMENTO__IDX" ON "AUMENTO" ("FEC_AUMENTO", "SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index RETIRO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "RETIRO__IDX" ON "RETIRO" ("FECHA_RETIRO", "SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index VAL_DOMINIO__IDX
--------------------------------------------------------

  CREATE INDEX "VAL_DOMINIO__IDX" ON "VAL_DOMINIO" ("COD_VAL_DOMINIO") 
  ;
--------------------------------------------------------
--  DDL for Index AUMENTO_PENDIENTE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUMENTO_PENDIENTE_PK" ON "AUMENTO_PENDIENTE" ("AUMENTO_FEC_AUMENTO", "AUMENTO_SOLICITUD", "TIPO_OBS_AUM") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV1" ON "TRANSACCION" ("RETIRO_FECHA_RETIRO", "RETI_SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index DESOCUPACION_PENDIENTE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "DESOCUPACION_PENDIENTE_PK" ON "DESOCUPACION_PENDIENTE" ("TIPO_OBS", "DESOCUPACION_FEC_REGI", "DESOCUPACION_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index DOMINIO_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "DOMINIO_PK" ON "DOMINIO" ("COD_DOMINIO") 
  ;
--------------------------------------------------------
--  DDL for Index SINIESTRO_PENDIENTE__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "SINIESTRO_PENDIENTE__IDX" ON "SINIESTRO_PENDIENTE" ("TIP_OBS") 
  ;
--------------------------------------------------------
--  DDL for Index MES_REGISTRADO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "MES_REGISTRADO__IDX" ON "MES_REGISTRADO" ("MES", "SINIESTRO_FEC_REP", "SINI_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index INGRESO_PENDIENTE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "INGRESO_PENDIENTE_PK" ON "INGRESO_PENDIENTE" ("INGRESO_FEC_REGISTRO_ING", "INGRESO_SOLICITUD", "TIPO_OBS_ING") 
  ;
--------------------------------------------------------
--  DDL for Index DOMINIO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "DOMINIO__IDX" ON "DOMINIO" ("COD_DOMINIO", "ESTADO") 
  ;
--------------------------------------------------------
--  DDL for Index INGRESO_PENDIENTE__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "INGRESO_PENDIENTE__IDXV1" ON "INGRESO_PENDIENTE" ("INGRESO_FEC_REGISTRO_ING", "INGRESO_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index NOTIFICACION_CORREO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "NOTIFICACION_CORREO__IDX" ON "NOTIFICACION_CORREO" ("COD_NOTI_CORR") 
  ;
--------------------------------------------------------
--  DDL for Index INGRESO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "INGRESO__IDX" ON "INGRESO" ("FEC_REGISTRO_ING", "SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index DAN_FALT_PEND__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "DAN_FALT_PEND__IDX" ON "DANIO_FALTANTE_PENDIENTE" ("TIPO_OBS", "ESTADO") 
  ;
--------------------------------------------------------
--  DDL for Index AUTO_DESOCUPACIOON__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTO_DESOCUPACIOON__IDX" ON "AUTORIZACION_DESOCUPACIOON" ("DESO_PEND_TIPO_OBS", "DESO_PEND_DESOC_FEC_REGI", "DESO_PEND_DESOC_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index NOTIFICACION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "NOTIFICACION__IDX" ON "NOTIFICACION" ("SOLICITUD", "FEC_NOTI") 
  ;
--------------------------------------------------------
--  DDL for Index SOLICITUD_SAI__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "SOLICITUD_SAI__IDX" ON "SOLICITUD_SAI" ("SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index AUTO_INDEMNIZACION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTO_INDEMNIZACION__IDX" ON "AUTORIZACION_INDEMNIZACION" ("DAN_FALT_PEND_FEC_REP", "DAN_FALT_PEND_SOLICITUD", "DAN_FALT_PEND_TIPO_OBS") 
  ;
--------------------------------------------------------
--  DDL for Index SINIESTRO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "SINIESTRO__IDX" ON "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index DAN_FALT_PEND__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "DAN_FALT_PEND__IDXV1" ON "DANIO_FALTANTE_PENDIENTE" ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV4
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV4" ON "TRANSACCION" ("REG_AMPARO_INTEGRAL_FEC_REP", "REG_AMP_INTE_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index SINIESTRO_PENDIENTE__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "SINIESTRO_PENDIENTE__IDXV1" ON "SINIESTRO_PENDIENTE" ("SINIESTRO_FEC_REP", "SINIESTRO_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index AUTO_INDEMNIZACION__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTO_INDEMNIZACION__IDXV1" ON "AUTORIZACION_INDEMNIZACION" ("SINI_PEND_SINIE_FEC_REP", "SINI_PEND_SINIE_SOLICITUD", "SINI_PEND_TIP_OBS") 
  ;
--------------------------------------------------------
--  DDL for Index PERFIL__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "PERFIL__IDX" ON "PERFIL" ("COD_PERF") 
  ;
--------------------------------------------------------
--  DDL for Index MODULO_PERFIL_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "MODULO_PERFIL_PK" ON "MODULO_PERFIL" ("MODULO_COD_MOD", "PERFIL_COD_PERF") 
  ;
--------------------------------------------------------
--  DDL for Index REGISTRO_DANIO_FALTANTE__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "REGISTRO_DANIO_FALTANTE__IDX" ON "REGISTRO_DANIO_FALTANTE" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index LOG_SERVICIO_SIMI__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "LOG_SERVICIO_SIMI__IDX" ON "LOG_SERVICIO_SIMI" ("COD_LOG_SERV") 
  ;
--------------------------------------------------------
--  DDL for Index AUMENTO_PENDIENTE__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUMENTO_PENDIENTE__IDXV1" ON "AUMENTO_PENDIENTE" ("AUMENTO_FEC_AUMENTO", "AUMENTO_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index AUTORIZACION_OPERACION__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTORIZACION_OPERACION__IDXV1" ON "AUTORIZACION_OPERACION" ("ING_PEND_INGR_FEC_REGISTRO_ING", "ING_PEND_INGR_SOLICITUD", "ING_PEND_TIPO_OBS_ING") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDX" ON "TRANSACCION" ("LOG_SERV_SIMI_COD_LOG_SERV") 
  ;
--------------------------------------------------------
--  DDL for Index DESOCUPACION_PENDIENTE__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "DESOCUPACION_PENDIENTE__IDXV1" ON "DESOCUPACION_PENDIENTE" ("DESOCUPACION_FEC_REGI", "DESOCUPACION_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index DOCUMENTO_NOTIFICACION_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "DOCUMENTO_NOTIFICACION_PK" ON "DOCUMENTO_NOTIFICACION" ("COD_DOC_NOTIFICACION") 
  ;
--------------------------------------------------------
--  DDL for Index INGRESO_PENDIENTE__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "INGRESO_PENDIENTE__IDX" ON "INGRESO_PENDIENTE" ("TIPO_OBS_ING", "ESTADO") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV5
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV5" ON "TRANSACCION" ("REG_DANIO_FALT_FEC_REP", "REG_DAN_FAL_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index LOG_ERROR_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "LOG_ERROR_PK" ON "LOG_ERROR" ("ID_LOG") 
  ;
--------------------------------------------------------
--  DDL for Index SINIESTRO_PENDIENTE_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "SINIESTRO_PENDIENTE_PK" ON "SINIESTRO_PENDIENTE" ("SINIESTRO_FEC_REP", "SINIESTRO_SOLICITUD", "TIP_OBS") 
  ;
--------------------------------------------------------
--  DDL for Index LISTA_DOCUMENTO__IDX
--------------------------------------------------------

  CREATE INDEX "LISTA_DOCUMENTO__IDX" ON "LISTA_DOCUMENTO" ("COD_LIST_DOC") 
  ;
--------------------------------------------------------
--  DDL for Index AUTORIZACION_INDEMNIZACION_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTORIZACION_INDEMNIZACION_PK" ON "AUTORIZACION_INDEMNIZACION" ("COD_AUT_IND") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV6
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV6" ON "TRANSACCION" ("DESISTIMIENTO_FEC_REG", "DESIS_SOL_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index AUTORIZACION_OPERACION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTORIZACION_OPERACION__IDX" ON "AUTORIZACION_OPERACION" ("AUM_PEND_AUM_FEC_AUMENTO", "AUM_PEND_AUME_SOLICITUD", "AUM_PEND_TIPO_OBS_AUM") 
  ;
--------------------------------------------------------
--  DDL for Index SERVICIO_PUBLICO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "SERVICIO_PUBLICO__IDX" ON "SERVICIO_PUBLICO" ("COD_SERV_PUB") 
  ;
--------------------------------------------------------
--  DDL for Index TRANSACCION__IDXV7
--------------------------------------------------------

  CREATE UNIQUE INDEX "TRANSACCION__IDXV7" ON "TRANSACCION" ("DESOCUPACION_FEC_REGI", "DESO_SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index DESISTIMIENTO__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "DESISTIMIENTO__IDX" ON "DESISTIMIENTO" ("FEC_REG", "SOLICITUD_SAI_SOLICITUD") 
  ;
--------------------------------------------------------
--  DDL for Index AUTORIZACION_DESOCUPACIOON_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTORIZACION_DESOCUPACIOON_PK" ON "AUTORIZACION_DESOCUPACIOON" ("CODIGO_AUT_DES") 
  ;
--------------------------------------------------------
--  Constraints for Table PARAMETRO
--------------------------------------------------------

  ALTER TABLE "PARAMETRO" MODIFY ("COD_PARA" NOT NULL ENABLE);
  ALTER TABLE "PARAMETRO" MODIFY ("DESCRIPCION" NOT NULL ENABLE);
  ALTER TABLE "PARAMETRO" MODIFY ("VALOR" NOT NULL ENABLE);
  ALTER TABLE "PARAMETRO" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "PARAMETRO" ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "PARAMETRO" ADD CONSTRAINT "PARAMETRO_PK" PRIMARY KEY ("COD_PARA") ENABLE;
  ALTER TABLE "PARAMETRO" ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
--------------------------------------------------------
--  Constraints for Table NOTIFICACION_CORREO
--------------------------------------------------------

  ALTER TABLE "NOTIFICACION_CORREO" ADD CONSTRAINT "NOTIFICACION_CORREO_PK" PRIMARY KEY ("COD_NOTI_CORR") ENABLE;
  ALTER TABLE "NOTIFICACION_CORREO" MODIFY ("COD_NOTI_CORR" NOT NULL ENABLE);
  ALTER TABLE "NOTIFICACION_CORREO" MODIFY ("DESTINATARIO" NOT NULL ENABLE);
  ALTER TABLE "NOTIFICACION_CORREO" MODIFY ("ASUNTO" NOT NULL ENABLE);
  ALTER TABLE "NOTIFICACION_CORREO" MODIFY ("CUERPO" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table SINIESTRO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("TIP_OBS" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("FEC_PEND" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("SINIESTRO_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" MODIFY ("SINIESTRO_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO_PENDIENTE" ADD CONSTRAINT "SINIESTRO_PENDIENTE_PK" PRIMARY KEY ("SINIESTRO_FEC_REP", "SINIESTRO_SOLICITUD", "TIP_OBS") ENABLE;
--------------------------------------------------------
--  Constraints for Table REGISTRO_AMPARO_INTEGRAL
--------------------------------------------------------

  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" MODIFY ("FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" MODIFY ("TIPO_POLI" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" MODIFY ("FECHA_MORA" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" MODIFY ("TOT_RECL" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" MODIFY ("EST_SINI" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" MODIFY ("EST_PAGO" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" ADD CHECK (
    tipo_poli IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" ADD CONSTRAINT "REGISTRO_AMPARO_INTEGRAL_PK" PRIMARY KEY ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" ADD CHECK (
    tipo_poli IN (
        '1','2'
    )
) ENABLE;
--------------------------------------------------------
--  Constraints for Table LISTA_DOCUMENTO
--------------------------------------------------------

  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("COD_LIST_DOC" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("COD_DOC" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("APLICA" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("SINIESTRO_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" MODIFY ("SINI_SOL_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "LISTA_DOCUMENTO" ADD CONSTRAINT "LISTA_DOCUMENTO_PK" PRIMARY KEY ("COD_LIST_DOC") ENABLE;
--------------------------------------------------------
--  Constraints for Table SOLICITUD_SAI
--------------------------------------------------------

  ALTER TABLE "SOLICITUD_SAI" MODIFY ("SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "SOLICITUD_SAI" ADD CONSTRAINT "SOLICITUD_SAI_PK" PRIMARY KEY ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Constraints for Table AUTORIZACION_DESOCUPACIOON
--------------------------------------------------------

  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("CODIGO_AUT_DES" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("AREA_AUTO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("FEC_AUTO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("RESPONSABLE" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("DESO_PEND_TIPO_OBS" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("DESO_PEND_DESOC_FEC_REGI" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" MODIFY ("DESO_PEND_DESOC_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" ADD CONSTRAINT "AUTORIZACION_DESOCUPACIOON_PK" PRIMARY KEY ("CODIGO_AUT_DES") ENABLE;
--------------------------------------------------------
--  Constraints for Table MODULO_PERFIL
--------------------------------------------------------

  ALTER TABLE "MODULO_PERFIL" MODIFY ("MODULO_COD_MOD" NOT NULL ENABLE);
  ALTER TABLE "MODULO_PERFIL" MODIFY ("PERFIL_COD_PERF" NOT NULL ENABLE);
  ALTER TABLE "MODULO_PERFIL" ADD CONSTRAINT "MODULO_PERFIL_PK" PRIMARY KEY ("MODULO_COD_MOD", "PERFIL_COD_PERF") ENABLE;
--------------------------------------------------------
--  Constraints for Table MES_REGISTRADO
--------------------------------------------------------

  ALTER TABLE "MES_REGISTRADO" MODIFY ("MES" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("CAN_ASEG" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("RECU_CAN" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("TOT_CAN" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("ADM_ASEG" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("RECU_ADMI" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("TOT_ADMI" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("TOTAL_MES" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("SINIESTRO_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" MODIFY ("SINI_SOL_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "MES_REGISTRADO" ADD CONSTRAINT "MES_REGISTRADO_PK" PRIMARY KEY ("MES", "SINIESTRO_FEC_REP", "SINI_SOL_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" MODIFY ("COD_TRAN" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("USUARIO" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("IDENTIFICACION" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("FEC_TRAN" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("EQUIPO" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "ARC_3" CHECK (
    (
        (
            aumento_fec_aumento IS NOT NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            ingreso_fec_registro_ing IS NOT NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            desocupacion_fec_regi IS NOT NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            desistimiento_fec_reg IS NOT NULL
        ) AND (
            desis_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            reg_danio_falt_fec_rep IS NOT NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            siniestro_fec_rep IS NOT NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            reg_amparo_integral_fec_rep IS NOT NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            log_serv_simi_cod_log_serv IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    ) OR (
        (
            retiro_fecha_retiro IS NOT NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NOT NULL
        ) AND (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        )
    ) OR (
        (
            aumento_fec_aumento IS NULL
        ) AND (
            aum_solicitud_sai_solicitud IS NULL
        ) AND (
            ingreso_fec_registro_ing IS NULL
        ) AND (
            ing_solicitud_sai_solicitud IS NULL
        ) AND (
            desocupacion_fec_regi IS NULL
        ) AND (
            deso_solicitud_sai_solicitud IS NULL
        ) AND (
            desistimiento_fec_reg IS NULL
        ) AND (
            desis_sol_sai_solicitud IS NULL
        ) AND (
            reg_danio_falt_fec_rep IS NULL
        ) AND (
            reg_dan_fal_sol_sai_solicitud IS NULL
        ) AND (
            siniestro_fec_rep IS NULL
        ) AND (
            siniestro_sol_sai_solicitud IS NULL
        ) AND (
            reg_amparo_integral_fec_rep IS NULL
        ) AND (
            reg_amp_inte_sol_sai_solicitud IS NULL
        ) AND (
            log_serv_simi_cod_log_serv IS NULL
        ) AND (
            retiro_fecha_retiro IS NULL
        ) AND (
            reti_solicitud_sai_solicitud IS NULL
        )
    )
) ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_PK" PRIMARY KEY ("COD_TRAN") ENABLE;
--------------------------------------------------------
--  Constraints for Table DOCUMENTO_SOPORTE
--------------------------------------------------------

  ALTER TABLE "DOCUMENTO_SOPORTE" ADD CONSTRAINT "DOCUMENTO_SOPORTE_PK" PRIMARY KEY ("COD_DOC_SOP") ENABLE;
  ALTER TABLE "DOCUMENTO_SOPORTE" MODIFY ("COD_DOC_SOP" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_SOPORTE" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_SOPORTE" MODIFY ("COD_REPO" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_SOPORTE" MODIFY ("RUTA_REPO" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_SOPORTE" MODIFY ("REG_DAN_FALT_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_SOPORTE" MODIFY ("REG_DAN_FALT_SOLICITUD" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table AUTORIZACION_OPERACION
--------------------------------------------------------

  ALTER TABLE "AUTORIZACION_OPERACION" MODIFY ("COD_AUTO_OPER" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_OPERACION" MODIFY ("OBSERVACION" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_OPERACION" MODIFY ("AREA_AUTO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_OPERACION" MODIFY ("FEC_AUTO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_OPERACION" MODIFY ("RESPONSABLE" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_OPERACION" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_OPERACION" ADD CONSTRAINT "ARC_1" CHECK (
    (
        (
            ing_pend_ingr_fec_registro_ing IS NOT NULL
        ) AND (
            ing_pend_ingr_solicitud IS NOT NULL
        ) AND (
            ing_pend_tipo_obs_ing IS NOT NULL
        ) AND (
            aum_pend_aum_fec_aumento IS NULL
        ) AND (
            aum_pend_aume_solicitud IS NULL
        ) AND (
            aum_pend_tipo_obs_aum IS NULL
        )
    ) OR (
        (
            aum_pend_aum_fec_aumento IS NOT NULL
        ) AND (
            aum_pend_aume_solicitud IS NOT NULL
        ) AND (
            aum_pend_tipo_obs_aum IS NOT NULL
        ) AND (
            ing_pend_ingr_fec_registro_ing IS NULL
        ) AND (
            ing_pend_ingr_solicitud IS NULL
        ) AND (
            ing_pend_tipo_obs_ing IS NULL
        )
    )
) ENABLE;
  ALTER TABLE "AUTORIZACION_OPERACION" ADD CONSTRAINT "AUTORIZACION_OPERACION_PK" PRIMARY KEY ("COD_AUTO_OPER") ENABLE;
--------------------------------------------------------
--  Constraints for Table ALERTA
--------------------------------------------------------

  ALTER TABLE "ALERTA" MODIFY ("COD_ALE" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" MODIFY ("FEC_ALE" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" MODIFY ("OBSERVACION" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" MODIFY ("TRANSACCION_COD_TRAN" NOT NULL ENABLE);
  ALTER TABLE "ALERTA" ADD CONSTRAINT "ALERTA_PK" PRIMARY KEY ("COD_ALE") ENABLE;
--------------------------------------------------------
--  Constraints for Table REGISTRO_DANIO_FALTANTE
--------------------------------------------------------

  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("FEC_MOR" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("VAL_ASEG" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("VAL_RECL" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("TIP_POL" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("ESTA_SINI" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("EST_PAG" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" ADD CHECK (
    tip_pol IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" ADD CONSTRAINT "REGISTRO_DANIO_FALTANTE_PK" PRIMARY KEY ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "REGISTRO_DANIO_FALTANTE" ADD CHECK (
    tip_pol IN (
        '1','2'
    )
) ENABLE;
--------------------------------------------------------
--  Constraints for Table DESISTIMIENTO
--------------------------------------------------------

  ALTER TABLE "DESISTIMIENTO" MODIFY ("FEC_REG" NOT NULL ENABLE);
  ALTER TABLE "DESISTIMIENTO" MODIFY ("COD_SINI" NOT NULL ENABLE);
  ALTER TABLE "DESISTIMIENTO" MODIFY ("FEC_DESI" NOT NULL ENABLE);
  ALTER TABLE "DESISTIMIENTO" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "DESISTIMIENTO" MODIFY ("TIPO_POLI" NOT NULL ENABLE);
  ALTER TABLE "DESISTIMIENTO" MODIFY ("EST_SINI" NOT NULL ENABLE);
  ALTER TABLE "DESISTIMIENTO" MODIFY ("EST_PAGO" NOT NULL ENABLE);
  ALTER TABLE "DESISTIMIENTO" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "DESISTIMIENTO" ADD CHECK (
    tipo_poli IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "DESISTIMIENTO" ADD CONSTRAINT "DESISTIMIENTO_PK" PRIMARY KEY ("FEC_REG", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "DESISTIMIENTO" ADD CHECK (
    tipo_poli IN (
        '1','2'
    )
) ENABLE;
--------------------------------------------------------
--  Constraints for Table SERVICIO_PUBLICO
--------------------------------------------------------

  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("COD_SERV_PUB" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("COD_SERV" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("VAL_RECL" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("FEC_INI" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("FEC_FIN" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("REG_AMP_INTE_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" MODIFY ("REG_AMP_INT_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "SERVICIO_PUBLICO" ADD CONSTRAINT "SERVICIO_PUBLICO_PK" PRIMARY KEY ("COD_SERV_PUB") ENABLE;
--------------------------------------------------------
--  Constraints for Table AUMENTO
--------------------------------------------------------

  ALTER TABLE "AUMENTO" MODIFY ("FEC_AUMENTO" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO" MODIFY ("CANO_ARRENDA_AUME" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO" MODIFY ("VAL_ADMIN_AUM" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO" ADD CONSTRAINT "AUMENTO_PK" PRIMARY KEY ("FEC_AUMENTO", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Constraints for Table NOTIFICACION
--------------------------------------------------------

  ALTER TABLE "NOTIFICACION" MODIFY ("SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "NOTIFICACION" MODIFY ("FEC_NOTI" NOT NULL ENABLE);
  ALTER TABLE "NOTIFICACION" ADD CONSTRAINT "NOTIFICACION_PK" PRIMARY KEY ("SOLICITUD", "FEC_NOTI") ENABLE;
--------------------------------------------------------
--  Constraints for Table LOG_ERROR
--------------------------------------------------------

  ALTER TABLE "LOG_ERROR" MODIFY ("ID_LOG" NOT NULL ENABLE);
  ALTER TABLE "LOG_ERROR" ADD CONSTRAINT "LOG_ERROR_PK" PRIMARY KEY ("ID_LOG") ENABLE;
  ALTER TABLE "LOG_ERROR" MODIFY ("FECHA_REGISTRO" NOT NULL ENABLE);
  ALTER TABLE "LOG_ERROR" MODIFY ("OBSERVACION" NOT NULL ENABLE);
--------------------------------------------------------
--  Constraints for Table INGRESO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "INGRESO_PENDIENTE" MODIFY ("TIPO_OBS_ING" NOT NULL ENABLE);
  ALTER TABLE "INGRESO_PENDIENTE" MODIFY ("FEC_PEND" NOT NULL ENABLE);
  ALTER TABLE "INGRESO_PENDIENTE" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO_PENDIENTE" MODIFY ("INGRESO_FEC_REGISTRO_ING" NOT NULL ENABLE);
  ALTER TABLE "INGRESO_PENDIENTE" MODIFY ("INGRESO_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "INGRESO_PENDIENTE" ADD CONSTRAINT "INGRESO_PENDIENTE_PK" PRIMARY KEY ("INGRESO_FEC_REGISTRO_ING", "INGRESO_SOLICITUD", "TIPO_OBS_ING") ENABLE;
--------------------------------------------------------
--  Constraints for Table VAL_DOMINIO
--------------------------------------------------------

  ALTER TABLE "VAL_DOMINIO" MODIFY ("COD_VAL_DOMINIO" NOT NULL ENABLE);
  ALTER TABLE "VAL_DOMINIO" MODIFY ("VALOR" NOT NULL ENABLE);
  ALTER TABLE "VAL_DOMINIO" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "VAL_DOMINIO" MODIFY ("DOMINIO_COD_DOMINIO" NOT NULL ENABLE);
  ALTER TABLE "VAL_DOMINIO" ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "VAL_DOMINIO" ADD CONSTRAINT "VAL_DOMINIO_PK" PRIMARY KEY ("COD_VAL_DOMINIO") ENABLE;
  ALTER TABLE "VAL_DOMINIO" ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
--------------------------------------------------------
--  Constraints for Table LOG_SERVICIO_SIMI
--------------------------------------------------------

  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("COD_LOG_SERV" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("FECHA_REGISTRO" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("REQUEST" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("RESPONSE" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "LOG_SERVICIO_SIMI" ADD CONSTRAINT "LOG_SERVICIO_SIMI_PK" PRIMARY KEY ("COD_LOG_SERV") ENABLE;
--------------------------------------------------------
--  Constraints for Table PERFIL
--------------------------------------------------------

  ALTER TABLE "PERFIL" MODIFY ("COD_PERF" NOT NULL ENABLE);
  ALTER TABLE "PERFIL" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "PERFIL" ADD CONSTRAINT "PERFIL_PK" PRIMARY KEY ("COD_PERF") ENABLE;
--------------------------------------------------------
--  Constraints for Table INGRESO
--------------------------------------------------------

  ALTER TABLE "INGRESO" MODIFY ("FEC_REGISTRO_ING" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("FEC_INGRESO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("CAN_ARRENDAMIENTO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("VAL_ADMINISTRACION" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "INGRESO" ADD CONSTRAINT "INGRESO_PK" PRIMARY KEY ("FEC_REGISTRO_ING", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Constraints for Table USUARIO_PERFIL
--------------------------------------------------------

  ALTER TABLE "USUARIO_PERFIL" MODIFY ("COD_USU" NOT NULL ENABLE);
  ALTER TABLE "USUARIO_PERFIL" MODIFY ("PERFIL_COD_PERF" NOT NULL ENABLE);
  ALTER TABLE "USUARIO_PERFIL" ADD CONSTRAINT "USUARIO_PERFIL_PK" PRIMARY KEY ("PERFIL_COD_PERF") ENABLE;
--------------------------------------------------------
--  Constraints for Table DESOCUPACION
--------------------------------------------------------

  ALTER TABLE "DESOCUPACION" MODIFY ("FEC_REGI" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" MODIFY ("FEC_DESO" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" MODIFY ("TIP_POL" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" MODIFY ("EST_SINI" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" MODIFY ("EST_PAG" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" MODIFY ("FEC_MOR" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" MODIFY ("NUM_SINI" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION" ADD CHECK (
    tip_pol IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "DESOCUPACION" ADD CONSTRAINT "DESOCUPACION_PK" PRIMARY KEY ("FEC_REGI", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "DESOCUPACION" ADD CHECK (
    tip_pol IN (
        '1','2'
    )
) ENABLE;
--------------------------------------------------------
--  Constraints for Table AUMENTO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("TIPO_OBS_AUM" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("FEC_PEND" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("AUMENTO_FEC_AUMENTO" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" MODIFY ("AUMENTO_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "AUMENTO_PENDIENTE" ADD CONSTRAINT "AUMENTO_PENDIENTE_PK" PRIMARY KEY ("AUMENTO_FEC_AUMENTO", "AUMENTO_SOLICITUD", "TIPO_OBS_AUM") ENABLE;
--------------------------------------------------------
--  Constraints for Table DOCUMENTO_NOTIFICACION
--------------------------------------------------------

  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("COD_DOC_NOTIFICACION" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("COD_DOC" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("COD_REPO" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("RUTA_REPO" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("NOTIFICACION_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" MODIFY ("NOTIFICACION_FEC_NOTI" NOT NULL ENABLE);
  ALTER TABLE "DOCUMENTO_NOTIFICACION" ADD CONSTRAINT "DOCUMENTO_NOTIFICACION_PK" PRIMARY KEY ("COD_DOC_NOTIFICACION") ENABLE;
--------------------------------------------------------
--  Constraints for Table VALOR_REPORTADO
--------------------------------------------------------

  ALTER TABLE "VALOR_REPORTADO" MODIFY ("COD_VAL_REPOR" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("TIP_CON" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("PER_INI" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("PER_FIN" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("VAL_REPO" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("SINIESTRO_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" MODIFY ("SINI_SOL_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "VALOR_REPORTADO" ADD CONSTRAINT "VALOR_REPORTADO_PK" PRIMARY KEY ("COD_VAL_REPOR") ENABLE;
--------------------------------------------------------
--  Constraints for Table RETIRO
--------------------------------------------------------

  ALTER TABLE "RETIRO" MODIFY ("FECHA_RETIRO" NOT NULL ENABLE);
  ALTER TABLE "RETIRO" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "RETIRO" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "RETIRO" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "RETIRO" ADD CONSTRAINT "RETIRO_PK" PRIMARY KEY ("FECHA_RETIRO", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Constraints for Table SINIESTRO
--------------------------------------------------------

  ALTER TABLE "SINIESTRO" MODIFY ("FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("COD_SINI_SAI" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("FEC_MORA" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("PERIODO" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("TIP_POL" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("TIPO_REP_SINI" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("CUOT_ADM" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("EST_PAGO" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("EST_SINI" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" MODIFY ("SOLICITUD_SAI_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "SINIESTRO" ADD CHECK (
    tip_pol IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "SINIESTRO" ADD CHECK (
    tipo_rep_sini IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "SINIESTRO" ADD CONSTRAINT "SINIESTRO_PK" PRIMARY KEY ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "SINIESTRO" ADD CHECK (
    tip_pol IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "SINIESTRO" ADD CHECK (
    tipo_rep_sini IN (
        '1','2'
    )
) ENABLE;
--------------------------------------------------------
--  Constraints for Table MODULO
--------------------------------------------------------

  ALTER TABLE "MODULO" MODIFY ("COD_MOD" NOT NULL ENABLE);
  ALTER TABLE "MODULO" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "MODULO" ADD CONSTRAINT "MODULO_PK" PRIMARY KEY ("COD_MOD") ENABLE;
--------------------------------------------------------
--  Constraints for Table DANIO_FALTANTE_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("TIPO_OBS" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("FEC_PEND" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("REG_DAN_FALT_FEC_REP" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" MODIFY ("REG_DAN_FALT_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" ADD CONSTRAINT "DANIO_FALTANTE_PENDIENTE_PK" PRIMARY KEY ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD", "TIPO_OBS") ENABLE;
--------------------------------------------------------
--  Constraints for Table DOMINIO
--------------------------------------------------------

  ALTER TABLE "DOMINIO" MODIFY ("COD_DOMINIO" NOT NULL ENABLE);
  ALTER TABLE "DOMINIO" MODIFY ("NOMBRE" NOT NULL ENABLE);
  ALTER TABLE "DOMINIO" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "DOMINIO" ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
  ALTER TABLE "DOMINIO" ADD CONSTRAINT "DOMINIO_PK" PRIMARY KEY ("COD_DOMINIO") ENABLE;
  ALTER TABLE "DOMINIO" ADD CHECK (
    estado IN (
        '1','2'
    )
) ENABLE;
--------------------------------------------------------
--  Constraints for Table DESOCUPACION_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "DESOCUPACION_PENDIENTE" MODIFY ("TIPO_OBS" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION_PENDIENTE" MODIFY ("FEC_PEN" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION_PENDIENTE" MODIFY ("DESOCUPACION_FEC_REGI" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION_PENDIENTE" MODIFY ("DESOCUPACION_SOLICITUD" NOT NULL ENABLE);
  ALTER TABLE "DESOCUPACION_PENDIENTE" ADD CONSTRAINT "DESOCUPACION_PENDIENTE_PK" PRIMARY KEY ("TIPO_OBS", "DESOCUPACION_FEC_REGI", "DESOCUPACION_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Constraints for Table AUTORIZACION_INDEMNIZACION
--------------------------------------------------------

  ALTER TABLE "AUTORIZACION_INDEMNIZACION" MODIFY ("COD_AUT_IND" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_INDEMNIZACION" MODIFY ("AREA_AUTO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_INDEMNIZACION" MODIFY ("FEC_AUTOR" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_INDEMNIZACION" MODIFY ("RESPONSABLE" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_INDEMNIZACION" MODIFY ("ESTADO" NOT NULL ENABLE);
  ALTER TABLE "AUTORIZACION_INDEMNIZACION" ADD CONSTRAINT "ARC_2" CHECK (
    (
        (
            sini_pend_sinie_fec_rep IS NOT NULL
        ) AND (
            sini_pend_sinie_solicitud IS NOT NULL
        ) AND (
            sini_pend_tip_obs IS NOT NULL
        ) AND (
            dan_falt_pend_fec_rep IS NULL
        ) AND (
            dan_falt_pend_solicitud IS NULL
        ) AND (
            dan_falt_pend_tipo_obs IS NULL
        )
    ) OR (
        (
            dan_falt_pend_fec_rep IS NOT NULL
        ) AND (
            dan_falt_pend_solicitud IS NOT NULL
        ) AND (
            dan_falt_pend_tipo_obs IS NOT NULL
        ) AND (
            sini_pend_sinie_fec_rep IS NULL
        ) AND (
            sini_pend_sinie_solicitud IS NULL
        ) AND (
            sini_pend_tip_obs IS NULL
        )
    )
) ENABLE;
  ALTER TABLE "AUTORIZACION_INDEMNIZACION" ADD CONSTRAINT "AUTORIZACION_INDEMNIZACION_PK" PRIMARY KEY ("COD_AUT_IND") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table ALERTA
--------------------------------------------------------

  ALTER TABLE "ALERTA" ADD CONSTRAINT "ALERTA_TRANSACCION_FK" FOREIGN KEY ("TRANSACCION_COD_TRAN")
	  REFERENCES "TRANSACCION" ("COD_TRAN") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table AUMENTO
--------------------------------------------------------

  ALTER TABLE "AUMENTO" ADD CONSTRAINT "AUMENTO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table AUMENTO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "AUMENTO_PENDIENTE" ADD CONSTRAINT "AUMENTO_PENDIENTE_AUMENTO_FK" FOREIGN KEY ("AUMENTO_FEC_AUMENTO", "AUMENTO_SOLICITUD")
	  REFERENCES "AUMENTO" ("FEC_AUMENTO", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table AUTORIZACION_DESOCUPACIOON
--------------------------------------------------------

  ALTER TABLE "AUTORIZACION_DESOCUPACIOON" ADD CONSTRAINT "AUTO_DESO_DESO_PEND_FK" FOREIGN KEY ("DESO_PEND_TIPO_OBS", "DESO_PEND_DESOC_FEC_REGI", "DESO_PEND_DESOC_SOLICITUD")
	  REFERENCES "DESOCUPACION_PENDIENTE" ("TIPO_OBS", "DESOCUPACION_FEC_REGI", "DESOCUPACION_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table AUTORIZACION_INDEMNIZACION
--------------------------------------------------------

  ALTER TABLE "AUTORIZACION_INDEMNIZACION" ADD CONSTRAINT "AUTO_INDEM_SINIESTRO_PEND_FK" FOREIGN KEY ("SINI_PEND_SINIE_FEC_REP", "SINI_PEND_SINIE_SOLICITUD", "SINI_PEND_TIP_OBS")
	  REFERENCES "SINIESTRO_PENDIENTE" ("SINIESTRO_FEC_REP", "SINIESTRO_SOLICITUD", "TIP_OBS") ENABLE;
  ALTER TABLE "AUTORIZACION_INDEMNIZACION" ADD CONSTRAINT "AUTO_IND_DANIO_FALT_PEND_FK" FOREIGN KEY ("DAN_FALT_PEND_FEC_REP", "DAN_FALT_PEND_SOLICITUD", "DAN_FALT_PEND_TIPO_OBS")
	  REFERENCES "DANIO_FALTANTE_PENDIENTE" ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD", "TIPO_OBS") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table AUTORIZACION_OPERACION
--------------------------------------------------------

  ALTER TABLE "AUTORIZACION_OPERACION" ADD CONSTRAINT "AUTO_OPER_AUM_PEND_FK" FOREIGN KEY ("AUM_PEND_AUM_FEC_AUMENTO", "AUM_PEND_AUME_SOLICITUD", "AUM_PEND_TIPO_OBS_AUM")
	  REFERENCES "AUMENTO_PENDIENTE" ("AUMENTO_FEC_AUMENTO", "AUMENTO_SOLICITUD", "TIPO_OBS_AUM") ENABLE;
  ALTER TABLE "AUTORIZACION_OPERACION" ADD CONSTRAINT "AUTO_OPER_ING_PEND_FK" FOREIGN KEY ("ING_PEND_INGR_FEC_REGISTRO_ING", "ING_PEND_INGR_SOLICITUD", "ING_PEND_TIPO_OBS_ING")
	  REFERENCES "INGRESO_PENDIENTE" ("INGRESO_FEC_REGISTRO_ING", "INGRESO_SOLICITUD", "TIPO_OBS_ING") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table DANIO_FALTANTE_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "DANIO_FALTANTE_PENDIENTE" ADD CONSTRAINT "DAN_FALT_PEND_REG_DAN_FALT_FK" FOREIGN KEY ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD")
	  REFERENCES "REGISTRO_DANIO_FALTANTE" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table DESISTIMIENTO
--------------------------------------------------------

  ALTER TABLE "DESISTIMIENTO" ADD CONSTRAINT "DESISTIMIENTO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table DESOCUPACION
--------------------------------------------------------

  ALTER TABLE "DESOCUPACION" ADD CONSTRAINT "DESOCUPACION_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table DESOCUPACION_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "DESOCUPACION_PENDIENTE" ADD CONSTRAINT "DESO_PEND_DESO_FK" FOREIGN KEY ("DESOCUPACION_FEC_REGI", "DESOCUPACION_SOLICITUD")
	  REFERENCES "DESOCUPACION" ("FEC_REGI", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table DOCUMENTO_NOTIFICACION
--------------------------------------------------------

  ALTER TABLE "DOCUMENTO_NOTIFICACION" ADD CONSTRAINT "DOCU_NOTI_NOTI_FK" FOREIGN KEY ("NOTIFICACION_SOLICITUD", "NOTIFICACION_FEC_NOTI")
	  REFERENCES "NOTIFICACION" ("SOLICITUD", "FEC_NOTI") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table DOCUMENTO_SOPORTE
--------------------------------------------------------

  ALTER TABLE "DOCUMENTO_SOPORTE" ADD CONSTRAINT "DOC_SOP_REG_DAN_FALT_FK" FOREIGN KEY ("REG_DAN_FALT_FEC_REP", "REG_DAN_FALT_SOLICITUD")
	  REFERENCES "REGISTRO_DANIO_FALTANTE" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table INGRESO
--------------------------------------------------------

  ALTER TABLE "INGRESO" ADD CONSTRAINT "INGRESO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table INGRESO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "INGRESO_PENDIENTE" ADD CONSTRAINT "INGRESO_PENDIENTE_INGRESO_FK" FOREIGN KEY ("INGRESO_FEC_REGISTRO_ING", "INGRESO_SOLICITUD")
	  REFERENCES "INGRESO" ("FEC_REGISTRO_ING", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table LISTA_DOCUMENTO
--------------------------------------------------------

  ALTER TABLE "LISTA_DOCUMENTO" ADD CONSTRAINT "LISTA_DOCUMENTO_SINIESTRO_FK" FOREIGN KEY ("SINIESTRO_FEC_REP", "SINI_SOL_SAI_SOLICITUD")
	  REFERENCES "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table MES_REGISTRADO
--------------------------------------------------------

  ALTER TABLE "MES_REGISTRADO" ADD CONSTRAINT "MES_REGISTRADO_SINIESTRO_FK" FOREIGN KEY ("SINIESTRO_FEC_REP", "SINI_SOL_SAI_SOLICITUD")
	  REFERENCES "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table MODULO_PERFIL
--------------------------------------------------------

  ALTER TABLE "MODULO_PERFIL" ADD CONSTRAINT "MODULO_PERFIL_MODULO_FK" FOREIGN KEY ("MODULO_COD_MOD")
	  REFERENCES "MODULO" ("COD_MOD") ENABLE;
  ALTER TABLE "MODULO_PERFIL" ADD CONSTRAINT "MODULO_PERFIL_PERFIL_FK" FOREIGN KEY ("PERFIL_COD_PERF")
	  REFERENCES "PERFIL" ("COD_PERF") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table REGISTRO_AMPARO_INTEGRAL
--------------------------------------------------------

  ALTER TABLE "REGISTRO_AMPARO_INTEGRAL" ADD CONSTRAINT "REG_AMPA_INTE_SOL_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table REGISTRO_DANIO_FALTANTE
--------------------------------------------------------

  ALTER TABLE "REGISTRO_DANIO_FALTANTE" ADD CONSTRAINT "REG_DAN_FALT_SOL_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table RETIRO
--------------------------------------------------------

  ALTER TABLE "RETIRO" ADD CONSTRAINT "RETIRO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table SERVICIO_PUBLICO
--------------------------------------------------------

  ALTER TABLE "SERVICIO_PUBLICO" ADD CONSTRAINT "SERV_PUB_REG_AMP_INTE_FK" FOREIGN KEY ("REG_AMP_INTE_FEC_REP", "REG_AMP_INT_SOLICITUD")
	  REFERENCES "REGISTRO_AMPARO_INTEGRAL" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table SINIESTRO
--------------------------------------------------------

  ALTER TABLE "SINIESTRO" ADD CONSTRAINT "SINIESTRO_SOLICITUD_SAI_FK" FOREIGN KEY ("SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "SOLICITUD_SAI" ("SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table SINIESTRO_PENDIENTE
--------------------------------------------------------

  ALTER TABLE "SINIESTRO_PENDIENTE" ADD CONSTRAINT "SINI_PEND_SINI_FK" FOREIGN KEY ("SINIESTRO_FEC_REP", "SINIESTRO_SOLICITUD")
	  REFERENCES "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table TRANSACCION
--------------------------------------------------------

  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_AUMENTO_FK" FOREIGN KEY ("AUMENTO_FEC_AUMENTO", "AUM_SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "AUMENTO" ("FEC_AUMENTO", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_DESISTIMIENTO_FK" FOREIGN KEY ("DESISTIMIENTO_FEC_REG", "DESIS_SOL_SAI_SOLICITUD")
	  REFERENCES "DESISTIMIENTO" ("FEC_REG", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_DESOCUPACION_FK" FOREIGN KEY ("DESOCUPACION_FEC_REGI", "DESO_SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "DESOCUPACION" ("FEC_REGI", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_INGRESO_FK" FOREIGN KEY ("INGRESO_FEC_REGISTRO_ING", "ING_SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "INGRESO" ("FEC_REGISTRO_ING", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_RETIRO_FK" FOREIGN KEY ("RETIRO_FECHA_RETIRO", "RETI_SOLICITUD_SAI_SOLICITUD")
	  REFERENCES "RETIRO" ("FECHA_RETIRO", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRANSACCION_SINIESTRO_FK" FOREIGN KEY ("SINIESTRO_FEC_REP", "SINIESTRO_SOL_SAI_SOLICITUD")
	  REFERENCES "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRAN_LOG_SERV_SIMI_FK" FOREIGN KEY ("LOG_SERV_SIMI_COD_LOG_SERV")
	  REFERENCES "LOG_SERVICIO_SIMI" ("COD_LOG_SERV") ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRAN_REG_AMP_INT_FK" FOREIGN KEY ("REG_AMPARO_INTEGRAL_FEC_REP", "REG_AMP_INTE_SOL_SAI_SOLICITUD")
	  REFERENCES "REGISTRO_AMPARO_INTEGRAL" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
  ALTER TABLE "TRANSACCION" ADD CONSTRAINT "TRAN_REG_DAN_FALT_FK" FOREIGN KEY ("REG_DANIO_FALT_FEC_REP", "REG_DAN_FAL_SOL_SAI_SOLICITUD")
	  REFERENCES "REGISTRO_DANIO_FALTANTE" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table USUARIO_PERFIL
--------------------------------------------------------

  ALTER TABLE "USUARIO_PERFIL" ADD CONSTRAINT "USUARIO_PERFIL_PERFIL_FK" FOREIGN KEY ("PERFIL_COD_PERF")
	  REFERENCES "PERFIL" ("COD_PERF") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table VAL_DOMINIO
--------------------------------------------------------

  ALTER TABLE "VAL_DOMINIO" ADD CONSTRAINT "VAL_DOMINIO_DOMINIO_FK" FOREIGN KEY ("DOMINIO_COD_DOMINIO")
	  REFERENCES "DOMINIO" ("COD_DOMINIO") ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table VALOR_REPORTADO
--------------------------------------------------------

  ALTER TABLE "VALOR_REPORTADO" ADD CONSTRAINT "VALOR_REPORTADO_SINIESTRO_FK" FOREIGN KEY ("SINIESTRO_FEC_REP", "SINI_SOL_SAI_SOLICITUD")
	  REFERENCES "SINIESTRO" ("FEC_REP", "SOLICITUD_SAI_SOLICITUD") ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_AUTO_DESOCUPA
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "TR_AUTO_DESOCUPA" 
   before insert on "AUTORIZACION_DESOCUPACIOON" 
   for each row 
begin  
   if inserting then 
      if :NEW."CODIGO_AUT_DES" is null then 
         select SEC_AUTO_DESOCU.nextval into :NEW."CODIGO_AUT_DES" from dual; 
      end if; 
   end if; 
end;
/
ALTER TRIGGER "TR_AUTO_DESOCUPA" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_AUTO_INDEMNIZA
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "TR_AUTO_INDEMNIZA" 
   before insert on AUTORIZACION_INDEMNIZACION
   for each row 
begin  
   if inserting then 
      if :NEW."COD_AUT_IND" is null then 
         select SEC_AUTO_INDEN.nextval into :NEW."COD_AUT_IND" from dual; 
      end if; 
   end if; 
end;
/
ALTER TRIGGER "TR_AUTO_INDEMNIZA" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TR_BI_LERR
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "TR_BI_LERR" 
   before insert on "LOG_ERROR" 
   for each row 
begin  
   if inserting then 
      if :NEW."ID_LOG" is null then 
         select SEQ_LOGERROR.nextval into :NEW."ID_LOG" from dual; 
      end if; 
   end if; 
end;
/
ALTER TRIGGER "TR_BI_LERR" ENABLE;
