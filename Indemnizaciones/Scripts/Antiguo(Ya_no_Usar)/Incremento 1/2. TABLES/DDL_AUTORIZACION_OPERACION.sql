--------------------------------------------------------
--  DDL for Table AUTORIZACION_OPERACION
--------------------------------------------------------

  CREATE TABLE "AUTORIZACION_OPERACION" 
   (	"COD_AUTO_OPER" NUMBER(15,0), 
	"OBSERVACION" VARCHAR2(200), 
	"AREA_AUTO" VARCHAR2(10), 
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
--  DDL for Index AUTORIZACION_OPERACION__IDX
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTORIZACION_OPERACION__IDX" ON "AUTORIZACION_OPERACION" ("AUM_PEND_AUM_FEC_AUMENTO", "AUM_PEND_AUME_SOLICITUD", "AUM_PEND_TIPO_OBS_AUM") 
  ;

--------------------------------------------------------
--  DDL for Index AUTORIZACION_OPERACION__IDXV1
--------------------------------------------------------

  CREATE UNIQUE INDEX "AUTORIZACION_OPERACION__IDXV1" ON "AUTORIZACION_OPERACION" ("ING_PEND_INGR_FEC_REGISTRO_ING", "ING_PEND_INGR_SOLICITUD", "ING_PEND_TIPO_OBS_ING") 
  ;

