--------------------------------------------------------
--  DDL for Table AUTORIZACION_INDEMNIZACION
--------------------------------------------------------

  CREATE TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION 
   (	COD_AUT_IND NUMBER(15,0), 
	AREA_AUTO VARCHAR2(10), 
	FEC_AUTOR DATE DEFAULT SYSDATE, 
	RESPONSABLE NUMBER(10,0), 
	ESTADO NUMBER(20,0), 
	TIPO_MOT NUMBER(20,0), 
	OBSERVACION VARCHAR2(400), 
	DAN_FALT_PEND_TIPO_OBS NUMBER(20,0), 
	DAN_FALT_PEND_FEC_REP DATE, 
	DAN_FALT_PEND_SOLICITUD NUMBER(10,0), 
	SINI_PEND_TIP_OBS NUMBER(20,0), 
	SINI_PEND_SINIE_FEC_REP DATE, 
	SINI_PEND_SINIE_SOLICITUD NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.COD_AUT_IND IS 'codigo autorizacion indenmnizacion - Codigo autoincremental de la tabla.';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.AREA_AUTO IS 'area autorizar - Dominio que establece quien va a realizar la autorización';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.FEC_AUTOR IS 'feccha auto - Campo donde se almacena la fecha y la hora en el que se proceso la autorizacion.';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.RESPONSABLE IS 'Campo donde se almacena el codigo del reponsable de la autorizacion/rechazo del pendiente.';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.ESTADO IS 'Campo que indica el estado de la autorizacion,si fue aprobada o rechazada.';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.TIPO_MOT IS 'tipo motivo - Dominio que indica el motivo por el cual esta siendo rechazada la novedad pendiente.';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.OBSERVACION IS 'Campo donde se almacena la observacion del rechazo o aprobacion del pendinte.';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.DAN_FALT_PEND_TIPO_OBS IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.DAN_FALT_PEND_FEC_REP IS 'fecha reporte - campo donde se registra la fecha del sistema en la cual se esta haciendo el reporte de danios y faltantes.';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.SINI_PEND_TIP_OBS IS 'tipo observacion - Dominio que indica la razon o la regla de negocio por la cual la solicitud quedo como pendiente';
   
   COMMENT ON COLUMN INDEMNIZA.AUTORIZACION_INDEMNIZACION.SINI_PEND_SINIE_FEC_REP IS 'fecha reporte - Fecha del sistema (sysdate) de cuando se hizo el reporte de sineistro';
   
   COMMENT ON TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION  IS 'Autorizacion Idenmnizacion - Tabla donde se registraran las autorizaciones realizadas para el reporte de siniestros,ya sea aprobar o rechazar la solicitud segun sea el caso.';
   
   
--------------------------------------------------------
--  Constraints for Table AUTORIZACION_INDEMNIZACION
--------------------------------------------------------

  ALTER TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION MODIFY (COD_AUT_IND NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION MODIFY (AREA_AUTO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION MODIFY (FEC_AUTOR NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION MODIFY (RESPONSABLE NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION MODIFY (ESTADO NOT NULL ENABLE);
  ALTER TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION ADD CONSTRAINT ARC_2 CHECK (
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
  ALTER TABLE INDEMNIZA.AUTORIZACION_INDEMNIZACION ADD CONSTRAINT AUTORIZACION_INDEMNIZACION_PK PRIMARY KEY (COD_AUT_IND) ENABLE;

--------------------------------------------------------
--  DDL for Index AUTO_INDEMNIZACION__IDXV1
--------------------------------------------------------

  CREATE INDEX INDEMNIZA.AUTO_INDEMNIZACION__IDXV1 ON INDEMNIZA.AUTORIZACION_INDEMNIZACION (SINI_PEND_SINIE_FEC_REP, SINI_PEND_SINIE_SOLICITUD, SINI_PEND_TIP_OBS) 
  ;

--------------------------------------------------------
--  DDL for Index AUTO_INDEMNIZACION__IDX
--------------------------------------------------------

  CREATE INDEX INDEMNIZA.AUTO_INDEMNIZACION__IDX ON INDEMNIZA.AUTORIZACION_INDEMNIZACION (DAN_FALT_PEND_FEC_REP, DAN_FALT_PEND_SOLICITUD, DAN_FALT_PEND_TIPO_OBS) 
  ;

